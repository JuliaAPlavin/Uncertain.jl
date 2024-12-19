using TestItems
using TestItemRunner
@run_package_tests

@testitem "disambiguations correct" begin
    @test U.ValueReal(1+0im) === U.ValueReal(1)
    @test Complex{U.ValueReal{Int,Int}}(1+0im) === Complex(U.Value(1,0), U.Value(0,0))
    @test Complex{U.ValueReal{Int,Int}}(1) === Complex(U.Value(1,0), U.Value(0,0))
    @test Complex{U.ValueReal{Float64,Float64}}(π) === Complex(U.Value(π,0), U.Value(0,0))

    @test isequal(1+0im, U.ValueReal(1))
    @test isequal(U.ValueReal(1), 1+0im)
    @test !isequal(1+2im, U.ValueReal(1))
    @test !isequal(U.ValueReal(1), 1+2im)

    @test (1+2im) + U.ValueReal(3,0.1) === U.Value(4+2im, 0.1)
    @test U.ValueReal(3,0.1) + (1+2im) === U.Value(4+2im, 0.1)
    @test im + U.ValueReal(3,0.1) === U.Value(3+1im, 0.1)
    @test U.ValueReal(3,0.1) + im === U.Value(3+1im, 0.1)
end

@testitem "_" begin
    import Aqua
    Aqua.test_all(Uncertain; ambiguities=(;broken=true))
    # Aqua.test_ambiguities(Uncertain)

    import CompatHelperLocal as CHL
    CHL.@check()
end
