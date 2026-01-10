# Sample Airline On-Time Performance Dataset

## Overview

### Raw CSV Schema
Header Columns: 
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

### Creating Azure Resouce
Creating the ff. Azure Resources then assign RBAC roles 
- Azure Resouce Group (RG-PKTestLab)
- Azure Data Lake Gen2 (datalakepktestlab)
  - Enable **hierarchical namespace**
  - RBAC role for user: **Storage Blob Data Contributor**
  - Create containers
    - raw
    - enriched
- Azure Data Factory (adfpktestlab)
  - RBAC role for user: **Data Factory Contributor **
- Azure Key Vault (akvpktestlab)
  - Name:Kvdatalakepktestlab  
	- Added myself as Key Vault Secret Officer as I encountered an error wherein I cannot add a secret even though I am the owner of the KV.  
	- The reason is because AKV uses RBAC authorization which require explicit RBAC roles.
	- Stored Storage Account Key from Azure Data Lake Gen2
  - RBAC Role for user, ADF,  Key Vault Secrets User
- Azure Synapse Workspace (pktestserverless)
- Azure Databricks (adbpktestlab)


### 




### 





