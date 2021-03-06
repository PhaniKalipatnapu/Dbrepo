/****** Object:  StoredProcedure [dbo].[BATCH_ENF_OUTGOING_STATE_TAX_OFFSET$SP_INSERT_PREOFFSET]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_ENF_OUTGOING_STATE_TAX_OFFSET$SP_INSERT_PREOFFSET
Programmer Name	:	IMP Team.
Description		:	The purpose of BATCH_ENF_OUTGOING_STATE_TAX_OFFSET$SP_INSERT_PREOFFSET is 
					  to insert into preoffset table
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
CREATE PROCEDURE [dbo].[BATCH_ENF_OUTGOING_STATE_TAX_OFFSET$SP_INSERT_PREOFFSET]
 @An_MemberMci_IDNO        NUMERIC(10),
 @An_Case_IDNO             NUMERIC(6),
 @An_TaxYear_NUMB          NUMERIC(4),
 @Ad_Run_DATE              DATE,
 @An_MemberSsn_NUMB        NUMERIC(9),
 @An_NonTanfArrear_AMNT    NUMERIC(11, 2),
 @An_TanfArrear_AMNT       NUMERIC(11, 2),
 @Ac_NonTanfCertified_INDC CHAR(01),
 @Ac_TanfCertified_INDC    CHAR(01),
 @Ac_TypeTransaction_CODE  CHAR(01),
 @Ac_CountyFips_CODE       CHAR(03),
 @Ac_Job_ID                CHAR(07),
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusSuccess_CODE CHAR(1) = 'S',
          @Lc_StatusFailed_CODE  CHAR(1) = 'F',
          @Lc_No_INDC            CHAR(1) = 'N',
          @Lc_BatchRunUser_TEXT  CHAR(5) = 'BATCH',
          @Lc_Job_ID             CHAR(7) = @Ac_Job_ID,
          @Ls_Procedure_NAME     VARCHAR(100) = 'SP_INSERT_PREOFFSET',
          @Ld_Run_DATE           DATE = @Ad_Run_DATE;
  DECLARE @Ln_EventFunctionalSeq_NUMB  NUMERIC(4) = 0,
          @Ln_Error_NUMB               NUMERIC(11),
          @Ln_ErrorLine_NUMB           NUMERIC(11),
          @Ln_Transaction_AMNT         NUMERIC(11, 2),
          @Ln_TransactionEventSeq_NUMB NUMERIC(19) = 0,
          @Lc_Empty_TEXT               CHAR = '',
          @Lc_Note_INDC                CHAR(1) = '',
          @Lc_Msg_CODE                 CHAR(5),
          @Lc_TypeArrear_CODE          CHAR(1),
          @Ls_Sql_TEXT                 VARCHAR(100) = '',
          @Ls_ErrorMessage_TEXT        VARCHAR(200),
          @Ls_SqlData_TEXT             VARCHAR(1000) = '',
          @Ls_DescriptionError_TEXT    VARCHAR(4000),
          @Ld_Start_DATE               DATETIME2;

  BEGIN TRY
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT';
   SET @Ls_SqlData_TEXT = 'Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', Process_ID = ' + ISNULL(@Lc_Job_ID, '') + ', EffectiveEvent_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Note_INDC = ' + ISNULL(@Lc_Note_INDC, '') + ', EventFunctionalSeq_NUMB = ' + ISNULL(CAST(@Ln_EventFunctionalSeq_NUMB AS VARCHAR), '');

   EXECUTE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
    @Ac_Worker_ID                = @Lc_BatchRunUser_TEXT,
    @Ac_Process_ID               = @Lc_Job_ID,
    @Ad_EffectiveEvent_DATE      = @Ld_Run_DATE,
    @Ac_Note_INDC                = @Lc_No_INDC,
    @An_EventFunctionalSeq_NUMB  = @Ln_EventFunctionalSeq_NUMB,
    @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
    @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

     RAISERROR (50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'CHECK FOR NON-TANF CERTIFIED';

   IF @An_NonTanfArrear_AMNT > 0
    BEGIN
     SET @Ls_Sql_TEXT = 'SET NON-TANF ARREAS';
     SET @Lc_TypeArrear_CODE = 'N';
     SET @Ln_Transaction_AMNT = @An_NonTanfArrear_AMNT;
     SET @Ls_Sql_TEXT = 'INSERT INTO #IstxData_P1 - 1';
     SET @Ls_SqlData_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@An_MemberMci_IDNO AS VARCHAR), '') + ', Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '') + ', MemberSsn_NUMB = ' + ISNULL(CAST(@An_MemberSsn_NUMB AS VARCHAR), '') + ', TaxYear_NUMB = ' + ISNULL(CAST(@An_TaxYear_NUMB AS VARCHAR), '') + ', TypeTransaction_CODE = ' + ISNULL(@Ac_TypeTransaction_CODE, '') + ', TypeArrear_CODE = ' + ISNULL(@Lc_TypeArrear_CODE, '') + ', Transaction_AMNT = ' + ISNULL(CAST(@Ln_Transaction_AMNT AS VARCHAR), '') + ', WorkerUpdate_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', ExcludeState_CODE = ' + ISNULL(@Lc_No_INDC, '') + ', CountyFips_CODE = ' + ISNULL(@Ac_CountyFips_CODE, '');

     INSERT INTO #IstxData_P1
                 (MemberMci_IDNO,
                  Case_IDNO,
                  MemberSsn_NUMB,
                  TaxYear_NUMB,
                  TypeTransaction_CODE,
                  TypeArrear_CODE,
                  Transaction_AMNT,
                  SubmitLast_DATE,
                  WorkerUpdate_ID,
                  Update_DTTM,
                  TransactionEventSeq_NUMB,
                  ExcludeState_CODE,
                  CountyFips_CODE)
          VALUES(@An_MemberMci_IDNO,--MemberMci_IDNO
                 @An_Case_IDNO,--Case_IDNO
                 @An_MemberSsn_NUMB,--MemberSsn_NUMB
                 @An_TaxYear_NUMB,--TaxYear_NUMB
                 @Ac_TypeTransaction_CODE,--TypeTransaction_CODE
                 @Lc_TypeArrear_CODE,--TypeArrear_CODE
                 @Ln_Transaction_AMNT,--Transaction_AMNT
                 CONVERT(CHAR(10), @Ad_Run_DATE, 101),--SubmitLast_DATE
                 @Lc_BatchRunUser_TEXT,--WorkerUpdate_ID
                 @Ld_Start_DATE,--Update_DTTM
                 @Ln_TransactionEventSeq_NUMB,--TransactionEventSeq_NUMB
                 @Lc_No_INDC,--ExcludeState_CODE
                 @Ac_CountyFips_CODE --CountyFips_CODE
     );
    END

   SET @Ls_Sql_TEXT = 'CHECK FOR TANF CERTIFIED';

   IF @An_TanfArrear_AMNT > 0
    BEGIN
     SET @Ls_Sql_TEXT = 'SET TANF ARREAS';
     SET @Lc_TypeArrear_CODE = 'A';
     SET @Ln_Transaction_AMNT = @An_TanfArrear_AMNT;
     SET @Ls_Sql_TEXT = 'INSERT INTO #IstxData_P1 - 2';
     SET @Ls_SqlData_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@An_MemberMci_IDNO AS VARCHAR), '') + ', Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '') + ', MemberSsn_NUMB = ' + ISNULL(CAST(@An_MemberSsn_NUMB AS VARCHAR), '') + ', TaxYear_NUMB = ' + ISNULL(CAST(@An_TaxYear_NUMB AS VARCHAR), '') + ', TypeTransaction_CODE = ' + ISNULL(@Ac_TypeTransaction_CODE, '') + ', TypeArrear_CODE = ' + ISNULL(@Lc_TypeArrear_CODE, '') + ', Transaction_AMNT = ' + ISNULL(CAST(@Ln_Transaction_AMNT AS VARCHAR), '') + ', WorkerUpdate_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', ExcludeState_CODE = ' + ISNULL(@Lc_No_INDC, '') + ', CountyFips_CODE = ' + ISNULL(@Ac_CountyFips_CODE, '');

     INSERT INTO #IstxData_P1
                 (MemberMci_IDNO,
                  Case_IDNO,
                  MemberSsn_NUMB,
                  TaxYear_NUMB,
                  TypeTransaction_CODE,
                  TypeArrear_CODE,
                  Transaction_AMNT,
                  SubmitLast_DATE,
                  WorkerUpdate_ID,
                  Update_DTTM,
                  TransactionEventSeq_NUMB,
                  ExcludeState_CODE,
                  CountyFips_CODE)
          VALUES(@An_MemberMci_IDNO,--MemberMci_IDNO
                 @An_Case_IDNO,--Case_IDNO
                 @An_MemberSsn_NUMB,--MemberSsn_NUMB
                 @An_TaxYear_NUMB,--TaxYear_NUMB
                 @Ac_TypeTransaction_CODE,--TypeTransaction_CODE
                 @Lc_TypeArrear_CODE,--TypeArrear_CODE
                 @Ln_Transaction_AMNT,--Transaction_AMNT
                 CONVERT(CHAR(10), @Ad_Run_DATE, 101),--SubmitLast_DATE
                 @Lc_BatchRunUser_TEXT,--WorkerUpdate_ID
                 @Ld_Start_DATE,--Update_DTTM
                 @Ln_TransactionEventSeq_NUMB,--TransactionEventSeq_NUMB
                 @Lc_No_INDC,--ExcludeState_CODE
                 @Ac_CountyFips_CODE --CountyFips_CODE
     );
    END

   SET @Ls_Sql_TEXT = 'INSERT INTO #InsertPreOffset_P1';
   SET @Ls_SqlData_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@An_MemberMci_IDNO AS VARCHAR), '') + ', Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '') + ', MemberSsn_NUMB = ' + ISNULL(CAST(@An_MemberSsn_NUMB AS VARCHAR), '') + ', County_CODE = ' + ISNULL(@Ac_CountyFips_CODE, '') + ', TanfArrear_AMNT = ' + ISNULL(CAST(@An_TanfArrear_AMNT AS VARCHAR), '') + ', NonTanfArrear_AMNT = ' + ISNULL(CAST(@An_NonTanfArrear_AMNT AS VARCHAR), '') + ', Create_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '');

   INSERT INTO #InsertPreOffset_P1
               (MemberMci_IDNO,
                Case_IDNO,
                MemberSsn_NUMB,
                County_CODE,
                TanfArrear_AMNT,
                NonTanfArrear_AMNT,
                Create_DATE,
                TransactionEventSeq_NUMB)
        VALUES (@An_MemberMci_IDNO,--MemberMci_IDNO
                @An_Case_IDNO,--Case_IDNO
                @An_MemberSsn_NUMB,--MemberSsn_NUMB
                @Ac_CountyFips_CODE,--County_CODE
                @An_TanfArrear_AMNT,--TanfArrear_AMNT
                @An_NonTanfArrear_AMNT,--NonTanfArrear_AMNT
                @Ad_Run_DATE,--Create_DATE
                @Ln_TransactionEventSeq_NUMB --TransactionEventSeq_NUMB
   );

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = @Lc_Empty_TEXT;
  END TRY

  BEGIN CATCH
   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_ErrorMessage_TEXT = ERROR_MESSAGE();
    END;

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
  END CATCH
 END;


GO
