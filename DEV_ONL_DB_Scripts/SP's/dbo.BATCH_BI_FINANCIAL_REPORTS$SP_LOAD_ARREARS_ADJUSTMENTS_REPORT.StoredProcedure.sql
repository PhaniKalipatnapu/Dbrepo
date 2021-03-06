/****** Object:  StoredProcedure [dbo].[BATCH_BI_FINANCIAL_REPORTS$SP_LOAD_ARREARS_ADJUSTMENTS_REPORT]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_BI_FINANCIAL_REPORTS$SP_LOAD_ARREARS_ADJUSTMENTS_REPORT
Programmer Name	:	IMP Team.
Description		:	Procedure to get the arrear adjustment amount for the particular month.
Frequency		:	
Developed On	:	4/27/2012
Called By		:	
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_BI_FINANCIAL_REPORTS$SP_LOAD_ARREARS_ADJUSTMENTS_REPORT]
 AS
 BEGIN 
 SET NOCOUNT ON;
    DECLARE @Ln_EventFunctionalSeq1030_NUMB		  NUMERIC(4,0)=1030,
            @Ln_ProcessedRecordCount_QNTY         NUMERIC(6)   = 0,
            @Lc_CaseRelationshipNCP_CODE          CHAR(1) = 'A',
            @Lc_CaseRelationshipPF_CODE           CHAR(1) = 'P',
            @Lc_TypeRecordOriginal_CODE           CHAR(1) = 'O',
			@Lc_StatusFailed_CODE                 CHAR(1) = 'F',
			@Lc_StatusSuccess_CODE				  CHAR(1) = 'S',
			@Lc_StatusAbnormalend_CODE            CHAR(1) = 'A',
			@Lc_Space_TEXT						  CHAR(1) = '',
			@Lc_ErrorE0664_CODE				      CHAR(5) = 'E0664',
			@Lc_DateFormatYyyymm_CODE             CHAR(6) ='YYYYMM',
			@Lc_Job_ID							  CHAR(7) = 'DEB0003',
            @Lc_WorkerConversion_CODE             CHAR(10) ='CONVERSION',
            @Lc_Successful_TEXT                   CHAR(20) = 'SUCCESSFUL',
            @Lc_BatchRunUser_TEXT                 CHAR(30) = 'BATCH',
            @Ls_Process_NAME                      VARCHAR(100) = 'BATCH_BI_FINANCIAL_REPORTS',
            @Ls_Procedure_NAME                    VARCHAR(100) = 'SP_LOAD_ARREARS_ADJUSTMENTS_REPORT',
            @Ls_CursorLocation_TEXT               VARCHAR(200) = '',
            @Ld_High_DATE                         DATE ='12/31/9999';

    DECLARE @Ln_CommitFreqParm_QNTY         NUMERIC(5),
			@Ln_ExceptionThresholdParm_QNTY NUMERIC(5),
			@Ln_RunDate_NUMB				NUMERIC(6,0),
			@Ln_Error_NUMB					NUMERIC(11),
			@Ln_ErrorLine_NUMB				NUMERIC(11),
			@Li_Rowcount_QNTY               SMALLINT,
			@Lc_Msg_CODE                    CHAR(5),
			@Ls_Sql_TEXT					VARCHAR(100),
			@Ls_Sqldata_TEXT				VARCHAR(200),
			@Ls_ErrorMessage_TEXT			VARCHAR(2000),
			@Ls_DescriptionError_TEXT		VARCHAR(4000),
			@Ls_BateRecord_TEXT             VARCHAR(4000),
			@Ld_Run_DATE					DATE,
			@Ld_LastRun_DATE				DATE,
			@Ld_Start_DTTM					DATETIME2;
			
 BEGIN TRY
    SET @Ld_Start_DTTM = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
    
    SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS';
    SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID,'');
 
	EXECUTE BATCH_COMMON$SP_GET_BATCH_DETAILS
    @Ac_Job_ID                  = @Lc_Job_ID,
    @Ad_Run_DATE                = @Ld_Run_DATE OUTPUT,
    @Ad_LastRun_DATE            = @Ld_LastRun_DATE OUTPUT,
    @An_CommitFreq_QNTY         = @Ln_CommitFreqParm_QNTY OUTPUT,
    @An_ExceptionThreshold_QNTY = @Ln_ExceptionThresholdParm_QNTY OUTPUT,
    @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT   = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS FAILED';
     RAISERROR(50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'RUN DATE VALIDATION';
   SET @Ls_Sqldata_TEXT = 'LastRun_DATE = ' + CAST(@Ld_LastRun_DATE AS VARCHAR) + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);
   
   IF DATEADD(D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'PARM DATE PROBLEM';
     RAISERROR(50001,16,1);
    END
    
     BEGIN TRANSACTION ArrearAdjustmentTran;
   
  	SET @Ls_Sql_TEXT   = 'DELETE_BARRA_Y1';    
  	   
    DELETE FROM  BARRA_Y1;
 
    SET @Ln_RunDate_NUMB = CAST(dbo.BATCH_COMMON_SCALAR$SF_TO_CHAR_DATE(@Ld_Run_DATE,@Lc_DateFormatYyyymm_CODE ) AS NUMERIC); 
 			  
 	SET @Ls_Sql_TEXT   = 'INSERT_BARRA_Y1';       
 	
   INSERT INTO BARRA_Y1(
	            Case_IDNO,
				File_ID,
				Ncp_NAME,
				ObligationKey_TEXT,
				Distribute_DATE,
				ReasonChange_CODE,
				Adjustment_AMNT,
				Paa_AMNT,
				Naa_AMNT,
				Taa_AMNT,
				Caa_AMNT,
				Uda_AMNT,
				Upa_AMNT,
				Medical_AMNT,
				Ivef_AMNT,
				Nffc_AMNT,
				NonIvd_AMNT,
				MonthYearApplied_NUMB,
				WorkerUpdate_ID,
				Worker_ID,
				TransactionEventSeq_NUMB)
	SELECT A.Case_IDNO,
 	       B.File_ID,
 	       E.Last_NAME AS NCP_NAME, 	            
 	       A.TypeDebt_CODE + CAST(A.MemberMCI_IDNO AS VARCHAR(10)) + A.FIPS_CODE ObligationKey_TEXT,
 	       A.Distribute_DATE Distribute_DATE, 	       
 	       SUBSTRING(F.DescriptionNote_TEXT,1,2) AS ReasonChange_CODE, 	       
	       A.TransactionPAA_AMNT + A.TransactionUDA_AMNT + A.TransactionNAA_AMNT + A.TransactionIVEF_AMNT + A.TransactionNFFC_AMNT + A.TransactionMEDI_AMNT + A.TransactionNONIVD_AMNT + A.TransactionTAA_AMNT + A.TransactionCAA_AMNT  +  A.TransactionUPA_AMNT AS Adjustment_AMNT, 
 	       A.TransactionPAA_AMNT AS Paa_AMNT,	      
	       A.TransactionNAA_AMNT AS Naa_AMNT,
	       A.TransactionTAA_AMNT AS Taa_AMNT, 
	       A.TransactionCAA_AMNT AS Caa_AMNT, 
	       A.TransactionUDA_AMNT AS Uda_AMNT,
	       A.TransactionUPA_AMNT AS Upa_AMNT, 
	       A.TransactionMEDI_AMNT AS Medical_AMNT,
	       A.TransactionIVEF_AMNT AS Ivef_AMNT,
	       A.TransactionNFFC_AMNT AS Nffc_AMNT,	       
	       A.TransactionNONIVD_AMNT AS NonIvd_AMNT,	      
	       A.SupportYearMonth_NUMB AS MonthYearApplied_NUMB,
	       C.Worker_ID AS WorkerUpdate_ID,
 	       B.Worker_ID AS Worker_ID,
 	       ROW_NUMBER() OVER (ORDER BY C.Worker_ID, A.DISTRIBUTE_DATE, A.Case_IDNO) AS TransactionEventSeq_NUMB
 	FROM		  		  		  
 	(	  
 	    SELECT B.Case_IDNO,
	           B.OrderSeq_NUMB,
	           B.ObligationSeq_NUMB,
	           B.SupportYearMonth_NUMB,
	           B.TransactionCURSUP_AMNT,
	           B.TransactionPAA_AMNT,
	           B.TransactionUDA_AMNT,
	           B.TransactionUPA_AMNT  , 
	           B.TransactionNAA_AMNT,
	           B.TransactionTAA_AMNT  , 
	           B.TransactionCAA_AMNT  , 
	           B.TransactionIVEF_AMNT,
	           B.TransactionNFFC_AMNT,
	           B.TransactionMEDI_AMNT,
	           B.TransactionNONIVD_AMNT,
	           B.EVENTGLOBALSEQ_NUMB,
	           A.MemberMCI_IDNO ,
	           A.ReasonChange_CODE,
	           B.DISTRIBUTE_DATE,
	           A.Fips_CODE,
	           A.TypeDebt_CODE 
 	    FROM LSUP_Y1  B
 	         JOIN 
        (SELECT A.Case_IDNO,
	           A.OrderSeq_NUMB,
	           A.ObligationSeq_NUMB,
	           A.MemberMCI_IDNO,
	           A.ReasonChange_CODE,
	           A.Fips_CODE,
	           A.TypeDebt_CODE  
 	      FROM OBLE_Y1  A
 	      WHERE ENDVALIDITY_DATE = @Ld_High_DATE
 	      ) A
 	       ON A.Case_IDNO = B.Case_IDNO
          AND A.OrderSeq_NUMB = B.OrderSeq_NUMB
          AND A.ObligationSeq_NUMB = B.ObligationSeq_NUMB
        WHERE B.TYPERECORD_CODE = @Lc_TypeRecordOriginal_CODE
          AND B.EVENTFUNCTIONALSEQ_NUMB = @Ln_EventFunctionalSeq1030_NUMB
          AND CAST(dbo.BATCH_COMMON_SCALAR$SF_TO_CHAR_DATE(B.DISTRIBUTE_DATE,@Lc_DateFormatYyyymm_CODE) AS NUMERIC) = @LN_RUNDATE_NUMB
    ) A
    INNER JOIN CASE_Y1 B 
            ON A.Case_IDNO = B.Case_IDNO                        
    	    INNER JOIN GLEV_Y1 C 
    	            ON A.EventGlobalSeq_NUMB = C.EventGlobalSeq_NUMB        				
    	      INNER JOIN CMEM_Y1 D 
    	              ON A.Case_IDNO = D.Case_IDNO                   
    	        INNER JOIN DEMO_Y1 E 
    	                ON D.MemberMCI_IDNO = E.MemberMCI_IDNO       
    	            LEFT JOIN UNOT_Y1 F 
    	                   ON C.EventGlobalSeq_NUMB = F.EventGlobalSeq_NUMB           
     WHERE D.CaseRelationship_CODE IN (@Lc_CaseRelationshipNCP_CODE, @Lc_CaseRelationshipPF_CODE) 
       AND C.Worker_ID <> @Lc_WorkerConversion_CODE                      
     ORDER BY C.Worker_ID, A.Distribute_DATE, A.Case_IDNO;   
            
      SET @Li_Rowcount_QNTY = @@ROWCOUNT;
      SET @Ln_ProcessedRecordCount_QNTY = @Li_Rowcount_QNTY;
      
  IF (@Li_RowCount_QNTY = 0)
      BEGIN
       SET @Ls_DescriptionError_TEXT = 'INSERT BARRA_Y1 FAILED';
       SET @Ls_BateRecord_TEXT = 'Process_NAME = ' + ISNULL(@Ls_Process_NAME,'')+ ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME,'')+ ', Job_ID = ' + ISNULL(@Lc_Job_ID,'')+ ', Run_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', TypeError_CODE = ' + ISNULL(@Lc_Space_TEXT,'')+ ', Line_NUMB = ' + ISNULL(CAST( @Li_RowCount_QNTY AS VARCHAR ),'')+ ', Error_CODE = ' + ISNULL(@Lc_ErrorE0664_CODE,'')+ ', DescriptionError_TEXT = ' + ISNULL(@Ls_DescriptionError_TEXT,'')+ ', ListKey_TEXT = ' + ISNULL(@Ls_Sqldata_TEXT,'')+ ', Msg_CODE = ' + ISNULL(@Lc_Msg_CODE,'')+ ', DescriptionErrorOut_TEXT = ' + ISNULL(@Ls_DescriptionError_TEXT,'');

       EXECUTE BATCH_COMMON$SP_BATE_LOG
        @As_Process_NAME             = @Ls_Process_NAME,
        @As_Procedure_NAME           = @Ls_Procedure_NAME,
        @Ac_Job_ID                   = @Lc_Job_ID,
        @Ad_Run_DATE                 = @Ld_Run_DATE,
        @Ac_TypeError_CODE           = @Lc_Space_TEXT,
        @An_Line_NUMB                = @Li_RowCount_QNTY,
        @Ac_Error_CODE               = @Lc_ErrorE0664_CODE,
        @As_DescriptionError_TEXT    = @Ls_BateRecord_TEXT,
        @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
        @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;
        
  IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
    SET @Ls_ErrorMessage_TEXT = 'BATCH_COMMON$SP_BATE_LOG FAILED';
     RAISERROR(50001,16,1);
    END
        
      END 
      
      SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE';
      SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL (@Lc_Job_ID, '');

   EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
       SET @Ls_ErrorMessage_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE FAILED';
       RAISERROR (50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BSTL_LOG';

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ad_Start_DATE            = @Ld_Start_DTTM,
    @Ac_Job_ID                = @Lc_Job_ID,
    @As_Process_NAME          = @Ls_Process_NAME,
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT   = @Ls_CursorLocation_TEXT,
    @As_ExecLocation_TEXT     = @Lc_Successful_TEXT,
    @As_ListKey_TEXT          = @Lc_Successful_TEXT,
    @As_DescriptionError_TEXT = @Lc_Space_TEXT,
    @Ac_Status_CODE           = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID             = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;

   COMMIT TRANSACTION ArrearAdjustmentTran; -- 1
  END TRY

  BEGIN CATCH

   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION ArrearAdjustmentTran;
    END

   --Check for Exception information to log the description text based on the error
   SET @Ln_Error_NUMB = ERROR_NUMBER ();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE ();

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
    @Ad_Start_DATE                = @Ld_Start_DTTM,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Lc_Space_TEXT,
    @As_ExecLocation_TEXT         = @Ls_Sql_TEXT,
    @As_ListKey_TEXT              = @Ls_SqlData_TEXT,
    @As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE               = @Lc_StatusAbnormalend_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH
 END;--BATCH_BI_FINANCIAL_REPORTS$SP_LOAD_ARREARS_ADJUSTMENTS_REPORT;

GO
