using CPIDataBase
using CPIDataBase.TestHelpers
using InflationFunctions
using Test
using CPIDataGT
CPIDataGT.load_data()

@testset "inflationfunctions.jl" begin

    @testset "inflationfunction method names and tags" begin
        inflation_functions = [
            InflationConstant(2), 
            InflationDynamicExclusion(1.5, 1.5), 
            InflationExpSmoothing(InflationTotalCPI(), 0.4),
            InflationFixedExclusion([1]), 
            InflationFixedExclusionCPI([1]),
            InflationGSEq(70, 0.1, 0.2, 2),
            InflationGSWeighted(70, 0.1, 0.2, 2),
            InflationMovingAverage(InflationTotalCPI(), 12),
            InflationPercentileEq(70), 
            InflationPercentileWeighted(70), 
            InflationSimpleMean(),
            InflationWeightedMean(), 
            InflationTotalRebaseCPI(36,2), 
            InflationTrimmedMeanEq(25, 75),
            InflationTrimmedMeanWeighted(25, 75),
            InflationCoreMaiF(GTDATA24, 10),
            InflationCoreMaiFG(GTDATA24, 10),
            InflationCoreMaiG(GTDATA24, 10),
        ]
        # test all InflationFunction objects for proper method_name and method_tag implementation
        for inflfn in inflation_functions
            @test measure_name(inflfn) isa String
            @test measure_tag(inflfn) isa String
        end
        
    end
end

# Pruebas sobre medidas de inflación. Se debe probar instanciar los tipos y que
# definan sus métodos sobre los objetos de CPIDataBase
@testset "InflationSimpleMean" begin
    # Instanciar un tipo
    simplefn = InflationSimpleMean()
    @test simplefn isa InflationSimpleMean

    # Probar que esté definido el método para obtener su nombre
    @test measure_name(simplefn) isa String
    @test measure_tag(simplefn) isa String

    # Probar con bases del IPC con variaciones intermensuales iguales a cero.
    # Estas pruebas ayudan a verificar que la función de inflación se pueda
    # llamar sobre los tipos correctos

    zero_base = getzerobase()
    m_traj_infl = simplefn(zero_base)
    # Probamos que el resumen intermensual sea igual a cero
    @test all(m_traj_infl .≈ 0)

    # Obtenemos un UniformCountryStructure con dos bases y todas las variaciones
    # intermensuales iguales a cero
    zero_cst = getzerocountryst()
    traj_infl = simplefn(zero_cst)

    # Probamos que la trayectoria de inflación sea más larga que el resumen
    # intermensual de una sola base
    @test length(traj_infl) > length(m_traj_infl)

    # Probamos que la trayectoria de inflación sea igual a cero
    @test all(traj_infl .≈ 0)
end

## Pruebas para Inflación de Exclusión Fija de Gastos Básicos
@testset "InflationFixedExclusionCPI" begin
    # Creación de vectores de exclusión de prueba
    exc00 = [10, 100, 200, 218]
    exc10 = [20, 120, 220, 279]
    # Instanciar un tipo
    simplefn = InflationFixedExclusionCPI(exc00, exc10)
    @test simplefn isa InflationFixedExclusionCPI

    # Probar que esté definido el método para obtener su nombre
    @test measure_name(simplefn) isa String
    @test measure_tag(simplefn) isa String

    # Probar con bases del IPC con variaciones intermensuales iguales a cero.
    # Estas pruebas ayudan a verificar que la función de inflación se pueda
    # llamar sobre los tipos correctos

    zero_base = getzerobase()

    m_traj_infl = simplefn(zero_base, 1)
    # Probamos que el resumen intermensual sea igual a cero
    @test all(isapprox.(m_traj_infl, 0; atol = 0.0001))

    # Obtenemos un UniformCountryStructure con dos bases y todas las variaciones
    # intermensuales iguales a cero
    zero_cst = getzerocountryst()
    traj_infl = simplefn(zero_cst)

    # Probamos que la trayectoria de inflación sea más larga que el resumen
    # intermensual de una sola base
    @test length(traj_infl) > length(m_traj_infl)

    @test all(isapprox.(traj_infl, 0; atol = 0.0001))

