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
    @test U.:±(7, 1) === 7 ±ᵤ 1
    @test U.nσ(7 ±ᵤ 2) === 3.5

    @test float(2.0 ±ᵤ 0.25) === 2.0 ±ᵤ 0.25
    @test float(2f0 ±ᵤ 0.25f0) === 2f0 ±ᵤ 0.25f0
    @test float(2 ±ᵤ 1) === 2.0 ±ᵤ 1.0
    @test float(typeof(a)) == U.ValueReal{Float64, Float64}

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

    @test float(c) === c
    @test complex(1 ±ᵤ 0.5) === complex(1.0 ±ᵤ 0.5, 0.0 ±ᵤ 0.0)
end

@testitem "IntervalSets, Measurements, MCM" begin
    import Measurements as ME
    import MonteCarloMeasurements as MCM
    import IntervalSets as IS
    using LinearAlgebra: Symmetric
    using StaticArrays

    me = ME.measurement(3, 1)
    @test U.Value(me) === 3.0 ±ᵤ 1.0
    @test ME.Measurement(U.Value(me)) == me

    @testset "Value from vector particles" for PT in [MCM.Particles, MCM.StaticParticles]
        p1 = PT([1.0, 3.0, 5.0])
        p2 = PT([10.0, 14.0, 18.0])
        expected_cov = Symmetric([4.0 8.0; 8.0 16.0])

        us = U.Value(SVector(p1, p2))
        @test us isa U.ValueAny
        @test U.value(us) isa SVector{2, Float64}
        @test U.value(us) == SVector(3.0, 14.0)
        @test U.uncertainty(us).cov isa Symmetric{Float64, <:SMatrix}
        @test U.uncertainty(us).cov == expected_cov

        uv = U.Value([p1, p2])
        @test uv isa U.ValueAny
        @test U.value(uv) isa Vector{Float64}
        @test U.value(uv) == [3.0, 14.0]
        @test U.uncertainty(uv).cov isa Symmetric{Float64, Matrix{Float64}}
        @test U.uncertainty(uv).cov == expected_cov
    end

    @testset for PT in [MCM.Particles, MCM.StaticParticles]
        pa = PT(3 .+ randn(10^3))
        u = U.Value(pa)
        @test U.value(u) ≈ 3 rtol=0.1
        @test U.uncertainty(u) ≈ 1 rtol=0.2

        pa = PT(10^3, 3 ±ᵤ 1)
        @test MCM.pmean(pa) ≈ 3 rtol=3e-2
        @test MCM.pstd(pa) ≈ 1 rtol=1e-1
    end

    @testset "uconvert" for PT in [MCM.Particles, MCM.StaticParticles]
        # scalar
        pa = U.uconvert(PT, 3 ±ᵤ 1)
        @test pa isa MCM.AbstractParticles
        @test MCM.pmean(pa) ≈ 3 rtol=0.1
        @test MCM.pstd(pa) ≈ 1 rtol=0.2

        # scalar with specified N
        pa100 = U.uconvert(PT{Any, 100}, 3 ±ᵤ 1)
        @test pa100 isa MCM.AbstractParticles
        @test MCM.nparticles(pa100) == 100
        @test MCM.pmean(pa100) ≈ 3 rtol=0.2

        # complex
        pc = U.uconvert(PT, Complex(1 ±ᵤ 0.5, 2 ±ᵤ 0.3))
        @test pc isa Complex{<:MCM.AbstractParticles}
        @test MCM.pmean(real(pc)) ≈ 1 rtol=0.1
        @test MCM.pmean(imag(pc)) ≈ 2 rtol=0.1
        @test MCM.pstd(real(pc)) ≈ 0.5 rtol=0.2
        @test MCM.pstd(imag(pc)) ≈ 0.3 rtol=0.2

        # vector + CovMat
        v = SVector(3.0, 4.0) ±ᵤ U.CovMat(σx=0.3, σy=0.4, ρ=0.5)
        pv = U.uconvert(PT, v)
        @test pv isa SVector{2, <:MCM.AbstractParticles}
        @test MCM.pmean(pv[1]) ≈ 3 rtol=0.1
        @test MCM.pmean(pv[2]) ≈ 4 rtol=0.1
        @test MCM.pstd(pv[1]) ≈ 0.3 rtol=0.2
        @test MCM.pstd(pv[2]) ≈ 0.4 rtol=0.2

        # dynamic vector + CovMat
        v_dyn = [3.0, 4.0] ±ᵤ U.CovMat(σx=0.3, σy=0.4, ρ=0.5)
        pv_dyn = U.uconvert(PT, v_dyn)
        @test pv_dyn isa Vector{<:MCM.AbstractParticles}

        # vector + CovMat with specified N
        pv100 = U.uconvert(PT{Any, 100}, v)
        @test pv100 isa SVector{2, <:MCM.AbstractParticles}
        @test MCM.nparticles(pv100[1]) == 100

        # singular: ρ=1
        v1 = SVector(3.0, 4.0) ±ᵤ U.CovMat(Symmetric(SMatrix{2,2}(0.09, 0.12, 0.12, 0.16)))
        pv1 = U.uconvert(PT, v1)
        @test MCM.pmean(pv1[1]) ≈ 3 rtol=0.1
        @test MCM.pstd(pv1[1]) ≈ 0.3 rtol=0.2
        @test MCM.pstd(pv1[2]) ≈ 0.4 rtol=0.2
        using Statistics: cor
        @test cor(pv1[1].particles, pv1[2].particles) ≈ 1

        # singular: σy=0
        v0 = SVector(3.0, 4.0) ±ᵤ U.CovMat(Symmetric(SMatrix{2,2}(0.09, 0.0, 0.0, 0.0)))
        pv0 = U.uconvert(PT, v0)
        @test MCM.pmean(pv0[1]) ≈ 3 rtol=0.1
        @test MCM.pstd(pv0[1]) ≈ 0.3 rtol=0.2
        @test all(pv0[2].particles .== 4.0)

    end

    # type stability with concrete types (outside loop so PT is compile-time)
    v = SVector(3.0, 4.0) ±ᵤ U.CovMat(σx=0.3, σy=0.4, ρ=0.5)
    @inferred U.uconvert(MCM.Particles{Any, 128}, 3 ±ᵤ 1)
    @inferred U.uconvert(MCM.Particles{Any, 128}, Complex(1 ±ᵤ 0.5, 2 ±ᵤ 0.3))
    @inferred U.uconvert(MCM.StaticParticles{Any, 128}, 3 ±ᵤ 1)
    @inferred U.uconvert(MCM.StaticParticles{Any, 128}, Complex(1 ±ᵤ 0.5, 2 ±ᵤ 0.3))

    @test IS.Interval(1 ±ᵤ 0.1) === IS.Interval(0.9, 1.1)
    @test U.Value(IS.Interval(0.5, 1.5)) === 1 ±ᵤ 0.5
