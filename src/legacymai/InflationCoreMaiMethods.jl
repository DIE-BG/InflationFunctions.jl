# Funciones de apoyo para generar funciones de inflación MAI

# MAI-FG
InflationCoreMaiFG(n::Int) = InflationCoreMai(MaiFG(n))
InflationCoreMaiFG(q::Vector{T}) where {T <: AbstractFloat} = InflationCoreMai(MaiFG(T[0, q..., 1]))

# MAI-G
InflationCoreMaiG(n::Int) = InflationCoreMai(MaiG(n))
InflationCoreMaiG(q::Vector{T}) where {T <: AbstractFloat} = InflationCoreMai(MaiG(T[0, q..., 1]))

# MAI-FP
InflationCoreMaiF(n::Int) = InflationCoreMai(MaiF(n))
InflationCoreMaiF(q::Vector{T}) where {T <: AbstractFloat} = InflationCoreMai(MaiF(T[0, q..., 1]))
