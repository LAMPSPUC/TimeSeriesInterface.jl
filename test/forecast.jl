@testset "Scenarios" begin
    @testset "constructor" begin
        timestamps = collect(DateTime(2000):Hour(1):DateTime(2000, 2, 1))
        vals       = rand(length(timestamps), 10)
        scen       = Scenarios("teste", timestamps, vals)
        @test isa(scen, Scenarios)

        timestamps = collect(DateTime(2000):Day(1):DateTime(2000, 2, 1))
        vals       = rand(length(timestamps), 10)
        scen       = Scenarios("teste", timestamps, vals)
        @test isa(scen, Scenarios)

        timestamps = collect(DateTime(2000):Second(1):DateTime(2000, 1, 1, 1, 1, 1))
        vals       = rand(length(timestamps), 1)
        scen       = Scenarios("teste", timestamps, vals)
        @test isa(scen, Scenarios)

        timestamps = collect(DateTime(2000):Day(1):DateTime(2000, 2, 1))
        vals       = rand(length(timestamps), 1)[1:end-1, :]
        @test_throws DimensionMismatch Scenarios("teste", timestamps, vals)

        timestamps = [DateTime(2001); DateTime(2000, 2, 1)]
        vals       = [1 1; 2 2]
        @test_throws ErrorException Scenarios("teste", timestamps, vals)

        timestamps = [DateTime(2001); DateTime(2001, 1, 1)]
        vals       = [1 2; 2 3]
        @test_throws ErrorException Scenarios("teste", timestamps, vals)
    end
end