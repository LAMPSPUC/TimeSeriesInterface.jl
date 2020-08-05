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

    @testset "arithmetic methods (+ - *)" begin
        stamps1  = [DateTime(2000, 1, i) for i = 1:2]
        vals1    = collect(1:length(stamps1))
        ts1      = TimeSeries("teste 1", stamps1, vals1)

        stamps2  = [DateTime(2000, 1, i) for i = 2:4]
        vals2    = collect(1:length(stamps2))
        ts2      = TimeSeries("teste 2", stamps2, vals2)

        stamps3  = [DateTime(2000, 1, i) for i = 1:4]
        vals3    = collect(1:length(stamps3))
        ts3      = TimeSeries("teste 3", stamps3, vals3)

        @test TimeSeriesInterface.verify_if_ts_are_equal(ts1 + ts2, TimeSeries("teste 1 + teste 2", [DateTime(2000, 1, i) for i = 1:4], [1, 3, 2, 3]))
        @test TimeSeriesInterface.verify_if_ts_are_equal(ts1 + ts2 + ts3, TimeSeries("teste 1 + teste 2 + teste 3", [DateTime(2000, 1, i) for i = 1:4], [2, 5, 5, 7]))
        @test TimeSeriesInterface.verify_if_ts_are_equal(- ts1, TimeSeries(string("- ",ts1.name), ts1.timestamps, -ts1.vals))
        @test TimeSeriesInterface.verify_if_ts_are_equal(ts1 - ts2, TimeSeries("teste 1 - teste 2", [DateTime(2000, 1, i) for i = 1:4], [1, 1, -2, -3]))
        @test TimeSeriesInterface.verify_if_ts_are_equal(+ ts1 - ts2, TimeSeries("teste 1 - teste 2", [DateTime(2000, 1, i) for i = 1:4], [1, 1, -2, -3]))
        @test TimeSeriesInterface.verify_if_ts_are_equal(ts1 - ts2, TimeSeries("teste 1 - teste 2", [DateTime(2000, 1, i) for i = 1:4], [1, 1, -2, -3]))
        @test TimeSeriesInterface.verify_if_ts_are_equal(ts1 - ts2 - ts3, TimeSeries("teste 1 - teste 2 - teste 3", [DateTime(2000, 1, i) for i = 1:4], [0, -1, -5, -7]))
        @test TimeSeriesInterface.verify_if_ts_are_equal(ts1 - ts1 + ts1, TimeSeries("teste 1 - teste 1 + teste 1", [DateTime(2000, 1, i) for i = 1:2], [1, 2]))
        @test TimeSeriesInterface.verify_if_ts_are_equal(ts1 * ts2, TimeSeries("teste 1 * teste 2", [DateTime(2000, 1, i) for i = 1:4], [1, 2, 2, 3]))
        @test TimeSeriesInterface.verify_if_ts_are_equal(ts1 * ts1 * ts1, TimeSeries("teste 1 * teste 1 * teste 1", [DateTime(2000, 1, i) for i = 1:2], [1, 8]))
        @test TimeSeriesInterface.verify_if_ts_are_equal(ts1 * ts2 * ts3, TimeSeries("teste 1 * teste 2 * teste 3", [DateTime(2000, 1, i) for i = 1:4], [1, 4, 6, 12]))
        @test TimeSeriesInterface.verify_if_ts_are_equal(ts1 + ts2 * ts3, TimeSeries("teste 1 + teste 2 * teste 3", [DateTime(2000, 1, i) for i = 1:4], [2, 4, 6, 12]))
        @test TimeSeriesInterface.verify_if_ts_are_equal((ts1 + ts2) * ts3, TimeSeries("teste 1 + teste 2 * teste 3", [DateTime(2000, 1, i) for i = 1:4], [1, 6, 6, 12]))
        
    end
end


