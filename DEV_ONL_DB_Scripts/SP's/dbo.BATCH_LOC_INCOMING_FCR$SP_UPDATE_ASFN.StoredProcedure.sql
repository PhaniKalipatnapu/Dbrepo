/****** Object:  StoredProcedure [dbo].[BATCH_LOC_INCOMING_FCR$SP_UPDATE_ASFN]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
------------------------------------------------------------------------------------------------------------------------
Procedure  Name	     : BATCH_LOC_INCOMING_FCR$SP_UPDATE_ASFN
Programmer Name		 : IMP Team
Description			 : Updates member Financial assets information into ASFN_Y1
                       and generates alert to worker.
Frequency			 : Daily
Developed On		 : 04/17/2011
Called By			 : None
Called On			 : 
------------------------------------------------------------------------------------------------------------------------
Modified By			 : 
Modified On			 :
Version No			 : 1.0
------------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_LOC_INCOMING_FCR$SP_UPDATE_ASFN]
 @Ad_Run_DATE                 DATE,
 @An_MemberMci_IDNO           NUMERIC(10),
 @An_OtherParty_IDNO          NUMERIC(9),
 @An_OthpAtty_IDNO            NUMERIC(9),
 @Ad_Response_DATE            DATE,
 @Ac_AcctAssetNo_TEXT         CHAR(30),
 @An_ValueAsset_AMNT          NUMERIC(11, 2),
 @Ac_AcctType_CODE            CHAR(2),
 @Ac_Asset_CODE               CHAR(3),
 @As_AcctLegalTitle_TEXT      VARCHAR(100),
 @Ac_IndJointAccount_TEXT     CHAR(1),
 @Ac_AcctLocState_CODE        CHAR(2),
 @Ac_SourceLoc_CODE           CHAR(3),
 @Ac_NameAcctPrimaryNo_TEXT   CHAR(40),
 @Ac_NameAcctSecondaryNo_TEXT CHAR(40),
 -- 13512 - Incoming FCR insurance match process to map calim loss date to ASFN_Y1 table -START-
 @Ad_ClaimLoss_DATE           DATE = '0001-01-01',
 -- 13512 - Incoming FCR insurance match process to map calim loss date to ASFN_Y1 table -END-
 @Ac_Msg_CODE                 CHAR(5) OUTPUT,
 @An_TransactionEventSeq_NUMB NUMERIC(19) OUTPUT,
 @As_DescriptionError_TEXT    VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

    DECLARE  @Lc_No_INDC                    CHAR(1) = 'N',
           @Lc_Yes_INDC                     CHAR(1) = 'Y',
           @Lc_StatusFailed_CODE            CHAR(1) = 'F',
           @Lc_VerificationStatusGood_CODE  CHAR(1) = 'Y',
           @Lc_StatusSuccess_CODE           CHAR(1) = 'S',
           @Lc_MsgD1_CODE                   CHAR(1) = 'D',
           @Lc_Note_INDC                    CHAR(1) = 'N',
           @Lc_CaseStatusOpen_CODE          CHAR(1) = 'O',
           @Lc_StatusCaseMemberActive_CODE  CHAR(1) = 'A',
           @Lc_SubsystemLoc_CODE            CHAR(3) = 'LO',
           @Lc_Asset_CODE                   CHAR(3) = ' ',
           @Lc_MajorActivityCase_CODE       CHAR(4) = 'CASE',
           @Lc_MinorActivityMrfin_CODE      CHAR(5) = 'MRFIN',
           @Lc_Job_ID                       CHAR(7) = 'DEB0480',
           @Lc_Process_ID                   CHAR(10) = 'FCR_ASFN',
           @Lc_BatchRunUser_TEXT            CHAR(30) = 'BATCH',
           @Ls_Procedure_NAME               VARCHAR(60) = 'SP_UPDATE_ASFN',
           @Ld_High_DATE                    DATE = '12/31/9999',
           @Ld_Low_DATE                     DATE = '01/01/0001';
  DECLARE  @Ln_Zero_NUMB					NUMERIC(1) = 0,
		   @Ln_AssetSeq_NUMB				NUMERIC(3),
           @Ln_Topic_IDNO					NUMERIC(10) = 0,
           @Ln_EventFunctionalSeq_NUMB		NUMERIC(10) = 0,
           @Ln_Error_NUMB					NUMERIC(11),
           @Ln_ErrorLine_NUMB				NUMERIC(11),
           @Ln_TransactionEventSeq_NUMB		NUMERIC(19),
           @Li_FetchStatus_QNTY				SMALLINT,
           @Li_Rowcount_QNTY				SMALLINT,
           @Lc_Space_TEXT					CHAR(1) = '',
           @Lc_Msg_CODE						CHAR(1),
           @Lc_Exists_INDC					CHAR(1),
           @Lc_UpdateFlag_INDC				CHAR(1),
           @Ls_Sql_TEXT						VARCHAR(100),
           @Ls_Sqldata_TEXT					VARCHAR(1000),
           @Ls_ErrorMessage_TEXT			VARCHAR(4000);
                      
  -- Cursor variables
  DECLARE @Ln_OpenCasesCur_Case_IDNO		NUMERIC(6); 

  BEGIN TRY
   SET @Ac_Msg_CODE = NULL;
   SET @As_DescriptionError_TEXT = NULL;
   SET @Ls_Sql_TEXT = @Lc_Space_TEXT;
   SET @Ls_Sqldata_TEXT = @Lc_Space_TEXT;
   SET @Lc_Exists_INDC = @Lc_No_INDC;
   SET @Lc_UpdateFlag_INDC = @Lc_No_INDC;
   SET @Ln_TransactionEventSeq_NUMB = 0;
   SET @Ls_Sql_TEXT = 'SELECT_ASFN_Y1 FOR DUPLICATE';
   SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@An_MemberMci_IDNO AS VARCHAR(10)), 0) + ', Asset_CODE = ' + ISNULL(@Ac_AcctType_CODE, '') + ', AccountAssetNo_TEXT = ' + ISNULL(@Ac_AcctAssetNo_TEXT, '') + ', OthpInsFin_IDNO = ' + ISNULL(CAST(@An_OtherParty_IDNO AS VARCHAR(9)), 0);   
   IF @An_OtherParty_IDNO <> 0
    BEGIN
     SET @Ls_Sql_TEXT = 'SELECT_ASFN_Y1 FOR DUPLICATE';
   SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@An_MemberMci_IDNO AS VARCHAR(10)), 0) + ', Asset_CODE = ' + ISNULL(@Ac_AcctType_CODE, '') + ', AccountAssetNo_TEXT = ' + ISNULL(@Ac_AcctAssetNo_TEXT, '') + ', OthpInsFin_IDNO = ' + ISNULL(CAST(@An_OtherParty_IDNO AS VARCHAR(9)), 0);
     SELECT @Lc_Exists_INDC = @Lc_Yes_INDC
       FROM ASFN_Y1 a
      WHERE a.MemberMci_IDNO = @An_MemberMci_IDNO
        AND a.Asset_CODE = @Ac_Asset_CODE
        AND a.AccountAssetNo_TEXT = @Ac_AcctAssetNo_TEXT
        AND a.OthpInsFin_IDNO = @An_OtherParty_IDNO
        AND a.EndValidity_DATE = @Ld_High_DATE;

     SET @Li_Rowcount_QNTY = @@ROWCOUNT;

     IF @Li_Rowcount_QNTY = 0
      BEGIN
       SET @Lc_Exists_INDC = @Lc_No_INDC;
      END
     ELSE IF @Li_Rowcount_QNTY > 1
      BEGIN
       SET @As_DescriptionError_TEXT = 'DUPLICATE FIN ASSET EXISTS FOR MEMBER';
       SET @Ac_Msg_CODE = @Lc_MsgD1_CODE;

       RETURN;
      END
    END
   ELSE IF @An_OthpAtty_IDNO <> 0
    BEGIN
     SET @Ls_Sql_TEXT = 'SELECT_ASFN_Y1 FOR DUPLICATE';
   SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@An_MemberMci_IDNO AS VARCHAR(10)), 0) + ', Asset_CODE = ' + ISNULL(@Ac_AcctType_CODE, '') + ', AccountAssetNo_TEXT = ' + ISNULL(@Ac_AcctAssetNo_TEXT, '') + ', OthpInsFin_IDNO = ' + ISNULL(CAST(@An_OtherParty_IDNO AS VARCHAR(9)), 0);
     SELECT @Lc_Exists_INDC = @Lc_Yes_INDC
       FROM ASFN_Y1 a
      WHERE a.MemberMci_IDNO = @An_MemberMci_IDNO
        AND a.Asset_CODE = @Ac_Asset_CODE
        AND a.AccountAssetNo_TEXT = @Ac_AcctAssetNo_TEXT
        AND a.OthpInsFin_IDNO = @An_OtherParty_IDNO
        AND a.EndValidity_DATE = @Ld_High_DATE;

     SET @Li_Rowcount_QNTY = @@ROWCOUNT;

     IF @Li_Rowcount_QNTY = 0
      BEGIN
       SET @Lc_Exists_INDC = @Lc_No_INDC;
      END
     ELSE IF @Li_Rowcount_QNTY > 1
      BEGIN
       SET @As_DescriptionError_TEXT = 'DUPLICATE FIN ASSET EXISTS FOR MEMBER';
       SET @Ac_Msg_CODE = @Lc_MsgD1_CODE;

       RETURN;
      END
    END

   IF @Lc_Exists_INDC = @Lc_Yes_INDC
    BEGIN
     SET @Ls_Sql_TEXT = 'SELECT_VASFN1 FOR AssetSeq_NUMB';
     SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@An_MemberMci_IDNO AS VARCHAR(10)), 0);
     
     SELECT @Ln_AssetSeq_NUMB = a.AssetSeq_NUMB,
            @Ln_TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB
       FROM ASFN_Y1 a
      WHERE a.MemberMci_IDNO = @An_MemberMci_IDNO
        AND a.Asset_CODE = @Ac_Asset_CODE
        AND a.AccountAssetNo_TEXT = @Ac_AcctAssetNo_TEXT
        AND a.OthpInsFin_IDNO = @An_OtherParty_IDNO
        AND a.EndValidity_DATE = @Ld_High_DATE;

     SET @Ls_Sql_TEXT = 'UPDATE ASFN_Y1 BEFORE INSERT';
     SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@An_MemberMci_IDNO AS VARCHAR(10)), 0) + ', Asset_CODE = ' + ISNULL(@Ac_AcctType_CODE, '') + ', AccountAssetNo_TEXT = ' + ISNULL(@Ac_AcctAssetNo_TEXT, '');
     
     UPDATE ASFN_Y1 
        SET EndValidity_DATE = @Ad_Run_DATE
      WHERE ASFN_Y1.MemberMci_IDNO = @An_MemberMci_IDNO
        AND ASFN_Y1.Asset_CODE = @Ac_Asset_CODE
        AND ASFN_Y1.AccountAssetNo_TEXT = @Ac_AcctAssetNo_TEXT
        AND ASFN_Y1.OthpInsFin_IDNO = @An_OtherParty_IDNO
        AND ASFN_Y1.EndValidity_DATE = @Ld_High_DATE
        AND ASFN_Y1.TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB;

     SET @Li_Rowcount_QNTY = @@ROWCOUNT;

     IF @Li_Rowcount_QNTY = 0
      BEGIN
       SET @As_DescriptionError_TEXT = 'UPDATE ASFN_Y1 FAILED';
       SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

       RAISERROR(50001,16,1);
      END

     SET @Lc_UpdateFlag_INDC = @Lc_Yes_INDC;
    END

   SET @Lc_Asset_CODE = @Ac_Asset_CODE;

   IF @Lc_UpdateFlag_INDC = @Lc_No_INDC
    BEGIN
     SET @Ls_Sql_TEXT = 'SELECT_NEXT_SEQ_ASSET';
     SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@An_MemberMci_IDNO AS VARCHAR),0);

     SELECT @Ln_AssetSeq_NUMB = ISNULL(MAX(a.AssetSeq_NUMB), 0)
       FROM ASFN_Y1 a 
      WHERE a.MemberMci_IDNO = @An_MemberMci_IDNO
        AND a.EndValidity_DATE = @Ld_High_DATE;

     SET @Ln_AssetSeq_NUMB = @Ln_AssetSeq_NUMB + 1;
    END

   SET @Ln_TransactionEventSeq_NUMB = 0;
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$BATCH_COMMON$SP_GENERATE_SEQ_TXN_EVENT 5';
   SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@An_MemberMci_IDNO AS VARCHAR),0);
   
   EXECUTE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
    @Ac_Worker_ID                = @Lc_BatchRunUser_TEXT,
    @Ac_Process_ID               = @Lc_Process_ID,
    @Ad_EffectiveEvent_DATE      = @Ad_Run_DATE,
    @Ac_Note_INDC                = @Lc_Note_INDC,
    @An_EventFunctionalSeq_NUMB  = @Ln_EventFunctionalSeq_NUMB,
    @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
    @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT    = @As_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     SET @As_DescriptionError_TEXT = 'BATCH_COMMON$BATCH_COMMON$SP_GENERATE_SEQ_TXN_EVENT 5 FAILED.';
     SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

     RETURN;
    
    END

   SET @Ls_Sql_TEXT = 'INSERT INTO ASFN_Y1';
   SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@An_MemberMci_IDNO AS VARCHAR(10)), 0) + ', Asset_CODE = ' + ISNULL(@Lc_Asset_CODE, '') + ', AssetSeq_NUMB = ' + ISNULL(CAST(@Ln_AssetSeq_NUMB AS VARCHAR(3)), 0);
  
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
   VALUES ( @An_MemberMci_IDNO, -- MemberMci_IDNO
            @Lc_Asset_CODE, -- Asset_CODE
            @Ln_AssetSeq_NUMB, -- AssetSeq_NUMB
            @Ac_SourceLoc_CODE, -- SourceLoc_CODE
            @An_OtherParty_IDNO, -- OthpInsFin_IDNO
            @An_OthpAtty_IDNO,--OthpAtty_IDNO 
            @Lc_VerificationStatusGood_CODE, -- Status_CODE
            @Ad_Run_DATE, -- Status_DATE
            ISNULL(@Ac_AcctAssetNo_TEXT, @Lc_Space_TEXT), -- AccountAssetNo_TEXT
            ISNULL(@Ac_AcctType_CODE, @Lc_Space_TEXT), -- AcctType_CODE
            @Ac_IndJointAccount_TEXT, -- JointAcct_INDC
            ISNULL(@Ac_NameAcctPrimaryNo_TEXT, @Lc_Space_TEXT), -- NameAcctPrimaryNo_TEXT
            ISNULL(@Ac_NameAcctSecondaryNo_TEXT, @Lc_Space_TEXT), -- NameAcctSecondaryNo_TEXT
            @An_ValueAsset_AMNT, -- ValueAsset_AMNT
            ISNULL(@As_AcctLegalTitle_TEXT, @Lc_Space_TEXT), -- DescriptionNote_TEXT
            ISNULL(@Ad_Response_DATE, @Ld_Low_DATE), -- AssetValue_DATE
            @Lc_No_INDC, -- LienInitiated_INDC
            ISNULL(@Ac_AcctLocState_CODE, @Ld_Low_DATE), -- LocateState_CODE
            @Ld_Low_DATE, -- Settlement_DATE
            @Ln_Zero_NUMB, --Settlement_AMNT
            @Ld_Low_DATE, -- Potential_DATE
            @Ln_Zero_NUMB, -- Potential_AMNT
            @Ad_Run_DATE, -- BeginValidity_DATE
            @Ld_High_DATE, -- EndValidity_DATE
            @Lc_BatchRunUser_TEXT, -- WorkerUpdate_ID
            dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(), -- Update_DTTM
            @Ln_TransactionEventSeq_NUMB, -- TransactionEventSeq_NUMB
            -- 13512 - Incoming FCR insurance match process to map calim loss date to ASFN_Y1 table -START-
            @Ad_ClaimLoss_DATE); -- ClaimLoss_DATE
            -- 13512 - Incoming FCR insurance match process to map calim loss date to ASFN_Y1 table -END-

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;

   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @As_DescriptionError_TEXT = 'UPDATE ASFN_Y1 FAILED';
     SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

     RETURN;
    END

   IF @Ac_SourceLoc_CODE <> 'OCS'
    BEGIN
     DECLARE OpenCases_CUR INSENSITIVE CURSOR FOR
      SELECT c.Case_IDNO 
        FROM CMEM_Y1  m,
             CASE_Y1  c
       WHERE m.MemberMci_IDNO = @An_MemberMci_IDNO
         AND m.Case_IDNO = c.Case_IDNO
         AND c.StatusCase_CODE = @Lc_CaseStatusOpen_CODE
         AND m.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE;

     OPEN OpenCases_CUR;

     FETCH NEXT FROM OpenCases_CUR INTO @Ln_OpenCasesCur_Case_IDNO;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
     -- Create Case journal entries  
     WHILE @Li_FetchStatus_QNTY = 0
      BEGIN
       
       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_ACTIVITY 3';
       SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@An_MemberMci_IDNO AS VARCHAR(10)), 0) + ', Case_IDNO = ' + ISNULL (CAST(@Ln_OpenCasesCur_Case_IDNO AS VARCHAR(6)), 0) + ', ActivityMinor_CODE = ' + ISNULL(@Lc_MinorActivityMrfin_CODE, '');
              
       EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
        @An_Case_IDNO                = @Ln_OpenCasesCur_Case_IDNO,
        @An_MemberMci_IDNO           = @An_MemberMci_IDNO,
        @Ac_ActivityMajor_CODE       = @Lc_MajorActivityCase_CODE,
        @Ac_ActivityMinor_CODE       = @Lc_MinorActivityMrfin_CODE,
        @Ac_Subsystem_CODE           = @Lc_SubsystemLoc_CODE,
        @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
        @Ac_WorkerUpdate_ID          = @Lc_BatchRunUser_TEXT,
        @Ac_WorkerDelegate_ID        = @Lc_Space_TEXT,
        @Ad_Run_DATE                 = @Ad_Run_DATE,
        @Ac_Job_ID                   = @Lc_Job_ID,
        @An_Topic_IDNO               = @Ln_Topic_IDNO OUTPUT,
        @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT    = @As_DescriptionError_TEXT OUTPUT;
      
       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_ACTIVITY 3 FAILED';
         SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

         CLOSE OpenCases_CUR;

         DEALLOCATE OpenCases_CUR;

         RETURN;
        END

       FETCH NEXT FROM OpenCases_CUR INTO @Ln_OpenCasesCur_Case_IDNO;

       SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
      END

     CLOSE OpenCases_CUR;

     DEALLOCATE OpenCases_CUR;
    END

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = @Lc_Space_TEXT;
   SET @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB;
  END TRY

  BEGIN CATCH
   
   IF CURSOR_STATUS ('local', 'OpenCases_CUR') IN (0, 1)
    BEGIN
     CLOSE OpenCases_CUR;

     DEALLOCATE OpenCases_CUR;
    END
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   SET @Ln_Error_NUMB = ERROR_NUMBER ();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE ();
   SET @Ls_ErrorMessage_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;
   
  END CATCH
 END


GO
