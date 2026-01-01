@testitem "one vs two sided" begin
    using Unitful

    @test U.TwoSided(0.1, 0.2) == U.TwoSided(0.1, 0.2)
    @test U.TwoSided(0.1, 0.2) ≈ U.TwoSided(0.1, 0.2)
    @test U.TwoSided(0.1, 0.2) != U.TwoSided(0.1, nextfloat(0.2))
    @test U.TwoSided(0.1, 0.2) ≈ U.TwoSided(0.1, nextfloat(0.2))
    @test U.TwoSided(0.1, 0.2) != U.TwoSided(0.1, 0.3)
    @test !(U.TwoSided(0.1, 0.2) ≈ U.TwoSided(0.1, 0.3))

    @test U.width(0.1) == 0.2
    @test U.maxdiff(0.1) == 0.1

    @test U.width(U.TwoSided(0.1, 0.2)) ≈ 0.3
    @test U.maxdiff(U.TwoSided(0.1, 0.2)) == 0.2
    @test U.maxdiff(U.TwoSided(0.2, 0.1)) == 0.2

    @test U.TwoSided(0.1, 0.2) * 2 == U.TwoSided(0.2, 0.4)
    @test 2 * U.TwoSided(0.1, 0.2) == U.TwoSided(0.2, 0.4)
    @test U.TwoSided(0.1, 0.2) * u"m" == U.TwoSided(0.1u"m", 0.2u"m")
    @test 1u"m" * U.TwoSided(0.1, 0.2) == U.TwoSided(0.1u"m", 0.2u"m")

    @test U.reverse(0.1) == 0.1
    @test U.reverse(U.TwoSided(0.1, 0.2)) == U.TwoSided(0.2, 0.1)

    @test U.add(0.1, 0.2) ≈ 0.3
    @test U.add(U.TwoSided(0.1, 0.2), 0.3) ≈ U.TwoSided(0.4, 0.5)
    @test U.add(0.3, U.TwoSided(0.1, 0.2)) ≈ U.TwoSided(0.4, 0.5)
    @test U.add(U.TwoSided(0.1, 0.2), U.TwoSided(0.3, 0.4)) ≈ U.TwoSided(0.4, 0.6)
end
