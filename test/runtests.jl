using TestItems
using TestItemRunner
@run_package_tests


@testitem "_" begin
    import Aqua
    Aqua.test_all(Uncertain; ambiguities=false)
    Aqua.test_ambiguities(Uncertain)

    import CompatHelperLocal as CHL
    CHL.@check()
end
