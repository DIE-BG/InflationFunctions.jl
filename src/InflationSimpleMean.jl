# #Inflación de media simple
# InflationSimpleMean.jl - Función de inflación de media simple interanual

"""
    InflationSimpleMean <: InflationFunction
Función de inflación para computar la media simple interanual.
"""
struct InflationSimpleMean <: InflationFunction
end

# 2. Extender el método de nombre
measure_name(::InflationSimpleMean) = "Interannual Simple Mean"

# Tag for inflation measure
measure_tag(::InflationSimpleMean) = "SM"

# Define cómo opera InflationSimpleMean sobre un objeto de tipo VarCPIBase.
function (inflfn::InflationSimpleMean)(base::VarCPIBase{T}) where {T}
    # For the first 11 observations
    nobs = size(base.v, 1)
    if nobs < 12
        simpmean = mean(base.v, dims = 2)
        return simpmean
    end

    #Obtener el indice correspondiente a las variaciones intermensuales
    indmat = capitalize(base.v)
    #Cálculo de la variación interanual
    y2ymat = varinteran(indmat)
    #Cálculo de la media simple de las variaciones interanuales
    y2ysimpmean = mean(y2ymat, dims = 2)
    #Utilizar el índice de la media simple de las variaciones intermensuales de los primeros
    #11 meses para completar la serie del índice de media simple de variaciones interanuales
    m2msimpmean = mean(base.v, dims = 2)
    simpmeanind = zeros(T, periods(base) + 1); simpmeanind[1] = 100
    simpmeanind[2:12] = capitalize(m2msimpmean[1:11])
    for j in 13:(periods(base) + 1)
        simpmeanind[j] = (y2ysimpmean[j - 12] / 100 + 1) * simpmeanind[j - 12]
    end
    #Cálculo de la variación intermensual del índice de media simple
    simpmean = varinterm(simpmeanind[2:end])
    return simpmean
end
