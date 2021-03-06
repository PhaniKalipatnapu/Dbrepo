/****** Object:  StoredProcedure [dbo].[BATCH_FIN_ROLL_IVMG_WEMO$SP_PROCESS_ROLL_IVMG_WEMO]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_FIN_ROLL_IVMG_WEMO$SP_PROCESS_ROLL_IVMG_WEMO
Programmer Name 	: IMP Team
Description			: The process BATCH_FIN_ROLL_IVMG_WEMO inserts new record in the
					  MONTHLY IV-A (IVMG) and TANF MONTHLY OBLIGATION (WEMO_Y1)
					  Tables for the Next Month associated with that obligation
 
					  This procedure get all the records from IVMG_Y1 with the latest month
					  welfare and inserts a records for the New Month Welfare
					  This procedure also gets all the records from the WEMO_Y1 for the
					  particular CaseWelfare_IDNO for the latest month and inserts a record
					  for the New month.
Frequency			: 'MONTHLY'
Developed On		: 11/30/2011
Called BY			: None
Called On			: 
--------------------------------------------------------------------------------------------------------------------
Modified BY			:
Modified On			:
Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_FIN_ROLL_IVMG_WEMO$SP_PROCESS_ROLL_IVMG_WEMO]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE  @Li_RollOverWemo1090_NUMB		INT = 1090,
           @Lc_StatusFailed_CODE            CHAR (1) = 'F',
           @Lc_WelfareEligTanf_CODE         CHAR (1) = 'A',
           @Lc_No_INDC                      CHAR (1) = 'N',
           @Lc_Space_TEXT                   CHAR (1) = ' ',
           @Lc_StatusSuccess_CODE           CHAR (1) = 'S',
           @Lc_StatusAbnormalend_CODE       CHAR (1) = 'A',
           @Lc_Job_ID                       CHAR (7) = 'DEB6310',
           @Lc_Successful_TEXT              CHAR (20) = 'SUCCESSFUL',
           @Lc_BatchRunUser_TEXT            CHAR (30) = 'BATCH',
           @Ls_Process_NAME                 VARCHAR (100) = 'BATCH_FIN_ROLL_IVMG_WEMO',
           @Ls_Procedure_NAME               VARCHAR (100) = 'SP_PROCESS_ROLL_IVMG_WEMO',
           @Ld_High_DATE                    DATE = '12/31/9999',
           @Ld_Start_DATE                   DATETIME2 = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
  DECLARE  @Ln_CommitFreqParm_QNTY          NUMERIC (5),
           @Ln_ExceptionThresholdParm_QNTY  NUMERIC (5),
           @Ln_NewWelfareYearMonth_NUMB     NUMERIC (6),
           @Ln_ProcessRecordsCount_QNTY     NUMERIC (6) = 0,
           @Ln_RowCount_QNTY                NUMERIC (7),
           @Ln_Error_NUMB                   NUMERIC (11),
           @Ln_ErrorLine_NUMB               NUMERIC (11),
           @Ln_EventGlobalSeq_NUMB          NUMERIC (19) = 0,
           @Lc_Msg_CODE                     CHAR (1),
           @Ls_Sql_TEXT                     VARCHAR (100),
           @Ls_CursorLoc_TEXT               VARCHAR (200),
           @Ls_Sqldata_TEXT                 VARCHAR (200),
           @Ls_ErrorMessage_TEXT            VARCHAR (4000),
           @Ls_DescriptionError_TEXT        VARCHAR (4000),
           @Ld_Run_DATE                     DATE,
           @Ld_LastRun_DATE                 DATE;
  BEGIN TRY
   /*
   	Get the current run date and last run date from PARM_Y1 (Parameters table) and validate that the 
   	batch program was not executed for the current run date by ensuring that the run date is different 
   	from the last run date in the PARM table.  Otherwise, an error message will be written into the 
   	Batch Status Log (BSTL) screen/ BSTL_Y1 table, and the process will terminate.
   */
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
   SET @Ls_Sqldata_TEXT = 'LastRun_DATE = ' + CAST(DATEADD(d,1,@Ld_LastRun_DATE) AS VARCHAR) + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);
   IF DATEADD(d,1,@Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'PARM DATE PROBLEM';
     RAISERROR (50001,16,1);
    END;
    
   SET @Ln_NewWelfareYearMonth_NUMB = CONVERT(VARCHAR(6),DATEADD (m, 1, @Ld_Run_DATE),112);
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GENERATE_SEQ';
   SET @Ls_Sqldata_TEXT = 'EventFunctionalSeq_NUMB = ' + CAST(@Li_RollOverWemo1090_NUMB AS VARCHAR) + ' ,Process_ID = '+ @Lc_Job_ID + ', EffectiveEvent_DATE = '+ CAST(@Ld_Run_DATE AS VARCHAR) +', Note_INDC = '+@Lc_No_INDC +', Worker_ID = '+@Lc_BatchRunUser_TEXT;
   EXECUTE BATCH_COMMON$SP_GENERATE_SEQ
    @An_EventFunctionalSeq_NUMB = @Li_RollOverWemo1090_NUMB,
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
   BEGIN TRANSACTION IvmgWemoTran;
   /*
    Insert a record in MONTHLY IV-A GRANT (IVMG_Y1) table for the next month and carry forward the previous month balance.  
    If record is already present in IVMG_Y1 table for next month then skip for the next IV-A case
   */
   SET @Ls_Sql_TEXT = 'INSERT IVMG_Y1 1';
   SET @Ls_Sqldata_TEXT = 'WelfareYearMonth_NUMB = ' + ISNULL(CAST( @Ln_NewWelfareYearMonth_NUMB AS VARCHAR ),'')+ ', TransactionAssistExpend_AMNT = ' + ISNULL('0','')+ ', MtdAssistExpend_AMNT = ' + ISNULL('0','')+ ', TransactionAssistRecoup_AMNT = ' + ISNULL('0','')+ ', MtdAssistRecoup_AMNT = ' + ISNULL('0','') + ', TypeAdjust_CODE = ' + ISNULL(@Lc_Space_TEXT,'')+ ', EventGlobalSeq_NUMB = ' + ISNULL(CAST( @Ln_EventGlobalSeq_NUMB AS VARCHAR ),'')+ ', ZeroGrant_INDC = ' + ISNULL(@Lc_No_INDC,'')+ ', AdjustLtdFlag_INDC = ' + ISNULL(@Lc_No_INDC,'')+ ', Defra_AMNT = ' + ISNULL('0','');
   INSERT IVMG_Y1
           (CaseWelfare_IDNO,
			WelfareYearMonth_NUMB,
			WelfareElig_CODE,
			TransactionAssistExpend_AMNT,
			MtdAssistExpend_AMNT,
			LtdAssistExpend_AMNT,
			TransactionAssistRecoup_AMNT,
			MtdAssistRecoup_AMNT,
			LtdAssistRecoup_AMNT,
			TypeAdjust_CODE,
			EventGlobalSeq_NUMB,
			ZeroGrant_INDC,
			AdjustLtdFlag_INDC,
			Defra_AMNT,
			CpMci_IDNO)
   SELECT a.CaseWelfare_IDNO,
          @Ln_NewWelfareYearMonth_NUMB AS WelfareYearMonth_NUMB,
          a.WelfareElig_CODE,
          0	AS TransactionAssistExpend_AMNT,
          0	AS MtdAssistExpend_AMNT,
          a.LtdAssistExpend_AMNT,
          0	AS TransactionAssistRecoup_AMNT,
          0	AS MtdAssistRecoup_AMNT,
          a.LtdAssistRecoup_AMNT,
          @Lc_Space_TEXT AS TypeAdjust_CODE,
          @Ln_EventGlobalSeq_NUMB AS EventGlobalSeq_NUMB,
          @Lc_No_INDC AS ZeroGrant_INDC,	
          @Lc_No_INDC AS AdjustLtdFlag_INDC,	
          0 AS Defra_AMNT,	
          a.CpMci_IDNO
     FROM IVMG_Y1 a
    WHERE a.WelfareYearMonth_NUMB = (SELECT MAX (b.WelfareYearMonth_NUMB) 
                                       FROM IVMG_Y1 b
                                      WHERE a.CaseWelfare_IDNO = b.CaseWelfare_IDNO
										AND a.CpMci_IDNO = b.CpMci_IDNO	
                                        AND a.WelfareElig_CODE = b.WelfareElig_CODE)
      AND a.EventGlobalSeq_NUMB = (SELECT MAX (c.EventGlobalSeq_NUMB)
                                     FROM IVMG_Y1 c
                                    WHERE a.CaseWelfare_IDNO = c.CaseWelfare_IDNO
                                      AND a.CpMci_IDNO = c.CpMci_IDNO	
                                      AND a.WelfareYearMonth_NUMB = c.WelfareYearMonth_NUMB
                                      AND a.WelfareElig_CODE = c.WelfareElig_CODE)
      AND NOT EXISTS (SELECT 1 
                        FROM IVMG_Y1 b
                       WHERE b.CaseWelfare_IDNO = a.CaseWelfare_IDNO
                         AND b.CpMci_IDNO = a.CpMci_IDNO
                         AND b.WelfareYearMonth_NUMB = @Ln_NewWelfareYearMonth_NUMB
                         AND b.WelfareElig_CODE = a.WelfareElig_CODE);

	   SET @Ln_RowCount_QNTY = @@ROWCOUNT;
	   
       IF @Ln_RowCount_QNTY = 0
        BEGIN
         SET @Ls_ErrorMessage_TEXT = 'INSERT IVMG_Y1 FAILED';
         RAISERROR (50001,16,1);
        END	
   
       SET @Ln_ProcessRecordsCount_QNTY = @Ln_ProcessRecordsCount_QNTY + @Ln_RowCount_QNTY ;
       /*
       	IF the case is IV-A Case (Welfare Eligible Indicator is equal to 'A') then get all the records from
		IVMG_Y1 table for the welfare case ID with the latest month welfare.
		
        Insert record in the TANF MONTHLY OBLIGATION (WEMO_Y1) table for the New Month Welfare and carry 
        forward the previous month balance
       */
       SET @Ls_Sql_TEXT = 'INSERT_WEMO_Y1 ';
       SET @Ls_Sqldata_TEXT = 'WelfareYearMonth_NUMB = ' + ISNULL(CAST( @Ln_NewWelfareYearMonth_NUMB AS VARCHAR ),'')+ ', TransactionAssistExpend_AMNT = ' + ISNULL('0','') + ', MtdAssistExpend_AMNT = ' + ISNULL('0','') + ', TransactionAssistRecoup_AMNT = ' + ISNULL('0','')+ ', MtdAssistRecoup_AMNT = ' + ISNULL('0','') + ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST( @Ln_EventGlobalSeq_NUMB AS VARCHAR ),'')+ ', EventGlobalEndSeq_NUMB = ' + ISNULL('0','') + ', BeginValidity_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'') + ', WelfareElig_CODE = ' + @Lc_WelfareEligTanf_CODE + ', EndValidity_DATE = ' + CAST(@Ld_High_DATE AS VARCHAR);
       INSERT WEMO_Y1
              (Case_IDNO,
               OrderSeq_NUMB,
               ObligationSeq_NUMB,
               CaseWelfare_IDNO,
               WelfareYearMonth_NUMB,
               TransactionAssistExpend_AMNT,
               MtdAssistExpend_AMNT,
               LtdAssistExpend_AMNT,
               TransactionAssistRecoup_AMNT,
               MtdAssistRecoup_AMNT,
               LtdAssistRecoup_AMNT,
               EventGlobalBeginSeq_NUMB,
               EventGlobalEndSeq_NUMB,
               BeginValidity_DATE,
               EndValidity_DATE)
       (SELECT DISTINCT a.Case_IDNO,
               a.OrderSeq_NUMB,
               a.ObligationSeq_NUMB,
               a.CaseWelfare_IDNO,
               @Ln_NewWelfareYearMonth_NUMB AS WelfareYearMonth_NUMB,
               0 AS TransactionAssistExpend_AMNT,
               0 AS MtdAssistExpend_AMNT,
               a.LtdAssistExpend_AMNT,
               0 AS TransactionAssistRecoup_AMNT,
               0 AS MtdAssistRecoup_AMNT,
               a.LtdAssistRecoup_AMNT,
               @Ln_EventGlobalSeq_NUMB AS EventGlobalBeginSeq_NUMB,
               0 AS EventGlobalEndSeq_NUMB,
               @Ld_Run_DATE	AS BeginValidity_DATE,
               @Ld_High_DATE AS EndValidity_DATE
          FROM WEMO_Y1 a,IVMG_Y1 b
         WHERE a.CaseWelfare_IDNO = b.CaseWelfare_IDNO
           AND b.WelfareYearMonth_NUMB = @Ln_NewWelfareYearMonth_NUMB
           AND b.WelfareElig_CODE = @Lc_WelfareEligTanf_CODE
           AND a.EndValidity_DATE = @Ld_High_DATE
           AND a.WelfareYearMonth_NUMB = (SELECT MAX (b.WelfareYearMonth_NUMB)
                                            FROM WEMO_Y1 b
                                           WHERE b.CaseWelfare_IDNO = b.CaseWelfare_IDNO
                                             AND b.Case_IDNO = a.Case_IDNO
                                             AND b.OrderSeq_NUMB = a.OrderSeq_NUMB
                                             AND b.ObligationSeq_NUMB = a.ObligationSeq_NUMB
                                             AND b.EndValidity_DATE = @Ld_High_DATE)
       AND NOT EXISTS (SELECT 1 
                         FROM WEMO_Y1 b
                        WHERE b.CaseWelfare_IDNO = a.CaseWelfare_IDNO
                          AND b.WelfareYearMonth_NUMB = @Ln_NewWelfareYearMonth_NUMB
                          AND b.EndValidity_DATE = @Ld_High_DATE));

       SET @Ln_RowCount_QNTY = @@ROWCOUNT;
       
       IF @Ln_RowCount_QNTY = 0
        BEGIN
         SET @Ls_ErrorMessage_TEXT = 'INSERT WEMO_Y1 FAILED';
         RAISERROR (50001,16,1);
        END
        
        SET @Ln_ProcessRecordsCount_QNTY = @Ln_ProcessRecordsCount_QNTY + @Ln_RowCount_QNTY ;
     
   /*
	 Update the last run date in the PARM_Y1 table with the run date, upon successful completion.
   */
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', Run_DATE = '+ CAST(@Ld_Run_DATE AS VARCHAR);
  
   EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END

   SET @Lc_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BSTL_LOG';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', Start_DATE = ' + CAST(@Ld_Start_DATE AS VARCHAR) + ', Job_ID = ' + @Lc_Job_ID + ', Process_NAME = ' + @Ls_Process_NAME + ', Procedure_NAME = ' + @Ls_Procedure_NAME + ', CursorLoc_TEXT = ' + @Ls_CursorLoc_TEXT + ', ExecLocation_TEXT = ' + @Lc_Successful_TEXT + ', ExecLocation_TEXT = ' + @Lc_Successful_TEXT + ', DescriptionError_TEXT = ' + @Lc_Space_TEXT + ', Status_CODE = ' + @Lc_StatusSuccess_CODE + ', Worker_ID = ' + @Lc_BatchRunUser_TEXT + ', ProcessedRecordCount_QNTY = ' + CAST(@Ln_ProcessRecordsCount_QNTY AS VARCHAR);	
   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ad_Start_DATE            = @Ld_Start_DATE,
    @Ac_Job_ID                = @Lc_Job_ID,
    @As_Process_NAME          = @Ls_Process_NAME,
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT   = @Ls_CursorLoc_TEXT,
    @As_ExecLocation_TEXT     = @Lc_Successful_TEXT,
    @As_ListKey_TEXT          = @Lc_Successful_TEXT,
    @As_DescriptionError_TEXT = @Lc_Space_TEXT,
    @Ac_Status_CODE           = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID             = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessRecordsCount_QNTY;

   COMMIT TRANSACTION IvmgWemoTran;
   
  END TRY

  BEGIN CATCH
  	-- Check if active transaction exists for this session then rollback the transaction
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION IvmgWemoTran;
    END

   --Check for Exception information to log the description text based on the error
   SET @Ln_Error_NUMB = ERROR_NUMBER ();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE ();

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
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ad_Start_DATE            = @Ld_Start_DATE,
    @Ac_Job_ID                = @Lc_Job_ID,
    @As_Process_NAME          = @Ls_Process_NAME,
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT   = @Ls_CursorLoc_TEXT,
    @As_ExecLocation_TEXT     = @Ls_Sql_TEXT,
    @As_ListKey_TEXT          = @Ls_Sqldata_TEXT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE           = @Lc_StatusAbnormalend_CODE,
    @Ac_Worker_ID             = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessRecordsCount_QNTY;

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH
 END


GO
