/****** Object:  StoredProcedure [dbo].[BATCH_FIN_TANF_GRANT$SP_PROCESS_UPDATE_TANF_GRANT]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name    :	BATCH_FIN_TANF_GRANT$SP_PROCESS_UPDATE_TANF_GRANT
Programmer Name   :	Imp Team
Description       :	This process reads the data from the temporary table and updates the Monthly Grant Modification
					TANF GRANT (IVMG_Y1) table.
Frequency		  : Monthly					
Developed On      :	12/29/2011
Called BY         :	None
Called On		  :	BATCH_COMMON$SP_GET_BATCH_DETAILS,
					BATCH_COMMON$BATE_LOG,  
					BATCH_COMMON$BSTL_LOG,
					BATCH_COMMON$SP_UPDATE_PARM_DATE,
					BATCH_COMMON_PRORATE_GRANT$SP_GRANT_SPLIT_IVMG,
-------------------------------------------------------------------------------------------------------------------						
Modified BY       :
Modified On       :
Version No        :	0.01
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_FIN_TANF_GRANT$SP_PROCESS_UPDATE_TANF_GRANT]
AS
 BEGIN
  SET NOCOUNT ON;
  --13347 - Chaning functional seq to 2730, same as IVMG screen -START-
  DECLARE @Li_TanfGrantSplit2730_NUMB INT = 2730,
  --13347 - Chaning functional seq to 2730, same as IVMG screen -END-
          @Lc_StatusFailed_CODE            CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE           CHAR(1) = 'S',
          @Lc_StatusAbnormalend_CODE       CHAR(1) = 'A',
          @Lc_IndNote_TEXT                 CHAR(1) = 'N',
          @Lc_TypeErrorE_CODE              CHAR(1) = 'E',
          @Lc_ProcessY_INDC                CHAR(1) = 'Y',
          @Lc_ProcessN_INDC                CHAR(1) = 'N',
          @Lc_WelfareEligTanf_CODE         CHAR(1) = 'A',
          @Lc_Msg_CODE                     CHAR(1) = ' ',
          @Lc_Space_TEXT                   CHAR(1) = ' ',
          @Lc_TypeAdjust_CODE              CHAR(1) = ' ',
          @Lc_AdjustLtdFlag_INDC           CHAR(1) = ' ',
          @Lc_ZeroGrant_INDC               CHAR(1) = ' ',
          @Lc_BatchRunUser_TEXT            CHAR(5) = 'BATCH',
          @Lc_ErrorE0085_CODE              CHAR(5) = 'E0085',
          @Lc_ErrorE0961_CODE              CHAR(5) = 'E0961',
		  @Lc_ErrorE0869_CODE			   CHAR(5) = 'E0869',
		  @Lc_ErrorE1424_CODE			   CHAR(5) = 'E1424',
          @Lc_ErrorE0944_CODE              CHAR(5) = 'E0944',
          @Lc_BateError_CODE               CHAR(5) = ' ',
          @Lc_Job_ID                       CHAR(7) = 'DEB0570',
          @Lc_Successful_TEXT              CHAR(20) = 'SUCCESSFUL',
          @Lc_Err0002_TEXT                 CHAR(30) = 'UPDATE NOT SUCCESSFUL',
          @Ls_ParmDateProblem_TEXT         VARCHAR(50) = 'PARM DATE PROBLEM',
          --13347 - Description note to UNOT_Y1 -START-
          @Ls_DescriptionNote_TEXT		   VARCHAR(100) = 'MONTHLY IVA GRANT ADDED/MODIFIED IN DECSS SYSTEM BY TANF GRANT BATCH',	
          --13347 - Description note to UNOT_Y1 -END-
          @Ls_Process_NAME                 VARCHAR(100) = 'BATCH_FIN_TANF_GRANT',
          @Ls_Procedure_NAME               VARCHAR(100) = 'SP_PROCESS_UPDATE_TANF_GRANT',
          @Ls_CursorLocation_TEXT          VARCHAR(200) = ' ',
          @Ls_Sql_TEXT                     VARCHAR(2000) = ' ',
          @Ls_ErrorMessage_TEXT            VARCHAR(4000) = ' ',
          @Ls_DescriptionError_TEXT        VARCHAR(4000) = ' ',
          @Ls_BateRecord_TEXT              VARCHAR(4000) = ' ',
          @Ls_Sqldata_TEXT                 VARCHAR(5000) = ' ';
  DECLARE @Ln_ExceptionThreshold_QNTY      NUMERIC(5) = 0,
          @Ln_ExceptionThresholdParm_QNTY  NUMERIC(5) = 0,
          @Ln_CommitFreq_QNTY              NUMERIC(5) = 0,
          @Ln_CommitFreqParm_QNTY          NUMERIC(5) = 0,
          @Ln_Zero_NUMB                    NUMERIC(5) = 0,
          @Ln_RestartLine_NUMB             NUMERIC(5) = 0,
          @Ln_ProcessedRecordCount_QNTY    NUMERIC(6) = 0,
          @Ln_SelectedWelfareYyyymm_NUMB   NUMERIC(6) = 0,
          @Ln_ProcessedRecordsCommit_QNTY  NUMERIC(6) = 0,
          @Ln_CurrentWelfare_NUMB          NUMERIC(6) = 0,
          @Ln_RunDateWelfare_NUMB          NUMERIC(6) = 0,
          @Ln_PrevWelfare_NUMB             NUMERIC(6) = 0,
          @Ln_RecCount_NUMB                NUMERIC(10) = 0,
          @Ln_Error_NUMB                   NUMERIC(11) = 0,
          @Ln_ErrorLine_NUMB               NUMERIC(11) = 0,
		  @Ln_Defra_AMNT			       NUMERIC(11, 2) = 0,
		  @Ln_TransactionAssistExpend_AMNT NUMERIC(11, 2) = 0,
          @Ln_MtdAssistExpend_AMNT         NUMERIC(11, 2) = 0,
          @Ln_LtdAssistExpend_AMNT         NUMERIC(11, 2) = 0,
          @Ln_TransactionAssistRecoup_AMNT NUMERIC(11, 2) = 0,
          @Ln_MtdAssistRecoup_AMNT         NUMERIC(11, 2) = 0,
          @Ln_LtdAssistRecoup_AMNT         NUMERIC(11, 2) = 0,
          @Ln_EventGlobalSeq_NUMB          NUMERIC(18) = 0,
          @Li_FetchStatus_QNTY             SMALLINT,
          @Li_RowsCount_QNTY               SMALLINT,
          @Ld_Run_DATE                     DATE,
          @Ld_LastRun_DATE                 DATE,
          @Ld_Start_DATE                   DATETIME2;
  DECLARE IvaGrant_CUR INSENSITIVE CURSOR FOR
   SELECT a.Seq_IDNO,
          a.CaseWelfare_IDNO,
          a.GrantYearMonth_NUMB,
          a.Grant_AMNT,
          a.MemberMci_IDNO,
          a.DefraYearMonth_NUMB,
          a.Defra_AMNT
     FROM LTGRA_Y1 a
    WHERE a.Process_INDC = @Lc_ProcessN_INDC
      --13347 - Not to process future grant -START-
      AND a.GrantYearMonth_NUMB <= CONVERT(CHAR(6), a.FileLoad_DATE, 112)
      --13347 - Not to process future grant -END-
    ORDER BY a.Seq_IDNO ASC;
  DECLARE @Ln_IvaGrantCur_Seq_IDNO                NUMERIC(19),
          @Lc_IvaGrantCur_WelfareCaseIdno_TEXT    CHAR(10),
          @Lc_IvaGrantCur_GrantYearMonthNumb_TEXT CHAR(6),
          @Lc_IvaGrantCur_GrantAmnt_TEXT          CHAR(12),
          @Lc_IvaGrantCur_MemberMciIdno_TEXT      CHAR(10),
          @Lc_IvaGrantCur_DefraYearMonthNumb_TEXT CHAR(6),
          @Lc_IvaGrantCur_DefraAmnt_TEXT          CHAR(12);
  DECLARE @Ln_IvaGrantCurGrantYearMonth_NUMB  NUMERIC(6),
          @Ln_IvaGrantCur_DefraYearMonth_NUMB NUMERIC(6),
          @Ln_IvaGrantCurGrant_AMNT           NUMERIC(9, 2),
          @Ln_IvaGrantCurDefra_AMNT           NUMERIC(9, 2),
          @Ln_IvaGrantCurCaseWelfare_IDNO     NUMERIC(10),
          @Ln_IvaGrantCurMemberMciCp_IDNO     NUMERIC(10);

  BEGIN TRY
   SET @Ls_Sql_TEXT = 'TRASACTION BEGINS - 1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   BEGIN TRANSACTION IVAGRANT_PROCESS;

   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;

   EXECUTE BATCH_COMMON$SP_GET_BATCH_DETAILS
    @Ac_Job_ID                  = @Lc_Job_ID,
    @Ad_Run_DATE                = @Ld_Run_DATE OUTPUT,
    @Ad_LastRun_DATE            = @Ld_LastRun_DATE OUTPUT,
    @An_CommitFreq_QNTY         = @Ln_CommitFreqParm_QNTY OUTPUT,
    @An_ExceptionThreshold_QNTY = @Ln_ExceptionThresholdParm_QNTY OUTPUT,
    @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT   = @Ls_DescriptionError_TEXT OUTPUT;

   SET @Ln_RunDateWelfare_NUMB = CONVERT(VARCHAR(6), @Ld_Run_DATE, 112);

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'RUN DATE AND LAST RUN DATE VALIDATION';
   SET @Ls_Sqldata_TEXT = 'LAST RUN DATE = ' + CAST(@Ld_LastRun_DATE AS VARCHAR) + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   IF DATEADD(D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_DescriptionError_TEXT = @Ls_ParmDateProblem_TEXT;

     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'CHECK KEY EXISTS';
   SET @Ls_Sqldata_TEXT ='Job_ID = ' + @Lc_Job_ID + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   SELECT @Ln_RestartLine_NUMB = CAST(RestartKey_TEXT AS NUMERIC)
     FROM RSTL_Y1 r
    WHERE r.Job_ID = @Lc_Job_ID
      AND r.Run_DATE = @Ld_Run_DATE;

   SET @Ls_Sql_TEXT = 'DELETE DUPLICATE BATE RECORDS';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', LINE NUMBER = ' + CAST(@Ln_RestartLine_NUMB AS VARCHAR);

   DELETE BATE_Y1
    WHERE Job_ID = @Lc_Job_ID
      AND EffectiveRun_DATE = @Ld_Run_DATE
      AND Line_NUMB > @Ln_RestartLine_NUMB;

   SET @Ls_Sql_TEXT = 'OPEN IvaGrant_CUR';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   OPEN IvaGrant_CUR;

   SET @Ls_Sql_TEXT = 'FETCH IvaGrant_CUR';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   FETCH NEXT FROM IvaGrant_CUR INTO @Ln_IvaGrantCur_Seq_IDNO, @Lc_IvaGrantCur_WelfareCaseIdno_TEXT, @Lc_IvaGrantCur_GrantYearMonthNumb_TEXT, @Lc_IvaGrantCur_GrantAmnt_TEXT, @Lc_IvaGrantCur_MemberMciIdno_TEXT, @Lc_IvaGrantCur_DefraYearMonthNumb_TEXT, @Lc_IvaGrantCur_DefraAmnt_TEXT;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;

   IF @Li_FetchStatus_QNTY <> 0
    BEGIN
     SET @Lc_BateError_CODE = @Lc_ErrorE0944_CODE;
    END;

   -- process each record
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
     BEGIN TRY
      SET @Ls_Sql_TEXT = 'SAVE TRASACTION BEGINS - 2';
      SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

      SAVE TRANSACTION SAVEIVAGRANT_PROCESS;

      SET @Ls_BateRecord_TEXT = 'Sequence IDNO = ' + CAST(@Ln_IvaGrantCur_Seq_IDNO AS VARCHAR) + ', Welfare Case Idno = ' + @Lc_IvaGrantCur_WelfareCaseIdno_TEXT + ', Welfare Year Month = ' + @Lc_IvaGrantCur_GrantYearMonthNumb_TEXT + ', Grant Amount = ' + @Lc_IvaGrantCur_GrantAmnt_TEXT + ', Cp Mci Number = ' + @Lc_IvaGrantCur_MemberMciIdno_TEXT + ', Defra Year Month = ' + @Lc_IvaGrantCur_DefraYearMonthNumb_TEXT + ', Defra Amount = ' + @Lc_IvaGrantCur_DefraAmnt_TEXT;
      SET @Lc_BateError_CODE = @Lc_Space_TEXT;
      SET @Ln_RecCount_NUMB = @Ln_RecCount_NUMB + 1;
      SET @Ls_CursorLocation_TEXT = 'TANF MONTHLY GRANT - CURSOR COUNT - ' + CAST(@Ln_RecCount_NUMB AS VARCHAR);
      SET @Ls_Sql_TEXT = 'CHECK FOR KEY MEMBER IDENTIFIER';
      SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   IF @Lc_IvaGrantCur_DefraYearMonthNumb_TEXT <> @Lc_Space_TEXT AND @Lc_IvaGrantCur_GrantYearMonthNumb_TEXT = @Lc_Space_TEXT
    BEGIN 
	  IF ISNUMERIC (@Lc_IvaGrantCur_DefraYearMonthNumb_TEXT) = 0
          OR ISNUMERIC (@Lc_IvaGrantCur_WelfareCaseIdno_TEXT) = 0
          OR ISNUMERIC (@Lc_IvaGrantCur_MemberMciIdno_TEXT) = 0
          OR ISNUMERIC (@Lc_IvaGrantCur_DefraAmnt_TEXT) = 0
       BEGIN
        SET @Lc_BateError_CODE = @Lc_ErrorE0085_CODE;

        RAISERROR (50001,16,1);
       END
      ELSE
       BEGIN
	    SET @Ln_IvaGrantCur_DefraYearMonth_NUMB = CAST(@Lc_IvaGrantCur_DefraYearMonthNumb_TEXT AS NUMERIC);
        SET @Ln_IvaGrantCurCaseWelfare_IDNO = CAST(@Lc_IvaGrantCur_WelfareCaseIdno_TEXT AS NUMERIC);
        SET @Ln_IvaGrantCurMemberMciCp_IDNO = CAST(@Lc_IvaGrantCur_MemberMciIdno_TEXT AS NUMERIC);
        SET @Ln_IvaGrantCurDefra_AMNT = CAST(@Lc_IvaGrantCur_DefraAmnt_TEXT AS MONEY);
       END

      IF NOT EXISTS(SELECT 1
                       FROM MHIS_Y1 m
                      WHERE m.CaseWelfare_IDNO = @Ln_IvaGrantCurCaseWelfare_IDNO
                        AND m.CaseWelfare_IDNO <> 0
                        AND m.TypeWelfare_CODE = @Lc_WelfareEligTanf_CODE
                        AND m.MemberMci_IDNO = @Ln_IvaGrantCurMemberMciCp_IDNO
						AND @Lc_IvaGrantCur_DefraYearMonthNumb_TEXT BETWEEN CONVERT(VARCHAR(6), m.Start_DATE, 112) AND CONVERT(VARCHAR(6), m.End_DATE, 112))
       BEGIN
        SET @Lc_BateError_CODE = @Lc_ErrorE0961_CODE;

        RAISERROR (50001,16,1);
       END

     IF NOT EXISTS (SELECT 1
	                  FROM IVMG_Y1 i
					 WHERE i.CaseWelfare_IDNO = @Ln_IvaGrantCurCaseWelfare_IDNO
					   AND i.WelfareElig_CODE = @Lc_WelfareEligTanf_CODE
					   AND i.CpMci_IDNO = @Ln_IvaGrantCurMemberMciCp_IDNO
					   AND i.WelfareYearMonth_NUMB = @Ln_IvaGrantCur_DefraYearMonth_NUMB)
       BEGIN
	    SET @Ls_Sql_TEXT = 'RECORD DOESNT EXISTS IN IVMG_Y1 TABLE TO UPDATE DEFRA AMOUNT';
		SET @Ls_Sqldata_TEXT = @Ls_BateRecord_TEXT;
        SET @Lc_BateError_CODE = @Lc_ErrorE0961_CODE;

        RAISERROR (50001,16,1);
       END

	  --13347 - Changing Functional Seq NUMB  -START-
      SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GENERATE_SEQ - 1';
      SET @Ls_Sqldata_TEXT = 'EventFunctionalSeq2430_NUMB = ' + CAST(@Li_TanfGrantSplit2730_NUMB AS VARCHAR) + ', Job_ID = ' + @Lc_Job_ID + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', IndNote_TEXT = ' + @Lc_IndNote_TEXT + ', BatchRunUser_TEXT = ' + @Lc_BatchRunUser_TEXT;

      EXECUTE BATCH_COMMON$SP_GENERATE_SEQ
       @An_EventFunctionalSeq_NUMB = @Li_TanfGrantSplit2730_NUMB,
       @Ac_Process_ID              = @Lc_Job_ID,
       @Ad_EffectiveEvent_DATE     = @Ld_Run_DATE,
       @Ac_Note_INDC               = @Lc_IndNote_TEXT,
       @Ac_Worker_ID               = @Lc_BatchRunUser_TEXT,
       @An_EventGlobalSeq_NUMB     = @Ln_EventGlobalSeq_NUMB OUTPUT,
       @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
       @As_DescriptionError_TEXT   = @Ls_DescriptionError_TEXT OUTPUT;
	  --13347 - Changing Functional Seq NUMB  -END-
      IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
       BEGIN
        RAISERROR (50001,16,1);
       END

        SET @Ln_TransactionAssistExpend_AMNT = @Ln_Zero_NUMB;
		SET @Ln_MtdAssistExpend_AMNT = @Ln_Zero_NUMB;
        SET @Ln_LtdAssistExpend_AMNT = @Ln_Zero_NUMB;
        SET @Ln_TransactionAssistRecoup_AMNT = @Ln_Zero_NUMB;
        SET @Ln_MtdAssistRecoup_AMNT = @Ln_Zero_NUMB;
        SET @Ln_LtdAssistRecoup_AMNT = @Ln_Zero_NUMB;
		SET @Ln_Defra_AMNT = @Ln_Zero_NUMB;
		SET @Lc_TypeAdjust_CODE = '';
		SET @Lc_ZeroGrant_INDC = '';
		SET @Lc_AdjustLtdFlag_INDC = '';

        SET @Ls_Sql_TEXT = 'ASSIGNING CURRENT VALUES OF THE CASE - 1';
        SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', CaseWelfare_IDNO = ' + CAST(@Ln_IvaGrantCurCaseWelfare_IDNO AS VARCHAR) + ', WelfareElig_CODE = ' + CAST(@Lc_WelfareEligTanf_CODE AS VARCHAR) + ', WelfareYearMonth_NUMB = ' + CAST(@Ln_IvaGrantCur_DefraYearMonth_NUMB AS VARCHAR);

        SELECT @Ln_SelectedWelfareYyyymm_NUMB = a.WelfareYearMonth_NUMB,
               @Ln_TransactionAssistExpend_AMNT = a.TransactionAssistExpend_AMNT,
			   @Ln_MtdAssistExpend_AMNT = a.MtdAssistExpend_AMNT,
               @Ln_LtdAssistExpend_AMNT = a.LtdAssistExpend_AMNT,
               @Ln_TransactionAssistRecoup_AMNT = a.TransactionAssistRecoup_AMNT,
               @Ln_LtdAssistRecoup_AMNT = a.LtdAssistRecoup_AMNT,
               @Ln_MtdAssistRecoup_AMNT = a.MtdAssistRecoup_AMNT,
               @Lc_TypeAdjust_CODE = a.TypeAdjust_CODE,
               @Lc_ZeroGrant_INDC = a.ZeroGrant_INDC,
               @Lc_AdjustLtdFlag_INDC = a.AdjustLtdFlag_INDC,
			   @Ln_Defra_AMNT = a.Defra_AMNT
          FROM IVMG_Y1 a
         WHERE a.CaseWelfare_IDNO = @Ln_IvaGrantCurCaseWelfare_IDNO
           AND a.WelfareElig_CODE = @Lc_WelfareEligTanf_CODE
		   AND a.CpMci_IDNO = @Ln_IvaGrantCurMemberMciCp_IDNO
           AND a.WelfareYearMonth_NUMB = @Ln_IvaGrantCur_DefraYearMonth_NUMB
           AND a.EventGlobalSeq_NUMB = (SELECT MAX(b.EventGlobalSeq_NUMB)
                                          FROM IVMG_Y1 b
                                         WHERE b.CaseWelfare_IDNO = a.CaseWelfare_IDNO
                                           AND b.WelfareElig_CODE = a.WelfareElig_CODE
                                           AND b.CpMci_IDNO = a.CpMci_IDNO
                                           AND b.WelfareYearMonth_NUMB = a.WelfareYearMonth_NUMB);

        SET @Ls_Sql_TEXT = 'INSERT INTO IVMG_Y1 - 1';
        SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', CaseWelfare_IDNO = ' + CAST(@Ln_IvaGrantCurCaseWelfare_IDNO AS VARCHAR) + ', WelfareYearMonth_NUMB = ' + CAST(@Ln_IvaGrantCur_DefraYearMonth_NUMB AS VARCHAR) + ', WelfareElig_CODE = ' + @Lc_WelfareEligTanf_CODE + ', TransactionAssistExpend_AMNT = ' + CAST(@Ln_IvaGrantCurGrant_AMNT AS VARCHAR) + ', MtdAssistExpend_AMNT = ' + CAST(@Ln_MtdAssistExpend_AMNT AS VARCHAR) + ', LtdAssistExpend_AMNT = ' + CAST(@Ln_LtdAssistExpend_AMNT AS VARCHAR) + ', TransactionAssistRecoup_AMNT = ' + CAST(@Ln_TransactionAssistRecoup_AMNT AS VARCHAR) + ', MtdAssistRecoup_AMNT = ' + CAST(@Ln_MtdAssistRecoup_AMNT AS VARCHAR) + ', LtdAssistRecoup_AMNT = ' + CAST(@Ln_LtdAssistRecoup_AMNT AS VARCHAR) + ', TypeAdjust_CODE = ' + @Lc_TypeAdjust_CODE + ', EventGlobalSeq_NUMB = ' + CAST(@Ln_EventGlobalSeq_NUMB AS VARCHAR) + ', ZeroGrant_INDC = ' + @Lc_ZeroGrant_INDC + ', AdjustLtdFlag_INDC = ' + @Lc_AdjustLtdFlag_INDC + ', Defra_AMNT = ' + CAST(@Ln_IvaGrantCurDefra_AMNT AS VARCHAR) + ', CpMci_IDNO = ' + CAST(@Ln_IvaGrantCurMemberMciCp_IDNO AS VARCHAR);

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
        VALUES( @Ln_IvaGrantCurCaseWelfare_IDNO,--CaseWelfare_IDNO
                @Ln_IvaGrantCur_DefraYearMonth_NUMB,--WelfareYearMonth_NUMB
                @Lc_WelfareEligTanf_CODE,--WelfareElig_CODE
                @Ln_TransactionAssistExpend_AMNT,-- TransactionAssistExpend_AMNT
                @Ln_MtdAssistExpend_AMNT,-- MtdAssistExpend_AMNT
                @Ln_LtdAssistExpend_AMNT,-- LtdAssistExpend_AMNT
                @Ln_TransactionAssistRecoup_AMNT,-- TransactionAssistRecoup_AMNT
                @Ln_MtdAssistRecoup_AMNT,-- MtdAssistRecoup_AMNT
                @Ln_LtdAssistRecoup_AMNT,-- LtdAssistRecoup_AMNT
                @Lc_TypeAdjust_CODE,-- TypeAdjust_CODE
                @Ln_EventGlobalSeq_NUMB,-- EventGlobalSeq_NUMB
                @Lc_ZeroGrant_INDC,-- ZeroGrant_INDC
                @Lc_AdjustLtdFlag_INDC,-- AdjustLtdFlag_INDC
				@Ln_Defra_AMNT + @Ln_IvaGrantCurDefra_AMNT, --Defra_AMNT
                @Ln_IvaGrantCurMemberMciCp_IDNO -- CpMci_IDNO
        );
	END  
   ELSE IF @Lc_IvaGrantCur_GrantYearMonthNumb_TEXT <> @Lc_Space_TEXT AND @Lc_IvaGrantCur_DefraYearMonthNumb_TEXT = @Lc_Space_TEXT
    BEGIN
    
      IF ISNUMERIC (@Lc_IvaGrantCur_GrantYearMonthNumb_TEXT) = 0
          OR ISNUMERIC (@Lc_IvaGrantCur_WelfareCaseIdno_TEXT) = 0
          OR ISNUMERIC (@Lc_IvaGrantCur_GrantAmnt_TEXT) = 0
          OR ISNUMERIC (@Lc_IvaGrantCur_MemberMciIdno_TEXT) = 0
          OR ISNUMERIC (@Lc_IvaGrantCur_DefraAmnt_TEXT) = 0
       BEGIN
        SET @Lc_BateError_CODE = @Lc_ErrorE0085_CODE;

        RAISERROR (50001,16,1);
       END
      ELSE
       BEGIN
	    SET @Ln_IvaGrantCurGrantYearMonth_NUMB = CAST(@Lc_IvaGrantCur_GrantYearMonthNumb_TEXT AS NUMERIC);
        SET @Ln_IvaGrantCurCaseWelfare_IDNO = CAST(@Lc_IvaGrantCur_WelfareCaseIdno_TEXT AS NUMERIC);
        SET @Ln_IvaGrantCurGrant_AMNT = CAST(@Lc_IvaGrantCur_GrantAmnt_TEXT AS MONEY);
        SET @Ln_IvaGrantCurMemberMciCp_IDNO = CAST(@Lc_IvaGrantCur_MemberMciIdno_TEXT AS NUMERIC);
        SET @Ln_IvaGrantCurDefra_AMNT = CAST(@Lc_IvaGrantCur_DefraAmnt_TEXT AS MONEY);
       END

      IF NOT EXISTS((SELECT 1
                       FROM MHIS_Y1 m
                      WHERE m.CaseWelfare_IDNO = @Ln_IvaGrantCurCaseWelfare_IDNO
                        AND m.CaseWelfare_IDNO <> 0
                        AND m.TypeWelfare_CODE = @Lc_WelfareEligTanf_CODE
                        AND m.MemberMci_IDNO = @Ln_IvaGrantCurMemberMciCp_IDNO
						AND @Lc_IvaGrantCur_GrantYearMonthNumb_TEXT BETWEEN CONVERT(VARCHAR(6), m.Start_DATE, 112) AND CONVERT(VARCHAR(6), m.End_DATE, 112)))
       BEGIN
        SET @Lc_BateError_CODE = @Lc_ErrorE0961_CODE;

        RAISERROR (50001,16,1);
       END

	  --13347 - Changing Functional Seq NUMB  -START-
      SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GENERATE_SEQ - 2';
      SET @Ls_Sqldata_TEXT = 'EventFunctionalSeq2430_NUMB = ' + CAST(@Li_TanfGrantSplit2730_NUMB AS VARCHAR) + ', Job_ID = ' + @Lc_Job_ID + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', IndNote_TEXT = ' + @Lc_IndNote_TEXT + ', BatchRunUser_TEXT = ' + @Lc_BatchRunUser_TEXT;

      EXECUTE BATCH_COMMON$SP_GENERATE_SEQ
       @An_EventFunctionalSeq_NUMB = @Li_TanfGrantSplit2730_NUMB,
       @Ac_Process_ID              = @Lc_Job_ID,
       @Ad_EffectiveEvent_DATE     = @Ld_Run_DATE,
       @Ac_Note_INDC               = @Lc_IndNote_TEXT,
       @Ac_Worker_ID               = @Lc_BatchRunUser_TEXT,
       @An_EventGlobalSeq_NUMB     = @Ln_EventGlobalSeq_NUMB OUTPUT,
       @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
       @As_DescriptionError_TEXT   = @Ls_DescriptionError_TEXT OUTPUT;
	  --13347 - Changing Functional Seq NUMB  -START-
      IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
       BEGIN
        RAISERROR (50001,16,1);
       END

      SET @Ls_Sql_TEXT = 'ASSIGNING CURRENT VALUES OF THE CASE - 2';
      SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', CaseWelfare_IDNO = ' + CAST(@Ln_IvaGrantCurCaseWelfare_IDNO AS VARCHAR) + ', WelfareElig_CODE = ' + @Lc_WelfareEligTanf_CODE + ', WelfareYearMonth_NUMB = ' + CAST(@Ln_IvaGrantCurGrantYearMonth_NUMB AS VARCHAR);

      SELECT @Ln_CurrentWelfare_NUMB = ISNULL(MAX(a.WelfareYearMonth_NUMB), @Ln_RunDateWelfare_NUMB)
        FROM IVMG_Y1 a
       WHERE a.CaseWelfare_IDNO = @Ln_IvaGrantCurCaseWelfare_IDNO
         AND a.WelfareElig_CODE = @Lc_WelfareEligTanf_CODE
         AND a.CpMci_IDNO = @Ln_IvaGrantCurMemberMciCp_IDNO
		 AND a.WelfareYearMonth_NUMB >= @Ln_IvaGrantCurGrantYearMonth_NUMB;

      SET @Ln_PrevWelfare_NUMB = @Ln_IvaGrantCurGrantYearMonth_NUMB;

      -- insert into IVMG table till current welfare month
      WHILE @Ln_PrevWelfare_NUMB <= @Ln_CurrentWelfare_NUMB
       BEGIN
        SET @Ln_MtdAssistExpend_AMNT = @Ln_Zero_NUMB;
        SET @Ln_LtdAssistExpend_AMNT = @Ln_Zero_NUMB;
        SET @Ln_TransactionAssistRecoup_AMNT = @Ln_Zero_NUMB;
        SET @Ln_MtdAssistRecoup_AMNT = @Ln_Zero_NUMB;
        SET @Ln_LtdAssistRecoup_AMNT = @Ln_Zero_NUMB;
        SET @Ln_Defra_AMNT = @Ln_Zero_NUMB;
		SET @Lc_TypeAdjust_CODE = @Lc_Space_TEXT;
		SET @Lc_ZeroGrant_INDC = @Lc_Space_TEXT;
		SET @Lc_AdjustLtdFlag_INDC = @Lc_Space_TEXT;
		
        SET @Ls_Sql_TEXT = 'ASSIGNING CURRENT VALUES OF THE CASE - 2';
        SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', CaseWelfare_IDNO = ' + CAST(@Ln_IvaGrantCurCaseWelfare_IDNO AS VARCHAR) + ', WelfareElig_CODE = ' + CAST(@Lc_WelfareEligTanf_CODE AS VARCHAR) + ', WelfareYearMonth_NUMB = ' + CAST(@Ln_PrevWelfare_NUMB AS VARCHAR);

        SELECT @Ln_SelectedWelfareYyyymm_NUMB = a.WelfareYearMonth_NUMB,
               @Ln_MtdAssistExpend_AMNT = a.MtdAssistExpend_AMNT,
               @Ln_LtdAssistExpend_AMNT = a.LtdAssistExpend_AMNT,
               @Ln_TransactionAssistRecoup_AMNT = a.TransactionAssistRecoup_AMNT,
               @Ln_LtdAssistRecoup_AMNT = a.LtdAssistRecoup_AMNT,
               @Ln_MtdAssistRecoup_AMNT = a.MtdAssistRecoup_AMNT,
               @Lc_TypeAdjust_CODE = a.TypeAdjust_CODE,
               @Lc_ZeroGrant_INDC = a.ZeroGrant_INDC,
               @Lc_AdjustLtdFlag_INDC = a.AdjustLtdFlag_INDC,
			   @Ln_Defra_AMNT = a.Defra_AMNT
          FROM IVMG_Y1 a
         WHERE a.CaseWelfare_IDNO = @Ln_IvaGrantCurCaseWelfare_IDNO
           AND a.WelfareElig_CODE = @Lc_WelfareEligTanf_CODE
		   AND a.CpMci_IDNO = @Ln_IvaGrantCurMemberMciCp_IDNO
           AND a.WelfareYearMonth_NUMB = (SELECT MAX(c.WelfareYearMonth_NUMB)
                                            FROM IVMG_Y1 c
                                           WHERE c.CaseWelfare_IDNO = a.CaseWelfare_IDNO
                                             AND c.WelfareElig_CODE = a.WelfareElig_CODE
                                             AND c.CpMci_IDNO = a.CpMci_IDNO
                                             AND c.WelfareYearMonth_NUMB <= @Ln_PrevWelfare_NUMB)
           AND a.EventGlobalSeq_NUMB = (SELECT MAX(b.EventGlobalSeq_NUMB)
                                          FROM IVMG_Y1 b
                                         WHERE b.CaseWelfare_IDNO = a.CaseWelfare_IDNO
                                           AND b.WelfareElig_CODE = a.WelfareElig_CODE
                                           AND b.CpMci_IDNO = a.CpMci_IDNO
                                           AND b.WelfareYearMonth_NUMB = a.WelfareYearMonth_NUMB);

        SET @Ls_Sql_TEXT = 'INSERT INTO IVMG_Y1 - 2';
        SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', CaseWelfare_IDNO = ' + CAST(@Ln_IvaGrantCurCaseWelfare_IDNO AS VARCHAR) + ', WelfareYearMonth_NUMB = ' + CAST(@Ln_PrevWelfare_NUMB AS VARCHAR) + ', WelfareElig_CODE = ' + @Lc_WelfareEligTanf_CODE + ', TransactionAssistExpend_AMNT = ' + CAST(@Ln_IvaGrantCurGrant_AMNT AS VARCHAR) + ', MtdAssistExpend_AMNT = ' + CAST(@Ln_MtdAssistExpend_AMNT AS VARCHAR) + ', LtdAssistExpend_AMNT = ' + CAST(@Ln_LtdAssistExpend_AMNT AS VARCHAR) + ', TransactionAssistRecoup_AMNT = ' + CAST(@Ln_TransactionAssistRecoup_AMNT AS VARCHAR) + ', MtdAssistRecoup_AMNT = ' + CAST(@Ln_MtdAssistRecoup_AMNT AS VARCHAR) + ', LtdAssistRecoup_AMNT = ' + CAST(@Ln_LtdAssistRecoup_AMNT AS VARCHAR) + ', TypeAdjust_CODE = ' + @Lc_TypeAdjust_CODE + ', EventGlobalSeq_NUMB = ' + CAST(@Ln_EventGlobalSeq_NUMB AS VARCHAR) + ', ZeroGrant_INDC = ' + @Lc_ZeroGrant_INDC + ', AdjustLtdFlag_INDC = ' + @Lc_AdjustLtdFlag_INDC + ', Defra_AMNT = ' + CAST(@Ln_IvaGrantCurDefra_AMNT AS VARCHAR) + ', CpMci_IDNO = ' + CAST(@Ln_IvaGrantCurMemberMciCp_IDNO AS VARCHAR);

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
        VALUES( @Ln_IvaGrantCurCaseWelfare_IDNO,--CaseWelfare_IDNO
                @Ln_PrevWelfare_NUMB,--WelfareYearMonth_NUMB
                @Lc_WelfareEligTanf_CODE,--WelfareElig_CODE
                @Ln_IvaGrantCurGrant_AMNT,-- TransactionAssistExpend_AMNT
                CASE @Ln_PrevWelfare_NUMB
                 WHEN @Ln_IvaGrantCurGrantYearMonth_NUMB
                  THEN @Ln_MtdAssistExpend_AMNT + @Ln_IvaGrantCurGrant_AMNT
                 WHEN @Ln_SelectedWelfareYyyymm_NUMB
                  THEN @Ln_MtdAssistExpend_AMNT
                 ELSE @Ln_Zero_NUMB
                END,-- MtdAssistExpend_AMNT
                CASE @Ln_PrevWelfare_NUMB
                 WHEN @Ln_SelectedWelfareYyyymm_NUMB
                  THEN @Ln_LtdAssistExpend_AMNT + @Ln_IvaGrantCurGrant_AMNT
                 ELSE @Ln_IvaGrantCurGrant_AMNT
                END,-- LtdAssistExpend_AMNT
                @Ln_TransactionAssistRecoup_AMNT,-- TransactionAssistRecoup_AMNT
                @Ln_MtdAssistRecoup_AMNT,-- MtdAssistRecoup_AMNT
                @Ln_LtdAssistRecoup_AMNT,-- LtdAssistRecoup_AMNT
                @Lc_TypeAdjust_CODE,-- TypeAdjust_CODE
                @Ln_EventGlobalSeq_NUMB,-- EventGlobalSeq_NUMB
                @Lc_ZeroGrant_INDC,-- ZeroGrant_INDC
                @Lc_AdjustLtdFlag_INDC,-- AdjustLtdFlag_INDC
				@Ln_Defra_AMNT, --Defra_AMNT
                @Ln_IvaGrantCurMemberMciCp_IDNO -- CpMci_IDNO
        );

        SET @Ln_PrevWelfare_NUMB = CONVERT(VARCHAR(6), DATEADD(MONTH, 1, CONVERT(DATE, CAST(@Ln_PrevWelfare_NUMB AS VARCHAR) + '01', 112)), 112);
       END

      SET @Ls_Sql_TEXT = 'BATCH_COMMON_PRORATE_GRANT$SP_GRANT_SPLIT_IVMG';
      SET @Ls_Sqldata_TEXT ='Job_ID = ' + @Lc_Job_ID + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', CaseWelfare_IDNO = ' + CAST(@Ln_IvaGrantCurCaseWelfare_IDNO AS VARCHAR) + ', CP MemberMci_IDNO = ' + CAST(@Ln_IvaGrantCurMemberMciCp_IDNO AS VARCHAR) + ', GrantYearMonth_NUMB = ' + CAST(@Ln_IvaGrantCurGrantYearMonth_NUMB AS VARCHAR) + ', BatchRunUser_TEXT = ' + @Lc_BatchRunUser_TEXT;

      EXECUTE BATCH_COMMON_PRORATE_GRANT$SP_GRANT_SPLIT_IVMG
       @An_CaseWelfare_IDNO      = @Ln_IvaGrantCurCaseWelfare_IDNO,
       @An_CpMci_IDNO            = @Ln_IvaGrantCurMemberMciCp_IDNO,
       @An_WelfareYearMonth_NUMB = @Ln_IvaGrantCurGrantYearMonth_NUMB,
       @Ac_SignedOnWorker_ID     = @Lc_BatchRunUser_TEXT,
       @Ad_Run_DATE              = @Ld_Run_DATE,
	   @Ac_Job_ID				 = @Lc_Job_ID,
       @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
       @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

      IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
       BEGIN
        RAISERROR (50001,16,1);
       END
       
      --13347 - Creating Elog, UNOT_Y1 -START- 
      SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_ENTITY_MATRIX';
      SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', CaseWelfare_IDNO = ' + CAST(@Ln_IvaGrantCurCaseWelfare_IDNO AS VARCHAR) + ', WelfareYearMonth_NUMB = ' + CAST(@Ln_IvaGrantCurGrantYearMonth_NUMB AS VARCHAR) + ', TypeWelfare_CODE	 = ' + @Lc_WelfareEligTanf_CODE + ', CpMci_IDNO = ' + CAST(@Ln_IvaGrantCurMemberMciCp_IDNO AS VARCHAR)+ ', Functional Seq number  = ' + CAST(@Li_TanfGrantSplit2730_NUMB AS VARCHAR)+ ', Event Global Seq number  = ' + CAST(@Ln_EventGlobalSeq_NUMB AS VARCHAR);
      EXECUTE BATCH_COMMON$SP_ENTITY_MATRIX
       @An_EntityCase_IDNO				= 0,
       @An_EntityCaseWelfare_IDNO		= @Ln_IvaGrantCurCaseWelfare_IDNO,
       @An_EntityWelfareYearMonth_NUMB  = @Ln_IvaGrantCurGrantYearMonth_NUMB,
       @Ac_TypeWelfare_CODE				= @Lc_WelfareEligTanf_CODE,
	   @An_EntityCpMci_IDNO				= @Ln_IvaGrantCurMemberMciCp_IDNO,       
	   @An_EventFunctionalSeq_NUMB		= @Li_TanfGrantSplit2730_NUMB,
	   @An_EventGlobalSeq_NUMB			= @Ln_EventGlobalSeq_NUMB,
	   @Ac_Msg_CODE						= @Lc_Msg_CODE OUTPUT,
	   @As_DescriptionError_TEXT		= @Ls_DescriptionError_TEXT OUTPUT;

      IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
       BEGIN
        RAISERROR (50001,16,1);
       END	                        
       
      SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_NOTES';
      SET @Ls_Sqldata_TEXT ='Job_ID = '+ @Lc_Job_ID +  ', Event Global Seq number  = ' + CAST(@Ln_EventGlobalSeq_NUMB AS VARCHAR) + ', DescriptionNote_TEXT = ' + @Ls_DescriptionNote_TEXT;
      
      EXECUTE BATCH_COMMON$SP_INSERT_NOTES
       @An_EventGlobalSeq_NUMB   = @Ln_EventGlobalSeq_NUMB,
	   @As_DescriptionNote_TEXT  = @Ls_DescriptionNote_TEXT,
	   @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
	   @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;
       
      IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
       BEGIN
        RAISERROR (50001,16,1);
       END
      --13347 - Creating Elog, UNOT_Y1 -START- 
    END
   END TRY

   BEGIN CATCH
      BEGIN
       IF XACT_STATE() = 1
        BEGIN
         ROLLBACK TRANSACTION SAVEIVAGRANT_PROCESS;
        END
       ELSE
        BEGIN
         SET @Ls_DescriptionError_TEXT = @Ls_DescriptionError_TEXT + SUBSTRING (ERROR_MESSAGE (), 1, 200);

         RAISERROR( 50001,16,1);
        END

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
        @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

       IF @Lc_BateError_CODE = @Lc_Space_TEXT
        BEGIN 
          SET @Lc_BateError_CODE = @Lc_ErrorE1424_CODE
        END 
		       
	   SET @Ls_BateRecord_TEXT = 'Error Record = ' + @Ls_BateRecord_TEXT + ', Error Description = ' + @Ls_DescriptionError_TEXT;

       EXECUTE BATCH_COMMON$SP_BATE_LOG
        @As_Process_NAME             = @Ls_Process_NAME,
        @As_Procedure_NAME           = @Ls_Procedure_NAME,
        @Ac_Job_ID                   = @Lc_Job_ID,
        @Ad_Run_DATE                 = @Ld_Run_DATE,
        @Ac_TypeError_CODE           = @Lc_TypeErrorE_CODE,
        @An_Line_NUMB                = @Ln_RestartLine_NUMB,
        @Ac_Error_CODE               = @Lc_BateError_CODE,
        @As_DescriptionError_TEXT    = @Ls_BateRecord_TEXT,
        @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
        @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_TypeErrorE_CODE
        BEGIN
         SET @Ln_ExceptionThreshold_QNTY = @Ln_ExceptionThreshold_QNTY + 1;
        END
       ELSE IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         RAISERROR (50001,16,1);
        END
      END
   END CATCH

     SET @Ls_Sql_TEXT = 'UPDATE LTGRA_Y1';
     SET @Ls_Sqldata_TEXT = 'Seq_IDNO = ' + CAST(@Ln_IvaGrantCur_Seq_IDNO AS VARCHAR);

     UPDATE LTGRA_Y1
        SET Process_INDC = @Lc_ProcessY_INDC
      WHERE Seq_IDNO = @Ln_IvaGrantCur_Seq_IDNO;

     SET @Li_RowsCount_QNTY = @@ROWCOUNT;

     IF @Li_RowsCount_QNTY = 0
      BEGIN
       SET @Ls_DescriptionError_TEXT = @Lc_Err0002_TEXT;

       RAISERROR (50001,16,1);
      END

     SET @Ln_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY + @Li_RowsCount_QNTY;
     SET @Ln_CommitFreq_QNTY = @Ln_CommitFreq_QNTY + @Li_RowsCount_QNTY;

     IF @Ln_CommitFreqParm_QNTY <> 0
        AND @Ln_CommitFreq_QNTY >= @Ln_CommitFreqParm_QNTY
      BEGIN
       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATCH_RESTART_UPDATE';
       SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL (@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL (CAST (@Ld_Run_DATE AS VARCHAR), '') + ', RESTART_KEY = ' + ISNULL (CAST (@Ln_RecCount_NUMB AS VARCHAR), '');

       EXECUTE BATCH_COMMON$SP_BATCH_RESTART_UPDATE
        @Ac_Job_ID                = @Lc_Job_ID,
        @Ad_Run_DATE              = @Ld_Run_DATE,
        @As_RestartKey_TEXT       = @Ln_RecCount_NUMB,
        @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         RAISERROR (50001,16,1);
        END

       SET @Ls_Sql_TEXT = 'TRASACTION COMMITS - 1';
       SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL (@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL (CAST (@Ld_Run_DATE AS VARCHAR), '');

       COMMIT TRANSACTION IVAGRANT_PROCESS;

       SET @Ln_ProcessedRecordsCommit_QNTY = @Ln_ProcessedRecordsCommit_QNTY + @Ln_CommitFreq_QNTY;
       SET @Ls_Sql_TEXT = 'TRASACTION BEGINS - 3';
       SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL (@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL (CAST (@Ld_Run_DATE AS VARCHAR), '');

       BEGIN TRANSACTION IVAGRANT_PROCESS;

       SET @Ln_CommitFreq_QNTY = 0;
      END;

     IF @Ln_ExceptionThreshold_QNTY > @Ln_ExceptionThresholdParm_QNTY
      BEGIN
       COMMIT TRANSACTION IVAGRANT_PROCESS;

       SET @Ln_ProcessedRecordsCommit_QNTY = @Ln_ProcessedRecordCount_QNTY;
       SET @Ls_Sql_TEXT = 'REACHED EXCEPTION THRESHOLD';
       SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL (@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL (CAST (@Ld_Run_DATE AS VARCHAR), '');

       RAISERROR (50001,16,1);
      END

     FETCH NEXT FROM IvaGrant_CUR INTO @Ln_IvaGrantCur_Seq_IDNO, @Lc_IvaGrantCur_WelfareCaseIdno_TEXT, @Lc_IvaGrantCur_GrantYearMonthNumb_TEXT, @Lc_IvaGrantCur_GrantAmnt_TEXT, @Lc_IvaGrantCur_MemberMciIdno_TEXT, @Lc_IvaGrantCur_DefraYearMonthNumb_TEXT, @Lc_IvaGrantCur_DefraAmnt_TEXT;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END

   IF @Lc_BateError_CODE = @Lc_ErrorE0944_CODE
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG';
     SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + ISNULL(@Ls_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', TypeError_CODE = ' + ISNULL(@Lc_TypeErrorE_CODE, '') + ', Line_NUMB = ' + ISNULL(CAST(@Ln_RestartLine_NUMB AS VARCHAR), '') + ', Error_CODE = ' + ISNULL(@Lc_BateError_CODE, '') + ', DescriptionError_TEXT = ' + ISNULL(@Lc_Space_TEXT, '') + ', ListKey_TEXT = ' + ISNULL(@Ls_Sqldata_TEXT, '');

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Ls_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_TypeErrorE_CODE,
      @An_Line_NUMB                = @Ln_RestartLine_NUMB,
      @Ac_Error_CODE               = @Lc_BateError_CODE,
      @As_DescriptionError_TEXT    = @Lc_Space_TEXT,
      @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END
    END

   CLOSE IvaGrant_CUR;

   DEALLOCATE IvaGrant_CUR;

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', Run_DATE = ' + ISNULL (CAST (@Ld_Run_DATE AS VARCHAR), '');

   EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BSTL_LOG';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', Start_DATE = ' + CAST(@Ld_Start_DATE AS VARCHAR) + ', Process_NAME = ' + @Ls_Process_NAME + ', Procedure_NAME = ' + @Ls_Procedure_NAME + ', CursorLocation_TEXT = ' + @Ls_CursorLocation_TEXT + ', ExecLocation_TEXT = ' + @Lc_Successful_TEXT + ', ListKey_TEXT = ' + @Lc_Successful_TEXT + ', DescriptionError_TEXT = ' + @Ls_DescriptionError_TEXT + ', Status_CODE = ' + @Lc_StatusSuccess_CODE + ', BatchRunUser_TEXT = ' + @Lc_BatchRunUser_TEXT + ', ProcessedRecordCount_QNTY = ' + CAST(@Ln_ProcessedRecordCount_QNTY AS VARCHAR);

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Ls_CursorLocation_TEXT,
    @As_ExecLocation_TEXT         = @Lc_Successful_TEXT,
    @As_ListKey_TEXT              = @Lc_Successful_TEXT,
    @As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE               = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;

   SET @Ls_Sql_TEXT = 'TRASACTION COMMITS - 2';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   COMMIT TRANSACTION IVAGRANT_PROCESS;
  END TRY

  BEGIN CATCH
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION IVAGRANT_PROCESS;
    END

   IF CURSOR_STATUS ('LOCAL', 'IvaGrant_CUR') IN (0, 1)
    BEGIN
     CLOSE IvaGrant_CUR;

     DEALLOCATE IvaGrant_CUR;
    END

   SET @Ln_Error_NUMB = ERROR_NUMBER ();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE ();
   SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_ErrorMessage_TEXT = SUBSTRING(ERROR_MESSAGE (), 1, 200);
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
  END CATCH;
 END;


GO
