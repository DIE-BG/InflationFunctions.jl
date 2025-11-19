"""
    InflationCoreMaiF <: InflationCoreMai <: InflationFunction 

    InflationCoreMaiF(cst::CountryStructure, q::Vector{<:AbstractFloat})
    InflationCoreMaiF(cst::CountryStructure, n::Int)
    InflationCoreMaiF(vlp::Vector{T}, q::Vector{T})

Defines the core inflation function that uses the Mai-F method.
"""
struct InflationCoreMaiF{T <: AbstractFloat} <: InflationCoreMai
    vlp::Vector{T}  # historical distribution of monthly price changes
    q::Vector{T}    # quantiles used to perform the reweighing by segments
    vqlp::Vector{T} # quantiles monthly price changes of historical distribution

    function InflationCoreMaiF(vlp, q)
        sort!(vlp)
        # Check q
        issorted(q) || error("Quantile vector should be ordered")
        all(0 .<= q .<= 1) || error("Quantile vector shuld have entries between 0 and 1")
        #Check that there are more than two segments
        length(q) >= 2 || error("There should be at least three segments (at least two cut points between 0 and 1)")


        F = eltype(vlp)
        nq = convert.(F, q)
        (iszero(first(nq)) && isone(last(nq))) && (nq = nq[2:(end - 1)])
        vqlp = quantile(vlp, nq)
        return new{F}(vlp, nq, vqlp)
    end
end

# Method to define Core Mai function with equidistant quantiles
InflationCoreMaiF(cst::CountryStructure, n::Int) = InflationCoreMaiF(cst, collect((1 / n):(1 / n):((n - 1) / n)))
# Define method to receive a CountryStructure and extract vlp and wlp
InflationCoreMaiF(cst::CountryStructure, q::AbstractVector) = InflationCoreMaiF(cst, collect(q))
function InflationCoreMaiF(cst::CountryStructure, q::Vector{<:AbstractFloat})
    vlp, _ = historical_distr(cst)
    return InflationCoreMaiF(vlp, q)
end

# Monthly price changes computed by this method
function (inflfn::InflationCoreMaiF)(base::VarCPIBase{T}) where {T}
    mai_f_mm = _mai_f_mm(base, inflfn.q, inflfn.vlp)
    return mai_f_mm
end

# Extend utility functions
CPIDataBase.measure_name(inflfn::InflationCoreMaiF) = MEASURE_NAMES[(LANGUAGE, :InflationCoreMaiF)] * _vecstr(inflfn.q)
CPIDataBase.measure_tag(inflfn::InflationCoreMaiF) = "Mai-F " * _vecstr(inflfn.q)
CPIDataBase.params(inflfn::InflationCoreMaiF) = (inflfn.vlp, inflfn.q)
