/****** Object:  StoredProcedure [dbo].[BATCH_ENF_INCOMING_IRS_REJECTS$SP_PROCESS_IRS_REJECTS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_ENF_INCOMING_IRS_REJECTS$SP_PROCESS_IRS_REJECTS

Programmer Name 	: IMP Team

Description			: The batch process reads the IRS reject data from the LIREJ_Y1 table and creates an entry 
					  in database table. This information can be viewed from the RJCT screen in the system

Frequency			: 'WEEKLY'

Developed On		: 09/14/2011

Called BY			: None

Called On			: 
--------------------------------------------------------------------------------------------------------------------
Modified BY			:

Modified On			:

Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_ENF_INCOMING_IRS_REJECTS$SP_PROCESS_IRS_REJECTS]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusSuccess_CODE		  CHAR (1) = 'S',
          @Lc_No_INDC					  CHAR (1) = 'N',
          @Lc_StatusFailed_CODE           CHAR (1) = 'F',
          @Lc_Yes_INDC                    CHAR (1) = 'Y',
          @Lc_ErrorTypeWarning_CODE       CHAR (1) = 'W',
          @Lc_StatusAbnormalend_CODE      CHAR (1) = 'A',
          @Lc_TypeErrorE_CODE             CHAR (1) = 'E',
          @Lc_Space_TEXT                  CHAR (1) = ' ',
          @Lc_Local003_CODE				  CHAR (3) = '003',	
          @Lc_ErrorNoRecords_CODE         CHAR (5) = 'E0944',
          @Lc_ErrorMemberNotFound_CODE    CHAR (5) = 'E0907',
          @Lc_ErrorInvalidValue_CODE      CHAR (5) = 'E0085',
          @Lc_ErrorKeyNotFound_CODE       CHAR (5) = 'E0958',
          @Lc_BateError_CODE              CHAR (5) = ' ',
          @Lc_BateErrorE1424_CODE         CHAR (5) = 'E1424',
          @Lc_Job_ID                      CHAR (7) = 'DEB5220',
          @Lc_Successful_TEXT             CHAR (20) = 'SUCCESSFUL',
          @Lc_BatchRunUser_TEXT           CHAR (30) = 'BATCH',
          @Ls_Process_NAME                VARCHAR (50) = 'BATCH_ENF_INCOMING_IRS_REJECTS',
          @Ls_Procedure_NAME              VARCHAR (50) = 'SP_PROCESS_IRS_REJECTS',
          @Ld_High_DATE                   DATE = '12/31/9999',
          @Ld_Start_DATE				  DATETIME2 = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
  DECLARE @Ln_FedhExist_NUMB              NUMERIC (1) = 0,
          @Ln_HfedhExist_NUMB             NUMERIC (1) = 0,
          @Ln_EventFunctionalSeq_NUMB     NUMERIC (4),
          @Ln_RejectCodeCount_QNTY        NUMERIC (5) = 1,
          @Ln_ExceptionThreshold_QNTY     NUMERIC (5) = 0,
          @Ln_CommitFreq_QNTY             NUMERIC (5) = 0,
          @Ln_CommitFreqParm_QNTY         NUMERIC (5) = 0,
          @Ln_ExceptionThresholdParm_QNTY NUMERIC (5) = 0,
          @Ln_ProcessedRecordCount_QNTY   NUMERIC (6) = 0,
          @Ln_TransactionEventSeq_NUMB    NUMERIC (9),
          @Ln_MemberMci_IDNO              NUMERIC (10),
          @Ln_Cursor_QNTY                 NUMERIC (10) = 0,
          @Ln_CursorRecord_QNTY           NUMERIC (10) = 0,
          @Ln_Error_NUMB                  NUMERIC (11),
          @Ln_ErrorLine_NUMB              NUMERIC (11),
          @Ln_RowCount_QNTY               NUMERIC (11),
          @Ln_RowCount_NUMB               NUMERIC (11),
          @Ln_Count_NUMB                  NUMERIC (11),
          @Ln_ProcessedRecordsCommit_QNTY NUMERIC (19) = 0,
          @Li_FetchStatus_QNTY            SMALLINT,
          @Lc_RejectInd_INDC              CHAR (1),
          @Lc_UpdateFlag_INDC             CHAR (1),
          @Lc_TypeError_CODE              CHAR (1),
          @Lc_Msg_CODE                    CHAR (3),
          @Lc_RejectError_CODE		      CHAR (5),
          @Ls_TypeErrorConcat_CODE        VARCHAR (50)= '',
          @Ls_Sql_TEXT                    VARCHAR (100),
          @Ls_CursorLocation_TEXT         VARCHAR (200),
          @Ls_Sqldata_TEXT                VARCHAR (1000),
          @Ls_ErrorMessage_TEXT           VARCHAR (2000),
          @Ls_DescriptionError_TEXT       VARCHAR (4000),
          @Ls_BateRecord_TEXT             VARCHAR (4000),
          @Ld_Run_DATE                    DATE,
          @Ld_LastRun_DATE                DATE;
  DECLARE @Ln_IrsRejectCur_Seq_IDNO							NUMERIC(19),
		  @Lc_IrsRejectCur_Local_CODE						CHAR(3),
          @Lc_IrsRejectCurArrearIdentifierIdno_TEXT			CHAR(15),
          @Ln_IrsRejectCurArrearIdentifier_IDNO				NUMERIC(15),
          @Lc_IrsRejectCur_MemberSsnNumb_TEXT				CHAR(9),
          @Ln_IrsRejectCur_MemberSsn_NUMB					NUMERIC(9),
          @Lc_IrsRejectCur_Last_NAME						CHAR(20),
          @Lc_IrsRejectCur_First_NAME						CHAR(15),
          @Lc_IrsRejectCur_ArrearsAmnt_TEXT					CHAR(8),
          @Ln_IrsRejectCur_Arrears_AMNT						NUMERIC(8),
          @Lc_IrsRejectCur_TypeTransaction_CODE				CHAR(1),
          @Lc_IrsRejectCur_Issued_DATE						CHAR(8),
          @Lc_IrsRejectCur_Error_CODE						CHAR(12),
          @Lc_IrsRejectCur_TypeCase_CODE					CHAR(1),
          @Lc_IrsRejectCur_Line1_ADDR						CHAR(30),
          @Lc_IrsRejectCur_Line2_ADDR						CHAR(30),
          @Lc_IrsRejectCur_State_ADDR						CHAR(2),
          @Lc_IrsRejectCur_Zip_ADDR							CHAR(9),
          @Lc_IrsRejectCur_ProcessYearNumb_TEXT				CHAR(4),
          @Ln_IrsRejectCur_ProcessYear_NUMB					NUMERIC(4),
          @Lc_IrsRejectCur_TypeOffsetExcl_CODE				CHAR(40),
          @Lc_IrsRejectCur_LastNcp_NAME						CHAR(4);
  /*
   	Read the IRS reject data from the temporary table and insert the details into the database table. 
   	This information can be viewed from the RJCT screen
   */
   DECLARE IrsReject_CUR INSENSITIVE CURSOR FOR
    SELECT l.Seq_IDNO,
		   l.Local_CODE,
           l.Case_IDNO,
           l.MemberSsn_NUMB,
           l.Last_NAME,
           l.First_NAME,
           l.Arrears_AMNT,
           l.TransType_CODE,
           l.Issued_DATE,
           l.Error_CODE,
           l.TypeCase_CODE,
           l.Line1_ADDR,
           l.Line2_ADDR,
           l.State_ADDR,
           l.Zip_ADDR,
           l.TypeOffsetExcl_CODE,
           l.ProcessYear_NUMB,
           l.LastNcp_NAME
      FROM LIREJ_Y1 l
     WHERE l.Process_INDC = @Lc_No_INDC;
     
  BEGIN TRY
   /*
   	Get the run date and last run date from PARM_Y1 table and validate that the batch program was not 
   	executed for the run date, by ensuring that the run date is different from the last run date in 
   	the PARM_Y1 table.  Otherwise, an error message to that effect will be written into Batch 
   	Status Log (BSTL) screen / Batch Status Log (BSTL_Y1) table and terminate the process.
   */
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS';
   SET @Ls_Sqldata_TEXT = ' Job_ID = ' + ISNULL(@Lc_Job_ID, '');

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
     RAISERROR(50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'PARM DATE CHECK';
   SET @Ls_Sqldata_TEXT = 'LastRun_DATE = ' + CAST(@Ld_LastRun_DATE AS VARCHAR) + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   IF DATEADD(D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'PARM DATE PROBLEM';

     RAISERROR(50001,16,1);
    END

   BEGIN TRANSACTION IRSRejects;

   SET @Ls_Sql_TEXT = 'OPEN IrsReject_CUR';
   SET @Ls_Sqldata_TEXT = '';

   OPEN IrsReject_CUR;

   SET @Ls_Sql_TEXT = 'FETCH IrsReject_CUR - 1';
   SET @Ls_Sqldata_TEXT = '';

   FETCH NEXT FROM IrsReject_CUR INTO @Ln_IrsRejectCur_Seq_IDNO,@Lc_IrsRejectCur_Local_CODE, @Lc_IrsRejectCurArrearIdentifierIdno_TEXT, @Lc_IrsRejectCur_MemberSsnNumb_TEXT, @Lc_IrsRejectCur_Last_NAME, @Lc_IrsRejectCur_First_NAME, @Lc_IrsRejectCur_ArrearsAmnt_TEXT, @Lc_IrsRejectCur_TypeTransaction_CODE, @Lc_IrsRejectCur_Issued_DATE, @Lc_IrsRejectCur_Error_CODE, @Lc_IrsRejectCur_TypeCase_CODE, @Lc_IrsRejectCur_Line1_ADDR, @Lc_IrsRejectCur_Line2_ADDR, @Lc_IrsRejectCur_State_ADDR, @Lc_IrsRejectCur_Zip_ADDR, @Lc_IrsRejectCur_TypeOffsetExcl_CODE, @Lc_IrsRejectCur_ProcessYearNumb_TEXT, @Lc_IrsRejectCur_LastNcp_NAME;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
   -- Cursor loop started
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
     BEGIN TRY
      SET @Ls_Sql_TEXT = 'SAVEANNUAL_PROCESS BEGINS - 2';
      SET @Ls_Sqldata_TEXT = '';
      SAVE TRANSACTION SAVEIRSREJECT_PROCESS;
      SET @Ls_ErrorMessage_TEXT = '';
      SET @Lc_BateError_CODE = @Lc_BateErrorE1424_CODE;
      
      IF LTRIM(RTRIM(@Lc_IrsRejectCur_Local_CODE)) IS NULL
		OR LTRIM(RTRIM(@Lc_IrsRejectCur_Local_CODE)) = ''
      BEGIN
        -- If empty then set the county code as 003
		SET @Lc_IrsRejectCur_Local_CODE = @Lc_Local003_CODE;
      END 
      
      SET @Ls_Sql_TEXT = 'MemberSsnNumb_TEXT - Conversion';
	  SET @Ls_Sqldata_TEXT = 'MemberSsnNumb_TEXT = ' + @Lc_IrsRejectCur_MemberSsnNumb_TEXT;
      IF LTRIM(RTRIM(@Lc_IrsRejectCur_MemberSsnNumb_TEXT)) <> ''
      BEGIN
	   IF ISNUMERIC(LTRIM(RTRIM(@Lc_IrsRejectCur_MemberSsnNumb_TEXT))) = 1
	    BEGIN 
		 SET @Ln_IrsRejectCur_MemberSsn_NUMB = CAST(@Lc_IrsRejectCur_MemberSsnNumb_TEXT AS NUMERIC);
	    END
	   ELSE
	    BEGIN
		 -- INVALID VALUE
		 SET @Lc_BateError_CODE = @Lc_ErrorInvalidValue_CODE;
		 RAISERROR (50001, 16, 1);
	    END	       
      END
      ELSE
      BEGIN
       SET @Ln_IrsRejectCur_MemberSsn_NUMB = 0;
      END     
      
      SET @Ls_Sql_TEXT = 'ArrearsAmnt_TEXT - Conversion';
	  SET @Ls_Sqldata_TEXT = 'ArrearsAmnt_TEXT = ' + @Lc_IrsRejectCur_ArrearsAmnt_TEXT;
      IF LTRIM(RTRIM(@Lc_IrsRejectCur_ArrearsAmnt_TEXT)) <> ''
      BEGIN
	   IF ISNUMERIC(LTRIM(RTRIM(@Lc_IrsRejectCur_ArrearsAmnt_TEXT))) = 1
	    BEGIN 
		 SET @Ln_IrsRejectCur_Arrears_AMNT = CAST(@Lc_IrsRejectCur_ArrearsAmnt_TEXT AS NUMERIC);
	    END
	   ELSE
	    BEGIN
		 -- INVALID VALUE
		 SET @Lc_BateError_CODE = @Lc_ErrorInvalidValue_CODE;
		 RAISERROR (50001, 16, 1);
	    END	       
      END
      ELSE
      BEGIN
       SET @Ln_IrsRejectCur_Arrears_AMNT = 0;
      END     
      
      
      SET @Ls_Sql_TEXT = 'ProcessYearNumb_TEXT - Conversion';
	  SET @Ls_Sqldata_TEXT = 'ProcessYearNumb_TEXT = ' + @Lc_IrsRejectCur_ProcessYearNumb_TEXT;
      IF LTRIM(RTRIM(@Lc_IrsRejectCur_ProcessYearNumb_TEXT)) <> ''
      BEGIN
	   IF ISNUMERIC(LTRIM(RTRIM(@Lc_IrsRejectCur_ProcessYearNumb_TEXT))) = 1
	    BEGIN 
		 SET @Ln_IrsRejectCur_ProcessYear_NUMB = CAST(@Lc_IrsRejectCur_ProcessYearNumb_TEXT AS NUMERIC);
	    END
	   ELSE
	    BEGIN
		 -- INVALID VALUE
		 SET @Lc_BateError_CODE = @Lc_ErrorInvalidValue_CODE;
		 RAISERROR (50001, 16, 1);
	    END	       
      END
      ELSE
      BEGIN
       SET @Ln_IrsRejectCur_ProcessYear_NUMB = 0;
      END     
      
      SET @Ls_Sql_TEXT = 'ArrearIdentifierIdno_TEXT - Conversion';
	  SET @Ls_Sqldata_TEXT = 'ArrearIdentifierIdno_TEXT = ' + @Lc_IrsRejectCurArrearIdentifierIdno_TEXT;
      IF LTRIM(RTRIM(@Lc_IrsRejectCurArrearIdentifierIdno_TEXT)) <> ''
      BEGIN
	   IF ISNUMERIC(LTRIM(RTRIM(@Lc_IrsRejectCurArrearIdentifierIdno_TEXT))) = 1
	    BEGIN 
		 SET @Ln_IrsRejectCurArrearIdentifier_IDNO = CAST(@Lc_IrsRejectCurArrearIdentifierIdno_TEXT AS NUMERIC);
	    END
	   ELSE
	    BEGIN
		 -- INVALID VALUE
		 SET @Lc_BateError_CODE = @Lc_ErrorInvalidValue_CODE;
		 RAISERROR (50001, 16, 1);
	    END	       
      END
      ELSE
      BEGIN
       SET @Ln_IrsRejectCurArrearIdentifier_IDNO = 0;
      END    
      
      SET @Ls_BateRecord_TEXT = 'Seq_IDNO = ' + CAST(@Ln_IrsRejectCur_Seq_IDNO AS VARCHAR) +', Local_CODE = ' + @Lc_IrsRejectCur_Local_CODE + ', Case_IDNO = ' + CAST(@Ln_IrsRejectCurArrearIdentifier_IDNO AS VARCHAR) + ', MemberSsn_NUMB = ' + CAST(@Ln_IrsRejectCur_MemberSsn_NUMB AS VARCHAR) + ', Last_NAME = ' + @Lc_IrsRejectCur_Last_NAME + ', First_NAME = ' + @Lc_IrsRejectCur_First_NAME + ', Arrears_AMNT = ' + CAST(@Ln_IrsRejectCur_Arrears_AMNT AS VARCHAR) + ', TypeTransaction_CODE = ' + @Lc_IrsRejectCur_TypeTransaction_CODE + ', Issued_DATE = ' + @Lc_IrsRejectCur_Issued_DATE + ', Error_CODE = ' + @Lc_IrsRejectCur_Error_CODE + ', TypeCase_CODE = ' + @Lc_IrsRejectCur_TypeCase_CODE + ', Line1_ADDR = ' + @Lc_IrsRejectCur_Line1_ADDR + ', Line2_ADDR = ' + @Lc_IrsRejectCur_Line2_ADDR + ', State_ADDR = ' + @Lc_IrsRejectCur_State_ADDR + ', Zip_ADDR = ' + @Lc_IrsRejectCur_Zip_ADDR + ', TypeOffsetExcl_CODE = ' + @Lc_IrsRejectCur_TypeOffsetExcl_CODE + ', ProcessYear_NUMB = ' + CAST(@Ln_IrsRejectCur_ProcessYear_NUMB AS VARCHAR) + ', LastNcp_NAME = ' + @Lc_IrsRejectCur_LastNcp_NAME;
      SET @Ln_Cursor_QNTY = @Ln_Cursor_QNTY + 1;
      SET @Ln_CursorRecord_QNTY = @Ln_CursorRecord_QNTY + 1;
      SET @Ln_CommitFreq_QNTY = @Ln_CommitFreq_QNTY + 1;
      SET @Ln_FedhExist_NUMB = 0;
      SET @Ln_HfedhExist_NUMB = 0;
      /*
		If there is NULL value in incoming Arrear Identifier field then write the error 
		E0958 – Key Data is Not Found in BATE_Y1 table.
      */
      SET @Ls_Sql_TEXT = 'CHECK KEY DTATA';
      SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_IrsRejectCurArrearIdentifier_IDNO AS VARCHAR), '') + ', MemberSsn_NUMB = ' + ISNULL(CAST(@Ln_IrsRejectCur_MemberSsn_NUMB AS VARCHAR), '') + ', TypeTransaction_CODE = ' + ISNULL(@Lc_IrsRejectCur_TypeTransaction_CODE, '') + ', TypeCase_CODE = ' + ISNULL(@Lc_IrsRejectCur_TypeCase_CODE, '') + ', ProcessYear_NUMB = ' + ISNULL(CAST(@Ln_IrsRejectCur_ProcessYear_NUMB AS VARCHAR), '');
      IF LTRIM(RTRIM(@Ln_IrsRejectCurArrearIdentifier_IDNO)) IS NULL
          OR LTRIM(RTRIM(@Ln_IrsRejectCurArrearIdentifier_IDNO)) = 0
       BEGIN
        SET @Lc_BateError_CODE = @Lc_ErrorKeyNotFound_CODE;

        RAISERROR(50001,16,1);
       END

      -- Checks if the record is present in FEDH_Y1 table
      SET @Ls_Sql_TEXT = 'CHECK FEDH_Y1 TABLE';
      SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_IrsRejectCurArrearIdentifier_IDNO AS VARCHAR), '') + ', MemberSsn_NUMB = ' + ISNULL(CAST(@Ln_IrsRejectCur_MemberSsn_NUMB AS VARCHAR), '') + ', TypeTransaction_CODE = ' + ISNULL(@Lc_IrsRejectCur_TypeTransaction_CODE, '') + ', CaseType_CODE = ' + ISNULL(@Lc_IrsRejectCur_TypeCase_CODE, '') + ', ProcessYear_NUMB = ' + ISNULL(CAST(@Ln_IrsRejectCur_ProcessYear_NUMB AS VARCHAR), '');
      
      SELECT @Ln_MemberMci_IDNO = MemberMci_IDNO,
             @Lc_RejectInd_INDC = RejectInd_INDC
        FROM FEDH_Y1 h
       WHERE h.MemberSsn_NUMB = @Ln_IrsRejectCur_MemberSsn_NUMB
         AND h.TypeTransaction_CODE = @Lc_IrsRejectCur_TypeTransaction_CODE
         AND h.TypeArrear_CODE = @Lc_IrsRejectCur_TypeCase_CODE
         AND h.SubmitLast_DATE = (SELECT MAX(e.SubmitLast_DATE)
                                    FROM FEDH_Y1 e
                                   WHERE h.MemberSsn_NUMB = e.MemberSsn_NUMB
                                     AND h.MemberMci_IDNO = e.MemberMci_IDNO
                                     AND h.TypeTransaction_CODE = e.TypeTransaction_CODE
                                     AND h.TypeArrear_CODE = e.TypeArrear_CODE
                                     AND h.TaxYear_NUMB = e.TaxYear_NUMB)
         AND h.TransactionEventSeq_NUMB = (SELECT MAX(e.TransactionEventSeq_NUMB)
                                             FROM FEDH_Y1 e
                                            WHERE h.MemberSsn_NUMB = e.MemberSsn_NUMB
                                              AND h.TypeTransaction_CODE = e.TypeTransaction_CODE
                                              AND h.MemberMci_IDNO = e.MemberMci_IDNO
                                              AND h.TypeArrear_CODE = e.TypeArrear_CODE
                                              AND h.TaxYear_NUMB = e.TaxYear_NUMB
                                              AND h.SubmitLast_DATE = e.SubmitLast_DATE);
      SET @Ln_RowCount_QNTY = @@ROWCOUNT;
      
      IF (@Ln_RowCount_QNTY = 0
           OR @Ln_RowCount_QNTY > 1)
       BEGIN
        SET @Ln_FedhExist_NUMB = 0;
       END
      ELSE
       BEGIN
        SET @Ln_FedhExist_NUMB = 1;
       END
      -- When record not found in FEDH_Y1 it will be logged into exception table 
      IF ((@Ln_FedhExist_NUMB = 1
           AND @Lc_RejectInd_INDC = @Lc_Yes_INDC)
           OR (@Ln_FedhExist_NUMB = 0))
       BEGIN
        SET @Lc_BateError_CODE = @Lc_ErrorMemberNotFound_CODE;

        RAISERROR(50001,16,1);
       END

      SET @Ls_Sql_TEXT = 'CHECK HFEDH_Y1 1 TABLE';
      SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_IrsRejectCurArrearIdentifier_IDNO AS VARCHAR), '') + ', MemberSsn_NUMB = ' + ISNULL(CAST(@Ln_IrsRejectCur_MemberSsn_NUMB AS VARCHAR), '') + ', TypeTransaction_CODE = ' + ISNULL(@Lc_IrsRejectCur_TypeTransaction_CODE, '') + ', TypeCase_CODE = ' + ISNULL(@Lc_IrsRejectCur_TypeCase_CODE, '') + ', ProcessYear_NUMB = ' + ISNULL(CAST(@Ln_IrsRejectCur_ProcessYear_NUMB AS VARCHAR), '');

      IF @Ln_FedhExist_NUMB = 0
       BEGIN
        SELECT @Ln_MemberMci_IDNO = MemberMci_IDNO,
               @Lc_RejectInd_INDC = RejectInd_INDC
          FROM HFEDH_Y1 h
         WHERE h.MemberSsn_NUMB = @Ln_IrsRejectCur_MemberSsn_NUMB
           AND h.TypeArrear_CODE = @Lc_IrsRejectCur_TypeCase_CODE
           AND h.TaxYear_NUMB = @Ln_IrsRejectCur_ProcessYear_NUMB
           AND h.SubmitLast_DATE = (SELECT MAX(e.SubmitLast_DATE)
                                      FROM HFEDH_Y1 e
                                     WHERE h.MemberSsn_NUMB = e.MemberSsn_NUMB
                                       AND h.MemberMci_IDNO = e.MemberMci_IDNO
                                       AND h.TypeTransaction_CODE = e.TypeTransaction_CODE
                                       AND h.TypeArrear_CODE = e.TypeArrear_CODE
                                       AND h.TaxYear_NUMB = e.TaxYear_NUMB)
           AND h.TransactionEventSeq_NUMB = (SELECT MAX(e.TransactionEventSeq_NUMB)
                                               FROM HFEDH_Y1 e
                                              WHERE h.MemberSsn_NUMB = e.MemberSsn_NUMB
                                                AND h.TypeTransaction_CODE = e.TypeTransaction_CODE
                                                AND h.MemberMci_IDNO = e.MemberMci_IDNO
                                                AND h.TypeArrear_CODE = e.TypeArrear_CODE
                                                AND h.TaxYear_NUMB = e.TaxYear_NUMB
                                                AND h.SubmitLast_DATE = e.SubmitLast_DATE);

        SET @Ln_RowCount_QNTY = @@ROWCOUNT;
        IF @Ln_RowCount_QNTY = 0
            OR @Ln_RowCount_QNTY > 0
         BEGIN
          SET @Lc_BateError_CODE = @Lc_ErrorMemberNotFound_CODE;

          RAISERROR(50001,16,1);
         END
        ELSE
         BEGIN
          SET @Ln_HfedhExist_NUMB = 1;
         END
       END

      IF (@Ln_HfedhExist_NUMB = 1
          AND @Lc_RejectInd_INDC = @Lc_Yes_INDC)
       BEGIN
        SET @Lc_BateError_CODE = @Lc_ErrorMemberNotFound_CODE;

        RAISERROR(50001,16,1);
       END

      SET @Ls_Sql_TEXT = 'PROCEDURE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT 1';
      SET @Ls_Sqldata_TEXT = 'BatchRunUser_TEXT = ' + @Lc_BatchRunUser_TEXT + ', Job_ID = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', IND NOTICE = ' + CAST(@Lc_No_INDC AS VARCHAR) + ', EventFunctionalSeq_NUMB = ' + CAST(@Ln_EventFunctionalSeq_NUMB AS VARCHAR);

      EXECUTE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
       @Ac_Worker_ID                = @Lc_BatchRunUser_TEXT,
       @Ac_Process_ID               = @Lc_Job_ID,
       @Ad_EffectiveEvent_DATE      = @Ld_Run_DATE,
       @Ac_Note_INDC                = @Lc_No_INDC,
       @An_EventFunctionalSeq_NUMB  = 0,
       @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
       @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
       @As_DescriptionError_TEXT    = @Ls_ErrorMessage_TEXT OUTPUT;

      IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
       BEGIN
        SET @Lc_Msg_CODE = @Lc_Msg_CODE;
        SET @Ls_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT;

        RAISERROR (50001,16,1);
       END

      -- Initializing the warning status 
      SET @Lc_UpdateFlag_INDC = 'N';
      SET @Ln_RejectCodeCount_QNTY = 0;
      -- Get the Error Type Code	
      SET @Ls_Sql_TEXT = 'GET ERROR TYPE CODE';
      SET @Ls_Sqldata_TEXT = 'MemberSsn_NUMB = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR), '') + ', MemberSsn_NUMB = ' + ISNULL(CAST(@Ln_IrsRejectCur_MemberSsn_NUMB AS VARCHAR), '') + ', TypeTransaction_CODE = ' + ISNULL(@Lc_IrsRejectCur_TypeTransaction_CODE, '') + ', Error_CODE = ' + ISNULL(@Lc_IrsRejectCur_Error_CODE, '');
	  -- To concatinate rejected code loop
      WHILE (@Ln_RejectCodeCount_QNTY <= 6)
       BEGIN
        BEGIN
         SET @Lc_RejectError_CODE = LTRIM(RTRIM(SUBSTRING (@Lc_IrsRejectCur_Error_CODE, (@Ln_RejectCodeCount_QNTY * 2 + 1), 2)));
         IF @Lc_RejectError_CODE NOT IN ('','00')
          BEGIN
           SET @Ls_Sql_TEXT = 'PROCEDURE BATCH_ENF_IRS_REJECTS$SF_GET_ERROR_TYPE';
           SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR), '') + ', MemberSsn_NUMB = ' + ISNULL(CAST(@Ln_IrsRejectCur_MemberSsn_NUMB AS VARCHAR), '') + ', TypeTransaction_CODE = ' + ISNULL(@Lc_IrsRejectCur_TypeTransaction_CODE, '') + ', Error_CODE = ' + ISNULL(@Lc_IrsRejectCur_Error_CODE, '');
           
           SET @Lc_TypeError_CODE = dbo.BATCH_ENF_INCOMING_IRS_REJECTS$SF_GET_ERROR_TYPE (@Lc_RejectError_CODE, @Lc_IrsRejectCur_TypeTransaction_CODE);
           /*
           	If there is no corresponding transaction type found for the incoming error codes then message 
           	E0085 – Invalid value will be written into BATE_Y1 table.
           */
           IF @Lc_TypeError_CODE = 'F'
            BEGIN
             SET @Lc_BateError_CODE = @Lc_ErrorInvalidValue_CODE;

             RAISERROR (50001,16,1);
            END

           -- Updating the indicator if error received 
           IF @Lc_TypeError_CODE <> @Lc_ErrorTypeWarning_CODE
            BEGIN
             SET @Lc_UpdateFlag_INDC = @Lc_Yes_INDC;
            END
			
           SET @Ls_TypeErrorConcat_CODE = @Ls_TypeErrorConcat_CODE + @Lc_TypeError_CODE;
           
          END

         SET @Ln_RejectCodeCount_QNTY = @Ln_RejectCodeCount_QNTY + 1;
        END

        IF @Ln_RejectCodeCount_QNTY = 6
         BEGIN
          BREAK;
         END
        ELSE
         BEGIN
          CONTINUE;
         END
       END
      -- Insert Record into RJDT_Y1 Table with the Information Received from IRS
      SET @Ls_Sql_TEXT = 'INSERT INTO RJDT_Y1';
      SET @Ls_Sqldata_TEXT = 'County_IDNO = ' + ISNULL(CAST(@Lc_IrsRejectCur_Local_CODE AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR), '') + ', MemberSsn_NUMB = ' + ISNULL(CAST(@Ln_IrsRejectCur_MemberSsn_NUMB AS VARCHAR), '') + ', Case_IDNO = ' + ISNULL(CAST(@Ln_IrsRejectCurArrearIdentifier_IDNO AS VARCHAR), '') + ', Last_NAME = ' + ISNULL (@Lc_IrsRejectCur_Last_NAME, '') + ', First_NAME = ' + ISNULL (@Lc_IrsRejectCur_First_NAME, '') + ', Arrear_AMNT = ' + ISNULL (CAST(@Ln_IrsRejectCur_Arrears_AMNT AS VARCHAR), '') + ', TypeArrear_CODE = ' + ISNULL (@Lc_IrsRejectCur_TypeCase_CODE, '') + ', TypeTransaction_CODE = ' + ISNULL (@Lc_IrsRejectCur_TypeTransaction_CODE, '') + ', Rejected_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', Reject1_CODE = ' + ISNULL(SUBSTRING (@Lc_IrsRejectCur_Error_CODE, 1, 2),'') + + ', Reject2_CODE = ' + ISNULL(SUBSTRING (@Lc_IrsRejectCur_Error_CODE, 3, 2),'') + ', Reject3_CODE = ' + ISNULL(SUBSTRING (@Lc_IrsRejectCur_Error_CODE, 5, 2),'') + ', Reject4_CODE = ' + ISNULL(SUBSTRING (@Lc_IrsRejectCur_Error_CODE, 7, 2),'') + ', Reject5_CODE = ' + ISNULL(SUBSTRING (@Lc_IrsRejectCur_Error_CODE, 9, 2),'') + ', Reject5_CODE = ' + ISNULL(SUBSTRING (@Lc_IrsRejectCur_Error_CODE, 11, 2),'') + ', TypeReject1_CODE = ' + ISNULL (SUBSTRING (@Ls_TypeErrorConcat_CODE, 1, 1),'') + ', TypeReject2_CODE = ' + ISNULL (SUBSTRING (@Ls_TypeErrorConcat_CODE, 2, 1),'') + ', TypeReject3_CODE = ' + ISNULL (SUBSTRING (@Ls_TypeErrorConcat_CODE, 3, 1),'') + ', TypeReject4_CODE = ' + ISNULL (SUBSTRING (@Ls_TypeErrorConcat_CODE, 4, 1),'') + ', TypeReject5_CODE = ' + ISNULL (SUBSTRING (@Ls_TypeErrorConcat_CODE, 5, 1),'') + ', TypeReject6_CODE = ' + ISNULL (SUBSTRING (@Ls_TypeErrorConcat_CODE, 6, 1),'') + ', BeginValidity_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR),'') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR),'') + ', WorkerUpdate_ID = ' + ISNULL (@Lc_BatchRunUser_TEXT,'') + ', Update_DTTM = ' + ISNULL(CAST(@Ld_Start_DATE AS VARCHAR),'') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR),'');
      INSERT INTO RJDT_Y1
                  (County_IDNO,
                   MemberMci_IDNO,
                   MemberSsn_NUMB,
                   ArrearIdentifier_IDNO,
                   Last_NAME,
                   First_NAME,
                   Arrear_AMNT,
                   TypeArrear_CODE,
                   TransactionType_CODE,
                   ExcludeIrs_INDC,
                   ExcludeAdm_INDC,
                   ExcludeFin_INDC,
                   ExcludePas_INDC,
                   ExcludeRet_INDC,
                   ExcludeSal_INDC,
                   ExcludeDebt_INDC,
                   ExcludeVen_INDC,
                   ExcludeIns_INDC,
                   Rejected_DATE,
                   Reject1_CODE,
                   Reject2_CODE,
                   Reject3_CODE,
                   Reject4_CODE,
                   Reject5_CODE,
                   Reject6_CODE,
                   TypeReject1_CODE,
                   TypeReject2_CODE,
                   TypeReject3_CODE,
                   TypeReject4_CODE,
                   TypeReject5_CODE,
                   TypeReject6_CODE,
                   BeginValidity_DATE,
                   EndValidity_DATE,
                   WorkerUpdate_ID,
                   Update_DTTM,
                   TransactionEventSeq_NUMB)
           VALUES ( @Lc_IrsRejectCur_Local_CODE ,--County_IDNO
                    @Ln_MemberMci_IDNO,--MemberMci_IDNO
                    @Ln_IrsRejectCur_MemberSsn_NUMB,--MemberSsn_NUMB
                    @Ln_IrsRejectCurArrearIdentifier_IDNO,--ArrearIdentifier_IDNO
                    @Lc_IrsRejectCur_Last_NAME,--Last_NAME
                    @Lc_IrsRejectCur_First_NAME,--First_NAME
                    @Ln_IrsRejectCur_Arrears_AMNT,--Arrear_AMNT
                    @Lc_IrsRejectCur_TypeCase_CODE,--TypeArrear_CODE
                    @Lc_IrsRejectCur_TypeTransaction_CODE,--TransactionType_CODE
                    CASE
                     WHEN CHARINDEX('TAX', @Lc_IrsRejectCur_TypeOffsetExcl_CODE) > 0
                      THEN @Lc_No_INDC
                     ELSE @Lc_Yes_INDC
                    END,--ExcludeIrs_INDC
                    CASE
                     WHEN CHARINDEX('PAS', @Lc_IrsRejectCur_TypeOffsetExcl_CODE) > 0
                      THEN @Lc_No_INDC
                     ELSE @Lc_Yes_INDC
                    END,--ExcludeAdm_INDC
                    CASE
                     WHEN CHARINDEX('FIN', @Lc_IrsRejectCur_TypeOffsetExcl_CODE) > 0
                      THEN @Lc_No_INDC
                     ELSE @Lc_Yes_INDC
                    END,--ExcludeFin_INDC
                    CASE
                     WHEN CHARINDEX('ADM', @Lc_IrsRejectCur_TypeOffsetExcl_CODE) > 0
                      THEN @Lc_No_INDC
                     ELSE @Lc_Yes_INDC
                    END,--ExcludePas_INDC
                    CASE
                     WHEN CHARINDEX('RET', @Lc_IrsRejectCur_TypeOffsetExcl_CODE) > 0
                      THEN @Lc_No_INDC
                     ELSE @Lc_Yes_INDC
                    END,--ExcludeRet_INDC
                    CASE
                     WHEN CHARINDEX('SAL', @Lc_IrsRejectCur_TypeOffsetExcl_CODE) > 0
                      THEN @Lc_No_INDC
                     ELSE @Lc_Yes_INDC
                    END,--ExcludeSal_INDC
                    CASE
                     WHEN CHARINDEX('DEBT', @Lc_IrsRejectCur_TypeOffsetExcl_CODE) > 0
                      THEN @Lc_No_INDC
                     ELSE @Lc_Yes_INDC
                    END,--ExcludeDebt_INDC
                    CASE
                     WHEN CHARINDEX('VEN', @Lc_IrsRejectCur_TypeOffsetExcl_CODE) > 0
                      THEN @Lc_No_INDC
                     ELSE @Lc_Yes_INDC
                    END,--ExcludeVen_INDC
                    CASE
                     WHEN CHARINDEX('INS', @Lc_IrsRejectCur_TypeOffsetExcl_CODE) > 0
                      THEN @Lc_No_INDC
                     ELSE @Lc_Yes_INDC
                    END,--ExcludeIns_INDC
                    @Ld_Run_DATE,--Rejected_DATE
                    SUBSTRING (@Lc_IrsRejectCur_Error_CODE, 1, 2),--Reject1_CODE
                    SUBSTRING (@Lc_IrsRejectCur_Error_CODE, 3, 2),--Reject2_CODE
                    SUBSTRING (@Lc_IrsRejectCur_Error_CODE, 5, 2),--Reject3_CODE
                    SUBSTRING (@Lc_IrsRejectCur_Error_CODE, 7, 2),--Reject4_CODE
                    SUBSTRING (@Lc_IrsRejectCur_Error_CODE, 9, 2),--Reject5_CODE
                    SUBSTRING (@Lc_IrsRejectCur_Error_CODE, 11, 2),--Reject6_CODE
                    ISNULL (SUBSTRING (@Ls_TypeErrorConcat_CODE, 1, 1),
                         @Lc_Space_TEXT
                        ), --TypeReject1_CODE
                    ISNULL (SUBSTRING (@Ls_TypeErrorConcat_CODE, 2, 1),
                         @Lc_Space_TEXT
                        ),--TypeReject2_CODE
                    ISNULL (SUBSTRING (@Ls_TypeErrorConcat_CODE, 3, 1),
                         @Lc_Space_TEXT
                        ),--TypeReject3_CODE
                    ISNULL (SUBSTRING (@Ls_TypeErrorConcat_CODE, 4, 1),
                         @Lc_Space_TEXT
                        ),--TypeReject4_CODE
                    ISNULL (SUBSTRING (@Ls_TypeErrorConcat_CODE, 5, 1),
                         @Lc_Space_TEXT
                        ),--TypeReject5_CODE
                    ISNULL (SUBSTRING (@Ls_TypeErrorConcat_CODE, 6, 1),
                         @Lc_Space_TEXT
                        ),--TypeReject6_CODE
                    @Ld_Run_DATE,--BeginValidity_DATE
                    @Ld_High_DATE,--EndValidity_DATE
                    @Lc_BatchRunUser_TEXT,--WorkerUpdate_ID
                    @Ld_Start_DATE,--Update_DTTM
                    @Ln_TransactionEventSeq_NUMB ); --TransactionEventSeq_NUMB
                    
      SET @Ln_RowCount_NUMB = @@ROWCOUNT;
      
      IF @Ln_RowCount_NUMB = 0
       BEGIN
        SET @Ls_ErrorMessage_TEXT = 'INSERT TO RJDT_Y1 TABLE FAILED';

        RAISERROR (50001,16,1);
       END;
      /*
      	Update the reject indicator in database table for the rejected members by end dating the 
      	current record (s) and creating a new record (s) with the reject indicator.
      */
      IF @Lc_UpdateFlag_INDC <> 'N'
       BEGIN
        IF @Ln_FedhExist_NUMB = 1
         BEGIN
          /*
          An error message E0907 – Member Not Found will be written into error log table ,BATE_Y1, 
          if there is no record found in the Federal Last Sent (FEDH_Y1) database table for the 
          NCP (match is done using the NCP's SSN)
          */
          SET @Ls_Sql_TEXT = 'CHECK HFEDH TABLE';
          SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR), '') + ', Case_IDNO = ' + ISNULL(CAST(@Ln_IrsRejectCurArrearIdentifier_IDNO AS VARCHAR), '') + ', MemberSsn_NUMB = ' + ISNULL(CAST(@Ln_IrsRejectCur_MemberSsn_NUMB AS VARCHAR), '') + ', TypeTransaction_CODE = ' + ISNULL(@Lc_IrsRejectCur_TypeTransaction_CODE, '') + ', TypeCase_CODE = ' + ISNULL (@Lc_IrsRejectCur_TypeCase_CODE, '');

          SELECT @Ln_Count_NUMB = COUNT(1)
            FROM HFEDH_Y1 h
           WHERE h.MemberMci_IDNO = @Ln_MemberMci_IDNO
             AND h.MemberSsn_NUMB = @Ln_IrsRejectCur_MemberSsn_NUMB
             AND h.TypeTransaction_CODE = @Lc_IrsRejectCur_TypeTransaction_CODE
             AND h.TypeArrear_CODE = @Lc_IrsRejectCur_TypeCase_CODE
             AND h.SubmitLast_DATE = (SELECT MAX(e.SubmitLast_DATE)
                                        FROM FEDH_Y1 e
                                       WHERE h.MemberMci_IDNO = e.MemberMci_IDNO
                                         AND h.MemberSsn_NUMB = e.MemberSsn_NUMB
                                         AND h.TypeTransaction_CODE = e.TypeTransaction_CODE
                                         AND h.TypeArrear_CODE = e.TypeArrear_CODE)
             AND h.TransactionEventSeq_NUMB = (SELECT MAX(e.TransactionEventSeq_NUMB)
                                                 FROM FEDH_Y1 e
                                                WHERE h.MemberMci_IDNO = e.MemberMci_IDNO
                                                  AND h.MemberSsn_NUMB = e.MemberSsn_NUMB
                                                  AND h.TypeTransaction_CODE = e.TypeTransaction_CODE
                                                  AND h.TypeArrear_CODE = e.TypeArrear_CODE
                                                  AND h.SubmitLast_DATE = e.SubmitLast_DATE);
			
          IF @Ln_Count_NUMB <> 0
           BEGIN
            SET @Lc_BateError_CODE = @Lc_ErrorMemberNotFound_CODE;

            RAISERROR(50001,16,1);
           END

          -- Writing the FEDH_Y1 details into HFEDH table for tracking history.
          SET @Ls_Sql_TEXT = 'INSERT INTO HFEDH_Y1 2 TABLE';
          SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR), '') + ', MemberSsn_NUMB = ' + ISNULL(CAST(@Ln_IrsRejectCur_MemberSsn_NUMB AS VARCHAR), '') + ', TypeTransaction_CODE = ' + ISNULL(@Lc_IrsRejectCur_TypeTransaction_CODE, '') + ', TypeCase_CODE = ' + ISNULL (@Lc_IrsRejectCur_TypeCase_CODE, '');

          INSERT INTO HFEDH_Y1
                      (MemberMci_IDNO,
                       MemberSsn_NUMB,
                       TypeArrear_CODE,
                       TypeTransaction_CODE,
                       Last_NAME,
                       First_NAME,
                       Middle_NAME,
                       Line1_ADDR,
                       Line2_ADDR,
                       City_ADDR,
                       State_ADDR,
                       Zip_ADDR,
                       ArrearIdentifier_IDNO,
                       Arrear_AMNT,
                       SubmitLast_DATE,
                       ExcludePas_CODE,
                       ExcludeFin_CODE,
                       ExcludeIrs_CODE,
                       ExcludeAdm_CODE,
                       ExcludeRet_CODE,
                       ExcludeSal_CODE,
                       ExcludeDebt_CODE,
                       ExcludeVen_CODE,
                       ExcludeIns_CODE,
                       RejectInd_INDC,
                       CountyFips_CODE,
                       BeginValidity_DATE,
                       EndValidity_DATE,
                       WorkerUpdate_ID,
                       Update_DTTM,
                       TransactionEventSeq_NUMB,
                       ReqPreOffset_CODE,
                       TaxYear_NUMB)
          SELECT h.MemberMci_IDNO,
                 h.MemberSsn_NUMB,
                 h.TypeArrear_CODE,
                 h.TypeTransaction_CODE,
                 h.Last_NAME,
                 h.First_NAME,
                 h.Middle_NAME,
                 h.Line1_ADDR,
                 h.Line2_ADDR,
                 h.City_ADDR,
                 h.State_ADDR,
                 h.Zip_ADDR,
                 h.ArrearIdentifier_IDNO,
                 h.Arrear_AMNT,
                 h.SubmitLast_DATE,
                 h.ExcludePas_CODE,
                 h.ExcludeFin_CODE,
                 h.ExcludeIrs_CODE,
                 h.ExcludeAdm_CODE,
                 h.ExcludeRet_CODE,
                 h.ExcludeSal_CODE,
                 h.ExcludeDebt_CODE,
                 h.ExcludeVen_CODE,
                 h.ExcludeIns_CODE,
                 h.RejectInd_INDC,
                 h.CountyFips_CODE,
                 h.BeginValidity_DATE,
                 @Ld_Run_DATE AS EndValidity_DATE,
                 @Lc_BatchRunUser_TEXT AS WorkerUpdate_ID,
                 @Ld_Start_DATE AS Update_DTTM,
                 h.TransactionEventSeq_NUMB,
                 h.ReqPreOffset_CODE,
                 h.TaxYear_NUMB
            FROM FEDH_Y1 h
           WHERE h.MemberMci_IDNO = @Ln_MemberMci_IDNO
             AND h.MemberSsn_NUMB = @Ln_IrsRejectCur_MemberSsn_NUMB
             AND h.TypeTransaction_CODE = @Lc_IrsRejectCur_TypeTransaction_CODE
             AND h.TypeArrear_CODE = @Lc_IrsRejectCur_TypeCase_CODE
             AND h.SubmitLast_DATE = (SELECT MAX(e.SubmitLast_DATE)
                                        FROM FEDH_Y1 e
                                       WHERE h.MemberMci_IDNO = e.MemberMci_IDNO
                                         AND h.MemberSsn_NUMB = e.MemberSsn_NUMB
                                         AND h.TypeTransaction_CODE = e.TypeTransaction_CODE
                                         AND h.TypeArrear_CODE = e.TypeArrear_CODE
                                         AND h.TaxYear_NUMB = e.TaxYear_NUMB)
             AND h.TransactionEventSeq_NUMB = (SELECT MAX(e.TransactionEventSeq_NUMB)
                                                 FROM FEDH_Y1 e
                                                WHERE h.MemberMci_IDNO = e.MemberMci_IDNO
                                                  AND h.MemberSsn_NUMB = e.MemberSsn_NUMB
                                                  AND h.TypeTransaction_CODE = e.TypeTransaction_CODE
                                                  AND h.TypeArrear_CODE = e.TypeArrear_CODE
                                                  AND h.TaxYear_NUMB = e.TaxYear_NUMB
                                                  AND h.SubmitLast_DATE = e.SubmitLast_DATE)
