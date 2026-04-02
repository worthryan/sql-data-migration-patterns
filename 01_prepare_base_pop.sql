-- get table of antigens minus doses of DIPH, TET, PORT, POL associated with 4IN1s coded as primaries
SELECT ba.*, AntigenCodeNorm = CAST( REPLACE(REPLACE(AntigenCode,'MENW','ACWY'),'CPOX','VAR') AS varchar(10))
INTO ##Ants
FROM [CHIS_DW].[dbo].[tbl_Immunisations_ByAntigen] ba
LEFT JOIN  [CHIS_DW].[dbo].[tbl_Immunisations_ByVaccine] bv
ON ba.nhsnumber = bv.nhsnumber
	AND ba.DateOfImmunisation = bv.DateOfImmunisation
		AND bv.VaccineCode = '4IN1'
			AND bv.VaccinePart =  ba.AntigenDose
				AND ba.AntigenCode IN ('DIPH','TET','PERT','POL')
					AND ba.AntigenDose like '%P'
WHERE bv.NHSNumber IS NULL 	

CREATE CLUSTERED INDEX CX_Ants_NHS_Date
ON ##Ants (NHSNumber, DateOfImmunisation);

CREATE NONCLUSTERED INDEX IX_Ants_NHS_AntigenNorm_Date
ON ##Ants (NHSNumber, AntigenCodeNorm, DateOfImmunisation);

  SELECT	 pds.[NHS_Number] as [NHSNumber]
			,pds.[Date_Of_Birth] as [DOB]
			,ar.Ref as [AntigenRef]
			,ar.ChildRef as [AntigenChildRef]
			,ar.VaccineName
			,ar.VaccineGroup
			,ar.Shortname
			,ar.Dose
			,ar.DoseOrder
			,ar.[AgeCountedFromValue]
			,ar.[AgeCountedFromUnit]
			,ar.[AgeCountedToValue]
			,ar.[AgeCountedToUnit]
			,ar.[AgeMissingFromUnit]
			,ar.[AgeMissingFromValue]
			,ar.[AgeMissingToUnit]
			,ar.[AgeMissingtoValue]
			
			,[analysts].[dbo].[ConvertDate](pds.[Date_Of_Birth],ar.[AgeCountedFromValue],ar.AgeCountedFromUnit) AS WindowStartDate
		,[analysts].[dbo].[ConvertDate](pds.[Date_Of_Birth],ar.[AgeCountedtoValue], ar.[AgeCountedToUnit]) AS WindowEndDate
		,pds.va_date
	INTO ##TempPop
  FROM [Population].[dbo].[tbl_SCW_PDS_live] pds
  -- Join to return what Antigens the child is due 
    LEFT JOIN REFERENCE.[dbo].[tbl_ref_AntigenRules_AntigensONLY] ar 
  -- Does today fall between the timeframes for when the Antigen is due to be given to the child?
		ON GETDATE() > [analysts].[dbo].[ConvertDate](pds.[Date_Of_Birth],ar.[AgeMissingFromValue],ar.AgeMissingFromUnit) 
		AND pds.[Date_Of_Birth] BETWEEN [DateValidFrom] AND COALESCE([DateValidTo],GETDATE()) 	
  WHERE pds.Date_of_Birth <= DATEADD(MONTH,-3,GETDATE())

  GROUP BY	 pds.[NHS_Number] 
			,pds.[Date_Of_Birth] 
			,ar.ChildRef
			,ar.VaccineName
			,ar.VaccineGroup
			,ar.Ref 
			,ar.Shortname
			,ar.Dose			
			,ar.DoseOrder
			,ar.[AgeCountedFromValue]
			,ar.[AgeCountedFromUnit]
			,ar.[AgeCountedToValue]
			,ar.[AgeCountedToUnit]
			,pds.va_date
			,ar.[AgeMissingFromUnit]
			,ar.[AgeMissingFromValue]
			,ar.[AgeMissingToUnit]
			,ar.[AgeMissingtoValue]
			,[analysts].[dbo].[ConvertDate](pds.[Date_Of_Birth],ar.[AgeCountedFromValue],ar.AgeCountedFromUnit)
			,[analysts].[dbo].[ConvertDate](pds.[Date_Of_Birth],ar.[AgeCountedtoValue], ar.[AgeCountedToUnit])

-- Helpful lookup index for joins back to rules by VaccineName/VaccineGroup
CREATE NONCLUSTERED INDEX IX_TempPop_NHS_VaccineName
ON ##TempPop (NHSNumber, VaccineName)
INCLUDE (VaccineGroup, ShortName, DOB, WindowStartDate, WindowEndDate);

--------------------------------------
--Now the table
-------------------------------------

SELECT   pop.NHSNumber
        ,pop.DOB
        ,pop.AntigenRef
        ,pop.[AntigenChildRef]
        ,pop.ShortName as [AntigenName]
        ,pop.VaccineName
        ,pop.VaccineGroup
        ,pop.Dose as [DosesRequired]
        ,COALESCE(COUNT(a.NHSNumber),0) as [ValidDosesGiven]
        ,pop.va_date
INTO ##AntigensMet
FROM ##TempPop pop
LEFT JOIN ##Ants a
    ON  a.NHSNumber = pop.NHSNumber
    AND a.AntigenCodeNorm = pop.ShortName
    AND a.DateOfImmunisation >= pop.WindowStartDate
    AND a.DateOfImmunisation <= pop.WindowEndDate
GROUP BY  pop.NHSNumber
        ,pop.DOB
        ,pop.AntigenRef
        ,pop.[AntigenChildRef]
        ,pop.ShortName
        ,pop.VaccineName
        ,pop.VaccineGroup
        ,pop.Dose
        ,pop.va_date

-- Used by takeover/aggregation updates
IF EXISTS (SELECT 1 FROM tempdb.sys.indexes WHERE object_id = OBJECT_ID('tempdb..##AntigensMet') AND name = 'IX_AntigensMet_NHS_Antigen')
    DROP INDEX IX_AntigensMet_NHS_Antigen ON ##AntigensMet;

CREATE NONCLUSTERED INDEX IX_AntigensMet_NHS_Antigen
ON ##AntigensMet (NHSNumber, AntigenName)
INCLUDE (ValidDosesGiven, DosesRequired, VaccineName, VaccineGroup);

---------------------------------------------------------------------------------------------------
--This little tweek is required to differentiate when one antigen takes precendence over the other
--used in the case statement in the following table
-------------------------------------------------------
SELECT Parent.ShortName
	INTO ##TakeOverVaccines
  FROM [Reference].[dbo].[tbl_ref_AntigenRules_AntigensONLY] Parent
	INNER JOIN [Reference].[dbo].[tbl_ref_AntigenRules_AntigensONLY] Child
		ON Parent.ChildRef = Child.Ref
		AND Parent.AgeCountedFromValue = Child.AgeCountedToValue
		AND Parent.AgeCountedFromUnit = Child.AgeCountedToUnit;