"""
    InflationTrimmedMeanEq <: InflationFunction

    InflationTrimmedMeanEq(l1::Real,l2::Real)
    InflationTrimmedMeanWeighted(factor_vec::Vector{<:Real})

Función de inflación para computar la media truncada equiponderada

# Ejemplo 
```julia-repl
julia> mtfn = InflationTrimmedMeanEq(25, 75.5)
(::InflationTrimmedMeanEq) (generic function with 5 methods)
```
"""
Base.@kwdef struct InflationTrimmedMeanEq <: InflationFunction
    l1::Float32
    l2::Float32
    function InflationTrimmedMeanEq(l1::Real, l2::Real)
        (l2 > l1) || error("Trimmed mean percentiles/quantiles should be in order, l1 < l2")
        (l1 < 0 || l1 > 100 || l2 < 0 || l2 > 100) && error("Percentile/quantiles out of bounds")
        # Check for percentiles / quantiles
        if 0 < l1 < 1
            l1 = Float32(100 * l1)
        end
        if 0 < l2 < 1
            l2 = Float32(100 * l2)
        end
        return new(l1, l2)
    end
end

# Método para recibir argumentos en forma de vector
function InflationTrimmedMeanEq(factor_vec::Vector{T}) where {T <: Real}
    length(factor_vec) != 2 && return @error "Dimensión incorrecta del vector"
    return InflationTrimmedMeanEq(factor_vec...)
end

function measure_name(inflfn::InflationTrimmedMeanEq)
    l1 = string(round(inflfn.l1, digits = 2))
    l2 = string(round(inflfn.l2, digits = 2))
    return MEASURE_NAMES[(LANGUAGE, :InflationTrimmedMeanEq)] * "(" * l1 * ", " * l2 * ")"
end

#tag
function measure_tag(inflfn::InflationTrimmedMeanEq)
    l1 = string(round(inflfn.l1, digits = 2))
    l2 = string(round(inflfn.l2, digits = 2))
    return "EqTM-(" * l1 * "," * l2 * ")"
end


# Extendemos `params`, que devuelve los parámetros de la medida de inflación
CPIDataBase.params(inflfn::InflationTrimmedMeanEq) = (inflfn.l1, inflfn.l2)


# Operación de InflationTrimmedMeanEq sobre VarCPIBase para obtener el resumen
# intermensual de esta metodología
function (inflfn::InflationTrimmedMeanEq)(base::VarCPIBase{T}) where {T}
    # Obtener los percentiles de recorte
    l1 = inflfn.l1
    l2 = inflfn.l2

    # Determinamos en dónde truncar
    q1 = Int(ceil(length(base.w) * l1 / 100))
    q2 = Int(floor(length(base.w) * l2 / 100))
    tm_mom = Vector{T}(undef, periods(base))

    if q1 == 0
        q1 = 1
    end

    # para cada t: ordenamos, truncamos y obtenemos la media.
    Threads.@threads for i in 1:periods(base)

        # Creamos una vista de cada fila: ahora temporal almacena una referencia
        # a la fila de base.v, sin crear nueva memoria
        temporal = @view base.v[i, :]
        # Ordenamos el vector y almacenamos en uno nuevo: `sorted_data`
        sorted = sort(temporal)

        # No es necesario generar esta asignación porque la función mean puede
        # acceder a una vista del arreglo entre las posiciones q1 y q2, sin
        # alojar nueva memoria
        # temporal    = temporal[q1:q2]

        # Por lo que la siguiente operación es la de obtener el promedio entre
        # dichas posiciones, sin reservar nueva memoria
        @inbounds tm_mom[i] = mean(@view sorted[q1:q2])
    end
    return tm_mom
end


