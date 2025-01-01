@testitem "display" begin
    @test string(U.Value(1, 0)) == "1 ±ᵤ 0"
    @test string(U.Value(1, nothing)) == "1 ±ᵤ nothing"
    @test string(U.Value(1.23456, 12.3456)) == "1.23456 ±ᵤ 12.3456"

    @test sprint(show, MIME("text/plain"), U.Value(1, 0)) == "1 ± 0"
    @test sprint(show, MIME("text/plain"), U.Value(1, nothing)) == "1 ± nothing"
    @test sprint(show, MIME("text/plain"), U.Value(1.23456, 12.3456)) == "1.23456 ± 12.3456"
end

@testitem "printf" begin
    using Printf
    using PyFormattedStrings

    u = U.Value(1.23, 0.45)
    @test @sprintf("%d", u) == "1 ± 0"
    @test @sprintf("%f", u) == "1.230000 ± 0.450000"
    @test @sprintf("%.3f", u) == "1.230 ± 0.450"
    @test f"u {u:f}" == "u 1.230000 ± 0.450000"
    @test f"u {u:.3f}" == "u 1.230 ± 0.450"
end
