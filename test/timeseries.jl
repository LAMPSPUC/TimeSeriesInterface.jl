@testset "TimeSeries" begin
    @testset "constructor" begin
        timestamps = collect(DateTime(2000):Hour(1):DateTime(2000, 2, 1))
        vals       = rand(length(timestamps))
        ts         = TimeSeries("teste", timestamps, vals)
        @test isa(ts, TimeSeries)

        timestamps = collect(DateTime(2000):Day(1):DateTime(2000, 2, 1))
        vals       = rand(length(timestamps))
        ts         = TimeSeries("teste", timestamps, vals)
        @test isa(ts, TimeSeries)

        timestamps = collect(DateTime(2000):Second(1):DateTime(2000, 1, 1, 1, 1, 1))
        vals       = rand(length(timestamps))
        ts         = TimeSeries("teste", timestamps, vals)
        @test isa(ts, TimeSeries)

        timestamps = collect(DateTime(2000):Day(1):DateTime(2000, 2, 1))
        vals       = rand(length(timestamps))[1:end-1]
        @test_throws DimensionMismatch TimeSeries("teste", timestamps, vals)

        timestamps = [DateTime(2001); DateTime(2000, 2, 1)]
        vals       = [1, 2]
        @test_throws ErrorException TimeSeries("teste", timestamps, vals)

        timestamps = [DateTime(2001); DateTime(2001, 1, 1)]
        vals       = [1, 2]
        @test_throws ErrorException TimeSeries("teste", timestamps, vals)
    end
end