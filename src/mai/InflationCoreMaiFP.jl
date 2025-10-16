"""
    InflationCoreMaiFP <: InflationCoreMai <: InflationFunction 

    InflationCoreMaiFP(cst::CountryStructure, q::Vector{<:AbstractFloat})
    InflationCoreMaiFP(cst::CountryStructure, n::Int)
    InflationCoreMaiFP(vlp::Vector{T}, q::Vector{T})

Defines the core inflation function that uses the MAI-FP method.
"""
struct InflationCoreMaiFP{T <: AbstractFloat} <: InflationCoreMai
    vlp::Vector{T}  # historical distribution of monthly price changes
    q::Vector{T}    # quantiles used to perform the reweighing by segments
    vqlp::Vector{T} # quantiles monthly price changes of historical distribution

    function InflationCoreMaiFP(vlp, q)
        sort!(vlp)
        # Check q
        issorted(q) || error("Quantile vector should be ordered")
        all(0 .<= q .<= 1) || error("Quantile vector shuld have entries between 0 and 1")
        #Check that there are more than two segments
        length(filter(x -> x >= 0.01 && x <= 0.99, q)) >= 2 ||
            error("There should be at least three segments (i.e., length of quantiles vector should be at least 3)")


        F = eltype(vlp)
        nq = convert.(F, q)
        (iszero(first(nq)) && isone(last(nq))) && (nq = nq[2:(end - 1)])
        vqlp = quantile(vlp, nq)
        return new{F}(vlp, nq, vqlp)
    end
end

# Method to define Core Mai function with equidistant quantiles
InflationCoreMaiFP(cst::CountryStructure, n::Int) = InflationCoreMaiFP(cst, collect((1 / n):(1 / n):((n - 1) / n)))
# Define method to receive a CountryStructure and extract vlp and wlp
InflationCoreMaiFP(cst::CountryStructure, q::AbstractVector) = InflationCoreMaiFP(cst, collect(q))
function InflationCoreMaiFP(cst::CountryStructure, q::Vector{<:AbstractFloat})
    vlp, _ = historical_distr(cst)
    return InflationCoreMaiFP(vlp, q)
end

# Monthly price changes computed by this method
function (inflfn::InflationCoreMaiFP)(base::VarCPIBase{T}) where {T}
    mai_fp_mm = _mai_fp_mm(base, inflfn.q, inflfn.vlp)
    return mai_fp_mm
end

# Extend utility functions
CPIDataBase.measure_name(inflfn::InflationCoreMaiFP) = "MAI-FP " * _vecstr(inflfn.q)
CPIDataBase.measure_tag(inflfn::InflationCoreMaiFP) = "MAI-FP " * _vecstr(inflfn.q)
CPIDataBase.params(inflfn::InflationCoreMaiFP) = (inflfn.vlp, inflfn.q)
