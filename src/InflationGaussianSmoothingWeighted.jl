

"""
    InflationGSWeighted <: InflationFunction
    InflationGSWeighted(k, s1, s2)

Computes a Gaussian smoothing to the weights according to quantile `k`, left-standard
deviation `s1`, and right-standard deviation `s2`. The item at the position of the `k`
quantile receives a higher weight and the items to the left or right are downweighted using
a Gaussian bell function with different standard deviations to the left and right.

There are ``n`` items in the CPI database of monthly price changes. If ``p`` is the index of
the desired quantile, the standard deviation is defined by `s(x,p) = x <= p ? s1*n : s2*n`
and the smoothing function by `f(x,p) = exp(-(x-p)^2 / s(x,p)^2)`.
"""
Base.@kwdef struct InflationGSWeighted <: InflationFunction
    k::Float32
    s1::Float32
    s2::Float32
end

InflationGSWeighted(k::Real, s1::Real,s2::Real) = InflationGSWeighted(
    k = Float32(k), 
    s1 = Float32(s1), 
    s2 = Float32(s2)
)

function InflationGSWeighted(params::Vector{<:Real})
    length(params) != 3 && error("Expected 3 parameters")
    InflationGSWeighted(convert.(Float32, params))
end

function (inflfn::InflationGSWeighted)(base::VarCPIBase{T}) where T     
    s1 = inflfn.s1
    s2 = inflfn.s2
    k = inflfn.k 

    # summary monthly inflation 
    vm = Vector{T}(undef, periods(base)) 

    # p is the index of the desired quantile
    n = items(base)

    # Standard deviation
    s(x,p) = x <= p ? s1*n : s2*n 
    # Gaussian smoothing function around p
    f(x,p) = exp(-(x-p)^2/s(x,p)^2) 

    # For every t, we sort and smooth the weights to compute the summary
    Threads.@threads for i in 1:periods(base)
        v = @view base.v[i, :]
        w = base.w 

        o = sortperm(v)
        vo = v[o]
        wo = w[o]
        
        p = findfirst(>=(100k), cumsum(wo))

        # Apply smoothing while computing the summary 
        cnorm = sum(wo[j] * f(j, p) for j in 1:n)
        @inbounds vm[i] = sum(vo[j] * wo[j] * f(j, p) for j in 1:n) / cnorm 
    end

    vm
end

function measure_name(inflfn::InflationGSWeighted) 
    p = string(round(inflfn.k, digits=2))
    s1 = string(round(inflfn.s1, digits=2))
    s2 = string(round(inflfn.s2, digits=2))
    "Suavizamiento Gausiano Ponderado ($p, $s1, $s2)"
end

CPIDataBase.params(inflfn::InflationGSWeighted) = (inflfn.k, inflfn.s1, inflfn.s2)