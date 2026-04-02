-- Now Pivot on VaccineCode 
DECLARE @VaccineCodes AS NVARCHAR(MAX)
DECLARE @PivotMet AS NVARCHAR(MAX)
DECLARE @PivotDosesGiven AS NVARCHAR(MAX)
DECLARE @PivotDosesRequired AS NVARCHAR(MAX);

--Get list of distinct VaccineCodes to pivot on  
WITH CTE AS(SELECT DISTINCT VaccineName
FROM [Reference].[dbo].[tbl_ref_AntigenRules_AntigensONLY])
SELECT @VaccineCodes=  ISNULL(@VaccineCodes + ', ','') +'['+VaccineName+']'
FROM  CTE 


 -- Define the strings to be used in the dynamic pivots
SET @PivotMet = 
N'WITH CTE AS(SELECT NHSNumber, VaccineName, CASE WHEN StillNeeded = 1 THEN MinMetFlag WHEN StillNeeded = 0 AND MinMetFlag = 1 THEN 1 ELSE 2 END AS MetFlagAdjusted
			FROM  ##VaccinesMet_2)(SELECT NHSNumber , ' + @VaccineCodes + '
		INTO [CHIS_DW].[dbo].[tbl_V&I_VaccinesMet]
    FROM CTE
    PIVOT(MAX(MetFlagAdjusted)
          FOR [VaccineName]  IN (' + @VaccineCodes + ')) AS pvt)'

SET @PivotDosesGiven = 
  N'SELECT NHSNumber , ' + @VaccineCodes + '
	INTO [CHIS_DW].[dbo].[tbl_V&I_DosesGiven]
    FROM ##DosesGiven
    PIVOT(MAX(ValidDosesGiven)
          FOR [VaccineName] IN (' + @VaccineCodes + ')) AS pvt '
		  
SET @PivotDosesRequired = 
  N'SELECT NHSNumber , ' + @VaccineCodes + '
	INTO [CHIS_DW].[dbo].[tbl_V&I_DosesRequired]
    FROM ##DosesRequired
    PIVOT(MAX(DosesRequired)
          FOR [VaccineName] IN (' + @VaccineCodes + ')) AS pvt '
  		  
EXEC (@PivotMet)
EXEC (@PivotDosesGiven)
EXEC  (@PivotDosesRequired)

	CREATE CLUSTERED INDEX [NHS_Idx] ON CHIS_DW.[dbo].[tbl_V&I_DosesGiven] ([NHSNumber] ASC)					
	CREATE CLUSTERED INDEX [NHS_Idx] ON CHIS_DW.[dbo].[tbl_V&I_DosesRequired] ([NHSNumber] ASC)
	CREATE CLUSTERED INDEX [NHS_Idx] ON CHIS_DW.[dbo].[tbl_V&I_VaccinesMet] ([NHSNumber] ASC)

IF EXISTS (SELECT * FROM [CHIS_DW].sys.objects WHERE name LIKE 'tbl_V&I_reporting_MASTER_v2' AND type in (N'U')) DROP TABLE [CHIS_DW].[dbo].[tbl_V&I_reporting_MASTER_v2]

--Create the MASTER Table that produces the reporting using dynamic SQL
DECLARE @VaccineCodes2 AS NVARCHAR(MAX)
		,@SQL AS NVARCHAR(MAX) ;

WITH CTE AS(SELECT DISTINCT CONCAT('[',VaccineName,']')VaccineName
FROM [Reference].[dbo].[tbl_ref_AntigenRules_AntigensONLY])

SELECT @VaccineCodes2=  ISNULL(@VaccineCodes2 + ', ','') +'CONVERT(NVARCHAR(25),(CONCAT (DG.'+VaccineName+',''.'',VM.'+VaccineName+'))) AS '+VaccineName
FROM  CTE  

