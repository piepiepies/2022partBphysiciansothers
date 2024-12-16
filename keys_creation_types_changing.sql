-- REMEMBER TO ALWAYS SET THE TYPES BEFORE KEYS, HASSLE TO DO IT AFTERWARDS

-- hcpcps pk change starts
-- updating hcpcs column to not null 
-- changing data types
ALTER TABLE dbo.hcpcs_information
ALTER COLUMN hcpcs_code VARCHAR(50) NOT NULL
GO

ALTER TABLE dbo.hcpcs_information 
ALTER COLUMN hcpcs_drug_indicator CHAR
GO

-- adding the hcpcs primary key constraint, hcpcs_code
IF OBJECT_id('dbo.PK_hcpcs_information','PK') IS NOT NULL
	ALTER TABLE dbo.hcpcs_information
	DROP CONSTRAINT PK_hcpcs_information
GO

ALTER TABLE dbo.hcpcs_information
ADD CONSTRAINT PK_hcpcs_information PRIMARY KEY (hcpcs_code)
GO


-- provider_information pk change starts
-- updating npi column to not null
-- changing data types
ALTER TABLE dbo.provider_information
ALTER COLUMN provider_npi int NOT NULL
GO

ALTER TABLE dbo.provider_information
ALTER COLUMN provider_gender VARCHAR(10)
GO

ALTER TABLE dbo.provider_information
ALTER COLUMN provider_entity_type VARCHAR(10)
GO

ALTER TABLE dbo.provider_information
ALTER COLUMN provider_state VARCHAR(10)
GO

ALTER TABLE dbo.provider_information
ALTER COLUMN provider_ruca FLOAT
GO

ALTER TABLE dbo.provider_information
ALTER COLUMN provider_country VARCHAR(10)
GO

-- adding the provider_information primary key constraint, provider_npi
IF OBJECT_id('dbo.PK_provider_information','PK') IS NOT NULL
	ALTER TABLE dbo.provider_information
	DROP CONSTRAINT PK_provider_information
GO

ALTER TABLE dbo.provider_information
ADD 
	CONSTRAINT PK_provider_information PRIMARY KEY (provider_npi)
GO


-- ruca_information pk change starts
-- deleting the null provider_ruca rows
-- updating npi column to not null
-- changing data types
DELETE FROM dbo.ruca_information
WHERE COALESCE(provider_ruca, provider_ruca_desc) IS NULL
GO

ALTER TABLE dbo.ruca_information
ALTER COLUMN provider_ruca FLOAT NOT NULL
GO

ALTER TABLE dbo.ruca_information
ALTER COLUMN provider_ruca_desc VARCHAR(MAX)
GO

-- adding the provider_information primary key constraint, provider_ruca
IF OBJECT_id('dbo.PK_ruca_information','PK') IS NOT NULL
	ALTER TABLE dbo.ruca_information
	DROP CONSTRAINT PK_ruca_information
GO

ALTER TABLE dbo.ruca_information
ADD CONSTRAINT PK_ruca_information PRIMARY KEY (provider_ruca)
GO

