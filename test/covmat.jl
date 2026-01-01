@testitem "CovMat 1d" begin
    using LinearAlgebra
    using StaticArrays
    using Unitful

    ≈(a, b) = isapprox(U.value(a), U.value(b)) && isapprox(U.uncertainty(a), U.uncertainty(b))

    # 1d case: should match scalar propagation
    v1 = [3] ±ᵤ U.CovMat(σ=0.1)
    @test U.nσ(v1) ≈ 30
    @test norm(v1) ≈ 3 ±ᵤ 0.1
    @test dot(v1, [2]) ≈ 6 ±ᵤ 0.2

    v1neg = [-4] ±ᵤ U.CovMat(σ=0.2)
    @test norm(v1neg) ≈ 4 ±ᵤ 0.2
    @test dot(v1neg, [3]) ≈ -12 ±ᵤ 0.6

    @test norm(2*v1) ≈ 6 ±ᵤ 0.2
    @test dot(v1*u"m", [2]) ≈ 6u"m" ±ᵤ 0.2u"m"
    @test U.nσ(v1*u"m") ≈ 30

    @test v1 + v1neg ≈ [-1] ±ᵤ U.CovMat(σ=hypot(0.1, 0.2))
    @test v1 - v1neg ≈ [7] ±ᵤ U.CovMat(σ=hypot(0.1, 0.2))
end

@testitem "CovMat 2d along one axis" begin
    using LinearAlgebra
    using StaticArrays

    ≈(a, b) = isapprox(U.value(a), U.value(b)) && isapprox(U.uncertainty(a), U.uncertainty(b))

    # 2d vector but only x component nonzero, σy=0: effectively 1d
    v = [3, 0] ±ᵤ U.CovMat(σx=0.1, σy=0, ρ=0)
    @test U.nσ(v) ≈ 30
    @test norm(v) ≈ 3 ±ᵤ 0.1
    @test dot(v, [2, 0]) ≈ 6 ±ᵤ 0.2
    @test dot(v, [0, 5]) ≈ 0 ±ᵤ 0

    # same but along y axis
    v = [0, 4] ±ᵤ U.CovMat(σx=0, σy=0.2, ρ=0)
    @test U.nσ(v) ≈ 20
    @test norm(v) ≈ 4 ±ᵤ 0.2
    @test dot(v, [0, 3]) ≈ 12 ±ᵤ 0.6

    v = [3, 0] ±ᵤ U.CovMat(σx=0, σy=0.1, ρ=0)
    @test U.nσ(v) ≈ Inf
    v = [3, 4] ±ᵤ U.CovMat(σx=0, σy=0.1, ρ=0)
    @test U.nσ(v) ≈ Inf
end

@testitem "CovMat 2d" begin
    using LinearAlgebra
    using StaticArrays
    using Unitful

    ≈(a, b) = isapprox(U.value(a), U.value(b)) && isapprox(U.uncertainty(a), U.uncertainty(b))

    @test zero(U.CovMat(σx=0.1, σy=0.2, ρ=0)).cov::Symmetric{Float64, <:SMatrix} == [0 0; 0 0]
    @test zero(U.CovMat(@SMatrix([1 2; 2 3]))).cov::SMatrix === @SMatrix([0 0; 0 0])

    v = [1, 0] ±ᵤ U.CovMat(@SMatrix [0.25 0.0; 0.0 0.0625])
    @test v == [1, 0] ±ᵤ U.CovMat(σx=0.5, σy=0.25, ρ=0)
    @test v != [1, 0] ±ᵤ U.CovMat(σx=0.5, σy=0.25, ρ=0.1)

    # zero uncertainty:
    v = [1, 2] ±ᵤ U.CovMat(σx=0, σy=0, ρ=0.5)
    @test U.nσ(v) == Inf
    @test dot(v, [3, 4]) == 11 ±ᵤ 0
    @test norm(v) == hypot(1, 2) ±ᵤ 0

    # uncorrelated case: σ of dot product is |y| * σ
    v = [1, 0] ±ᵤ U.CovMat(σx=0.1, σy=0.2, ρ=0)
    @test U.nσ(v) ≈ 10
    @test U.nσ(v*u"km") ≈ 10
    @test dot(v, [1, 0]) ≈ 1 ±ᵤ 0.1
    @test dot(v, [0, -1]) ≈ 0 ±ᵤ 0.2
    @test dot(v, [3, 4]) ≈ 3 ±ᵤ hypot(3*0.1, 4*0.2)
    @test dot(v, [3, -4]) ≈ 3 ±ᵤ hypot(3*0.1, 4*0.2)
    @test dot(2v, [3, 4]) ≈ 6 ±ᵤ 2*hypot(3*0.1, 4*0.2)
    @test dot(v*u"m", [3, 4]) ≈ (3 ±ᵤ hypot(3*0.1, 4*0.2))u"m"
    @test dot(NoUnits(v*u"m"/u"cm"), [3, 4]) ≈ 300 ±ᵤ 100*hypot(3*0.1, 4*0.2)

    # fully correlated case:
    v_corr = [1, 3] ±ᵤ U.CovMat(σx=0.1, σy=0.2, ρ=1)
    @test U.nσ(v_corr) ≈ Inf
    @test dot(v_corr, [1, 1]) ≈ 4 ±ᵤ 0.3

    # norm propagation
    v2 = [3, 4] ±ᵤ U.CovMat(σx=0.3, σy=0.3, ρ=0)
    @test norm(v2) ≈ 5 ±ᵤ 0.3
    v2 = [3, 0] ±ᵤ U.CovMat(σx=0.3, σy=0.4, ρ=0)
    @test norm(v2) ≈ 3 ±ᵤ 0.3
    v2 = [3, 4] ±ᵤ U.CovMat(σx=0.3, σy=0.4, ρ=1)
    @test U.nσ(v2) ≈ 10
    @test norm(v2) ≈ 5 ±ᵤ 0.5

    @test U.nσ([NaN, 1] ±ᵤ U.CovMat(σx=0.1, σy=0.2, ρ=0)) |> isnan
    @test U.nσ([1, 2] ±ᵤ U.CovMat(σx=NaN, σy=0.2, ρ=0)) |> isnan

    M = @SMatrix [1 2; 3 4]
    @test M * v2 == [11, 25] ±ᵤ U.CovMat(@SMatrix [1.21 2.75; 2.75 6.25])
end