end

# Función de inflación por percentiles equiponderados
# prueba con percentil 70
@testset "InflationPercentileEq" begin
    # Instanciar un tipo
    percEqfn = InflationPercentileEq(70)
    @test percEqfn isa InflationPercentileEq

    # Probar que esté definido el método para obtener su nombre
    @test measure_name(percEqfn) isa String
    @test measure_tag(percEqfn) isa String

    # Probar con bases del IPC con variaciones intermensuales iguales a cero.
    # Estas pruebas ayudan a verificar que la función de inflación se pueda
    # llamar sobre los tipos correctos

    zero_base = getzerobase()
    m_traj_infl = percEqfn(zero_base)
    # Probamos que el resumen intermensual sea igual a cero
    @test all(m_traj_infl .≈ 0)

    # Obtenemos un UniformCountryStructure con dos bases y todas las variaciones
    # intermensuales iguales a cero
    zero_cst = getzerocountryst()
    traj_infl = percEqfn(zero_cst)

    # Probamos que la trayectoria de inflación sea más larga que el resumen
    # intermensual de una sola base
    @test length(traj_infl) > length(m_traj_infl)

    # Probamos que la trayectoria de inflación sea igual a cero
    @test all(traj_infl .≈ 0)
end


# Función de inflación por percentiles ponderados
# prueba con percentil 70
@testset "InflationPercentileWeighted" begin
    # Instanciar un tipo
    percfn = InflationPercentileWeighted(70)
    @test percfn isa InflationPercentileWeighted

    # Probar que esté definido el método para obtener su nombre
    @test measure_name(percfn) isa String
    @test measure_tag(percfn) isa String

    # Probar con bases del IPC con variaciones intermensuales iguales a cero.
    # Estas pruebas ayudan a verificar que la función de inflación se pueda
    # llamar sobre los tipos correctos

    zero_base = getzerobase()
    m_traj_infl = percfn(zero_base)
    # Probamos que el resumen intermensual sea igual a cero
    @test all(m_traj_infl .≈ 0)

    # Obtenemos un UniformCountryStructure con dos bases y todas las variaciones
    # intermensuales iguales a cero
    zero_cst = getzerocountryst()
    traj_infl = percfn(zero_cst)

    # Probamos que la trayectoria de inflación sea más larga que el resumen
    # intermensual de una sola base
    @test length(traj_infl) > length(m_traj_infl)

    # Probamos que la trayectoria de inflación sea igual a cero
    @test all(traj_infl .≈ 0)
end

@testset "InflationDynamicExclusion" begin
    # Instanciar un tipo
    dynExfn = InflationDynamicExclusion(2, 2)
    @test dynExfn isa InflationDynamicExclusion

    # Probar que esté definido el método para obtener su nombre
    @test measure_name(dynExfn) isa String
    @test measure_tag(dynExfn) isa String

    # Probar con bases del IPC con variaciones intermensuales iguales a cero.
    # Estas pruebas ayudan a verificar que la función de inflación se pueda
    # llamar sobre los tipos correctos

    zero_base = getzerobase()
    m_traj_infl = dynExfn(zero_base)
    # Probamos que el resumen intermensual sea igual a cero
    @test all(m_traj_infl .≈ 0)

    # Obtenemos un UniformCountryStructure con dos bases y todas las variaciones
    # intermensuales iguales a cero
    zero_cst = getzerocountryst()
    traj_infl = dynExfn(zero_cst)

    # Probamos que la trayectoria de inflación sea más larga que el resumen
    # intermensual de una sola base
    @test length(traj_infl) > length(m_traj_infl)

    # Probamos que la trayectoria de inflación sea igual a cero
    @test all(traj_infl .≈ 0)
