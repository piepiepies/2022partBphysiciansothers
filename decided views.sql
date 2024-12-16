-- 1) total numbers for this data
WITH initial_cte AS(
SELECT
	CAST(COUNT(*) AS float) AS total_rows,
	CAST(SUM(total_services) AS float) AS total_services_counts,
	CAST(COUNT(DISTINCT hcpcs_code) AS float) AS total_distinct_codes,
	CAST(COUNT(DISTINCT provider_npi) AS float) AS total_distinct_providers,
	CAST(ROUND(SUM(total_services * avg_submitted_charge),2) AS float) AS total_submitted,
	CAST(ROUND(SUM(total_services * avg_medicare_allowed_amt),2) AS float) AS total_allowed,
	CAST(ROUND(SUM(total_services * avg_medicare_payment_amt),2) AS float) AS total_paid
FROM payment_information),
initial_unpvt_cte AS (
SELECT
	count,
	total
FROM initial_cte
UNPIVOT
(
	total FOR count IN (total_rows, total_services_counts, total_distinct_codes, total_distinct_providers,
	total_submitted, total_allowed, total_paid)) unpvt),
part_cte AS (
SELECT
	CAST(COUNT(*) AS float) AS total_rows,
	CAST(SUM(total_services) AS float) AS total_services_counts,
	CAST(COUNT(DISTINCT hcpcs_code) AS float) AS total_distinct_codes,
	CAST(COUNT(DISTINCT pay.provider_npi) AS float) AS total_distinct_providers,
	CAST(ROUND(SUM(total_services * avg_submitted_charge),2) AS float) AS total_submitted,
	CAST(ROUND(SUM(total_services * avg_medicare_allowed_amt),2) AS float) AS total_allowed,
	CAST(ROUND(SUM(total_services * avg_medicare_payment_amt),2) AS float) AS total_paid
FROM payment_information pay
INNER JOIN provider_information pro
	ON pay.provider_npi = pro.provider_npi
WHERE provider_medicare_participation = 'Y'),
part_unpvt_cte AS (
SELECT
	count,
	participating
FROM part_cte
UNPIVOT
(
	participating FOR count IN (total_rows, total_services_counts, total_distinct_codes, total_distinct_providers,
	total_submitted, total_allowed, total_paid)) unpvt),
nonpart_cte AS(
SELECT
	CAST(COUNT(*) AS float) AS total_rows,
	CAST(SUM(total_services) AS float) AS total_services_counts,
	CAST(COUNT(DISTINCT hcpcs_code) AS float) AS total_distinct_codes,
	CAST(COUNT(DISTINCT pay.provider_npi) AS float) AS total_distinct_providers,
	CAST(ROUND(SUM(total_services * avg_submitted_charge),2) AS float) AS total_submitted,
	CAST(ROUND(SUM(total_services * avg_medicare_allowed_amt),2) AS float) AS total_allowed,
	CAST(ROUND(SUM(total_services * avg_medicare_payment_amt),2) AS float) AS total_paid
FROM payment_information pay
INNER JOIN provider_information pro
	ON pay.provider_npi = pro.provider_npi
WHERE provider_medicare_participation = 'N'),
unpart_unpvt_cte AS (
SELECT
	count,
	nonparticipating
FROM nonpart_cte
UNPIVOT
(
	nonparticipating FOR count IN (total_rows, total_services_counts, total_distinct_codes, total_distinct_providers,
	total_submitted, total_allowed, total_paid)) unpvt)
SELECT 
	a.count, a.total, b.participating, c.nonparticipating
FROM initial_unpvt_cte a
INNER JOIN part_unpvt_cte b
ON a.count = b.count 
INNER JOIN unpart_unpvt_cte c
ON a.count = c.count
GO

-- 2) states information (medicare participant) in the continental us including hawaii
CREATE VIEW state_information AS
WITH state_cte AS (
SELECT
	provider_state,
	COUNT(*) AS state_total_rows,
	SUM(total_services) AS state_total_services_counts,
	COUNT(DISTINCT hcpcs_code) AS state_total_distinct_codes,
	COUNT(DISTINCT pay.provider_npi) AS state_total_distinct_providers,
	ROUND(SUM(total_services * avg_submitted_charge),2) AS state_total_submitted,
	ROUND(SUM(total_services * avg_medicare_allowed_amt),2) AS state_total_allowed,
	ROUND(SUM(total_services * avg_medicare_payment_amt),2) AS state_total_paid
FROM payment_information pay
INNER JOIN provider_information pro
	ON pay.provider_npi = pro.provider_npi
WHERE provider_medicare_participation = 'Y'
	AND provider_country = 'US' 
	AND provider_state NOT IN ('XX', 'AA', 'AE', 'AP', 'AS', 'GU', 'MP', 'PR', 'VI' , 'ZZ', 'FM')
GROUP BY provider_state)
SELECT
	TOP (100) PERCENT
	provider_state,
	state_total_rows,
	state_total_services_counts,
	state_total_distinct_codes,
	state_total_distinct_providers,
	state_total_paid,
	ROUND(AVG(state_total_paid) OVER (), 2) AS avg_total_paid,
	ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY state_total_paid) OVER (), 2) AS median_total_paid,
	state_total_allowed,
	state_total_submitted
