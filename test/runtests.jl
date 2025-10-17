using CPIDataBase
using CPIDataBase.TestHelpers
using InflationFunctions
using Test
using CPIDataGT
CPIDataGT.load_data()


@test periods(GT00) == 120
@testset "InflationFunctions.jl" begin
    # Write your tests here.
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


## MAI-F
@testset "InflationCoreMaiF" begin
    # Instanciar un tipo
    cst_test = GTDATA24
    base_test = GT10
    vlp = vec(base_test.v)
    wlp = repeat(base_test.w, periods(base_test))
    inflMaiF_with_base_q = InflationCoreMaiF(vlp, wlp, 0:0.2:1)
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

## MAI_FP
@testset "InflationCoreMaiFP" begin
    # Instanciar un tipo
    cst_test = GTDATA24
    base_test = GT10
    vlp = vec(base_test.v)
    inflMaiFP_with_base_q = InflationCoreMaiFP(vlp, 0:0.2:1)
    inflMaiFP_with_cst_q = InflationCoreMaiFP(cst_test, 0:0.2:1)
    inflMaiFP_with_cst_n = InflationCoreMaiFP(cst_test, 5)

    @test inflMaiFP_with_base_q isa InflationCoreMaiFP
    @test inflMaiFP_with_cst_q isa InflationCoreMaiFP
    @test inflMaiFP_with_cst_n isa InflationCoreMaiFP

    # Test that function has correct name and tag
    @test measure_name(inflMaiFP_with_base_q) isa String
    @test measure_tag(inflMaiFP_with_base_q) isa String

    # Test that function can be called on base and countryst

    m_traj_infl = inflMaiFP_with_base_q(base_test)
    @test m_traj_infl isa AbstractVector
    # Obtenemos un UniformCountryStructure con dos bases y todas las variaciones
    # intermensuales
    traj_infl_n = inflMaiFP_with_cst_n(cst_test)
    traj_infl_q = inflMaiFP_with_cst_q(cst_test)
    @test traj_infl_n isa AbstractVector

    @test all((traj_infl_n - traj_infl_q) .== 0)
    # Testa that trajectory is longer than monthly summary
    @test length(traj_infl_n) > length(m_traj_infl)

end


# Test that legacy MAI code and new MAI code give the same results

@testset "InflationMAI New vrs.Legacy Code" begin

    using InflationFunctions.LegacyMai
    using Statistics
    # Test MAI-G with legacy code
    inflmaig_legacy = InflationFunctions.LegacyMai.InflationCoreMaiG(5)

    m_traj_inflMaiG_legacy = inflmaig_legacy(GTDATA)
    m_traj_inflMaiG_legacy_24 = inflmaig_legacy(GTDATA24)

    # Test MAI-G with new code
    inflmaig_new = InflationCoreMaiG(GTDATA, 5)
    inflmaig_new_24 = InflationCoreMaiG(GTDATA24, 5)

    m_traj_inflMaiG_new = inflmaig_new(GTDATA)
    m_traj_inflMaiG_new_24 = inflmaig_new_24(GTDATA24)

    @test mean(abs.(m_traj_inflMaiG_legacy - m_traj_inflMaiG_new)) < 0.1
    @test mean(abs.(m_traj_inflMaiG_legacy_24 - m_traj_inflMaiG_new_24)) < 0.1

    ## Test MAI-F with legacy code and new code

    inflMaiF_legacy = InflationFunctions.LegacyMai.InflationCoreMaiF(5)

    m_traj_inflMaiF_legacy = inflMaiF_legacy(GTDATA)
    m_traj_inflMaiF_legacy_24 = inflMaiF_legacy(GTDATA24)

    # Test MAI-G with new code
    inflMaiF_new = InflationCoreMaiF(GTDATA, 5)
    inflMaiF_new_24 = InflationCoreMaiF(GTDATA24, 5)

    m_traj_inflMaiF_new = inflMaiF_new(GTDATA)
    m_traj_inflMaiF_new_24 = inflMaiF_new_24(GTDATA24)

    @test mean(abs.(m_traj_inflMaiF_legacy - m_traj_inflMaiF_new)) < 0.1
    @test mean(abs.(m_traj_inflMaiF_legacy_24 - m_traj_inflMaiF_new_24)) < 0.1

    ## Test MAI-FP with legacy code and new code

    inflMaiFP_legacy = InflationFunctions.LegacyMai.InflationCoreMaiFP(5)

    m_traj_inflMaiFP_legacy = inflMaiFP_legacy(GTDATA)
    m_traj_inflMaiFP_legacy_24 = inflMaiFP_legacy(GTDATA24)

    # Test MAI-G with new code
    inflMaiFP_new = InflationCoreMaiFP(GTDATA, 5)
    inflMaiFP_new_24 = InflationCoreMaiFP(GTDATA24, 5)

    m_traj_inflMaiFP_new = inflMaiFP_new(GTDATA)
    m_traj_inflMaiFP_new_24 = inflMaiFP_new_24(GTDATA24)

    @test mean(abs.(m_traj_inflMaiFP_legacy - m_traj_inflMaiFP_new)) < 0.1
    @test mean(abs.(m_traj_inflMaiFP_legacy_24 - m_traj_inflMaiFP_new_24)) < 0.1


end
