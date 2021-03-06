/****** Object:  StoredProcedure [dbo].[BATCH_ENF_OUTGOING_CSLN$SP_EXTRACT_CSLN]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_ENF_OUTGOING_CSLN$SP_EXTRACT_CSLN
Programmer Name	:	IMP Team.
Description		:	The purpose of the batch program is to send enforcement remedy eligible NCPs details to 
                          CSLN vendor so that a match data file with insurance claim (worker comp and personal injury) 
                          information from the CSLN can be returned.
Frequency		:	'MONTHLY'
Developed On	:	4/19/2012
Called By		:	NONE
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_ENF_OUTGOING_CSLN$SP_EXTRACT_CSLN]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Li_RowCount_QNTY                 SMALLINT = 0,
          @Lc_StatusSuccess_CODE            CHAR(1) = 'S',
          @Lc_StatusFailed_CODE             CHAR(1) = 'F',
          @Lc_StatusAbnormalend_CODE        CHAR(1) = 'A',
          @Lc_StringZero_TEXT               CHAR(1) = '0',
          @Lc_Space_TEXT                    CHAR(1) = ' ',
          @Lc_CaseStatusOpen_CODE           CHAR(1) = 'O',
          @Lc_Yes_TEXT                      CHAR(1) = 'Y',
          @Lc_VerificationStatusGood_TEXT   CHAR(1) = 'Y',
          @Lc_TypeCaseNonIVD_CODE           CHAR(1) = 'H',
          @Lc_StatusEnforceExempt_CODE      CHAR(1) = 'E',
          @Lc_CaseMemberStatusActive_CODE   CHAR(1) = 'A',
          @Lc_TypePrimaryP_CODE             CHAR(1) = 'P',
          @Lc_TypePrimaryI_CODE             CHAR(1) = 'I',
          @Lc_InitatingInternational_CODE   CHAR(1) = 'C',
          @Lc_InitatingState_CODE           CHAR(1) = 'I',
          @Lc_InitatingTribal_CODE          CHAR(1) = 'T',
          @Lc_RespondingInternational_CODE  CHAR(1) = 'Y',
          @Lc_RespondingState_CODE          CHAR(1) = 'R',
          @Lc_RespondingTribal_CODE         CHAR(1) = 'S',
          @Lc_TypeWarning_CODE              CHAR(1) = 'W',   
          @Lc_No_TEXT					    CHAR(1) = 'N',       
          @Lc_CaseRelationshipNcp_CODE      CHAR(1) = 'A',
          @Lc_CaseRelationshipPutative_CODE CHAR(1) = 'P',          
          @Lc_State_CODE                    CHAR(2) = 'DE',
          @Lc_SourceReceiptCd_CODE          CHAR(2) = 'CD',
          @Lc_SourceReceiptDb_CODE          CHAR(2) = 'DB',
          @Lc_SourceReceiptEw_CODE          CHAR(2) = 'EW',
          @Lc_SourceReceiptRe_CODE          CHAR(2) = 'RE',
          @Lc_SourceReceiptUc_CODE          CHAR(2) = 'UC',
          @Lc_SourceReceiptVn_CODE          CHAR(2) = 'VN',
          @Lc_SubsystemEn_CODE			    CHAR(2) = 'EN',
          @Lc_ReasonStatusSy_CODE		    CHAR(2) = 'SY',    
          @Lc_ReasonStatusBi_CODE			CHAR(2) = 'BI', 
          @Lc_StatusStart_CODE              CHAR(4) = 'STRT',
          @Lc_StatusExempt_CODE             CHAR(4) = 'EXMT',
          @Lc_ActivityMajorCase_CODE		CHAR(4) = 'CASE',
          @Lc_ActivityMajorCclo_CODE        CHAR(4) = 'CCLO',
          @Lc_ActivityMajorCsln_CODE        CHAR(4) = 'CSLN',
          @Lc_StatusStrt_CODE			    CHAR(4) = 'STRT',
          @Lc_StatusComp_CODE			    CHAR(4) = 'COMP',
          @Lc_ReasonErfso_CODE              CHAR(5) = 'ERFSO',
          @Lc_ReasonErfsm_CODE              CHAR(5) = 'ERFSM',
          @Lc_ReasonErfss_CODE              CHAR(5) = 'ERFSS',
          @Lc_ActivityMinorStcln_CODE       CHAR(5) = 'STCLN',
          @Lc_BatchRunUser_TEXT             CHAR(5) = 'BATCH',
          @Lc_BateErrorE0944_CODE           CHAR(5) = 'E0944',
          @Lc_Job_ID                        CHAR(7) = 'DEB6010',
          @Lc_Successful_TEXT               CHAR(10) = 'SUCCESSFUL',          
          @Ls_Procedure_NAME                VARCHAR(50) = 'BATCH_ENF_OUTGOING_CSLN$SP_EXTRACT_CSLN',
          @Ls_Process_NAME                  VARCHAR(50) = 'BATCH_ENF_OUTGOING_CSLN',
          @Ld_Low_DATE					    DATE = '01/01/0001',
          @Ld_High_DATE                     DATE = '12/31/9999';
  DECLARE @Ln_Zero_NUMB                   NUMERIC(1) = 0,
          @Ln_Increment_NUMB			  NUMERIC(1) = 1,
          @Ln_CommitFreqParm_QNTY         NUMERIC(5),
          @Ln_ExceptionThresholdParm_QNTY NUMERIC(5),
          @Ln_Topic_IDNO                  NUMERIC(10),
          @Ln_Error_NUMB                  NUMERIC(11),
          @Ln_ErrorLine_NUMB              NUMERIC(11),
          @Ln_TransactionEventSeq_NUMB    NUMERIC(19) = 0,
          @Ln_SeqUnique_IDNO              NUMERIC(19) = 0,
          @Li_FetchStatus_QNTY            SMALLINT,
          @Lc_Msg_CODE                    CHAR(1),          
          @Lc_BateError_CODE              CHAR(5),
          @Ls_FileName_NAME               VARCHAR(50),
          @Ls_FileLocation_TEXT           VARCHAR(80),
          @Ls_Sql_TEXT                    VARCHAR(100),
          @Ls_FileSource_TEXT             VARCHAR(130),
          @Ls_Sqldata_TEXT                VARCHAR(1000),
          @Ls_Query_TEXT                  VARCHAR(1000),
          @Ls_ErrorMessage_TEXT           VARCHAR(4000),
          @Ls_DescriptionError_TEXT       VARCHAR(4000),          
          @Ld_Run_DATE                    DATE,
          @Ld_LastRun_DATE                DATE,
          @Ld_Start_DATE                  DATETIME2(0);
  DECLARE @Ln_CaseMemberCur_Case_IDNO       NUMERIC(6),
          @Ln_CaseMemberCur_MemberMci_IDNO  NUMERIC(10);

  BEGIN TRY
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   SET @Lc_BateError_CODE = @Lc_BateErrorE0944_CODE;
   SET @Ls_Sql_TEXT = 'CREATE ##ExtCsln_P1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, @Lc_Space_TEXT);

   CREATE TABLE ##ExtCsln_P1
    (
      Record_TEXT VARCHAR(900)
    );

   BEGIN TRANSACTION PROCESS_CSLN;

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS2';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, @Lc_Space_TEXT);

   EXECUTE BATCH_COMMON$SP_GET_BATCH_DETAILS2
    @Ac_Job_ID                  = @Lc_Job_ID,
    @Ad_Run_DATE                = @Ld_Run_DATE OUTPUT,
    @Ad_LastRun_DATE            = @Ld_LastRun_DATE OUTPUT,
    @An_CommitFreq_QNTY         = @Ln_CommitFreqParm_QNTY OUTPUT,
    @An_ExceptionThreshold_QNTY = @Ln_ExceptionThresholdParm_QNTY OUTPUT,
    @As_File_NAME               = @Ls_FileName_NAME OUTPUT,
    @As_FileLocation_TEXT       = @Ls_FileLocation_TEXT OUTPUT,
    @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT   = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     SET @Ls_DescriptionError_TEXT = 'PARM DATE CHECK';

     RAISERROR(50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'RUN DATE AND LAST RUN DATE VALIDATION';
   SET @Ls_Sqldata_TEXT = 'LAST RUN DATE = ' + CAST(@Ld_LastRun_DATE AS VARCHAR) + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   IF DATEADD(DAY, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_DescriptionError_TEXT = 'PARM DATE PROBLEM';

     RAISERROR(50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'FILE LOCATION AND NAME VALIDATION';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, @Lc_Space_TEXT);   
   SET @Ls_FileSource_TEXT = ISNULL(LTRIM (RTRIM (@Ls_FileLocation_TEXT)) + LTRIM (RTRIM (@Ls_FileName_NAME)), @Lc_Space_TEXT);

   IF @Ls_FileSource_TEXT = @Lc_Space_TEXT
    BEGIN
     SET @Ls_DescriptionError_TEXT = 'INVALID FILE NAME AND FILE LOCATION';

     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'DELETE ECSLN_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, @Lc_Space_TEXT);

   DELETE FROM ECSLN_Y1;

   SET @Ls_Sql_TEXT = 'INSERT NCP ECSLN_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, @Lc_Space_TEXT);

   INSERT INTO ECSLN_Y1
               (MemberMci_IDNO,
                Last_NAME,
                First_NAME,
                Middle_NAME,
                Suffix_NAME,
                MemberSsn_NUMB,
                Birth_DATE,
                LkcaAttn_ADDR,
                LkcaLine1_ADDR,
                LkcaLine2_ADDR,
                LkcaCity_ADDR,
                LkcaState_ADDR,
                LkcaZip_ADDR,
                Attn_ADDR,
                Line1_ADDR,
                Line2_ADDR,
                City_ADDR,
                State_ADDR,
                Zip_ADDR,
                HomePhone_NUMB,
                CellPhone_NUMB,
                InsCompany_IDNO,
                InsCompany_NAME,
                InsCompanyLine1_ADDR,
                InsCompanyLine2_ADDR,
                InsCompanyCity_ADDR,
                InsCompanyState_ADDR,
                InsCompanyZip_ADDR,
                InsClaim_NUMB,
                InsClaimType_CODE,
                InsClaimLoss_DATE,
                InsContactFirst_NAME,
                InsContactLast_NAME,
                InsContactPhone_NUMB,
                InsFaxContact_NUMB,
                Case_IDNO,
                File_ID,
                OrderIssued_DATE,
                TotalArrears_AMNT,
                TypeAction_CODE,
                Action_DATE)
   SELECT x.NcpPf_IDNO MemberMci_IDNO,
          SUBSTRING(x.LastNcp_NAME, 1, 15) Last_NAME,
          SUBSTRING(x.FirstNcp_NAME, 1, 11) First_NAME,
          SUBSTRING(x.MiddleNcp_NAME, 1, 1) Middle_NAME,
          SUBSTRING(x.SuffixNcp_NAME, 1, 3) Suffix_NAME,
          x.MemberSsn_NUMB,
          CONVERT(VARCHAR(8), x.BirthNcp_DATE, 112) Birth_DATE,
          @Lc_Space_TEXT LkcaAttn_ADDR,
          @Lc_Space_TEXT LkcaLine1_ADDR,
          @Lc_Space_TEXT LkcaLine2_ADDR,
          @Lc_Space_TEXT LkcaCity_ADDR,
          @Lc_Space_TEXT LkcaState_ADDR,
          @Lc_Space_TEXT LkcaZip_ADDR,
          @Lc_Space_TEXT Attn_ADDR,
          @Lc_Space_TEXT Line1_ADDR,
          @Lc_Space_TEXT Line2_ADDR,
          @Lc_Space_TEXT City_ADDR,
          @Lc_Space_TEXT State_ADDR,
          @Lc_Space_TEXT Zip_ADDR,
          @Lc_Space_TEXT HomePhone_NUMB,
          @Lc_Space_TEXT CellPhone_NUMB,
          @Lc_Space_TEXT InsCompany_IDNO,
          @Lc_Space_TEXT InsCompany_NAME,
          @Lc_Space_TEXT InsCompanyLine1_ADDR,
          @Lc_Space_TEXT InsCompanyLine2_ADDR,
          @Lc_Space_TEXT InsCompanyCity_ADDR,
          @Lc_Space_TEXT InsCompanyState_ADDR,
          @Lc_Space_TEXT InsCompanyZip_ADDR,
          @Lc_Space_TEXT InsClaim_NUMB,
          @Lc_Space_TEXT InsClaimType_CODE,
          @Lc_Space_TEXT InsClaimLoss_DATE,
          @Lc_Space_TEXT InsContactFirst_NAME,
          @Lc_Space_TEXT InsContactLast_NAME,
          @Lc_Space_TEXT InsContactPhone_NUMB,
          @Lc_Space_TEXT InsFaxContact_NUMB,
          @Lc_Space_TEXT Case_IDNO,
          @Lc_Space_TEXT File_ID,
          @Lc_Space_TEXT OrderIssued_DATE,
          @Lc_Space_TEXT TotalArrears_AMNT,
          @Lc_Space_TEXT TypeAction_CODE,
          @Lc_Space_TEXT Action_DATE
     FROM (SELECT DISTINCT
                  a.NcpPf_IDNO,
                  a.LastNcp_NAME,
                  a.FirstNcp_NAME,
                  a.MiddleNcp_NAME,
                  a.SuffixNcp_NAME,
                  b.MemberSsn_NUMB,
                  a.BirthNcp_DATE
             FROM ENSD_Y1 a,
                  ACEN_Y1 m,
                  DEMO_Y1 b,
                  MSSN_Y1 c
            WHERE b.MemberMci_IDNO = a.NcpPf_IDNO
              AND a.StatusCase_CODE = @Lc_CaseStatusOpen_CODE 
              AND a.TypeCase_CODE != @Lc_TypeCaseNonIVD_CODE              
              AND (a.RespondInit_CODE NOT IN (@Lc_InitatingInternational_CODE, @Lc_InitatingState_CODE, @Lc_InitatingTribal_CODE, @Lc_RespondingInternational_CODE,
                                              @Lc_RespondingState_CODE, @Lc_RespondingTribal_CODE)
                    OR (a.RespondInit_CODE IN (@Lc_RespondingInternational_CODE, @Lc_RespondingState_CODE, @Lc_RespondingTribal_CODE)
                        AND EXISTS(SELECT 1
                                     FROM ICAS_Y1 x
                                    WHERE x.Case_IDNO = a.Case_IDNO
                                      AND x.Reason_CODE NOT IN (@Lc_ReasonErfso_CODE, @Lc_ReasonErfsm_CODE, @Lc_ReasonErfss_CODE))))  
              AND DATEDIFF(DAY, @Ld_Run_DATE, a.OrderIssued_DATE) < 45 
              AND @Ld_Run_DATE BETWEEN a.OrderEffective_DATE AND a.OrderEnd_DATE 
              AND a.Case_IDNO NOT IN (SELECT z.Case_IDNO
                                        FROM DMJR_Y1 z
                                       WHERE z.ActivityMajor_CODE = @Lc_ActivityMajorCclo_CODE
                                         AND z.Status_CODE = @Lc_StatusStart_CODE
                                         AND z.MajorIntSeq_NUMB = (SELECT MAX(MajorIntSeq_NUMB)
                                                                     FROM DMJR_Y1 y
                                                                    WHERE y.MemberMci_IDNO = a.NcpPf_IDNO
                                                                      AND y.Case_IDNO = a.Case_IDNO
                                                                      AND y.ActivityMajor_CODE = z.ActivityMajor_CODE
                                                                      AND y.Status_CODE = z.Status_CODE)) 
              AND a.Case_IDNO = m.Case_IDNO
              AND m.StatusEnforce_CODE != @Lc_StatusEnforceExempt_CODE 
              AND @Ld_Run_DATE NOT BETWEEN m.BeginExempt_DATE AND m.EndExempt_DATE 											
              AND a.Case_IDNO NOT IN (SELECT DISTINCT
                                             n.Case_IDNO
                                        FROM DMJR_Y1 n,
                                             ENSD_Y1 x
                                       WHERE n.ActivityMajor_CODE = @Lc_ActivityMajorCsln_CODE
                                         AND n.Status_CODE = @Lc_StatusExempt_CODE
                                         AND @Ld_Run_DATE BETWEEN n.BeginExempt_DATE AND n.EndExempt_DATE
                                         AND n.Case_IDNO = x.Case_IDNO) 
              AND a.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE 
              AND a.NcpPf_IDNO NOT IN (SELECT z.NcpPf_IDNO
                                         FROM ENSD_Y1 z
                                        WHERE z.Bankruptcy13_INDC = @Lc_Yes_TEXT
                                          AND z.NcpPf_IDNO = a.NcpPf_IDNO) 
              AND c.MemberMci_IDNO = a.NcpPf_IDNO
              AND c.Enumeration_CODE = @Lc_VerificationStatusGood_TEXT 
              AND c.TypePrimary_CODE IN (@Lc_TypePrimaryP_CODE, @Lc_TypePrimaryI_CODE) 
              AND a.Arrears_AMNT >= 500 -- 11
              AND a.Case_IDNO NOT IN (SELECT l.Case_IDNO
                                        FROM RCTH_Y1 r, LSUP_Y1 l
                                       WHERE r.SourceReceipt_CODE IN (@Lc_SourceReceiptCd_CODE, @Lc_SourceReceiptDb_CODE, @Lc_SourceReceiptEw_CODE, @Lc_SourceReceiptRe_CODE,
                                                                          @Lc_SourceReceiptUc_CODE, @Lc_SourceReceiptVn_CODE) 
                                         AND DATEDIFF(DAY, r.Receipt_DATE, @Ld_Run_DATE) < 60
                                         AND r.Batch_DATE = l.Batch_DATE
										 AND r.SourceBatch_CODE = l.SourceBatch_CODE
										 AND r.Batch_NUMB = l.Batch_NUMB
										 AND r.SeqReceipt_NUMB = l.SeqReceipt_NUMB
										 AND r.PayorMci_IDNO = a.NcpPf_IDNO)             
          ) AS x
   OPTION (RECOMPILE);

   SET @Li_RowCount_QNTY = @@ROWCOUNT;

   IF(@Li_RowCount_QNTY = 0)
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'NO RECORD(S) TO PROCESS';
     
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_ERROR_DESCRIPTION';
     SET @Ls_SqlData_TEXT = 'Procedure_NAME = ' + @Ls_Procedure_NAME + ', ErrorMessage_TEXT = ' + @Ls_ErrorMessage_TEXT + ', Error_NUMB = ' + CAST(@Ln_Error_NUMB AS VARCHAR)+ ', ErrorLine_NUMB = ' + CAST(@Ln_ErrorLine_NUMB AS VARCHAR);
     
     EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
      @As_Procedure_NAME        = @Ls_Procedure_NAME,
      @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
      @As_Sql_TEXT              = @Ls_Sql_TEXT,
      @As_Sqldata_TEXT          = @Ls_SqlData_TEXT,
      @An_Error_NUMB            = @Ln_Error_NUMB,
      @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
      @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG';
     SET @Ls_SqlData_TEXT = 'Process_NAME = ' + @Ls_Process_NAME + ', Procedure_NAME = ' + @Ls_Procedure_NAME + ', Job_ID = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', TypeError_CODE = ' + @Lc_TypeWarning_CODE + ', Line_NUMB = ' + @Ln_Zero_NUMB + ', Error_CODE = ' + @Lc_BateError_CODE + ', DescriptionError_TEXT = ' + @Ls_DescriptionError_TEXT + ', ListKey_TEXT = ' + @Ls_SqlData_TEXT;

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Ls_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_TypeWarning_CODE,
      @An_Line_NUMB                = @Ln_Zero_NUMB,
      @Ac_Error_CODE               = @Lc_BateError_CODE,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
      @As_ListKey_TEXT             = @Ls_SqlData_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END
    END
      
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT';
   SET @Ls_Sqldata_TEXT = 'Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', EffectiveEvent_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Note_INDC = ' + ISNULL(@Lc_No_TEXT, '') + ', EventFunctionalSeq_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '');
   
   EXECUTE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
    @Ac_Worker_ID                = @Lc_BatchRunUser_TEXT,
    @Ac_Process_ID               = @Lc_Job_ID,
    @Ad_EffectiveEvent_DATE      = @Ld_Run_DATE,
    @Ac_Note_INDC                = @Lc_No_TEXT,
    @An_EventFunctionalSeq_NUMB  = @Ln_Zero_NUMB,
    @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
    @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;
   
   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR(50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'INSERT DMJR_Y1';
   SET @Ls_Sqldata_TEXT = 'TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '')+', Increment_NUMB = '+ CAST(@Ln_Increment_NUMB  AS VARCHAR) + ', ActivityMajorCase_CODE = '+@Lc_ActivityMajorCase_CODE  +', SubsystemLo_CODE = '+@Lc_SubsystemEn_CODE +', Run_DATE = '+ CAST(@Ld_Run_DATE AS VARCHAR) +', High_DATE = '+ CAST(@Ld_High_DATE AS VARCHAR) +', ReasonStatusBi_CODE = '+  @Lc_ReasonStatusBi_CODE +', Low_DATE = '+ CAST(@Ld_Low_DATE AS VARCHAR) +', BatchRunUser_TEXT = '+ @Lc_BatchRunUser_TEXT ;
			
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
   SELECT DISTINCT B.Case_IDNO, 
		  0 AS OrderSeq_NUMB,
		  (SELECT ISNULL(MAX(c.MajorIntSEQ_NUMB), 0) + @Ln_Increment_NUMB
			 FROM DMJR_Y1 c
			WHERE c.Case_IDNO = b.Case_IDNO) AS MajorIntSEQ_NUMB,
		  0 AS MemberMci_IDNO, 
		  @Lc_ActivityMajorCase_CODE AS ActivityMajor_CODE,
		  @Lc_SubsystemEn_CODE AS Subsystem_CODE, 
		  @Lc_Space_TEXT AS TypeOthpSource_CODE,
		  0 AS OthpSource_IDNO,
		  @Ld_Run_DATE AS Entered_DATE,
		  @Ld_High_DATE AS Status_DATE,
		  @Lc_StatusStrt_CODE AS Status_CODE,
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
		  @Ld_Start_DATE AS Update_DTTM,
		  @Ln_TransactionEventSeq_NUMB AS TransactionEventSeq_NUMB,
		  @Lc_Space_TEXT AS TypeReference_CODE,
		  @Lc_Space_TEXT AS Reference_ID
	FROM ECSLN_Y1 a,
		 CMEM_Y1 b,
		 CASE_Y1 s
   WHERE a.MemberMci_IDNO = b.MemberMci_IDNO
      AND b.Case_IDNO = s.Case_IDNO
      AND s.StatusCase_CODE = @Lc_CaseStatusOpen_CODE
	  AND b.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE ,@Lc_CaseRelationshipPutative_CODE)
	  AND b.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
	  AND NOT EXISTS (SELECT 1
						FROM DMJR_Y1 d
					   WHERE b.Case_IDNO = d.Case_IDNO
						 AND d.Subsystem_CODE = @Lc_SubsystemEn_CODE
						 AND d.ActivityMajor_CODE = @Lc_ActivityMajorCase_CODE
						 AND d.Status_CODE = @Lc_StatusStrt_CODE); 
			
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
   SET @Ls_SqlData_TEXT = 'TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '')+', ActivityMinor_CODE = '+ @Lc_ActivityMinorStcln_CODE + ', Run_DATE = '+ CAST( @Ld_Run_DATE  AS VARCHAR)+ ', StatusComplete_CODE = '+ @Lc_StatusComp_CODE  +', ReasonStatusSy_CODE = '+ @Lc_ReasonStatusSy_CODE +', BatchRunUser_TEXT = '+ @Lc_BatchRunUser_TEXT +', SubsystemLo_CODE = '+@Lc_SubsystemEn_CODE  + ', ActivityMajorCase_CODE = '+ @Lc_ActivityMajorCsln_CODE +', StatusStart_CODE = '+ @Lc_StatusStrt_CODE;
   
   WITH BulkInsert_CjnrItopc
   AS(
    SELECT a.Case_IDNO AS Case_IDNO,
		   0 AS OrderSeq_NUMB,		   
		   d.MajorIntSEQ_NUMB AS MajorIntSEQ_NUMB,
		   ISNULL((SELECT MAX(x.MinorIntSeq_NUMB)
		  		     FROM UDMNR_V1 x
		  	        WHERE d.Case_IDNO = x.Case_IDNO
		  		      AND d.MajorIntSEQ_NUMB = x.MajorIntSEQ_NUMB), 0) + ROW_NUMBER() OVER(PARTITION BY a.Case_IDNO ORDER BY a.Case_IDNO) AS MinorIntSeq_NUMB,		   
		   x.MemberMci_IDNO AS MemberMci_IDNO,
		   @Lc_ActivityMinorStcln_CODE AS ActivityMinor_CODE,
		   @Lc_Space_TEXT AS ActivityMinorNext_CODE,
		   @Ld_Run_DATE AS Entered_DATE,
		   @Ld_Run_DATE AS Due_DATE,
		   @Ld_Run_DATE AS Status_DATE,
		   @Lc_StatusComp_CODE AS Status_CODE,
		   @Lc_ReasonStatusSy_CODE AS ReasonStatus_CODE, 
		   0 AS Schedule_NUMB,		   
		   d.Forum_IDNO,
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
		   @Lc_SubsystemEn_CODE AS Subsystem_CODE,
		   @Lc_ActivityMajorCase_CODE AS ActivityMajor_CODE
      FROM ECSLN_Y1 x,
           ENSD_Y1 a,
           ACEN_Y1 m,
           DEMO_Y1 b,
           MSSN_Y1 c,
           DMJR_Y1 d           
     WHERE a.Case_IDNO = d.Case_IDNO
       AND d.Subsystem_CODE = @Lc_SubsystemEn_CODE
	   AND d.ActivityMajor_CODE = @Lc_ActivityMajorCase_CODE
	   AND d.Status_CODE = @Lc_StatusStrt_CODE
       AND x.MemberMci_IDNO = a.NcpPf_IDNO
       AND b.MemberMci_IDNO = a.NcpPf_IDNO
       AND a.StatusCase_CODE = @Lc_CaseStatusOpen_CODE 
       AND a.TypeCase_CODE != @Lc_TypeCaseNonIVD_CODE           
       AND (a.RespondInit_CODE NOT IN (@Lc_InitatingInternational_CODE, @Lc_InitatingState_CODE, @Lc_InitatingTribal_CODE, @Lc_RespondingInternational_CODE,
                                       @Lc_RespondingState_CODE, @Lc_RespondingTribal_CODE)
             OR (a.RespondInit_CODE IN (@Lc_RespondingInternational_CODE, @Lc_RespondingState_CODE, @Lc_RespondingTribal_CODE)
                 AND EXISTS(SELECT 1
                              FROM ICAS_Y1 x
                             WHERE x.Case_IDNO = a.Case_IDNO
                               AND x.Reason_CODE NOT IN (@Lc_ReasonErfso_CODE, @Lc_ReasonErfsm_CODE, @Lc_ReasonErfss_CODE)))) 
       AND DATEDIFF(DAY, @Ld_Run_DATE, a.OrderIssued_DATE) < 45
       AND @Ld_Run_DATE BETWEEN a.OrderEffective_DATE AND a.OrderEnd_DATE 
       AND a.Case_IDNO NOT IN (SELECT z.Case_IDNO
                                 FROM DMJR_Y1 z
                                WHERE z.ActivityMajor_CODE = @Lc_ActivityMajorCclo_CODE
                                  AND z.Status_CODE = @Lc_StatusStart_CODE
                                  AND z.MajorIntSeq_NUMB = (SELECT MAX(MajorIntSeq_NUMB)
                                                              FROM DMJR_Y1 y
                                                             WHERE y.MemberMci_IDNO = a.NcpPf_IDNO
                                                               AND y.Case_IDNO = a.Case_IDNO
                                                               AND y.ActivityMajor_CODE = z.ActivityMajor_CODE
                                                               AND y.Status_CODE = z.Status_CODE)) 
       AND a.Case_IDNO = m.Case_IDNO
       AND m.StatusEnforce_CODE != @Lc_StatusEnforceExempt_CODE 
       AND @Ld_Run_DATE NOT BETWEEN m.BeginExempt_DATE AND m.EndExempt_DATE 												
       AND a.Case_IDNO NOT IN (SELECT DISTINCT
                                      n.Case_IDNO
                                 FROM DMJR_Y1 n,
                                      ENSD_Y1 x
                                WHERE n.ActivityMajor_CODE = @Lc_ActivityMajorCsln_CODE
                                  AND n.Status_CODE = @Lc_StatusExempt_CODE
                                  AND @Ld_Run_DATE BETWEEN n.BeginExempt_DATE AND n.EndExempt_DATE
                                  AND n.Case_IDNO = x.Case_IDNO) 
       AND a.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE 
       AND a.NcpPf_IDNO NOT IN (SELECT z.NcpPf_IDNO
                                  FROM ENSD_Y1 z
                                 WHERE z.Bankruptcy13_INDC = @Lc_Yes_TEXT
                                   AND z.NcpPf_IDNO = a.NcpPf_IDNO) 
       AND c.MemberMci_IDNO = a.NcpPf_IDNO
       AND c.Enumeration_CODE = @Lc_VerificationStatusGood_TEXT 
       AND c.TypePrimary_CODE IN (@Lc_TypePrimaryP_CODE, @Lc_TypePrimaryI_CODE) 
       AND a.Arrears_AMNT >= 500 
       AND a.Case_IDNO NOT IN (SELECT r.Case_IDNO
                                 FROM RCTH_Y1 R
                                WHERE r.SourceReceipt_CODE NOT IN (@Lc_SourceReceiptCd_CODE, @Lc_SourceReceiptDb_CODE, @Lc_SourceReceiptEw_CODE, @Lc_SourceReceiptRe_CODE,
                                                                   @Lc_SourceReceiptUc_CODE, @Lc_SourceReceiptVn_CODE) 
                                  AND DATEDIFF(DAY, r.Receipt_DATE, @Ld_Run_DATE) >= 60)
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
		  FROM BulkInsert_CjnrItopc;

   SET @Ls_Sql_TEXT = 'INSERT ##ExtCsln_P1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, @Lc_Space_TEXT);

   INSERT INTO ##ExtCsln_P1
               (Record_TEXT)
   SELECT (CAST(RIGHT((REPLICATE(@Lc_StringZero_TEXT, 10) + LTRIM(RTRIM(a.MemberMci_IDNO))), 10) AS CHAR(10)) + CAST(LEFT((LTRIM(RTRIM(a.Last_NAME)) + REPLICATE(@Lc_Space_TEXT, 15)), 15) AS CHAR(15)) + CAST(LEFT((LTRIM(RTRIM(a.First_NAME)) + REPLICATE(@Lc_Space_TEXT, 11)), 11) AS CHAR(11)) + CAST(LEFT((LTRIM(RTRIM(a.Middle_NAME)) + REPLICATE(@Lc_Space_TEXT, 1)), 1) AS CHAR(1)) + CAST(LEFT((LTRIM(RTRIM(a.Suffix_NAME)) + REPLICATE(@Lc_Space_TEXT, 3)), 3) AS CHAR(3)) + CAST(RIGHT((REPLICATE(@Lc_StringZero_TEXT, 9) + LTRIM(RTRIM(a.MemberSsn_NUMB))), 9) AS CHAR(9)) + CAST(LEFT((LTRIM(RTRIM(a.Birth_DATE)) + REPLICATE(@Lc_Space_TEXT, 8)), 8) AS CHAR(8)) + CAST(LEFT((LTRIM(RTRIM(a.LkcaAttn_ADDR)) + REPLICATE(@Lc_Space_TEXT, 40)), 40) AS CHAR(40)) + CAST(LEFT((LTRIM(RTRIM(a.LkcaLine1_ADDR)) + REPLICATE(@Lc_Space_TEXT, 40)), 40) AS CHAR(40)) + CAST(LEFT((LTRIM(RTRIM(a.LkcaLine2_ADDR)) + REPLICATE(@Lc_Space_TEXT, 40)), 40)AS CHAR(40)) + CAST(LEFT((LTRIM(RTRIM(a.LkcaCity_ADDR)) + REPLICATE(@Lc_Space_TEXT, 30)), 30) AS CHAR(30)) + CAST(LEFT((LTRIM(RTRIM(a.LkcaState_ADDR)) + REPLICATE(@Lc_Space_TEXT, 2)), 2) AS CHAR(2)) + CAST(LEFT((LTRIM(RTRIM(a.LkcaZip_ADDR)) + REPLICATE(@Lc_Space_TEXT, 9)), 9) AS CHAR(9)) + CAST(LEFT((LTRIM(RTRIM(a.Attn_ADDR)) + REPLICATE(@Lc_Space_TEXT, 40)), 40) AS CHAR(40)) + CAST(LEFT((LTRIM(RTRIM(a.Line1_ADDR)) + REPLICATE(@Lc_Space_TEXT, 40)), 40) AS CHAR(40)) + CAST(LEFT((LTRIM(RTRIM(a.Line2_ADDR)) + REPLICATE(@Lc_Space_TEXT, 40)), 40) AS CHAR(40)) + CAST(LEFT((LTRIM(RTRIM(a.City_ADDR)) + REPLICATE(@Lc_Space_TEXT, 30)), 30) AS CHAR(30)) + CAST(LEFT((LTRIM(RTRIM(a.State_ADDR)) + REPLICATE(@Lc_Space_TEXT, 2)), 2) AS CHAR(2)) + CAST(LEFT((LTRIM(RTRIM(a.Zip_ADDR)) + REPLICATE(@Lc_Space_TEXT, 9)), 9) AS CHAR(9)) + CAST(LEFT((LTRIM(RTRIM(a.HomePhone_NUMB)) + REPLICATE(@Lc_Space_TEXT, 25)), 25) AS CHAR(25)) + CAST(LEFT((LTRIM(RTRIM(a.CellPhone_NUMB)) + REPLICATE(@Lc_Space_TEXT, 25)), 25) AS CHAR(25)) + CAST(LEFT((LTRIM(RTRIM(a.InsCompany_NAME)) + REPLICATE(@Lc_Space_TEXT, 80)), 80) AS CHAR(80)) + CAST(LEFT((LTRIM(RTRIM(a.InsCompanyLine1_ADDR)) + REPLICATE(@Lc_Space_TEXT, 40)), 40) AS CHAR(40)) + CAST(LEFT((LTRIM(RTRIM(a.InsCompanyLine2_ADDR)) + REPLICATE(@Lc_Space_TEXT, 40)), 40) AS CHAR(40)) + CAST(LEFT((LTRIM(RTRIM(a.InsCompanyCity_ADDR)) + REPLICATE(@Lc_Space_TEXT, 30)), 30) AS CHAR(30)) + CAST(LEFT((LTRIM(RTRIM(a.InsCompanyState_ADDR)) + REPLICATE(@Lc_Space_TEXT, 2)), 2) AS CHAR(2)) + CAST(LEFT((LTRIM(RTRIM(a.InsCompanyZip_ADDR)) + REPLICATE(@Lc_Space_TEXT, 9)), 9) AS CHAR(9)) + CAST(LEFT((LTRIM(RTRIM(a.InsClaim_NUMB)) + REPLICATE(@Lc_Space_TEXT, 30)), 30) AS CHAR(30)) + CAST(LEFT((LTRIM(RTRIM(a.InsClaimType_CODE)) + REPLICATE(@Lc_Space_TEXT, 1)), 1) AS CHAR(1)) + CAST(LEFT((LTRIM(RTRIM(a.InsClaimLoss_DATE)) + REPLICATE(@Lc_Space_TEXT, 8)), 8) AS CHAR(8)) + CAST(LEFT((LTRIM(RTRIM(a.InsContactFirst_NAME)) + REPLICATE(@Lc_Space_TEXT, 20)), 20) AS CHAR(20)) + CAST(LEFT((LTRIM(RTRIM(a.InsContactLast_NAME)) + REPLICATE(@Lc_Space_TEXT, 30)), 30) AS CHAR(30)) + CAST(LEFT((LTRIM(RTRIM(a.InsContactPhone_NUMB)) + REPLICATE(@Lc_Space_TEXT, 25)), 25) AS CHAR(25)) + CAST(LEFT((LTRIM(RTRIM(a.InsFaxContact_NUMB)) + REPLICATE(@Lc_Space_TEXT, 25)), 25) AS CHAR(25)) + CAST(LEFT((LTRIM(RTRIM(a.Case_IDNO)) + REPLICATE(@Lc_Space_TEXT, 6)), 6) AS CHAR(6)) + CAST(LEFT((LTRIM(RTRIM(a.File_ID)) + REPLICATE(@Lc_Space_TEXT, 11)), 11) AS CHAR(11)) + CAST(LEFT((LTRIM(RTRIM(a.OrderIssued_DATE)) + REPLICATE(@Lc_Space_TEXT, 8)), 8) AS CHAR(8)) + @Lc_State_CODE + CAST(RIGHT((REPLICATE(@Lc_StringZero_TEXT, 8) + LTRIM(RTRIM(a.TotalArrears_AMNT))), 8) AS CHAR(8)) + CAST(LEFT((LTRIM(RTRIM(a.TypeAction_CODE)) + REPLICATE(@Lc_Space_TEXT, 1)), 1) AS CHAR(1)) + CAST(LEFT((LTRIM(RTRIM(a.Action_DATE)) + REPLICATE(@Lc_Space_TEXT, 8)), 8) AS CHAR(8)) + REPLICATE(@Lc_Space_TEXT, 87)) AS Record_TEXT 
     FROM ECSLN_Y1 a
    ORDER BY a.MemberMci_IDNO;

   COMMIT TRANSACTION PROCESS_CSLN;

   SET @Ls_Query_TEXT = 'SELECT Record_TEXT FROM ##ExtCsln_P1';
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_EXTRACT_DATA';
   SET @Ls_Sqldata_TEXT ='FILE LOCATION = ' + @Ls_FileLocation_TEXT + ', FILE NAME = ' + @Ls_FileName_NAME + ', QUERY = ' + @Ls_Query_TEXT;

   EXECUTE BATCH_COMMON$SP_EXTRACT_DATA
    @As_FileLocation_TEXT     = @Ls_FileLocation_TEXT,
    @As_File_NAME             = @Ls_FileName_NAME,
    @As_Query_TEXT            = @Ls_Query_TEXT,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END

   BEGIN TRANSACTION PROCESS_CSLN;

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE';
   SET @Ls_Sqldata_TEXT = 'JOB ID = ' + @Lc_Job_ID + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

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
   SET @Ls_Sqldata_TEXT ='JOB ID = ' + @Lc_Job_ID + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', START DATE = ' + CAST(@Ld_Start_DATE AS VARCHAR) + ', PACKAGE NAME = ' + @Ls_Process_NAME + ', PROCEDURE NAME = ' + @Ls_Procedure_NAME;

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
    @An_ProcessedRecordCount_QNTY = @Li_RowCount_QNTY;

   SET @Ls_Sql_TEXT = 'DROP TABLE ##ExtCsln_P1 - 2';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, @Lc_Space_TEXT);

   DROP TABLE ##ExtCsln_P1;

   COMMIT TRANSACTION PROCESS_CSLN;
  END TRY

  BEGIN CATCH
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION PROCESS_CSLN;
    END

   IF OBJECT_ID('tempdb..##ExtCsln_P1') IS NOT NULL
    BEGIN
     DROP TABLE ##ExtCsln_P1;
    END

   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();
   SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_ErrorMessage_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Lc_Space_TEXT,
    @As_ExecLocation_TEXT         = @Ls_Sql_TEXT,
    @As_ListKey_TEXT              = @Ls_Sqldata_TEXT,
    @As_DescriptionError_TEXT     = @Ls_ErrorMessage_TEXT,
    @Ac_Status_CODE               = @Lc_StatusAbnormalend_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Li_RowCount_QNTY;

   RAISERROR(@Ls_DescriptionError_TEXT,16,1);
  END CATCH;
 END;


GO