FROM state_cte
ORDER BY state_total_paid DESC
GO

-- 3) individual vs organizations (medicare participant) in the continental us including hawaii
CREATE VIEW indiv_vs_org AS
SELECT
	CASE WHEN provider_entity_type = 'O' THEN 'Organization' ELSE 'Individual' END AS entity_type,
	COUNT(*) AS entity_total_rows,
	SUM(total_services) AS entity_total_services_counts,
	COUNT(DISTINCT hcpcs_code) AS entity_total_distinct_codes,
	COUNT(DISTINCT pay.provider_npi) AS entity_total_distinct_providers,
	ROUND(SUM(total_services * avg_submitted_charge),2) AS entity_total_submitted,
	ROUND(SUM(total_services * avg_medicare_allowed_amt),2) AS entity_total_allowed,
	ROUND(SUM(total_services * avg_medicare_payment_amt),2) AS entity_total_paid
FROM payment_information pay
INNER JOIN provider_information pro
	ON pay.provider_npi = pro.provider_npi
WHERE provider_medicare_participation = 'Y'
	AND provider_country = 'US' 
	AND provider_state NOT IN ('XX', 'AA', 'AE', 'AP', 'AS', 'GU', 'MP', 'PR', 'VI' , 'ZZ', 'FM')
GROUP BY provider_entity_type
GO

-- 4) 15 highest paid providers in the continental us, including HI (medicare participant) that organization
CREATE VIEW highest_org AS
WITH npi_cte AS (
SELECT
	pay.provider_npi,
	pro.provider_type,
	pro.provider_first_name,
	pro.provider_last_name,
	pro.provider_city,
	pro.provider_state,
	provider_entity_type,
	COUNT(*) AS total_rows,
	SUM(total_services) AS total_services_counts,
	ROUND(SUM(total_services * avg_submitted_charge),2) AS npi_total_submitted,
	ROUND(SUM(total_services * avg_medicare_allowed_amt),2) AS npi_total_allowed,
	ROUND(SUM(total_services * avg_medicare_payment_amt),2) AS npi_total_paid
FROM payment_information pay
INNER JOIN provider_information pro
	ON pay.provider_npi = pro.provider_npi
WHERE provider_medicare_participation = 'Y'
	AND provider_country = 'US' 
	AND provider_state NOT IN ('XX', 'AA', 'AE', 'AP', 'AS', 'GU', 'MP', 'PR', 'VI' , 'ZZ', 'FM')
GROUP BY pay.provider_npi,pro.provider_type,
	pro.provider_first_name, pro.provider_last_name,pro.provider_city,pro.provider_state, provider_entity_type)
SELECT TOP 15 *
FROM npi_cte
ORDER BY npi_total_paid DESC
GO

-- 5) 15 highest paid providers in the continental us, including HI (medicare participant) that are individuals
CREATE VIEW highest_indiv AS
WITH npi_cte AS (
SELECT
	pay.provider_npi,
	pro.provider_type,
	pro.provider_first_name,
	pro.provider_last_name,
	pro.provider_city,
	pro.provider_state,
	provider_entity_type,
	COUNT(*) AS total_rows,
	SUM(total_services) AS total_services_counts,
	ROUND(SUM(total_services * avg_submitted_charge),2) AS npi_total_submitted,
	ROUND(SUM(total_services * avg_medicare_allowed_amt),2) AS npi_total_allowed,
	ROUND(SUM(total_services * avg_medicare_payment_amt),2) AS npi_total_paid
FROM payment_information pay
INNER JOIN provider_information pro
	ON pay.provider_npi = pro.provider_npi
WHERE provider_medicare_participation = 'Y'
	AND provider_country = 'US' 
	AND provider_state NOT IN ('XX', 'AA', 'AE', 'AP', 'AS', 'GU', 'MP', 'PR', 'VI' , 'ZZ', 'FM')
	AND provider_entity_type = 'I'
GROUP BY pay.provider_npi,pro.provider_type,
	pro.provider_first_name, pro.provider_last_name,pro.provider_city,pro.provider_state, provider_entity_type)
SELECT TOP 15 *
FROM npi_cte
ORDER BY npi_total_paid DESC
GO