end

@testset "InflationGaussianSmoothingEq" begin
    # Instantiate a type
    gaussSmoothEqInfl = InflationGSEq(50.0, 0.5, 0.5, 2)
    @test gaussSmoothEqInfl isa InflationGSEq

    # Test that the method to get its name is defined
    @test measure_name(gaussSmoothEqInfl) isa String
    @test measure_tag(gaussSmoothEqInfl) isa String

    # Test with CPI bases with zero month-to-month variations.

    zero_base = getzerobase()
    m_traj_infl = gaussSmoothEqInfl(zero_base)
    @test all(m_traj_infl .≈ 0)

    # Get a UniformCountryStructure with two bases and all
    # month-to-month variations equal to zero
    zero_cst = getzerocountryst()
    traj_infl = gaussSmoothEqInfl(zero_cst)

    # Test that the inflation trajectory is longer than the month-to-month summary
    @test length(traj_infl) > length(m_traj_infl)

    # Test that the inflation trajectory is equal to zero
    @test all(traj_infl .≈ 0)

    # Test with CPI bases with Guatemalan data
    base_gt = GT00
    cst_gt = GTDATA24

    @test gaussSmoothEqInfl(base_gt) isa AbstractVector
    @test gaussSmoothEqInfl(cst_gt) isa AbstractVector
end


@testset "InflationGaussianSmoothingWeighted" begin
    # Instantiate a type
    gaussSmoothWeighInfl = InflationGSWeighted(0.5, 0.5, 0.5, 2)
    @test gaussSmoothWeighInfl isa InflationGSWeighted

    # Test that the method to get its name is defined
    @test measure_name(gaussSmoothWeighInfl) isa String
    @test measure_tag(gaussSmoothWeighInfl) isa String

    # Test with CPI bases with zero month-to-month variations.

    zero_base = getzerobase()
    m_traj_infl = gaussSmoothWeighInfl(zero_base)
    @test all(m_traj_infl .≈ 0)

    # Get a UniformCountryStructure with two bases and all
    # month-to-month variations equal to zero
    zero_cst = getzerocountryst()
    traj_infl = gaussSmoothWeighInfl(zero_cst)

    # Test that the inflation trajectory is longer than the month-to-month summary
    @test length(traj_infl) > length(m_traj_infl)

    # Test that the inflation trajectory is equal to zero
    @test all(traj_infl .≈ 0)

    # Test with CPI bases with Guatemalan data
    base_gt = GT00
    cst_gt = GTDATA24

    @test gaussSmoothWeighInfl(base_gt) isa AbstractVector
    @test gaussSmoothWeighInfl(cst_gt) isa AbstractVector
    # Test that legacy MAI code and new MAI code give the same results
end

# Pruebas para Inflación subyacente MAI (muestra ampliada implícitamente)

@testset "InflationCoreMaiG" begin
    # Instanciar un tipo
    cst_test = GTDATA24
    base_test = GT10
    vlp = vec(base_test.v)
    wlp = repeat(base_test.w, periods(base_test))
    inflmaig_with_base_q = InflationCoreMaiG(vlp, wlp, 0:0.2:1)
    inflmaig_with_cst_q = InflationCoreMaiG(cst_test, 0:0.2:1)
    inflmaig_with_cst_n = InflationCoreMaiG(cst_test, 5)

    @test inflmaig_with_base_q isa InflationCoreMaiG
    @test inflmaig_with_cst_q isa InflationCoreMaiG
    @test inflmaig_with_cst_n isa InflationCoreMaiG

    # Test that function has correct name and tag
    @test measure_name(inflmaig_with_base_q) isa String
    @test measure_tag(inflmaig_with_base_q) isa String


    # Test that function can be called on base and countryst


    m_traj_infl = inflmaig_with_base_q(base_test)
    @test m_traj_infl isa AbstractVector
    # Obtenemos un UniformCountryStructure con dos bases y todas las variaciones
    # intermensuales
    traj_infl_n = inflmaig_with_cst_n(cst_test)
    traj_infl_q = inflmaig_with_cst_q(cst_test)
    @test traj_infl_n isa AbstractVector

    @test all((traj_infl_n - traj_infl_q) .== 0)
    # Testa that trajectory is longer than monthly summary
    @test length(traj_infl_n) > length(m_traj_infl)
