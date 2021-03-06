/****** Object:  StoredProcedure [dbo].[BATCH_EST_OUTGOING_FC$SP_EXTRACT_PETITIONS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_EST_OUTGOING_FC$SP_EXTRACT_PETITIONS
Programmer Name	:	IMP Team.
Description		:	The purpose of BATCH_EST_OUTGOING_FC$SP_EXTRACT_PETITIONS batch process is to create multiple interface records for transmission 
					  to the Family Court system FAMIS. The process looks for all petitions that were generated on the run date. For all the 
					  records found, the process creates the appropriate set of interface records to notify the court of pending action. In 
					  addition, the process looks for all MCI's that were successfully merged in the DACSES Replacement System and provides that 
					  data to FAMIS. Lastly, a special summary record is inserted at the end of the file to describe the total number of 
					  petitions and records transmitted.
Frequency		:	'DAILY'
Developed On	:	5/3/2012
Called By		:	NONE
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_EST_OUTGOING_FC$SP_EXTRACT_PETITIONS]
AS
 BEGIN
  SET NOCOUNT ON;
  
  DECLARE  @Ln_County1_IDNO                    NUMERIC(5) = 1,
           @Ln_County3_IDNO                    NUMERIC(5) = 3,
           @Ln_County5_IDNO                    NUMERIC(5) = 5,
           @Ln_OtherParty7989_IDNO             NUMERIC(9) = 999999989,
           @Ln_OtherParty7988_IDNO             NUMERIC(9) = 999999988,
           @Ln_OtherParty7987_IDNO             NUMERIC(9) = 999999987,
           @Ln_MemberMci598_IDNO               NUMERIC(10) = 999998,
           @Lc_StatusSuccess_CODE              CHAR(1) = 'S',
           @Lc_StatusFailed_CODE               CHAR(1) = 'F',
           @Lc_StatusAbnormalend_CODE          CHAR(1) = 'A',
           @Lc_Space_TEXT                      CHAR(1) = ' ',
           @Lc_Zero_TEXT                       CHAR(1) = '0',
           @Lc_Note_INDC                       CHAR(1) = 'N',
           @Lc_TypeError_CODE                  CHAR(1) = 'E',
           @Lc_RespondInitN_CODE               CHAR(1) = 'N',
           @Lc_GeneratePdfN_INDC               CHAR(1) = 'N',
           @Lc_MergePdfY_INDC                  CHAR(1) = 'Y',
           @Lc_MergePdfN_INDC                  CHAR(1) = 'N',
           @Lc_TypeAddressM_CODE               CHAR(1) = 'M',
           @Lc_TypeAddressR_CODE               CHAR(1) = 'R',
           @Lc_TypeOthpE_CODE                  CHAR(1) = 'E',
           @Lc_StatusY_CODE                    CHAR(1) = 'Y',
           @Lc_InterpreterReqdY_INDC           CHAR(1) = 'Y',
           @Lc_CaseRelationshipC_CODE          CHAR(1) = 'C',
           @Lc_CaseRelationshipA_CODE          CHAR(1) = 'A',
           @Lc_CaseRelationshipP_CODE          CHAR(1) = 'P',
           @Lc_CaseRelationshipG_CODE          CHAR(1) = 'G',
           @Lc_CaseRelationshipD_CODE          CHAR(1) = 'D',
           @Lc_CaseMemberStatusA_CODE          CHAR(1) = 'A',
           @Lc_StatusMergeM_CODE               CHAR(1) = 'M',
           @Lc_IsCaseExtracted_INDC            CHAR(1) = 'N',
           @Lc_StatusNoticeFailure_CODE        CHAR(1) = 'F',
           @Lc_StatusNoticeGenerated_CODE      CHAR(1) = 'G',
           @Lc_StatusCaseO_CODE                CHAR(1) = 'O',
           @Lc_TypeCaseF_CODE                  CHAR(1) = 'F',
           @Lc_TypeCaseJ_CODE                  CHAR(1) = 'J',
           @Lc_LanguageEN_CODE                 CHAR(2) = 'EN',
           @Lc_TypePartyCp_CODE                CHAR(2) = 'CP',
           @Lc_TypePartyPa_CODE                CHAR(2) = 'PA',
           @Lc_TypePartyRa_CODE                CHAR(2) = 'RA',
           @Lc_StatusCg_CODE                   CHAR(2) = 'CG',
           @Lc_SubsystemEs_CODE                CHAR(3) = 'ES',
           @Lc_TypePartyNcp_CODE               CHAR(3) = 'NCP',
           @Lc_TypeReference_IDNO              CHAR(4) = ' ',
           @Lc_ActivityMajorEstp_CODE          CHAR(4) = 'ESTP',
           @Lc_ActivityMajorMapp_CODE          CHAR(4) = 'MAPP',
           @Lc_ActivityMajorRofo_CODE          CHAR(4) = 'ROFO',
           @Lc_ActivityMajorImiw_CODE          CHAR(4) = 'IMIW',
           @Lc_IdTableNoid_CODE                CHAR(4) = 'NOID',
           @Lc_IdTableSubFmis_CODE             CHAR(4) = 'FMIS',
           @Lc_PetitionTypePetn_CODE           CHAR(4) = 'PETN',
           @Lc_PetitionTypePreg_CODE           CHAR(4) = 'PREG',
           @Lc_FcioKeyRecordTypeCase_CODE      CHAR(4) = 'CASE',
           @Lc_FcioKeyRecordTypePart_CODE      CHAR(4) = 'PART',
           @Lc_FcioKeyRecordTypeEmpl_CODE      CHAR(4) = 'EMPL',
           @Lc_FcioKeyRecordTypeMcii_CODE      CHAR(4) = 'MCII',
           @Lc_FcioKeyRecordTypeSumm_CODE      CHAR(4) = 'SUMM',
           @Lc_StatusComp_CODE                 CHAR(4) = 'COMP',
           @Lc_ActivityMajorCase_CODE          CHAR(4) = 'CASE',
           @Lc_TypeLicenseDr_CODE              CHAR(5) = 'DR',
           @Lc_BatchRunUser_TEXT               CHAR(5) = 'BATCH',
           @Lc_BateError_CODE                  CHAR(5) = 'E0944',
           @Lc_ActivityMinorRsstf_CODE         CHAR(5) = 'RSSTF',
           @Lc_Job_ID                          CHAR(7) = 'DEB8053',
           @Lc_Notice_ID                       CHAR(8) = NULL,
           @Lc_FcioKeyPetitionCreate_DATE      CHAR(8) = ' ',
           @Lc_FcioKeyPetitionCreate_TIME      CHAR(8) = ' ',
           --13417 - CR0382 Related Petition Number Change in Outgoing Petitions Batch -START-
           @Lc_NoticeLeg191b_ID                CHAR(10) = 'LEG-191B',
           @Lc_NoticeLeg191d_ID                CHAR(10) = 'LEG-191D',
           @Lc_NoticeLeg191e_ID                CHAR(10) = 'LEG-191E',
           @Lc_NoticeLeg191h_ID                CHAR(10) = 'LEG-191H',
           @Lc_NoticeLeg194_ID                 CHAR(10) = 'LEG-194',
           @Lc_NoticeLeg197_ID                 CHAR(10) = 'LEG-197',
           @Lc_NoticeLeg197d_ID                CHAR(10) = 'LEG-197D',
           @Lc_NoticeLeg297_ID                 CHAR(10) = 'LEG-297',
           @Lc_NoticeLeg499_ID                 CHAR(10) = 'LEG-499',
           --13417 - CR0382 Related Petition Number Change in Outgoing Petitions Batch -END-           
           @Lc_Successful_TEXT                 CHAR(20) = 'SUCCESSFUL',
           @Lc_WorkerDelegate_ID               CHAR(30) = ' ',
           @Lc_Reference_ID                    CHAR(30) = ' ',
           @Ls_Procedure_NAME                  VARCHAR(100) = 'SP_EXTRACT_PETITIONS',
           @Ls_Process_NAME                    VARCHAR(100) = 'Dhss.Ivd.Decss.Batch.EstOutgoingFc',
           @Ls_BateError_TEXT                  VARCHAR(4000) = 'NO RECORD(S) TO PROCESS',
           @Ls_XmlIn_TEXT                      VARCHAR(4000) = ' ',
           @Ld_High_DATE                       DATE = '12/31/9999',
           @Ld_Low_DATE                        DATE = '01/01/0001';
  DECLARE  @Ln_FetchStatus_QNTY             NUMERIC,
           @Ln_RowCount_QNTY                NUMERIC,
           @Ln_CommitFreqParm_QNTY          NUMERIC(5),
           @Ln_ExceptionThresholdParm_QNTY  NUMERIC(5),
           @Ln_RestartLine_NUMB             NUMERIC(5,0) = 0,
           @Ln_MajorIntSeq_NUMB             NUMERIC(5) = 0,
           @Ln_MinorIntSeq_NUMB             NUMERIC(5) = 0,
           @Ln_ProcessedRecordCount_QNTY    NUMERIC(6) = 0,
           @Ln_CaseRecordCount_QNTY         NUMERIC(7) = 0,
           @Ln_PartRecordCount_QNTY         NUMERIC(7) = 0,
           @Ln_EmplRecordCount_QNTY         NUMERIC(7) = 0,
           @Ln_MciiRecordCount_QNTY         NUMERIC(7) = 0,
           @Ln_TopicIn_IDNO                 NUMERIC(10) = 0,
           @Ln_Schedule_NUMB                NUMERIC(10) = 0,
           @Ln_Topic_IDNO                   NUMERIC(10),
           @Ln_Error_NUMB                   NUMERIC(11),
           @Ln_ErrorLine_NUMB               NUMERIC(11),
           @Ln_TransactionEventSeq_NUMB     NUMERIC(19) = 0,
           @Lc_Empty_TEXT                   CHAR = '',
           @Lc_Msg_CODE                     CHAR(5),
           @Ls_File_NAME                    VARCHAR(50),
           @Ls_FileLocation_TEXT            VARCHAR(80),
           @Ls_Sql_TEXT                     VARCHAR(100) = '',
           @Ls_FileSource_TEXT              VARCHAR(130),
           @Ls_ErrorMessage_TEXT            VARCHAR(200),
           @Ls_Sqldata_TEXT                 VARCHAR(1000) = '',
           @Ls_Query_TEXT                   VARCHAR(1000),
           @Ls_DescriptionError_TEXT        VARCHAR(4000),
           @Ld_Run_DATE                     DATE,
           @Ld_LastRun_DATE                 DATE,
           @Ld_Start_DATE                   DATETIME2;
  DECLARE @Lc_EmptyTypeCase_CODE                    CHAR(1) = @Lc_Space_TEXT,
          @Lc_EmptyCaseRelationship_CODE            CHAR(1) = @Lc_Space_TEXT,
          @Lc_EmptyMi_NAME                          CHAR(1) = @Lc_Space_TEXT,
          @Lc_EmptyMemberSex_CODE                   CHAR(1) = @Lc_Space_TEXT,
          @Lc_EmptyRace_CODE                        CHAR(1) = @Lc_Space_TEXT,
          @Lc_EmptyInterpreterReqd_INDC             CHAR(1) = @Lc_Space_TEXT,
          @Lc_EmptySequence_NUMB                    CHAR(2) = REPLICATE(@Lc_Zero_TEXT, 2),
          @Lc_EmptyRespondInit_CODE                 CHAR(2) = REPLICATE(@Lc_Space_TEXT, 2),
          @Lc_EmptyIVDOutOfStateFips_CODE           CHAR(2) = REPLICATE(@Lc_Space_TEXT, 2),
          @Lc_EmptyColorEyes_CODE                   CHAR(2) = REPLICATE(@Lc_Space_TEXT, 2),
          @Lc_EmptyColorHair_CODE                   CHAR(2) = REPLICATE(@Lc_Space_TEXT, 2),
          @Lc_EmptyState_ADDR                       CHAR(2) = REPLICATE(@Lc_Space_TEXT, 2),
          @Lc_EmptyLanguage_CODE                    CHAR(2) = REPLICATE(@Lc_Space_TEXT, 2),
          @Lc_EmptyIssuingState_CODE                CHAR(2) = REPLICATE(@Lc_Space_TEXT, 2),
          @Lc_EmptyCounty_IDNO                      CHAR(3) = REPLICATE(@Lc_Space_TEXT, 3),
          @Lc_EmptyRelationshipToChild_CODE         CHAR(3) = REPLICATE(@Lc_Space_TEXT, 3),
          @Lc_EmptySuffix_NAME                      CHAR(3) = REPLICATE(@Lc_Space_TEXT, 3),
          @Lc_EmptyCpRelationshipToNcp_CODE         CHAR(3) = REPLICATE(@Lc_Space_TEXT, 3),
          @Lc_EmptyAsset_CODE                       CHAR(3) = REPLICATE(@Lc_Space_TEXT, 3),
          @Lc_EmptyDescriptionWeightLbs_TEXT        CHAR(4) = REPLICATE(@Lc_Zero_TEXT, 4),
          @Lc_EmptyDescriptionHeight_TEXT           CHAR(4) = @Lc_Zero_TEXT + REPLICATE(@Lc_Space_TEXT, 3),
          @Lc_EmptyFcioKeyCase_IDNO                 CHAR(6) = REPLICATE(@Lc_Zero_TEXT, 6),
          @Lc_EmptyPetition_IDNO                    CHAR(7) = REPLICATE(@Lc_Zero_TEXT, 7),
          @Lc_EmptyDecssPetitionKey_IDNO            CHAR(8) = REPLICATE(@Lc_Space_TEXT, 8),
          @Lc_EmptyBirth_DATE                       CHAR(8) = REPLICATE(@Lc_Space_TEXT, 8),
          @Lc_EmptyExpireLicense_DATE               CHAR(8) = REPLICATE(@Lc_Space_TEXT, 8),
          @Lc_EmptyMemberSsn_NUMB                   CHAR(9) = REPLICATE(@Lc_Zero_TEXT, 9),
          @Lc_EmptyZip_ADDR                         CHAR(9) = REPLICATE(@Lc_Zero_TEXT, 9),
          @Lc_EmptyFein_IDNO                        CHAR(9) = REPLICATE(@Lc_Zero_TEXT, 9),
          @Lc_EmptyMemberMci_IDNO                   CHAR(10) = REPLICATE(@Lc_Zero_TEXT, 10),
          @Lc_EmptyHomePhone_NUMB                   CHAR(10) = REPLICATE(@Lc_Zero_TEXT, 10),
          @Lc_EmptyCellPhone_NUMB                   CHAR(10) = REPLICATE(@Lc_Zero_TEXT, 10),
          @Lc_EmptyPhone_NUMB                       CHAR(10) = REPLICATE(@Lc_Zero_TEXT, 10),
          @Lc_EmptyFirst_NAME                       CHAR(15) = REPLICATE(@Lc_Space_TEXT, 15),
          @Lc_EmptyLast_NAME                        CHAR(20) = REPLICATE(@Lc_Space_TEXT, 20),
          @Lc_EmptyEmplContact_TEXT                 CHAR(24) = REPLICATE(@Lc_Space_TEXT, 24),
          @Lc_EmptyLicenseNo_TEXT                   CHAR(25) = REPLICATE(@Lc_Space_TEXT, 25),
          @Lc_EmptyMergedPdf_NAME                   CHAR(27) = REPLICATE(@Lc_Space_TEXT, 27),
          @Lc_EmptyCity_ADDR                        CHAR(28) = REPLICATE(@Lc_Space_TEXT, 28),
          @Lc_EmptyDescriptionIdentifyingMarks_TEXT CHAR(40) = REPLICATE(@Lc_Space_TEXT, 40),
          @Ls_EmptyLine1_ADDR                       VARCHAR(50) = REPLICATE(@Lc_Space_TEXT, 50),
          @Ls_EmptyLine2_ADDR                       VARCHAR(50) = REPLICATE(@Lc_Space_TEXT, 50),
          @Ls_EmptyEmployer_NAME                    VARCHAR(50) = REPLICATE(@Lc_Space_TEXT, 50),
          @Ls_EmptyAttorney_NAME                    VARCHAR(60) = REPLICATE(@Lc_Space_TEXT, 60),
          @Ls_EmptyDescriptionServiceDirection_TEXT VARCHAR(400) = REPLICATE(@Lc_Space_TEXT, 400);
  DECLARE @Lc_CaseMjrActCur_Case_IDNO             CHAR(6),
          @Ln_CaseMjrActCur_MajorIntSeq_NUMB      NUMERIC(5),
          @Lc_CaseMjrActCur_ActivityMajor_CODE    CHAR(4),
          @Lc_CaseFileCur_Case_IDNO               CHAR(6),
          --13710 - Incorrect PF being sent to Family Court -START-
          @Ln_CaseFileCur_MajorIntSeq_NUMB        NUMERIC(5),
          --13710 - Incorrect PF being sent to Family Court -END-
          @Lc_CaseFileCur_PetitionDocFile_NAME    CHAR(27),
          @Lc_CaseMemberCur_MemberMci_IDNO        CHAR(10),
          @Lc_CaseMemberCur_CaseRelationship_CODE CHAR(1),
          @Ln_NrrqAxmlCur_Barcode_NUMB            NUMERIC(12),
          @Lc_CaseJrnActCur_Case_IDNO             CHAR(6),
          @Ln_UpdateNmrqCur_Barcode_NUMB          NUMERIC(12);

  BEGIN TRY
   SET @Ls_Sql_TEXT = 'CREATE ##ExtFcPetition_P1';
   SET @Ls_SqlData_TEXT = '';

   CREATE TABLE ##ExtFcPetition_P1
    (
      Seq_IDNO    NUMERIC IDENTITY(1, 1),
      Record_TEXT VARCHAR(1300)
    );

   SET @Ls_Sql_TEXT = 'BEGIN TRANSACTION EXTRACT_PETITIONS';
   SET @Ls_SqlData_TEXT = '';

   BEGIN TRANSACTION EXTRACT_PETITIONS;

   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS2';
   SET @Ls_SqlData_TEXT = 'Job_ID = ' + @Lc_Job_ID;

   EXECUTE BATCH_COMMON$SP_GET_BATCH_DETAILS2
    @Ac_Job_ID                  = @Lc_Job_ID,
    @Ad_Run_DATE                = @Ld_Run_DATE OUTPUT,
    @Ad_LastRun_DATE            = @Ld_LastRun_DATE OUTPUT,
    @An_CommitFreq_QNTY         = @Ln_CommitFreqParm_QNTY OUTPUT,
    @An_ExceptionThreshold_QNTY = @Ln_ExceptionThresholdParm_QNTY OUTPUT,
    @As_File_NAME               = @Ls_File_NAME OUTPUT,
    @As_FileLocation_TEXT       = @Ls_FileLocation_TEXT OUTPUT,
    @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT   = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

     RAISERROR (50001,16,1);
    END;

   SET @Lc_FcioKeyPetitionCreate_DATE = CONVERT(CHAR(8), @Ld_Run_DATE, 112);
   SET @Lc_FcioKeyPetitionCreate_TIME = CONVERT(CHAR(8), @Ld_Start_DATE, 108);
   SET @Ls_Sql_TEXT='DELETE ECASE_Y1';
   SET @Ls_SqlData_TEXT = '';

   DELETE FROM ECASE_Y1;

   SET @Ls_Sql_TEXT='INSERT ECASE_Y1';
   SET @Ls_SqlData_TEXT = '';

   INSERT INTO ECASE_Y1
               (Case_IDNO,
                TypePetition_CODE,
                TypeCase_CODE,
                County_IDNO,
                Petition_IDNO,
                IVDOutOfStateRespondInit_CODE,
                IVDOutOfStateFips_CODE,
                DecssPetitionKey_IDNO,
                PetitionDocFile_NAME)
   SELECT (RIGHT(REPLICATE(@Lc_Zero_TEXT, 6) + LTRIM(RTRIM(ISNULL(LTRIM(RTRIM(CAST(A.Case_IDNO AS VARCHAR))), ''))), 6)) AS FcioKeyCase_IDNO,
          ISNULL((CASE A.ActivityMajor_CODE
                   WHEN @Lc_ActivityMajorRofo_CODE
                    THEN @Lc_PetitionTypePreg_CODE
                   ELSE
                    CASE
                     WHEN ISNUMERIC(B.Notice_ID) > 0
                      THEN ISNULL((SELECT TOP 1 CASE
                                                 WHEN LEN(LTRIM(RTRIM(ISNULL(Z.DescriptionValue_TEXT, '')))) = 0
                                                  THEN @Lc_PetitionTypePetn_CODE
                                                 ELSE LTRIM(RTRIM(Z.DescriptionValue_TEXT))
                                                END
                                     FROM PDAFP_Y1 X,
                                          FORM_Y1 Y,
                                          REFM_Y1 Z
                                    WHERE X.Case_IDNO = A.Case_IDNO
                                      AND X.County_IDNO = A.County_IDNO
                                      AND X.MajorIntSeq_NUMB = A.MajorIntSeq_NUMB
                                      AND X.ActivityMajor_CODE = A.ActivityMajor_CODE
                                      AND X.GeneratePdf_INDC = 'Y'
                                      AND X.MergePdf_INDC = 'Y'
                                      AND UPPER(LTRIM(RTRIM(X.MergedPdf_NAME))) = UPPER(LTRIM(RTRIM(A.MergedPdf_NAME)))
                                      AND Y.Barcode_NUMB = X.Barcode_NUMB
                                      AND ISNUMERIC(Y.Notice_ID) = 0
                                      AND Z.Value_CODE = Y.Notice_ID
                                      AND Z.Table_ID = @Lc_IdTableNoid_CODE
                                      AND Z.TableSub_ID = @Lc_IdTableSubFmis_CODE), @Lc_PetitionTypePetn_CODE)
                     ELSE
                      CASE
                       WHEN LEN(LTRIM(RTRIM(ISNULL(C.DescriptionValue_TEXT, '')))) = 0
                        THEN @Lc_PetitionTypePetn_CODE
                       ELSE LTRIM(RTRIM(C.DescriptionValue_TEXT))
                      END
                    END
                  END), @Lc_EmptyTypeCase_CODE) AS FcioCasePetitionType_CODE,
          ISNULL(D.TypeCase_CODE, @Lc_EmptyTypeCase_CODE) AS FcioCaseIvdType_CODE,
          RIGHT(REPLICATE(@Lc_Zero_TEXT, 3) + LTRIM(RTRIM(ISNULL(LTRIM(RTRIM(CAST(D.County_IDNO AS VARCHAR))), ''))), 3) AS FcioCaseCounty_CODE,
          --13417 - CR0382 Related Petition Number Change in Outgoing Petitions Batch -START-
          CASE
			WHEN ISNUMERIC(B.Notice_ID) = 0
				AND B.Notice_ID IN (@Lc_NoticeLeg191b_ID, @Lc_NoticeLeg191d_ID, @Lc_NoticeLeg191e_ID, @Lc_NoticeLeg191h_ID, @Lc_NoticeLeg194_ID,
				@Lc_NoticeLeg197_ID, @Lc_NoticeLeg197d_ID, @Lc_NoticeLeg297_ID, @Lc_NoticeLeg499_ID) THEN
				RIGHT(REPLICATE(@Lc_Zero_TEXT, 7) + LTRIM(RTRIM(ISNULL(LTRIM(RTRIM(CAST(K.Petition_IDNO AS VARCHAR))), ''))), 7)
			ELSE @Lc_EmptyPetition_IDNO
          END AS FcioCaseRelatedPet_NUMB,
          --13417 - CR0382 Related Petition Number Change in Outgoing Petitions Batch -END-
          CAST(LEFT((LTRIM(RTRIM(ISNULL(LTRIM(RTRIM(ISNULL(D.RespondInit_CODE, 'N'))), ''))) + REPLICATE(@Lc_Space_TEXT, 2)), 2) AS CHAR(2)) AS FcioCaseInterstateStat_CODE,
          CAST(LEFT((LTRIM(RTRIM(ISNULL(LTRIM(RTRIM(ISNULL((CASE
                                                             WHEN UPPER(LTRIM(RTRIM(D.RespondInit_CODE))) <> @Lc_RespondInitN_CODE
                                                              THEN ISNULL(G.Value_CODE, '')
                                                             ELSE @Lc_EmptyIVDOutOfStateFips_CODE
                                                            END), ''))), ''))) + REPLICATE(@Lc_Space_TEXT, 2)), 2) AS CHAR(2)) AS FcioCaseInterstateSt_CODE,
          RIGHT(REPLICATE(@Lc_Zero_TEXT, 8) + LTRIM(RTRIM(ISNULL(LTRIM(RTRIM(CAST(A.MajorIntSeq_NUMB AS VARCHAR))), ''))), 8) AS FcioCaseAcsesPet_KEY,
          CAST(LEFT((LTRIM(RTRIM(ISNULL(LTRIM(RTRIM(A.MergedPdf_NAME)), ''))) + REPLICATE(@Lc_Space_TEXT, 27)), 27) AS CHAR(27)) AS FcioPetitionDocFile_NAME
     FROM PDAFP_Y1 A
          JOIN FORM_Y1 B
           ON B.Barcode_NUMB = A.Barcode_NUMB
          LEFT OUTER JOIN REFM_Y1 C
           ON C.Value_CODE = B.Notice_ID
              AND C.Table_ID = @Lc_IdTableNoid_CODE
              AND C.TableSub_ID = @Lc_IdTableSubFmis_CODE
          LEFT OUTER JOIN CASE_Y1 D
           ON D.Case_IDNO = A.Case_IDNO
          LEFT OUTER JOIN ICAS_Y1 E
           ON E.Case_IDNO = A.Case_IDNO
              AND E.EndValidity_DATE = @Ld_High_DATE
          LEFT OUTER JOIN REFM_Y1 F
           ON F.Value_CODE = E.IVDOutOfStateFips_CODE
              AND F.Table_ID = 'FIPS'
              AND F.TableSub_ID = 'STCD'
          LEFT OUTER JOIN REFM_Y1 G
           ON UPPER(LTRIM(RTRIM(G.DescriptionValue_TEXT))) = UPPER(LTRIM(RTRIM(F.DescriptionValue_TEXT)))
              AND G.Table_ID = 'STAT'
              AND G.TableSub_ID = 'STAT'
          LEFT OUTER JOIN DMJR_Y1 H
           ON H.Case_IDNO = A.Case_IDNO
              AND H.ActivityMajor_CODE = A.ActivityMajor_CODE
              AND H.ActivityMajor_CODE <> @Lc_ActivityMajorCase_CODE
              AND H.Status_CODE <> @Lc_StatusComp_CODE
              AND H.Status_DATE = @Ld_High_DATE
              AND EXISTS (SELECT 1
                            FROM DMJR_Y1 I
                           WHERE I.Case_IDNO = H.Case_IDNO
                             AND I.ActivityMajor_CODE = H.ActivityMajor_CODE
                             AND I.ActivityMajor_CODE <> @Lc_ActivityMajorCase_CODE
                             AND I.Status_CODE <> @Lc_StatusComp_CODE
                             AND I.Status_DATE = @Ld_High_DATE
                             AND I.MajorIntSeq_NUMB > H.MajorIntSeq_NUMB
                             AND I.OthpSource_IDNO = H.OthpSource_IDNO
                             AND I.Reference_ID = H.Reference_ID)
              AND H.MajorIntSeq_NUMB = (SELECT MIN(J.MajorIntSeq_NUMB)
                                          FROM DMJR_Y1 J
                                         WHERE J.Case_IDNO = H.Case_IDNO
                                           AND J.ActivityMajor_CODE = H.ActivityMajor_CODE
                                           AND J.ActivityMajor_CODE <> @Lc_ActivityMajorCase_CODE
                                           AND J.Status_CODE <> @Lc_StatusComp_CODE
                                           AND J.Status_DATE = @Ld_High_DATE
                                           AND J.OthpSource_IDNO = H.OthpSource_IDNO
                                           AND J.Reference_ID = H.Reference_ID)
          LEFT OUTER JOIN FDEM_Y1 K
           ON K.Case_IDNO = H.Case_IDNO
              AND K.MajorIntSeq_NUMB = H.MajorIntSeq_NUMB
              AND K.EndValidity_DATE = @Ld_High_DATE
    WHERE A.MergePdf_INDC = @Lc_MergePdfY_INDC
      AND LEN(LTRIM(RTRIM(ISNULL(A.MergedPdf_NAME, @Lc_Empty_TEXT)))) > 0
      AND NOT EXISTS (SELECT 1
                        FROM PDAFP_Y1 X
                       WHERE X.Case_IDNO = A.Case_IDNO
                         AND X.County_IDNO = A.County_IDNO
                         AND X.MajorIntSeq_NUMB = A.MajorIntSeq_NUMB
                         AND X.ActivityMajor_CODE = A.ActivityMajor_CODE
                         AND X.GeneratePdf_INDC = @Lc_GeneratePdfN_INDC)
      AND A.ActivityMajor_CODE IN (@Lc_ActivityMajorEstp_CODE, @Lc_ActivityMajorMapp_CODE, @Lc_ActivityMajorRofo_CODE, @Lc_ActivityMajorImiw_CODE)
    ORDER BY FcioKeyCase_IDNO,
             FcioCaseCounty_CODE,
             FcioCaseAcsesPet_KEY;

   SET @Ls_Sql_TEXT='DELETE EPART_Y1';
   SET @Ls_SqlData_TEXT = '';

   DELETE FROM EPART_Y1;

   SET @Ls_Sql_TEXT='DECLARE CaseMjrAct_CUR';
   SET @Ls_SqlData_TEXT = '';

   DECLARE CaseMjrAct_CUR INSENSITIVE CURSOR FOR
    SELECT DISTINCT
           A.Case_IDNO,
           A.MajorIntSeq_NUMB,
           A.ActivityMajor_CODE
      FROM PDAFP_Y1 A,
           ECASE_Y1 B
     WHERE A.ActivityMajor_CODE IN (@Lc_ActivityMajorEstp_CODE, @Lc_ActivityMajorMapp_CODE, @Lc_ActivityMajorRofo_CODE, @Lc_ActivityMajorImiw_CODE)
       AND A.MergePdf_INDC = @Lc_MergePdfY_INDC
       AND LEN(LTRIM(RTRIM(ISNULL(A.MergedPdf_NAME, @Lc_Empty_TEXT)))) > 0
       AND NOT EXISTS (SELECT 1
                         FROM PDAFP_Y1 X
                        WHERE X.Case_IDNO = A.Case_IDNO
                          AND X.MajorIntSeq_NUMB = A.MajorIntSeq_NUMB
                          AND X.ActivityMajor_CODE = A.ActivityMajor_CODE
                          AND X.GeneratePdf_INDC = @Lc_GeneratePdfN_INDC)
       AND B.Case_IDNO = A.Case_IDNO
     ORDER BY A.Case_IDNO,
              A.MajorIntSeq_NUMB,
              A.ActivityMajor_CODE;

   SET @Ls_Sql_TEXT = 'OPEN CaseMjrAct_CUR';
   SET @Ls_SqlData_TEXT = '';

   OPEN CaseMjrAct_CUR;

   SET @Ls_Sql_TEXT = 'FETCH NEXT FROM CaseMjrAct_CUR - 1';
   SET @Ls_SqlData_TEXT = '';

   FETCH NEXT FROM CaseMjrAct_CUR INTO @Lc_CaseMjrActCur_Case_IDNO, @Ln_CaseMjrActCur_MajorIntSeq_NUMB, @Lc_CaseMjrActCur_ActivityMajor_CODE;

   SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;
   SET @Ls_Sql_TEXT = 'FOR EACH RECORD IN CaseMjrAct_CUR';
   SET @Ls_SqlData_TEXT = '';

   --LOOP THROUGH CaseMjrAct_CUR 
   WHILE @Ln_FetchStatus_QNTY = 0
    BEGIN
     SET @Ls_Sql_TEXT='INSERT EPART_Y1';
     SET @Ls_SqlData_TEXT = '';

     INSERT INTO EPART_Y1
                 (Case_IDNO,
                  MemberMci_IDNO,
                  CaseRelationship_CODE,
                  RelationshipToChild_CODE,
                  Last_NAME,
                  First_NAME,
                  Middle_NAME,
                  Suffix_NAME,
                  MemberSsn_NUMB,
                  Birth_DATE,
                  MemberSex_CODE,
                  Race_CODE,
                  ColorEyes_CODE,
                  ColorHair_CODE,
                  DescriptionHeight_TEXT,
                  DescriptionWeightLbs_TEXT,
                  HomePhone_NUMB,
                  MailingLine1_ADDR,
                  MailingLine2_ADDR,
                  MailingCity_ADDR,
                  MailingState_ADDR,
                  MailingZip_ADDR,
                  CellPhone_NUMB,
                  ResidenceLine1_ADDR,
                  ResidenceLine2_ADDR,
                  ResidenceCity_ADDR,
                  ResidenceState_ADDR,
                  ResidenceZip_ADDR,
                  DescriptionIdentifyingMarks_TEXT,
                  TypeVehicle_CODE,
                  LicenseNo_TEXT,
                  IssuingState_CODE,
                  ExpireLicense_DATE,
                  CpRelationshipToNcp_CODE,
                  InterpreterRequired_INDC,
                  Language_CODE,
                  Attorney_NAME,
                  AttorneyLine1_ADDR,
                  AttorneyLine2_ADDR,
                  AttorneyCity_ADDR,
                  AttorneyState_ADDR,
                  AttorneyZip_ADDR,
                  AttorneyPhone_NUMB,
                  GuardianFirst_NAME,
                  GuardianLast_NAME,
                  DescriptionServiceDirection_TEXT)
     SELECT (RIGHT(REPLICATE(@Lc_Zero_TEXT, 6) + LTRIM(RTRIM(ISNULL(LTRIM(RTRIM(CAST(H.Case_IDNO AS VARCHAR))), ''))), 6)) AS FcioKeyCase_IDNO,
            CASE
             WHEN LEN(LTRIM(RTRIM(ISNULL(CAST(H.MemberMci_IDNO AS VARCHAR), @Lc_Empty_TEXT)))) = 0
              THEN @Lc_EmptyMemberMci_IDNO
             ELSE RIGHT(REPLICATE(@Lc_Zero_TEXT, 10) + LTRIM(RTRIM(ISNULL(LTRIM(RTRIM(CAST(H.MemberMci_IDNO AS VARCHAR))), ''))), 10)
            END AS FcioPartMci_IDNO,
            CASE
             WHEN LEN(LTRIM(RTRIM(ISNULL(H.CaseRelationship_CODE, @Lc_Empty_TEXT)))) = 0
              THEN @Lc_EmptyCaseRelationship_CODE
             ELSE CAST(LEFT((LTRIM(RTRIM(ISNULL(LTRIM(RTRIM(H.CaseRelationship_CODE)), ''))) + REPLICATE(@Lc_Space_TEXT, 1)), 1) AS CHAR(1))
            END AS FcioPartType_CODE,
            CASE
             WHEN H.CaseRelationship_CODE IN (@Lc_CaseRelationshipC_CODE, @Lc_CaseRelationshipA_CODE, @Lc_CaseRelationshipP_CODE)
              THEN
              CASE
               WHEN 0 = (SELECT COUNT(DISTINCT(X.MemberMci_IDNO))
                           FROM CMEM_Y1 X
                          WHERE X.Case_IDNO = H.Case_IDNO
                            AND X.CaseMemberStatus_CODE = @Lc_CaseMemberStatusA_CODE
                            AND X.CaseRelationship_CODE = @Lc_CaseRelationshipD_CODE)
                THEN @Lc_EmptyRelationshipToChild_CODE
               WHEN 1 >= (SELECT COUNT(DISTINCT(X.MemberMci_IDNO))
                            FROM CMEM_Y1 X
                           WHERE X.Case_IDNO = H.Case_IDNO
                             AND X.CaseMemberStatus_CODE = @Lc_CaseMemberStatusA_CODE
                             AND X.CaseRelationship_CODE = @Lc_CaseRelationshipD_CODE)
                THEN (SELECT DISTINCT
                             (CASE
                               WHEN H.CaseRelationship_CODE = @Lc_CaseRelationshipC_CODE
                                THEN
                                CASE
                                 WHEN LEN(LTRIM(RTRIM(ISNULL(X.CpRelationshipToChild_CODE, @Lc_Empty_TEXT)))) = 0
                                  THEN @Lc_EmptyRelationshipToChild_CODE
                                 ELSE CAST(LEFT((LTRIM(RTRIM(ISNULL(LTRIM(RTRIM(X.CpRelationshipToChild_CODE)), ''))) + REPLICATE(@Lc_Space_TEXT, 3)), 3) AS CHAR(3))
                                END
                               WHEN H.CaseRelationship_CODE IN (@Lc_CaseRelationshipA_CODE, @Lc_CaseRelationshipP_CODE)
                                THEN
                                CASE
                                 WHEN LEN(LTRIM(RTRIM(ISNULL(X.NcpRelationshipToChild_CODE, @Lc_Empty_TEXT)))) = 0
                                  THEN @Lc_EmptyRelationshipToChild_CODE
                                 ELSE CAST(LEFT((LTRIM(RTRIM(ISNULL(LTRIM(RTRIM(X.NcpRelationshipToChild_CODE)), ''))) + REPLICATE(@Lc_Space_TEXT, 3)), 3) AS CHAR(3))
                                END
                              END)
                        FROM CMEM_Y1 X
                       WHERE X.Case_IDNO = H.Case_IDNO
                         AND X.CaseMemberStatus_CODE = @Lc_CaseMemberStatusA_CODE
                         AND X.CaseRelationship_CODE = @Lc_CaseRelationshipD_CODE)
               ELSE
                CASE
                 WHEN 2 > (SELECT COUNT (DISTINCT (CASE
                                                    WHEN LEN(LTRIM(RTRIM(ISNULL(X.CpRelationshipToChild_CODE, @Lc_Empty_TEXT)))) = 0
                                                     THEN @Lc_EmptyRelationshipToChild_CODE
                                                    ELSE CAST(LEFT((LTRIM(RTRIM(ISNULL(LTRIM(RTRIM(X.CpRelationshipToChild_CODE)), ''))) + REPLICATE(@Lc_Space_TEXT, 3)), 3) AS CHAR(3))
                                                   END + CASE
                                                          WHEN LEN(LTRIM(RTRIM(ISNULL(X.NcpRelationshipToChild_CODE, @Lc_Empty_TEXT)))) = 0
                                                           THEN @Lc_EmptyRelationshipToChild_CODE
                                                          ELSE CAST(LEFT((LTRIM(RTRIM(ISNULL(LTRIM(RTRIM(X.NcpRelationshipToChild_CODE)), ''))) + REPLICATE(@Lc_Space_TEXT, 3)), 3) AS CHAR(3))
                                                         END))
                             FROM CMEM_Y1 X
                            WHERE X.Case_IDNO = H.Case_IDNO
                              AND X.CaseMemberStatus_CODE = @Lc_CaseMemberStatusA_CODE
                              AND X.CaseRelationship_CODE = @Lc_CaseRelationshipD_CODE)
                  THEN (SELECT DISTINCT
                               (CASE
                                 WHEN H.CaseRelationship_CODE = @Lc_CaseRelationshipC_CODE
                                  THEN
                                  CASE
                                   WHEN LEN(LTRIM(RTRIM(ISNULL(X.CpRelationshipToChild_CODE, @Lc_Empty_TEXT)))) = 0
                                    THEN @Lc_EmptyRelationshipToChild_CODE
                                   ELSE CAST(LEFT((LTRIM(RTRIM(ISNULL(LTRIM(RTRIM(X.CpRelationshipToChild_CODE)), ''))) + REPLICATE(@Lc_Space_TEXT, 3)), 3) AS CHAR(3))
                                  END
                                 WHEN H.CaseRelationship_CODE IN (@Lc_CaseRelationshipA_CODE, @Lc_CaseRelationshipP_CODE)
                                  THEN
                                  CASE
                                   WHEN LEN(LTRIM(RTRIM(ISNULL(X.NcpRelationshipToChild_CODE, @Lc_Empty_TEXT)))) = 0
                                    THEN @Lc_EmptyRelationshipToChild_CODE
                                   ELSE CAST(LEFT((LTRIM(RTRIM(ISNULL(LTRIM(RTRIM(X.NcpRelationshipToChild_CODE)), ''))) + REPLICATE(@Lc_Space_TEXT, 3)), 3) AS CHAR(3))
                                  END
                                END)
                          FROM CMEM_Y1 X
                         WHERE X.Case_IDNO = H.Case_IDNO
                           AND X.CaseMemberStatus_CODE = @Lc_CaseMemberStatusA_CODE
                           AND X.CaseRelationship_CODE = @Lc_CaseRelationshipD_CODE)
                 ELSE @Lc_EmptyRelationshipToChild_CODE
                END
              END
             ELSE @Lc_EmptyRelationshipToChild_CODE
            END AS FcioPartRelate_CODE,
            CASE
             WHEN LEN(LTRIM(RTRIM(ISNULL(I.Last_NAME, @Lc_Empty_TEXT)))) = 0
              THEN @Lc_EmptyLast_NAME
             ELSE CAST(LEFT((LTRIM(RTRIM(ISNULL(LTRIM(RTRIM(I.Last_NAME)), ''))) + REPLICATE(@Lc_Space_TEXT, 20)), 20) AS CHAR(20))
            END AS FcioPartLast_NAME,
            CASE
             WHEN LEN(LTRIM(RTRIM(ISNULL(I.First_NAME, @Lc_Empty_TEXT)))) = 0
              THEN @Lc_EmptyFirst_NAME
             ELSE CAST(LEFT((LTRIM(RTRIM(ISNULL(LTRIM(RTRIM(I.First_NAME)), ''))) + REPLICATE(@Lc_Space_TEXT, 15)), 15) AS CHAR(15))
            END AS FcioPartFirst_NAME,
            CASE
             WHEN LEN(LTRIM(RTRIM(ISNULL(I.Middle_NAME, @Lc_Empty_TEXT)))) = 0
              THEN @Lc_EmptyMi_NAME
             ELSE CAST(LEFT((LTRIM(RTRIM(ISNULL(LEFT(LTRIM(RTRIM(I.Middle_NAME)), 1), ''))) + REPLICATE(@Lc_Space_TEXT, 1)), 1) AS CHAR(1))
            END AS FcioPartMiddleInitial_NAME,
            CASE
             WHEN LEN(LTRIM(RTRIM(ISNULL(I.Suffix_NAME, @Lc_Empty_TEXT)))) = 0
              THEN @Lc_EmptySuffix_NAME
             ELSE CAST(LEFT((LTRIM(RTRIM(ISNULL(LTRIM(RTRIM(I.Suffix_NAME)), ''))) + REPLICATE(@Lc_Space_TEXT, 3)), 3) AS CHAR(3))
            END AS FcioPartSuffix_NAME,
            CASE
             WHEN LEN(LTRIM(RTRIM(ISNULL(CAST(I.MemberSsn_NUMB AS VARCHAR), @Lc_Empty_TEXT)))) = 0
              THEN @Lc_EmptyMemberSsn_NUMB
             ELSE RIGHT(REPLICATE(@Lc_Zero_TEXT, 9) + LTRIM(RTRIM(ISNULL(LTRIM(RTRIM(CAST(I.MemberSsn_NUMB AS VARCHAR))), ''))), 9)
            END AS FcioPart_SSN,
            CASE
             WHEN LEN(LTRIM(RTRIM(CAST(ISNULL(I.Birth_DATE, @Lc_Empty_TEXT) AS VARCHAR)))) = 0
              THEN @Lc_EmptyBirth_DATE
             ELSE CAST(LEFT((LTRIM(RTRIM(ISNULL(LTRIM(RTRIM(CONVERT(CHAR(8), I.Birth_DATE, 112))), ''))) + REPLICATE(@Lc_Space_TEXT, 8)), 8) AS CHAR(8))
            END AS FcioPartBirth_DATE,
            CASE
             WHEN LEN(LTRIM(RTRIM(ISNULL(I.MemberSex_CODE, @Lc_Empty_TEXT)))) = 0
              THEN @Lc_EmptyMemberSex_CODE
             ELSE CAST(LEFT((LTRIM(RTRIM(ISNULL(LTRIM(RTRIM(I.MemberSex_CODE)), ''))) + REPLICATE(@Lc_Space_TEXT, 1)), 1) AS CHAR(1))
            END AS FcioPartSex_INDC,
            CASE
             WHEN LEN(LTRIM(RTRIM(ISNULL(I.Race_CODE, @Lc_Empty_TEXT)))) = 0
              THEN @Lc_EmptyRace_CODE
             ELSE CAST(LEFT((LTRIM(RTRIM(ISNULL(LTRIM(RTRIM(I.Race_CODE)), ''))) + REPLICATE(@Lc_Space_TEXT, 1)), 1) AS CHAR(1))
            END AS FcioPartRace_CODE,
            CASE
             WHEN LEN(LTRIM(RTRIM(ISNULL(I.ColorEyes_CODE, @Lc_Empty_TEXT)))) = 0
              THEN @Lc_EmptyColorEyes_CODE
             ELSE CAST(LEFT((LTRIM(RTRIM(ISNULL(LTRIM(RTRIM(I.ColorEyes_CODE)), ''))) + REPLICATE(@Lc_Space_TEXT, 2)), 2) AS CHAR(2))
            END AS FcioPartEyeColor_CODE,
            CASE
             WHEN LEN(LTRIM(RTRIM(ISNULL(I.ColorHair_CODE, @Lc_Empty_TEXT)))) = 0
              THEN @Lc_EmptyColorHair_CODE
             ELSE CAST(LEFT((LTRIM(RTRIM(ISNULL(LTRIM(RTRIM(I.ColorHair_CODE)), ''))) + REPLICATE(@Lc_Space_TEXT, 2)), 2) AS CHAR(2))
            END AS FcioPartHairColor_CODE,
            CASE
             WHEN LEN(LTRIM(RTRIM(ISNULL(I.DescriptionHeight_TEXT, @Lc_Empty_TEXT)))) = 0
              THEN @Lc_EmptyDescriptionHeight_TEXT
             ELSE RIGHT(REPLICATE(@Lc_Zero_TEXT, 1) + LTRIM(RTRIM(ISNULL(LEFT(LTRIM(RTRIM(I.DescriptionHeight_TEXT)), 1), ''))), 1) + @Lc_Space_TEXT + CAST(LEFT((LTRIM(RTRIM(ISNULL(RIGHT(LTRIM(RTRIM(I.DescriptionHeight_TEXT)), 2), ''))) + REPLICATE(@Lc_Space_TEXT, 2)), 2) AS CHAR(2))
            END AS FcioPartHeight_TEXT,
            CASE
             WHEN LEN(LTRIM(RTRIM(ISNULL(I.DescriptionWeightLbs_TEXT, @Lc_Empty_TEXT)))) = 0
              THEN @Lc_EmptyDescriptionWeightLbs_TEXT
             ELSE RIGHT(REPLICATE(@Lc_Zero_TEXT, 4) + LTRIM(RTRIM(ISNULL(LTRIM(RTRIM(I.DescriptionWeightLbs_TEXT)), ''))), 4)
            END AS FcioPartWeight_TEXT,
            CASE
             WHEN LEN(LTRIM(RTRIM(ISNULL(CAST(I.HomePhone_NUMB AS VARCHAR), @Lc_Empty_TEXT)))) = 0
              THEN @Lc_EmptyHomePhone_NUMB
             ELSE RIGHT(REPLICATE(@Lc_Zero_TEXT, 10) + LTRIM(RTRIM(ISNULL(LTRIM(RTRIM(CAST(I.HomePhone_NUMB AS VARCHAR))), ''))), 10)
            END AS FcioPartMailPhone_NUMB,
--13617 - Get Address from OTHP for CP when on IVE cases -START-
            CASE 
				WHEN H.CaseRelationship_CODE = @Lc_CaseRelationshipC_CODE
					AND V.TypeCase_CODE IN (@Lc_TypeCaseF_CODE, @Lc_TypeCaseJ_CODE) 
					AND H.MemberMci_IDNO = @Ln_MemberMci598_IDNO THEN
					CASE
					 WHEN LEN(LTRIM(RTRIM(ISNULL(W.Line1_ADDR, @Lc_Empty_TEXT)))) = 0
					  THEN @Ls_EmptyLine1_ADDR
					 ELSE CAST(LEFT((LTRIM(RTRIM(ISNULL(LTRIM(RTRIM(W.Line1_ADDR)), ''))) + REPLICATE(@Lc_Space_TEXT, 50)), 50) AS CHAR(50))
					END
				ELSE 
					CASE
					 WHEN LEN(LTRIM(RTRIM(ISNULL(J.Line1_ADDR, @Lc_Empty_TEXT)))) = 0
					  THEN @Ls_EmptyLine1_ADDR
					 ELSE CAST(LEFT((LTRIM(RTRIM(ISNULL(LTRIM(RTRIM(J.Line1_ADDR)), ''))) + REPLICATE(@Lc_Space_TEXT, 50)), 50) AS CHAR(50))
					END				
			END,
            CASE 
				WHEN H.CaseRelationship_CODE = @Lc_CaseRelationshipC_CODE
					AND V.TypeCase_CODE IN (@Lc_TypeCaseF_CODE, @Lc_TypeCaseJ_CODE) 
					AND H.MemberMci_IDNO = @Ln_MemberMci598_IDNO THEN
					CASE
					 WHEN LEN(LTRIM(RTRIM(ISNULL(W.Line2_ADDR, @Lc_Empty_TEXT)))) = 0
					  THEN @Ls_EmptyLine2_ADDR
					 ELSE CAST(LEFT((LTRIM(RTRIM(ISNULL(LTRIM(RTRIM(W.Line2_ADDR)), ''))) + REPLICATE(@Lc_Space_TEXT, 50)), 50) AS CHAR(50))
					END	
				ELSE 
					CASE
					 WHEN LEN(LTRIM(RTRIM(ISNULL(J.Line2_ADDR, @Lc_Empty_TEXT)))) = 0
					  THEN @Ls_EmptyLine2_ADDR
					 ELSE CAST(LEFT((LTRIM(RTRIM(ISNULL(LTRIM(RTRIM(J.Line2_ADDR)), ''))) + REPLICATE(@Lc_Space_TEXT, 50)), 50) AS CHAR(50))
					END			
			END,            
            CASE 
				WHEN H.CaseRelationship_CODE = @Lc_CaseRelationshipC_CODE
					AND V.TypeCase_CODE IN (@Lc_TypeCaseF_CODE, @Lc_TypeCaseJ_CODE) 
					AND H.MemberMci_IDNO = @Ln_MemberMci598_IDNO THEN
					CASE
					 WHEN LEN(LTRIM(RTRIM(ISNULL(W.City_ADDR, @Lc_Empty_TEXT)))) = 0
					  THEN @Lc_EmptyCity_ADDR
					 ELSE CAST(LEFT((LTRIM(RTRIM(ISNULL(LTRIM(RTRIM(W.City_ADDR)), ''))) + REPLICATE(@Lc_Space_TEXT, 28)), 28) AS CHAR(28))
					END
				ELSE 
					CASE
					 WHEN LEN(LTRIM(RTRIM(ISNULL(J.City_ADDR, @Lc_Empty_TEXT)))) = 0
					  THEN @Lc_EmptyCity_ADDR
					 ELSE CAST(LEFT((LTRIM(RTRIM(ISNULL(LTRIM(RTRIM(J.City_ADDR)), ''))) + REPLICATE(@Lc_Space_TEXT, 28)), 28) AS CHAR(28))
					END
			END,
            CASE 
				WHEN H.CaseRelationship_CODE = @Lc_CaseRelationshipC_CODE
					AND V.TypeCase_CODE IN (@Lc_TypeCaseF_CODE, @Lc_TypeCaseJ_CODE) 
					AND H.MemberMci_IDNO = @Ln_MemberMci598_IDNO THEN
					CASE
					 WHEN LEN(LTRIM(RTRIM(ISNULL(W.State_ADDR, @Lc_Empty_TEXT)))) = 0
					  THEN @Lc_EmptyState_ADDR
					 ELSE CAST(LEFT((LTRIM(RTRIM(ISNULL(LTRIM(RTRIM(W.State_ADDR)), ''))) + REPLICATE(@Lc_Space_TEXT, 2)), 2) AS CHAR(2))
					END
				ELSE 
					CASE
					 WHEN LEN(LTRIM(RTRIM(ISNULL(J.State_ADDR, @Lc_Empty_TEXT)))) = 0
					  THEN @Lc_EmptyState_ADDR
					 ELSE CAST(LEFT((LTRIM(RTRIM(ISNULL(LTRIM(RTRIM(J.State_ADDR)), ''))) + REPLICATE(@Lc_Space_TEXT, 2)), 2) AS CHAR(2))
					END
			END,
            CASE 
				WHEN H.CaseRelationship_CODE = @Lc_CaseRelationshipC_CODE
					AND V.TypeCase_CODE IN (@Lc_TypeCaseF_CODE, @Lc_TypeCaseJ_CODE) 
					AND H.MemberMci_IDNO = @Ln_MemberMci598_IDNO THEN
					CASE
					 WHEN LEN(LTRIM(RTRIM(ISNULL(W.Zip_ADDR, @Lc_Empty_TEXT)))) = 0
					  THEN @Lc_EmptyZip_ADDR
					 ELSE CAST(LEFT((LTRIM(RTRIM(ISNULL(LTRIM(RTRIM(W.Zip_ADDR)), ''))) + REPLICATE(@Lc_Zero_TEXT, 9)), 9) AS CHAR(9))
					END
				ELSE 
					CASE
					 WHEN LEN(LTRIM(RTRIM(ISNULL(J.Zip_ADDR, @Lc_Empty_TEXT)))) = 0
					  THEN @Lc_EmptyZip_ADDR
					 ELSE CAST(LEFT((LTRIM(RTRIM(ISNULL(LTRIM(RTRIM(J.Zip_ADDR)), ''))) + REPLICATE(@Lc_Zero_TEXT, 9)), 9) AS CHAR(9))
					END
			END,
--13617 - Get Address from OTHP for CP when on IVE cases -END-
            CASE
             WHEN LEN(LTRIM(RTRIM(ISNULL(CAST(I.CellPhone_NUMB AS VARCHAR), @Lc_Empty_TEXT)))) = 0
              THEN @Lc_EmptyCellPhone_NUMB
             ELSE RIGHT(REPLICATE(@Lc_Zero_TEXT, 10) + LTRIM(RTRIM(ISNULL(LTRIM(RTRIM(CAST(I.CellPhone_NUMB AS VARCHAR))), ''))), 10)
            END AS FcioPartCellPhone_NUMB,
            CASE
             WHEN LEN(LTRIM(RTRIM(ISNULL(K.Line1_ADDR, @Lc_Empty_TEXT)))) = 0
              THEN @Ls_EmptyLine1_ADDR
             ELSE CAST(LEFT((LTRIM(RTRIM(ISNULL(LTRIM(RTRIM(K.Line1_ADDR)), ''))) + REPLICATE(@Lc_Space_TEXT, 50)), 50) AS CHAR(50))
            END,
            CASE
             WHEN LEN(LTRIM(RTRIM(ISNULL(K.Line2_ADDR, @Lc_Empty_TEXT)))) = 0
              THEN @Ls_EmptyLine2_ADDR
             ELSE CAST(LEFT((LTRIM(RTRIM(ISNULL(LTRIM(RTRIM(K.Line2_ADDR)), ''))) + REPLICATE(@Lc_Space_TEXT, 50)), 50) AS CHAR(50))
            END,
            CASE
             WHEN LEN(LTRIM(RTRIM(ISNULL(K.City_ADDR, @Lc_Empty_TEXT)))) = 0
              THEN @Lc_EmptyCity_ADDR
             ELSE CAST(LEFT((LTRIM(RTRIM(ISNULL(LTRIM(RTRIM(K.City_ADDR)), ''))) + REPLICATE(@Lc_Space_TEXT, 28)), 28) AS CHAR(28))
            END,
            CASE
             WHEN LEN(LTRIM(RTRIM(ISNULL(K.State_ADDR, @Lc_Empty_TEXT)))) = 0
              THEN @Lc_EmptyState_ADDR
             ELSE CAST(LEFT((LTRIM(RTRIM(ISNULL(LTRIM(RTRIM(K.State_ADDR)), ''))) + REPLICATE(@Lc_Space_TEXT, 2)), 2) AS CHAR(2))
            END,
            CASE
             WHEN LEN(LTRIM(RTRIM(ISNULL(K.Zip_ADDR, @Lc_Empty_TEXT)))) = 0
              THEN @Lc_EmptyZip_ADDR
             ELSE CAST(LEFT((LTRIM(RTRIM(ISNULL(LTRIM(RTRIM(K.Zip_ADDR)), ''))) + REPLICATE(@Lc_Zero_TEXT, 9)), 9) AS CHAR(9))
            END,
            CASE
             WHEN LEN(LTRIM(RTRIM(ISNULL(I.DescriptionIdentifyingMarks_TEXT, @Lc_Empty_TEXT)))) = 0
              THEN @Lc_EmptyDescriptionIdentifyingMarks_TEXT
             ELSE CAST(LEFT((LTRIM(RTRIM(ISNULL(LTRIM(RTRIM(I.DescriptionIdentifyingMarks_TEXT)), ''))) + REPLICATE(@Lc_Space_TEXT, 40)), 40) AS CHAR(40))
            END,
            CASE
             WHEN LEN(LTRIM(RTRIM(ISNULL(Q.Asset_CODE, @Lc_Empty_TEXT)))) = 0
              THEN @Lc_EmptyAsset_CODE
             ELSE CAST(LEFT((LTRIM(RTRIM(ISNULL(LTRIM(RTRIM(Q.Asset_CODE)), ''))) + REPLICATE(@Lc_Space_TEXT, 3)), 3) AS CHAR(3))
            END,
            CASE
             WHEN LEN(LTRIM(RTRIM(ISNULL(L.LicenseNo_TEXT, @Lc_Empty_TEXT)))) = 0
              THEN @Lc_EmptyLicenseNo_TEXT
             ELSE CAST(LEFT((LTRIM(RTRIM(ISNULL(LTRIM(RTRIM(L.LicenseNo_TEXT)), ''))) + REPLICATE(@Lc_Space_TEXT, 25)), 25) AS CHAR(25))
            END,
            CASE
             WHEN LEN(LTRIM(RTRIM(ISNULL(L.IssuingState_CODE, @Lc_Empty_TEXT)))) = 0
              THEN @Lc_EmptyIssuingState_CODE
             ELSE CAST(LEFT((LTRIM(RTRIM(ISNULL(LTRIM(RTRIM(L.IssuingState_CODE)), ''))) + REPLICATE(@Lc_Space_TEXT, 2)), 2) AS CHAR(2))
            END,
            CASE
             WHEN LEN(LTRIM(RTRIM(CAST(ISNULL(L.ExpireLicense_DATE, @Lc_Empty_TEXT) AS VARCHAR)))) = 0
                   OR CONVERT(VARCHAR(10), ISNULL(L.ExpireLicense_DATE, ''), 101) IN (@Ld_High_DATE, '01/01/1900', @Ld_Low_DATE)
              THEN @Lc_EmptyExpireLicense_DATE
             ELSE CONVERT(CHAR(8), L.ExpireLicense_DATE, 112)
            END,
            CASE
             WHEN H.CaseRelationship_CODE = @Lc_CaseRelationshipC_CODE
              THEN
              CASE
               WHEN LEN(LTRIM(RTRIM(ISNULL(P.CpRelationshipToNcp_CODE, @Lc_Empty_TEXT)))) = 0
                THEN @Lc_EmptyCpRelationshipToNcp_CODE
               ELSE CAST(LEFT((LTRIM(RTRIM(ISNULL(LTRIM(RTRIM(P.CpRelationshipToNcp_CODE)), ''))) + REPLICATE(@Lc_Space_TEXT, 3)), 3) AS CHAR(3))
              END
             ELSE @Lc_EmptyCpRelationshipToNcp_CODE
            END,
            CASE
             WHEN LEN(LTRIM(RTRIM(ISNULL(I.Language_CODE, @Lc_Empty_TEXT)))) = 0
              THEN @Lc_EmptyInterpreterReqd_INDC
             ELSE
              CASE
               WHEN UPPER(LTRIM(RTRIM(I.Language_CODE))) = @Lc_LanguageEN_CODE
                THEN @Lc_EmptyInterpreterReqd_INDC
               ELSE @Lc_InterpreterReqdY_INDC
              END
            END,
            CASE
             WHEN LEN(LTRIM(RTRIM(ISNULL(I.Language_CODE, @Lc_Empty_TEXT)))) = 0
              THEN @Lc_EmptyLanguage_CODE
             ELSE CAST(LEFT((LTRIM(RTRIM(ISNULL(LTRIM(RTRIM(I.Language_CODE)), ''))) + REPLICATE(@Lc_Space_TEXT, 2)), 2) AS CHAR(2))
            END,
            CASE
             WHEN H.CaseRelationship_CODE IN (@Lc_CaseRelationshipC_CODE, @Lc_CaseRelationshipA_CODE, @Lc_CaseRelationshipP_CODE)
              THEN
              CASE
               WHEN LEN(LTRIM(RTRIM(ISNULL(O.OtherParty_NAME, @Lc_Empty_TEXT)))) = 0
                THEN @Ls_EmptyAttorney_NAME
               ELSE CAST(LEFT((LTRIM(RTRIM(ISNULL(LTRIM(RTRIM(O.OtherParty_NAME)), ''))) + REPLICATE(@Lc_Space_TEXT, 60)), 60) AS CHAR(60))
              END
             ELSE @Ls_EmptyAttorney_NAME
            END,
            CASE
             WHEN H.CaseRelationship_CODE IN (@Lc_CaseRelationshipC_CODE, @Lc_CaseRelationshipA_CODE, @Lc_CaseRelationshipP_CODE)
              THEN
              CASE
               WHEN LEN(LTRIM(RTRIM(ISNULL(O.Line1_ADDR, @Lc_Empty_TEXT)))) = 0
                THEN @Ls_EmptyLine1_ADDR
               ELSE CAST(LEFT((LTRIM(RTRIM(ISNULL(LTRIM(RTRIM(O.Line1_ADDR)), ''))) + REPLICATE(@Lc_Space_TEXT, 50)), 50) AS CHAR(50))
              END
             ELSE @Ls_EmptyLine1_ADDR
            END,
            CASE
             WHEN H.CaseRelationship_CODE IN (@Lc_CaseRelationshipC_CODE, @Lc_CaseRelationshipA_CODE, @Lc_CaseRelationshipP_CODE)
              THEN
              CASE
               WHEN LEN(LTRIM(RTRIM(ISNULL(O.Line2_ADDR, @Lc_Empty_TEXT)))) = 0
                THEN @Ls_EmptyLine2_ADDR
               ELSE CAST(LEFT((LTRIM(RTRIM(ISNULL(LTRIM(RTRIM(O.Line2_ADDR)), ''))) + REPLICATE(@Lc_Space_TEXT, 50)), 50) AS CHAR(50))
              END
             ELSE @Ls_EmptyLine2_ADDR
            END,
            CASE
             WHEN H.CaseRelationship_CODE IN (@Lc_CaseRelationshipC_CODE, @Lc_CaseRelationshipA_CODE, @Lc_CaseRelationshipP_CODE)
              THEN
              CASE
               WHEN LEN(LTRIM(RTRIM(ISNULL(O.City_ADDR, @Lc_Empty_TEXT)))) = 0
                THEN @Lc_EmptyCity_ADDR
               ELSE CAST(LEFT((LTRIM(RTRIM(ISNULL(LTRIM(RTRIM(O.City_ADDR)), ''))) + REPLICATE(@Lc_Space_TEXT, 28)), 28) AS CHAR(28))
              END
             ELSE @Lc_EmptyCity_ADDR
            END,
            CASE
             WHEN H.CaseRelationship_CODE IN (@Lc_CaseRelationshipC_CODE, @Lc_CaseRelationshipA_CODE, @Lc_CaseRelationshipP_CODE)
              THEN
              CASE
               WHEN LEN(LTRIM(RTRIM(ISNULL(O.State_ADDR, @Lc_Empty_TEXT)))) = 0
                THEN @Lc_EmptyState_ADDR
               ELSE CAST(LEFT((LTRIM(RTRIM(ISNULL(LTRIM(RTRIM(O.State_ADDR)), ''))) + REPLICATE(@Lc_Space_TEXT, 2)), 2) AS CHAR(2))
              END
             ELSE @Lc_EmptyState_ADDR
            END,
            CASE
             WHEN H.CaseRelationship_CODE IN (@Lc_CaseRelationshipC_CODE, @Lc_CaseRelationshipA_CODE, @Lc_CaseRelationshipP_CODE)
              THEN
              CASE
               WHEN LEN(LTRIM(RTRIM(ISNULL(O.Zip_ADDR, @Lc_Empty_TEXT)))) = 0
                THEN @Lc_EmptyZip_ADDR
               ELSE CAST(LEFT((LTRIM(RTRIM(ISNULL(LTRIM(RTRIM(O.Zip_ADDR)), ''))) + REPLICATE(@Lc_Zero_TEXT, 9)), 9) AS CHAR(9))
              END
             ELSE @Lc_EmptyZip_ADDR
            END,
            CASE
             WHEN H.CaseRelationship_CODE IN (@Lc_CaseRelationshipC_CODE, @Lc_CaseRelationshipA_CODE, @Lc_CaseRelationshipP_CODE)
              THEN
              CASE
               WHEN LEN(LTRIM(RTRIM(ISNULL(CAST(O.Phone_NUMB AS VARCHAR), @Lc_Empty_TEXT)))) = 0
                THEN @Lc_EmptyPhone_NUMB
               ELSE RIGHT(REPLICATE(@Lc_Zero_TEXT, 10) + LTRIM(RTRIM(ISNULL(LTRIM(RTRIM(CAST(O.Phone_NUMB AS VARCHAR))), ''))), 10)
              END
             ELSE @Lc_EmptyPhone_NUMB
            END,
            CASE
             WHEN H.CaseRelationship_CODE IN (@Lc_CaseRelationshipA_CODE, @Lc_CaseRelationshipP_CODE)
              THEN
              CASE
               WHEN EXISTS(SELECT 1
                             FROM CMEM_Y1 X
                            WHERE X.Case_IDNO = H.Case_IDNO
                              AND X.CaseMemberStatus_CODE = @Lc_CaseMemberStatusA_CODE
                              AND X.CaseRelationship_CODE = @Lc_CaseRelationshipG_CODE)
                THEN ISNULL((SELECT TOP 1 CAST(LEFT((LTRIM(RTRIM(ISNULL(LTRIM(RTRIM(X.First_NAME)), ''))) + REPLICATE(@Lc_Space_TEXT, 15)), 15) AS CHAR(15))
                               FROM DEMO_Y1 X
                              WHERE EXISTS(SELECT 1
                                             FROM CMEM_Y1 Y
                                            WHERE Y.Case_IDNO = H.Case_IDNO
                                              AND Y.MemberMci_IDNO = X.MemberMci_IDNO
                                              AND Y.CaseMemberStatus_CODE = @Lc_CaseMemberStatusA_CODE
                                              AND Y.CaseRelationship_CODE = @Lc_CaseRelationshipG_CODE)), @Lc_EmptyFirst_NAME)
               ELSE @Lc_EmptyFirst_NAME
              END
             ELSE @Lc_EmptyFirst_NAME
            END,
            CASE
             WHEN H.CaseRelationship_CODE IN (@Lc_CaseRelationshipA_CODE, @Lc_CaseRelationshipP_CODE)
              THEN
              CASE
               WHEN EXISTS(SELECT 1
                             FROM CMEM_Y1 X
                            WHERE X.Case_IDNO = H.Case_IDNO
                              AND X.CaseMemberStatus_CODE = @Lc_CaseMemberStatusA_CODE
                              AND X.CaseRelationship_CODE = @Lc_CaseRelationshipG_CODE)
                THEN ISNULL((SELECT TOP 1 CAST(LEFT((LTRIM(RTRIM(ISNULL(LTRIM(RTRIM(X.Last_NAME)), ''))) + REPLICATE(@Lc_Space_TEXT, 20)), 20) AS CHAR(20))
                               FROM DEMO_Y1 X
                              WHERE EXISTS(SELECT 1
                                             FROM CMEM_Y1 Y
                                            WHERE Y.Case_IDNO = H.Case_IDNO
                                              AND Y.MemberMci_IDNO = X.MemberMci_IDNO
                                              AND Y.CaseMemberStatus_CODE = @Lc_CaseMemberStatusA_CODE
                                              AND Y.CaseRelationship_CODE = @Lc_CaseRelationshipG_CODE)), @Lc_EmptyLast_NAME)
               ELSE @Lc_EmptyLast_NAME
              END
             ELSE @Lc_EmptyLast_NAME
            END,
--13617 - Get Address from OTHP for CP when on IVE cases -START-
            CASE 
				WHEN H.CaseRelationship_CODE = @Lc_CaseRelationshipC_CODE
					AND V.TypeCase_CODE IN (@Lc_TypeCaseF_CODE, @Lc_TypeCaseJ_CODE) 
					AND H.MemberMci_IDNO = @Ln_MemberMci598_IDNO THEN
					@Ls_EmptyDescriptionServiceDirection_TEXT
				ELSE 
					CASE
					 WHEN LEN(LTRIM(RTRIM(ISNULL(J.DescriptionServiceDirection_TEXT, @Lc_Empty_TEXT)))) = 0
					  THEN @Ls_EmptyDescriptionServiceDirection_TEXT
					 --13721 - Check and Remove New Line Characters from Service Direction text -START-
					 ELSE CAST(LEFT((LTRIM(RTRIM(ISNULL(LTRIM(RTRIM(
						CASE 
							WHEN CHARINDEX(CHAR(10), J.DescriptionServiceDirection_TEXT) > 0 THEN 
								REPLACE(J.DescriptionServiceDirection_TEXT, CHAR(10), @Lc_Space_TEXT)
							ELSE J.DescriptionServiceDirection_TEXT
						END
						)), ''))) + REPLICATE(@Lc_Space_TEXT, 400)), 400) AS CHAR(400))
					--13721 - Check and Remove New Line Characters from Service Direction text -END-
					END
			END
--13617 - Get Address from OTHP for CP when on IVE cases -END-
       FROM DEMO_Y1 I,
            CMEM_Y1 H
            LEFT OUTER JOIN AHIS_Y1 J
             ON J.MemberMci_IDNO = H.MemberMci_IDNO
                AND J.TypeAddress_CODE = @Lc_TypeAddressM_CODE
                AND J.Status_CODE = @Lc_StatusY_CODE
                AND J.End_DATE = @Ld_High_DATE
            LEFT OUTER JOIN AHIS_Y1 K
             ON K.MemberMci_IDNO = H.MemberMci_IDNO
                AND K.TypeAddress_CODE = @Lc_TypeAddressR_CODE
                AND K.Status_CODE = @Lc_StatusY_CODE
                AND K.End_DATE = @Ld_High_DATE
--13617 - Get Address from OTHP for CP when on IVE cases -START-
            LEFT OUTER JOIN CASE_Y1 V
			 ON V.Case_IDNO = H.Case_IDNO
				AND V.StatusCase_CODE = @Lc_StatusCaseO_CODE
			LEFT OUTER JOIN OTHP_Y1 W
			 ON W.OtherParty_IDNO = 
				CASE V.County_IDNO
					WHEN @Ln_County1_IDNO THEN @Ln_OtherParty7989_IDNO 
					WHEN @Ln_County3_IDNO THEN @Ln_OtherParty7988_IDNO
					WHEN @Ln_County5_IDNO THEN @Ln_OtherParty7987_IDNO
				END
				AND W.EndValidity_DATE = @Ld_High_DATE
--13617 - Get Address from OTHP for CP when on IVE cases -END-
            LEFT OUTER JOIN PLIC_Y1 L
             ON L.MemberMci_IDNO = H.MemberMci_IDNO
                AND L.TypeLicense_CODE = @Lc_TypeLicenseDr_CODE
                AND L.Status_CODE = @Lc_StatusCg_CODE
                AND L.EndValidity_DATE = @Ld_High_DATE
            LEFT OUTER JOIN DPRS_Y1 M
             ON M.DocketPerson_IDNO = H.MemberMci_IDNO
                AND M.File_ID = (SELECT TOP 1 Y.File_ID
                                   FROM DMJR_Y1 X,
                                        DPRS_Y1 Y
                                  WHERE X.Case_IDNO = @Lc_CaseMjrActCur_Case_IDNO
                                    AND X.MajorIntSeq_NUMB = @Ln_CaseMjrActCur_MajorIntSeq_NUMB
                                    AND X.ActivityMajor_CODE = @Lc_CaseMjrActCur_ActivityMajor_CODE
                                    AND Y.DocketPerson_IDNO = X.OthpSource_IDNO
                                    AND Y.EndValidity_DATE = @Ld_High_DATE
                                    AND Y.TransactionEventSeq_NUMB = (SELECT TOP 1 MAX(Z.TransactionEventSeq_NUMB)
                                                                        FROM DPRS_Y1 Z
                                                                       WHERE Z.DocketPerson_IDNO = Y.DocketPerson_IDNO
                                                                         AND Z.TypePerson_CODE = Y.TypePerson_CODE
                                                                         AND Z.EndValidity_DATE = @Ld_High_DATE))
                AND M.EndValidity_DATE = @Ld_High_DATE
            LEFT OUTER JOIN DPRS_Y1 N
             ON N.File_ID = M.File_ID
                AND N.TypePerson_CODE = CASE
                                         WHEN M.TypePerson_CODE = @Lc_TypePartyNcp_CODE
                                          THEN @Lc_TypePartyRa_CODE
                                         WHEN M.TypePerson_CODE = @Lc_TypePartyCp_CODE
                                          THEN @Lc_TypePartyPa_CODE
                                        END
                AND N.EndValidity_DATE = @Ld_High_DATE
            LEFT OUTER JOIN OTHP_Y1 O
             ON O.OtherParty_IDNO = N.DocketPerson_IDNO
                AND O.EndValidity_DATE = @Ld_High_DATE
            LEFT OUTER JOIN (SELECT Row_NUMB = ROW_NUMBER() OVER (PARTITION BY A.MemberMci_IDNO, A.CaseRelationship_CODE ORDER BY A.TransactionEventSeq_NUMB DESC),
                                    A.*
                               FROM APCM_Y1 A
                              WHERE A.EndValidity_DATE = @Ld_High_DATE) P
             ON P.MemberMci_IDNO = H.MemberMci_IDNO
                AND P.CaseRelationship_CODE = H.CaseRelationship_CODE
                AND P.Row_NUMB = 1
            LEFT OUTER JOIN ASRV_Y1 Q
             ON Q.MemberMci_IDNO = H.MemberMci_IDNO
                AND Q.Status_CODE = @Lc_StatusY_CODE
                AND Q.EndValidity_DATE = @Ld_High_DATE
                AND Q.TransactionEventSeq_NUMB = (SELECT MAX(X.TransactionEventSeq_NUMB)
                                                    FROM ASRV_Y1 X
                                                   WHERE X.MemberMci_IDNO = Q.MemberMci_IDNO
                                                     AND X.Status_CODE = Q.Status_CODE
                                                     AND X.EndValidity_DATE = @Ld_High_DATE)
      WHERE H.Case_IDNO = @Lc_CaseMjrActCur_Case_IDNO
        AND H.CaseMemberStatus_CODE = @Lc_CaseMemberStatusA_CODE
--13710 - Incorrect PF being sent to Family Court -START-        
        AND 
        (
			H.CaseRelationship_CODE IN (@Lc_CaseRelationshipC_CODE, @Lc_CaseRelationshipA_CODE, @Lc_CaseRelationshipG_CODE, @Lc_CaseRelationshipD_CODE)
			OR 
			(
				H.CaseRelationship_CODE = @Lc_CaseRelationshipP_CODE
				AND EXISTS
				(
					SELECT 1
					FROM DMJR_Y1 Y 
					WHERE Y.Case_IDNO = H.Case_IDNO
					AND Y.MemberMci_IDNO = H.MemberMci_IDNO
					AND Y.MajorIntSeq_NUMB = @Ln_CaseMjrActCur_MajorIntSeq_NUMB
				)
			)				
		)			
--13710 - Incorrect PF being sent to Family Court -END-
        AND I.MemberMci_IDNO = H.MemberMci_IDNO;

     SET @Ls_Sql_TEXT='FETCH NEXT FROM CaseMjrAct_CUR - 2';
     SET @Ls_SqlData_TEXT = '';

     FETCH NEXT FROM CaseMjrAct_CUR INTO @Lc_CaseMjrActCur_Case_IDNO, @Ln_CaseMjrActCur_MajorIntSeq_NUMB, @Lc_CaseMjrActCur_ActivityMajor_CODE;

     SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;
    END

   SET @Ls_Sql_TEXT='CLOSE CaseMjrAct_CUR';
   SET @Ls_SqlData_TEXT = '';

   CLOSE CaseMjrAct_CUR;

   SET @Ls_Sql_TEXT='DEALLOCATE CaseMjrAct_CUR';
   SET @Ls_SqlData_TEXT = '';

   DEALLOCATE CaseMjrAct_CUR;

   SET @Ls_Sql_TEXT='DELETE EEMPL_Y1';
   SET @Ls_SqlData_TEXT = '';

   DELETE FROM EEMPL_Y1;

   SET @Ls_Sql_TEXT='INSERT EEMPL_Y1';
   SET @Ls_SqlData_TEXT = '';

   INSERT INTO EEMPL_Y1
               (Employer_IDNO,
                Fein_IDNO,
                Employer_NAME,
                Line1_ADDR,
                Line2_ADDR,
                City_ADDR,
                State_ADDR,
                Zip_ADDR,
                Phone_NUMB,
                DescriptionContactOther_TEXT)
   SELECT (RIGHT(REPLICATE(@Lc_Zero_TEXT, 9) + LTRIM(RTRIM(ISNULL(LTRIM(RTRIM(CAST(Y.OtherParty_IDNO AS VARCHAR))), ''))), 9)) AS FcioEmplOthp_IDNO,
          CASE
           WHEN LEN(LTRIM(RTRIM(ISNULL(CAST(Y.Fein_IDNO AS VARCHAR), @Lc_Empty_TEXT)))) = 0
            THEN @Lc_EmptyFein_IDNO
           ELSE RIGHT(REPLICATE(@Lc_Zero_TEXT, 9) + LTRIM(RTRIM(ISNULL(LTRIM(RTRIM(CAST(Y.Fein_IDNO AS VARCHAR))), ''))), 9)
          END AS FcioFein_IDNO,
          CASE
           WHEN LEN(LTRIM(RTRIM(ISNULL(Y.OtherParty_NAME, @Lc_Empty_TEXT)))) = 0
            THEN @Ls_EmptyEmployer_NAME
           ELSE CAST(LEFT((LTRIM(RTRIM(ISNULL(LTRIM(RTRIM(Y.OtherParty_NAME)), ''))) + REPLICATE(@Lc_Space_TEXT, 50)), 50) AS CHAR(50))
          END AS FcioEmpl_NAME,
          CASE
           WHEN LEN(LTRIM(RTRIM(ISNULL(Y.Line1_ADDR, @Lc_Empty_TEXT)))) = 0
            THEN @Ls_EmptyLine1_ADDR
           ELSE CAST(LEFT((LTRIM(RTRIM(ISNULL(LTRIM(RTRIM(Y.Line1_ADDR)), ''))) + REPLICATE(@Lc_Space_TEXT, 50)), 50) AS CHAR(50))
          END AS FcioEmplLine1_ADDR,
          CASE
           WHEN LEN(LTRIM(RTRIM(ISNULL(Y.Line2_ADDR, @Lc_Empty_TEXT)))) = 0
            THEN @Ls_EmptyLine2_ADDR
           ELSE CAST(LEFT((LTRIM(RTRIM(ISNULL(LTRIM(RTRIM(Y.Line2_ADDR)), ''))) + REPLICATE(@Lc_Space_TEXT, 50)), 50) AS CHAR(50))
          END AS FcioEmplLine2_ADDR,
          CASE
           WHEN LEN(LTRIM(RTRIM(ISNULL(Y.City_ADDR, @Lc_Empty_TEXT)))) = 0
            THEN @Lc_EmptyCity_ADDR
           ELSE CAST(LEFT((LTRIM(RTRIM(ISNULL(LTRIM(RTRIM(Y.City_ADDR)), ''))) + REPLICATE(@Lc_Space_TEXT, 28)), 28) AS CHAR(28))
          END AS FcioEmplCity_ADDR,
          CASE
           WHEN LEN(LTRIM(RTRIM(ISNULL(Y.State_ADDR, @Lc_Empty_TEXT)))) = 0
            THEN @Lc_EmptyState_ADDR
           ELSE CAST(LEFT((LTRIM(RTRIM(ISNULL(LTRIM(RTRIM(Y.State_ADDR)), ''))) + REPLICATE(@Lc_Space_TEXT, 2)), 2) AS CHAR(2))
          END AS FcioEmplState_ADDR,
          CASE
           WHEN LEN(LTRIM(RTRIM(ISNULL(Y.Zip_ADDR, @Lc_Empty_TEXT)))) = 0
            THEN @Lc_EmptyZip_ADDR
           ELSE CAST(LEFT((LTRIM(RTRIM(ISNULL(LTRIM(RTRIM(Y.Zip_ADDR)), ''))) + REPLICATE(@Lc_Zero_TEXT, 9)), 9) AS CHAR(9))
          END AS FcioEmplZip_ADDR,
          CASE
           WHEN LEN(LTRIM(RTRIM(ISNULL(CAST(Y.Phone_NUMB AS VARCHAR), @Lc_Empty_TEXT)))) = 0
            THEN @Lc_EmptyPhone_NUMB
           ELSE RIGHT(REPLICATE(@Lc_Zero_TEXT, 10) + LTRIM(RTRIM(ISNULL(LTRIM(RTRIM(CAST(Y.Phone_NUMB AS VARCHAR))), ''))), 10)
          END AS FcioEmplPhone_NUMB,
          CASE
           WHEN LEN(LTRIM(RTRIM(ISNULL(Y.DescriptionContactOther_TEXT, @Lc_Empty_TEXT)))) = 0
            THEN @Lc_EmptyEmplContact_TEXT
           ELSE CAST(LEFT((LTRIM(RTRIM(ISNULL(LTRIM(RTRIM(Y.DescriptionContactOther_TEXT)), ''))) + REPLICATE(@Lc_Space_TEXT, 24)), 24) AS CHAR(24))
          END AS FcioEmplContact_TEXT
     FROM OTHP_Y1 Y
    WHERE Y.TypeOthp_CODE = @Lc_TypeOthpE_CODE
      AND Y.BeginValidity_DATE BETWEEN DATEADD(D, 1, @Ld_LastRun_DATE) AND @Ld_Run_DATE
      AND Y.EndValidity_DATE = @Ld_High_DATE;

   SET @Ls_Sql_TEXT='DELETE EMCII_Y1';
   SET @Ls_SqlData_TEXT = '';

   DELETE FROM EMCII_Y1;

   SET @Ls_Sql_TEXT='INSERT EMCII_Y1';
   SET @Ls_SqlData_TEXT = '';

   INSERT INTO EMCII_Y1
               (MemberMciSecondary_IDNO,
                MemberMciPrimary_IDNO,
                Effective_DATE)
   SELECT (RIGHT(REPLICATE(@Lc_Zero_TEXT, 10) + LTRIM(RTRIM(ISNULL(CAST(Y.MemberMciSecondary_IDNO AS VARCHAR), ''))), 10)) AS FcioMciiOriginalMci_IDNO,
          (RIGHT(REPLICATE(@Lc_Zero_TEXT, 10) + LTRIM(RTRIM(ISNULL(CAST(Y.MemberMciPrimary_IDNO AS VARCHAR), ''))), 10)) AS FcioMciiNewMci_IDNO,
          (CONVERT(CHAR(8), @Ld_Start_DATE, 112)) AS FcioMciiEffective_DATE
     FROM MMRG_Y1 Y
    WHERE Y.StatusMerge_CODE = @Lc_StatusMergeM_CODE
      AND Y.BeginValidity_DATE BETWEEN DATEADD(D, 1, @Ld_LastRun_DATE) AND @Ld_Run_DATE
      AND Y.EndValidity_DATE = @Ld_High_DATE;

   SET @Ls_Sql_TEXT = 'INSERT ##ExtFcPetition_P1';
   SET @Ls_SqlData_TEXT = '';
   SET @Ls_Sql_TEXT='DECLARE CaseFile_CUR';
   SET @Ls_SqlData_TEXT = '';

   DECLARE CaseFile_CUR INSENSITIVE CURSOR FOR
    SELECT DISTINCT
           A.Case_IDNO,
           --13710 - Incorrect PF being sent to Family Court -START-
           A.DecssPetitionKey_IDNO AS MajorIntSeq_NUMB,
           --13710 - Incorrect PF being sent to Family Court -END-
           A.PetitionDocFile_NAME
      FROM ECASE_Y1 A
     ORDER BY A.Case_IDNO,
              --13710 - Incorrect PF being sent to Family Court -START-
              A.DecssPetitionKey_IDNO,
              --13710 - Incorrect PF being sent to Family Court -END-
              A.PetitionDocFile_NAME;

   SET @Ls_Sql_TEXT = 'OPEN CaseFile_CUR';
   SET @Ls_SqlData_TEXT = '';

   OPEN CaseFile_CUR;

   SET @Ls_Sql_TEXT = 'FETCH NEXT FROM CaseFile_CUR - 1';
   SET @Ls_SqlData_TEXT = '';

   FETCH NEXT FROM CaseFile_CUR INTO @Lc_CaseFileCur_Case_IDNO, @Ln_CaseFileCur_MajorIntSeq_NUMB, @Lc_CaseFileCur_PetitionDocFile_NAME;

   SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;
   SET @Ls_Sql_TEXT = 'FOR EACH RECORD IN CaseFile_CUR';
   SET @Ls_SqlData_TEXT = '';

   --LOOP THROUGH CaseFile_CUR
   WHILE @Ln_FetchStatus_QNTY = 0
    BEGIN
     SET @Lc_IsCaseExtracted_INDC = 'N';

     SET @Ls_Sql_TEXT='DECLARE CaseMember_CUR';
     SET @Ls_SqlData_TEXT = '';

     DECLARE CaseMember_CUR INSENSITIVE CURSOR FOR
      SELECT DISTINCT
             (RIGHT(REPLICATE(@Lc_Zero_TEXT, 10) + LTRIM(RTRIM(ISNULL(A.MemberMci_IDNO, ''))), 10)) AS MemberMci_IDNO,
             A.CaseRelationship_CODE
        FROM EPART_Y1 A
       WHERE A.Case_IDNO = @Lc_CaseFileCur_Case_IDNO
       ORDER BY MemberMci_IDNO,
                A.CaseRelationship_CODE;

     SET @Ls_Sql_TEXT = 'OPEN CaseMember_CUR';
     SET @Ls_SqlData_TEXT = '';

     OPEN CaseMember_CUR;

     SET @Ls_Sql_TEXT = 'FETCH NEXT FROM CaseMember_CUR - 1';
     SET @Ls_SqlData_TEXT = '';

     FETCH NEXT FROM CaseMember_CUR INTO @Lc_CaseMemberCur_MemberMci_IDNO, @Lc_CaseMemberCur_CaseRelationship_CODE;

     SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;
     SET @Ls_Sql_TEXT = 'FOR EACH RECORD IN CaseMember_CUR';
     SET @Ls_SqlData_TEXT = '';

     --LOOP THROUGH CaseMember_CUR
     WHILE @Ln_FetchStatus_QNTY = 0
      BEGIN
       IF @Lc_IsCaseExtracted_INDC = 'N'
        BEGIN
         SET @Ls_Sql_TEXT='INSERT ##ExtFcPetition_P1 CASE';
         SET @Ls_SqlData_TEXT = '';

         INSERT INTO ##ExtFcPetition_P1
                     (Record_TEXT)
         SELECT DISTINCT
                (X.Case_IDNO + @Lc_FcioKeyPetitionCreate_DATE + @Lc_FcioKeyPetitionCreate_TIME + @Lc_FcioKeyRecordTypeCase_CODE + X.TypePetition_CODE + X.TypeCase_CODE + X.County_IDNO + X.Petition_IDNO + @Lc_EmptySequence_NUMB + X.IVDOutOfStateRespondInit_CODE + X.IVDOutOfStateFips_CODE + X.DecssPetitionKey_IDNO + X.PetitionDocFile_NAME + REPLICATE(@Lc_Space_TEXT, 1218)) AS Record_TEXT
           FROM ECASE_Y1 X
          WHERE X.Case_IDNO = @Lc_CaseFileCur_Case_IDNO
            --13710 - Incorrect PF being sent to Family Court -START-
            AND X.DecssPetitionKey_IDNO = @Ln_CaseFileCur_MajorIntSeq_NUMB
            --13710 - Incorrect PF being sent to Family Court -END-
            AND UPPER(LTRIM(RTRIM(X.PetitionDocFile_NAME))) = UPPER(LTRIM(RTRIM(@Lc_CaseFileCur_PetitionDocFile_NAME)));

         SET @Ln_RowCount_QNTY = @@ROWCOUNT;
         SET @Ln_CaseRecordCount_QNTY = @Ln_CaseRecordCount_QNTY + @Ln_RowCount_QNTY;
         SET @Lc_IsCaseExtracted_INDC = 'Y';
        END

       SET @Ls_Sql_TEXT='INSERT ##ExtFcPetition_P1 PART';
       SET @Ls_SqlData_TEXT = '';

       INSERT INTO ##ExtFcPetition_P1
                   (Record_TEXT)
       SELECT DISTINCT
              (X.Case_IDNO + @Lc_FcioKeyPetitionCreate_DATE + @Lc_FcioKeyPetitionCreate_TIME + @Lc_FcioKeyRecordTypePart_CODE + X.MemberMci_IDNO + X.CaseRelationship_CODE + X.RelationshipToChild_CODE + X.Last_NAME + X.First_NAME + X.Middle_NAME + X.Suffix_NAME + X.MemberSsn_NUMB + X.Birth_DATE + X.MemberSex_CODE + X.Race_CODE + X.ColorEyes_CODE + X.ColorHair_CODE + X.DescriptionHeight_TEXT + X.DescriptionWeightLbs_TEXT + X.HomePhone_NUMB + CAST(LEFT((LTRIM(RTRIM(ISNULL(X.MailingLine1_ADDR, ''))) + REPLICATE(@Lc_Space_TEXT, 50)), 50) AS CHAR(50)) + CAST(LEFT((LTRIM(RTRIM(ISNULL(X.MailingLine2_ADDR, ''))) + REPLICATE(@Lc_Space_TEXT, 50)), 50) AS CHAR(50)) + X.MailingCity_ADDR + X.MailingState_ADDR + X.MailingZip_ADDR + X.CellPhone_NUMB + CAST(LEFT((LTRIM(RTRIM(ISNULL(X.ResidenceLine1_ADDR, ''))) + REPLICATE(@Lc_Space_TEXT, 50)), 50) AS CHAR(50)) + CAST(LEFT((LTRIM(RTRIM(ISNULL(X.ResidenceLine2_ADDR, ''))) + REPLICATE(@Lc_Space_TEXT, 50)), 50) AS CHAR(50)) + X.ResidenceCity_ADDR + X.ResidenceState_ADDR + X.ResidenceZip_ADDR + X.DescriptionIdentifyingMarks_TEXT + X.TypeVehicle_CODE + X.LicenseNo_TEXT + X.IssuingState_CODE + X.ExpireLicense_DATE + X.CpRelationshipToNcp_CODE + X.InterpreterRequired_INDC + X.Language_CODE + CAST(LEFT((LTRIM(RTRIM(ISNULL(X.Attorney_NAME, ''))) + REPLICATE(@Lc_Space_TEXT, 60)), 60) AS CHAR(60)) + CAST(LEFT((LTRIM(RTRIM(ISNULL(X.AttorneyLine1_ADDR, ''))) + REPLICATE(@Lc_Space_TEXT, 50)), 50) AS CHAR(50)) + CAST(LEFT((LTRIM(RTRIM(ISNULL(X.AttorneyLine2_ADDR, ''))) + REPLICATE(@Lc_Space_TEXT, 50)), 50) AS CHAR(50)) + X.AttorneyCity_ADDR + X.AttorneyState_ADDR + X.AttorneyZip_ADDR + X.AttorneyPhone_NUMB + X.GuardianFirst_NAME + X.GuardianLast_NAME + CAST(LEFT((LTRIM(RTRIM(ISNULL(X.DescriptionServiceDirection_TEXT, ''))) + REPLICATE(@Lc_Space_TEXT, 400)), 400) AS CHAR(400)) + REPLICATE(@Lc_Space_TEXT, 164)) AS Record_TEXT
         FROM EPART_Y1 X
        WHERE X.Case_IDNO = @Lc_CaseFileCur_Case_IDNO
          AND X.MemberMci_IDNO = @Lc_CaseMemberCur_MemberMci_IDNO
--13710 - Incorrect PF being sent to Family Court -START-
		AND 
		(
			X.CaseRelationship_CODE <> @Lc_CaseRelationshipP_CODE
			OR
			(
				X.CaseRelationship_CODE = @Lc_CaseRelationshipP_CODE
				AND EXISTS
				(
					SELECT 1
					FROM DMJR_Y1 Y 
					WHERE Y.Case_IDNO = X.Case_IDNO
					AND Y.MemberMci_IDNO = X.MemberMci_IDNO
					AND Y.MajorIntSeq_NUMB = @Ln_CaseFileCur_MajorIntSeq_NUMB
				)
			)
		)
--13710 - Incorrect PF being sent to Family Court -END-
       SET @Ln_RowCount_QNTY = @@ROWCOUNT;
       SET @Ln_PartRecordCount_QNTY = @Ln_PartRecordCount_QNTY + @Ln_RowCount_QNTY;

       SET @Ls_Sql_TEXT = 'FETCH NEXT FROM CaseMember_CUR - 2';
       SET @Ls_SqlData_TEXT = '';

       FETCH NEXT FROM CaseMember_CUR INTO @Lc_CaseMemberCur_MemberMci_IDNO, @Lc_CaseMemberCur_CaseRelationship_CODE;

       SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;
      END

     SET @Ls_Sql_TEXT='CLOSE CaseMember_CUR';
     SET @Ls_SqlData_TEXT = '';

     CLOSE CaseMember_CUR;

     SET @Ls_Sql_TEXT='DEALLOCATE CaseMember_CUR';
     SET @Ls_SqlData_TEXT = '';

     DEALLOCATE CaseMember_CUR;

     SET @Ls_Sql_TEXT='FETCH NEXT FROM CaseFile_CUR - 2';
     SET @Ls_SqlData_TEXT = '';

     FETCH NEXT FROM CaseFile_CUR INTO @Lc_CaseFileCur_Case_IDNO, @Ln_CaseFileCur_MajorIntSeq_NUMB, @Lc_CaseFileCur_PetitionDocFile_NAME;

     SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;
    END

   SET @Ls_Sql_TEXT='CLOSE CaseFile_CUR';
   SET @Ls_SqlData_TEXT = '';

   CLOSE CaseFile_CUR;

   SET @Ls_Sql_TEXT='DEALLOCATE CaseFile_CUR';
   SET @Ls_SqlData_TEXT = '';

   DEALLOCATE CaseFile_CUR;

   SET @Ls_Sql_TEXT='INSERT ##ExtFcPetition_P1 - EMPL';
   SET @Ls_SqlData_TEXT = '';

   INSERT INTO ##ExtFcPetition_P1
               (Record_TEXT)
   SELECT (@Lc_EmptyFcioKeyCase_IDNO + @Lc_FcioKeyPetitionCreate_DATE + @Lc_FcioKeyPetitionCreate_TIME + @Lc_FcioKeyRecordTypeEmpl_CODE + X.Employer_IDNO + X.Fein_IDNO + CAST(LEFT((LTRIM(RTRIM(ISNULL(X.Employer_NAME, ''))) + REPLICATE(@Lc_Space_TEXT, 50)), 50) AS CHAR(50)) + CAST(LEFT((LTRIM(RTRIM(ISNULL(X.Line1_ADDR, ''))) + REPLICATE(@Lc_Space_TEXT, 50)), 50) AS CHAR(50)) + CAST(LEFT((LTRIM(RTRIM(ISNULL(X.Line2_ADDR, ''))) + REPLICATE(@Lc_Space_TEXT, 50)), 50) AS CHAR(50)) + X.City_ADDR + X.State_ADDR + X.Zip_ADDR + X.Phone_NUMB + X.DescriptionContactOther_TEXT + REPLICATE(@Lc_Space_TEXT, 1033)) AS Record_TEXT
     FROM EEMPL_Y1 X;

   SET @Ln_RowCount_QNTY = @@ROWCOUNT;
   SET @Ln_EmplRecordCount_QNTY = @Ln_EmplRecordCount_QNTY + @Ln_RowCount_QNTY;
   SET @Ls_Sql_TEXT='INSERT ##ExtFcPetition_P1 - MCII';
   SET @Ls_SqlData_TEXT = '';

   INSERT INTO ##ExtFcPetition_P1
               (Record_TEXT)
   SELECT (@Lc_EmptyFcioKeyCase_IDNO + @Lc_FcioKeyPetitionCreate_DATE + @Lc_FcioKeyPetitionCreate_TIME + @Lc_FcioKeyRecordTypeMcii_CODE + X.MemberMciSecondary_IDNO + X.MemberMciPrimary_IDNO + X.Effective_DATE + REPLICATE(@Lc_Space_TEXT, 1246)) AS Record_TEXT
     FROM EMCII_Y1 X;

   SET @Ln_RowCount_QNTY = @@ROWCOUNT;
   SET @Ln_MciiRecordCount_QNTY = @Ln_MciiRecordCount_QNTY + @Ln_RowCount_QNTY;
   SET @Ls_Sql_TEXT='INSERT ##ExtFcPetition_P1 - SUMM';
   SET @Ls_SqlData_TEXT = '';

   INSERT INTO ##ExtFcPetition_P1
               (Record_TEXT)
   SELECT (@Lc_EmptyFcioKeyCase_IDNO + @Lc_FcioKeyPetitionCreate_DATE + @Lc_FcioKeyPetitionCreate_TIME + @Lc_FcioKeyRecordTypeSumm_CODE + (SELECT RIGHT(REPLICATE(@Lc_Zero_TEXT, 7) + LTRIM(RTRIM(ISNULL(CAST(SUM(X.Record_QNTY) AS VARCHAR), ''))), 7) AS FcioSummaryTotalRecord_QNTY
                                                                                                                                             FROM (SELECT @Ln_CaseRecordCount_QNTY AS Record_QNTY
                                                                                                                                                   UNION ALL
                                                                                                                                                   SELECT @Ln_PartRecordCount_QNTY AS Record_QNTY
                                                                                                                                                   UNION ALL
                                                                                                                                                   SELECT @Ln_EmplRecordCount_QNTY AS Record_QNTY
                                                                                                                                                   UNION ALL
                                                                                                                                                   SELECT @Ln_MciiRecordCount_QNTY AS Record_QNTY) X) + @Lc_Space_TEXT + (SELECT RIGHT(REPLICATE(@Lc_Zero_TEXT, 7) + LTRIM(RTRIM(ISNULL(CAST(@Ln_CaseRecordCount_QNTY AS VARCHAR), ''))), 7) AS FcioSummaryTotalCaseRecord_QNTY) + @Lc_Space_TEXT + (SELECT RIGHT(REPLICATE(@Lc_Zero_TEXT, 7) + LTRIM(RTRIM(ISNULL(CAST(@Ln_PartRecordCount_QNTY AS VARCHAR), ''))), 7) AS FcioSummaryTotalPartRecord_QNTY) + @Lc_Space_TEXT + (SELECT RIGHT(REPLICATE(@Lc_Zero_TEXT, 7) + LTRIM(RTRIM(ISNULL(CAST(@Ln_EmplRecordCount_QNTY AS VARCHAR), ''))), 7) AS FcioSummaryTotalEmplRecord_QNTY) + @Lc_Space_TEXT + (SELECT RIGHT(REPLICATE(@Lc_Zero_TEXT, 7) + LTRIM(RTRIM(ISNULL(CAST(@Ln_MciiRecordCount_QNTY AS VARCHAR), ''))), 7) AS FcioSummaryTotalMciiRecord_QNTY) + REPLICATE(@Lc_Space_TEXT, 1235)) AS Record_TEXT;

   SET @Ls_Sql_TEXT='SET ProcessedRecordCount_QNTY';
   SET @Ls_SqlData_TEXT = '';
   SET @Ln_ProcessedRecordCount_QNTY = @Ln_CaseRecordCount_QNTY + @Ln_PartRecordCount_QNTY + @Ln_EmplRecordCount_QNTY + @Ln_MciiRecordCount_QNTY

   IF @Ln_ProcessedRecordCount_QNTY = 0
    BEGIN
     SET @Ls_Sql_TEXT='BATCH_COMMON$SP_BATE_LOG';
     SET @Ls_SqlData_TEXT = '';

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Ls_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_TypeError_CODE,
      @An_Line_NUMB                = @Ln_RestartLine_NUMB,
      @Ac_Error_CODE               = @Lc_BateError_CODE,
      @As_DescriptionError_TEXT    = @Ls_BateError_TEXT,
      @As_ListKey_TEXT             = @Ls_SqlData_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

       RAISERROR (50001,16,1);
      END;
    END;

   SET @Ls_Sql_TEXT = 'COMMIT TRANSACTION EXTRACT_PETITIONS';
   SET @Ls_SqlData_TEXT = '';

   COMMIT TRANSACTION EXTRACT_PETITIONS;

   SET @Ls_Query_TEXT = 'SELECT Record_TEXT FROM ##ExtFcPetition_P1 ORDER BY Seq_IDNO';
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_EXTRACT_DATA';
   SET @Ls_SqlData_TEXT = 'FileLocation_TEXT = ' + @Ls_FileLocation_TEXT + ', File_NAME = ' + @Ls_File_NAME + ', Query_TEXT = ' + @Ls_Query_TEXT;

   EXECUTE BATCH_COMMON$SP_EXTRACT_DATA
    @As_FileLocation_TEXT     = @Ls_FileLocation_TEXT,
    @As_File_NAME             = @Ls_File_NAME,
    @As_Query_TEXT            = @Ls_Query_TEXT,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'BEGIN TRANSACTION EXTRACT_PETITIONS';
   SET @Ls_SqlData_TEXT = '';

   BEGIN TRANSACTION EXTRACT_PETITIONS;

   IF @Ln_CaseRecordCount_QNTY > 0
    BEGIN
     SET @Ls_Sql_TEXT='DECLARE NrrqAxml_CUR';
     SET @Ls_SqlData_TEXT = '';

     DECLARE NrrqAxml_CUR INSENSITIVE CURSOR FOR
      SELECT D.Barcode_NUMB
        FROM PDAFP_Y1 D
       WHERE D.MergePdf_INDC = @Lc_MergePdfY_INDC
         AND LEN(LTRIM(RTRIM(ISNULL(D.MergedPdf_NAME, @Lc_Empty_TEXT)))) > 0
         AND NOT EXISTS (SELECT 1
                           FROM PDAFP_Y1 X
                          WHERE X.Case_IDNO = D.Case_IDNO
                            AND X.County_IDNO = D.County_IDNO
                            AND X.MajorIntSeq_NUMB = D.MajorIntSeq_NUMB
                            AND X.ActivityMajor_CODE = D.ActivityMajor_CODE
                            AND X.GeneratePdf_INDC = @Lc_GeneratePdfN_INDC)
         AND D.ActivityMajor_CODE IN (@Lc_ActivityMajorEstp_CODE, @Lc_ActivityMajorMapp_CODE, @Lc_ActivityMajorRofo_CODE, @Lc_ActivityMajorImiw_CODE)
       ORDER BY D.Case_IDNO,
                D.County_IDNO,
                D.MajorIntSeq_NUMB,
                D.ActivityMajor_CODE,
                D.ReasonStatus_CODE,
                D.Barcode_NUMB;

     SET @Ls_Sql_TEXT = 'OPEN NrrqAxml_CUR';
     SET @Ls_SqlData_TEXT = '';

     OPEN NrrqAxml_CUR;

     SET @Ls_Sql_TEXT = 'FETCH NEXT FROM NrrqAxml_CUR - 1';
     SET @Ls_SqlData_TEXT = '';

     FETCH NEXT FROM NrrqAxml_CUR INTO @Ln_NrrqAxmlCur_Barcode_NUMB;

     SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;
     SET @Ls_Sql_TEXT = 'FOR EACH RECORD IN NrrqAxml_CUR';
     SET @Ls_SqlData_TEXT = '';

     --LOOP THROUGH NrrqAxml_CUR
     WHILE @Ln_FetchStatus_QNTY = 0
      BEGIN
       SET @Ls_Sql_TEXT = 'INSERT NRRQ_Y1';
       SET @Ls_Sqldata_TEXT = 'Barcode_NUMB = ' + CAST(@Ln_NrrqAxmlCur_Barcode_NUMB AS VARCHAR);

       INSERT NRRQ_Y1
              (Notice_ID,
               Case_IDNO,
               Recipient_ID,
               Barcode_NUMB,
               Recipient_CODE,
               NoticeVersion_NUMB,
               StatusNotice_CODE,
               Request_DTTM,
               WorkerRequest_ID,
               WorkerPrinted_ID,
               Generate_DTTM,
               Job_ID,
               Copies_QNTY,
               TransactionEventSeq_NUMB,
               Update_DTTM,
               File_ID,
               LoginWrkOficAttn_ADDR,
               LoginWorkersOffice_NAME,
               LoginWrkOficLine1_ADDR,
               LoginWrkOficLine2_ADDR,
               LoginWrkOficCity_ADDR,
               LoginWrkOficState_ADDR,
               LoginWrkOficZip_ADDR,
               LoginWorkerOfficeCountry_ADDR,
               RecipientAttn_ADDR,
               Recipient_NAME,
               RecipientLine1_ADDR,
               RecipientLine2_ADDR,
               RecipientCity_ADDR,
               RecipientState_ADDR,
               RecipientZip_ADDR,
               RecipientCountry_ADDR,
               PrintMethod_CODE,
               TypeService_CODE)
       SELECT A.Notice_ID,
              A.Case_IDNO,
              A.Recipient_ID,
              A.Barcode_NUMB,
              A.Recipient_CODE,
              A.NoticeVersion_NUMB,
              @Lc_StatusNoticeGenerated_CODE AS StatusNotice_CODE,
              A.Request_DTTM,
              A.WorkerRequest_ID,
              @Lc_Space_TEXT AS WorkerPrinted_ID,
              @Ld_Start_DATE AS Generate_DTTM,
              A.Job_ID,
              A.Copies_QNTY,
              A.TransactionEventSeq_NUMB,
              A.Update_DTTM,
              A.File_ID,
              A.LoginWrkOficAttn_ADDR,
              A.LoginWorkersOffice_NAME,
              A.LoginWrkOficLine1_ADDR,
              A.LoginWrkOficLine2_ADDR,
              A.LoginWrkOficCity_ADDR,
              A.LoginWrkOficState_ADDR,
              A.LoginWrkOficZip_ADDR,
              A.LoginWorkerOfficeCountry_ADDR,
              A.RecipientAttn_ADDR,
              A.Recipient_NAME,
              A.RecipientLine1_ADDR,
              A.RecipientLine2_ADDR,
              A.RecipientCity_ADDR,
              A.RecipientState_ADDR,
              A.RecipientZip_ADDR,
              A.RecipientCountry_ADDR,
              A.PrintMethod_CODE,
              A.TypeService_CODE
         FROM NMRQ_Y1 A
        WHERE A.Barcode_NUMB = @Ln_NrrqAxmlCur_Barcode_NUMB;

       SET @Ln_RowCount_QNTY = @@ROWCOUNT;

       IF @Ln_RowCount_QNTY > 0
        BEGIN
         SET @Ls_Sql_TEXT = 'DELETE NMRQ_Y1';
         SET @Ls_Sqldata_TEXT = 'Barcode_NUMB = ' + CAST(@Ln_NrrqAxmlCur_Barcode_NUMB AS VARCHAR);

         DELETE FROM NMRQ_Y1
          WHERE Barcode_NUMB = @Ln_NrrqAxmlCur_Barcode_NUMB;
        END

       SET @Ls_Sql_TEXT = 'INSERT AXML_Y1';
       SET @Ls_Sqldata_TEXT = 'Barcode_NUMB = ' + CAST(@Ln_NrrqAxmlCur_Barcode_NUMB AS VARCHAR);

       INSERT AXML_Y1
              (Barcode_NUMB,
               Xml_TEXT)
       SELECT A.Barcode_NUMB,
              A.Xml_TEXT
         FROM NXML_Y1 A
        WHERE A.Barcode_NUMB = @Ln_NrrqAxmlCur_Barcode_NUMB;

       SET @Ln_RowCount_QNTY = @@ROWCOUNT;

       IF @Ln_RowCount_QNTY > 0
        BEGIN
         SET @Ls_Sql_TEXT = 'DELETE NXML_Y1';
         SET @Ls_Sqldata_TEXT = 'Barcode_NUMB = ' + CAST(@Ln_NrrqAxmlCur_Barcode_NUMB AS VARCHAR);

         DELETE FROM NXML_Y1
          WHERE Barcode_NUMB = @Ln_NrrqAxmlCur_Barcode_NUMB;
        END

       SET @Ls_Sql_TEXT='FETCH NEXT FROM NrrqAxml_CUR - 2';
       SET @Ls_SqlData_TEXT = '';

       FETCH NEXT FROM NrrqAxml_CUR INTO @Ln_NrrqAxmlCur_Barcode_NUMB;

       SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;
      END

     SET @Ls_Sql_TEXT='CLOSE NrrqAxml_CUR';
     SET @Ls_SqlData_TEXT = '';

     CLOSE NrrqAxml_CUR;

     SET @Ls_Sql_TEXT='DEALLOCATE NrrqAxml_CUR';
     SET @Ls_SqlData_TEXT = '';

     DEALLOCATE NrrqAxml_CUR;

     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT';
     SET @Ls_SqlData_TEXT = '';

     EXEC BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
      @Ac_Worker_ID                = @Lc_BatchRunUser_TEXT,
      @Ac_Process_ID               = @Lc_Job_ID,
      @Ad_EffectiveEvent_DATE      = @Ld_Run_DATE,
      @Ac_Note_INDC                = @Lc_Note_INDC,
      @An_EventFunctionalSeq_NUMB  = 0,
      @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

       RAISERROR (50001,16,1);
      END

     SET @Ls_Sql_TEXT='DECLARE CaseJrnAct_CUR';
     SET @Ls_SqlData_TEXT = '';

     DECLARE CaseJrnAct_CUR INSENSITIVE CURSOR FOR
      SELECT DISTINCT
             A.Case_IDNO
        FROM ECASE_Y1 A
       ORDER BY A.Case_IDNO;

     SET @Ls_Sql_TEXT = 'OPEN CaseJrnAct_CUR';
     SET @Ls_SqlData_TEXT = '';

     OPEN CaseJrnAct_CUR;

     SET @Ls_Sql_TEXT = 'FETCH NEXT FROM CaseJrnAct_CUR - 1';
     SET @Ls_SqlData_TEXT = '';

     FETCH NEXT FROM CaseJrnAct_CUR INTO @Lc_CaseJrnActCur_Case_IDNO;

     SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;
     SET @Ls_Sql_TEXT = 'FOR EACH RECORD IN CaseJrnAct_CUR';
     SET @Ls_SqlData_TEXT = '';

     --LOOP THROUGH CaseJrnAct_CUR
     WHILE @Ln_FetchStatus_QNTY = 0
      BEGIN
       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_ACTIVITY';
       SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + @Lc_CaseJrnActCur_Case_IDNO;

       EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
        @An_Case_IDNO                = @Lc_CaseJrnActCur_Case_IDNO,
        @An_MemberMci_IDNO           = @Lc_Zero_TEXT,
        @Ac_ActivityMajor_CODE       = @Lc_ActivityMajorCase_CODE,
        @Ac_ActivityMinor_CODE       = @Lc_ActivityMinorRsstf_CODE,
        @Ac_Subsystem_CODE           = @Lc_SubsystemEs_CODE,
        @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
        @Ac_WorkerUpdate_ID          = @Lc_BatchRunUser_TEXT,
        @Ac_WorkerDelegate_ID        = @Lc_WorkerDelegate_ID,
        @Ad_Run_DATE                 = @Ld_Run_DATE,
        @Ac_TypeReference_CODE       = @Lc_TypeReference_IDNO,
        @Ac_Reference_ID             = @Lc_Reference_ID,
        @Ac_Notice_ID                = @Lc_Notice_ID,
        @An_TopicIn_IDNO             = @Ln_TopicIn_IDNO,
        @Ac_Job_ID                   = @Lc_Job_ID,
        @As_Xml_TEXT                 = @Ls_XmlIn_TEXT,
        @An_MajorIntSeq_NUMB         = @Ln_MajorIntSeq_NUMB,
        @An_MinorIntSeq_NUMB         = @Ln_MinorIntSeq_NUMB,
        @An_Schedule_NUMB            = @Ln_Schedule_NUMB,
        @An_Topic_IDNO               = @Ln_Topic_IDNO OUTPUT,
        @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

         RAISERROR (50001,16,1);
        END;

       SET @Ls_Sql_TEXT='FETCH NEXT FROM CaseJrnAct_CUR - 2';
       SET @Ls_SqlData_TEXT = '';

       FETCH NEXT FROM CaseJrnAct_CUR INTO @Lc_CaseJrnActCur_Case_IDNO;

       SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;
      END

     SET @Ls_Sql_TEXT='CLOSE CaseJrnAct_CUR';
     SET @Ls_SqlData_TEXT = '';

     CLOSE CaseJrnAct_CUR;

     SET @Ls_Sql_TEXT='DEALLOCATE CaseJrnAct_CUR';
     SET @Ls_SqlData_TEXT = '';

     DEALLOCATE CaseJrnAct_CUR;

     SET @Ls_Sql_TEXT='DECLARE UpdateNmrq_CUR';
     SET @Ls_SqlData_TEXT = '';

     DECLARE UpdateNmrq_CUR INSENSITIVE CURSOR FOR
      SELECT D.Barcode_NUMB
        FROM PDAFP_Y1 D
       WHERE D.ActivityMajor_CODE IN (@Lc_ActivityMajorEstp_CODE, @Lc_ActivityMajorMapp_CODE, @Lc_ActivityMajorRofo_CODE, @Lc_ActivityMajorImiw_CODE)
         AND ((D.MergePdf_INDC = @Lc_MergePdfN_INDC
               AND LEN(LTRIM(RTRIM(ISNULL(D.MergedPdf_NAME, @Lc_Empty_TEXT)))) = 0)
               OR (D.MergePdf_INDC = @Lc_MergePdfY_INDC
                   AND LEN(LTRIM(RTRIM(ISNULL(D.MergedPdf_NAME, @Lc_Empty_TEXT)))) > 0
                   AND EXISTS (SELECT 1
                                 FROM PDAFP_Y1 X
                                WHERE X.Case_IDNO = D.Case_IDNO
                                  AND X.County_IDNO = D.County_IDNO
                                  AND X.MajorIntSeq_NUMB = D.MajorIntSeq_NUMB
                                  AND X.ActivityMajor_CODE = D.ActivityMajor_CODE
                                  AND X.GeneratePdf_INDC = @Lc_GeneratePdfN_INDC)))
       ORDER BY D.Case_IDNO,
                D.County_IDNO,
                D.MajorIntSeq_NUMB,
                D.ActivityMajor_CODE,
                D.ReasonStatus_CODE,
                D.Barcode_NUMB;

     SET @Ls_Sql_TEXT = 'OPEN UpdateNmrq_CUR';
     SET @Ls_SqlData_TEXT = '';

     OPEN UpdateNmrq_CUR;

     SET @Ls_Sql_TEXT = 'FETCH NEXT FROM UpdateNmrq_CUR - 1';
     SET @Ls_SqlData_TEXT = '';

     FETCH NEXT FROM UpdateNmrq_CUR INTO @Ln_UpdateNmrqCur_Barcode_NUMB;

     SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;
     SET @Ls_Sql_TEXT = 'FOR EACH RECORD IN UpdateNmrq_CUR';
     SET @Ls_SqlData_TEXT = '';

     --LOOP THROUGH UpdateNmrq_CUR
     WHILE @Ln_FetchStatus_QNTY = 0
      BEGIN
       SET @Ls_Sql_TEXT = 'UPDATE NMRQ_Y1';
       SET @Ls_Sqldata_TEXT = 'Barcode_NUMB = ' + CAST(@Ln_UpdateNmrqCur_Barcode_NUMB AS VARCHAR);

       UPDATE NMRQ_Y1
          SET StatusNotice_CODE = @Lc_StatusNoticeFailure_CODE
        WHERE Barcode_NUMB = @Ln_UpdateNmrqCur_Barcode_NUMB;

       SET @Ls_Sql_TEXT='FETCH NEXT FROM UpdateNmrq_CUR - 2';
       SET @Ls_SqlData_TEXT = '';

       FETCH NEXT FROM UpdateNmrq_CUR INTO @Ln_UpdateNmrqCur_Barcode_NUMB;

       SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;
      END

     SET @Ls_Sql_TEXT='CLOSE UpdateNmrq_CUR';
     SET @Ls_SqlData_TEXT = '';

     CLOSE UpdateNmrq_CUR;

     SET @Ls_Sql_TEXT='DEALLOCATE UpdateNmrq_CUR';
     SET @Ls_SqlData_TEXT = '';

     DEALLOCATE UpdateNmrq_CUR;
    END;

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE';
   SET @Ls_SqlData_TEXT = 'Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BSTL_LOG';
   SET @Ls_SqlData_TEXT = 'Status_CODE = ' + @Lc_StatusSuccess_CODE;

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CURsorLocation_TEXT       = @Lc_Empty_TEXT,
    @As_ExecLocation_TEXT         = @Lc_Successful_TEXT,
    @As_ListKey_TEXT              = @Lc_Successful_TEXT,
    @As_DescriptionError_TEXT     = @Lc_Empty_TEXT,
    @Ac_Status_CODE               = @Lc_StatusSuccess_CODE,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT;

   SET @Ls_Sql_TEXT = 'COMMIT TRANSACTION EXTRACT_PETITIONS';
   SET @Ls_SqlData_TEXT = '';

   COMMIT TRANSACTION EXTRACT_PETITIONS;

   SET @Ls_Sql_TEXT = 'DROP TABLE ##ExtFcPetition_P1';
   SET @Ls_SqlData_TEXT = '';

   DROP TABLE ##ExtFcPetition_P1;
  END TRY

  BEGIN CATCH
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION EXTRACT_PETITIONS;
    END

   IF CURSOR_STATUS('Local', 'CaseMjrAct_CUR') IN (0, 1)
    BEGIN
     CLOSE CaseMjrAct_CUR;

     DEALLOCATE CaseMjrAct_CUR;
    END

   IF CURSOR_STATUS('Local', 'CaseFile_CUR') IN (0, 1)
    BEGIN
     CLOSE CaseFile_CUR;

     DEALLOCATE CaseFile_CUR;
    END

   IF CURSOR_STATUS('Local', 'CaseJrnAct_CUR') IN (0, 1)
    BEGIN
     CLOSE CaseJrnAct_CUR;

     DEALLOCATE CaseJrnAct_CUR;
    END

   IF CURSOR_STATUS('Local', 'CaseMember_CUR') IN (0, 1)
    BEGIN
     CLOSE CaseMember_CUR;

     DEALLOCATE CaseMember_CUR;
    END

   IF CURSOR_STATUS('Local', 'NrrqAxml_CUR') IN (0, 1)
    BEGIN
     CLOSE NrrqAxml_CUR;

     DEALLOCATE NrrqAxml_CUR;
    END

   IF CURSOR_STATUS('Local', 'UpdateNmrq_CUR') IN (0, 1)
    BEGIN
     CLOSE UpdateNmrq_CUR;

     DEALLOCATE UpdateNmrq_CUR;
    END

   IF OBJECT_ID('tempdb..##ExtFcPetition_P1') IS NOT NULL
    BEGIN
     DROP TABLE ##ExtFcPetition_P1;
    END;

   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_ErrorMessage_TEXT = SUBSTRING(ERROR_MESSAGE(), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_SqlData_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Lc_Empty_TEXT,
    @As_ExecLocation_TEXT         = @Ls_Sql_TEXT,
    @As_ListKey_TEXT              = @Ls_SqlData_TEXT,
    @As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE               = @Lc_StatusAbnormalEnd_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH;
 END;


GO
