/****** Object:  StoredProcedure [dbo].[BATCH_FIN_DISBURSEMENT$SP_CPFL_INSERT]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_FIN_DISBURSEMENT$SP_CPFL_INSERT
Programmer Name 	: IMP Team
Description			: Procedure IRS Offset Fee assessment
Frequency           : 'DAILY'
Developed On        : 01/31/2012
Called BY			: None
Called On			: 
--------------------------------------------------------------------------------------------------------------------
Modified BY			:
Modified On			:
Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_FIN_DISBURSEMENT$SP_CPFL_INSERT] (
 @Ac_FeeType_CODE               CHAR(6),
 @Ac_Transaction_CODE           CHAR(4),
 @An_Transaction_AMNT           NUMERIC(11, 2),
 @An_Case_IDNO                  NUMERIC(6),
 @Ac_CheckRecipient_ID          CHAR(10),
 @Ac_CheckRecipient_CODE        CHAR(1),
 @Ad_Run_DATE                   DATE,
 @An_OrderSeq_NUMB              NUMERIC(2),
 @An_ObligationSeq_NUMB         NUMERIC(2),
 @Ac_TypeDisburse_CODE          CHAR(5),
 @Ad_Batch_DATE                 DATE,
 @An_Batch_NUMB                 NUMERIC(4),
 @Ac_SourceBatch_CODE           CHAR(3),
 @An_SeqReceipt_NUMB            NUMERIC(6),
 @Ac_Job_ID                     CHAR (7),
 @An_EventGlobalSeq_NUMB        NUMERIC(19),
 @An_EventGlobalSupportSeq_NUMB NUMERIC(19),
 @An_AssessedTot_AMNT           NUMERIC(11, 2) OUTPUT,
 @An_RecoveredTot_AMNT          NUMERIC(11, 2) OUTPUT,
 @Ac_Msg_CODE                   CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT      VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Ln_FunctionalEventSeq2235_NUMB NUMERIC(4) = 2235,
		  @Lc_StatusSuccess_CODE          CHAR(1) = 'S',
          @Lc_StatusFailed_CODE           CHAR(1) = 'F',
          @Lc_No_INDC					  CHAR(1) = 'N',
          @Lc_SubsystemFm_CODE            CHAR(2) = 'FM',
          @Lc_TransactionAsmt_CODE        CHAR(4) = 'ASMT',
          @Lc_CaseMajorActivity_CODE      CHAR(4) = 'CASE',
          @Lc_ActivityMinorDrafa_CODE     CHAR(5) = 'DRAFA',
          @Lc_ActivityMinorSpcfa_CODE     CHAR(5) = 'SPCFA',
          @Lc_BatchRunUser_TEXT           CHAR(5) = 'BATCH',
          @Lc_TypeEntityRctno_CODE        CHAR(5) = 'RCTNO',
          @Lc_TypeEntityCase_CODE         CHAR(5) = 'CASE',
          @Lc_TypeEntityRcpid_CODE        CHAR(5) = 'RCPID',
          @Lc_TypeEntityRcpcd_CODE        CHAR(5) = 'RCPCD',
          @Lc_FeeTypeIrsfee_CODE          CHAR(6) = 'SC',
          @Lc_MonthOct_TEXT				  CHAR(10) = 'October',
          @Lc_MonthNov_TEXT        	      CHAR(10) = 'November',
          @Lc_MonthDec_TEXT				  CHAR(10) = 'December',          
          @Ls_Procedure_NAME              VARCHAR(100) = 'SP_CPFL_INSERT';
  DECLARE @Ln_AssessedYear_NUMB					NUMERIC(4),
		  @Ln_FiscalYear_NUMB					NUMERIC(4),
		  @Ln_AssessedYearInsert_NUMB			NUMERIC(4),
          @Ln_MemberMci_IDNO					NUMERIC(10),
          @Ln_Topic_IDNO						NUMERIC(10) = 0,
          @Ln_AssessedTot_AMNT					NUMERIC(11, 2),
          @Ln_RecoveredTot_AMNT					NUMERIC(11, 2),
          @Ln_Error_NUMB						NUMERIC(11),
          @Ln_ErrorLine_NUMB					NUMERIC(11),
          @Ln_Rowcount_QNTY						NUMERIC(19),
          @Ln_TransactionEventSeq_NUMB			NUMERIC(19),
          @Lc_ActivityMinor_CODE				CHAR(5) = '',
          @Lc_Msg_CODE							CHAR(5),
          @Ls_Sql_TEXT							VARCHAR(100) = '',
          @Ls_SqlData_TEXT						VARCHAR(1000),
          @Ls_ErrorMessage_TEXT					VARCHAR(4000);
  BEGIN TRY
  
   IF @Ac_FeeType_CODE = @Lc_FeeTypeIrsfee_CODE
    BEGIN
     SET @Ls_Sql_TEXT = 'SELECT CPFL_Y1 IRS';
     SET @Ls_SqlData_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(@Ac_CheckRecipient_ID, '') + ', FeeType_CODE = ' + ISNULL(@Ac_FeeType_CODE, '') + ', Batch_DATE = ' + ISNULL(CAST(@Ad_Batch_DATE AS VARCHAR), '') + ', Batch_NUMB = ' + ISNULL(CAST(@An_Batch_NUMB AS VARCHAR), '') + ', SourceBatch_CODE = ' + ISNULL(@Ac_SourceBatch_CODE, '') + ', SeqReceipt_NUMB = ' + ISNULL(CAST(@An_SeqReceipt_NUMB AS VARCHAR), '') + ', Batch_DATE = ' + ISNULL(CAST(@Ad_Batch_DATE AS VARCHAR), '') + ', Batch_NUMB = ' + ISNULL(CAST(@An_Batch_NUMB AS VARCHAR), '') + ', SourceBatch_CODE = ' + ISNULL(@Ac_SourceBatch_CODE, '') + ', SeqReceipt_NUMB = ' + ISNULL(CAST(@An_SeqReceipt_NUMB AS VARCHAR), '');

     SELECT @Ln_AssessedYear_NUMB = AssessedYear_NUMB,
            @Ln_AssessedTot_AMNT = AssessedTot_AMNT,
            @Ln_RecoveredTot_AMNT = RecoveredTot_AMNT
       FROM CPFL_Y1 a
      WHERE a.Case_IDNO = @An_Case_IDNO
        AND a.MemberMci_IDNO = @Ac_CheckRecipient_ID
        AND a.FeeType_CODE = @Ac_FeeType_CODE
        AND a.Batch_DATE = @Ad_Batch_DATE
        AND a.Batch_NUMB = @An_Batch_NUMB
        AND a.SourceBatch_CODE = @Ac_SourceBatch_CODE
        AND a.SeqReceipt_NUMB = @An_SeqReceipt_NUMB
        AND a.Unique_IDNO = (SELECT MAX (Unique_IDNO)
                               FROM CPFL_Y1 b
                              WHERE a.Case_IDNO = b.Case_IDNO
                                AND a.MemberMci_IDNO = b.MemberMci_IDNO
                                AND a.FeeType_CODE = b.FeeType_CODE
                                AND a.Batch_DATE = @Ad_Batch_DATE
                                AND a.Batch_NUMB = @An_Batch_NUMB
                                AND a.SourceBatch_CODE = @Ac_SourceBatch_CODE
                                AND a.SeqReceipt_NUMB = @An_SeqReceipt_NUMB);

     SET @Ln_Rowcount_QNTY = @@ROWCOUNT;

     IF @Ln_Rowcount_QNTY = 0
      BEGIN
       SET @Ln_AssessedTot_AMNT = 0;
       SET @Ln_RecoveredTot_AMNT = 0;
      END

     IF @Ln_AssessedYear_NUMB != SUBSTRING(CONVERT(VARCHAR(4), @Ad_Run_DATE, 112), 1, 4)
      BEGIN
       SET @Ln_AssessedTot_AMNT = 0;
       SET @Ln_RecoveredTot_AMNT = 0;
      END
	 SET @Ln_AssessedYearInsert_NUMB = SUBSTRING(CONVERT(VARCHAR(4), @Ad_Run_DATE, 112), 1, 4)
     SET @Lc_ActivityMinor_CODE = @Lc_ActivityMinorSpcfa_CODE;
    END
   ELSE
    BEGIN

     IF (DATENAME(MONTH, @Ad_Run_DATE) NOT IN (@Lc_MonthOct_TEXT, @Lc_MonthNov_TEXT, @Lc_MonthDec_TEXT))
      BEGIN
       SET @Ln_FiscalYear_NUMB = YEAR(@Ad_Run_DATE)
      END
     ELSE
      BEGIN
       SET @Ln_FiscalYear_NUMB = YEAR(DATEADD(m, 3, @Ad_Run_DATE))
      END;    
    
     SET @Ls_Sql_TEXT = 'SELECT CPFL_Y1';
     SET @Ls_SqlData_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(@Ac_CheckRecipient_ID, '') + ', FeeType_CODE = ' + ISNULL(@Ac_FeeType_CODE, '');

     SELECT @Ln_AssessedYear_NUMB = AssessedYear_NUMB,
            @Ln_AssessedTot_AMNT = AssessedTot_AMNT,
            @Ln_RecoveredTot_AMNT = RecoveredTot_AMNT
       FROM CPFL_Y1 a
      WHERE a.Case_IDNO = @An_Case_IDNO
        AND a.MemberMci_IDNO = @Ac_CheckRecipient_ID
        AND a.FeeType_CODE = @Ac_FeeType_CODE
        AND a.Unique_IDNO = (SELECT MAX (Unique_IDNO)
                               FROM CPFL_Y1 b
                              WHERE a.Case_IDNO = b.Case_IDNO
                                AND a.MemberMci_IDNO = b.MemberMci_IDNO
                                AND a.FeeType_CODE = b.FeeType_CODE);

     SET @Ln_Rowcount_QNTY = @@ROWCOUNT;

     IF @Ln_Rowcount_QNTY = 0
      BEGIN
       SET @Ln_AssessedTot_AMNT = 0;
       SET @Ln_RecoveredTot_AMNT = 0;
      END

     IF @Ln_AssessedYear_NUMB != @Ln_FiscalYear_NUMB 
      BEGIN
       SET @Ln_AssessedTot_AMNT = 0;
       SET @Ln_RecoveredTot_AMNT = 0;
      END
	 SET @Ln_AssessedYearInsert_NUMB = @Ln_FiscalYear_NUMB
     SET @Lc_ActivityMinor_CODE = @Lc_ActivityMinorDrafa_CODE;
    END

   IF @Ac_Transaction_CODE = @Lc_TransactionAsmt_CODE
    BEGIN
     -- Assessed Amount
     SET @An_AssessedTot_AMNT = @Ln_AssessedTot_AMNT + @An_Transaction_AMNT;
     SET @An_RecoveredTot_AMNT = 0;
    END
   ELSE
    BEGIN
     -- Recovered Amount
     SET @An_AssessedTot_AMNT = @Ln_AssessedTot_AMNT;
     SET @An_RecoveredTot_AMNT = @Ln_RecoveredTot_AMNT + @An_Transaction_AMNT;
    END

   SET @Ls_Sql_TEXT = 'INSERT CPFL_Y1 ';
   SET @Ls_SqlData_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '') + ', OrderSeq_NUMB = ' + ISNULL(CAST(@An_OrderSeq_NUMB AS VARCHAR), '') + ', ObligationSeq_NUMB = ' + ISNULL(CAST(@An_ObligationSeq_NUMB AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(@Ac_CheckRecipient_ID, '') + ', FeeType_CODE = ' + ISNULL(@Ac_FeeType_CODE, '') + ', Transaction_CODE = ' + ISNULL(@Ac_Transaction_CODE, '') + ', Transaction_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', Transaction_AMNT = ' + ISNULL(CAST(@An_Transaction_AMNT AS VARCHAR), '') + ', AssessedTot_AMNT = ' + ISNULL(CAST(@An_AssessedTot_AMNT AS VARCHAR), '') + ', RecoveredTot_AMNT = ' + ISNULL(CAST(@An_RecoveredTot_AMNT AS VARCHAR), '') + ', TypeDisburse_CODE = ' + ISNULL(@Ac_TypeDisburse_CODE, '') + ', Batch_DATE = ' + ISNULL(CAST(@Ad_Batch_DATE AS VARCHAR), '') + ', SourceBatch_CODE = ' + ISNULL(@Ac_SourceBatch_CODE, '') + ', Batch_NUMB = ' + ISNULL(CAST(@An_Batch_NUMB AS VARCHAR), '') + ', SeqReceipt_NUMB = ' + ISNULL(CAST(@An_SeqReceipt_NUMB AS VARCHAR), '') + ', EventGlobalSeq_NUMB = ' + ISNULL(CAST(@An_EventGlobalSeq_NUMB AS VARCHAR), '') + ', EventGlobalSupportSeq_NUMB = ' + ISNULL(CAST(@An_EventGlobalSupportSeq_NUMB AS VARCHAR), '');

   INSERT INTO CPFL_Y1
               (Case_IDNO,
                OrderSeq_NUMB,
                ObligationSeq_NUMB,
                MemberMci_IDNO,
                FeeType_CODE,
                AssessedYear_NUMB,
                Transaction_CODE,
                Transaction_DATE,
                Transaction_AMNT,
                AssessedTot_AMNT,
                RecoveredTot_AMNT,
                TypeDisburse_CODE,
                Batch_DATE,
                SourceBatch_CODE,
                Batch_NUMB,
                SeqReceipt_NUMB,
                EventGlobalSeq_NUMB,
                EventGlobalSupportSeq_NUMB)
        VALUES (@An_Case_IDNO,--Case_IDNO
                @An_OrderSeq_NUMB,--OrderSeq_NUMB
                @An_ObligationSeq_NUMB,--ObligationSeq_NUMB
                @Ac_CheckRecipient_ID,--MemberMci_IDNO
                @Ac_FeeType_CODE,--FeeType_CODE
                @Ln_AssessedYearInsert_NUMB,--AssessedYear_NUMB
                @Ac_Transaction_CODE,--Transaction_CODE
                @Ad_Run_DATE,--Transaction_DATE
                @An_Transaction_AMNT,--Transaction_AMNT
                @An_AssessedTot_AMNT,--AssessedTot_AMNT
                @An_RecoveredTot_AMNT,--RecoveredTot_AMNT
                @Ac_TypeDisburse_CODE,--TypeDisburse_CODE
                @Ad_Batch_DATE,--Batch_DATE
                @Ac_SourceBatch_CODE,--SourceBatch_CODE
                @An_Batch_NUMB,--Batch_NUMB
                @An_SeqReceipt_NUMB,--SeqReceipt_NUMB
                @An_EventGlobalSeq_NUMB,--EventGlobalSeq_NUMB
                @An_EventGlobalSupportSeq_NUMB --EventGlobalSupportSeq_NUMB
   );

   SET @Ln_Rowcount_QNTY = @@ROWCOUNT;

   IF @Ln_Rowcount_QNTY != 1
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'CPFL INSERT FAILED';

     RAISERROR(50001,16,1);
    END

   -- When recovery is happening for both IRS and DRA fee then Case Journal Entry Need to be Inserted and elog entry should be created
   IF @Ac_Transaction_CODE = 'SREC'
    BEGIN
     
      SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT';
      SET @Ls_SqlData_TEXT =  'Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Ac_Job_ID, '');
      
      EXECUTE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
       @Ac_Worker_ID                = @Lc_BatchRunUser_TEXT,
       @Ac_Process_ID               = @Ac_Job_ID,
       @Ad_EffectiveEvent_DATE      = @Ad_Run_DATE,
       @Ac_Note_INDC                = @Lc_No_INDC,
       @An_EventFunctionalSeq_NUMB  = @Ln_FunctionalEventSeq2235_NUMB,
       @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
       @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
       @As_DescriptionError_TEXT    = @Ls_ErrorMessage_TEXT OUTPUT

      IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
       BEGIN
        SET @Ls_ErrorMessage_TEXT = 'BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT FAILED';

        RAISERROR(50001,16,1);
       END
    
     SET @Ln_MemberMci_IDNO = CAST(@Ac_CheckRecipient_ID AS NUMERIC);
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_ACTIVITY';
     SET @Ls_SqlData_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR), '') + ', ActivityMajor_CODE = ' + ISNULL(@Lc_CaseMajorActivity_CODE, '') + ', ActivityMinor_CODE = ' + ISNULL(@Lc_ActivityMinor_CODE, '') + ', Subsystem_CODE = ' + ISNULL(@Lc_SubsystemFm_CODE, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@An_EventGlobalSeq_NUMB AS VARCHAR), '') + ', WorkerUpdate_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Ac_Job_ID, '');

     EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
      @An_Case_IDNO                = @An_Case_IDNO,
      @An_MemberMci_IDNO           = @Ln_MemberMci_IDNO,
      @Ac_ActivityMajor_CODE       = @Lc_CaseMajorActivity_CODE,
      @Ac_ActivityMinor_CODE       = @Lc_ActivityMinor_CODE,
      @Ac_Subsystem_CODE           = @Lc_SubsystemFm_CODE,
      @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
      @Ac_WorkerUpdate_ID          = @Lc_BatchRunUser_TEXT,
      @Ad_Run_DATE                 = @Ad_Run_DATE,
      @Ac_Job_ID                   = @Ac_Job_ID,
      @An_Topic_IDNO               = @Ln_Topic_IDNO OUTPUT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT    = @Ls_ErrorMessage_TEXT OUTPUT;

     IF @Ac_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END
     ELSE IF @Ac_Msg_CODE <> @Lc_StatusSuccess_CODE
      BEGIN
       SET @Ac_Msg_CODE = @Lc_Msg_CODE;

       RAISERROR (50001,16,1);
      END

     SET @Ls_Sql_TEXT = 'INSERT_PESEM_FEE_RECOVERY';
     SET @Ls_SqlData_TEXT = '';

     INSERT INTO PESEM_Y1
                 (Entity_ID,
                  EventGlobalSeq_NUMB,
                  TypeEntity_CODE,
                  EventFunctionalSeq_NUMB)
     SELECT dbo.BATCH_COMMON$SF_GET_RECEIPT_NO (@Ad_Batch_DATE, @Ac_SourceBatch_CODE, @An_Batch_NUMB, @An_SeqReceipt_NUMB),
            @An_EventGlobalSeq_NUMB,
            @Lc_TypeEntityRctno_CODE,
            @Ln_FunctionalEventSeq2235_NUMB
     UNION ALL
     SELECT CAST(@An_Case_IDNO AS VARCHAR),
            @An_EventGlobalSeq_NUMB,
            @Lc_TypeEntityCase_CODE,
            @Ln_FunctionalEventSeq2235_NUMB
     UNION ALL
     SELECT @Ac_CheckRecipient_ID,
            @An_EventGlobalSeq_NUMB,
            @Lc_TypeEntityRcpid_CODE,
            @Ln_FunctionalEventSeq2235_NUMB
     UNION ALL
     SELECT @Ac_CheckRecipient_CODE,
            @An_EventGlobalSeq_NUMB,
            @Lc_TypeEntityRcpcd_CODE,
            @Ln_FunctionalEventSeq2235_NUMB;

     SET @Ln_Rowcount_QNTY = @@ROWCOUNT;

     IF @Ln_Rowcount_QNTY = 0
      BEGIN
       SET @Ls_ErrorMessage_TEXT = 'INSERT_PESEM_FEE_RECOVERY FAILED';

       RAISERROR (50001,16,1);
      END;
    END

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
    IF LEN(@Lc_Msg_CODE) <> 5 
    BEGIN
     SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
    END

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
    @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;
  END CATCH
 END


GO
