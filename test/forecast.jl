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
        forecast   = rand(length(timestamps))[1:end-1]
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

        point_forecast = PointForecast("teste", timestamps[1:end-1], forecast[1:end-1])
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
        scenarios               = rand(length(timestamps), 10)[1:end-1, :]
        quantiles_probabilities = [0.05; 0.95]
        quantiles               = rand(length(timestamps), 2)
        @test_throws DimensionMismatch ScenariosForecast("teste", timestamps, scenarios, quantiles_probabilities, quantiles)

        timestamps              = collect(DateTime(2000):Day(1):DateTime(2000, 2, 1))
        scenarios               = rand(length(timestamps), 10)
        quantiles_probabilities = [0.05; 0.95]
        quantiles               = rand(length(timestamps), 2)[1:end-1, :]
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
        # probabilistic_calibration
        timestamps              = collect(DateTime(2000):Hour(1):DateTime(2000, 2, 1))
        scenarios               = vcat([collect(1.0:100)' for i in 1:length(timestamps)]...)
        quantiles_probabilities = [0.05; 0.95]
        quantiles               = TimeSeriesInterface.get_quantiles(quantiles_probabilities, scenarios)
        scenarios_forecast      = ScenariosForecast("teste", timestamps, scenarios, quantiles_probabilities, quantiles)

        vals    = 0.9*ones(length(timestamps))
        real_ts = TimeSeries("teste", timestamps, vals)
        scen_forecast_metrics = forecast_metrics(scenarios_forecast, real_ts)
        @test scen_forecast_metrics.probabilistic_calibration[1][0.025] == true
        @test scen_forecast_metrics.probabilistic_calibration[1][0.975] == true
        @test scen_forecast_metrics.probabilistic_calibration[end][0.025] == true
        @test scen_forecast_metrics.probabilistic_calibration[end][0.975] == true

        vals    = 50*ones(length(timestamps))
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

        real_ts = TimeSeries("teste", timestamps[1:end-1], vals[1:end-1])
        @test_throws DimensionMismatch forecast_metrics(scenarios_forecast, real_ts)

        # interval_width

        timestamps              = collect(DateTime(2000):Hour(1):DateTime(2000, 2, 1))
        scenarios               = vcat([collect(0.0:100)' for i in 1:length(timestamps)]...)
        quantiles_probabilities = [0.05; 0.95]
        quantiles               = TimeSeriesInterface.get_quantiles(quantiles_probabilities, scenarios)
        scenarios_forecast      = ScenariosForecast("teste", timestamps, scenarios, quantiles_probabilities,        quantiles)

    
        vals    = 0.9*ones(length(timestamps))
        real_ts = TimeSeries("teste", timestamps, vals)
        scen_forecast_metrics = forecast_metrics(scenarios_forecast, real_ts)

        @test scen_forecast_metrics.interval_width[1][0.95] == 95
        @test scen_forecast_metrics.interval_width[1][0.85] == 85
        @test scen_forecast_metrics.interval_width[1][0.75] == 75
        @test scen_forecast_metrics.interval_width[1][0.05] == 5
        

        scenarios_forecast      = ScenariosForecast("teste", timestamps, 1 .+ 0*scenarios, quantiles_probabilities, 
        quantiles)
        
        scen_forecast_metrics = forecast_metrics(scenarios_forecast, real_ts)

        @test scen_forecast_metrics.interval_width[1][0.95] == 0
        @test scen_forecast_metrics.interval_width[1][0.85] == 0
        @test scen_forecast_metrics.interval_width[1][0.75] == 0
        @test scen_forecast_metrics.interval_width[1][0.05] == 0
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
        quantiles               = rand(length(timestamps), 2)[1:end-1, :]
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