end


## MAI-FG
@testset "InflationCoreMaiFG" begin
    # Instanciar un tipo
    cst_test = GTDATA24
    base_test = GT10
    vlp = vec(base_test.v)
    wlp = repeat(base_test.w, periods(base_test))
    inflMaiFG_with_base_q = InflationCoreMaiFG(vlp, wlp, 0:0.2:1)
    inflMaiFG_with_cst_q = InflationCoreMaiFG(cst_test, 0:0.2:1)
    inflMaiFG_with_cst_n = InflationCoreMaiFG(cst_test, 5)

    @test inflMaiFG_with_base_q isa InflationCoreMaiFG
    @test inflMaiFG_with_cst_q isa InflationCoreMaiFG
    @test inflMaiFG_with_cst_n isa InflationCoreMaiFG

    # Test that function has correct name and tag
    @test measure_name(inflMaiFG_with_base_q) isa String
    @test measure_tag(inflMaiFG_with_base_q) isa String


    # Test that function can be called on base and countryst


    m_traj_infl = inflMaiFG_with_base_q(base_test)
    @test m_traj_infl isa AbstractVector
    # Obtenemos un UniformCountryStructure con dos bases y todas las variaciones
    # intermensuales
    traj_infl_n = inflMaiFG_with_cst_n(cst_test)
    traj_infl_q = inflMaiFG_with_cst_q(cst_test)
    @test traj_infl_n isa AbstractVector

    @test all((traj_infl_n - traj_infl_q) .== 0)
    # Testa that trajectory is longer than monthly summary
    @test length(traj_infl_n) > length(m_traj_infl)

end

## MAI-F
@testset "InflationCoreMaiF" begin
    # Instanciar un tipo
    cst_test = GTDATA24
    base_test = GT10
    vlp = vec(base_test.v)
    inflMaiF_with_base_q = InflationCoreMaiF(vlp, 0:0.2:1)
    inflMaiF_with_cst_q = InflationCoreMaiF(cst_test, 0:0.2:1)
    inflMaiF_with_cst_n = InflationCoreMaiF(cst_test, 5)

    @test inflMaiF_with_base_q isa InflationCoreMaiF
    @test inflMaiF_with_cst_q isa InflationCoreMaiF
    @test inflMaiF_with_cst_n isa InflationCoreMaiF

    # Test that function has correct name and tag
    @test measure_name(inflMaiF_with_base_q) isa String
    @test measure_tag(inflMaiF_with_base_q) isa String

    # Test that function can be called on base and countryst

    m_traj_infl = inflMaiF_with_base_q(base_test)
    @test m_traj_infl isa AbstractVector
    # Obtenemos un UniformCountryStructure con dos bases y todas las variaciones
    # intermensuales
    traj_infl_n = inflMaiF_with_cst_n(cst_test)
    traj_infl_q = inflMaiF_with_cst_q(cst_test)
    @test traj_infl_n isa AbstractVector

    @test all((traj_infl_n - traj_infl_q) .== 0)
    # Testa that trajectory is longer than monthly summary
    @test length(traj_infl_n) > length(m_traj_infl)

end


