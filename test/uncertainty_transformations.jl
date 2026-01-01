@testitem "UncertaintyTransformationF" begin
    t = U.UncertaintyTransformationF(x -> 2x)
    @test t(3.45) == 6.9
    @test t(U.TwoSided(3.45, 0.01)) == U.TwoSided(6.9, 0.02)
    @test t(1 ±ᵤ 0.1) == 1 ±ᵤ 0.2
end

@testitem "LinearAdd" begin
    t = U.LinearAdd(1.23)
    @test t(3.45) == 4.68
    @test t(U.TwoSided(3.45, 0.01)) == U.TwoSided(4.68, 1.24)
    @test t(1 ±ᵤ 0.1) == 1 ±ᵤ 1.33
end