AND NOT EXISTS(SELECT 1 FROM HFEDH_Y1 X
WHERE X.MemberMci_IDNO = H.MemberMci_IDNO
AND X.SubmitLast_DATE = H.SubmitLast_DATE
AND X.TaxYear_NUMB = H.TaxYear_NUMB
AND X.TransactionEventSeq_NUMB = H.TransactionEventSeq_NUMB
AND X.TypeArrear_CODE = H.TypeArrear_CODE
AND X.TypeTransaction_CODE = H.TypeTransaction_CODE)                                                  

          SET @Ln_RowCount_NUMB = @@ROWCOUNT;

          IF @Ln_RowCount_NUMB = 0
           BEGIN
            SET @Ls_ErrorMessage_TEXT = 'INSERT HFEDH_Y1 TABLE FAILED ';

            RAISERROR(50001,16,1);
           END

          -- Updating the reject details received from IRS
          SET @Ls_Sql_TEXT = 'UPDATE FEDH_Y1 1 TABLE';
          SET @Ls_Sqldata_TEXT = 'RejectInd_INDC = ' + @Lc_Yes_INDC + ', BeginValidity_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', WorkerUpdate_ID = ' + @Lc_BatchRunUser_TEXT + ', Update_DTTM = ' + CAST(@Ld_Start_DATE AS VARCHAR) + ', TransactionEventSeq_NUMB = ' + CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR) + ', MemberMci_IDNO = ' + CAST(@Ln_MemberMci_IDNO AS VARCHAR) + ', MemberSsn_NUMB = ' + CAST(@Ln_IrsRejectCur_MemberSsn_NUMB AS VARCHAR) + ', TypeTransaction_CODE = ' + @Lc_IrsRejectCur_TypeTransaction_CODE + ', TypeArrear_CODE = ' + @Lc_IrsRejectCur_TypeCase_CODE;
          UPDATE h
             SET h.RejectInd_INDC = @Lc_Yes_INDC,
                 h.BeginValidity_DATE = @Ld_Run_DATE,
                 h.WorkerUpdate_ID = @Lc_BatchRunUser_TEXT,
                 h.Update_DTTM = @Ld_Start_DATE,
                 h.TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB
            FROM FEDH_Y1 h
           WHERE h.MemberMci_IDNO = @Ln_MemberMci_IDNO
             AND h.MemberSsn_NUMB = @Ln_IrsRejectCur_MemberSsn_NUMB
             AND h.TypeTransaction_CODE = @Lc_IrsRejectCur_TypeTransaction_CODE
             AND h.TypeArrear_CODE = @Lc_IrsRejectCur_TypeCase_CODE
             AND h.SubmitLast_DATE = (SELECT MAX(e.SubmitLast_DATE)
                                        FROM FEDH_Y1 e
                                       WHERE h.MemberMci_IDNO = e.MemberMci_IDNO
                                         AND h.MemberSsn_NUMB = e.MemberSsn_NUMB
                                         AND h.TypeTransaction_CODE = e.TypeTransaction_CODE
                                         AND h.TypeArrear_CODE = e.TypeArrear_CODE
                                         AND h.TaxYear_NUMB = e.TaxYear_NUMB)
             AND h.TransactionEventSeq_NUMB = (SELECT MAX(e.TransactionEventSeq_NUMB)
                                                 FROM FEDH_Y1 e
                                                WHERE h.MemberMci_IDNO = e.MemberMci_IDNO
                                                  AND h.MemberSsn_NUMB = e.MemberSsn_NUMB
                                                  AND h.TypeTransaction_CODE = e.TypeTransaction_CODE
                                                  AND h.TypeArrear_CODE = e.TypeArrear_CODE
                                                  AND h.TaxYear_NUMB = e.TaxYear_NUMB
                                                  AND h.SubmitLast_DATE = e.SubmitLast_DATE)
