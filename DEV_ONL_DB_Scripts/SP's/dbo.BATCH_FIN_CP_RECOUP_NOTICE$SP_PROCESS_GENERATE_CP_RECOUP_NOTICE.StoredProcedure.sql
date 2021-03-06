/****** Object:  StoredProcedure [dbo].[BATCH_FIN_CP_RECOUP_NOTICE$SP_PROCESS_GENERATE_CP_RECOUP_NOTICE]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_FIN_CP_RECOUP_NOTICE$SP_PROCESS_GENERATE_CP_RECOUP_NOTICE
Programmer Name		: IMP Team
Description			: The batch process sends recoupment notices to the CPs. 
					  The batch process also updates the 'Pending' recoupment Status to 'Active' recoupment based 
					  on the CP's response to the notices and/or payment agreement.
Frequency			: DAILY
Developed On		: 4/12/2011
Called By			:
Called On			: BATCH_GEN_NOTICE_UTIL$SP_GET_RECIPIENT_ADDRESS,BATCH_FIN_CP_RECOUP_NOTICE$SP_SET_RECOUP_ACTIVE,
					  BATCH_FIN_CP_RECOUP_NOTICE$SP_INSERT_CPNO
--------------------------------------------------------------------------------------------------------------------
Modified By			:
Modified On			:
Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_FIN_CP_RECOUP_NOTICE$SP_PROCESS_GENERATE_CP_RECOUP_NOTICE]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @RecipientAddress_P1 TABLE (
   Line1_ADDR       VARCHAR(50),
   Line2_ADDR       VARCHAR(50),
   State_ADDR       VARCHAR(2),
   City_ADDR        CHAR(28),
   Zip_ADDR         CHAR(15),
   TypeAddress_CODE CHAR(1),
   Status_CODE      CHAR(1),
   Addr_INDC        CHAR(1));
  DECLARE @Ln_NoticeSeq_NUMB                NUMERIC(1) = 1,
          @Ln_WaitForResponce_NUMB          NUMERIC(2) = 30,
          @Li_CrecActivity2210_NUMB         INT = 2210,
          @Lc_CheckRecipientCpNcp_CODE      CHAR(1) = '1',
          @Lc_StatusCaseOpen_CODE           CHAR(1) = 'O',
          @Lc_TypeCaseNonIvd_CODE           CHAR(1) = 'H',
          @Lc_CaseRelationshipCp_CODE       CHAR(1) = 'C',
          @Lc_CaseMemberStatusActive_CODE   CHAR(1) = 'A',
          @Lc_StatusFailed_CODE             CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE            CHAR(1) = 'S',
          @Lc_StatusAbnormalend_CODE        CHAR(1) = 'A',
          @Lc_No_INDC                       CHAR(1) = 'N',
          @Lc_Yes_INDC                      CHAR(1) = 'Y',
          @Lc_TypeErrorE_CODE               CHAR(1) = 'E',
          @Lc_Busday_INDC                   CHAR(1) = '1',
          @Lc_Space_TEXT                    CHAR(1) = ' ',
          @Lc_Subsystem_CODE                CHAR(2) = 'FM',
          @Lc_CheckReceipientMc_ID          CHAR(2) = 'MC',
          @Lc_MajorActivityCase_CODE        CHAR(4) = 'CASE',
          @Lc_BatchRunUser_TEXT             CHAR(5) = 'BATCH',
          @Lc_ActivityMinor_CODE            CHAR(5) = 'NOPRI',
          @Lc_BateErrorUnknown_CODE         CHAR(5) = 'E1424',
          @Lc_FirstOverPaymentNotice_ID     CHAR(6) = 'FIN-36',
          @Lc_SecondOverPaymentNotice_ID    CHAR(6) = 'FIN-37',
          @Lc_FinalOverPaymentNotice_ID     CHAR(6) = 'FIN-38',
          @Lc_Job_ID                        CHAR(7) = 'DEB0610',
          @Lc_Successful_TEXT               CHAR(20) = 'SUCCESSFUL',
          @Lc_Err0002_TEXT                  CHAR(25) = 'UPDATE NOT SUCCESSFUL',
          @Ls_Procedure_NAME                VARCHAR(100) = 'SP_PROCESS_GENERATE_CP_RECOUP_NOTICE',
          @Ls_Process_NAME                  VARCHAR(100) = 'BATCH_FIN_CP_RECOUP_NOTICE',
          @Ld_Low_DATE                      DATE = '01/01/0001',
          @Ld_High_DATE                     DATE = '12/31/9999',
          @Ld_Start_DATE                    DATETIME2 = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
  DECLARE @Ln_ExceptionThresholdParm_QNTY NUMERIC(5) =0,
          @Ln_ExceptionThreshold_QNTY     NUMERIC(5) =0,
          @Ln_CommitFreqParm_QNTY         NUMERIC(5) = 0,
          @Ln_CommitFreq_QNTY             NUMERIC(5) = 0,
          @Ln_Topic_IDNO                  NUMERIC(10) = 0,
          @Ln_MemberMci_IDNO              NUMERIC(10),
          @Ln_ProcessedRecordCount_QNTY   NUMERIC(11) = 0,
          @Ln_RowCount_QNTY               NUMERIC(11),
          @Ln_ErrorLine_NUMB              NUMERIC(11),
          @Ln_Error_NUMB                  NUMERIC(11),
          @Ln_AssessTotOverpay_AMNT       NUMERIC(11, 2),
          @Ln_RecTotOverpay_AMNT          NUMERIC(11, 2),
          @Ln_Cursor_QNTY                 NUMERIC(11) = 0,
          @Ln_EventGlobalSeq_NUMB         NUMERIC(19) = 0,
          @Ln_TransactionEventSeq_NUMB    NUMERIC(19),
          @Li_FetchStatus_QNTY            SMALLINT,
          @Lc_BateError_CODE              CHAR(5),
          @Lc_Msg_CODE                    CHAR(5),
          @Lc_Notice_ID                   CHAR(8),
          @Ls_Sql_TEXT                    VARCHAR(100) = '',
          @Ls_Sqldata_TEXT                VARCHAR(1000) = '',
          @Ls_ErrorMessage_TEXT           VARCHAR(4000) = '',
          @Ls_DescriptionError_TEXT       VARCHAR(4000) = '',
          @Ls_BateRecord_TEXT             VARCHAR(4000) = '',
          @Ld_LastRun_DATE                DATE,
          @Ld_Run_DATE                    DATE;
  DECLARE @Ln_RecoupCur_Case_IDNO           NUMERIC(6),
          @Lc_RecoupCur_CheckRecipient_ID   CHAR(10),
          @Lc_RecoupCur_CheckRecipient_CODE CHAR(1),
          @Ld_RecoupCur_AppSigned_DATE      DATE;
  DECLARE @Lc_PoflCur_CheckRecipient_ID   CHAR(10),
          @Lc_PoflCur_CheckRecipient_CODE CHAR(1),
          @Ln_PoflCur_Case_IDNO           NUMERIC(6),
          @Ld_PoflCur_Batch_DATE          DATE,
          @Lc_PoflCur_SourceBatch_CODE    CHAR(3),
          @Ln_PoflCur_Batch_NUMB          NUMERIC(4),
          @Ln_PoflCur_SeqReceipt_NUMB     NUMERIC(6);
  DECLARE @Lc_CpnoCur_CheckRecipient_ID   CHAR(10),
          @Lc_CpnoCur_CheckRecipient_CODE CHAR(1),
          @Ln_CpnoCur_Case_IDNO           NUMERIC(6),
          @Lc_CpnoCur_Notice_ID           CHAR(8),
          @Lc_CpnoCur_TypeCase_CODE       CHAR(1),
          @Ln_CpnoCur_NoticeSeq_NUMB      NUMERIC(1);
  DECLARE @Lc_RecoupActCur_CheckRecipient_ID   CHAR(10),
          @Lc_RecoupActCur_CheckRecipient_CODE CHAR(1),
          @Ln_RecoupActCur_Case_IDNO           NUMERIC(6),
          @Ld_RecoupActCur_Batch_DATE          DATE,
          @Lc_RecoupActCur_SourceBatch_CODE    CHAR(3),
          @Ln_RecoupActCur_Batch_NUMB          NUMERIC(4),
          @Ln_RecoupActCur_SeqReceipt_NUMB     NUMERIC(6),
          @Ln_RecoupActCur_NoticeSeq_NUMB      NUMERIC(1);

  BEGIN TRY
   BEGIN TRANSACTION EXT_PAYMENT;

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;

   EXECUTE BATCH_COMMON$SP_GET_BATCH_DETAILS
    @Ac_Job_ID                  = @Lc_Job_ID,
    @Ad_Run_DATE                = @Ld_Run_DATE OUTPUT,
    @Ad_LastRun_DATE            = @Ld_LastRun_DATE OUTPUT,
    @An_CommitFreq_QNTY         = @Ln_CommitFreqParm_QNTY OUTPUT,
    @An_ExceptionThreshold_QNTY = @Ln_ExceptionThresholdParm_QNTY OUTPUT,
    @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT   = @Ls_ErrorMessage_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'PARM DATE CHECK';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', LastRun_DATE = ' + CAST(@Ld_LastRun_DATE AS VARCHAR);

   /*
       Get the run date and last run date from Parameters (PARM_Y1) table and validate that the batch program 
       was not executed for the run date 
     */
   IF DATEADD(D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'PARM DATE PROBLEM';

     RAISERROR (50001,16,1);
    END;

   -- Select  Restart Key  from  RSTL_Y1                                       
   SET @Ls_Sql_TEXT = 'SELECT RSTL_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   /*
   	 When a receipt is reversed, the system creates 'Pending' recoupment balances for the CPs who has already received 
   	 the disbursement from the collection.   
   If a CP has more than one case, separate notices will be sent for each case to which a reversal was applied. 
   Three attempts will be made to the recipient to get an agreement for repayment of the over disbursement 
    Retrieve recoupment records from Payee Offset Log (POFL_Y1) table to identify receipts which have been reversed since the last run date.
    Exclude recoupments records if the recipient type is for an other party
    Notice should not be generated for Responding cases
    RREP would have created active recoupment for responding cases
    Exclude recoupments records if the recipient is not the CP of the case
   
   */
   
   DECLARE Recoup_Cur INSENSITIVE CURSOR FOR
    SELECT a.Case_IDNO,
           a.CheckRecipient_ID,
           a.CheckRecipient_CODE,
           b.AppSigned_DATE
      FROM (SELECT DISTINCT
                   p.Case_IDNO,
                   p.CheckRecipient_ID,
                   p.CheckRecipient_CODE
              FROM POFL_Y1 p
             WHERE p.Batch_DATE <> @Ld_Low_DATE
               AND p.CheckRecipient_CODE = @Lc_CheckRecipientCpNcp_CODE
               AND p.Transaction_DATE > @Ld_LastRun_DATE
               AND p.PendOffset_AMNT > 0
               AND NOT EXISTS(SELECT 1
                                FROM RECP_Y1 d
                               WHERE d.CheckRecipient_ID = p.CheckRecipient_ID
                                 AND d.CheckRecipient_CODE = p.CheckRecipient_CODE
                                 AND d.CpResponse_INDC = @Lc_Yes_INDC
                                 AND d.EndValidity_DATE = @Ld_High_DATE)) a,
           CASE_Y1 b,
           CMEM_Y1 c
     WHERE b.Case_IDNO = a.Case_IDNO
       AND b.StatusCase_CODE = @Lc_StatusCaseOpen_CODE
       AND c.MemberMci_IDNO = a.CheckRecipient_ID
       AND c.Case_IDNO = a.Case_IDNO
       AND c.CaseRelationship_CODE = @Lc_CaseRelationshipCp_CODE
       AND c.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
       AND NOT EXISTS(SELECT 1
                        FROM CPNO_Y1 e
                       WHERE a.Case_IDNO = e.Case_IDNO
                         AND a.CheckRecipient_CODE = e.CheckRecipient_CODE
                         AND a.CheckRecipient_ID = e.CheckRecipient_ID
                         AND StatusUpdate_DATE = @Ld_High_DATE)
     ORDER BY a.Case_IDNO;

   SET @Ls_Sql_TEXT = 'OPEN Recoup_Cur';
   SET @Ls_Sqldata_TEXT='';

   OPEN Recoup_Cur;

   SET @Ls_Sql_TEXT = 'FETCH Recoup_Cur-1';
   SET @Ls_Sqldata_TEXT='';

   FETCH NEXT FROM Recoup_Cur INTO @Ln_RecoupCur_Case_IDNO, @Lc_RecoupCur_CheckRecipient_ID, @Lc_RecoupCur_CheckRecipient_CODE, @Ld_RecoupCur_AppSigned_DATE;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
   SET @Ls_Sql_TEXT = 'WHILE-1';
   SET @Ls_Sqldata_TEXT='';

   /* FIN-36 */
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
     BEGIN TRY
      SAVE TRANSACTION EXT_PAYMENT_SAVE

      SET @Lc_BateError_CODE = @Lc_BateErrorUnknown_CODE;
      SET @Ls_ErrorMessage_TEXT ='';
      -- Incrementing the commit frequency count
      SET @Ln_CommitFreq_QNTY = @Ln_CommitFreq_QNTY + 1;
      SET @Ln_Cursor_QNTY =@Ln_Cursor_QNTY + 1;
      SET @Ln_AssessTotOverpay_AMNT = 0;
      SET @Ln_RecTotOverpay_AMNT =0;
      SET @Ls_BateRecord_TEXT = ' Case_IDNO = ' + ISNULL(CAST(@Ln_RecoupCur_Case_IDNO AS VARCHAR), '') + ', CheckRecipient_ID = ' + ISNULL(CAST(@Lc_RecoupCur_CheckRecipient_ID AS VARCHAR), '') + ', CheckRecipient_CODE = ' + ISNULL(CAST(@Lc_RecoupCur_CheckRecipient_CODE AS VARCHAR), '') + ', AppSigned_DATE = ' + ISNULL(CAST(@Ld_RecoupCur_AppSigned_DATE AS VARCHAR), '');
      -- Generating the EventGlobalSeq_NUMB
      SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GENERATE_SEQ-1';
      SET @Ls_Sqldata_TEXT = 'EventFunctionalSeq_NUMB = ' + ISNULL (CAST (@Li_CrecActivity2210_NUMB AS VARCHAR), '') + ', Job_ID = ' + ISNULL (@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL (CAST (@Ld_Run_DATE AS VARCHAR), '') + ', No_INDC = ' + @Lc_No_INDC + ', BatchRunUser_TEXT = ' + @Lc_BatchRunUser_TEXT;

      EXECUTE BATCH_COMMON$SP_GENERATE_SEQ
       @An_EventFunctionalSeq_NUMB = @Li_CrecActivity2210_NUMB,
       @Ac_Process_ID              = @Lc_Job_ID,
       @Ad_EffectiveEvent_DATE     = @Ld_Run_DATE,
       @Ac_Note_INDC               = @Lc_No_INDC,
       @Ac_Worker_ID               = @Lc_BatchRunUser_TEXT,
       @An_EventGlobalSeq_NUMB     = @Ln_EventGlobalSeq_NUMB OUTPUT,
       @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
       @As_DescriptionError_TEXT   = @Ls_ErrorMessage_TEXT OUTPUT;

      IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
       BEGIN
        RAISERROR (50001,16,1);
       END

      -- CP has no set recoupment percentage to recoup from his/her disbursements - FIN-36
      SET @Ls_Sql_TEXT = 'Delete @RecipientAddress_P1';
      SET @Ls_Sqldata_TEXT ='';

      DELETE FROM @RecipientAddress_P1;

      SET @Ls_Sql_TEXT = 'BATCH_GEN_NOTICE_UTIL$SP_GET_RECIPIENT_ADDRESS-1';
      SET @Ls_Sqldata_TEXT = 'Notice_ID = ' + ISNULL (@Lc_FirstOverPaymentNotice_ID, '') + ', Recipient_ID = ' + ISNULL (CAST(@Lc_RecoupCur_CheckRecipient_ID AS VARCHAR), '') + ', Recipient CODE = ' + @Lc_CheckReceipientMc_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

      INSERT INTO @RecipientAddress_P1
                  (Line1_ADDR,
                   Line2_ADDR,
                   State_ADDR,
                   City_ADDR,
                   Zip_ADDR,
                   TypeAddress_CODE,
                   Status_CODE,
                   Addr_INDC)
      EXECUTE BATCH_GEN_NOTICE_UTIL$SP_GET_RECIPIENT_ADDRESS
       @Ac_Notice_ID             = @Lc_FirstOverPaymentNotice_ID,
       @Ac_Recipient_ID          = @Lc_RecoupCur_CheckRecipient_ID,
       @Ac_Recipient_CODE        = @Lc_CheckReceipientMc_ID,
       @Ad_Run_DATE              = @Ld_Run_DATE,
       @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
       @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

      IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
       BEGIN
        RAISERROR (50001,16,1);
       END

      IF NOT EXISTS(SELECT 1
                      FROM @RecipientAddress_P1)
       BEGIN
        -- Moving Pending recoupment to Active recoupment for bad address
        -- Cursor to fetch all receipts for recipient
        DECLARE Pofl_CUR INSENSITIVE CURSOR FOR
         SELECT DISTINCT
                a.CheckRecipient_ID,
                a.CheckRecipient_CODE,
                a.Case_IDNO,
                a.Batch_DATE,
                a.SourceBatch_CODE,
                a.Batch_NUMB,
                a.SeqReceipt_NUMB
           FROM POFL_Y1 a
          WHERE a.Case_IDNO = @Ln_RecoupCur_Case_IDNO
            AND a.CheckRecipient_ID = @Lc_RecoupCur_CheckRecipient_ID
            AND a.CheckRecipient_CODE = @Lc_RecoupCur_CheckRecipient_CODE
            AND a.Batch_DATE <> @Ld_Low_DATE
            AND a.Transaction_DATE > @Ld_LastRun_DATE
            AND a.PendOffset_AMNT > 0;

        SET @Ls_Sql_TEXT = 'OPEN Pofl_CUR';
        SET @Ls_Sqldata_TEXT='';

        OPEN Pofl_CUR;

        SET @Ls_Sql_TEXT = 'FETCH Pofl_CUR-1';
        SET @Ls_Sqldata_TEXT='';

        FETCH NEXT FROM Pofl_CUR INTO @Lc_PoflCur_CheckRecipient_ID, @Lc_PoflCur_CheckRecipient_CODE, @Ln_PoflCur_Case_IDNO, @Ld_PoflCur_Batch_DATE, @Lc_PoflCur_SourceBatch_CODE, @Ln_PoflCur_Batch_NUMB, @Ln_PoflCur_SeqReceipt_NUMB;

        SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
        SET @Ls_Sql_TEXT = 'WHILE-2';
        SET @Ls_Sqldata_TEXT = 'CheckRecipient_ID = ' + ISNULL (CAST(@Lc_RecoupCur_CheckRecipient_ID AS VARCHAR), '') + ', CheckRecipient_CODE = ' + ISNULL (@Lc_RecoupCur_CheckRecipient_CODE, '') + ', Case_IDNO = ' + ISNULL (CAST(@Ln_RecoupCur_Case_IDNO AS VARCHAR), '');

        -- Moving Pending recoupment to Active recoupment for bad address
        WHILE @Li_FetchStatus_QNTY = 0
         BEGIN
          SET @Ls_Sql_TEXT = 'BATCH_FIN_CP_RECOUP_NOTICE$SP_SET_RECOUP_ACTIVE-1 ';
          SET @Ls_Sqldata_TEXT = 'CheckRecipient_ID = ' + ISNULL (CAST(@Lc_RecoupCur_CheckRecipient_ID AS VARCHAR), '') + ', CheckRecipient_CODE = ' + ISNULL (@Lc_RecoupCur_CheckRecipient_CODE, '') + ', Case_IDNO = ' + ISNULL (CAST(@Ln_RecoupCur_Case_IDNO AS VARCHAR), '') + ', Batch_DATE = ' + CAST(@Ld_PoflCur_Batch_DATE AS VARCHAR) + ', SourceBatch_CODE = ' + @Lc_PoflCur_SourceBatch_CODE + ', Batch_NUMB = ' + CAST(@Ln_PoflCur_Batch_NUMB AS VARCHAR) + ', SeqReceipt_NUMB = ' + CAST(@Ln_PoflCur_SeqReceipt_NUMB AS VARCHAR) + ', EventGlobalSeq_NUMB = ' + CAST(@Ln_EventGlobalSeq_NUMB AS VARCHAR) + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

          EXECUTE BATCH_FIN_CP_RECOUP_NOTICE$SP_SET_RECOUP_ACTIVE
           @Ac_CheckRecipient_ID     = @Lc_RecoupCur_CheckRecipient_ID,
           @Ac_CheckRecipient_CODE   = @Lc_RecoupCur_CheckRecipient_CODE,
           @An_Case_IDNO             = @Ln_RecoupCur_Case_IDNO,
           @Ad_Batch_DATE            = @Ld_PoflCur_Batch_DATE,
           @Ac_SourceBatch_CODE      = @Lc_PoflCur_SourceBatch_CODE,
           @An_Batch_NUMB            = @Ln_PoflCur_Batch_NUMB,
           @An_SeqReceipt_NUMB       = @Ln_PoflCur_SeqReceipt_NUMB,
           @An_EventGlobalSeq_NUMB   = @Ln_EventGlobalSeq_NUMB,
           @Ad_Run_DATE              = @Ld_Run_DATE,
           @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
           @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

          IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
           BEGIN
            RAISERROR (50001,16,1);
           END

          SET @Ls_Sql_TEXT = 'FETCH Pofl_CUR-2';
          SET @Ls_Sqldata_TEXT='';

          FETCH NEXT FROM Pofl_CUR INTO @Lc_PoflCur_CheckRecipient_ID, @Lc_PoflCur_CheckRecipient_CODE, @Ln_PoflCur_Case_IDNO, @Ld_PoflCur_Batch_DATE, @Lc_PoflCur_SourceBatch_CODE, @Ln_PoflCur_Batch_NUMB, @Ln_PoflCur_SeqReceipt_NUMB;

          SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
         END

        CLOSE Pofl_CUR;

        DEALLOCATE Pofl_CUR;

        SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_ENTITY_MATRIX-1';
        SET @Ls_Sqldata_TEXT = 'EventGlobalSeq_NUMB = ' + ISNULL (CAST (@Ln_EventGlobalSeq_NUMB AS VARCHAR), '') + ', EventFunctionalSeq_NUMB = ' + ISNULL (CAST (@Li_CrecActivity2210_NUMB AS VARCHAR), '') + ', Case_IDNO = ' + ISNULL (CAST(@Ln_RecoupCur_Case_IDNO AS VARCHAR), '') + ', CheckRecipient_ID = ' + ISNULL (CAST(@Lc_RecoupCur_CheckRecipient_ID AS VARCHAR), '') + ', Check Recepient Code = ' + @Lc_RecoupCur_CheckRecipient_CODE;

        EXECUTE BATCH_COMMON$SP_ENTITY_MATRIX
         @An_EventGlobalSeq_NUMB       = @Ln_EventGlobalSeq_NUMB,
         @An_EventFunctionalSeq_NUMB   = @Li_CrecActivity2210_NUMB,
         @An_EntityCase_IDNO           = @Ln_RecoupCur_Case_IDNO,
         @Ac_EntityCheckRecipient_ID   = @Lc_RecoupCur_CheckRecipient_ID,
         @Ac_EntityCheckRecipient_CODE = @Lc_RecoupCur_CheckRecipient_CODE,
         @Ac_Msg_CODE                  = @Lc_Msg_CODE OUTPUT,
         @As_DescriptionError_TEXT     = @Ls_ErrorMessage_TEXT OUTPUT;

        IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
         BEGIN
          RAISERROR (50001,16,1);
         END
       END
      ELSE
       BEGIN
        /*
        For remaining recoupment records where the funds recipient is the CP, send an initial notice (FIN-36 Notice of Overpayment of Support) to the CP listing all the receipts reversed from CP’s IV-D case. 
        FIN-36 is a notice requesting the CP to agree to a definite recoupment percentage
        */
        IF dbo.BATCH_FIN_CP_RECOUP_NOTICE$SF_CALC_RECOUP_AMT (@Lc_RecoupCur_CheckRecipient_ID) > 0
         BEGIN
          SET @Ls_Sql_TEXT = 'BATCH_FIN_CP_RECOUP_NOTICE$SP_INSERT_CPNO -3 ';
          SET @Ls_Sqldata_TEXT = 'CheckRecipient_ID = ' + ISNULL (CAST(@Lc_RecoupCur_CheckRecipient_ID AS VARCHAR), '') + ', CheckRecipient_CODE = ' + ISNULL (@Lc_RecoupCur_CheckRecipient_CODE, '') + ', Case_IDNO = ' + ISNULL (CAST(@Ln_RecoupCur_Case_IDNO AS VARCHAR), '') + ', Notice_ID = ' + ISNULL (@Lc_FirstOverPaymentNotice_ID, '') + ', FirstOverPaymentNotice_ID = ' + @Lc_FirstOverPaymentNotice_ID + ', NoticeSeq_NUMB = ' + CAST(@Ln_NoticeSeq_NUMB AS VARCHAR) + ', AppSigned_DATE = ' + CAST(@Ld_RecoupCur_AppSigned_DATE AS VARCHAR) + ', EventGlobalSeq_NUMB = ' + CAST(@Ln_EventGlobalSeq_NUMB AS VARCHAR) + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', LastRun_DATE = ' + CAST(@Ld_LastRun_DATE AS VARCHAR);

          EXECUTE BATCH_FIN_CP_RECOUP_NOTICE$SP_INSERT_CPNO
           @Ac_CheckRecipient_ID     = @Lc_RecoupCur_CheckRecipient_ID,
           @Ac_CheckRecipient_CODE   = @Lc_RecoupCur_CheckRecipient_CODE,
           @An_Case_IDNO             = @Ln_RecoupCur_Case_IDNO,
           @Ac_Notice_ID             = @Lc_FirstOverPaymentNotice_ID,
           @An_NoticeSeq_NUMB        = @Ln_NoticeSeq_NUMB,
           @Ad_AppSigned_DATE        = @Ld_RecoupCur_AppSigned_DATE,
           @An_EventGlobalSeq_NUMB   = @Ln_EventGlobalSeq_NUMB,
           @Ad_Run_DATE              = @Ld_Run_DATE,
           @Ad_LastRun_DATE			 = @Ld_LastRun_DATE,
           @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
           @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

          IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
           BEGIN
            RAISERROR (50001,16,1);
           END
			
          SET @Ls_Sql_TEXT ='BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT-3';
          SET @Ls_Sqldata_TEXT = 'EventFunctionalSeq_NUMB = ' + ISNULL (CAST (@Li_CrecActivity2210_NUMB AS VARCHAR), '') + ', Job_ID = ' + ISNULL (@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL (CAST (@Ld_Run_DATE AS VARCHAR), '') + ', No_INDC = ' + @Lc_No_INDC + ', BatchRunUser_TEXT = ' + @Lc_BatchRunUser_TEXT;

          EXECUTE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
           @An_EventFunctionalSeq_NUMB  = @Li_CrecActivity2210_NUMB,
           @Ac_Process_ID               = @Lc_Job_ID,
           @Ad_EffectiveEvent_DATE      = @Ld_Run_DATE,
           @Ac_Note_INDC                = @Lc_No_INDC,
           @Ac_Worker_ID                = @Lc_BatchRunUser_TEXT,
           @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
           @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
           @As_DescriptionError_TEXT    = @Ls_ErrorMessage_TEXT OUTPUT;

          IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
           BEGIN
            RAISERROR (50001,16,1);
           END

          SET @Ls_Sql_TEXT = ' BATCH_COMMON$SP_INSERT_ACTIVITY-3 ';
          SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL (CAST(@Ln_RecoupCur_Case_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL (CAST (@Lc_RecoupCur_CheckRecipient_ID AS VARCHAR), '') + ', CheckRecipient_CODE = ' + ISNULL (@Lc_RecoupCur_CheckRecipient_CODE, '') + ', Notice_ID = ' + ISNULL (@Lc_FirstOverPaymentNotice_ID, '') + ', Transaction Seq = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', MemberMci_IDNO = ' + CAST(@Ln_MemberMci_IDNO AS VARCHAR) + ', MajorActivityCase_CODE = ' + @Lc_MajorActivityCase_CODE + ', ActivityMinor_CODE = ' + @Lc_ActivityMinor_CODE + ', Subsystem_CODE = ' + @Lc_Subsystem_CODE + ', TransactionEventSeq_NUMB = ' + CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR) + ', BatchRunUser_TEXT = ' + @Lc_BatchRunUser_TEXT + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', FirstOverPaymentNotice_ID = ' + @Lc_FirstOverPaymentNotice_ID + ', Job_ID = ' + @Lc_Job_ID;
          SET @Ln_MemberMci_IDNO =CAST(@Lc_RecoupCur_CheckRecipient_ID AS NUMERIC(10));

          EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
           @An_Case_IDNO                = @Ln_RecoupCur_Case_IDNO,
           @An_MemberMci_IDNO           = @Ln_MemberMci_IDNO,
           @Ac_ActivityMajor_CODE       = @Lc_MajorActivityCase_CODE,
           @Ac_ActivityMinor_CODE       = @Lc_ActivityMinor_CODE,
           @Ac_Subsystem_CODE           = @Lc_Subsystem_CODE,
           @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
           @Ac_WorkerUpdate_ID          = @Lc_BatchRunUser_TEXT,
           @Ad_Run_DATE                 = @Ld_Run_DATE,
           @Ac_Notice_ID                = @Lc_FirstOverPaymentNotice_ID,
           @Ac_Job_ID                   = @Lc_Job_ID,
           @An_Topic_IDNO               = @Ln_Topic_IDNO OUTPUT,
           @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
           @As_DescriptionError_TEXT    = @Ls_ErrorMessage_TEXT OUTPUT;

          IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
           BEGIN
            SET @Lc_BateError_CODE = @Lc_BateErrorUnknown_CODE;

            RAISERROR (50001,16,1);
           END
          ELSE IF @Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
           BEGIN
            SET @Lc_BateError_CODE = @Lc_Msg_CODE;

            RAISERROR (50001,16,1);
           END
           
         END
       END
     END TRY

     BEGIN CATCH
      IF XACT_STATE() = 1
       BEGIN
        ROLLBACK TRANSACTION EXT_PAYMENT_SAVE
       END
      ELSE
       BEGIN
        SET @Ls_ErrorMessage_TEXT =@Ls_ErrorMessage_TEXT + ' ' + SUBSTRING (ERROR_MESSAGE (), 1, 200);

        RAISERROR( 50001,16,1);
       END

      SET @Ln_Error_NUMB = ERROR_NUMBER();
      SET @Ln_ErrorLine_NUMB = ERROR_LINE();

      IF @Ln_Error_NUMB <> 50001
       BEGIN
        SET @Lc_BateError_CODE = @Lc_BateErrorUnknown_CODE;
        SET @Ls_ErrorMessage_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
       END

      EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
       @As_Procedure_NAME        = @Ls_Procedure_NAME,
       @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
       @As_Sql_TEXT              = @Ls_Sql_TEXT,
       @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
       @An_Error_NUMB            = @Ln_Error_NUMB,
       @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
       @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

      SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG - 1';
      SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + @Ls_Process_NAME + ', Procedure_NAME = ' + @Ls_Procedure_NAME + ', Job_ID = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', Cursor_QNTY = ' + CAST(@Ln_Cursor_QNTY AS VARCHAR) + ', BateError_CODE = ' + @Lc_BateError_CODE + ', ErrorMessage_TEXT = ' + @Ls_ErrorMessage_TEXT + ', BateRecord_TEXT = ' + @Ls_BateRecord_TEXT;

      EXECUTE BATCH_COMMON$SP_BATE_LOG
       @As_Process_NAME             = @Ls_Process_NAME,
       @As_Procedure_NAME           = @Ls_Procedure_NAME,
       @Ac_Job_ID                   = @Lc_Job_ID,
       @Ad_Run_DATE                 = @Ld_Run_DATE,
       @Ac_TypeError_CODE           = @Lc_TypeErrorE_CODE,
       @An_Line_NUMB                = @Ln_Cursor_QNTY,
       @Ac_Error_CODE               = @Lc_BateError_CODE,
       @As_DescriptionError_TEXT    = @Ls_ErrorMessage_TEXT,
       @As_ListKey_TEXT             = @Ls_BateRecord_TEXT,
       @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
       @As_DescriptionErrorOut_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

      IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
       BEGIN
        RAISERROR (50001,16,1);
       END

      IF @Lc_Msg_CODE = @Lc_TypeErrorE_CODE
       BEGIN
        SET @Ln_ExceptionThreshold_QNTY = @Ln_ExceptionThreshold_QNTY + 1;
       END
     END CATCH

     -- If the commit frequency is attained, the following is done. Reset the commit count, Commit the transaction completed until now.
     IF @Ln_CommitFreqParm_QNTY <> 0
        AND @Ln_CommitFreq_QNTY = @Ln_CommitFreqParm_QNTY
      BEGIN
       COMMIT TRANSACTION EXT_PAYMENT;

       BEGIN TRANSACTION EXT_PAYMENT;

       SET @Ln_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY + @Ln_CommitFreq_QNTY;
       SET @Ln_CommitFreq_QNTY = 0;
      END;

     SET @Ls_Sql_TEXT = 'ExceptionThreshold Check -1';
     SET @Ls_Sqldata_TEXT ='ExceptionThreshold_QNTY = ' + CAST(@Ln_ExceptionThreshold_QNTY AS VARCHAR) + ', ExceptionThresholdParm_QNTY = ' + CAST(@Ln_ExceptionThresholdParm_QNTY AS VARCHAR);

     IF @Ln_ExceptionThreshold_QNTY > @Ln_ExceptionThresholdParm_QNTY
      BEGIN
       COMMIT TRANSACTION EXT_PAYMENT;

       SET @Ln_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY + @Ln_CommitFreq_QNTY;
       SET @Ls_ErrorMessage_TEXT = 'REACHED EXCEPTION THRESHOLD';

       RAISERROR (50001,16,1);
      END

     SET @Ls_Sql_TEXT = 'FETCH Recoup_Cur-2';
     SET @Ls_Sqldata_TEXT = 'Cursor Previous Record = ' + SUBSTRING(@Ls_BateRecord_TEXT, 1, 970);

     FETCH NEXT FROM Recoup_Cur INTO @Ln_RecoupCur_Case_IDNO, @Lc_RecoupCur_CheckRecipient_ID, @Lc_RecoupCur_CheckRecipient_CODE, @Ld_RecoupCur_AppSigned_DATE;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END

   CLOSE Recoup_Cur;

   DEALLOCATE Recoup_Cur;

   IF @Ln_CommitFreqParm_QNTY <> 0
    BEGIN
     COMMIT TRANSACTION EXT_PAYMENT;

     BEGIN TRANSACTION EXT_PAYMENT;

     SET @Ln_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY + @Ln_CommitFreq_QNTY;
     SET @Ln_CommitFreq_QNTY = 0;
    END

   /* Cursor to fetch all CPs, where there is no response for
   the notice FIN-36, FIN-37 and FIN-38 
   
   If the CP does not respond to the first notice (FIN-36), and 30 calendar days have elapsed, on the 31st day from 
   the generation of FIN-36, the system will generate the second notice (FIN-37 Second Notice of Overpayment of Support)
   reminding the CP to respond to the notice.
   */
   DECLARE Cpno_CUR INSENSITIVE CURSOR FOR
    SELECT DISTINCT
           a.CheckRecipient_ID,
           a.CheckRecipient_CODE,
           a.Case_IDNO,
           a.Notice_ID,
           c.TypeCase_CODE,
           a.NoticeSeq_NUMB
      FROM CPNO_Y1 a,
           CASE_Y1 c
     WHERE c.Case_IDNO = a.Case_IDNO
       AND a.StatusUpdate_DATE = @Ld_High_DATE
       AND DATEDIFF(DAY, a.Notice_DATE, @Ld_Run_DATE) > @Ln_WaitForResponce_NUMB
     ORDER BY a.Case_IDNO;

   SET @Ls_Sql_TEXT = 'OPEN Cpno_CUR';
   SET @Ls_Sqldata_TEXT ='';

   OPEN Cpno_CUR;

   SET @Ls_Sql_TEXT = 'FETCH Cpno_CUR-1';
   SET @Ls_Sqldata_TEXT ='';

   FETCH NEXT FROM Cpno_CUR INTO @Lc_CpnoCur_CheckRecipient_ID, @Lc_CpnoCur_CheckRecipient_CODE, @Ln_CpnoCur_Case_IDNO, @Lc_CpnoCur_Notice_ID, @Lc_CpnoCur_TypeCase_CODE, @Ln_CpnoCur_NoticeSeq_NUMB;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
   SET @Ls_Sql_TEXT = 'WHILE-3';
   SET @Ls_Sqldata_TEXT = 'EventFunctionalSeq_NUMB = ' + ISNULL (CAST (@Li_CrecActivity2210_NUMB AS VARCHAR), '') + ', Job_ID = ' + ISNULL (@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL (CAST (@Ld_Run_DATE AS VARCHAR), '');

   --notice FIN-36, FIN-37 and FIN-38 
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
     BEGIN TRY
      SAVE TRANSACTION EXT_PAYMENT_SAVE

      SET @Lc_BateError_CODE = @Lc_BateErrorUnknown_CODE;
      SET @Ls_ErrorMessage_TEXT = '';
      SET @Ln_CommitFreq_QNTY = @Ln_CommitFreq_QNTY + 1;
      SET @Ln_Cursor_QNTY = @Ln_Cursor_QNTY + 1;
      SET @Ls_BateRecord_TEXT = 'CheckRecipient_ID = ' + ISNULL(CAST(@Lc_CpnoCur_CheckRecipient_ID AS VARCHAR), '') + ', CheckRecipient_CODE = ' + ISNULL(CAST(@Lc_CpnoCur_CheckRecipient_CODE AS VARCHAR), '') + ', Case_IDNO = ' + ISNULL(CAST(@Ln_CpnoCur_Case_IDNO AS VARCHAR), '') + ', Notice_ID = ' + ISNULL(CAST(@Lc_CpnoCur_Notice_ID AS VARCHAR), '') + ', TypeCase_CODE = ' + ISNULL(CAST(@Lc_CpnoCur_TypeCase_CODE AS VARCHAR), '') + ', NoticeSeq_NUMB = ' + ISNULL(CAST(@Ln_CpnoCur_NoticeSeq_NUMB AS VARCHAR), '');
      SET @Ls_Sql_TEXT = ' BATCH_COMMON$SP_GENERATE_SEQ-2 ';
      SET @Ls_Sqldata_TEXT = 'EventFunctionalSeq_NUMB = ' + ISNULL (CAST (@Li_CrecActivity2210_NUMB AS VARCHAR), '') + ', Job_ID = ' + ISNULL (@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL (CAST (@Ld_Run_DATE AS VARCHAR), '') + ', No_INDC = ' + @Lc_No_INDC + ', BatchRunUser_TEXT = ' + @Lc_BatchRunUser_TEXT;

      EXECUTE BATCH_COMMON$SP_GENERATE_SEQ
       @An_EventFunctionalSeq_NUMB = @Li_CrecActivity2210_NUMB,
       @Ac_Process_ID              = @Lc_Job_ID,
       @Ad_EffectiveEvent_DATE     = @Ld_Run_DATE,
       @Ac_Note_INDC               = @Lc_No_INDC,
       @Ac_Worker_ID               = @Lc_BatchRunUser_TEXT,
       @An_EventGlobalSeq_NUMB     = @Ln_EventGlobalSeq_NUMB OUTPUT,
       @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
       @As_DescriptionError_TEXT   = @Ls_ErrorMessage_TEXT OUTPUT;

      IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
       BEGIN
        RAISERROR (50001,16,1);
       END

      /*
      If the case type is changed to Non-IV-D, then the pending recoupment balances will be moved to active recoupment 
      for the given Case ID.
      */
      IF @Lc_CpnoCur_TypeCase_CODE = @Lc_TypeCaseNonIvd_CODE
       BEGIN
        -- Cursor to fetch all receipts for recipient
        DECLARE RecoupAct_CUR INSENSITIVE CURSOR FOR
         SELECT a.CheckRecipient_ID,
                a.CheckRecipient_CODE,
                a.Case_IDNO,
                a.Batch_DATE,
                a.SourceBatch_CODE,
                a.Batch_NUMB,
                a.SeqReceipt_NUMB,
                a.NoticeSeq_NUMB
           FROM CPNO_Y1 a
          WHERE a.Case_IDNO = @Ln_CpnoCur_Case_IDNO
            AND a.CheckRecipient_ID = @Lc_CpnoCur_CheckRecipient_ID
            AND a.CheckRecipient_CODE = @Lc_CpnoCur_CheckRecipient_CODE
            AND a.StatusUpdate_DATE = @Ld_High_DATE;

        SET @Ls_Sql_TEXT = 'OPEN RecoupAct_CUR';
        SET @Ls_Sqldata_TEXT ='';

        OPEN RecoupAct_CUR;

        SET @Ls_Sql_TEXT = 'FETCH RecoupAct_CUR-1';
        SET @Ls_Sqldata_TEXT ='';

        FETCH NEXT FROM RecoupAct_CUR INTO @Lc_RecoupActCur_CheckRecipient_ID, @Lc_RecoupActCur_CheckRecipient_CODE, @Ln_RecoupActCur_Case_IDNO, @Ld_RecoupActCur_Batch_DATE, @Lc_RecoupActCur_SourceBatch_CODE, @Ln_RecoupActCur_Batch_NUMB, @Ln_RecoupActCur_SeqReceipt_NUMB, @Ln_RecoupActCur_NoticeSeq_NUMB;

        SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
        SET @Ls_Sql_TEXT = 'WHILE-4';
        SET @Ls_Sqldata_TEXT = 'CheckRecipient_ID = ' + ISNULL (CAST(@Lc_RecoupActCur_CheckRecipient_ID AS VARCHAR), '') + ', CheckRecipient_CODE = ' + ISNULL (@Lc_RecoupActCur_CheckRecipient_CODE, '') + ', Case_IDNO = ' + ISNULL (CAST(@Ln_RecoupActCur_Case_IDNO AS VARCHAR), '');

        --Non-IV-D
        WHILE @Li_FetchStatus_QNTY = 0
         BEGIN
          SET @Ls_Sql_TEXT = ' BATCH_FIN_CP_RECOUP_NOTICE$SP_SET_RECOUP_ACTIVE-2';
          SET @Ls_Sqldata_TEXT = 'CheckRecipient_ID = ' + ISNULL (CAST(@Lc_RecoupActCur_CheckRecipient_ID AS VARCHAR), '') + ', CheckRecipient_CODE = ' + ISNULL (@Lc_RecoupActCur_CheckRecipient_CODE, '') + ', Case_IDNO = ' + ISNULL (CAST(@Ln_RecoupActCur_Case_IDNO AS VARCHAR), '') + ', RecoupActCur_Batch_DATE = ' + CAST(@Ld_RecoupActCur_Batch_DATE AS VARCHAR) + ', RecoupActCur_SourceBatch_CODE = ' + @Lc_RecoupActCur_SourceBatch_CODE + ', Ln_RecoupActCur_Batch_NUMB = ' + CAST(@Ln_RecoupActCur_Batch_NUMB AS VARCHAR) + ', SeqReceipt_NUMB = ' + CAST(@Ln_RecoupActCur_SeqReceipt_NUMB AS VARCHAR) + ', EventGlobalSeq_NUMB = ' + CAST(@Ln_EventGlobalSeq_NUMB AS VARCHAR) + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

          EXECUTE BATCH_FIN_CP_RECOUP_NOTICE$SP_SET_RECOUP_ACTIVE
           @Ac_CheckRecipient_ID     = @Lc_RecoupActCur_CheckRecipient_ID,
           @Ac_CheckRecipient_CODE   = @Lc_RecoupActCur_CheckRecipient_CODE,
           @An_Case_IDNO             = @Ln_RecoupActCur_Case_IDNO,
           @Ad_Batch_DATE            = @Ld_RecoupActCur_Batch_DATE,
           @Ac_SourceBatch_CODE      = @Lc_RecoupActCur_SourceBatch_CODE,
           @An_Batch_NUMB            = @Ln_RecoupActCur_Batch_NUMB,
           @An_SeqReceipt_NUMB       = @Ln_RecoupActCur_SeqReceipt_NUMB,
           @An_EventGlobalSeq_NUMB   = @Ln_EventGlobalSeq_NUMB,
           @Ad_Run_DATE              = @Ld_Run_DATE,
           @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
           @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

          IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
           BEGIN
            RAISERROR (50001,16,1);
           END

          SET @Ls_Sql_TEXT = 'UPDATE_CPNO_Y1 CALL18 ';
          SET @Ls_Sqldata_TEXT = 'CheckRecipient_ID = ' + ISNULL (CAST(@Lc_CpnoCur_CheckRecipient_ID AS VARCHAR), '') + ', CheckRecipient_CODE = ' + ISNULL (@Lc_CpnoCur_CheckRecipient_CODE, '') + ', Case_IDNO = ' + ISNULL (CAST(@Ln_CpnoCur_Case_IDNO AS VARCHAR), '') + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', EventGlobalSeq_NUMB = ' + CAST(@Ln_EventGlobalSeq_NUMB AS VARCHAR) + ', Batch_DATE = ' + CAST(@Ld_RecoupActCur_Batch_DATE AS VARCHAR) + ', SourceBatch_CODE = ' + @Lc_RecoupActCur_SourceBatch_CODE + ', RecoupActCur_Batch_NUMB = ' + CAST(@Ln_RecoupActCur_Batch_NUMB AS VARCHAR) + ', SeqReceipt_NUMB = ' + CAST(@Ln_RecoupActCur_SeqReceipt_NUMB AS VARCHAR) + ', RecoupActCur_NoticeSeq_NUMB = ' + CAST(@Ln_RecoupActCur_NoticeSeq_NUMB AS VARCHAR) + ', CheckRecipient_ID = ' + @Lc_RecoupActCur_CheckRecipient_ID + ', CheckRecipient_CODE = ' + @Lc_RecoupActCur_CheckRecipient_CODE + ', Case_IDNO = ' + CAST(@Ln_RecoupActCur_Case_IDNO AS VARCHAR);

          UPDATE CPNO_Y1
             SET StatusUpdate_DATE = @Ld_Run_DATE,
                 EventGlobalUpdateSeq_NUMB = @Ln_EventGlobalSeq_NUMB
           WHERE CheckRecipient_ID = @Lc_RecoupActCur_CheckRecipient_ID
             AND CheckRecipient_CODE = @Lc_RecoupActCur_CheckRecipient_CODE
             AND Case_IDNO = @Ln_RecoupActCur_Case_IDNO
             AND Batch_DATE = @Ld_RecoupActCur_Batch_DATE
             AND SourceBatch_CODE = @Lc_RecoupActCur_SourceBatch_CODE
             AND Batch_NUMB = @Ln_RecoupActCur_Batch_NUMB
             AND SeqReceipt_NUMB = @Ln_RecoupActCur_SeqReceipt_NUMB
             AND NoticeSeq_NUMB = @Ln_RecoupActCur_NoticeSeq_NUMB;

          SET @Ln_RowCount_QNTY = @@ROWCOUNT;

          IF @Ln_RowCount_QNTY = 0
           BEGIN
            SET @Ls_ErrorMessage_TEXT = @Lc_Err0002_TEXT;

            RAISERROR (50001,16,1);
           END

          SET @Ls_Sql_TEXT = 'FETCH RecoupAct_CUR -2';
          SET @Ls_Sqldata_TEXT = '';

          FETCH NEXT FROM RecoupAct_CUR INTO @Lc_RecoupActCur_CheckRecipient_ID, @Lc_RecoupActCur_CheckRecipient_CODE, @Ln_RecoupActCur_Case_IDNO, @Ld_RecoupActCur_Batch_DATE, @Lc_RecoupActCur_SourceBatch_CODE, @Ln_RecoupActCur_Batch_NUMB, @Ln_RecoupActCur_SeqReceipt_NUMB, @Ln_RecoupActCur_NoticeSeq_NUMB;

          SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
         END

        CLOSE RecoupAct_CUR;

        DEALLOCATE RecoupAct_CUR;

        SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_ENTITY_MATRIX-2';
        SET @Ls_Sqldata_TEXT = 'EventGlobalSeq_NUMB = ' + ISNULL (CAST (@Ln_EventGlobalSeq_NUMB AS VARCHAR), '') + ', EventFunctionalSeq_NUMB = ' + ISNULL (CAST (@Li_CrecActivity2210_NUMB AS VARCHAR), '') + ', Case_IDNO = ' + ISNULL (CAST(@Ln_CpnoCur_Case_IDNO AS VARCHAR), '') + ', CheckRecipient_ID = ' + ISNULL (CAST(@Lc_CpnoCur_CheckRecipient_ID AS VARCHAR), '') + ', Check Recipient Code = ' + @Lc_CpnoCur_CheckRecipient_CODE;

        EXECUTE BATCH_COMMON$SP_ENTITY_MATRIX
         @An_EventGlobalSeq_NUMB       = @Ln_EventGlobalSeq_NUMB,
         @An_EventFunctionalSeq_NUMB   = @Li_CrecActivity2210_NUMB,
         @An_EntityCase_IDNO           = @Ln_CpnoCur_Case_IDNO,
         @Ac_EntityCheckRecipient_ID   = @Lc_CpnoCur_CheckRecipient_ID,
         @Ac_EntityCheckRecipient_CODE = @Lc_CpnoCur_CheckRecipient_CODE,
         @Ac_Msg_CODE                  = @Lc_Msg_CODE OUTPUT,
         @As_DescriptionError_TEXT     = @Ls_ErrorMessage_TEXT OUTPUT;

        IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
         BEGIN
          RAISERROR (50001,16,1);
         END
       END -- Non-IV-D
      ELSE
       BEGIN
        IF @Lc_CpnoCur_Notice_ID = @Lc_FirstOverPaymentNotice_ID
         BEGIN
          SET @Lc_Notice_ID = @Lc_SecondOverPaymentNotice_ID;
         END
        ELSE IF @Lc_CpnoCur_Notice_ID = @Lc_SecondOverPaymentNotice_ID
         BEGIN
          SET @Lc_Notice_ID = @Lc_FinalOverPaymentNotice_ID;
         END
        ELSE IF @Lc_CpnoCur_Notice_ID = @Lc_FinalOverPaymentNotice_ID
         BEGIN
          SET @Lc_Notice_ID = @Lc_Space_TEXT;
         END

        SET @Ls_Sql_TEXT = 'Delete @RecipientAddress_P1 2';
        SET @Ls_Sqldata_TEXT ='';

        DELETE FROM @RecipientAddress_P1;

        SET @Ls_Sql_TEXT = 'BATCH_GEN_NOTICE_UTIL$SP_GET_RECIPIENT_ADDRESS-2';
        SET @Ls_Sqldata_TEXT = 'Notice_ID = ' + ISNULL (@Lc_Notice_ID, '') + ', Recipient_ID = ' + ISNULL (CAST(@Lc_CpnoCur_CheckRecipient_ID AS VARCHAR), '') + ', Recipient CODE = ' + @Lc_CheckReceipientMc_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

        INSERT INTO @RecipientAddress_P1
                    (Line1_ADDR,
                     Line2_ADDR,
                     State_ADDR,
                     City_ADDR,
                     Zip_ADDR,
                     TypeAddress_CODE,
                     Status_CODE,
                     Addr_INDC)
        EXECUTE BATCH_GEN_NOTICE_UTIL$SP_GET_RECIPIENT_ADDRESS
         @Ac_Notice_ID             = @Lc_Notice_ID,
         @Ac_Recipient_ID          = @Lc_CpnoCur_CheckRecipient_ID,
         @Ac_Recipient_CODE        = @Lc_CheckReceipientMc_ID,
         @Ad_Run_DATE              = @Ld_Run_DATE,
         @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
         @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

        IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
         BEGIN
          RAISERROR (50001,16,1);
         END

        /*
        If no address is available as per the address hierarchy for the CP for FIN-36, FIN-37 or FIN-38 
         the pending recoupment relating to the receipts identified will immediately be moved to active recoupment, 
         and the recoupment percentage will be either what currently exists in the percentage field or if blank, set 
         to 10% and will be recouped from future disbursements.
        */
        IF NOT EXISTS(SELECT 1
                        FROM @RecipientAddress_P1)
         BEGIN
          DECLARE RecoupAct_CUR INSENSITIVE CURSOR FOR
           SELECT a.CheckRecipient_ID,
                  a.CheckRecipient_CODE,
                  a.Case_IDNO,
                  a.Batch_DATE,
                  a.SourceBatch_CODE,
                  a.Batch_NUMB,
                  a.SeqReceipt_NUMB,
                  a.NoticeSeq_NUMB
             FROM CPNO_Y1 a
            WHERE a.Case_IDNO = @Ln_CpnoCur_Case_IDNO
              AND a.CheckRecipient_ID = @Lc_CpnoCur_CheckRecipient_ID
              AND a.CheckRecipient_CODE = @Lc_CpnoCur_CheckRecipient_CODE
              AND a.StatusUpdate_DATE = @Ld_High_DATE;

          SET @Ls_Sql_TEXT = 'OPEN RecoupAct_CUR -2';
          SET @Ls_Sqldata_TEXT = '';

          OPEN RecoupAct_CUR;

          SET @Ls_Sql_TEXT = 'FETCH RecoupAct_CUR-3';
          SET @Ls_Sqldata_TEXT = '';

          FETCH NEXT FROM RecoupAct_CUR INTO @Lc_RecoupActCur_CheckRecipient_ID, @Lc_RecoupActCur_CheckRecipient_CODE, @Ln_RecoupActCur_Case_IDNO, @Ld_RecoupActCur_Batch_DATE, @Lc_RecoupActCur_SourceBatch_CODE, @Ln_RecoupActCur_Batch_NUMB, @Ln_RecoupActCur_SeqReceipt_NUMB, @Ln_RecoupActCur_NoticeSeq_NUMB;

          SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
          SET @Ls_Sql_TEXT = 'WHILE-5';
          SET @Ls_Sqldata_TEXT = 'CheckRecipient_ID = ' + ISNULL (CAST(@Lc_RecoupActCur_CheckRecipient_ID AS VARCHAR), '') + ', Case_IDNO = ' + ISNULL (CAST(@Ln_RecoupActCur_Case_IDNO AS VARCHAR), '');

          --Address not avaliable
          WHILE @Li_FetchStatus_QNTY = 0
           BEGIN
            SET @Ls_Sql_TEXT = 'BATCH_FIN_CP_RECOUP_NOTICE$SP_SET_RECOUP_ACTIVE-3';
            SET @Ls_Sqldata_TEXT = 'CheckRecipient_ID = ' + ISNULL (CAST(@Lc_RecoupActCur_CheckRecipient_ID AS VARCHAR), '') + ', Case_IDNO = ' + ISNULL (CAST(@Ln_RecoupActCur_Case_IDNO AS VARCHAR), '') + ', CheckRecipient_CODE = ' + @Lc_RecoupActCur_CheckRecipient_CODE + ', Batch_DATE = ' + CAST(@Ld_RecoupActCur_Batch_DATE AS VARCHAR) + ', SourceBatch_CODE = ' + @Lc_RecoupActCur_SourceBatch_CODE + ', @Ln_RecoupActCur_Batch_NUMB = ' + CAST(@Ln_RecoupActCur_Batch_NUMB AS VARCHAR) + ', SeqReceipt_NUMB = ' +CAST( @Ln_RecoupActCur_SeqReceipt_NUMB AS VARCHAR) + ', EventGlobalSeq_NUMB = ' + CAST(@Ln_EventGlobalSeq_NUMB AS VARCHAR) + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

            EXECUTE BATCH_FIN_CP_RECOUP_NOTICE$SP_SET_RECOUP_ACTIVE
             @Ac_CheckRecipient_ID     = @Lc_RecoupActCur_CheckRecipient_ID,
             @Ac_CheckRecipient_CODE   = @Lc_RecoupActCur_CheckRecipient_CODE,
             @An_Case_IDNO             = @Ln_RecoupActCur_Case_IDNO,
             @Ad_Batch_DATE            = @Ld_RecoupActCur_Batch_DATE,
             @Ac_SourceBatch_CODE      = @Lc_RecoupActCur_SourceBatch_CODE,
             @An_Batch_NUMB            = @Ln_RecoupActCur_Batch_NUMB,
             @An_SeqReceipt_NUMB       = @Ln_RecoupActCur_SeqReceipt_NUMB,
             @An_EventGlobalSeq_NUMB   = @Ln_EventGlobalSeq_NUMB,
             @Ad_Run_DATE              = @Ld_Run_DATE,
             @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
             @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

            IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
             BEGIN
              RAISERROR (50001,16,1);
             END;

            SET @Ls_Sql_TEXT = 'UPDATE_CPNO-1';
            SET @Ls_Sqldata_TEXT = ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', EventGlobalSeq_NUMB = ' + CAST(@Ln_EventGlobalSeq_NUMB AS VARCHAR) + ', CheckRecipient_ID = ' + @Lc_RecoupActCur_CheckRecipient_ID + ', CheckRecipient_CODE = ' + @Lc_RecoupActCur_CheckRecipient_CODE + ', Case_IDNO' + CAST(@Ln_RecoupActCur_Case_IDNO AS VARCHAR) + ', Batch_DATE = ' + CAST(@Ld_RecoupActCur_Batch_DATE AS VARCHAR) + ', SourceBatch_CODE = ' + @Lc_RecoupActCur_SourceBatch_CODE + ', Batch_NUMB = ' + CAST(@Ln_RecoupActCur_Batch_NUMB AS VARCHAR) + ', SeqReceipt_NUMB = ' + CAST(@Ln_RecoupActCur_SeqReceipt_NUMB AS VARCHAR) + ', NoticeSeq_NUMB = ' + CAST(@Ln_RecoupActCur_NoticeSeq_NUMB AS VARCHAR);

            UPDATE CPNO_Y1
               SET StatusUpdate_DATE = @Ld_Run_DATE,
                   EventGlobalUpdateSeq_NUMB = @Ln_EventGlobalSeq_NUMB
             WHERE CheckRecipient_ID = @Lc_RecoupActCur_CheckRecipient_ID
               AND CheckRecipient_CODE = @Lc_RecoupActCur_CheckRecipient_CODE
               AND Case_IDNO = @Ln_RecoupActCur_Case_IDNO
               AND Batch_DATE = @Ld_RecoupActCur_Batch_DATE
               AND SourceBatch_CODE = @Lc_RecoupActCur_SourceBatch_CODE
               AND Batch_NUMB = @Ln_RecoupActCur_Batch_NUMB
               AND SeqReceipt_NUMB = @Ln_RecoupActCur_SeqReceipt_NUMB
               AND NoticeSeq_NUMB = @Ln_RecoupActCur_NoticeSeq_NUMB;

            SET @Ln_RowCount_QNTY = @@ROWCOUNT;

            IF @Ln_RowCount_QNTY = 0
             BEGIN
              SET @Ls_ErrorMessage_TEXT = @Lc_Err0002_TEXT;

              RAISERROR (50001,16,1);
             END

            SET @Ls_Sql_TEXT = 'FETCH RecoupAct_CUR-4';
            SET @Ls_Sqldata_TEXT = '';

            FETCH NEXT FROM RecoupAct_CUR INTO @Lc_RecoupActCur_CheckRecipient_ID, @Lc_RecoupActCur_CheckRecipient_CODE, @Ln_RecoupActCur_Case_IDNO, @Ld_RecoupActCur_Batch_DATE, @Lc_RecoupActCur_SourceBatch_CODE, @Ln_RecoupActCur_Batch_NUMB, @Ln_RecoupActCur_SeqReceipt_NUMB, @Ln_RecoupActCur_NoticeSeq_NUMB;

            SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
           END

          CLOSE RecoupAct_CUR;

          DEALLOCATE RecoupAct_CUR;

          SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_ENTITY_MATRIX-3';
          SET @Ls_Sqldata_TEXT = 'EventGlobalSeq_NUMB = ' + ISNULL (CAST (@Ln_EventGlobalSeq_NUMB AS VARCHAR), '') + ', EventFunctionalSeq_NUMB = ' + ISNULL (CAST (@Li_CrecActivity2210_NUMB AS VARCHAR), '') + ', Case_IDNO = ' + ISNULL (CAST(@Ln_CpnoCur_Case_IDNO AS VARCHAR), '') + ', CheckRecipient_ID = ' + ISNULL (CAST(@Lc_CpnoCur_CheckRecipient_ID AS VARCHAR), '') + ', Check Recipient Code = ' + @Lc_CpnoCur_CheckRecipient_CODE;

          EXECUTE BATCH_COMMON$SP_ENTITY_MATRIX
           @An_EventGlobalSeq_NUMB       = @Ln_EventGlobalSeq_NUMB,
           @An_EventFunctionalSeq_NUMB   = @Li_CrecActivity2210_NUMB,
           @An_EntityCase_IDNO           = @Ln_CpnoCur_Case_IDNO,
           @Ac_EntityCheckRecipient_ID   = @Lc_CpnoCur_CheckRecipient_ID,
           @Ac_EntityCheckRecipient_CODE = @Lc_CpnoCur_CheckRecipient_CODE,
           @Ac_Msg_CODE                  = @Lc_Msg_CODE OUTPUT,
           @As_DescriptionError_TEXT     = @Ls_ErrorMessage_TEXT OUTPUT;

          IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
           BEGIN
            RAISERROR (50001,16,1);
           END
         END
        ELSE
         BEGIN
          /*
          The batch process checks all CP MCI’s where there is no response for the second notice (FIN-37) and 30 calendar days have elapsed.
          If the CP does not respond to the second notice (FIN-37), and 30 calendar days have elapsed, on the 31st day from the generation of FIN-37, the system will generate the third and final notice 
          (FIN-38 Final Notice of Overpayment of Support) reminding the CP to respond to the notice
          */
          IF @Lc_Notice_ID IN (@Lc_SecondOverPaymentNotice_ID, @Lc_FinalOverPaymentNotice_ID)
           BEGIN
            --generate notice when the balance is due
            IF dbo.BATCH_FIN_CP_RECOUP_NOTICE$SF_CALC_RECOUP_AMT (@Lc_CpnoCur_CheckRecipient_ID) > 0
             BEGIN
              SET @Ls_Sql_TEXT = 'BATCH_FIN_CP_RECOUP_NOTICE$SP_INSERT_CPNO-4 ';
              SET @Ls_Sqldata_TEXT = 'CheckRecipient_ID = ' + ISNULL (CAST(@Lc_CpnoCur_CheckRecipient_ID AS VARCHAR), '') + ', CheckRecipient_CODE = ' + @Lc_CpnoCur_CheckRecipient_CODE + ', Case_IDNO = ' + ISNULL (CAST(@Ln_CpnoCur_Case_IDNO AS VARCHAR), '') + ', Notice_ID = ' + @Lc_Notice_ID + ', NoticeSeq_NUMB = ' + CAST(@Ln_CpnoCur_NoticeSeq_NUMB AS VARCHAR) + ', EventGlobalSeq_NUMB = ' + CAST(@Ln_EventGlobalSeq_NUMB AS VARCHAR) + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', LastRun_DATE = ' + CAST(@Ld_LastRun_DATE AS VARCHAR);
              SET @Ln_CpnoCur_NoticeSeq_NUMB = @Ln_CpnoCur_NoticeSeq_NUMB + 1;

              EXECUTE BATCH_FIN_CP_RECOUP_NOTICE$SP_INSERT_CPNO
               @Ac_CheckRecipient_ID     = @Lc_CpnoCur_CheckRecipient_ID,
               @Ac_CheckRecipient_CODE   = @Lc_CpnoCur_CheckRecipient_CODE,
               @An_Case_IDNO             = @Ln_CpnoCur_Case_IDNO,
               @Ac_Notice_ID             = @Lc_Notice_ID,
               @An_NoticeSeq_NUMB        = @Ln_CpnoCur_NoticeSeq_NUMB,
               @Ad_AppSigned_DATE        = NULL,
               @An_EventGlobalSeq_NUMB   = @Ln_EventGlobalSeq_NUMB,
               @Ad_Run_DATE              = @Ld_Run_DATE,
               @Ad_LastRun_DATE			 = @Ld_LastRun_DATE,
               @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
               @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

              IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
               BEGIN
                RAISERROR (50001,16,1);
               END

              SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT -4 ';
              SET @Ls_Sqldata_TEXT = 'EventFunctionalSeq_NUMB = ' + ISNULL (CAST (@Li_CrecActivity2210_NUMB AS VARCHAR), '') + ', Job_ID = ' + ISNULL (@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL (CAST (@Ld_Run_DATE AS VARCHAR), '') + ', No_INDC = ' + @Lc_No_INDC + ', BatchRunUser_TEXT = ' + @Lc_BatchRunUser_TEXT;

              EXECUTE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
               @An_EventFunctionalSeq_NUMB  = @Li_CrecActivity2210_NUMB,
               @Ac_Process_ID               = @Lc_Job_ID,
               @Ad_EffectiveEvent_DATE      = @Ld_Run_DATE,
               @Ac_Note_INDC                = @Lc_No_INDC,
               @Ac_Worker_ID                = @Lc_BatchRunUser_TEXT,
               @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
               @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
               @As_DescriptionError_TEXT    = @Ls_ErrorMessage_TEXT OUTPUT;

              IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
               BEGIN
                RAISERROR (50001,16,1);
               END

              /*
              	Insert a record into the Notice Print Request (NMRQ_Y1) table with the CP, Member Client Index (MCI) Number, and notice details, so that the notice can be printed from a centralized location.
              */
              SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_ACTIVITY-4 ';
              SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL (CAST(@Ln_CpnoCur_Case_IDNO AS VARCHAR), '') + ', CheckRecipient_ID  = ' + ISNULL (CAST(@Lc_CpnoCur_CheckRecipient_ID AS VARCHAR), '') + ', Notice_ID = ' + ISNULL (@Lc_Notice_ID, '') + ', Transaction Seq = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', MemberMci_IDNO = ' + CAST(@Ln_MemberMci_IDNO AS VARCHAR) + ', MajorActivityCase_CODE = ' + @Lc_MajorActivityCase_CODE + ', ActivityMinor_CODE = ' + @Lc_ActivityMinor_CODE + ', Subsystem_CODE = ' + @Lc_Subsystem_CODE + ', BatchRunUser_TEXT = ' + @Lc_BatchRunUser_TEXT + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', Job_ID = ' + @Lc_Job_ID;
              SET @Ln_MemberMci_IDNO =CAST(@Lc_CpnoCur_CheckRecipient_ID AS NUMERIC(10));

              EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
               @An_Case_IDNO                = @Ln_CpnoCur_Case_IDNO,
               @An_MemberMci_IDNO           = @Ln_MemberMci_IDNO,
               @Ac_ActivityMajor_CODE       = @Lc_MajorActivityCase_CODE,
               @Ac_ActivityMinor_CODE       = @Lc_ActivityMinor_CODE,
               @Ac_Subsystem_CODE           = @Lc_Subsystem_CODE,
               @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
               @Ac_WorkerUpdate_ID          = @Lc_BatchRunUser_TEXT,
               @Ad_Run_DATE                 = @Ld_Run_DATE,
               @Ac_Notice_ID                = @Lc_Notice_ID,
               @Ac_Job_ID                   = @Lc_Job_ID,
               @An_Topic_IDNO               = @Ln_Topic_IDNO OUTPUT,
               @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
               @As_DescriptionError_TEXT    = @Ls_ErrorMessage_TEXT OUTPUT;

              IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
               BEGIN
                SET @Lc_BateError_CODE = @Lc_BateErrorUnknown_CODE;

                RAISERROR (50001,16,1);
               END
              ELSE IF @Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
               BEGIN
                SET @Lc_BateError_CODE = @Lc_Msg_CODE;

                RAISERROR (50001,16,1);
               END
             END
            --To end date the old notices which are already generated
            ELSE
             BEGIN
              SET @Ls_Sql_TEXT = 'UPDATE_CPNO - 2 ';
              SET @Ls_Sqldata_TEXT = 'CheckRecipient_ID = ' + ISNULL (CAST(@Lc_CpnoCur_CheckRecipient_ID AS VARCHAR), '') + ', CheckRecipient_CODE = ' + ISNULL (@Lc_CpnoCur_CheckRecipient_CODE, '') + ', Case_IDNO = ' + ISNULL (CAST(@Ln_CpnoCur_Case_IDNO AS VARCHAR), '') + ', Notice_ID = ' + ISNULL (@Lc_Notice_ID, '') + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', EventGlobalSeq_NUMB = ' + CAST(@Ln_EventGlobalSeq_NUMB AS VARCHAR) + ', NoticeSeq_NUMB = ' + CAST(@Ln_CpnoCur_NoticeSeq_NUMB AS VARCHAR) + ', Busday_INDC = ' + @Lc_Busday_INDC + ', High_DATE = ' + CAST(@Ld_High_DATE AS VARCHAR);

              UPDATE CPNO_Y1
                 SET StatusUpdate_DATE = @Ld_Run_DATE,
                     EventGlobalUpdateSeq_NUMB = @Ln_EventGlobalSeq_NUMB
               WHERE Case_IDNO = @Ln_CpnoCur_Case_IDNO
                 AND CheckRecipient_ID = @Lc_CpnoCur_CheckRecipient_ID
                 AND CheckRecipient_CODE = @Lc_CpnoCur_CheckRecipient_CODE
                 AND NoticeSeq_NUMB = @Ln_CpnoCur_NoticeSeq_NUMB
                 AND StatusUpdate_DATE = @Ld_High_DATE;

              SET @Ln_RowCount_QNTY = @@ROWCOUNT;

              IF @Ln_RowCount_QNTY = 0
               BEGIN
                SET @Ls_ErrorMessage_TEXT = @Lc_Err0002_TEXT;

                RAISERROR (50001,16,1);
               END
             END
           END
          ELSE
           BEGIN
            /*
            If there is no response after the three attempts, the system will automatically move the pending 
            recoupment balance of those receipts to an active recoupment and set the percentage rate to be recouped at
             10%.
            */
            DECLARE RecoupAct_CUR INSENSITIVE CURSOR FOR
             SELECT a.CheckRecipient_ID,
                    a.CheckRecipient_CODE,
                    a.Case_IDNO,
                    a.Batch_DATE,
                    a.SourceBatch_CODE,
                    a.Batch_NUMB,
                    a.SeqReceipt_NUMB,
                    a.NoticeSeq_NUMB
               FROM CPNO_Y1 a
              WHERE a.Case_IDNO = @Ln_CpnoCur_Case_IDNO
                AND a.CheckRecipient_ID = @Lc_CpnoCur_CheckRecipient_ID
                AND a.CheckRecipient_CODE = @Lc_CpnoCur_CheckRecipient_CODE
                AND a.StatusUpdate_DATE = @Ld_High_DATE;

            SET @Ls_Sql_TEXT = 'OPEN RecoupAct_CUR-3';
            SET @Ls_Sqldata_TEXT = '';

            OPEN RecoupAct_CUR;

            SET @Ls_Sql_TEXT = 'FETCH RecoupAct_CUR-5';
            SET @Ls_Sqldata_TEXT = '';

            FETCH NEXT FROM RecoupAct_CUR INTO @Lc_RecoupActCur_CheckRecipient_ID, @Lc_RecoupActCur_CheckRecipient_CODE, @Ln_RecoupActCur_Case_IDNO, @Ld_RecoupActCur_Batch_DATE, @Lc_RecoupActCur_SourceBatch_CODE, @Ln_RecoupActCur_Batch_NUMB, @Ln_RecoupActCur_SeqReceipt_NUMB, @Ln_RecoupActCur_NoticeSeq_NUMB;

            SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
            SET @Ls_Sql_TEXT = 'WHILE-6';
            SET @Ls_Sqldata_TEXT = 'CheckRecipient_ID = ' + ISNULL (CAST(@Lc_CpnoCur_CheckRecipient_ID AS VARCHAR), '') + ', Case_IDNO = ' + ISNULL (CAST(@Ln_CpnoCur_Case_IDNO AS VARCHAR), '');

            -- Moving Pending recoupment to Active recoupment
            WHILE @Li_FetchStatus_QNTY = 0
             BEGIN
              SET @Ls_Sql_TEXT = 'BATCH_FIN_CP_RECOUP_NOTICE$SP_SET_RECOUP_ACTIVE-4';
              SET @Ls_Sqldata_TEXT = 'CheckRecipient_ID = ' + ISNULL (CAST(@Lc_RecoupActCur_CheckRecipient_ID AS VARCHAR), '') + ', Case_IDNO = ' + ISNULL (CAST(@Ln_RecoupActCur_Case_IDNO AS VARCHAR), '') + ', CheckRecipient_CODE = ' + @Lc_RecoupActCur_CheckRecipient_CODE + ', Batch_DATE = ' + CAST(@Ld_RecoupActCur_Batch_DATE AS VARCHAR) + ', SourceBatch_CODE = ' + @Lc_RecoupActCur_SourceBatch_CODE + ', Batch_NUMB = ' + CAST(@Ln_RecoupActCur_Batch_NUMB AS VARCHAR) + ', SeqReceipt_NUMB = ' + CAST(@Ln_RecoupActCur_SeqReceipt_NUMB AS VARCHAR) + ', EventGlobalSeq_NUMB = ' + CAST(@Ln_EventGlobalSeq_NUMB AS VARCHAR) + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

              EXECUTE BATCH_FIN_CP_RECOUP_NOTICE$SP_SET_RECOUP_ACTIVE
               @Ac_CheckRecipient_ID     = @Lc_RecoupActCur_CheckRecipient_ID,
               @Ac_CheckRecipient_CODE   = @Lc_RecoupActCur_CheckRecipient_CODE,
               @An_Case_IDNO             = @Ln_RecoupActCur_Case_IDNO,
               @Ad_Batch_DATE            = @Ld_RecoupActCur_Batch_DATE,
               @Ac_SourceBatch_CODE      = @Lc_RecoupActCur_SourceBatch_CODE,
               @An_Batch_NUMB            = @Ln_RecoupActCur_Batch_NUMB,
               @An_SeqReceipt_NUMB       = @Ln_RecoupActCur_SeqReceipt_NUMB,
               @An_EventGlobalSeq_NUMB   = @Ln_EventGlobalSeq_NUMB,
               @Ad_Run_DATE              = @Ld_Run_DATE,
               @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
               @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

              IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
               BEGIN
                RAISERROR (50001,16,1);
               END

              SET @Ls_Sql_TEXT = 'UPDATE_CPNO_V1 -3';
              SET @Ls_Sqldata_TEXT = 'CheckRecipient_ID = ' + ISNULL (CAST(@Lc_RecoupActCur_CheckRecipient_ID AS VARCHAR), '') + ', CheckRecipient_CODE = ' + ISNULL (@Lc_RecoupActCur_CheckRecipient_CODE, '') + ', Case_IDNO = ' + ISNULL (CAST(@Ln_RecoupActCur_Case_IDNO AS VARCHAR), '') + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', EventGlobalSeq_NUMB = ' + CAST(@Ln_EventGlobalSeq_NUMB AS VARCHAR) + ', Batch_DATE = ' + CAST (@Ld_RecoupActCur_Batch_DATE AS VARCHAR) + ', SourceBatch_CODE = ' + @Lc_RecoupActCur_SourceBatch_CODE + ', Batch_NUMB = ' + CAST(@Ln_RecoupActCur_Batch_NUMB AS VARCHAR) + ', SeqReceipt_NUMB = ' + CAST(@Ln_RecoupActCur_SeqReceipt_NUMB AS VARCHAR) + ', NoticeSeq_NUMB = ' + CAST(@Ln_RecoupActCur_NoticeSeq_NUMB AS VARCHAR);

              UPDATE CPNO_Y1
                 SET StatusUpdate_DATE = @Ld_Run_DATE,
                     EventGlobalUpdateSeq_NUMB = @Ln_EventGlobalSeq_NUMB
               WHERE CheckRecipient_ID = @Lc_RecoupActCur_CheckRecipient_ID
                 AND CheckRecipient_CODE = @Lc_RecoupActCur_CheckRecipient_CODE
                 AND Case_IDNO = @Ln_RecoupActCur_Case_IDNO
                 AND Batch_DATE = @Ld_RecoupActCur_Batch_DATE
                 AND SourceBatch_CODE = @Lc_RecoupActCur_SourceBatch_CODE
                 AND Batch_NUMB = @Ln_RecoupActCur_Batch_NUMB
                 AND SeqReceipt_NUMB = @Ln_RecoupActCur_SeqReceipt_NUMB
                 AND NoticeSeq_NUMB = @Ln_RecoupActCur_NoticeSeq_NUMB;

              SET @Ln_RowCount_QNTY = @@ROWCOUNT;

              IF @Ln_RowCount_QNTY = 0
               BEGIN
                -- UPDATE NOT SUCCESSFUL
                SET @Ls_ErrorMessage_TEXT =@Lc_Err0002_TEXT;

                RAISERROR (50001,16,1);
               END

              SET @Ls_Sql_TEXT = 'FETCH recoup_cpno_cur-6';
              SET @Ls_Sqldata_TEXT = '';

              FETCH NEXT FROM RecoupAct_CUR INTO @Lc_RecoupActCur_CheckRecipient_ID, @Lc_RecoupActCur_CheckRecipient_CODE, @Ln_RecoupActCur_Case_IDNO, @Ld_RecoupActCur_Batch_DATE, @Lc_RecoupActCur_SourceBatch_CODE, @Ln_RecoupActCur_Batch_NUMB, @Ln_RecoupActCur_SeqReceipt_NUMB, @Ln_RecoupActCur_NoticeSeq_NUMB;

              SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
             END

            CLOSE RecoupAct_CUR;

            DEALLOCATE RecoupAct_CUR;

            SET @Ls_Sql_TEXT = ' BATCH_COMMON$SP_ENTITY_MATRIX-4';
            SET @Ls_Sqldata_TEXT = 'EventGlobalSeq_NUMB = ' + ISNULL (CAST (@Ln_EventGlobalSeq_NUMB AS VARCHAR), '') + ', EventFunctionalSeq_NUMB = ' + ISNULL (CAST (@Li_CrecActivity2210_NUMB AS VARCHAR), '') + ', Case_IDNO = ' + ISNULL (CAST(@Ln_CpnoCur_Case_IDNO AS VARCHAR), '') + ', CheckRecipient_ID = ' + ISNULL (CAST(@Lc_CpnoCur_CheckRecipient_ID AS VARCHAR), '') + ', Check Recipient Code = ' + @Lc_CpnoCur_CheckRecipient_CODE;

            EXECUTE BATCH_COMMON$SP_ENTITY_MATRIX
             @An_EventGlobalSeq_NUMB       = @Ln_EventGlobalSeq_NUMB,
             @An_EventFunctionalSeq_NUMB   = @Li_CrecActivity2210_NUMB,
             @An_EntityCase_IDNO           = @Ln_CpnoCur_Case_IDNO,
             @Ac_EntityCheckRecipient_ID   = @Lc_CpnoCur_CheckRecipient_ID,
             @Ac_EntityCheckRecipient_CODE = @Lc_CpnoCur_CheckRecipient_CODE,
             @Ac_Msg_CODE                  = @Lc_Msg_CODE OUTPUT,
             @As_DescriptionError_TEXT     = @Ls_ErrorMessage_TEXT OUTPUT;

            IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
             BEGIN
              RAISERROR (50001,16,1);
             END
           END
         END
       END
     END try

     BEGIN catch
      IF XACT_STATE() = 1
       BEGIN
        ROLLBACK TRANSACTION EXT_PAYMENT_SAVE;
       END
      ELSE
       BEGIN
        SET @Ls_ErrorMessage_TEXT = @Ls_ErrorMessage_TEXT + ' ' + SUBSTRING (ERROR_MESSAGE (), 1, 200);

        RAISERROR( 50001,16,1);
       END

      SET @Ln_Error_NUMB = ERROR_NUMBER();
      SET @Ln_ErrorLine_NUMB = ERROR_LINE();

      IF @Ln_Error_NUMB <> 50001
       BEGIN
        SET @Lc_BateError_CODE = @Lc_BateErrorUnknown_CODE;
        SET @Ls_ErrorMessage_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
       END

      EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
       @As_Procedure_NAME        = @Ls_Procedure_NAME,
       @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
       @As_Sql_TEXT              = @Ls_Sql_TEXT,
       @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
       @An_Error_NUMB            = @Ln_Error_NUMB,
       @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
       @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

      SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG - 2';
      SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + @Ls_Process_NAME + ', Procedure_NAME = ' + @Ls_Procedure_NAME + ', Job_ID = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', Cursor_QNTY = ' + CAST(@Ln_Cursor_QNTY AS VARCHAR) + ', BateError_CODE = ' + @Lc_BateError_CODE + ', ErrorMessage_TEXT = ' + @Ls_ErrorMessage_TEXT + ', BateRecord_TEXT = ' + @Ls_BateRecord_TEXT;

      EXECUTE BATCH_COMMON$SP_BATE_LOG
       @As_Process_NAME             = @Ls_Process_NAME,
       @As_Procedure_NAME           = @Ls_Procedure_NAME,
       @Ac_Job_ID                   = @Lc_Job_ID,
       @Ad_Run_DATE                 = @Ld_Run_DATE,
       @Ac_TypeError_CODE           = @Lc_TypeErrorE_CODE,
       @An_Line_NUMB                = @Ln_Cursor_QNTY,
       @Ac_Error_CODE               = @Lc_BateError_CODE,
       @As_DescriptionError_TEXT    = @Ls_ErrorMessage_TEXT,
       @As_ListKey_TEXT             = @Ls_BateRecord_TEXT,
       @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
       @As_DescriptionErrorOut_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

      IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
       BEGIN
        RAISERROR (50001,16,1);
       END

      IF @Lc_Msg_CODE = @Lc_TypeErrorE_CODE
       BEGIN
        SET @Ln_ExceptionThreshold_QNTY = @Ln_ExceptionThreshold_QNTY + 1;
       END
     END catch

     /* If the commit frequency is attained, the following is done.
         Reset the commit count, Commit the transaction completed until now.*/
     IF @Ln_CommitFreqParm_QNTY <> 0
        AND @Ln_CommitFreq_QNTY = @Ln_CommitFreqParm_QNTY
      BEGIN
       COMMIT TRANSACTION EXT_PAYMENT;

       BEGIN TRANSACTION EXT_PAYMENT;

       SET @Ln_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY + @Ln_CommitFreq_QNTY;
       SET @Ln_CommitFreq_QNTY = 0;
      END

     SET @Ls_Sql_TEXT = 'ExceptionThreshold Check -2';
     SET @Ls_Sqldata_TEXT ='ExceptionThreshold_QNTY = ' + CAST(@Ln_ExceptionThreshold_QNTY AS VARCHAR) + ', ExceptionThresholdParm_QNTY = ' + CAST(@Ln_ExceptionThresholdParm_QNTY AS VARCHAR);

     IF @Ln_ExceptionThreshold_QNTY > @Ln_ExceptionThresholdParm_QNTY
      BEGIN
       COMMIT TRANSACTION EXT_PAYMENT;

       SET @Ln_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY + @Ln_CommitFreq_QNTY;
       SET @Ls_ErrorMessage_TEXT = 'REACHED EXCEPTION THRESHOLD';

       RAISERROR (50001,16,1);
      END

     SET @Ls_Sql_TEXT = 'FETCH Cpno_CUR-2';
     SET @Ls_Sqldata_TEXT = 'Cursor Previous Record = ' + SUBSTRING(@Ls_BateRecord_TEXT, 1, 970);

     FETCH NEXT FROM Cpno_CUR INTO @Lc_CpnoCur_CheckRecipient_ID, @Lc_CpnoCur_CheckRecipient_CODE, @Ln_CpnoCur_Case_IDNO, @Lc_CpnoCur_Notice_ID, @Lc_CpnoCur_TypeCase_CODE, @Ln_CpnoCur_NoticeSeq_NUMB;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END;

   CLOSE Cpno_CUR;

   DEALLOCATE Cpno_CUR;

   IF @Ln_CommitFreqParm_QNTY <> 0
    BEGIN
     COMMIT TRANSACTION EXT_PAYMENT;

     BEGIN TRANSACTION EXT_PAYMENT;

     SET @Ln_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY + @Ln_CommitFreq_QNTY;
     SET @Ln_CommitFreq_QNTY = 0;
    END

   /*
   If there was a response from the CP for any of the three notices but no payment received, and there is an outstanding recoupment balance at the receipt level,
   then, at 91 calendar days from the original notice date, the system will automatically move the pending recoupment to active recoupment in POFL_Y1, 
   and the percentage amount will be set to 10% in RECP_Y1 to be recouped from future disbursements.
      */
   DECLARE RecoupAct_CUR INSENSITIVE CURSOR FOR
    SELECT DISTINCT
           l.CheckRecipient_ID,
           l.CheckRecipient_CODE,
           l.Case_IDNO,
           l.Batch_DATE,
           l.SourceBatch_CODE,
           l.Batch_NUMB,
           l.SeqReceipt_NUMB
      FROM POFL_Y1 l,
           (SELECT DISTINCT
                   a.CheckRecipient_ID,
                   a.CheckRecipient_CODE,
                   a.Case_IDNO
              FROM CPNO_Y1 a
             WHERE a.Notice_ID = @Lc_FirstOverPaymentNotice_ID
               AND a.Notice_DATE <= DATEADD(D, -91, @Ld_Run_DATE)
               AND NOT EXISTS (SELECT 1
                                 FROM CPNO_Y1 C
                                WHERE C.CheckRecipient_ID = a.CheckRecipient_ID
                                  AND C.CheckRecipient_CODE = a.CheckRecipient_CODE
                                  AND C.Notice_ID = @Lc_FirstOverPaymentNotice_ID
                                  AND C.Notice_DATE > DATEADD(D, -91, @Ld_Run_DATE))
               AND EXISTS(SELECT 1
                            FROM RECP_Y1 R
                           WHERE R.Cpresponse_INDC = @Lc_Yes_INDC
                             AND EndValidity_DATE = @Ld_High_DATE)
               AND EXISTS(SELECT 1
                            FROM (SELECT p.AssessTotOverpay_AMNT,
                                         p.PendTotOffset_AMNT,
                                         ROW_NUMBER () OVER ( PARTITION BY p.CheckRecipient_ID, p.CheckRecipient_CODE ORDER BY p.Unique_IDNO DESC) AS Row_NUMB
                                    FROM POFL_Y1 p
                                   WHERE p.CheckRecipient_ID = a.CheckRecipient_ID
                                     AND p.CheckRecipient_CODE = a.CheckRecipient_CODE) AS b
                           WHERE b.Row_NUMB = 1
                             AND (b.AssessTotOverpay_AMNT > 0
                                   OR b.PendTotOffset_AMNT > 0))) t
     WHERE l.CheckRecipient_ID = t.CheckRecipient_ID
       AND l.CheckRecipient_CODE = t.CheckRecipient_CODE
       AND l.Case_IDNO = t.Case_IDNO;

   SET @Ls_Sql_TEXT = 'OPEN RecoupAct_CUR-4';
   SET @Ls_Sqldata_TEXT = '';

   OPEN RecoupAct_CUR;

   SET @Ls_Sql_TEXT = 'FETCH RecoupAct_CUR-7';
   SET @Ls_Sqldata_TEXT = '';

   FETCH NEXT FROM RecoupAct_CUR INTO @Lc_RecoupActCur_CheckRecipient_ID, @Lc_RecoupActCur_CheckRecipient_CODE, @Ln_RecoupActCur_Case_IDNO, @Ld_RecoupActCur_Batch_DATE, @Lc_RecoupActCur_SourceBatch_CODE, @Ln_RecoupActCur_Batch_NUMB, @Ln_RecoupActCur_SeqReceipt_NUMB;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
   SET @Ls_Sql_TEXT = 'WHILE-7';
   SET @Ls_Sqldata_TEXT = 'CheckRecipient_ID = ' + ISNULL (CAST(@Lc_RecoupActCur_CheckRecipient_ID AS VARCHAR), '') + ', Case_IDNO = ' + ISNULL (CAST(@Ln_RecoupActCur_Case_IDNO AS VARCHAR), '');

   -- Moving Pending recoupment to Active recoupment
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
     BEGIN TRY
      SAVE TRANSACTION EXT_PAYMENT_SAVE

      SET @Lc_BateError_CODE = @Lc_BateErrorUnknown_CODE;
      SET @Ls_ErrorMessage_TEXT ='';
      -- Incrementing the commit frequency count
      SET @Ln_CommitFreq_QNTY = @Ln_CommitFreq_QNTY + 1;
      SET @Ln_Cursor_QNTY =@Ln_Cursor_QNTY + 1;
      SET @Ls_BateRecord_TEXT = ' Case_IDNO = ' + ISNULL(CAST(@Ln_RecoupActCur_Case_IDNO AS VARCHAR), '') + ', CheckRecipient_ID = ' + ISNULL(CAST(@Lc_RecoupActCur_CheckRecipient_ID AS VARCHAR), '') + ', CheckRecipient_CODE = ' + ISNULL(CAST(@Lc_RecoupActCur_CheckRecipient_CODE AS VARCHAR), '') + ', Batch_DATE =' + CAST(@Ld_RecoupActCur_Batch_DATE AS VARCHAR) + ', SourceBatch_CODE = ' + @Lc_RecoupActCur_SourceBatch_CODE + ', Batch_NUMB = ' + CAST(@Ln_RecoupActCur_Batch_NUMB AS VARCHAR) + ', SeqReceipt_NUMB = ' + CAST(@Ln_RecoupActCur_SeqReceipt_NUMB AS VARCHAR);
      SET @Ls_Sql_TEXT = ' BATCH_COMMON$SP_GENERATE_SEQ-3 ';
      SET @Ls_Sqldata_TEXT = 'EventFunctionalSeq_NUMB = ' + ISNULL (CAST (@Li_CrecActivity2210_NUMB AS VARCHAR), '') + ', Job_ID = ' + ISNULL (@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL (CAST (@Ld_Run_DATE AS VARCHAR), '') + ', No_INDC = ' + @Lc_No_INDC + ', BatchRunUser_TEXT = ' + @Lc_BatchRunUser_TEXT;

      EXECUTE BATCH_COMMON$SP_GENERATE_SEQ
       @An_EventFunctionalSeq_NUMB = @Li_CrecActivity2210_NUMB,
       @Ac_Process_ID              = @Lc_Job_ID,
       @Ad_EffectiveEvent_DATE     = @Ld_Run_DATE,
       @Ac_Note_INDC               = @Lc_No_INDC,
       @Ac_Worker_ID               = @Lc_BatchRunUser_TEXT,
       @An_EventGlobalSeq_NUMB     = @Ln_EventGlobalSeq_NUMB OUTPUT,
       @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
       @As_DescriptionError_TEXT   = @Ls_ErrorMessage_TEXT OUTPUT;

      IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
       BEGIN
        RAISERROR (50001,16,1);
       END

      SET @Ls_Sql_TEXT = 'UPDATE RECP_Y1 1';
      SET @Ls_Sqldata_TEXT = 'CheckRecipient_ID = ' + ISNULL (CAST(@Lc_RecoupActCur_CheckRecipient_ID AS VARCHAR), '') + ', CheckRecipient_CODE = ' + @Lc_RecoupActCur_CheckRecipient_CODE + ', EventGlobalSeq_NUMB = ' + CAST(@Ln_EventGlobalSeq_NUMB AS VARCHAR) + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', High_DATE = ' + CAST(@Ld_High_DATE AS VARCHAR) + ', Yes_INDC = ' + @Lc_Yes_INDC;

      UPDATE RECP_Y1
         SET EndValidity_DATE = @Ld_Run_DATE,
             EventGlobalEndSeq_NUMB = @Ln_EventGlobalSeq_NUMB
       WHERE CheckRecipient_ID = @Lc_RecoupActCur_CheckRecipient_ID
         AND CheckRecipient_CODE = @Lc_RecoupActCur_CheckRecipient_CODE
         AND EndValidity_DATE = @Ld_High_DATE
         AND CpResponse_INDC = @Lc_Yes_INDC
         AND Recoupment_PCT <> 10;

      SET @Ls_Sql_TEXT = 'BATCH_FIN_CP_RECOUP_NOTICE$SP_SET_RECOUP_ACTIVE-5';
      SET @Ls_Sqldata_TEXT = 'CheckRecipient_ID = ' + ISNULL (CAST(@Lc_RecoupActCur_CheckRecipient_ID AS VARCHAR), '') + ', Case_IDNO = ' + ISNULL (CAST(@Ln_RecoupActCur_Case_IDNO AS VARCHAR), '') + ', CheckRecipient_CODE = ' + @Lc_RecoupActCur_CheckRecipient_CODE + ', Batch_DATE = ' + CAST(@Ld_RecoupActCur_Batch_DATE AS VARCHAR) + ', SourceBatch_CODE = ' + @Lc_RecoupActCur_SourceBatch_CODE + ', Batch_NUMB = ' + CAST(@Ln_RecoupActCur_Batch_NUMB AS VARCHAR) + ', SeqReceipt_NUMB = ' + CAST(@Ln_RecoupActCur_SeqReceipt_NUMB AS VARCHAR) + ', EventGlobalSeq_NUMB = ' + CAST(@Ln_EventGlobalSeq_NUMB AS VARCHAR) + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

      EXECUTE BATCH_FIN_CP_RECOUP_NOTICE$SP_SET_RECOUP_ACTIVE
       @Ac_CheckRecipient_ID     = @Lc_RecoupActCur_CheckRecipient_ID,
       @Ac_CheckRecipient_CODE   = @Lc_RecoupActCur_CheckRecipient_CODE,
       @An_Case_IDNO             = @Ln_RecoupActCur_Case_IDNO,
       @Ad_Batch_DATE            = @Ld_RecoupActCur_Batch_DATE,
       @Ac_SourceBatch_CODE      = @Lc_RecoupActCur_SourceBatch_CODE,
       @An_Batch_NUMB            = @Ln_RecoupActCur_Batch_NUMB,
       @An_SeqReceipt_NUMB       = @Ln_RecoupActCur_SeqReceipt_NUMB,
       @An_EventGlobalSeq_NUMB   = @Ln_EventGlobalSeq_NUMB,
       @Ad_Run_DATE              = @Ld_Run_DATE,
       @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
       @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

      IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
       BEGIN
        RAISERROR (50001,16,1);
       END

      SET @Ls_Sql_TEXT = 'FETCH recoup_cpno_cur-6';
      SET @Ls_Sqldata_TEXT = '';
     END try

     BEGIN catch
      IF XACT_STATE() = 1
       BEGIN
        ROLLBACK TRANSACTION EXT_PAYMENT_SAVE;
       END
      ELSE
       BEGIN
        SET @Ls_ErrorMessage_TEXT = @Ls_ErrorMessage_TEXT + ' ' + SUBSTRING (ERROR_MESSAGE (), 1, 200);

        RAISERROR( 50001,16,1);
       END

      SET @Ln_Error_NUMB = ERROR_NUMBER();
      SET @Ln_ErrorLine_NUMB = ERROR_LINE();

      IF @Ln_Error_NUMB <> 50001
       BEGIN
        SET @Lc_BateError_CODE = @Lc_BateErrorUnknown_CODE;
        SET @Ls_ErrorMessage_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
       END

      EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
       @As_Procedure_NAME        = @Ls_Procedure_NAME,
       @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
       @As_Sql_TEXT              = @Ls_Sql_TEXT,
       @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
       @An_Error_NUMB            = @Ln_Error_NUMB,
       @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
       @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

      SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG - 2';
      SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + @Ls_Process_NAME + ', Procedure_NAME = ' + @Ls_Procedure_NAME + ', Job_ID = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', Cursor_QNTY = ' + CAST(@Ln_Cursor_QNTY AS VARCHAR) + ', BateError_CODE = ' + @Lc_BateError_CODE + ', ErrorMessage_TEXT = ' + @Ls_ErrorMessage_TEXT + ', BateRecord_TEXT = ' + @Ls_BateRecord_TEXT;

      EXECUTE BATCH_COMMON$SP_BATE_LOG
       @As_Process_NAME             = @Ls_Process_NAME,
       @As_Procedure_NAME           = @Ls_Procedure_NAME,
       @Ac_Job_ID                   = @Lc_Job_ID,
       @Ad_Run_DATE                 = @Ld_Run_DATE,
       @Ac_TypeError_CODE           = @Lc_TypeErrorE_CODE,
       @An_Line_NUMB                = @Ln_Cursor_QNTY,
       @Ac_Error_CODE               = @Lc_BateError_CODE,
       @As_DescriptionError_TEXT    = @Ls_ErrorMessage_TEXT,
       @As_ListKey_TEXT             = @Ls_BateRecord_TEXT,
       @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
       @As_DescriptionErrorOut_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

      IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
       BEGIN
        RAISERROR (50001,16,1);
       END

      IF @Lc_Msg_CODE = @Lc_TypeErrorE_CODE
       BEGIN
        SET @Ln_ExceptionThreshold_QNTY = @Ln_ExceptionThreshold_QNTY + 1;
       END
     END catch

     /* If the commit frequency is attained, the following is done.
         Reset the commit count, Commit the transaction completed until now.*/
     IF @Ln_CommitFreqParm_QNTY <> 0
        AND @Ln_CommitFreq_QNTY = @Ln_CommitFreqParm_QNTY
      BEGIN
       COMMIT TRANSACTION EXT_PAYMENT;

       BEGIN TRANSACTION EXT_PAYMENT;

       SET @Ln_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY + @Ln_CommitFreq_QNTY;
       SET @Ln_CommitFreq_QNTY = 0;
      END

     SET @Ls_Sql_TEXT = 'ExceptionThreshold Check -2';
     SET @Ls_Sqldata_TEXT ='ExceptionThreshold_QNTY = ' + CAST(@Ln_ExceptionThreshold_QNTY AS VARCHAR) + ', ExceptionThresholdParm_QNTY = ' + CAST(@Ln_ExceptionThresholdParm_QNTY AS VARCHAR);

     IF @Ln_ExceptionThreshold_QNTY > @Ln_ExceptionThresholdParm_QNTY
      BEGIN
       COMMIT TRANSACTION EXT_PAYMENT;

       SET @Ln_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY + @Ln_CommitFreq_QNTY;
       SET @Ls_ErrorMessage_TEXT = 'REACHED EXCEPTION THRESHOLD';

       RAISERROR (50001,16,1);
      END

     FETCH NEXT FROM RecoupAct_CUR INTO @Lc_RecoupActCur_CheckRecipient_ID, @Lc_RecoupActCur_CheckRecipient_CODE, @Ln_RecoupActCur_Case_IDNO, @Ld_RecoupActCur_Batch_DATE, @Lc_RecoupActCur_SourceBatch_CODE, @Ln_RecoupActCur_Batch_NUMB, @Ln_RecoupActCur_SeqReceipt_NUMB;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END

   CLOSE RecoupAct_CUR;

   DEALLOCATE RecoupAct_CUR;

   SET @Ln_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY + @Ln_CommitFreq_QNTY;
   -- Update the last run date for the procedure with the run date in the PARM_Y1 table
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END

   -- Updating the log with the Result_TEXT
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BSTL_LOG-1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', Process_NAME = ' + @Ls_Process_NAME + ', Procedure_NAME = ' + @Ls_Procedure_NAME + ', StatusSuccess_CODE = ' + @Lc_StatusSuccess_CODE + ', Successful_TEXT = ' + @Lc_Successful_TEXT + ', BatchRunUser_TEXT = ' + @Lc_BatchRunUser_TEXT + ', Start_DATE = ' + CAST(@Ld_Start_DATE AS VARCHAR) + ', ProcessedRecordCount_QNTY = ' + CAST(@Ln_ProcessedRecordCount_QNTY AS VARCHAR) + ', Space_TEXT = ' + @Lc_Space_TEXT;

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Lc_Space_TEXT,
    @As_ExecLocation_TEXT         = @Lc_Successful_TEXT,
    @An_ProcessedRecordCount_QNTY =@Ln_ProcessedRecordCount_QNTY,
    @As_ListKey_TEXT              = @Lc_Successful_TEXT,
    @As_DescriptionError_TEXT     = @Lc_Space_TEXT,
    @Ac_Status_CODE               = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT;

   COMMIT TRANSACTION EXT_PAYMENT;
  END TRY

  BEGIN CATCH
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION EXT_PAYMENT;
    END

   IF CURSOR_STATUS ('LOCAL', 'Recoup_Cur') IN (0, 1)
    BEGIN
     CLOSE Recoup_Cur;

     DEALLOCATE Recoup_Cur;
    END

   IF CURSOR_STATUS ('LOCAL', 'Cpno_CUR') IN (0, 1)
    BEGIN
     CLOSE Cpno_CUR;

     DEALLOCATE Cpno_CUR;
    END;

   IF CURSOR_STATUS ('LOCAL', 'Pofl_CUR') IN (0, 1)
    BEGIN
     CLOSE Pofl_CUR;

     DEALLOCATE Pofl_CUR;
    END;

   IF CURSOR_STATUS ('LOCAL', 'RecoupAct_CUR') IN (0, 1)
    BEGIN
     CLOSE RecoupAct_CUR;

     DEALLOCATE RecoupAct_CUR;
    END;

   --Check for Exception information to log the description text based on the error
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
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Lc_Space_TEXT,
    @As_ExecLocation_TEXT         = @Ls_Sql_TEXT,
    @An_ProcessedRecordCount_QNTY =@Ln_ProcessedRecordCount_QNTY,
    @As_ListKey_TEXT              = @Ls_Sqldata_TEXT,
    @As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE               = @Lc_StatusAbnormalend_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT;

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH
 END


GO
