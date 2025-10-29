# Defines the set of available languages
LANGUAGES = [:english, :spanish]

# Redefine the measure_name for CPI inflation
CPIDataBase.measure_name(::InflationTotalCPI) = MEASURE_NAMES[(LANGUAGE, :InflationTotalCPI)]

"""
    set_language!(language::Symbol)
Changes the measure name string language. Currently available only in `:english`
and `:spanish`
"""
function set_language!(language::Symbol)
    (language in LANGUAGES) || error("Non-existent language")
    return global LANGUAGE = language
end

MEASURE_NAMES = Dict(
    (:spanish, :InflationTotalCPI) => "Variación interanual IPC",
    (:english, :InflationTotalCPI) => "CPI inflation",
    (:spanish, :InflationConstant) => "Inflación constante al ",
    (:english, :InflationConstant) => "Year-on-year Constant Inflation at ",
    (:spanish, :InflationDynamicExclusion) => "Exclusión dinámica ",
    (:english, :InflationDynamicExclusion) => "Dynamic Exclusion ",
    (:spanish, :InflationExpSmoothing) => "Exponential Smoothing with ",
    (:english, :InflationExpSmoothing) => "Suavizamiento exponencial con ",
    (:spanish, :InflationFixedExclusion) => "Exclusión fija (intermensual) ",
    (:english, :InflationFixedExclusion) => "Fixed Exclusion (month-on-month) ",
    (:spanish, :InflationFixedExclusionCPI) => "Exclusión fija ",
    (:english, :InflationFixedExclusionCPI) => "Fixed Exclusion ",
    (:spanish, :InflationGSEq) => "Suavizamiento gaussiano equiponderado ",
    (:english, :InflationGSEq) => "Unweighted Gausssian Smoothing ",
    (:spanish, :InflationGSWeighted) => "Suavizamiento gaussiano ponderado ",
    (:english, :InflationGSWeighted) => "Weighted Gausssian Smoothing ",
    (:spanish, :InflationMovingAverage) => "Media móvil de ",
    (:english, :InflationMovingAverage) => "Moving Average of ",
    (:spanish, :InflationPercentileEq) => "Percentil equiponderado ",
    (:english, :InflationPercentileEq) => "Unweighted Percentile ",
    (:spanish, :InflationPercentileWeighted) => "Percentil ponderado ",
    (:english, :InflationPercentileWeighted) => "Weighted Percentile ",
    (:spanish, :InflationTotalRebaseCPI) => "Variación interanual IPC con cambios de base sintéticos ",
    (:english, :InflationTotalRebaseCPI) => "CPI Inflation with Synthetic Rebasing ",
    (:spanish, :InflationTrimmedMeanEq) => "Media truncada equiponderada ",
    (:english, :InflationTrimmedMeanEq) => "Unweighted Trimmed Mean ",
    (:spanish, :InflationTrimmedMeanWeighted) => "Media truncada equiponderada ",
    (:english, :InflationTrimmedMeanWeighted) => "Weighted Trimmed Mean ",
    (:spanish, :InflationSimpleMean) => "Media simple interanual",
    (:english, :InflationSimpleMean) => "Year-on-year Simple Mean",
    (:spanish, :InflationWeightedMean) => "Media ponderada interanual",
    (:english, :InflationWeightedMean) => "Year-on-year Weighted Average",
    (:spanish, :InflationCoreMaiF) => "Subyacente MAI-F ",
    (:english, :InflationCoreMaiF) => "Core MAI-F ",
    (:spanish, :InflationCoreMaiFG) => "Subyacente MAI-FG ",
    (:english, :InflationCoreMaiFG) => "Core MAI-FG ",
    (:spanish, :InflationCoreMaiG) => "Subyacente MAI-G ",
    (:english, :InflationCoreMaiG) => "Core MAI-G ",
)
