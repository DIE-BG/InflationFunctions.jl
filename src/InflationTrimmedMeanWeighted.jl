"""
    InflationTrimmedMeanWeighted <: InflationFunction

    InflationTrimmedMeanWeighted(l1::Real, l2::Real)
    InflationTrimmedMeanWeighted(factor_vec::Vector{<:Real})

Función de inflación para computar la media truncada ponderada

# Ejemplo
```julia-repl
julia> mtfn = InflationTrimmedMeanWeighted(25,75.5)
(::InflationTrimmedMeanWeighted) (generic function with 5 methods)
```
"""
Base.@kwdef struct InflationTrimmedMeanWeighted <: InflationFunction
    l1::Float32
    l2::Float32
    function InflationTrimmedMeanWeighted(l1::Real, l2::Real)
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
function InflationTrimmedMeanWeighted(factor_vec::Vector{T}) where {T <: Real}
    length(factor_vec) != 2 && return @error "Dimensión incorrecta del vector"
    return InflationTrimmedMeanWeighted(factor_vec...) 
end

function measure_name(inflfn::InflationTrimmedMeanWeighted)
    l1 = string(round(inflfn.l1, digits = 2))
    l2 = string(round(inflfn.l2, digits = 2))
    return MEASURE_NAMES[(LANGUAGE, :InflationTrimmedMeanWeighted)] * "(" * l1 * ", " * l2 * ")"
end

#tag
function measure_tag(inflfn::InflationTrimmedMeanWeighted)
    l1 = string(round(inflfn.l1, digits = 2))
    l2 = string(round(inflfn.l2, digits = 2))
    return "WTM-(" * l1 * "," * l2 * ")"
end

# Extendemos `params`, que devuelve los parámetros de la medida de inflación
CPIDataBase.params(inflfn::InflationTrimmedMeanWeighted) = (inflfn.l1, inflfn.l2)


# Operación de InflationTrimmedMeanWeighted sobre VarCPIBase para obtener el
# resumen intermensual de esta metodología
function (inflfn::InflationTrimmedMeanWeighted)(base::VarCPIBase{T}) where {T}
    l1 = inflfn.l1
    l2 = inflfn.l2

    tm_mom = Vector{T}(undef, periods(base))

    # para cada t: creamos parejas de variaciones con pesos,
    # ordenamos de acuerdo a variaciones, truncamos
    # renormalizamos para que los pesos sumen 1
    # sumamos el producto de variaciones con pesos

    # Reservar la memoria para cómputos de media truncada
    g = items(base)
    sort_idx = zeros(Int, g)
    w_sorted_acum = zeros(T, g)
    w_sorted_renorm = zeros(T, g)

    for i in 1:periods(base)

        # Obtener índices de orden en sort_idx
        v_month = @view base.v[i, :]
        sortperm!(sort_idx, v_month)

        # Acumular las ponderaciones en w_sorted_acum
        w_sorted = @view base.w[sort_idx]
        cumsum!(w_sorted_acum, w_sorted)

        # Poner a cero las ponderaciones fuera de límites
        @inbounds for x in 1:g
            if w_sorted_acum[x] < l1 || w_sorted_acum[x] > l2
                w_sorted_acum[x] = 0
            else
                w_sorted_acum[x] = 1
            end
        end

        # Renormalizar las ponderaciones dentro de los límites
        w_sorted_renorm .= (w_sorted .* w_sorted_acum)
        w_sorted_renorm ./= sum(w_sorted_renorm)

        # Computar promedio ponderado de variaciones dentro de límites
        @inbounds tm_mom[i] = sum((@view v_month[sort_idx]) .* w_sorted_renorm)
    end

    return tm_mom
end
