@testset "PointForecast" begin
    @testset "constructor" begin
        timestamps     = collect(DateTime(2000):Hour(1):DateTime(2000, 2, 1))
        forecast       = rand(length(timestamps))
        point_forecast = PointForecast("teste", timestamps, forecast)
        @test isa(point_forecast, PointForecast)

        timestamps     = collect(DateTime(2000):Day(1):DateTime(2000, 2, 1))
        forecast       = rand(length(timestamps))
        point_forecast = PointForecast("teste", timestamps, forecast)
        @test isa(point_forecast, PointForecast)

        timestamps     = collect(DateTime(2000):Second(1):DateTime(2000, 1, 1, 1, 1, 1))
        forecast       = rand(length(timestamps))
        point_forecast = PointForecast("teste", timestamps, forecast)
        @test isa(point_forecast, PointForecast)

        timestamps     = collect(Date(2000):Day(1):Date(2000, 2, 1))
        forecast       = rand(length(timestamps))
        point_forecast = PointForecast("teste", timestamps, forecast)
        @test isa(point_forecast, PointForecast)

        timestamps     = collect(Date(2000):Month(1):Date(2000, 12, 1))
        forecast       = rand(length(timestamps))
        point_forecast = PointForecast("teste", timestamps, forecast)
        @test isa(point_forecast, PointForecast)

        timestamps = collect(DateTime(2000):Day(1):DateTime(2000, 2, 1))
        forecast   = rand(length(timestamps))[1:end - 1]
        @test_throws DimensionMismatch PointForecast("teste", timestamps, forecast)

        timestamps = [DateTime(2001); DateTime(2000, 2, 1)]
        forecast   = [1; 1]
        @test_throws ErrorException PointForecast("teste", timestamps, forecast)

        timestamps = [DateTime(2001); DateTime(2001, 1, 1)]
        forecast   = [1; 1]
        @test_throws ErrorException PointForecast("teste", timestamps, forecast)
    end
    @testset "forecast_metrics" begin
        timestamps     = collect(DateTime(2000):Hour(1):DateTime(2000, 2, 1))
        vals           = rand(length(timestamps))
        forecast       = rand(length(timestamps))
        real_ts        = TimeSeries("teste", timestamps, vals)
        point_forecast = PointForecast("teste", timestamps, forecast)
        perfect_forecast = PointForecast("teste", timestamps, vals)

        point_forecast_metrics = forecast_metrics(point_forecast, real_ts)
        @test isa(point_forecast_metrics, PointForecastMetrics)
        @test all(point_forecast_metrics.absolute_percentage_errors .>= 0)

        perfect_forecast_metrics = forecast_metrics(perfect_forecast, real_ts)
        @test all(perfect_forecast_metrics.errors .== 0)
        @test all(perfect_forecast_metrics.absolute_percentage_errors .== 0)

        real_ts.vals[3] = 0
        warn_msg = "The real observations have values too close to zero. This makes the " *
                   "absolute percentage error impractical, NaNs will be returned."
                        
        @test_logs (:warn, warn_msg) forecast_metrics(point_forecast, real_ts)
        
        point_forecast_metrics = forecast_metrics(point_forecast, real_ts)
        @test isnan(point_forecast_metrics.absolute_percentage_errors[1])

        point_forecast = PointForecast("teste", timestamps[1:end - 1], forecast[1:end - 1])
        @test_throws DimensionMismatch forecast_metrics(point_forecast, real_ts)
    end
end