end

@testitem "equality" begin
    @testset for f in [==, isequal]
        @test f(U.Value(1, 0), 1)
        @test !f(U.Value(1, 0.1), 1)
        @test f(U.Value(1, 0.5), U.Value(1f0, 0.5f0))
        @test !f(U.Value(1, 0.1), U.Value(1, 0.15))
    end

    @test U.Value(+0.0, 0.1) == U.Value(-0.0, 0.1)
    @test !isequal(U.Value(+0.0, 0.1), U.Value(-0.0, 0.1))
    @test U.Value(NaN, 0.1) != U.Value(NaN, 0.1)
    @test isequal(U.Value(NaN, 0.1), U.Value(NaN, 0.1))

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

@testitem "hash" begin
    @testset for (a, b, p) in [
        (0 ±ᵤ 0, 0 ±ᵤ 0, ==),
        (0 ±ᵤ 1, 0 ±ᵤ 1.0, ==),
        (0 ±ᵤ 1, 1 ±ᵤ 1.0, !=),
        (0 ±ᵤ 1, 0 ±ᵤ 0, !=),
        (-0.0 ±ᵤ 1, +0.0 ±ᵤ 1.0, !=),
        (NaN ±ᵤ 1, NaN ±ᵤ 1.0, ==),
        ((1+0im) ±ᵤ 1, 1 ±ᵤ 1.0, ==),
        ((1+2im) ±ᵤ 1, 1 ±ᵤ 1.0, !=),
    ]
        @test p(hash(a), hash(b))
    end