SELECT @SQL =

 '		SELECT IDENTITY(int, 1,1) AS ID
		, DG.NHSNumber
		, CAST (NULL AS VARCHAR(500)) AS LocalIDcode
		, CAST(NULL AS VARCHAR(500)) AS Forename
		, CAST(NULL AS VARCHAR(500)) AS Surname
		, CAST(NULL AS VARCHAR(500)) AS Gender
		, CAST(NULL AS DATE) AS DateOfBirth
		, CAST(NULL AS VARCHAR(500)) AS CurrentCover
		, CAST(NULL AS VARCHAR(500)) AS NextQuarterCover
		, CAST(NULL AS VARCHAR(500)) AS PostCode
		, CAST(NULL AS VARCHAR(500)) AS WardCode
		, CAST(NULL AS VARCHAR(500)) AS WardName
		, CAST(NULL AS VARCHAR(8000)) AS ContactNumbers
		, CAST(NULL AS VARCHAR(500)) AS LSOA
		, CAST(NULL AS VARCHAR(500)) AS IMDdecile
	    , CAST(NULL AS VARCHAR(500)) AS PracticeCode
		, CAST(NULL AS VARCHAR(500)) AS PracticeName
		, CAST(NULL AS VARCHAR(500)) AS SCWregistered
		, CAST(NULL AS VARCHAR(500)) AS SCWregisteredLocality
		, CAST(NULL AS VARCHAR(500)) AS CCGcode
		, CAST(NULL AS VARCHAR(500)) AS CCGname
		, CAST(NULL AS VARCHAR(500)) AS PCNcode
		, CAST(NULL AS VARCHAR(500)) AS PCNname
		, CAST(NULL AS VARCHAR(500)) AS LAcode
		, CAST(NULL AS VARCHAR(500)) AS LAname
		, CAST(NULL AS VARCHAR(500)) AS SCWresident
		, CAST(NULL AS VARCHAR(500)) AS SCWresidentLocality
		, CAST(NULL AS VARCHAR(500)) AS SchoolCode
		, CAST(NULL AS VARCHAR(500)) AS SchoolName
        , CAST(NULL AS INT) AS SCWschool
        , CAST(NULL AS VARCHAR(500)) AS SCWschoolLocality
		, CAST(NULL AS VARCHAR(500)) AS UpToDate
		, CAST(NULL AS VARCHAR(500)) AS UpToDatePrimary
		, CAST(NULL AS VARCHAR(500)) AS UpToDate12Month
		, CAST(NULL AS VARCHAR(500)) AS UpToDate18Month
		, CAST(NULL AS VARCHAR(500)) AS UpToDatePreSchool
		, CAST(NULL AS VARCHAR(500)) AS UpToDateSchool
		, CAST(NULL AS INT) AS AgeInMonths
		, CAST(NULL AS INT) AS AgeInYears
		, CAST(NULL AS VARCHAR(500)) AS FullAge
		, CAST(NULL AS VARCHAR(500)) AS AgeGroup
		, CAST(NULL AS VARCHAR(500)) AS EthnicCode
		, CAST(NULL AS VARCHAR(500)) AS EthnicDescription
		, ' + @VaccineCodes2 + '

		, CAST(NULL AS NVARCHAR(12)) AS [MMR(V)-1] 
		, CAST(NULL AS NVARCHAR(12)) AS [MMR(V)-2] 

		, CAST(NULL AS VARCHAR(MAX)) AS OutstandingImms
		, CAST(NULL AS VARCHAR(MAX)) AS NegativeConsent
		, CAST(NULL AS VARCHAR(MAX)) AS ImmsHistory
		, CAST(NULL AS VARCHAR(MAX)) AS Suspended
		, CAST(NULL AS INT) AS OnPreviousReportFlag
		, CAST(NULL AS VARCHAR(MAX)) AS [DNA(s)SinceImmunised]	

		, CAST(NULL AS VARCHAR(500)) AS Forename_CHIS
		, CAST(NULL AS VARCHAR(500)) AS Surname_CHIS
		, CAST(NULL AS VARCHAR(500)) AS Gender_CHIS
		, CAST(NULL AS DATE) AS DateOfBirth_CHIS

	    , CAST(NULL AS VARCHAR(500)) AS PracticeCode_CHIS
		, CAST(NULL AS VARCHAR(500)) AS PracticeName_CHIS
		, CAST(NULL AS VARCHAR(500)) AS SCWregistered_CHIS
		, CAST(NULL AS VARCHAR(500)) AS SCWregisteredLocality_CHIS

		, CAST(NULL AS VARCHAR(500)) AS CCGcode_CHIS
		, CAST(NULL AS VARCHAR(500)) AS CCGname_CHIS
		, CAST(NULL AS VARCHAR(500)) AS PCNcode_CHIS
		, CAST(NULL AS VARCHAR(500)) AS PCNname_CHIS

		, CAST(NULL AS VARCHAR(500)) AS PostCode_CHIS
		, CAST(NULL AS VARCHAR(500)) AS WardCode_CHIS
		, CAST(NULL AS VARCHAR(500)) AS WardName_CHIS
		, CAST(NULL AS VARCHAR(500)) AS LSOA_CHIS
		, CAST(NULL AS VARCHAR(500)) AS IMDdecile_CHIS

		, CAST(NULL AS VARCHAR(500)) AS LAcode_CHIS
		, CAST(NULL AS VARCHAR(500)) AS LAname_CHIS
		, CAST(NULL AS VARCHAR(500)) AS SCWresident_CHIS
		, CAST(NULL AS VARCHAR(500)) AS SCWresidentLocality_CHIS
		, CAST(NULL AS DATE) AS va_date

