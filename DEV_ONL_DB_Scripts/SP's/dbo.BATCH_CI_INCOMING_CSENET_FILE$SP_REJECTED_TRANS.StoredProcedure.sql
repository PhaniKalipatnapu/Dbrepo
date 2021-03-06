/****** Object:  StoredProcedure [dbo].[BATCH_CI_INCOMING_CSENET_FILE$SP_REJECTED_TRANS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_CI_INCOMING_CSENET_FILE$SP_REJECTED_TRANS
Programmer Name	:	IMP Team.
Description		:	This procedure is used to process Rejected Transaction
Frequency		:	DAILY
Developed On	:	04/04/2011
Called By		:	NONE
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_CI_INCOMING_CSENET_FILE$SP_REJECTED_TRANS] (
 @Ac_RejectReason_CODE     CHAR(2),
 @Ac_ExchangeMode_INDC     CHAR(1),
 @Ad_Run_DATE              DATE,
 @Ad_Start_DATE            DATE,
 @Ac_JobProcess_IDNO       CHAR(7),
 @Ac_BatchRunUser_TEXT     CHAR(30),
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusSuccess_CODE          CHAR(1) = 'S',
          @Lc_StringZero_TEXT             CHAR(1) = '0',
          @Lc_ActionRequest_CODE          CHAR(1) = 'R',
          @Lc_ActionUpdate_CODE           CHAR(1) = 'U',
          @Lc_Space_TEXT                  CHAR(1) = ' ',
          @Lc_RelationshipCaseCp_TEXT     CHAR(1) = 'C',
          @Lc_StatusFailed_CODE           CHAR(1) = 'F',
          @Lc_CaseStatusOpen_CODE         CHAR(1) = 'O',
          @Lc_RelationshipCaseNcp_TEXT    CHAR(1) = 'A',
          @Lc_StatusCaseMemberActive_CODE CHAR(1) = 'A',
          @Lc_ActionProvide_CODE          CHAR(1) = 'P',
          @Lc_No_INDC                     CHAR(1) = 'N',
          @Lc_ErrorTypeError_CODE         CHAR(1) = 'E',
          @Lc_NcpMemberSex_TEXT           CHAR(1) = ' ',
          @Lc_SsnMatch_CODE               CHAR(1) = ' ',
          @Lc_NameMatch_INDC              CHAR(1) = ' ',
          @Lc_ExactMatch_INDC             CHAR(1) = ' ',
          @Lc_MultMatch_INDC              CHAR(1) = ' ',
          @Lc_ReqStatusPending_CODE       CHAR(2) = 'PN',
          @Lc_FunctionCasesummary_CODE    CHAR(3) = 'CSI',
          @Lc_FunctionQuickLocate_CODE    CHAR(3) = 'LO1',
          @Lc_FunctionManagestcases_CODE  CHAR(3) = 'MSC',
          @Lc_FarUnprocessed_CODE         CHAR(5) = 'REJCT',
          @Lc_ReasonGscas_CODE            CHAR(5) = 'GSCAS',
          @Lc_ErrorAddNotsuccess_TEXT     CHAR(5) = 'E0113',
          @Lc_Msg_CODE                    CHAR(5) = ' ',
          @Lc_Reason_CODE                 CHAR(5) = ' ',
          @Lc_NcpMemberSsn_TEXT           CHAR(9) = '0',
          @Lc_NcpFirst_NAME               CHAR(16) = ' ',
          @Lc_NcpMiddle_NAME              CHAR(16) = ' ',
          @Lc_CpFirst_NAME                CHAR(16) = ' ',
          @Lc_NcpLast_NAME                CHAR(21) = ' ',
          @Lc_CpLast_NAME                 CHAR(21) = ' ',
          @Lc_WorkerUpdate_ID             CHAR(30) = 'BATCH',
          @Ls_Procedure_NAME              VARCHAR(100) = 'BATCH_CI_INCOMING_CSENET_FILE$SP_REJECTED_TRANS',
          @Ls_DescriptionError_TEXT       VARCHAR(1000) = ' ',
          @Ls_DescriptionComments_TEXT    VARCHAR(1000) = ' ',
          @Ls_Sqldata_TEXT                VARCHAR(4000) = ' ',
          @Ls_Sql_TEXT                    VARCHAR(4000) = ' ',
          @Ld_Low_DATE                    DATE = '01/01/0001',
          @Ld_High_DATE                   DATE = '12/31/9999';
  DECLARE @Ln_FetchStatus_QNTY         NUMERIC,
          @Ln_RowCount_QNTY            NUMERIC,
          @Ln_NcpMemberSsn_NUMB        NUMERIC(9),
          @Ln_MemberMci_IDNO           NUMERIC(10),
          @Ln_TransactionEventSeq_NUMB NUMERIC(19),
          @Li_Error_NUMB               INT,
          @Li_ErrorLine_NUMB           INT,
          @Li_Zero_NUMB                SMALLINT = 0,
          @Lc_Empty_TEXT               CHAR(1) = '',
          @Ld_NcpBirth_DATE            DATE;
  DECLARE @Ln_RjctCur_TransHeader_IDNO             NUMERIC(12),
          @Lc_RjctCur_IVDOutOfStateFips_CODE       CHAR(2),
          @Lc_RjctCur_Case_IDNO                    CHAR(6),
          @Ld_RjctCur_Transaction_DATE             DATE,
          @Lc_RjctCur_Function_CODE                CHAR(3),
          @Lc_RjctCur_Action_CODE                  CHAR(1),
          @Lc_RjctCur_Reason_CODE                  CHAR(5),
          @Lc_RjctCur_IVDOutOfStateCountyFips_CODE CHAR(3),
          @Lc_RjctCur_IVDOutOfStateOfficeFips_CODE CHAR(2),
          @Lc_RjctCur_IVDOutOfStateCase_ID         CHAR(15),
          @Lc_RjctCur_RejectReason_CODE            CHAR(5),
          @Li_RjctCur_NcpBlock_INDC                SMALLINT,
          @Li_RjctCur_Participant_QNTY             INT;

  BEGIN TRY
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$BATCH_COMMON$SP_GENERATE_SEQ_TXN_EVENT';
   SET @Ls_Sqldata_TEXT = 'Worker_ID = ' + ISNULL(@Ac_BatchRunUser_TEXT, '') + ', Process_ID = ' + ISNULL(@Ac_JobProcess_IDNO, '') + ', EffectiveEvent_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '');

   EXECUTE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
    @Ac_Worker_ID                = @Ac_BatchRunUser_TEXT,
    @Ac_Process_ID               = @Ac_JobProcess_IDNO,
    @Ad_EffectiveEvent_DATE      = @Ad_Run_DATE,
    @Ac_Note_INDC                = 'N',
    @An_EventFunctionalSeq_NUMB  = 0,
    @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
    @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE != @Lc_StatusSuccess_CODE
    BEGIN
     RAISERROR(50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'INSERT INTO CSPR_Y1';

   IF (NOT EXISTS (SELECT TOP 1 a.Case_IDNO
                     FROM LTHBL_Y1 a
                    WHERE LTRIM(a.RejectReason_CODE) <> @Lc_Empty_TEXT))
    BEGIN
     SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;

     RETURN;
    END;

   SET @Ls_Sql_TEXT = 'CURSOR FOR INSERT INTO CSPR_Y1';

   DECLARE Rjct_CUR INSENSITIVE CURSOR FOR
    SELECT a.TransHeader_IDNO,
           a.IVDOutOfStateFips_CODE,
           a.Case_IDNO,
           a.Transaction_DATE,
           a.Function_CODE,
           a.Action_CODE,
           a.Reason_CODE,
           a.IVDOutOfStateCountyFips_CODE,
           a.IVDOutOfStateOfficeFips_CODE,
           a.IVDOutOfStateCase_ID,
           a.RejectReason_CODE,
           CAST((CASE LTRIM(a.Ncp_QNTY)
                  WHEN @Lc_Empty_TEXT
                   THEN @Lc_StringZero_TEXT
                  ELSE a.Ncp_QNTY
                 END) AS NUMERIC) AS NcpBlock_INDC,
           CAST((CASE LTRIM(a.Participant_QNTY)
                  WHEN @Lc_Empty_TEXT
                   THEN @Lc_StringZero_TEXT
                  ELSE a.Participant_QNTY
                 END) AS NUMERIC) AS Participant_QNTY
      FROM LTHBL_Y1 a
     WHERE LTRIM(a.RejectReason_CODE) <> @Lc_Empty_TEXT
       AND NOT (a.Function_CODE IN (@Lc_FunctionCasesummary_CODE, @Lc_FunctionQuickLocate_CODE)
                AND a.Action_CODE IN (@Lc_ActionRequest_CODE, @Lc_ActionUpdate_CODE));

   OPEN Rjct_CUR;

   FETCH NEXT FROM Rjct_CUR INTO @Ln_RjctCur_TransHeader_IDNO, @Lc_RjctCur_IVDOutOfStateFips_CODE, @Lc_RjctCur_Case_IDNO, @Ld_RjctCur_Transaction_DATE, @Lc_RjctCur_Function_CODE, @Lc_RjctCur_Action_CODE, @Lc_RjctCur_Reason_CODE, @Lc_RjctCur_IVDOutOfStateCountyFips_CODE, @Lc_RjctCur_IVDOutOfStateOfficeFips_CODE, @Lc_RjctCur_IVDOutOfStateCase_ID, @Lc_RjctCur_RejectReason_CODE, @Li_RjctCur_NcpBlock_INDC, @Li_RjctCur_Participant_QNTY;

   SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;

   -- Process the rejected transactions (LO1, CSI transactions)
   WHILE @Ln_FetchStatus_QNTY = 0
    BEGIN
     SET @Ln_MemberMci_IDNO = 0;
     SET @Ls_DescriptionComments_TEXT = CAST(@Ln_RjctCur_TransHeader_IDNO AS VARCHAR) + @Lc_RjctCur_Action_CODE + @Lc_RjctCur_Function_CODE + CAST(@Ld_RjctCur_Transaction_DATE AS VARCHAR) + @Lc_RjctCur_Reason_CODE;
     SET @Lc_Reason_CODE = @Lc_FarUnprocessed_CODE;

     IF @Li_RjctCur_NcpBlock_INDC > 0
        AND @Li_RjctCur_Participant_QNTY > 0
        AND @Lc_RjctCur_RejectReason_CODE = @Ac_RejectReason_CODE
      BEGIN
       SET @Ls_Sql_TEXT = 'SELECT NCP INFORMATION FROM NCP BLOCK';

       IF @Li_RjctCur_Participant_QNTY > 0
        BEGIN
         SET @Ls_Sql_TEXT = 'SELECT LPBLK_Y1 FOR MSC P REJCT TRANSACTION';
         SET @Ls_Sqldata_TEXT = 'TransHeader_IDNO = ' + ISNULL(CAST(@Ln_RjctCur_TransHeader_IDNO AS VARCHAR), '') + ', Transaction_DATE = ' + ISNULL(CAST(@Ld_RjctCur_Transaction_DATE AS VARCHAR), '') + ', IVDOutOfStateFips_CODE = ' + ISNULL(@Lc_RjctCur_IVDOutOfStateFips_CODE, '') + ', Relationship_CODE = ' + ISNULL(@Lc_RelationshipCaseCp_TEXT, '');

         SELECT @Lc_CpFirst_NAME = a.First_NAME,
                @Lc_CpLast_NAME = a.Last_NAME
           FROM LPBLK_Y1 a
          WHERE a.TransHeader_IDNO = @Ln_RjctCur_TransHeader_IDNO
            AND a.Transaction_DATE = @Ld_RjctCur_Transaction_DATE
            AND a.IVDOutOfStateFips_CODE = @Lc_RjctCur_IVDOutOfStateFips_CODE
            AND a.Relationship_CODE = @Lc_RelationshipCaseCp_TEXT;
        END;

       SET @Ls_Sql_TEXT = 'SELECT LOAD_NCP_BLOCK FOR MSC P REJCT TRANSACTION';
       SET @Ls_Sqldata_TEXT = 'TransHeader_IDNO = ' + ISNULL(CAST(@Ln_RjctCur_TransHeader_IDNO AS VARCHAR), '') + ', Transaction_DATE = ' + ISNULL(CAST(@Ld_RjctCur_Transaction_DATE AS VARCHAR), '') + ', IVDOutOfStateFips_CODE = ' + ISNULL(@Lc_RjctCur_IVDOutOfStateFips_CODE, '');

       SELECT @Lc_NcpFirst_NAME = a.First_NAME,
              @Lc_NcpLast_NAME = a.Last_NAME,
              @Lc_NcpMiddle_NAME = a.Middle_NAME,
              @Lc_NcpMemberSsn_TEXT = CASE
                                       WHEN LTRIM(a.MemberSsn_NUMB) = ''
                                        THEN '0'
                                       ELSE a.MemberSsn_NUMB
                                      END
         FROM LNBLK_Y1 a
        WHERE a.TransHeader_IDNO = @Ln_RjctCur_TransHeader_IDNO
          AND a.Transaction_DATE = @Ld_RjctCur_Transaction_DATE
          AND a.IVDOutOfStateFips_CODE = @Lc_RjctCur_IVDOutOfStateFips_CODE;

       SET @Ln_NcpMemberSsn_NUMB = CAST(@Lc_NcpMemberSsn_TEXT AS NUMERIC);
       SET @Ls_Sql_TEXT = ' BATCH_COMMON$SP_MEMBER_CLEARENCE IN REJECTED TRANSACTION';
       SET @Ls_Sqldata_TEXT = 'MemberSsn_NUMB = ' + ISNULL(CAST(@Ln_NcpMemberSsn_NUMB AS VARCHAR), '') + ', First_NAME = ' + ISNULL(@Lc_NcpFirst_NAME, '') + ', Last_NAME = ' + ISNULL(@Lc_NcpLast_NAME, '') + ', Middle_NAME = ' + ISNULL(@Lc_NcpMiddle_NAME, '') + ', MemberSex_CODE = ' + ISNULL(@Lc_NcpMemberSex_TEXT, '') + ', Birth_DATE = ' + ISNULL(CAST(@Ld_NcpBirth_DATE AS VARCHAR), '');

       EXECUTE BATCH_COMMON$SP_MEMBER_CLEARENCE
        @An_MemberMci_IDNO        = 0,
        @An_MemberSsn_NUMB        = @Ln_NcpMemberSsn_NUMB,
        @Ac_First_NAME            = @Lc_NcpFirst_NAME,
        @Ac_Last_NAME             = @Lc_NcpLast_NAME,
        @Ac_Middle_NAME           = @Lc_NcpMiddle_NAME,
        @Ac_MemberSex_CODE        = @Lc_NcpMemberSex_TEXT,
        @Ad_Birth_DATE            = @Ld_NcpBirth_DATE,
        @An_MemberMciOut_IDNO     = @Ln_MemberMci_IDNO OUTPUT,
        @Ac_MemberSsnMatch_INDC   = @Lc_SsnMatch_CODE OUTPUT,
        @Ac_NameMatch_INDC        = @Lc_NameMatch_INDC OUTPUT,
        @Ac_ExactMatch_INDC       = @Lc_ExactMatch_INDC OUTPUT,
        @Ac_MultMatch_INDC        = @Lc_MultMatch_INDC OUTPUT,
        @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

       IF @Lc_Msg_CODE != @Lc_StatusFailed_CODE
        BEGIN
         IF @Ln_MemberMci_IDNO != 0
            AND (@Lc_MultMatch_INDC = 'S')
          BEGIN
           SET @Ls_Sql_TEXT = 'SELECT CASE COUNT IN REJECTED TRANSACTION FOR MemberMci_IDNO: ' + CAST(@Ln_MemberMci_IDNO AS VARCHAR);

           IF (EXISTS (SELECT TOP 1 a.Case_IDNO
                         FROM CMEM_Y1 AS a,
                              CASE_Y1 AS b
                        WHERE a.MemberMci_IDNO = @Ln_MemberMci_IDNO
                          AND a.Case_IDNO = b.Case_IDNO
                          AND b.StatusCase_CODE = @Lc_CaseStatusOpen_CODE
                          AND a.CaseRelationship_CODE = @Lc_RelationshipCaseNcp_TEXT
                          AND a.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE))
            BEGIN
             IF LTRIM(@Lc_CpFirst_NAME) <> @Lc_Empty_TEXT
                AND LTRIM(@Lc_CpLast_NAME) <> @Lc_Empty_TEXT
              BEGIN
               SET @Ls_Sql_TEXT = 'SELECT CASE IN REJECTED TRANSACTION FOR MemberMci_IDNO: ' + CAST(@Ln_MemberMci_IDNO AS VARCHAR) + ' AND CP';
               SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR), '') + ', StatusCase_CODE = ' + ISNULL(@Lc_CaseStatusOpen_CODE, '') + ', CaseRelationship_CODE = ' + ISNULL(@Lc_RelationshipCaseNcp_TEXT, '') + ', CaseMemberStatus_CODE = ' + ISNULL(@Lc_StatusCaseMemberActive_CODE, '') + ', CaseRelationship_CODE = ' + ISNULL(@Lc_RelationshipCaseCp_TEXT, '') + ', First_NAME = ' + ISNULL(@Lc_CpFirst_NAME, '') + ', Last_NAME = ' + ISNULL(@Lc_CpLast_NAME, '') + ', CaseMemberStatus_CODE = ' + ISNULL(@Lc_StatusCaseMemberActive_CODE, '');

               SELECT @Ls_DescriptionComments_TEXT = a.Case_IDNO
                 FROM CMEM_Y1 a,
                      DEMO_Y1 b
                WHERE a.Case_IDNO IN (SELECT x.Case_IDNO
                                        FROM CMEM_Y1 x,
                                             CASE_Y1 c
                                       WHERE x.MemberMci_IDNO = @Ln_MemberMci_IDNO
                                         AND x.Case_IDNO = c.Case_IDNO
                                         AND c.StatusCase_CODE = @Lc_CaseStatusOpen_CODE
                                         AND x.CaseRelationship_CODE = @Lc_RelationshipCaseNcp_TEXT
                                         AND x.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE)
                  AND a.MemberMci_IDNO = b.MemberMci_IDNO
                  AND a.CaseRelationship_CODE = @Lc_RelationshipCaseCp_TEXT
                  AND b.First_NAME = @Lc_CpFirst_NAME
                  AND b.Last_NAME = @Lc_CpLast_NAME
                  AND a.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE;

               SET @Lc_Reason_CODE = @Lc_ReasonGscas_CODE;
              END;
            END;
          END;
        END;
      END;

     SET @Ls_Sql_TEXT = 'INSERT INTO CSPR_Y1';
     SET @Ls_Sqldata_TEXT = 'Generated_DATE = ' + ISNULL(CAST(@Ld_RjctCur_Transaction_DATE AS VARCHAR), '') + ', IVDOutOfStateFips_CODE = ' + ISNULL(@Lc_RjctCur_IVDOutOfStateFips_CODE, '') + ', IVDOutOfStateCountyFips_CODE = ' + ISNULL(@Lc_RjctCur_IVDOutOfStateCountyFips_CODE, '') + ', IVDOutOfStateOfficeFips_CODE = ' + ISNULL(@Lc_RjctCur_IVDOutOfStateOfficeFips_CODE, '') + ', IVDOutOfStateCase_ID = ' + ISNULL(@Lc_RjctCur_IVDOutOfStateCase_ID, '') + ', ExchangeMode_INDC = ' + ISNULL(@Ac_ExchangeMode_INDC, '') + ', StatusRequest_CODE = ' + ISNULL(@Lc_ReqStatusPending_CODE, '') + ', Form_ID = ' + ISNULL(CAST(@Li_Zero_NUMB AS VARCHAR), '') + ', FormWeb_URL = ' + ISNULL(@Lc_Space_TEXT, '') + ', TransHeader_IDNO = ' + ISNULL(CAST(@Ln_RjctCur_TransHeader_IDNO AS VARCHAR), '') + ', Function_CODE = ' + ISNULL(@Lc_FunctionManagestcases_CODE, '') + ', Action_CODE = ' + ISNULL(@Lc_ActionProvide_CODE, '') + ', Reason_CODE = ' + ISNULL(@Lc_Reason_CODE, '') + ', DescriptionComments_TEXT = ' + ISNULL(@Ls_DescriptionComments_TEXT, '') + ', CaseFormer_ID = ' + ISNULL(@Lc_Space_TEXT, '') + ', InsCarrier_NAME = ' + ISNULL(@Lc_Space_TEXT, '') + ', InsPolicyNo_TEXT = ' + ISNULL(@Lc_Space_TEXT, '') + ', Hearing_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '') + ', Dismissal_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '') + ', GeneticTest_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '') + ', Attachment_INDC = ' + ISNULL(@Lc_No_INDC, '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '') + ', WorkerUpdate_ID = ' + ISNULL(@Lc_WorkerUpdate_ID, '') + ', Update_DTTM = ' + ISNULL(CAST(@Ad_Start_DATE AS VARCHAR), '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', File_ID = ' + ISNULL(@Lc_Space_TEXT, '') + ', PfNoShow_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '') + ', ArrearComputed_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '');

     INSERT CSPR_Y1
            (Generated_DATE,
             Case_IDNO,
             IVDOutOfStateFips_CODE,
             IVDOutOfStateCountyFips_CODE,
             IVDOutOfStateOfficeFips_CODE,
             IVDOutOfStateCase_ID,
             ExchangeMode_INDC,
             StatusRequest_CODE,
             Form_ID,
             FormWeb_URL,
             TransHeader_IDNO,
             Function_CODE,
             Action_CODE,
             Reason_CODE,
             DescriptionComments_TEXT,
             CaseFormer_ID,
             InsCarrier_NAME,
             InsPolicyNo_TEXT,
             Hearing_DATE,
             Dismissal_DATE,
             GeneticTest_DATE,
             Attachment_INDC,
             BeginValidity_DATE,
             EndValidity_DATE,
             WorkerUpdate_ID,
             Update_DTTM,
             TransactionEventSeq_NUMB,
             File_ID,
             PfNoShow_DATE,
             RespondentMci_IDNO,
             ArrearComputed_DATE,
             TotalInterestOwed_AMNT,
             TotalArrearsOwed_AMNT)
     VALUES (@Ld_RjctCur_Transaction_DATE,--Generated_DATE
             CAST((CASE LTRIM(SUBSTRING(@Lc_RjctCur_Case_IDNO, 1, 11))
                    WHEN @Lc_Empty_TEXT
                     THEN '0'
                    ELSE LTRIM(SUBSTRING(@Lc_RjctCur_Case_IDNO, 1, 11))
                   END) AS NUMERIC),--Case_IDNO
             RIGHT(REPLICATE('0', 2) + LTRIM(RTRIM(@Lc_RjctCur_IVDOutOfStateFips_CODE)), 2),--IVDOutOfStateFips_CODE
             RIGHT(REPLICATE('0', 3) + LTRIM(RTRIM(@Lc_RjctCur_IVDOutOfStateCountyFips_CODE)), 3),--IVDOutOfStateCountyFips_CODE
             RIGHT(REPLICATE('0', 2) + LTRIM(RTRIM(@Lc_RjctCur_IVDOutOfStateOfficeFips_CODE)), 2),--IVDOutOfStateOfficeFips_CODE
             @Lc_RjctCur_IVDOutOfStateCase_ID,--IVDOutOfStateCase_ID
             @Ac_ExchangeMode_INDC,--ExchangeMode_INDC
             @Lc_ReqStatusPending_CODE,--StatusRequest_CODE
             @Li_Zero_NUMB,--Form_ID
             @Lc_Space_TEXT,--FormWeb_URL
             @Ln_RjctCur_TransHeader_IDNO,--TransHeader_IDNO
             @Lc_FunctionManagestcases_CODE,--Function_CODE
             @Lc_ActionProvide_CODE,--Action_CODE
             @Lc_Reason_CODE,--Reason_CODE
             @Ls_DescriptionComments_TEXT,--DescriptionComments_TEXT
             @Lc_Space_TEXT,--CaseFormer_ID
             @Lc_Space_TEXT,--InsCarrier_NAME
             @Lc_Space_TEXT,--InsPolicyNo_TEXT
             @Ld_Low_DATE,--Hearing_DATE
             @Ld_Low_DATE,--Dismissal_DATE
             @Ld_Low_DATE,--GeneticTest_DATE
             @Lc_No_INDC,--Attachment_INDC
             CONVERT(DATE, @Ad_Run_DATE, 101),--BeginValidity_DATE
             @Ld_High_DATE,--EndValidity_DATE
             @Lc_WorkerUpdate_ID,--WorkerUpdate_ID
             @Ad_Start_DATE,--Update_DTTM
             @Ln_TransactionEventSeq_NUMB,--TransactionEventSeq_NUMB
             @Lc_Space_TEXT,--File_ID
             @Ld_Low_DATE,--PfNoShow_DATE
             0,--RespondentMci_IDNO
             @Ld_Low_DATE,--ArrearComputed_DATE
             0,--TotalInterestOwed_AMNT
             0 --TotalArrearsOwed_AMNT
     );

     SET @Ln_RowCount_QNTY = @@ROWCOUNT;

     IF @Ln_RowCount_QNTY = 0
      BEGIN
       SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
       SET @As_DescriptionError_TEXT = 'CSPR_Y1 INSERT FAILED FOR REJECTED TRANSACTION';
       SET @Ls_Sql_TEXT = 'CSPR_Y1 INSERT FAILED';
       SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Ac_JobProcess_IDNO, '') + ', Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', TypeError_CODE = ' + ISNULL(@Lc_ErrorTypeError_CODE, '') + ', Error_CODE = ' + ISNULL(@Lc_ErrorAddNotsuccess_TEXT, '') + ', DescriptionError_TEXT = ' + ISNULL(@As_DescriptionError_TEXT, '') + ', ListKey_TEXT = ' + ISNULL(@Ls_Sqldata_TEXT, '');

       EXECUTE BATCH_COMMON$SP_BATE_LOG
        @As_Process_NAME             = 'BATCH_CI_INCOMING_CSENET_FILE',
        @As_Procedure_NAME           = 'BATCH_CI_INCOMING_CSENET_FILE$SP_REJECTED_TRANS',
        @Ac_Job_ID                   = @Ac_JobProcess_IDNO,
        @Ad_Run_DATE                 = @Ad_Run_DATE,
        @Ac_TypeError_CODE           = @Lc_ErrorTypeError_CODE,
        @An_Line_NUMB                = 1,
        @Ac_Error_CODE               = @Lc_ErrorAddNotsuccess_TEXT,
        @As_DescriptionError_TEXT    = @As_DescriptionError_TEXT,
        @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
        @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         SET @Ls_DescriptionError_TEXT = 'INSERT INTO BATE FAILED FOR ';
        END;

       RAISERROR(50001,16,1);
      END;

     FETCH NEXT FROM Rjct_CUR INTO @Ln_RjctCur_TransHeader_IDNO, @Lc_RjctCur_IVDOutOfStateFips_CODE, @Lc_RjctCur_Case_IDNO, @Ld_RjctCur_Transaction_DATE, @Lc_RjctCur_Function_CODE, @Lc_RjctCur_Action_CODE, @Lc_RjctCur_Reason_CODE, @Lc_RjctCur_IVDOutOfStateCountyFips_CODE, @Lc_RjctCur_IVDOutOfStateOfficeFips_CODE, @Lc_RjctCur_IVDOutOfStateCase_ID, @Lc_RjctCur_RejectReason_CODE, @Li_RjctCur_NcpBlock_INDC, @Li_RjctCur_Participant_QNTY;

     SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;
    END;

   IF CURSOR_STATUS('LOCAL', 'Rjct_CUR') IN (0, 1)
    BEGIN
     CLOSE Rjct_CUR;

     DEALLOCATE Rjct_CUR;
    END;

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

   IF CURSOR_STATUS('LOCAL', 'Rjct_CUR') IN (0, 1)
    BEGIN
     CLOSE Rjct_CUR;

     DEALLOCATE Rjct_CUR;
    END;

   IF CURSOR_STATUS('LOCAL', 'RecCPDP_CUR') IN (0, 1)
    BEGIN
     CLOSE RecCPDP_CUR;

     DEALLOCATE RecCPDP_CUR;
    END;

   SET @Li_Error_NUMB = ERROR_NUMBER();
   SET @Li_ErrorLine_NUMB = ERROR_LINE();

   IF (@Li_Error_NUMB <> 50001)
    BEGIN
     SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END;

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_SqlData_TEXT,
    @An_Error_NUMB            = @Li_Error_NUMB,
    @An_ErrorLine_NUMB        = @Li_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
  END CATCH;
 END;


GO