@testset "ScenariosForecast" begin
    @testset "constructor" begin
        timestamps              = collect(DateTime(2000):Hour(1):DateTime(2000, 2, 1))
        scenarios               = rand(length(timestamps), 10)
        quantiles_probabilities = [0.05; 0.95]
        quantiles               = rand(length(timestamps), 2)
        scenarios_forecast      = ScenariosForecast("teste", timestamps, scenarios, quantiles_probabilities, quantiles)
        @test isa(scenarios_forecast, ScenariosForecast)

        timestamps              = collect(DateTime(2000):Day(1):DateTime(2000, 2, 1))
        scenarios               = rand(length(timestamps), 10)
        quantiles_probabilities = [0.05; 0.95]
        quantiles               = rand(length(timestamps), 2)
        scenarios_forecast      = ScenariosForecast("teste", timestamps, scenarios, quantiles_probabilities, quantiles)
        @test isa(scenarios_forecast, ScenariosForecast)

        timestamps              = collect(DateTime(2000):Second(1):DateTime(2000, 1, 1, 1, 1, 1))
        scenarios               = rand(length(timestamps), 10)
        quantiles_probabilities = [0.05; 0.95]
        quantiles               = rand(length(timestamps), 2)
        scenarios_forecast      = ScenariosForecast("teste", timestamps, scenarios, quantiles_probabilities, quantiles)
        @test isa(scenarios_forecast, ScenariosForecast)

        timestamps              = collect(Date(2000):Day(1):Date(2000, 2, 1))
        scenarios               = rand(length(timestamps), 10)
        quantiles_probabilities = [0.05; 0.95]
        quantiles               = rand(length(timestamps), 2)
        scenarios_forecast      = ScenariosForecast("teste", timestamps, scenarios, quantiles_probabilities, quantiles)
        @test isa(scenarios_forecast, ScenariosForecast)

        timestamps              = collect(Date(2000):Month(1):Date(2000, 12, 1))
        scenarios               = rand(length(timestamps), 10)
        quantiles_probabilities = [0.05; 0.95]
        quantiles               = rand(length(timestamps), 2)
        scenarios_forecast      = ScenariosForecast("teste", timestamps, scenarios, quantiles_probabilities, quantiles)
        @test isa(scenarios_forecast, ScenariosForecast)

        timestamps              = collect(DateTime(2000):Day(1):DateTime(2000, 2, 1))
        scenarios               = rand(length(timestamps), 10)[1:end - 1, :]
        quantiles_probabilities = [0.05; 0.95]
        quantiles               = rand(length(timestamps), 2)
        @test_throws DimensionMismatch ScenariosForecast("teste", timestamps, scenarios, quantiles_probabilities, quantiles)

        timestamps              = collect(DateTime(2000):Day(1):DateTime(2000, 2, 1))
        scenarios               = rand(length(timestamps), 10)
        quantiles_probabilities = [0.05; 0.95]
        quantiles               = rand(length(timestamps), 2)[1:end - 1, :]
        @test_throws DimensionMismatch ScenariosForecast("teste", timestamps, scenarios, quantiles_probabilities, quantiles)
        
        timestamps              = collect(DateTime(2000):Day(1):DateTime(2000, 2, 1))
        scenarios               = rand(length(timestamps), 10)
        quantiles_probabilities = [0.05; 0.95]
        quantiles               = rand(length(timestamps), 1)
        @test_throws DimensionMismatch ScenariosForecast("teste", timestamps, scenarios, quantiles_probabilities, quantiles)

        timestamps              = [DateTime(2001); DateTime(2000, 2, 1)]
        scenarios               = [1.0 2.0; 3.0 4.0]
        quantiles_probabilities = [0.05; 0.95]
        quantiles               = rand(length(timestamps), 2)
        @test_throws ErrorException ScenariosForecast("teste", timestamps, scenarios, quantiles_probabilities, quantiles)

        timestamps = [DateTime(2001); DateTime(2001, 1, 1)]
        scenarios               = [1.0 2.0; 3.0 4.0]
        quantiles_probabilities = [0.05; 0.95]
        quantiles               = rand(length(timestamps), 2)
        @test_throws ErrorException ScenariosForecast("teste", timestamps, scenarios, quantiles_probabilities, quantiles)

    end
    @testset "forecast_metrics" begin
        @testset "probabilistic_calibration" begin
            # probabilistic_calibration
            timestamps              = collect(DateTime(2000):Hour(1):DateTime(2000, 1, 1, 24))
            scenarios               = vcat([collect(1.0:100)' for i in 1:length(timestamps)]...)
            quantiles_probabilities = [0.05; 0.95]
            quantiles               = TimeSeriesInterface.get_quantiles(quantiles_probabilities, scenarios)
            scenarios_forecast      = ScenariosForecast("teste", timestamps, scenarios, quantiles_probabilities, quantiles)

            vals    = 0.9 * ones(length(timestamps))
            real_ts = TimeSeries("teste", timestamps, vals)
            scen_forecast_metrics = forecast_metrics(scenarios_forecast, real_ts)
            @test scen_forecast_metrics.probabilistic_calibration[1][0.025] == true
            @test scen_forecast_metrics.probabilistic_calibration[1][0.975] == true
            @test scen_forecast_metrics.probabilistic_calibration[end][0.025] == true
            @test scen_forecast_metrics.probabilistic_calibration[end][0.975] == true

            vals    = 50 * ones(length(timestamps))
            real_ts = TimeSeries("teste", timestamps, vals)
            scen_forecast_metrics = forecast_metrics(scenarios_forecast, real_ts)
            @test scen_forecast_metrics.probabilistic_calibration[1][0.025] == false
            @test scen_forecast_metrics.probabilistic_calibration[1][0.475] == false
            @test scen_forecast_metrics.probabilistic_calibration[1][0.525] == true
            @test scen_forecast_metrics.probabilistic_calibration[1][0.975] == true
            @test scen_forecast_metrics.probabilistic_calibration[end][0.025] == false
            @test scen_forecast_metrics.probabilistic_calibration[end][0.475] == false
            @test scen_forecast_metrics.probabilistic_calibration[end][0.525] == true
            @test scen_forecast_metrics.probabilistic_calibration[end][0.975] == true

            real_ts = TimeSeries("teste", timestamps[1:end - 1], vals[1:end - 1])
            @test_throws DimensionMismatch forecast_metrics(scenarios_forecast, real_ts)
        end

        @testset "interval_width" begin
            # interval_width

            timestamps              = collect(DateTime(2000):Hour(1):DateTime(2000, 1, 1, 24))
            scenarios               = vcat([collect(0.0:100)' for i in 1:length(timestamps)]...)
            quantiles_probabilities = [0.05; 0.95]
            quantiles               = TimeSeriesInterface.get_quantiles(quantiles_probabilities, scenarios)
            scenarios_forecast      = ScenariosForecast("teste", timestamps, scenarios, quantiles_probabilities, quantiles)

        
            vals    = 50 * ones(length(timestamps))
            real_ts = TimeSeries("teste", timestamps, vals)
            scen_forecast_metrics = forecast_metrics(scenarios_forecast, real_ts)

            @test scen_forecast_metrics.interval_width[1][0.95] == 95
            @test scen_forecast_metrics.interval_width[1][0.85] == 85
            @test scen_forecast_metrics.interval_width[1][0.75] == 75
            @test isapprox(scen_forecast_metrics.interval_width[1][0.05], 5, atol=1e-8)
            

            scenarios_forecast = ScenariosForecast("teste", 
                                                   timestamps, 
                                                   fill(1.0, size(scenarios)),
                                                   quantiles_probabilities,
                                                   quantiles)
            
            scen_forecast_metrics = forecast_metrics(scenarios_forecast, real_ts)

            @test scen_forecast_metrics.interval_width[1][0.95] == 0
            @test scen_forecast_metrics.interval_width[1][0.85] == 0
            @test scen_forecast_metrics.interval_width[1][0.75] == 0
            @test scen_forecast_metrics.interval_width[1][0.05] == 0
        end

        @testset "crps" begin
            timestamps              = collect(DateTime(2000):Hour(1):DateTime(2000, 1, 1, 24))
            scenarios               = vcat([collect(1.0:10)' for i in 1:length(timestamps)]...)
            quantiles_probabilities = [0.05; 0.95]
            quantiles               = TimeSeriesInterface.get_quantiles(quantiles_probabilities, scenarios)
            scenarios_forecast      = ScenariosForecast("teste", timestamps, scenarios, quantiles_probabilities, quantiles)

        
            vals    = 5 * ones(length(timestamps))
            real_ts = TimeSeries("teste", timestamps, vals)

            scen_forecast_metrics = forecast_metrics(scenarios_forecast, real_ts)

            @test isapprox(scen_forecast_metrics.crps[1], 0.85, atol=1e-8)
            @test isapprox(scen_forecast_metrics.crps[end], 0.85, atol=1e-8)
            
            timestamps              = collect(DateTime(2000):Hour(1):DateTime(2000, 1, 1, 24))
            scenarios               = vcat([100 * ones(100)' for i in 1:length(timestamps)]...)
            quantiles_probabilities = [0.05; 0.95]
            quantiles               = TimeSeriesInterface.get_quantiles(quantiles_probabilities, scenarios)
            scenarios_forecast      = ScenariosForecast("teste", timestamps, scenarios, quantiles_probabilities, quantiles)
        
            vals    = 100 * ones(length(timestamps))
            real_ts = TimeSeries("teste", timestamps, vals)

            scen_forecast_metrics = forecast_metrics(scenarios_forecast, real_ts)

            @test scen_forecast_metrics.crps[1] == 0
            @test scen_forecast_metrics.crps[end] == 0

            vals    = 75 * ones(length(timestamps))
            real_ts = TimeSeries("teste", timestamps, vals)

            scen_forecast_metrics = forecast_metrics(scenarios_forecast, real_ts)

            @test scen_forecast_metrics.crps[1] == 25
            @test scen_forecast_metrics.crps[end] == 25

            sample                  = [-0.199187226 -0.654257527 -0.288307156  0.418189042  0.197436432  1.895931546  1.017915723 -0.272472671 2.214909442  1.380922228  0.282614757  0.913507684 -0.053783258  1.881443019  0.103841771 -1.252779110 -0.132589256 -0.579265376 -0.583994395  0.002848462 -0.269945185 -0.456626860 -2.109125117  0.733358687 -1.504387776  0.056461675 -1.152835005  1.378847909 -1.337631414 -1.523305411]
            timestamps              = collect(DateTime(2000):Hour(1):DateTime(2000, 1, 1, 24))
            scenarios               = vcat([sample for i in 1:length(timestamps)]...)
            quantiles_probabilities = [0.05; 0.95]
            quantiles               = TimeSeriesInterface.get_quantiles(quantiles_probabilities, scenarios)
            scenarios_forecast      = ScenariosForecast("teste", timestamps, scenarios, quantiles_probabilities, quantiles)

            vals    = 0 * ones(length(timestamps))
            real_ts = TimeSeries("teste", timestamps, vals)

            scen_forecast_metrics = forecast_metrics(scenarios_forecast, real_ts)
            
            @test scen_forecast_metrics.crps[1] ≈ 0.2302562 atol = 1e-5

            sample = [-0.6889628 -2.4344944  0.9186731  0.2957021 -2.4110891 -1.5940046 -0.9326339 -0.9258965  0.1313751 -0.4786784 -1.2069921 -0.5199624 -0.5428000  0.7640408  2.4055897 -0.6818087 -0.5684771  1.2199405  0.7852317 -1.0741016 0.8523647  0.2882272  0.1489849  0.5510892  2.2931913 -0.4039241  0.4205298  1.0697491  1.6286060 -0.5272440]
            timestamps              = collect(DateTime(2000):Hour(1):DateTime(2000, 1, 1, 24))
            scenarios               = vcat([sample for i in 1:length(timestamps)]...)
            quantiles_probabilities = [0.05; 0.95]
            quantiles               = TimeSeriesInterface.get_quantiles(quantiles_probabilities, scenarios)
            scenarios_forecast      = ScenariosForecast("teste", timestamps, scenarios, quantiles_probabilities, quantiles)

            vals    = 0 * ones(length(timestamps))
            real_ts = TimeSeries("teste", timestamps, vals)
            
            scen_forecast_metrics = forecast_metrics(scenarios_forecast, real_ts)
            
            @test scen_forecast_metrics.crps[1] ≈ 0.3051423 atol = 1e-5

            vals    = 2 * ones(length(timestamps))
            real_ts = TimeSeries("teste", timestamps, vals)
            
            scen_forecast_metrics = forecast_metrics(scenarios_forecast, real_ts)
            
            @test scen_forecast_metrics.crps[1] ≈ 1.433508 atol = 1e-5

            sample = [-0.22081509 -1.86684550 -1.44745981 -0.29519517 -0.64409419 -1.10534094 -2.50302412 -0.85041688 -1.39955151 0.36355304 -1.04568980  0.06692555 -0.10243452  0.82107023 -0.12405433  0.44602407  0.21596285  0.54478824 0.18668522  0.17744940  0.11352589  2.07332063  1.32748061 -2.08552933 -0.30302669  0.09773248 -0.26601496 -0.17519691  0.93558685 -1.36265031]
            timestamps              = collect(DateTime(2000):Hour(1):DateTime(2000, 1, 1, 24))
            scenarios               = vcat([sample for i in 1:length(timestamps)]...)
            quantiles_probabilities = [0.05; 0.95]
            quantiles               = TimeSeriesInterface.get_quantiles(quantiles_probabilities, scenarios)
            scenarios_forecast      = ScenariosForecast("teste", timestamps, scenarios, quantiles_probabilities, quantiles)

            vals    = 0 * ones(length(timestamps))
            real_ts = TimeSeries("teste", timestamps, vals)
            
            scen_forecast_metrics = forecast_metrics(scenarios_forecast, real_ts)
            
            @test scen_forecast_metrics.crps[1] ≈ 0.2197104 atol = 1e-5

            vals    = 2 * ones(length(timestamps))
            real_ts = TimeSeries("teste", timestamps, vals)
            
            scen_forecast_metrics = forecast_metrics(scenarios_forecast, real_ts)
            
            @test scen_forecast_metrics.crps[1] ≈ 1.733258 atol = 1e-5
        end
        @testset "mean_of_metrics" begin
            timestamps              = collect(DateTime(2000):Year(1):DateTime(2001))
            scenarios               = vcat([collect(1.0:10)' for i in 1:length(timestamps)]...)
            quantiles_probabilities = [0.05; 0.95]
            quantiles               = TimeSeriesInterface.get_quantiles(quantiles_probabilities, scenarios)
            scenarios_forecast      = ScenariosForecast("teste", timestamps, scenarios, quantiles_probabilities, quantiles)
            real_ts                 = TimeSeries("teste", timestamps, [5.0; 5.0])
            metrics                 = forecast_metrics(scenarios_forecast, real_ts)

            mean_of_probabilistic_calibration,
            mean_of_interval_width,
            mean_of_crps = TimeSeriesInterface.mean_of_metrics([metrics; metrics])

            @test mean_of_crps == [0.85; 0.85]
        end
    end
end

@testset "QuantilesForecast" begin
    @testset "constructor" begin
        timestamps              = collect(DateTime(2000):Hour(1):DateTime(2000, 2, 1))
        quantiles_probabilities = [0.05; 0.95]
        quantiles               = rand(length(timestamps), 2)
        quantiles_forecast      = QuantilesForecast("teste", timestamps, quantiles_probabilities, quantiles)
        @test isa(quantiles_forecast, QuantilesForecast)

        timestamps              = collect(DateTime(2000):Day(1):DateTime(2000, 2, 1))
        quantiles_probabilities = [0.05; 0.95]
        quantiles               = rand(length(timestamps), 2)
        quantiles_forecast      = QuantilesForecast("teste", timestamps, quantiles_probabilities, quantiles)
        @test isa(quantiles_forecast, QuantilesForecast)

        timestamps              = collect(DateTime(2000):Second(1):DateTime(2000, 1, 1, 1, 1, 1))
        quantiles_probabilities = [0.05; 0.95]
        quantiles               = rand(length(timestamps), 2)
        quantiles_forecast      = QuantilesForecast("teste", timestamps, quantiles_probabilities, quantiles)
        @test isa(quantiles_forecast, QuantilesForecast)

        timestamps              = collect(Date(2000):Day(1):Date(2000, 2, 1))
        quantiles_probabilities = [0.05; 0.95]
        quantiles               = rand(length(timestamps), 2)
        quantiles_forecast      = QuantilesForecast("teste", timestamps, quantiles_probabilities, quantiles)
        @test isa(quantiles_forecast, QuantilesForecast)

        timestamps              = collect(Date(2000):Month(1):Date(2000, 12, 1))
        quantiles_probabilities = [0.05; 0.95]
        quantiles               = rand(length(timestamps), 2)
        quantiles_forecast      = QuantilesForecast("teste", timestamps, quantiles_probabilities, quantiles)
        @test isa(quantiles_forecast, QuantilesForecast)

        timestamps              = collect(DateTime(2000):Day(1):DateTime(2000, 2, 1))
        quantiles_probabilities = [0.05; 0.95]
        quantiles               = rand(length(timestamps), 2)[1:end - 1, :]
        @test_throws DimensionMismatch QuantilesForecast("teste", timestamps, quantiles_probabilities, quantiles)
        
        timestamps              = collect(DateTime(2000):Day(1):DateTime(2000, 2, 1))
        quantiles_probabilities = [0.05; 0.95]
        quantiles               = rand(length(timestamps), 1)
        @test_throws DimensionMismatch QuantilesForecast("teste", timestamps, quantiles_probabilities, quantiles)

        timestamps              = [DateTime(2001); DateTime(2000, 2, 1)]
        quantiles_probabilities = [0.05; 0.95]
        quantiles               = rand(length(timestamps), 2)
        @test_throws ErrorException QuantilesForecast("teste", timestamps, quantiles_probabilities, quantiles)

        timestamps = [DateTime(2001); DateTime(2001, 1, 1)]
        quantiles_probabilities = [0.05; 0.95]
        quantiles               = rand(length(timestamps), 2)
        @test_throws ErrorException QuantilesForecast("teste", timestamps, quantiles_probabilities, quantiles)

    end
end