-- adding the foreign key constraint for provider_information (can't do this before designating PK in ruca_information)
-- provider_information ruca (foreign key) references to ruca_information ruca
IF OBJECT_id('dbo.FK_ruca_provider','F') IS NOT NULL
	ALTER TABLE dbo.provider_information
	DROP CONSTRAINT FK_ruca_provider
GO

ALTER TABLE dbo.provider_information
ADD 
	CONSTRAINT FK_ruca_provider FOREIGN KEY (provider_ruca) REFERENCES ruca_information (provider_ruca)
GO


-- payment_information pk change starts
-- updating npi, hcpcs_code, and place of service columns to not null
-- changing data types
ALTER TABLE dbo.payment_information
ALTER COLUMN provider_npi int NOT NULL
GO

ALTER TABLE dbo.payment_information
ALTER COLUMN hcpcs_code VARCHAR(50) NOT NULL
GO

-- wanted to set this as text, but text can't be used as key
ALTER TABLE dbo.payment_information
ALTER COLUMN place_of_service VARCHAR(10) NOT NULL
GO

ALTER TABLE dbo.payment_information
ALTER COLUMN provider_medicare_participation VARCHAR(10)
GO

-- had to do this because there are commas in the numbers and can't change into int because of that
-- changing total_beneficiaries data type
IF (SELECT COUNT(*) special_count FROM dbo.payment_information WHERE total_beneficiaries LIKE '%[^a-Z0-9]%') >= 1
	BEGIN
	UPDATE dbo.payment_information
	SET total_beneficiaries = REPLACE(total_beneficiaries, ',', '')
	WHERE total_beneficiaries IN 
		(SELECT total_beneficiaries 
		 FROM dbo.payment_information
		 WHERE total_beneficiaries LIKE '%[^a-Z0-9]%'
		 GROUP BY total_beneficiaries 
		 HAVING COUNT(*) >= 1)	 
	ALTER TABLE dbo.payment_information
	ALTER COLUMN total_beneficiaries INT
	END
ELSE
	BEGIN
	ALTER TABLE dbo.payment_information
	ALTER COLUMN total_services INT
	END
GO

-- changing total_beneficiaries_per_day_services data type
IF (SELECT COUNT(*) special_count FROM dbo.payment_information WHERE total_beneficiaries_per_day_services LIKE '%[^a-Z0-9]%') >= 1
	BEGIN
	UPDATE dbo.payment_information
	SET total_beneficiaries_per_day_services = REPLACE(total_beneficiaries_per_day_services, ',', '')
	WHERE total_beneficiaries_per_day_services IN 
		(SELECT total_beneficiaries_per_day_services
		 FROM dbo.payment_information
		 WHERE total_beneficiaries_per_day_services LIKE '%[^a-Z0-9]%'
		 GROUP BY total_beneficiaries_per_day_services
		 HAVING COUNT(*) >= 1)	 
	ALTER TABLE dbo.payment_information
	ALTER COLUMN total_beneficiaries_per_day_services INT
	END
ELSE
	BEGIN
	ALTER TABLE dbo.payment_information
	ALTER COLUMN total_beneficiaries_per_day_services INT
	END
GO

-- changing total_services data type
IF (SELECT COUNT(*) special_count FROM dbo.payment_information WHERE total_services LIKE '%[^a-Z0-9]%') >= 1
	BEGIN
	UPDATE dbo.payment_information
	SET total_services = REPLACE(total_services, ',', '')
	WHERE total_services IN 
		(SELECT total_services
		 FROM dbo.payment_information
		 WHERE total_services LIKE '%[^a-Z0-9]%'
		 GROUP BY total_services
		 HAVING COUNT(*) >= 1)	 
	ALTER TABLE dbo.payment_information
	ALTER COLUMN total_services FLOAT
	END
ELSE
	BEGIN
	ALTER TABLE dbo.payment_information
	ALTER COLUMN total_services FLOAT
	END
GO

ALTER TABLE dbo.payment_information
ALTER COLUMN avg_submitted_charge SMALLMONEY
GO

ALTER TABLE dbo.payment_information
ALTER COLUMN avg_medicare_allowed_amt SMALLMONEY
GO

ALTER TABLE dbo.payment_information
ALTER COLUMN avg_medicare_payment_amt SMALLMONEY
GO

ALTER TABLE dbo.payment_information
ALTER COLUMN avg_medicare_standardized_amount SMALLMONEY
GO

-- adding the payment_information primary key constraint, npi hcpcs_code place of service
-- adding the foreign keys constraint for payment_information
-- payment_information provider_npi (foreign key) references to provider_information provider_npi
-- payment_information hcpcs_code (foreign key) references to hcpcs_information hcpcs_code
IF OBJECT_id('dbo.PK_payment_information','PK') IS NOT NULL
	AND OBJECT_id('dbo.FK1_npi_payment','F') IS NOT NULL
	AND OBJECT_id('dbo.FK2_hcpcs_payment','F') IS NOT NULL
		ALTER TABLE dbo.payment_information
		DROP 
			CONSTRAINT PK_payment_information,
			CONSTRAINT FK1_npi_payment,
			CONSTRAINT FK2_hcpcs_payment
GO

ALTER TABLE dbo.payment_information
ADD 
	CONSTRAINT PK_payment_information PRIMARY KEY (provider_npi, hcpcs_code, place_of_service),
	CONSTRAINT FK1_npi_payment FOREIGN KEY (provider_npi) REFERENCES provider_information (provider_npi),
	CONSTRAINT FK2_hcpcs_payment FOREIGN KEY (hcpcs_code) REFERENCES hcpcs_information (hcpcs_code)
GO