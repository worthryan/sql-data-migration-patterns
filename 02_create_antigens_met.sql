-- Now return what Antigens have been given against the Antigens required and write to table
;
WITH CTE AS (
    SELECT
        Child.NHSNumber,
        Child.DOB,
        Child.AntigenName,
        MAX(CONVERT(INT, Child.DosesRequired)) AS DosesRequired,
        MAX(AntigenRef) AS AntigenRef,
        Two.ValidDosesGiven,
        Child.VaccineName,
        Child.VaccineGroup,
        AntigenChildRef
    FROM ##AntigensMet Child
    OUTER APPLY (
        SELECT TOP 1 ValidDosesGiven
        FROM ##AntigensMet
        WHERE NHSNumber = Child.NHSNumber
          AND VaccineName = Child.VaccineName
          AND AntigenName = Child.AntigenName
        ORDER BY ValidDosesGiven
    ) Two
    GROUP BY
        Child.NHSNumber,
        Child.DOB,
        Child.AntigenName,
        Child.VaccineName,
        Child.VaccineGroup,
        Two.ValidDosesGiven,
        AntigenChildRef
)

SELECT   Child.NHSNumber
		,Child.DOB
		,Child.AntigenName
		,CASE	WHEN  Parent.NHSNumber IS NOT NULL AND Child.ValidDosesGiven = 0 THEN 0
				WHEN Parent.NHSNumber IS NOT NULL AND Child.DosesRequired<Child.ValidDosesGiven AND Parent.DosesRequired>=Parent.ValidDosesGiven
						AND Child.ValidDosesGiven - Parent.ValidDosesGiven >= Child.DosesRequired 
						THEN  Child.ValidDosesGiven - Parent.ValidDosesGiven
				WHEN Parent.NHSNumber IS NOT NULL AND Child.DosesRequired <= Child.ValidDosesGiven 
						THEN Child.DosesRequired
				WHEN MyChild.NHSNumber IS NOT NULL AND Child.ValidDosesGiven = 0 THEN 0
				WHEN MyChild.NHSNumber IS NOT NULL AND Child.ValidDosesGiven + MyChild.DosesRequired <= MyChild.ValidDosesGiven
						THEN Child.ValidDosesGiven
				WHEN MyChild.ValidDosesGiven< child.ValidDosesGiven AND Child.AntigenName NOT IN (SELECT Shortname FROM ##TakeOverVaccines) THEN child.ValidDosesGiven - MyChild.ValidDosesGiven
				WHEN MyChild.NHSNumber IS NOT NULL AND MyChild.ValidDosesGiven<=MyChild.DosesRequired AND Child.VaccineName IN (SELECT [VaccineName] FROM [Reference].[dbo].[tbl_ref_AntigenRules_AntigensONLY]WHERE [DosesSplitByVaccineGroup] = 1)THEN 0
				WHEN MyChild.ValidDosesGiven< child.ValidDosesGiven AND Child.AntigenName NOT IN (SELECT Shortname FROM ##TakeOverVaccines) THEN child.ValidDosesGiven
				WHEN MyChild.NHSNumber IS NOT NULL AND Child.AntigenRef IN (SELECT Ref FROM [Reference].[dbo].[tbl_ref_AntigenRules_AntigensONLY] WHERE [DosesSplitByVaccineGroup] = 1)
					THEN Child.DosesRequired
			ELSE Child.ValidDosesGiven
		 END AS ValidDosesGiven
		,Child.DosesRequired
		,Child.VaccineName
		,Child.VaccineGroup
		,CONVERT(NVARCHAR(10),NULL) MetFlag
		,Child.AntigenRef
		,Child.AntigenChildRef
INTO  ##AntigensMet_2
FROM CTE Child
	LEFT JOIN CTE Parent
	ON Child.NHSNumber = Parent.NHSNumber
	AND Child.AntigenRef = Parent.AntigenChildRef
	AND Child.AntigenName = Parent.AntigenName
	LEFT JOIN CTE MyChild
		ON MyChild.NHSNumber = Child.NHSNumber
			AND MyChild.AntigenRef = Child.AntigenChildRef
			AND MyChild.AntigenName = Child.AntigenName
ORDER BY MyChild.DosesRequired DESC
 
CREATE CLUSTERED INDEX [NHS_Idx] ON ##AntigensMet_2 ([NHSNumber] ASC)


CREATE NONCLUSTERED INDEX IX_AntigensMet2_NHS_Vaccine
ON ##AntigensMet_2 (NHSNumber, VaccineName)
INCLUDE (VaccineGroup, AntigenName, ValidDosesGiven, DosesRequired, MetFlag);

UPDATE ##AntigensMet_2
	SET MetFlag = 1
	WHERE ValidDosesGiven >=DosesRequired
UPDATE ##AntigensMet_2
	SET MetFlag = 0
	WHERE MetFlag IS NULL