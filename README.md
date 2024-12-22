# 2022 Part B Physicians and Others 
This is a SQL project using the Medicare Physician & Other Practitioners - by Provider and Service data for the 2022 year provided by CMS.
Description of the data taken from the website:
Information on services and procedures provided to Original Medicare (fee-for-service) 
Part B (Medical Insurance) beneficiaries by physicians and other healthcare professionals; aggregated by provider and service.
This data is available on https://data.cms.gov/provider-summary-by-type-of-service/medicare-physician-other-practitioners/medicare-physician-other-practitioners-by-provider-and-service. I was not able to upload it on here because the CSV is 3GB, limit is 25MB. 

The data was imported into SQL Server via SSMS using SQL. After importing the data, the data was further normalized and distributed into 4 tables: payment_information (main table), provider_information, ruca_information, and hcpcs_information. See [database diagram](https://github.com/piepiepies/2022partBphysiciansothers/blob/main/database%20diagram.PNG) for the four tables.

Refer to the SQL code below for the process and the views:
   * to upload the data to SQL Server: [original_data_load.sql](https://github.com/piepiepies/2022partBphysiciansothers/blob/main/original_data_load.sql)
   * normalizing the data by distributing into multiple tables: [table_creation.sql](https://github.com/piepiepies/2022partBphysiciansothers/blob/main/table_creation.sql)
   * updating the column types and creating primary/foreign keys: [keys_creation_types_changing.sql](https://github.com/piepiepies/2022partBphysiciansothers/blob/main/keys_creation_types_changing.sql)
   * creating views for the for further querying and visualizations: [decided views.sql](https://github.com/piepiepies/2022partBphysiciansothers/blob/main/decided%20views.sql)


This project is to analyze the submissions for services on the continental US (including Hawaii) from providers that are Medicare participants, meaning that they are willing to accept the payment amount dictated by Medicare. See below Power BI visualization for the general visualization of the project. Refer to [queryresults.MD](https://github.com/piepiepies/2022partBphysiciansothers/blob/main/queryresults.MD) for indepth analysis of the area of focus.

![alt text](https://github.com/piepiepies/2022partBphysiciansothers/blob/main/overall_info_visualization.PNG?raw=True)
