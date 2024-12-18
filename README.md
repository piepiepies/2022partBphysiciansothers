# 2022 Part B Physicians and Others 
This is a SQL project analyzing the Medicare Physician & Other Practitioners - by Provider and Service data for the 2022 year provided by CMS.
Description of the data taken from the website:
Information on services and procedures provided to Original Medicare (fee-for-service) 
Part B (Medical Insurance) beneficiaries by physicians and other healthcare professionals; aggregated by provider and service.
This data is available on https://data.cms.gov/provider-summary-by-type-of-service/medicare-physician-other-practitioners/medicare-physician-other-practitioners-by-provider-and-service. I was not able to upload it on here because the CSV is 3GB, limit is 25MB. The data was imported into SQL Server via SSMS using SQL. The visualizations are screenshots from visualizations created on PowerBI after importing the views from the decided views.sql file.

The focus of this project is on submissions for services on the continental US (including Hawaii) 
from providers that are Medicare participants, meaning that they are willing to accept the payment amount dictated by Medicare. 


Files include:
1) SQL code
   * to upload the data to SQL Server: [original_data_load.sql](https://github.com/piepiepies/2022partBphysiciansothers/blob/main/original_data_load.sql)
   * normalizing the data by distributing into multiple tables: [table_creation.sql](https://github.com/piepiepies/2022partBphysiciansothers/blob/main/table_creation.sql)
   * updating the column types and creating primary/foreign keys: [keys_creation_types_changing.sql](https://github.com/piepiepies/2022partBphysiciansothers/blob/main/keys_creation_types_changing.sql)
   * creating views for the for further querying and visualizations: [decided views.sql](https://github.com/piepiepies/2022partBphysiciansothers/blob/main/decided%20views.sql)
2) Database diagram from SSMS: [database diagram.PNG](https://github.com/piepiepies/2022partBphysiciansothers/blob/main/database%20diagram.PNG)
3) Query results: [queryresults.MD](https://github.com/piepiepies/2022partBphysiciansothers/blob/main/queryresults.MD) 
