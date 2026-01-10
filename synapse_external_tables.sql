CREATE EXTERNAL DATA SOURCE AirlineLake
WITH (
    LOCATION = 'https://datalakepktestlab.dfs.core.windows.net/enriched',
    CREDENTIAL = pktestcreds
);
--need to include the credentials since it was set in the first external data source
--DROP EXTERNAL DATA SOURCE AirlineLake; --in case you made a wrong external data source


--check if query is working
SELECT *
FROM OPENROWSET(
    BULK 'airline_dw/dim_airline',
    DATA_SOURCE = 'AirlineLake',
    FORMAT = 'DELTA'
) AS d;

SELECT * FROM sys.external_data_sources;


--3.1 Create Dimension Views
-- DimAirline
CREATE VIEW vw_DimAirline
AS
SELECT *
FROM OPENROWSET(
    BULK 'airline_dw/dim_airline',
    DATA_SOURCE = 'AirlineLake',
    FORMAT = 'DELTA'
) AS d;


--DimDate

CREATE VIEW vw_DimDate
AS
SELECT *
FROM OPENROWSET(
    BULK 'airline_dw/dim_date',
    DATA_SOURCE = 'AirlineLake',
    FORMAT = 'DELTA'
) AS d;

--DimAirport

CREATE VIEW vw_DimAirport
AS
SELECT *
FROM OPENROWSET(
    BULK 'airline_dw/dim_airport',
    DATA_SOURCE = 'AirlineLake',
    FORMAT = 'DELTA'
) AS d;


--Create Fact Table
CREATE VIEW vw_FactFlights
AS
SELECT *
FROM OPENROWSET(
    BULK 'airline_dw/fact_flights',
    DATA_SOURCE = 'AirlineLake',
    FORMAT = 'DELTA'
) AS f;




CREATE VIEW vw_OnTimePerformance
AS
SELECT
    d.Year,
    a.AirlineName,
    COUNT(*) AS TotalFlights,
    AVG(f.ArrDelayMinutes) AS AvgArrivalDelay
FROM vw_FactFlights f
JOIN vw_DimDate d
    ON f.FlightDate = d.Date
JOIN vw_DimAirline a
    ON f.AirlineCode = a.AirlineCode
WHERE f.Cancelled = 0
GROUP BY d.Year, a.AirlineName;

--Cancellation Rate View (Extra Value)

CREATE VIEW vw_CancellationRate
AS
SELECT
    d.Year,
    a.AirlineName,
    SUM(CASE WHEN f.Cancelled = 1 THEN 1 ELSE 0 END) * 1.0 / COUNT(*) AS CancellationRate
FROM vw_FactFlights f
JOIN vw_DimDate d
    ON f.FlightDate = d.Date
JOIN vw_DimAirline a
    ON f.AirlineCode = a.AirlineCode
GROUP BY d.Year, a.AirlineName;

