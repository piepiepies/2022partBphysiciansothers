# Query 1 - Exploratory

|count                   |total          |participating  |nonparticipating|
|------------------------|---------------|---------------|----------------|
|total_rows              |9755427        |9752920        |2507            |
|total_services_counts   |2519056497     |2518643360     |413137          |
|total_distinct_codes    |6326           |6326           |254             |
|total_distinct_providers|1148873        |1147953        |1500            |
|total_submitted         |350498591205.20|350472972845.55|25618359.65     |
|total_allowed           |113035590246.62|113017521823.43|18068423.19     |
|total_paid              |89042721381.01 |89029606711.96 |13114669.05     |

The first query is for exploratory purposes. 
For clarification:
  * total_rows = the total number of rows in that were submitted
  * total_services_counts = the total number of all the services that were provided
  * total_distinct_codes = the total number of distinct HCPCS codes that were provided
  * total_distinct_providers = the total number of distinct NPI in the submissions
  * total_submitted = the total amount of money that providers submitted to Medicare for payments
  * total_allowed = the total amount of money that Medicare agrees that the beneficiaries were responsible for
  * total_paid = the total amount of money that Medicare paid to the providers
  * participating = accepting Medicare designated payments
  * nonparticipating = not accepting Medicare designated payments

Summarization:
  * total amount that Original Medicare Part B paid for Physicians and Others in the year 2022 was $89,029,606,711.96, which was
    about 9% of the total Medicare spending in the year 2022. This amount came from 1,147,953 individual providers.
  * Only a minimum amount of all submissions were from providers that did not accept the Medicare designated payment


# Query 2 - Spending per State

![alt text](https://github.com/piepiepies/2022partBphysiciansothers/blob/main/payment%20state.PNG?raw=true)
