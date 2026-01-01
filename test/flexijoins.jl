@testitem "xxx" begin
    using FlexiJoins
    using Uncertain: setproperties

    @test setproperties(U.by_uncertainty(identity, identity), f_L=first) === U.by_uncertainty(first, identity)

    A = [1, 2, 3, 6, 7]
    B = [0±ᵤ0.1, 1±ᵤ0.1, 2±ᵤ1, 3±ᵤ3.5]
    @test_throws "both sides" innerjoin((B, B), U.by_uncertainty(identity, identity); mode=FlexiJoins.Mode.NestedLoop())
    J = innerjoin((;A, B), U.by_uncertainty(identity, identity); mode=FlexiJoins.Mode.NestedLoop())
    @test issetequal(J, [
        (A=1, B=1±ᵤ0.1),
        (A=1, B=2±ᵤ1),
        (A=2, B=2±ᵤ1),
        (A=3, B=2±ᵤ1),
        (A=1, B=3±ᵤ3.5),
        (A=2, B=3±ᵤ3.5),
        (A=3, B=3±ᵤ3.5),
        (A=6, B=3±ᵤ3.5),
    ])
    @test issetequal(
        innerjoin((;A, B), U.by_uncertainty(identity, identity); mode=FlexiJoins.Mode.NestedLoop(), loop_over_side=:B),
        J
    )
    J = innerjoin((;A=map(tuple, A), B), U.by_uncertainty(only, identity); mode=FlexiJoins.Mode.NestedLoop())
    J = innerjoin((;A=map(tuple, A), B=map(tuple, B)), U.by_uncertainty(only, only); mode=FlexiJoins.Mode.NestedLoop())
    # @test issetequal(innerjoin((;A, B), U.by_uncertainty(identity, identity)), J)
end
