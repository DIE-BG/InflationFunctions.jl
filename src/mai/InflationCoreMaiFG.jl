"""
    InflationCoreMaiFG <: InflationCoreMai <: InflationFunction 

    InflationCoreMaiFG(cst::CountryStructure, q::Vector{<:AbstractFloat})
    InflationCoreMaiFG(cst::CountryStructure, n::Int)
    InflationCoreMaiFG(vlp::Vector{T}, wlp::Vector{T}, q::Vector{T})

Defines the core inflation function that uses the Mai-FG method.
"""
struct InflationCoreMaiFG{T <: AbstractFloat} <: InflationCoreMai
    vlp::Vector{T}  # historical distribution of monthly price changes
    wlp::Vector{T}  # weights vector
    q::Vector{T}    # quantiles used to perform the reweighing by segments
    vqlp::Vector{T} # quantiles monthly price changes of historical distribution

    function InflationCoreMaiFG(vlp, wlp, q)
        # Check vlp and wlp
        eltype(vlp) == eltype(wlp) || error("Type mismatch between distribution vector and weights vector.")
        length(vlp) == length(wlp) || error("Distribution and weights vectors should be the same length.")
        # Check q
        issorted(q) || error("Quantile vector should be ordered")
        all(0 .<= q .<= 1) || error("Quantile vector shuld have entries between 0 and 1")
        #Check that there are more than two segments
        length(q) >= 2 || error("There should be at least three segments (at least two cut points between 0 and 1)")


        # Sort vlp and glp accordingly
        o = sortperm(vlp)
        vlp = vlp[o]
        wlp = wlp[o]

        F = eltype(vlp)
        nq = convert.(F, q)
        (iszero(first(nq)) && isone(last(nq))) && (nq = nq[2:(end - 1)])
        vqlp = quantile(vlp, aweights(wlp), nq)
        return new{F}(vlp, wlp, nq, vqlp)
    end
end

# Method to define Core Mai function with equidistant quantiles
InflationCoreMaiFG(cst::CountryStructure, n::Int) = InflationCoreMaiFG(cst, collect((1 / n):(1 / n):((n - 1) / n)))
# Define method to receive a CountryStructure and extract vlp and wlp
InflationCoreMaiFG(cst::CountryStructure, q::AbstractVector) = InflationCoreMaiFG(cst, collect(q))
function InflationCoreMaiFG(cst::CountryStructure, q::Vector{<:AbstractFloat})
    vlp, wlp = historical_distr(cst)
    return InflationCoreMaiFG(vlp, wlp, q)
end

# Monthly price changes computed by this method
function (inflfn::InflationCoreMaiFG)(base::VarCPIBase{T}) where {T}
    mai_fg_mm = _mai_fg_mm(base, inflfn.q, inflfn.vlp, inflfn.wlp)
    return mai_fg_mm
end

# Extend utility functions
CPIDataBase.measure_name(inflfn::InflationCoreMaiFG) = MEASURE_NAMES[(LANGUAGE, :InflationCoreMaiFG)] * _vecstr(inflfn.q)
CPIDataBase.measure_tag(inflfn::InflationCoreMaiFG) = "Mai-FG " * _vecstr(inflfn.q)
CPIDataBase.params(inflfn::InflationCoreMaiFG) = (inflfn.vlp, inflfn.wlp, inflfn.q)
