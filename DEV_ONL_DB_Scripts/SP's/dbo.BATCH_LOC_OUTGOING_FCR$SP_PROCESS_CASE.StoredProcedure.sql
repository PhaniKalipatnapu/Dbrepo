/****** Object:  StoredProcedure [dbo].[BATCH_LOC_OUTGOING_FCR$SP_PROCESS_CASE]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_LOC_OUTGOING_FCR$SP_PROCESS_CASE
Programmer Name	:	IMP Team.
Description		:	The purpose of BATCH_LOC_OUTGOING_FCR$SP_PROCESS_CASE batch process is to extract Case details 
					  from system database and insert into EFCAS_Y1. And to extract member details for new case and 
                      insert into EFMEM_Y1.
Frequency		:	'DAILY'
Developed On	:	4/27/2012
Called By		:	NONE
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_LOC_OUTGOING_FCR$SP_PROCESS_CASE] (
 @Ad_Run_DATE                 DATE,
 @Ac_TransType_CODE           CHAR(2),
 @An_Case_IDNO                NUMERIC(6),
 @An_MemberMci_IDNO           NUMERIC(10),
 @An_TransactionEventSeq_NUMB NUMERIC(19),
 @Ac_Msg_CODE                 CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT    VARCHAR(4000) OUTPUT,
 @An_Batch_NUMB               NUMERIC(6),
 @Ac_Job_ID                   CHAR(7)
 )
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Ln_InputCase_IDNO                 NUMERIC(6) = @An_Case_IDNO,
          @Ln_TransactionEventSeq_NUMB       NUMERIC(19) = @An_TransactionEventSeq_NUMB,
          @Lc_Space_TEXT                     CHAR = ' ',
          @Lc_Zero_TEXT                      CHAR = '0',
          @Lc_StatusCaseMemberActive_CODE    CHAR = 'A',
          @Lc_StringZero_TEXT                CHAR = '0',
          @Lc_Yes_INDC                       CHAR = 'Y',
          @Lc_SkipRecord_INDC                CHAR = 'N',
          @Lc_StatusFailed_CODE              CHAR(1) = 'F',
          @Lc_CaseTypeNonIvd_CODE            CHAR(1) = 'H',
          @Lc_OrderTypeVoluntary_CODE        CHAR(1) = 'V',
          @Lc_CaseRelationshipDp_CODE        CHAR(1) = 'D',
          @Lc_CaseRelationshipCp_CODE        CHAR(1) = 'C',
          @Lc_CaseRelationshipNcp_CODE       CHAR(1) = 'A',
          @Lc_CaseRelationshipPf_CODE        CHAR(1) = 'P',
          @Lc_ActionAdd_CODE                 CHAR(1) = 'A',
          @Lc_ActionChange_CODE              CHAR(1) = 'C',
          @Lc_ActionDelete_CODE              CHAR(1) = 'D',
          @Lc_FcrCaseTypeNonIvd_CODE         CHAR(1) = 'N',
          @Lc_FcrCaseTypeIvd_CODE            CHAR(1) = 'F',
          @Lc_OrderYes_INDC                  CHAR(1) = 'Y',
          @Lc_OrderNo_INDC                   CHAR(1) = 'N',
          @Lc_CaseProcessFlag_INDC           CHAR(1) = 'C',
          @Lc_DebtTypeChildSupp_CODE         CHAR(2) = 'CS',
          @Lc_TransTypeCaseAdd_CODE          CHAR(2) = 'CA',
          @Lc_TransTypeCaseChange_CODE       CHAR(2) = 'CC',
          @Lc_TransTypeCaseDelete_CODE       CHAR(2) = 'CD',
          @Lc_TransTypePersonAdd_CODE        CHAR(2) = 'PA',
          @Lc_LocRequestForIvd_CODE          CHAR(2) = 'CS',
          @Lc_RecCase_ID                     CHAR(2) = 'FC',
          @Lc_RecPerson_ID                   CHAR(2) = 'FP',
          @Lc_SubsystemLo_CODE               CHAR(2) = 'LO',
          @Lc_All_TEXT                       CHAR(3) = 'ALL',
          @Lc_ActivityMajorCase_CODE         CHAR(4) = 'CASE',
          @Lc_TypeReference_IDNO             CHAR(4) = ' ',
          @Lc_BatchRunUser_TEXT              CHAR(5) = 'BATCH',
          @Lc_ActivityMinorStfcr_CODE        CHAR(5) = 'STFCR',
          @Lc_Job_ID                         CHAR(7) = @Ac_Job_ID,
          @Lc_DateFormatYyyymmdd_TEXT        CHAR(8) = 'YYYYMMDD',
          @Lc_Notice_ID                      CHAR(8) = NULL,
          @Lc_WorkerDelegate_ID              CHAR(30) = ' ',
          @Lc_Reference_ID                   CHAR(30) = ' ',
          @Ls_Procedure_NAME                 VARCHAR(100) = 'SP_PROCESS_CASE',
          @Ls_NoteDescriptionCaseAdd_TEXT    VARCHAR(4000) = 'CASE ADDITION SENT TO FCR',
          @Ls_NoteDescriptionCaseChange_TEXT VARCHAR(4000) = 'CASE CHANGES SENT TO FCR',
          @Ls_NoteDescriptionCaseDelete_TEXT VARCHAR(4000) = 'CASE DELETION SENT TO FCR',
          @Ls_XmlIn_TEXT                     VARCHAR(4000) = ' ',
          @Ld_High_DATE                      DATE = '12/31/9999',
          @Ld_Low_DATE                       DATE = '01/01/0001',
          @Ld_Run_DATE                       DATE = @Ad_Run_DATE;
  DECLARE @Ln_Zero_NUMB             NUMERIC = 0,
          @Ln_Member1_QNTY          NUMERIC(3) = 0,
          @Ln_Member2_QNTY          NUMERIC(3) = 0,
          @Ln_CaseCounty_IDNO       NUMERIC(5),
          @Ln_CaseOffice_IDNO       NUMERIC(5),
          @Ln_MajorIntSeq_NUMB      NUMERIC(5) = 0,
          @Ln_MinorIntSeq_NUMB      NUMERIC(5) = 0,
          @Ln_Case_IDNO             NUMERIC(6),
          @Ln_CasePrevious_IDNO     NUMERIC(6),
          @Ln_CaseCase_IDNO         NUMERIC(6),
          @Ln_Exists_NUMB           NUMERIC(10) = 0,
          @Ln_TopicIn_IDNO          NUMERIC(10) = 0,
          @Ln_Schedule_NUMB         NUMERIC(10) = 0,
          @Ln_Topic_IDNO            NUMERIC(10),
          @Ln_Error_NUMB            NUMERIC(11),
          @Ln_ErrorLine_NUMB        NUMERIC(11),
          @Li_FetchStatus_QNTY      SMALLINT,
          @Li_RowCount_QNTY         SMALLINT,
          @Lc_Msg_CODE              CHAR(5),
          @Lc_TypeAction_CODE       CHAR(1),
          @Lc_TypeCase_CODE         CHAR(1),
          @Lc_Order_INDC            CHAR(1),
          @Lc_CaseTypeCase_CODE     CHAR(1),
          @Lc_CaseStatusCase_CODE   CHAR(1),
          @Lc_Rec_ID                CHAR(2),
          @Lc_CountyFips_CODE       CHAR(3),
          @Lc_CaseCounty_CODE       CHAR(3),
          @Lc_UserField_NAME        CHAR(15),
          @Lc_CaseFile_ID           CHAR(15),
          @Lc_CaseWorker_ID         CHAR(30),
          @Ls_Sql_TEXT              VARCHAR(100) = '',
          @Ls_DescriptionNote_TEXT  VARCHAR(100),
          @Ls_ErrorMessage_TEXT     VARCHAR(200),
          @Ls_SqlData_TEXT          VARCHAR(1000) = '',
          @Ls_DescriptionError_TEXT VARCHAR(4000);
  DECLARE @Ln_ScrCaseCur_Case_IDNO              NUMERIC(6),
          @Ln_ScrCaseCur_MemberMci_IDNO         NUMERIC(10),
          @Lc_PscrCur_CaseRelationship_CODE     CHAR(1),
          @Lc_PscrCur_Rec_ID                    CHAR(2),
          @Lc_PscrCur_TypeAction_CODE           CHAR(1),
          @Ln_PscrCur_Case_IDNO                 NUMERIC(6),
          @Lc_PscrCur_ReservedFcr_CODE          CHAR(2),
          @Lc_PscrCur_UserField_NAME            CHAR(15),
          @Lc_PscrCur_CountyFips_CODE           CHAR(3),
          @Lc_PscrCur_TypeLocReq_CODE           CHAR(2),
          @Lc_PscrCur_BundleResults_INDC        CHAR(1),
          @Lc_PscrCur_TypeParticipant_CODE      CHAR(2),
          @Lc_PscrCur_FamilyViolence_CODE       CHAR(2),
          @Ln_PscrCur_MemberMci_IDNO            NUMERIC(10),
          @Lc_PscrCur_MemberSex_CODE            CHAR(1),
          @Ld_PscrCur_Birth_DATE                DATE,
          @Ln_PscrCur_MemberSsn_NUMB            NUMERIC(9),
          @Ln_PscrCur_PreviousMemberSsn_NUMB    NUMERIC(9),
          @Lc_PscrCur_First_NAME                CHAR(16),
          @Lc_PscrCur_Middle_NAME               CHAR(20),
          @Lc_PscrCur_Last_NAME                 CHAR(20),
          @Lc_PscrCur_BirthCity_NAME            CHAR(28),
          @Lc_PscrCur_BirthState_CODE           CHAR(2),
          @Lc_PscrCur_BirthCountry_CODE         CHAR(2),
          @Lc_PscrCur_FirstFather_NAME          CHAR(15),
          @Lc_PscrCur_MiddleFather_NAME         CHAR(20),
          @Lc_PscrCur_LastFather_NAME           CHAR(20),
          @Lc_PscrCur_FirstMother_NAME          CHAR(15),
          @Lc_PscrCur_MiddleMother_NAME         CHAR(20),
          @Lc_PscrCur_LastMother_NAME           CHAR(20),
          @Ln_PscrCur_IrsUsedMemberSsn_NUMB     NUMERIC(9),
          @Ln_PscrCur_MemberAdditional1Ssn_NUMB NUMERIC(9),
          @Ln_PscrCur_MemberAdditional2Ssn_NUMB NUMERIC(9),
          @Lc_PscrCur_FirstAdditional1_NAME     CHAR(15),
          @Lc_PscrCur_MiddleAdditional1_NAME    CHAR(20),
          @Lc_PscrCur_LastAdditional1_NAME      CHAR(20),
          @Lc_PscrCur_FirstAdditional2_NAME     CHAR(15),
          @Lc_PscrCur_MiddleAdditional2_NAME    CHAR(20),
          @Lc_PscrCur_LastAdditional2_NAME      CHAR(20),
          @Lc_PscrCur_FirstAdditional3_NAME     CHAR(15),
          @Lc_PscrCur_MiddleAdditional3_NAME    CHAR(20),
          @Lc_PscrCur_LastAdditional3_NAME      CHAR(20),
          @Lc_PscrCur_FirstAdditional4_NAME     CHAR(15),
          @Lc_PscrCur_MiddleAdditional4_NAME    CHAR(20),
          @Lc_PscrCur_LastAdditional4_NAME      CHAR(20),
          @Ln_PscrCur_NewMemberMci_IDNO         NUMERIC(10),
          @Lc_PscrCur_Irs1099_INDC              CHAR(1),
          @Lc_PscrCur_SourceLoc1_CODE           CHAR(3),
          @Lc_PscrCur_SourceLoc2_CODE           CHAR(3),
          @Lc_PscrCur_SourceLoc3_CODE           CHAR(3),
          @Lc_PscrCur_SourceLoc4_CODE           CHAR(3),
          @Lc_PscrCur_SourceLoc5_CODE           CHAR(3),
          @Lc_PscrCur_SourceLoc6_CODE           CHAR(3),
          @Lc_PscrCur_SourceLoc7_CODE           CHAR(3),
          @Lc_PscrCur_SourceLoc8_CODE           CHAR(3),
          @Lc_PscrCur_ChildNotPassed_INDC       CHAR(1);
  --scr_case cursor to select active members from cmem
  DECLARE ScrCase_CUR INSENSITIVE CURSOR FOR
   SELECT A.Case_IDNO,
          A.MemberMci_IDNO
     FROM CMEM_Y1 A
    WHERE A.Case_IDNO = @Ln_InputCase_IDNO
      AND A.CaseMemberStatus_CODE = 'A';
  --pscr cursor to select active member details from pscr   
  DECLARE Pscr_CUR INSENSITIVE CURSOR FOR
   SELECT A.CaseRelationship_CODE,
          A.Rec_ID,
          A.TypeAction_CODE,
          A.Case_IDNO,
          A.ReservedFcr_CODE,
          A.UserField_NAME,
          A.CountyFips_CODE,
          A.TypeLocReq_CODE,
          A.BundleResults_INDC,
          A.TypeParticipant_CODE,
          A.FamilyViolence_CODE,
          A.MemberMci_IDNO,
          A.MemberSex_CODE,
          A.Birth_DATE,
          A.MemberSsn_NUMB,
          A.PreviousMemberSsn_NUMB,
          A.First_NAME,
          A.Middle_NAME,
          A.Last_NAME,
          A.BirthCity_NAME,
          A.BirthState_CODE,
          A.BirthCountry_CODE,
          A.FirstFather_NAME,
          A.MiddleFather_NAME,
          A.LastFather_NAME,
          A.FirstMother_NAME,
          A.MiddleMother_NAME,
          A.LastMother_NAME,
          A.IrsUsedMemberSsn_NUMB,
          A.MemberAdditional1Ssn_NUMB,
          A.MemberAdditional2Ssn_NUMB,
          A.FirstAdditional1_NAME,
          A.MiddleAdditional1_NAME,
          A.LastAdditional1_NAME,
          A.FirstAdditional2_NAME,
          A.MiddleAdditional2_NAME,
          A.LastAdditional2_NAME,
          A.FirstAdditional3_NAME,
          A.MiddleAdditional3_NAME,
          A.LastAdditional3_NAME,
          A.FirstAdditional4_NAME,
          A.MiddleAdditional4_NAME,
          A.LastAdditional4_NAME,
          A.NewMemberMci_IDNO,
          A.Irs1099_INDC,
          A.SourceLoc1_CODE,
          A.SourceLoc2_CODE,
          A.SourceLoc3_CODE,
          A.SourceLoc4_CODE,
          A.SourceLoc5_CODE,
          A.SourceLoc6_CODE,
          A.SourceLoc7_CODE,
          A.SourceLoc8_CODE,
          A.ChildNotPassed_INDC
     FROM PSCRM_Y1 A
    WHERE A.ChildNotPassed_INDC = 'N';

  BEGIN TRY
   SET @Ac_Msg_CODE = NULL;
   SET @As_DescriptionError_TEXT = NULL;
   SET @Ls_Sql_TEXT = 'DELETE FROM PSCRM_Y1';
   SET @Ls_SqlData_TEXT = '';

   DELETE FROM PSCRM_Y1;

   SET @Lc_Rec_ID = @Lc_RecCase_ID;
   SET @Ls_Sql_TEXT = 'CHECK TRANS TYPE AND SET ACTION TYPE AND NOTE';

   IF @Ac_TransType_CODE = @Lc_TransTypeCaseAdd_CODE
    BEGIN
     SET @Lc_TypeAction_CODE = @Lc_ActionAdd_CODE;
     SET @Ls_DescriptionNote_TEXT = @Ls_NoteDescriptionCaseAdd_TEXT;
    END
   ELSE IF @Ac_TransType_CODE = @Lc_TransTypeCaseChange_CODE
    BEGIN
     SET @Lc_TypeAction_CODE = @Lc_ActionChange_CODE;
     SET @Ls_DescriptionNote_TEXT = @Ls_NoteDescriptionCaseChange_TEXT;
    END
   ELSE IF @Ac_TransType_CODE = @Lc_TransTypeCaseDelete_CODE
    BEGIN
     SET @Lc_TypeAction_CODE = @Lc_ActionDelete_CODE;
     SET @Ls_DescriptionNote_TEXT = @Ls_NoteDescriptionCaseDelete_TEXT;
    END
   ELSE
    BEGIN
     SET @Lc_TypeAction_CODE = @Lc_Space_TEXT;
     SET @Ls_DescriptionNote_TEXT = @Lc_Space_TEXT;
    END

   --Get case details from case details table for the case
   SET @Ls_Sql_TEXT = 'SELECT FROM CASE_Y1';
   SET @Ls_SqlData_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_InputCase_IDNO AS VARCHAR), '');

   SELECT @Ln_CaseCase_IDNO = A.Case_IDNO,
          @Lc_CaseTypeCase_CODE = A.TypeCase_CODE,
          @Lc_CaseStatusCase_CODE = A.StatusCase_CODE,
          @Lc_CaseCounty_CODE = A.County_IDNO,
          @Ln_CaseCounty_IDNO = A.County_IDNO,
          @Ln_CaseOffice_IDNO = A.Office_IDNO,
          @Lc_CaseWorker_ID = A.Worker_ID,
          @Lc_CaseFile_ID = A.File_ID
     FROM CASE_Y1 A
    WHERE A.Case_IDNO = @Ln_InputCase_IDNO;

   --Derive case type for FCR request file
   SET @Ls_Sql_TEXT = 'DERIVE CASE TYPE FOR FCR REQUEST FILE';

   IF @Lc_CaseTypeCase_CODE = @Lc_CaseTypeNonIvd_CODE
    BEGIN
     SET @Lc_TypeCase_CODE = @Lc_FcrCaseTypeNonIvd_CODE;
    END
   ELSE
    BEGIN
     SET @Lc_TypeCase_CODE = @Lc_FcrCaseTypeIvd_CODE;
    END

   --Get county fips code
   SET @Lc_CountyFips_CODE = @Lc_Space_TEXT;
   SET @Ls_Sql_TEXT = 'GET COUNTY FIPS CODE';

   IF dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR(@Ln_CaseCounty_IDNO) IS NOT NULL
    BEGIN
     SET @Lc_CountyFips_CODE = (RIGHT(REPLICATE('0', 3) + LTRIM(RTRIM(CAST(@Ln_CaseCounty_IDNO AS VARCHAR))), 3));
    END

   SET @Ln_Exists_NUMB = 0;
   SET @Ls_Sql_TEXT = 'CHECK FOR ORDER IN SORD_Y1';
   SET @Ls_SqlData_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_CaseCase_IDNO AS VARCHAR), '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

   SELECT @Ln_Exists_NUMB = COUNT(1)
     FROM SORD_Y1 A
    WHERE A.Case_IDNO = @Ln_CaseCase_IDNO
      AND A.TypeOrder_CODE != @Lc_OrderTypeVoluntary_CODE
      AND A.OrderEnd_DATE > @Ld_Run_DATE
      AND A.EndValidity_DATE = @Ld_High_DATE;

   --Get support order inidcator 
   SET @Ls_Sql_TEXT = 'GET SUPPORT ORDER INIDCATOR';

   IF @Ln_Exists_NUMB > 0
    BEGIN
     SET @Lc_Order_INDC = @Lc_OrderYes_INDC;
    END
   ELSE
    BEGIN
     SET @Lc_Order_INDC = @Lc_OrderNo_INDC;
    END

   IF @Lc_CaseTypeCase_CODE = @Lc_CaseTypeNonIvd_CODE
      AND @Ac_TransType_CODE <> @Lc_TransTypeCaseDelete_CODE
    BEGIN
     --check for child support obligation
     SET @Ls_Sql_TEXT = 'SELECT OBLE_Y1';
     SET @Ls_SqlData_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_CaseCase_IDNO AS VARCHAR), '') + ', TypeDebt_CODE = ' + ISNULL(@Lc_DebtTypeChildSupp_CODE, '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

     SELECT @Ln_Exists_NUMB = COUNT(1)
       FROM OBLE_Y1 a
      WHERE a.Case_IDNO = @Ln_CaseCase_IDNO
        AND a.TypeDebt_CODE = @Lc_DebtTypeChildSupp_CODE
        AND a.EndValidity_DATE = @Ld_High_DATE;

     IF @Ln_Exists_NUMB > 0
      BEGIN
       SET @Lc_Order_INDC = @Lc_OrderYes_INDC;
      END
     ELSE
      BEGIN
       --No child support order established for this case skip the case 
       SET @Lc_SkipRecord_INDC = 'Y';
       SET @Ls_ErrorMessage_TEXT = 'NO CHILD SUPPORT ORDER ESTABLISHED FOR THIS CASE';

       RAISERROR(50001,16,1);
      END
    END

   --Set run date as User field
   SET @Lc_UserField_NAME = CONVERT(VARCHAR(8), @Ld_Run_DATE, 112);
   SET @Ln_CasePrevious_IDNO = @Lc_Zero_TEXT;
   SET @Ln_Case_IDNO = @Ln_CaseCase_IDNO;
   SET @Ln_Member1_QNTY = 0;

   --If case Add transaction then get all members in case.
   IF @Ac_TransType_CODE = @Lc_TransTypeCaseAdd_CODE
    BEGIN
     SET @Ls_Sql_TEXT = 'OPEN ScrCase_CUR';

     OPEN ScrCase_CUR;

     SET @Ls_Sql_TEXT = 'FETCH NEXT FROM ScrCase_CUR - 1';

     FETCH NEXT FROM ScrCase_CUR INTO @Ln_ScrCaseCur_Case_IDNO, @Ln_ScrCaseCur_MemberMci_IDNO;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
     SET @Ls_Sql_TEXT = 'LOOP THROUGH ScrCase_CUR';

     --Get all persons details for the new case add. 
     WHILE @Li_FetchStatus_QNTY = 0
      BEGIN
       SET @Ln_Member1_QNTY = @Ln_Member1_QNTY + 1;
       SET @Ls_Sql_TEXT = 'BATCH_LOC_OUTGOING_FCR$SP_PROCESS_PERSON FOR CASE ADD TRANS ' + CAST(ISNULL(@Ln_Member1_QNTY, '0') AS VARCHAR);
       SET @Ls_SqlData_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', ProcessFlag_INDC = ' + ISNULL(@Lc_CaseProcessFlag_INDC, '') + ', TransType_CODE = ' + ISNULL(@Lc_TransTypePersonAdd_CODE, '') + ', Case_IDNO = ' + ISNULL(CAST(@Ln_ScrCaseCur_Case_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_ScrCaseCur_MemberMci_IDNO AS VARCHAR), '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', Batch_NUMB = ' + ISNULL(CAST(@An_Batch_NUMB AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '');

       EXECUTE BATCH_LOC_OUTGOING_FCR$SP_PROCESS_PERSON
        @Ad_Run_DATE                 = @Ld_Run_DATE,
        @Ac_Process_INDC             = @Lc_CaseProcessFlag_INDC,
        @Ac_TransType_CODE           = @Lc_TransTypePersonAdd_CODE,
        @An_Case_IDNO                = @Ln_ScrCaseCur_Case_IDNO,
        @An_MemberMci_IDNO           = @Ln_ScrCaseCur_MemberMci_IDNO,
        @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
        @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT,
        @An_Batch_NUMB               = @An_Batch_NUMB,
        @Ac_Job_ID                   = @Lc_Job_ID;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

         RAISERROR(50001,16,1);
        END

       SET @Ls_Sql_TEXT = 'FETCH NEXT FROM ScrCase_CUR - 2';

       FETCH NEXT FROM ScrCase_CUR INTO @Ln_ScrCaseCur_Case_IDNO, @Ln_ScrCaseCur_MemberMci_IDNO;

       SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
      END

     IF CURSOR_STATUS('LOCAL', 'ScrCase_CUR') IN (0, 1)
      BEGIN
       SET @Ls_Sql_TEXT = 'CLOSE ScrCase_CUR';

       CLOSE ScrCase_CUR;

       SET @Ls_Sql_TEXT = 'DEALLOCATE ScrCase_CUR';

       DEALLOCATE ScrCase_CUR;
      END

     SET @Ln_Exists_NUMB = 0;
     --check if atleast one dependent exists or not
     SET @Ls_Sql_TEXT = 'CHECK FOR DEPENDENT IN PSCRM_Y1';
     SET @Ls_SqlData_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_InputCase_IDNO AS VARCHAR), '') + ', CaseRelationship_CODE = ' + ISNULL(@Lc_CaseRelationshipDp_CODE, '');

     SELECT @Ln_Exists_NUMB = COUNT(1)
       FROM PSCRM_Y1 A
      WHERE A.Case_IDNO = @Ln_InputCase_IDNO
        AND A.MemberMci_IDNO > 0
        AND A.CaseRelationship_CODE = @Lc_CaseRelationshipDp_CODE;

     IF @Ln_Exists_NUMB = 0
      BEGIN
       --No child specified for this case
       SET @Lc_SkipRecord_INDC = 'Y';
       SET @Ls_ErrorMessage_TEXT = 'NO CHILD SPECIFIED FOR THIS CASE';

       RAISERROR(50001,16,1);
      END

     SET @Ln_Exists_NUMB = 0;
     --Check for existance of CP/NCP/PF in PSCRM
     SET @Ls_Sql_TEXT = 'CHECK FOR ADULT IN PSCRM_Y1';
     SET @Ls_SqlData_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_InputCase_IDNO AS VARCHAR), '');

     SELECT @Ln_Exists_NUMB = COUNT(1)
       FROM PSCRM_Y1 A
      WHERE A.Case_IDNO = @Ln_InputCase_IDNO
        AND A.MemberMci_IDNO > 0
        AND A.CaseRelationship_CODE IN (@Lc_CaseRelationshipCp_CODE, @Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPf_CODE);

     IF @Ln_Exists_NUMB = 0
      BEGIN
       SET @Ls_Sql_TEXT = 'UPDATE PSCRM_Y1 - 1';
       SET @Ls_SqlData_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_InputCase_IDNO AS VARCHAR), '');

       UPDATE PSCRM_Y1
          SET ChildNotPassed_INDC = @Lc_Yes_INDC
        WHERE Case_IDNO = @Ln_InputCase_IDNO
          AND MemberMci_IDNO > 0;

       SET @Li_RowCount_QNTY = @@ROWCOUNT;

       IF @Li_RowCount_QNTY = 0
        BEGIN
         SET @Ls_ErrorMessage_TEXT = 'UPDATE PSCRM_Y1 - 1 FAILED';

         RAISERROR(50001,16,1);
        END

       --No adult in case
       SET @Lc_SkipRecord_INDC = 'Y';
       SET @Ls_ErrorMessage_TEXT = 'NO ADULT IN CASE';

       RAISERROR(50001,16,1);
      END
    END

   SET @Ls_Sql_TEXT = 'INSERT INTO EFCAS_Y1';
   SET @Ls_SqlData_TEXT = 'Rec_ID = ' + ISNULL(@Lc_Rec_ID, '') + ', TypeAction_CODE = ' + ISNULL(@Lc_TypeAction_CODE, '') + ', Case_IDNO = ' + ISNULL(CAST(@Ln_Case_IDNO AS VARCHAR), '') + ', TypeCase_CODE = ' + ISNULL(@Lc_TypeCase_CODE, '') + ', Order_INDC = ' + ISNULL(@Lc_Order_INDC, '') + ', CountyFips_CODE = ' + ISNULL(@Lc_CountyFips_CODE, '') + ', UserField_NAME = ' + ISNULL(@Lc_UserField_NAME, '') + ', CasePrevious_IDNO = ' + ISNULL(CAST(@Ln_CasePrevious_IDNO AS VARCHAR), '');

   INSERT EFCAS_Y1
          (Rec_ID,
           TypeAction_CODE,
           Case_IDNO,
           TypeCase_CODE,
           Order_INDC,
           CountyFips_CODE,
           UserField_NAME,
           CasePrevious_IDNO)
   VALUES ( @Lc_Rec_ID,--Rec_ID
            @Lc_TypeAction_CODE,--TypeAction_CODE
            @Ln_Case_IDNO,--Case_IDNO
            @Lc_TypeCase_CODE,--TypeCase_CODE
            @Lc_Order_INDC,--Order_INDC
            @Lc_CountyFips_CODE,--CountyFips_CODE
            @Lc_UserField_NAME,--UserField_NAME
            @Ln_CasePrevious_IDNO --CasePrevious_IDNO
   );

   SET @Li_RowCount_QNTY = @@ROWCOUNT;

   IF @Li_RowCount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'INSERT INTO EFCAS_Y1 FAILED';

     RAISERROR(50001,16,1);
    END

   SET @Ln_Exists_NUMB = 0;
   --check for member in FADT
   SET @Ls_Sql_TEXT = 'CHECK FOR EXISTANCE IN FADT_Y1 - 1';
   SET @Ls_SqlData_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_InputCase_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + CAST(@Ln_Zero_NUMB AS VARCHAR) + ', TypeTrans_CODE = ' + ISNULL(@Lc_RecCase_ID, '');

   SELECT @Ln_Exists_NUMB = COUNT(1)
     FROM FADT_Y1 A
    WHERE A.Case_IDNO = @Ln_InputCase_IDNO
      AND A.MemberMci_IDNO = @Ln_Zero_NUMB
      AND A.TypeTrans_CODE = @Lc_RecCase_ID;

   IF @Ln_Exists_NUMB > 0
    BEGIN
     --Update FADT details
     SET @Ls_Sql_TEXT = 'UPDATE FADT_Y1 - 1';
     SET @Ls_SqlData_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_InputCase_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + CAST(@Ln_Zero_NUMB AS VARCHAR) + ', TypeTrans_CODE = ' + ISNULL(@Lc_RecCase_ID, '');

     UPDATE FADT_Y1
        SET TypeTrans_CODE = @Lc_Rec_ID,
            Action_CODE = @Lc_TypeAction_CODE,
            Transmitted_DATE = @Ld_Run_DATE,
            TypeCase_CODE = @Lc_CaseTypeCase_CODE,
            StatusCase_CODE = @Lc_CaseStatusCase_CODE,
            County_IDNO = @Lc_CaseCounty_CODE,
            Order_INDC = @Lc_Order_INDC,
            Batch_NUMB = @An_Batch_NUMB
      WHERE Case_IDNO = @Ln_InputCase_IDNO
        AND MemberMci_IDNO = @Ln_Zero_NUMB
        AND TypeTrans_CODE = @Lc_RecCase_ID;

     SET @Li_RowCount_QNTY = @@ROWCOUNT;

     IF @Li_RowCount_QNTY = 0
      BEGIN
       SET @Ls_ErrorMessage_TEXT = 'UPDATE FADT_Y1 - 1 FAILED';

       RAISERROR(50001,16,1);
      END
    END
   ELSE
    BEGIN
     SET @Ls_Sql_TEXT = 'INSERT INTO FADT_Y1 - 1';
     SET @Ls_SqlData_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_InputCase_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + CAST(@Ln_Zero_NUMB AS VARCHAR) + ', Action_CODE = ' + ISNULL(@Lc_TypeAction_CODE, '') + ', TypeTrans_CODE = ' + ISNULL(@Lc_Rec_ID, '') + ', Transmitted_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', TypeCase_CODE = ' + ISNULL(@Lc_CaseTypeCase_CODE, '') + ', StatusCase_CODE = ' + ISNULL(@Lc_CaseStatusCase_CODE, '') + ', County_IDNO = ' + ISNULL(@Lc_CaseCounty_CODE, '') + ', Order_INDC = ' + ISNULL(@Lc_Order_INDC, '') + ', MemberSsn_NUMB = ' + CAST(@Ln_Zero_NUMB AS VARCHAR) + ', Birth_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '') + ', Last_NAME = ' + ISNULL(@Lc_Space_TEXT, '') + ', First_NAME = ' + ISNULL(@Lc_Space_TEXT, '') + ', CaseRelationship_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', CaseMemberStatus_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', Response_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '') + ', ResponseFcr_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', Batch_NUMB = ' + ISNULL(CAST(@An_Batch_NUMB AS VARCHAR), '');

     INSERT FADT_Y1
            (Case_IDNO,
             MemberMci_IDNO,
             Action_CODE,
             TypeTrans_CODE,
             Transmitted_DATE,
             TypeCase_CODE,
             StatusCase_CODE,
             County_IDNO,
             Order_INDC,
             MemberSsn_NUMB,
             Birth_DATE,
             Last_NAME,
             First_NAME,
             CaseRelationship_CODE,
             CaseMemberStatus_CODE,
             Response_DATE,
             ResponseFcr_CODE,
             Batch_NUMB)
     VALUES ( @Ln_InputCase_IDNO,--Case_IDNO
              @Ln_Zero_NUMB,--MemberMci_IDNO
              @Lc_TypeAction_CODE,--Action_CODE
              @Lc_Rec_ID,--TypeTrans_CODE
              @Ld_Run_DATE,--Transmitted_DATE
              @Lc_CaseTypeCase_CODE,--TypeCase_CODE
              @Lc_CaseStatusCase_CODE,--StatusCase_CODE
              @Lc_CaseCounty_CODE,--County_IDNO
              @Lc_Order_INDC,--Order_INDC
              @Ln_Zero_NUMB,--MemberSsn_NUMB
              @Ld_Low_DATE,--Birth_DATE
              @Lc_Space_TEXT,--Last_NAME
              @Lc_Space_TEXT,--First_NAME
              @Lc_Space_TEXT,--CaseRelationship_CODE
              @Lc_Space_TEXT,--CaseMemberStatus_CODE
              @Ld_Low_DATE,--Response_DATE
              @Lc_Space_TEXT,--ResponseFcr_CODE
              @An_Batch_NUMB --Batch_NUMB
     );

     SET @Li_RowCount_QNTY = @@ROWCOUNT;

     IF @Li_RowCount_QNTY = 0
      BEGIN
       SET @Ls_ErrorMessage_TEXT = 'INSERT INTO FADT_Y1 - 1 FAILED';

       RAISERROR(50001,16,1);
      END
    END

   SET @Ln_Exists_NUMB = 0;
   --Delete record from fprj.
   SET @Ls_Sql_TEXT = 'CHECK FOR Case_IDNO IN FPRJ_Y1 - 1';
   SET @Ls_SqlData_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_InputCase_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + CAST(@Ln_Zero_NUMB AS VARCHAR);

   SELECT @Ln_Exists_NUMB = COUNT(1)
     FROM FPRJ_Y1 A
    WHERE A.Case_IDNO = @Ln_InputCase_IDNO
      AND A.MemberMci_IDNO = @Ln_Zero_NUMB;

   IF @Ln_Exists_NUMB != 0
    BEGIN
     SET @Ls_Sql_TEXT = 'DELETE FROM FPRJ_Y1 - 1';
     SET @Ls_SqlData_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_InputCase_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + CAST(@Ln_Zero_NUMB AS VARCHAR);

     DELETE FROM FPRJ_Y1
      WHERE Case_IDNO = @Ln_InputCase_IDNO
        AND MemberMci_IDNO = @Ln_Zero_NUMB;

     SET @Li_RowCount_QNTY = @@ROWCOUNT;

     IF @Li_RowCount_QNTY = 0
      BEGIN
       SET @Ls_ErrorMessage_TEXT = 'DELETE FROM FPRJ_Y1 - 1 FAILED';

       RAISERROR(50001,16,1);
      END
    END

   --write a case Journal entry for transactions submitted to FCR
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_ACTIVITY - 1';
   SET @Ls_SqlData_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_InputCase_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + CAST(@Ln_Zero_NUMB AS VARCHAR) + ', ActivityMajor_CODE = ' + ISNULL(@Lc_ActivityMajorCase_CODE, '') + ', ActivityMinor_CODE = ' + ISNULL(@Lc_ActivityMinorStfcr_CODE, '') + ', Subsystem_CODE = ' + ISNULL(@Lc_SubsystemLo_CODE, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', WorkerUpdate_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', WorkerDelegate_ID = ' + ISNULL(@Lc_WorkerDelegate_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', TypeReference_CODE = ' + ISNULL(@Lc_TypeReference_IDNO, '') + ', Reference_ID = ' + ISNULL(@Lc_Reference_ID, '') + ', Notice_ID = ' + ISNULL(@Lc_Notice_ID, '') + ', TopicIn_IDNO = ' + ISNULL(CAST(@Ln_TopicIn_IDNO AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Xml_TEXT = ' + ISNULL(@Ls_XmlIn_TEXT, '') + ', MajorIntSeq_NUMB = ' + ISNULL(CAST(@Ln_MajorIntSeq_NUMB AS VARCHAR), '') + ', MinorIntSeq_NUMB = ' + ISNULL(CAST(@Ln_MinorIntSeq_NUMB AS VARCHAR), '') + ', Schedule_NUMB = ' + ISNULL(CAST(@Ln_Schedule_NUMB AS VARCHAR), '');

   EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
    @An_Case_IDNO                = @Ln_InputCase_IDNO,
    @An_MemberMci_IDNO           = @Ln_Zero_NUMB,
    @Ac_ActivityMajor_CODE       = @Lc_ActivityMajorCase_CODE,
    @Ac_ActivityMinor_CODE       = @Lc_ActivityMinorStfcr_CODE,
    @Ac_Subsystem_CODE           = @Lc_SubsystemLo_CODE,
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

   --Notes added for corresponding case journal entry
   SET @Ls_Sql_TEXT = 'BATCH_COMMON_NOTE$SP_CREATE_NOTE - 1';
   SET @Ls_SqlData_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_InputCase_IDNO AS VARCHAR), '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', DescriptionNote_TEXT = ' + ISNULL(@Ls_DescriptionNote_TEXT, '') + ', Category_CODE = ' + ISNULL(@Lc_SubsystemLo_CODE, '') + ', Subject_CODE = ' + ISNULL(@Lc_ActivityMinorStfcr_CODE, '') + ', WorkerSignedOn_IDNO = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', Process_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Topic_IDNO = ' + ISNULL(CAST(@Ln_Topic_IDNO AS VARCHAR), '');

   EXECUTE BATCH_COMMON_NOTE$SP_CREATE_NOTE
    @Ac_Case_IDNO                = @Ln_InputCase_IDNO,
    @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
    @As_DescriptionNote_TEXT     = @Ls_DescriptionNote_TEXT,
    @Ac_Category_CODE            = @Lc_SubsystemLo_CODE,
    @Ac_Subject_CODE             = @Lc_ActivityMinorStfcr_CODE,
    @As_WorkerSignedOn_IDNO      = @Lc_BatchRunUser_TEXT,
    @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT,
    @Ac_Process_ID               = @Lc_Job_ID,
    @An_Topic_IDNO               = @Ln_Topic_IDNO;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'OPEN Pscr_CUR';

   OPEN Pscr_CUR;

   SET @Ls_Sql_TEXT = 'FETCH NEXT FROM Pscr_CUR - 1';

   FETCH NEXT FROM Pscr_CUR INTO @Lc_PscrCur_CaseRelationship_CODE, @Lc_PscrCur_Rec_ID, @Lc_PscrCur_TypeAction_CODE, @Ln_PscrCur_Case_IDNO, @Lc_PscrCur_ReservedFcr_CODE, @Lc_PscrCur_UserField_NAME, @Lc_PscrCur_CountyFips_CODE, @Lc_PscrCur_TypeLocReq_CODE, @Lc_PscrCur_BundleResults_INDC, @Lc_PscrCur_TypeParticipant_CODE, @Lc_PscrCur_FamilyViolence_CODE, @Ln_PscrCur_MemberMci_IDNO, @Lc_PscrCur_MemberSex_CODE, @Ld_PscrCur_Birth_DATE, @Ln_PscrCur_MemberSsn_NUMB, @Ln_PscrCur_PreviousMemberSsn_NUMB, @Lc_PscrCur_First_NAME, @Lc_PscrCur_Middle_NAME, @Lc_PscrCur_Last_NAME, @Lc_PscrCur_BirthCity_NAME, @Lc_PscrCur_BirthState_CODE, @Lc_PscrCur_BirthCountry_CODE, @Lc_PscrCur_FirstFather_NAME, @Lc_PscrCur_MiddleFather_NAME, @Lc_PscrCur_LastFather_NAME, @Lc_PscrCur_FirstMother_NAME, @Lc_PscrCur_MiddleMother_NAME, @Lc_PscrCur_LastMother_NAME, @Ln_PscrCur_IrsUsedMemberSsn_NUMB, @Ln_PscrCur_MemberAdditional1Ssn_NUMB, @Ln_PscrCur_MemberAdditional2Ssn_NUMB, @Lc_PscrCur_FirstAdditional1_NAME, @Lc_PscrCur_MiddleAdditional1_NAME, @Lc_PscrCur_LastAdditional1_NAME, @Lc_PscrCur_FirstAdditional2_NAME, @Lc_PscrCur_MiddleAdditional2_NAME, @Lc_PscrCur_LastAdditional2_NAME, @Lc_PscrCur_FirstAdditional3_NAME, @Lc_PscrCur_MiddleAdditional3_NAME, @Lc_PscrCur_LastAdditional3_NAME, @Lc_PscrCur_FirstAdditional4_NAME, @Lc_PscrCur_MiddleAdditional4_NAME, @Lc_PscrCur_LastAdditional4_NAME, @Ln_PscrCur_NewMemberMci_IDNO, @Lc_PscrCur_Irs1099_INDC, @Lc_PscrCur_SourceLoc1_CODE, @Lc_PscrCur_SourceLoc2_CODE, @Lc_PscrCur_SourceLoc3_CODE, @Lc_PscrCur_SourceLoc4_CODE, @Lc_PscrCur_SourceLoc5_CODE, @Lc_PscrCur_SourceLoc6_CODE, @Lc_PscrCur_SourceLoc7_CODE, @Lc_PscrCur_SourceLoc8_CODE, @Lc_PscrCur_ChildNotPassed_INDC;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
   SET @Ls_Sql_TEXT = 'LOOP THROUGH Pscr_CUR';

   --member cursor to get member information for new case
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
     SET @Ln_Member2_QNTY = @Ln_Member2_QNTY + 1;

     IF @Lc_PscrCur_CaseRelationship_CODE IN (@Lc_CaseRelationshipCp_CODE, @Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPf_CODE)
      BEGIN
       SET @Ls_Sql_TEXT = 'UPDATE PSCRM_Y1 - 2';
       --Member not located set loc_re_type as IVD. 
       SET @Ls_SqlData_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_PscrCur_MemberMci_IDNO AS VARCHAR), '') + ', CaseRelationship_CODE = ' + ISNULL(@Lc_PscrCur_CaseRelationship_CODE, '');

       UPDATE PSCRM_Y1
          SET TypeLocReq_CODE = @Lc_LocRequestForIvd_CODE,
              BundleResults_INDC = @Lc_Yes_INDC,
              SourceLoc1_CODE = @Lc_All_TEXT
        WHERE MemberMci_IDNO = @Ln_PscrCur_MemberMci_IDNO
          AND CaseRelationship_CODE = @Lc_PscrCur_CaseRelationship_CODE;

       SET @Li_RowCount_QNTY = @@ROWCOUNT;

       IF @Li_RowCount_QNTY = 0
        BEGIN
         SET @Ls_ErrorMessage_TEXT = 'UPDATE PSCRM_Y1 - 2 FAILED';

         RAISERROR(50001,16,1);
        END
      END

     SET @Ls_Sql_TEXT = 'INSERT INTO EFMEM_Y1 - 1';
     --Insert member extracted details into extract_member 
     SET @Ls_SqlData_TEXT = 'Rec_ID = ' + ISNULL(@Lc_PscrCur_Rec_ID, '') + ', TypeAction_CODE = ' + ISNULL(@Lc_PscrCur_TypeAction_CODE, '') + ', Case_IDNO = ' + ISNULL(CAST(@Ln_PscrCur_Case_IDNO AS VARCHAR), '') + ', ReservedFcr_CODE = ' + ISNULL(@Lc_PscrCur_ReservedFcr_CODE, '') + ', UserField_NAME = ' + ISNULL(@Lc_PscrCur_UserField_NAME, '') + ', CountyFips_CODE = ' + ISNULL(@Lc_PscrCur_CountyFips_CODE, '') + ', TypeLocReq_CODE = ' + ISNULL(@Lc_PscrCur_TypeLocReq_CODE, '') + ', BundleResults_INDC = ' + ISNULL(@Lc_PscrCur_BundleResults_INDC, '') + ', TypeParticipant_CODE = ' + ISNULL(@Lc_PscrCur_TypeParticipant_CODE, '') + ', FamilyViolence_CODE = ' + ISNULL(@Lc_PscrCur_FamilyViolence_CODE, '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_PscrCur_MemberMci_IDNO AS VARCHAR), '') + ', Sex_CODE = ' + ISNULL(@Lc_PscrCur_MemberSex_CODE, '') + ', MemberSsn_NUMB = ' + ISNULL(CAST(@Ln_PscrCur_MemberSsn_NUMB AS VARCHAR), '') + ', PreviousMemberSsn_NUMB = ' + ISNULL(CAST(@Ln_PscrCur_PreviousMemberSsn_NUMB AS VARCHAR), '') + ', First_NAME = ' + ISNULL(@Lc_PscrCur_First_NAME, '') + ', Middle_NAME = ' + ISNULL(@Lc_PscrCur_Middle_NAME, '') + ', Last_NAME = ' + ISNULL(@Lc_PscrCur_Last_NAME, '') + ', CityBirth_NAME = ' + ISNULL(@Lc_PscrCur_BirthCity_NAME, '') + ', FirstFather_NAME = ' + ISNULL(@Lc_PscrCur_FirstFather_NAME, '') + ', MiddleFather_NAME = ' + ISNULL(@Lc_PscrCur_MiddleFather_NAME, '') + ', LastFather_NAME = ' + ISNULL(@Lc_PscrCur_LastFather_NAME, '') + ', FirstMother_NAME = ' + ISNULL(@Lc_PscrCur_FirstMother_NAME, '') + ', MiddleMother_NAME = ' + ISNULL(@Lc_PscrCur_MiddleMother_NAME, '') + ', LastMother_NAME = ' + ISNULL(@Lc_PscrCur_LastMother_NAME, '') + ', IrsUsedMemberSsn_NUMB = ' + ISNULL(CAST(@Ln_PscrCur_IrsUsedMemberSsn_NUMB AS VARCHAR), '') + ', MemberAdditional1Ssn_NUMB = ' + ISNULL(CAST(@Ln_PscrCur_MemberAdditional1Ssn_NUMB AS VARCHAR), '') + ', MemberAdditional2Ssn_NUMB = ' + ISNULL(CAST(@Ln_PscrCur_MemberAdditional2Ssn_NUMB AS VARCHAR), '') + ', FirstAdditional1_NAME = ' + ISNULL(@Lc_PscrCur_FirstAdditional1_NAME, '') + ', MiddleAdditional1_NAME = ' + ISNULL(@Lc_PscrCur_MiddleAdditional1_NAME, '') + ', LastAdditional1_NAME = ' + ISNULL(@Lc_PscrCur_LastAdditional1_NAME, '') + ', FirstAdditional2_NAME = ' + ISNULL(@Lc_PscrCur_FirstAdditional2_NAME, '') + ', MiddleAdditional2_NAME = ' + ISNULL(@Lc_PscrCur_MiddleAdditional2_NAME, '') + ', LastAdditional2_NAME = ' + ISNULL(@Lc_PscrCur_LastAdditional2_NAME, '') + ', FirstAdditional3_NAME = ' + ISNULL(@Lc_PscrCur_FirstAdditional3_NAME, '') + ', MiddleAdditional3_NAME = ' + ISNULL(@Lc_PscrCur_MiddleAdditional3_NAME, '') + ', LastAdditional3_NAME = ' + ISNULL(@Lc_PscrCur_LastAdditional3_NAME, '') + ', FirstAdditional4_NAME = ' + ISNULL(@Lc_PscrCur_FirstAdditional4_NAME, '') + ', MiddleAdditional4_NAME = ' + ISNULL(@Lc_PscrCur_MiddleAdditional4_NAME, '') + ', LastAdditional4_NAME = ' + ISNULL(@Lc_PscrCur_LastAdditional4_NAME, '') + ', NewMemberMci_IDNO = ' + ISNULL(CAST(@Ln_PscrCur_NewMemberMci_IDNO AS VARCHAR), '') + ', Irs1099_INDC = ' + ISNULL(@Lc_PscrCur_Irs1099_INDC, '') + ', LocateSource1_CODE = ' + ISNULL(@Lc_PscrCur_SourceLoc1_CODE, '') + ', LocateSource2_CODE = ' + ISNULL(@Lc_PscrCur_SourceLoc2_CODE, '') + ', LocateSource3_CODE = ' + ISNULL(@Lc_PscrCur_SourceLoc3_CODE, '') + ', LocateSource4_CODE = ' + ISNULL(@Lc_PscrCur_SourceLoc4_CODE, '') + ', LocateSource5_CODE = ' + ISNULL(@Lc_PscrCur_SourceLoc5_CODE, '') + ', LocateSource6_CODE = ' + ISNULL(@Lc_PscrCur_SourceLoc6_CODE, '') + ', LocateSource7_CODE = ' + ISNULL(@Lc_PscrCur_SourceLoc7_CODE, '') + ', LocateSource8_CODE = ' + ISNULL(@Lc_PscrCur_SourceLoc8_CODE, '');

     INSERT EFMEM_Y1
            (Rec_ID,
             TypeAction_CODE,
             Case_IDNO,
             ReservedFcr_CODE,
             UserField_NAME,
             CountyFips_CODE,
             TypeLocReq_CODE,
             BundleResults_INDC,
             TypeParticipant_CODE,
             FamilyViolence_CODE,
             MemberMci_IDNO,
             Sex_CODE,
             Birth_DATE,
             MemberSsn_NUMB,
             PreviousMemberSsn_NUMB,
             First_NAME,
             Middle_NAME,
             Last_NAME,
             CityBirth_NAME,
             StCountryBirth_CODE,
             FirstFather_NAME,
             MiddleFather_NAME,
             LastFather_NAME,
             FirstMother_NAME,
             MiddleMother_NAME,
             LastMother_NAME,
             IrsUsedMemberSsn_NUMB,
             MemberAdditional1Ssn_NUMB,
             MemberAdditional2Ssn_NUMB,
             FirstAdditional1_NAME,
             MiddleAdditional1_NAME,
             LastAdditional1_NAME,
             FirstAdditional2_NAME,
             MiddleAdditional2_NAME,
             LastAdditional2_NAME,
             FirstAdditional3_NAME,
             MiddleAdditional3_NAME,
             LastAdditional3_NAME,
             FirstAdditional4_NAME,
             MiddleAdditional4_NAME,
             LastAdditional4_NAME,
             NewMemberMci_IDNO,
             Irs1099_INDC,
             LocateSource1_CODE,
             LocateSource2_CODE,
             LocateSource3_CODE,
             LocateSource4_CODE,
             LocateSource5_CODE,
             LocateSource6_CODE,
             LocateSource7_CODE,
             LocateSource8_CODE)
     VALUES ( @Lc_PscrCur_Rec_ID,--Rec_ID
              @Lc_PscrCur_TypeAction_CODE,--TypeAction_CODE
              @Ln_PscrCur_Case_IDNO,--Case_IDNO
              @Lc_PscrCur_ReservedFcr_CODE,--ReservedFcr_CODE
              @Lc_PscrCur_UserField_NAME,--UserField_NAME
              @Lc_PscrCur_CountyFips_CODE,--CountyFips_CODE
              @Lc_PscrCur_TypeLocReq_CODE,--TypeLocReq_CODE
              @Lc_PscrCur_BundleResults_INDC,--BundleResults_INDC
              @Lc_PscrCur_TypeParticipant_CODE,--TypeParticipant_CODE
              @Lc_PscrCur_FamilyViolence_CODE,--FamilyViolence_CODE
              @Ln_PscrCur_MemberMci_IDNO,--MemberMci_IDNO
              @Lc_PscrCur_MemberSex_CODE,--Sex_CODE
              ISNULL(CONVERT(VARCHAR(8), @Ld_PscrCur_Birth_DATE, 112), @Lc_Space_TEXT),--Birth_DATE
              @Ln_PscrCur_MemberSsn_NUMB,--MemberSsn_NUMB
              @Ln_PscrCur_PreviousMemberSsn_NUMB,--PreviousMemberSsn_NUMB
              @Lc_PscrCur_First_NAME,--First_NAME
              @Lc_PscrCur_Middle_NAME,--Middle_NAME
              @Lc_PscrCur_Last_NAME,--Last_NAME
              @Lc_PscrCur_BirthCity_NAME,--CityBirth_NAME
              ISNULL(@Lc_PscrCur_BirthState_CODE, '') + ISNULL(@Lc_PscrCur_BirthCountry_CODE, ''),--StCountryBirth_CODE
              @Lc_PscrCur_FirstFather_NAME,--FirstFather_NAME
              @Lc_PscrCur_MiddleFather_NAME,--MiddleFather_NAME
              @Lc_PscrCur_LastFather_NAME,--LastFather_NAME
              @Lc_PscrCur_FirstMother_NAME,--FirstMother_NAME
              @Lc_PscrCur_MiddleMother_NAME,--MiddleMother_NAME
              @Lc_PscrCur_LastMother_NAME,--LastMother_NAME
              @Ln_PscrCur_IrsUsedMemberSsn_NUMB,--IrsUsedMemberSsn_NUMB
              @Ln_PscrCur_MemberAdditional1Ssn_NUMB,--MemberAdditional1Ssn_NUMB
              @Ln_PscrCur_MemberAdditional2Ssn_NUMB,--MemberAdditional2Ssn_NUMB
              @Lc_PscrCur_FirstAdditional1_NAME,--FirstAdditional1_NAME
              @Lc_PscrCur_MiddleAdditional1_NAME,--MiddleAdditional1_NAME
              @Lc_PscrCur_LastAdditional1_NAME,--LastAdditional1_NAME
              @Lc_PscrCur_FirstAdditional2_NAME,--FirstAdditional2_NAME
              @Lc_PscrCur_MiddleAdditional2_NAME,--MiddleAdditional2_NAME
              @Lc_PscrCur_LastAdditional2_NAME,--LastAdditional2_NAME
              @Lc_PscrCur_FirstAdditional3_NAME,--FirstAdditional3_NAME
              @Lc_PscrCur_MiddleAdditional3_NAME,--MiddleAdditional3_NAME
              @Lc_PscrCur_LastAdditional3_NAME,--LastAdditional3_NAME
              @Lc_PscrCur_FirstAdditional4_NAME,--FirstAdditional4_NAME
              @Lc_PscrCur_MiddleAdditional4_NAME,--MiddleAdditional4_NAME
              @Lc_PscrCur_LastAdditional4_NAME,--LastAdditional4_NAME
              @Ln_PscrCur_NewMemberMci_IDNO,--NewMemberMci_IDNO
              @Lc_PscrCur_Irs1099_INDC,--Irs1099_INDC
              @Lc_PscrCur_SourceLoc1_CODE,--LocateSource1_CODE
              @Lc_PscrCur_SourceLoc2_CODE,--LocateSource2_CODE
              @Lc_PscrCur_SourceLoc3_CODE,--LocateSource3_CODE
              @Lc_PscrCur_SourceLoc4_CODE,--LocateSource4_CODE
              @Lc_PscrCur_SourceLoc5_CODE,--LocateSource5_CODE
              @Lc_PscrCur_SourceLoc6_CODE,--LocateSource6_CODE
              @Lc_PscrCur_SourceLoc7_CODE,--LocateSource7_CODE
              @Lc_PscrCur_SourceLoc8_CODE --LocateSource8_CODE
     );

     SET @Li_RowCount_QNTY = @@ROWCOUNT;

     IF @Li_RowCount_QNTY = 0
      BEGIN
       SET @Ls_ErrorMessage_TEXT = 'INSERT INTO EFMEM_Y1 - 1 FAILED';

       RAISERROR(50001,16,1);
      END

     SET @Ln_Exists_NUMB = 0;
     --Check for the existance of member in Audit table
     SET @Ls_Sql_TEXT = 'CHECK FOR THE MEMBER IN FADT_Y1 - 2';
     SET @Ls_SqlData_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_PscrCur_Case_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_PscrCur_MemberMci_IDNO AS VARCHAR), '') + ', TypeTrans_CODE = ' + ISNULL(@Lc_RecPerson_ID, '');

     SELECT @Ln_Exists_NUMB = COUNT(1)
       FROM FADT_Y1 A
      WHERE A.Case_IDNO = @Ln_PscrCur_Case_IDNO
        AND A.MemberMci_IDNO = @Ln_PscrCur_MemberMci_IDNO
        AND A.TypeTrans_CODE = @Lc_RecPerson_ID;

     IF @Ln_Exists_NUMB != 0
      BEGIN
       --update member audit details
       SET @Ls_Sql_TEXT = 'UPDATE FADT_Y1 - 2';
       SET @Ls_SqlData_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_PscrCur_Case_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_PscrCur_MemberMci_IDNO AS VARCHAR), '') + ', TypeTrans_CODE = ' + ISNULL(@Lc_RecPerson_ID, '');

       UPDATE FADT_Y1
          SET TypeTrans_CODE = @Lc_PscrCur_Rec_ID,
              Action_CODE = @Lc_PscrCur_TypeAction_CODE,
              Transmitted_DATE = @Ld_Run_DATE,
              MemberSsn_NUMB = @Ln_PscrCur_MemberSsn_NUMB,
              Birth_DATE = @Ld_PscrCur_Birth_DATE,
              Last_NAME = @Lc_PscrCur_Last_NAME,
              First_NAME = @Lc_PscrCur_First_NAME,
              CaseRelationship_CODE = @Lc_PscrCur_CaseRelationship_CODE,
              CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE,
              Batch_NUMB = @An_Batch_NUMB
        WHERE Case_IDNO = @Ln_PscrCur_Case_IDNO
          AND MemberMci_IDNO = @Ln_PscrCur_MemberMci_IDNO
          AND TypeTrans_CODE = @Lc_RecPerson_ID;

       SET @Li_RowCount_QNTY = @@ROWCOUNT;

       IF @Li_RowCount_QNTY = 0
        BEGIN
         SET @Ls_ErrorMessage_TEXT = 'UPDATE FADT_Y1 - 2 FAILED';

         RAISERROR(50001,16,1);
        END
      END
     ELSE
      BEGIN
       --If member is not in fadt insert member record
       SET @Ls_Sql_TEXT = 'INSERT INTO FADT_Y1 - 2';
       SET @Ls_SqlData_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_PscrCur_Case_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_PscrCur_MemberMci_IDNO AS VARCHAR), '') + ', Action_CODE = ' + ISNULL(@Lc_PscrCur_TypeAction_CODE, '') + ', TypeTrans_CODE = ' + ISNULL(@Lc_PscrCur_Rec_ID, '') + ', Transmitted_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', TypeCase_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', StatusCase_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', County_IDNO = ' + ISNULL(@Lc_Zero_TEXT, '') + ', Order_INDC = ' + ISNULL(@Lc_Space_TEXT, '') + ', MemberSsn_NUMB = ' + ISNULL(CAST(@Ln_PscrCur_MemberSsn_NUMB AS VARCHAR), '') + ', Birth_DATE = ' + ISNULL(CAST(@Ld_PscrCur_Birth_DATE AS VARCHAR), '') + ', Last_NAME = ' + ISNULL(@Lc_PscrCur_Last_NAME, '') + ', First_NAME = ' + ISNULL(@Lc_PscrCur_First_NAME, '') + ', CaseRelationship_CODE = ' + ISNULL(@Lc_PscrCur_CaseRelationship_CODE, '') + ', CaseMemberStatus_CODE = ' + ISNULL(@Lc_StatusCaseMemberActive_CODE, '') + ', Response_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '') + ', ResponseFcr_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', Batch_NUMB = ' + ISNULL(CAST(@An_Batch_NUMB AS VARCHAR), '');

       INSERT FADT_Y1
              (Case_IDNO,
               MemberMci_IDNO,
               Action_CODE,
               TypeTrans_CODE,
               Transmitted_DATE,
               TypeCase_CODE,
               StatusCase_CODE,
               County_IDNO,
               Order_INDC,
               MemberSsn_NUMB,
               Birth_DATE,
               Last_NAME,
               First_NAME,
               CaseRelationship_CODE,
               CaseMemberStatus_CODE,
               Response_DATE,
               ResponseFcr_CODE,
               Batch_NUMB)
       VALUES ( @Ln_PscrCur_Case_IDNO,--Case_IDNO
                @Ln_PscrCur_MemberMci_IDNO,--MemberMci_IDNO
                @Lc_PscrCur_TypeAction_CODE,--Action_CODE
                @Lc_PscrCur_Rec_ID,--TypeTrans_CODE
                @Ld_Run_DATE,--Transmitted_DATE
                @Lc_Space_TEXT,--TypeCase_CODE
                @Lc_Space_TEXT,--StatusCase_CODE
                @Lc_Zero_TEXT,--County_IDNO
                @Lc_Space_TEXT,--Order_INDC
                @Ln_PscrCur_MemberSsn_NUMB,--MemberSsn_NUMB
                @Ld_PscrCur_Birth_DATE,--Birth_DATE
                @Lc_PscrCur_Last_NAME,--Last_NAME
                @Lc_PscrCur_First_NAME,--First_NAME
                @Lc_PscrCur_CaseRelationship_CODE,--CaseRelationship_CODE
                @Lc_StatusCaseMemberActive_CODE,--CaseMemberStatus_CODE
                @Ld_Low_DATE,--Response_DATE
                @Lc_Space_TEXT,--ResponseFcr_CODE
                @An_Batch_NUMB --Batch_NUMB
       );

       SET @Li_RowCount_QNTY = @@ROWCOUNT;

       IF @Li_RowCount_QNTY = 0
        BEGIN
         SET @Ls_ErrorMessage_TEXT = 'INSERT INTO FADT_Y1 - 2 FAILED';

         RAISERROR(50001,16,1);
        END
      END

     SET @Ln_Exists_NUMB = 0;
     SET @Ls_Sql_TEXT = 'CHECK FOR EXISTANCE IN FPRJ_Y1 - 2';
     SET @Ls_SqlData_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_PscrCur_Case_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_PscrCur_MemberMci_IDNO AS VARCHAR), '');

     SELECT @Ln_Exists_NUMB = COUNT(1)
       FROM FPRJ_Y1 A
      WHERE A.Case_IDNO = @Ln_PscrCur_Case_IDNO
        AND A.MemberMci_IDNO = @Ln_PscrCur_MemberMci_IDNO;

     IF @Ln_Exists_NUMB != 0
      BEGIN
       --Delete member from fprj if exists 
       SET @Ls_Sql_TEXT = 'DELETE FROM FPRJ_Y1 - 2';
       SET @Ls_SqlData_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_PscrCur_Case_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_PscrCur_MemberMci_IDNO AS VARCHAR), '');

       DELETE FPRJ_Y1
        WHERE Case_IDNO = @Ln_PscrCur_Case_IDNO
          AND MemberMci_IDNO = @Ln_PscrCur_MemberMci_IDNO;

       SET @Li_RowCount_QNTY = @@ROWCOUNT;

       IF @Li_RowCount_QNTY = 0
        BEGIN
         SET @Ls_ErrorMessage_TEXT = 'DELETE FROM FPRJ_Y1 - 2 FAILED';

         RAISERROR(50001,16,1);
        END
      END

     --write a case Journal entry for transactions submitted to FCR
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_ACTIVITY - 2';
     SET @Ls_SqlData_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_PscrCur_Case_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_PscrCur_MemberMci_IDNO AS VARCHAR), '') + ', ActivityMajor_CODE = ' + ISNULL(@Lc_ActivityMajorCase_CODE, '') + ', ActivityMinor_CODE = ' + ISNULL(@Lc_ActivityMinorStfcr_CODE, '') + ', Subsystem_CODE = ' + ISNULL(@Lc_SubsystemLo_CODE, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', WorkerUpdate_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', WorkerDelegate_ID = ' + ISNULL(@Lc_WorkerDelegate_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', TypeReference_CODE = ' + ISNULL(@Lc_TypeReference_IDNO, '') + ', Reference_ID = ' + ISNULL(@Lc_Reference_ID, '') + ', Notice_ID = ' + ISNULL(@Lc_Notice_ID, '') + ', TopicIn_IDNO = ' + ISNULL(CAST(@Ln_TopicIn_IDNO AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Xml_TEXT = ' + ISNULL(@Ls_XmlIn_TEXT, '') + ', MajorIntSeq_NUMB = ' + ISNULL(CAST(@Ln_MajorIntSeq_NUMB AS VARCHAR), '') + ', MinorIntSeq_NUMB = ' + ISNULL(CAST(@Ln_MinorIntSeq_NUMB AS VARCHAR), '') + ', Schedule_NUMB = ' + ISNULL(CAST(@Ln_Schedule_NUMB AS VARCHAR), '');

     EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
      @An_Case_IDNO                = @Ln_PscrCur_Case_IDNO,
      @An_MemberMci_IDNO           = @Ln_PscrCur_MemberMci_IDNO,
      @Ac_ActivityMajor_CODE       = @Lc_ActivityMajorCase_CODE,
      @Ac_ActivityMinor_CODE       = @Lc_ActivityMinorStfcr_CODE,
      @Ac_Subsystem_CODE           = @Lc_SubsystemLo_CODE,
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

     --Notes added for corresponding case journal entry
     SET @Ls_Sql_TEXT = 'BATCH_COMMON_NOTE$SP_CREATE_NOTE - 2';
     SET @Ls_SqlData_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_InputCase_IDNO AS VARCHAR), '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', DescriptionNote_TEXT = ' + ISNULL(@Ls_DescriptionNote_TEXT, '') + ', Category_CODE = ' + ISNULL(@Lc_SubsystemLo_CODE, '') + ', Subject_CODE = ' + ISNULL(@Lc_ActivityMinorStfcr_CODE, '') + ', WorkerSignedOn_IDNO = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', Process_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Topic_IDNO = ' + ISNULL(CAST(@Ln_Topic_IDNO AS VARCHAR), '');

     EXECUTE BATCH_COMMON_NOTE$SP_CREATE_NOTE
      @Ac_Case_IDNO                = @Ln_InputCase_IDNO,
      @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
      @As_DescriptionNote_TEXT     = @Ls_DescriptionNote_TEXT,
      @Ac_Category_CODE            = @Lc_SubsystemLo_CODE,
      @Ac_Subject_CODE             = @Lc_ActivityMinorStfcr_CODE,
      @As_WorkerSignedOn_IDNO      = @Lc_BatchRunUser_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT,
      @Ac_Process_ID               = @Lc_Job_ID,
      @An_Topic_IDNO               = @Ln_Topic_IDNO;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

       RAISERROR (50001,16,1);
      END;

     SET @Ls_Sql_TEXT = 'FETCH NEXT FROM Pscr_CUR - 2';

     FETCH NEXT FROM Pscr_CUR INTO @Lc_PscrCur_CaseRelationship_CODE, @Lc_PscrCur_Rec_ID, @Lc_PscrCur_TypeAction_CODE, @Ln_PscrCur_Case_IDNO, @Lc_PscrCur_ReservedFcr_CODE, @Lc_PscrCur_UserField_NAME, @Lc_PscrCur_CountyFips_CODE, @Lc_PscrCur_TypeLocReq_CODE, @Lc_PscrCur_BundleResults_INDC, @Lc_PscrCur_TypeParticipant_CODE, @Lc_PscrCur_FamilyViolence_CODE, @Ln_PscrCur_MemberMci_IDNO, @Lc_PscrCur_MemberSex_CODE, @Ld_PscrCur_Birth_DATE, @Ln_PscrCur_MemberSsn_NUMB, @Ln_PscrCur_PreviousMemberSsn_NUMB, @Lc_PscrCur_First_NAME, @Lc_PscrCur_Middle_NAME, @Lc_PscrCur_Last_NAME, @Lc_PscrCur_BirthCity_NAME, @Lc_PscrCur_BirthState_CODE, @Lc_PscrCur_BirthCountry_CODE, @Lc_PscrCur_FirstFather_NAME, @Lc_PscrCur_MiddleFather_NAME, @Lc_PscrCur_LastFather_NAME, @Lc_PscrCur_FirstMother_NAME, @Lc_PscrCur_MiddleMother_NAME, @Lc_PscrCur_LastMother_NAME, @Ln_PscrCur_IrsUsedMemberSsn_NUMB, @Ln_PscrCur_MemberAdditional1Ssn_NUMB, @Ln_PscrCur_MemberAdditional2Ssn_NUMB, @Lc_PscrCur_FirstAdditional1_NAME, @Lc_PscrCur_MiddleAdditional1_NAME, @Lc_PscrCur_LastAdditional1_NAME, @Lc_PscrCur_FirstAdditional2_NAME, @Lc_PscrCur_MiddleAdditional2_NAME, @Lc_PscrCur_LastAdditional2_NAME, @Lc_PscrCur_FirstAdditional3_NAME, @Lc_PscrCur_MiddleAdditional3_NAME, @Lc_PscrCur_LastAdditional3_NAME, @Lc_PscrCur_FirstAdditional4_NAME, @Lc_PscrCur_MiddleAdditional4_NAME, @Lc_PscrCur_LastAdditional4_NAME, @Ln_PscrCur_NewMemberMci_IDNO, @Lc_PscrCur_Irs1099_INDC, @Lc_PscrCur_SourceLoc1_CODE, @Lc_PscrCur_SourceLoc2_CODE, @Lc_PscrCur_SourceLoc3_CODE, @Lc_PscrCur_SourceLoc4_CODE, @Lc_PscrCur_SourceLoc5_CODE, @Lc_PscrCur_SourceLoc6_CODE, @Lc_PscrCur_SourceLoc7_CODE, @Lc_PscrCur_SourceLoc8_CODE, @Lc_PscrCur_ChildNotPassed_INDC;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END

   IF CURSOR_STATUS('LOCAL', 'Pscr_CUR') IN (0, 1)
    BEGIN
     SET @Ls_Sql_TEXT = 'CLOSE Pscr_CUR';

     CLOSE Pscr_CUR;

     SET @Ls_Sql_TEXT = 'DEALLOCATE Pscr_CUR';

     DEALLOCATE Pscr_CUR;
    END

   SET @Ac_Msg_CODE = NULL;
   SET @As_DescriptionError_TEXT = NULL;
  END TRY

  BEGIN CATCH
   IF CURSOR_STATUS('LOCAL', 'Pscr_CUR') IN (0, 1)
    BEGIN
     CLOSE Pscr_CUR;

     DEALLOCATE Pscr_CUR;
    END

   IF CURSOR_STATUS('LOCAL', 'ScrCase_CUR') IN (0, 1)
    BEGIN
     CLOSE ScrCase_CUR;

     DEALLOCATE ScrCase_CUR;
    END

   IF @Lc_SkipRecord_INDC = 'Y'
    BEGIN
     SET @Ac_Msg_CODE = NULL;
     SET @As_DescriptionError_TEXT = NULL;

     RETURN;
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

   SELECT '@Ls_DescriptionError_TEXT  = ' + @Ls_DescriptionError_TEXT;

   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
  END CATCH
 END


GO
