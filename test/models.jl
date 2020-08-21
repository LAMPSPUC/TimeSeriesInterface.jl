@testset "ModelInput" begin
    @testset "FitInput" begin
        # Creation of parameters
        parameters1 = Dict{String,Any}("steps_ahead" => 5)
        parameters2 = Dict{String,Any}()
        parameters3 = Dict{String,Any}("steps_ahead" => 6)

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

        # Test if the dependent vector is empty.
        parameters = parameters1
        dependent = TimeSeries{Float64}[]
        exogenous = [exogenous1, exogenous1]
        @test_throws ErrorException FitInput(parameters, dependent, exogenous)
           
        # Warn if the exogenous vector is empty.
        parameters = parameters1
        dependent = [dependent1]
        exogenous = TimeSeries{Float64}[]
        warn_msg = "Deterministic has no exogenous variables."
        @test_logs (:warn, warn_msg) FitInput(parameters, dependent, exogenous)

        # Test if all the dependent have the same timestamps
        parameters = parameters1
        dependent = [dependent1, dependent2]
        exogenous = [exogenous1]
        @test_throws DimensionMismatch FitInput(parameters, dependent, exogenous)

        # Test if all the exogenous have the same timestamps
        parameters = parameters1
        dependent = [dependent1]
        exogenous = [exogenous1, exogenous2]
        @test_throws DimensionMismatch FitInput(parameters, dependent, exogenous)

        # Test if dependent and exogenous have the same timestaamps
        parameters = parameters1
        dependent = [dependent1]
        exogenous = [exogenous2]
        @test_throws DimensionMismatch FitInput(parameters, dependent, exogenous)

    end

    @testset "SimulateInput" begin
        # Creation of parameters
        parameters1 = Dict{String,Any}("steps_ahead" => 5)
        parameters2 = Dict{String,Any}()
        parameters3 = Dict{String,Any}("steps_ahead" => 6)

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

        # Creation of timestamps forecast
        timestamps_forecast1 = collect(DateTime(2021):Year(1):DateTime(2025))
        timestamps_forecast2 = collect(DateTime(2022):Year(1):DateTime(2025))
        timestamps_forecast3 = collect(DateTime(2012):Year(1):DateTime(2016))
        
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

        # Creation of FitResult
        fit_result = FitResult(nothing, nothing)

       # Test if exogenous and exogenous_forecast have the same number of time series
        parameters = parameters1
        dependent = [dependent1, dependent1]
        exogenous = [exogenous1]
        exogenous_forecast = TimeSeries{Float64}[]
        @test_throws ErrorException SimulateInput(FitInput(parameters, dependent, exogenous), timestamps_forecast1, exogenous_forecast, fit_result)

        # Test if all the exogenous_forecast have the same timestamps
        parameters = parameters1
        dependent = [dependent1]
        exogenous = [exogenous1, exogenous1]
        exogenous_forecast = [exogenous_forecast1, exogenous_forecast2]
        @test_throws DimensionMismatch SimulateInput(FitInput(parameters, dependent, exogenous), timestamps_forecast1, exogenous_forecast, fit_result)

        # Warn if exogenous_forecast timestamps are not greater than dependent timestamps
        parameters = parameters1
        dependent = [dependent1]
        exogenous = [exogenous1]
        exogenous_forecast = [exogenous_forecast3]
        warn_msg = "timestamps of exogenous forecast are not greater than dependent timestamps."
        @test_logs (:warn, warn_msg) SimulateInput(FitInput(parameters, dependent, exogenous), timestamps_forecast3, exogenous_forecast, fit_result)

        # Test if each exogenous_forecast timestamps is equal timestamps_forecast
        parameters = parameters1
        dependent = [dependent1]
        exogenous = [exogenous1]
        exogenous_forecast = [exogenous_forecast1]
        @test_throws DimensionMismatch SimulateInput(FitInput(parameters, dependent, exogenous), timestamps_forecast2, exogenous_forecast, fit_result)
    end
end