AND 1 = (SELECT COUNT(1) FROM FEDH_Y1 X
WHERE X.MemberMci_IDNO = H.MemberMci_IDNO
AND X.SubmitLast_DATE = H.SubmitLast_DATE
AND X.TaxYear_NUMB = H.TaxYear_NUMB
AND X.TransactionEventSeq_NUMB = H.TransactionEventSeq_NUMB
AND X.TypeArrear_CODE = H.TypeArrear_CODE
AND X.TypeTransaction_CODE = H.TypeTransaction_CODE)

          SET @Ln_RowCount_NUMB = @@ROWCOUNT;

          IF @Ln_RowCount_NUMB = 0
           BEGIN
            SET @Ls_ErrorMessage_TEXT = 'UPDATE FEDH_Y1 TABLE FAILED ';

            RAISERROR (50001,16,1);
           END;
         END

        IF @Ln_HfedhExist_NUMB = 1
         BEGIN
          -- Writing the FEDH_Y1 details into HFEDH_Y1 table for tracking history.
          SET @Ls_Sql_TEXT = 'INSERT INTO HFEDH_Y1 3 TABLE';
          SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR), '') + ', MemberSsn_NUMB = ' + ISNULL(CAST(@Ln_IrsRejectCur_MemberSsn_NUMB AS VARCHAR), '') + ', TypeTransaction_CODE = ' + ISNULL(@Lc_IrsRejectCur_TypeTransaction_CODE, '') + ', TypeCase_CODE = ' + ISNULL (@Lc_IrsRejectCur_TypeCase_CODE, '') + ', TaxYear_NUMB = ' + ISNULL(CAST(@Ln_IrsRejectCur_ProcessYear_NUMB AS VARCHAR),'');
          INSERT INTO HFEDH_Y1
                      (MemberMci_IDNO,
                       MemberSsn_NUMB,
                       TypeArrear_CODE,
                       TypeTransaction_CODE,
                       Last_NAME,
                       First_NAME,
                       Middle_NAME,
                       Line1_ADDR,
                       Line2_ADDR,
                       City_ADDR,
                       State_ADDR,
                       Zip_ADDR,
                       ArrearIdentifier_IDNO,
                       Arrear_AMNT,
                       SubmitLast_DATE,
                       ExcludePas_CODE,
                       ExcludeFin_CODE,
                       ExcludeIrs_CODE,
                       ExcludeAdm_CODE,
                       ExcludeRet_CODE,
                       ExcludeSal_CODE,
                       ExcludeDebt_CODE,
                       ExcludeVen_CODE,
                       ExcludeIns_CODE,
                       RejectInd_INDC,
                       CountyFips_CODE,
                       BeginValidity_DATE,
                       EndValidity_DATE,
                       WorkerUpdate_ID,
                       Update_DTTM,
                       TransactionEventSeq_NUMB,
                       ReqPreOffset_CODE,
                       TaxYear_NUMB)
          SELECT h.MemberMci_IDNO,
                 h.MemberSsn_NUMB,
                 h.TypeArrear_CODE,
                 h.TypeTransaction_CODE,
                 h.Last_NAME,
                 h.First_NAME,
                 h.Middle_NAME,
                 h.Line1_ADDR,
                 h.Line2_ADDR,
                 h.City_ADDR,
                 h.State_ADDR,
                 h.Zip_ADDR,
                 h.ArrearIdentifier_IDNO,
                 h.Arrear_AMNT,
                 h.SubmitLast_DATE,
                 h.ExcludePas_CODE,
                 h.ExcludeFin_CODE,
                 h.ExcludeIrs_CODE,
                 h.ExcludeAdm_CODE,
                 h.ExcludeRet_CODE,
                 h.ExcludeSal_CODE,
                 h.ExcludeDebt_CODE,
                 h.ExcludeVen_CODE,
                 h.ExcludeIns_CODE,
                 h.RejectInd_INDC,
                 h.CountyFips_CODE,
                 h.BeginValidity_DATE,
                 @Ld_Run_DATE AS EndValidity_DATE,
                 @Lc_BatchRunUser_TEXT AS WorkerUpdate_ID,
                 @Ld_Start_DATE AS Update_DTTM,
                 @Ln_TransactionEventSeq_NUMB AS TransactionEventSeq_NUMB,
                 h.ReqPreOffset_CODE,
                 h.TaxYear_NUMB
            FROM HFEDH_Y1 h
           WHERE h.MemberMci_IDNO = @Ln_MemberMci_IDNO
             AND h.MemberSsn_NUMB = @Ln_IrsRejectCur_MemberSsn_NUMB
             AND h.TypeTransaction_CODE = @Lc_IrsRejectCur_TypeTransaction_CODE
             AND h.TypeArrear_CODE = @Lc_IrsRejectCur_TypeCase_CODE
             AND h.TaxYear_NUMB = @Ln_IrsRejectCur_ProcessYear_NUMB
             AND h.SubmitLast_DATE = (SELECT MAX(e.SubmitLast_DATE)
                                        FROM HFEDH_Y1 e
                                       WHERE h.MemberMci_IDNO = e.MemberMci_IDNO
                                         AND h.MemberSsn_NUMB = e.MemberSsn_NUMB
                                         AND h.TypeTransaction_CODE = e.TypeTransaction_CODE
                                         AND h.TypeArrear_CODE = e.TypeArrear_CODE
                                         AND h.TaxYear_NUMB = e.TaxYear_NUMB)
             AND h.TransactionEventSeq_NUMB = (SELECT MAX(e.TransactionEventSeq_NUMB)
                                                 FROM HFEDH_Y1 e
                                                WHERE h.MemberMci_IDNO = e.MemberMci_IDNO
                                                  AND h.MemberSsn_NUMB = e.MemberSsn_NUMB
                                                  AND h.TypeTransaction_CODE = e.TypeTransaction_CODE
                                                  AND h.TypeArrear_CODE = e.TypeArrear_CODE
                                                  AND h.TaxYear_NUMB = e.TaxYear_NUMB
                                                  AND h.SubmitLast_DATE = e.SubmitLast_DATE)
