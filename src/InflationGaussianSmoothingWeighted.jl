"""
    InflationGSWeighted <: InflationFunction
    InflationGSWeighted(k, s1, s2, r=2)

Computes a Gaussian smoothing to the weights according to quantile `k`, left-standard
deviation `s1`, and right-standard deviation `s2`. The item at the position of the `k`
quantile receives a higher weight and the items to the left or right are downweighted using
a Gaussian bell function with different standard deviations to the left and right. The bell
function is shaped by the power `r`.

If ``k`` is the desired centering quantile, the standard deviation is a simple piecewise
function defined by `s(x,k) = x <= p ? 100s1 : 100s2` and the smoothing function by `f(x,p,r)
= exp(-abs((x-p) / s(x,p))^r)`.
"""
Base.@kwdef struct InflationGSWeighted <: InflationFunction
    k::Float32
    s1::Float32
    s2::Float32
    r::Float32
    function InflationGSWeighted(k::Real, s1::Real, s2::Real, r::Real)
        k > 0 || error("Center quantile should be positive")
        (s1 < 0 || s2 < 0) && error("Sides standard deviations should be positive")
        (r > 0) || error("Smooothing power should be positive")
        k = Float32(_percentiles2quantiles(k))
        s1 = Float32(_percentiles2quantiles(s1))
        s2 = Float32(_percentiles2quantiles(s2))
        return new(k, s1, s2, r)
    end

end

_percentiles2quantiles(x::Real) = x > 1 ? x / 100 : x

function (inflfn::InflationGSWeighted)(base::VarCPIBase{T}) where {T}
    s1 = inflfn.s1
    s2 = inflfn.s2
    k = 100inflfn.k
    r = inflfn.r

    # summary monthly inflation
    vm = Vector{T}(undef, periods(base))

    # p is the index of the desired quantile
    n = items(base)

    # Standard deviation
    s(x, k) = x <= k ? 100s1 : 100s2
    # Gaussian smoothing function around k with power r
    f(x, k, r) = exp(-abs((x - k) / s(x, k))^r)

    # For every t, we sort and smooth the weights to compute the summary
    Threads.@threads for i in 1:periods(base)
        v = @view base.v[i, :]
        w = base.w

        o = sortperm(v)
        vo = v[o]
        wo = w[o]
        cwo = cumsum(wo)
        ccwo = [i == 1 ? cwo[1] / 2 : cwo[i - 1] + wo[i] / 2 for i in 1:n] # centers

        # Apply smoothing while computing the summary
        cnorm = sum(wo[j] * f(ccwo[j], k, r) for j in 1:n)
        @inbounds vm[i] = sum(vo[j] * wo[j] * f(ccwo[j], k, r) for j in 1:n) / cnorm
    end

    return vm
end
#Name of measure
function measure_name(inflfn::InflationGSWeighted)
    p = string(round(inflfn.k, digits = 2))
    s1 = string(round(inflfn.s1, digits = 2))
    s2 = string(round(inflfn.s2, digits = 2))
    r = inflfn.r
    return MEASURE_NAMES[(LANGUAGE, :InflationGSWeighted)] * "($p, $s1, $s2, $r)"
end
#tags
function measure_tag(inflfn::InflationGSWeighted)
    p = string(round(inflfn.k, digits = 2))
    s1 = string(round(inflfn.s1, digits = 2))
    s2 = string(round(inflfn.s2, digits = 2))
    r = inflfn.r
    return "WGS-($p, $s1, $s2, $r)"
end

CPIDataBase.params(inflfn::InflationGSWeighted) = (inflfn.k, inflfn.s1, inflfn.s2, inflfn.r)
