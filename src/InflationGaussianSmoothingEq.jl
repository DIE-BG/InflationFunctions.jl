

"""
    InflationGSEq <: InflationFunction
    InflationGSEq(k, s1, s2, r=2)

Computes a Gaussian smoothing with equal weights according to quantile `k`, left-standard
deviation `s1`, and right-standard deviation `s2`. The item at the position of the `k`
quantile receives a higher weight and the items to the left or right are downweighted using
a Gaussian bell function with different standard deviations to the left and right. The bell
function is shaped by the power `r`.

If ``k`` is the desired centering quantile, the standard deviation is a simple piecewise
function defined by `s(x,k) = x <= p ? 100s1 : 100s2` and the smoothing function by `f(x,p,r)
= exp(-abs((x-p) / s(x,p))^r)`.
"""
Base.@kwdef struct InflationGSEq <: InflationFunction
    k::Float32
    s1::Float32
    s2::Float32
    r::Int
end

_validate_param(x::Real) = x > 1 ? x / 100 : x
InflationGSEq(k::Real, s1::Real,s2::Real, r::Int=2) = InflationGSEq(
    k = Float32(_validate_param(k)), 
    s1 = Float32(_validate_param(s1)), 
    s2 = Float32(_validate_param(s2)),
    r = r,
)

function InflationGSEq(params::Vector{<:Real}, r::Int=2)
    length(params) != 3 && error("Expected 3 parameters")
    InflationGSEq(convert.(Float32, params), r)
end

function (inflfn::InflationGSEq)(base::VarCPIBase{T}) where T     
    s1 = inflfn.s1
    s2 = inflfn.s2
    k = 100 * inflfn.k 
    r = inflfn.r

    # summary monthly inflation 
    vm = Vector{T}(undef, periods(base)) 

    # p is the index of the desired percentile
    n = items(base)
    cew = (100 / n) * (1:n)

    # Standard deviation
    s(x,k) = x <= k ? 100s1 : 100s2 
    # Gaussian smoothing function around k with power r
    f(x,k,r) = exp(-abs((x-k) / s(x,k))^r) 

    # For every t, we sort and smooth the weights to compute the summary
    Threads.@threads for i in 1:periods(base)
        v = @view base.v[i, :]

        o = sortperm(v)
        vo = v[o]

        # Apply smoothing while computing the summary 
        cnorm = sum(f(cew[j], k, r) for j in 1:n)
        @inbounds vm[i] = sum(vo[j] * f(cew[j], k, r) for j in 1:n) / cnorm 
    end

    vm
end

function measure_name(inflfn::InflationGSEq) 
    p = string(round(inflfn.k, digits=2))
    s1 = string(round(inflfn.s1, digits=2))
    s2 = string(round(inflfn.s2, digits=2))
    r = inflfn.r
    "Suavizamiento Gausiano Equiponderado ($p, $s1, $s2, $r)"
end

CPIDataBase.params(inflfn::InflationGSEq) = (inflfn.k, inflfn.s1, inflfn.s2, inflfn.r)