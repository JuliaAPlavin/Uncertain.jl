@testitem "real" begin
    using Accessors

    a = 2 ±ᵤ 0.25
    @test U.value(a) == 2
    @test U.uncertainty(a) == 0.25
    @test U.Value(a) === a

    @test a == (2f0 ±ᵤ 0.25f0)
    @test a != 2
    @test U.Value(2, 0) == 2

    @test (@set U.value(a) = -0.5) === -0.5 ±ᵤ 0.25
    @test (@set U.uncertainty(a) = 0.5) === 2 ±ᵤ 0.5

    @test zero(a) === U.Value(0, 0.)

    @test U.Value(7) === 7 ±ᵤ 0

    # smoke tests for promotion:
    [2±ᵤ1, 2±ᵤ0.5]
    [1, 2±ᵤ1, 2±ᵤ0.5]
    [1, 2±ᵤ1, 2±ᵤ0.5, (2+1im)±ᵤ0.1]
end

@testitem "complex" begin
    c = U.Value(1+2im, 0.5)
    @test c === (1.0+2.0im) ±ᵤ 0.5
    @test U.value(c) === 1.0+2.0im
    @test U.uncertainty(c) === 0.5

    @test zero(c) === U.Value(0+0im, 0.)

    @test_throws "isreal" (1+2im) ±ᵤ 0.5im

    @test real(c) === 1 ±ᵤ 0.5
    @test imag(c) === 2 ±ᵤ 0.5
    @test real(typeof(c)) === typeof(real(c))
end

@testitem "conversions" begin
    import Measurements as ME
    import MonteCarloMeasurements as MCM
    import IntervalSets as IS

    me = ME.measurement(3, 1)
    @test U.Value(me) === 3.0 ±ᵤ 1.0
    @test ME.Measurement(U.Value(me)) == me

    pa = MCM.Particles(3 .+ randn(10^4))
    u = U.Value(pa)
    @test U.value(u) ≈ 3 rtol=3e-2
    @test U.uncertainty(u) ≈ 1 rtol=1e-1

    pa = MCM.Particles(10^4, 3 ±ᵤ 1)
    @test MCM.pmean(pa) ≈ 3 rtol=3e-2
    @test MCM.pstd(pa) ≈ 1 rtol=1e-1

    @test IS.Interval(1 ±ᵤ 0.1) === IS.Interval(0.9, 1.1)
    @test U.Value(IS.Interval(0.5, 1.5)) === 1 ±ᵤ 0.5
end

@testitem "accessing basic numbers" begin
    @test U.value(123) === 123
    @test U.uncertainty(123) === 0
end

@testitem "equality" begin
    @test U.Value(1, 0) == 1
    @test U.Value(1, 0.1) != 1
    @test U.Value(1, 0.5) == U.Value(1f0, 0.5f0)
    @test U.Value(1, 0.1) != U.Value(1, 0.15)

    @test U.Value(1 + 2im, 0) == 1 + 2im
    @test Complex(U.Value(1, 0), U.Value(2, 0)) == 1 + 2im
    @test U.Value(1 + 2im, 0.1) != 1 + 2im

    @test promote(U.Value(10 + 20im, 0.1),                     Complex(U.Value(1, 0.1), U.Value(2, 0.1))) ===
                 (Complex(U.Value(10, 0.1), U.Value(20, 0.1)), Complex(U.Value(1, 0.1), U.Value(2, 0.1)))
    @test U.Value(1 + 2im, 0.1) == Complex(U.Value(1, 0.1), U.Value(2, 0.1))
    @test U.Value(1 + 2im, 0.15) != Complex(U.Value(1, 0.1), U.Value(2, 0.1))
    @test U.Value(1 + 2im, 0.1) != Complex(U.Value(1, 0.15), U.Value(2, 0.1))
    @test U.Value(1 + 2im, 0.1) != Complex(U.Value(1, 0.1), U.Value(2, 0.15))
end

@testitem "broadcast" begin
    @test U.Value(1, 0.1) .+ [1, 2, 3] == U.Value.([2, 3, 4], 0.1)
end

@testitem "Unitful" begin
    using Unitful

    a = 3 ±ᵤ 0.2
    b = 3u"km" ±ᵤ 0.2u"km"
    c = 3.0u"km" ±ᵤ 200u"m"

    @test unit(a) == NoUnits
    @test unit(b) == u"km"
    @test unit(c) == u"m"

    @test ustrip(a) == 3 ±ᵤ 0.2 == a
    @test ustrip(b) == 3 ±ᵤ 0.2 == a
    @test ustrip(c) == 3e3 ±ᵤ 200

    @test b*im === (3.0im)u"km" ±ᵤ 0.2u"km"
    @test 2((1+1im)u"km" ±ᵤ 10u"m") === (2000 + 2000im)u"m" ±ᵤ 20u"m"

    @test_broken a*u"km" == b
    @test_broken a*1u"km" == b
end
