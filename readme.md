# PSE
PSE WS2016/2017 Muth:  "Data-Warehouse mit Business Intelligence Dashboard"

This project has transformations and schema-cubes to transform date form the EIA into a more useful format.

We have used only the [ELEC.zip](http://api.eia.gov/bulk/ELEC.zip) but there are more files you could transform at the ['Bulk download facility'](http://www.eia.gov/opendata/bulkfiles.php) of the EIA.

In our case this format is a galaxy-schema in a MySQL-database. We also have the cubes to visualize the data using
pentaho and SAIKU, but decided to later create our own DB-API/queries in combination with a Bootstrap-Template. 
This is done in another repo [PSE Dashboard](https://github.com/SerkanBe/pse_dashboard)

# Contents
This project consists of 4 parts
  - Data analysis: Just code to understand the huge files EIA gives us.
  - Database: The db-schema, ERDs and the connector for mysql.
  - Data-integration: The transformations
  - Workbench schemas: The cubes
  
Each of the directories contain their own readme, where things are explained.