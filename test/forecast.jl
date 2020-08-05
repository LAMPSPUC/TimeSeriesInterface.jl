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