end

@testitem "broadcast" begin
    @test U.Value(1, 0.1) .+ [1, 2, 3] == U.Value.([2, 3, 4], 0.1)
end

@testitem "Unitful" begin
    using Unitful

    a = 3 ±ᵤ 0.2
    b = 3u"km" ±ᵤ 0.2u"km"
    c = 3.0u"km" ±ᵤ 200u"m"

    @test b === (3 ±ᵤ 0.2)u"km"

    @test unit(a) == NoUnits
    @test unit(b) == u"km"
    @test unit(c) == u"m"

    @test ustrip(a) == 3 ±ᵤ 0.2 == a
    @test ustrip(b) == 3 ±ᵤ 0.2 == a
    @test ustrip(c) == 3e3 ±ᵤ 200

    @test ustrip(NoUnits, a) === a
    @test ustrip(u"m", b) == 3000 ±ᵤ 200
    @test ustrip(u"m", c) == 3000 ±ᵤ 200

    @test a |> NoUnits == a
    @test b |> u"m" == (3000 ±ᵤ 200)u"m"
    @test c |> u"m" == (3000 ±ᵤ 200)u"m"

    @test zero(a) === 0.0 ±ᵤ 0.0
    @test zero(b) === (0.0 ±ᵤ 0.0)u"km"
    @test zero(typeof(a)) === 0.0 ±ᵤ 0.0
    @test zero(typeof(b)) === (0.0 ±ᵤ 0.0)u"km"
    @test one(a) === 1.0 ±ᵤ 0.0
    @test one(b) === 1.0 ±ᵤ 0.0
    @test one(typeof(a)) === 1.0 ±ᵤ 0.0
    @test one(typeof(b)) === 1.0 ±ᵤ 0.0

    @test b*im === (3.0im)u"km" ±ᵤ 0.2u"km"
    @test 2((1+1im)u"km" ±ᵤ 10u"m") === (2000 + 2000im)u"m" ±ᵤ 20u"m"

    @test a*u"km" == b
    @test a*(-1u"km") == -b
    @test u"km"*a == b
    @test (1u"km")*a == b
    
    @test b*u"m" == (3±ᵤ0.2)u"km*m"
    @test b*(-1u"m") == -(3±ᵤ0.2)u"km*m"
    @test b/u"km" == 3±ᵤ0.2
    @test b/1u"km" == 3±ᵤ0.2
    @test u"km"/a == (1/3 ±ᵤ 1/45)u"km"
    @test 1u"km"/b == 1/3 ±ᵤ 5
end

@testitem "accessing values without uncertainty" begin
    using Unitful
    using Accessors

    @test U.value(123) === 123
    @test U.uncertainty(123) === 0
    @test U.nσ(123) === Inf
    @test (@set U.value(123) = 456) === 456

    @test U.value(123 + 456im) === 123 + 456im
    @test U.uncertainty(123 + 456im) === 0
    @test U.nσ(123 + 456im) === Inf
    @test (@set U.value(123 + 456im) = 789 + 1011im) === 789 + 1011im

    @test U.value(123u"m") === 123u"m"
    @test U.uncertainty(123u"m") === 0u"m"
    @test U.nσ(123u"m") === Inf

    @test U.value((123 + 456im)u"m") === (123 + 456im)u"m"
    @test U.uncertainty((123 + 456im)u"m") === 0u"m"
    @test U.nσ((123 + 456im)u"m") === Inf
end
