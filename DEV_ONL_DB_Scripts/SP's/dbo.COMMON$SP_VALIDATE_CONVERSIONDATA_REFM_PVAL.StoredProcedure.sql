/****** Object:  StoredProcedure [dbo].[COMMON$SP_VALIDATE_CONVERSIONDATA_REFM_PVAL]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
------------------------------------------------------------------------------------------------------------------
Program Name		: COMMON$SP_VALIDATE_CONVERSIONDATA_REFM_PVAL
Programmer Name		: Protech Solutions, Inc. RAJKUMAR RAJENDRAN
Description_TEXT	: This Procedure loads all the REFM, Possible Values data issues in CRPR_Y1 table.
Developed On		: 02/02/2011
Modified By			:
Modified On			: 02/08/2013
Version No			: 1.0
------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[COMMON$SP_VALIDATE_CONVERSIONDATA_REFM_PVAL]
 @Ad_Conversion_DATE DATE
AS
 BEGIN
  BEGIN TRY
   DECLARE @Ls_Sql_TEXT VARCHAR(200);

   SET @Ls_Sql_TEXT = '';

   IF EXISTS(SELECT 1
               FROM SYS.OBJECTS
              WHERE Name = 'CRPR_Y1_BK'
                AND TYPE = 'U')
    BEGIN
     INSERT INTO CRPR_Y1_BK
     SELECT *
       FROM CRPR_Y1
    END

   IF NOT EXISTS(SELECT 1
                   FROM SYS.OBJECTS
                  WHERE Name = 'CRPR_Y1_BK'
                    AND TYPE = 'U')
    BEGIN
     IF EXISTS(SELECT TOP 1 *
                 FROM CRPR_Y1)
      BEGIN
       SELECT *
         INTO CRPR_Y1_BK
         FROM CRPR_Y1;
      END
    END

   IF EXISTS(SELECT TOP 1 *
               FROM CRPR_Y1)
    BEGIN
     DELETE FROM CRPR_Y1;
    END

   -----------
   IF EXISTS(SELECT 1
               FROM SYS.OBJECTS
              WHERE Name = 'CRPRLog_Y1_BK'
                AND TYPE = 'U')
    BEGIN
     --DROP TABLE CRPRLog_Y1_BK;
     INSERT INTO CRPRLog_Y1_BK
     SELECT *
       FROM CRPRLog_Y1
    END

   IF NOT EXISTS(SELECT 1
                   FROM SYS.OBJECTS
                  WHERE Name = 'CRPRLog_Y1_BK'
                    AND TYPE = 'U')
    BEGIN
     IF EXISTS(SELECT TOP 1 *
                 FROM CRPRLog_Y1)
      BEGIN
       SELECT *
         INTO CRPRLog_Y1_BK
         FROM CRPRLog_Y1;
      END
    END

   IF EXISTS(SELECT TOP 1 *
               FROM CRPRLog_Y1)
    BEGIN
     DELETE FROM CRPRLog_Y1;
    END



   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          'COMMON$SP_VALIDATE_CONVERSIONDATA_REFM_PVAL Execution IS Started. Please Wait....',
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in ASFN_Y1.SourceLoc_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'MemberFinAssets_T1',
          'SourceLoc_CODE',
          SourceLoc_CODE,
          COUNT(1)
     FROM MemberFinAssets_T1
    WHERE LTRIM(RTRIM(SourceLoc_CODE)) <> ''
      AND SourceLoc_CODE NOT IN (SELECT VALUE_CODE
                                   FROM REFM_Y1
                                  WHERE (Table_ID = 'MAST'
                                     AND TableSub_ID = 'SRCE'))
    GROUP BY SourceLoc_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in ASFN_Y1.Status_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'MemberFinAssets_T1',
          'Status_CODE',
          Status_CODE,
          COUNT(1)
     FROM MemberFinAssets_T1
    WHERE LTRIM(RTRIM(Status_CODE)) <> ''
      AND Status_CODE NOT IN (SELECT VALUE_CODE
                                FROM REFM_Y1
                               WHERE (Table_ID = 'MAST'
                                  AND TableSub_ID = 'VSTS'))
    GROUP BY Status_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in CASE_Y1.CpRelationshipToNcp_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'CaseDetails_T1',
          'CpRelationshipToNcp_CODE',
          CpRelationshipToNcp_CODE,
          COUNT(1)
     FROM CaseDetails_T1
    WHERE LTRIM(RTRIM(CpRelationshipToNcp_CODE)) <> ''
      AND CpRelationshipToNcp_CODE NOT IN (SELECT VALUE_CODE
                                             FROM REFM_Y1
                                            WHERE (Table_ID = 'FMLY'
                                               AND TableSub_ID = 'RELA'))
    GROUP BY CpRelationshipToNcp_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in CASE_Y1.ReasonFeeWaived_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'CaseDetails_T1',
          'ReasonFeeWaived_CODE',
          ReasonFeeWaived_CODE,
          COUNT(1)
     FROM CaseDetails_T1
    WHERE LTRIM(RTRIM(ReasonFeeWaived_CODE)) <> ''
      AND ReasonFeeWaived_CODE NOT IN (SELECT VALUE_CODE
                                         FROM REFM_Y1
                                        WHERE (Table_ID = 'CCRT'
                                           AND TableSub_ID = 'WRES'))
    GROUP BY ReasonFeeWaived_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in CBOR_Y1.TypeTransCbor_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'CreditBureauOvr_T1',
          'TypeTransCbor_CODE',
          TypeTransCbor_CODE,
          COUNT(1)
     FROM CreditBureauOvr_T1
    WHERE LTRIM(RTRIM(TypeTransCbor_CODE)) <> ''
      AND TypeTransCbor_CODE NOT IN (SELECT VALUE_CODE
                                       FROM REFM_Y1
                                      WHERE (Table_ID = 'UIRR'
                                         AND TableSub_ID = 'TRAN'))
    GROUP BY TypeTransCbor_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in CHLD_Y1.ReasonHold_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'CpHold_T1',
          'ReasonHold_CODE',
          ReasonHold_CODE,
          COUNT(1)
     FROM CpHold_T1
    WHERE LTRIM(RTRIM(ReasonHold_CODE)) <> ''
      AND ReasonHold_CODE NOT IN (SELECT VALUE_CODE
                                    FROM REFM_Y1
                                   WHERE (Table_ID = 'DHLD'
                                      AND TableSub_ID = 'DHLH'))
    GROUP BY ReasonHold_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in CMEM_Y1.TypeFamilyViolence_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'CaseMembers_T1',
          'TypeFamilyViolence_CODE',
          TypeFamilyViolence_CODE,
          COUNT(1)
     FROM CaseMembers_T1
    WHERE LTRIM(RTRIM(TypeFamilyViolence_CODE)) <> ''
      AND TypeFamilyViolence_CODE NOT IN (SELECT VALUE_CODE
                                            FROM REFM_Y1
                                           WHERE (Table_ID = 'DEMO'
                                              AND TableSub_ID = 'VIOL'))
    GROUP BY TypeFamilyViolence_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in DCKT_Y1.FileType_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'Dockets_T1',
          'FileType_CODE',
          FileType_CODE,
          COUNT(1)
     FROM Dockets_T1
    WHERE LTRIM(RTRIM(FileType_CODE)) <> ''
      AND FileType_CODE NOT IN (SELECT VALUE_CODE
                                  FROM REFM_Y1
                                 WHERE (Table_ID = 'FILE'
                                    AND TableSub_ID = 'CNTY'))
    GROUP BY FileType_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in DEMO_Y1.Assistance_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'MemberDemographics_T1',
          'Assistance_CODE',
          Assistance_CODE,
          COUNT(1)
     FROM MemberDemographics_T1
    WHERE LTRIM(RTRIM(Assistance_CODE)) <> ''
      AND Assistance_CODE NOT IN (SELECT VALUE_CODE
                                    FROM REFM_Y1
                                   WHERE (Table_ID = 'GENR'
                                      AND TableSub_ID = 'ASTS'))
    GROUP BY Assistance_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in DHLD_Y1.SourceBatch_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'LogDisbursementHold_T1',
          'SourceBatch_CODE',
          SourceBatch_CODE,
          COUNT(1)
     FROM LogDisbursementHold_T1
    WHERE LTRIM(RTRIM(SourceBatch_CODE)) <> ''
      AND SourceBatch_CODE NOT IN (SELECT VALUE_CODE
                                     FROM REFM_Y1
                                    WHERE (Table_ID = 'RCTB'
                                       AND TableSub_ID = 'RCTB'))
    GROUP BY SourceBatch_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in DHLD_Y1.Status_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'LogDisbursementHold_T1',
          'Status_CODE',
          Status_CODE,
          COUNT(1)
     FROM LogDisbursementHold_T1
    WHERE LTRIM(RTRIM(Status_CODE)) <> ''
      AND Status_CODE NOT IN (SELECT VALUE_CODE
                                FROM REFM_Y1
                               WHERE (Table_ID = 'RCTH'
                                  AND TableSub_ID = 'STAT'))
    GROUP BY Status_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in DINS_Y1.InsSource_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'DependantInsurance_T1',
          'InsSource_CODE',
          InsSource_CODE,
          COUNT(1)
     FROM DependantInsurance_T1
    WHERE LTRIM(RTRIM(InsSource_CODE)) <> ''
      AND InsSource_CODE NOT IN (SELECT VALUE_CODE
                                   FROM REFM_Y1
                                  WHERE (Table_ID = 'MDIN'
                                     AND TableSub_ID = 'SRCE'))
    GROUP BY InsSource_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in DINS_Y1.NonQualified_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'DependantInsurance_T1',
          'NonQualified_CODE',
          NonQualified_CODE,
          COUNT(1)
     FROM DependantInsurance_T1
    WHERE LTRIM(RTRIM(NonQualified_CODE)) <> ''
      AND NonQualified_CODE NOT IN (SELECT VALUE_CODE
                                      FROM REFM_Y1
                                     WHERE (Table_ID = 'MDIN'
                                        AND TableSub_ID = 'NOQU'))
    GROUP BY NonQualified_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in DINS_Y1.Status_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'DependantInsurance_T1',
          'Status_CODE',
          Status_CODE,
          COUNT(1)
     FROM DependantInsurance_T1
    WHERE LTRIM(RTRIM(Status_CODE)) <> ''
      AND Status_CODE NOT IN (SELECT VALUE_CODE
                                FROM REFM_Y1
                               WHERE (Table_ID = 'MDIN'
                                  AND TableSub_ID = 'PVST'))
    GROUP BY Status_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in DISH_Y1.TypeHold_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'DistributionHold_T1',
          'TypeHold_CODE',
          TypeHold_CODE,
          COUNT(1)
     FROM DistributionHold_T1
    WHERE LTRIM(RTRIM(TypeHold_CODE)) <> ''
      AND TypeHold_CODE NOT IN (SELECT VALUE_CODE
                                  FROM REFM_Y1
                                 WHERE (Table_ID = 'DHLD'
                                    AND TableSub_ID = 'TYPH'))
    GROUP BY TypeHold_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in DMNR_Y1.Status_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'MinorActivityDiary_T1',
          'Status_CODE',
          Status_CODE,
          COUNT(1)
     FROM MinorActivityDiary_T1
    WHERE LTRIM(RTRIM(Status_CODE)) <> ''
      AND Status_CODE NOT IN (SELECT VALUE_CODE
                                FROM REFM_Y1
                               WHERE (Table_ID = 'CPRO'
                                  AND TableSub_ID = 'RSTS'))
    GROUP BY Status_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in DSBL_Y1.CheckRecipient_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'LogDisbursementDetail_T1',
          'CheckRecipient_CODE',
          CheckRecipient_CODE,
          COUNT(1)
     FROM LogDisbursementDetail_T1
    WHERE LTRIM(RTRIM(CheckRecipient_CODE)) <> ''
      AND CheckRecipient_CODE NOT IN (SELECT VALUE_CODE
                                        FROM REFM_Y1
                                       WHERE (Table_ID = 'GENR'
                                          AND TableSub_ID = 'FUND'))
    GROUP BY CheckRecipient_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in DSBL_Y1.SourceBatch_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'LogDisbursementDetail_T1',
          'SourceBatch_CODE',
          SourceBatch_CODE,
          COUNT(1)
     FROM LogDisbursementDetail_T1
    WHERE LTRIM(RTRIM(SourceBatch_CODE)) <> ''
      AND SourceBatch_CODE NOT IN (SELECT VALUE_CODE
                                     FROM REFM_Y1
                                    WHERE (Table_ID = 'RCTB'
                                       AND TableSub_ID = 'RCTB'))
    GROUP BY SourceBatch_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in FADT_Y1.CaseMemberStatus_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'FcrAuditDetails_T1',
          'CaseMemberStatus_CODE',
          CaseMemberStatus_CODE,
          COUNT(1)
     FROM FcrAuditDetails_T1
    WHERE LTRIM(RTRIM(CaseMemberStatus_CODE)) <> ''
      AND CaseMemberStatus_CODE NOT IN (SELECT VALUE_CODE
                                          FROM REFM_Y1
                                         WHERE (Table_ID = 'GENR'
                                            AND TableSub_ID = 'MEMS'))
    GROUP BY CaseMemberStatus_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in FADT_Y1.CaseRelationship_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'FcrAuditDetails_T1',
          'CaseRelationship_CODE',
          CaseRelationship_CODE,
          COUNT(1)
     FROM FcrAuditDetails_T1
    WHERE LTRIM(RTRIM(CaseRelationship_CODE)) <> ''
      AND CaseRelationship_CODE NOT IN (SELECT VALUE_CODE
                                          FROM REFM_Y1
                                         WHERE (Table_ID = 'RELA'
                                            AND TableSub_ID = 'CASE'))
    GROUP BY CaseRelationship_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in FADT_Y1.StatusCase_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'FcrAuditDetails_T1',
          'StatusCase_CODE',
          StatusCase_CODE,
          COUNT(1)
     FROM FcrAuditDetails_T1
    WHERE LTRIM(RTRIM(StatusCase_CODE)) <> ''
      AND StatusCase_CODE NOT IN (SELECT VALUE_CODE
                                    FROM REFM_Y1
                                   WHERE (Table_ID = 'CSTS'
                                      AND TableSub_ID = 'CSTS'))
    GROUP BY StatusCase_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in FADT_Y1.TypeCase_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'FcrAuditDetails_T1',
          'TypeCase_CODE',
          TypeCase_CODE,
          COUNT(1)
     FROM FcrAuditDetails_T1
    WHERE LTRIM(RTRIM(TypeCase_CODE)) <> ''
      AND TypeCase_CODE NOT IN (SELECT VALUE_CODE
                                  FROM REFM_Y1
                                 WHERE (Table_ID = 'CCRT'
                                    AND TableSub_ID = 'CTYP'))
    GROUP BY TypeCase_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in FEDH_Y1.CountyFips_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'FederalLastSent_T1',
          'CountyFips_CODE',
          CountyFips_CODE,
          COUNT(1)
     FROM FederalLastSent_T1
    WHERE LTRIM(RTRIM(ISNULL(CountyFips_CODE, ''))) <> ''
      AND (RIGHT(REPLICATE('0', 3) + LTRIM(RTRIM(CAST(ISNULL(CountyFips_CODE, '') AS VARCHAR))), 3)) NOT IN (SELECT (RIGHT(REPLICATE('0', 3) + LTRIM(RTRIM(CAST(ISNULL(VALUE_CODE, '') AS VARCHAR))), 3))
                                                                                                               FROM REFM_Y1
                                                                                                              WHERE (Table_ID = 'OTHP'
                                                                                                                 AND TableSub_ID = 'CNTY'))
    GROUP BY CountyFips_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in ICAS_Y1.IVDOutOfStateFips_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'InterstateCases_T1',
          'IVDOutOfStateFips_CODE',
          a.IVDOutOfStateFips_CODE,
          COUNT(1)
     FROM InterstateCases_T1 A
    WHERE LTRIM(RTRIM(a.IVDOutOfStateFips_CODE)) <> ''
      AND NOT EXISTS (SELECT 1
                        FROM FIPS_Y1 B
                       WHERE A.IVDOutOfStateFips_CODE = B.StateFips_CODE
                         AND EndValidity_DATE = '12/31/9999')
    GROUP BY IVDOutOfStateFips_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in IFMS_Y1.CountyFips_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'InterceptFmsLog_T1',
          'CountyFips_CODE',
          CountyFips_CODE,
          COUNT(1)
     FROM InterceptFmsLog_T1
    WHERE LTRIM(RTRIM(ISNULL(CountyFips_CODE, ''))) <> ''
      AND (RIGHT(REPLICATE('0', 3) + LTRIM(RTRIM(CAST(ISNULL(CountyFips_CODE, '') AS VARCHAR))), 3)) NOT IN (SELECT (RIGHT(REPLICATE('0', 3) + LTRIM(RTRIM(CAST(ISNULL(VALUE_CODE, '') AS VARCHAR))), 3))
                                                                                                               FROM REFM_Y1
                                                                                                              WHERE (Table_ID = 'OTHP'
                                                                                                                 AND TableSub_ID = 'CNTY'))
    GROUP BY CountyFips_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in ISTX_Y1.CountyFips_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'InterceptStxLog_T1',
          'CountyFips_CODE',
          CountyFips_CODE,
          COUNT(1)
     FROM InterceptStxLog_T1
    WHERE LTRIM(RTRIM(ISNULL(CountyFips_CODE, ''))) <> ''
      AND (RIGHT(REPLICATE('0', 3) + LTRIM(RTRIM(CAST(ISNULL(CountyFips_CODE, '') AS VARCHAR))), 3)) NOT IN (SELECT (RIGHT(REPLICATE('0', 3) + LTRIM(RTRIM(CAST(ISNULL(VALUE_CODE, '') AS VARCHAR))), 3))
                                                                                                               FROM REFM_Y1
                                                                                                              WHERE (Table_ID = 'OTHP'
                                                                                                                 AND TableSub_ID = 'CNTY'))
    GROUP BY CountyFips_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in IWEM_Y1.FreqCs_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'IwEmployers_T1',
          'FreqCs_CODE',
          FreqCs_CODE,
          COUNT(1)
     FROM IwEmployers_T1
    WHERE LTRIM(RTRIM(FreqCs_CODE)) <> ''
      AND FreqCs_CODE NOT IN (SELECT VALUE_CODE
                                FROM REFM_Y1
                               WHERE (Table_ID = 'FRQA'
                                  AND TableSub_ID = 'FRQ3'))
    GROUP BY FreqCs_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in IWEM_Y1.FreqMd_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'IwEmployers_T1',
          'FreqMd_CODE',
          FreqMd_CODE,
          COUNT(1)
     FROM IwEmployers_T1
    WHERE LTRIM(RTRIM(FreqMd_CODE)) <> ''
      AND FreqMd_CODE NOT IN (SELECT VALUE_CODE
                                FROM REFM_Y1
                               WHERE (Table_ID = 'FRQA'
                                  AND TableSub_ID = 'FRQ3'))
    GROUP BY FreqMd_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in IWEM_Y1.FreqOt_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'IwEmployers_T1',
          'FreqOt_CODE',
          FreqOt_CODE,
          COUNT(1)
     FROM IwEmployers_T1
    WHERE LTRIM(RTRIM(FreqOt_CODE)) <> ''
      AND FreqOt_CODE NOT IN (SELECT VALUE_CODE
                                FROM REFM_Y1
                               WHERE (Table_ID = 'FRQA'
                                  AND TableSub_ID = 'FRQ3'))
    GROUP BY FreqOt_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in IWEM_Y1.FreqPayback_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'IwEmployers_T1',
          'FreqPayback_CODE',
          FreqPayback_CODE,
          COUNT(1)
     FROM IwEmployers_T1
    WHERE LTRIM(RTRIM(FreqPayback_CODE)) <> ''
      AND FreqPayback_CODE NOT IN (SELECT VALUE_CODE
                                     FROM REFM_Y1
                                    WHERE (Table_ID = 'FRQA'
                                       AND TableSub_ID = 'FRQ3'))
    GROUP BY FreqPayback_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in IWEM_Y1.FreqSs_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'IwEmployers_T1',
          'FreqSs_CODE',
          FreqSs_CODE,
          COUNT(1)
     FROM IwEmployers_T1
    WHERE LTRIM(RTRIM(FreqSs_CODE)) <> ''
      AND FreqSs_CODE NOT IN (SELECT VALUE_CODE
                                FROM REFM_Y1
                               WHERE (Table_ID = 'FRQA'
                                  AND TableSub_ID = 'FRQ3'))
    GROUP BY FreqSs_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in IWEM_Y1.IwnPer_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'IwEmployers_T1',
          'IwnPer_CODE',
          IwnPer_CODE,
          COUNT(1)
     FROM IwEmployers_T1
    WHERE LTRIM(RTRIM(IwnPer_CODE)) <> ''
      AND IwnPer_CODE NOT IN (SELECT VALUE_CODE
                                FROM REFM_Y1
                               WHERE (Table_ID = 'IWNS'
                                  AND TableSub_ID = 'IWME'))
    GROUP BY IwnPer_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in IWEM_Y1.IwnStatus_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'IwEmployers_T1',
          'IwnStatus_CODE',
          IwnStatus_CODE,
          COUNT(1)
     FROM IwEmployers_T1
    WHERE LTRIM(RTRIM(IwnStatus_CODE)) <> ''
      AND IwnStatus_CODE NOT IN (SELECT VALUE_CODE
                                   FROM REFM_Y1
                                  WHERE (Table_ID = 'IWNS'
                                     AND TableSub_ID = 'STAT'))
    GROUP BY IwnStatus_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in IWEM_Y1.TypeSource_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'IwEmployers_T1',
          'TypeSource_CODE',
          TypeSource_CODE,
          COUNT(1)
     FROM IwEmployers_T1
    WHERE LTRIM(RTRIM(TypeSource_CODE)) <> ''
      AND TypeSource_CODE NOT IN (SELECT VALUE_CODE
                                    FROM REFM_Y1
                                   WHERE (Table_ID = 'SORD'
                                      AND TableSub_ID = 'IWOR'))
    GROUP BY TypeSource_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in LSTT_Y1.SourceLoc_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'LocateStatus_T1',
          'SourceLoc_CODE',
          SourceLoc_CODE,
          COUNT(1)
     FROM LocateStatus_T1
    WHERE LTRIM(RTRIM(SourceLoc_CODE)) <> ''
      AND SourceLoc_CODE NOT IN (SELECT VALUE_CODE
                                   FROM REFM_Y1
                                  WHERE (Table_ID = 'AHIS'
                                     AND TableSub_ID = 'VERS'))
    GROUP BY SourceLoc_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in LSUP_Y1.CheckRecipient_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'LogSupport_T1',
          'CheckRecipient_CODE',
          CheckRecipient_CODE,
          COUNT(1)
     FROM LogSupport_T1
    WHERE LTRIM(RTRIM(CheckRecipient_CODE)) <> ''
      AND CheckRecipient_CODE NOT IN (SELECT VALUE_CODE
                                        FROM REFM_Y1
                                       WHERE (Table_ID = 'GENR'
                                          AND TableSub_ID = 'FUND'))
    GROUP BY CheckRecipient_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in LSUP_Y1.SourceBatch_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'LogSupport_T1',
          'SourceBatch_CODE',
          SourceBatch_CODE,
          COUNT(1)
     FROM LogSupport_T1
    WHERE LTRIM(RTRIM(SourceBatch_CODE)) <> ''
      AND SourceBatch_CODE NOT IN (SELECT VALUE_CODE
                                     FROM REFM_Y1
                                    WHERE (Table_ID = 'RCTB'
                                       AND TableSub_ID = 'RCTB'))
    GROUP BY SourceBatch_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in MDET_Y1.ParoleReason_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'MemberDetention_T1',
          'ParoleReason_CODE',
          ParoleReason_CODE,
          COUNT(1)
     FROM MemberDetention_T1
    WHERE LTRIM(RTRIM(ParoleReason_CODE)) <> ''
      AND ParoleReason_CODE NOT IN (SELECT VALUE_CODE
                                      FROM REFM_Y1
                                     WHERE (Table_ID = 'DEMO'
                                        AND TableSub_ID = 'INST'))
    GROUP BY ParoleReason_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in MINS_Y1.InsSource_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'MemberInsurance_T1',
          'InsSource_CODE',
          InsSource_CODE,
          COUNT(1)
     FROM MemberInsurance_T1
    WHERE LTRIM(RTRIM(InsSource_CODE)) <> ''
      AND InsSource_CODE NOT IN (SELECT VALUE_CODE
                                   FROM REFM_Y1
                                  WHERE (Table_ID = 'MDIN'
                                     AND TableSub_ID = 'SRCE'))
    GROUP BY InsSource_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in OBLE_Y1.CheckRecipient_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'Obligation_T1',
          'CheckRecipient_CODE',
          CheckRecipient_CODE,
          COUNT(1)
     FROM Obligation_T1
    WHERE LTRIM(RTRIM(CheckRecipient_CODE)) <> ''
      AND CheckRecipient_CODE NOT IN (SELECT VALUE_CODE
                                        FROM REFM_Y1
                                       WHERE (Table_ID = 'GENR'
                                          AND TableSub_ID = 'FUND'))
    GROUP BY CheckRecipient_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in ORDB_Y1.TypeDebt_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'OrderDebt_T1',
          'TypeDebt_CODE',
          TypeDebt_CODE,
          COUNT(1)
     FROM OrderDebt_T1
    WHERE LTRIM(RTRIM(TypeDebt_CODE)) <> ''
      AND TypeDebt_CODE NOT IN (SELECT VALUE_CODE
                                  FROM REFM_Y1
                                 WHERE (Table_ID = 'DBTP'
                                    AND TableSub_ID = 'DBTP'))
    GROUP BY TypeDebt_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in POFL_Y1.SourceBatch_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'PayeeOffsetLog_T1',
          'SourceBatch_CODE',
          SourceBatch_CODE,
          COUNT(1)
     FROM PayeeOffsetLog_T1
    WHERE LTRIM(RTRIM(SourceBatch_CODE)) <> ''
      AND SourceBatch_CODE NOT IN (SELECT VALUE_CODE
                                     FROM REFM_Y1
                                    WHERE (Table_ID = 'RCTB'
                                       AND TableSub_ID = 'RCTB'))
    GROUP BY SourceBatch_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in POFL_Y1.TypeDisburse_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'PayeeOffsetLog_T1',
          'TypeDisburse_CODE',
          TypeDisburse_CODE,
          COUNT(1)
     FROM PayeeOffsetLog_T1
    WHERE LTRIM(RTRIM(TypeDisburse_CODE)) <> ''
      AND TypeDisburse_CODE NOT IN (SELECT VALUE_CODE
                                      FROM REFM_Y1
                                     WHERE (Table_ID = 'DISB'
                                        AND TableSub_ID = 'DISB'))
    GROUP BY TypeDisburse_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in RBAT_Y1.SourceReceipt_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'ReceiptBatch_T1',
          'SourceReceipt_CODE',
          SourceReceipt_CODE,
          COUNT(1)
     FROM ReceiptBatch_T1
    WHERE LTRIM(RTRIM(SourceReceipt_CODE)) <> ''
      AND SourceReceipt_CODE NOT IN (SELECT VALUE_CODE
                                       FROM REFM_Y1
                                      WHERE (Table_ID = 'RCTS'
                                         AND TableSub_ID = 'RCTS'))
    GROUP BY SourceReceipt_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in RBAT_Y1.TypeRemittance_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'ReceiptBatch_T1',
          'TypeRemittance_CODE',
          TypeRemittance_CODE,
          COUNT(1)
     FROM ReceiptBatch_T1
    WHERE LTRIM(RTRIM(TypeRemittance_CODE)) <> ''
      AND TypeRemittance_CODE NOT IN (SELECT VALUE_CODE
                                        FROM REFM_Y1
                                       WHERE (Table_ID = 'RCTP'
                                          AND TableSub_ID = 'RCTP'))
    GROUP BY TypeRemittance_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in RSDU_Y1.SourceBatch_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'ReceiptSduReference_T1',
          'SourceBatch_CODE',
          SourceBatch_CODE,
          COUNT(1)
     FROM ReceiptSduReference_T1
    WHERE LTRIM(RTRIM(SourceBatch_CODE)) <> ''
      AND SourceBatch_CODE NOT IN (SELECT VALUE_CODE
                                     FROM REFM_Y1
                                    WHERE (Table_ID = 'RCTB'
                                       AND TableSub_ID = 'RCTB'))
    GROUP BY SourceBatch_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in SLST_Y1.CountyFips_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'StateLastSent_T1',
          'CountyFips_CODE',
          CountyFips_CODE,
          COUNT(1)
     FROM StateLastSent_T1
    WHERE LTRIM(RTRIM(ISNULL(CountyFips_CODE, ''))) <> ''
      AND (RIGHT(REPLICATE('0', 3) + LTRIM(RTRIM(CAST(ISNULL(CountyFips_CODE, '') AS VARCHAR))), 3)) NOT IN (SELECT (RIGHT(REPLICATE('0', 3) + LTRIM(RTRIM(CAST(ISNULL(VALUE_CODE, '') AS VARCHAR))), 3))
                                                                                                               FROM REFM_Y1
                                                                                                              WHERE (Table_ID = 'OTHP'
                                                                                                                 AND TableSub_ID = 'CNTY'))
    GROUP BY CountyFips_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in SORD_Y1.IwoInitiatedBy_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'SupportOrder_T1',
          'IwoInitiatedBy_CODE',
          IwoInitiatedBy_CODE,
          COUNT(1)
     FROM SupportOrder_T1
    WHERE LTRIM(RTRIM(IwoInitiatedBy_CODE)) <> ''
      AND IwoInitiatedBy_CODE NOT IN (SELECT VALUE_CODE
                                        FROM REFM_Y1
                                       WHERE (Table_ID = 'SORD'
                                          AND TableSub_ID = 'IWOR'))
    GROUP BY IwoInitiatedBy_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in SORD_Y1.StatusOrder_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'SupportOrder_T1',
          'StatusOrder_CODE',
          StatusOrder_CODE,
          COUNT(1)
     FROM SupportOrder_T1
    WHERE LTRIM(RTRIM(StatusOrder_CODE)) <> ''
      AND StatusOrder_CODE NOT IN (SELECT VALUE_CODE
                                     FROM REFM_Y1
                                    WHERE (Table_ID = 'SORD'
                                       AND TableSub_ID = 'INSC'))
    GROUP BY StatusOrder_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in TADR_Y1.SourceBatch_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'TripAddressDetails_T1',
          'SourceBatch_CODE',
          SourceBatch_CODE,
          COUNT(1)
     FROM TripAddressDetails_T1
    WHERE LTRIM(RTRIM(SourceBatch_CODE)) <> ''
      AND SourceBatch_CODE NOT IN (SELECT VALUE_CODE
                                     FROM REFM_Y1
                                    WHERE (Table_ID = 'RCTB'
                                       AND TableSub_ID = 'RCTB'))
    GROUP BY SourceBatch_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in URCT_Y1.SourceBatch_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'UnidentifiedReceipts_T1',
          'SourceBatch_CODE',
          SourceBatch_CODE,
          COUNT(1)
     FROM UnidentifiedReceipts_T1
    WHERE LTRIM(RTRIM(SourceBatch_CODE)) <> ''
      AND SourceBatch_CODE NOT IN (SELECT VALUE_CODE
                                     FROM REFM_Y1
                                    WHERE (Table_ID = 'RCTB'
                                       AND TableSub_ID = 'RCTB'))
    GROUP BY SourceBatch_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in ACEN_Y1.StatusEnforce_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'ACEN_Y1',
          'StatusEnforce_CODE',
          StatusEnforce_CODE,
          COUNT(1)
     FROM ACEN_Y1
    WHERE LTRIM(RTRIM(StatusEnforce_CODE)) <> ''
      AND StatusEnforce_CODE NOT IN (SELECT VALUE_CODE
                                       FROM REFM_Y1
                                      WHERE Table_ID = 'CPRO'
                                        AND TableSub_ID = 'STAT')
    GROUP BY StatusEnforce_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in AHIS_Y1.Country_ADDR column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'AHIS_Y1',
          'Country_ADDR',
          Country_ADDR,
          COUNT(1)
     FROM AHIS_Y1
    WHERE LTRIM(RTRIM(Country_ADDR)) <> ''
      AND Country_ADDR NOT IN (SELECT VALUE_CODE
                                 FROM REFM_Y1
                                WHERE Table_ID = 'CTRY'
                                  AND TableSub_ID = 'CTRY')
    GROUP BY Country_ADDR

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in AHIS_Y1.Normalization_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'AHIS_Y1',
          'Normalization_CODE',
          Normalization_CODE,
          COUNT(1)
     FROM AHIS_Y1
    WHERE LTRIM(RTRIM(Normalization_CODE)) <> ''
      AND Normalization_CODE NOT IN (SELECT VALUE_CODE
                                       FROM REFM_Y1
                                      WHERE Table_ID = 'ADDR'
                                        AND TableSub_ID = 'NORM')
    GROUP BY Normalization_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in AHIS_Y1.SourceLoc_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'AHIS_Y1',
          'SourceLoc_CODE',
          SourceLoc_CODE,
          COUNT(1)
     FROM AHIS_Y1
    WHERE LTRIM(RTRIM(SourceLoc_CODE)) <> ''
      AND SourceLoc_CODE NOT IN (SELECT VALUE_CODE
                                   FROM REFM_Y1
                                  WHERE Table_ID = 'AHIS'
                                    AND TableSub_ID = 'VERS')
    GROUP BY SourceLoc_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in AHIS_Y1.SourceVerified_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'AHIS_Y1',
          'SourceVerified_CODE',
          SourceVerified_CODE,
          COUNT(1)
     FROM AHIS_Y1
    WHERE LTRIM(RTRIM(SourceVerified_CODE)) <> ''
      AND SourceVerified_CODE NOT IN (SELECT VALUE_CODE
                                        FROM REFM_Y1
                                       WHERE Table_ID = 'AHIS'
                                         AND TableSub_ID = 'VERF')
    GROUP BY SourceVerified_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in AHIS_Y1.Status_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'AHIS_Y1',
          'Status_CODE',
          Status_CODE,
          COUNT(1)
     FROM AHIS_Y1
    WHERE LTRIM(RTRIM(Status_CODE)) <> ''
      AND Status_CODE NOT IN (SELECT VALUE_CODE
                                FROM REFM_Y1
                               WHERE Table_ID = 'CONF'
                                 AND TableSub_ID = 'CON1')
    GROUP BY Status_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in ASFN_Y1.AcctType_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'ASFN_Y1',
          'AcctType_CODE',
          AcctType_CODE,
          COUNT(1)
     FROM ASFN_Y1
    WHERE LTRIM(RTRIM(AcctType_CODE)) <> ''
      AND AcctType_CODE NOT IN (SELECT VALUE_CODE
                                  FROM REFM_Y1
                                 WHERE Table_ID = 'MAST'
                                   AND TableSub_ID IN ('FIIS', 'FINA', 'FINS', 'CTYP'))
    GROUP BY AcctType_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in ASFN_Y1.JointAcct_INDC column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'ASFN_Y1',
          'JointAcct_INDC',
          JointAcct_INDC,
          COUNT(1)
     FROM ASFN_Y1
    WHERE LTRIM(RTRIM(JointAcct_INDC)) <> ''
      AND JointAcct_INDC NOT IN (SELECT VALUE_CODE
                                   FROM REFM_Y1
                                  WHERE Table_ID = 'YSNO'
                                    AND TableSub_ID = 'YSNO')
    GROUP BY JointAcct_INDC

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in ASFN_Y1.LienInitiated_INDC column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'ASFN_Y1',
          'LienInitiated_INDC',
          LienInitiated_INDC,
          COUNT(1)
     FROM ASFN_Y1
    WHERE LTRIM(RTRIM(LienInitiated_INDC)) <> ''
      AND LienInitiated_INDC NOT IN (SELECT VALUE_CODE
                                       FROM REFM_Y1
                                      WHERE Table_ID = 'YSNO'
                                        AND TableSub_ID = 'YSNO')
    GROUP BY LienInitiated_INDC

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in ASFN_Y1.LocateState_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'ASFN_Y1',
          'LocateState_CODE',
          LocateState_CODE,
          COUNT(1)
     FROM ASFN_Y1
    WHERE LTRIM(RTRIM(LocateState_CODE)) <> ''
      AND LocateState_CODE NOT IN (SELECT VALUE_CODE
                                     FROM REFM_Y1
                                    WHERE Table_ID = 'STAT'
                                      AND TableSub_ID = 'STAT')
    GROUP BY LocateState_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in BNKR_Y1.TypeBankruptcy_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'BNKR_Y1',
          'TypeBankruptcy_CODE',
          TypeBankruptcy_CODE,
          COUNT(1)
     FROM BNKR_Y1
    WHERE LTRIM(RTRIM(TypeBankruptcy_CODE)) <> ''
      AND TypeBankruptcy_CODE NOT IN (SELECT VALUE_CODE
                                        FROM REFM_Y1
                                       WHERE Table_ID = 'DEMO'
                                         AND TableSub_ID = 'BANK')
    GROUP BY TypeBankruptcy_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in CASE_Y1.ApplicationFee_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'CASE_Y1',
          'ApplicationFee_CODE',
          ApplicationFee_CODE,
          COUNT(1)
     FROM CASE_Y1
    WHERE LTRIM(RTRIM(ApplicationFee_CODE)) <> ''
      AND ApplicationFee_CODE NOT IN (SELECT VALUE_CODE
                                        FROM REFM_Y1
                                       WHERE Table_ID = 'CCRT'
                                         AND TableSub_ID = 'APFE')
    GROUP BY ApplicationFee_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in CASE_Y1.CaseCategory_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'CASE_Y1',
          'CaseCategory_CODE',
          CaseCategory_CODE,
          COUNT(1)
     FROM CASE_Y1
    WHERE LTRIM(RTRIM(CaseCategory_CODE)) <> ''
      AND CaseCategory_CODE NOT IN (SELECT VALUE_CODE
                                      FROM REFM_Y1
                                     WHERE Table_ID = 'CCRT'
                                       AND TableSub_ID = 'CCTG')
    GROUP BY CaseCategory_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in CASE_Y1.ClientLitigantRole_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'CASE_Y1',
          'ClientLitigantRole_CODE',
          ClientLitigantRole_CODE,
          COUNT(1)
     FROM CASE_Y1
    WHERE LTRIM(RTRIM(ClientLitigantRole_CODE)) <> ''
      AND ClientLitigantRole_CODE NOT IN (SELECT VALUE_CODE
                                            FROM REFM_Y1
                                           WHERE Table_ID = 'GENR'
                                             AND TableSub_ID = 'PART')
    GROUP BY ClientLitigantRole_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in CASE_Y1.GoodCause_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'CASE_Y1',
          'GoodCause_CODE',
          GoodCause_CODE,
          COUNT(1)
     FROM CASE_Y1
    WHERE LTRIM(RTRIM(GoodCause_CODE)) <> ''
      AND GoodCause_CODE NOT IN (SELECT VALUE_CODE
                                   FROM REFM_Y1
                                  WHERE Table_ID = 'CCRT'
                                    AND TableSub_ID = 'GOOD')
    GROUP BY GoodCause_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in CASE_Y1.IvdApplicant_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'CASE_Y1',
          'IvdApplicant_CODE',
          IvdApplicant_CODE,
          COUNT(1)
     FROM CASE_Y1
    WHERE LTRIM(RTRIM(IvdApplicant_CODE)) <> ''
      AND IvdApplicant_CODE NOT IN (SELECT VALUE_CODE
                                      FROM REFM_Y1
                                     WHERE Table_ID = 'CCRT'
                                       AND TableSub_ID = 'APLT')
    GROUP BY IvdApplicant_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in CASE_Y1.NonCoop_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'CASE_Y1',
          'NonCoop_CODE',
          NonCoop_CODE,
          COUNT(1)
     FROM CASE_Y1
    WHERE LTRIM(RTRIM(NonCoop_CODE)) <> ''
      AND NonCoop_CODE NOT IN (SELECT VALUE_CODE
                                 FROM REFM_Y1
                                WHERE Table_ID = 'CCRT'
                                  AND TableSub_ID = 'NCOP')
    GROUP BY NonCoop_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in CASE_Y1.Restricted_INDC column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'CASE_Y1',
          'Restricted_INDC',
          Restricted_INDC,
          COUNT(1)
     FROM CASE_Y1
    WHERE LTRIM(RTRIM(Restricted_INDC)) <> ''
      AND Restricted_INDC NOT IN (SELECT VALUE_CODE
                                    FROM REFM_Y1
                                   WHERE Table_ID = 'YSNO'
                                     AND TableSub_ID = 'YSNO')
    GROUP BY Restricted_INDC

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in CASE_Y1.RsnStatusCase_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'CASE_Y1',
          'RsnStatusCase_CODE',
          RsnStatusCase_CODE,
          COUNT(1)
     FROM CASE_Y1
    WHERE LTRIM(RTRIM(RsnStatusCase_CODE)) <> ''
      AND RsnStatusCase_CODE NOT IN (SELECT VALUE_CODE
                                       FROM REFM_Y1
                                      WHERE Table_ID = 'CPRO'
                                        AND TableSub_ID = 'REAS')
    GROUP BY RsnStatusCase_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in CASE_Y1.ServiceRequested_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'CASE_Y1',
          'ServiceRequested_CODE',
          ServiceRequested_CODE,
          COUNT(1)
     FROM CASE_Y1
    WHERE LTRIM(RTRIM(ServiceRequested_CODE)) <> ''
      AND ServiceRequested_CODE NOT IN (SELECT VALUE_CODE
                                          FROM REFM_Y1
                                         WHERE Table_ID = 'CCRT'
                                           AND TableSub_ID = 'SREQ')
    GROUP BY ServiceRequested_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in CASE_Y1.SourceRfrl_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'CASE_Y1',
          'SourceRfrl_CODE',
          SourceRfrl_CODE,
          COUNT(1)
     FROM CASE_Y1
    WHERE LTRIM(RTRIM(SourceRfrl_CODE)) <> ''
      AND SourceRfrl_CODE NOT IN (SELECT VALUE_CODE
                                    FROM REFM_Y1
                                   WHERE Table_ID = 'CCRT'
                                     AND TableSub_ID = 'REFS')
    GROUP BY SourceRfrl_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in CASE_Y1.StatusCase_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'CASE_Y1',
          'StatusCase_CODE',
          StatusCase_CODE,
          COUNT(1)
     FROM CASE_Y1
    WHERE LTRIM(RTRIM(StatusCase_CODE)) <> ''
      AND StatusCase_CODE NOT IN (SELECT VALUE_CODE
                                    FROM REFM_Y1
                                   WHERE Table_ID = 'CSTS'
                                     AND TableSub_ID = 'CSTS')
    GROUP BY StatusCase_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in CASE_Y1.StatusEnforce_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'CASE_Y1',
          'StatusEnforce_CODE',
          StatusEnforce_CODE,
          COUNT(1)
     FROM CASE_Y1
    WHERE LTRIM(RTRIM(StatusEnforce_CODE)) <> ''
      AND StatusEnforce_CODE NOT IN (SELECT VALUE_CODE
                                       FROM REFM_Y1
                                      WHERE Table_ID = 'CCRT'
                                        AND TableSub_ID = 'ENST')
    GROUP BY StatusEnforce_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in CASE_Y1.TypeCase_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'CASE_Y1',
          'TypeCase_CODE',
          TypeCase_CODE,
          COUNT(1)
     FROM CASE_Y1
    WHERE LTRIM(RTRIM(TypeCase_CODE)) <> ''
      AND TypeCase_CODE NOT IN (SELECT VALUE_CODE
                                  FROM REFM_Y1
                                 WHERE Table_ID = 'CCRT'
                                   AND TableSub_ID = 'CTYP')
    GROUP BY TypeCase_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in CMEM_Y1.CaseMemberStatus_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'CMEM_Y1',
          'CaseMemberStatus_CODE',
          CaseMemberStatus_CODE,
          COUNT(1)
     FROM CMEM_Y1
    WHERE LTRIM(RTRIM(CaseMemberStatus_CODE)) <> ''
      AND CaseMemberStatus_CODE NOT IN (SELECT VALUE_CODE
                                          FROM REFM_Y1
                                         WHERE Table_ID = 'GENR'
                                           AND TableSub_ID = 'MEMS')
    GROUP BY CaseMemberStatus_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in CMEM_Y1.CaseRelationship_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'CMEM_Y1',
          'CaseRelationship_CODE',
          CaseRelationship_CODE,
          COUNT(1)
     FROM CMEM_Y1
    WHERE LTRIM(RTRIM(CaseRelationship_CODE)) <> ''
      AND CaseRelationship_CODE NOT IN (SELECT VALUE_CODE
                                          FROM REFM_Y1
                                         WHERE Table_ID = 'RELA'
                                           AND TableSub_ID = 'CASE')
    GROUP BY CaseRelationship_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in CMEM_Y1.CpRelationshipToChild_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'CMEM_Y1',
          'CpRelationshipToChild_CODE',
          CpRelationshipToChild_CODE,
          COUNT(1)
     FROM CMEM_Y1
    WHERE LTRIM(RTRIM(CpRelationshipToChild_CODE)) <> ''
      AND CpRelationshipToChild_CODE NOT IN (SELECT VALUE_CODE
                                               FROM REFM_Y1
                                              WHERE Table_ID = 'FMLY'
                                                AND TableSub_ID = 'RELA')
    GROUP BY CpRelationshipToChild_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in CMEM_Y1.FamilyViolence_INDC column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'CMEM_Y1',
          'FamilyViolence_INDC',
          FamilyViolence_INDC,
          COUNT(1)
     FROM CMEM_Y1
    WHERE LTRIM(RTRIM(FamilyViolence_INDC)) <> ''
      AND FamilyViolence_INDC NOT IN (SELECT VALUE_CODE
                                        FROM REFM_Y1
                                       WHERE Table_ID = 'YSNO'
                                         AND TableSub_ID = 'YSNO')
    GROUP BY FamilyViolence_INDC

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in CMEM_Y1.NcpRelationshipToChild_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'CMEM_Y1',
          'NcpRelationshipToChild_CODE',
          NcpRelationshipToChild_CODE,
          COUNT(1)
     FROM CMEM_Y1
    WHERE LTRIM(RTRIM(NcpRelationshipToChild_CODE)) <> ''
      AND NcpRelationshipToChild_CODE NOT IN (SELECT VALUE_CODE
                                                FROM REFM_Y1
                                               WHERE Table_ID = 'FMLY'
                                                 AND TableSub_ID = 'RELA')
    GROUP BY NcpRelationshipToChild_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in CMEM_Y1.ReasonMemberStatus_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'CMEM_Y1',
          'ReasonMemberStatus_CODE',
          ReasonMemberStatus_CODE,
          COUNT(1)
     FROM CMEM_Y1
    WHERE LTRIM(RTRIM(ReasonMemberStatus_CODE)) <> ''
      AND ReasonMemberStatus_CODE NOT IN (SELECT VALUE_CODE
                                            FROM REFM_Y1
                                           WHERE Table_ID = 'GENR'
                                             AND TableSub_ID = 'MSTR')
    GROUP BY ReasonMemberStatus_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in COMP_Y1.ComplianceStatus_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'COMP_Y1',
          'ComplianceStatus_CODE',
          ComplianceStatus_CODE,
          COUNT(1)
     FROM COMP_Y1
    WHERE LTRIM(RTRIM(ComplianceStatus_CODE)) <> ''
      AND ComplianceStatus_CODE NOT IN (SELECT VALUE_CODE
                                          FROM REFM_Y1
                                         WHERE Table_ID = 'COMP'
                                           AND TableSub_ID = 'STAT')
    GROUP BY ComplianceStatus_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in COMP_Y1.ComplianceType_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'COMP_Y1',
          'ComplianceType_CODE',
          ComplianceType_CODE,
          COUNT(1)
     FROM COMP_Y1
    WHERE LTRIM(RTRIM(ComplianceType_CODE)) <> ''
      AND ComplianceType_CODE NOT IN (SELECT VALUE_CODE
                                        FROM REFM_Y1
                                       WHERE Table_ID = 'COMP'
                                         AND TableSub_ID = 'TYPE')
    GROUP BY ComplianceType_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in COMP_Y1.Freq_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'COMP_Y1',
          'Freq_CODE',
          Freq_CODE,
          COUNT(1)
     FROM COMP_Y1
    WHERE LTRIM(RTRIM(Freq_CODE)) <> ''
      AND Freq_CODE NOT IN (SELECT VALUE_CODE
                              FROM REFM_Y1
                             WHERE Table_ID = 'COMP'
                               AND TableSub_ID = 'FRQY')
      AND @Ad_Conversion_DATE BETWEEN Effective_DATE AND End_DATE
    GROUP BY Freq_CODE
	HAVING COUNT(1) > 10;

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in COMP_Y1.OrderedParty_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'COMP_Y1',
          'OrderedParty_CODE',
          OrderedParty_CODE,
          COUNT(1)
     FROM COMP_Y1
    WHERE LTRIM(RTRIM(OrderedParty_CODE)) <> ''
      AND OrderedParty_CODE NOT IN (SELECT VALUE_CODE
                                      FROM REFM_Y1
                                     WHERE Table_ID = 'COMP'
                                       AND TableSub_ID = 'ODPT')
    GROUP BY OrderedParty_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in DCKT_Y1.Commissioner_ID column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'DCKT_Y1',
          'Commissioner_ID',
          Commissioner_ID,
          COUNT(1)
     FROM DCKT_Y1
    WHERE LTRIM(RTRIM(Commissioner_ID)) <> ''
      AND Commissioner_ID NOT IN (SELECT VALUE_CODE
                                    FROM REFM_Y1
                                   WHERE Table_ID = 'FMIS'
                                     AND TableSub_ID = 'COMM')
    GROUP BY Commissioner_ID

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in DCKT_Y1.Judge_ID column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'DCKT_Y1',
          'Judge_ID',
          Judge_ID,
          COUNT(1)
     FROM DCKT_Y1
    WHERE LTRIM(RTRIM(Judge_ID)) <> ''
      AND Judge_ID NOT IN (SELECT VALUE_CODE
                             FROM REFM_Y1
                            WHERE Table_ID = 'FMIS'
                              AND TableSub_ID = 'JDGE')
    GROUP BY Judge_ID

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in DCRS_Y1.Reason_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'DCRS_Y1',
          'Reason_CODE',
          Reason_CODE,
          COUNT(1)
     FROM DCRS_Y1
    WHERE LTRIM(RTRIM(Reason_CODE)) <> ''
      AND Reason_CODE NOT IN (SELECT VALUE_CODE
                                FROM REFM_Y1
                               WHERE Table_ID = 'DCST'
                                 AND TableSub_ID = 'DCRS')
    GROUP BY Reason_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in DCRS_Y1.Status_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'DCRS_Y1',
          'Status_CODE',
          Status_CODE,
          COUNT(1)
     FROM DCRS_Y1
    WHERE LTRIM(RTRIM(Status_CODE)) <> ''
      AND Status_CODE NOT IN (SELECT VALUE_CODE
                                FROM REFM_Y1
                               WHERE Table_ID = 'DCST'
                                 AND TableSub_ID = 'DCST')
    GROUP BY Status_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in DEMO_Y1.BirthCountry_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'DEMO_Y1',
          'BirthCountry_CODE',
          BirthCountry_CODE,
          COUNT(1)
     FROM DEMO_Y1
    WHERE LTRIM(RTRIM(BirthCountry_CODE)) <> ''
      AND BirthCountry_CODE NOT IN (SELECT VALUE_CODE
                                      FROM REFM_Y1
                                     WHERE Table_ID = 'CTRY'
                                       AND TableSub_ID = 'CTRY')
    GROUP BY BirthCountry_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in DEMO_Y1.ColorEyes_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'DEMO_Y1',
          'ColorEyes_CODE',
          ColorEyes_CODE,
          COUNT(1)
     FROM DEMO_Y1
    WHERE LTRIM(RTRIM(ColorEyes_CODE)) <> ''
      AND ColorEyes_CODE NOT IN (SELECT VALUE_CODE
                                   FROM REFM_Y1
                                  WHERE Table_ID = 'DEMO'
                                    AND TableSub_ID = 'EYEC')
    GROUP BY ColorEyes_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in DEMO_Y1.ColorHair_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'DEMO_Y1',
          'ColorHair_CODE',
          ColorHair_CODE,
          COUNT(1)
     FROM DEMO_Y1
    WHERE LTRIM(RTRIM(ColorHair_CODE)) <> ''
      AND ColorHair_CODE NOT IN (SELECT VALUE_CODE
                                   FROM REFM_Y1
                                  WHERE Table_ID = 'DEMO'
                                    AND TableSub_ID = 'HAIR')
    GROUP BY ColorHair_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in DEMO_Y1.CountyBirth_IDNO column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'DEMO_Y1',
          'CountyBirth_IDNO',
          CountyBirth_IDNO,
          COUNT(1)
     FROM DEMO_Y1
    WHERE LTRIM(RTRIM(CountyBirth_IDNO)) <> '0'
      AND CountyBirth_IDNO NOT IN (SELECT VALUE_CODE
                                     FROM REFM_Y1
                                    WHERE Table_ID = 'DEMO'
                                      AND TableSub_ID = 'BICO')
    GROUP BY CountyBirth_IDNO

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in DEMO_Y1.Divorce_INDC column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'DEMO_Y1',
          'Divorce_INDC',
          Divorce_INDC,
          COUNT(1)
     FROM DEMO_Y1
    WHERE LTRIM(RTRIM(Divorce_INDC)) <> ''
      AND Divorce_INDC NOT IN (SELECT VALUE_CODE
                                 FROM REFM_Y1
                                WHERE Table_ID = 'YSNO'
                                  AND TableSub_ID = 'YSNO')
    GROUP BY Divorce_INDC

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in DEMO_Y1.EducationLevel_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'DEMO_Y1',
          'EducationLevel_CODE',
          EducationLevel_CODE,
          COUNT(1)
     FROM DEMO_Y1
    WHERE LTRIM(RTRIM(EducationLevel_CODE)) <> ''
      AND EducationLevel_CODE NOT IN (SELECT VALUE_CODE
                                        FROM REFM_Y1
                                       WHERE Table_ID = 'DEMO'
                                         AND TableSub_ID = 'EDUC')
    GROUP BY EducationLevel_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in DEMO_Y1.FacialHair_INDC column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'DEMO_Y1',
          'FacialHair_INDC',
          FacialHair_INDC,
          COUNT(1)
     FROM DEMO_Y1
    WHERE LTRIM(RTRIM(FacialHair_INDC)) <> ''
      AND FacialHair_INDC NOT IN (SELECT VALUE_CODE
                                    FROM REFM_Y1
                                   WHERE Table_ID = 'YSNO'
                                     AND TableSub_ID = 'YSNO')
    GROUP BY FacialHair_INDC

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in DEMO_Y1.Language_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'DEMO_Y1',
          'Language_CODE',
          Language_CODE,
          COUNT(1)
     FROM DEMO_Y1
    WHERE LTRIM(RTRIM(Language_CODE)) <> ''
      AND Language_CODE NOT IN (SELECT VALUE_CODE
                                  FROM REFM_Y1
                                 WHERE Table_ID = 'GENR'
                                   AND TableSub_ID = 'LANG')
    GROUP BY Language_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in DEMO_Y1.MilitaryBenefitStatus_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'DEMO_Y1',
          'MilitaryBenefitStatus_CODE',
          MilitaryBenefitStatus_CODE,
          COUNT(1)
     FROM DEMO_Y1
    WHERE LTRIM(RTRIM(MilitaryBenefitStatus_CODE)) <> ''
      AND MilitaryBenefitStatus_CODE NOT IN (SELECT VALUE_CODE
                                               FROM REFM_Y1
                                              WHERE Table_ID = 'DEMO'
                                                AND TableSub_ID = 'BENS')
    GROUP BY MilitaryBenefitStatus_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in DEMO_Y1.MilitaryBranch_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'DEMO_Y1',
          'MilitaryBranch_CODE',
          MilitaryBranch_CODE,
          COUNT(1)
     FROM DEMO_Y1
    WHERE LTRIM(RTRIM(MilitaryBranch_CODE)) <> ''
      AND MilitaryBranch_CODE NOT IN (SELECT VALUE_CODE
                                        FROM REFM_Y1
                                       WHERE Table_ID = 'GENR'
                                         AND TableSub_ID = 'MILT')
    GROUP BY MilitaryBranch_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in DEMO_Y1.MilitaryStatus_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'DEMO_Y1',
          'MilitaryStatus_CODE',
          MilitaryStatus_CODE,
          COUNT(1)
     FROM DEMO_Y1
    WHERE LTRIM(RTRIM(MilitaryStatus_CODE)) <> ''
      AND MilitaryStatus_CODE NOT IN (SELECT VALUE_CODE
                                        FROM REFM_Y1
                                       WHERE Table_ID = 'GENR'
                                         AND TableSub_ID = 'MILS')
    GROUP BY MilitaryStatus_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in DEMO_Y1.Race_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'DEMO_Y1',
          'Race_CODE',
          Race_CODE,
          COUNT(1)
     FROM DEMO_Y1
    WHERE LTRIM(RTRIM(Race_CODE)) <> ''
      AND Race_CODE NOT IN (SELECT VALUE_CODE
                              FROM REFM_Y1
                             WHERE Table_ID = 'GENR'
                               AND TableSub_ID = 'RACE')
    GROUP BY Race_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in DEMO_Y1.Restricted_INDC column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'DEMO_Y1',
          'Restricted_INDC',
          Restricted_INDC,
          COUNT(1)
     FROM DEMO_Y1
    WHERE LTRIM(RTRIM(Restricted_INDC)) <> ''
      AND Restricted_INDC NOT IN (SELECT VALUE_CODE
                                    FROM REFM_Y1
                                   WHERE Table_ID = 'YSNO'
                                     AND TableSub_ID = 'YSNO')
    GROUP BY Restricted_INDC

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in DEMO_Y1.Suffix_NAME column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'DEMO_Y1',
          'Suffix_NAME',
          Suffix_NAME,
          COUNT(1)
     FROM DEMO_Y1
    WHERE LTRIM(RTRIM(Suffix_NAME)) <> ''
      AND Suffix_NAME NOT IN (SELECT VALUE_CODE
                                FROM REFM_Y1
                               WHERE Table_ID = 'DEMO'
                                 AND TableSub_ID = 'SUFX')
    GROUP BY Suffix_NAME

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in DEMO_Y1.Title_NAME column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'DEMO_Y1',
          'Title_NAME',
          Title_NAME,
          COUNT(1)
     FROM DEMO_Y1
    WHERE LTRIM(RTRIM(Title_NAME)) <> ''
      AND Title_NAME NOT IN (SELECT VALUE_CODE
                               FROM REFM_Y1
                              WHERE Table_ID = 'GENR'
                                AND TableSub_ID = 'TITL')
    GROUP BY Title_NAME

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in DEMO_Y1.TribalAffiliations_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'DEMO_Y1',
          'TribalAffiliations_CODE',
          TribalAffiliations_CODE,
          COUNT(1)
     FROM DEMO_Y1
    WHERE LTRIM(RTRIM(TribalAffiliations_CODE)) <> ''
      AND TribalAffiliations_CODE NOT IN (SELECT VALUE_CODE
                                            FROM REFM_Y1
                                           WHERE Table_ID = 'CSNT'
                                             AND TableSub_ID = 'TRIB')
    GROUP BY TribalAffiliations_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in DEMO_Y1.TypeOccupation_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'DEMO_Y1',
          'TypeOccupation_CODE',
          TypeOccupation_CODE,
          COUNT(1)
     FROM DEMO_Y1
    WHERE LTRIM(RTRIM(TypeOccupation_CODE)) <> ''
      AND TypeOccupation_CODE NOT IN (SELECT VALUE_CODE
                                        FROM REFM_Y1
                                       WHERE Table_ID = 'DEMO'
                                         AND TableSub_ID = 'OCCT')
    GROUP BY TypeOccupation_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in DEMO_Y1.TypeProblem_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'DEMO_Y1',
          'TypeProblem_CODE',
          TypeProblem_CODE,
          COUNT(1)
     FROM DEMO_Y1
    WHERE LTRIM(RTRIM(TypeProblem_CODE)) <> ''
      AND TypeProblem_CODE NOT IN (SELECT VALUE_CODE
                                     FROM REFM_Y1
                                    WHERE Table_ID = 'HIPA'
                                      AND TableSub_ID = 'REGS')
    GROUP BY TypeProblem_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in DHLD_Y1.CheckRecipient_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'DHLD_Y1',
          'CheckRecipient_CODE',
          CheckRecipient_CODE,
          COUNT(1)
     FROM DHLD_Y1
    WHERE LTRIM(RTRIM(CheckRecipient_CODE)) <> ''
      AND CheckRecipient_CODE NOT IN (SELECT VALUE_CODE
                                        FROM REFM_Y1
                                       WHERE Table_ID = 'GENR'
                                         AND TableSub_ID = 'FUND')
    GROUP BY CheckRecipient_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in DHLD_Y1.TypeDisburse_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'DHLD_Y1',
          'TypeDisburse_CODE',
          TypeDisburse_CODE,
          COUNT(1)
     FROM DHLD_Y1
    WHERE LTRIM(RTRIM(TypeDisburse_CODE)) <> ''
      AND TypeDisburse_CODE NOT IN (SELECT VALUE_CODE
                                      FROM REFM_Y1
                                     WHERE Table_ID = 'DISB'
                                       AND TableSub_ID = 'PREV')
    GROUP BY TypeDisburse_CODE

   -- Note:Added "AND (SourceHold_CODE <> 'DH')" condition in DISH_Y1.SourceHold_CODE 
   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in DISH_Y1.SourceHold_CODE  column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'DISH_Y1',
          'SourceHold_CODE ',
          SourceHold_CODE,
          COUNT(1)
     FROM DISH_Y1
    WHERE LTRIM(RTRIM(SourceHold_CODE)) <> ''
      AND ((SourceHold_CODE NOT IN (SELECT VALUE_CODE
                                      FROM REFM_Y1
                                     WHERE Table_ID = 'RCTS'
                                       AND TableSub_ID = 'RCTS'))
           AND (SourceHold_CODE <> 'DH'))
    GROUP BY SourceHold_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in DMJR_Y1.Status_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'DMJR_Y1',
          'Status_CODE',
          Status_CODE,
          COUNT(1)
     FROM DMJR_Y1
    WHERE LTRIM(RTRIM(Status_CODE)) <> ''
      AND Status_CODE NOT IN (SELECT VALUE_CODE
                                FROM REFM_Y1
                               WHERE Table_ID = 'ENST'
                                 AND TableSub_ID = 'REST')
    GROUP BY Status_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in DMJR_Y1.Subsystem_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'DMJR_Y1',
          'Subsystem_CODE',
          Subsystem_CODE,
          COUNT(1)
     FROM DMJR_Y1
    WHERE LTRIM(RTRIM(Subsystem_CODE)) <> ''
      AND Subsystem_CODE NOT IN (SELECT VALUE_CODE
                                   FROM REFM_Y1
                                  WHERE Table_ID = 'CPRO'
                                    AND TableSub_ID = 'CATG')
    GROUP BY Subsystem_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in DMNR_Y1.ReasonStatus_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'DMNR_Y1',
          'ReasonStatus_CODE',
          ReasonStatus_CODE,
          COUNT(1)
     FROM DMNR_Y1
    WHERE LTRIM(RTRIM(ReasonStatus_CODE)) <> ''
      AND ReasonStatus_CODE NOT IN (SELECT VALUE_CODE
                                      FROM REFM_Y1
                                     WHERE Table_ID = 'CPRO'
                                       AND TableSub_ID = 'REAS')
    GROUP BY ReasonStatus_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in DMNR_Y1.Subsystem_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'DMNR_Y1',
          'Subsystem_CODE',
          Subsystem_CODE,
          COUNT(1)
     FROM DMNR_Y1
    WHERE LTRIM(RTRIM(Subsystem_CODE)) <> ''
      AND Subsystem_CODE NOT IN (SELECT VALUE_CODE
                                   FROM REFM_Y1
                                  WHERE Table_ID = 'CPRO'
                                    AND TableSub_ID = 'CATG')
    GROUP BY Subsystem_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in DPRS_Y1.TypePerson_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'DPRS_Y1',
          'TypePerson_CODE',
          TypePerson_CODE,
          COUNT(1)
     FROM DPRS_Y1
    WHERE LTRIM(RTRIM(TypePerson_CODE)) <> ''
      AND TypePerson_CODE NOT IN (SELECT VALUE_CODE
                                    FROM REFM_Y1
                                   WHERE Table_ID = 'DPRS'
                                     AND TableSub_ID = 'ROLE')
    GROUP BY TypePerson_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in DSBH_Y1.CheckRecipient_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'DSBH_Y1',
          'CheckRecipient_CODE',
          CheckRecipient_CODE,
          COUNT(1)
     FROM DSBH_Y1
    WHERE LTRIM(RTRIM(CheckRecipient_CODE)) <> ''
      AND CheckRecipient_CODE NOT IN (SELECT VALUE_CODE
                                        FROM REFM_Y1
                                       WHERE Table_ID = 'GENR'
                                         AND TableSub_ID = 'FUND')
    GROUP BY CheckRecipient_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in DSBH_Y1.ReasonStatus_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'DSBH_Y1',
          'ReasonStatus_CODE',
          ReasonStatus_CODE,
          COUNT(1)
     FROM DSBH_Y1
    WHERE LTRIM(RTRIM(ReasonStatus_CODE)) <> ''
      AND ReasonStatus_CODE NOT IN (SELECT VALUE_CODE
                                      FROM REFM_Y1
                                     WHERE Table_ID = 'VOID'
                                       AND TableSub_ID = 'REAS')
    GROUP BY ReasonStatus_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in DSBL_Y1.TypeDisburse_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'DSBL_Y1',
          'TypeDisburse_CODE',
          TypeDisburse_CODE,
          COUNT(1)
     FROM DSBL_Y1
    WHERE LTRIM(RTRIM(TypeDisburse_CODE)) <> ''
      AND TypeDisburse_CODE NOT IN (SELECT VALUE_CODE
                                      FROM REFM_Y1
                                     WHERE Table_ID = 'DISB'
                                       AND TableSub_ID = 'PREV')
    GROUP BY TypeDisburse_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in EFTR_Y1.RoutingBank_NUMB column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'EFTR_Y1',
          'RoutingBank_NUMB',
          RoutingBank_NUMB,
          COUNT(1)
     FROM EFTR_Y1
    WHERE LTRIM(RTRIM(RoutingBank_NUMB)) <> ''
      AND RoutingBank_NUMB NOT IN (SELECT VALUE_CODE
                                     FROM REFM_Y1
                                    WHERE Table_ID = 'EFTI'
                                      AND TableSub_ID = 'RONO')
    GROUP BY RoutingBank_NUMB

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in EFTR_Y1.StatusEft_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'EFTR_Y1',
          'StatusEft_CODE',
          StatusEft_CODE,
          COUNT(1)
     FROM EFTR_Y1
    WHERE LTRIM(RTRIM(StatusEft_CODE)) <> ''
      AND StatusEft_CODE NOT IN (SELECT VALUE_CODE
                                   FROM REFM_Y1
                                  WHERE Table_ID = 'EFTR'
                                    AND TableSub_ID = 'EFTS')
    GROUP BY StatusEft_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in EFTR_Y1.TypeAccount_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'EFTR_Y1',
          'TypeAccount_CODE',
          TypeAccount_CODE,
          COUNT(1)
     FROM EFTR_Y1
    WHERE LTRIM(RTRIM(TypeAccount_CODE)) <> ''
      AND TypeAccount_CODE NOT IN (SELECT VALUE_CODE
                                     FROM REFM_Y1
                                    WHERE Table_ID = 'EFTR'
                                      AND TableSub_ID = 'TYAC')
    GROUP BY TypeAccount_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in EHIS_Y1.EmployerPrime_INDC column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'EHIS_Y1',
          'EmployerPrime_INDC',
          EmployerPrime_INDC,
          COUNT(1)
     FROM EHIS_Y1
    WHERE LTRIM(RTRIM(EmployerPrime_INDC)) <> ''
      AND EmployerPrime_INDC NOT IN (SELECT VALUE_CODE
                                       FROM REFM_Y1
                                      WHERE Table_ID = 'YSNO'
                                        AND TableSub_ID = 'YSNO')
    GROUP BY EmployerPrime_INDC

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in EHIS_Y1.FreqIncome_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'EHIS_Y1',
          'FreqIncome_CODE',
          FreqIncome_CODE,
          COUNT(1)
     FROM EHIS_Y1
    WHERE LTRIM(RTRIM(FreqIncome_CODE)) <> ''
      AND FreqIncome_CODE NOT IN (SELECT VALUE_CODE
                                    FROM REFM_Y1
                                   WHERE Table_ID = 'EHIS'
                                     AND TableSub_ID = 'WAGE')
    GROUP BY FreqIncome_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in EHIS_Y1.FreqInsurance_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'EHIS_Y1',
          'FreqInsurance_CODE',
          FreqInsurance_CODE,
          COUNT(1)
     FROM EHIS_Y1
    WHERE LTRIM(RTRIM(FreqInsurance_CODE)) <> ''
      AND FreqInsurance_CODE NOT IN (SELECT VALUE_CODE
                                       FROM REFM_Y1
                                      WHERE Table_ID = 'FRQA'
                                        AND TableSub_ID = 'FRQ3')
    GROUP BY FreqInsurance_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in EHIS_Y1.FreqPay_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'EHIS_Y1',
          'FreqPay_CODE',
          FreqPay_CODE,
          COUNT(1)
     FROM EHIS_Y1
    WHERE LTRIM(RTRIM(FreqPay_CODE)) <> ''
      AND FreqPay_CODE NOT IN (SELECT VALUE_CODE
                                 FROM REFM_Y1
                                WHERE Table_ID = 'FRQA'
                                  AND TableSub_ID = 'FRQ3')
    GROUP BY FreqPay_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in EHIS_Y1.LimitCcpa_INDC column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'EHIS_Y1',
          'LimitCcpa_INDC',
          LimitCcpa_INDC,
          COUNT(1)
     FROM EHIS_Y1
    WHERE LTRIM(RTRIM(LimitCcpa_INDC)) <> ''
      AND LimitCcpa_INDC NOT IN (SELECT VALUE_CODE
                                   FROM REFM_Y1
                                  WHERE Table_ID = 'YSNO'
                                    AND TableSub_ID = 'YSNO')
    GROUP BY LimitCcpa_INDC

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in EHIS_Y1.SourceLoc_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'EHIS_Y1',
          'SourceLoc_CODE',
          SourceLoc_CODE,
          COUNT(1)
     FROM EHIS_Y1
    WHERE LTRIM(RTRIM(SourceLoc_CODE)) <> ''
      AND SourceLoc_CODE NOT IN (SELECT VALUE_CODE
                                   FROM REFM_Y1
                                  WHERE Table_ID = 'EHIS'
                                    AND TableSub_ID = 'SRCE')
    GROUP BY SourceLoc_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in EHIS_Y1.SourceLocConf_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'EHIS_Y1',
          'SourceLocConf_CODE',
          SourceLocConf_CODE,
          COUNT(1)
     FROM EHIS_Y1
    WHERE LTRIM(RTRIM(SourceLocConf_CODE)) <> ''
      AND SourceLocConf_CODE NOT IN (SELECT VALUE_CODE
                                       FROM REFM_Y1
                                      WHERE Table_ID = 'EHIS'
                                        AND TableSub_ID = 'VERF')
    GROUP BY SourceLocConf_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in EHIS_Y1.Status_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'EHIS_Y1',
          'Status_CODE',
          Status_CODE,
          COUNT(1)
     FROM EHIS_Y1
    WHERE LTRIM(RTRIM(Status_CODE)) <> ''
      AND Status_CODE NOT IN (SELECT VALUE_CODE
                                FROM REFM_Y1
                               WHERE Table_ID = 'CONF'
                                 AND TableSub_ID = 'CONF')
    GROUP BY Status_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in EHIS_Y1.TypeIncome_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'EHIS_Y1',
          'TypeIncome_CODE',
          TypeIncome_CODE,
          COUNT(1)
     FROM EHIS_Y1
    WHERE LTRIM(RTRIM(TypeIncome_CODE)) <> ''
      AND TypeIncome_CODE NOT IN (SELECT VALUE_CODE
                                    FROM REFM_Y1
                                   WHERE Table_ID = 'EHIS'
                                     AND TableSub_ID = 'SOIT')
    GROUP BY TypeIncome_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in FDEM_Y1.ApprovedBy_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'FDEM_Y1',
          'ApprovedBy_CODE',
          ApprovedBy_CODE,
          COUNT(1)
     FROM FDEM_Y1
    WHERE LTRIM(RTRIM(ApprovedBy_CODE)) <> ''
      AND ApprovedBy_CODE NOT IN (SELECT VALUE_CODE
                                    FROM REFM_Y1
                                   WHERE Table_ID = 'FMIS'
                                     AND TableSub_ID = 'APBY')
    GROUP BY ApprovedBy_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in FDEM_Y1.DocReference_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'FDEM_Y1',
          'DocReference_CODE',
          DocReference_CODE,
          COUNT(1)
     FROM FDEM_Y1
    WHERE LTRIM(RTRIM(DocReference_CODE)) <> ''
      AND DocReference_CODE NOT IN (SELECT VALUE_CODE
                                      FROM REFM_Y1
                                     WHERE Table_ID = 'FMIS'
                                       AND TableSub_ID = 'FDOC')
    GROUP BY DocReference_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in FDEM_Y1.SourceDoc_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'FDEM_Y1',
          'SourceDoc_CODE',
          SourceDoc_CODE,
          COUNT(1)
     FROM FDEM_Y1
    WHERE LTRIM(RTRIM(SourceDoc_CODE)) <> ''
      AND SourceDoc_CODE NOT IN (SELECT VALUE_CODE
                                   FROM REFM_Y1
                                  WHERE Table_ID = 'FMIS'
                                    AND TableSub_ID = 'DSRC')
    GROUP BY SourceDoc_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in FDEM_Y1.TypeDoc_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'FDEM_Y1',
          'TypeDoc_CODE',
          TypeDoc_CODE,
          COUNT(1)
     FROM FDEM_Y1
    WHERE LTRIM(RTRIM(TypeDoc_CODE)) <> ''
      AND TypeDoc_CODE NOT IN (SELECT VALUE_CODE
                                 FROM REFM_Y1
                                WHERE Table_ID = 'FMIS'
                                  AND TableSub_ID = 'DTYP')
    GROUP BY TypeDoc_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in FEDH_Y1.ExcludeFin_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'FEDH_Y1',
          'ExcludeFin_CODE',
          ExcludeFin_CODE,
          COUNT(1)
     FROM FEDH_Y1
    WHERE LTRIM(RTRIM(ExcludeFin_CODE)) <> ''
      AND ExcludeFin_CODE NOT IN (SELECT VALUE_CODE
                                    FROM REFM_Y1
                                   WHERE Table_ID = 'TAXI'
                                     AND TableSub_ID = 'EXEM')
    GROUP BY ExcludeFin_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in FEDH_Y1.ExcludeIns_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'FEDH_Y1',
          'ExcludeIns_CODE',
          ExcludeIns_CODE,
          COUNT(1)
     FROM FEDH_Y1
    WHERE LTRIM(RTRIM(ExcludeIns_CODE)) <> ''
      AND ExcludeIns_CODE NOT IN (SELECT VALUE_CODE
                                    FROM REFM_Y1
                                   WHERE Table_ID = 'TAXI'
                                     AND TableSub_ID = 'EXEM')
    GROUP BY ExcludeIns_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in FEDH_Y1.ExcludeIrs_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'FEDH_Y1',
          'ExcludeIrs_CODE',
          ExcludeIrs_CODE,
          COUNT(1)
     FROM FEDH_Y1
    WHERE LTRIM(RTRIM(ExcludeIrs_CODE)) <> ''
      AND ExcludeIrs_CODE NOT IN (SELECT VALUE_CODE
                                    FROM REFM_Y1
                                   WHERE Table_ID = 'TAXI'
                                     AND TableSub_ID = 'EXEM')
    GROUP BY ExcludeIrs_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in FEDH_Y1.ExcludePas_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'FEDH_Y1',
          'ExcludePas_CODE',
          ExcludePas_CODE,
          COUNT(1)
     FROM FEDH_Y1
    WHERE LTRIM(RTRIM(ExcludePas_CODE)) <> ''
      AND ExcludePas_CODE NOT IN (SELECT VALUE_CODE
                                    FROM REFM_Y1
                                   WHERE Table_ID = 'TAXI'
                                     AND TableSub_ID = 'EXEM')
    GROUP BY ExcludePas_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in FEDH_Y1.ExcludeRet_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'FEDH_Y1',
          'ExcludeRet_CODE',
          ExcludeRet_CODE,
          COUNT(1)
     FROM FEDH_Y1
    WHERE LTRIM(RTRIM(ExcludeRet_CODE)) <> ''
      AND ExcludeRet_CODE NOT IN (SELECT VALUE_CODE
                                    FROM REFM_Y1
                                   WHERE Table_ID = 'TAXI'
                                     AND TableSub_ID = 'EXEM')
    GROUP BY ExcludeRet_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in FEDH_Y1.ExcludeSal_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'FEDH_Y1',
          'ExcludeSal_CODE',
          ExcludeSal_CODE,
          COUNT(1)
     FROM FEDH_Y1
    WHERE LTRIM(RTRIM(ExcludeSal_CODE)) <> ''
      AND ExcludeSal_CODE NOT IN (SELECT VALUE_CODE
                                    FROM REFM_Y1
                                   WHERE Table_ID = 'TAXI'
                                     AND TableSub_ID = 'EXEM')
    GROUP BY ExcludeSal_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in FEDH_Y1.TypeTransaction_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'FEDH_Y1',
          'TypeTransaction_CODE',
          TypeTransaction_CODE,
          COUNT(1)
     FROM FEDH_Y1
    WHERE LTRIM(RTRIM(TypeTransaction_CODE)) <> ''
      AND TypeTransaction_CODE NOT IN (SELECT VALUE_CODE
                                         FROM REFM_Y1
                                        WHERE Table_ID = 'TAXI'
                                          AND TableSub_ID = 'TRAN')
    GROUP BY TypeTransaction_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in FSRT_Y1.ServiceCountry_ADDR column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'FSRT_Y1',
          'ServiceCountry_ADDR',
          ServiceCountry_ADDR,
          COUNT(1)
     FROM FSRT_Y1
    WHERE LTRIM(RTRIM(ServiceCountry_ADDR)) <> ''
      AND ServiceCountry_ADDR NOT IN (SELECT VALUE_CODE
                                        FROM REFM_Y1
                                       WHERE Table_ID = 'CTRY'
                                         AND TableSub_ID = 'CTRY')
    GROUP BY ServiceCountry_ADDR

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in FSRT_Y1.ServiceFailureReason_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'FSRT_Y1',
          'ServiceFailureReason_CODE',
          ServiceFailureReason_CODE,
          COUNT(1)
     FROM FSRT_Y1
    WHERE LTRIM(RTRIM(ServiceFailureReason_CODE)) <> ''
      AND ServiceFailureReason_CODE NOT IN (SELECT VALUE_CODE
                                              FROM REFM_Y1
                                             WHERE Table_ID = 'FMIS'
                                               AND TableSub_ID = 'SRFF')
    GROUP BY ServiceFailureReason_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in FSRT_Y1.ServiceMethod_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'FSRT_Y1',
          'ServiceMethod_CODE',
          ServiceMethod_CODE,
          COUNT(1)
     FROM FSRT_Y1
    WHERE LTRIM(RTRIM(ServiceMethod_CODE)) <> ''
      AND ServiceMethod_CODE NOT IN (SELECT VALUE_CODE
                                       FROM REFM_Y1
                                      WHERE Table_ID = 'FMIS'
                                        AND TableSub_ID = 'SEME')
    GROUP BY ServiceMethod_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in FSRT_Y1.ServiceResult_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'FSRT_Y1',
          'ServiceResult_CODE',
          ServiceResult_CODE,
          COUNT(1)
     FROM FSRT_Y1
    WHERE LTRIM(RTRIM(ServiceResult_CODE)) <> ''
      AND ServiceResult_CODE NOT IN (SELECT VALUE_CODE
                                       FROM REFM_Y1
                                      WHERE Table_ID = 'FMIS'
                                        AND TableSub_ID = 'SERE')
    GROUP BY ServiceResult_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in ICAS_Y1.IVDOutOfStateTypeCase_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'ICAS_Y1',
          'IVDOutOfStateTypeCase_CODE',
          IVDOutOfStateTypeCase_CODE,
          COUNT(1)
     FROM ICAS_Y1
    WHERE LTRIM(RTRIM(IVDOutOfStateTypeCase_CODE)) <> ''
      AND IVDOutOfStateTypeCase_CODE NOT IN (SELECT VALUE_CODE
                                               FROM REFM_Y1
                                              WHERE Table_ID = 'CCRT'
                                                AND TableSub_ID = 'CTYP')
    GROUP BY IVDOutOfStateTypeCase_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in ICAS_Y1.Reason_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'ICAS_Y1',
          'Reason_CODE',
          Reason_CODE,
          COUNT(1)
     FROM ICAS_Y1
    WHERE LTRIM(RTRIM(Reason_CODE)) <> ''
      AND Reason_CODE NOT IN (SELECT VALUE_CODE
                                FROM REFM_Y1
                               WHERE Table_ID = 'ISIN'
                                 AND TableSub_ID = 'REFL')
    GROUP BY Reason_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in IFMS_Y1.ExcludeVen_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'IFMS_Y1',
          'ExcludeVen_CODE',
          ExcludeVen_CODE,
          COUNT(1)
     FROM IFMS_Y1
    WHERE LTRIM(RTRIM(ExcludeVen_CODE)) <> ''
      AND ExcludeVen_CODE NOT IN (SELECT VALUE_CODE
                                    FROM REFM_Y1
                                   WHERE Table_ID = 'TAXI'
                                     AND TableSub_ID = 'EXEM')
    GROUP BY ExcludeVen_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in IFMS_Y1.StateAdministration_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'IFMS_Y1',
          'StateAdministration_CODE',
          StateAdministration_CODE,
          COUNT(1)
     FROM IFMS_Y1
    WHERE LTRIM(RTRIM(StateAdministration_CODE)) <> ''
      AND StateAdministration_CODE NOT IN (SELECT VALUE_CODE
                                             FROM REFM_Y1
                                            WHERE Table_ID = 'TAXI'
                                              AND TableSub_ID = 'ADST')
    GROUP BY StateAdministration_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in LSTT_Y1.StatusLocate_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'LSTT_Y1',
          'StatusLocate_CODE',
          StatusLocate_CODE,
          COUNT(1)
     FROM LSTT_Y1
    WHERE LTRIM(RTRIM(StatusLocate_CODE)) <> ''
      AND StatusLocate_CODE NOT IN (SELECT VALUE_CODE
                                      FROM REFM_Y1
                                     WHERE Table_ID = 'LOCS'
                                       AND TableSub_ID = 'LOCS')
    GROUP BY StatusLocate_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in MDET_Y1.InstitutionStatus_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'MDET_Y1',
          'InstitutionStatus_CODE',
          InstitutionStatus_CODE,
          COUNT(1)
     FROM MDET_Y1
    WHERE LTRIM(RTRIM(InstitutionStatus_CODE)) <> ''
      AND InstitutionStatus_CODE NOT IN (SELECT VALUE_CODE
                                           FROM REFM_Y1
                                          WHERE Table_ID = 'DEMO'
                                            AND TableSub_ID = 'ISTA')
    GROUP BY InstitutionStatus_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in MDET_Y1.MoveType_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'MDET_Y1',
          'MoveType_CODE',
          MoveType_CODE,
          COUNT(1)
     FROM MDET_Y1
    WHERE LTRIM(RTRIM(MoveType_CODE)) <> ''
      AND MoveType_CODE NOT IN (SELECT VALUE_CODE
                                  FROM REFM_Y1
                                 WHERE Table_ID = 'DEMO'
                                   AND TableSub_ID = 'MOVE')
    GROUP BY MoveType_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in MDET_Y1.ReleaseReason_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'MDET_Y1',
          'ReleaseReason_CODE',
          ReleaseReason_CODE,
          COUNT(1)
     FROM MDET_Y1
    WHERE LTRIM(RTRIM(ReleaseReason_CODE)) <> ''
      AND ReleaseReason_CODE NOT IN (SELECT VALUE_CODE
                                       FROM REFM_Y1
                                      WHERE Table_ID = 'DEMO'
                                        AND TableSub_ID = 'INST')
    GROUP BY ReleaseReason_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in MDET_Y1.Sentence_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'MDET_Y1',
          'Sentence_CODE',
          Sentence_CODE,
          COUNT(1)
     FROM MDET_Y1
    WHERE LTRIM(RTRIM(Sentence_CODE)) <> ''
      AND Sentence_CODE NOT IN (SELECT VALUE_CODE
                                  FROM REFM_Y1
                                 WHERE Table_ID = 'DEMO'
                                   AND TableSub_ID = 'SENT')
    GROUP BY Sentence_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in MDET_Y1.TypeInst_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'MDET_Y1',
          'TypeInst_CODE',
          TypeInst_CODE,
          COUNT(1)
     FROM MDET_Y1
    WHERE LTRIM(RTRIM(TypeInst_CODE)) <> ''
      AND TypeInst_CODE NOT IN (SELECT VALUE_CODE
                                  FROM REFM_Y1
                                 WHERE Table_ID = 'DEMO'
                                   AND TableSub_ID = 'TYPE')
    GROUP BY TypeInst_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in MDET_Y1.WorkRelease_INDC column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'MDET_Y1',
          'WorkRelease_INDC',
          WorkRelease_INDC,
          COUNT(1)
     FROM MDET_Y1
    WHERE LTRIM(RTRIM(WorkRelease_INDC)) <> ''
      AND WorkRelease_INDC NOT IN (SELECT VALUE_CODE
                                     FROM REFM_Y1
                                    WHERE Table_ID = 'YSNO'
                                      AND TableSub_ID = 'YSNO')
    GROUP BY WorkRelease_INDC

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in MHIS_Y1.Reason_Code column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'MHIS_Y1',
          'Reason_Code',
          Reason_Code,
          COUNT(1)
     FROM MHIS_Y1
    WHERE LTRIM(RTRIM(Reason_Code)) <> ''
      AND Reason_Code NOT IN (SELECT VALUE_CODE
                                FROM REFM_Y1
                               WHERE Table_ID = 'MHIS'
                                 AND TableSub_ID = 'MHIS')
    GROUP BY Reason_Code

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in MINS_Y1.NonQualified_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'MINS_Y1',
          'NonQualified_CODE',
          NonQualified_CODE,
          COUNT(1)
     FROM MINS_Y1
    WHERE LTRIM(RTRIM(NonQualified_CODE)) <> ''
      AND NonQualified_CODE NOT IN (SELECT VALUE_CODE
                                      FROM REFM_Y1
                                     WHERE Table_ID = 'MDIN'
                                       AND TableSub_ID = 'NOQU')
    GROUP BY NonQualified_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in MINS_Y1.PolicyAnnivMonth_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'MINS_Y1',
          'PolicyAnnivMonth_CODE',
          PolicyAnnivMonth_CODE,
          COUNT(1)
     FROM MINS_Y1
    WHERE LTRIM(RTRIM(PolicyAnnivMonth_CODE)) <> ''
      AND PolicyAnnivMonth_CODE NOT IN (SELECT VALUE_CODE
                                          FROM REFM_Y1
                                         WHERE Table_ID = 'CALD'
                                           AND TableSub_ID = 'MNTH')
    GROUP BY PolicyAnnivMonth_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in MINS_Y1.PolicyHolderRelationship_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'MINS_Y1',
          'PolicyHolderRelationship_CODE',
          PolicyHolderRelationship_CODE,
          COUNT(1)
     FROM MINS_Y1
    WHERE LTRIM(RTRIM(PolicyHolderRelationship_CODE)) <> ''
      AND PolicyHolderRelationship_CODE NOT IN (SELECT VALUE_CODE
                                                  FROM REFM_Y1
                                                 WHERE Table_ID = 'RELA'
                                                   AND TableSub_ID = 'MDIN')
    GROUP BY PolicyHolderRelationship_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in MINS_Y1.SourceVerified_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'MINS_Y1',
          'SourceVerified_CODE',
          SourceVerified_CODE,
          COUNT(1)
     FROM MINS_Y1
    WHERE LTRIM(RTRIM(SourceVerified_CODE)) <> ''
      AND SourceVerified_CODE NOT IN (SELECT VALUE_CODE
                                        FROM REFM_Y1
                                       WHERE Table_ID = 'MDIN'
                                         AND TableSub_ID = 'SRCE')
    GROUP BY SourceVerified_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in MPAT_Y1.BornOfMarriage_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'MPAT_Y1',
          'BornOfMarriage_CODE',
          BornOfMarriage_CODE,
          COUNT(1)
     FROM MPAT_Y1
    WHERE LTRIM(RTRIM(BornOfMarriage_CODE)) <> ''
      AND BornOfMarriage_CODE NOT IN (SELECT VALUE_CODE
                                        FROM REFM_Y1
                                       WHERE Table_ID = 'DEMO'
                                         AND TableSub_ID = 'BORN')
    GROUP BY BornOfMarriage_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in MPAT_Y1.ConceptionCountry_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'MPAT_Y1',
          'ConceptionCountry_CODE',
          ConceptionCountry_CODE,
          COUNT(1)
     FROM MPAT_Y1
    WHERE LTRIM(RTRIM(ConceptionCountry_CODE)) <> ''
      AND ConceptionCountry_CODE NOT IN (SELECT VALUE_CODE
                                           FROM REFM_Y1
                                          WHERE Table_ID = 'CTRY'
                                            AND TableSub_ID = 'CTRY')
    GROUP BY ConceptionCountry_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in MPAT_Y1.ConceptionCounty_IDNO column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'MPAT_Y1',
          'ConceptionCounty_IDNO',
          ConceptionCounty_IDNO,
          COUNT(1)
     FROM MPAT_Y1
    WHERE LTRIM(RTRIM(ConceptionCounty_IDNO)) <> '0'
      AND ConceptionCounty_IDNO NOT IN (SELECT VALUE_CODE
                                          FROM REFM_Y1
                                         WHERE Table_ID = 'DEMO'
                                           AND TableSub_ID = 'BICO')
    GROUP BY ConceptionCounty_IDNO

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in MPAT_Y1.DisEstablishedFather_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'MPAT_Y1',
          'DisEstablishedFather_CODE',
          DisEstablishedFather_CODE,
          COUNT(1)
     FROM MPAT_Y1
    WHERE LTRIM(RTRIM(DisEstablishedFather_CODE)) <> ''
      AND DisEstablishedFather_CODE NOT IN (SELECT VALUE_CODE
                                              FROM REFM_Y1
                                             WHERE Table_ID = 'CCRT'
                                               AND TableSub_ID = 'ESTF')
    GROUP BY DisEstablishedFather_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in MPAT_Y1.DisEstablishedFatherSuffix_NAME column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'MPAT_Y1',
          'DisEstablishedFatherSuffix_NAME',
          DisEstablishedFatherSuffix_NAME,
          COUNT(1)
     FROM MPAT_Y1
    WHERE LTRIM(RTRIM(DisEstablishedFatherSuffix_NAME)) <> ''
      AND DisEstablishedFatherSuffix_NAME NOT IN (SELECT VALUE_CODE
                                                    FROM REFM_Y1
                                                   WHERE Table_ID = 'DEMO'
                                                     AND TableSub_ID = 'SUFX')
    GROUP BY DisEstablishedFatherSuffix_NAME

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in MPAT_Y1.EstablishedFather_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'MPAT_Y1',
          'EstablishedFather_CODE',
          EstablishedFather_CODE,
          COUNT(1)
     FROM MPAT_Y1
    WHERE LTRIM(RTRIM(EstablishedFather_CODE)) <> ''
      AND EstablishedFather_CODE NOT IN (SELECT VALUE_CODE
                                           FROM REFM_Y1
                                          WHERE Table_ID = 'CCRT'
                                            AND TableSub_ID = 'ESTF')
    GROUP BY EstablishedFather_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in MPAT_Y1.EstablishedFatherSuffix_NAME column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'MPAT_Y1',
          'EstablishedFatherSuffix_NAME',
          EstablishedFatherSuffix_NAME,
          COUNT(1)
     FROM MPAT_Y1
    WHERE LTRIM(RTRIM(EstablishedFatherSuffix_NAME)) <> ''
      AND EstablishedFatherSuffix_NAME NOT IN (SELECT VALUE_CODE
                                                 FROM REFM_Y1
                                                WHERE Table_ID = 'DEMO'
                                                  AND TableSub_ID = 'SUFX')
    GROUP BY EstablishedFatherSuffix_NAME

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in MPAT_Y1.EstablishedMother_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'MPAT_Y1',
          'EstablishedMother_CODE',
          EstablishedMother_CODE,
          COUNT(1)
     FROM MPAT_Y1
    WHERE LTRIM(RTRIM(EstablishedMother_CODE)) <> ''
      AND EstablishedMother_CODE NOT IN (SELECT VALUE_CODE
                                           FROM REFM_Y1
                                          WHERE Table_ID = 'CCRT'
                                            AND TableSub_ID = 'ESTM')
    GROUP BY EstablishedMother_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in MPAT_Y1.EstablishedMotherSuffix_NAME column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'MPAT_Y1',
          'EstablishedMotherSuffix_NAME',
          EstablishedMotherSuffix_NAME,
          COUNT(1)
     FROM MPAT_Y1
    WHERE LTRIM(RTRIM(EstablishedMotherSuffix_NAME)) <> ''
      AND EstablishedMotherSuffix_NAME NOT IN (SELECT VALUE_CODE
                                                 FROM REFM_Y1
                                                WHERE Table_ID = 'DEMO'
                                                  AND TableSub_ID = 'SUFX')
    GROUP BY EstablishedMotherSuffix_NAME

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in MPAT_Y1.MethodDisestablish_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'MPAT_Y1',
          'MethodDisestablish_CODE',
          MethodDisestablish_CODE,
          COUNT(1)
     FROM MPAT_Y1
    WHERE LTRIM(RTRIM(MethodDisestablish_CODE)) <> ''
      AND MethodDisestablish_CODE NOT IN (SELECT VALUE_CODE
                                            FROM REFM_Y1
                                           WHERE Table_ID = 'DEMO'
                                             AND TableSub_ID = 'DISE')
    GROUP BY MethodDisestablish_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in MPAT_Y1.PaternityEst_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'MPAT_Y1',
          'PaternityEst_CODE',
          PaternityEst_CODE,
          COUNT(1)
     FROM MPAT_Y1
    WHERE LTRIM(RTRIM(PaternityEst_CODE)) <> ''
      AND PaternityEst_CODE NOT IN (SELECT VALUE_CODE
                                      FROM REFM_Y1
                                     WHERE Table_ID = 'DEMO'
                                       AND TableSub_ID = 'ESTM')
    GROUP BY PaternityEst_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in MPAT_Y1.PaternityEst_INDC column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'MPAT_Y1',
          'PaternityEst_INDC',
          PaternityEst_INDC,
          COUNT(1)
     FROM MPAT_Y1
    WHERE LTRIM(RTRIM(PaternityEst_INDC)) <> ''
      AND PaternityEst_INDC NOT IN (SELECT VALUE_CODE
                                      FROM REFM_Y1
                                     WHERE Table_ID = 'YSNO'
                                       AND TableSub_ID = 'YSNO')
    GROUP BY PaternityEst_INDC

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in MPAT_Y1.QiStatus_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'MPAT_Y1',
          'QiStatus_CODE',
          QiStatus_CODE,
          COUNT(1)
     FROM MPAT_Y1
    WHERE LTRIM(RTRIM(QiStatus_CODE)) <> ''
      AND QiStatus_CODE NOT IN (SELECT VALUE_CODE
                                  FROM REFM_Y1
                                 WHERE Table_ID = 'DEMO'
                                   AND TableSub_ID = 'QIST')
    GROUP BY QiStatus_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in MPAT_Y1.StatusEstablish_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'MPAT_Y1',
          'StatusEstablish_CODE',
          StatusEstablish_CODE,
          COUNT(1)
     FROM MPAT_Y1
    WHERE LTRIM(RTRIM(StatusEstablish_CODE)) <> ''
      AND StatusEstablish_CODE NOT IN (SELECT VALUE_CODE
                                         FROM REFM_Y1
                                        WHERE Table_ID = 'DEMO'
                                          AND TableSub_ID = 'STAT')
    GROUP BY StatusEstablish_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in MPAT_Y1.VapImage_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'MPAT_Y1',
          'VapImage_CODE',
          VapImage_CODE,
          COUNT(1)
     FROM MPAT_Y1
    WHERE LTRIM(RTRIM(VapImage_CODE)) <> ''
      AND VapImage_CODE NOT IN (SELECT VALUE_CODE
                                  FROM REFM_Y1
                                 WHERE Table_ID = 'DEMO'
                                   AND TableSub_ID = 'VAPI')
    GROUP BY VapImage_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in MSSN_Y1.Enumeration_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'MSSN_Y1',
          'Enumeration_CODE',
          Enumeration_CODE,
          COUNT(1)
     FROM MSSN_Y1
    WHERE LTRIM(RTRIM(Enumeration_CODE)) <> ''
      AND Enumeration_CODE NOT IN (SELECT VALUE_CODE
                                     FROM REFM_Y1
                                    WHERE Table_ID = 'CONF'
                                      AND TableSub_ID = 'CON1')
    GROUP BY Enumeration_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in MSSN_Y1.TypePrimary_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'MSSN_Y1',
          'TypePrimary_CODE',
          TypePrimary_CODE,
          COUNT(1)
     FROM MSSN_Y1
    WHERE LTRIM(RTRIM(TypePrimary_CODE)) <> ''
      AND TypePrimary_CODE NOT IN (SELECT VALUE_CODE
                                     FROM REFM_Y1
                                    WHERE Table_ID = 'DEMO'
                                      AND TableSub_ID = 'SSNT')
    GROUP BY TypePrimary_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in NOTE_Y1.CallBack_INDC column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'NOTE_Y1',
          'CallBack_INDC',
          CallBack_INDC,
          COUNT(1)
     FROM NOTE_Y1
    WHERE LTRIM(RTRIM(CallBack_INDC)) <> ''
      AND CallBack_INDC NOT IN (SELECT VALUE_CODE
                                  FROM REFM_Y1
                                 WHERE Table_ID = 'YSNO'
                                   AND TableSub_ID = 'YSNO')
    GROUP BY CallBack_INDC

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in NOTE_Y1.Category_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'NOTE_Y1',
          'Category_CODE',
          Category_CODE,
          COUNT(1)
     FROM NOTE_Y1
    WHERE LTRIM(RTRIM(Category_CODE)) <> ''
      AND Category_CODE NOT IN (SELECT VALUE_CODE
                                  FROM REFM_Y1
                                 WHERE Table_ID = 'CPRO'
                                   AND TableSub_ID = 'CATG')
    GROUP BY Category_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in NOTE_Y1.MethodContact_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'NOTE_Y1',
          'MethodContact_CODE',
          MethodContact_CODE,
          COUNT(1)
     FROM NOTE_Y1
    WHERE LTRIM(RTRIM(MethodContact_CODE)) <> ''
      AND MethodContact_CODE NOT IN (SELECT VALUE_CODE
                                       FROM REFM_Y1
                                      WHERE Table_ID = 'NOTE'
                                        AND TableSub_ID = 'CONM')
    GROUP BY MethodContact_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in NOTE_Y1.NotifySender_INDC column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'NOTE_Y1',
          'NotifySender_INDC',
          NotifySender_INDC,
          COUNT(1)
     FROM NOTE_Y1
    WHERE LTRIM(RTRIM(NotifySender_INDC)) <> ''
      AND NotifySender_INDC NOT IN (SELECT VALUE_CODE
                                      FROM REFM_Y1
                                     WHERE Table_ID = 'YSNO'
                                       AND TableSub_ID = 'YSNO')
    GROUP BY NotifySender_INDC

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in NOTE_Y1.SourceContact_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'NOTE_Y1',
          'SourceContact_CODE',
          SourceContact_CODE,
          COUNT(1)
     FROM NOTE_Y1
    WHERE LTRIM(RTRIM(SourceContact_CODE)) <> ''
      AND SourceContact_CODE NOT IN (SELECT VALUE_CODE
                                       FROM REFM_Y1
                                      WHERE Table_ID = 'NOTE'
                                        AND TableSub_ID = 'SRCE')
    GROUP BY SourceContact_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in NOTE_Y1.Status_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'NOTE_Y1',
          'Status_CODE',
          Status_CODE,
          COUNT(1)
     FROM NOTE_Y1
    WHERE LTRIM(RTRIM(Status_CODE)) <> ''
      AND Status_CODE NOT IN (SELECT VALUE_CODE
                                FROM REFM_Y1
                               WHERE Table_ID = 'NOTE'
                                 AND TableSub_ID = 'STAT')
    GROUP BY Status_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in NOTE_Y1.TypeContact_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'NOTE_Y1',
          'TypeContact_CODE',
          TypeContact_CODE,
          COUNT(1)
     FROM NOTE_Y1
    WHERE LTRIM(RTRIM(TypeContact_CODE)) <> ''
      AND TypeContact_CODE NOT IN (SELECT VALUE_CODE
                                     FROM REFM_Y1
                                    WHERE Table_ID = 'NOTE'
                                      AND TableSub_ID = 'CONT')
    GROUP BY TypeContact_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in OBLE_Y1.ExpectToPay_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'OBLE_Y1',
          'ExpectToPay_CODE',
          ExpectToPay_CODE,
          COUNT(1)
     FROM OBLE_Y1
    WHERE LTRIM(RTRIM(ExpectToPay_CODE)) <> ''
      AND ExpectToPay_CODE NOT IN (SELECT VALUE_CODE
                                     FROM REFM_Y1
                                    WHERE Table_ID = 'OWIZ'
                                      AND TableSub_ID = 'PAYT')
    GROUP BY ExpectToPay_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in OBLE_Y1.FreqPeriodic_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'OBLE_Y1',
          'FreqPeriodic_CODE',
          FreqPeriodic_CODE,
          COUNT(1)
     FROM OBLE_Y1
    WHERE LTRIM(RTRIM(FreqPeriodic_CODE)) <> ''
      AND FreqPeriodic_CODE NOT IN (SELECT VALUE_CODE
                                      FROM REFM_Y1
                                     WHERE Table_ID = 'FRQA'
                                       AND TableSub_ID = 'FRQ3')
    GROUP BY FreqPeriodic_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in OBLE_Y1.ReasonChange_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'OBLE_Y1',
          'ReasonChange_CODE',
          ReasonChange_CODE,
          COUNT(1)
     FROM OBLE_Y1
    WHERE LTRIM(RTRIM(ReasonChange_CODE)) <> ''
      AND ReasonChange_CODE NOT IN (SELECT VALUE_CODE
                                      FROM REFM_Y1
                                     WHERE Table_ID = 'OWIZ'
                                       AND TableSub_ID = 'REAS')
    GROUP BY ReasonChange_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in ORDB_Y1.Allocated_INDC column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'ORDB_Y1',
          'Allocated_INDC',
          Allocated_INDC,
          COUNT(1)
     FROM ORDB_Y1
    WHERE LTRIM(RTRIM(Allocated_INDC)) <> ''
      AND Allocated_INDC NOT IN (SELECT VALUE_CODE
                                   FROM REFM_Y1
                                  WHERE Table_ID = 'YSNO'
                                    AND TableSub_ID = 'YSNO')
    GROUP BY Allocated_INDC

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in OTHP_Y1.Country_ADDR column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'OTHP_Y1',
          'Country_ADDR',
          Country_ADDR,
          COUNT(1)
     FROM OTHP_Y1
    WHERE LTRIM(RTRIM(Country_ADDR)) <> ''
      AND Country_ADDR NOT IN (SELECT VALUE_CODE
                                 FROM REFM_Y1
                                WHERE Table_ID = 'CTRY'
                                  AND TableSub_ID = 'CTRY')
    GROUP BY Country_ADDR

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in OTHP_Y1.Eiwn_INDC column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'OTHP_Y1',
          'Eiwn_INDC',
          Eiwn_INDC,
          COUNT(1)
     FROM OTHP_Y1
    WHERE LTRIM(RTRIM(Eiwn_INDC)) <> ''
      AND Eiwn_INDC NOT IN (SELECT VALUE_CODE
                              FROM REFM_Y1
                             WHERE Table_ID = 'YSNO'
                               AND TableSub_ID = 'YSNO')
    GROUP BY Eiwn_INDC

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in OTHP_Y1.Enmsn_INDC column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'OTHP_Y1',
          'Enmsn_INDC',
          Enmsn_INDC,
          COUNT(1)
     FROM OTHP_Y1
    WHERE LTRIM(RTRIM(Enmsn_INDC)) <> ''
      AND Enmsn_INDC NOT IN (SELECT VALUE_CODE
                               FROM REFM_Y1
                              WHERE Table_ID = 'YSNO'
                                AND TableSub_ID = 'YSNO')
    GROUP BY Enmsn_INDC

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in OTHP_Y1.EportalSubscription_INDC column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'OTHP_Y1',
          'EportalSubscription_INDC',
          EportalSubscription_INDC,
          COUNT(1)
     FROM OTHP_Y1
    WHERE LTRIM(RTRIM(EportalSubscription_INDC)) <> ''
      AND EportalSubscription_INDC NOT IN (SELECT VALUE_CODE
                                             FROM REFM_Y1
                                            WHERE Table_ID = 'YSNO'
                                              AND TableSub_ID = 'YSNO')
    GROUP BY EportalSubscription_INDC

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in OTHP_Y1.InsuranceProvided_INDC column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'OTHP_Y1',
          'InsuranceProvided_INDC',
          InsuranceProvided_INDC,
          COUNT(1)
     FROM OTHP_Y1
    WHERE LTRIM(RTRIM(InsuranceProvided_INDC)) <> ''
      AND InsuranceProvided_INDC NOT IN (SELECT VALUE_CODE
                                           FROM REFM_Y1
                                          WHERE Table_ID = 'YSNO'
                                            AND TableSub_ID = 'YSNO')
    GROUP BY InsuranceProvided_INDC

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in OTHP_Y1.Normalization_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'OTHP_Y1',
          'Normalization_CODE',
          Normalization_CODE,
          COUNT(1)
     FROM OTHP_Y1
    WHERE LTRIM(RTRIM(Normalization_CODE)) <> ''
      AND Normalization_CODE NOT IN (SELECT VALUE_CODE
                                       FROM REFM_Y1
                                      WHERE Table_ID = 'ADDR'
                                        AND TableSub_ID = 'NORM')
    GROUP BY Normalization_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in OTHP_Y1.PpaEiwn_INDC column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'OTHP_Y1',
          'PpaEiwn_INDC',
          PpaEiwn_INDC,
          COUNT(1)
     FROM OTHP_Y1
    WHERE LTRIM(RTRIM(PpaEiwn_INDC)) <> ''
      AND PpaEiwn_INDC NOT IN (SELECT VALUE_CODE
                                 FROM REFM_Y1
                                WHERE Table_ID = 'YSNO'
                                  AND TableSub_ID = 'YSNO')
    GROUP BY PpaEiwn_INDC

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in OTHP_Y1.ReceivePaperForms_INDC column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'OTHP_Y1',
          'ReceivePaperForms_INDC',
          ReceivePaperForms_INDC,
          COUNT(1)
     FROM OTHP_Y1
    WHERE LTRIM(RTRIM(ReceivePaperForms_INDC)) <> ''
      AND ReceivePaperForms_INDC NOT IN (SELECT VALUE_CODE
                                           FROM REFM_Y1
                                          WHERE Table_ID = 'YSNO'
                                            AND TableSub_ID = 'YSNO')
    GROUP BY ReceivePaperForms_INDC

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in OTHP_Y1.SendShort_INDC column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'OTHP_Y1',
          'SendShort_INDC',
          SendShort_INDC,
          COUNT(1)
     FROM OTHP_Y1
    WHERE LTRIM(RTRIM(SendShort_INDC)) <> ''
      AND SendShort_INDC NOT IN (SELECT VALUE_CODE
                                   FROM REFM_Y1
                                  WHERE Table_ID = 'YSNO'
                                    AND TableSub_ID = 'YSNO')
    GROUP BY SendShort_INDC

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in OTHP_Y1.Tribal_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'OTHP_Y1',
          'Tribal_CODE',
          Tribal_CODE,
          COUNT(1)
     FROM OTHP_Y1
    WHERE LTRIM(RTRIM(Tribal_CODE)) <> ''
      AND Tribal_CODE NOT IN (SELECT VALUE_CODE
                                FROM REFM_Y1
                               WHERE Table_ID = 'OTHP'
                                 AND TableSub_ID = 'TRCD')
    GROUP BY Tribal_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in OTHP_Y1.Tribal_INDC column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'OTHP_Y1',
          'Tribal_INDC',
          Tribal_INDC,
          COUNT(1)
     FROM OTHP_Y1
    WHERE LTRIM(RTRIM(Tribal_INDC)) <> ''
      AND Tribal_INDC NOT IN (SELECT VALUE_CODE
                                FROM REFM_Y1
                               WHERE Table_ID = 'YSNO'
                                 AND TableSub_ID = 'YSNO')
    GROUP BY Tribal_INDC

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in OTHP_Y1.TypeOthp_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'OTHP_Y1',
          'TypeOthp_CODE',
          TypeOthp_CODE,
          COUNT(1)
     FROM OTHP_Y1
    WHERE LTRIM(RTRIM(TypeOthp_CODE)) <> ''
      AND TypeOthp_CODE NOT IN (SELECT VALUE_CODE
                                  FROM REFM_Y1
                                 WHERE Table_ID = 'OTHP'
                                   AND TableSub_ID = 'TYPE')
    GROUP BY TypeOthp_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in OTHP_Y1.Verified_INDC column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'OTHP_Y1',
          'Verified_INDC',
          Verified_INDC,
          COUNT(1)
     FROM OTHP_Y1
    WHERE LTRIM(RTRIM(Verified_INDC)) <> ''
      AND Verified_INDC NOT IN (SELECT VALUE_CODE
                                  FROM REFM_Y1
                                 WHERE Table_ID = 'YSNO'
                                   AND TableSub_ID = 'YSNO')
    GROUP BY Verified_INDC

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in PLIC_Y1.LicenseStatus_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'PLIC_Y1',
          'LicenseStatus_CODE',
          LicenseStatus_CODE,
          COUNT(1)
     FROM PLIC_Y1
    WHERE LTRIM(RTRIM(LicenseStatus_CODE)) <> ''
      AND LicenseStatus_CODE NOT IN (SELECT VALUE_CODE
                                       FROM REFM_Y1
                                      WHERE Table_ID = 'MLIC'
                                        AND TableSub_ID = 'LICS')
    GROUP BY LicenseStatus_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in PLIC_Y1.SourceVerified_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'PLIC_Y1',
          'SourceVerified_CODE',
          SourceVerified_CODE,
          COUNT(1)
     FROM PLIC_Y1
    WHERE LTRIM(RTRIM(SourceVerified_CODE)) <> ''
      AND SourceVerified_CODE NOT IN (SELECT VALUE_CODE
                                        FROM REFM_Y1
                                       WHERE Table_ID = 'MLIC'
                                         AND TableSub_ID = 'SRCE')
    GROUP BY SourceVerified_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in PLIC_Y1.Status_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'PLIC_Y1',
          'Status_CODE',
          Status_CODE,
          COUNT(1)
     FROM PLIC_Y1
    WHERE LTRIM(RTRIM(Status_CODE)) <> ''
      AND Status_CODE NOT IN (SELECT VALUE_CODE
                                FROM REFM_Y1
                               WHERE Table_ID = 'MLIC'
                                 AND TableSub_ID = 'VERI')
    GROUP BY Status_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in POFL_Y1.CheckRecipient_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'POFL_Y1',
          'CheckRecipient_CODE',
          CheckRecipient_CODE,
          COUNT(1)
     FROM POFL_Y1
    WHERE LTRIM(RTRIM(CheckRecipient_CODE)) <> ''
      AND CheckRecipient_CODE NOT IN (SELECT VALUE_CODE
                                        FROM REFM_Y1
                                       WHERE Table_ID = 'DRAR'
                                         AND TableSub_ID = 'FUND')
    GROUP BY CheckRecipient_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in POFL_Y1.RecoupmentPayee_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'POFL_Y1',
          'RecoupmentPayee_CODE',
          RecoupmentPayee_CODE,
          COUNT(1)
     FROM POFL_Y1
    WHERE LTRIM(RTRIM(RecoupmentPayee_CODE)) <> ''
      AND RecoupmentPayee_CODE NOT IN (SELECT VALUE_CODE
                                         FROM REFM_Y1
                                        WHERE Table_ID = 'DRAR'
                                          AND TableSub_ID = 'RECP')
    GROUP BY RecoupmentPayee_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in POFL_Y1.Transaction_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'POFL_Y1',
          'Transaction_CODE',
          Transaction_CODE,
          COUNT(1)
     FROM POFL_Y1
    WHERE LTRIM(RTRIM(Transaction_CODE)) <> ''
      AND Transaction_CODE NOT IN (SELECT VALUE_CODE
                                     FROM REFM_Y1
                                    WHERE Table_ID = 'CREC'
                                      AND TableSub_ID = 'DESC')
    GROUP BY Transaction_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in POFL_Y1.TypeRecoupment_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'POFL_Y1',
          'TypeRecoupment_CODE',
          TypeRecoupment_CODE,
          COUNT(1)
     FROM POFL_Y1
    WHERE LTRIM(RTRIM(TypeRecoupment_CODE)) <> ''
      AND TypeRecoupment_CODE NOT IN (SELECT VALUE_CODE
                                        FROM REFM_Y1
                                       WHERE Table_ID = 'CREC'
                                         AND TableSub_ID = 'RECT')
    GROUP BY TypeRecoupment_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in RBAT_Y1.RePost_INDC column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'RBAT_Y1',
          'RePost_INDC',
          RePost_INDC,
          COUNT(1)
     FROM RBAT_Y1
    WHERE LTRIM(RTRIM(RePost_INDC)) <> ''
      AND RePost_INDC NOT IN (SELECT VALUE_CODE
                                FROM REFM_Y1
                               WHERE Table_ID = 'YSNO'
                                 AND TableSub_ID = 'YSNO')
    GROUP BY RePost_INDC

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in RBAT_Y1.SourceBatch_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'RBAT_Y1',
          'SourceBatch_CODE',
          SourceBatch_CODE,
          COUNT(1)
     FROM RBAT_Y1
    WHERE LTRIM(RTRIM(SourceBatch_CODE)) <> ''
      AND SourceBatch_CODE NOT IN (SELECT VALUE_CODE
                                     FROM REFM_Y1
                                    WHERE Table_ID = 'RCTB'
                                      AND TableSub_ID = 'RCTB')
    GROUP BY SourceBatch_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in RBAT_Y1.StatusBatch_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'RBAT_Y1',
          'StatusBatch_CODE',
          StatusBatch_CODE,
          COUNT(1)
     FROM RBAT_Y1
    WHERE LTRIM(RTRIM(StatusBatch_CODE)) <> ''
      AND StatusBatch_CODE NOT IN (SELECT VALUE_CODE
                                     FROM REFM_Y1
                                    WHERE Table_ID = 'BATS'
                                      AND TableSub_ID = 'CBAT')
    GROUP BY StatusBatch_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in RCTH_Y1.SourceBatch_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'RCTH_Y1',
          'SourceBatch_CODE',
          SourceBatch_CODE,
          COUNT(1)
     FROM RCTH_Y1
    WHERE LTRIM(RTRIM(SourceBatch_CODE)) <> ''
      AND SourceBatch_CODE NOT IN (SELECT VALUE_CODE
                                     FROM REFM_Y1
                                    WHERE Table_ID = 'RCTB'
                                      AND TableSub_ID = 'RCTB')
    GROUP BY SourceBatch_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in RCTH_Y1.SourceReceipt_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'RCTH_Y1',
          'SourceReceipt_CODE',
          SourceReceipt_CODE,
          COUNT(1)
     FROM RCTH_Y1
    WHERE LTRIM(RTRIM(SourceReceipt_CODE)) <> ''
      AND SourceReceipt_CODE NOT IN (SELECT VALUE_CODE
                                       FROM REFM_Y1
                                      WHERE Table_ID = 'RCTS'
                                        AND TableSub_ID = 'RCTS')
    GROUP BY SourceReceipt_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in RCTH_Y1.TaxJoint_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'RCTH_Y1',
          'TaxJoint_CODE',
          TaxJoint_CODE,
          COUNT(1)
     FROM RCTH_Y1
    WHERE LTRIM(RTRIM(TaxJoint_CODE)) <> ''
      AND TaxJoint_CODE NOT IN (SELECT VALUE_CODE
                                  FROM REFM_Y1
                                 WHERE Table_ID = 'TAXI'
                                   AND TableSub_ID = 'ACCT')
    GROUP BY TaxJoint_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in RCTH_Y1.TypePosting_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'RCTH_Y1',
          'TypePosting_CODE',
          TypePosting_CODE,
          COUNT(1)
     FROM RCTH_Y1
    WHERE LTRIM(RTRIM(TypePosting_CODE)) <> ''
      AND TypePosting_CODE NOT IN (SELECT VALUE_CODE
                                     FROM REFM_Y1
                                    WHERE Table_ID = 'RCTS'
                                      AND TableSub_ID = 'POST')
    GROUP BY TypePosting_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in RCTH_Y1.TypeRemittance_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'RCTH_Y1',
          'TypeRemittance_CODE',
          TypeRemittance_CODE,
          COUNT(1)
     FROM RCTH_Y1
    WHERE LTRIM(RTRIM(TypeRemittance_CODE)) <> ''
      AND TypeRemittance_CODE NOT IN (SELECT VALUE_CODE
                                        FROM REFM_Y1
                                       WHERE Table_ID = 'RCTP'
                                         AND TableSub_ID = 'RCTP')
    GROUP BY TypeRemittance_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in RECP_Y1.CpResponse_INDC column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'RECP_Y1',
          'CpResponse_INDC',
          CpResponse_INDC,
          COUNT(1)
     FROM RECP_Y1
    WHERE LTRIM(RTRIM(CpResponse_INDC)) <> ''
      AND CpResponse_INDC NOT IN (SELECT VALUE_CODE
                                    FROM REFM_Y1
                                   WHERE Table_ID = 'YSNO'
                                     AND TableSub_ID = 'YSNO')
    GROUP BY CpResponse_INDC

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in SLST_Y1.TypeArrear_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'SLST_Y1',
          'TypeArrear_CODE',
          TypeArrear_CODE,
          COUNT(1)
     FROM SLST_Y1
    WHERE LTRIM(RTRIM(TypeArrear_CODE)) <> ''
      AND TypeArrear_CODE NOT IN (SELECT VALUE_CODE
                                    FROM REFM_Y1
                                   WHERE Table_ID = 'TANF'
                                     AND TableSub_ID = 'TYPE')
    GROUP BY TypeArrear_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in SLST_Y1.TypeTransaction_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'SLST_Y1',
          'TypeTransaction_CODE',
          TypeTransaction_CODE,
          COUNT(1)
     FROM SLST_Y1
    WHERE LTRIM(RTRIM(TypeTransaction_CODE)) <> ''
      AND TypeTransaction_CODE NOT IN (SELECT VALUE_CODE
                                         FROM REFM_Y1
                                        WHERE Table_ID = 'STXH'
                                          AND TableSub_ID = 'TRAN')
    GROUP BY TypeTransaction_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in SORD_Y1.CejStatus_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'SORD_Y1',
          'CejStatus_CODE',
          CejStatus_CODE,
          COUNT(1)
     FROM SORD_Y1
    WHERE LTRIM(RTRIM(CejStatus_CODE)) <> ''
      AND CejStatus_CODE NOT IN (SELECT VALUE_CODE
                                   FROM REFM_Y1
                                  WHERE Table_ID = 'SORD'
                                    AND TableSub_ID = 'CEJS')
    GROUP BY CejStatus_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in SORD_Y1.DeviationReason_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'SORD_Y1',
          'DeviationReason_CODE',
          DeviationReason_CODE,
          COUNT(1)
     FROM SORD_Y1
    WHERE LTRIM(RTRIM(DeviationReason_CODE)) <> ''
      AND DeviationReason_CODE NOT IN (SELECT VALUE_CODE
                                         FROM REFM_Y1
                                        WHERE Table_ID = 'DEVT'
                                          AND TableSub_ID = 'DEVT')
    GROUP BY DeviationReason_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in SORD_Y1.Iiwo_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'SORD_Y1',
          'Iiwo_CODE',
          Iiwo_CODE,
          COUNT(1)
     FROM SORD_Y1
    WHERE LTRIM(RTRIM(Iiwo_CODE)) <> ''
      AND Iiwo_CODE NOT IN (SELECT VALUE_CODE
                              FROM REFM_Y1
                             WHERE Table_ID = 'SORD'
                               AND TableSub_ID = 'IWOR')
    GROUP BY Iiwo_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in SORD_Y1.InsOrdered_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'SORD_Y1',
          'InsOrdered_CODE',
          InsOrdered_CODE,
          COUNT(1)
     FROM SORD_Y1
    WHERE LTRIM(RTRIM(InsOrdered_CODE)) <> ''
      AND InsOrdered_CODE NOT IN (SELECT VALUE_CODE
                                    FROM REFM_Y1
                                   WHERE Table_ID = 'SORD'
                                     AND TableSub_ID = 'INSO')
    GROUP BY InsOrdered_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in SORD_Y1.SourceOrdered_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'SORD_Y1',
          'SourceOrdered_CODE',
          SourceOrdered_CODE,
          COUNT(1)
     FROM SORD_Y1
    WHERE LTRIM(RTRIM(SourceOrdered_CODE)) <> ''
      AND SourceOrdered_CODE NOT IN (SELECT VALUE_CODE
                                       FROM REFM_Y1
                                      WHERE Table_ID = 'SORD'
                                        AND TableSub_ID = 'ORDB')
    GROUP BY SourceOrdered_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in SORD_Y1.StateControl_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'SORD_Y1',
          'StateControl_CODE',
          StateControl_CODE,
          COUNT(1)
     FROM SORD_Y1
    WHERE LTRIM(RTRIM(StateControl_CODE)) <> ''
      AND StateControl_CODE NOT IN (SELECT VALUE_CODE
                                      FROM REFM_Y1
                                     WHERE Table_ID = 'STAT'
                                       AND TableSub_ID = 'STAT')
    GROUP BY StateControl_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in SORD_Y1.StatusControl_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'SORD_Y1',
          'StatusControl_CODE',
          StatusControl_CODE,
          COUNT(1)
     FROM SORD_Y1
    WHERE LTRIM(RTRIM(StatusControl_CODE)) <> ''
      AND StatusControl_CODE NOT IN (SELECT VALUE_CODE
                                       FROM REFM_Y1
                                      WHERE Table_ID = 'CTRL'
                                        AND TableSub_ID = 'STAT')
    GROUP BY StatusControl_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in SORD_Y1.TypeOrder_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'SORD_Y1',
          'TypeOrder_CODE',
          TypeOrder_CODE,
          COUNT(1)
     FROM SORD_Y1
    WHERE LTRIM(RTRIM(TypeOrder_CODE)) <> ''
      AND TypeOrder_CODE NOT IN (SELECT VALUE_CODE
                                   FROM REFM_Y1
                                  WHERE Table_ID = 'SORD'
                                    AND TableSub_ID = 'ORDT')
    GROUP BY TypeOrder_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in SWKS_Y1.ActivityMinor_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'SWKS_Y1',
          'ActivityMinor_CODE',
          ActivityMinor_CODE,
          COUNT(1)
     FROM SWKS_Y1
    WHERE LTRIM(RTRIM(ActivityMinor_CODE)) <> ''
      AND ActivityMinor_CODE NOT IN (SELECT ActivityMinor_CODE
                                       FROM AMNR_Y1)
    GROUP BY ActivityMinor_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in SWKS_Y1.ApptStatus_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'SWKS_Y1',
          'ApptStatus_CODE',
          ApptStatus_CODE,
          COUNT(1)
     FROM SWKS_Y1
    WHERE LTRIM(RTRIM(ApptStatus_CODE)) <> ''
      AND ApptStatus_CODE NOT IN (SELECT VALUE_CODE
                                    FROM REFM_Y1
                                   WHERE Table_ID = 'APPT'
                                     AND TableSub_ID = 'STAT')
    GROUP BY ApptStatus_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in SWKS_Y1.ReasonAdjourn_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'SWKS_Y1',
          'ReasonAdjourn_CODE',
          ReasonAdjourn_CODE,
          COUNT(1)
     FROM SWKS_Y1
    WHERE LTRIM(RTRIM(ReasonAdjourn_CODE)) <> ''
      AND ReasonAdjourn_CODE NOT IN (SELECT VALUE_CODE
                                       FROM REFM_Y1
                                      WHERE Table_ID = 'FMIS'
                                        AND TableSub_ID = 'AJRN')
    GROUP BY ReasonAdjourn_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in SWKS_Y1.SchedulingUnit_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'SWKS_Y1',
          'SchedulingUnit_CODE',
          SchedulingUnit_CODE,
          COUNT(1)
     FROM SWKS_Y1
    WHERE LTRIM(RTRIM(SchedulingUnit_CODE)) <> ''
      AND SchedulingUnit_CODE NOT IN (SELECT VALUE_CODE
                                        FROM REFM_Y1
                                       WHERE Table_ID = 'SPRO'
                                         AND TableSub_ID = 'SCUN')
    GROUP BY SchedulingUnit_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in SWKS_Y1.TypeActivity_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'SWKS_Y1',
          'TypeActivity_CODE',
          TypeActivity_CODE,
          COUNT(1)
     FROM SWKS_Y1
    WHERE LTRIM(RTRIM(TypeActivity_CODE)) <> ''
      AND TypeActivity_CODE NOT IN (SELECT VALUE_CODE
                                      FROM REFM_Y1
                                     WHERE Table_ID = 'ACTP'
                                       AND TableSub_ID = 'ACTP')
    GROUP BY TypeActivity_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in SWKS_Y1.TypeFamisProceeding_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'SWKS_Y1',
          'TypeFamisProceeding_CODE',
          TypeFamisProceeding_CODE,
          COUNT(1)
     FROM SWKS_Y1
    WHERE LTRIM(RTRIM(TypeFamisProceeding_CODE)) <> ''
      AND TypeFamisProceeding_CODE NOT IN (SELECT VALUE_CODE
                                             FROM REFM_Y1
                                            WHERE Table_ID = 'FMIS'
                                              AND TableSub_ID = 'PRYP')
    GROUP BY TypeFamisProceeding_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in TEXC_Y1.ExcludeFin_INDC column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'TEXC_Y1',
          'ExcludeFin_INDC',
          ExcludeFin_INDC,
          COUNT(1)
     FROM TEXC_Y1
    WHERE LTRIM(RTRIM(ExcludeFin_INDC)) <> ''
      AND ExcludeFin_INDC NOT IN (SELECT VALUE_CODE
                                    FROM REFM_Y1
                                   WHERE Table_ID = 'TAXI'
                                     AND TableSub_ID = 'EXEM')
    GROUP BY ExcludeFin_INDC

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in TEXC_Y1.ExcludeIns_INDC column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'TEXC_Y1',
          'ExcludeIns_INDC',
          ExcludeIns_INDC,
          COUNT(1)
     FROM TEXC_Y1
    WHERE LTRIM(RTRIM(ExcludeIns_INDC)) <> ''
      AND ExcludeIns_INDC NOT IN (SELECT VALUE_CODE
                                    FROM REFM_Y1
                                   WHERE Table_ID = 'TAXI'
                                     AND TableSub_ID = 'EXEM')
    GROUP BY ExcludeIns_INDC

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in TEXC_Y1.ExcludeIrs_INDC column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'TEXC_Y1',
          'ExcludeIrs_INDC',
          ExcludeIrs_INDC,
          COUNT(1)
     FROM TEXC_Y1
    WHERE LTRIM(RTRIM(ExcludeIrs_INDC)) <> ''
      AND ExcludeIrs_INDC NOT IN (SELECT VALUE_CODE
                                    FROM REFM_Y1
                                   WHERE Table_ID = 'TAXI'
                                     AND TableSub_ID = 'EXEM')
    GROUP BY ExcludeIrs_INDC

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in TEXC_Y1.ExcludePas_INDC column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'TEXC_Y1',
          'ExcludePas_INDC',
          ExcludePas_INDC,
          COUNT(1)
     FROM TEXC_Y1
    WHERE LTRIM(RTRIM(ExcludePas_INDC)) <> ''
      AND ExcludePas_INDC NOT IN (SELECT VALUE_CODE
                                    FROM REFM_Y1
                                   WHERE Table_ID = 'TAXI'
                                     AND TableSub_ID = 'EXEM')
    GROUP BY ExcludePas_INDC

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in TEXC_Y1.ExcludeRet_INDC column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'TEXC_Y1',
          'ExcludeRet_INDC',
          ExcludeRet_INDC,
          COUNT(1)
     FROM TEXC_Y1
    WHERE LTRIM(RTRIM(ExcludeRet_INDC)) <> ''
      AND ExcludeRet_INDC NOT IN (SELECT VALUE_CODE
                                    FROM REFM_Y1
                                   WHERE Table_ID = 'TAXI'
                                     AND TableSub_ID = 'EXEM')
    GROUP BY ExcludeRet_INDC

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in TEXC_Y1.ExcludeSal_INDC column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'TEXC_Y1',
          'ExcludeSal_INDC',
          ExcludeSal_INDC,
          COUNT(1)
     FROM TEXC_Y1
    WHERE LTRIM(RTRIM(ExcludeSal_INDC)) <> ''
      AND ExcludeSal_INDC NOT IN (SELECT VALUE_CODE
                                    FROM REFM_Y1
                                   WHERE Table_ID = 'TAXI'
                                     AND TableSub_ID = 'EXEM')
    GROUP BY ExcludeSal_INDC

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in TEXC_Y1.ExcludeState_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'TEXC_Y1',
          'ExcludeState_CODE',
          ExcludeState_CODE,
          COUNT(1)
     FROM TEXC_Y1
    WHERE LTRIM(RTRIM(ExcludeState_CODE)) <> ''
      AND ExcludeState_CODE NOT IN (SELECT VALUE_CODE
                                      FROM REFM_Y1
                                     WHERE Table_ID = 'TAXI'
                                       AND TableSub_ID = 'EXEM')
    GROUP BY ExcludeState_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in TEXC_Y1.ExcludeVen_INDC column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'TEXC_Y1',
          'ExcludeVen_INDC',
          ExcludeVen_INDC,
          COUNT(1)
     FROM TEXC_Y1
    WHERE LTRIM(RTRIM(ExcludeVen_INDC)) <> ''
      AND ExcludeVen_INDC NOT IN (SELECT VALUE_CODE
                                    FROM REFM_Y1
                                   WHERE Table_ID = 'TAXI'
                                     AND TableSub_ID = 'EXEM')
    GROUP BY ExcludeVen_INDC

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in URCT_Y1.IdentificationStatus_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'URCT_Y1',
          'IdentificationStatus_CODE',
          IdentificationStatus_CODE,
          COUNT(1)
     FROM URCT_Y1
    WHERE LTRIM(RTRIM(IdentificationStatus_CODE)) <> ''
      AND IdentificationStatus_CODE NOT IN (SELECT VALUE_CODE
                                              FROM REFM_Y1
                                             WHERE Table_ID = 'RCTH'
                                               AND TableSub_ID = 'STAT')
    GROUP BY IdentificationStatus_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in URCT_Y1.SourceReceipt_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'URCT_Y1',
          'SourceReceipt_CODE',
          SourceReceipt_CODE,
          COUNT(1)
     FROM URCT_Y1
    WHERE LTRIM(RTRIM(SourceReceipt_CODE)) <> ''
      AND SourceReceipt_CODE NOT IN (SELECT VALUE_CODE
                                       FROM REFM_Y1
                                      WHERE Table_ID = 'RCTS'
                                        AND TableSub_ID = 'RCTS')
    GROUP BY SourceReceipt_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in USEM_Y1.WorkerSubTitle_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'USEM_Y1',
          'WorkerSubTitle_CODE',
          WorkerSubTitle_CODE,
          COUNT(1)
     FROM USEM_Y1
    WHERE LTRIM(RTRIM(WorkerSubTitle_CODE)) <> ''
      AND WorkerSubTitle_CODE NOT IN (SELECT VALUE_CODE
                                        FROM REFM_Y1
                                       WHERE Table_ID = 'DTIT'
                                         AND TableSub_ID = 'DTIT')
    GROUP BY WorkerSubTitle_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in USEM_Y1.WorkerTitle_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'USEM_Y1',
          'WorkerTitle_CODE',
          WorkerTitle_CODE,
          COUNT(1)
     FROM USEM_Y1
    WHERE LTRIM(RTRIM(WorkerTitle_CODE)) <> ''
      AND WorkerTitle_CODE NOT IN (SELECT VALUE_CODE
                                     FROM REFM_Y1
                                    WHERE Table_ID = 'USEM'
                                      AND TableSub_ID = 'TTLS')
    GROUP BY WorkerTitle_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in VAPP_Y1.ChildBirthCity_INDC column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'VAPP_Y1',
          'ChildBirthCity_INDC',
          ChildBirthCity_INDC,
          COUNT(1)
     FROM VAPP_Y1
    WHERE LTRIM(RTRIM(ChildBirthCity_INDC)) <> ''
      AND ChildBirthCity_INDC NOT IN (SELECT VALUE_CODE
                                        FROM REFM_Y1
                                       WHERE Table_ID = 'YSNO'
                                         AND TableSub_ID = 'YSNO')
    GROUP BY ChildBirthCity_INDC

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in VAPP_Y1.ChildBirthCounty_INDC column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'VAPP_Y1',
          'ChildBirthCounty_INDC',
          ChildBirthCounty_INDC,
          COUNT(1)
     FROM VAPP_Y1
    WHERE LTRIM(RTRIM(ChildBirthCounty_INDC)) <> ''
      AND ChildBirthCounty_INDC NOT IN (SELECT VALUE_CODE
                                          FROM REFM_Y1
                                         WHERE Table_ID = 'YSNO'
                                           AND TableSub_ID = 'YSNO')
    GROUP BY ChildBirthCounty_INDC

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in VAPP_Y1.ChildBirthState_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'VAPP_Y1',
          'ChildBirthState_CODE',
          ChildBirthState_CODE,
          COUNT(1)
     FROM VAPP_Y1
    WHERE LTRIM(RTRIM(ChildBirthState_CODE)) <> ''
      AND ChildBirthState_CODE NOT IN (SELECT VALUE_CODE
                                         FROM REFM_Y1
                                        WHERE Table_ID = 'STAT'
                                          AND TableSub_ID = 'STAT')
    GROUP BY ChildBirthState_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in VAPP_Y1.DataRecordStatus_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'VAPP_Y1',
          'DataRecordStatus_CODE',
          DataRecordStatus_CODE,
          COUNT(1)
     FROM VAPP_Y1
    WHERE LTRIM(RTRIM(DataRecordStatus_CODE)) <> ''
      AND DataRecordStatus_CODE NOT IN (SELECT VALUE_CODE
                                          FROM REFM_Y1
                                         WHERE Table_ID = 'VAPP'
                                           AND TableSub_ID = 'DSTA')
    GROUP BY DataRecordStatus_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in VAPP_Y1.Declaration_INDC column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'VAPP_Y1',
          'Declaration_INDC',
          Declaration_INDC,
          COUNT(1)
     FROM VAPP_Y1
    WHERE LTRIM(RTRIM(Declaration_INDC)) <> ''
      AND Declaration_INDC NOT IN (SELECT VALUE_CODE
                                     FROM REFM_Y1
                                    WHERE Table_ID = 'YSNO'
                                      AND TableSub_ID = 'YSNO')
    GROUP BY Declaration_INDC

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in VAPP_Y1.DopAttached_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'VAPP_Y1',
          'DopAttached_CODE',
          DopAttached_CODE,
          COUNT(1)
     FROM VAPP_Y1
    WHERE LTRIM(RTRIM(DopAttached_CODE)) <> ''
      AND DopAttached_CODE NOT IN (SELECT VALUE_CODE
                                     FROM REFM_Y1
                                    WHERE Table_ID = 'VAPP'
                                      AND TableSub_ID = 'DOPA')
    GROUP BY DopAttached_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in VAPP_Y1.FatherAddrExist_INDC column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'VAPP_Y1',
          'FatherAddrExist_INDC',
          FatherAddrExist_INDC,
          COUNT(1)
     FROM VAPP_Y1
    WHERE LTRIM(RTRIM(FatherAddrExist_INDC)) <> ''
      AND FatherAddrExist_INDC NOT IN (SELECT VALUE_CODE
                                         FROM REFM_Y1
                                        WHERE Table_ID = 'YSNO'
                                          AND TableSub_ID = 'YSNO')
    GROUP BY FatherAddrExist_INDC

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in VAPP_Y1.GeneticTest_INDC column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'VAPP_Y1',
          'GeneticTest_INDC',
          GeneticTest_INDC,
          COUNT(1)
     FROM VAPP_Y1
    WHERE LTRIM(RTRIM(GeneticTest_INDC)) <> ''
      AND GeneticTest_INDC NOT IN (SELECT VALUE_CODE
                                     FROM REFM_Y1
                                    WHERE Table_ID = 'YSNO'
                                      AND TableSub_ID = 'YSNO')
    GROUP BY GeneticTest_INDC

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in VAPP_Y1.ImageLink_INDC column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'VAPP_Y1',
          'ImageLink_INDC',
          ImageLink_INDC,
          COUNT(1)
     FROM VAPP_Y1
    WHERE LTRIM(RTRIM(ImageLink_INDC)) <> ''
      AND ImageLink_INDC NOT IN (SELECT VALUE_CODE
                                   FROM REFM_Y1
                                  WHERE Table_ID = 'YSNO'
                                    AND TableSub_ID = 'YSNO')
    GROUP BY ImageLink_INDC

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in VAPP_Y1.MotherAddrExist_INDC column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'VAPP_Y1',
          'MotherAddrExist_INDC',
          MotherAddrExist_INDC,
          COUNT(1)
     FROM VAPP_Y1
    WHERE LTRIM(RTRIM(MotherAddrExist_INDC)) <> ''
      AND MotherAddrExist_INDC NOT IN (SELECT VALUE_CODE
                                         FROM REFM_Y1
                                        WHERE Table_ID = 'YSNO'
                                          AND TableSub_ID = 'YSNO')
    GROUP BY MotherAddrExist_INDC

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in VAPP_Y1.PlaceOfAck_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'VAPP_Y1',
          'PlaceOfAck_CODE',
          PlaceOfAck_CODE,
          COUNT(1)
     FROM VAPP_Y1
    WHERE LTRIM(RTRIM(PlaceOfAck_CODE)) <> ''
      AND PlaceOfAck_CODE NOT IN (SELECT VALUE_CODE
                                    FROM REFM_Y1
                                   WHERE Table_ID = 'VAPP'
                                     AND TableSub_ID = 'PLOA')
    GROUP BY PlaceOfAck_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in VAPP_Y1.TypeDocument_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'VAPP_Y1',
          'TypeDocument_CODE',
          TypeDocument_CODE,
          COUNT(1)
     FROM VAPP_Y1
    WHERE LTRIM(RTRIM(TypeDocument_CODE)) <> ''
      AND TypeDocument_CODE NOT IN (SELECT VALUE_CODE
                                      FROM REFM_Y1
                                     WHERE Table_ID = 'VAPP'
                                       AND TableSub_ID = 'DOCT')
    GROUP BY TypeDocument_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in VAPP_Y1.VapAttached_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'VAPP_Y1',
          'VapAttached_CODE',
          VapAttached_CODE,
          COUNT(1)
     FROM VAPP_Y1
    WHERE LTRIM(RTRIM(VapAttached_CODE)) <> ''
      AND VapAttached_CODE NOT IN (SELECT VALUE_CODE
                                     FROM REFM_Y1
                                    WHERE Table_ID = 'VAPP'
                                      AND TableSub_ID = 'VAPA')
    GROUP BY VapAttached_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in ACEN_Y1.ReasonStatus_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'ACEN_Y1',
          'ReasonStatus_CODE',
          ReasonStatus_CODE,
          COUNT(1)
     FROM ACEN_Y1
    WHERE LTRIM(RTRIM(ReasonStatus_CODE)) <> ''
      AND ReasonStatus_CODE NOT IN (SELECT VALUE_CODE
                                      FROM REFM_Y1
                                     WHERE (Table_ID = 'ENST'
                                        AND TableSub_ID = 'REAS')
                                        OR (Table_ID = 'EXMT'
                                            AND TableSub_ID = 'EXMT'))
    GROUP BY ReasonStatus_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in AHIS_Y1.State_ADDR column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'AHIS_Y1',
          'State_ADDR',
          State_ADDR,
          COUNT(1)
     FROM AHIS_Y1
    WHERE LTRIM(RTRIM(State_ADDR)) <> ''
      AND State_ADDR NOT IN (SELECT VALUE_CODE
                               FROM REFM_Y1
                              WHERE (Table_ID = 'STAT'
                                 AND TableSub_ID = 'CANA')
                                 OR (Table_ID = 'STAT'
                                     AND TableSub_ID = 'STAT'))
    GROUP BY State_ADDR

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in AHIS_Y1.TypeAddress_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'AHIS_Y1',
          'TypeAddress_CODE',
          TypeAddress_CODE,
          COUNT(1)
     FROM AHIS_Y1
    WHERE LTRIM(RTRIM(TypeAddress_CODE)) <> ''
      AND TypeAddress_CODE NOT IN (SELECT VALUE_CODE
                                     FROM REFM_Y1
                                    WHERE (Table_ID = 'ADDR'
                                       AND TableSub_ID = 'ADD1')
                                       OR (Table_ID = 'ADDR'
                                           AND TableSub_ID = 'ADD2'))
    GROUP BY TypeAddress_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in ASFN_Y1.Asset_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'ASFN_Y1',
          'Asset_CODE',
          Asset_CODE,
          COUNT(1)
     FROM ASFN_Y1
    WHERE LTRIM(RTRIM(Asset_CODE)) <> ''
      AND Asset_CODE NOT IN (SELECT VALUE_CODE
                               FROM REFM_Y1
                              WHERE (Table_ID = 'MAST'
                                 AND TableSub_ID = 'FIIS')
                                 OR (Table_ID = 'MAST'
                                     AND TableSub_ID = 'FINA')
                                 OR (Table_ID = 'MAST'
                                     AND TableSub_ID = 'FINS'))
    GROUP BY Asset_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in CASE_Y1.County_IDNO column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'CASE_Y1',
          'County_IDNO',
          County_IDNO,
          COUNT(1)
     FROM CASE_Y1
    WHERE LTRIM(RTRIM(County_IDNO)) <> ''
      AND County_IDNO NOT IN (SELECT VALUE_CODE
                                FROM REFM_Y1
                               WHERE (Table_ID = '    '
                                  AND TableSub_ID = '    ')
                                  OR (Table_ID = 'OTHP'
                                      AND TableSub_ID = 'CNTY')
                                  OR (Table_ID = 'RJCT'
                                      AND TableSub_ID = 'CNTY'))
    GROUP BY County_IDNO

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in CASE_Y1.RespondInit_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'CASE_Y1',
          'RespondInit_CODE',
          RespondInit_CODE,
          COUNT(1)
     FROM CASE_Y1
    WHERE LTRIM(RTRIM(RespondInit_CODE)) <> ''
      AND RespondInit_CODE NOT IN (SELECT VALUE_CODE
                                     FROM REFM_Y1
                                    WHERE (Table_ID = 'INTS'
                                       AND TableSub_ID = 'CATG')
                                       OR (Table_ID = 'WRKL'
                                           AND TableSub_ID = 'INST')
                                       OR (Table_ID = 'YSNO'
                                           AND TableSub_ID = 'YSNO'))
    GROUP BY RespondInit_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in DEMO_Y1.BirthState_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'DEMO_Y1',
          'BirthState_CODE',
          BirthState_CODE,
          COUNT(1)
     FROM DEMO_Y1
    WHERE LTRIM(RTRIM(BirthState_CODE)) <> ''
      AND BirthState_CODE NOT IN (SELECT VALUE_CODE
                                    FROM REFM_Y1
                                   WHERE (Table_ID = 'STAT'
                                      AND TableSub_ID = 'CANA')
                                      OR (Table_ID = 'STAT'
                                          AND TableSub_ID = 'STAT'))
    GROUP BY BirthState_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in DEMO_Y1.MemberSex_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'DEMO_Y1',
          'MemberSex_CODE',
          MemberSex_CODE,
          COUNT(1)
     FROM DEMO_Y1
    WHERE LTRIM(RTRIM(MemberSex_CODE)) <> ''
      AND MemberSex_CODE NOT IN (SELECT VALUE_CODE
                                   FROM REFM_Y1
                                  WHERE (Table_ID = 'GENR'
                                     AND TableSub_ID = 'GEND')
                                     OR (Table_ID = 'GENR'
                                         AND TableSub_ID = 'GEN2'))
    GROUP BY MemberSex_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in DEMO_Y1.StateDivorce_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'DEMO_Y1',
          'StateDivorce_CODE',
          StateDivorce_CODE,
          COUNT(1)
     FROM DEMO_Y1
    WHERE LTRIM(RTRIM(StateDivorce_CODE)) <> ''
      AND StateDivorce_CODE NOT IN (SELECT VALUE_CODE
                                      FROM REFM_Y1
                                     WHERE (Table_ID = 'STAT'
                                        AND TableSub_ID = 'CANA')
                                        OR (Table_ID = 'STAT'
                                            AND TableSub_ID = 'STAT'))
    GROUP BY StateDivorce_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in DEMO_Y1.StateMarriage_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'DEMO_Y1',
          'StateMarriage_CODE',
          StateMarriage_CODE,
          COUNT(1)
     FROM DEMO_Y1
    WHERE LTRIM(RTRIM(StateMarriage_CODE)) <> ''
      AND StateMarriage_CODE NOT IN (SELECT VALUE_CODE
                                       FROM REFM_Y1
                                      WHERE (Table_ID = 'STAT'
                                         AND TableSub_ID = 'CANA')
                                         OR (Table_ID = 'STAT'
                                             AND TableSub_ID = 'STAT'))
    GROUP BY StateMarriage_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in DHLD_Y1.ReasonStatus_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'DHLD_Y1',
          'ReasonStatus_CODE',
          ReasonStatus_CODE,
          COUNT(1)
     FROM DHLD_Y1
    WHERE LTRIM(RTRIM(ReasonStatus_CODE)) <> ''
      AND ReasonStatus_CODE NOT IN (SELECT VALUE_CODE
                                      FROM REFM_Y1
                                     WHERE (Table_ID = 'DHLD'
                                        AND TableSub_ID = 'DHLD')
                                        OR (Table_ID = 'DHLD'
                                            AND TableSub_ID = 'DHLH'))
    GROUP BY ReasonStatus_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in DHLD_Y1.TypeHold_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'DHLD_Y1',
          'TypeHold_CODE',
          TypeHold_CODE,
          COUNT(1)
     FROM DHLD_Y1
    WHERE LTRIM(RTRIM(TypeHold_CODE)) <> ''
      AND TypeHold_CODE NOT IN (SELECT VALUE_CODE
                                  FROM REFM_Y1
                                 WHERE (Table_ID = 'DHLD'
                                    AND TableSub_ID = 'DHLH')
                                    OR (Table_ID = 'DHLD'
                                        AND TableSub_ID = 'TYPH'))
    GROUP BY TypeHold_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in DISH_Y1.ReasonHold_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'DISH_Y1',
          'ReasonHold_CODE',
          ReasonHold_CODE,
          COUNT(1)
     FROM DISH_Y1
    WHERE LTRIM(RTRIM(ReasonHold_CODE)) <> ''
      AND ReasonHold_CODE NOT IN (SELECT VALUE_CODE
                                    FROM REFM_Y1
                                   WHERE (Table_ID = 'DHLD'
                                      AND TableSub_ID = 'CPHI')
                                      OR (Table_ID = 'DISH'
                                          AND TableSub_ID = 'DISH'))
    GROUP BY ReasonHold_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in DMJR_Y1.ReasonStatus_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'DMJR_Y1',
          'ReasonStatus_CODE',
          ReasonStatus_CODE,
          COUNT(1)
     FROM DMJR_Y1
    WHERE LTRIM(RTRIM(ReasonStatus_CODE)) <> ''
      AND ReasonStatus_CODE NOT IN (SELECT VALUE_CODE
                                      FROM REFM_Y1
                                     WHERE (Table_ID = 'CPRO'
                                        AND TableSub_ID = 'URSN')
                                        OR (Table_ID = 'EXMT'
                                            AND TableSub_ID = 'EXMT'))
    GROUP BY ReasonStatus_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in DMJR_Y1.TypeOthpSource_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'DMJR_Y1',
          'TypeOthpSource_CODE',
          TypeOthpSource_CODE,
          COUNT(1)
     FROM DMJR_Y1
    WHERE LTRIM(RTRIM(TypeOthpSource_CODE)) <> ''
      AND TypeOthpSource_CODE NOT IN (SELECT VALUE_CODE
                                        FROM REFM_Y1
                                       WHERE (Table_ID = 'AREN'
                                          AND TableSub_ID = 'SRCT')
                                          OR (Table_ID = 'CCLO'
                                              AND TableSub_ID = 'SRCT')
                                          OR (Table_ID = 'COOP'
                                              AND TableSub_ID = 'SRCT')
                                          OR (Table_ID = 'CRIM'
                                              AND TableSub_ID = 'SRCT')
                                          OR (Table_ID = 'CRPT'
                                              AND TableSub_ID = 'SRCT')
                                          OR (Table_ID = 'CSLN'
                                              AND TableSub_ID = 'SRCT')
                                          OR (Table_ID = 'EMNP'
                                              AND TableSub_ID = 'SRCT')
                                          OR (Table_ID = 'ESTP'
                                              AND TableSub_ID = 'SRCT')
                                          OR (Table_ID = 'FIDM'
                                              AND TableSub_ID = 'SRCT')
                                          OR (Table_ID = 'GTST'
                                              AND TableSub_ID = 'SRCT')
                                          OR (Table_ID = 'IMIW'
                                              AND TableSub_ID = 'SRCT')
                                          OR (Table_ID = 'LIEN'
                                              AND TableSub_ID = 'SRCT')
                                          OR (Table_ID = 'LINT'
                                              AND TableSub_ID = 'SRCT')
                                          OR (Table_ID = 'LSNR'
                                              AND TableSub_ID = 'SRCT')
                                          OR (Table_ID = 'MAPP'
                                              AND TableSub_ID = 'SRCT')
                                          OR (Table_ID = 'NMSN'
                                              AND TableSub_ID = 'SRCT')
                                          OR (Table_ID = 'OBRA'
                                              AND TableSub_ID = 'SRCT')
                                          OR (Table_ID = 'PSOC'
                                              AND TableSub_ID = 'SRCT')
                                          OR (Table_ID = 'ROFO'
                                              AND TableSub_ID = 'SRCT')
                                          OR (Table_ID = 'SEQO'
                                              AND TableSub_ID = 'SRCT')
                                          OR (Table_ID = 'VAPP'
                                              AND TableSub_ID = 'SRCT'))
    GROUP BY TypeOthpSource_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in DSBH_Y1.MediumDisburse_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'DSBH_Y1',
          'MediumDisburse_CODE',
          MediumDisburse_CODE,
          COUNT(1)
     FROM DSBH_Y1
    WHERE LTRIM(RTRIM(MediumDisburse_CODE)) <> ''
      AND MediumDisburse_CODE NOT IN (SELECT VALUE_CODE
                                        FROM REFM_Y1
                                       WHERE (Table_ID = 'CHKM'
                                          AND TableSub_ID = 'CHKM')
                                          OR (Table_ID = 'DSBV'
                                              AND TableSub_ID = 'CHKM'))
    GROUP BY MediumDisburse_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in DSBH_Y1.StatusCheck_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'DSBH_Y1',
          'StatusCheck_CODE',
          StatusCheck_CODE,
          COUNT(1)
     FROM DSBH_Y1
    WHERE LTRIM(RTRIM(StatusCheck_CODE)) <> ''
      AND StatusCheck_CODE NOT IN (SELECT VALUE_CODE
                                     FROM REFM_Y1
                                    WHERE (Table_ID = 'CHKS'
                                       AND TableSub_ID = 'CHKS')
                                       OR (Table_ID = 'VOID'
                                           AND TableSub_ID = 'STOP'))
    GROUP BY StatusCheck_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in EFTR_Y1.Reason_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'EFTR_Y1',
          'Reason_CODE',
          Reason_CODE,
          COUNT(1)
     FROM EFTR_Y1
    WHERE LTRIM(RTRIM(Reason_CODE)) <> ''
      AND Reason_CODE NOT IN (SELECT VALUE_CODE
                                FROM REFM_Y1
                               WHERE (Table_ID = 'EFTR'
                                  AND TableSub_ID = 'EFRJ')
                                  OR (Table_ID = 'EFTR'
                                      AND TableSub_ID = 'EFTR'))
    GROUP BY Reason_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in FSRT_Y1.ServiceState_ADDR column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'FSRT_Y1',
          'ServiceState_ADDR',
          ServiceState_ADDR,
          COUNT(1)
     FROM FSRT_Y1
    WHERE LTRIM(RTRIM(ServiceState_ADDR)) <> ''
      AND ServiceState_ADDR NOT IN (SELECT VALUE_CODE
                                      FROM REFM_Y1
                                     WHERE (Table_ID = 'STAT'
                                        AND TableSub_ID = 'CANA')
                                        OR (Table_ID = 'STAT'
                                            AND TableSub_ID = 'STAT'))
    GROUP BY ServiceState_ADDR

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in ICAS_Y1.RespondInit_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'ICAS_Y1',
          'RespondInit_CODE',
          RespondInit_CODE,
          COUNT(1)
     FROM ICAS_Y1
    WHERE LTRIM(RTRIM(RespondInit_CODE)) <> ''
      AND RespondInit_CODE NOT IN (SELECT VALUE_CODE
                                     FROM REFM_Y1
                                    WHERE (Table_ID = 'INTS'
                                       AND TableSub_ID = 'CATG')
                                       OR (Table_ID = 'WRKL'
                                           AND TableSub_ID = 'INST'))
    GROUP BY RespondInit_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in ICAS_Y1.Status_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'ICAS_Y1',
          'Status_CODE',
          Status_CODE,
          COUNT(1)
     FROM ICAS_Y1
    WHERE LTRIM(RTRIM(Status_CODE)) <> ''
      AND Status_CODE NOT IN (SELECT VALUE_CODE
                                FROM REFM_Y1
                               WHERE (Table_ID = 'CONF'
                                  AND TableSub_ID = 'CON1')
                                  OR (Table_ID = 'CSTS'
                                      AND TableSub_ID = 'CSTS'))
    GROUP BY Status_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in LSUP_Y1.TypeWelfare_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'LSUP_Y1',
          'TypeWelfare_CODE',
          TypeWelfare_CODE,
          COUNT(1)
     FROM LSUP_Y1
    WHERE LTRIM(RTRIM(TypeWelfare_CODE)) <> ''
      AND TypeWelfare_CODE NOT IN (SELECT VALUE_CODE
                                     FROM REFM_Y1
                                    WHERE (Table_ID = 'MHIS'
                                       AND TableSub_ID = 'PGTY')
                                       OR (Table_ID = 'SLOG'
                                           AND TableSub_ID = 'PGTY'))
    GROUP BY TypeWelfare_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in MHIS_Y1.TypeWelfare_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'MHIS_Y1',
          'TypeWelfare_CODE',
          TypeWelfare_CODE,
          COUNT(1)
     FROM MHIS_Y1
    WHERE LTRIM(RTRIM(TypeWelfare_CODE)) <> ''
      AND TypeWelfare_CODE NOT IN (SELECT VALUE_CODE
                                     FROM REFM_Y1
                                    WHERE (Table_ID = 'MHIS'
                                       AND TableSub_ID = 'PGTY')
                                       OR (Table_ID = 'SLOG'
                                           AND TableSub_ID = 'PGTY'))
    GROUP BY TypeWelfare_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in MINS_Y1.Status_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'MINS_Y1',
          'Status_CODE',
          Status_CODE,
          COUNT(1)
     FROM MINS_Y1
    WHERE LTRIM(RTRIM(Status_CODE)) <> ''
      AND Status_CODE NOT IN (SELECT VALUE_CODE
                                FROM REFM_Y1
                               WHERE (Table_ID = 'MAST'
                                  AND TableSub_ID = 'VSTS')
                                  OR (Table_ID = 'MDIN'
                                      AND TableSub_ID = 'PVST'))
    GROUP BY Status_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in MPAT_Y1.ConceptionState_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'MPAT_Y1',
          'ConceptionState_CODE',
          ConceptionState_CODE,
          COUNT(1)
     FROM MPAT_Y1
    WHERE LTRIM(RTRIM(ConceptionState_CODE)) <> ''
      AND ConceptionState_CODE NOT IN (SELECT VALUE_CODE
                                         FROM REFM_Y1
                                        WHERE (Table_ID = 'STAT'
                                           AND TableSub_ID = 'CANA')
                                           OR (Table_ID = 'STAT'
                                               AND TableSub_ID = 'STAT'))
    GROUP BY ConceptionState_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in MPAT_Y1.StateDisestablish_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'MPAT_Y1',
          'StateDisestablish_CODE',
          StateDisestablish_CODE,
          COUNT(1)
     FROM MPAT_Y1
    WHERE LTRIM(RTRIM(StateDisestablish_CODE)) <> ''
      AND StateDisestablish_CODE NOT IN (SELECT VALUE_CODE
                                           FROM REFM_Y1
                                          WHERE (Table_ID = 'STAT'
                                             AND TableSub_ID = 'CANA')
                                             OR (Table_ID = 'STAT'
                                                 AND TableSub_ID = 'STAT'))
    GROUP BY StateDisestablish_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in MPAT_Y1.StateEstablish_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'MPAT_Y1',
          'StateEstablish_CODE',
          StateEstablish_CODE,
          COUNT(1)
     FROM MPAT_Y1
    WHERE LTRIM(RTRIM(StateEstablish_CODE)) <> ''
      AND StateEstablish_CODE NOT IN (SELECT VALUE_CODE
                                        FROM REFM_Y1
                                       WHERE (Table_ID = 'STAT'
                                          AND TableSub_ID = 'CANA')
                                          OR (Table_ID = 'STAT'
                                              AND TableSub_ID = 'STAT'))
    GROUP BY StateEstablish_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in MSSN_Y1.SourceVerify_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'MSSN_Y1',
          'SourceVerify_CODE',
          SourceVerify_CODE,
          COUNT(1)
     FROM MSSN_Y1
    WHERE LTRIM(RTRIM(SourceVerify_CODE)) <> ''
      AND SourceVerify_CODE NOT IN (SELECT VALUE_CODE
                                      FROM REFM_Y1
                                     WHERE (Table_ID = 'CONF'
                                        AND TableSub_ID = 'CON1')
                                        OR (Table_ID = 'DEMO'
                                            AND TableSub_ID = 'VERS'))
    GROUP BY SourceVerify_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in OBLE_Y1.TypeDebt_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'OBLE_Y1',
          'TypeDebt_CODE',
          TypeDebt_CODE,
          COUNT(1)
     FROM OBLE_Y1
    WHERE LTRIM(RTRIM(TypeDebt_CODE)) <> ''
      AND TypeDebt_CODE NOT IN (SELECT VALUE_CODE
                                  FROM REFM_Y1
                                 WHERE (Table_ID = 'DBTP'
                                    AND TableSub_ID = 'DBTP')
                                    OR (Table_ID = 'OWIZ'
                                        AND TableSub_ID = 'ALLO')
                                    OR (Table_ID = 'OWIZ'
                                        AND TableSub_ID = 'FCAR')
                                    OR (Table_ID = 'OWIZ'
                                        AND TableSub_ID = 'NONA'))
    GROUP BY TypeDebt_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in OTHP_Y1.State_ADDR column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'OTHP_Y1 ',
          'State_ADDR',
          State_ADDR,
          COUNT(1)
     FROM OTHP_Y1
    WHERE LTRIM(RTRIM(State_ADDR)) <> ''
      AND State_ADDR NOT IN (SELECT VALUE_CODE
                               FROM REFM_Y1
                              WHERE (Table_ID = 'STAT'
                                 AND TableSub_ID = 'STAT')
                                 OR (Table_ID = 'STAT'
                                     AND TableSub_ID = 'CANA'))
    GROUP BY State_ADDR

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in PLIC_Y1.Profession_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'PLIC_Y1',
          'Profession_CODE',
          Profession_CODE,
          COUNT(1)
     FROM PLIC_Y1
    WHERE LTRIM(RTRIM(Profession_CODE)) <> ''
      AND Profession_CODE NOT IN (SELECT VALUE_CODE
                                    FROM REFM_Y1
                                   WHERE (Table_ID = 'MLIC'
                                      AND TableSub_ID = 'BUSC')
                                      OR (Table_ID = 'MLIC'
                                          AND TableSub_ID = 'PROF'))
    GROUP BY Profession_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in PLIC_Y1.TypeLicense_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'PLIC_Y1',
          'TypeLicense_CODE',
          TypeLicense_CODE,
          COUNT(1)
     FROM PLIC_Y1
    WHERE LTRIM(RTRIM(TypeLicense_CODE)) <> ''
      AND TypeLicense_CODE NOT IN (SELECT VALUE_CODE
                                     FROM REFM_Y1
                                    WHERE (Table_ID = 'LICT'
                                       AND TableSub_ID = 'TYPE')
                                       OR (Table_ID = 'LITP'
                                           AND TableSub_ID = 'LITP'))
    GROUP BY TypeLicense_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in POFL_Y1.Reason_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'POFL_Y1',
          'Reason_CODE',
          Reason_CODE,
          COUNT(1)
     FROM POFL_Y1
    WHERE LTRIM(RTRIM(Reason_CODE)) <> ''
      AND Reason_CODE NOT IN (SELECT VALUE_CODE
                                FROM REFM_Y1
                               WHERE (Table_ID = 'CREC'
                                  AND TableSub_ID = 'NOTI')
                                  OR (Table_ID = 'CREC'
                                      AND TableSub_ID = 'REAS')
                                  OR (Table_ID = 'CREC'
                                      AND TableSub_ID = 'REVR'))
    GROUP BY Reason_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in RCTH_Y1.ReasonBackOut_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'RCTH_Y1',
          'ReasonBackOut_CODE',
          ReasonBackOut_CODE,
          COUNT(1)
     FROM RCTH_Y1
    WHERE LTRIM(RTRIM(ReasonBackOut_CODE)) <> ''
      AND ReasonBackOut_CODE NOT IN (SELECT VALUE_CODE
                                       FROM REFM_Y1
                                      WHERE (Table_ID = 'CREC'
                                         AND TableSub_ID = 'REVR')
                                         OR (Table_ID = 'RCTH'
                                             AND TableSub_ID = 'RCTH')
                                         OR (Table_ID = 'RCTR'
                                             AND TableSub_ID = 'RCTR')
                                         OR (Table_ID = 'RERT'
                                             AND TableSub_ID = 'REAS'))
    GROUP BY ReasonBackOut_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in RCTH_Y1.ReasonStatus_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'RCTH_Y1',
          'ReasonStatus_CODE',
          ReasonStatus_CODE,
          COUNT(1)
     FROM RCTH_Y1
    WHERE LTRIM(RTRIM(ReasonStatus_CODE)) <> ''
      AND ReasonStatus_CODE NOT IN (SELECT VALUE_CODE
                                      FROM REFM_Y1
                                     WHERE (Table_ID = 'RCTH'
                                        AND TableSub_ID = 'RCTH')
                                        OR (Table_ID = 'RERT'
                                            AND TableSub_ID = 'REAS')
                                        OR (Table_ID = 'RERT'
                                            AND TableSub_ID = 'VPRA'))
    GROUP BY ReasonStatus_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in RCTH_Y1.RefundRecipient_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'RCTH_Y1',
          'RefundRecipient_CODE',
          RefundRecipient_CODE,
          COUNT(1)
     FROM RCTH_Y1
    WHERE LTRIM(RTRIM(RefundRecipient_CODE)) <> ''
      AND RefundRecipient_CODE NOT IN (SELECT VALUE_CODE
                                         FROM REFM_Y1
                                        WHERE (Table_ID = 'RERT'
                                           AND TableSub_ID = 'IDEN')
                                           OR (Table_ID = 'RERT'
                                               AND TableSub_ID = 'UNID'))
    GROUP BY RefundRecipient_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in RCTH_Y1.StatusReceipt_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'RCTH_Y1',
          'StatusReceipt_CODE',
          StatusReceipt_CODE,
          COUNT(1)
     FROM RCTH_Y1
    WHERE LTRIM(RTRIM(StatusReceipt_CODE)) <> ''
      AND StatusReceipt_CODE NOT IN (SELECT VALUE_CODE
                                       FROM REFM_Y1
                                      WHERE (Table_ID = 'RCTH'
                                         AND TableSub_ID = 'STAT')
                                         OR (Table_ID = 'RHIS'
                                             AND TableSub_ID = 'DIST')
                                         OR (Table_ID = 'STAB'
                                             AND TableSub_ID = 'STAB'))
    GROUP BY StatusReceipt_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid REFM Value loaded in RCTH_Y1.Tanf_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'REFM',
          'RCTH_Y1',
          'Tanf_CODE',
          Tanf_CODE,
          COUNT(1)
     FROM RCTH_Y1
    WHERE LTRIM(RTRIM(Tanf_CODE)) <> ''
      AND Tanf_CODE NOT IN (SELECT VALUE_CODE
                              FROM REFM_Y1
                             WHERE (Table_ID = 'TANF'
                                AND TableSub_ID = 'TYPE')
                                OR (Table_ID = 'YSNO'
                                    AND TableSub_ID = 'YSNO'))
    GROUP BY Tanf_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid Possible Value loaded in CASE_Y1.AssignedFips_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'PVAL',
          'CaseDetails_T1',
          'AssignedFips_CODE',
          AssignedFips_CODE,
          COUNT(1)
     FROM CaseDetails_T1 A
    WHERE LTRIM(RTRIM(AssignedFips_CODE)) <> ''
      AND AssignedFips_CODE NOT IN (SELECT DISTINCT
                                           X.Fips_CODE
                                      FROM FIPS_Y1 X
                                     WHERE X.Fips_CODE = A.AssignedFips_CODE
                                       AND EndValidity_DATE = '12/31/9999')
    GROUP BY AssignedFips_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid Possible Value loaded in CHLD_Y1.CheckRecipient_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'PVAL',
          'CpHold_T1',
          'CheckRecipient_CODE',
          CheckRecipient_CODE,
          COUNT(1)
     FROM CpHold_T1
    WHERE LTRIM(RTRIM(CheckRecipient_CODE)) <> ''
      AND CheckRecipient_CODE NOT IN ('1', '2', '3')
    GROUP BY CheckRecipient_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid Possible Value loaded in CBOR_Y1.Referral_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'PVAL',
          'CreditBureauOvr_T1',
          'Referral_CODE',
          Referral_CODE,
          COUNT(1)
     FROM CreditBureauOvr_T1
    WHERE LTRIM(RTRIM(Referral_CODE)) <> ''
      AND Referral_CODE NOT IN ('R', 'S')
    GROUP BY Referral_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid Possible Value loaded in EFTR_Y1.CheckRecipient_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'PVAL',
          'ElectronicFundTransfer_T1',
          'CheckRecipient_CODE',
          CheckRecipient_CODE,
          COUNT(1)
     FROM ElectronicFundTransfer_T1
    WHERE LTRIM(RTRIM(CheckRecipient_CODE)) <> ''
      AND CheckRecipient_CODE NOT IN ('1', '2', '3')
    GROUP BY CheckRecipient_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid Possible Value loaded in ESEM_Y1.TypeEntity_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'PVAL',
          'EventSeqMatrix_T1',
          'TypeEntity_CODE',
          TypeEntity_CODE,
          COUNT(1)
     FROM EventSeqMatrix_T1 A
    WHERE LTRIM(RTRIM(TypeEntity_CODE)) <> ''
      AND TypeEntity_CODE NOT IN (SELECT DISTINCT
                                         X.TypeEntity_CODE
                                    FROM EEMA_Y1 X
                                   WHERE A.TypeEntity_CODE = X.TypeEntity_CODE)
    GROUP BY TypeEntity_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid Possible Value loaded in FADT_Y1.Action_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'PVAL',
          'FcrAuditDetails_T1',
          'Action_CODE',
          Action_CODE,
          COUNT(1)
     FROM FcrAuditDetails_T1
    WHERE LTRIM(RTRIM(Action_CODE)) <> ''
      AND Action_CODE NOT IN ('A', 'C', 'D', 'L', 'T')
    GROUP BY Action_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid Possible Value loaded in FADT_Y1.TypeTrans_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'PVAL',
          'FcrAuditDetails_T1',
          'TypeTrans_CODE',
          TypeTrans_CODE,
          COUNT(1)
     FROM FcrAuditDetails_T1
    WHERE LTRIM(RTRIM(TypeTrans_CODE)) <> ''
      AND TypeTrans_CODE NOT IN ('FC', 'FP', 'FR', 'NC',
                                 'FD', 'FS')
    GROUP BY TypeTrans_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid Possible Value loaded in FEDH_Y1.ExcludeAdm_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'PVAL',
          'FederalLastSent_T1',
          'ExcludeAdm_CODE',
          ExcludeAdm_CODE,
          COUNT(1)
     FROM FederalLastSent_T1
    WHERE LTRIM(RTRIM(ExcludeAdm_CODE)) <> ''
      AND ExcludeAdm_CODE NOT IN ('Y', 'N', 'S')
    GROUP BY ExcludeAdm_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid Possible Value loaded in FEDH_Y1.ExcludeDebt_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'PVAL',
          'FederalLastSent_T1',
          'ExcludeDebt_CODE',
          ExcludeDebt_CODE,
          COUNT(1)
     FROM FederalLastSent_T1
    WHERE LTRIM(RTRIM(ExcludeDebt_CODE)) <> ''
      AND ExcludeDebt_CODE NOT IN ('Y', 'N', 'S')
    GROUP BY ExcludeDebt_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid Possible Value loaded in FEDH_Y1.ExcludeVen_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'PVAL',
          'FederalLastSent_T1',
          'ExcludeVen_CODE',
          ExcludeVen_CODE,
          COUNT(1)
     FROM FederalLastSent_T1
    WHERE LTRIM(RTRIM(ExcludeVen_CODE)) <> ''
      AND ExcludeVen_CODE NOT IN ('Y', 'N', 'S')
    GROUP BY ExcludeVen_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid Possible Value loaded in FEDH_Y1.TypeArrear_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'PVAL',
          'FederalLastSent_T1',
          'TypeArrear_CODE',
          TypeArrear_CODE,
          COUNT(1)
     FROM FederalLastSent_T1
    WHERE LTRIM(RTRIM(TypeArrear_CODE)) <> ''
      AND TypeArrear_CODE NOT IN ('A', 'N')
    GROUP BY TypeArrear_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid Possible Value loaded in IFMS_Y1.ExcludeAdm_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'PVAL',
          'InterceptFmsLog_T1',
          'ExcludeAdm_CODE',
          ExcludeAdm_CODE,
          COUNT(1)
     FROM InterceptFmsLog_T1
    WHERE LTRIM(RTRIM(ExcludeAdm_CODE)) <> ''
      AND ExcludeAdm_CODE NOT IN ('Y', 'N', 'S')
    GROUP BY ExcludeAdm_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid Possible Value loaded in IFMS_Y1.ExcludeDebt_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'PVAL',
          'InterceptFmsLog_T1',
          'ExcludeDebt_CODE',
          ExcludeDebt_CODE,
          COUNT(1)
     FROM InterceptFmsLog_T1
    WHERE LTRIM(RTRIM(ExcludeDebt_CODE)) <> ''
      AND ExcludeDebt_CODE NOT IN ('Y', 'N', 'S')
    GROUP BY ExcludeDebt_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid Possible Value loaded in IFMS_Y1.ExcludeFin_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'PVAL',
          'InterceptFmsLog_T1',
          'ExcludeFin_CODE',
          ExcludeFin_CODE,
          COUNT(1)
     FROM InterceptFmsLog_T1
    WHERE LTRIM(RTRIM(ExcludeFin_CODE)) <> ''
      AND ExcludeFin_CODE NOT IN ('Y', 'N', 'S')
    GROUP BY ExcludeFin_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid Possible Value loaded in IFMS_Y1.ExcludeIns_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'PVAL',
          'InterceptFmsLog_T1',
          'ExcludeIns_CODE',
          ExcludeIns_CODE,
          COUNT(1)
     FROM InterceptFmsLog_T1
    WHERE LTRIM(RTRIM(ExcludeIns_CODE)) <> ''
      AND ExcludeIns_CODE NOT IN ('Y', 'N', 'S')
    GROUP BY ExcludeIns_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid Possible Value loaded in IFMS_Y1.ExcludeIrs_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'PVAL',
          'InterceptFmsLog_T1',
          'ExcludeIrs_CODE',
          ExcludeIrs_CODE,
          COUNT(1)
     FROM InterceptFmsLog_T1
    WHERE LTRIM(RTRIM(ExcludeIrs_CODE)) <> ''
      AND ExcludeIrs_CODE NOT IN ('Y', 'N', 'S')
    GROUP BY ExcludeIrs_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid Possible Value loaded in IFMS_Y1.ExcludePas_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'PVAL',
          'InterceptFmsLog_T1',
          'ExcludePas_CODE',
          ExcludePas_CODE,
          COUNT(1)
     FROM InterceptFmsLog_T1
    WHERE LTRIM(RTRIM(ExcludePas_CODE)) <> ''
      AND ExcludePas_CODE NOT IN ('Y', 'N', 'S')
    GROUP BY ExcludePas_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid Possible Value loaded in IFMS_Y1.ExcludeRet_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'PVAL',
          'InterceptFmsLog_T1',
          'ExcludeRet_CODE',
          ExcludeRet_CODE,
          COUNT(1)
     FROM InterceptFmsLog_T1
    WHERE LTRIM(RTRIM(ExcludeRet_CODE)) <> ''
      AND ExcludeRet_CODE NOT IN ('Y', 'N', 'S')
    GROUP BY ExcludeRet_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid Possible Value loaded in IFMS_Y1.ExcludeSal_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'PVAL',
          'InterceptFmsLog_T1',
          'ExcludeSal_CODE',
          ExcludeSal_CODE,
          COUNT(1)
     FROM InterceptFmsLog_T1
    WHERE LTRIM(RTRIM(ExcludeSal_CODE)) <> ''
      AND ExcludeSal_CODE NOT IN ('Y', 'N', 'S')
    GROUP BY ExcludeSal_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid Possible Value loaded in IFMS_Y1.TypeArrear_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'PVAL',
          'InterceptFmsLog_T1',
          'TypeArrear_CODE',
          TypeArrear_CODE,
          COUNT(1)
     FROM InterceptFmsLog_T1
    WHERE LTRIM(RTRIM(TypeArrear_CODE)) <> ''
      AND TypeArrear_CODE NOT IN ('A', 'N')
    GROUP BY TypeArrear_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid Possible Value loaded in ISTX_Y1.ExcludeState_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'PVAL',
          'InterceptStxLog_T1',
          'ExcludeState_CODE',
          ExcludeState_CODE,
          COUNT(1)
     FROM InterceptStxLog_T1
    WHERE LTRIM(RTRIM(ExcludeState_CODE)) <> ''
      AND ExcludeState_CODE NOT IN ('Y', 'N', 'S')
    GROUP BY ExcludeState_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid Possible Value loaded in ISTX_Y1.TypeArrear_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'PVAL',
          'InterceptStxLog_T1',
          'TypeArrear_CODE',
          TypeArrear_CODE,
          COUNT(1)
     FROM InterceptStxLog_T1
    WHERE LTRIM(RTRIM(TypeArrear_CODE)) <> ''
      AND TypeArrear_CODE NOT IN ('A', 'N')
    GROUP BY TypeArrear_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid Possible Value loaded in ISTX_Y1.TypeTransaction_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'PVAL',
          'InterceptStxLog_T1',
          'TypeTransaction_CODE',
          TypeTransaction_CODE,
          COUNT(1)
     FROM InterceptStxLog_T1
    WHERE LTRIM(RTRIM(TypeTransaction_CODE)) <> ''
      AND TypeTransaction_CODE NOT IN ('I', 'D', 'C', 'A', 'L')
    GROUP BY TypeTransaction_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid Possible Value loaded in ICAS_Y1.IVDOutOfStateCountyFips_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'PVAL',
          'InterstateCases_T1',
          'IVDOutOfStateCountyFips_CODE',
          IVDOutOfStateCountyFips_CODE,
          COUNT(1)
     FROM InterstateCases_T1 A
    WHERE LTRIM(RTRIM(IVDOutOfStateCountyFips_CODE)) <> ''
      AND IVDOutOfStateCountyFips_CODE NOT IN (SELECT DISTINCT
                                                      X.CountyFips_CODE
                                                 FROM FIPS_Y1 X
                                                WHERE X.CountyFips_CODE = A.IVDOutOfStateCountyFips_CODE
                                                  AND EndValidity_DATE = '12/31/9999')
      AND A.EndValidity_DATE = '12/31/9999'
    GROUP BY IVDOutOfStateCountyFips_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid Possible Value loaded in ICAS_Y1.IVDOutOfStateOfficeFips_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'PVAL',
          'InterstateCases_T1',
          'IVDOutOfStateOfficeFips_CODE',
          IVDOutOfStateOfficeFips_CODE,
          COUNT(1)
     FROM InterstateCases_T1 A
    WHERE LTRIM(RTRIM(IVDOutOfStateOfficeFips_CODE)) <> ''
      AND IVDOutOfStateOfficeFips_CODE NOT IN (SELECT DISTINCT
                                                      X.OfficeFips_CODE
                                                 FROM FIPS_Y1 X
                                                WHERE X.OfficeFips_CODE = A.IVDOutOfStateOfficeFips_CODE
                                                  AND EndValidity_DATE = '12/31/9999')
      AND A.EndValidity_DATE = '12/31/9999'
    GROUP BY IVDOutOfStateOfficeFips_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid Possible Value loaded in DMJR_Y1.ActivityMajor_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'PVAL',
          'MajorActivityDiary_T1',
          'ActivityMajor_CODE',
          ActivityMajor_CODE,
          COUNT(1)
     FROM MajorActivityDiary_T1 A
    WHERE LTRIM(RTRIM(ActivityMajor_CODE)) <> ''
      AND NOT EXISTS(SELECT 1
                       FROM AMJR_Y1 X
                      WHERE X.ActivityMajor_CODE = A.ActivityMajor_CODE)
    GROUP BY ActivityMajor_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid Possible Value loaded in DMNR_Y1.ActivityMajor_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'PVAL',
          'MinorActivityDiary_T1',
          'ActivityMajor_CODE',
          ActivityMajor_CODE,
          COUNT(1)
     FROM MinorActivityDiary_T1 A
    WHERE LTRIM(RTRIM(ActivityMajor_CODE)) <> ''
      AND NOT EXISTS(SELECT 1
                       FROM AMJR_Y1 X
                      WHERE X.ActivityMajor_CODE = A.ActivityMajor_CODE)
    GROUP BY ActivityMajor_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid Possible Value loaded in DMNR_Y1.ActivityMinor_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'PVAL',
          'MinorActivityDiary_T1',
          'ActivityMinor_CODE',
          ActivityMinor_CODE,
          COUNT(1)
     FROM MinorActivityDiary_T1 A
    WHERE LTRIM(RTRIM(ActivityMinor_CODE)) <> ''
      AND NOT EXISTS(SELECT 1
                       FROM AMNR_Y1 X
                      WHERE X.ActivityMinor_CODE = A.ActivityMinor_CODE)
    GROUP BY ActivityMinor_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid Possible Value loaded in DMNR_Y1.ActivityMinorNext_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'PVAL',
          'MinorActivityDiary_T1',
          'ActivityMinorNext_CODE',
          ActivityMinorNext_CODE,
          COUNT(1)
     FROM MinorActivityDiary_T1 A
    WHERE LTRIM(RTRIM(ActivityMinorNext_CODE)) <> ''
      AND NOT EXISTS(SELECT 1
                       FROM AMNR_Y1 X
                      WHERE X.ActivityMinor_CODE = A.ActivityMinorNext_CODE)
    GROUP BY ActivityMinorNext_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid Possible Value loaded in NOTE_Y1.Subject_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'PVAL',
          'Notes_T1',
          'Subject_CODE',
          Subject_CODE,
          COUNT(1)
     FROM Notes_T1 A
    WHERE LTRIM(RTRIM(Subject_CODE)) <> ''
      AND NOT EXISTS(SELECT 1
                       FROM AMNR_Y1 X
                      WHERE X.ActivityMinor_CODE = A.Subject_CODE)
    GROUP BY Subject_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid Possible Value loaded in OBLE_Y1.Fips_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'PVAL',
          'Obligation_T1',
          'Fips_CODE',
          Fips_CODE,
          COUNT(1)
     FROM Obligation_T1 A
    WHERE LTRIM(RTRIM(Fips_CODE)) <> ''
      AND NOT EXISTS(SELECT 1
                       FROM FIPS_Y1 B
                      WHERE A.Fips_CODE = B.Fips_CODE
                        AND EndValidity_DATE = '12/31/9999')
      AND A.EndValidity_DATE = '12/31/9999'
    GROUP BY Fips_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid Possible Value loaded in OTHP_Y1.Fips_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'PVAL',
          'OtherParty_T1',
          'Fips_CODE',
          Fips_CODE,
          COUNT(1)
     FROM OtherParty_T1 A
    WHERE LTRIM(RTRIM(Fips_CODE)) <> ''
      AND NOT EXISTS(SELECT 1
                       FROM FIPS_Y1 B
                      WHERE A.Fips_CODE = B.Fips_CODE
                        AND EndValidity_DATE = '12/31/9999')
      AND A.EndValidity_DATE = '12/31/9999'
    GROUP BY Fips_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid Possible Value loaded in POFL_Y1.RecoupmentPayee_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'PVAL',
          'PayeeOffsetLog_T1',
          'RecoupmentPayee_CODE',
          RecoupmentPayee_CODE,
          COUNT(1)
     FROM PayeeOffsetLog_T1
    WHERE LTRIM(RTRIM(RecoupmentPayee_CODE)) <> ''
      AND RecoupmentPayee_CODE NOT IN ('S', 'D')
    GROUP BY RecoupmentPayee_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid Possible Value loaded in PLIC_Y1.IssuingState_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'PVAL',
          'ProfessionalLicense_T1',
          'IssuingState_CODE',
          IssuingState_CODE,
          COUNT(1)
     FROM ProfessionalLicense_T1
    WHERE LTRIM(RTRIM(IssuingState_CODE)) <> ''
      AND NOT EXISTS(SELECT 1
                       FROM REFM_Y1
                      WHERE Table_ID = 'STAT'
                        AND TableSub_ID = 'STAT'
                        AND Value_CODE = IssuingState_CODE)
    GROUP BY IssuingState_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid Possible Value loaded in RCTH_Y1.Fips_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'PVAL',
          'Receipt_T1',
          'Fips_CODE',
          Fips_CODE,
          COUNT(1)
     FROM Receipt_T1 A
    WHERE LTRIM(RTRIM(Fips_CODE)) <> ''
      AND NOT EXISTS(SELECT 1
                       FROM FIPS_Y1 B
                      WHERE A.Fips_CODE = B.Fips_CODE
                        AND EndValidity_DATE = '12/31/9999')
      AND A.EndValidity_DATE = '12/31/9999'
    GROUP BY Fips_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid Possible Value loaded in RECP_Y1.CheckRecipient_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'PVAL',
          'RecoupmentPercent_T1',
          'CheckRecipient_CODE',
          CheckRecipient_CODE,
          COUNT(1)
     FROM RecoupmentPercent_T1
    WHERE LTRIM(RTRIM(CheckRecipient_CODE)) <> ''
      AND CheckRecipient_CODE NOT IN (1, 2, 3)
    GROUP BY CheckRecipient_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid Possible Value loaded in SWKS_Y1.ActivityMajor_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'PVAL',
          'Schedule_T1',
          'ActivityMajor_CODE',
          ActivityMajor_CODE,
          COUNT(1)
     FROM Schedule_T1 A
    WHERE LTRIM(RTRIM(ActivityMajor_CODE)) <> ''
      AND NOT EXISTS(SELECT 1
                       FROM AMJR_Y1 X
                      WHERE X.ActivityMajor_CODE = A.ActivityMajor_CODE)
    GROUP BY ActivityMajor_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid Possible Value loaded in SWKS_Y1.ActivityMinor_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'PVAL',
          'Schedule_T1',
          'ActivityMinor_CODE',
          ActivityMinor_CODE,
          COUNT(1)
     FROM Schedule_T1 A
    WHERE LTRIM(RTRIM(ActivityMinor_CODE)) <> ''
      AND NOT EXISTS(SELECT 1
                       FROM AMNR_Y1 X
                      WHERE X.ActivityMinor_CODE = A.ActivityMinor_CODE)
    GROUP BY ActivityMinor_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid Possible Value loaded in SWRK_Y1.Day_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'PVAL',
          'SchWorkerModel_T1',
          'Day_CODE',
          Day_CODE,
          COUNT(1)
     FROM SchWorkerModel_T1
    WHERE LTRIM(RTRIM(Day_CODE)) <> ''
      AND Day_CODE NOT BETWEEN 1 AND 7
    GROUP BY Day_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid Possible Value loaded in SORD_Y1.CejFips_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'PVAL',
          'SupportOrder_T1',
          'CejFips_CODE',
          CejFips_CODE,
          COUNT(1)
     FROM SupportOrder_T1 A
    WHERE LTRIM(RTRIM(CejFips_CODE)) <> ''
      AND NOT EXISTS(SELECT 1
                       FROM FIPS_Y1 B
                      WHERE A.CejFips_CODE = B.Fips_CODE
                        AND EndValidity_DATE = '12/31/9999')
      AND A.EndValidity_DATE = '12/31/9999'
    GROUP BY CejFips_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid Possible Value loaded in SORD_Y1.IssuingOrderFips_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'PVAL',
          'SupportOrder_T1',
          'IssuingOrderFips_CODE',
          IssuingOrderFips_CODE,
          COUNT(1)
     FROM SupportOrder_T1 A
    WHERE LTRIM(RTRIM(IssuingOrderFips_CODE)) <> ''
      AND NOT EXISTS(SELECT 1
                       FROM FIPS_Y1 B
                      WHERE A.IssuingOrderFips_CODE = B.Fips_CODE
                        AND EndValidity_DATE = '12/31/9999')
      AND A.EndValidity_DATE = '12/31/9999'
    GROUP BY IssuingOrderFips_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid Possible Value loaded in USRL_Y1.AlphaRangeFrom_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'PVAL',
          'UserOfficeRoles_T1',
          'AlphaRangeFrom_CODE',
          AlphaRangeFrom_CODE,
          COUNT(1)
     FROM UserOfficeRoles_T1
    WHERE LTRIM(RTRIM(AlphaRangeFrom_CODE)) <> ''
      AND ISNUMERIC(AlphaRangeFrom_CODE) = 1
    GROUP BY AlphaRangeFrom_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid Possible Value loaded in USRL_Y1.AlphaRangeTo_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'PVAL',
          'UserOfficeRoles_T1',
          'AlphaRangeTo_CODE',
          AlphaRangeTo_CODE,
          COUNT(1)
     FROM UserOfficeRoles_T1
    WHERE LTRIM(RTRIM(AlphaRangeTo_CODE)) <> ''
      AND ISNUMERIC(AlphaRangeTo_CODE) = 1
    GROUP BY AlphaRangeTo_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid Possible Value loaded in ACES_Y1.ReasonStatus_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'PVAL',
          'ActiveEstablishment_T1',
          'ReasonStatus_CODE',
          ReasonStatus_CODE,
          COUNT(1)
     FROM ActiveEstablishment_T1
    WHERE LTRIM(RTRIM(ReasonStatus_CODE)) <> ''
      AND ReasonStatus_CODE NOT IN ('SI', 'SC', 'BI', 'BC')
    GROUP BY ReasonStatus_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid Possible Value loaded in ACES_Y1.StatusEstablish_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'PVAL',
          'ActiveEstablishment_T1',
          'StatusEstablish_CODE',
          StatusEstablish_CODE,
          COUNT(1)
     FROM ActiveEstablishment_T1
    WHERE LTRIM(RTRIM(StatusEstablish_CODE)) <> ''
      AND StatusEstablish_CODE NOT IN ('C', 'O')
    GROUP BY StatusEstablish_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid Possible Value loaded in CASE_Y1.Intercept_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'PVAL',
          'CaseDetails_T1',
          'Intercept_CODE',
          Intercept_CODE,
          COUNT(1)
     FROM CaseDetails_T1
    WHERE LTRIM(RTRIM(Intercept_CODE)) <> ''
      AND Intercept_CODE NOT IN ('S', 'I', 'B', 'N')
    GROUP BY Intercept_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid Possible Value loaded in EFTR_Y1.TypeAccount_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'PVAL',
          'ElectronicFundTransfer_T1',
          'TypeAccount_CODE',
          TypeAccount_CODE,
          COUNT(1)
     FROM ElectronicFundTransfer_T1
    WHERE LTRIM(RTRIM(TypeAccount_CODE)) <> ''
      AND TypeAccount_CODE NOT IN ('C', 'S')
    GROUP BY TypeAccount_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid Possible Value loaded in FADT_Y1.ResponseFcr_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'PVAL',
          'FcrAuditDetails_T1',
          'ResponseFcr_CODE',
          ResponseFcr_CODE,
          COUNT(1)
     FROM FcrAuditDetails_T1
    WHERE LTRIM(RTRIM(ResponseFcr_CODE)) <> ''
      AND ResponseFcr_CODE NOT IN ('A', 'R', 'W', 'P')
    GROUP BY ResponseFcr_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid Possible Value loaded in FEDH_Y1.TypeTransaction_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'PVAL',
          'FederalLastSent_T1',
          'TypeTransaction_CODE',
          TypeTransaction_CODE,
          COUNT(1)
     FROM FederalLastSent_T1
    WHERE LTRIM(RTRIM(TypeTransaction_CODE)) <> ''
      AND TypeTransaction_CODE NOT IN ('A', 'B', 'C', 'D',
                                       'L', 'M', 'R', 'S',
                                       'I', 'Z')
    GROUP BY TypeTransaction_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid Possible Value loaded in IFMS_Y1.TypeTransaction_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'PVAL',
          'InterceptFmsLog_T1',
          'TypeTransaction_CODE',
          TypeTransaction_CODE,
          COUNT(1)
     FROM InterceptFmsLog_T1
    WHERE LTRIM(RTRIM(TypeTransaction_CODE)) <> ''
      AND TypeTransaction_CODE NOT IN ('A', 'B', 'C', 'D',
                                       'L', 'M', 'R', 'S',
                                       'I', 'Z')
    GROUP BY TypeTransaction_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid Possible Value loaded in IVMG_Y1.WelfareElig_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'PVAL',
          'IvaIveGrant_T1',
          'WelfareElig_CODE',
          WelfareElig_CODE,
          COUNT(1)
     FROM IvaIveGrant_T1
    WHERE LTRIM(RTRIM(WelfareElig_CODE)) <> ''
      AND WelfareElig_CODE NOT IN ('A', 'F')
    GROUP BY WelfareElig_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid Possible Value loaded in LSUP_Y1.TypeRecord_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'PVAL',
          'LogSupport_T1',
          'TypeRecord_CODE',
          TypeRecord_CODE,
          COUNT(1)
     FROM LogSupport_T1
    WHERE LTRIM(RTRIM(TypeRecord_CODE)) <> ''
      AND TypeRecord_CODE NOT IN ('O', 'P', 'C')
    GROUP BY TypeRecord_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid Possible Value loaded in NOTE_Y1.OpenCases_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'PVAL',
          'Notes_T1',
          'OpenCases_CODE',
          OpenCases_CODE,
          COUNT(1)
     FROM Notes_T1
    WHERE LTRIM(RTRIM(OpenCases_CODE)) <> ''
      AND OpenCases_CODE NOT IN ('C', 'A')
    GROUP BY OpenCases_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid Possible Value loaded in NOTE_Y1.TypeAssigned_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'PVAL',
          'Notes_T1',
          'TypeAssigned_CODE',
          TypeAssigned_CODE,
          COUNT(1)
     FROM Notes_T1
    WHERE LTRIM(RTRIM(TypeAssigned_CODE)) <> ''
      AND TypeAssigned_CODE NOT IN ('W', 'R')
    GROUP BY TypeAssigned_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid Possible Value loaded in RSDU_Y1.PaymentSourceSdu_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'PVAL',
          'ReceiptSduReference_T1',
          'PaymentSourceSdu_CODE',
          PaymentSourceSdu_CODE,
          COUNT(1)
     FROM ReceiptSduReference_T1
    WHERE LTRIM(RTRIM(PaymentSourceSdu_CODE)) <> ''
      AND PaymentSourceSdu_CODE NOT IN ('IND', 'EMP', 'INT', 'OTH', 'FIN')
    GROUP BY PaymentSourceSdu_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid Possible Value loaded in SLST_Y1.TypeTransaction_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'PVAL',
          'StateLastSent_T1',
          'TypeTransaction_CODE',
          TypeTransaction_CODE,
          COUNT(1)
     FROM StateLastSent_T1
    WHERE LTRIM(RTRIM(TypeTransaction_CODE)) <> ''
      AND TypeTransaction_CODE NOT IN ('A', 'L', 'I', 'C', 'D')
    GROUP BY TypeTransaction_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid Possible Value loaded in SORD_Y1.CoverageDental_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'PVAL',
          'SupportOrder_T1',
          'CoverageDental_CODE',
          CoverageDental_CODE,
          COUNT(1)
     FROM SupportOrder_T1
    WHERE LTRIM(RTRIM(CoverageDental_CODE)) <> ''
      AND CoverageDental_CODE NOT IN ('C', 'A', 'B', 'N')
    GROUP BY CoverageDental_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid Possible Value loaded in SORD_Y1.CoverageDrug_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'PVAL',
          'SupportOrder_T1',
          'CoverageDrug_CODE',
          CoverageDrug_CODE,
          COUNT(1)
     FROM SupportOrder_T1
    WHERE LTRIM(RTRIM(CoverageDrug_CODE)) <> ''
      AND CoverageDrug_CODE NOT IN ('C', 'A', 'B', 'N')
    GROUP BY CoverageDrug_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid Possible Value loaded in SORD_Y1.CoverageMedical_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'PVAL',
          'SupportOrder_T1',
          'CoverageMedical_CODE',
          CoverageMedical_CODE,
          COUNT(1)
     FROM SupportOrder_T1
    WHERE LTRIM(RTRIM(CoverageMedical_CODE)) <> ''
      AND CoverageMedical_CODE NOT IN ('C', 'A', 'B', 'N')
    GROUP BY CoverageMedical_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid Possible Value loaded in SORD_Y1.CoverageMental_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'PVAL',
          'SupportOrder_T1',
          'CoverageMental_CODE',
          CoverageMental_CODE,
          COUNT(1)
     FROM SupportOrder_T1
    WHERE LTRIM(RTRIM(CoverageMental_CODE)) <> ''
      AND CoverageMental_CODE NOT IN ('C', 'A', 'B', 'N')
    GROUP BY CoverageMental_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid Possible Value loaded in SORD_Y1.CoverageOthers_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'PVAL',
          'SupportOrder_T1',
          'CoverageOthers_CODE',
          CoverageOthers_CODE,
          COUNT(1)
     FROM SupportOrder_T1
    WHERE LTRIM(RTRIM(CoverageOthers_CODE)) <> ''
      AND CoverageOthers_CODE NOT IN ('C', 'A', 'B', 'N')
    GROUP BY CoverageOthers_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid Possible Value loaded in SORD_Y1.CoverageVision_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'PVAL',
          'SupportOrder_T1',
          'CoverageVision_CODE',
          CoverageVision_CODE,
          COUNT(1)
     FROM SupportOrder_T1
    WHERE LTRIM(RTRIM(CoverageVision_CODE)) <> ''
      AND CoverageVision_CODE NOT IN ('C', 'A', 'B', 'N')
    GROUP BY CoverageVision_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid Possible Value loaded in URCT_Y1.IdentificationStatus_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'PVAL',
          'UnidentifiedReceipts_T1',
          'IdentificationStatus_CODE',
          IdentificationStatus_CODE,
          COUNT(1)
     FROM UnidentifiedReceipts_T1
    WHERE LTRIM(RTRIM(IdentificationStatus_CODE)) <> ''
      AND IdentificationStatus_CODE NOT IN ('U', 'I', 'O')
    GROUP BY IdentificationStatus_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid Possible Value loaded in VAPP_Y1.DopPresumedFather_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'PVAL',
          'VoluntaryAckPatProcess_T1',
          'DopPresumedFather_CODE',
          DopPresumedFather_CODE,
          COUNT(1)
     FROM VoluntaryAckPatProcess_T1
    WHERE LTRIM(RTRIM(DopPresumedFather_CODE)) <> ''
      AND DopPresumedFather_CODE NOT IN ('M', 'N')
    GROUP BY DopPresumedFather_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid Possible Value loaded in VAPP_Y1.NoPresumedFather_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'PVAL',
          'VoluntaryAckPatProcess_T1',
          'NoPresumedFather_CODE',
          NoPresumedFather_CODE,
          COUNT(1)
     FROM VoluntaryAckPatProcess_T1
    WHERE LTRIM(RTRIM(NoPresumedFather_CODE)) <> ''
      AND NoPresumedFather_CODE NOT IN ('M', 'N', 'L', 'O', 'P')
    GROUP BY NoPresumedFather_CODE

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SET @Ls_Sql_TEXT = 'Invalid Possible Value loaded in VAPP_Y1.VapPresumedFather_CODE column.'

   INSERT CRPR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY)
   SELECT @Ls_Sql_TEXT,
          'PVAL',
          'VoluntaryAckPatProcess_T1',
          'VapPresumedFather_CODE',
          VapPresumedFather_CODE,
          COUNT(1)
     FROM VoluntaryAckPatProcess_T1
    WHERE LTRIM(RTRIM(VapPresumedFather_CODE)) <> ''
      AND VapPresumedFather_CODE NOT IN ('M', 'N')
    GROUP BY VapPresumedFather_CODE;

	INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRPRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          'COMMON$SP_VALIDATE_CONVERSIONDATA_REFM_PVAL Execution IS Completed. Please CHECK Result IN CRPR_Y1 TABLE',
          'S';
  END Try

  BEGIN Catch
   SELECT 'Error IN ' + ERROR_PROCEDURE () + ' PROCEDURE' + '. Error DESC - ' + SUBSTRING (ERROR_MESSAGE (), 1, 200) + '. Error Line No - ' + CAST (ERROR_LINE () AS VARCHAR) + '. Error Number - ' + CAST (ERROR_NUMBER () AS VARCHAR) + '. Error EXECUTE Location - ' + @Ls_Sql_TEXT
  END Catch
 END

GO
