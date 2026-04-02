--Update the Updatestatus on each of the records
UPDATE [CHIS_DW].[dbo].[tbl_V&I_reporting_MASTER_v2]	
SET UpToDate = 'No Record'
WHERE NHSNumber NOT IN (SELECT NHSNumber FROM [CHIS_DW].[dbo].[tbl_Immunisations_ByAntigen]) 
	
UPDATE [CHIS_DW].[dbo].[tbl_V&I_reporting_MASTER_v2]	
SET UpToDate = 'No'
FROM [CHIS_DW].[dbo].[tbl_V&I_reporting_MASTER_v2] rm	
WHERE UpToDate  IS NULL
	AND NHSNumber IN (SELECT NHSNumber FROM ##VaccinesMet_2 WHERE MinMetFlag = 0 AND  StillNeeded = 1)

UPDATE [CHIS_DW].[dbo].[tbl_V&I_reporting_MASTER_v2]	
SET UpToDate = 'Yes'
FROM [CHIS_DW].[dbo].[tbl_V&I_reporting_MASTER_v2] rm	
WHERE UpToDate IS NULL
	AND NHSNumber NOT IN (SELECT NHSNumber FROM ##VaccinesMet_2 WHERE MinMetFlag = 0 AND  StillNeeded = 1)

----------------------------------------------
--Primary Flag
--------------------------------------------------
UPDATE [CHIS_DW].[dbo].[tbl_V&I_reporting_MASTER_v2]	
SET UptoDatePrimary = 'No'
WHERE NHSNumber IN (SELECT NHSNumber
					FROM ##VaccinesMet_2 
					WHERE MinMetFlag = 0 AND  StillNeeded = 1 AND VaccineGroup = 'Primary')

UPDATE [CHIS_DW].[dbo].[tbl_V&I_reporting_MASTER_v2]	
SET UptoDatePrimary = 'Yes'
WHERE NHSNumber  NOT IN (SELECT NHSNumber
					FROM ##VaccinesMet_2 
					WHERE MinMetFlag = 0 AND  StillNeeded = 1 AND VaccineGroup = 'Primary')
	  AND NHSNumber IN (SELECT NHSNumber FROM ##VaccinesMet_2 WHERE VaccineGroup = 'Primary')

UPDATE [CHIS_DW].[dbo].[tbl_V&I_reporting_MASTER_v2]	
SET UptoDatePrimary = UptoDate
WHERE UpToDate = 'No Record'
----------------------------------------------
--Booster Flag (12 Month)
--------------------------------------------------

UPDATE [CHIS_DW].[dbo].[tbl_V&I_reporting_MASTER_v2]	--- CHANGE
SET UptoDate12Month = 'No'
WHERE NHSNumber IN (SELECT NHSNumber
					FROM ##VaccinesMet_2 
					WHERE MinMetFlag = 0 AND  StillNeeded = 1 AND VaccineGroup = '12 Month')

UPDATE [CHIS_DW].[dbo].[tbl_V&I_reporting_MASTER_v2]	
SET UptoDate12Month = 'Yes'
WHERE NHSNumber NOT IN (SELECT NHSNumber
					FROM ##VaccinesMet_2 
					WHERE MinMetFlag = 0 AND  StillNeeded = 1 AND VaccineGroup = '12 Month')
		AND NHSNumber IN (SELECT NHSNumber FROM ##VaccinesMet_2 WHERE VaccineGroup = '12 Month')

UPDATE [CHIS_DW].[dbo].[tbl_V&I_reporting_MASTER_v2]	
SET UptoDate12Month = UptoDate
WHERE UpToDate = 'No Record'
	AND ([AgeInMonths] >=14 OR UptoDate12Month IS NOT NULL)


----------------------------------------------  
--Booster Flag (18 Month)
--------------------------------------------------

UPDATE [CHIS_DW].[dbo].[tbl_V&I_reporting_MASTER_v2]	--- CHANGE
SET UptoDate18Month = 'No'
WHERE NHSNumber IN (SELECT NHSNumber
					FROM ##VaccinesMet_2 
					WHERE MinMetFlag = 0 AND  StillNeeded = 1 AND VaccineGroup = '18 Month')

UPDATE [CHIS_DW].[dbo].[tbl_V&I_reporting_MASTER_v2]	
SET UptoDate18Month = 'Yes'
WHERE NHSNumber NOT IN (SELECT NHSNumber
					FROM ##VaccinesMet_2 
					WHERE MinMetFlag = 0 AND  StillNeeded = 1 AND VaccineGroup = '18 Month')
		AND NHSNumber IN (SELECT NHSNumber FROM ##VaccinesMet_2 WHERE VaccineGroup = '18 Month')

UPDATE [CHIS_DW].[dbo].[tbl_V&I_reporting_MASTER_v2]	
SET UptoDate18Month = UptoDate
WHERE UpToDate = 'No Record'
	AND ([AgeInMonths] >=19 OR UptoDate18Month IS NOT NULL)
		AND CAST(GETDATE() AS DATE) > '31 DEC 2025'  --- CHANGE
			AND DateOfBirth >= '01 SEP 2022'
				AND ([6IN1-18Month] IS NOT NULL OR [MMRV-2] IS NOT NULL)

----------------------------------------------
--Preschool Flag
--------------------------------------------------

UPDATE [CHIS_DW].[dbo].[tbl_V&I_reporting_MASTER_v2]	
SET UptoDatePreSchool = 'No'
WHERE NHSNumber IN (SELECT NHSNumber
					FROM ##VaccinesMet_2 
					WHERE MinMetFlag = 0 AND  StillNeeded = 1 AND VaccineGroup = 'Preschool')

UPDATE [CHIS_DW].[dbo].[tbl_V&I_reporting_MASTER_v2]	
SET UptoDatePreSchool = 'Yes'
WHERE NHSNumber NOT IN  (SELECT NHSNumber
					FROM ##VaccinesMet_2 
					WHERE MinMetFlag = 0 AND  StillNeeded = 1 AND VaccineGroup = 'Preschool')
		AND NHSNumber IN (SELECT NHSNumber FROM ##VaccinesMet_2 WHERE VaccineGroup = 'Preschool')

UPDATE [CHIS_DW].[dbo].[tbl_V&I_reporting_MASTER_v2]	
SET UptoDatePreSchool = UptoDate
WHERE UpToDate = 'No Record'
AND ([AgeInMonths] >= 42 OR UptoDatePreSchool IS NOT NULL)
----------------------------------------------
--School Flag
--------------------------------------------------
UPDATE [CHIS_DW].[dbo].[tbl_V&I_reporting_MASTER_v2]	
SET UptoDateSchool =  'No'
WHERE NHSNumber IN (SELECT NHSNumber
					FROM ##VaccinesMet_2 
					WHERE MinMetFlag = 0 AND  StillNeeded = 1 AND VaccineGroup = 'School')

UPDATE [CHIS_DW].[dbo].[tbl_V&I_reporting_MASTER_v2]	
SET UptoDateSchool = 'Yes'
WHERE NHSNumber NOT IN  (SELECT NHSNumber
					FROM ##VaccinesMet_2 
					WHERE MinMetFlag = 0 AND  StillNeeded = 1 AND VaccineGroup = 'School')
		AND NHSNumber IN (SELECT NHSNumber FROM ##VaccinesMet_2 WHERE VaccineGroup = 'school')

UPDATE [CHIS_DW].[dbo].[tbl_V&I_reporting_MASTER_v2]	
SET UptoDateSchool = UptoDate
WHERE UpToDate = 'No Record'
AND ([AgeInYears] >=14 OR UptoDateSchool IS NOT NULL)
			
--Update negative consent
UPDATE [CHIS_DW].[dbo].[tbl_V&I_reporting_MASTER_v2]	
SET NEGATIVECONSENT = IH.NEGATIVECONSENT
FROM [CHIS_DW].[dbo].[tbl_V&I_reporting_MASTER_v2] RM
LEFT JOIN 
(	SELECT NHSNUMBER, NC.NEGATIVECONSENTDESCS + ' - ' + NC.NEGATIVECONSENTS AS NEGATIVECONSENT FROM
	(		SELECT 
				NHSNUMBER
			,   NEGATIVECONSENTS = STUFF((SELECT  ', ' + [VACCINE] FROM [CHIS_DW].[DBO].[TBL_NEGATIVE_CONSENTS] S1 WHERE S1.NHSNUMBER = S2.NHSNUMBER AND S1.[REASONFORNEGATIVECONSENT] IN ('PR','34','B','REF','NPC','PREF','MED') GROUP BY [VACCINE] FOR XML PATH('')),1,2,'')
			,   NEGATIVECONSENTDESCS = STUFF((SELECT  ', ' + [REASONFORNEGATIVECONSENTDESC] FROM [CHIS_DW].[DBO].[TBL_NEGATIVE_CONSENTS] S1 WHERE S1.NHSNUMBER = S2.NHSNUMBER AND S1.[REASONFORNEGATIVECONSENT] IN ('PR','34','B','REF','NPC','PREF','MED') GROUP BY [REASONFORNEGATIVECONSENTDESC] FOR XML PATH('')),1,2,'')
			FROM [CHIS_DW].[DBO].[TBL_NEGATIVE_CONSENTS] S2
			WHERE S2.[REASONFORNEGATIVECONSENT] IN ('PR','34','B','REF','NPC','PREF', 'MED')
			AND S2.VACCINE <> 'BCG'
			GROUP BY NHSNUMBER
	) NC
)IH ON IH.NHSNUMBER = RM.NHSNUMBER 
  
-- Update the Imms History
UPDATE [CHIS_DW].[dbo].[tbl_V&I_reporting_MASTER_v2]	
SET IMMSHISTORY = IH.IMMSHISTORY
FROM [CHIS_DW].[dbo].[tbl_V&I_reporting_MASTER_v2] RM
LEFT JOIN 
(	  SELECT NHSNUMBER,  IMMSHISTORY = STUFF(
             (SELECT ', ' + '' + [VACCINECODE]  + ' - ' +  CAST([DATEOFIMMUNISATION] AS VARCHAR(50)) + '' 
              FROM [CHIS_DW].[DBO].[TBL_IMMUNISATIONS_BYVACCINE] IH1
              WHERE IH1.NHSNUMBER = IH2.NHSNUMBER GROUP BY [VACCINECODE],[DATEOFIMMUNISATION]
              FOR XML PATH (''))
             , 1, 1, '') FROM [CHIS_DW].[DBO].[TBL_IMMUNISATIONS_BYVACCINE] IH2
		GROUP BY NHSNUMBER
) IH ON IH.NHSNUMBER = RM.NHSNUMBER 

-- Update the DNAs 
UPDATE [CHIS_DW].[dbo].[tbl_V&I_reporting_MASTER_v2]	
SET [DNA(s)SinceImmunised] = IH.[DNA(s)]
FROM [CHIS_DW].[dbo].[tbl_V&I_reporting_MASTER_v2] RM
LEFT JOIN (SELECT NHSNUMBER, [DNA(s)] FROM [CHIS_DW].[dbo].[tbl_DNAs_SinceImmunised] GROUP BY NHSNUMBER, [DNA(s)]) IH ON IH.NHSNUMBER = RM.NHSNUMBER 

--Update the suspensions
UPDATE [CHIS_DW].[dbo].[tbl_V&I_reporting_MASTER_v2]	
SET Suspended = SS2.Suspensions
FROM [CHIS_DW].[dbo].[tbl_V&I_reporting_MASTER_v2] rm
LEFT JOIN (
	SELECT
	 SS.NHSNumber
	,CASE WHEN SS.SUSPENSIONDESCS LIKE 'Waiting for records%' THEN SS.SUSPENSIONDESCS  + ' from ' + SS.SUSPENSIONDATES -- do not need to list all vaccines when waiting for records (PM 04/10/19)
																ELSE (SS.SUSPENSIONS + ': ' + SS.SUSPENSIONDESCS  + ' from ' + SS.SUSPENSIONDATES)
																	END AS Suspensions
		FROM
			(	SELECT 
					NHSNUMBER
				,   SUSPENSIONS = STUFF((SELECT  ', ' + [VACCINE] FROM [CHIS_DW].[DBO].[TBL_SUSPENSIONS] S1 WHERE S1.NHSNUMBER = S2.NHSNUMBER AND (S1.SUSPENSIONENDDATE > s1.va_date OR S1.SuspensionEndDate IS NULL) AND S1.REASONFORSUSPENSIONCODE IN ('MED','W','M','VS','AC','IIR','PRIV') GROUP BY [VACCINE],s1.va_date FOR XML PATH('')),1,2,'')
				,   SUSPENSIONDATES = STUFF((SELECT  ', ' + CONVERT(VARCHAR(50),[SUSPENSIONSTARTDATE],103) FROM [CHIS_DW].[DBO].[TBL_SUSPENSIONS] S1 WHERE S1.NHSNUMBER = S2.NHSNUMBER AND (S1.SUSPENSIONENDDATE > s1.va_date OR S1.SuspensionEndDate IS NULL) AND S1.REASONFORSUSPENSIONCODE IN ('MED','W','M','VS','AC','IIR','PRIV') GROUP BY [SUSPENSIONSTARTDATE],s1.va_date FOR XML PATH('')),1,2,'')
				,   SUSPENSIONDESCS = STUFF((SELECT  ', ' + [REASONFORSUSPENSIONDESC] FROM [CHIS_DW].[DBO].[TBL_SUSPENSIONS] S1 WHERE S1.NHSNUMBER = S2.NHSNUMBER AND (S1.SUSPENSIONENDDATE > s1.va_date OR S1.SuspensionEndDate IS NULL) AND S1.REASONFORSUSPENSIONCODE IN ('MED','W','M','VS','AC','IIR','PRIV') GROUP BY [REASONFORSUSPENSIONDESC],s1.va_date FOR XML PATH('')),1,2,'')
				FROM [CHIS_DW].[DBO].[TBL_SUSPENSIONS] S2
				GROUP BY NHSNUMBER
			) SS 
	WHERE SS.SUSPENSIONS IS NOT NULL
) SS2 on SS2.NHSNumber = rm.NHSNumber 


-- Add the missing vaccines using dynamic SQL
DECLARE		 @MissingVaccinesSQL NVARCHAR(MAX)
			,@MissingVaccInt INT;

WITH CTE AS(SELECT DISTINCT CONCAT('[',[VaccineName],']') AS [VaccineName]
FROM [Reference].[dbo].[tbl_ref_AntigenRules_AntigensONLY])

SELECT @MissingVaccinesSQL=  ISNULL(@MissingVaccinesSQL + ' ','') + 'CASE WHEN RIGHT('+[VaccineName]+',1) = ''0'' 
	THEN '''+REPLACE(REPLACE([VaccineName],'[',''),']','')+', ''ELSE '''' END, '
FROM  CTE   

SELECT @MissingVaccInt = LEN(@MissingVaccinesSQL)-1

SELECT @MissingVaccinesSQL = LEFT (@MissingVaccinesSQL,@MissingVaccInt)

SELECT @MissingVaccinesSQL = 'UPDATE [CHIS_DW].[dbo].[tbl_V&I_reporting_MASTER_v2]	
SET OutstandingImms = ss.[OutstandingImms]
FROM [CHIS_DW].[dbo].[tbl_V&I_reporting_MASTER_v2] rm
LEFT JOIN 
(  SELECT 
	    [NHSNumber]
	 ,	REPLACE((CONCAT(' +@MissingVaccinesSQL +') + '' ''),'',  '','''') AS [OutstandingImms]

   FROM [CHIS_DW].[dbo].[tbl_V&I_reporting_MASTER_v2]

) ss on ss.NHSNumber = rm.NHSNumber '
EXEC (@MissingVaccinesSQL)
				
UPDATE [CHIS_DW].[dbo].[tbl_V&I_reporting_MASTER_v2]
SET OnPreviousReportFlag = his.OnPreviousReportFlag
FROM [CHIS_DW].[dbo].[tbl_V&I_reporting_MASTER_v2] rm
LEFT JOIN
 ( SELECT cur.NHSNUMBER, CASE WHEN his.NHSNUMBER is NOT NULL THEN 1 ELSE NULL END AS OnPreviousReportFlag
	FROM [CHIS_DW].[dbo].[tbl_V&I_reporting_MASTER_v2] cur
	LEFT JOIN [CHIS_DW].[dbo].[tbl_V&I_Historic] his
	ON his.NHSNUMBER = cur.NHSNUMBER  	
	GROUP BY  cur.NHSNUMBER, his.NHSNUMBER
 ) his on his.NHSNUMBER = rm.NHSNUMBER


UPDATE  [CHIS_DW].[dbo].[tbl_V&I_reporting_MASTER_v2]
SET OutstandingImms =
    LTRIM(RTRIM(
        REPLACE(
        REPLACE(
        REPLACE(
        REPLACE(
            REPLACE(REPLACE(OutstandingImms, 'MMR-1', 'MMRV-1'), 'MMR-2', 'MMRV-2'),

            'MMRV-1, MMRV-1', 'MMRV-1'
        ),
            'MMRV-2, MMRV-2', 'MMRV-2'
        ),

            ', ,', ','
        ),
            '  ', ' '
        )
    ))
WHERE OutstandingImms LIKE '%MMR-%';
 	
UPDATE [chis_dw].[dbo].[tbl_v&i_reporting_master_v2] 
SET va_Date = cast(getdate() as date) -- to prevent multiple va_dates when written to aggregate table 
