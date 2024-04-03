
abstract type AbstractMaiMethod end 

"""
    MaiG{P} <: AbstractMaiMethod
    MaiG(n::Int)
    MaiG(p::Vector{<:AbstractFloat})
"""
struct MaiG{P} <: AbstractMaiMethod
    n::Int
    p::P

    function MaiG(n, p)
        n, p = _checkmethod(n, p)
        new{typeof(p)}(n, p)
    end
end

# Algoritmo de cómputo de MAI-F con n segmentos marcados en las posiciones p
"""
    MaiF{P} <: AbstractMaiMethod
    MaiF(n::Int)
    MaiF(p::Vector{<:AbstractFloat})
"""
struct MaiF{P} <: AbstractMaiMethod
    n::Int
    p::P

    function MaiF(n, p)
        n, p = _checkmethod(n, p)
        new{typeof(p)}(n, p)
    end
end

"""
    MaiFP{P} <: AbstractMaiMethod
    MaiFP(n::Int)
    MaiFP(p::Vector{<:AbstractFloat})
"""
struct MaiFP{P} <: AbstractMaiMethod
    n::Int
    p::P

    function MaiFP(n, p)
        n, p = _checkmethod(n, p)
        new{typeof(p)}(n, p)
    end
end


# Check conditions for MAI methods
function _checkmethod(n, p)
    length(p) == n-1 || error("Incorrect size of quantiles vector")
    issorted(p) || error("Quantiles vector should be sorted")
    all(0 .<= p .<= 1) || error("Quantiles should be between 0 and 1")
    (iszero(first(p)) && isone(last(p))) && (p = p[2:end-1])
    n, p 
end

# Constructores para división equitativa de posiciones p
MaiF(n::Int) = MaiF(n, Float32.(collect(1/n:1/n:(n-1)/n)))
MaiG(n::Int) = MaiG(n, Float32.(collect(1/n:1/n:(n-1)/n)))
MaiFP(n::Int) = MaiFP(n, Float32.(collect(1/n:1/n:(n-1)/n)))
MaiF(p::AbstractVector)  = MaiF(length(p)+1, p)
MaiG(p::AbstractVector)  = MaiG(length(p)+1, p)
MaiFP(p::AbstractVector) = MaiFP(length(p)+1, p)

function Base.string(method::AbstractMaiMethod)
    algorithm = method isa MaiG ? "G" : (method isa MaiF ? "F" : "FP")
    if method.p isa StepRangeLen 
        return "($algorithm," * string(method.n) * ")"
    else
        return "($algorithm," * string(method.n) * "," * string(round.(method.p[2:end-1], digits=2)) * ")"
    end
end

function InflationCoreMai(data::CountryStructure, method::AbstractMaiMethod)
    if method isa MaiF 
        return InflationCoreMaiF(data, method.p)
    elseif method isa MaiG 
        return InflationCoreMaiG(data, method.p)
    elseif method isa MaiFP 
        return InflationCoreMaiFP(data, method.p)
    end
    error("No MAI method found")
end