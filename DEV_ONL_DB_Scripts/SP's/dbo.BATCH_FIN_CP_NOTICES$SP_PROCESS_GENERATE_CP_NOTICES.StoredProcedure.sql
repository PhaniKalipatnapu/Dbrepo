/****** Object:  StoredProcedure [dbo].[BATCH_FIN_CP_NOTICES$SP_PROCESS_GENERATE_CP_NOTICES]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
 --------------------------------------------------------------------------------------------------------------------
 Procedure Name		: BATCH_FIN_CP_NOTICES$SP_PROCESS_GENERATE_CP_NOTICES
 Programmer Name	: IMP Team
  Description		: The process describes the creating and generation of a Notice of Assigned Support Collections (FIN-06)
					  to the custodial parents who are currently on IV-A or were on IV-A and have collections applied. The
					  notice is generated for each of the eligible case ID associated with the CP.
 Frequency			: Monthly
 Developed On		: 5/31/2011
 Called By			: None
 Called On			: BATCH_GEN_NOTICE_UTIL$SP_GET_RECIPIENT_ADDRESS
 --------------------------------------------------------------------------------------------------------------------
 Modified By		:
 Modified On		:
 Version No			: 1.0
 --------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_FIN_CP_NOTICES$SP_PROCESS_GENERATE_CP_NOTICES]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @RecipientAddress_P1 TABLE (
   Line1_ADDR       VARCHAR(50),
   Line2_ADDR       VARCHAR(50),
   State_ADDR       CHAR(2),
   City_ADDR        CHAR(28),
   Zip_ADDR         CHAR(15),
   TypeAddress_CODE CHAR(1),
   Status_CODE      CHAR(1),
   Ind_ADDR         VARCHAR);
  DECLARE @Lc_Space_TEXT                              CHAR(1) = ' ',
          @Lc_No_INDC                                 CHAR(1) = 'N',
          @Lc_StatusCaseOpen_CODE                     CHAR(1) = 'O',
          @Lc_TypeWelfareTanf_CODE                    CHAR(1) = 'A',
          @Lc_CaseRelationshipCp_CODE                 CHAR(1) = 'C',
          @Lc_CaseMemberStatusActive_CODE             CHAR(1) = 'A',
          @Lc_RespondInitInitiate_CODE                CHAR(1) = 'N',
          @Lc_RespondInitInitiatingState_CODE         CHAR(1) = 'I',
          @Lc_RespondInitInitiatingInternational_CODE CHAR(1) = 'C',
          @Lc_RespondInitInitiatingTribal_CODE        CHAR(1) = 'T',
          @Lc_StatusFailed_CODE                       CHAR(1) = 'F',
          @Lc_StatusAbnormalend_CODE                  CHAR(1) = 'A',
          @Lc_StatusSuccess_CODE                      CHAR(1) = 'S',
          @Lc_TypeErrorInformation_CODE               CHAR(1) = 'I',
          @Lc_TypeErrorE_CODE                         CHAR(1) = 'E',
          @Lc_TypeCaseTanf_CODE                       CHAR(1) = 'A',
          @Lc_RecipientNCP_CODE                       CHAR(2) = 'MC',
          @Lc_Subsystem_CODE                          CHAR(2) = 'FM',
          @Lc_DisburseStatusVoidNoReissue_CODE        CHAR(2) = 'VN',
          @Lc_DisburseStatusVoidReissue_CODE          CHAR(2) = 'VR',
          @Lc_DisburseStatusStopReissue_CODE          CHAR(2) = 'SR',
          @Lc_DisburseStatusStopNoReissue_CODE        CHAR(2) = 'SN',
          @Lc_DisburseStatusRejectedEft_CODE          CHAR(2) = 'RE',
          @Lc_BatchRunUser_TEXT                       CHAR(5) = 'BATCH',
          @Lc_NoRecordsToProcess_CODE                 CHAR(5) = 'E0944',
          @Lc_InvalidAddress_CODE                     CHAR(5) = 'E0606',
          @Lc_BateErrorUnknown_CODE                   CHAR(5) = 'E1424',
          @Lc_DisbursementTypeCznaa_CODE              CHAR(5) = 'CZNAA',
          @Lc_DisbursementTypeAznaa_CODE              CHAR(5) = 'AZNAA',
          @Lc_DisbursementTypeCgpaa_CODE              CHAR(5) = 'CGPAA',
          @Lc_DisbursementTypeCxpaa_CODE              CHAR(5) = 'CXPAA',
          @Lc_DisbursementTypeAxpaa_CODE              CHAR(5) = 'AXPAA',
          @Lc_DisbursementTypePgpaa_CODE              CHAR(5) = 'PGPAA',
          @Lc_DisbursementTypeAgtaa_CODE              CHAR(5) = 'AGTAA',
          @Lc_DisbursementTypeAgcaa_CODE              CHAR(5) = 'AGCAA',
          @Lc_DisbursementTypeAgpaa_CODE              CHAR(5) = 'AGPAA',
          @Lc_MajorActivityCase_CODE                  CHAR(5) = 'CASE',
          @Lc_ActivityMinor_CODE                      CHAR(5) = 'NOPRI',
          @Lc_Job_ID                                  CHAR(7) = 'DEB7610',
          @Lc_AssignedSupportCollectionsNotice_CODE   CHAR(8) = 'FIN-06',
          @Lc_Successful_TEXT                         CHAR(20) = 'SUCCESSFUL',
          @Ls_Procedure_NAME                          VARCHAR(100) = 'SP_PROCESS_GENERATE_CP_NOTICES  ',
          @Ls_Process_NAME                            VARCHAR(100) = 'BATCH_FIN_CP_NOTICES',
          @Ld_Run_DATE                                DATE = '01/01/0001',
          @Ld_Low_DATE                                DATE = '01/01/0001',
          @Ld_High_DATE                               DATE = '12/31/9999',
          @Ld_Start_DATE                              DATETIME2 = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
  DECLARE @Ln_CommitFreq_QNTY             NUMERIC(5) = 0,
          @Ln_CommitFreqParm_QNTY         NUMERIC(5) = 0,
          @Ln_ExceptionThresholdParm_QNTY NUMERIC(5) = 0,
          @Ln_ExceptionThreshold_QNTY     NUMERIC(5) = 0,
          @Ln_SupportYearMonth_NUMB       NUMERIC(6) = 0,
          @Ln_MemberMci_IDNO              NUMERIC(10) = 0,
          @Ln_EventFunctional0_NUMB       NUMERIC(11) = 0,
          @Ln_ProcessedRecordCount_QNTY   NUMERIC(11) = 0,
          @Ln_Cursor_QNTY                 NUMERIC(11) = 0,
          @Ln_Topic_IDNO                  NUMERIC(11) = 0,
          @Ln_ErrorLine_NUMB              NUMERIC(11) = 0,
          @Ln_Error_NUMB                  NUMERIC(11) = 0,
          @Ln_CaseCount_QNTY              NUMERIC(11) = 0,
          @Ln_CurrentSupport_AMNT         NUMERIC(11, 2) = 0,
          @Ln_CustodialArrear_AMNT        NUMERIC(11, 2) = 0,
          @Ln_StateArrear_AMNT            NUMERIC(11, 2) = 0,
          @Ln_TotalPaid_AMNT              NUMERIC(11, 2) = 0,
          @Ln_Passthrough_AMNT            NUMERIC(11, 2) = 0,
          @Ln_TanfMonthSupport_AMNT       NUMERIC(11, 2) = 0,
          @Ln_NonTanfMonthSupport_AMNT    NUMERIC(11, 2) = 0,
          @Ln_MonthSupportState_AMNT      NUMERIC(11, 2) = 0,
          @Ln_Defra_AMNT                  NUMERIC(11, 2) = 0,
          @Ln_TransactionEventSeq_NUMB    NUMERIC(19) = 0,
          @Li_FetchStatus_QNTY            SMALLINT,
          @Lc_BateError_CODE              CHAR(5),
          @Lc_Msg_CODE                    CHAR(5) = '',
          @Lc_Notice_ID                   CHAR(6) = '',
          @Ls_Sql_TEXT                    VARCHAR(100) = '',
          @Ls_Sqldata_TEXT                VARCHAR(1000) = '',
          @Ls_CursorLocation_TEXT         VARCHAR(1000) = '',
          @Ls_ErrorMessage_TEXT           VARCHAR(4000) = '',
          @Ls_DescriptionError_TEXT       VARCHAR(4000) = '',
          @Ls_XmlInput_TEXT               VARCHAR(4000) = '',
          @Ls_XMLCase_TEXT                VARCHAR(4000) = '',
          @Ls_BateRecord_TEXT             VARCHAR(4000) = '',
          @Ld_LastRun_DATE                DATE,
          @Ld_MonthStart_DATE             DATE,
          @Ld_MonthEnd_DATE               DATE;
  DECLARE @Ln_CpCur_MemberMci_IDNO NUMERIC(10) = 0;
  DECLARE @Ln_CaseCur_Case_IDNO        NUMERIC(6) = 0,
          @Lc_CaseCur_FirstNcp_NAME    CHAR(16),
          @Lc_CaseCur_MiddleNcp_NAME   CHAR(20),
          @Lc_CaseCur_LastNcp_NAME     CHAR(20),
          @Lc_CaseCur_SuffixNcp_NAME   CHAR(4),
          @Lc_CaseCur_TypeWelfare_CODE CHAR(1) = '',
          @Lc_CaseCur_TypeCase_CODE    CHAR(1) = '';

  BEGIN TRY
   BEGIN TRANSACTION CP_NOTICES;

   -- Selecting the Batch start time
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS';
   SET @Ls_Sqldata_TEXT = ' Job_ID = ' + @Lc_Job_ID;

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
   Get the run date and last run date from Parameter (PARM_Y1) table and validate that the batch program was not executed
   for the run date, by ensuring that the run date is different from the last run date in the PARM_Y1 table
   */
   IF DATEADD(D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'PARM DATE PROBLEM';

     RAISERROR (50001,16,1);
    END;

   -- Get Restart Key Details
   BEGIN
    SET @Ls_Sql_TEXT = 'GET RESTART KEY DETAILS';
    SET @Ls_Sqldata_TEXT ='Job_ID = ' + @Lc_Job_ID + ', RUN DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '');
    SET @Ln_MemberMci_IDNO =0;

    SELECT @Ln_MemberMci_IDNO = ISNULL(CAST((SUBSTRING(r.RestartKey_TEXT, 1, 10)) AS NUMERIC), 0)
      FROM RSTL_Y1 r
     WHERE r.Job_ID = @Lc_Job_ID
       AND r.Run_DATE = @Ld_Run_DATE;
   END

   SET @Ld_MonthStart_DATE = DATEADD(D, -DAY(@Ld_Run_DATE) + 1, @Ld_Run_DATE);
   SET @Ld_MonthEnd_DATE = DATEADD(M, 1, @Ld_MonthStart_DATE);
   SET @Ld_MonthEnd_DATE = DATEADD(D, -1, @Ld_MonthEnd_DATE);
   SET @Ln_SupportYearMonth_NUMB= CAST (CONVERT(CHAR(6), @Ld_MonthEnd_DATE, 112) AS NUMERIC);

   /*
   	Cursor to select CP's 
   */
   DECLARE Cp_CUR INSENSITIVE CURSOR FOR
    SELECT DISTINCT
           a.MemberMci_IDNO
      FROM CMEM_Y1 a
     WHERE a.MemberMci_IDNO > @Ln_MemberMci_IDNO
       AND a.CaseRelationship_CODE = @Lc_CaseRelationshipCp_CODE
       AND a.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
       AND EXISTS (SELECT 1
                     FROM CASE_Y1 b,
                          MHIS_Y1 C
                    WHERE a.Case_IDNO = b.Case_IDNO
                          --Open IV-D cases that are either instate or initiating cases
                          AND b.StatusCase_CODE = @Lc_StatusCaseOpen_CODE
                          AND a.Case_IDNO = c.Case_IDNO
                          AND a.MemberMci_IDNO = c.MemberMci_IDNO
                          AND @Ld_Run_DATE BETWEEN c.Start_DATE AND c.End_DATE
                          AND b.RespondInit_CODE IN (@Lc_RespondInitInitiate_CODE, @Lc_RespondInitInitiatingState_CODE, @Lc_RespondInitInitiatingInternational_CODE, @Lc_RespondInitInitiatingTribal_CODE)
                          AND EXISTS (SELECT 1
                                        FROM MHIS_Y1 d
                                       WHERE d.Case_IDNO = a.Case_IDNO
                                         AND d.MemberMci_IDNO = a.MemberMci_IDNO
                                         --CP currently receives TANF or CP received TANF in the past
                                         AND d.TypeWelfare_CODE = @Lc_TypeWelfareTanf_CODE)
                          AND EXISTS (SELECT 1
                                        FROM LSUP_Y1 e
                                       WHERE e.Case_IDNO = a.Case_IDNO
                                         AND e.SupportYearMonth_NUMB = @Ln_SupportYearMonth_NUMB
                                         AND e.Batch_DATE <> @Ld_Low_DATE
                                         AND e.Batch_NUMB <> 0
                                         AND e.SeqReceipt_NUMB <> 0
                                         --If there are payments applied to CP’s cases in the reported month
                                         AND (TransactionPaa_AMNT > 0
                                               OR TransactionNaa_AMNT > 0
                                               OR TransactionUda_AMNT > 0))
                          AND EXISTS (SELECT 1
                                        FROM LSUP_Y1 e
                                       WHERE e.Case_IDNO = a.Case_IDNO
                                         AND e.SupportYearMonth_NUMB = @Ln_SupportYearMonth_NUMB
                                         --If there are any assigned arrears 
                                         AND (OweTotPaa_AMNT - AppTotPaa_AMNT > 0)))
       AND EXISTS(SELECT 1
                    FROM DSBL_Y1 d,
                         DSBH_Y1 b
                   WHERE d.Case_IDNO = a.Case_IDNO
                     AND d.Disburse_DATE BETWEEN @Ld_MonthStart_DATE AND @Ld_MonthEnd_DATE
                     AND d.CheckRecipient_ID = b.CheckRecipient_ID
                     AND d.CheckRecipient_CODE = b.CheckRecipient_CODE
                     AND d.Disburse_DATE = b.Disburse_DATE
                     AND d.DisburseSeq_NUMB = b.DisburseSeq_NUMB
                     AND b.StatusCheck_CODE NOT IN (@Lc_DisburseStatusVoidNoReissue_CODE, @Lc_DisburseStatusVoidReissue_CODE, @Lc_DisburseStatusStopReissue_CODE, @Lc_DisburseStatusStopNoReissue_CODE, @Lc_DisburseStatusRejectedEft_CODE)
                     AND b.EndValidity_DATE = @Ld_High_DATE
                     AND d.TypeDisburse_CODE IN (@Lc_DisbursementTypeCgpaa_CODE, @Lc_DisbursementTypeCxpaa_CODE, @Lc_DisbursementTypePgpaa_CODE, @Lc_DisbursementTypeCznaa_CODE,
                                                 @Lc_DisbursementTypeAznaa_CODE, @Lc_DisbursementTypeAxpaa_CODE, @Lc_DisbursementTypeAgtaa_CODE, @Lc_DisbursementTypeAgcaa_CODE, @Lc_DisbursementTypeAgpaa_CODE)
                     AND NOT EXISTS (SELECT 1
                                       FROM DSBC_Y1 c
                                      WHERE b.CheckRecipient_ID = c.CheckRecipientOrig_ID
                                        AND b.CheckRecipient_CODE = c.CheckRecipientOrig_CODE
                                        AND b.Disburse_DATE = c.DisburseOrig_DATE
                                        AND b.DisburseSeq_NUMB = c.DisburseOrigSeq_NUMB))
     ORDER BY a.MemberMci_IDNO;

   SET @Ls_Sql_TEXT = 'OPEN Cp_CUR-1';
   SET @Ls_Sqldata_TEXT = '';

   OPEN Cp_CUR;

   SET @Ls_Sql_TEXT = 'FETCH Cp_CUR-1';
   SET @Ls_Sqldata_TEXT = '';

   FETCH NEXT FROM Cp_CUR INTO @Ln_CpCur_MemberMci_IDNO;

   SET @Li_FetchStatus_QNTY =@@FETCH_STATUS;
   SET @Ls_Sql_TEXT = 'WHILE -1';
   SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL (CAST(@Ln_CpCur_MemberMci_IDNO AS VARCHAR), '');

   --Construct XmlInput_TEXT with all the cases of the selected member 
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
     BEGIN TRY
      SAVE TRANSACTION CP_NOTICES_SAVE

      SET @Ls_ErrorMessage_TEXT ='';
      SET @Lc_BateError_CODE = @Lc_BateErrorUnknown_CODE;
      SET @Ls_XmlInput_TEXT = '<InputParameters>' + '<report_begin_date>' + CONVERT(VARCHAR, @Ld_MonthStart_DATE, 101) --mm/dd/yyyy
                               + '</report_begin_date>' + '<report_end_date>' + CONVERT(VARCHAR, @Ld_MonthEnd_DATE, 101) --mm/dd/yyyy
                               + '</report_end_date>' + '<cp_membermci_idno>' + CONVERT(VARCHAR, @Ln_CpCur_MemberMci_IDNO) + '</cp_membermci_idno>';
      SET @Ln_CommitFreq_QNTY = @Ln_CommitFreq_QNTY + 1;
      SET @Ln_Cursor_QNTY = @Ln_Cursor_QNTY + 1;
      SET @Ls_CursorLocation_TEXT = +', Cursor_QNTY = ' + CAST(@Ln_Cursor_QNTY AS VARCHAR);
      SET @Ls_BateRecord_TEXT= 'MemberMci_IDNO = ' + ISNULL (CAST(@Ln_CpCur_MemberMci_IDNO AS VARCHAR), '');
      SET @Ls_Sql_TEXT = 'DELETE RecipientAddress_P1';
      SET @Ls_Sqldata_TEXT = '';

      DELETE FROM @RecipientAddress_P1;

      SET @Ls_Sql_TEXT = 'BATCH_GEN_NOTICE_UTIL$SP_GET_RECIPIENT_ADDRESS-1';
      SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL (CAST(@Ln_CpCur_MemberMci_IDNO AS VARCHAR), '') + ', AssignedSupportCollectionsNotice_CODE = ' + @Lc_AssignedSupportCollectionsNotice_CODE + ', Ld_Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', RecipientNCP_CODE = ' + @Lc_RecipientNCP_CODE;

      INSERT INTO @RecipientAddress_P1
                  (Line1_ADDR,
                   Line2_ADDR,
                   State_ADDR,
                   City_ADDR,
                   Zip_ADDR,
                   TypeAddress_CODE,
                   Status_CODE,
                   Ind_ADDR)
      EXECUTE BATCH_GEN_NOTICE_UTIL$SP_GET_RECIPIENT_ADDRESS
       @Ac_Notice_ID             = @Lc_AssignedSupportCollectionsNotice_CODE,
       @Ad_Run_DATE              = @Ld_Run_DATE,
       @Ac_Recipient_ID          = @Ln_CpCur_MemberMci_IDNO,
       @Ac_Recipient_CODE        = @Lc_RecipientNCP_CODE,
       @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
       @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

      IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
       BEGIN
        RAISERROR (50001,16,1);
       END;

      --	For the eligible CP’s, the system checks for a valid current mailing address or residential address
      IF EXISTS(SELECT 1
                  FROM @RecipientAddress_P1)
       BEGIN
        SET @Ln_Passthrough_AMNT =0;
        SET @Ln_TanfMonthSupport_AMNT =0;
        SET @Ln_NonTanfMonthSupport_AMNT=0;
        SET @Ln_MonthSupportState_AMNT =0;
        SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT - 1';
        SET @Ls_Sqldata_TEXT = 'EventFunctionalSeq_NUMB = ' + ISNULL(CAST(@Ln_EventFunctional0_NUMB AS VARCHAR), '') + ', EffectiveEvent_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Job_ID = ' + @Lc_Job_ID + ', No_INDC = ' + @Lc_No_INDC + ', BatchRunUser_TEXT = ' + @Lc_BatchRunUser_TEXT;

        EXECUTE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
         @Ac_Worker_ID                = @Lc_BatchRunUser_TEXT,
         @Ac_Process_ID               = @Lc_Job_ID,
         @Ad_EffectiveEvent_DATE      = @Ld_Run_DATE,
         @Ac_Note_INDC                = @Lc_No_INDC,
         @An_EventFunctionalSeq_NUMB  = @Ln_EventFunctional0_NUMB,
         @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
         @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
         @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

        IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
         BEGIN
          RAISERROR (50001,16,1);
         END

        IF CURSOR_STATUS ('LOCAL', 'Case_Cur') IN (0, 1)
         BEGIN
          CLOSE Case_Cur;

          DEALLOCATE Case_Cur;
         END

        DECLARE Case_Cur INSENSITIVE CURSOR FOR
         SELECT a.Case_IDNO,
                d.FirstNcp_NAME,
                d.MiddleNcp_NAME,
                d.LastNcp_NAME,
                d.SuffixNcp_NAME,
                c.TypeWelfare_CODE,
                b.TypeCase_CODE
           FROM CMEM_Y1 a,
                MHIS_Y1 C,
                CASE_Y1 b
                LEFT OUTER JOIN ENSD_Y1 d
                 ON d.Case_IDNO = b.Case_IDNO
          WHERE a.MemberMci_IDNO = @Ln_CpCur_MemberMci_IDNO
            AND a.Case_IDNO = b.Case_IDNO
            AND b.StatusCase_CODE = @Lc_StatusCaseOpen_CODE
            AND a.CaseRelationship_CODE = @Lc_CaseRelationshipCp_CODE
            AND a.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
            AND a.Case_IDNO = c.Case_IDNO
            AND a.MemberMci_IDNO = c.MemberMci_IDNO
            AND @Ld_Run_DATE BETWEEN c.Start_DATE AND c.End_DATE
            AND b.RespondInit_CODE IN (@Lc_RespondInitInitiate_CODE, @Lc_RespondInitInitiatingState_CODE, @Lc_RespondInitInitiatingInternational_CODE, @Lc_RespondInitInitiatingTribal_CODE)
            AND EXISTS (SELECT 1
                          FROM MHIS_Y1 d
                         WHERE d.Case_IDNO = a.Case_IDNO
                           AND d.MemberMci_IDNO = a.MemberMci_IDNO
                           AND d.TypeWelfare_CODE = @Lc_TypeWelfareTanf_CODE)
            AND EXISTS (SELECT 1
                          FROM LSUP_Y1 e
                         WHERE e.Case_IDNO = a.Case_IDNO
                           AND e.SupportYearMonth_NUMB = @Ln_SupportYearMonth_NUMB
                           AND e.Batch_DATE <> @Ld_Low_DATE
                           AND e.Batch_NUMB <> 0
                           AND e.SeqReceipt_NUMB <> 0
                           AND (TransactionPaa_AMNT > 0
                                 OR TransactionNaa_AMNT > 0
                                 OR TransactionUda_AMNT > 0))
               AND EXISTS (SELECT 1
                        FROM LSUP_Y1 e
                       WHERE e.Case_IDNO = a.Case_IDNO
                         AND e.SupportYearMonth_NUMB = @Ln_SupportYearMonth_NUMB
                         AND (OweTotPaa_AMNT - AppTotPaa_AMNT > 0))                  
                                 
            AND EXISTS(SELECT 1
                         FROM DSBL_Y1 d,
                              DSBH_Y1 s
                        WHERE d.Case_IDNO = a.Case_IDNO
                          AND d.Disburse_DATE BETWEEN @Ld_MonthStart_DATE AND @Ld_MonthEnd_DATE
                          AND d.CheckRecipient_ID = s.CheckRecipient_ID
                          AND d.CheckRecipient_CODE = s.CheckRecipient_CODE
                          AND d.Disburse_DATE = s.Disburse_DATE
                          AND d.DisburseSeq_NUMB = s.DisburseSeq_NUMB
                          AND s.StatusCheck_CODE NOT IN (@Lc_DisburseStatusVoidNoReissue_CODE, @Lc_DisburseStatusVoidReissue_CODE, @Lc_DisburseStatusStopReissue_CODE, @Lc_DisburseStatusStopNoReissue_CODE, @Lc_DisburseStatusRejectedEft_CODE)
                          AND s.EndValidity_DATE = @Ld_High_DATE
                          AND d.TypeDisburse_CODE IN (@Lc_DisbursementTypeCgpaa_CODE, @Lc_DisbursementTypeCxpaa_CODE, @Lc_DisbursementTypePgpaa_CODE, @Lc_DisbursementTypeCznaa_CODE,
                                                      @Lc_DisbursementTypeAznaa_CODE, @Lc_DisbursementTypeAxpaa_CODE, @Lc_DisbursementTypeAgtaa_CODE, @Lc_DisbursementTypeAgcaa_CODE, @Lc_DisbursementTypeAgpaa_CODE)
                          AND NOT EXISTS (SELECT 1
                                            FROM DSBC_Y1 c
                                           WHERE s.CheckRecipient_ID = c.CheckRecipientOrig_ID
                                             AND s.CheckRecipient_CODE = c.CheckRecipientOrig_CODE
                                             AND s.Disburse_DATE = c.DisburseOrig_DATE
                                             AND s.DisburseSeq_NUMB = c.DisburseOrigSeq_NUMB));

        SET @Ls_Sql_TEXT = 'OPEN Case_Cur-1';
        SET @Ls_Sqldata_TEXT = '';

        OPEN Case_Cur;

        SET @Ls_Sql_TEXT = 'FETCH Case_Cur-1';
        SET @Ls_Sqldata_TEXT = '';

        FETCH Case_Cur INTO @Ln_CaseCur_Case_IDNO, @Lc_CaseCur_FirstNcp_NAME, @Lc_CaseCur_MiddleNcp_NAME, @Lc_CaseCur_LastNcp_NAME, @Lc_CaseCur_SuffixNcp_NAME, @Lc_CaseCur_TypeWelfare_CODE, @Lc_CaseCur_TypeCase_CODE;

        SET @Li_FetchStatus_QNTY =@@FETCH_STATUS;
        SET @Ln_CaseCount_QNTY = 0;
        SET @Ls_XMLCase_TEXT ='';
        SET @Ls_Sql_TEXT = 'WHILE -2';
        SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL (CAST(@Ln_CpCur_MemberMci_IDNO AS VARCHAR), '') + ', TypeWelfare_CODE = ' + ISNULL (CAST(@Lc_CaseCur_TypeWelfare_CODE AS VARCHAR), '') + ', FirstNcp_NAME = ' + ISNULL (CAST(@Lc_CaseCur_FirstNcp_NAME AS VARCHAR), '') + ', MiddleNcp_NAME = ' + ISNULL (CAST(@Lc_CaseCur_MiddleNcp_NAME AS VARCHAR), '') + ', LastNcp_NAME = ' + ISNULL (CAST(@Lc_CaseCur_LastNcp_NAME AS VARCHAR), '') + ', SuffixNcp_NAME = ' + ISNULL (CAST(@Lc_CaseCur_SuffixNcp_NAME AS VARCHAR), '') + ', Case_IDNO = ' + ISNULL (CAST(@Ln_CaseCur_Case_IDNO AS VARCHAR), '') + ', TypeCase_CODE = ' + @Lc_CaseCur_TypeCase_CODE;

        /*
        	For those CP’s with a valid address, (address selected as per the address hierarchy), the program will calculate  the assigned arrears by adding up the difference amount (owed – applied) in the buckets:
        */
        WHILE @Li_FetchStatus_QNTY = 0
         BEGIN
          SET @Ls_BateRecord_TEXT= 'MemberMci_IDNO = ' + ISNULL (CAST(@Ln_CpCur_MemberMci_IDNO AS VARCHAR), '') + ', TypeWelfare_CODE = ' + ISNULL (CAST(@Lc_CaseCur_TypeWelfare_CODE AS VARCHAR), '') + ', FirstNcp_NAME = ' + ISNULL (CAST(@Lc_CaseCur_FirstNcp_NAME AS VARCHAR), '') + ', MiddleNcp_NAME = ' + ISNULL (CAST(@Lc_CaseCur_MiddleNcp_NAME AS VARCHAR), '') + ', LastNcp_NAME = ' + ISNULL (CAST(@Lc_CaseCur_LastNcp_NAME AS VARCHAR), '') + ', SuffixNcp_NAME = ' + ISNULL (CAST(@Lc_CaseCur_SuffixNcp_NAME AS VARCHAR), '') + ', Case_IDNO = ' + ISNULL (CAST(@Ln_CaseCur_Case_IDNO AS VARCHAR), '') + ', TypeCase_CODE = ' + @Lc_CaseCur_TypeCase_CODE;
          SET @Ls_CursorLocation_TEXT = +', Cursor_QNTY = ' + CAST(@Ln_Cursor_QNTY AS VARCHAR);
          SET @Ln_CurrentSupport_AMNT=0;
          SET @Ln_CustodialArrear_AMNT=0;
          SET @Ln_StateArrear_AMNT =0;
          SET @Ln_TotalPaid_AMNT =0;
          SET @Ln_Topic_IDNO =0;
          SET @Ln_CaseCount_QNTY =@Ln_CaseCount_QNTY + 1;
          /*
          Get Current Support, Custodial Arrears and State Arrears
          */
          SET @Ls_Sql_TEXT ='SELECT LSUP_Y1 ';
          SET @Ls_Sqldata_TEXT = 'Low_DATE = ' + CAST(@Ld_Low_DATE AS VARCHAR) + ', LastMonthSupport_NUMB = ' + CAST(@Ln_SupportYearMonth_NUMB AS VARCHAR);
          SET @Ln_CurrentSupport_AMNT =dbo.BATCH_FIN_CP_NOTICES$SF_GET_CURR_SUPPORT(@Ln_CaseCur_Case_IDNO, @Ld_MonthStart_DATE, @Ld_MonthEnd_DATE);
          SET @Ln_CustodialArrear_AMNT = dbo.BATCH_FIN_CP_NOTICES$SF_GET_AMT_PAID_TO_CP(@Ln_CaseCur_Case_IDNO, @Ld_MonthStart_DATE, @Ld_MonthEnd_DATE);
          SET @Ln_StateArrear_AMNT =dbo.BATCH_FIN_CP_NOTICES$SF_GET_ARR_PAID_TO_IVA(@Ln_CaseCur_Case_IDNO, @Ld_MonthStart_DATE, @Ld_MonthEnd_DATE);
          SET @Ln_MonthSupportState_AMNT = @Ln_MonthSupportState_AMNT + @Ln_StateArrear_AMNT;
          SET @Ln_TotalPaid_AMNT = @Ln_CurrentSupport_AMNT + @Ln_CustodialArrear_AMNT + @Ln_StateArrear_AMNT;

          IF @Lc_CaseCur_TypeCase_CODE = @Lc_TypeCaseTanf_CODE
           BEGIN
            SET @Ls_Sql_TEXT ='SELECT DSBL_Y1 DSBH_Y1';
            SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + CAST(@Ln_CaseCur_Case_IDNO AS VARCHAR) + ', MemberMci_IDNO = ' + CAST(@Ln_CpCur_MemberMci_IDNO AS VARCHAR) + ', MonthStart_DATE =' + CAST(@Ld_MonthStart_DATE AS VARCHAR) + ', MonthEnd_DATE = ' + CAST(@Ld_MonthEnd_DATE AS VARCHAR) + ', DisburseStatusVoidNoReissue_CODE = ' + @Lc_DisburseStatusVoidNoReissue_CODE + ', DisburseStatusVoidReissue_CODE = ' + @Lc_DisburseStatusVoidReissue_CODE + ', DisburseStatusStopReissue_CODE = ' + @Lc_DisburseStatusStopReissue_CODE + ', DisburseStatusStopNoReissue_CODE = ' + @Lc_DisburseStatusStopNoReissue_CODE + ', DisburseStatusRejectedEft_CODE = ' + @Lc_DisburseStatusRejectedEft_CODE + ', High_DATE = ' + CAST(@Ld_High_DATE AS VARCHAR) + ', TanfMonthSupport_AMNT = ' + CAST(@Ln_TanfMonthSupport_AMNT AS VARCHAR);

            SELECT @Ln_TanfMonthSupport_AMNT = @Ln_TanfMonthSupport_AMNT + ISNULL(SUM(d.Disburse_AMNT), 0)
              FROM (SELECT a.Disburse_AMNT
                      FROM DSBL_Y1 a,
                           DSBH_Y1 b
                     WHERE a.Case_IDNO = @Ln_CaseCur_Case_IDNO
                       AND a.CheckRecipient_ID = @Ln_CpCur_MemberMci_IDNO
                       AND a.CheckRecipient_CODE = 1
                       AND a.Disburse_DATE BETWEEN @Ld_MonthStart_DATE AND @Ld_MonthEnd_DATE
                       AND a.CheckRecipient_ID = b.CheckRecipient_ID
                       AND a.CheckRecipient_CODE = b.CheckRecipient_CODE
                       AND a.Disburse_DATE = b.Disburse_DATE
                       AND a.DisburseSeq_NUMB = b.DisburseSeq_NUMB
                       AND b.StatusCheck_CODE NOT IN (@Lc_DisburseStatusVoidNoReissue_CODE, @Lc_DisburseStatusVoidReissue_CODE, @Lc_DisburseStatusStopReissue_CODE, @Lc_DisburseStatusStopNoReissue_CODE, @Lc_DisburseStatusRejectedEft_CODE)
                       AND b.EndValidity_DATE = @Ld_High_DATE
                       AND NOT EXISTS (SELECT 1
                                         FROM DSBC_Y1 c
                                        WHERE b.CheckRecipient_ID = c.CheckRecipientOrig_ID
                                          AND b.CheckRecipient_CODE = c.CheckRecipientOrig_CODE
                                          AND b.Disburse_DATE = c.DisburseOrig_DATE
                                          AND b.DisburseSeq_NUMB = c.DisburseOrigSeq_NUMB)) d;
           END
          ELSE
           BEGIN
            SET @Ls_Sql_TEXT ='SELECT DSBL_Y1 DSBH_Y1';
            SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + CAST(@Ln_CaseCur_Case_IDNO AS VARCHAR) + ', MemberMci_IDNO = ' + CAST(@Ln_CpCur_MemberMci_IDNO AS VARCHAR) + ', MonthStart_DATE =' + CAST(@Ld_MonthStart_DATE AS VARCHAR) + ', MonthEnd_DATE = ' + CAST(@Ld_MonthEnd_DATE AS VARCHAR) + ', DisburseStatusVoidNoReissue_CODE = ' + @Lc_DisburseStatusVoidNoReissue_CODE + ', DisburseStatusVoidReissue_CODE = ' + @Lc_DisburseStatusVoidReissue_CODE + ', DisburseStatusStopReissue_CODE = ' + @Lc_DisburseStatusStopReissue_CODE + ', DisburseStatusStopNoReissue_CODE = ' + @Lc_DisburseStatusStopNoReissue_CODE + ', DisburseStatusRejectedEft_CODE = ' + @Lc_DisburseStatusRejectedEft_CODE + ', High_DATE = ' + CAST(@Ld_High_DATE AS VARCHAR) + ', NonTanfMonthSupport_AMNT = ' + CAST(@Ln_NonTanfMonthSupport_AMNT AS VARCHAR);

            SELECT @Ln_NonTanfMonthSupport_AMNT = @Ln_NonTanfMonthSupport_AMNT + ISNULL(SUM(d.Disburse_AMNT), 0)
              FROM (SELECT a.Disburse_AMNT
                      FROM DSBL_Y1 a,
                           DSBH_Y1 b
                     WHERE a.Case_IDNO = @Ln_CaseCur_Case_IDNO
                       AND a.CheckRecipient_ID = @Ln_CpCur_MemberMci_IDNO
                       AND a.CheckRecipient_CODE = 1
                       AND a.Disburse_DATE BETWEEN @Ld_MonthStart_DATE AND @Ld_MonthEnd_DATE
                       AND a.CheckRecipient_ID = b.CheckRecipient_ID
                       AND a.CheckRecipient_CODE = b.CheckRecipient_CODE
                       AND a.Disburse_DATE = b.Disburse_DATE
                       AND a.DisburseSeq_NUMB = b.DisburseSeq_NUMB
                       AND b.StatusCheck_CODE NOT IN (@Lc_DisburseStatusVoidNoReissue_CODE, @Lc_DisburseStatusVoidReissue_CODE, @Lc_DisburseStatusStopReissue_CODE, @Lc_DisburseStatusStopNoReissue_CODE, @Lc_DisburseStatusRejectedEft_CODE)
                       AND b.EndValidity_DATE = @Ld_High_DATE
                       AND NOT EXISTS (SELECT 1
                                         FROM DSBC_Y1 c
                                        WHERE b.CheckRecipient_ID = c.CheckRecipientOrig_ID
                                          AND b.CheckRecipient_CODE = c.CheckRecipientOrig_CODE
                                          AND b.Disburse_DATE = c.DisburseOrig_DATE
                                          AND b.DisburseSeq_NUMB = c.DisburseOrigSeq_NUMB)) d;
           END

          /*
          The estimated amount paid to cp in disregard/pass through monies while CP'S case was active
          */
          SET @Ln_Defra_AMNT =0;
          SET @Ls_Sql_TEXT ='SELECT Ivmg_Y1';
          SET @Ls_Sqldata_TEXT = ', LastMonthSupport_NUMB = ' + CAST(@Ln_SupportYearMonth_NUMB AS VARCHAR) + ', TypeWelfareTanf_CODE = ' + @Lc_TypeWelfareTanf_CODE + ', Case_IDNO = ' + CAST(@Ln_CaseCur_Case_IDNO AS VARCHAR) + ', @Ln_CpCur_MemberMci_IDNO = ' + CAST(@Ln_CpCur_MemberMci_IDNO AS VARCHAR);

          SELECT @Ln_Defra_AMNT = ISNULL(SUM(a.Defra_AMNT), 0)
            FROM IVMG_Y1 a
           WHERE CaseWelfare_IDNO IN (SELECT DISTINCT
                                             x.CaseWelfare_IDNO
                                        FROM MHIS_Y1 x
                                       WHERE x.Case_IDNO = @Ln_CaseCur_Case_IDNO
                                         AND x.TypeWelfare_CODE = @Lc_TypeWelfareTanf_CODE
                                         AND x.End_DATE = (SELECT MAX(y.End_DATE)
                                                             FROM MHIS_Y1 y
                                                            WHERE y.Case_IDNO = x.Case_IDNO
                                                              AND y.MemberMci_IDNO = x.MemberMci_IDNO
                                                              AND y.TypeWelfare_CODE = @Lc_TypeWelfareTanf_CODE))
             AND a.CpMci_IDNO = @Ln_CpCur_MemberMci_IDNO
             AND WelfareElig_CODE = @Lc_TypeWelfareTanf_CODE
             AND WelfareYearMonth_NUMB = @Ln_SupportYearMonth_NUMB
             AND a.EventGlobalSeq_NUMB = (SELECT MAX(b.EventGlobalSeq_NUMB)
                                            FROM IVMG_Y1 b
                                           WHERE b.CaseWelfare_IDNO = a.CaseWelfare_IDNO
                                             AND b.WelfareElig_CODE = a.WelfareElig_CODE
                                             AND b.WelfareYearMonth_NUMB = a.WelfareYearMonth_NUMB
                                             AND b.CpMci_IDNO = a.CpMci_IDNO);

          SET @Ln_Passthrough_AMNT =@Ln_Passthrough_AMNT + @Ln_Defra_AMNT;
          SET @Ls_XMLCase_TEXT= @Ls_XMLCase_TEXT + '<row>' + '<case_idno> ' + ISNULL(CAST(@Ln_CaseCur_Case_IDNO AS VARCHAR), '') + '</case_idno> ' + '<ncp_first_name>' + ISNULL(LTRIM(RTRIM(@Lc_CaseCur_FirstNcp_NAME)), '') + '</ncp_first_name>' + '<ncp_middle_name> ' + ISNULL(LTRIM(RTRIM(@Lc_CaseCur_MiddleNcp_NAME)), '') + '</ncp_middle_name>' + '<ncp_last_name> ' + ISNULL(LTRIM(RTRIM(@Lc_CaseCur_LastNcp_NAME)), '') + '</ncp_last_name>' + '<ncp_suffix_name> ' + ISNULL(LTRIM(RTRIM(@Lc_CaseCur_SuffixNcp_NAME)), '') + '</ncp_suffix_name>' + '<current_support_paid_by_ncp_amnt>' + ISNULL(CAST(@Ln_CurrentSupport_AMNT AS VARCHAR), '') + '</current_support_paid_by_ncp_amnt>' + '<custodial_arrears_paid_by_ncp_amnt>' + ISNULL(CAST(@Ln_CustodialArrear_AMNT AS VARCHAR), '') + '</custodial_arrears_paid_by_ncp_amnt>' + '<state_arrears_paid_by_ncp_amnt>' + ISNULL(CAST(@Ln_StateArrear_AMNT AS VARCHAR), '') + '</state_arrears_paid_by_ncp_amnt>' + '<total_paid_by_ncp_amnt>' + ISNULL(CAST(@Ln_TotalPaid_AMNT AS VARCHAR), '') + '</total_paid_by_ncp_amnt>' + '</row>';
          SET @Ln_CaseCount_QNTY =@Ln_CaseCount_QNTY + 1;
          SET @Ls_Sql_TEXT = 'FETCH Case_Cur-2';
          SET @Ls_Sqldata_TEXT = '';

          FETCH Case_Cur INTO @Ln_CaseCur_Case_IDNO, @Lc_CaseCur_FirstNcp_NAME, @Lc_CaseCur_MiddleNcp_NAME, @Lc_CaseCur_LastNcp_NAME, @Lc_CaseCur_SuffixNcp_NAME, @Lc_CaseCur_TypeWelfare_CODE, @Lc_CaseCur_TypeCase_CODE;

          SET @Li_FetchStatus_QNTY =@@FETCH_STATUS;
         END

        CLOSE Case_Cur;

        SET @Ls_XmlInput_TEXT= @Ls_XmlInput_TEXT + '<collections_and_distributed_list count="' + CAST(@Ln_CaseCount_QNTY AS VARCHAR) + '" >' + @Ls_XMLCase_TEXT + '</collections_and_distributed_list>' + '<disregard_or_passthrough_amnt>' + CAST(@Ln_Passthrough_AMNT AS VARCHAR) + '</disregard_or_passthrough_amnt>' + '<support_payments_to_cp_tanf_amnt>' + CAST(@Ln_TanfMonthSupport_AMNT AS VARCHAR) + '</support_payments_to_cp_tanf_amnt>' + '<support_payments_to_cp_non_tanf_amnt>' + CAST(@Ln_NonTanfMonthSupport_AMNT AS VARCHAR) + '</support_payments_to_cp_non_tanf_amnt>' + '<support_payments_retained_by_state_amnt>' + CAST(@Ln_MonthSupportState_AMNT AS VARCHAR) + '</support_payments_retained_by_state_amnt>' + '</InputParameters>';
        SET @Ls_Sql_TEXT = 'OPEN Case_Cur-2';
        SET @Ls_Sqldata_TEXT = '';

        OPEN Case_Cur;

        SET @Ls_Sql_TEXT = 'FETCH Case_Cur-3';
        SET @Ls_Sqldata_TEXT = '';

        FETCH Case_Cur INTO @Ln_CaseCur_Case_IDNO, @Lc_CaseCur_FirstNcp_NAME, @Lc_CaseCur_MiddleNcp_NAME, @Lc_CaseCur_LastNcp_NAME, @Lc_CaseCur_SuffixNcp_NAME, @Lc_CaseCur_TypeWelfare_CODE, @Lc_CaseCur_TypeCase_CODE;

        SET @Li_FetchStatus_QNTY =@@FETCH_STATUS;
        SET @Lc_Notice_ID=@Lc_AssignedSupportCollectionsNotice_CODE;
        SET @Ls_Sql_TEXT = 'WHILE -3';
        SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + CAST(@Ln_CaseCur_Case_IDNO AS VARCHAR) + ', FirstNcp_NAME = ' + CAST(ISNULL(@Lc_CaseCur_FirstNcp_NAME, '') AS VARCHAR) + ', MiddleNcp_NAME = ' + CAST(ISNULL(@Lc_CaseCur_MiddleNcp_NAME, '') AS VARCHAR) + ', LastNcp_NAME = ' + CAST(ISNULL(@Lc_CaseCur_LastNcp_NAME, '') AS VARCHAR) + ', SuffixNcp_NAME = ' + CAST(ISNULL(@Lc_CaseCur_SuffixNcp_NAME, '') AS VARCHAR) + ', TypeWelfare_CODE = ' + CAST(ISNULL(@Lc_CaseCur_TypeWelfare_CODE, '') AS VARCHAR) + ', MemberMci_IDNO = ' + CAST(@Ln_CpCur_MemberMci_IDNO AS VARCHAR) + ', MajorActivityCase_CODE = ' + @Lc_MajorActivityCase_CODE + ', ActivityMinor_CODE = ' + @Lc_ActivityMinor_CODE + ', Subsystem_CODE = ' + @Lc_Subsystem_CODE + ', EventGlobalSeq_NUMB = ' + CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR) + ', Topic_IDNO = ' + CAST(@Ln_Topic_IDNO AS VARCHAR);

        /*
        Write this information into a Notices Print Request Queue (NMRQ_Y1) table after deriving the required data elements for generating FIN-06 notice (NCP details, CP details) for batch printing
        */
        WHILE @Li_FetchStatus_QNTY = 0
         BEGIN
          SET @Ls_BateRecord_TEXT= ' Case_IDNO = ' + CAST(@Ln_CaseCur_Case_IDNO AS VARCHAR) + ', FirstNcp_NAME = ' + CAST(ISNULL(@Lc_CaseCur_FirstNcp_NAME, '') AS VARCHAR) + ', MiddleNcp_NAME = ' + CAST(ISNULL(@Lc_CaseCur_MiddleNcp_NAME, '') AS VARCHAR) + ', LastNcp_NAME = ' + CAST(ISNULL(@Lc_CaseCur_LastNcp_NAME, '') AS VARCHAR) + ', SuffixNcp_NAME = ' + CAST(ISNULL(@Lc_CaseCur_SuffixNcp_NAME, '') AS VARCHAR) + ', TypeWelfare_CODE = ' + CAST(ISNULL(@Lc_CaseCur_TypeWelfare_CODE, '') AS VARCHAR) + ', MemberMci_IDNO = ' + CAST(@Ln_CpCur_MemberMci_IDNO AS VARCHAR) + ', MajorActivityCase_CODE = ' + @Lc_MajorActivityCase_CODE + ', ActivityMinor_CODE = ' + @Lc_ActivityMinor_CODE + ', Subsystem_CODE = ' + @Lc_Subsystem_CODE + ', EventGlobalSeq_NUMB = ' + CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR) + ', Topic_IDNO = ' + CAST(@Ln_Topic_IDNO AS VARCHAR) + ', XmlInput_TEXT = ' + @Ls_XmlInput_TEXT;
          SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_ACTIVITY';
          SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + CAST(@Ln_CaseCur_Case_IDNO AS VARCHAR) + ', MemberMci_IDNO = ' + CAST(@Ln_CpCur_MemberMci_IDNO AS VARCHAR) + ', MajorActivityCase_CODE = ' + @Lc_MajorActivityCase_CODE + ', ActivityMinor_CODE = ' + @Lc_ActivityMinor_CODE + ', Subsystem_CODE = ' + @Lc_Subsystem_CODE + ', EventGlobalSeq_NUMB = ' + CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR) + ', Topic_IDNO = ' + CAST(@Ln_Topic_IDNO AS VARCHAR) + ', BatchRunUser_TEXT = ' + @Lc_BatchRunUser_TEXT + ', Job_ID = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', Notice_ID = ' + @Lc_Notice_ID + ', XmlInput_TEXT = ' + @Ls_XmlInput_TEXT;

          EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
           @An_Case_IDNO                = @Ln_CaseCur_Case_IDNO,
           @An_MemberMci_IDNO           = @Ln_CpCur_MemberMci_IDNO,
           @Ac_ActivityMajor_CODE       = @Lc_MajorActivityCase_CODE,
           @Ac_ActivityMinor_CODE       = @Lc_ActivityMinor_CODE,
           @Ac_Subsystem_CODE           = @Lc_Subsystem_CODE,
           @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
           @Ac_WorkerUpdate_ID          = @Lc_BatchRunUser_TEXT,
           @As_Xml_TEXT                 = @Ls_XmlInput_TEXT,
           @Ad_Run_DATE                 = @Ld_Run_DATE,
           @Ac_Notice_ID                = @Lc_Notice_ID,
           @An_TopicIn_IDNO             = @Ln_Topic_IDNO,
           @Ac_Job_ID                   = @Lc_Job_ID,
           @An_Topic_IDNO               = @Ln_Topic_IDNO OUTPUT,
           @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
           @As_DescriptionError_TEXT    = @Ls_ErrorMessage_TEXT OUTPUT;

          IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
           BEGIN
            RAISERROR (50001,16,1);
           END
          ELSE IF @Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
           BEGIN
            SET @Lc_BateError_CODE = @Lc_Msg_CODE;

            RAISERROR (50001,16,1);
           END

          SET @Ls_XmlInput_TEXT =@Lc_Space_TEXT;
          SET @Lc_Notice_ID=@Lc_Space_TEXT;
          SET @Ls_Sql_TEXT = 'FETCH Case_Cur-4';
          SET @Ls_Sqldata_TEXT = '';

          FETCH Case_Cur INTO @Ln_CaseCur_Case_IDNO, @Lc_CaseCur_FirstNcp_NAME, @Lc_CaseCur_MiddleNcp_NAME, @Lc_CaseCur_LastNcp_NAME, @Lc_CaseCur_SuffixNcp_NAME, @Lc_CaseCur_TypeWelfare_CODE, @Lc_CaseCur_TypeCase_CODE;

          SET @Li_FetchStatus_QNTY =@@FETCH_STATUS;
         END

        CLOSE Case_Cur;

        DEALLOCATE Case_Cur;
       END
      ELSE
       BEGIN
        -- If there is no valid address, a record will be written to Batch Error (BATE_Y1) table/Batch Status Log (BSTL) screen. Error code is E0606 – Invalid Adddress.
        SET @Lc_BateError_CODE = @Lc_InvalidAddress_CODE;
        SET @Ls_ErrorMessage_TEXT= 'Invalied Address';

        RAISERROR (50001,16,1);
       END
     END TRY

     BEGIN CATCH
      IF XACT_STATE() = 1
       BEGIN
        ROLLBACK TRANSACTION CP_NOTICES_SAVE
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

     IF @Ln_CommitFreq_QNTY >= @Ln_CommitFreqParm_QNTY
      BEGIN
       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATCH_RESTART_UPDATE-1';
       SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', MemberMci_IDNO = ' + CAST(@Ln_CpCur_MemberMci_IDNO AS VARCHAR);

       EXECUTE BATCH_COMMON$SP_BATCH_RESTART_UPDATE
        @Ac_Job_ID                = @Lc_Job_ID,
        @Ad_Run_DATE              = @Ld_Run_DATE,
        @As_RestartKey_TEXT       = @Ln_CpCur_MemberMci_IDNO,
        @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         RAISERROR(50001,16,1);
        END

       COMMIT TRANSACTION CP_NOTICES;

       BEGIN TRANSACTION CP_NOTICES;

       SET @Ln_ProcessedRecordCount_QNTY =@Ln_Cursor_QNTY;
       SET @Ln_CommitFreq_QNTY = 0;
      END;

     IF @Ln_ExceptionThreshold_QNTY > @Ln_ExceptionThresholdParm_QNTY
      BEGIN
       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATCH_RESTART_UPDATE-2';
       SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', MemberMci_IDNO = ' + CAST(@Ln_CpCur_MemberMci_IDNO AS VARCHAR);

       EXECUTE BATCH_COMMON$SP_BATCH_RESTART_UPDATE
        @Ac_Job_ID                = @Lc_Job_ID,
        @Ad_Run_DATE              = @Ld_Run_DATE,
        @As_RestartKey_TEXT       = @Ln_CpCur_MemberMci_IDNO,
        @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         RAISERROR(50001,16,1);
        END

       COMMIT TRANSACTION CP_NOTICES;

       SET @Ln_ProcessedRecordCount_QNTY =@Ln_Cursor_QNTY;
       SET @Ls_ErrorMessage_TEXT = 'REACHED EXCEPTION THRESHOLD';

       RAISERROR (50001,16,1);
      END

     SET @Ls_Sql_TEXT = 'FETCH Cp_CUR-2';
     SET @Ls_Sqldata_TEXT = '';

     FETCH NEXT FROM Cp_CUR INTO @Ln_CpCur_MemberMci_IDNO;

     SET @Li_FetchStatus_QNTY =@@FETCH_STATUS;
    END;

   CLOSE Cp_CUR;

   DEALLOCATE Cp_CUR;

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATCH_RESTART_UPDATE-3';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', MemberMci_IDNO = ' + CAST(@Ln_CpCur_MemberMci_IDNO AS VARCHAR);

   EXECUTE BATCH_COMMON$SP_BATCH_RESTART_UPDATE
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @As_RestartKey_TEXT       = @Ln_CpCur_MemberMci_IDNO,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR(50001,16,1);
    END

   IF @Ln_Cursor_QNTY = 0
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG - 2';
     SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + @Ls_Process_NAME + ', Procedure_NAME = ' + @Ls_Procedure_NAME + ', Job_ID = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', TypeErrorInformation_CODE = ' + @Lc_TypeErrorInformation_CODE + ', Cursor_QNTY = ' + CAST(@Ln_Cursor_QNTY AS VARCHAR) + ', NoRecordsToProcess_CODE = ' + @Lc_NoRecordsToProcess_CODE + ', Space_TEXT = ' + @Lc_Space_TEXT + ', Sqldata_TEXT = ' + @Ls_Sqldata_TEXT;

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Ls_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_TypeErrorInformation_CODE,
      @As_DescriptionError_TEXT    = @Lc_Space_TEXT,
      @An_Line_NUMB                = @Ln_Cursor_QNTY,
      @Ac_Error_CODE               = @Lc_NoRecordsToProcess_CODE,
      @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END
    END

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

   SET @Ln_ProcessedRecordCount_QNTY =@Ln_Cursor_QNTY;
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BSTL_LOG-1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', Process_NAME = ' + @Ls_Process_NAME + ', Procedure_NAME = ' + @Ls_Procedure_NAME + ', StatusSuccess_CODE = ' + @Lc_StatusSuccess_CODE + ', Successful_TEXT = ' + @Lc_Successful_TEXT + ', BatchRunUser_TEXT = ' + @Lc_BatchRunUser_TEXT + ', ProcessedRecordCount_QNTY = ' + CAST(@Ln_ProcessedRecordCount_QNTY AS VARCHAR) + ', Space_TEXT = ' + @Lc_Space_TEXT + ', CursorLocation_TEXT = ' + @Ls_CursorLocation_TEXT + ', Start_DATE = ' + CAST(@Ld_Start_DATE AS VARCHAR);

   -- Updating the log with the Result_TEXT
   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Ls_CursorLocation_TEXT,
    @As_ExecLocation_TEXT         = @Lc_Successful_TEXT,
    @As_ListKey_TEXT              = @Lc_Successful_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY,
    @As_DescriptionError_TEXT     = @Lc_Space_TEXT,
    @Ac_Status_CODE               = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT;

   COMMIT TRANSACTION CP_NOTICES;
  END TRY

  BEGIN CATCH
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION CP_NOTICES;
    END

   IF CURSOR_STATUS ('LOCAL', 'Cp_CUR') IN (0, 1)
    BEGIN
     CLOSE Cp_CUR;

     DEALLOCATE Cp_CUR;
    END

   IF CURSOR_STATUS ('LOCAL', 'Case_Cur') IN (0, 1)
    BEGIN
     CLOSE Case_Cur;

     DEALLOCATE Case_Cur;
    END

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
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY,
    @As_ListKey_TEXT              = @Ls_Sqldata_TEXT,
    @As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE               = @Lc_StatusAbnormalend_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT;

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH
 END


GO
