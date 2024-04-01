"""
    InflationFunctions

Funciones para computar estimadores muestrales de inflación. 
"""
module InflationFunctions

    using CPIDataBase
    using Statistics
    using StatsBase
    using SparseArrays
    using RecipesBase
    using Dates

    ## Métodos a extender 
    import CPIDataBase: measure_name, measure_tag, params
    _vecstr(q) = "(" * join(string.(round.(q, digits=2)), ",") * ")"

    ## Media simple interanual 
    export InflationSimpleMean
    include("InflationSimpleMean.jl")

    ## Media ponderada interanual 
    export InflationWeightedMean
    include("InflationWeightedMean.jl")

    ## Método de medias móviles y suavizamiento exponencial simple (SES)
    export InflationMovingAverage, InflationExpSmoothing
    include("InflationMovingAverage.jl")
    include("InflationExpSmoothing.jl")

    ## Percentiles equiponderados
    export InflationPercentileEq
    include("InflationPercentileEq.jl")

    ## Percentiles ponderados
    export InflationPercentileWeighted
    include("InflationPercentileWeighted.jl")

    ## Variación interanual IPC con cambio de base sintético 
    export InflationTotalRebaseCPI
    include("InflationTotalRebaseCPI.jl")

    ## Media Truncada Equiponderada 
    export InflationTrimmedMeanEq
    include("InflationTrimmedMeanEq.jl")

    ## Media Truncada Ponderada 
    export InflationTrimmedMeanWeighted
    include("InflationTrimmedMeanWeighted.jl")

    ## Exclusión Fija de gastos básicos
    export InflationFixedExclusion, InflationFixedExclusionCPI
    include("InflationFixedExclusionCPI.jl")
    include("InflationFixedExclusion.jl")

    ## Subyacente MAI (muestra ampliada implícitamente)
    # Legacy code
    module LegacyMai
         
        using SparseArrays
        using Statistics
        using CPIDataBase
        using RecipesBase
        using Dates

        # export MaiG, MaiF, MaiFP
        # export InflationCoreMai           # new efficient algorithms export this
        include("legacymai/TransversalDistr.jl")
        include("legacymai/renormalize.jl")
        include("legacymai/InflationCoreMai.jl")

        # Funciones de inflación MAI simplificadas
        # export InflationCoreMaiF, InflationCoreMaiG, InflationCoreMaiFP
        include("legacymai/InflationCoreMaiMethods.jl")
    end

    ## Efficient MAI algorithms
    export InflationCoreMaiF, InflationCoreMaiG, InflationCoreMaiFP
    include("mai/maifns.jl")
    include("mai/InflationCoreMaiG.jl")
    include("mai/InflationCoreMaiF.jl")
    include("mai/InflationCoreMaiFP.jl")

    ## Exclusión dinámica
    export InflationDynamicExclusion
    include("InflationDynamicExclusion.jl")

    ## Inflación constante 
    export InflationConstant
    include("InflationConstant.jl")

    ## Gaussian Smoothing 
    export InflationGSEq, InflationGSWeighted
    include("InflationGaussianSmoothingEq.jl")
    include("InflationGaussianSmoothingWeighted.jl")
    
    ## Etiquetas 
    include("inflation_tags.jl")

    ## Desarrollo 
    include("dev/totalcpi_methods.jl")

    ## Recetas para Gráficas
    include("recipes/plotrecipes.jl")

end
