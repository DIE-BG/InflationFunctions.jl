#Función de inflación de exclusión dinámica

#InflationDynamicExclusion.jl - Definición de exclusión dinámica

"""
    InflationDynamicExclusion <: InflationFunction

Función para computar la inflación de exclusión dinámica dado el factor inferior (`lower_factor`) y factor superior (`upper_factor`).

## Utilización

    function (inflfn::InflationDynamicExclusion)(base::VarCPIBase)

Define cómo opera `InflationDynamicExclusion` sobre un objeto de tipo VarCPIBase.

    function (inflfn::InflationDynamicExclusion)(cs::CountryStructure) 

Define cómo opera `InflationDynamicExclusion` sobre un objeto de tipo CountryStructure.

### Ejemplo
Cálculo el recorte dinámico simétrico (2, 2) la distribución de variaciones intermensuales ponderadas.

```julia-repl
julia> dynExfn = InflationDynamicExclusion(2, 2)
(::InflationDynamicExclusion) (generic function with 5 methods)
julia>dynExfn(gtdata) #gtdata es de tipo UniformCountryStructure
231×1 Matrix{Float32}:
 7.0480227
 7.3734045
 7.6767564
 7.6933146
 7.7317834
 ⋮
 1.0896564
 1.1332393
 1.0305643
 1.1091232
```
"""
Base.@kwdef struct InflationDynamicExclusion <: InflationFunction
    lower_factor::Float32
    upper_factor::Float32
end

# Método para recibir argumentos como par en una tupla.
InflationDynamicExclusion(factors::Tuple{Real, Real}) = InflationDynamicExclusion(
    convert(Float32, factors[1]),
    convert(Float32, factors[2])
)

# Método para recibir argumentos como par en una lista.
function (InflationDynamicExclusion)(factor_vec::Vector{<:Real})
    length(factor_vec) != 2 && return @error "Dimensión incorrectal del vector"
    return InflationDynamicExclusion(
        convert(Float32, factor_vec[1]),
        convert(Float32, factor_vec[2])
    )
end

function CPIDataBase.measure_name(inflfn::InflationDynamicExclusion)
    round_lower_factor, round_upper_factor = string.(
        round.([inflfn.lower_factor, inflfn.upper_factor], digits = 2)
    )
    return MEASURE_NAMES[(LANGUAGE, :InflationDynamicExclusion)] * "($(round_lower_factor), $(round_upper_factor))"
end
#tag
function CPIDataBase.measure_tag(inflfn::InflationDynamicExclusion)
    round_lower_factor, round_upper_factor = string.(
        round.( [inflfn.lower_factor, inflfn.upper_factor], digits = 2)
    )
    return "DynEx($(round_lower_factor),$(round_upper_factor))"
end


"""
    measure_tag(inflfn::InflationDynamicExclusion)

Indica qué medida se utiliza para una instancia de una función de inflación.

# Ejemplo
```julia-repl
julia> dynExfn = InflationDynamicExclusion(2, 2)
julia> measure_tag(dynExfn)
"DynEx(2.0,2.0)"
```
"""
# Extendemos `params`, que devuelve los parámetros de la medida de inflación
CPIDataBase.params(inflfn::InflationDynamicExclusion) = (inflfn.lower_factor, inflfn.upper_factor)

# Las funciones sobre VarCPIBase resumen en variaciones intermensuales
function (inflfn::InflationDynamicExclusion)(base::VarCPIBase)
    lower_factor = inflfn.lower_factor
    upper_factor = inflfn.upper_factor

    std_v = std(base.v, dims = 2)
    mean_v = mean(base.v, dims = 2)

    dynEx_filter = (mean_v - (lower_factor .* std_v)) .<=
        base.v .<=
        (mean_v + (upper_factor .* std_v))

    dynEx_w = base.w' .* dynEx_filter
    dynEx_w = dynEx_w ./ sum(dynEx_w, dims = 2)

    return dynEx_v = sum(
        base.v .* dynEx_w,
        dims = 2
    ) |> vec
end
