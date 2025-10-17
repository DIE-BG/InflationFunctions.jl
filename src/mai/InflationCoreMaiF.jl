"""
    InflationCoreMaiF <: InflationCoreMai <: InflationFunction 

    InflationCoreMaiF(cst::CountryStructure, q::Vector{<:AbstractFloat})
    InflationCoreMaiF(cst::CountryStructure, n::Int)
    InflationCoreMaiF(vlp::Vector{T}, wlp::Vector{T}, q::Vector{T})

Defines the core inflation function that uses the MAI-F method.
"""
struct InflationCoreMaiF{T <: AbstractFloat} <: InflationCoreMai
    vlp::Vector{T}  # historical distribution of monthly price changes
    wlp::Vector{T}  # weights vector
    q::Vector{T}    # quantiles used to perform the reweighing by segments
    vqlp::Vector{T} # quantiles monthly price changes of historical distribution

    function InflationCoreMaiF(vlp, wlp, q)
        # Check vlp and wlp
        eltype(vlp) == eltype(wlp) || error("Type mismatch between distribution vector and weights vector.")
        length(vlp) == length(wlp) || error("Distribution and weights vectors should be the same length.")
        # Check q
        issorted(q) || error("Quantile vector should be ordered")
        all(0 .<= q .<= 1) || error("Quantile vector shuld have entries between 0 and 1")
        #Check that there are more than two segments
        length(filter(x -> x >= 0.01 && x <= 0.99, q)) >= 2 ||
            error("There should be at least three segments (at least two cut points between 0 and 1)")


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
InflationCoreMaiF(cst::CountryStructure, n::Int) = InflationCoreMaiF(cst, collect((1 / n):(1 / n):((n - 1) / n)))
# Define method to receive a CountryStructure and extract vlp and wlp
InflationCoreMaiF(cst::CountryStructure, q::AbstractVector) = InflationCoreMaiF(cst, collect(q))
function InflationCoreMaiF(cst::CountryStructure, q::Vector{<:AbstractFloat})
    vlp, wlp = historical_distr(cst)
    return InflationCoreMaiF(vlp, wlp, q)
end

# Monthly price changes computed by this method
function (inflfn::InflationCoreMaiF)(base::VarCPIBase{T}) where {T}
    mai_f_mm = _mai_f_mm(base, inflfn.q, inflfn.vlp, inflfn.wlp)
    return mai_f_mm
end

# Extend utility functions
CPIDataBase.measure_name(inflfn::InflationCoreMaiF) = "MAI-F " * _vecstr(inflfn.q)
CPIDataBase.measure_tag(inflfn::InflationCoreMaiF) = "MAI-F " * _vecstr(inflfn.q)
CPIDataBase.params(inflfn::InflationCoreMaiF) = (inflfn.vlp, inflfn.wlp, inflfn.q)