AND NOT EXISTS(SELECT 1 FROM HFEDH_Y1 X
WHERE X.MemberMci_IDNO = H.MemberMci_IDNO
AND X.SubmitLast_DATE = H.SubmitLast_DATE
AND X.TaxYear_NUMB = H.TaxYear_NUMB
AND X.TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB
AND X.TypeArrear_CODE = H.TypeArrear_CODE
AND X.TypeTransaction_CODE = H.TypeTransaction_CODE)                                                  
                                                  

          SET @Ln_RowCount_NUMB = @@ROWCOUNT;

          IF @Ln_RowCount_NUMB = 0
           BEGIN
            SET @Ls_ErrorMessage_TEXT = 'INSERT HFEDH_Y1 TABLE FAILED ';

            RAISERROR(50001,16,1);
           END
         END
       END
      SET @Ls_Sql_TEXT = 'CHECK IFMS_Y1 TABLE';
      SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR), '') + ', Case_IDNO = ' + ISNULL(CAST(@Ln_IrsRejectCurArrearIdentifier_IDNO AS VARCHAR), '') + ', MemberSsn_NUMB = ' + ISNULL(CAST(@Ln_IrsRejectCur_MemberSsn_NUMB AS VARCHAR), '') + ', TypeTransaction_CODE = ' + ISNULL(@Lc_IrsRejectCur_TypeTransaction_CODE, '') + ', TypeCase_CODE = ' + ISNULL (@Lc_IrsRejectCur_TypeCase_CODE, '');
      BEGIN
       SELECT @Ln_Count_NUMB = COUNT(1)
         FROM IFMS_Y1 h
        WHERE h.MemberMci_IDNO = @Ln_MemberMci_IDNO
          AND h.TypeTransaction_CODE = @Lc_IrsRejectCur_TypeTransaction_CODE
          AND h.TypeArrear_CODE = @Lc_IrsRejectCur_TypeCase_CODE
          AND h.SubmitLast_DATE = (SELECT MAX(e.SubmitLast_DATE)
                                     FROM IFMS_Y1 e
                                    WHERE h.MemberMci_IDNO = e.MemberMci_IDNO
                                      AND h.Case_IDNO = e.Case_IDNO
                                      AND h.TypeTransaction_CODE = e.TypeTransaction_CODE
                                      AND h.TypeArrear_CODE = e.TypeArrear_CODE);
      END
      IF @Ln_Count_NUMB = 0
       BEGIN
        SET @Lc_BateError_CODE = @Lc_ErrorMemberNotFound_CODE;

        RAISERROR(50001,16,1);
       END
      SET @Ls_Sql_TEXT = 'CHECK RJCS_Y1 TABLE';
      SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR), '') + ', Case_IDNO = ' + ISNULL(CAST(@Ln_IrsRejectCurArrearIdentifier_IDNO AS VARCHAR), '') + ', TypeArrear_CODE = ' + @Lc_IrsRejectCur_TypeCase_CODE + ', EndValidity_DATE = ' + CAST (@Ld_High_DATE AS VARCHAR);

      SELECT @Ln_Count_NUMB = COUNT(1)
        FROM RJCS_Y1 h
       WHERE h.MemberMci_IDNO = @Ln_MemberMci_IDNO
         AND h.TypeArrear_CODE = @Lc_IrsRejectCur_TypeCase_CODE
         AND h.EndValidity_DATE = @Ld_High_DATE;
           
      IF @Ln_Count_NUMB > 0
       BEGIN
        SET @Ls_Sql_TEXT = 'UPDATE RJCS_Y1 TABLE';
        SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR), '') + ', Case_IDNO = ' + ISNULL(CAST(@Ln_IrsRejectCurArrearIdentifier_IDNO AS VARCHAR), '') + ', TypeArrear_CODE = ' + @Lc_IrsRejectCur_TypeCase_CODE + ', EndValidity_DATE = ' + CAST (@Ld_High_DATE AS VARCHAR);

        UPDATE RJCS_Y1
           SET EndValidity_DATE = @Ld_Run_DATE
         WHERE MemberMci_IDNO = @Ln_MemberMci_IDNO
           AND TypeArrear_CODE = @Lc_IrsRejectCur_TypeCase_CODE
           AND EndValidity_DATE = @Ld_High_DATE;

        SET @Ln_RowCount_NUMB = @@ROWCOUNT;

        IF @Ln_RowCount_NUMB = 0
         BEGIN
          SET @Ls_ErrorMessage_TEXT = 'UPDATE RJCS_Y1 TABLE FAILED ';

          RAISERROR (50001,16,1);
         END;
       END
      -- Insert the reject details received from IRS into RJCS_Y1 table
      SET @Ls_Sql_TEXT = 'INSERT RJCS_Y1 TABLE';
      SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + CAST(@Ln_IrsRejectCurArrearIdentifier_IDNO AS VARCHAR) + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR), '') + ', TypeArrear_CODE = ' + ISNULL(@Lc_IrsRejectCur_TypeCase_CODE, '') + ', TypeTransaction_CODE = ' + ISNULL(@Lc_IrsRejectCur_TypeTransaction_CODE, '');
      INSERT INTO RJCS_Y1
                  (MemberMci_IDNO,
                   Case_IDNO,
                   TypeArrear_CODE,
                   Arrear_AMNT,
                   ExcludeIrs_CODE,
                   ExcludeAdm_CODE,
                   ExcludeFin_CODE,
                   ExcludePas_CODE,
                   ExcludeRet_CODE,
                   ExcludeSal_CODE,
                   ExcludeDebt_CODE,
                   ExcludeVen_CODE,
                   ExcludeIns_CODE,
                   BeginValidity_DATE,
                   EndValidity_DATE,
                   WorkerUpdate_ID,
                   Update_DTTM,
                   TransactionEventSeq_NUMB,
                   County_IDNO)
      SELECT DISTINCT
             @Ln_MemberMci_IDNO AS MemberMci_IDNO,
             Case_IDNO,
             TypeArrear_CODE,
             Transaction_AMNT,
             ExcludeIrs_CODE,
             ExcludeAdm_CODE,
             ExcludeFin_CODE,
             ExcludePas_CODE,
             ExcludeRet_CODE,
             ExcludeSal_CODE,
             ExcludeDebt_CODE,
             ExcludeVen_CODE,
             ExcludeIns_CODE,
             @Ld_Run_DATE AS BeginValidity_DATE,
             @Ld_High_DATE AS EndValidity_DATE,
             @Lc_BatchRunUser_TEXT AS WorkerUpdate_ID,
             @Ld_Start_DATE AS Update_DTTM,
             @Ln_TransactionEventSeq_NUMB AS TransactionEventSeq_NUMB,
             ISNULL ((SELECT c.County_IDNO
                        FROM IRSA_Y1 c
                       WHERE c.MemberMci_IDNO = b.MemberMci_IDNO
                         AND c.Case_IDNO = b.Case_IDNO
                         ), 0) AS County_IDNO
        FROM IFMS_Y1 b
       WHERE b.MemberMci_IDNO = @Ln_MemberMci_IDNO
         AND b.TypeArrear_CODE = @Lc_IrsRejectCur_TypeCase_CODE
         AND b.TypeTransaction_CODE = @Lc_IrsRejectCur_TypeTransaction_CODE
         AND b.SubmitLast_DATE = (SELECT MAX (f.SubmitLast_DATE)
                                    FROM IFMS_Y1 f
                                   WHERE b.MemberMci_IDNO = f.MemberMci_IDNO
                                     AND b.Case_IDNO = f.Case_IDNO
                                     AND b.TypeArrear_CODE = f.TypeArrear_CODE
                                     AND b.TypeTransaction_CODE = f.TypeTransaction_CODE);

      SET @Ln_RowCount_NUMB = @@ROWCOUNT;

      IF @Ln_RowCount_NUMB = 0
       BEGIN
        SET @Ls_ErrorMessage_TEXT = 'INSERT RJCS_Y1 TABLE FAILED ';

        RAISERROR (50001,16,1);
       END;

      -- Updates IFMS_Y1 only if error received
      IF @Lc_UpdateFlag_INDC <> 'N'
       BEGIN
        -- Delete the IFMS_Y1 details which was rejected by IRS
        IF @Lc_IrsRejectCur_TypeTransaction_CODE IN ('A', 'M', 'D')
         BEGIN
          SET @Ls_Sql_TEXT = 'DELETE IFMS_Y1 TABLE';
          SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR), '') + ', TypeArrear_CODE = ' + ISNULL(@Lc_IrsRejectCur_TypeCase_CODE, '') + ', TypeTransaction_CODE = ' + ISNULL(@Lc_IrsRejectCur_TypeTransaction_CODE, '');

          DELETE b
            FROM IFMS_Y1 b
           WHERE b.MemberMci_IDNO = @Ln_MemberMci_IDNO
             AND b.TypeArrear_CODE = @Lc_IrsRejectCur_TypeCase_CODE
             AND b.TypeTransaction_CODE = @Lc_IrsRejectCur_TypeTransaction_CODE
             AND @Lc_IrsRejectCur_TypeTransaction_CODE IN ('A', 'M', 'D')
             AND SubmitLast_DATE = (SELECT MAX (f.SubmitLast_DATE)
                                      FROM IFMS_Y1 f
                                     WHERE b.MemberMci_IDNO = f.MemberMci_IDNO
                                       AND b.Case_IDNO = f.Case_IDNO
                                       AND b.TypeArrear_CODE = f.TypeArrear_CODE
                                       AND b.TypeTransaction_CODE = f.TypeTransaction_CODE);

          SET @Ln_RowCount_NUMB = @@ROWCOUNT;

          IF @Ln_RowCount_NUMB = 0
           BEGIN
            SET @Ls_ErrorMessage_TEXT = 'DELETE IFMS_Y1 TABLE FAILED ';

            RAISERROR (50001,16,1);
           END;

          SET @Ls_Sql_TEXT = 'SELECT HIFMS_Y1 COUNT';
          SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + CAST(@Ln_MemberMci_IDNO AS VARCHAR) + ', TypeArrear_CODE = ' + @Lc_IrsRejectCur_TypeCase_CODE;

          SELECT @Ln_Count_NUMB = COUNT(1)
            FROM HIFMS_Y1 a
           WHERE a.MemberMci_IDNO = @Ln_MemberMci_IDNO
             AND a.TypeArrear_CODE = @Lc_IrsRejectCur_TypeCase_CODE
             AND a.TypeTransaction_CODE IN ('A', 'M', 'D')
             AND a.SubmitLast_DATE = (SELECT MAX (d.SubmitLast_DATE)
                                        FROM HIFMS_Y1 d
                                       WHERE d.MemberMci_IDNO = a.MemberMci_IDNO
                                         AND d.Case_IDNO = a.Case_IDNO
                                         AND d.TypeArrear_CODE = a.TypeArrear_CODE
                                         AND d.TypeTransaction_CODE IN ('A', 'M', 'D'))
             AND a.TransactionEventSeq_NUMB = (SELECT MAX (d.TransactionEventSeq_NUMB)
                                        FROM HIFMS_Y1 d
                                       WHERE d.MemberMci_IDNO = a.MemberMci_IDNO
                                         AND d.Case_IDNO = a.Case_IDNO
                                         AND d.TypeArrear_CODE = a.TypeArrear_CODE
                                         AND d.TypeTransaction_CODE IN ('A', 'M', 'D')
                                         AND d.SubmitLast_DATE = a.SubmitLast_DATE)
             AND NOT EXISTS (SELECT 1
                               FROM IFMS_Y1 e
                              WHERE e.MemberMci_IDNO = a.MemberMci_IDNO
                                AND e.Case_IDNO = a.Case_IDNO
                                AND e.TypeArrear_CODE = a.TypeArrear_CODE
                                AND e.TypeTransaction_CODE = a.TypeTransaction_CODE);

          IF @Ln_Count_NUMB > 0
           BEGIN
            SET @Ls_Sql_TEXT = 'INSERT IFMS_Y1 TABLE';
            SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + CAST(@Ln_MemberMci_IDNO AS VARCHAR) + ', TypeArrear_CODE = ' + @Lc_IrsRejectCur_TypeCase_CODE;

            INSERT INTO IFMS_Y1
                        (MemberMci_IDNO,
                         Case_IDNO,
                         MemberSsn_NUMB,
                         Last_NAME,
                         First_NAME,
                         Middle_NAME,
                         TaxYear_NUMB,
                         TypeArrear_CODE,
                         Transaction_AMNT,
                         SubmitLast_DATE,
                         TypeTransaction_CODE,
                         CountyFips_CODE,
                         Certified_DATE,
                         StateAdministration_CODE,
                         ExcludeIrs_CODE,
                         ExcludeAdm_CODE,
                         ExcludeFin_CODE,
                         ExcludePas_CODE,
                         ExcludeRet_CODE,
                         ExcludeSal_CODE,
                         ExcludeDebt_CODE,
                         ExcludeVen_CODE,
                         ExcludeIns_CODE,
                         WorkerUpdate_ID,
                         Update_DTTM,
                         TransactionEventSeq_NUMB)
            SELECT DISTINCT
                   a.MemberMci_IDNO,
                   a.Case_IDNO,
                   a.MemberSsn_NUMB,
                   a.Last_NAME,
                   a.First_NAME,
                   a.Middle_NAME,
                   a.TaxYear_NUMB,
                   a.TypeArrear_CODE,
                   a.Transaction_AMNT,
                   a.SubmitLast_DATE,
                   a.TypeTransaction_CODE,
                   a.CountyFips_CODE,
                   a.Certified_DATE,
                   a.StateAdministration_CODE,
                   a.ExcludeIrs_CODE,
                   a.ExcludeAdm_CODE,
                   a.ExcludeFin_CODE,
                   a.ExcludePas_CODE,
                   a.ExcludeRet_CODE,
                   a.ExcludeSal_CODE,
                   a.ExcludeDebt_CODE,
                   a.ExcludeVen_CODE,
                   a.ExcludeIns_CODE,
                   a.WorkerUpdate_ID,
                   a.Update_DTTM,
                   a.TransactionEventSeq_NUMB
              FROM HIFMS_Y1 a
             WHERE a.MemberMci_IDNO = @Ln_MemberMci_IDNO
               AND a.TypeArrear_CODE = @Lc_IrsRejectCur_TypeCase_CODE
			   AND a.TypeTransaction_CODE IN ('A', 'M', 'D')
               AND a.SubmitLast_DATE = (SELECT MAX (d.SubmitLast_DATE)
                                          FROM HIFMS_Y1 d
                                         WHERE d.MemberMci_IDNO = a.MemberMci_IDNO
                                           AND d.Case_IDNO = a.Case_IDNO
                                           AND d.TypeArrear_CODE = a.TypeArrear_CODE
                                           AND d.TypeTransaction_CODE IN ('A', 'M', 'D'))
             AND a.TransactionEventSeq_NUMB = (SELECT MAX (d.TransactionEventSeq_NUMB)
                                        FROM HIFMS_Y1 d
                                       WHERE d.MemberMci_IDNO = a.MemberMci_IDNO
                                         AND d.Case_IDNO = a.Case_IDNO
                                         AND d.TypeArrear_CODE = a.TypeArrear_CODE
                                         AND d.TypeTransaction_CODE IN ('A', 'M', 'D')
                                         AND d.SubmitLast_DATE = a.SubmitLast_DATE)                                           
