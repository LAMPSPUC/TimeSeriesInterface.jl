@testset "aggregation" begin
        timestamps = DateTime.(["2020-02-23T18:00", "2020-02-23T19:00", "2020-02-24T17:00", "2020-02-24T18:00",
                                "2020-04-23T18:00", "2020-05-23T18:00", "2020-07-13T13:00"])
        vals = Vector(1:length(timestamps))
        ts = TimeSeries("teste", timestamps, vals)
        ts = hourly_to_monthly(ts)
        @test ts.name == "teste"
        @test all(ts.timestamps .== DateTime.(["2020-02-01T00:00", "2020-04-01T00:00", "2020-05-01T00:00", "2020-07-01T00:00",]))
        @test all(ts.vals .≈  [2.5, 5, 6, 7])
end

@testset "disaggregation" begin
        timestamps = DateTime.(["2020-02-01T00:00", "2020-04-01T00:00", "2020-05-01T00:00", "2020-07-01T00:00",])
        vals = Vector(1:length(timestamps))
        ts = TimeSeries("teste", timestamps, vals)
        ts = monthly_to_hourly(ts)
        @test ts.name == "teste"
        expected_time_stamps = vcat(collect(DateTime(2020, 2, 1):Hour(1):DateTime(2020, 2, 29, 23)),
                collect(DateTime(2020, 4, 1):Hour(1):DateTime(2020, 4, 30, 23)),
                collect(DateTime(2020, 5, 1):Hour(1):DateTime(2020, 5, 31, 23)),
                collect(DateTime(2020, 7, 1):Hour(1):DateTime(2020, 7, 31, 23)))
        @test all(ts.timestamps .== expected_time_stamps)
        expected_vals = ones(length(expected_time_stamps))
        expected_vals[1:696] .= 1
        expected_vals[697:1416] .= 2
        expected_vals[1417:2160] .= 3
        expected_vals[2161:end] .= 4
        @test all(ts.vals .≈ expected_vals)
end