/****** Object:  StoredProcedure [dbo].[BATCH_FIN_RELEASE_RECEIPT$SP_SNFX_HOLD_ALERT]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_FIN_RELEASE_RECEIPT$SP_SNFX_HOLD_ALERT 
Programmer Name 	: IMP Team
Description			: This Procedure used for SNFX Hold Alert for Case Worker if the hold amount greater than 
					  or equal to 2 month MSO
Frequency			: 'DAILY'
Developed On		: 03/05/2012
Called BY			: BATCH_FIN_RELEASE_RECEIPT$SP_RELEASE_RECEIPT  
Called On			: 
--------------------------------------------------------------------------------------------------------------------
Modified BY			:
Modified On			:
Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_FIN_RELEASE_RECEIPT$SP_SNFX_HOLD_ALERT]
 @Ad_Run_DATE              DATE OUTPUT,
 @Ac_Job_ID                CHAR(7) OUTPUT,
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Li_NewExtractRequestedIsCompletedForComponents5970_NUMB INT = 5970,
          @Lc_Yes_INDC                                             CHAR (1) = 'Y',
          @Lc_No_INDC                                              CHAR (1) = 'N',
          @Lc_StatusReceiptHeld_CODE                               CHAR (1) = 'H',
          @Lc_TypePostingCase_CODE                                 CHAR (1) = 'C',
          @Lc_TypePostingPayor_CODE                                CHAR (1) = 'P',
          @Lc_CaseMemberStatusActive_CODE                          CHAR (1) = 'A',
          @Lc_CaseRelationshipNcp_CODE                             CHAR (1) = 'A',
          @Lc_CaseRelationshipPutFather_CODE                       CHAR (1) = 'P',
          @Lc_StatusFailed_CODE                                    CHAR (1) = 'F',
          @Lc_Space_TEXT                                           CHAR (1) = ' ',
          @Lc_StatusSuccess_CODE                                   CHAR (1) = 'S',
          @Lc_CaseCategory_CODE                                    CHAR (2) = 'FM',
          @Lc_HoldReasonStatusSnfx_CODE                            CHAR (4) = 'SNFX',
          @Lc_ActivityMajorCase_CODE                               CHAR (4) = 'CASE',
          @Lc_ActivityMinorAsfnx_CODE                              CHAR (5) = 'ASNFX',
          @Lc_BatchRunUser_TEXT                                    CHAR (30) = 'BATCH',
          @Ls_Procedure_NAME                                       VARCHAR (100) = 'SP_SNFX_HOLD_ALERT',
          @Ld_Low_DATE                                             DATE = '01/01/0001',
          @Ld_High_DATE                                            DATE = '12/31/9999';
  DECLARE @Ln_Rowcount_QNTY            NUMERIC(9),
          @Ln_Topic_IDNO               NUMERIC (10),
          @Ln_Error_NUMB               NUMERIC (11),
          @Ln_ErrorLine_NUMB           NUMERIC (11),
          @Ln_TransactionEventSeq_NUMB NUMERIC (19),
          @Li_FetchStatus_QNTY         SMALLINT,
          @Lc_Msg_CODE                 CHAR (5),
          @Lc_Worker_ID                CHAR (30),
          @Ls_Sql_TEXT                 VARCHAR (100),
          @Ls_Sqldata_TEXT             VARCHAR (1000),
          @Ls_ErrorMessage_TEXT        VARCHAR (4000),
          @Ls_DescriptionError_TEXT    VARCHAR (4000),
          @Ld_SysTemp_DATE             DATE;
  DECLARE @Ln_SnfxCur_PayorMCI_IDNO NUMERIC(10),
          @Ln_SnfxCur_Case_IDNO     NUMERIC(6),
          @Ln_SnfxCur_Receipt_AMNT  NUMERIC(11, 2),
          @Lc_SnfxCur_Alert_INDC    CHAR(1);

  BEGIN TRY
   SET @Ac_Msg_CODE = '';
   SET @As_DescriptionError_TEXT = '';
   SET @Ad_Run_DATE = ISNULL(@Ad_Run_DATE, dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME());
   SET @Ac_Job_ID = ISNULL(@Ac_Job_ID, 'DEB0550');
   SET @Ld_SysTemp_DATE =  CONVERT(VARCHAR(10),dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),101);
   SET @Ls_Sql_TEXT = ' BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT';
   SET @Ls_Sqldata_TEXT = 'Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT,'')+ ', Process_ID = ' + ISNULL(@Ac_Job_ID,'')+ ', EffectiveEvent_DATE = ' + ISNULL(CAST( @Ld_SysTemp_DATE AS VARCHAR ),'')+ ', Note_INDC = ' + ISNULL(@Lc_No_INDC,'')+ ', EventFunctionalSeq_NUMB = ' + ISNULL(CAST( @Li_NewExtractRequestedIsCompletedForComponents5970_NUMB AS VARCHAR ),'');

   EXECUTE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
    @Ac_Worker_ID                = @Lc_BatchRunUser_TEXT,
    @Ac_Process_ID               = @Ac_Job_ID,
    @Ad_EffectiveEvent_DATE      = @Ld_SysTemp_DATE,
    @Ac_Note_INDC                = @Lc_No_INDC,
    @An_EventFunctionalSeq_NUMB  = @Li_NewExtractRequestedIsCompletedForComponents5970_NUMB,
    @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
    @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT    = @Ls_ErrorMessage_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR(50001,16,1);
    END

   DECLARE Snfx_CUR INSENSITIVE CURSOR FOR
    SELECT f.PayorMCI_IDNO,
           f.Case_IDNO,
           f.Receipt_AMNT,
           f.Alert_INDC
      FROM (SELECT q.PayorMCI_IDNO,
                   q.Case_IDNO,
                   q.Receipt_AMNT,
                   -- If the hold amount greater than or equal to 2 month MSO then Alert_INDC is equal to 'Y' else 'N'
                   CASE
                    WHEN q.Receipt_AMNT >= (dbo.BATCH_COMMON$SF_GET_OBLIGATION_AMT(q.Case_IDNO, CONVERT(VARCHAR(10),dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),101)) * 2)
                     THEN @Lc_Yes_INDC
                    ELSE @Lc_No_INDC
                   END AS Alert_INDC
              FROM (SELECT v.PayorMCI_IDNO,
                           v.Case_IDNO,
                           SUM(v.ToDistribute_AMNT) Receipt_AMNT
                      FROM (SELECT a.PayorMCI_IDNO,
                                   a.Case_IDNO,
                                   SUM(a.ToDistribute_AMNT) ToDistribute_AMNT
                              FROM RCTH_Y1 a
                             WHERE a.StatusReceipt_CODE = @Lc_StatusReceiptHeld_CODE
                               AND a.ReasonStatus_CODE = @Lc_HoldReasonStatusSnfx_CODE
                               AND a.Distribute_DATE = @Ld_Low_DATE
                               AND a.EndValidity_DATE = @Ld_High_DATE
                               AND a.Batch_DATE < @Ad_Run_DATE
                               AND a.TypePosting_CODE = @Lc_TypePostingCase_CODE
                             GROUP BY a.PayorMCI_IDNO,
                                      a.Case_IDNO
                            UNION ALL
                            SELECT a.PayorMCI_IDNO,
                                   b.Case_IDNO,
                                   a.ToDistribute_AMNT
                              FROM (SELECT a.PayorMCI_IDNO,
                                           SUM(a.ToDistribute_AMNT) ToDistribute_AMNT
                                      FROM RCTH_Y1 a
                                     WHERE a.StatusReceipt_CODE = @Lc_StatusReceiptHeld_CODE
                                       AND a.ReasonStatus_CODE = @Lc_HoldReasonStatusSnfx_CODE
                                       AND a.Distribute_DATE = @Ld_Low_DATE
                                       AND a.EndValidity_DATE = @Ld_High_DATE
                                       AND a.Batch_DATE < @Ad_Run_DATE
                                       AND a.TypePosting_CODE = @Lc_TypePostingPayor_CODE
                                     GROUP BY a.PayorMCI_IDNO) a,
                                   CMEM_Y1 b
                             WHERE a.PayorMCI_IDNO = b.MemberMci_IDNO
                               AND b.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
                               AND b.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE)) v
                     GROUP BY v.PayorMCI_IDNO,
                              v.Case_IDNO) q) f
     WHERE f.Alert_INDC = @Lc_Yes_INDC;

   SET @Ls_Sql_TEXT = 'OPEN Snfx_CUR';
   SET @Ls_Sqldata_TEXT = '';

   OPEN Snfx_CUR;

   SET @Ls_Sql_TEXT = 'FETCH Snfx_CUR - 1';
   SET @Ls_Sqldata_TEXT = '';

   FETCH NEXT FROM Snfx_CUR INTO @Ln_SnfxCur_PayorMCI_IDNO, @Ln_SnfxCur_Case_IDNO, @Ln_SnfxCur_Receipt_AMNT, @Lc_SnfxCur_Alert_INDC;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
   -- SNFX cursor started
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
     SET @Ls_Sql_TEXT = 'SELECT CASE_Y1 - Worker_ID';
     SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + ISNULL(CAST(@Ln_SnfxCur_Case_IDNO AS VARCHAR), '');

     SELECT @Lc_Worker_ID = c.Worker_ID
       FROM CASE_Y1 c
      WHERE c.Case_IDNO = @Ln_SnfxCur_Case_IDNO;

     SET @Ln_Rowcount_QNTY = @@ROWCOUNT;

     IF @Ln_Rowcount_QNTY = 0
      BEGIN
       SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
       SET @As_DescriptionError_TEXT = ISNULL(@Ls_Sql_TEXT, '') + ISNULL(@Lc_Space_TEXT, '') + ISNULL(@Ls_Sqldata_TEXT, '');

       RETURN;
      END

     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_ACTIVITY';
     SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_SnfxCur_Case_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_SnfxCur_PayorMCI_IDNO AS VARCHAR), '') + ', ActivityMajor_CODE = ' + ISNULL(@Lc_ActivityMajorCase_CODE, '') + ', ActivityMinor_CODE = ' + ISNULL(@Lc_ActivityMinorAsfnx_CODE, '') + ', Subsystem_CODE = ' + ISNULL(@Lc_CaseCategory_CODE, '') + ', TransactionEventSeq_NUMB = ' + ISNULL (CAST (@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', WorkerUpdate_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', WorkerDelegate_ID = ' + ISNULL(@Lc_Worker_ID, '') + ', Run_DATE = ' + ISNULL (CAST (@Ad_Run_DATE AS VARCHAR), '');

     EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
      @An_Case_IDNO                = @Ln_SnfxCur_Case_IDNO,
      @An_MemberMCI_IDNO           = @Ln_SnfxCur_PayorMCI_IDNO,
      @Ac_ActivityMajor_CODE       = @Lc_ActivityMajorCase_CODE,
      @Ac_ActivityMinor_CODE       = @Lc_ActivityMinorAsfnx_CODE,
      @Ac_Subsystem_CODE           = @Lc_CaseCategory_CODE,
      @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
      @Ac_WorkerUpdate_ID          = @Lc_BatchRunUser_TEXT,
      @Ac_WorkerDelegate_ID        = @Lc_Worker_ID,
      @Ad_Run_DATE                 = @Ad_Run_DATE,
      @An_Topic_IDNO               = @Ln_Topic_IDNO OUTPUT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT    = @Ls_ErrorMessage_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END
     ELSE IF @Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
      BEGIN
       SET @Ac_Msg_CODE = @Lc_Msg_CODE;

       RAISERROR (50001,16,1);
      END

     IF @Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END

     SET @Ls_Sql_TEXT = 'FETCH Snfx_CUR- 2';
     SET @Ls_Sqldata_TEXT = '';

     FETCH NEXT FROM Snfx_CUR INTO @Ln_SnfxCur_PayorMCI_IDNO, @Ln_SnfxCur_Case_IDNO, @Ln_SnfxCur_Receipt_AMNT, @Lc_SnfxCur_Alert_INDC;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END

   CLOSE Snfx_CUR;

   DEALLOCATE Snfx_CUR;
  END TRY

  BEGIN CATCH
   BEGIN
    IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
     BEGIN
      SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
     END
	
	IF CURSOR_STATUS('Local', 'Snfx_CUR') IN (0, 1)
    BEGIN
     CLOSE Snfx_CUR;
     DEALLOCATE Snfx_CUR;
    END
	
    SET @Ln_Error_NUMB = ERROR_NUMBER ();

    IF @Ln_Error_NUMB <> 50001
     BEGIN
      SET @Ln_ErrorLine_NUMB = ERROR_LINE ();
      SET @Ls_ErrorMessage_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
     END

    EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
     @As_Procedure_NAME        = @Ls_Procedure_NAME,
     @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
     @As_Sql_TEXT              = @Ls_Sql_TEXT,
     @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
     @An_Error_NUMB            = @Ln_Error_NUMB,
     @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
     @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

    SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
   END
  END CATCH
 END


GO
