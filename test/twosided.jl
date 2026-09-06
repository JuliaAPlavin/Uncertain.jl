@testitem "one vs two sided" begin
    using Unitful

    function test_isequal_hash(a, b)
        @test isequal(a, b)
        @test isequal(b, a)
        @test hash(a) == hash(b)
    end

    function test_total_order(a, b)
        relations = (isequal(a, b), isless(a, b), isless(b, a))
        @test count(identity, relations) == 1
    end

    @test U.TwoSided(0.1, 0.2) == U.TwoSided(0.1, 0.2)
    @test U.TwoSided(0.1, 0.2) ≈ U.TwoSided(0.1, 0.2)
    @test U.TwoSided(0.1, 0.2) != U.TwoSided(0.1, nextfloat(0.2))
    @test U.TwoSided(0.1, 0.2) ≈ U.TwoSided(0.1, nextfloat(0.2))
    @test U.TwoSided(0.1, 0.2) != U.TwoSided(0.1, 0.3)
    @test !(U.TwoSided(0.1, 0.2) ≈ U.TwoSided(0.1, 0.3))

    test_isequal_hash(U.TwoSided(1, 2), U.TwoSided(1.0, 2.0))

    @test U.TwoSided(NaN, 1.0) != U.TwoSided(NaN, 1.0)
    test_isequal_hash(U.TwoSided(NaN, 1.0), U.TwoSided(NaN, 1.0))

    @test U.TwoSided(-0.0, 1.0) == U.TwoSided(+0.0, 1.0)
    @test !isequal(U.TwoSided(-0.0, 1.0), U.TwoSided(+0.0, 1.0))

    @test U.TwoSided(1, 1) != 1
    @test !isequal(U.TwoSided(1, 1), 1)

    a = U.TwoSided(0.1, 0.2)
    b = U.TwoSided(0.1, 0.3)
    @testset for (x, y) in [
        (a, b),
        (U.TwoSided(1, 2), U.TwoSided(1.0, 2.0)),
        (U.TwoSided(NaN, 1.0), U.TwoSided(NaN, 1.0)),
        (U.TwoSided(-0.0, 1.0), U.TwoSided(+0.0, 1.0)),
    ]
        test_total_order(x, y)
    end
    @test isless(a, b)
    @test sort([1 ±ᵤ b, 1 ±ᵤ a]) == [1 ±ᵤ a, 1 ±ᵤ b]

    test_isequal_hash(
        1 ±ᵤ U.TwoSided(1, 2),
        1.0 ±ᵤ U.TwoSided(1.0, 2.0),
    )

    @test iszero(U.TwoSided(0.0, 0.0))
    @test !iszero(U.TwoSided(0.0, 0.1))

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

    # @test U.add(0.1, 0.2) ≈ 0.3
    # @test U.add(U.TwoSided(0.1, 0.2), 0.3) ≈ U.TwoSided(0.4, 0.5)
    # @test U.add(0.3, U.TwoSided(0.1, 0.2)) ≈ U.TwoSided(0.4, 0.5)
    # @test U.add(U.TwoSided(0.1, 0.2), U.TwoSided(0.3, 0.4)) ≈ U.TwoSided(0.4, 0.6)
end
