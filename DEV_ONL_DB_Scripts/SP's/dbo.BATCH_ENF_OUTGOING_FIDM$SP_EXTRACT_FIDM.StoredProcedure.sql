/****** Object:  StoredProcedure [dbo].[BATCH_ENF_OUTGOING_FIDM$SP_EXTRACT_FIDM]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_ENF_OUTGOING_FIDM$SP_EXTRACT_FIDM
Programmer Name 	: IMP Team
Description			: This batch program creates an extract file to be sent to the instate FIDM
					  vendor (Informatrix) for the NCPs who are eligible for attachment of 
					  funds from bank accounts
Frequency			: 'Monthly'
Developed On		: 4/22/2011
Called BY			: None
Called	On			:
--------------------------------------------------------------------------------------------------------------------
Modified BY			:
Modified On			:
Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_ENF_OUTGOING_FIDM$SP_EXTRACT_FIDM]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Ln_Increment_NUMB                          NUMERIC(1) =1,
          @Ln_TwelveDays_NUMB                         NUMERIC(2) = 12,
          @Ln_FortyFiveDays_NUMB                      NUMERIC(2) = 45,
          @Ln_MaxArrearLimit_AMNT                     NUMERIC(11) = 1000,
          @Lc_TypeErrorWarning_CODE                   CHAR(1) = 'W',
          @Lc_StatusFailed_CODE                       CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE                      CHAR(1) = 'S',
          @Lc_StatusAbnormalend_CODE                  CHAR(1) = 'A',
          @Lc_RespondInitInstate_CODE                 CHAR(1) = 'N',
          @Lc_RespondInitRespondingsTATE_CODE         CHAR(1) = 'R',
          @Lc_RespondInitRespondingInternational_CODE CHAR(1) = 'Y',
          @Lc_RespondInitRespondingTribal_CODE        CHAR(1) = 'S',
          @Lc_StatusCaseOpen_CODE                     CHAR(1) = 'O',
          @Lc_TypeCaseNonIvd_CODE                     CHAR(1) = 'H',
          @Lc_ChargingCase_TEXT						  CHAR(1) = 'C',
          @Lc_ArrearOnlyCase_CODE                     CHAR(1) = 'A',
          @Lc_RecordHeader_INDC                       CHAR(1) = 'D',
          @Lc_RecordDetail_INDC                       CHAR(1) = 'I',
          @Lc_RecordTrailer_INDC                      CHAR(1) = 'T',
          @Lc_HeaderDataMatch_INDC                    CHAR(1) = 'M',
          @Lc_Yes_INDC                                CHAR(1) = 'Y',
          @Lc_No_INDC                                 CHAR(1) = 'N',
          @Lc_EnumerationConfirmedGoodY_CODE          CHAR(1) = 'Y',
          @Lc_TypePrimaryItin_CODE                    CHAR(1) = 'I',
          @Lc_TypePrimaryPrimary_CODE                 CHAR(1) = 'P',
          @Lc_Space_TEXT                              CHAR(1) = ' ',
          @Lc_SubsystemEnforcement_CODE               CHAR(2) = 'EN',
          @Lc_ReasonStatusSy_CODE                     CHAR(2) = 'SY',
          @Lc_ReasonStatusBi_CODE                     CHAR(2) = 'BI',
          @Lc_ReasonStatusDisapproved_CODE            CHAR(2) = 'FL',
          @Lc_ActivityMajorCase_CODE                  CHAR(4) = 'CASE',
          @Lc_StatusStart_CODE                        CHAR(4) = 'STRT',
          @Lc_StatusComplete_CODE                     CHAR(4) = 'COMP',
          @Lc_Complete_CODE                           CHAR(4) = 'COMP',
          @Lc_ActivityMinorStfdm_CODE                 CHAR(5) = 'STFDM',
          @Lc_ActivityMinorEcfla_CODE                 CHAR(5) = 'ECFLA',
          @Lc_ErrorE0944_CODE                         CHAR(5) = 'E0944',
          @Lc_BatchRunUser_TEXT                       CHAR(5) = 'BATCH',
          @Lc_Job_ID                                  CHAR(7) = 'DEB5350',
          @Lc_Successful_TEXT                         CHAR(10) = 'SUCCESSFUL',
          @Lc_Procedure_NAME                          CHAR(15) = 'SP_EXTRACT_FIDM',
          @Lc_Process_NAME                            CHAR(30) = 'BATCH_ENF_OUTGOING_FIDM',
          @Ld_Low_DATE                                DATE = '01/01/0001',
          @Ld_High_DATE                               DATE = '12/31/9999';
  DECLARE @Ln_DefaultSsn_NUMB             NUMERIC(1) = 0,
          @Ln_MinArrearLimit_AMNT         NUMERIC(1) = 0,
          @Ln_CommitFreqParm_QNTY         NUMERIC(5),
          @Ln_ExceptionThresholdParm_QNTY NUMERIC(5),
          @Ln_DetailRecordCount_QNTY      NUMERIC(11) = 0,
          @Ln_RecordCount_QNTY            NUMERIC(11) = 0,
          @Ln_Error_NUMB                  NUMERIC(11),
          @Ln_ErrorLine_NUMB              NUMERIC(11),
          @Ln_TransactionEventSeq_NUMB    NUMERIC(19) = 0,
          @Ln_SeqUnique_IDNO              NUMERIC(38),
          @Lc_Msg_CODE                    CHAR(1) = '',
          @Ls_File_NAME                   VARCHAR(50) = '',
          @Ls_FileLocation_TEXT           VARCHAR(80) = '',
          @Ls_Sql_TEXT                    VARCHAR(100) = '',
          @Ls_Query_TEXT                  VARCHAR(1000) = '',
          @Ls_SqlData_TEXT                VARCHAR(1000) = '',
          @Ls_ErrorMessage_TEXT           VARCHAR(4000) = '',
          @Ls_DescriptionError_TEXT       VARCHAR(4000),
          @Ld_Run_DATE                    DATE,
          @Ld_LastRun_DATE                DATE,
          @Ld_RunMinus45_DATE             DATE,
          @Ld_Start_DATE                  DATETIME2;

  BEGIN TRY
   --Global temprary table creation
   CREATE TABLE ##ExtFIDM_P1
    (
      Seq_IDNO    NUMERIC IDENTITY(1, 1),
      Record_TEXT VARCHAR(99)
    );

   -- Begin the transaction to extract data 
   BEGIN TRANSACTION OUTGOING_FIDM;

   -- The Batch start time to use while inserting in to the batch log
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   /*
   Get the run date and last run date from PARM_Y1 table and validate that the batch program 
   was not executed for the run date, by ensuring that the run date is different from the last 
   run date in the PARM_Y1 table.  Otherwise, an error message to that effect will be written 
   into Batch Status Log (BSTL) screen / Batch Status Log (BSTL_Y1) table and terminate the process.
   */
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS2';
   SET @Ls_SqlData_TEXT = 'JOB ID = ' + @Lc_Job_ID;

   EXECUTE BATCH_COMMON$SP_GET_BATCH_DETAILS2
    @Ac_Job_ID                  = @Lc_Job_ID,
    @Ad_Run_DATE                = @Ld_Run_DATE OUTPUT,
    @Ad_LastRun_DATE            = @Ld_LastRun_DATE OUTPUT,
    @An_CommitFreq_QNTY         = @Ln_CommitFreqParm_QNTY OUTPUT,
    @An_ExceptionThreshold_QNTY = @Ln_ExceptionThresholdParm_QNTY OUTPUT,
    @As_File_NAME               = @Ls_File_NAME OUTPUT,
    @As_FileLocation_TEXT       = @Ls_FileLocation_TEXT OUTPUT,
    @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT   = @Ls_ErrorMessage_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END;

   -- Validation 1:Check Whether the Job ran already on same day
   SET @Ls_Sql_TEXT = 'PARM DATE CHECK';
   SET @Ls_SqlData_TEXT = 'RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', LAST RUN DATE = ' + CAST(@Ld_LastRun_DATE AS VARCHAR);

   IF DATEADD(D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'PARM DATE PROBLEM';

     RAISERROR (50001,16,1);
    END;

   --Get date less than 45, days  from run date to skip the case if the original court order issue date is less than 45 days of batch run date.
   SET @Ld_RunMinus45_DATE = DATEADD(D, -@Ln_FortyFiveDays_NUMB, @Ld_Run_DATE);
   --Delete the records from the temporary table EFIDM_Y1
   SET @Ls_Sql_TEXT = 'DELETE EFIDM_Y1';
   SET @Ls_SqlData_TEXT = '';

   --Delete the records from the temporary table EFIDM_Y1
   DELETE FROM EFIDM_Y1;

   -- Insert NCP details into table EFIDM_Y1
   SET @Ls_Sql_TEXT = 'INSERT INTO EFIDM_Y1';
   SET @Ls_SqlData_TEXT = 'RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', Les THEN 45 MIN = ' + CAST(@Ld_RunMinus45_DATE AS VARCHAR) + ', StatusCaseOpen_CODE = ' + @Lc_StatusCaseOpen_CODE + ', TypeCaseNonIvd_CODE = ' + @Lc_TypeCaseNonIvd_CODE + ', RespondInitInstate_CODE = ' + @Lc_RespondInitInstate_CODE + ', No_INDC = ' + @Lc_No_INDC + ', Yes_INDC = ' + @Lc_Yes_INDC + ', Low_DATE = ' + CAST(@Ld_Low_DATE AS VARCHAR) + ', DefaultSsn_NUMB = ' + CAST(@Ln_DefaultSsn_NUMB AS VARCHAR) + ', MaxArrearLimit_AMNT = ' + CAST(@Ln_MaxArrearLimit_AMNT AS VARCHAR) + ', High_DATE = ' + CAST(@Ld_High_DATE AS VARCHAR)  + ', ArrearOnlyCase_CODE = ' + @Lc_ArrearOnlyCase_CODE + ', MinArrearLimit_AMNT = ' + CAST(@Ln_MinArrearLimit_AMNT AS VARCHAR) + ', TwelveDays_NUMB = ' + CAST(@Ln_TwelveDays_NUMB AS VARCHAR) + ', ActivityMinorEcfla_CODE = ' + @Lc_ActivityMinorEcfla_CODE + ', ReasonStatusDisapproved_CODE = ' + @Lc_ReasonStatusDisapproved_CODE + ', Complete_CODE = ' + @Lc_Complete_CODE + ', RespondInitResponding_CODE = ' + @Lc_RespondInitRespondingsTATE_CODE + ', RespondInitRespondingTribal_CODE = ' + @Lc_RespondInitRespondingTribal_CODE + ', RespondInitRespondingInternational_CODE = ' + @Lc_RespondInitRespondingInternational_CODE;

   INSERT EFIDM_Y1
          (MemberSsn_NUMB,
           MemberMci_IDNO,
           Last_NAME,
           First_NAME,
           Case_IDNO,
           Fips_CODE)
   SELECT CASE a.NcpPfSsn_NUMB
           WHEN 0
            THEN RIGHT(REPLICATE(CAST(0 AS VARCHAR), 9) + CAST(a.VerifiedltinNcpOrpfSsn_NUMB AS VARCHAR), 9)
           ELSE RIGHT(REPLICATE(CAST(0 AS VARCHAR), 9) + CAST(a.NcpPfSsn_NUMB AS VARCHAR), 9)
          END AS MemberSsn_NUMB,
          RIGHT(REPLICATE(CAST(0 AS VARCHAR), 10) + CAST(a.NcpPf_IDNO AS VARCHAR), 10) AS MemberMci_IDNO,
          CONVERT(CHAR(20), a.LastNcp_NAME) AS Last_NAME,
          CONVERT(CHAR(16), a.FirstNcp_NAME) AS First_NAME,
          RIGHT(REPLICATE(CAST(0 AS VARCHAR), 15) + CAST(a.Case_IDNO AS VARCHAR), 15) AS Case_IDNO,
          CONVERT(CHAR(05), SUBSTRING(c.AssignedFips_CODE, 1, 5)) AS Fips_CODE
     FROM ENSD_Y1 a, CASE_Y1 c
    WHERE
    a.Case_IDNO=c.Case_IDNO
    --Read ENSD_Y1table and get the open instate IV-D cases or responding intergovernmental cases.
   AND  a.StatusCase_CODE = @Lc_StatusCaseOpen_CODE
   AND a.TypeCase_CODE <> @Lc_TypeCaseNonIvd_CODE
   AND a.RespondInit_CODE IN (@Lc_RespondInitInstate_CODE, @Lc_RespondInitRespondingsTATE_CODE, @Lc_RespondInitRespondingTribal_CODE, @Lc_RespondInitRespondingInternational_CODE)
   
   --Skip the case if the enforcement exemption indicator is set in database table 
   AND a.CaseExempt_INDC = @Lc_No_INDC
   --Skip the case if the FIDM Remedy Exemption is set in the database table 
   AND a.FidmExempt_INDC = @Lc_No_INDC
   --Skip the case if the original court order issue date is less than 45 days of batch run date (with in past 45 calendar days)
   AND a.CourtOrderIssuedOrg_DATE < @Ld_RunMinus45_DATE
   --Skip the case if a Case Closure activity chain exists in active mode
   AND a.CcloStrt_INDC = @Lc_No_INDC
   --the case if the NCP doesn’t have Chapter 13 Bankruptcy in the database table 
   AND (a.Bankruptcy13_INDC = @Lc_No_INDC
      OR (a.Bankruptcy13_INDC = @Lc_Yes_INDC
          AND ((a.Dismissed_DATE <> @Ld_Low_DATE
                AND @Ld_Run_DATE > a.Dismissed_DATE)
                OR (a.Discharge_DATE <> @Ld_Low_DATE
                    AND @Ld_Run_DATE > a.Discharge_DATE))))
   --Check the SSN of the NCP in Member-SSN database table using the following condition whether it is verified confirmed as good:
   AND EXISTS(SELECT 1
             FROM MSSN_Y1 m
            WHERE m.MemberMci_IDNO = NcpPf_IDNO
              AND Enumeration_CODE = @Lc_EnumerationConfirmedGoodY_CODE
              AND TypePrimary_CODE IN(@Lc_TypePrimaryItin_CODE, @Lc_TypePrimaryPrimary_CODE)
              AND EndValidity_DATE = @Ld_High_DATE)
   --Select the charging or arrears only case if arrears are greater than or equal to $1000 and no voluntary payments made in last 60 calendar days  OR select the arrears only case if arrears are less than $1000 and no voluntary payments made in the past 12 months.
   AND ((a.CaseChargingArrears_CODE  IN (@Lc_ArrearOnlyCase_CODE,@Lc_ChargingCase_TEXT)
		AND a.Arrears_AMNT >= @Ln_MaxArrearLimit_AMNT
		AND a.LastRegularPaymentReceived_DATE < DATEADD(D, -60, @Ld_Run_DATE)	
		)
      OR (a.CaseChargingArrears_CODE = @Lc_ArrearOnlyCase_CODE
          AND a.Arrears_AMNT <= @Ln_MaxArrearLimit_AMNT
          AND a.Arrears_AMNT > @Ln_MinArrearLimit_AMNT
          AND a.LastRegularPaymentReceived_DATE< DATEADD(M, -@Ln_TwelveDays_NUMB, @Ld_Run_DATE)
          ))
   --Select the case if a worker has not disapproved a FIDM remedy in the last 60 calendar days.
   AND NOT EXISTS (SELECT 1
                  FROM DMNR_Y1 b
                 WHERE b.Case_IDNO = a.Case_IDNO
                   AND b.MemberMci_IDNO = a.NcpPf_IDNO
                   AND b.ActivityMinor_CODE = @Lc_ActivityMinorEcfla_CODE
                   AND b.ReasonStatus_CODE = @Lc_ReasonStatusDisapproved_CODE
                   AND b.Status_CODE = @Lc_Complete_CODE
                   AND b.Status_DATE > DATEADD(D, -60, @Ld_Run_DATE));

   SET @Ln_RecordCount_QNTY =@@ROWCOUNT;

   IF @Ln_RecordCount_QNTY > 0
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT FOR ACTIVITY';
     SET @Ls_SqlData_TEXT = 'RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', Job_ID = ' + @Lc_Job_ID + ', BatchRunUser_TEXT = ' + @Lc_BatchRunUser_TEXT + ', No_INDC = ' + @Lc_No_INDC;

     EXECUTE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
      @Ac_Worker_ID               = @Lc_BatchRunUser_TEXT,
      @Ac_Process_ID              = @Lc_Job_ID,
      @Ad_EffectiveEvent_DATE     = @Ld_Run_DATE,
      @Ac_Note_INDC               = @Lc_No_INDC,
      @An_EventFunctionalSeq_NUMB = 0,
      @An_TransactionEventSeq_NUMB= @Ln_TransactionEventSeq_NUMB OUTPUT,
      @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT   = @Ls_ErrorMessage_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END;

     SET @Ls_Sql_TEXT = 'INSERT DMJR_Y1';
     SET @Ls_SqlData_TEXT = 'TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', Increment_NUMB = ' + CAST(@Ln_Increment_NUMB AS VARCHAR) + ', ActivityMajorCase_CODE = ' + @Lc_ActivityMajorCase_CODE + ', SubsystemLo_CODE = ' + @Lc_SubsystemEnforcement_CODE + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', High_DATE = ' + CAST(@Ld_High_DATE AS VARCHAR) + ', ReasonStatusBi_CODE = ' + @Lc_ReasonStatusBi_CODE + ', Low_DATE = ' + CAST(@Ld_Low_DATE AS VARCHAR) + ', BatchRunUser_TEXT = ' + @Lc_BatchRunUser_TEXT + ', Space_TEXT = ' + @Lc_Space_TEXT + ', StatusStart_CODE = ' + @Lc_StatusStart_CODE;

     INSERT DMJR_Y1
            (Case_IDNO,
             OrderSeq_NUMB,
             MajorIntSEQ_NUMB,
             MemberMci_IDNO,
             ActivityMajor_CODE,
             Subsystem_CODE,
             TypeOthpSource_CODE,
             OthpSource_IDNO,
             Entered_DATE,
             Status_DATE,
             Status_CODE,
             ReasonStatus_CODE,
             BeginExempt_DATE,
             EndExempt_DATE,
             TotalTopics_QNTY,
             PostLastPoster_IDNO,
             UserLastPoster_ID,
             SubjectLastPoster_TEXT,
             LastPost_DTTM,
             BeginValidity_DATE,
             WorkerUpdate_ID,
             Update_DTTM,
             TransactionEventSeq_NUMB,
             TypeReference_CODE,
             Reference_ID)
     SELECT a.Case_IDNO,
            0 AS OrderSeq_NUMB,
            (SELECT ISNULL(MAX(b.MajorIntSEQ_NUMB), 0) + @Ln_Increment_NUMB
               FROM DMJR_Y1 b
              WHERE a.Case_IDNO = b.Case_IDNO) AS MajorIntSEQ_NUMB,
            0 AS MemberMci_IDNO,
            @Lc_ActivityMajorCase_CODE AS ActivityMajor_CODE,
            @Lc_SubsystemEnforcement_CODE AS Subsystem_CODE,
            @Lc_Space_TEXT AS TypeOthpSource_CODE,
            0 AS OthpSource_IDNO,
            @Ld_Run_DATE AS Entered_DATE,
            @Ld_High_DATE AS Status_DATE,
            @Lc_StatusStart_CODE AS Status_CODE,
            @Lc_ReasonStatusBi_CODE AS ReasonStatus_CODE,
            @Ld_Low_DATE AS BeginExempt_DATE,
            @Ld_Low_DATE AS EndExempt_DATE,
            0 AS TotalTopics_QNTY,
            0 AS PostLastPoster_IDNO,
            @Lc_Space_TEXT AS UserLastPoster_ID,
            @Lc_Space_TEXT AS SubjectLastPoster_TEXT,
            @Ld_Low_DATE AS LastPost_DTTM,
            @Ld_Run_DATE AS BeginValidity_DATE,
            @Lc_BatchRunUser_TEXT AS WorkerUpdate_ID,
            dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME() AS Update_DTTM,
            @Ln_TransactionEventSeq_NUMB AS TransactionEventSeq_NUMB,
            @Lc_Space_TEXT AS TypeReference_CODE,
            @Lc_Space_TEXT AS Reference_ID
       FROM EFIDM_Y1 a,
            ENSD_Y1 b
      WHERE a.Case_IDNO = b.Case_IDNO
        AND b.StatusCase_CODE = @Lc_StatusCaseOpen_CODE
        AND NOT EXISTS (SELECT 1
                          FROM DMJR_Y1 d
                         WHERE a.Case_IDNO = d.Case_IDNO
                           AND d.Subsystem_CODE = @Lc_SubsystemEnforcement_CODE
                           AND d.ActivityMajor_CODE = @Lc_ActivityMajorCase_CODE
                           AND d.Status_CODE = @Lc_StatusStart_CODE);

     /* To store the case journal entries  in a separate table (CJNR_Y1) 
        and the records that are not required to be shown in WRKL AS info or action alerts.
        So, Inserting a record for STFDM activity in CJNR_Y1 table 
     */
   SET @Ls_Sql_TEXT = 'GET THE MAX OF TOPIC IDNO FROM ITOPC_Y1 - 1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);		

   SELECT @Ln_SeqUnique_IDNO = ISNULL(MAX(a.Seq_IDNO), 0) 
     FROM ITOPC_Y1 a;
  
  IF @Ln_SeqUnique_IDNO = 0 
   BEGIN
	   SET @Ls_Sql_TEXT = 'INSERT ITOPC_Y1';
	   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);   
	   
	   INSERT INTO ITOPC_Y1
				   (Entered_DATE)
			VALUES (dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME()--Entered_DATE
	   );   

	   SET @Ls_Sql_TEXT = 'GET THE MAX OF TOPIC IDNO FROM ITOPC_Y1 - 2';
	   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);
	   
       SELECT @Ln_SeqUnique_IDNO = ISNULL(MAX(a.Seq_IDNO), 0) 
		 FROM ITOPC_Y1 a;	   
		 
   END 

     SET @Ls_Sql_TEXT = 'INSERT CJNR_Y1';
     SET @Ls_SqlData_TEXT = 'TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', ActivityMinorStfdm_CODE = ' + @Lc_ActivityMinorStfdm_CODE + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', StatusComplete_CODE = ' + @Lc_StatusComplete_CODE + ', ReasonStatusSy_CODE = ' + @Lc_ReasonStatusSy_CODE + ', BatchRunUser_TEXT = ' + @Lc_BatchRunUser_TEXT + ', SubsystemLo_CODE = ' + @Lc_SubsystemEnforcement_CODE + ', ActivityMajorCase_CODE = ' + @Lc_ActivityMajorCase_CODE + ', StatusStart_CODE = ' + @Lc_StatusStart_CODE + ', SeqUnique_IDNO = ' + CAST(@Ln_SeqUnique_IDNO AS VARCHAR); 

	WITH BulkInsert_CjnrItopc
	AS (       
		SELECT a.Case_IDNO AS Case_IDNO,
                    0 AS OrderSeq_NUMB,
                    d.MajorIntSEQ_NUMB AS MajorIntSEQ_NUMB,
                    ISNULL((SELECT MAX(x.MinorIntSeq_NUMB)
                              FROM UDMNR_V1 x
                             WHERE d.Case_IDNO = x.Case_IDNO
                               AND 0 = x.OrderSeq_NUMB
                               AND d.MajorIntSEQ_NUMB = x.MajorIntSEQ_NUMB), 0) + ROW_NUMBER() OVER(PARTITION BY b.Case_IDNO ORDER BY b.Case_IDNO) AS MinorIntSeq_NUMB,
                    b.NcpPf_IDNO AS MemberMci_IDNO,
                    @Lc_ActivityMinorStfdm_CODE AS ActivityMinor_CODE,
                    @Lc_Space_TEXT AS ActivityMinorNext_CODE,
                    @Ld_Run_DATE AS Entered_DATE,
                    @Ld_Run_DATE AS Due_DATE,
                    @Ld_Run_DATE AS Status_DATE,
                    @Lc_StatusComplete_CODE AS Status_CODE,
                    @Lc_ReasonStatusSy_CODE AS ReasonStatus_CODE,
                    0 AS Schedule_NUMB,
                    d.Forum_IDNO,
                    0 AS Topic_IDNO,
                    0 AS NoTotalReplies_QNTY,
                    0 AS NoTotalViews_QNTY,
                    0 AS PostLastPoster_IDNO,
                    @Lc_BatchRunUser_TEXT AS UserLastPoster_ID,
                    dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME() AS LastPost_DTTM,
                    @Ld_Run_DATE AS AlertPrior_DATE,
                    @Ld_Run_DATE AS BeginValidity_DATE,
                    @Lc_BatchRunUser_TEXT AS WorkerUpdate_ID,
                    dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME() AS Update_DTTM,
                    @Ln_TransactionEventSeq_NUMB AS TransactionEventSeq_NUMB,
                    @Lc_Space_TEXT AS WorkerDelegate_ID,
                    0 AS UssoSeq_NUMB,
                    @Lc_SubsystemEnforcement_CODE AS Subsystem_CODE,
                    @Lc_ActivityMajorCase_CODE AS ActivityMajor_CODE
               FROM EFIDM_Y1 a,
                    ENSD_Y1 b,
                    DMJR_Y1 d
              WHERE a.Case_IDNO = b.Case_IDNO
                AND b.Case_IDNO = d.Case_IDNO
                AND d.Subsystem_CODE = @Lc_SubsystemEnforcement_CODE
                AND d.ActivityMajor_CODE = @Lc_ActivityMajorCase_CODE
                AND b.StatusCase_CODE = @Lc_StatusCaseOpen_CODE
                AND d.Status_CODE = @Lc_StatusStart_CODE
                ) 
                 
	   INSERT INTO CJNR_Y1
					  (Case_IDNO,
					   OrderSeq_NUMB,
					   MajorIntSEQ_NUMB,
					   MinorIntSeq_NUMB,
					   MemberMci_IDNO,
					   ActivityMinor_CODE,
					   ActivityMinorNext_CODE,
					   Entered_DATE,
					   Due_DATE,
					   Status_DATE,
					   Status_CODE,
					   ReasonStatus_CODE,
					   Schedule_NUMB,
					   Forum_IDNO,
					   Topic_IDNO,
					   TotalReplies_QNTY,
					   TotalViews_QNTY,
					   PostLastPoster_IDNO,
					   UserLastPoster_ID,
					   LastPost_DTTM,
					   AlertPrior_DATE,
					   BeginValidity_DATE,
					   WorkerUpdate_ID,
					   Update_DTTM,
					   TransactionEventSeq_NUMB,
					   WorkerDelegate_ID,
					   Subsystem_CODE,
					   ActivityMajor_CODE)		
	        OUTPUT @Ld_Run_DATE
			INTO ITOPC_Y1  
			SELECT Case_IDNO,
			OrderSeq_NUMB,
			MajorIntSEQ_NUMB,
			MinorIntSeq_NUMB,
			MemberMci_IDNO,
			ActivityMinor_CODE,
			ActivityMinorNext_CODE,
			Entered_DATE,
			Due_DATE,
			Status_DATE,
			Status_CODE,
			ReasonStatus_CODE,
			Schedule_NUMB,
			Forum_IDNO,
			@Ln_SeqUnique_IDNO + (ROW_NUMBER() OVER( ORDER BY TransactionEventSeq_NUMB)) AS Topic_IDNO,
			NoTotalReplies_QNTY,
			NoTotalViews_QNTY,
			PostLastPoster_IDNO,
			UserLastPoster_ID,
			LastPost_DTTM,
			AlertPrior_DATE,
			BeginValidity_DATE,
			WorkerUpdate_ID,	
			Update_DTTM,
			TransactionEventSeq_NUMB,
			WorkerDelegate_ID,
			Subsystem_CODE,
			ActivityMajor_CODE
			FROM BulkInsert_CjnrItopc 
    END;

   -- Extracting Data
   --Header
   SET @Ls_Sql_TEXT = 'INSERT Header Record';
   SET @Ls_SqlData_TEXT = 'RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', RecordHeader_INDC = ' + @Lc_RecordHeader_INDC + ', HeaderDataMatch_INDC = ' + @Lc_HeaderDataMatch_INDC;

   INSERT INTO ##ExtFIDM_P1
               (Record_TEXT)
        VALUES ( @Lc_RecordHeader_INDC + CONVERT(CHAR(6), @Ld_Run_DATE, 112) + @Lc_HeaderDataMatch_INDC + REPLICATE(@Lc_Space_TEXT, 91) --Record_TEXT
   );

   SET @Ls_Sql_TEXT = 'INSERT Detail Record';
   SET @Ls_SqlData_TEXT = 'RecordDetail_INDC = ' + @Lc_RecordDetail_INDC;

   INSERT INTO ##ExtFIDM_P1
               (Record_TEXT)
   SELECT @Lc_RecordDetail_INDC + a.MemberSsn_NUMB + a.MemberMci_IDNO + a.Last_NAME + a.First_NAME + a.Case_IDNO + a.Fips_CODE + REPLICATE(@Lc_Space_TEXT, 23) AS Record_TEXT
     FROM EFIDM_Y1 a;

   SET @Ln_DetailRecordCount_QNTY =@@ROWCOUNT;
   --Writing trailer record
   SET @Ls_Sql_TEXT = 'INSERT TRAILER RECORD';
   SET @Ls_SqlData_TEXT = 'Record Number = ' + ISNULL(CAST(@Ln_DetailRecordCount_QNTY AS VARCHAR), '') + ', RecordTrailer_INDC = ' + @Lc_RecordTrailer_INDC;

   INSERT INTO ##ExtFIDM_P1
               (Record_TEXT)
        VALUES ( @Lc_RecordTrailer_INDC + CONVERT(CHAR(6), @Ln_DetailRecordCount_QNTY) + REPLICATE(@Lc_Space_TEXT, 88) ); -- Record_TEXT

   COMMIT TRANSACTION OUTGOING_FIDM;

   SET @Ls_Query_TEXT = 'SELECT Record_TEXT FROM ##ExtFIDM_P1 ORDER BY Seq_IDNO';
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_EXTRACT_DATA';
   SET @Ls_SqlData_TEXT = 'FileLocation_TEXT = ' + @Ls_FileLocation_TEXT + ', Ls_File_NAME = ' + @Ls_File_NAME + ', Query TEXT = ' + @Ls_Query_TEXT;

   EXECUTE BATCH_COMMON$SP_EXTRACT_DATA
    @As_FileLocation_TEXT     = @Ls_FileLocation_TEXT,
    @As_File_NAME             = @Ls_File_NAME,
    @As_Query_TEXT            = @Ls_Query_TEXT,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END;

   BEGIN TRANSACTION OUTGOING_FIDM;

   IF @Ln_DetailRecordCount_QNTY = 0
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG - 1';
     SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + @Lc_Process_NAME + ', Procedure_NAME = ' + @Lc_Procedure_NAME + ', Job_ID = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', TypeError_CODE = ' + @Lc_TypeErrorWarning_CODE + ', RecordPosition_QNTY = ' + CAST(@Ln_DetailRecordCount_QNTY AS VARCHAR) + ', ErrorE0944_CODE = ' + @Lc_ErrorE0944_CODE + ', ErrorMessage_TEXT = ' + @Ls_ErrorMessage_TEXT + ', SqlData_TEXT = ' + @Ls_SqlData_TEXT;
     SET @Ls_ErrorMessage_TEXT ='';

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Lc_Process_NAME,
      @As_Procedure_NAME           = @Lc_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_TypeErrorWarning_CODE,
      @An_Line_NUMB                = @Ln_DetailRecordCount_QNTY,
      @As_DescriptionError_TEXT    = @Ls_ErrorMessage_TEXT,
      @Ac_Error_CODE               = @Lc_ErrorE0944_CODE,
      @As_ListKey_TEXT             = @Ls_SqlData_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END
    END

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE';
   SET @Ls_SqlData_TEXT = 'Job Id = ' + @Lc_Job_ID + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END

   --Success full execution write to VBSTL
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BSTL_LOG';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', Start_DATE = ' + CAST(@Ld_Start_DATE AS VARCHAR) + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', Process_NAME = ' + @Lc_Process_NAME + ', Procedure_NAME = ' + @Lc_Procedure_NAME + ', Successful_TEXT = ' + @Lc_Successful_TEXT + ', RecordPosition_QNTY = ' + CAST(@Ln_DetailRecordCount_QNTY AS VARCHAR) + ', StatusSuccess_CODE = ' + @Lc_StatusSuccess_CODE + ', BatchRunUser_TEXT = ' + @Lc_BatchRunUser_TEXT + ', Space_TEXT = ' + @Lc_Space_TEXT;

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Lc_Process_NAME,
    @As_Procedure_NAME            = @Lc_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Lc_Space_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_DetailRecordCount_QNTY,
    @As_ExecLocation_TEXT         = @Lc_Successful_TEXT,
    @As_ListKey_TEXT              = @Lc_Successful_TEXT,
    @As_DescriptionError_TEXT     = @Lc_Space_TEXT,
    @Ac_Status_CODE               = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT;

   --Commit the transaction
   COMMIT TRANSACTION OUTGOING_FIDM;

   --Drop the temporary table used to store data
   SET @Ls_Sql_TEXT = 'DROP TABLE ##ExtFIDM_P1 - 2';
   SET @Ls_SqlData_TEXT = '';

   DROP TABLE ##ExtFIDM_P1;
  END TRY

  BEGIN CATCH
   --Check if active transaction exists for this session then rollback the transaction
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION OUTGOING_FIDM;
    END;

   --Check if temporary table exists drop the table
   IF OBJECT_ID('tempdb..##ExtFIDM_P1') IS NOT NULL
    BEGIN
     DROP TABLE ##ExtFIDM_P1;
    END

   --Check for Exception information to log the description text based on the error
   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_ErrorMessage_TEXT = SUBSTRING(ERROR_MESSAGE(), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Lc_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_SqlData_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Lc_Process_NAME,
    @As_Procedure_NAME            = @Lc_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Lc_Space_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_DetailRecordCount_QNTY,
    @As_ExecLocation_TEXT         = @Ls_Sql_TEXT,
    @As_ListKey_TEXT              = @Ls_SqlData_TEXT,
    @As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE               = @Lc_StatusAbnormalend_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT;

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH
 END


GO