AND NOT EXISTS(SELECT 1 FROM IFMS_Y1 X
WHERE X.Case_IDNO = a.Case_IDNO
AND X.MemberMci_IDNO = a.MemberMci_IDNO
AND X.SubmitLast_DATE = a.SubmitLast_DATE
AND X.TaxYear_NUMB = a.TaxYear_NUMB
AND X.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB
AND X.TypeArrear_CODE = a.TypeArrear_CODE
AND X.TypeTransaction_CODE = a.TypeTransaction_CODE)                 

            SET @Ln_RowCount_NUMB = @@ROWCOUNT;

            IF @Ln_RowCount_NUMB = 0
             BEGIN
              SET @Ls_ErrorMessage_TEXT = 'INSERT IFMS_Y1 TABLE FAILED2 ';

              RAISERROR (50001,16,1);
             END;

            -- Delete the HIFMS_Y1 details which was copied to IFMS_Y1 table
            SET @Ls_Sql_TEXT = 'DELETE HIFMS TABLE';
			SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + CAST(@Ln_MemberMci_IDNO AS VARCHAR) + ', TypeArrear_CODE = ' + @Lc_IrsRejectCur_TypeCase_CODE;
            DELETE b
              FROM HIFMS_Y1 b
             WHERE b.MemberMci_IDNO = @Ln_MemberMci_IDNO
               AND b.TypeArrear_CODE = @Lc_IrsRejectCur_TypeCase_CODE
			   AND b.TypeTransaction_CODE IN ('A', 'M', 'D')
               AND b.SubmitLast_DATE = (SELECT MAX (f.SubmitLast_DATE)
                                          FROM HIFMS_Y1 f
                                         WHERE b.MemberMci_IDNO = f.MemberMci_IDNO
                                           AND b.Case_IDNO = f.Case_IDNO
                                           AND b.TypeArrear_CODE = f.TypeArrear_CODE
                                           AND f.TypeTransaction_CODE IN ('A', 'M', 'D'))
             AND b.TransactionEventSeq_NUMB = (SELECT MAX (f.TransactionEventSeq_NUMB)
                                        FROM HIFMS_Y1 f
                                       WHERE f.MemberMci_IDNO = b.MemberMci_IDNO
                                         AND f.Case_IDNO = b.Case_IDNO
                                         AND f.TypeArrear_CODE = b.TypeArrear_CODE
                                         AND f.TypeTransaction_CODE IN ('A', 'M', 'D')
                                         AND f.SubmitLast_DATE = b.SubmitLast_DATE)                                            
