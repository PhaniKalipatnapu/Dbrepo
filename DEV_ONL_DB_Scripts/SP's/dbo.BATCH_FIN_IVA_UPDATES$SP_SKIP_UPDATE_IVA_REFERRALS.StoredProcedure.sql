/****** Object:  StoredProcedure [dbo].[BATCH_FIN_IVA_UPDATES$SP_SKIP_UPDATE_IVA_REFERRALS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_FIN_IVA_UPDATES$SP_SKIP_UPDATE_IVA_REFERRALS
Programmer Name	:	IMP Team.
Description		:	This process reads the data from the temporary load tables to skip the records based on the business conditions,
					reopens the closed case and/or adds child to reopened case, and/or changes the program type to match the incoming program type.
Frequency		:	DAILY
Developed On	:	04/12/2012
Called By		:	NONE
Called On		:	BATCH_COMMON$SP_GET_BATCH_DETAILS2,
					BATCH_COMMON$BATE_LOG,  
					BATCH_COMMON$BSTL_LOG,
					BATCH_COMMON$SP_UPDATE_PARM_DATE,
					BATCH_FIN_IVA_UPDATES$SP_CASE_MHIS_UPDATE
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_FIN_IVA_UPDATES$SP_SKIP_UPDATE_IVA_REFERRALS] (
 @Ad_Run_DATE              DATE,
 @Ac_Job_ID                CHAR(7),
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  --SET NOCOUNT ON After BEGIN Statement:
  SET NOCOUNT ON;

  --Variable Declarations After SET NOCOUNT ON Statement:
  DECLARE @Li_RowsCount_QNTY                    SMALLINT = 0,
          @Ln_ChildAge19_NUMB                   NUMERIC(2) = 19,
          @Ln_ChildAge12_NUMB                   NUMERIC(2) = 12,
          @Ln_UnknownMci_IDNO                   NUMERIC(10) = 999995,
          @Lc_StatusFailed_CODE                 CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE                CHAR(1) = 'S',
          @Lc_IntactFamilyStatusY_CODE          CHAR(1) = 'Y',
          @Lc_TypeWelfareTANF_CODE              CHAR(1) = 'A',
          @Lc_Percenatage_TEXT                  CHAR(1) = '%',
          @Lc_CaseRelationshipCp_CODE           CHAR(1) = 'C',
          @Lc_CaseRelationshipChild_CODE        CHAR(1) = 'D',
          @Lc_CaseRelationshipNcpA_CODE         CHAR(1) = 'A',
          @Lc_CaseRelationshipNcpP_CODE         CHAR(1) = 'P',
          @Lc_TypeWelfareMedicaid_CODE          CHAR(1) = 'M',
          @Lc_TypeWelfareNonTanf_CODE           CHAR(1) = 'N',
          @Lc_TypeWelfareIVAPurchaseOfCare_CODE CHAR(1) = 'C',
          @Lc_StatusCaseOpen_CODE               CHAR(1) = 'O',
          @Lc_StatusCaseClosed_CODE             CHAR(1) = 'C',
          @Lc_CaseMemberStatusActive_CODE       CHAR(1) = 'A',
          @Lc_RespondInitI_CODE                 CHAR(1) = 'I',
          @Lc_RespondInitC_CODE                 CHAR(1) = 'C',
          @Lc_RespondInitT_CODE                 CHAR(1) = 'T',
          @Lc_RespondInitN_CODE                 CHAR(1) = 'N',
          @Lc_RespondInitR_CODE                 CHAR(1) = 'R',
          @Lc_RespondInitY_CODE                 CHAR(1) = 'Y',
          @Lc_RespondInitS_CODE                 CHAR(1) = 'S',
		  --13128 - CR0344 PFA and Case Assignment Issues 20131226 -START-
		  @Lc_TypeCaseH_CODE                    CHAR(1) = 'H',
		  --13128 - CR0344 PFA and Case Assignment Issues 20131226 -END-
          @Lc_ReferralProcessD_CODE             CHAR(1) = 'D',
          @Lc_ApplicationStatusC_CODE           CHAR(1) = 'C',
          @Lc_ProcessY_CODE                     CHAR(1) = 'Y',
          @Lc_ProcessN_CODE                     CHAR(1) = 'N',
          @Lc_ProcessS_CODE                     CHAR(1) = 'S',
          @Lc_TypeCaseA_CODE                    CHAR(1) = 'A',
          @Lc_TypeCaseN_CODE                    CHAR(1) = 'N',
          @Lc_TypeErrorWarning_CODE             CHAR(1) = 'W',
          @Lc_Space_TEXT                        CHAR(1) = ' ',
          @Lc_SubsystemCI_CODE                  CHAR(2) = 'CI',
          @Lc_CaseCategoryMO_CODE               CHAR(2) = 'MO',
          @Lc_CaseCategoryPO_CODE               CHAR(2) = 'PO',
          @Lc_ReasonForPendingRC_CODE           CHAR(2) = 'RC',
          @Lc_ReasonForPendingCC_CODE           CHAR(2) = 'CC',
          @Lc_ReasonForPendingAG_CODE           CHAR(2) = 'AG',
          @Lc_ReasonForPendingUN_CODE           CHAR(2) = 'UN',
		  --13128 - CR0344 PFA and Case Assignment Issues 20131226 -START-
		  @Lc_ReasonForPendingFM_CODE           CHAR(2) = 'FM',
		  @Lc_ReasonForPendingPM_CODE           CHAR(2) = 'PM',
		  @Lc_ReasonForPendingPN_CODE           CHAR(2) = 'PN',
          --13128 - CR0344 PFA and Case Assignment Issues 20131226 -END-
		  @Lc_RsnStatusCaseEX_CODE              CHAR(2) = 'EX',
          @Lc_RsnStatusCaseDI_CODE              CHAR(2) = 'DI',
          @Lc_RsnStatusCaseGV_CODE              CHAR(2) = 'GV',
          @Lc_RsnStatusCaseUM_CODE              CHAR(2) = 'UM',
          @Lc_RsnStatusCaseFN_CODE              CHAR(2) = 'FN',
          @Lc_RsnStatusCasePB_CODE              CHAR(2) = 'PB',
          @Lc_RsnStatusCasePR_CODE              CHAR(2) = 'PR',
          @Lc_RsnStatusCasePK_CODE              CHAR(2) = 'PK',
          @Lc_RsnStatusCasePC_CODE              CHAR(2) = 'PC',
          @Lc_RsnStatusCaseUC_CODE              CHAR(2) = 'UC',
          @Lc_RsnStatusCaseUB_CODE              CHAR(2) = 'UB',
          @Lc_ActivityMajorCase_CODE            CHAR(4) = 'CASE',
          @Lc_ActivityMinorCam3c_CODE           CHAR(5) = 'CAM3C',
          @Lc_Msg_CODE                          CHAR(5) = ' ',
          @Lc_ErrorE0102_CODE                   CHAR(5) = 'E0102',
          @Ls_InvalidMci_TEXT                   VARCHAR(50) = 'INVALID PARTICIPANT MCI',
          @Ls_Procedure_NAME                    VARCHAR(100) = 'BATCH_FIN_IVA_UPDATES$SP_SKIP_UPDATE_IVA_REFERRALS',
          @Ls_Sql_TEXT                          VARCHAR(2000) = ' ',
          @Ls_DescriptionError_TEXT             VARCHAR(4000) = ' ',
          @Ls_ErrorMessage_TEXT                 VARCHAR(4000) = ' ',
          @Ls_Sqldata_TEXT                      VARCHAR(5000) = ' ',
          @Ld_High_DATE                         DATE = '12/31/9999';
  DECLARE @Ln_Zero_NUMB      NUMERIC(5) = 0,
          @Ln_ErrorLine_NUMB NUMERIC(11) = 0,
          @Ln_Error_NUMB     NUMERIC(11) = 0,
          @Ld_Run_DATE       DATE = @Ad_Run_DATE,
          @Ld_Start_DATE     DATETIME2;

  IF OBJECT_ID('tempdb..#TempClosedCasesToReopen_P1') IS NOT NULL
   BEGIN
    DROP TABLE #TempClosedCasesToReopen_P1;
   END;

  CREATE TABLE #TempClosedCasesToReopen_P1
   (
     Seq_IDNO               NUMERIC(19, 0),
     Case_IDNO              NUMERIC(6),
     RsnStatusCase_CODE     CHAR(2),
     ChildMci_IDNO          NUMERIC(10),
     NcpMci_IDNO            NUMERIC(10),
     MappedTypeWelfare_CODE CHAR(1),
     CaseWelfare_IDNO       NUMERIC(10),
     IVACaseType_CODE       CHAR(1)
   );

  BEGIN TRY
   -- Selecting the Batch Start Time
   SET @Ls_Sql_TEXT = 'GET BATCH START DATE';
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   --13536 - CR0396 Updates Needed in BATCH_FIN_IVA_Updates 20140620 -START-
   SET @Ls_Sql_TEXT = 'DELETE ##TempSeqIdno_P1 - SKIP PROCESS';
   DELETE ##TempSeqIdno_P1;
   --13536 - CR0396 Updates Needed in BATCH_FIN_IVA_Updates 20140620 -END-
   SET @Ls_Sql_TEXT = 'UPDATE LIVAD_Y1 FOR THE DUPLICATE DETAILS RECORDS BASED ON ApSequence_NUMB';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Ac_Job_ID, '');

   DELETE a
     FROM LIVAD_Y1 a,
          (SELECT MAX(CAST(ApSequence_NUMB AS NUMERIC)) AS ApSequence_NUMB,
                  CaseWelfare_IDNO AS CaseWelfare_IDNO,
                  CpMci_IDNO AS CpMci_IDNO,
                  NcpMci_IDNO AS NcpMci_IDNO,
                  AgSequence_NUMB AS AgSequence_NUMB,
                  FileLoad_DATE AS FileLoad_DATE
             FROM LIVAD_Y1
            WHERE Process_CODE = @Lc_ProcessN_CODE
            GROUP BY CaseWelfare_IDNO,
                     CpMci_IDNO,
                     NcpMci_IDNO,
                     AgSequence_NUMB,
                     FileLoad_DATE
           HAVING COUNT(1) > 1)b
    WHERE a.Process_CODE = @Lc_ProcessN_CODE
      AND a.FileLoad_DATE = b.FileLoad_DATE
      AND a.CaseWelfare_IDNO = b.CaseWelfare_IDNO
      AND a.CpMci_IDNO = b.CpMci_IDNO
      AND a.NcpMci_IDNO = b.NcpMci_IDNO
      AND a.AgSequence_NUMB = b.AgSequence_NUMB
      AND a.ApSequence_NUMB != b.ApSequence_NUMB;
   
   SET @Ls_Sql_TEXT = 'DELETE LIVAD_Y1 FOR THE DUPLICATE DETAILS RECORDS FOR SAME ApSequence_NUMB';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Ac_Job_ID, '');

   DELETE a
     FROM LIVAD_Y1 a,
          (SELECT MAX(Seq_IDNO) AS Seq_IDNO,
                  CaseWelfare_IDNO AS CaseWelfare_IDNO,
                  CpMci_IDNO AS CpMci_IDNO,
                  NcpMci_IDNO AS NcpMci_IDNO,
                  AgSequence_NUMB AS AgSequence_NUMB,
				  ApSequence_NUMB AS ApSequence_NUMB,
                  FileLoad_DATE AS FileLoad_DATE
             FROM LIVAD_Y1
            GROUP BY CaseWelfare_IDNO,
                     CpMci_IDNO,
                     NcpMci_IDNO,
                     AgSequence_NUMB,
					 ApSequence_NUMB,
                     FileLoad_DATE
           HAVING COUNT(1) > 1)b
    WHERE a.FileLoad_DATE = b.FileLoad_DATE
      AND a.CaseWelfare_IDNO = b.CaseWelfare_IDNO
      AND a.CpMci_IDNO = b.CpMci_IDNO
      AND a.NcpMci_IDNO = b.NcpMci_IDNO
      AND a.AgSequence_NUMB = b.AgSequence_NUMB
      AND a.ApSequence_NUMB = b.ApSequence_NUMB
	  AND a.Seq_IDNO != b.Seq_IDNO;

   /** CPDR Screen Processed referral will be deleted as mentioned in the CPDR Screen DSD.**/
   IF EXISTS (SELECT 1
                FROM PRCA_Y1 c
                     LEFT OUTER JOIN APCS_Y1 a
                      ON c.Application_IDNO = a.Application_IDNO
               WHERE ReferralProcess_CODE = @Lc_ReferralProcessD_CODE
                  OR (c.Application_IDNO <> @Ln_Zero_NUMB
                      AND a.ApplicationStatus_CODE = @Lc_ApplicationStatusC_CODE))
    BEGIN
     SET @Ls_Sql_TEXT = 'DELETE PRDE_Y1';
     SET @Ls_Sqldata_TEXT = 'ReferralProcess_CODE = ' + ISNULL(@Lc_ReferralProcessD_CODE, '') + ', ApplicationStatus_CODE = ' + ISNULL(@Lc_ApplicationStatusC_CODE, '');

     DELETE PRDE_Y1
      WHERE TransactionEventSeq_NUMB IN (SELECT c.TransactionEventSeq_NUMB
                                           FROM PRCA_Y1 c
                                                LEFT OUTER JOIN APCS_Y1 a
                                                 ON c.Application_IDNO = a.Application_IDNO
                                          WHERE ReferralProcess_CODE = @Lc_ReferralProcessD_CODE
                                             OR (c.Application_IDNO <> @Ln_Zero_NUMB
                                                 AND a.ApplicationStatus_CODE = @Lc_ApplicationStatusC_CODE));

     SET @Ls_Sql_TEXT = 'DELETE PRSO_Y1';
     SET @Ls_Sqldata_TEXT = 'ReferralProcess_CODE = ' + ISNULL(@Lc_ReferralProcessD_CODE, '') + ', ApplicationStatus_CODE = ' + ISNULL(@Lc_ApplicationStatusC_CODE, '');

     DELETE PRSO_Y1
      WHERE TransactionEventSeq_NUMB IN (SELECT c.TransactionEventSeq_NUMB
                                           FROM PRCA_Y1 c
                                                LEFT OUTER JOIN APCS_Y1 a
                                                 ON c.Application_IDNO = a.Application_IDNO
                                          WHERE ReferralProcess_CODE = @Lc_ReferralProcessD_CODE
                                             OR (c.Application_IDNO <> @Ln_Zero_NUMB
                                                 AND a.ApplicationStatus_CODE = @Lc_ApplicationStatusC_CODE));

     SET @Ls_Sql_TEXT = 'DELETE PRAH_Y1';
     SET @Ls_Sqldata_TEXT = 'ReferralProcess_CODE = ' + ISNULL(@Lc_ReferralProcessD_CODE, '') + ', ApplicationStatus_CODE = ' + ISNULL(@Lc_ApplicationStatusC_CODE, '');

     DELETE a
       FROM PRAH_Y1 a,
            PRCA_Y1 c
            LEFT OUTER JOIN APCS_Y1 b
             ON c.Application_IDNO = b.Application_IDNO
      WHERE a.CaseWelfare_IDNO = c.CaseWelfare_IDNO
        AND a.AgSequence_NUMB = c.AgSequence_NUMB
        AND a.ReferralReceived_DATE = c.ReferralReceived_DATE
        AND (c.ReferralProcess_CODE = @Lc_ReferralProcessD_CODE
              OR (c.Application_IDNO <> @Ln_Zero_NUMB
                  AND b.ApplicationStatus_CODE = @Lc_ApplicationStatusC_CODE));

     SET @Ls_Sql_TEXT = 'DELETE PREH_Y1';
     SET @Ls_Sqldata_TEXT = 'ReferralProcess_CODE = ' + ISNULL(@Lc_ReferralProcessD_CODE, '') + ', ApplicationStatus_CODE = ' + ISNULL(@Lc_ApplicationStatusC_CODE, '');

     DELETE a
       FROM PREH_Y1 a,
            PRCA_Y1 c
            LEFT OUTER JOIN APCS_Y1 b
             ON c.Application_IDNO = b.Application_IDNO
      WHERE a.CaseWelfare_IDNO = c.CaseWelfare_IDNO
        AND a.AgSequence_NUMB = c.AgSequence_NUMB
        AND a.ReferralReceived_DATE = c.ReferralReceived_DATE
        AND (c.ReferralProcess_CODE = @Lc_ReferralProcessD_CODE
              OR (c.Application_IDNO <> @Ln_Zero_NUMB
                  AND b.ApplicationStatus_CODE = @Lc_ApplicationStatusC_CODE));

     SET @Ls_Sql_TEXT = 'DELETE PRCA_Y1';
     SET @Ls_Sqldata_TEXT = 'ReferralProcess_CODE = ' + ISNULL(@Lc_ReferralProcessD_CODE, '') + ', ApplicationStatus_CODE = ' + ISNULL(@Lc_ApplicationStatusC_CODE, '');

     DELETE c
       FROM PRCA_Y1 c
            LEFT OUTER JOIN APCS_Y1 a
             ON c.Application_IDNO = a.Application_IDNO
      WHERE ReferralProcess_CODE = @Lc_ReferralProcessD_CODE
         OR (c.Application_IDNO <> @Ln_Zero_NUMB
             AND a.ApplicationStatus_CODE = @Lc_ApplicationStatusC_CODE);
    END

   --13536 - CR0396 Updates Needed in BATCH_FIN_IVA_Updates 20140620 -START-
   --Skip the records for duplicate referral
   SET @Ls_Sql_TEXT = 'SKIP THE REFERRALS FOR DUPLICATE REFERRAL IF PROCESS FAILED AND SAME REFERRAL RECEIVED ON THE SUBSEQUEANT DAY';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Ac_Job_ID, '');

   UPDATE LIVAR_Y1
      SET Process_CODE = @Lc_ProcessS_CODE
    WHERE Seq_IDNO NOT IN (SELECT A.Seq_IDNO
                             FROM (SELECT MAX(Seq_IDNO) AS Seq_IDNO,
                                          CaseWelfare_IDNO,
                                          CpMci_IDNO,
                                          NcpMci_IDNO,
                                          AgSequence_NUMB,
                                          ChildMci_IDNO,
                                          Program_CODE,
                                          SubProgram_CODE
                                     FROM LIVAR_Y1
                                    WHERE PROCESS_CODE = @Lc_ProcessN_CODE
                                    GROUP BY CaseWelfare_IDNO,
                                             CpMci_IDNO,
                                             NcpMci_IDNO,
                                             AgSequence_NUMB,
                                             ChildMci_IDNO,
                                             Program_CODE,
                                             SubProgram_CODE)A)
      AND Process_CODE = @Lc_ProcessN_CODE;
   --13536 - CR0396 Updates Needed in BATCH_FIN_IVA_Updates 20140620 -END-

   /** Member does not exists in MCI database will move the referrals to the BATE for the worker review with E0102 as error code. **/
   SET @Ls_Sql_TEXT = 'INSERT BATE_Y1 - 1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Ac_Job_ID, '') + ', EffectiveRun_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', Create_DTTM = ' + ISNULL(CAST(@Ld_Start_DATE AS VARCHAR), '') + ', TypeError_CODE = ' + ISNULL(@Lc_TypeErrorWarning_CODE, '') + ', Line_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '');

   INSERT BATE_Y1
          (Job_ID,
           Process_NAME,
           EffectiveRun_DATE,
           Procedure_NAME,
           Create_DTTM,
           TypeError_CODE,
           ListKey_TEXT,
           DescriptionError_TEXT,
           Line_NUMB,
           Error_CODE)
   SELECT DISTINCT
          @Ac_Job_ID AS Job_ID,
          SUBSTRING(@Ls_Procedure_NAME, @Ln_Zero_NUMB, CHARINDEX('$', @Ls_Procedure_NAME)) AS Process_NAME,
          @Ad_Run_DATE AS EffectiveRun_DATE,
          SUBSTRING(@Ls_Procedure_NAME, CHARINDEX('$', @Ls_Procedure_NAME) + 1, LEN(@Ls_Procedure_NAME)) AS Procedure_NAME,
          @Ld_Start_DATE AS Create_DTTM,
          @Lc_TypeErrorWarning_CODE AS TypeError_CODE,
          'Error List KEY - ' + 'Seq_IDNO = ' + CAST(a.Seq_IDNO AS VARCHAR) + ', CaseWelfare_IDNO = ' + ISNULL(RTRIM(a.CaseWelfare_IDNO), '') + ', CpMci_IDNO = ' + ISNULL(RTRIM(a.CpMci_IDNO), '') + ', NcpMci_IDNO = ' + ISNULL(RTRIM(a.NcpMci_IDNO), '') + ', ChildMci_IDNO = ' + ISNULL(RTRIM(a.ChildMci_IDNO), '') + ', AgSequence_NUMB = ' + ISNULL(RTRIM(a.AgSequence_NUMB), '') + ', ChildLast_NAME = ' + ISNULL(RTRIM(a.ChildLast_NAME), '') + ', ChildFirst_NAME = ' + ISNULL(RTRIM(a.ChildFirst_NAME), '') + ', CpLast_NAME = ' + ISNULL(RTRIM(b.CpLast_NAME), '') + ', CpFirst_NAME = ' + ISNULL(RTRIM(b.CpFirst_NAME), '') + ', NcpLast_NAME = ' + ISNULL(RTRIM(b.NcpLast_NAME), '') + ', NcpFirst_NAME = ' + ISNULL(RTRIM(b.NcpFirst_NAME), '') + ', FileLoad_DATE = ' + ISNULL(CAST(a.FileLoad_DATE AS VARCHAR), '') AS ListKey_TEXT,
          'Error IN ' + @Ls_Procedure_NAME + ' PROCEDURE' + '. Error DESC - ' + CASE
                                                                                 WHEN (a.CpMci_IDNO = a.NcpMci_IDNO
                                                                                        OR a.CpMci_IDNO = a.ChildMci_IDNO
                                                                                        OR a.NcpMci_IDNO = a.ChildMci_IDNO)
                                                                                  THEN 'Multiple members on a single case have the same MCI.'
                                                                                 ELSE @Ls_InvalidMci_TEXT
                                                                                END + '. Error EXECUTE Location - ' + @Ls_Sql_TEXT + '. Error List KEY - ' + 'Seq_IDNO = ' + CAST(a.Seq_IDNO AS VARCHAR) + ', CaseWelfare_IDNO = ' + ISNULL(RTRIM(a.CaseWelfare_IDNO), '') + ', CpMci_IDNO = ' + ISNULL(RTRIM(a.CpMci_IDNO), '') + ', NcpMci_IDNO = ' + ISNULL(RTRIM(a.NcpMci_IDNO), '') + ', ChildMci_IDNO = ' + ISNULL(RTRIM(a.ChildMci_IDNO), '') + ', AgSequence_NUMB = ' + ISNULL(RTRIM(a.AgSequence_NUMB), '') + ', ChildLast_NAME = ' + ISNULL(RTRIM(a.ChildLast_NAME), '') + ', ChildFirst_NAME = ' + ISNULL(RTRIM(a.ChildFirst_NAME), '') + ', CpLast_NAME = ' + ISNULL(RTRIM(b.CpLast_NAME), '') + ', CpFirst_NAME = ' + ISNULL(RTRIM(b.CpFirst_NAME), '') + ', NcpLast_NAME = ' + ISNULL(RTRIM(b.NcpLast_NAME), '') + ', NcpFirst_NAME = ' + ISNULL(RTRIM(b.NcpFirst_NAME), '') + ', FileLoad_DATE = ' + ISNULL(CAST(a.FileLoad_DATE AS VARCHAR), '') AS DescriptionError_TEXT,
          @Ln_Zero_NUMB AS Line_NUMB,
          CASE
           WHEN (a.CpMci_IDNO = a.NcpMci_IDNO
                  OR a.CpMci_IDNO = a.ChildMci_IDNO
                  OR a.NcpMci_IDNO = a.ChildMci_IDNO)
            THEN 'E1176'
           ELSE @Lc_ErrorE0102_CODE
          END AS Error_CODE
     FROM LIVAR_Y1 a,
          LIVAD_Y1 b
    WHERE a.CaseWelfare_IDNO = b.CaseWelfare_IDNO
      AND a.CpMci_IDNO = b.CpMci_IDNO
      AND a.NcpMci_IDNO = b.NcpMci_IDNO
      AND a.AgSequence_NUMB = b.AgSequence_NUMB
      AND a.Process_CODE = @Lc_ProcessN_CODE
      AND a.Process_CODE = b.Process_CODE
      AND a.FileLoad_DATE = b.FileLoad_DATE
      AND (((b.NcpMci_IDNO != CAST(@Ln_UnknownMci_IDNO AS VARCHAR)
             AND b.NcpMci_IDNO > CAST(@Ln_Zero_NUMB AS VARCHAR)
             AND b.NcpLast_NAME = @Lc_Space_TEXT
             AND b.NcpFirst_NAME = @Lc_Space_TEXT)
             OR (b.CpMci_IDNO > CAST(@Ln_Zero_NUMB AS VARCHAR)
                 AND b.CpLast_NAME = @Lc_Space_TEXT
                 AND b.CpFirst_NAME = @Lc_Space_TEXT)
             OR (a.ChildMci_IDNO > CAST(@Ln_Zero_NUMB AS VARCHAR)
                 AND a.ChildLast_NAME = @Lc_Space_TEXT
                 AND a.ChildFirst_NAME = @Lc_Space_TEXT))
            OR (a.CpMci_IDNO = a.NcpMci_IDNO
                 OR a.CpMci_IDNO = a.ChildMci_IDNO
                 OR a.NcpMci_IDNO = a.ChildMci_IDNO));

   SET @Li_RowsCount_QNTY = @@ROWCOUNT;

   IF @Li_RowsCount_QNTY != @Ln_Zero_NUMB
    BEGIN
     SET @Ls_Sql_TEXT = 'UPDATE LIVAR_Y1 - 1';
     SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Ac_Job_ID, '');

     UPDATE a
        SET Process_CODE = @Lc_ProcessY_CODE
       FROM LIVAR_Y1 a,
            LIVAD_Y1 b
      WHERE a.CaseWelfare_IDNO = b.CaseWelfare_IDNO
        AND a.CpMci_IDNO = b.CpMci_IDNO
        AND a.NcpMci_IDNO = b.NcpMci_IDNO
        AND a.AgSequence_NUMB = b.AgSequence_NUMB
        AND a.Process_CODE = @Lc_ProcessN_CODE
        AND a.Process_CODE = b.Process_CODE
        AND a.FileLoad_DATE = b.FileLoad_DATE
        AND (((b.NcpMci_IDNO != CAST(@Ln_UnknownMci_IDNO AS VARCHAR)
               AND b.NcpMci_IDNO > CAST(@Ln_Zero_NUMB AS VARCHAR)
               AND b.NcpLast_NAME = @Lc_Space_TEXT
               AND b.NcpFirst_NAME = @Lc_Space_TEXT)
               OR (b.CpMci_IDNO > CAST(@Ln_Zero_NUMB AS VARCHAR)
                   AND b.CpLast_NAME = @Lc_Space_TEXT
                   AND b.CpFirst_NAME = @Lc_Space_TEXT)
               OR (a.ChildMci_IDNO > CAST(@Ln_Zero_NUMB AS VARCHAR)
                   AND a.ChildLast_NAME = @Lc_Space_TEXT
                   AND a.ChildFirst_NAME = @Lc_Space_TEXT))
              OR (a.CpMci_IDNO = a.NcpMci_IDNO
                   OR a.CpMci_IDNO = a.ChildMci_IDNO
                   OR a.NcpMci_IDNO = a.ChildMci_IDNO));

     IF @Li_RowsCount_QNTY != @@ROWCOUNT
      BEGIN
       SET @Ls_ErrorMessage_TEXT = 'UPDATE LIVAR_Y1 FAILED - 1';

       RAISERROR(50001,16,1);
      END
    END

   --Skip the records based on Priority
   --Skip the same CP, NCP, Child AND Case has different Case Types then Give Priority as
   --1. TANF 2. Medicaid 3. Purchase of Care
   --13536 - CR0396 Updates Needed in BATCH_FIN_IVA_Updates 20140620 -START-
   SET @Ls_Sql_TEXT = 'SKIP THE REFERRALS BASED ON PRIORITY';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Ac_Job_ID, '');

   ;WITH SkipReferrals
        AS (SELECT l.CaseWelfare_IDNO,
                   l.CpMci_IDNO,
				   l.NcpMci_IDNO,
				   l.ChildMci_IDNO,
				   l.Process_CODE,
				   ROW_NUMBER() OVER(PARTITION BY l.CaseWelfare_IDNO, l.CpMci_IDNO, l.NcpMci_IDNO, l.ChildMci_IDNO, l.FileLoad_DATE ORDER BY CASE
																																		      WHEN (l.Program_CODE) LIKE 'A%'
																																			   THEN 1
																																			  WHEN (l.Program_CODE) LIKE 'M%'
																																			   THEN 2
																																			  WHEN (l.Program_CODE) LIKE 'C%'
																																			   THEN 3 END) AS Row_NUMB
              FROM LIVAR_Y1 l
             WHERE l.Process_CODE = @Lc_ProcessN_CODE)
   UPDATE s
      SET s.Process_CODE = @Lc_ProcessS_CODE
     FROM SkipReferrals s
    WHERE s.Row_NUMB != 1;
   
   --Skip the Medicaid referrals for same child different Medicaid Codes, has new and old Medicaid Codes.
   SET @Ls_Sql_TEXT = 'SKIP THE REFERRALS BASED ON MEDICAID PRIORITY ASC';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Ac_Job_ID, '');

   ;WITH SkipMedicaidReferrals
        AS (SELECT l.CaseWelfare_IDNO,
                   l.CpMci_IDNO,
				   l.NcpMci_IDNO,
				   l.ChildMci_IDNO,
				   l.Process_CODE,
				   ROW_NUMBER() OVER(PARTITION BY l.CaseWelfare_IDNO, l.CpMci_IDNO, l.NcpMci_IDNO, l.ChildMci_IDNO ORDER BY (l.Program_CODE + l.SubProgram_CODE)) AS Row_NUMB
              FROM LIVAR_Y1 l
             WHERE l.Process_CODE = @Lc_ProcessN_CODE
			   AND l.Program_CODE LIKE 'M%')
   UPDATE s
      SET s.Process_CODE = @Lc_ProcessS_CODE
     FROM SkipMedicaidReferrals s
    WHERE s.Row_NUMB != 1;
   --13536 - CR0396 Updates Needed in BATCH_FIN_IVA_Updates 20140620 -END-

   SET @Ls_Sql_TEXT = 'EXECUTE BATCH_FIN_IVA_UPDATES$SP_PROCESS_CP_CHILD';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Ac_Job_ID, '');

   EXECUTE BATCH_FIN_IVA_UPDATES$SP_PROCESS_CP_CHILD
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Job_ID                = @Ac_Job_ID,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE != @Lc_StatusSuccess_CODE
    BEGIN
     RAISERROR(50001,16,1);
    END

   --Skip the referrals, when incoming PO referral has match with existing CP,NCP and Child on an open case(s).						
   SET @Ls_Sql_TEXT = 'INSERT ##InsertActivity_P1';
   SET @Ls_Sqldata_TEXT = 'ActivityMajor_CODE = ' + ISNULL(@Lc_ActivityMajorCase_CODE, '') + ', ActivityMinor_CODE = ' + ISNULL(@Lc_ActivityMinorCam3c_CODE, '') + ', Subsystem_CODE = ' + ISNULL(@Lc_SubsystemCI_CODE, '');

   INSERT ##InsertActivity_P1
          (Seq_IDNO,
           Case_IDNO,
           MemberMci_IDNO,
           ActivityMajor_CODE,
           ActivityMinor_CODE,
           Subsystem_CODE)
   SELECT DISTINCT
          l.Seq_IDNO,
          ca.Case_IDNO,
          c.MemberMci_IDNO,
          @Lc_ActivityMajorCase_CODE AS ActivityMajor_CODE,
          @Lc_ActivityMinorCam3c_CODE AS ActivityMinor_CODE,
          @Lc_SubsystemCI_CODE AS Subsystem_CODE
     FROM CASE_Y1 ca,
          CMEM_Y1 c,
          CMEM_Y1 d,
          CMEM_Y1 n,
          LIVAR_Y1 l
    WHERE ca.StatusCase_CODE = @Lc_StatusCaseOpen_CODE
      AND ca.Case_IDNO = c.Case_IDNO
      AND c.Case_IDNO = d.Case_IDNO
      AND c.Case_IDNO = n.Case_IDNO
      AND c.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
      AND d.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
      AND n.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
      AND c.CaseRelationship_CODE = @Lc_CaseRelationshipCp_CODE
      AND d.CaseRelationship_CODE = @Lc_CaseRelationshipChild_CODE
      AND n.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcpA_CODE, @Lc_CaseRelationshipNcpP_CODE)
      AND l.CpMci_IDNO = c.MemberMci_IDNO
      AND l.NcpMci_IDNO = n.MemberMci_IDNO
      AND l.ChildMci_IDNO = d.MemberMci_IDNO
      AND l.Process_CODE = @Lc_ProcessN_CODE
      AND l.Program_CODE LIKE @Lc_TypeWelfareIVAPurchaseOfCare_CODE + @Lc_Percenatage_TEXT;

   IF EXISTS (SELECT 1
                FROM ##InsertActivity_P1)
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_FIN_IVA_UPDATES$SP_INSERT_ACTIVITY FOR SKIP';
     SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Ac_Job_ID, '') + ', ActivityMajor_CODE = ' + ISNULL(@Lc_ActivityMajorCase_CODE, '') + ', ActivityMinor_CODE = ' + ISNULL(@Lc_ActivityMinorCam3c_CODE, '') + ', Subsystem_CODE = ' + ISNULL(@Lc_SubsystemCI_CODE, '');

     EXECUTE BATCH_FIN_IVA_UPDATES$SP_INSERT_ACTIVITY
      @Ad_Run_DATE                 = @Ld_Run_DATE,
      @Ac_Job_ID                   = @Ac_Job_ID,
      @Ac_ActivityMajor_CODE       = @Lc_ActivityMajorCase_CODE,
      @Ac_ActivityMinor_CODE       = @Lc_ActivityMinorCam3c_CODE,
      @Ac_Subsystem_CODE           = @Lc_SubsystemCI_CODE,
      @An_TransactionEventSeq_NUMB = 0,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
      BEGIN
       SET @Ls_Sqldata_TEXT = '';

       DELETE ##InsertActivity_P1;

       RAISERROR(50001,16,1);
      END

     SET @Ls_Sql_TEXT = 'UPDATE LIVAR_Y1 AFTER REOPENING CASE';
     SET @Ls_Sqldata_TEXT = '';

     UPDATE LIVAR_Y1
        SET Process_CODE = @Lc_ProcessS_CODE
      WHERE Seq_IDNO IN (SELECT Seq_IDNO
                           FROM ##InsertActivity_P1);

     SET @Ls_Sql_TEXT = 'DELETE ##InsertActivity_P1 - 1';
     SET @Ls_Sqldata_TEXT = '';

     DELETE ##InsertActivity_P1;
    END

   --Skip the referral for intact family
   --The incoming client, child, AND absent parent do not match a CP, dependent, AND NCP on any DECSS cases, AND case is an intact family case 
   --(i.e. the absent parent is residing in the same household)
   SET @Ls_Sql_TEXT = 'SKIP THE REFERRALS FOR INTACT FAMILY';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Ac_Job_ID, '');

   UPDATE LIVAR_Y1
      SET Process_CODE = @Lc_ProcessS_CODE
    WHERE Process_CODE = @Lc_ProcessN_CODE
      AND IntactFamilyStatus_CODE = @Lc_IntactFamilyStatusY_CODE;

   --Skip the referral for child age >= 19 YEARS
   SET @Ls_Sql_TEXT = 'SKIP THE REFERRALS FOR CHILD AGE >= 19 YEARS';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Ac_Job_ID, '');

   UPDATE LIVAR_Y1
      SET Process_CODE = @Lc_ProcessS_CODE
    WHERE Seq_IDNO IN (SELECT DISTINCT
                              a.Seq_IDNO
                         FROM LIVAR_Y1 a
                        WHERE a.Process_CODE = @Lc_ProcessN_CODE
                          AND ISDATE(a.ChildBirth_DATE) = 1
                          AND (DATEDIFF(YY, a.ChildBirth_DATE, @Ld_Run_DATE) - CASE
                                                                                WHEN DATEADD(YY, DATEDIFF(YY, a.ChildBirth_DATE, @Ld_Run_DATE), a.ChildBirth_DATE) > @Ld_Run_DATE
                                                                                 THEN 1
                                                                                ELSE 0
                                                                               END) >= @Ln_ChildAge19_NUMB)
      AND Process_CODE = @Lc_ProcessN_CODE;

   --Skip the referral if Matched, On an existing open IV-D case (Instate or Intergovernmental Initiating) in DECSS, 
   --the incoming client MCI matches the CP MCI, child MCI matches a dependent MCI, and absent parent MCI matches the NCP MCI
   SET @Ls_Sql_TEXT = 'SKIP THE REFERRALS FOR INSTATE OR INTERGOV INITIATING CASES MATCHES CP, NCP AND CHILD WITH INCOMING';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Ac_Job_ID, '');

   UPDATE LIVAR_Y1
      SET Process_CODE = @Lc_ProcessS_CODE
    WHERE Seq_IDNO IN (SELECT DISTINCT
                              l.Seq_IDNO
                         FROM LIVAR_Y1 l,
                              MHIS_Y1 m,
                              CASE_Y1 c,
                              CMEM_Y1 Cp,
                              CMEM_Y1 Dp,
                              CMEM_Y1 Ncp
                        WHERE l.Process_CODE = @Lc_ProcessN_CODE
                          AND l.ChildMci_IDNO = m.MemberMci_IDNO
                          AND l.CaseWelfare_IDNO = m.CaseWelfare_IDNO
                          AND m.End_DATE = @Ld_High_DATE
                          AND m.TypeWelfare_CODE = CASE
                                                    WHEN l.Program_CODE LIKE @Lc_TypeWelfareTANF_CODE + @Lc_Percenatage_TEXT
                                                     THEN @Lc_TypeWelfareTANF_CODE
                                                    WHEN l.Program_CODE LIKE @Lc_TypeWelfareMedicaid_CODE + @Lc_Percenatage_TEXT
                                                     THEN @Lc_TypeWelfareMedicaid_CODE
                                                    WHEN l.Program_CODE LIKE @Lc_TypeWelfareIVAPurchaseOfCare_CODE + @Lc_Percenatage_TEXT
                                                     THEN @Lc_TypeWelfareNonTanf_CODE
                                                   END
                          AND m.Case_IDNO = c.Case_IDNO
                          AND c.StatusCase_CODE = @Lc_StatusCaseOpen_CODE
                          AND c.RespondInit_CODE IN (@Lc_RespondInitI_CODE, @Lc_RespondInitC_CODE, @Lc_RespondInitT_CODE, @Lc_RespondInitN_CODE)
                          AND m.Case_IDNO = Cp.Case_IDNO
                          AND Cp.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
                          AND Cp.CaseRelationship_CODE = @Lc_CaseRelationshipCp_CODE
                          AND m.Case_IDNO = Dp.Case_IDNO
                          AND Dp.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
                          AND Dp.CaseRelationship_CODE = @Lc_CaseRelationshipChild_CODE
                          AND m.Case_IDNO = Ncp.Case_IDNO
                          AND Ncp.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
                          AND Ncp.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcpA_CODE, @Lc_CaseRelationshipNcpP_CODE)
                          AND m.MemberMci_IDNO = Dp.MemberMci_IDNO
                          AND l.CpMci_IDNO = Cp.MemberMci_IDNO
                          AND l.NcpMci_IDNO = Ncp.MemberMci_IDNO)
      AND Process_CODE = @Lc_ProcessN_CODE;

   --Skip the referral if:
   --The incoming program code for the child is Medicaid AND:
   --On existing open IV-D case(s) in DECSS, the incoming client MCI matches the CP MCI,
   --child MCI matches a dependent MCI, but the program type in MHIS is TANF. 
   SET @Ls_Sql_TEXT = 'SKIP THE REFERRALS FOR OPEN IVD CASES WHERE CP AND CHILD MATCHES WITH INCOMING CLIENT AND CHILD AND PROGRAM TYPE IN MHIS IS TANF AND REFERRAL IS MEDICAID';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Ac_Job_ID, '');

   UPDATE LIVAR_Y1
      SET Process_CODE = @Lc_ProcessS_CODE
    WHERE Seq_IDNO IN (SELECT DISTINCT
                              l.Seq_IDNO
                         FROM LIVAR_Y1 l,
                              CASE_Y1 c,
                              CMEM_Y1 Cp,
                              CMEM_Y1 Dp,
                              MHIS_Y1 y
                        WHERE l.Program_CODE LIKE @Lc_TypeWelfareMedicaid_CODE + @Lc_Percenatage_TEXT
                          AND l.Process_CODE = @Lc_ProcessN_CODE
                          AND c.StatusCase_CODE = @Lc_StatusCaseOpen_CODE
                          AND c.Case_IDNO = Cp.Case_IDNO
                          AND c.Case_IDNO = Dp.Case_IDNO
                          AND Cp.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
                          AND Cp.CaseRelationship_CODE = @Lc_CaseRelationshipCp_CODE
                          AND Dp.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
                          AND Dp.CaseRelationship_CODE = @Lc_CaseRelationshipChild_CODE
                          AND Cp.MemberMci_IDNO = l.CpMci_IDNO
                          AND Dp.MemberMci_IDNO = l.ChildMci_IDNO
                          AND y.Case_IDNO = Dp.Case_IDNO
                          AND y.MemberMci_IDNO = Dp.MemberMci_IDNO
                          AND y.TypeWelfare_CODE = @Lc_TypeWelfareTANF_CODE
                          AND y.End_DATE = @Ld_High_DATE)
      AND Process_CODE = @Lc_ProcessN_CODE;

   --MOVE REFERRALS TO CPDR:
   --If on open an Intergovernmental Responding IV-D case in DECSS, the incoming client MCI matches the CP MCI, 
   --absent parent MCI matches the NCP MCI then extract all records for the IV-A case from the incoming file, 
   --and move them to Pending Referrals (REASON [RC]  Referral matched an Intergovernmental Responding Case).
   --13536 - CR0396 Updates Needed in BATCH_FIN_IVA_Updates 20140620 -START-
   SET @Ls_Sql_TEXT = 'MOVE REFERRALS TO CPDR FOR REFERRAL MATCHED AN INTERGOVERNMENTAL RESPONDING CASE';
   SET @Ls_Sqldata_TEXT = '';

   INSERT ##TempSeqIdno_P1
          (Seq_IDNO)
   SELECT DISTINCT
          x.Seq_IDNO
     FROM LIVAR_Y1 x,
          CASE_Y1 b,
          CMEM_Y1 Cp,
          CMEM_Y1 Ncp,
		  CMEM_Y1 Child
    WHERE x.Process_CODE = @Lc_ProcessN_CODE
      AND b.StatusCase_CODE = @Lc_StatusCaseOpen_CODE
      AND b.RespondInit_CODE IN (@Lc_RespondInitR_CODE, @Lc_RespondInitY_CODE, @Lc_RespondInitS_CODE)
      AND b.Case_IDNO = Cp.Case_IDNO
      AND Cp.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
      AND Cp.CaseRelationship_CODE = @Lc_CaseRelationshipCp_CODE
      AND b.Case_IDNO = Ncp.Case_IDNO
	  AND b.Case_IDNO = Child.Case_IDNO
      AND Ncp.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
      AND Ncp.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcpA_CODE, @Lc_CaseRelationshipNcpP_CODE)
	  AND Child.CaseRelationship_CODE IN (@Lc_CaseRelationshipChild_CODE)
      AND x.CpMci_IDNO = Cp.MemberMci_IDNO
      AND (x.NcpMci_IDNO = Ncp.MemberMci_IDNO
	  	    OR x.ChildMci_IDNO = Child.MemberMci_IDNO)
    ORDER BY x.Seq_IDNO;
   --13536 - CR0396 Updates Needed in BATCH_FIN_IVA_Updates 20140620 -END-

   IF EXISTS (SELECT 1
                FROM ##TempSeqIdno_P1)
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_FIN_IVA_UPDATES$SP_INSERT_CPDR FOR Pending Referrals (REASON [RC])';
     SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Ac_Job_ID, '') + ', ReasonForPending_CODE = ' + ISNULL(@Lc_ReasonForPendingRC_CODE, '');

     EXECUTE BATCH_FIN_IVA_UPDATES$SP_INSERT_CPDR
      @Ad_Run_DATE              = @Ad_Run_DATE,
      @Ac_Job_ID                = @Ac_Job_ID,
      @Ac_ReasonForPending_CODE = @Lc_ReasonForPendingRC_CODE,
      @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END

     SET @Ls_Sql_TEXT = 'UPDATE LIVAR_Y1 FOR Pending Referrals (REASON [RC])';
     SET @Ls_Sqldata_TEXT = '';

     UPDATE LIVAR_Y1
        SET Process_CODE = @Lc_ProcessY_CODE
      WHERE Seq_IDNO IN (SELECT Seq_IDNO
                           FROM ##TempSeqIdno_P1);
    END

   --DELETE TEMP TABLE TO HOLD OTHER VALUES
   SET @Ls_Sql_TEXT = 'DELETE ##TempSeqIdno_P1 - 1';
   SET @Ls_Sqldata_TEXT = '';

   DELETE ##TempSeqIdno_P1;

   --MOVE REFERRALS TO CPDR WHEN CHILDS AGE <=12
   SET @Ls_Sql_TEXT = 'INSERT ##TempSeqIdno_P1 TO MOVE REFERRALS TO CPDR WHEN CHILDS AGE <=12';
   SET @Ls_Sqldata_TEXT = '';

   INSERT ##TempSeqIdno_P1
          (Seq_IDNO)
   SELECT DISTINCT
          a.Seq_IDNO
     FROM LIVAR_Y1 a,
          LIVAD_Y1 b,
          CASE_Y1 c,
          CMEM_Y1 Cp,
          CMEM_Y1 Ncp,
          CMEM_Y1 Dp
    WHERE a.Process_CODE = @Lc_ProcessN_CODE
      AND a.CaseWelfare_IDNO = b.CaseWelfare_IDNO
      AND a.NcpMci_IDNO = b.NcpMci_IDNO
      AND a.CpMci_IDNO = b.CpMci_IDNO
      AND a.AgSequence_NUMB = b.AgSequence_NUMB
      AND ISDATE(b.NcpBirth_DATE) = 1
      AND ISDATE(a.ChildBirth_DATE) = 1
      AND (DATEDIFF(YY, b.NcpBirth_DATE, a.ChildBirth_DATE) - CASE
                                                               WHEN DATEADD(YY, DATEDIFF(YY, b.NcpBirth_DATE, a.ChildBirth_DATE), b.NcpBirth_DATE) > a.ChildBirth_DATE
                                                                THEN 1
                                                               ELSE 0
                                                              END) <= @Ln_ChildAge12_NUMB
      AND c.Case_IDNO = Cp.Case_IDNO
      AND c.Case_IDNO = Ncp.Case_IDNO
      AND c.Case_IDNO = Dp.Case_IDNO
      AND Cp.CaseRelationship_CODE = @Lc_CaseRelationshipCp_CODE
      AND Ncp.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcpA_CODE, @Lc_CaseRelationshipNcpP_CODE)
      AND Dp.CaseRelationship_CODE = @Lc_CaseRelationshipChild_CODE
      AND Cp.MemberMci_IDNO <> a.CpMci_IDNO
      AND Ncp.MemberMci_IDNO <> a.NcpMci_IDNO
      AND Dp.MemberMci_IDNO <> a.ChildMci_IDNO;

   IF EXISTS (SELECT 1
                FROM ##TempSeqIdno_P1)
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_FIN_IVA_UPDATES$SP_INSERT_CPDR FOR Pending Referrals (REASON [AG])';
     SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Ac_Job_ID, '') + ', ReasonForPending_CODE = ' + ISNULL(@Lc_ReasonForPendingAG_CODE, '');

     EXECUTE BATCH_FIN_IVA_UPDATES$SP_INSERT_CPDR
      @Ad_Run_DATE              = @Ad_Run_DATE,
      @Ac_Job_ID                = @Ac_Job_ID,
      @Ac_ReasonForPending_CODE = @Lc_ReasonForPendingAG_CODE,
      @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END

     SET @Ls_Sql_TEXT = 'UPDATE LIVAR_Y1 FOR Pending Referrals (REASON [AG])';
     SET @Ls_Sqldata_TEXT = '';

     UPDATE LIVAR_Y1
        SET Process_CODE = @Lc_ProcessY_CODE
      WHERE Seq_IDNO IN (SELECT Seq_IDNO
                           FROM ##TempSeqIdno_P1);
    END
	
   --13128 - CR0344 PFA and Case Assignment Issues 20131226 -START-

   --DELETE TEMP TABLE TO HOLD OTHER VALUES
   SET @Ls_Sql_TEXT = 'DELETE ##TempSeqIdno_P1 - 1.1';
   SET @Ls_Sqldata_TEXT = '';

   DELETE ##TempSeqIdno_P1;

   SET @Ls_Sql_TEXT = 'INSERT ##TempSeqIdno_P1 TO MOVE REFERRALS TO CPDR WHEN - FULL MATCH TO AN EXISTING NON IVD CASE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Ac_Job_ID, '');

   INSERT ##TempSeqIdno_P1
          (Seq_IDNO)
   SELECT DISTINCT
          l.Seq_IDNO
     FROM LIVAR_Y1 l,
          CASE_Y1 c,
          CMEM_Y1 Cp,
          CMEM_Y1 Dp,
          CMEM_Y1 Ncp
    WHERE l.Process_CODE = @Lc_ProcessN_CODE
      AND c.StatusCase_CODE = @Lc_StatusCaseOpen_CODE
      AND c.TypeCase_CODE = @Lc_TypeCaseH_CODE
	  AND c.Case_IDNO = Cp.Case_IDNO
	  AND Cp.Case_IDNO = Dp.Case_IDNO
	  AND Cp.Case_IDNO = Ncp.Case_IDNO
      AND Cp.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
      AND Cp.CaseRelationship_CODE = @Lc_CaseRelationshipCp_CODE
      AND Dp.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
      AND Dp.CaseRelationship_CODE = @Lc_CaseRelationshipChild_CODE
      AND Ncp.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
      AND Ncp.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcpA_CODE, @Lc_CaseRelationshipNcpP_CODE)
      AND l.CpMci_IDNO = Cp.MemberMci_IDNO
	  AND l.ChildMci_IDNO = Dp.MemberMci_IDNO
      AND l.NcpMci_IDNO = Ncp.MemberMci_IDNO;
   
   IF EXISTS (SELECT 1
                FROM ##TempSeqIdno_P1)
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_FIN_IVA_UPDATES$SP_INSERT_CPDR FOR Pending Referrals (REASON [FM])';
     SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Ac_Job_ID, '') + ', ReasonForPending_CODE = ' + ISNULL(@Lc_ReasonForPendingAG_CODE, '');

     EXECUTE BATCH_FIN_IVA_UPDATES$SP_INSERT_CPDR
      @Ad_Run_DATE              = @Ad_Run_DATE,
      @Ac_Job_ID                = @Ac_Job_ID,
      @Ac_ReasonForPending_CODE = @Lc_ReasonForPendingFM_CODE,
      @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END

     SET @Ls_Sql_TEXT = 'UPDATE LIVAR_Y1 FOR Pending Referrals (REASON [FM])';
     SET @Ls_Sqldata_TEXT = '';

     UPDATE LIVAR_Y1
        SET Process_CODE = @Lc_ProcessY_CODE
      WHERE Seq_IDNO IN (SELECT Seq_IDNO
                           FROM ##TempSeqIdno_P1);
    END

   --DELETE TEMP TABLE TO HOLD OTHER VALUES
   SET @Ls_Sql_TEXT = 'DELETE ##TempSeqIdno_P1 - 1.2';
   SET @Ls_Sqldata_TEXT = '';

   DELETE ##TempSeqIdno_P1;

   SET @Ls_Sql_TEXT = 'INSERT ##TempSeqIdno_P1 TO MOVE REFERRALS TO CPDR WHEN - PARTIAL MATCH TO AN EXISTING NON IVD CASE BASED ON MCI MATCHES';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Ac_Job_ID, '');

   INSERT ##TempSeqIdno_P1
          (Seq_IDNO)
   SELECT DISTINCT
          l.Seq_IDNO
     FROM LIVAR_Y1 l,
          CASE_Y1 c,
          CMEM_Y1 Cp,
          CMEM_Y1 Dp,
          CMEM_Y1 Ncp
    WHERE l.Process_CODE = @Lc_ProcessN_CODE
      AND c.StatusCase_CODE = @Lc_StatusCaseOpen_CODE
      AND c.TypeCase_CODE = @Lc_TypeCaseH_CODE
	  AND c.Case_IDNO = Cp.Case_IDNO
	  AND Cp.Case_IDNO = Dp.Case_IDNO
	  AND Cp.Case_IDNO = Ncp.Case_IDNO
      AND Cp.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
      AND Cp.CaseRelationship_CODE = @Lc_CaseRelationshipCp_CODE
      AND Dp.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
      AND Dp.CaseRelationship_CODE = @Lc_CaseRelationshipChild_CODE
      AND Ncp.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
      AND Ncp.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcpA_CODE, @Lc_CaseRelationshipNcpP_CODE)
      AND ((l.CpMci_IDNO = Cp.MemberMci_IDNO
	        AND l.NcpMci_IDNO = Ncp.MemberMci_IDNO)
	   OR (l.NcpMci_IDNO = Cp.MemberMci_IDNO
	        AND l.CpMci_IDNO = Ncp.MemberMci_IDNO)
	   OR l.ChildMci_IDNO = Dp.MemberMci_IDNO);
      
   
   IF EXISTS (SELECT 1
                FROM ##TempSeqIdno_P1)
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_FIN_IVA_UPDATES$SP_INSERT_CPDR FOR Pending Referrals (REASON [PM])';
     SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Ac_Job_ID, '') + ', ReasonForPending_CODE = ' + ISNULL(@Lc_ReasonForPendingAG_CODE, '');

     EXECUTE BATCH_FIN_IVA_UPDATES$SP_INSERT_CPDR
      @Ad_Run_DATE              = @Ad_Run_DATE,
      @Ac_Job_ID                = @Ac_Job_ID,
      @Ac_ReasonForPending_CODE = @Lc_ReasonForPendingPM_CODE,
      @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END

     SET @Ls_Sql_TEXT = 'UPDATE LIVAR_Y1 FOR Pending Referrals (REASON [PM])';
     SET @Ls_Sqldata_TEXT = '';

     UPDATE LIVAR_Y1
        SET Process_CODE = @Lc_ProcessY_CODE
      WHERE Seq_IDNO IN (SELECT Seq_IDNO
                           FROM ##TempSeqIdno_P1);
    END

	--DELETE TEMP TABLE TO HOLD OTHER VALUES
   SET @Ls_Sql_TEXT = 'DELETE ##TempSeqIdno_P1 - 1.3';
   SET @Ls_Sqldata_TEXT = '';

   DELETE ##TempSeqIdno_P1;

   SET @Ls_Sql_TEXT = 'INSERT ##TempSeqIdno_P1 TO MOVE REFERRALS TO CPDR WHEN - PARTIAL MATCH TO AN EXISTING NON IVD CASE; MCIS DO NOT FULLY MATCH';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Ac_Job_ID, '');

   INSERT ##TempSeqIdno_P1
          (Seq_IDNO)
   SELECT DISTINCT
          l.Seq_IDNO
     FROM LIVAR_Y1 l,
	      LIVAD_Y1 d,
          CASE_Y1 c,
          CMEM_Y1 Cp,
          CMEM_Y1 Dp,
          CMEM_Y1 Ncp,
		  DEMO_Y1 dc,
		  DEMO_Y1 dd,
		  DEMO_Y1 dn
    WHERE l.Process_CODE = @Lc_ProcessN_CODE
      AND l.CaseWelfare_IDNO = d.CaseWelfare_IDNO
	  AND l.CpMci_IDNO = d.CpMci_IDNO
	  AND l.NcpMci_IDNO = d.NcpMci_IDNO
	  AND l.AgSequence_NUMB = d.AgSequence_NUMB
	  AND c.StatusCase_CODE = @Lc_StatusCaseOpen_CODE
      AND c.TypeCase_CODE = @Lc_TypeCaseH_CODE
	  AND c.Case_IDNO = Cp.Case_IDNO
	  AND Cp.Case_IDNO = Dp.Case_IDNO
	  AND Cp.Case_IDNO = Ncp.Case_IDNO
	  AND dc.MemberMci_IDNO = Cp.MemberMci_IDNO
	  AND dd.MemberMci_IDNO = Dp.MemberMci_IDNO
	  AND dn.MemberMci_IDNO = Ncp.MemberMci_IDNO
      AND Cp.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
      AND Cp.CaseRelationship_CODE = @Lc_CaseRelationshipCp_CODE
      AND Dp.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
      AND Dp.CaseRelationship_CODE = @Lc_CaseRelationshipChild_CODE
      AND Ncp.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
      AND Ncp.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcpA_CODE, @Lc_CaseRelationshipNcpP_CODE)
      AND ((SUBSTRING(d.CpFirst_NAME,1,3) = SUBSTRING(dc.First_NAME,1,3)
			 AND SUBSTRING(d.CpLast_NAME,1,5) = SUBSTRING(dc.Last_NAME,1,5)
			 AND (CAST(d.CpBirth_DATE AS DATE) = dc.Birth_DATE
			  OR d.CpSex_CODE = dc.MemberSex_CODE)
	         AND SUBSTRING(d.NcpFirst_NAME,1,3) = SUBSTRING(dn.First_NAME,1,3)
			 AND SUBSTRING(d.NcpLast_NAME,1,5) = SUBSTRING(dn.Last_NAME,1,5)
			 AND (CAST(d.NcpBirth_DATE AS DATE) = dn.Birth_DATE
			  OR d.NcpSex_CODE = dn.MemberSex_CODE))
	    OR (SUBSTRING(d.NcpFirst_NAME,1,3) = SUBSTRING(dc.First_NAME,1,3)
			 AND SUBSTRING(d.NcpLast_NAME,1,5) = SUBSTRING(dc.Last_NAME,1,5)
			 AND (CAST(d.NcpBirth_DATE AS DATE) = dc.Birth_DATE
			  OR d.NcpSex_CODE = dc.MemberSex_CODE)
	         AND SUBSTRING(d.CpFirst_NAME,1,3) = SUBSTRING(dn.First_NAME,1,3)
			 AND SUBSTRING(d.CpLast_NAME,1,5) = SUBSTRING(dn.Last_NAME,1,5)
			 AND (CAST(d.CpBirth_DATE AS DATE) = dn.Birth_DATE
			  OR d.CpSex_CODE = dn.MemberSex_CODE))
	    OR (SUBSTRING(l.ChildFirst_NAME,1,3) = SUBSTRING(dd.First_NAME,1,3)
			 AND SUBSTRING(l.ChildLast_NAME,1,5) = SUBSTRING(dd.Last_NAME,1,5)
			 AND CAST(l.ChildBirth_DATE AS DATE) = dd.Birth_DATE
			 AND l.ChildSex_CODE = dd.MemberSex_CODE));
   
   IF EXISTS (SELECT 1
                FROM ##TempSeqIdno_P1)
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_FIN_IVA_UPDATES$SP_INSERT_CPDR FOR Pending Referrals (REASON [PN])';
     SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Ac_Job_ID, '') + ', ReasonForPending_CODE = ' + ISNULL(@Lc_ReasonForPendingAG_CODE, '');

     EXECUTE BATCH_FIN_IVA_UPDATES$SP_INSERT_CPDR
      @Ad_Run_DATE              = @Ad_Run_DATE,
      @Ac_Job_ID                = @Ac_Job_ID,
      @Ac_ReasonForPending_CODE = @Lc_ReasonForPendingPN_CODE,
      @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END

     SET @Ls_Sql_TEXT = 'UPDATE LIVAR_Y1 FOR Pending Referrals (REASON [PN])';
     SET @Ls_Sqldata_TEXT = '';

     UPDATE LIVAR_Y1
        SET Process_CODE = @Lc_ProcessY_CODE
      WHERE Seq_IDNO IN (SELECT Seq_IDNO
                           FROM ##TempSeqIdno_P1);
    END

   --13128 - CR0344 PFA and Case Assignment Issues 20131226 -END-

   --If on a closed IV-D case in DECSS, the incoming client MCI matches the CP MCI, 
   --absent parent MCI matches the NCP MCI, then perform  the following action
   --Extract all records for the IV-A case from the incoming file, 
   --and move them to Pending Referrals (REASON [CC]  Referral matches closed case),  
   --ELSE
   --If the case is not closed for any of the above reasons, reopen the case
   --if the case type is Non TANF, TANF, or Medicaid. For the children who match the dependents on the DECSS case, update the program type 
   --in MHIS to match the incoming program code.  If there are additional children on the incoming IV-A case, add the children to the DECSS case 
   --and update MHIS to match incoming program code.
   SET @Ls_Sql_TEXT = 'INSERT #TempClosedCasesToReopen_P1 FOR Evaluating Closed Case Match';
   SET @Ls_Sqldata_TEXT = '';

   INSERT #TempClosedCasesToReopen_P1
          (Seq_IDNO,
           Case_IDNO,
           RsnStatusCase_CODE,
           ChildMci_IDNO,
           NcpMci_IDNO,
           MappedTypeWelfare_CODE,
           CaseWelfare_IDNO,
           IVACaseType_CODE)
   SELECT DISTINCT
          l.Seq_IDNO,
          c.Case_IDNO,
          c.RsnStatusCase_CODE,
          l.ChildMci_IDNO,
          l.NcpMci_IDNO,
          CASE
           WHEN c.TypeCase_CODE = @Lc_TypeCaseA_CODE
            THEN @Lc_TypeWelfareTANF_CODE
           WHEN c.TypeCase_CODE = @Lc_TypeCaseN_CODE
                AND c.CaseCategory_CODE = @Lc_CaseCategoryMO_CODE
            THEN @Lc_TypeWelfareMedicaid_CODE
           WHEN c.TypeCase_CODE = @Lc_TypeCaseN_CODE
                AND c.CaseCategory_CODE = @Lc_CaseCategoryPO_CODE
            THEN @Lc_TypeWelfareNonTanf_CODE
           WHEN c.TypeCase_CODE = @Lc_TypeCaseN_CODE
                AND c.CaseCategory_CODE NOT IN (@Lc_CaseCategoryPO_CODE, @Lc_CaseCategoryMO_CODE)
            THEN @Lc_TypeWelfareNonTanf_CODE
           ELSE @Lc_Space_TEXT
          END AS MappedTypeWelfare_CODE,
          l.CaseWelfare_IDNO,
          CASE
           WHEN l.Program_CODE LIKE @Lc_TypeWelfareTANF_CODE + @Lc_Percenatage_TEXT
            THEN @Lc_TypeWelfareTANF_CODE
           WHEN l.Program_CODE LIKE @Lc_TypeWelfareMedicaid_CODE + @Lc_Percenatage_TEXT
            THEN @Lc_TypeWelfareMedicaid_CODE
           WHEN l.Program_CODE LIKE @Lc_TypeWelfareIVAPurchaseOfCare_CODE + @Lc_Percenatage_TEXT
            THEN @Lc_TypeWelfareNonTanf_CODE
          END AS IVACaseType_CODE
     FROM LIVAR_Y1 l,
          CASE_Y1 c,
          CMEM_Y1 Cp,
          CMEM_Y1 Ncp
    WHERE l.Process_CODE = @Lc_ProcessN_CODE
      AND c.StatusCase_CODE = @Lc_StatusCaseClosed_CODE
      AND c.Case_IDNO = Cp.Case_IDNO
      AND Cp.CaseRelationship_CODE = @Lc_CaseRelationshipCp_CODE
      AND c.Case_IDNO = Ncp.Case_IDNO
      AND Ncp.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcpA_CODE, @Lc_CaseRelationshipNcpP_CODE)
      AND l.CpMci_IDNO = Cp.MemberMci_IDNO
      AND l.NcpMci_IDNO = Ncp.MemberMci_IDNO
    ORDER BY l.Seq_IDNO;

   SET @Ls_Sql_TEXT = 'DELETE ##TempSeqIdno_P1 - 2';
   SET @Ls_Sqldata_TEXT = '';

   DELETE ##TempSeqIdno_P1;

   --Referral matches closed case for the reasons then moving them to CPDR
   SET @Ls_Sql_TEXT = 'INSERT ##TempSeqIdno_P1 Referral matches closed case (REASON [CC])';
   SET @Ls_Sqldata_TEXT = '';

   INSERT ##TempSeqIdno_P1
          (Seq_IDNO)
   SELECT a.Seq_IDNO
     FROM #TempClosedCasesToReopen_P1 a
    WHERE a.RsnStatusCase_CODE IN (@Lc_RsnStatusCaseEX_CODE, @Lc_RsnStatusCaseDI_CODE, @Lc_RsnStatusCaseGV_CODE, @Lc_RsnStatusCaseUM_CODE,
                                   @Lc_RsnStatusCaseFN_CODE, @Lc_RsnStatusCasePB_CODE, @Lc_RsnStatusCasePR_CODE, @Lc_RsnStatusCasePK_CODE,
                                   @Lc_RsnStatusCasePC_CODE, @Lc_RsnStatusCaseUC_CODE, @Lc_RsnStatusCaseUB_CODE);

   IF EXISTS (SELECT 1
                FROM ##TempSeqIdno_P1)
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_FIN_IVA_UPDATES$SP_INSERT_CPDR FOR Pending Referrals (REASON [CC])';
     SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Ac_Job_ID, '') + ', ReasonForPending_CODE = ' + ISNULL(@Lc_ReasonForPendingCC_CODE, '');

     EXECUTE BATCH_FIN_IVA_UPDATES$SP_INSERT_CPDR
      @Ad_Run_DATE              = @Ad_Run_DATE,
      @Ac_Job_ID                = @Ac_Job_ID,
      @Ac_ReasonForPending_CODE = @Lc_ReasonForPendingCC_CODE,
      @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END

     SET @Ls_Sql_TEXT = 'UPDATE LIVAR_Y1 FOR Pending Referrals (REASON [CC])';
     SET @Ls_Sqldata_TEXT = '';

     UPDATE LIVAR_Y1
        SET Process_CODE = @Lc_ProcessY_CODE
      WHERE Seq_IDNO IN (SELECT Seq_IDNO
                           FROM ##TempSeqIdno_P1);

     SET @Ls_Sql_TEXT = 'DELETE #TempClosedCasesToReopen_P1 - 1';
     SET @Ls_Sqldata_TEXT = '';

     DELETE #TempClosedCasesToReopen_P1
      WHERE Seq_IDNO IN (SELECT Seq_IDNO
                           FROM ##TempSeqIdno_P1);
    END

   --Referral does not matches closed case for the reasons then reopen case, 
   IF EXISTS (SELECT 1
                FROM #TempClosedCasesToReopen_P1)
    BEGIN
     --Move the UNKNOWN NCP MCI who matches the closed case to CPDR
     SET @Ls_Sql_TEXT = 'DELETE ##TempSeqIdno_P1 - 3';
     SET @Ls_Sqldata_TEXT = '';

     DELETE ##TempSeqIdno_P1;

     SET @Ls_Sql_TEXT = 'INSERT ##TempSeqIdno_P1 UNKNOWM NCP MCI WHO MATCHES THE CLOSED CASE (REASON [UN])';
     SET @Ls_Sqldata_TEXT = '';

     INSERT ##TempSeqIdno_P1
            (Seq_IDNO)
     SELECT a.Seq_IDNO
       FROM #TempClosedCasesToReopen_P1 a
      WHERE a.NcpMci_IDNO = @Ln_UnknownMci_IDNO;

     IF EXISTS (SELECT 1
                  FROM ##TempSeqIdno_P1)
      BEGIN
       SET @Ls_Sql_TEXT = 'BATCH_FIN_IVA_UPDATES$SP_INSERT_CPDR FOR Pending Referrals (REASON [UN])';
       SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Ac_Job_ID, '') + ', ReasonForPending_CODE = ' + ISNULL(@Lc_ReasonForPendingUN_CODE, '');

       EXECUTE BATCH_FIN_IVA_UPDATES$SP_INSERT_CPDR
        @Ad_Run_DATE              = @Ad_Run_DATE,
        @Ac_Job_ID                = @Ac_Job_ID,
        @Ac_ReasonForPending_CODE = @Lc_ReasonForPendingUN_CODE,
        @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         RAISERROR(50001,16,1);
        END

       SET @Ls_Sql_TEXT = 'UPDATE LIVAR_Y1 FOR Pending Referrals (REASON [UN])';
       SET @Ls_Sqldata_TEXT = '';

       UPDATE LIVAR_Y1
          SET Process_CODE = @Lc_ProcessY_CODE
        WHERE Seq_IDNO IN (SELECT Seq_IDNO
                             FROM ##TempSeqIdno_P1);

       SET @Ls_Sql_TEXT = 'DELETE #TempClosedCasesToReopen_P1 - 2';
       SET @Ls_Sqldata_TEXT = '';

       DELETE #TempClosedCasesToReopen_P1
        WHERE Seq_IDNO IN (SELECT Seq_IDNO
                             FROM ##TempSeqIdno_P1);
      END

     IF EXISTS (SELECT 1
                  FROM #TempClosedCasesToReopen_P1)
      BEGIN
       --CONSIDER ONLY MEDICAID, TANF AND NON-TANF TO REOPEN OTHER CASES WILL BE PROCESSED
       SET @Ls_Sql_TEXT = 'DELETE #TempClosedCasesToReopen_P1 - 3';
       SET @Ls_Sqldata_TEXT = '';

       DELETE #TempClosedCasesToReopen_P1
        WHERE MappedTypeWelfare_CODE NOT IN (@Lc_TypeWelfareTANF_CODE, @Lc_TypeWelfareMedicaid_CODE, @Lc_TypeWelfareNonTanf_CODE);

       SET @Ls_Sql_TEXT = 'DELETE ##TempSeqIdno_P1 - 4';
       SET @Ls_Sqldata_TEXT = '';

       DELETE ##TempSeqIdno_P1;

       IF EXISTS (SELECT 1
                    FROM #TempClosedCasesToReopen_P1)
        BEGIN
         SET @Ls_Sql_TEXT = 'DELETE ##TempCaseReopenAddUpdateChild_P1';
         SET @Ls_Sqldata_TEXT = '';

         DELETE ##TempCaseReopenAddUpdateChild_P1;

         SET @Ls_Sql_TEXT = 'INSERT ##TempCaseReopenAddUpdateChild_P1';
         SET @Ls_Sqldata_TEXT = '';

         INSERT ##TempCaseReopenAddUpdateChild_P1
                (Seq_IDNO,
                 Case_IDNO)
         SELECT DISTINCT
                t.Seq_IDNO,
                t.Case_IDNO
           FROM #TempClosedCasesToReopen_P1 t;

         SET @Ls_Sql_TEXT = 'BATCH_FIN_IVA_UPDATES$SP_CASE_MHIS_UPDATE FOR Closed Case TO Re-Open';
         SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Ac_Job_ID, '');

         EXECUTE BATCH_FIN_IVA_UPDATES$SP_CASE_MHIS_UPDATE
          @Ad_Run_DATE              = @Ld_Run_DATE,
          @Ac_Job_ID                = @Ac_Job_ID,
          @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
          @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

         IF @Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
          BEGIN
           RAISERROR(50001,16,1);
          END

         SET @Ls_Sql_TEXT = 'UPDATE LIVAR_Y1 AFTER REOPENING CASE';
         SET @Ls_Sqldata_TEXT = '';

         UPDATE LIVAR_Y1
            SET Process_CODE = @Lc_ProcessY_CODE
          WHERE Seq_IDNO IN (SELECT Seq_IDNO
                               FROM #TempClosedCasesToReopen_P1);

         SET @Ls_Sql_TEXT = 'DELETE #TempClosedCasesToReopen_P1 - 4';
         SET @Ls_Sqldata_TEXT = '';

         DELETE #TempClosedCasesToReopen_P1;

         SET @Ls_Sql_TEXT = 'DELETE ##TempCaseReopenAddUpdateChild_P1 - 2';
         SET @Ls_Sqldata_TEXT = '';

         DELETE ##TempCaseReopenAddUpdateChild_P1;
        END
      END
    END

   --UPDATE THE RECORDS IN DETAILS TABLE
   SET @Ls_Sql_TEXT = 'UPDATE LIVAD_Y1';
   SET @Ls_Sqldata_TEXT = 'Process_CODE = ' + ISNULL(@Lc_ProcessN_CODE, '');

   UPDATE LIVAD_Y1
      SET Process_CODE = x.Process_CODE
     FROM (SELECT DISTINCT
                  a.CaseWelfare_IDNO,
                  a.CpMci_IDNO,
                  a.NcpMci_IDNO,
                  a.AgSequence_NUMB,
                  a.Process_CODE,
                  a.FileLoad_DATE
             FROM LIVAR_Y1 a
            WHERE a.Process_CODE <> @Lc_ProcessN_CODE
              AND NOT EXISTS (SELECT 1
                                FROM LIVAR_Y1 b
                               WHERE b.CaseWelfare_IDNO = a.CaseWelfare_IDNO
                                 AND b.CpMci_IDNO = a.CpMci_IDNO
                                 AND b.NcpMci_IDNO = a.NcpMci_IDNO
                                 AND b.AgSequence_NUMB = a.AgSequence_NUMB
                                 AND b.FileLoad_DATE = a.FileLoad_DATE
                                 AND b.Process_CODE = @Lc_ProcessN_CODE))x
    WHERE LIVAD_Y1.CaseWelfare_IDNO = x.CaseWelfare_IDNO
      AND LIVAD_Y1.CpMci_IDNO = x.CpMci_IDNO
      AND LIVAD_Y1.NcpMci_IDNO = x.NcpMci_IDNO
      AND LIVAD_Y1.AgSequence_NUMB = x.AgSequence_NUMB
      AND LIVAD_Y1.FileLoad_DATE = x.FileLoad_DATE
      AND LIVAD_Y1.Process_CODE = @Lc_ProcessN_CODE;

   --DROP TEMP TABLES
   IF OBJECT_ID('tempdb..#TempClosedCasesToReopen_P1') IS NOT NULL
    BEGIN
     DROP TABLE #TempClosedCasesToReopen_P1;
    END

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = '';
  END TRY

  BEGIN CATCH
   --DROP TEMP TABLES
   IF OBJECT_ID('tempdb..#TempClosedCasesToReopen_P1') IS NOT NULL
    BEGIN
     DROP TABLE #TempClosedCasesToReopen_P1;
    END

   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();
   SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_ErrorMessage_TEXT = SUBSTRING(ERROR_MESSAGE(), 1, 200);
    END

   --Check for Exception information to log the description text based on the error
   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   SET @Ac_Msg_CODE = ISNULL(@Lc_Msg_CODE, @Lc_StatusFailed_CODE);
   SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
  END CATCH
 END


GO
