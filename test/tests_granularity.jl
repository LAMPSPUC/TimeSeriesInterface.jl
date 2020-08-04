@testset "granularity" begin
        timestamps = collect(DateTime(2000, 2, 27):Hour(1):DateTime(2000, 10, 5))
        vals = ones(length(timestamps))
        ts = TimeSeries("teste", timestamps, vals)
        ts = hourly_to_monthly(ts)
        @test ts.name == "teste"
        @test all(ts.timestamps .== collect(DateTime(2000, 2, 1):Month(1):DateTime(2000, 10, 1)))
        @test all(ts.vals .== 1)
end