INTO [CHIS_DW].[dbo].[tbl_V&I_reporting_MASTER_v2]  
FROM [CHIS_DW].[dbo].[tbl_V&I_DosesGiven] AS DG LEFT JOIN [CHIS_DW].[dbo].[tbl_V&I_VaccinesMet] AS VM ON DG.NHSNumber = VM.NHSNumber'
EXEC (@SQL)

	CREATE CLUSTERED INDEX [Id_Idx] ON CHIS_DW.[dbo].[tbl_V&I_reporting_MASTER_v2] ([ID] ASC)
	CREATE INDEX [AgeYears_Idx] ON CHIS_DW.[dbo].[tbl_V&I_reporting_MASTER_v2] ([AgeInYears] ASC)
	CREATE INDEX [AgeMonths_Idx] ON CHIS_DW.[dbo].[tbl_V&I_reporting_MASTER_v2] ([AgeInMonths] ASC)
	CREATE INDEX [NHS_Idx] ON CHIS_DW.[dbo].[tbl_V&I_reporting_MASTER_v2] ([NHSNUMBER] ASC)


DECLARE	 @VaccineCodesSQL NVARCHAR(MAX);

WITH CTE AS(SELECT DISTINCT CONCAT('[',VaccineName,']') AS [VaccineName]
FROM [Reference].[dbo].[tbl_ref_AntigenRules_AntigensONLY])

