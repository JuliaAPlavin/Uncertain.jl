using TestItems
using TestItemRunner
@run_package_tests



    # cmplx = U.Value(1+2im, 0.5)
    # @test im*(1±0.1) == U.Value(1im, 0.1)
    # @test 2*cmplx == U.Value(2+4im, 1)
    # @test im*cmplx == U.Value(-2+1im, 0.5)
    # @test real(cmplx) == U.Value(1, 0.5)
    # @test imag(cmplx) == U.Value(2, 0.5)
    # @test conj(cmplx) == U.Value(1-2im, 0.5)
    # @test abs(cmplx) == U.Value(sqrt(5), 0.5)
    # @test angle(cmplx) == U.Value(atan(2, 1), 0.5/sqrt(5))

@testitem "_" begin
    import Aqua
    Aqua.test_all(Uncertain; ambiguities=(;broken=true))
    # Aqua.test_ambiguities(Uncertain)

    import CompatHelperLocal as CHL
    CHL.@check()
end
