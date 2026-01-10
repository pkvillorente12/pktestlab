# Sample Airline On-Time Performance Dataset

### Raw CSV Schema
FlightDate, AirlineCode, AirlineName, FlightNumber, OriginAirport, OriginCity, OriginState, DestAirport, DestCity, DestState, ScheduledDepTime, ActualDepTime, DepDelayMinutes, ScheduledArrTime, ActualArrTime, ArrDelayMinutes, Cancelled, CancellationReason, DistanceKM

File Used: 
https://github.com/pkvillorente12/pktestlab/tree/main/raw

### Logical Model
FactFlightPerformance
 ├── AirlineKey → DimAirline
 ├── OriginAirportKey → DimAirport
 ├── DestAirportKey → DimAirport
 ├── DateKey → DimDate

### Azure Multi-service Medallion Architecture
Sample architecture is provided below: 

ADLS via ADF
datalakepktestlab/
│
├── raw/
│   └── airline_dw/
│       └── year=2024/month=01/flight_raw.csv
│       └── year=2024/month=02/flight_raw.csv
│       └── year=2024/month=03/flight_raw.csv
│

ADLS via Databricks
├── enriched/
│   ├── airline_dw/
│     ├── dim_airline/
│     ├── dim_airport/
│     ├── dim_date/
│     └── fact_flight_performance/

SYNAPSE ANALYTICS
pktestserverless
├── analytics/
    └── synapse_external_tables/


### Target Data Model (Star Schema)
Fact Table
	• FactFlightPerformance
Dimension Tables
	• DimAirline
	• DimAirport
	• DimDate

Other External Views created
	• OnTimePerformance
	• CancellationRate


## Procedure

### Upload csv files into GitHub
- File location: https://github.com/pkvillorente12/pktestlab/tree/main/raw
- This contains 3 csv files with same naming convention