@testset "InflationMAI New vrs.Legacy Code" begin

    using InflationFunctions.LegacyMai
    using Statistics
    # Test MAI-G with legacy code
    inflmaig_legacy = InflationFunctions.LegacyMai.InflationCoreMaiG(5)

    m_traj_inflMaiG_legacy = inflmaig_legacy(GTDATA)
    m_traj_inflMaiG_legacy_23 = inflmaig_legacy(GTDATA23)
    m_traj_inflMaiG_legacy_24 = inflmaig_legacy(GTDATA24)


    # Test MAI-G with new code
    inflmaig_new = InflationCoreMaiG(GTDATA, 5)
    inflmaig_new_23 = InflationCoreMaiG(GTDATA23, 5)
    inflmaig_new_24 = InflationCoreMaiG(GTDATA24, 5)

    m_traj_inflMaiG_new = inflmaig_new(GTDATA)
    m_traj_inflMaiG_new_23 = inflmaig_new_23(GTDATA23)
    m_traj_inflMaiG_new_24 = inflmaig_new_24(GTDATA24)

    @test mean(abs.(m_traj_inflMaiG_legacy - m_traj_inflMaiG_new)) < 0.3
    @test mean(abs.(m_traj_inflMaiG_legacy_23 - m_traj_inflMaiG_new_23)) < 0.1
    @test mean(abs.(m_traj_inflMaiG_legacy_24 - m_traj_inflMaiG_new_24)) < 0.1

    ## Test MAI-FG with legacy code and new code

    inflMaiFG_legacy = InflationFunctions.LegacyMai.InflationCoreMaiFG(5)

    m_traj_inflMaiFG_legacy = inflMaiFG_legacy(GTDATA)
    m_traj_inflMaiFG_legacy_23 = inflMaiFG_legacy(GTDATA23)
    m_traj_inflMaiFG_legacy_24 = inflMaiFG_legacy(GTDATA24)

    # Test MAI-FG with new code
    inflMaiFG_new = InflationCoreMaiFG(GTDATA, 5)
    inflMaiFG_new_23 = InflationCoreMaiFG(GTDATA23, 5)
    inflMaiFG_new_24 = InflationCoreMaiFG(GTDATA24, 5)

    m_traj_inflMaiFG_new = inflMaiFG_new(GTDATA)
    m_traj_inflMaiFG_new_23 = inflMaiFG_new_23(GTDATA23)
    m_traj_inflMaiFG_new_24 = inflMaiFG_new_24(GTDATA24)

    @test mean(abs.(m_traj_inflMaiFG_legacy - m_traj_inflMaiFG_new)) < 0.1
    @test mean(abs.(m_traj_inflMaiFG_legacy_23 - m_traj_inflMaiFG_new_23)) < 0.1
    @test mean(abs.(m_traj_inflMaiFG_legacy_24 - m_traj_inflMaiFG_new_24)) < 0.1

    ## Test MAI-F with legacy code and new code

    inflMaiF_legacy = InflationFunctions.LegacyMai.InflationCoreMaiF(5)

    m_traj_inflMaiF_legacy = inflMaiF_legacy(GTDATA)
    m_traj_inflMaiF_legacy_23 = inflMaiF_legacy(GTDATA23)
    m_traj_inflMaiF_legacy_24 = inflMaiF_legacy(GTDATA24)

    # Test MAI-F with new code
    inflMaiF_new = InflationCoreMaiF(GTDATA, 5)
    inflMaiF_new_23 = InflationCoreMaiF(GTDATA23, 5)
    inflMaiF_new_24 = InflationCoreMaiF(GTDATA24, 5)

    m_traj_inflMaiF_new = inflMaiF_new(GTDATA)
    m_traj_inflMaiF_new_23 = inflMaiF_new_23(GTDATA23)
    m_traj_inflMaiF_new_24 = inflMaiF_new_24(GTDATA24)

    @test mean(abs.(m_traj_inflMaiF_legacy - m_traj_inflMaiF_new)) < 0.1
    @test mean(abs.(m_traj_inflMaiF_legacy_23 - m_traj_inflMaiF_new_23)) < 0.1
    @test mean(abs.(m_traj_inflMaiF_legacy_24 - m_traj_inflMaiF_new_24)) < 0.1


end
