/****** Object:  StoredProcedure [dbo].[BATCH_ENF_INCOMING_FIDM$SP_UPDATE_ASFN]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_ENF_INCOMING_FIDM$SP_UPDATE_ASFN
Programmer Name	:	IMP Team.
Description		:	The procedure BATCH_ENF_INCOMING_FIDM$SP_UPDATE_ASFN reads the data from the temporary tables (LFIIR_Y1, LACHL_Y1 ) 
					  and updates the database tables with address and account information and starts the FIDM enforcement remedy
Frequency		:	'WEEKLY'
Developed On	:	4/19/2012
Called By		:	NONE
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_ENF_INCOMING_FIDM$SP_UPDATE_ASFN]
 @Ad_Run_DATE                 DATE,
 @Ac_Job_ID                   CHAR(7),
 @An_MemberMci_IDNO           NUMERIC(10),
 @An_OtherParty_IDNO          NUMERIC(9),
 @Ad_Response_DATE            DATE,
 @Ac_AccountAssetNo_TEXT      CHAR(30),
 @An_ValueAsset_AMNT          NUMERIC(11, 2),
 @Ac_AcctType_CODE            CHAR(3),
 @As_FullAccountTitle_TEXT    VARCHAR(250),
 @Ac_JointAcct_INDC           CHAR(1),
 @Ac_LocateState_CODE         CHAR(2),
 @Ac_SourceLoc_CODE           CHAR(3),
 @Ac_NameAcctPrimaryNo_TEXT   CHAR(40),
 @Ac_NameAcctSecondaryNo_TEXT CHAR(40),
 @Ac_Msg_CODE                 CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT    VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_Exists_INDC                 CHAR = ' ',
          @Lc_Yes_INDC                    CHAR = 'Y',
          @Lc_No_INDC                     CHAR = 'N',
          @Lc_Update_INDC                 CHAR = ' ',
          @Lc_NegPosStartRemedy_CODE      CHAR = 'P',
          @Lc_StatusFailed_CODE           CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE          CHAR(1) = 'S',
          @Lc_Space_TEXT                  CHAR(1) = ' ',
          @Lc_Note_INDC                   CHAR(1) = 'N',
          @Lc_CaseMemberStatusA_CODE      CHAR(1) = 'A',
          @Lc_StatusCaseO_CODE            CHAR(1) = 'O',
          @Lc_CaseRelationshipA_CODE      CHAR(1) = 'A',
          @Lc_CaseRelationshipP_CODE      CHAR(1) = 'P',
          @Lc_StatusEnforceO_CODE         CHAR(1) = 'O',
          @Lc_Zero_TEXT                   CHAR(1) = '0',
          @Lc_FidmEligible_INDC           CHAR(1) = 'N',
          @Lc_TypeChangeFidm_CODE         CHAR(2) = 'DM',
          @Lc_ComplianceStatusActive_CODE CHAR(2) = 'AC',
          @Lc_Asset_CODE                  CHAR(3) = ' ',
          @Lc_Subsystem_CODE              CHAR(3) = 'LO',
          @Lc_ActivityMajorCase_CODE      CHAR(4) = 'CASE',
          @Lc_TypeReference_IDNO          CHAR(4) = ' ',
          @Lc_ProcessFidm_ID              CHAR(4) = 'FIDM',
          @Lc_BatchRunUser_TEXT           CHAR(5) = 'BATCH',
          @Lc_ActivityMinorRacfd_CODE     CHAR(5) = 'RACFD',
          @Lc_Job_ID                      CHAR(7) = @Ac_Job_ID,
          @Lc_Notice_ID                   CHAR(8) = NULL,
          @Lc_WorkerDelegate_ID           CHAR(30) = ' ',
          @Lc_Reference_ID                CHAR(30) = ' ',
          @Ls_Procedure_NAME              VARCHAR(100) = 'SP_UPDATE_ASFN',
          @Ls_XmlIn_TEXT                  VARCHAR(MAX) = ' ',
          @Ld_Low_DATE                    DATE = '01/01/0001',
          @Ld_High_DATE                   DATE = '12/31/9999';
  DECLARE @Ln_MajorIntSeq_NUMB         NUMERIC(5) = 0,
          @Ln_MinorIntSeq_NUMB         NUMERIC(5) = 0,
          @Ln_AssetSeq_NUMB            NUMERIC(5, 3) = 0,
          @Ln_TopicIn_IDNO             NUMERIC(10) = 0,
          @Ln_MemberMci_IDNO           NUMERIC(10) = @An_MemberMci_IDNO,
          @Ln_Schedule_NUMB            NUMERIC(10) = 0,
          @Ln_Topic_IDNO               NUMERIC(10),
          @Ln_ErrorLine_NUMB           NUMERIC(11) = 0,
          @Ln_Error_NUMB               NUMERIC(11),
          @Ln_TransactionEventSeq_NUMB NUMERIC(19) = 0,
          @Li_FetchStatus_QNTY         SMALLINT,
          @Li_RowCount_QNTY            SMALLINT,
          @Lc_Msg_CODE                 CHAR(5),
          @Ls_Sql_TEXT                 VARCHAR(200) = '',
          @Ls_SqlData_TEXT             VARCHAR(1000) = '',
          @Ls_ErrorMessage_TEXT        VARCHAR(2000),
          @Ls_DescriptionError_TEXT    VARCHAR(4000),
          @Ld_Run_DATE                 DATE = @Ad_Run_DATE,
          @Ld_Start_DATE               DATETIME2;
  DECLARE @Ln_CaseMemberCur_Case_IDNO    NUMERIC(6),
          @Ln_OrderCaseCur_Case_IDNO     NUMERIC(6),
          @Ln_OrderCaseCur_OrderSeq_NUMB NUMERIC(5, 2);
  DECLARE CaseMember_CUR INSENSITIVE CURSOR FOR
   SELECT A.Case_IDNO
     FROM CMEM_Y1 A,
          CASE_Y1 B
    WHERE MemberMci_IDNO = @Ln_MemberMci_IDNO
      AND A.CaseMemberStatus_CODE = @Lc_CaseMemberStatusA_CODE
      AND A.Case_IDNO = B.Case_IDNO
      AND B.StatusCase_CODE = @Lc_StatusCaseO_CODE;
  DECLARE OrderCase_CUR INSENSITIVE CURSOR FOR
   SELECT A.Case_IDNO,
          C.OrderSeq_NUMB
     FROM CMEM_Y1 A,
          CASE_Y1 B,
          ACEN_Y1 C
    WHERE A.MemberMci_IDNO = @Ln_MemberMci_IDNO
      AND A.CaseMemberStatus_CODE = @Lc_CaseMemberStatusA_CODE
      AND A.CaseRelationship_CODE IN (@Lc_CaseRelationshipA_CODE, @Lc_CaseRelationshipP_CODE)
      AND A.Case_IDNO = B.Case_IDNO
      AND B.StatusCase_CODE = @Lc_StatusCaseO_CODE
      AND C.Case_IDNO = B.Case_IDNO
      AND C.StatusEnforce_CODE = @Lc_StatusEnforceO_CODE
      AND C.EndValidity_DATE = @Ld_High_DATE;

  BEGIN TRY
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   SET @Lc_Exists_INDC = @Lc_No_INDC;
   SET @Lc_Update_INDC = @Lc_No_INDC;
   SET @Ls_Sql_TEXT = 'CHECK ASFN FOR DUPLICATES';
   SET @Ls_SqlData_TEXT = 'MemberMci_IDNO = ' + CAST(@Ln_MemberMci_IDNO AS VARCHAR) + ', AcctType_CODE = ' + @Ac_AcctType_CODE + ', AcctAssetNo_TEXT = ' + @Ac_AccountAssetNo_TEXT + ', OtherParty_IDNO = ' + CAST(@An_OtherParty_IDNO AS VARCHAR);

   SELECT @Lc_Exists_INDC = @Lc_Yes_INDC
     FROM ASFN_Y1 A
    WHERE A.MemberMci_IDNO = @Ln_MemberMci_IDNO
      AND A.Asset_CODE = @Ac_AcctType_CODE
      AND A.AccountAssetNo_TEXT = @Ac_AccountAssetNo_TEXT
      AND A.OthpInsFin_IDNO = @An_OtherParty_IDNO
      AND A.EndValidity_DATE = @Ld_High_DATE;

   IF @Lc_Exists_INDC = @Lc_Yes_INDC
    BEGIN
     SET @Ls_Sql_TEXT = 'UPDATE ASFN BEFORE INSERT';
     SET @Ls_SqlData_TEXT = 'MemberMci_IDNO = ' + CAST(@Ln_MemberMci_IDNO AS VARCHAR) + ', AcctType_CODE = ' + @Ac_AcctType_CODE + ', AcctAssetNo_TEXT = ' + @Ac_AccountAssetNo_TEXT + ', OtherParty_IDNO = ' + CAST(@An_OtherParty_IDNO AS VARCHAR);

     UPDATE ASFN_Y1
        SET EndValidity_DATE = @Ld_Run_DATE
      WHERE MemberMci_IDNO = @Ln_MemberMci_IDNO
        AND Asset_CODE = @Ac_AcctType_CODE
        AND AccountAssetNo_TEXT = @Ac_AccountAssetNo_TEXT
        AND OthpInsFin_IDNO = @An_OtherParty_IDNO
        AND EndValidity_DATE = @Ld_High_DATE;

     SET @Li_RowCount_QNTY = @@ROWCOUNT;

     IF @Li_RowCount_QNTY = 0
      BEGIN
       SET @Ls_ErrorMessage_TEXT = 'UPDATE ASFN FAILED';

       RAISERROR (50001,16,1);
      END;
    END;

   SET @Lc_Asset_CODE = @Ac_AcctType_CODE;
   SET @Ls_Sql_TEXT = 'GET NEXT SEQUENCE ASSET FROM ASFN';
   SET @Ls_SqlData_TEXT = 'MemberMci_IDNO = ' + CAST(@Ln_MemberMci_IDNO AS VARCHAR);
   SET @Ln_AssetSeq_NUMB = ISNULL((SELECT MAX(ISNULL(AssetSeq_NUMB, 0))
                                     FROM ASFN_Y1 A
                                    WHERE A.MemberMci_IDNO = @Ln_MemberMci_IDNO
                                      AND A.EndValidity_DATE = @Ld_High_DATE), 0);
   SET @Ln_AssetSeq_NUMB = @Ln_AssetSeq_NUMB + 1;
   SET @Ln_TransactionEventSeq_NUMB = 0;
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT';
   SET @Ls_SqlData_TEXT = 'Process_ID = ' + @Lc_Job_ID;

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
     SET @Ls_ErrorMessage_TEXT = 'SP_GEN_SEQ_TXN_EVENT FAILED';

     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'INSERT INTO ASFN';
   SET @Ls_SqlData_TEXT = 'Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', MemberMci_IDNO = ' + CAST(@Ln_MemberMci_IDNO AS VARCHAR) + ', OtherParty_IDNO = ' + CAST(@An_OtherParty_IDNO AS VARCHAR) + ', Response_DATE = ' + CAST(@Ad_Response_DATE AS VARCHAR) + ', AcctAssetNo_TEXT = ' + @Ac_AccountAssetNo_TEXT + ', ValueAsset_AMNT = ' + CAST(@An_ValueAsset_AMNT AS VARCHAR) + ', AcctType_CODE = ' + @Ac_AcctType_CODE + ', AcctLegalTitle_TEXT = ' + @As_FullAccountTitle_TEXT + ', JointAcct_INDC = ' + @Ac_JointAcct_INDC + ', LocateState_CODE = ' + @Ac_LocateState_CODE + ', SourceLoc_CODE = ' + @Ac_SourceLoc_CODE + ', NameAcctPrimaryNo_TEXT = ' + @Ac_NameAcctPrimaryNo_TEXT + ', NameAcctSecondaryNo_TEXT = ' + @Ac_NameAcctSecondaryNo_TEXT;

   INSERT ASFN_Y1
          (MemberMci_IDNO,
           Asset_CODE,
           AssetSeq_NUMB,
           SourceLoc_CODE,
           OthpInsFin_IDNO,
           OthpAtty_IDNO,
           Status_CODE,
           Status_DATE,
           AccountAssetNo_TEXT,
           AcctType_CODE,
           JointAcct_INDC,
           NameAcctPrimaryNo_TEXT,
           NameAcctSecondaryNo_TEXT,
           ValueAsset_AMNT,
           DescriptionNote_TEXT,
           AssetValue_DATE,
           LienInitiated_INDC,
           LocateState_CODE,
           Settlement_DATE,
           Settlement_AMNT,
           Potential_DATE,
           Potential_AMNT,
           BeginValidity_DATE,
           EndValidity_DATE,
           WorkerUpdate_ID,
           Update_DTTM,
           TransactionEventSeq_NUMB,
           ClaimLoss_DATE)
   SELECT @Ln_MemberMci_IDNO AS MemberMci_IDNO,
          @Lc_Asset_CODE AS Asset_CODE,
          @Ln_AssetSeq_NUMB AS AssetSeq_NUMB,
          @Ac_SourceLoc_CODE AS SourceLoc_CODE,
          @An_OtherParty_IDNO AS OthpInsFin_IDNO,
          @Lc_Zero_TEXT AS OthpAtty_IDNO,
          @Lc_Yes_INDC AS Status_CODE,
          @Ld_Run_DATE AS Status_DATE,
          CASE
           WHEN LEN(LTRIM(RTRIM(ISNULL(@Ac_AccountAssetNo_TEXT, '')))) = 0
            THEN @Lc_Space_TEXT
           ELSE @Ac_AccountAssetNo_TEXT
          END AS AccountAssetNo_TEXT,
          CASE
           WHEN LEN(LTRIM(RTRIM(ISNULL(@Ac_AcctType_CODE, '')))) = 0
            THEN @Lc_Space_TEXT
           ELSE @Ac_AcctType_CODE
          END AS AcctType_CODE,
          @Ac_JointAcct_INDC AS JointAcct_INDC,
          CASE
           WHEN LEN(LTRIM(RTRIM(ISNULL(@Ac_NameAcctPrimaryNo_TEXT, '')))) = 0
            THEN @Lc_Space_TEXT
           ELSE @Ac_NameAcctPrimaryNo_TEXT
          END AS NameAcctPrimaryNo_TEXT,
          CASE
           WHEN LEN(LTRIM(RTRIM(ISNULL(@Ac_NameAcctSecondaryNo_TEXT, '')))) = 0
            THEN @Lc_Space_TEXT
           ELSE @Ac_NameAcctSecondaryNo_TEXT
          END AS NameAcctSecondaryNo_TEXT,
          @An_ValueAsset_AMNT AS ValueAsset_AMNT,
          CASE
           WHEN LEN(LTRIM(RTRIM(ISNULL(@As_FullAccountTitle_TEXT, '')))) = 0
            THEN @Lc_Space_TEXT
           ELSE @As_FullAccountTitle_TEXT
          END AS DescriptionNote_TEXT,
          CASE
           WHEN LEN(LTRIM(RTRIM(ISNULL(@Ad_Response_DATE, '')))) = 0
            THEN @Ld_Low_DATE
           ELSE @Ad_Response_DATE
          END AS AssetValue_DATE,
          @Lc_No_INDC AS LienInitiated_INDC,
          CASE
           WHEN LEN(LTRIM(RTRIM(ISNULL(@Ac_LocateState_CODE, '')))) = 0
            THEN @Lc_Space_TEXT
           ELSE @Ac_LocateState_CODE
          END AS LocateState_CODE,
          @Ld_Low_DATE AS Settlement_DATE,
          @Lc_Zero_TEXT AS Settlement_AMNT,
          @Ld_Low_DATE AS Potential_DATE,
          @Lc_Zero_TEXT AS Potential_AMNT,
          @Ld_Run_DATE AS BeginValidity_DATE,
          @Ld_High_DATE AS EndValidity_DATE,
          @Lc_BatchRunUser_TEXT AS WorkerUpdate_ID,
          @Ld_Start_DATE AS Update_DTTM,
          @Ln_TransactionEventSeq_NUMB AS TransactionEventSeq_NUMB,
          @Ld_Low_DATE AS ClaimLoss_DATE;

   SET @Li_RowCount_QNTY = @@ROWCOUNT;

   IF @Li_RowCount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'INSERT ASFN FAILED';

     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'OPEN CaseMember_CUR';
   SET @Ls_SqlData_TEXT = '';

   OPEN CaseMember_CUR;

   SET @Ls_Sql_TEXT = 'FETCH NEXT FROM CaseMember_CUR - 1';
   SET @Ls_SqlData_TEXT = '';

   FETCH NEXT FROM CaseMember_CUR INTO @Ln_CaseMemberCur_Case_IDNO;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
   SET @Ls_Sql_TEXT = 'LOOP THROUGH CaseMember_CUR';
   SET @Ls_SqlData_TEXT = '';

   --Insert alert for all cases of member 
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_ACTIVITY';
     SET @Ls_SqlData_TEXT = 'Case_IDNO = ' + CAST(@Ln_CaseMemberCur_Case_IDNO AS VARCHAR) + ', MemberMci_IDNO = ' + CAST(@Ln_MemberMci_IDNO AS VARCHAR) + ', ActivityMinor_CODE = ' + @Lc_ActivityMinorRacfd_CODE;

     EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
      @An_Case_IDNO                = @Ln_CaseMemberCur_Case_IDNO,
      @An_MemberMci_IDNO           = @Ln_MemberMci_IDNO,
      @Ac_ActivityMajor_CODE       = @Lc_ActivityMajorCase_CODE,
      @Ac_ActivityMinor_CODE       = @Lc_ActivityMinorRacfd_CODE,
      @Ac_Subsystem_CODE           = @Lc_Subsystem_CODE,
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

     SET @Ls_Sql_TEXT = 'FETCH NEXT FROM CaseMember_CUR - 2';
     SET @Ls_SqlData_TEXT = '';

     FETCH NEXT FROM CaseMember_CUR INTO @Ln_CaseMemberCur_Case_IDNO;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END;

   SET @Ls_Sql_TEXT = 'CLOSE CaseMember_CUR';
   SET @Ls_SqlData_TEXT = '';

   CLOSE CaseMember_CUR;

   SET @Ls_Sql_TEXT = 'DEALLOCATE CaseMember_CUR';
   SET @Ls_SqlData_TEXT = '';

   DEALLOCATE CaseMember_CUR;

   SET @Ls_Sql_TEXT = 'OPEN OrderCase_CUR';
   SET @Ls_SqlData_TEXT = '';

   OPEN OrderCase_CUR;

   SET @Ls_Sql_TEXT = 'FETCH NEXT FROM OrderCase_CUR - 1';
   SET @Ls_SqlData_TEXT = '';

   FETCH NEXT FROM OrderCase_CUR INTO @Ln_OrderCaseCur_Case_IDNO, @Ln_OrderCaseCur_OrderSeq_NUMB;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
   SET @Ls_Sql_TEXT = 'LOOP THROUGH OrderCase_CUR';
   SET @Ls_SqlData_TEXT = '';

   --Insert into elfc for all open cases of member
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
     SET @Lc_FidmEligible_INDC = @Lc_No_INDC;
     SET @Ls_Sql_TEXT = 'VERIFY THAT THERE IS NO ACTIVE PERIODIC PAYMENT COMPLIANCE SCHEDULE ON COMP SCREEN';
     SET @Ls_SqlData_TEXT = 'Case_IDNO = ' + CAST(@Ln_OrderCaseCur_Case_IDNO AS VARCHAR) + ', OrderSeq_NUMB = ' + CAST(@Ln_OrderCaseCur_OrderSeq_NUMB AS VARCHAR);

     IF NOT EXISTS (SELECT 1
                      FROM COMP_Y1 X
                     WHERE X.Case_IDNO = @Ln_OrderCaseCur_Case_IDNO
                       AND X.OrderSeq_NUMB = @Ln_OrderCaseCur_OrderSeq_NUMB
                       AND X.EndValidity_DATE = @Ld_High_DATE
                       AND X.ComplianceStatus_CODE = @Lc_ComplianceStatusActive_CODE)
      BEGIN
       IF LEN(LTRIM(RTRIM(ISNULL(@Ac_AccountAssetNo_TEXT, '')))) > 0
        BEGIN
         SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_ELFC';
         SET @Ls_SqlData_TEXT = 'Case_IDNO = ' + CAST(@Ln_OrderCaseCur_Case_IDNO AS VARCHAR);

         EXECUTE BATCH_COMMON$SP_INSERT_ELFC
          @An_Case_IDNO                = @Ln_OrderCaseCur_Case_IDNO,
          @An_OrderSeq_NUMB            = @Ln_OrderCaseCur_OrderSeq_NUMB,
          @An_MemberMci_IDNO           = @Ln_MemberMci_IDNO,
          @An_OthpSource_IDNO          = @An_OtherParty_IDNO,
          @Ac_TypeChange_CODE          = @Lc_TypeChangeFidm_CODE,
          @Ac_NegPos_CODE              = @Lc_NegPosStartRemedy_CODE,
          @Ac_Process_ID               = @Lc_ProcessFidm_ID,
          @Ad_Create_DATE              = @Ld_Run_DATE,
          @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
          @Ac_WorkerUpdate_ID          = @Lc_BatchRunUser_TEXT,
          @Ac_TypeReference_CODE       = @Lc_Asset_CODE,
          @Ac_Reference_ID             = @Ac_AccountAssetNo_TEXT,
          @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
          @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

         IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
          BEGIN
           SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

           RAISERROR (50001,16,1);
          END;
        END;
      END;

     SET @Ls_Sql_TEXT = 'FETCH NEXT FROM OrderCase_CUR - 2';
     SET @Ls_SqlData_TEXT = '';

     FETCH NEXT FROM OrderCase_CUR INTO @Ln_OrderCaseCur_Case_IDNO, @Ln_OrderCaseCur_OrderSeq_NUMB;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END;

   SET @Ls_Sql_TEXT = 'CLOSE OrderCase_CUR';
   SET @Ls_SqlData_TEXT = '';

   CLOSE OrderCase_CUR;

   SET @Ls_Sql_TEXT = 'DEALLOCATE OrderCase_CUR';
   SET @Ls_SqlData_TEXT = '';

   DEALLOCATE OrderCase_CUR;

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = @Lc_Space_TEXT;
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

   IF CURSOR_STATUS('Local', 'CaseMember_CUR') IN (0, 1)
    BEGIN
     CLOSE CaseMember_CUR;

     DEALLOCATE CaseMember_CUR;
    END;

   IF CURSOR_STATUS('Local', 'OrderCase_CUR') IN (0, 1)
    BEGIN
     CLOSE OrderCase_CUR;

     DEALLOCATE OrderCase_CUR;
    END;

   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_ErrorMessage_TEXT = SUBSTRING(ERROR_MESSAGE(), 1, 200);
    END;

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_SqlData_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;
  END CATCH;
 END;


GO