AND EXISTS(SELECT 1 FROM IFMS_Y1 X
WHERE X.Case_IDNO = B.Case_IDNO
AND X.MemberMci_IDNO = B.MemberMci_IDNO
AND X.SubmitLast_DATE = B.SubmitLast_DATE
AND X.TaxYear_NUMB = B.TaxYear_NUMB
AND X.TransactionEventSeq_NUMB = B.TransactionEventSeq_NUMB
AND X.TypeArrear_CODE = B.TypeArrear_CODE
AND X.TypeTransaction_CODE = B.TypeTransaction_CODE)                   

            SET @Ln_RowCount_NUMB = @@ROWCOUNT;

            IF @Ln_RowCount_NUMB = 0
             BEGIN
              SET @Ls_ErrorMessage_TEXT = 'DELETE IFMS_Y1 TABLE FAILED2  ';
              RAISERROR (50001,16,1);
             END;
           END
         END
       END
     END TRY

     BEGIN CATCH
       -- Rollback the save point.
      IF XACT_STATE() = 1
        BEGIN
         ROLLBACK TRANSACTION SAVEIRSREJECT_PROCESS;
        END
       ELSE
        BEGIN
         SET @Ls_ErrorMessage_TEXT = @Ls_ErrorMessage_TEXT + ' ' + SUBSTRING (ERROR_MESSAGE (), 1, 200);

         RAISERROR( 50001,16,1);
        END
 
	  -- Check for Exception information to log the description text based on the error	
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

      SET @Ls_BateRecord_TEXT = 'BateRecord_TEXT = ' + @Ls_BateRecord_TEXT + ', Error Description = ' + @Ls_DescriptionError_TEXT;

      EXECUTE BATCH_COMMON$SP_BATE_LOG
       @As_Process_NAME             = @Ls_Process_NAME,
       @As_Procedure_NAME           = @Ls_Procedure_NAME,
       @Ac_Job_ID                   = @Lc_Job_ID,
       @Ad_Run_DATE                 = @Ld_Run_DATE,
       @Ac_TypeError_CODE           = @Lc_TypeError_CODE,
       @An_Line_NUMB                = @Ln_Cursor_QNTY,
       @Ac_Error_CODE               = @Lc_BateError_CODE,
       @As_DescriptionError_TEXT    = @Ls_BateRecord_TEXT,
       @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
       @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
       @As_DescriptionErrorOut_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

      IF @Lc_Msg_CODE = @Lc_TypeErrorE_CODE
        BEGIN
         SET @Ln_ExceptionThreshold_QNTY = @Ln_ExceptionThreshold_QNTY + 1;
        END
       ELSE IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         RAISERROR (50001,16,1);
        END
     END CATCH

     SET @Ls_Sql_TEXT = 'UPDATING LIREJ_Y1';
     SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(LTRIM(RTRIM(@Lc_IrsRejectCurArrearIdentifierIdno_TEXT)), ' ') + ', MemberSsn_NUMB = ' + ISNULL(@Lc_IrsRejectCur_MemberSsnNumb_TEXT, '') + ', TypeCase_CODE = ' + ISNULL(@Lc_IrsRejectCur_TypeCase_CODE, '') + ', TransType_CODE = ' + ISNULL (@Lc_IrsRejectCur_TypeTransaction_CODE, '') + ', Process_INDC = ' + @Lc_No_INDC;
     UPDATE LIREJ_Y1
        SET Process_INDC = @Lc_Yes_INDC
      WHERE ISNULL(LTRIM(RTRIM(Case_IDNO)), ' ') = ISNULL(LTRIM(RTRIM(@Lc_IrsRejectCurArrearIdentifierIdno_TEXT)), ' ')
        AND MemberSsn_NUMB = @Lc_IrsRejectCur_MemberSsnNumb_TEXT
        AND TypeCase_CODE = @Lc_IrsRejectCur_TypeCase_CODE
        AND TransType_CODE = @Lc_IrsRejectCur_TypeTransaction_CODE
        AND Process_INDC = @Lc_No_INDC
        AND Seq_IDNO = @Ln_IrsRejectCur_Seq_IDNO;

     SET @Ln_Rowcount_QNTY = @@ROWCOUNT;

     IF @Ln_Rowcount_QNTY = 0
      BEGIN
       SET @Ls_ErrorMessage_TEXT = 'UPDATE LOAD_IRS_REJECT FAILED';

       RAISERROR(50001,16,1);
      END

     SET @Ln_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY + 1;

     -- Reset the commit count, Commit the transaction completed until now.
     SET @Ls_Sql_TEXT = 'COMMIT COUNT CHECK';
     SET @Ls_Sqldata_TEXT = 'CommitFreq_QNTY = ' + CAST(@Ln_CommitFreq_QNTY AS VARCHAR) + ', CommitFreqParm_QNTY = ' + CAST(@Ln_CommitFreqParm_QNTY AS VARCHAR);
     IF @Ln_CommitFreq_QNTY >= @Ln_CommitFreqParm_QNTY
        AND @Ln_CommitFreqParm_QNTY <> 0
      BEGIN
       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATCH_RESTART_UPDATE';
       SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', Cursor_QNTY = ' + ISNULL(CAST(@Ln_Cursor_QNTY AS VARCHAR), '');

       EXECUTE BATCH_COMMON$SP_BATCH_RESTART_UPDATE
        @Ac_Job_ID                = @Lc_Job_ID,
        @Ad_Run_DATE              = @Ld_Run_DATE,
        @As_RestartKey_TEXT       = @Ln_Cursor_QNTY,
        @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         RAISERROR(50001,16,1);
        END

       COMMIT TRANSACTION IRSRejects;

       SET @Ln_ProcessedRecordsCommit_QNTY = @Ln_ProcessedRecordsCommit_QNTY + @Ln_CommitFreqParm_QNTY;

       BEGIN TRANSACTION IRSRejects;

       SET @Ln_CommitFreq_QNTY = 0;
      END
      
      SET @Ls_Sql_TEXT = 'REACHED EXCEPTION THRESHOLD';
      SET @Ls_Sqldata_TEXT = 'ExceptionThreshold_QNTY = ' + CAST(@Ln_ExceptionThreshold_QNTY AS VARCHAR) + ', ExceptionThresholdParm_QNTY = ' + CAST(@Ln_ExceptionThresholdParm_QNTY AS VARCHAR);
      IF @Ln_ExceptionThreshold_QNTY > @Ln_ExceptionThresholdParm_QNTY
       BEGIN
        
        COMMIT TRANSACTION IRSRejects;
        SET @Ln_ProcessedRecordsCommit_QNTY = @Ln_ProcessedRecordCount_QNTY;
        SET @Ls_ErrorMessage_TEXT = 'REACHED EXCEPTION THRESHOLD';

        RAISERROR (50001,16,1);
       END

     SET @Ls_Sql_TEXT = 'FETCH IrsReject_CUR - 2';
     SET @Ls_Sqldata_TEXT = '';

     FETCH NEXT FROM IrsReject_CUR INTO @Ln_IrsRejectCur_Seq_IDNO,@Lc_IrsRejectCur_Local_CODE, @Lc_IrsRejectCurArrearIdentifierIdno_TEXT, @Lc_IrsRejectCur_MemberSsnNumb_TEXT, @Lc_IrsRejectCur_Last_NAME, @Lc_IrsRejectCur_First_NAME, @Lc_IrsRejectCur_ArrearsAmnt_TEXT, @Lc_IrsRejectCur_TypeTransaction_CODE, @Lc_IrsRejectCur_Issued_DATE, @Lc_IrsRejectCur_Error_CODE, @Lc_IrsRejectCur_TypeCase_CODE, @Lc_IrsRejectCur_Line1_ADDR, @Lc_IrsRejectCur_Line2_ADDR, @Lc_IrsRejectCur_State_ADDR, @Lc_IrsRejectCur_Zip_ADDR, @Lc_IrsRejectCur_TypeOffsetExcl_CODE, @Lc_IrsRejectCur_ProcessYearNumb_TEXT, @Lc_IrsRejectCur_LastNcp_NAME;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END

   CLOSE IrsReject_CUR;

   DEALLOCATE IrsReject_CUR;

   IF @Ln_CursorRecord_QNTY = 0
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG 2';
     SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + @Ls_Process_NAME + ', Procedure_NAME = ' + @Ls_Procedure_NAME + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', TypeError_CODE = ' + @Lc_ErrorTypeWarning_CODE + ', Line_NUMB = ' + CAST(@Ln_Cursor_QNTY AS VARCHAR) + ', Error_CODE = ' + @Lc_ErrorNoRecords_CODE + ', DescriptionError_TEXT = ' + @Ls_BateRecord_TEXT + ', ListKey_TEXT = ' + @Ls_Sqldata_TEXT;

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Ls_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_ErrorTypeWarning_CODE,
      @An_Line_NUMB                = @Ln_Cursor_QNTY,
      @Ac_Error_CODE               = @Lc_ErrorNoRecords_CODE,
      @As_DescriptionError_TEXT    = @Ls_BateRecord_TEXT,
      @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END
    END

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR(50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATCH_RESTART_UPDATE2';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', Cursor_QNTY = ' + ISNULL(CAST(@Ln_Cursor_QNTY AS VARCHAR), '');

   EXECUTE BATCH_COMMON$SP_BATCH_RESTART_UPDATE
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @As_RestartKey_TEXT       = @Ln_Cursor_QNTY,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR(50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BSTL_LOG';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', Start_DATE = ' + CAST(@Ld_Start_DATE AS VARCHAR) + ', Job_ID = ' + @Lc_Job_ID + ', Process_NAME = ' + @Ls_Process_NAME + ', Procedure_NAME = ' + @Ls_Procedure_NAME + ', CursorLoc_TEXT = ' + @Lc_Space_TEXT + ', ExecLocation_TEXT = ' + @Lc_Successful_TEXT + ', ExecLocation_TEXT = ' + @Lc_Successful_TEXT + ', DescriptionError_TEXT = ' + @Lc_Space_TEXT + ', Status_CODE = ' + @Lc_StatusSuccess_CODE + ', Worker_ID = ' + @Lc_BatchRunUser_TEXT + ', ProcessedRecordCount_QNTY = ' + CAST(@Ln_ProcessedRecordCount_QNTY AS VARCHAR);

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Lc_Space_TEXT,
    @As_ExecLocation_TEXT         = @Lc_Successful_TEXT,
    @As_ListKey_TEXT              = @Lc_Successful_TEXT,
    @As_DescriptionError_TEXT     = @Lc_Space_TEXT,
    @Ac_Status_CODE               = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;

   COMMIT TRANSACTION IRSRejects;
  END TRY

  BEGIN CATCH
   -- Check if active transaction exists for this session then rollback the transaction
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION IRSRejects;
    END
   -- Check if cursor is open close and deallocate it
   IF CURSOR_STATUS ('LOCAL', 'IrsReject_CUR') IN (0, 1)
    BEGIN
     CLOSE IrsReject_CUR;

     DEALLOCATE IrsReject_CUR;
    END

   -- Check for Exception information to log the description text based on the error	
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
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Ls_CursorLocation_TEXT,
    @As_ExecLocation_TEXT         = @Ls_Sql_TEXT,
    @As_ListKey_TEXT              = @Ls_Sqldata_TEXT,
    @As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE               = @Lc_StatusAbnormalend_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordsCommit_QNTY;

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH
 END


GO
