@testitem "always-correct vs indepdendent-only" begin
    Uncertain.assume_independent() = false
    a = 2 ±ᵤ 0.1
    @test a + 3 == 5 ±ᵤ 0.1
    @test_throws "independent" a + a
end

@testsnippet MeasSnippet begin
    import Measurements
    using Supposition, Supposition.Data
    using Supposition: @check
    ispass(x::Supposition.SuppositionReport) = Supposition.results(x).ispass

    const ≈ = (x, y) ->
        isnan(x) || isinf(x) ? isnan(y) || isinf(y) :
        isapprox(x, y; rtol=1e-5)

    function is_approx_same(func, args...; transform=Measurements.measurement)
        # https://github.com/JuliaLang/julia/issues/56782
        all(args) do a
            !(exp(U.value(a)) < zero(U.value(a)))
        end || reject!()
        margs = map(x -> x isa U.Value ? transform(x) : x, args)
        meas_res = try
            func(margs...)
        catch
            reject!()
        end
        event!("margs", margs)
        event!("Measurements", meas_res)
        our_res = @inferred func(args...)
        event!("Uncertain", our_res)
        return U.value(our_res) ≈ Measurements.value(meas_res) && U.uncertainty(our_res) ≈ Measurements.uncertainty(meas_res)
    end

    valgen = @composed (v=Data.Floats{Float32}(), u=Data.Floats{Float32}(minimum=0)) -> U.Value(v, u)
    fgen = Data.Floats{Float32}(minimum=1e-1, maximum=1e1, nans=false)
    smaller_valgen = @composed (v=(Data.Just(0f0) | fgen | map(-, fgen)), u=(Data.Just(0f0) | fgen)) -> U.Value(v, u)
end

@testitem "consistency - univariate" setup=[MeasSnippet] begin
    @testset for op in [+, -, exp, Base.Fix1(^, ℯ), inv, sin, cos, tan, asin, acos, atan, abs, abs2, rad2deg, deg2rad, mod2pi]
        @test ispass(@check is_approx_same(Data.Just(op), valgen))
    end
    @testset for op in [sqrt, log, log2, log10]
        @test ispass(@check is_approx_same(Data.Just(op), filter(x -> !(x < zero(x)), valgen)))
    end
    @testset for op in [sign]
        f(args...) = is_approx_same(args...; transform=U.value)
        @test ispass(@check f(Data.Just(op), valgen))
    end
end

@testitem "consistency - predicates" setup=[MeasSnippet] begin
    @testset for op in [isnan, isfinite, isinf, iszero, isone, isreal]
        @test ispass(@check is_approx_same(Data.Just(op), valgen))
    end
    @testset for op in [<, >, ≤, ≥, ==, isequal]
        @test ispass(@check db=false is_approx_same(Data.Just(op), valgen, Data.Floats{Float32}()))
        @test ispass(@check db=false is_approx_same(Data.Just(op), Data.Floats{Float32}(), valgen))
        @test ispass(@check db=false is_approx_same(Data.Just(op), valgen, valgen))
    end
end

@testitem "consistency - bivariate, one Value" setup=[MeasSnippet] begin
    @testset for op in [+, -, *, /, ^, hypot, atan]
        @test ispass(@check db=false is_approx_same(Data.Just(op), valgen, Data.Floats{Float32}()))
        @test ispass(@check db=false is_approx_same(Data.Just(op), Data.Floats{Float32}(), valgen))
    end
    @testset for op in [mod]
        @test ispass(@check db=false is_approx_same(Data.Just(op), valgen, Data.Floats{Float32}()))
    end
end

@testitem "consistency - minmax-like" setup=[MeasSnippet] begin
    @testset for op in [max, min]
        @test ispass(@check db=false is_approx_same(Data.Just(op), valgen, Data.Floats{Float32}()))
        @test ispass(@check db=false is_approx_same(Data.Just(op), Data.Floats{Float32}(), valgen))
        @test ispass(@check db=false is_approx_same(Data.Just(op), valgen, valgen))
    end
    @testset for op in [clamp]
        @test ispass(@check db=false is_approx_same(Data.Just(op), Data.Floats{Float32}(), Data.Floats{Float32}(), valgen))
        @test ispass(@check db=false is_approx_same(Data.Just(op), Data.Floats{Float32}(), valgen, Data.Floats{Float32}()))
        @test ispass(@check db=false is_approx_same(Data.Just(op), valgen, Data.Floats{Float32}(), Data.Floats{Float32}()))
        @test ispass(@check db=false is_approx_same(Data.Just(op), Data.Floats{Float32}(), valgen, valgen))
        @test ispass(@check db=false is_approx_same(Data.Just(op), valgen, Data.Floats{Float32}(), valgen))
        @test ispass(@check db=false is_approx_same(Data.Just(op), valgen, valgen, Data.Floats{Float32}()))
        @test ispass(@check db=false is_approx_same(Data.Just(op), valgen, valgen, valgen))
    end
end

@testitem "consistency - bivariate, independent" setup=[MeasSnippet] begin
    Uncertain.assume_independent() = true
    @testset for op in [+, -, *, /, ^, hypot, atan]
        @test ispass(@check db=false is_approx_same(Data.Just(op), smaller_valgen, smaller_valgen))
    end
    Uncertain.assume_independent() = false
end

@testitem "complex" begin
    @test cis(1±ᵤ0.01) === Complex(0.5403023058681398 ±ᵤ 0.008414709848078966, 0.8414709848078965 ±ᵤ 0.005403023058681398)
    @test cis(1±ᵤ0.01) |> U.value ≈ cis(1)
    @test cis(1±ᵤ0.01) |> U.uncertainty ≈ 0.008414709848078966 + 0.005403023058681398im

    @test U.Value(1 + 2im, 0.1) == Complex(U.Value(1, 0.1), U.Value(2, 0.1))

    @test im*(1±ᵤ0.1) === U.Value(1im, 0.1)
    cmplx = U.Value(1+2im, 0.5)
    @test 2*cmplx == U.Value(2+4im, 1)
    @test im*cmplx == U.Value(-2+1im, 0.5)
    @test real(cmplx) == U.Value(1, 0.5)
    @test imag(cmplx) == U.Value(2, 0.5)
    @test conj(cmplx) == U.Value(1-2im, 0.5)
    @test abs(cmplx) == U.Value(sqrt(5), 0.5)
    @test angle(cmplx) == U.Value(atan(2, 1), 0.5/sqrt(5))
end