-- 6) specialties comparison in the continental us, including HI (medicare participant). grouped for better generalization
CREATE VIEW type_groups AS
WITH npi_cte AS (
SELECT
	CASE
		WHEN provider_type IN ('Internal Medicine', 'Family Practice', 'Geriatric Medicine', 
			'Osteopathic Manipulative Medicine', 'Nurse Practitioner', 
			'Preventive Medicine','General Practice') THEN 'PCP'
		WHEN provider_type IN ('Independent Diagnostic Testing Facility (IDTF)', 
			'Centralized Flu', 'Clinical Laboratory') THEN 'Lab'
		WHEN provider_type IN ('Pharmacy', 'All Other Suppliers') THEN 'Pharmacy/Supplier'
		WHEN provider_type IN ('Portable X-Ray Supplier', 'Mammography Center', 'Diagnostic Radiology') THEN 'Radiology'
		ELSE 'Specialist'
	END AS grouped_provider_type,
	pay.*
FROM payment_information pay
INNER JOIN provider_information pro
	ON pay.provider_npi = pro.provider_npi
WHERE provider_medicare_participation = 'Y'
	AND provider_country = 'US' 
	AND provider_state NOT IN ('XX', 'AA', 'AE', 'AP', 'AS', 'GU', 'MP', 'PR', 'VI' , 'ZZ', 'FM'))
SELECT
	TOP (100) PERCENT
	grouped_provider_type,
	COUNT(*) AS npi_total_rows,
	SUM(total_services) AS npi_total_services_counts,
	COUNT(DISTINCT hcpcs_code) AS npi_total_distinct_codes,
	ROUND(SUM(total_services * avg_submitted_charge),2) AS npi_total_submitted,
	ROUND(SUM(total_services * avg_medicare_allowed_amt),2) AS npi_total_allowed,
	ROUND(SUM(total_services * avg_medicare_payment_amt),2) AS npi_total_paid
FROM npi_cte
GROUP BY grouped_provider_type
ORDER BY npi_total_paid DESC
GO

-- 7) 15 highest paid hcpcs in the continental us, including HI (medicare participant)
CREATE VIEW highest_hcpcs AS
SELECT
	TOP 15
	pay.hcpcs_code,
	hcpcs.hcpcs_desc,
	hcpcs_drug_indicator,
	COUNT(*) AS total_rows,
	SUM(total_services) AS total_services_counts,
	AVG(pay.avg_medicare_payment_amt) AS hcpcs_avg_medicare_payment,
	ROUND(SUM(total_services * avg_submitted_charge),2) AS hcpcs_total_submitted,
	ROUND(SUM(total_services * avg_medicare_allowed_amt),2) AS hcpcs_total_allowed,
	ROUND(SUM(total_services * avg_medicare_payment_amt),2) AS hcpcs_total_paid
FROM payment_information pay
INNER JOIN provider_information pro
	ON pay.provider_npi = pro.provider_npi
INNER JOIN hcpcs_information hcpcs
	ON pay.hcpcs_code = hcpcs.hcpcs_code
WHERE provider_medicare_participation = 'Y'
	AND provider_country = 'US' 
	AND provider_state NOT IN ('XX', 'AA', 'AE', 'AP', 'AS', 'GU', 'MP', 'PR', 'VI' , 'ZZ', 'FM')
GROUP BY pay.hcpcs_code, hcpcs.hcpcs_desc, hcpcs_drug_indicator, pay.avg_medicare_payment_amt
ORDER BY hcpcs_total_paid DESC
GO

-- 8) outpatient visit codes in the continental us, including HI (medicare participant)
CREATE VIEW outpatient_visit_information AS
SELECT
	TOP (100) PERCENT
	pay.hcpcs_code,
	hcpcs.hcpcs_desc,
	COUNT(*) AS total_rows,
	SUM(total_services) AS total_services_counts,
	AVG(pay.avg_medicare_payment_amt) AS hcpcs_avg_medicare_payment,
	ROUND(SUM(total_services * avg_submitted_charge),2) AS hcpcs_total_submitted,
	ROUND(SUM(total_services * avg_medicare_allowed_amt),2) AS hcpcs_total_allowed,
	ROUND(SUM(total_services * avg_medicare_payment_amt),2) AS hcpcs_total_paid
FROM payment_information pay
INNER JOIN provider_information pro
	ON pay.provider_npi = pro.provider_npi
INNER JOIN hcpcs_information hcpcs
	ON pay.hcpcs_code = hcpcs.hcpcs_code
WHERE provider_medicare_participation = 'Y'
	AND provider_country = 'US' 
	AND provider_state NOT IN ('XX', 'AA', 'AE', 'AP', 'AS', 'GU', 'MP', 'PR', 'VI' , 'ZZ', 'FM')
	AND pay.hcpcs_code IN ('99202', '99203', '99204', 
		'99205', '99211', '99212', '99213', '99214', '99215', 'G2212', '99417')
GROUP BY pay.hcpcs_code, hcpcs.hcpcs_desc
ORDER BY hcpcs_total_paid DESC
GO
