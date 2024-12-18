# 1 - Exploratory

|count                   |total          |participating  |nonparticipating|
|------------------------|---------------|---------------|----------------|
|total_rows              |9755427        |9752920        |2507            |
|total_services_counts   |2519056497     |2518643360     |413137          |
|total_distinct_codes    |6326           |6326           |254             |
|total_distinct_providers|1148873        |1147953        |1500            |
|total_submitted         |350498591205.20|350472972845.55|25618359.65     |
|total_allowed           |113035590246.62|113017521823.43|18068423.19     |
|total_paid              |89042721381.01 |89029606711.96 |13114669.05     |

The first query is for exploratory purposes. The code is the first set of SQL code in the decided views file. 

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
  * The counts of total and participating are almost the same, only a minimum amount of all submissions were from providers that 
    did not accept the Medicare designated payment

Reminder: for the rest of the queries, the focus will be on the the payment data that falls under the participating column also within the continental United States (including Hawaii)

***
***

# 2 - Spending per State

![alt text](https://github.com/piepiepies/2022partBphysiciansothers/blob/main/payment%20state.PNG?raw=true)

This table was generated with the second set of SQL code from the decided views file. The focus on the total amount that was paid
to each state through Medicare Part B for the phyisicians and others services, the average amount between all the states, and the median amount.

The top 4 states in terms of total payment are California, Florida, Texas, and NY in descending order.
Through this query:
````sql
SELECT
	TOP 4
	provider_state,
	ROUND(state_total_paid/1000000000, 2) AS total_paid_in_billions,
	ROUND(avg_total_paid/1000000000, 2) AS national_avg_in_billions,
	ROUND(median_total_paid/1000000000,2 ) AS national_median_in_billions
FROM state_information
ORDER BY state_total_paid DESC
````
|provider_state          |total_paid_in_billions|national_avg_in_billions|national_median_in_billions|
|------------------------|----------------------|------------------------|---------------------------|
|CA                      |10.67                 |1.74                    |1.02                       |
|FL                      |8.32                  |1.74                    |1.02                       |
|TX                      |6.47                  |1.74                    |1.02                       |
|NY                      |6.24                  |1.74                    |1.02                       |

You can see how each of the 4 states total payment amount compares to the national average and national median.
California's total paid amount was over 10 times the national average state paid amount amongst the states.

***

A quick query of the amount of states that were over the national average payment and below the national average payment.
````sql
SELECT
	SUM(CASE WHEN state_total_paid > avg_total_paid THEN 1 ELSE 0 END) AS states_count_over_avg,
	SUM(CASE WHEN state_total_paid < avg_total_paid THEN 1 ELSE 0 END) AS states_count_under_avg
FROM state_information
````
|states_count_over_avg   |states_count_under_avg|
|------------------------|----------------------|
|16                      |35                    |

The majority of the states were actually under the national average paid amount.

***

Another quick query of the sum of total paid amounts of the top 4 vs. another sum of the rest shows that with the rest of the states.
````sql
SELECT
	ROUND(SUM(CASE WHEN provider_state IN ('CA', 'FL', 'TX', 'NY') 
		THEN (state_total_paid)/1000000000.00 ELSE 0 END), 2) AS top_4_total_in_billions,
	ROUND(SUM(CASE WHEN provider_state NOT IN ('CA', 'FL', 'TX', 'NY') 
		THEN (state_total_paid)/1000000000.00 ELSE 0 END), 2) AS the_rest_total_in_billions
FROM state_information
````
|top_4_total_in_billions |the_rest_total_in_billions|
|------------------------|--------------------------|
|31.71                   |57.22                     |

The other states combined to 57.22 billion dollars in total payment, 25.51 billion dollars more than the top 4 combined amount.


***
***

# 3 Spending by Provider Entity Type

The following analysis uses the views third, fourth and fifth SQL codes in the decided views file.

I wanted to look at the Medicare payments to providers who are categorized as individuals versus those of providers categorized as organizations.

![alt text](https://github.com/piepiepies/2022partBphysiciansothers/blob/main/individual%20vs%20provider%20total%20spending.PNG?raw=true)
The total amount that individual providers received in payments from Medicare is over 3 times that of organization providers.
The total amount of services that were submitted and the amount of providers that submitted also reflect that as well.

````sql
SELECT
	entity_type,
	entity_total_rows,
	entity_total_services_counts,
	entity_total_distinct_codes,
	entity_total_distinct_providers
FROM indiv_vs_org
ORDER BY entity_type ASC
````
|entity_type |entity_total_rows|entity_total_services_counts|entity_total_distinct_codes|entity_total_distinct_providers|
|------------|-----------------|----------------------------|---------------------------|-------------------------------|
|Individual  |9190970          |1904696224                  |5616                       |1080540                        |
|Organization|538161           |610032904                   |2929                       |62915                          |

However, when querying for the top 15 providers in total paid amount in the continental U.S., the top 15 providers are actually all organization types.
````sql
select
	provider_last_name AS organization_name,
	provider_type AS organization_type,
	provider_state,
	total_rows,
	total_services_counts,
	npi_total_paid
from highest_providers
````
|organization_name                                 |organization_type                             |provider_state|total_rows|total_services_counts|npi_total_paid|
|--------------------------------------------------|----------------------------------------------|--------------|----------|---------------------|--------------|
|Exact Sciences Laboratories, Llc                  |Clinical Laboratory                           |WI            |1         |533023               |267646839     |
|Laboratory Corporation Of America Holdings        |Clinical Laboratory                           |NC            |657       |16218146             |221327954.3   |
|Care Dx, Inc.                                     |Clinical Laboratory                           |CA            |2         |61076                |174087958.6   |
|Laboratory Corporation Of America Holdings        |Clinical Laboratory                           |NJ            |625       |10835521             |131552863.2   |
|Guardant Health, Inc.                             |Clinical Laboratory                           |CA            |5         |31190                |129973918.6   |
|Quest Diagnostics Incorporated                    |Clinical Laboratory                           |NJ            |637       |9087471              |112350341.2   |
|Genomic Health, Inc.                              |Clinical Laboratory                           |CA            |8         |28784                |108512222.7   |
|Cardionet, Llc.                                   |Independent Diagnostic Testing Facility (IDTF)|CA            |5         |231540               |103610394     |
|Quest Diagnostics Clinical Laboratories Inc       |Clinical Laboratory                           |FL            |631       |8679973              |103112492     |
|Unilab Corporation                                |Clinical Laboratory                           |CA            |609       |7686331              |94459064.62   |
|Walgreen Co                                       |Centralized Flu                               |CO            |27        |4058537              |94271190.74   |
|Natera, Inc.                                      |Clinical Laboratory                           |CA            |3         |27128                |93177424.18   |
|Foundation Medicine, Inc.                         |Clinical Laboratory                           |MA            |4         |34323                |86855812.72   |
|Boston Scientific Cardiac Diagnostic Services, Llc|Independent Diagnostic Testing Facility (IDTF)|TX            |10        |169373               |80455900.36   |
|Irhythm Technologies, Inc.                        |Independent Diagnostic Testing Facility (IDTF)|CA            |4         |331089               |78873148.92   |

As the table shows, all the organizations that were part of the top 15 paid highest providers are some sort of testing facility/lab. For the state that these providers operate in, California came up the most, which is to be expected, since California was the top paid state. With that in mind, the top paid provider is actually from Wisconsin. From the visualization in part 2 earlier, Wisconsin was state whose total spending was lower than the national average.

![alt text](https://github.com/piepiepies/2022partBphysiciansothers/blob/main/wisconsin.PNG?raw=True)

The Exact Sciences total paid, 0.27 billion dollars, accounts for 32% of the total paid amount of Wisconsin, 1.19 billion dollars.
