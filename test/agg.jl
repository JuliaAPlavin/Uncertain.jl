@testitem "basic" begin
    Uncertain.assume_independent() = true
    A = [2 ±ᵤ 0.25, 2 ±ᵤ 0.5, 3 ±ᵤ 0.5]
    @test sum(A) == 7 ±ᵤ 0.75
    @test maximum(A) == 3 ±ᵤ 0.5
    Uncertain.assume_independent() = false
end

@testitem "weightedmean" begin
    Uncertain.assume_independent() = true
    import Measurements
    using Unitful

    xs = U.Value.([1, 2, 3], [0.2, 0.05, 0.25])
    xsm = Measurements.measurement.(U.value.(xs), U.uncertainty.(xs))
    wm = @inferred U.weightedmean(xs)
    wmm = Measurements.weightedmean(xsm)
    @test U.value(wm) ≈ Measurements.value(wmm)
    @test U.uncertainty(wm) ≈ Measurements.uncertainty(wmm)

    @test (@inferred U.weightedmean([1f0±ᵤ0.1f0, 2f0±ᵤ0.05f0, 3f0±ᵤ0.25f0])) === 1.8372093f0 ±ᵤ 0.044022545f0
    @test (@inferred U.weightedmean(xs[1:0])) === U.Value(NaN, Inf)
    @test (@inferred U.weightedmean([1f0±ᵤ1f0][1:0])) === U.Value(NaN32, Inf32)
    @test_broken (U.weightedmean([1u"m" ±ᵤ 10u"cm"]); true)
    # @test U.weightedmean([1u"m" ± 10u"cm"][1:0]) === U.Value(NaN32, Inf32)
    @test_throws InexactError U.weightedmean([1±ᵤ1][1:0])
    Uncertain.assume_independent() = false
end
