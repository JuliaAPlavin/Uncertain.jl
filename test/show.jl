@testitem "display" begin
    @test string(U.Value(1, 0)) == "1 ±ᵤ 0"
    @test string(U.Value(1, nothing)) == "1 ±ᵤ nothing"
    @test string(U.Value(1.23456, 12.3456)) == "1.23456 ±ᵤ 12.3456"
end
