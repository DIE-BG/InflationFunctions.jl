# Funciones de apoyo para generar funciones de inflación MAI 

# MAI-F
InflationCoreMaiF(n::Int) = InflationCoreMai(MaiF(n))
InflationCoreMaiF(q::Vector{T}) where {T<:AbstractFloat} = InflationCoreMai(MaiF(T[0, q..., 1]))

# MAI-G
InflationCoreMaiG(n::Int) = InflationCoreMai(MaiG(n))
InflationCoreMaiG(q::Vector{T}) where {T<:AbstractFloat} = InflationCoreMai(MaiG(T[0, q..., 1]))

# MAI-FP
InflationCoreMaiFP(n::Int) = InflationCoreMai(MaiFP(n))
InflationCoreMaiFP(q::Vector{T}) where {T<:AbstractFloat} = InflationCoreMai(MaiFP(T[0, q..., 1]))