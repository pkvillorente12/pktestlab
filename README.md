# Sample Airline On-Time Performance Dataset


## Overview
Why this dataset?  
- High-volume transactional data (flights)
- Time-based analysis (daily, monthly, seasonal trends)
- Dimensional modeling (facts + dimensions)
- Late-arriving and corrected data
- Performance-sensitive reporting for business users

The Airline On-Time Performance analytics solution is created to demonstrate design enterprise-grade Power BI models.  
The project handles late-arriving data using Delta Lake upserts, uses a star schema optimized for reporting, and exposes analytics through Synapse and Power BI.   The focus was on performance, correctness, and scalability rather than just visuals.  


### Raw CSV Schema
Header Columns: 
FlightDate, AirlineCode, AirlineName, FlightNumber, OriginAirport, OriginCity, OriginState, DestAirport, DestCity, DestState, ScheduledDepTime, ActualDepTime, DepDelayMinutes, ScheduledArrTime, ActualArrTime, ArrDelayMinutes, Cancelled, CancellationReason, DistanceKM

File Used in this folder:  
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
- [x] Azure Resouce Group (RG-PKTestLab)
- [x] Azure Data Lake Gen2 (datalakepktestlab)
  - Enable **hierarchical namespace**
  - RBAC role for user: **Storage Blob Data Contributor**
  - Create containers
    - raw
    - enriched
- [x] Azure Data Factory (adfpktestlab)
  - RBAC role for user: **Data Factory Contributor**
- [x] Azure Key Vault (akvpktestlab)
  - Name:Kvdatalakepktestlab  
	- Added myself as Key Vault Secret Officer as I encountered an error wherein I cannot add a secret even though I am the owner of the KV.  
	- The reason is because AKV uses RBAC authorization which require explicit RBAC roles.
	- Stored Storage Account Key from Azure Data Lake Gen2
  - RBAC Role for user, ADF,   **Key Vault Secrets User**
- [x] Azure Synapse Workspace (pktestserverless)
- [x] Azure Databricks (adbpktestlab)


### Azure Data Factory Ingestion Pipeline (Raw/Browze Layer)  
Purpose:  
This activity is to copy the files from GitHub repo to Azure Data Lake

Document created:  
https://github.com/pkvillorente12/pktestlab/blob/main/Azure%20Data%20Factory%20Activities.docx

Source:  
https://github.com/pkvillorente12/pktestlab/tree/main/raw  

Target:   
├──raw/airline_dw/year=2024/month=01/FactFlights_raw_202401.csv  
├──raw/airline_dw/year=2024/month=02/FactFlights_raw_202402.csv  
├──raw/airline_dw/year=2024/month=03/FactFlights_raw_202403.csv  


### Databricks (Enriched/Silver Layer)  
Purpose:  
- Transform raw airline CSV into curated fact & dimension tables using PySpark + Delta Lake.
- Fact and dimension tables in the ADLS Gen2 to be used in analytics.
- Creating Delta Lake, provide historical logs, ensures reliability, ACID transactions, and schema enforcement on data lake storage, crucial for data quality
- Databricks is used in a broader scale which provide a clean enterprise view for different methods or procedure

Setting up Databricks:  
https://github.com/pkvillorente12/pktestlab/blob/main/Setting%20up%20Databricks.docx  

_I am having issues when setting up Databricks but I used an AI tool to assist me in connecting Databricks to ADLS Gen 2. _ 

Exported Jupyter Notebook used:  
https://github.com/pkvillorente12/pktestlab/blob/main/databricks_raw_to_enriched_airline_etl_multiple_files.ipynb  

Source:  
├──raw/airline_dw/year=2024/month=01/FactFlights_raw_202401.csv  
├──raw/airline_dw/year=2024/month=02/FactFlights_raw_202402.csv  
├──raw/airline_dw/year=2024/month=03/FactFlights_raw_202403.csv  

Target:  
├──enriched/airline_dw/fact_flights/  
├──enriched/airline_dw/dim_airport/  
├──enriched/airline_dw/dim_airline/   

_Target contains multiple folders and files (including json metadata) since Delta Lake is used_


### Synapse Analytics (Analytics/Gold Layer)  
Pool used:  
**Serverless**  

Purpose:
- Query Delta Tables directly from ADLS Gen2
- Create analytics semantic layer (views)
- Connects Power BI without data movement (uses view as screenshot)
- Technically, goal of using synapse serverless is it uses just adhoc sql which is more cost-efficient compare to doing in dedicated pool or databricks in smaller scales.  

Source:  
├──enriched/airline_dw/fact_flights/  
├──enriched/airline_dw/dim_airport/  
├──enriched/airline_dw/dim_airline/  

Target (created sql tables):  
├──dbo(analytics)/vw_fact_flights  
├──dbo(analytics)/vw_DimAirport  
├──dbo(analytics)/vw_DimAirline  
├──dbo(analytics)/vw_DimDate  

- Gold Layer (specific view in computing performance - business logic layer only)
 ├──dbo(analytics)/vw_OnTimePerformance  
 ├──dbo(analytics)/vw_CancellationRate  
  
Exported SQL Queries:  
https://github.com/pkvillorente12/pktestlab/blob/main/synapse_external_tables.sql  


### Connect to Power BI

_apparently azure service got expired but got the star schema in the PBI file_  

Procedure:  
- Connect to Synapse SQL Serverless
- Import or DirectQuery
- Build dashboards:
  - Flight tracking of Airlines passed for 3 months
  - Avg delay by airline
  - Cancellation rate
  - On-time percentage

Power BI Intricate details:  

| Characteristic | Why It Matters |
| --- | --- |
| Time-series data | Enables trends, YoY, MoM |
| Large fact table | Shows performance tuning |
| Natural dimensions | Airline, Airport, Date |
| Late data | Tests upsert logic |
| KPIs | On-time %, delay minutes |