SELECT @VaccineCodesSQL=  ISNULL(@VaccineCodesSQL + ' ','') + 'UPDATE [CHIS_DW].[dbo].[tbl_V&I_reporting_MASTER_v2]
  SET '+ [VaccineName] +'= NULL WHERE '+[VaccineName]+'= ''.''' 
FROM  CTE   
EXEC (@VaccineCodesSQL)

--Update demographics on the master table
UPDATE [CHIS_DW].[dbo].[tbl_V&I_reporting_MASTER_v2]	
SET      LocalIDcode = dd.LocalIDcode
		,Forename = pd.forename
		,Surname = pd.Surname
		,Gender = pd.Gender
		,DateOfBirth = pd.Date_Of_Birth
		,Postcode = pd.Postcode
		,WardCode = ons.WardCode
		,WardName = ons.WardName
		,ContactNumbers = dd.ContactNumbers
		,LSOA = ons.LSOA11
		,PracticeCode = pd.[GP_Code]
		,PracticeName = scw_gp.PracticeName
		,SCWRegistered = CASE WHEN scw_gp.Practicecode IS NOT NULL THEN 1 ELSE 0 END 
		,SCWregisteredLocality = CASE WHEN scw_gp.Practicecode IS NOT NULL THEN REPLACE(REPLACE(scw_gp.[CHIShub],'East','TV'),'West','BGSW') ELSE NULL END 
		,CCGcode = pd.Responsible_CCG_Code
		,CCGname = scw_gp.CCGdescription
		,PCNcode = scw_gp.PCNcode
		,PCNname = scw_gp.PCNname
		,LAcode =  pd.LA_Code
		,LAname =  COALESCE(scw_la.[LA Description],'Out of Area LA')
		,SCWResident = CASE WHEN scw_la.[LA Code] IS NOT NULL THEN 1 ELSE 0 END 
		,SCWResidentLocality = CASE WHEN scw_la.[LA Code] IS NOT NULL THEN REPLACE(REPLACE(scw_la.[CHIS Hub],'East','TV'),'West','BGSW') ELSE NULL END 
		,SchoolCode = dd.CurrentSchoolCode
		,SchoolName = dd.CurrentSchoolName
		,SCWSchool = dd.SCWSchool
		,SCWSchoolLocality = scw_sch.[CHIS_Contract]
		,AgeinMonths = DATEDIFF(M, pd.Date_Of_Birth, GETDATE()) - CASE WHEN DAY(pd.Date_Of_Birth) > DAY(GETDATE()) THEN 1 ELSE 0 END
		,AgeInYears = Analysts.[dbo].[AgeInYears](PD.Date_Of_Birth)
		,FullAge = [analysts].[dbo].[CalculateFullAge](pd.Date_Of_Birth)
		,AgeGroup = CASE WHEN COALESCE(Analysts.[dbo].[AgeInYears](PD.Date_Of_Birth),CAST(dd.AgeInYears as int)) < 6 THEN '0-5' 
								WHEN COALESCE(Analysts.[dbo].[AgeInYears](PD.Date_Of_Birth),CAST(dd.AgeInYears as int)) >= 6 AND COALESCE(Analysts.[dbo].[AgeInYears](PD.Date_Of_Birth),CAST(dd.AgeInYears as int)) < 19 THEN '6-19' 
									ELSE '19+' 
									END
		,EthnicCode = dd.EthnicCode
		,EthnicDescription = dd.EthnicDescription
		,va_date = dd.va_date
		,CurrentCover = CASE WHEN [12MonthCohort] = ([analysts].[dbo].[GetFinYear] (GETDATE(),0) + '- Q' + CAST([analysts].[dbo].[GetFinQuarter] (GETDATE()) AS VARCHAR) ) THEN '12MonthCohort' 
								WHEN [24MonthCohort] = ([analysts].[dbo].[GetFinYear] (GETDATE(),0) + '- Q' + CAST([analysts].[dbo].[GetFinQuarter] (GETDATE()) AS VARCHAR) ) THEN '24MonthCohort' 
	  								WHEN [5YearCohort] = ([analysts].[dbo].[GetFinYear] (GETDATE(),0) + '- Q' + CAST([analysts].[dbo].[GetFinQuarter] (GETDATE()) AS VARCHAR) ) THEN '5YearCohort' 
										ELSE NULL 
						END 
		,NextQuarterCover = CASE WHEN [12MonthCohort] = [analysts].dbo.GetNextFinYearQuarter() THEN '12MonthCohort' 
									WHEN [24MonthCohort] = [analysts].dbo.GetNextFinYearQuarter() THEN '24MonthCohort' 
	  									WHEN [5YearCohort] = [analysts].dbo.GetNextFinYearQuarter() THEN '5YearCohort' 
											ELSE NULL
						END
		,[IMDdecile] = IMD.IMD_Decile  


		,Forename_CHIS = dd.Forename
		,Surname_CHIS = dd.Surname
		,DateOfBirth_CHIS = dd.DOB
		,Gender_CHIS = dd.Sex
	    ,PracticeCode_CHIS = dd.PracticeCode
		,PracticeName_CHIS = dd.PracticeName
		,SCWregistered_CHIS = CASE WHEN scw_gp_cp.Practicecode IS NOT NULL THEN 1 ELSE 0 END 
		,SCWregisteredLocality_CHIS = CASE WHEN scw_gp_cp.Practicecode IS NOT NULL THEN REPLACE(REPLACE(scw_gp_cp.[CHIShub],'East','TV'),'West','BGSW') ELSE NULL END 

		,CCGcode_CHIS = dd.ResponsibleCCGcode
		,CCGname_CHIS = COALESCE(scw_gp_cp.CCGdescription,'Out of Area CCG')
		,PCNcode_CHIS = scw_gp_cp.PCNcode
		,PCNname_CHIS = scw_gp_cp.PCNname

        ,PostCode_CHIS = dd.Postcode	
		,WardCode_CHIS = ons_cp.WardCode
		,WardName_CHIS = ons_cp.WardName
		,LSOA_CHIS = ons_cp.LSOA11
		,LAcode_CHIS = dd.ResidentLAcode
		,IMDdecile_CHIS = IMD_cp.IMD_Decile 
		,LAname_CHIS = COALESCE(scw_la_cp.[LA Description],'Out of Area LA')
		,SCWresident_CHIS = CASE WHEN scw_la_cp.[LA Code] IS NOT NULL THEN 1 ELSE 0 END 
		,SCWresidentLocality_CHIS = CASE WHEN scw_la_cp.[LA Code] IS NOT NULL THEN REPLACE(REPLACE(scw_la_cp.[CHIS Hub],'East','TV'),'West','BGSW') ELSE NULL END 

FROM [CHIS_DW].[dbo].[tbl_V&I_reporting_MASTER_v2] vm

LEFT JOIN [CHIS_DW].[dbo].[tbl_Demographic_Details] dd
	ON vm.NHSNumber = dd.NHSNumber 

LEFT JOIN [Population].[dbo].[tbl_SCW_PDS_live] pd
	ON pd.[NHS_Number] = vm.NHSNumber

LEFT JOIN [Reference].[dbo].[tbl_ref_SCW_GP] scw_gp
	ON scw_gp.PracticeCode = pd.GP_Code

LEFT JOIN [Reference].[dbo].[tbl_ref_SCW_GP] scw_gp_cp
	ON scw_gp_cp.PracticeCode = dd.PracticeCode

LEFT JOIN [Reference].[dbo].[tbl_ref_SCW_LA] scw_la_cp
	ON scw_la_cp.[LA Code] = dd.ResidentLAcode

LEFT JOIN [Reference].[dbo].[tbl_ref_SCW_LA] scw_la
	ON scw_la.[LA Code] = pd.LA_Code

LEFT JOIN [Reference].[dbo].[tbl_ref_ONS_Postcodes] ons -- PDS JOIN 
	ON ons.Postcode = pd.Postcode

LEFT JOIN [Reference]. [dbo].[Indices_of_Multiple_Deprivation_(IMD)_2019] IMD
	ON ons.LSOA11  = IMD.lsoa11cd
	
LEFT JOIN [Reference].[dbo].[tbl_ref_ONS_Postcodes] ons_cp -- CAREPLUS JOIN 
	ON ons_cp.Postcode = dd.Postcode

LEFT JOIN [Reference]. [dbo].[Indices_of_Multiple_Deprivation_(IMD)_2019] IMD_cp
	ON ons_cp.LSOA11  = IMD_cp.lsoa11cd

LEFT JOIN [Reference].[dbo].[tbl_ref_SCW_Schools] scw_sch
	ON scw_sch.[DFEcode] = dd.CurrentSchoolCode
	
UPDATE [CHIS_DW].[DBO].[TBL_V&I_REPORTING_MASTER_V2]	
SET CCGNAME = CG.CCGNAME_REVISED
FROM [CHIS_DW].[DBO].[TBL_V&I_REPORTING_MASTER_V2] RM
LEFT JOIN (
SELECT	[NHSNUMBER]
	  ,	PRACTICECODE
	  ,	PRACTICENAME     
      ,	[CCGCODE]
      ,	[CCGNAME]
	  ,	CG.[CCG CODE]
	  ,	CG.[CCG DESCRIPTION]
	  ,	COALESCE(CG.[CCG DESCRIPTION],'Out of Area CCG') AS CCGNAME_REVISED     
FROM [CHIS_DW].[DBO].[TBL_V&I_REPORTING_MASTER_V2] VR
LEFT JOIN [REFERENCE].[DBO].[TBL_REF_SCW_CCG] CG
ON CG.[CCG CODE] = VR.CCGCODE
WHERE CCGCODE IS NOT NULL AND CCGNAME IS NULL
) CG ON CG.NHSNUMBER = RM.NHSNUMBER 
WHERE CG.NHSNUMBER IS NOT NULL
	
	CREATE INDEX [PracticeCode_Idx] ON CHIS_DW.[dbo].[tbl_V&I_reporting_MASTER_v2] ([PracticeCode] ASC)
	CREATE INDEX [CCGcode_Idx] ON CHIS_DW.[dbo].[tbl_V&I_reporting_MASTER_v2] ([CCGcode] ASC)
	CREATE INDEX [LAcode_Idx] ON CHIS_DW.[dbo].[tbl_V&I_reporting_MASTER_v2] ([LAcode] ASC)

-- Update MMR(V) combined cols 
--If one side is NULL, return the other side
--left digit = sum of the two left digits
--right digit = MIN of the two right digits

UPDATE [CHIS_DW].[dbo].[tbl_V&I_reporting_MASTER_v2]	
SET
    [MMR(V)-1] =
        CASE
            WHEN [MMR-1]  IS NULL AND [MMRV-1] IS NULL THEN NULL
            WHEN [MMR-1]  IS NULL THEN [MMRV-1]
            WHEN [MMRV-1] IS NULL THEN [MMR-1]
            ELSE
                CAST( TRY_CONVERT(int, LEFT([MMR-1],  CHARINDEX('.', [MMR-1]  + '.') - 1))
                    + TRY_CONVERT(int, LEFT([MMRV-1], CHARINDEX('.', [MMRV-1] + '.') - 1))
                    AS varchar(10)
                )
                + '.'
                + CAST(
                    CASE
                        WHEN TRY_CONVERT(int, RIGHT([MMR-1],  1)) < TRY_CONVERT(int, RIGHT([MMRV-1], 1))
                            THEN TRY_CONVERT(int, RIGHT([MMR-1],  1))
                        ELSE TRY_CONVERT(int, RIGHT([MMRV-1], 1))
                    END
                    AS varchar(10)
                )
        END,
    [MMR(V)-2] =
        CASE
            WHEN [MMR-2]  IS NULL AND [MMRV-2] IS NULL THEN NULL
            WHEN [MMR-2]  IS NULL THEN [MMRV-2]
            WHEN [MMRV-2] IS NULL THEN [MMR-2]
            ELSE
                CAST( TRY_CONVERT(int, LEFT([MMR-2],  CHARINDEX('.', [MMR-2]  + '.') - 1))
                    + TRY_CONVERT(int, LEFT([MMRV-2], CHARINDEX('.', [MMRV-2] + '.') - 1))
                    AS varchar(10)
                )
                + '.'
                + CAST(
                    CASE
                        WHEN TRY_CONVERT(int, RIGHT([MMR-2],  1)) < TRY_CONVERT(int, RIGHT([MMRV-2], 1))
                            THEN TRY_CONVERT(int, RIGHT([MMR-2],  1))
                        ELSE TRY_CONVERT(int, RIGHT([MMRV-2], 1))
                    END
                    AS varchar(10)
                )
        END
---------------------------------------------------
-- Manual update to ensure that it is not flagging incomplete for boys not in year 8 or below in 2019/20 school year 
----------------------------------------------------
UPDATE ##VaccinesMet_2
SET StillNeeded = 0
WHERE VaccineName = 'HPV'
	AND NHSNumber IN (SELECT NHSNumber FROM [CHIS_DW].[dbo].[tbl_V&I_reporting_MASTER_v2] WHERE[Gender] = 'M'AND [DateOfBirth] < '2006-09-01' )

UPDATE [CHIS_DW].[dbo].[tbl_V&I_reporting_MASTER_v2]
SET  [HPV] = HPV.[HPV PROXY]
FROM [CHIS_DW].[dbo].[tbl_V&I_reporting_MASTER_v2] RM
INNER JOIN 
(  SELECT 
	  NHSNUMBER
	, [DATEOFBIRTH]
	, [HPV]
	, CASE WHEN LEFT([HPV],1) = '0' THEN NULL ELSE LEFT([HPV],1) + '.4' END AS [HPV PROXY] -- .4 used for doses with no formatting 
	, [AGEINYEARS]
	, [AGEINMONTHS]
	FROM [CHIS_DW].[dbo].[tbl_V&I_reporting_MASTER_v2]
	WHERE [DATEOFBIRTH] < '2006-09-01' 
	AND [GENDER] = 'M'
	AND [HPV]  IS NOT NULL
) HPV ON HPV.NHSNUMBER = RM.NHSNUMBER 