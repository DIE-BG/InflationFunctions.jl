"""
    InflationConstant <: InflationFunction 
    InflationConstant(c) 

Metodología de inflación constante con valor interanual `c`. 
"""
struct InflationConstant <: InflationFunction
    c::Float32
end
InflationConstant() = InflationConstant(1)

# Método para obtener la variación interanual constante igual a c
function (inflfn::InflationConstant)(cs::CountryStructure)
    t = infl_periods(cs::CountryStructure)
    return fill(eltype(cs)(inflfn.c), t)
end

# Variación intermensual correspondiente a la variación interanual constante igual a c
function (inflfn::InflationConstant)(base::VarCPIBase{T}) where {T}
    v = 100 * ((inflfn.c / 100 + 1)^(1 // 12) - 1)
    return fill(T(v), periods(base))
end

# Nombre de la medida
measure_name(inflfn::InflationConstant) = MEASURE_NAMES[(LANGUAGE, :InflationConstant)] * string(round(inflfn.c, digits = 2))

#tag
measure_tag(inflfn::InflationConstant) = "C" * string(round(inflfn.c, digits = 2))
