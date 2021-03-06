/****** Object:  StoredProcedure [dbo].[BATCH_ENF_ELFC$SP_PROCESS_CHECK_ELIGIBILITY_HALFYEARLY]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	    : BATCH_ENF_ELFC$SP_PROCESS_CHECK_ELIGIBILITY_HALFYEARLY
Programmer Name		: IMP Team
Description			: This process reads records from ELFC_V1 table and initiates/closes remedies based on the
					  eligibility criteria.
Frequency			: 'DAILY'
Developed On		: 04/06/2011
Called BY			: None
Called On	        : BATCH_COMMON$SP_GET_BATCH_DETAILS and BATCH_COMMON$SP_BSTL_LOG
--------------------------------------------------------------------------------------------------------------------
Modified BY			:
Modified On			:
Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_ENF_ELFC$SP_PROCESS_CHECK_ELIGIBILITY_HALFYEARLY]
AS
 BEGIN
  SET NOCOUNT ON;

   DECLARE  @Lc_StatusSuccess_CODE                       CHAR(1) = 'S',
           @Lc_Space_TEXT                               CHAR(1) = ' ',
           @Lc_StatusAbnormalend_CODE                   CHAR(1) = 'A',
           @Lc_CaseStatusOpen_CODE                      CHAR(1) = 'O',
           @Lc_CaseTypeNonIvd_CODE                      CHAR(1) = 'H',
           @Lc_Yes_TEXT                                 CHAR(1) = 'Y',
           @Lc_No_TEXT                                  CHAR(1) = 'N',
           @Lc_OrderTypeVoluntary_CODE                  CHAR(1) = 'V',
           @Lc_RespondInitInitiate_TEXT                 CHAR(1) = 'I',
           @Lc_RespondInitInitiateIntrnl_TEXT           CHAR(1) = 'C',
           @Lc_RespondInitInitiateTribal_TEXT           CHAR(1) = 'T',
           @Lc_NegPosPositive_CODE                      CHAR(1) = 'P',
           @Lc_RespondInitRespondingState_CODE          CHAR(1) = 'R',
           @Lc_RespondInitRespondingTribal_CODE         CHAR(1) = 'S',
           @Lc_RespondInitRespondingInternational_CODE  CHAR(1) = 'Y',
           @Lc_TypeChangeIr_IDNO                        CHAR(2) = 'IR',
           @Lc_ActivityMajorCclo_CODE                   CHAR(4) = 'CCLO',
           @Lc_MajorActivityImiw_CODE                   CHAR(4) = 'IMIW',
           @Lc_RemedyStatusStart_CODE                   CHAR(4) = 'STRT',
           @Lc_BatchRunUser_TEXT                        CHAR(5) = 'BATCH',
           @Lc_MinorActivityDelqn_CODE                  CHAR(5) = 'DELQN',
           @Lc_ReasonErfso_CODE                         CHAR(5) = 'ERFSO',
           @Lc_ReasonErfsm_CODE                         CHAR(5) = 'ERFSM',
           @Lc_ReasonErfss_CODE                         CHAR(5) = 'ERFSS',
           @Lc_Job_ID                                   CHAR(7) = 'DEB7605',
           @Lc_NoticeEnf16_IDNO                         CHAR(8) = 'ENF-16',
           @Lc_Successful_INDC                          CHAR(20) = 'SUCCESSFUL',
           @Lc_Package_NAME                             CHAR(40) = 'BATCH_ENF_ELFC',
           @Lc_Routine_TEXT                             CHAR(40) = 'SP_PROCESS_CHECK_ELIGIBILITY_HALFYEARLY',
           @Ld_Highdate_DATE                            DATE = '12/31/9999',
           @Ld_Lowdate_DATE                             DATE = '01/01/0001',
           @Ld_Start_DATE                               DATETIME2(0) = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
  DECLARE  @Ln_CommitFreq_NUMB           NUMERIC(10,0),
           @Ln_ExceptionThreshold_NUMB   NUMERIC(10,0),
           @Ln_IsrcCount_NUMB            NUMERIC(10,0) = 0,
           @Ln_Error_NUMB                NUMERIC(10,0),
           @Ln_ErrorLine_NUMB            NUMERIC(10,0),
           @Ln_TransactionEventSeq_NUMB  NUMERIC(19,0) = 0,
           @Lc_Msg_CODE                  CHAR(1),
           @Ls_Sql_TEXT                  VARCHAR(100),
           @Ls_Sqldata_TEXT              VARCHAR(1000),
           @Ls_DescriptionError_TEXT     VARCHAR(4000),
           @Ld_LastRun_DATE              DATETIME2(0),
           @Ld_Run_DATE                  DATETIME2(0);

  DECLARE @Ls_CursorLoc_TEXT VARCHAR(200);

  BEGIN TRY
   -- Initiating the Batch start Date and Time
   SET @Ls_Sql_TEXT = 'ELFC002 : BATCH_COMMON$SP_GET_BATCH_DETAILS';
   SET @Ls_Sqldata_TEXT = 'Job_IDNO = ' + ISNULL(@Lc_Job_ID, '');

   -- Fetching date run, date last run, commit freq, exception threshold details
   EXECUTE BATCH_COMMON$SP_GET_BATCH_DETAILS
    @Ac_Job_ID                  = @Lc_Job_ID,
    @Ad_Run_DATE                = @Ld_Run_DATE OUTPUT,
    @Ad_LastRun_DATE            = @Ld_LastRun_DATE OUTPUT,
    @An_CommitFreq_QNTY         = @Ln_CommitFreq_NUMB OUTPUT,
    @An_ExceptionThreshold_QNTY = @Ln_ExceptionThreshold_NUMB OUTPUT,
    @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT   = @Ls_DescriptionError_TEXT OUTPUT;

   --Date Run Validation
   IF @Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'ELFC003 : CHECKING BATCH LAST RUN DATE';
   SET @Ls_Sqldata_TEXT = 'DT_LAST_RUN = ' + ISNULL(CAST(@Ld_LastRun_DATE AS VARCHAR), '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '');

   --Last Run Date Validation
   IF DATEADD(D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_DescriptionError_TEXT = 'PARM DATE PROBLEM';
     SET @Ls_Sql_TEXT  = 'PARM DATE PROBLEM';
     SET @Ls_Sqldata_TEXT = @Ls_Sqldata_TEXT;
     RAISERROR (50001,16,1);
    END

   BEGIN TRANSACTION ElfcHalfYearlyTran;
  
   SET @Ls_Sql_TEXT = 'IRSC - IRS FULL COLLECTION';
   SET @Ls_Sqldata_TEXT = @Lc_Space_TEXT;
   SET @Ls_Sql_TEXT = 'ELFC0103 : IRSC CURSOR';
   SET @Ls_Sqldata_TEXT = @Lc_Space_TEXT;

   INSERT ELFC_Y1
          (MemberMci_IDNO,
           Case_IDNO,
           OrderSeq_NUMB,
           Process_ID,
           TypeChange_CODE,
           OthpSource_IDNO,
           NegPos_CODE,
           Create_DATE,
           Process_DATE,
           WorkerUpdate_ID,
           Update_DTTM,
           TransactionEventSeq_NUMB,
           TypeReference_CODE,
           Reference_ID)
   SELECT NcpPf_IDNO,
          fci.Case_IDNO,
          fci.OrderSeq_NUMB,
          @Lc_Job_ID AS Process_ID,
          fci.TypeChange_CODE,
          fci.NcpPf_IDNO,
          fci.NegPos_CODE,
          @Ld_Run_DATE AS Create_DATE,
          @Ld_Highdate_DATE AS Process_DATE,
          @Lc_BatchRunUser_TEXT AS WorkerUpdate_ID,
          dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME() AS Update_DTTM,
          @Ln_TransactionEventSeq_NUMB AS TransactionEventSeq_NUMB,
          @Lc_Space_TEXT AS TypeReference_CODE,
          @Lc_Space_TEXT AS Reference_ID
     FROM (SELECT i.NcpPf_IDNO,
                  i.Case_IDNO,
                  i.OrderSeq_NUMB,
                  @Lc_TypeChangeIr_IDNO AS TypeChange_CODE,
                  @Lc_NegPosPositive_CODE AS NegPos_CODE
             FROM (SELECT a.Case_IDNO,
                          a.OrderSeq_NUMB,
                          a.NcpPf_IDNO,
                          a.TypeCase_CODE,
                          a.VerCpAddrExist_INDC,
                          a.Arrears_AMNT,
                          a.LastRegularPaymentReceived_DATE
                     FROM ENSD_Y1 a,
                          SORD_Y1 s,
                         
                          (SELECT DISTINCT
                                  r.Case_IDNO
                             FROM (SELECT r.Case_IDNO
                                     FROM NRRQ_Y1 r
                                    WHERE r.Notice_ID = @Lc_NoticeEnf16_IDNO
                                      AND r.Generate_DTTM < @Ld_Run_DATE
                                   UNION ALL
                                   SELECT r.Case_IDNO
                                     FROM NMRQ_Y1 r
                                    WHERE r.Notice_ID = @Lc_NoticeEnf16_IDNO
                                      AND r.Request_DTTM < @Ld_Run_DATE
                                   UNION ALL
                                   SELECT r.Case_IDNO
                                     FROM UDMNR_V1 r
                                    WHERE r.ActivityMinor_CODE = @Lc_MinorActivityDelqn_CODE
                                      AND r.Entered_DATE < @Ld_Run_DATE) AS r) AS r
                    WHERE a.StatusCase_CODE = @Lc_CaseStatusOpen_CODE
                      AND a.TypeCase_CODE <> @Lc_CaseTypeNonIvd_CODE
                      AND a.Case_IDNO = r.Case_IDNO
                      AND (a.RespondInit_CODE NOT IN (@Lc_RespondInitInitiateIntrnl_TEXT, @Lc_RespondInitInitiate_TEXT, @Lc_RespondInitInitiateTribal_TEXT)
                            OR (a.RespondInit_CODE IN (@Lc_RespondInitRespondingState_CODE, @Lc_RespondInitRespondingTribal_CODE, @Lc_RespondInitRespondingInternational_CODE)
									   AND NOT EXISTS(SELECT 1
											FROM ICAS_Y1 x
										   WHERE x.Case_IDNO = a.Case_IDNO
											 AND x.RespondInit_CODE IN (@Lc_RespondInitRespondingState_CODE, @Lc_RespondInitRespondingTribal_CODE, @Lc_RespondInitRespondingInternational_CODE)
											 AND x.Reason_CODE IN (@Lc_ReasonErfso_CODE, @Lc_ReasonErfsm_CODE,@Lc_ReasonErfss_CODE )
											 AND x.EndValidity_DATE=@Ld_Highdate_DATE)))
                      AND a.NcpPf_IDNO != 0
                      AND a.TypeOrder_CODE != @Lc_OrderTypeVoluntary_CODE
                      /*A non-end dated support order exists*/
                      AND @Ld_Run_DATE BETWEEN a.OrderEffective_DATE AND a.OrderEnd_DATE
                      AND a.Case_IDNO = s.Case_IDNO
                      AND a.OrderSeq_NUMB = s.OrderSeq_NUMB
                      AND s.EndValidity_DATE = @Ld_Highdate_DATE
                      AND (s.LastIrscReferred_DATE > DATEADD(m, -72, @Ld_Run_DATE)
                            OR s.LastIrscReferred_DATE = @Ld_Lowdate_DATE)
                      AND (s.LastIrscUpdated_DATE <= DATEADD(m, -6, @Ld_Run_DATE)
                            OR s.LastIrscUpdated_DATE = @Ld_Lowdate_DATE)
                      /*An verified address for the NCP exists*/      
                      AND a.NcpAddrExist_INDC = @Lc_Yes_TEXT
                      /*A Confirmed Good Primary SSN for the NCP exists*/
                      AND a.NcpPfSsn_NUMB != 0
                      /*NCP is not incarcerated, deceased, or institutionalized*/
                      AND a.Deceased_DATE = @Ld_Lowdate_DATE
                      AND ((a.Incarceration_DATE = @Ld_Lowdate_DATE
                            AND a.Institutionalized_DATE = @Ld_Lowdate_DATE)
                            OR @Ld_Run_DATE > a.Released_DATE)
                      -- Member is not in active chapter 13 bankruptcy       
                      AND (a.Bankruptcy13_INDC = @Lc_No_Text
                            OR (a.Bankruptcy13_INDC = @Lc_Yes_TEXT
                                AND ((a.Dismissed_DATE != @Ld_Lowdate_DATE
                                      AND @Ld_Run_DATE > a.Dismissed_DATE)
                                      OR (a.Discharge_DATE != @Ld_Lowdate_DATE
                                          AND @Ld_Run_DATE > a.Discharge_DATE))))
                      -- No Active Case Closure chain NCP as a source
                      AND NOT EXISTS (SELECT 1
                                        FROM DMJR_Y1 b
                                       WHERE b.Case_IDNO = a.Case_IDNO
                                         AND b.ActivityMajor_CODE = @Lc_ActivityMajorCclo_CODE
                                         AND b.Status_CODE = @Lc_RemedyStatusStart_CODE)
                      -- No Active Case Closure and IMIW chain NCP as a source
                      AND NOT EXISTS (SELECT 1
                                        FROM ELFC_Y1 b
                                       WHERE b.Case_IDNO = a.Case_IDNO
                                          AND (	 b.OrderSeq_NUMB = a.OrderSeq_NUMB
                                              OR b.OrderSeq_NUMB = 0)
    									  AND (	 (b.MemberMci_IDNO = a.NcpPf_IDNO AND b.TypeChange_CODE = 'IW')
											  OR b.TypeChange_CODE IN ('CC')
											 )
                                         AND b.Process_DATE = @Ld_Highdate_DATE)
                      AND NOT EXISTS (SELECT 1
                                        FROM DMJR_Y1 d
                                       WHERE d.Case_IDNO = a.Case_IDNO
                                         AND d.OrderSeq_NUMB = a.OrderSeq_NUMB
                                         AND d.Reference_ID = a.NcpPf_IDNO
                                         AND d.ActivityMajor_CODE = @Lc_MajorActivityImiw_CODE
                                         AND d.Status_CODE = @Lc_RemedyStatusStart_CODE)
                      AND a.CaseExempt_INDC = @Lc_No_Text
                      AND a.GenerateIrsci_DATE < DATEADD(m, -6, @Ld_Run_DATE)) AS i
            WHERE ((i.TypeCase_CODE = 'N'
                    AND EXISTS (SELECT 1
                                  FROM MHIS_Y1 m
                                 WHERE m.Case_IDNO = i.Case_IDNO
                                   AND m.TypeWelfare_CODE IN ('A', 'F', 'J'))
                    AND i.VerCpAddrExist_INDC = 'Y')
                    OR i.TypeCase_CODE IN ('A', 'F', 'J'))
              /*Arrears are equal to or greater than $20K*/      
              AND i.Arrears_AMNT >= 20000
              /*No payment in the last 2 years*/
              AND i.LastRegularPaymentReceived_DATE < DATEADD(m, -24, @Ld_Run_DATE)
           EXCEPT
           SELECT i.MemberMci_IDNO,
                  i.Case_IDNO,
                  i.OrderSeq_NUMB,
                  i.TypeChange_CODE,
                  i.NegPos_CODE
             FROM ELFC_Y1 i
            WHERE i.Process_DATE = @Ld_Highdate_DATE
              AND i.TypeChange_CODE = @Lc_TypeChangeIr_IDNO) AS fci;

   SET @Ln_IsrcCount_NUMB = @@ROWCOUNT;

   COMMIT TRANSACTION ElfcHalfYearlyTran;

   SET @Ls_Sql_TEXT = 'ELFC0106 : BATCH_COMMON$SP_UPDATE_PARM_DATE';
   SET @Ls_Sqldata_TEXT = 'Job_IDNO = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR(max)), '');

   EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
    BEGIN
     IF LTRIM(RTRIM(@Ls_DescriptionError_TEXT)) = ''
      BEGIN
       SET @Ls_DescriptionError_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE FAILED';
      END
     ELSE
      BEGIN
       SET @Ls_Sql_TEXT = 'ELFC0106A : BATCH_COMMON$SP_UPDATE_PARM_DATE FAILED';
      END

     RAISERROR (50001,16,1);
    END

   SET @Ls_CursorLoc_TEXT = 'IRSC : ' + ISNULL(LEFT(CAST(@Ln_IsrcCount_NUMB AS VARCHAR(4000)) + REPLICATE(@Lc_Space_TEXT, 10), 10), '');

   -- Updating the log with result
   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Lc_Package_NAME,
    @As_Procedure_NAME            = @Lc_Routine_TEXT,
    @As_CursorLocation_TEXT       = @Ls_CursorLoc_TEXT,
    @As_ExecLocation_TEXT         = @Lc_Successful_INDC,
    @As_ListKey_TEXT              = @Lc_Successful_INDC,
    @As_DescriptionError_TEXT     = @Lc_Space_TEXT,
    @Ac_Status_CODE               = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_IsrcCount_NUMB;
  END TRY

  BEGIN CATCH
   --Rollback the Transaction 		
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION ElfcHalfYearlyTran;
    END

   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();

   --Check for Exception information to log the description text based on the error
   IF (@Ln_Error_NUMB <> 50001)
    BEGIN
     SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Lc_Routine_TEXT,
    @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Lc_Package_NAME,
    @As_Procedure_NAME            = @Lc_Routine_TEXT,
    @As_CursorLocation_TEXT       = @Lc_Space_TEXT,
    @As_ExecLocation_TEXT         = @Ls_Sql_TEXT,
    @As_ListKey_TEXT              = @Ls_Sqldata_TEXT,
    @As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE               = @Lc_StatusAbnormalend_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = 0;

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH
 END


GO
