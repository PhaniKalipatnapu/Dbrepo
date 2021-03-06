/****** Object:  StoredProcedure [dbo].[BATCH_BI_MAPCM$SP_PROCESS_BITABLES5A]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_BI_MAPCM$SP_PROCESS_BITABLES5A
Programmer Name	:	IMP Team.
Description		:	This process loads the data from staging tables into BI tables.
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
CREATE PROCEDURE [dbo].[BATCH_BI_MAPCM$SP_PROCESS_BITABLES5A]
 @An_RecordCount_NUMB      NUMERIC(6) OUTPUT,
 @Ac_Msg_CODE              CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Li_RowCount_QNTY  INT = 0,
          @Lc_Space_TEXT     CHAR(1) = ' ',
          @Lc_Failed_CODE    CHAR(1) = 'F',
          @Lc_Success_CODE   CHAR(1) = 'S',
          @Lc_TypeError_CODE CHAR(1) = 'E',
          @Lc_BateError_CODE CHAR(5) = 'E0944',
          @Lc_Job_ID         CHAR(7) = 'DEB1400',
          @Lc_Process_NAME   CHAR(14) = 'BATCH_BI_MAPCM',
          @Ls_Procedure_NAME VARCHAR(50) = 'SP_PROCESS_BITABLES5A';
  DECLARE @Ln_Zero_NUMB             NUMERIC(1) = 0,
          @Ln_Error_NUMB            NUMERIC(11),
          @Ln_ErrorLine_NUMB        NUMERIC(11),
          @Lc_Msg_CODE              CHAR(1),
          @Ls_Sql_TEXT              VARCHAR(100),
          @Ls_Sqldata_TEXT          VARCHAR(1000),
          @Ls_ErrorMessage_TEXT     VARCHAR(4000),
          @Ls_DescriptionError_TEXT VARCHAR(4000),
          @Ld_Start_DATE            DATETIME2;

  BEGIN TRY
   SET @Ac_Msg_CODE = @Lc_Success_CODE;
   SET @As_DescriptionError_TEXT = @Lc_Space_TEXT;
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   SET @Ls_Sql_TEXT = 'DELETE FROM BUCOL_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   DELETE FROM BUCOL_Y1;

   SET @Ls_Sql_TEXT = 'INSERT INTO BUCOL_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   INSERT BUCOL_Y1
          (Batch_DATE,
           SourceBatch_CODE,
           Batch_NUMB,
           SeqReceipt_NUMB,
           SourceReceipt_CODE,
           Case_IDNO,
           PayorMCI_IDNO,
           UndistCollection_AMNT,
           Receipt_DATE,
           Record_DATE,
           StatusReceipt_CODE,
           EventGlobalBeginSeq_NUMB,
           ReasonStatus_CODE,
           Receipt_AMNT)
   SELECT a.Batch_DATE,
          a.SourceBatch_CODE,
          a.Batch_NUMB,
          a.SeqReceipt_NUMB,
          a.SourceReceipt_CODE,
          a.Case_IDNO,
          a.PayorMCI_IDNO,
          a.UndistCollection_AMNT,
          a.Receipt_DATE,
          a.Record_DATE,
          a.StatusReceipt_CODE,
          a.EventGlobalBeginSeq_NUMB,
          a.ReasonStatus_CODE,
          a.Receipt_AMNT
     FROM BPUCOL_Y1 a;

   SET @Li_RowCount_QNTY = @@ROWCOUNT;

   IF (@Li_RowCount_QNTY = 0)
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG';
     SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + ISNULL(@Lc_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Start_DATE AS VARCHAR), '') + ', TypeError_CODE = ' + ISNULL(@Lc_TypeError_CODE, '') + ', Line_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Error_CODE = ' + ISNULL(@Lc_BateError_CODE, '') + ', DescriptionError_TEXT = ' + ISNULL(@Ls_DescriptionError_TEXT, '');

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Lc_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Start_DATE,
      @Ac_TypeError_CODE           = @Lc_TypeError_CODE,
      @An_Line_NUMB                = @Ln_Zero_NUMB,
      @Ac_Error_CODE               = @Lc_BateError_CODE,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
      @As_ListKey_TEXT             = @Ls_SqlData_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_Failed_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END
    END

   SET @Ls_Sql_TEXT = 'DELETE FROM BRCTH_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   DELETE FROM BRCTH_Y1;

   SET @Ls_Sql_TEXT = 'INSERT INTO BRCTH_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   INSERT BRCTH_Y1
          (Case_IDNO,
           EndOfMonth_DATE,
           Receipt_AMNT,
           OrderSeq_NUMB,
           ObligationSeq_NUMB,
           Batch_DATE,
           SourceBatch_CODE,
           Batch_NUMB,
           SeqReceipt_NUMB,
           SourceReceipt_CODE,
           PayorMCI_IDNO,
           ToDistribute_AMNT,
           StatusReceipt_CODE,
           Receipt_DATE)
   SELECT a.Case_IDNO,
          a.EndOfMonth_DATE,
          a.Receipt_AMNT,
          a.OrderSeq_NUMB,
          a.ObligationSeq_NUMB,
          a.Batch_DATE,
          a.SourceBatch_CODE,
          a.Batch_NUMB,
          a.SeqReceipt_NUMB,
          a.SourceReceipt_CODE,
          a.PayorMCI_IDNO,
          a.ToDistribute_AMNT,
          a.StatusReceipt_CODE,
          a.Receipt_DATE
     FROM BPRCTH_Y1 a;

   SET @Li_RowCount_QNTY = @@ROWCOUNT;

   IF (@Li_RowCount_QNTY = 0)
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG';
     SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + ISNULL(@Lc_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Start_DATE AS VARCHAR), '') + ', TypeError_CODE = ' + ISNULL(@Lc_TypeError_CODE, '') + ', Line_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Error_CODE = ' + ISNULL(@Lc_BateError_CODE, '') + ', DescriptionError_TEXT = ' + ISNULL(@Ls_DescriptionError_TEXT, '');

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Lc_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Start_DATE,
      @Ac_TypeError_CODE           = @Lc_TypeError_CODE,
      @An_Line_NUMB                = @Ln_Zero_NUMB,
      @Ac_Error_CODE               = @Lc_BateError_CODE,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
      @As_ListKey_TEXT             = @Ls_SqlData_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_Failed_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END
    END

   SET @Ls_Sql_TEXT = 'DELETE FROM BDHLD_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   DELETE FROM BDHLD_Y1;

   SET @Ls_Sql_TEXT = 'INSERT INTO BDHLD_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   INSERT BDHLD_Y1
          (Case_IDNO,
           OrderSeq_NUMB,
           ObligationSeq_NUMB,
           Transaction_DATE,
           Batch_DATE,
           SourceBatch_CODE,
           Batch_NUMB,
           SeqReceipt_NUMB,
           TypeHold_CODE,
           Transaction_AMNT,
           Unique_IDNO,
           ReasonStatus_CODE,
           PayorMCI_IDNO,
           Receipt_DATE,
           EventGlobalSupportSeq_NUMB)
   SELECT a.Case_IDNO,
          a.OrderSeq_NUMB,
          a.ObligationSeq_NUMB,
          a.Transaction_DATE,
          a.Batch_DATE,
          a.SourceBatch_CODE,
          a.Batch_NUMB,
          a.SeqReceipt_NUMB,
          a.TypeHold_CODE,
          a.Transaction_AMNT,
          a.Unique_IDNO,
          a.ReasonStatus_CODE,
          a.PayorMCI_IDNO,
          a.Receipt_DATE,
          a.EventGlobalSupportSeq_NUMB
     FROM BPDHLD_Y1 a;

   SET @Li_RowCount_QNTY = @@ROWCOUNT;

   IF (@Li_RowCount_QNTY = 0)
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG';
     SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + ISNULL(@Lc_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Start_DATE AS VARCHAR), '') + ', TypeError_CODE = ' + ISNULL(@Lc_TypeError_CODE, '') + ', Line_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Error_CODE = ' + ISNULL(@Lc_BateError_CODE, '') + ', DescriptionError_TEXT = ' + ISNULL(@Ls_DescriptionError_TEXT, '');

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Lc_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Start_DATE,
      @Ac_TypeError_CODE           = @Lc_TypeError_CODE,
      @An_Line_NUMB                = @Ln_Zero_NUMB,
      @Ac_Error_CODE               = @Lc_BateError_CODE,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
      @As_ListKey_TEXT             = @Ls_SqlData_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_Failed_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END
    END

   SET @Ls_Sql_TEXT = 'DELETE FROM BUSEM_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   DELETE FROM BUSEM_Y1;

   SET @Ls_Sql_TEXT = 'INSERT INTO BUSEM_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   INSERT BUSEM_Y1
          (Worker_ID,
           First_NAME,
           Middle_NAME,
           Last_NAME,
           Suffix_NAME,
           Contact_EML,
           WorkerTitle_CODE,
           WorkerSubTitle_CODE,
           Organization_NAME,
           BarCode_IDNO,
           BeginEmployment_DATE,
           EndEmployment_DATE,
           BeginValidity_DATE,
           Update_DTTM,
           WorkerUpdate_ID)
   SELECT a.Worker_ID,
          a.First_NAME,
          a.Middle_NAME,
          a.Last_NAME,
          a.Suffix_NAME,
          a.Contact_EML,
          a.WorkerTitle_CODE,
          a.WorkerSubTitle_CODE,
          a.Organization_NAME,
          a.BarCode_IDNO,
          a.BeginEmployment_DATE,
          a.EndEmployment_DATE,
          a.BeginValidity_DATE,
          a.Update_DTTM,
          a.WorkerUpdate_ID
     FROM BPUSEM_Y1 a;

   SET @Li_RowCount_QNTY = @@ROWCOUNT;

   IF (@Li_RowCount_QNTY = 0)
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG';
     SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + ISNULL(@Lc_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Start_DATE AS VARCHAR), '') + ', TypeError_CODE = ' + ISNULL(@Lc_TypeError_CODE, '') + ', Line_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Error_CODE = ' + ISNULL(@Lc_BateError_CODE, '') + ', DescriptionError_TEXT = ' + ISNULL(@Ls_DescriptionError_TEXT, '');

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Lc_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Start_DATE,
      @Ac_TypeError_CODE           = @Lc_TypeError_CODE,
      @An_Line_NUMB                = @Ln_Zero_NUMB,
      @Ac_Error_CODE               = @Lc_BateError_CODE,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
      @As_ListKey_TEXT             = @Ls_SqlData_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_Failed_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END
    END

   SET @An_RecordCount_NUMB = @An_RecordCount_NUMB + @Li_RowCount_QNTY;
   SET @Ls_Sql_TEXT = 'DELETE FROM BSORD_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   DELETE FROM BSORD_Y1;

   SET @Ls_Sql_TEXT = 'INSERT INTO BSORD_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   INSERT BSORD_Y1
          (Case_IDNO,
           Order_IDNO,
           OrderSeq_NUMB,
           OrderMedical_CODE,
           OrderEffective_DATE,
           OrderIssued_DATE,
           Payback_AMNT,
           FreqPayback_CODE,
           File_ID,
           InsOrdered_CODE,
           StateControl_CODE,
           StatusControl_CODE,
           OrderControl_ID,
           Judge_ID,
           BeginValidity_DATE)
   SELECT DISTINCT
          a.Case_IDNO,
          a.Order_IDNO,
          a.OrderSeq_NUMB,
          a.OrderMedical_CODE,
          a.OrderEffective_DATE,
          a.OrderIssued_DATE,
          a.Payback_AMNT,
          a.FreqPayback_CODE,
          a.File_ID,
          a.InsOrdered_CODE,
          a.StateControl_CODE,
          a.StatusControl_CODE,
          a.OrderControl_ID,
          a.Judge_ID,
          a.BeginValidity_DATE
     FROM BPSORD_Y1 a;

   SET @Li_RowCount_QNTY = @@ROWCOUNT;

   IF (@Li_RowCount_QNTY = 0)
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG';
     SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + ISNULL(@Lc_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Start_DATE AS VARCHAR), '') + ', TypeError_CODE = ' + ISNULL(@Lc_TypeError_CODE, '') + ', Line_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Error_CODE = ' + ISNULL(@Lc_BateError_CODE, '') + ', DescriptionError_TEXT = ' + ISNULL(@Ls_DescriptionError_TEXT, '');

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Lc_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Start_DATE,
      @Ac_TypeError_CODE           = @Lc_TypeError_CODE,
      @An_Line_NUMB                = @Ln_Zero_NUMB,
      @Ac_Error_CODE               = @Lc_BateError_CODE,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
      @As_ListKey_TEXT             = @Ls_SqlData_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_Failed_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END
    END

   SET @Ls_Sql_TEXT = 'DELETE FROM BLSUP_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   DELETE FROM BLSUP_Y1;

   SET @Ls_Sql_TEXT = 'INSERT INTO BLSUP_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   INSERT BLSUP_Y1
          (Case_IDNO,
           SupportYearMonth_NUMB,
           TanfArrear_AMNT,
           NonTanfArrear_AMNT,
           IvefArrear_AMNT,
           MedicAidArrear_AMNT,
           NonIvdArrear_AMNT,
           NffcArrear_AMNT,
           NffmArrear_AMNT,
           IvA1Arrear_AMNT,
           CpArrear_AMNT,
           TotalOwed_AMNT,
           TotalPaid_AMNT,
           OrderSeq_NUMB,
           ObligationSeq_NUMB,
           OweTotCurSup_AMNT,
           TypeDebt_CODE,
           Distribute_DATE,
           Batch_DATE,
           SourceBatch_CODE,
           Batch_NUMB,
           SeqReceipt_NUMB,
           TypeRecord_CODE,
           EventGlobalSeq_NUMB,
           CurSupOwed_AMNT,
           AppTotCurSup_AMNT,
           OweTotExptPay_AMNT,
           AppTotExptPay_AMNT)
   SELECT a.Case_IDNO,
          a.SupportYearMonth_NUMB,
          a.TanfArrear_AMNT,
          a.NonTanfArrear_AMNT,
          a.IvefArrear_AMNT,
          a.MedicAidArrear_AMNT,
          a.NonIvdArrear_AMNT,
          a.NffcArrear_AMNT,
          a.NffmArrear_AMNT,
          a.IvA1Arrear_AMNT,
          a.CpArrear_AMNT,
          a.TotalOwed_AMNT,
          a.TotalPaid_AMNT,
          a.OrderSeq_NUMB,
          a.ObligationSeq_NUMB,
          a.OweTotCurSup_AMNT,
          a.TypeDebt_CODE,
          a.Distribute_DATE,
          a.Batch_DATE,
          a.SourceBatch_CODE,
          a.Batch_NUMB,
          a.SeqReceipt_NUMB,
          a.TypeRecord_CODE,
          a.EventGlobalSeq_NUMB,
          a.CurSupOwed_AMNT,
          a.AppTotCurSup_AMNT,
          a.OweTotExptPay_AMNT,
          a.AppTotExptPay_AMNT
     FROM BPLSUP_Y1 a;

   SET @Li_RowCount_QNTY = @@ROWCOUNT;

   IF (@Li_RowCount_QNTY = 0)
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG';
     SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + ISNULL(@Lc_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Start_DATE AS VARCHAR), '') + ', TypeError_CODE = ' + ISNULL(@Lc_TypeError_CODE, '') + ', Line_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Error_CODE = ' + ISNULL(@Lc_BateError_CODE, '') + ', DescriptionError_TEXT = ' + ISNULL(@Ls_DescriptionError_TEXT, '');

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Lc_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Start_DATE,
      @Ac_TypeError_CODE           = @Lc_TypeError_CODE,
      @An_Line_NUMB                = @Ln_Zero_NUMB,
      @Ac_Error_CODE               = @Lc_BateError_CODE,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
      @As_ListKey_TEXT             = @Ls_SqlData_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_Failed_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END
    END

   SET @Ls_Sql_TEXT = 'DELETE FROM BAHIS_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   DELETE FROM BAHIS_Y1;

   SET @Ls_Sql_TEXT = 'INSERT INTO BAHIS_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   INSERT BAHIS_Y1
          (Case_IDNO,
           MemberMci_IDNO,
           TypeAddress_CODE,
           Attn_ADDR,
           Line1_ADDR,
           Line2_ADDR,
           Line3_ADDR,
           EndOfMonth_DATE,
           EndAhis_DATE,
           Action_CODE,
           TransactionEventSeq_NUMB)
   SELECT a.Case_IDNO,
          a.MemberMci_IDNO,
          a.TypeAddress_CODE,
          a.Attn_ADDR,
          a.Line1_ADDR,
          a.Line2_ADDR,
          a.Line3_ADDR,
          a.EndOfMonth_DATE,
          a.EndAhis_DATE,
          a.Action_CODE,
          a.TransactionEventSeq_NUMB
     FROM BPAHIS_Y1 a;

   SET @Li_RowCount_QNTY = @@ROWCOUNT;

   IF (@Li_RowCount_QNTY = 0)
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG';
     SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + ISNULL(@Lc_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Start_DATE AS VARCHAR), '') + ', TypeError_CODE = ' + ISNULL(@Lc_TypeError_CODE, '') + ', Line_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Error_CODE = ' + ISNULL(@Lc_BateError_CODE, '') + ', DescriptionError_TEXT = ' + ISNULL(@Ls_DescriptionError_TEXT, '');

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Lc_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Start_DATE,
      @Ac_TypeError_CODE           = @Lc_TypeError_CODE,
      @An_Line_NUMB                = @Ln_Zero_NUMB,
      @Ac_Error_CODE               = @Lc_BateError_CODE,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
      @As_ListKey_TEXT             = @Ls_SqlData_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_Failed_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END
    END

   SET @Ls_Sql_TEXT = 'DELETE FROM BAHSC_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   DELETE FROM BAHSC_Y1;

   SET @Ls_Sql_TEXT = 'INSERT INTO BAHSC_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   INSERT BAHSC_Y1
          (Case_IDNO,
           MemberMci_IDNO,
           TypeAddress_CODE,
           Attn_ADDR,
           Line1_ADDR,
           Line2_ADDR,
           Line3_ADDR,
           EndOfMonth_DATE,
           EndAhis_DATE,
           Action_CODE,
           TransactionEventSeq_NUMB)
   SELECT a.Case_IDNO,
          a.MemberMci_IDNO,
          a.TypeAddress_CODE,
          a.Attn_ADDR,
          a.Line1_ADDR,
          a.Line2_ADDR,
          a.Line3_ADDR,
          a.EndOfMonth_DATE,
          a.EndAhis_DATE,
          a.Action_CODE,
          a.TransactionEventSeq_NUMB
     FROM BPAHSC_Y1 a;

   SET @Li_RowCount_QNTY = @@ROWCOUNT;

   IF (@Li_RowCount_QNTY = 0)
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG';
     SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + ISNULL(@Lc_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Start_DATE AS VARCHAR), '') + ', TypeError_CODE = ' + ISNULL(@Lc_TypeError_CODE, '') + ', Line_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Error_CODE = ' + ISNULL(@Lc_BateError_CODE, '') + ', DescriptionError_TEXT = ' + ISNULL(@Ls_DescriptionError_TEXT, '');

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Lc_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Start_DATE,
      @Ac_TypeError_CODE           = @Lc_TypeError_CODE,
      @An_Line_NUMB                = @Ln_Zero_NUMB,
      @Ac_Error_CODE               = @Lc_BateError_CODE,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
      @As_ListKey_TEXT             = @Ls_SqlData_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_Failed_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END
    END

   SET @Ls_Sql_TEXT = 'DELETE FROM BEHIS_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   DELETE FROM BEHIS_Y1;

   SET @Ls_Sql_TEXT = 'INSERT RECORDS INTO BEHIS_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   INSERT BEHIS_Y1
          (Case_IDNO,
           MemberMci_IDNO,
           EndOfMonth_DATE,
           MonthlyNetIncome_AMNT,
           EhisEnd_DATE,
           Action_CODE,
           OthpPartyEmpl_IDNO,
           TransactionEventSeq_NUMB,
           BeginEmployment_DATE)
   SELECT a.Case_IDNO,
          a.MemberMci_IDNO,
          a.EndOfMonth_DATE,
          a.MonthlyNetIncome_AMNT,
          a.EhisEnd_DATE,
          a.Action_CODE,
          a.OthpPartyEmpl_IDNO,
          a.TransactionEventSeq_NUMB,
          a.BeginEmployment_DATE
     FROM BPEHIS_Y1 a;

   SET @Li_RowCount_QNTY = @@ROWCOUNT;

   IF (@Li_RowCount_QNTY = 0)
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG';
     SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + ISNULL(@Lc_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Start_DATE AS VARCHAR), '') + ', TypeError_CODE = ' + ISNULL(@Lc_TypeError_CODE, '') + ', Line_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Error_CODE = ' + ISNULL(@Lc_BateError_CODE, '') + ', DescriptionError_TEXT = ' + ISNULL(@Ls_DescriptionError_TEXT, '');

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Lc_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Start_DATE,
      @Ac_TypeError_CODE           = @Lc_TypeError_CODE,
      @An_Line_NUMB                = @Ln_Zero_NUMB,
      @Ac_Error_CODE               = @Lc_BateError_CODE,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
      @As_ListKey_TEXT             = @Ls_SqlData_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_Failed_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END
    END

   SET @An_RecordCount_NUMB = @An_RecordCount_NUMB + (SELECT COUNT(*)
                                                        FROM (SELECT Case_IDNO
                                                                FROM BUCOL_Y1
                                                              UNION
                                                              SELECT Case_IDNO
                                                                FROM BRCTH_Y1
                                                              UNION
                                                              SELECT Case_IDNO
                                                                FROM BDHLD_Y1
                                                              UNION
                                                              SELECT Case_IDNO
                                                                FROM BSORD_Y1
                                                              UNION
                                                              SELECT Case_IDNO
                                                                FROM BLSUP_Y1
                                                              UNION
                                                              SELECT Case_IDNO
                                                                FROM BAHIS_Y1
                                                              UNION
                                                              SELECT Case_IDNO
                                                                FROM BAHSC_Y1
                                                              UNION
                                                              SELECT Case_IDNO
                                                                FROM BEHIS_Y1) AS t);
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_Failed_CODE;
   SET @An_RecordCount_NUMB = 0;
   SET @Ln_Error_NUMB = ERROR_NUMBER ();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE ();
   SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_ErrorMessage_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END

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
