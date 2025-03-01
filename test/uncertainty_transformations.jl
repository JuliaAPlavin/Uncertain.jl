@testitem "LinearAdd" begin
    t = U.LinearAdd(1.23)
    @test t(3.45) == 4.68
    @test t(U.TwoSided(3.45, 0.01)) ≈ U.TwoSided(4.68, 1.24)
end
