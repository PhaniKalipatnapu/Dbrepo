/****** Object:  StoredProcedure [dbo].[BATCH_ENF_OUTGOING_CBR$SP_EXTRACT_CBR]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_ENF_OUTGOING_CBR$SP_EXTRACT_CBR
Programmer Name	:	IMP Team.
Description		:	This batch program extracts all qualified NCPs who have not responded to the notice ENF-52 
						  (Notice of reporting to Credit Agencies) for more than 35 calendar days and has an arrears 
						  balance greater than or equal to $1000.
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
CREATE PROCEDURE [dbo].[BATCH_ENF_OUTGOING_CBR$SP_EXTRACT_CBR]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Li_Rowcount_QNTY                 SMALLINT = 0,
          @Li_FetchStatus_QNTY              SMALLINT = 0,
          @Lc_StatusFailed_CODE             CHAR(1) = 'F',
          @Lc_Note_INDC                     CHAR(1) = 'N',
          @Lc_StatusSuccess_CODE            CHAR(1) = 'S',
          @Lc_StatusAbnormalend_CODE        CHAR(1) = 'A',
          @Lc_Space_TEXT                    CHAR(1) = ' ',
          @Lc_No_INDC                       CHAR(1) = 'N',
          @Lc_Yes_INDC                      CHAR(1) = 'Y',
          @Lc_StringOne_TEXT                CHAR(1) = '1',
          @Lc_StringZero_TEXT               CHAR(1) = '0',
          @Lc_ConsumerValidAddress_INDC     CHAR(1) = 'U',
          @Lc_ConsumerNoAddress_INDC        CHAR(1) = 'T',
          @Lc_ReferralUpdateSent_TEXT       CHAR(1) = 'S',
          @Lc_CaseStatusOpen_CODE           CHAR(1) = 'O',
          @Lc_RespondInitNonInterstate_CODE CHAR(1) = 'N',
          @Lc_RespondingState_CODE          CHAR(1) = 'R',
          @Lc_RespondingTribal_CODE         CHAR(1) = 'S',
          @Lc_RespondingInternational_CODE  CHAR(1) = 'Y',
          @Lc_TypeCaseNonIVD_CODE           CHAR(1) = 'H',
          @Lc_CaseMemberStatusActive_CODE   CHAR(1) = 'A',
          @Lc_TypePortfolioO_INDC           CHAR(1) = 'O',
          @Lc_ReferralUpdateSent_CODE       CHAR(1) = 'S',
          @Lc_ReferralFirstTime_CODE        CHAR(1) = 'R',
          @Lc_ReferralDelete_CODE           CHAR(1) = 'D',
          @Lc_ReferralNotExclude_CODE       CHAR(1) = 'N',
          @Lc_CbrSupportProcess_INDC        CHAR(1) = 'C',          
          @Lc_TypeWarning_CODE              CHAR(1) = 'W',
          @Lc_ReasonStatusRw_CODE           CHAR(2) = 'RW',
          @Lc_ReasonStatusNr_CODE           CHAR(2) = 'NR',
          @Lc_ReasonStatusFs_CODE           CHAR(2) = 'FS',
          @Lc_ReasonStatusRi_CODE           CHAR(2) = 'RI',
          @Lc_ReasonStatusNm_CODE           CHAR(2) = 'NM',
          @Lc_ReasonStatusRz_CODE           CHAR(2) = 'RZ',
          @Lc_ReasonStatusBc_CODE           CHAR(2) = 'BC',
          @Lc_ReasonStatusWp_CODE           CHAR(2) = 'WP',
          @Lc_ReasonStatusCy_CODE           CHAR(2) = 'CY',
          @Lc_ActiveCase_TEXT               CHAR(2) = '93',
          @Lc_CaseAlreadySent_TEXT          CHAR(2) = '11',
          @Lc_CaseClosed_TEXT               CHAR(2) = '62',
          @Lc_CaseDelete_TEXT               CHAR(2) = 'DA',
          @Lc_ChildSupport_TEXT             CHAR(2) = '93',
          @Lc_ChargingCase_TEXT             CHAR(2) = 'CS',
          @Lc_CycleNumber_TEXT              CHAR(2) = '20',
          @Lc_Term_TEXT                     CHAR(3) = '001',
          @Lc_StatusStart_CODE              CHAR(4) = 'STRT',
          @Lc_StatusComplete_CODE           CHAR(4) = 'COMP',
          @Lc_ActivityMajorCrpt_CODE        CHAR(4) = 'CRPT',
          @Lc_RecordDescriptorWord_TEXT     CHAR(4) = '0426',
          @Lc_TableIdCrdt_CODE              CHAR(4) = 'CRDT',
          @Lc_TableSubIdAcno_CODE           CHAR(4) = 'ACNO',
          @Lc_ValueInvs_CODE                CHAR(4) = 'INVS',
          @Lc_ValueEqfx_CODE                CHAR(4) = 'EQFX',
          @Lc_ValueExpr_CODE                CHAR(4) = 'EXPR',
          @Lc_ValueTrun_CODE                CHAR(4) = 'TRUN',
          @Lc_BatchRunUser_TEXT             CHAR(5) = 'BATCH',
          @Lc_ActivityMinorRencp_CODE       CHAR(5) = 'RENCP',
          @Lc_ActivityMinorSadmh_CODE       CHAR(5) = 'SADMH',
          @Lc_ActivityMinorInfff_CODE       CHAR(5) = 'INFFF',
          @Lc_ActivityMinorRroah_CODE       CHAR(5) = 'RROAH',
          @Lc_ActivityMinorMoncr_CODE       CHAR(5) = 'MONCR',
          @Lc_ActivityMinorAcdna_CODE       CHAR(5) = 'ACDNA',
          @Lc_ActivityMinorCafrd_CODE       CHAR(5) = 'CAFRD',          
          @Lc_FsoByObligee_CODE             CHAR(5) = 'ERFSM',
          @Lc_FsoModObligee_CODE            CHAR(5) = 'ERFSO',
          @Lc_FsoModIvDAgency_CODE          CHAR(5) = 'ERFSS',
          @Lc_BateErrorE0944_CODE           CHAR(5) = 'E0944', 
          @Lc_Header_TEXT                   CHAR(6) = 'HEADER',
          @Lc_Trailer_TEXT                  CHAR(7) = 'TRAILER', 
          @Lc_Identify_NUMB					CHAR(7) = '3500001',        
          @Lc_Job_ID                        CHAR(7) = 'DEB5360',
          @Lc_LowdateMMDDYYYY00000000_CODE  CHAR(8) = '00000000',          
          @Lc_NotUsed_TEXT                  CHAR(8) = 'NOT USED',          
          @Lc_Successful_TEXT               CHAR(10) = 'SUCCESSFUL',
          @Lc_ReporterPhoneNo_TEXT          CHAR(10) = '3023956734',
          @Lc_ReporterName_TEXT             CHAR(17) = 'STATE OF DELAWARE',
          @Lc_ReporterAddress_TEXT          CHAR(29) = 'DE HEALTH AND SOCIAL SERVICES',
          @Lc_PayHistProfileB_TEXT			CHAR(24) = 'BBBBBBBBBBBBBBBBBBBBBBBB',
          @Lc_Reporter2Address_TEXT         CHAR(32) = 'PO BOX 15012 WILMINGTON DE 19850',
          @Lc_Reporter1Address_TEXT         CHAR(33) = 'DIV. OF CHILD SUPPORT ENFORCEMENT',
          @Ls_Procedure_NAME                VARCHAR(100) = 'BATCH_ENF_OUTGOING_CBR$SP_EXTRACT_CBR',
          @Ls_Process_NAME                  VARCHAR(100) = 'BATCH_ENF_OUTGOING_CBR',
          @Ld_Low_DATE                      DATE = '01/01/0001',
          @Ld_High_DATE                     DATE = '12/31/9999';
  DECLARE @Ln_Zero_NUMB                       NUMERIC(1) = 0,          
          @Ln_CommitFreqParm_QNTY             NUMERIC(5),
          @Ln_ExceptionThresholdParm_QNTY     NUMERIC(5),
          @Ln_CursorCount_NUMB                NUMERIC(9) = 0,
          @Ln_ActiveCaseStatusCount_NUMB      NUMERIC(9) = 0,
          @Ln_CaseAlreadySentStatusCount_NUMB NUMERIC(9) = 0,
          @Ln_CaseClosedStatusCount_NUMB      NUMERIC(9) = 0,
          @Ln_CaseDeleteStatusCount_NUMB      NUMERIC(9) = 0,
          @Ln_PhoneCount_NUMB                 NUMERIC(9) = 0,
          @Ln_TotalRecord_NUMB                NUMERIC(9) = 0,
          @Ln_Error_NUMB                      NUMERIC(10),
          @Ln_ErrorLine_NUMB                  NUMERIC(10),
          @Ln_TransactionEventSeq_NUMB        NUMERIC(19),
          @Lc_Msg_CODE                        CHAR(1),
          @Lc_Referral_CODE                   CHAR(1),
          @Lc_StatusAccount_CODE              CHAR(2),
          @Lc_BateError_CODE                  CHAR(5),
          @Lc_FileTotRecCount_TEXT            CHAR(7),
          @Lc_IdInnovis_TEXT                  CHAR(10),
          @Lc_IdEquifax_TEXT                  CHAR(10),
          @Lc_IdExperian_TEXT                 CHAR(10),
          @Lc_IdTransunion_TEXT               CHAR(10),
          @Ls_File_NAME                       VARCHAR(50),
          @Ls_FileLocation_TEXT               VARCHAR(80),
          @Ls_FileSource_TEXT                 VARCHAR(130),
          @Ls_Sql_TEXT                        VARCHAR(200),
          @Ls_Sqldata_TEXT                    VARCHAR(1000),
          @Ls_BcpCommand_TEXT                 VARCHAR(1000),
          @Ls_ErrorMessage_TEXT               VARCHAR(4000),
          @Ls_DescriptionError_TEXT		      VARCHAR(4000),		
          @Ls_BateRecord_TEXT                 VARCHAR(4000),
          @Ld_Run_DATE                        DATE,
          @Ld_LastRun_DATE                    DATE,
          @Ld_Start_DATE                      DATETIME2(0),
          @Ln_BatchCommonInsertCbor			  int = 0;    
  DECLARE @Lc_CbrCur_MemberMci_IDNO           CHAR(10),
          @Lc_CbrCur_Case_IDNO                CHAR(6),       
          @Lc_CbrCur_StatusAccount_CODE       CHAR(2),
          @Lc_CbrCur_Referral_CODE            CHAR(1),
          @Lc_CbrCur_ReasonExclude_CODE       CHAR(2),
          @Lc_CbrCur_TypeTransCbor_CODE       CHAR(1),
          @Ld_CbrCur_SubmitForm_DATE          DATE,
          @Ld_CbrCur_SubmitLast_DATE          DATE,
          @Lc_CbrCur_Merged_INDC              CHAR(1),
          @Lc_CbrCur_Form_INDC                CHAR(1),
          @Lc_CbrCur_WorkerUpdate_IDNO        CHAR(30),
          @Ln_CbrCur_OrderSeq_NUMB            NUMERIC(5),
          @Ld_CbrCur_BeginValidity_DATE       DATE,
          @Ld_CbrCur_EndValidity_DATE         DATE,
          @Ld_CbrCur_Update_DTTM              DATETIME2(0),
          @Ld_CbrCur_LastDelinquent_DATE      DATE,
          @Lc_CbrCur_LastNcp_NAME             CHAR(20),
          @Lc_CbrCur_FirstNcp_NAME            CHAR(15),
          @Lc_CbrCur_MiNcp_NAME               CHAR(20),
          @Lc_CbrCur_NcpPfSsn_NUMB            CHAR(9),
          @Ld_CbrCur_Birth_DATE               DATE,
          @Lc_CbrCur_County_CODE              CHAR(3),
          @Lc_CbrCur_StatusCase_CODE          CHAR(1),
          @Lc_CbrCur_TypeCase_CODE            CHAR(1),
          @Ld_CbrCur_Opened_DATE              DATE,
          @Ld_CbrCur_Closed_DATE              DATE,
          @Lc_CbrCur_ActivityMinor_CODE       CHAR(5),
          @Lc_CbrCur_ReasonStatus_CODE        CHAR(2),
          @Ln_CbrCur_Arrears_AMNT             NUMERIC(11, 2),
          @Ln_CbrCur_Mso_AMNT                 NUMERIC(11, 2),
          @Lc_CbrCur_ChargingCase_INDC        CHAR(2),
          @Ln_CbrCur_HighestArrear_AMNT       NUMERIC(11, 2),
          @Ls_CbrCur_Line1_ADDR               VARCHAR(50),
          @Ls_CbrCur_Line2_ADDR               VARCHAR(50),
          @Lc_CbrCur_City_ADDR                CHAR(28),
          @Lc_CbrCur_State_ADDR               CHAR(2),
          @Lc_CbrCur_Zip_ADDR                 CHAR(15),
          @Lc_CbrCur_Country_ADDR             CHAR(2),
          @Lc_CbrCur_NcpAddrExist_INDC        CHAR(1),
          @Lc_CbrCur_InfoConsumerAddress_INDC CHAR(1),
          @Lc_CbrCur_Phone_TEXT               CHAR(15),
          @Ld_CbrCur_DistributeLast_DATE      DATE,
          @Ln_CbrCur_Receipt_AMNT             NUMERIC(11, 2),
          @Lc_CbrCur_ExtConsTransType_INDC    CHAR(1),
          @Lc_CbrCur_FreqLeastOble_CODE       CHAR(1);

  BEGIN TRY
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   SET @Lc_BateError_CODE = @Lc_BateErrorE0944_CODE;
   SET @Ls_Sql_TEXT = 'CREATE ##ExtCbr_P1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, @Lc_Space_TEXT);

   CREATE TABLE ##ExtCbr_P1
    (
      Seq_IDNO NUMERIC(6) IDENTITY(1,1),
      Record_TEXT VARCHAR(426)
    );
	   
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS2';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, @Lc_Space_TEXT);

   EXECUTE BATCH_COMMON$SP_GET_BATCH_DETAILS2
    @Ac_Job_ID                  = @Lc_Job_ID,
    @Ad_Run_DATE                = @Ld_Run_DATE OUTPUT,
    @Ad_LastRun_DATE            = @Ld_LastRun_DATE OUTPUT,
    @An_CommitFreq_QNTY         = @Ln_CommitFreqParm_QNTY OUTPUT,
    @An_ExceptionThreshold_QNTY = @Ln_ExceptionThresholdParm_QNTY OUTPUT,
    @As_File_NAME               = @Ls_File_NAME OUTPUT,
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
      
   DECLARE Cbr_CUR INSENSITIVE CURSOR FOR
    SELECT DISTINCT
           r.MemberMci_IDNO,
           r.Case_IDNO,
           r.StatusAccount_CODE,
           r.Referral_CODE,
           r.ReasonExclude_CODE,
           r.TypeTransCbor_CODE,
           r.SubmitForm_DATE,
           r.SubmitLast_DATE,
           r.Merged_INDC,
           r.Form_INDC,
           r.WorkerUpdate_ID,
           r.OrderSeq_NUMB,
           r.BeginValidity_DATE,
           r.EndValidity_DATE,
           r.Update_DTTM,
           @Ld_Run_DATE LastDelinquent_DATE,            
           SUBSTRING(e.LastNcp_NAME, 1, 25) LastNcp_NAME,
           SUBSTRING(e.FirstNcp_NAME, 1, 20) FirstNcp_NAME,
           SUBSTRING(e.MiddleNcp_NAME, 1, 20) MiNcp_NAME,
           e.NcpPfSsn_NUMB NcpPfSsn_NUMB,
           CONVERT(VARCHAR(8), e.BirthNcp_DATE, 112) Birth_DATE,
           e.County_IDNO,
           e.StatusCase_CODE,
           e.TypeCase_CODE,
           (SELECT CONVERT(VARCHAR(8), c.Opened_DATE, 112)
              FROM CASE_Y1 c
             WHERE c.Case_IDNO = e.Case_IDNO) Opened_DATE,
           @Ld_Low_DATE AS Closed_DATE,
           n.ActivityMinor_CODE,
           n.ReasonStatus_CODE,
           (CASE
             WHEN e.Arrears_AMNT < 0
              THEN 0
             ELSE e.Arrears_AMNT
            END) Arrears_AMNT,
           (CASE
             WHEN e.Mso_AMNT < 0
              THEN 0
             ELSE e.Mso_AMNT
            END) Mso_AMNT,
           (CASE
             WHEN e.Mso_AMNT > 0
              THEN @Lc_ChargingCase_TEXT
             ELSE @Lc_Space_TEXT
            END) ChargingCase_INDC,
           (ISNULL(LTRIM(RTRIM(CASE
                                WHEN ISNULL(LTRIM(RTRIM(r.HighestArrear_AMNT)), 0) < e.Arrears_AMNT
                                 THEN e.Arrears_AMNT
                                ELSE r.HighestArrear_AMNT
                               END)), 0)) HighestArrear_AMNT,
           e.Line1Ncp_ADDR Line1_ADDR,
           e.Line2Ncp_ADDR Line2_ADDR,
           e.CityNcp_ADDR City_ADDR,
           e.StateNcp_ADDR State_ADDR,
           e.ZipNcp_ADDR Zip_ADDR,
           e.CountryNcp_ADDR Country_ADDR,
           (CASE
             WHEN e.Line1Ncp_ADDR <> @Lc_Space_TEXT
              THEN @Lc_Yes_INDC
             ELSE @Lc_No_INDC
            END) NcpAddrExist_INDC,
           (CASE
             WHEN e.Line1Ncp_ADDR <> @Lc_Space_TEXT
              THEN @Lc_ConsumerValidAddress_INDC
             ELSE @Lc_ConsumerNoAddress_INDC
            END) InfoConsumerAddress_INDC,
           SUBSTRING(ISNULL(LTRIM(RTRIM(e.PhoneNcp_NUMB)), @Lc_Space_TEXT), 1, 10) Phone_NUMB,
           e.DistributeLast_DATE,
           e.TotToDistributeMtd_AMNT AS Receipt_AMNT,
           (ISNULL((SELECT TOP 1 @Lc_Space_TEXT
                      FROM CBOR_Y1 q
                     WHERE r.Case_IDNO = q.Case_IDNO
                       AND r.MemberMci_IDNO = q.MemberMci_IDNO
                       AND q.Referral_CODE = @Lc_ReferralUpdateSent_TEXT), @Lc_StringOne_TEXT)) ExtConsTransType_INDC,
           e.FreqLeastOble_CODE
      FROM CBOR_Y1 r,
           ENSD_Y1 e,
           DMJR_Y1 j,
           DMNR_Y1 n           
     WHERE e.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
       AND e.NcpPfSsn_NUMB > 0
       AND e.Line1Ncp_ADDR <> @Lc_Space_TEXT
       AND e.StatusCase_CODE = @Lc_CaseStatusOpen_CODE 
       AND e.TypeCase_CODE <> @Lc_TypeCaseNonIVD_CODE 
       AND (e.RespondInit_CODE IN (@Lc_RespondInitNonInterstate_CODE) 
             OR (e.RespondInit_CODE IN (@Lc_RespondingState_CODE, @Lc_RespondingTribal_CODE, @Lc_RespondingInternational_CODE)
                 AND (NOT EXISTS (SELECT 1
                                    FROM CTHB_Y1 c
                                   WHERE c.Case_IDNO = e.Case_IDNO
                                     AND c.Reason_CODE IN (@Lc_FsoByObligee_CODE, @Lc_FsoModObligee_CODE, @Lc_FsoModIvDAgency_CODE)
                                     AND c.End_DATE = @Ld_High_DATE)))) 
       AND j.Case_IDNO = e.Case_IDNO 
       AND j.MemberMci_IDNO = e.NcpPf_IDNO 
       AND j.OrderSeq_NUMB = e.OrderSeq_NUMB 
       AND j.ActivityMajor_CODE = @Lc_ActivityMajorCrpt_CODE 
       AND j.MajorIntSeq_NUMB = (SELECT MAX(MajorIntSeq_NUMB)
                                   FROM DMJR_Y1 p
                                  WHERE p.Case_IDNO = j.Case_IDNO
                                    AND p.MemberMci_IDNO = j.MemberMci_IDNO
                                    AND p.OrderSeq_NUMB = j.OrderSeq_NUMB
                                    AND p.Status_CODE IN (@Lc_StatusStart_CODE, @Lc_StatusComplete_CODE)
									AND p.ActivityMajor_CODE = @Lc_ActivityMajorCrpt_CODE) 
       AND j.Status_CODE IN (@Lc_StatusStart_CODE, @Lc_StatusComplete_CODE)
       AND n.Case_IDNO = e.Case_IDNO 
       AND n.MemberMci_IDNO = e.NcpPf_IDNO 
       AND n.OrderSeq_NUMB = j.OrderSeq_NUMB 
       AND n.MajorIntSEQ_NUMB = j.MajorIntSEQ_NUMB 
       AND n.Status_CODE = @Lc_StatusComplete_CODE  
       AND n.Status_DATE BETWEEN @Ld_LastRun_DATE AND @Ld_Run_DATE        
       AND ((n.ActivityMinor_CODE = @Lc_ActivityMinorRencp_CODE
             AND n.ReasonStatus_CODE = @Lc_ReasonStatusNr_CODE) 
             OR (n.ActivityMinor_CODE = @Lc_ActivityMinorSadmh_CODE
                 AND n.ReasonStatus_CODE = @Lc_ReasonStatusFs_CODE) 
             OR (n.ActivityMinor_CODE = @Lc_ActivityMinorInfff_CODE
                 AND n.ReasonStatus_CODE = @Lc_ReasonStatusFs_CODE) 
             OR (n.ActivityMinor_CODE = @Lc_ActivityMinorRroah_CODE
                 AND n.ReasonStatus_CODE = @Lc_ReasonStatusRi_CODE) 
             OR (n.ActivityMinor_CODE = @Lc_ActivityMinorRroah_CODE
                 AND n.ReasonStatus_CODE = @Lc_ReasonStatusNm_CODE) 
             OR (n.ActivityMinor_CODE = @Lc_ActivityMinorMoncr_CODE
                 AND n.ReasonStatus_CODE = @Lc_ReasonStatusRz_CODE) 
             OR (n.ActivityMinor_CODE = @Lc_ActivityMinorMoncr_CODE
                 AND n.ReasonStatus_CODE = @Lc_ReasonStatusBc_CODE)                 
             OR (n.ActivityMinor_CODE = @Lc_ActivityMinorMoncr_CODE
                 AND n.ReasonStatus_CODE = @Lc_ReasonStatusWp_CODE) 
             OR (n.ActivityMinor_CODE = @Lc_ActivityMinorMoncr_CODE
                 AND n.ReasonStatus_CODE = @Lc_ReasonStatusCy_CODE) 
             OR (n.ActivityMinor_CODE = @Lc_ActivityMinorAcdna_CODE
                 AND n.ReasonStatus_CODE = @Lc_ReasonStatusRw_CODE) 
             OR (n.ActivityMinor_CODE = @Lc_ActivityMinorCafrd_CODE
                 AND n.ReasonStatus_CODE = @Lc_ReasonStatusWp_CODE)         
           )
       AND n.Update_DTTM IN (SELECT MAX(Update_DTTM)
							   FROM DMNR_Y1 x 
							  WHERE x.Case_IDNO = n.Case_IDNO
							    AND x.OrderSeq_NUMB = n.OrderSeq_NUMB   
							    AND x.MajorIntSEQ_NUMB = n.MajorIntSEQ_NUMB
							    AND x.Status_CODE = n.Status_CODE
							    AND x.ActivityMinor_CODE = n.ActivityMinor_CODE)
	   AND n.MinorIntSeq_NUMB = (SELECT MAX(MinorIntSeq_NUMB)
								   FROM DMNR_Y1 d
								  WHERE d.MemberMci_IDNO = n.MemberMci_IDNO
								    AND d.Case_IDNO = n.Case_IDNO
								    AND d.OrderSeq_NUMB = n.OrderSeq_NUMB
								    AND d.MajorIntSEQ_NUMB = n.MajorIntSEQ_NUMB
								    AND d.Status_CODE = n.Status_CODE
								    AND d.Status_DATE = n.Status_DATE
								    AND d.Update_DTTM = n.Update_DTTM
								    AND ((d.ActivityMinor_CODE = @Lc_ActivityMinorRencp_CODE
										   AND d.ReasonStatus_CODE = @Lc_ReasonStatusNr_CODE) 
										  OR (d.ActivityMinor_CODE = @Lc_ActivityMinorSadmh_CODE
											   AND d.ReasonStatus_CODE = @Lc_ReasonStatusFs_CODE) 
										  OR (d.ActivityMinor_CODE = @Lc_ActivityMinorInfff_CODE
											   AND d.ReasonStatus_CODE = @Lc_ReasonStatusFs_CODE) 
										  OR (d.ActivityMinor_CODE = @Lc_ActivityMinorRroah_CODE
											   AND d.ReasonStatus_CODE = @Lc_ReasonStatusRi_CODE) 
										  OR (d.ActivityMinor_CODE = @Lc_ActivityMinorRroah_CODE
											   AND d.ReasonStatus_CODE = @Lc_ReasonStatusNm_CODE) 
										  OR (d.ActivityMinor_CODE = @Lc_ActivityMinorMoncr_CODE
											   AND d.ReasonStatus_CODE = @Lc_ReasonStatusRz_CODE) 
										  OR (d.ActivityMinor_CODE = @Lc_ActivityMinorMoncr_CODE
											   AND d.ReasonStatus_CODE = @Lc_ReasonStatusBc_CODE) 
										  OR (d.ActivityMinor_CODE = @Lc_ActivityMinorMoncr_CODE
											   AND d.ReasonStatus_CODE = @Lc_ReasonStatusWp_CODE) 
										  OR (d.ActivityMinor_CODE = @Lc_ActivityMinorMoncr_CODE
											   AND d.ReasonStatus_CODE = @Lc_ReasonStatusCy_CODE) 
										  OR (d.ActivityMinor_CODE = @Lc_ActivityMinorAcdna_CODE
											   AND d.ReasonStatus_CODE = @Lc_ReasonStatusRw_CODE) 
										  OR (d.ActivityMinor_CODE = @Lc_ActivityMinorCafrd_CODE
											   AND d.ReasonStatus_CODE = @Lc_ReasonStatusWp_CODE)         
									    ))
       AND r.MemberMci_IDNO = e.NcpPf_IDNO
       AND r.Case_IDNO = e.Case_IDNO
       AND r.EndValidity_DATE = @Ld_High_DATE       
     ORDER BY r.MemberMci_IDNO,
              r.Case_IDNO ASC
     OPTION (RECOMPILE);
      
   SET @Ls_Sql_TEXT = 'FILE LOCATION AND NAME VALIDATION';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, @Lc_Space_TEXT);   
   SET @Ls_FileSource_TEXT = ISNULL(LTRIM (RTRIM (@Ls_FileLocation_TEXT)) + LTRIM (RTRIM (@Ls_File_NAME)), @Lc_Space_TEXT);

   IF @Ls_FileSource_TEXT = @Lc_Space_TEXT
    BEGIN
     SET @Ls_DescriptionError_TEXT = 'INVALID FILE NAME AND FILE LOCATION';

     RAISERROR (50001,16,1);
    END;

   BEGIN TRANSACTION CBR_EXTRACT_FILE;

   SET @Ls_Sql_TEXT = 'DELETE ECBTW_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   DELETE FROM ECBTW_Y1;
      
   SET @Ls_Sql_TEXT='INSERT HEADER';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, @Lc_Space_TEXT);
   SET @Lc_IdInnovis_TEXT = (SELECT CASE
                                     WHEN z.DescriptionValue_TEXT = @Lc_NotUsed_TEXT
                                      THEN @Lc_Space_TEXT
                                     ELSE z.DescriptionValue_TEXT
                                    END
                               FROM REFM_Y1 z
                              WHERE z.Table_ID = @Lc_TableIdCrdt_CODE
                                AND TableSub_ID = @Lc_TableSubIdAcno_CODE
                                AND Value_CODE = @Lc_ValueInvs_CODE);
   SET @Lc_IdEquifax_TEXT = (SELECT CASE
                                     WHEN z.DescriptionValue_TEXT = @Lc_NotUsed_TEXT
                                      THEN @Lc_Space_TEXT
                                     ELSE z.DescriptionValue_TEXT
                                    END
                               FROM REFM_Y1 z
                              WHERE z.Table_ID = @Lc_TableIdCrdt_CODE
                                AND TableSub_ID = @Lc_TableSubIdAcno_CODE
                                AND Value_CODE = @Lc_ValueEqfx_CODE);
   SET @Lc_IdExperian_TEXT = (SELECT CASE
                                      WHEN z.DescriptionValue_TEXT = @Lc_NotUsed_TEXT
                                       THEN @Lc_Space_TEXT
                                      ELSE z.DescriptionValue_TEXT
                                     END
                                FROM REFM_Y1 z
                               WHERE z.Table_ID = @Lc_TableIdCrdt_CODE
                                 AND TableSub_ID = @Lc_TableSubIdAcno_CODE
                                 AND Value_CODE = @Lc_ValueExpr_CODE);
   SET @Lc_IdTransunion_TEXT = (SELECT CASE
                                        WHEN z.DescriptionValue_TEXT = @Lc_NotUsed_TEXT
                                         THEN @Lc_Space_TEXT
                                        ELSE z.DescriptionValue_TEXT
                                       END
                                  FROM REFM_Y1 z
                                 WHERE z.Table_ID = @Lc_TableIdCrdt_CODE
                                   AND TableSub_ID = @Lc_TableSubIdAcno_CODE
                                   AND Value_CODE = @Lc_ValueTrun_CODE);
   INSERT INTO ##ExtCbr_P1
               (Record_TEXT)
        VALUES ( @Lc_RecordDescriptorWord_TEXT + LEFT((LTRIM(RTRIM(@Lc_Header_TEXT)) + REPLICATE(@Lc_Space_TEXT, 6)), 6) + RIGHT((REPLICATE(@Lc_StringZero_TEXT, 2) + LTRIM(RTRIM(@Lc_CycleNumber_TEXT))), 2) + LEFT((LTRIM(RTRIM(@Lc_IdInnovis_TEXT)) + REPLICATE(@Lc_Space_TEXT, 10)), 10) + LEFT((LTRIM(RTRIM(@Lc_IdEquifax_TEXT)) + REPLICATE(@Lc_Space_TEXT, 10)), 10) + LEFT((LTRIM(RTRIM(@Lc_IdExperian_TEXT)) + REPLICATE(@Lc_Space_TEXT, 5)), 5) + LEFT((LTRIM(RTRIM(@Lc_IdTransunion_TEXT)) + REPLICATE(@Lc_Space_TEXT, 10)), 10) + LEFT((REPLACE(CONVERT(VARCHAR(10), @Ld_Run_DATE, 101), '/', '') + REPLICATE(@Lc_Space_TEXT, 8)), 8) + LEFT((REPLACE(CONVERT(VARCHAR(10), @Ld_Run_DATE, 101), '/', '') + REPLICATE(@Lc_Space_TEXT, 8)), 8) + LEFT((LTRIM(RTRIM(@Lc_Space_TEXT)) + REPLICATE(@Lc_Space_TEXT, 8)), 8) + LEFT((LTRIM(RTRIM(@Lc_Space_TEXT)) + REPLICATE(@Lc_Space_TEXT, 8)), 8) + LEFT((LTRIM(RTRIM(@Lc_ReporterName_TEXT)) + REPLICATE(@Lc_Space_TEXT, 40)), 40) + LEFT((LTRIM(RTRIM(@Lc_ReporterAddress_TEXT)) + REPLICATE(@Lc_Space_TEXT, 31)), 31) + LEFT((LTRIM(RTRIM(@Lc_Reporter1Address_TEXT)) + REPLICATE(@Lc_Space_TEXT, 33)), 33) + LEFT((LTRIM(RTRIM(@Lc_Reporter2Address_TEXT)) + REPLICATE(@Lc_Space_TEXT, 32)), 32) + RIGHT((REPLICATE(@Lc_StringZero_TEXT, 10) + LTRIM(RTRIM(@Lc_ReporterPhoneNo_TEXT))), 10) + LEFT((LTRIM(RTRIM(@Lc_Space_TEXT)) + REPLICATE(@Lc_Space_TEXT, 40)), 40) + LEFT((LTRIM(RTRIM(@Lc_Space_TEXT)) + REPLICATE(@Lc_Space_TEXT, 5)), 5) + REPLICATE(@Lc_Space_TEXT, 156)); --Record_TEXT

   SET @Ls_Sql_TEXT = 'PROCEDURE SP_GENERATE_SEQ_TXN_EVENT';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, @Lc_Space_TEXT);
   
   EXECUTE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
    @Ac_Worker_ID                = @Lc_BatchRunUser_TEXT,
    @Ac_Process_ID               = @Lc_Job_ID,
    @Ad_EffectiveEvent_DATE      = @Ld_Run_DATE,
    @Ac_Note_INDC                = @Lc_Note_INDC,
    @An_EventFunctionalSeq_NUMB  = @Lc_StringZero_TEXT,
    @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
    @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR(50001,16,1);
    END
      
   SET @Ls_Sql_TEXT = 'OPEN Cbr_CUR';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, @Lc_Space_TEXT);
      
   OPEN Cbr_CUR;
 
   SET @Ls_Sql_TEXT = 'FETCH Cbr_CUR - 1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, @Lc_Space_TEXT);
     
   FETCH NEXT FROM Cbr_CUR INTO @Lc_CbrCur_MemberMci_IDNO, @Lc_CbrCur_Case_IDNO, @Lc_CbrCur_StatusAccount_CODE, @Lc_CbrCur_Referral_CODE, @Lc_CbrCur_ReasonExclude_CODE, @Lc_CbrCur_TypeTransCbor_CODE, @Ld_CbrCur_SubmitForm_DATE, @Ld_CbrCur_SubmitLast_DATE, @Lc_CbrCur_Merged_INDC, @Lc_CbrCur_Form_INDC, @Lc_CbrCur_WorkerUpdate_IDNO, @Ln_CbrCur_OrderSeq_NUMB, @Ld_CbrCur_BeginValidity_DATE, @Ld_CbrCur_EndValidity_DATE, @Ld_CbrCur_Update_DTTM, @Ld_CbrCur_LastDelinquent_DATE, @Lc_CbrCur_LastNcp_NAME, @Lc_CbrCur_FirstNcp_NAME, @Lc_CbrCur_MiNcp_NAME, @Lc_CbrCur_NcpPfSsn_NUMB, @Ld_CbrCur_Birth_DATE, @Lc_CbrCur_County_CODE, @Lc_CbrCur_StatusCase_CODE, @Lc_CbrCur_TypeCase_CODE, @Ld_CbrCur_Opened_DATE, @Ld_CbrCur_Closed_DATE, @Lc_CbrCur_ActivityMinor_CODE, @Lc_CbrCur_ReasonStatus_CODE, @Ln_CbrCur_Arrears_AMNT, @Ln_CbrCur_Mso_AMNT, @Lc_CbrCur_ChargingCase_INDC, @Ln_CbrCur_HighestArrear_AMNT, @Ls_CbrCur_Line1_ADDR, @Ls_CbrCur_Line2_ADDR, @Lc_CbrCur_City_ADDR, @Lc_CbrCur_State_ADDR, @Lc_CbrCur_Zip_ADDR, @Lc_CbrCur_Country_ADDR, @Lc_CbrCur_NcpAddrExist_INDC, @Lc_CbrCur_InfoConsumerAddress_INDC, @Lc_CbrCur_Phone_TEXT, @Ld_CbrCur_DistributeLast_DATE, @Ln_CbrCur_Receipt_AMNT, @Lc_CbrCur_ExtConsTransType_INDC, @Lc_CbrCur_FreqLeastOble_CODE;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;

   -- Iterate through each record and update the StatusAccount_CODE and Referral_CODE
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
     SET @Ln_TotalRecord_NUMB = @Ln_TotalRecord_NUMB + 1;
     SET @Lc_StatusAccount_CODE = @Lc_Space_TEXT;
     SET @Ls_Sql_TEXT = 'GET STATUS ACCOUNT';
     SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + @Lc_CbrCur_Case_IDNO + ', MemberMci_IDNO = ' + @Lc_CbrCur_MemberMci_IDNO + ', ActivityMinor_CODE = ' + @Lc_CbrCur_ActivityMinor_CODE + ', ReasonStatus_CODE = ' + @Lc_CbrCur_ReasonStatus_CODE;

     IF ((@Lc_CbrCur_ActivityMinor_CODE = @Lc_ActivityMinorRencp_CODE
          AND @Lc_CbrCur_ReasonStatus_CODE = @Lc_ReasonStatusNr_CODE
          AND @Ln_CbrCur_Arrears_AMNT >= 1000										                      
         )
          OR (@Lc_CbrCur_ActivityMinor_CODE = @Lc_ActivityMinorSadmh_CODE
              AND @Lc_CbrCur_ReasonStatus_CODE = @Lc_ReasonStatusFs_CODE)
          OR (@Lc_CbrCur_ActivityMinor_CODE = @Lc_ActivityMinorInfff_CODE
              AND @Lc_CbrCur_ReasonStatus_CODE = @Lc_ReasonStatusFs_CODE)
          OR (@Lc_CbrCur_ActivityMinor_CODE = @Lc_ActivityMinorRroah_CODE
              AND @Lc_CbrCur_ReasonStatus_CODE = @Lc_ReasonStatusNm_CODE)
          OR (@Lc_CbrCur_ActivityMinor_CODE = @Lc_ActivityMinorMoncr_CODE
              AND @Lc_CbrCur_ReasonStatus_CODE = @Lc_ReasonStatusBc_CODE)        
        )
      BEGIN
       SET @Lc_StatusAccount_CODE = @Lc_ActiveCase_TEXT; 
       SET @Ln_ActiveCaseStatusCount_NUMB = @Ln_ActiveCaseStatusCount_NUMB + 1;
      END
     ELSE IF(@Lc_CbrCur_ActivityMinor_CODE = @Lc_ActivityMinorMoncr_CODE
        AND @Lc_CbrCur_ReasonStatus_CODE = @Lc_ReasonStatusCy_CODE)
      BEGIN
       SET @Lc_StatusAccount_CODE = @Lc_CaseClosed_TEXT; 
       SET @Ln_CaseClosedStatusCount_NUMB = @Ln_CaseClosedStatusCount_NUMB + 1;
      END
     ELSE IF ((@Lc_CbrCur_ActivityMinor_CODE = @Lc_ActivityMinorRroah_CODE
          AND @Lc_CbrCur_ReasonStatus_CODE = @Lc_ReasonStatusRi_CODE)
          OR (@Lc_CbrCur_ActivityMinor_CODE = @Lc_ActivityMinorMoncr_CODE
              AND @Lc_CbrCur_ReasonStatus_CODE = @Lc_ReasonStatusRz_CODE)
          OR (@Lc_CbrCur_ActivityMinor_CODE = @Lc_ActivityMinorAcdna_CODE
              AND @Lc_CbrCur_ReasonStatus_CODE = @Lc_ReasonStatusRw_CODE))
      BEGIN
       SET @Lc_StatusAccount_CODE = @Lc_CaseAlreadySent_TEXT; 
       SET @Ln_CaseAlreadySentStatusCount_NUMB = @Ln_CaseAlreadySentStatusCount_NUMB + 1;
      END
     ELSE IF ((@Lc_CbrCur_ActivityMinor_CODE = @Lc_ActivityMinorMoncr_CODE
          AND @Lc_CbrCur_ReasonStatus_CODE = @Lc_ReasonStatusWp_CODE)
          OR (@Lc_CbrCur_ActivityMinor_CODE = @Lc_ActivityMinorCafrd_CODE
              AND @Lc_CbrCur_ReasonStatus_CODE = @Lc_ReasonStatusWp_CODE))
      BEGIN
       SET @Lc_StatusAccount_CODE = @Lc_CaseDelete_TEXT; 
       SET @Ln_CaseDeleteStatusCount_NUMB = @Ln_CaseDeleteStatusCount_NUMB + 1;
      END

     SET @Ls_Sql_TEXT = 'REFERING THE MEMBER TO CREDIT BUREAU';
     SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + @Lc_CbrCur_Case_IDNO + ', MemberMci_IDNO = ' + @Lc_CbrCur_MemberMci_IDNO + ', ActivityMinor_CODE = ' + @Lc_CbrCur_ActivityMinor_CODE + ', StatusAccount_CODE = ' + @Lc_StatusAccount_CODE;
    
     IF LTRIM(RTRIM(@Lc_StatusAccount_CODE)) IS NOT NULL
      BEGIN
       SET @Ln_CursorCount_NUMB = @Ln_CursorCount_NUMB + 1;

       IF (@Lc_CbrCur_StatusAccount_CODE = @Lc_Space_TEXT
           AND @Lc_CbrCur_Referral_CODE = @Lc_ReferralFirstTime_CODE)
        BEGIN
         SET @Lc_Referral_CODE = @Lc_ReferralFirstTime_CODE;
        END
       ELSE IF @Lc_StatusAccount_CODE = @Lc_ActiveCase_TEXT
        BEGIN
         SET @Lc_Referral_CODE = @Lc_ReferralUpdateSent_CODE;
        END
       ELSE IF @Lc_StatusAccount_CODE = @Lc_CaseDelete_TEXT
        BEGIN
         SET @Lc_Referral_CODE = @Lc_ReferralDelete_CODE;
        END
       ELSE IF @Lc_StatusAccount_CODE IN (@Lc_CaseClosed_TEXT, @Lc_CaseAlreadySent_TEXT)
        BEGIN
         SET @Lc_Referral_CODE = @Lc_ReferralNotExclude_CODE;
        END

       SET @Ls_Sql_TEXT = 'INSERT THE RECORD IN VCBOR TO SEND STATUS';
       SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + @Lc_CbrCur_Case_IDNO + ', MemberMci_IDNO = ' + @Lc_CbrCur_MemberMci_IDNO + ', OrderSeq_NUMB = ' + CAST(@Ln_CbrCur_OrderSeq_NUMB AS VARCHAR) + ', StatusAccount_CODE = ' + @Lc_StatusAccount_CODE + ', @Lc_Referral_CODE = ' + @Lc_Referral_CODE;
       
       IF NOT EXISTS (SELECT 1
						FROM CBOR_Y1 c
					   WHERE c.MemberMci_IDNO = @Lc_CbrCur_MemberMci_IDNO
	                     AND c.Case_IDNO = @Lc_CbrCur_Case_IDNO
	                     AND c.OrderSeq_NUMB = @Ln_CbrCur_OrderSeq_NUMB
	                     AND c.TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB
	                     AND c.Referral_CODE = @Lc_Referral_CODE
		                 AND c.Update_DTTM = @Ld_Run_DATE)
	    BEGIN
	       SET @Ln_BatchCommonInsertCbor = @Ln_BatchCommonInsertCbor + 1;
	    		  
		   EXECUTE BATCH_COMMON$SP_INSERT_CBOR
			@An_MemberMci_IDNO           = @Lc_CbrCur_MemberMci_IDNO,
			@An_Case_IDNO                = @Lc_CbrCur_Case_IDNO,
			@An_OrderSeq_NUMB            = @Ln_CbrCur_OrderSeq_NUMB,
			@Ac_StatusAccount_CODE       = @Lc_StatusAccount_CODE,
			@Ac_Referral_CODE            = @Lc_Referral_CODE,
			@Ac_ReasonExclude_CODE       = @Lc_CbrCur_ReasonExclude_CODE,
			@Ac_TypeTransCbor_CODE       = @Lc_CbrCur_TypeTransCbor_CODE,
			@An_SupObligationMm_AMNT     = @Ln_CbrCur_Mso_AMNT,
			@An_Arrear_AMNT              = @Ln_CbrCur_Arrears_AMNT,
			@Ad_SubmitForm_DATE          = @Ld_CbrCur_SubmitForm_DATE,
			@Ad_PaymentLast_DATE         = @Ld_CbrCur_DistributeLast_DATE,
			@Ad_SubmitLast_DATE          = @Ld_CbrCur_SubmitLast_DATE,
			@Ac_Merged_INDC              = @Lc_CbrCur_Merged_INDC,
			@Ac_Form_INDC                = @Lc_CbrCur_Form_INDC,
			@An_HighestArrear_AMNT       = @Ln_CbrCur_HighestArrear_AMNT,
			@Ad_LastDelinquent_DATE      = @Ld_CbrCur_LastDelinquent_DATE,
			@Ad_BeginValidity_DATE       = @Ld_Run_DATE,
			@Ad_EndValidity_DATE         = @Ld_High_DATE,
			@An_WorkerUpdate_ID          = @Lc_BatchRunUser_TEXT,
			@Ad_Update_DTTM              = @Ld_Run_DATE,
			@An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
			@Ad_Run_DATE                 = @Ld_Run_DATE,
			@Ac_Support_INDC             = @Lc_CbrSupportProcess_INDC,
			@Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
			@As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;
		END;
     
       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN         
         RAISERROR(50001,16,1);
        END

       IF @Lc_CbrCur_Phone_TEXT <> @Lc_Space_TEXT
        BEGIN
         SET @Ln_PhoneCount_NUMB = @Ln_PhoneCount_NUMB + 1;
        END
              
       SET @Ls_Sql_TEXT = 'INSERT INTO ECBTW_Y1';
       SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, @Lc_Space_TEXT);       
       
       INSERT INTO ECBTW_Y1
                   (Rec_ID,
                    Process_INDC,
                    Batch_DTTM,
                    Correction_INDC,
                    Identify_NUMB,
                    Cycle_IDNO,
                    Case_IDNO,
                    TypePortfolio_INDC,
                    TypeAcct_CODE,
                    Opened_DATE,
                    CreditLimit_AMNT,
                    HighCredit_AMNT,
                    TermDuration_CODE,
                    TermFreq_CODE,
                    Monthly_AMNT,
                    Actual_AMNT,
                    StatusAccount_CODE,
                    PayRating_CODE,
                    PayHistProfile_TEXT,
                    SpecialComment_CODE,
                    Compliance_CODE,
                    CurrentBalance_AMNT,
                    PastDue_AMNT,
                    OrigCharge_AMNT,
                    Billing_DATE,
                    FirstDelinquent_DATE,
                    Closed_DATE,
                    LastPayment_DATE,
                    DescriptionReserved_TEXT,
                    ConsTransType_CODE,
                    Last_NAME,
                    First_NAME,
                    Middle_NAME,
                    Generation_CODE,
                    MemberSsn_NUMB,
                    Birth_DATE,
                    Phone_NUMB,
                    Ecoa_CODE,
                    ConsumerInfo_CODE,
                    Country_CODE,
                    Line1_ADDR,
                    Line2_ADDR,
                    City_ADDR,
                    State_ADDR,
                    Zip_ADDR,
                    Confirm_CODE,
                    Residence_CODE)
            VALUES ( @Lc_RecordDescriptorWord_TEXT,-- Rec_ID
                     @Lc_StringOne_TEXT,-- Process_INDC
                     REPLACE(CONVERT(VARCHAR(10), @Ld_Start_DATE, 110), '-','') + REPLACE(CONVERT(VARCHAR(8), @Ld_Start_DATE, 114), ':', ''),-- Batch_DTTM
                     @Lc_StringZero_TEXT,-- Correction_INDC
                     @Lc_Identify_NUMB,-- Identify_NUMB
                     @Lc_Space_TEXT,-- Cycle_IDNO
                     @Lc_CbrCur_Case_IDNO,-- Case_IDNO
                     @Lc_TypePortfolioO_INDC,-- TypePortfolio_INDC
                     @Lc_ChildSupport_TEXT,-- TypeAcct_CODE
                     ISNULL(REPLACE(CONVERT(VARCHAR(10), @Ld_CbrCur_Opened_DATE, 110), '-',''), @Lc_LowdateMMDDYYYY00000000_CODE), -- Opened_DATE                     
                     @Lc_StringZero_TEXT,-- CreditLimit_AMNT
                     REPLACE(CAST(ROUND(@Ln_CbrCur_HighestArrear_AMNT, 0) AS VARCHAR(9)),'.00',''),-- HighCredit_AMNT                     
                     @Lc_Term_TEXT,-- TermDuration_CODE
                     @Lc_CbrCur_FreqLeastOble_CODE,-- TermFreq_CODE                     
                     REPLACE(CAST(ROUND(@Ln_CbrCur_Mso_AMNT, 0) AS VARCHAR(9)),'.00',''),-- Monthly_AMNT
                     REPLACE(CAST(ROUND(@Ln_CbrCur_Receipt_AMNT, 0) AS VARCHAR(9)),'.00',''),-- Actual_AMNT                     
                     @Lc_StatusAccount_CODE,-- StatusAccount_CODE
                     @Lc_Space_TEXT,-- PayRating_CODE
                     @Lc_PayHistProfileB_TEXT,-- PayHistProfile_TEXT
                     (CASE
                       WHEN @Lc_StatusAccount_CODE = @Lc_ActiveCase_TEXT
                        THEN @Lc_CbrCur_ChargingCase_INDC
                       ELSE @Lc_Space_TEXT
                      END),-- SpecialComment_CODE
                     @Lc_Space_TEXT,-- Compliance_CODE                     
                     REPLACE(CAST(ROUND(@Ln_CbrCur_Arrears_AMNT, 0) AS VARCHAR(9)),'.00',''),-- CurrentBalance_AMNT
                     REPLACE(CAST(ROUND(@Ln_CbrCur_Arrears_AMNT, 0) AS VARCHAR(9)),'.00',''),-- PastDue_AMNT 
                     @Lc_StringZero_TEXT,-- OrigCharge_AMNT     
                     REPLACE(CONVERT(VARCHAR(10), @Ld_Run_DATE, 110), '-',''),-- Billing_DATE 
                     REPLACE(CONVERT(VARCHAR(10), @Ld_CbrCur_LastDelinquent_DATE, 110), '-',''),-- FirstDelinquent_DATE 
                     (CASE
                       WHEN @Lc_StatusAccount_CODE = @Lc_CaseClosed_TEXT
                        THEN REPLACE(CONVERT(VARCHAR(10), @Ld_Run_DATE, 110), '-','')
                       ELSE @Lc_LowdateMMDDYYYY00000000_CODE
                      END),-- Closed_DATE
                     (CASE
                       WHEN CONVERT(VARCHAR(8), @Ld_CbrCur_DistributeLast_DATE, 112) = CONVERT(VARCHAR(8), @Ld_Low_DATE, 112)
                        THEN @Lc_LowdateMmddyyyy00000000_CODE
                       ELSE REPLACE(CONVERT(VARCHAR(10), @Ld_CbrCur_DistributeLast_DATE, 110), '-','')
                      END),-- LastPayment_DATE
                     @Lc_Space_TEXT,-- DescriptionReserved_TEXT
                     @Lc_CbrCur_ExtConsTransType_INDC,-- ConsTransType_CODE
                     @Lc_CbrCur_LastNcp_NAME,-- Last_NAME
                     @Lc_CbrCur_FirstNcp_NAME,-- First_NAME
                     @Lc_CbrCur_MiNcp_NAME,-- Middle_NAME
                     @Lc_Space_TEXT,-- Generation_CODE
                     RIGHT((REPLICATE(@Lc_StringZero_TEXT, 9) + LTRIM(RTRIM(@Lc_CbrCur_NcpPfSsn_NUMB))), 9), -- MemberSsn_NUMB
                     CASE 
                      WHEN REPLACE(CONVERT(VARCHAR(10), @Ld_CbrCur_Birth_DATE, 110), '-','') IN ('01010001', '12319999')
                       THEN @Lc_LowdateMMDDYYYY00000000_CODE
                      ELSE REPLACE(CONVERT(VARCHAR(10), @Ld_CbrCur_Birth_DATE, 110), '-','')
                     END,-- Birth_DATE
                     @Lc_CbrCur_Phone_TEXT,-- Phone_NUMB
                     @Lc_StringOne_TEXT,-- Ecoa_CODE
                     @Lc_CbrCur_InfoConsumerAddress_INDC,-- ConsumerInfo_CODE
                     SUBSTRING(@Lc_CbrCur_Country_ADDR, 1, 2),-- Country_CODE
                     SUBSTRING(@Ls_CbrCur_Line1_ADDR, 1, 32),-- Line1_ADDR
                     SUBSTRING(@Ls_CbrCur_Line2_ADDR, 1, 32),-- Line2_ADDR
                     SUBSTRING(@Lc_CbrCur_City_ADDR, 1, 20),-- City_ADDR
                     SUBSTRING(@Lc_CbrCur_State_ADDR, 1, 2),-- State_ADDR
                     SUBSTRING(@Lc_CbrCur_Zip_ADDR, 1, 9),-- Zip_ADDR
                     @Lc_CbrCur_NcpAddrExist_INDC,-- Confirm_CODE
                     @Lc_Space_TEXT ); -- Residence_CODE 				
      END
          
     SET @Ls_Sql_TEXT = 'FETCH Cbr_CUR - 2';
     SET @Ls_Sqldata_TEXT = 'Cursor Previous Record = ' + SUBSTRING(@Ls_BateRecord_TEXT,1,970);

     FETCH NEXT FROM Cbr_CUR INTO @Lc_CbrCur_MemberMci_IDNO, @Lc_CbrCur_Case_IDNO, @Lc_CbrCur_StatusAccount_CODE, @Lc_CbrCur_Referral_CODE, @Lc_CbrCur_ReasonExclude_CODE, @Lc_CbrCur_TypeTransCbor_CODE, @Ld_CbrCur_SubmitForm_DATE, @Ld_CbrCur_SubmitLast_DATE, @Lc_CbrCur_Merged_INDC, @Lc_CbrCur_Form_INDC, @Lc_CbrCur_WorkerUpdate_IDNO, @Ln_CbrCur_OrderSeq_NUMB, @Ld_CbrCur_BeginValidity_DATE, @Ld_CbrCur_EndValidity_DATE, @Ld_CbrCur_Update_DTTM, @Ld_CbrCur_LastDelinquent_DATE, @Lc_CbrCur_LastNcp_NAME, @Lc_CbrCur_FirstNcp_NAME, @Lc_CbrCur_MiNcp_NAME, @Lc_CbrCur_NcpPfSsn_NUMB, @Ld_CbrCur_Birth_DATE, @Lc_CbrCur_County_CODE, @Lc_CbrCur_StatusCase_CODE, @Lc_CbrCur_TypeCase_CODE, @Ld_CbrCur_Opened_DATE, @Ld_CbrCur_Closed_DATE, @Lc_CbrCur_ActivityMinor_CODE, @Lc_CbrCur_ReasonStatus_CODE, @Ln_CbrCur_Arrears_AMNT, @Ln_CbrCur_Mso_AMNT, @Lc_CbrCur_ChargingCase_INDC, @Ln_CbrCur_HighestArrear_AMNT, @Ls_CbrCur_Line1_ADDR, @Ls_CbrCur_Line2_ADDR, @Lc_CbrCur_City_ADDR, @Lc_CbrCur_State_ADDR, @Lc_CbrCur_Zip_ADDR, @Lc_CbrCur_Country_ADDR, @Lc_CbrCur_NcpAddrExist_INDC, @Lc_CbrCur_InfoConsumerAddress_INDC, @Lc_CbrCur_Phone_TEXT, @Ld_CbrCur_DistributeLast_DATE, @Ln_CbrCur_Receipt_AMNT, @Lc_CbrCur_ExtConsTransType_INDC, @Lc_CbrCur_FreqLeastOble_CODE;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
     
    END

   CLOSE Cbr_CUR;
   
   DEALLOCATE Cbr_CUR;

   IF(@Ln_TotalRecord_NUMB = 0)    
	BEGIN
	 SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG';     
     SET @Ls_SqlData_TEXT = 'Process_NAME = ' + @Ls_Process_NAME + ', Procedure_NAME = ' + @Ls_Procedure_NAME + ', Job_ID = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', TypeError_CODE = ' + @Lc_TypeWarning_CODE + ', Line_NUMB = ' + CAST(@Ln_Zero_NUMB AS VARCHAR)+ ', Error_CODE = ' + @Lc_BateError_CODE + ', DescriptionError_TEXT = ' + @Ls_DescriptionError_TEXT + ', ListKey_TEXT = ' + @Ls_SqlData_TEXT;

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
	   
   SET @Ls_Sql_TEXT = 'INSERT ##ExtCbr_P1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, @Lc_Space_TEXT);

   INSERT INTO ##ExtCbr_P1
               (Record_TEXT)
   SELECT (RIGHT((REPLICATE(@Lc_StringZero_TEXT, 4) + LTRIM(RTRIM(a.Rec_ID))), 4) + LEFT((LTRIM(RTRIM(a.Process_INDC)) + REPLICATE(@Lc_Space_TEXT, 1)), 1) + LEFT((LTRIM(RTRIM(a.Batch_DTTM)) + REPLICATE(@Lc_Space_TEXT, 14)), 14) + LEFT((LTRIM(RTRIM(a.Correction_INDC)) + REPLICATE(@Lc_Space_TEXT, 1)), 1) + LEFT((LTRIM(RTRIM(a.Identify_NUMB)) + REPLICATE(@Lc_Space_TEXT, 20)), 20) + LEFT ((LTRIM(RTRIM(a.Cycle_IDNO)) + REPLICATE(@Lc_Space_TEXT, 2)), 2) + LEFT((LTRIM(RTRIM(a.Case_IDNO)) + REPLICATE(@Lc_Space_TEXT, 30)), 30) + LEFT((LTRIM(RTRIM(a.TypePortfolio_INDC)) + REPLICATE(@Lc_Space_TEXT, 1)), 1) + LEFT((LTRIM(RTRIM(a.TypeAcct_CODE)) + REPLICATE(@Lc_Space_TEXT, 2)), 2) + LEFT((LTRIM(RTRIM(a.Opened_DATE)) + REPLICATE(@Lc_Space_TEXT, 8)), 8) + RIGHT((REPLICATE(@Lc_StringZero_TEXT, 9) + LTRIM(RTRIM(a.CreditLimit_AMNT))), 9) + RIGHT((REPLICATE(@Lc_StringZero_TEXT, 9) + LTRIM(RTRIM(a.HighCredit_AMNT))), 9) + LEFT((LTRIM(RTRIM(a.TermDuration_CODE)) + REPLICATE(@Lc_Space_TEXT, 3)), 3) + LEFT((LTRIM(RTRIM(a.TermFreq_CODE)) + REPLICATE(@Lc_Space_TEXT, 1)), 1) + RIGHT((REPLICATE(@Lc_StringZero_TEXT, 9) + LTRIM(RTRIM(a.Monthly_AMNT))), 9) + RIGHT((REPLICATE(@Lc_StringZero_TEXT, 9) + LTRIM(RTRIM(a.Actual_AMNT))), 9) + LEFT((LTRIM(RTRIM(a.StatusAccount_CODE)) + REPLICATE(@Lc_Space_TEXT, 2)), 2) + LEFT((LTRIM(RTRIM(a.PayRating_CODE)) + REPLICATE(@Lc_Space_TEXT, 1)), 1) + LEFT((LTRIM(RTRIM(a.PayHistProfile_TEXT)) + REPLICATE(@Lc_Space_TEXT, 24)), 24) + LEFT((LTRIM(RTRIM(a.SpecialComment_CODE)) + REPLICATE(@Lc_Space_TEXT, 2)), 2) + LEFT((LTRIM(RTRIM(a.Compliance_CODE)) + REPLICATE(@Lc_Space_TEXT, 2)), 2) + RIGHT((REPLICATE(@Lc_StringZero_TEXT, 9) + LTRIM(RTRIM(a.CurrentBalance_AMNT))), 9) + RIGHT((REPLICATE(@Lc_StringZero_TEXT, 9) + LTRIM(RTRIM(a.PastDue_AMNT))), 9) + RIGHT((REPLICATE(@Lc_StringZero_TEXT, 9) + LTRIM(RTRIM(a.OrigCharge_AMNT))), 9) + LEFT((LTRIM(RTRIM(a.Billing_DATE)) + REPLICATE(@Lc_Space_TEXT, 8)), 8) + LEFT((LTRIM(RTRIM(a.FirstDelinquent_DATE)) + REPLICATE(@Lc_Space_TEXT, 8)), 8) + LEFT((LTRIM(RTRIM(a.Closed_DATE)) + REPLICATE(@Lc_Space_TEXT, 8)), 8) + LEFT((LTRIM(RTRIM(a.LastPayment_DATE)) + REPLICATE(@Lc_Space_TEXT, 8)), 8) + LEFT((LTRIM(RTRIM(a.DescriptionReserved_TEXT)) + REPLICATE(@Lc_Space_TEXT, 17)), 17) + LEFT((LTRIM(RTRIM(a.ConsTransType_CODE)) + REPLICATE(@Lc_Space_TEXT, 1)), 1) + LEFT((LTRIM(RTRIM(a.Last_NAME)) + REPLICATE(@Lc_Space_TEXT, 25)), 25) + LEFT((LTRIM(RTRIM(a.First_NAME)) + REPLICATE(@Lc_Space_TEXT, 20)), 20) + LEFT((LTRIM(RTRIM(a.Middle_NAME)) + REPLICATE(@Lc_Space_TEXT, 20)), 20) + LEFT((LTRIM(RTRIM(a.Generation_CODE)) + REPLICATE(@Lc_Space_TEXT, 1)), 1) + RIGHT((REPLICATE(@Lc_StringZero_TEXT, 9) + LTRIM(RTRIM(a.MemberSsn_NUMB))), 9) + LEFT((LTRIM(RTRIM(a.Birth_DATE)) + REPLICATE(@Lc_Space_TEXT, 8)), 8) + LEFT((LTRIM(RTRIM(a.Phone_NUMB)) + REPLICATE(@Lc_Space_TEXT, 10)), 10) + LEFT((LTRIM(RTRIM(a.Ecoa_CODE)) + REPLICATE(@Lc_Space_TEXT, 1)), 1) + LEFT((LTRIM(RTRIM(a.ConsumerInfo_CODE)) + REPLICATE(@Lc_Space_TEXT, 2)), 2) + LEFT((LTRIM(RTRIM(a.Country_CODE)) + REPLICATE(@Lc_Space_TEXT, 2)), 2) + LEFT((LTRIM(RTRIM(a.Line1_ADDR)) + REPLICATE(@Lc_Space_TEXT, 32)), 32) + LEFT((LTRIM(RTRIM(a.Line2_ADDR)) + REPLICATE(@Lc_Space_TEXT, 32)), 32) + LEFT((LTRIM(RTRIM(a.City_ADDR)) + REPLICATE(@Lc_Space_TEXT, 20)), 20) + LEFT((LTRIM(RTRIM(a.State_ADDR)) + REPLICATE(@Lc_Space_TEXT, 2)), 2) + LEFT((LTRIM(RTRIM(a.Zip_ADDR)) + REPLICATE(@Lc_Space_TEXT, 9)), 9) + LEFT((LTRIM(RTRIM(a.Confirm_CODE)) + REPLICATE(@Lc_Space_TEXT, 1)), 1) + LEFT((LTRIM(RTRIM(a.Residence_CODE)) + REPLICATE(@Lc_Space_TEXT, 1)), 1)) AS Record_TEXT
     FROM ECBTW_Y1 a;

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   SET @Lc_FileTotRecCount_TEXT = RIGHT(('0000000' + @Ln_TotalRecord_NUMB), 7);
   
   SET @Ls_Sql_TEXT='INSERT ##EXTCPR_P1 - 2';
   SET @Ls_Sqldata_TEXT = 'FILE RECORD COUNT = ' + @Lc_FileTotRecCount_TEXT;

   INSERT INTO ##ExtCbr_P1
               (Record_TEXT)
        VALUES ( @Lc_RecordDescriptorWord_TEXT + LEFT((LTRIM(RTRIM(@Lc_Trailer_TEXT)) + REPLICATE(@Lc_Space_TEXT, 7)), 7) + RIGHT((REPLICATE(@Lc_StringZero_TEXT, 9) + LTRIM(RTRIM(@Ln_CursorCount_NUMB))), 9) + REPLICATE(@Lc_Space_TEXT, 18) + RIGHT((REPLICATE(@Lc_StringZero_TEXT, 9) + LTRIM(RTRIM(@Lc_StringZero_TEXT))), 9) + RIGHT((REPLICATE(@Lc_StringZero_TEXT, 9) + LTRIM(RTRIM(@Lc_StringZero_TEXT))), 9) + RIGHT((REPLICATE(@Lc_StringZero_TEXT, 9) + LTRIM(RTRIM(@Lc_StringZero_TEXT))), 9) + RIGHT((REPLICATE(@Lc_StringZero_TEXT, 9) + LTRIM(RTRIM(@Ln_CaseDeleteStatusCount_NUMB))), 9) + RIGHT((REPLICATE(@Lc_StringZero_TEXT, 9) + LTRIM(RTRIM(@Lc_StringZero_TEXT))), 9) + RIGHT((REPLICATE(@Lc_StringZero_TEXT, 9) + LTRIM(RTRIM(@Ln_CaseAlreadySentStatusCount_NUMB))), 9) + RIGHT((REPLICATE(@Lc_StringZero_TEXT, 9) + LTRIM(RTRIM(@Lc_StringZero_TEXT))), 9) + RIGHT((REPLICATE(@Lc_StringZero_TEXT, 9) + LTRIM(RTRIM(@Lc_StringZero_TEXT))), 9) + RIGHT((REPLICATE(@Lc_StringZero_TEXT, 9) + LTRIM(RTRIM(@Ln_CaseClosedStatusCount_NUMB))), 9) + RIGHT((REPLICATE(@Lc_StringZero_TEXT, 9) + LTRIM(RTRIM(@Lc_StringZero_TEXT))), 9) + RIGHT((REPLICATE(@Lc_StringZero_TEXT, 9) + LTRIM(RTRIM(@Lc_StringZero_TEXT))), 9) + RIGHT((REPLICATE(@Lc_StringZero_TEXT, 9) + LTRIM(RTRIM(@Lc_StringZero_TEXT))), 9) + RIGHT((REPLICATE(@Lc_StringZero_TEXT, 9) + LTRIM(RTRIM(@Lc_StringZero_TEXT))), 9) + RIGHT((REPLICATE(@Lc_StringZero_TEXT, 9) + LTRIM(RTRIM(@Lc_StringZero_TEXT))), 9) + RIGHT((REPLICATE(@Lc_StringZero_TEXT, 9) + LTRIM(RTRIM(@Lc_StringZero_TEXT))), 9) + RIGHT((REPLICATE(@Lc_StringZero_TEXT, 9) + LTRIM(RTRIM(@Lc_StringZero_TEXT))), 9) + RIGHT((REPLICATE(@Lc_StringZero_TEXT, 9) + LTRIM(RTRIM(@Lc_StringZero_TEXT))), 9) + RIGHT((REPLICATE(@Lc_StringZero_TEXT, 9) + LTRIM(RTRIM(@Lc_StringZero_TEXT))), 9) + RIGHT((REPLICATE(@Lc_StringZero_TEXT, 9) + LTRIM(RTRIM(@Lc_StringZero_TEXT))), 9) + RIGHT((REPLICATE(@Lc_StringZero_TEXT, 9) + LTRIM(RTRIM(@Lc_StringZero_TEXT))), 9) + RIGHT((REPLICATE(@Lc_StringZero_TEXT, 9) + LTRIM(RTRIM(@Ln_ActiveCaseStatusCount_NUMB))), 9) + RIGHT((REPLICATE(@Lc_StringZero_TEXT, 9) + LTRIM(RTRIM(@Lc_StringZero_TEXT))), 9) + RIGHT((REPLICATE(@Lc_StringZero_TEXT, 9) + LTRIM(RTRIM(@Lc_StringZero_TEXT))), 9) + RIGHT((REPLICATE(@Lc_StringZero_TEXT, 9) + LTRIM(RTRIM(@Lc_StringZero_TEXT))), 9) + RIGHT((REPLICATE(@Lc_StringZero_TEXT, 9) + LTRIM(RTRIM(@Lc_StringZero_TEXT))), 9) + RIGHT((REPLICATE(@Lc_StringZero_TEXT, 9) + LTRIM(RTRIM(@Lc_StringZero_TEXT))), 9) + RIGHT((REPLICATE(@Lc_StringZero_TEXT, 9) + LTRIM(RTRIM(@Lc_StringZero_TEXT))), 9) + RIGHT((REPLICATE(@Lc_StringZero_TEXT, 9) + LTRIM(RTRIM(@Lc_StringZero_TEXT))), 9) + RIGHT((REPLICATE(@Lc_StringZero_TEXT, 9) + LTRIM(RTRIM(@Lc_StringZero_TEXT))), 9) + RIGHT((REPLICATE(@Lc_StringZero_TEXT, 9) + LTRIM(RTRIM(@Lc_StringZero_TEXT))), 9) + RIGHT((REPLICATE(@Lc_StringZero_TEXT, 9) + LTRIM(RTRIM(@Lc_StringZero_TEXT))), 9) + RIGHT((REPLICATE(@Lc_StringZero_TEXT, 9) + LTRIM(RTRIM(@Lc_StringZero_TEXT))), 9) + RIGHT((REPLICATE(@Lc_StringZero_TEXT, 9) + LTRIM(RTRIM(@Ln_CursorCount_NUMB))), 9) + RIGHT((REPLICATE(@Lc_StringZero_TEXT, 9) + LTRIM(RTRIM(@Ln_CursorCount_NUMB))), 9) + RIGHT((REPLICATE(@Lc_StringZero_TEXT, 9) + LTRIM(RTRIM(@Lc_StringZero_TEXT))), 9) + RIGHT((REPLICATE(@Lc_StringZero_TEXT, 9) + LTRIM(RTRIM(@Lc_StringZero_TEXT))), 9) + RIGHT((REPLICATE(@Lc_StringZero_TEXT, 9) + LTRIM(RTRIM(@Ln_CursorCount_NUMB))), 9) + RIGHT((REPLICATE(@Lc_StringZero_TEXT, 9) + LTRIM(RTRIM(@Ln_CursorCount_NUMB))), 9) + RIGHT((REPLICATE(@Lc_StringZero_TEXT, 9) + LTRIM(RTRIM(@Lc_StringZero_TEXT))), 9) + RIGHT((REPLICATE(@Lc_StringZero_TEXT, 9) + LTRIM(RTRIM(@Lc_StringZero_TEXT))), 9) + RIGHT((REPLICATE(@Lc_StringZero_TEXT, 9) + LTRIM(RTRIM(@Ln_PhoneCount_NUMB))), 9) + REPLICATE(@Lc_Space_TEXT, 19) ); -- Record_TEXT

   COMMIT TRANSACTION CBR_EXTRACT_FILE;

   SET @Ls_BcpCommand_TEXT = 'SELECT Record_TEXT FROM ##ExtCbr_P1 ORDER BY Seq_IDNO ASC';
   SET @Ls_Sql_TEXT = 'EXTRACT TO FILE';
   SET @Ls_Sqldata_TEXT ='QUERY = ' + @Ls_BcpCommand_TEXT;

   EXECUTE BATCH_COMMON$SP_EXTRACT_DATA
    @As_FileLocation_TEXT     = @Ls_FileLocation_TEXT,
    @As_File_NAME             = @Ls_File_NAME,
    @As_Query_TEXT            = @Ls_BcpCommand_TEXT,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END

   BEGIN TRANSACTION CBR_EXTRACT_FILE;

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
    @As_ExecLocation_TEXT         = @LC_Successful_TEXT,
    @As_ListKey_TEXT              = @LC_Successful_TEXT,
    @As_DescriptionError_TEXT     = @Lc_Space_TEXT,
    @Ac_Status_CODE               = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_TotalRecord_NUMB;

   SET @Ls_Sql_TEXT = 'DROP TABLE ##ExtCbr_P1 - 2';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, @Lc_Space_TEXT);

   DROP TABLE ##ExtCbr_P1;

   COMMIT TRANSACTION CBR_EXTRACT_FILE;
  END TRY

  BEGIN CATCH
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION CBR_EXTRACT_FILE;
    END

   IF OBJECT_ID('tempdb..##ExtCbr_P1') IS NOT NULL
    BEGIN
     DROP TABLE ##ExtCbr_P1;
    END

   IF CURSOR_STATUS ('LOCAL', 'Cbr_CUR') IN (0, 1)
    BEGIN
     CLOSE Cbr_CUR;

     DEALLOCATE Cbr_CUR;
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
    @An_ProcessedRecordCount_QNTY = @Lc_StringZero_TEXT;

   RAISERROR(@Ls_DescriptionError_TEXT,16,1);
  END CATCH
 END


GO
