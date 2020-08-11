@testset "ModelInput" begin
    @testset "Deterministic" begin
        # Creation of parameters
        parameters1 = Dict{String, Any}("steps_ahead" => 5)
        parameters2 = Dict{String, Any}()
        parameters3 = Dict{String, Any}("steps_ahead" => 6)

        # Creation of dependent
        name       = "Dependent1"
        timestamps = collect(DateTime(2001):Year(1):DateTime(2020))
        vals       = rand(20)
        dependent1 = TimeSeries(name, timestamps, vals)
        
        name       = "Dependent2"
        timestamps = collect(DateTime(1981):Year(1):DateTime(2000))
        vals       = rand(20)
        dependent2 = TimeSeries(name, timestamps, vals)

        name       = "Dependent3"
        timestamps = collect(DateTime(1981):Year(1):DateTime(2020))
        vals       = rand(40)
        dependent3 = TimeSeries(name, timestamps, vals)

        # Creation of exogenous
        name       = "Exogenous1"
        timestamps = collect(DateTime(2001):Year(1):DateTime(2020))
        vals       = rand(20)
        exogenous1 = TimeSeries(name, timestamps, vals)
        
        name       = "Exogenous2"
        timestamps = collect(DateTime(1981):Year(1):DateTime(2000))
        vals       = rand(20)
        exogenous2 = TimeSeries(name, timestamps, vals)
        
        name       = "Exogenous3"
        timestamps = collect(DateTime(1981):Year(1):DateTime(2020))
        vals       = rand(40)
        exogenous3 = TimeSeries(name, timestamps, vals)
        
        # Creation of exogenous forecast
        name       = "Exogenous Forecast 1"
        timestamps = collect(DateTime(2021):Year(1):DateTime(2025))
        vals       = rand(5)
        exogenous_forecast1 = TimeSeries(name, timestamps, vals)

        name       = "Exogenous Forecast 2"
        timestamps = collect(DateTime(2022):Year(1):DateTime(2025))
        vals       = rand(4)
        exogenous_forecast2 = TimeSeries(name, timestamps, vals)

        name       = "Exogenous Forecast 3"
        timestamps = collect(DateTime(2012):Year(1):DateTime(2016))
        vals       = rand(5)
        exogenous_forecast3 = TimeSeries(name, timestamps, vals)
        
        # Test if there is the key steps_ahead in parameters.
        parameters = parameters2
        dependent = [dependent1, dependent1]
        exogenous = [exogenous1, exogenous1]
        exogenous_forecast = [exogenous_forecast1, exogenous_forecast1]
        @test_throws ErrorException Deterministic(parameters, dependent, exogenous, exogenous_forecast)

        # Test if the dependent vector is empty.
        parameters = parameters1
        dependent = TimeSeries{Float64}[]
        exogenous = [exogenous1, exogenous1]
        exogenous_forecast = [exogenous_forecast1, exogenous_forecast1]
        @test_throws ErrorException Deterministic(parameters, dependent, exogenous, exogenous_forecast)
           
        # Warn if the exogenous vector is empty.
        parameters = parameters1
        dependent = [dependent1]
        exogenous = TimeSeries{Float64}[]
        exogenous_forecast = TimeSeries{Float64}[]
        warn_msg = "Deterministic has no exogenous variables."
        @test_logs (:warn, warn_msg) Deterministic(parameters, dependent, exogenous, exogenous_forecast)

       # Test if exogenous and exogenous_forecast have the same number of time series
        parameters = parameters1
        dependent = [dependent1, dependent1]
        exogenous = [exogenous1]
        exogenous_forecast = TimeSeries{Float64}[]
        @test_throws ErrorException Deterministic(parameters, dependent, exogenous, exogenous_forecast)

        # Test if all the dependent have the same timestamps
        parameters = parameters1
        dependent = [dependent1, dependent2]
        exogenous = [exogenous1]
        exogenous_forecast = [exogenous_forecast1]
        @test_throws DimensionMismatch Deterministic(parameters, dependent, exogenous, exogenous_forecast)

        # Test if all the exogenous have the same timestamps
        parameters = parameters1
        dependent = [dependent1]
        exogenous = [exogenous1, exogenous2]
        exogenous_forecast = [exogenous_forecast1, exogenous_forecast1]
        @test_throws DimensionMismatch Deterministic(parameters, dependent, exogenous, exogenous_forecast)

        # Test if all the exogenous_forecast have the same timestamps
        parameters = parameters1
        dependent = [dependent1]
        exogenous = [exogenous1, exogenous1]
        exogenous_forecast = [exogenous_forecast1, exogenous_forecast2]
        @test_throws DimensionMismatch Deterministic(parameters, dependent, exogenous, exogenous_forecast)

        # Test if all the exogenous forecast timestamps has length equal to steps ahead
        parameters = parameters3
        dependent = [dependent1]
        exogenous = [exogenous1]
        exogenous_forecast = [exogenous_forecast1]
        @test_throws ErrorException Deterministic(parameters, dependent, exogenous, exogenous_forecast)

        # Test if dependent and exogenous have the same timestaamps
        parameters = parameters1
        dependent = [dependent1]
        exogenous = [exogenous2]
        exogenous_forecast = [exogenous_forecast1]
        @test_throws ErrorException Deterministic(parameters, dependent, exogenous, exogenous_forecast)

        # Test if exogenous_forecast timestamps are greater than dependent timestamps
        parameters = parameters1
        dependent = [dependent1]
        exogenous = [exogenous1]
        exogenous_forecast = [exogenous_forecast3]
        @test_throws ErrorException Deterministic(parameters, dependent, exogenous, exogenous_forecast)
    end
end