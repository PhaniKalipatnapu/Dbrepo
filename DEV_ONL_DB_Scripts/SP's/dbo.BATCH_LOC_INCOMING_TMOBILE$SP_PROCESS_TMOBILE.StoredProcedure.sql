/****** Object:  StoredProcedure [dbo].[BATCH_LOC_INCOMING_TMOBILE$SP_PROCESS_TMOBILE]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name    :	BATCH_LOC_INCOMING_TMOBILE$SP_PROCESS_TMOBILE
Programmer Name   :	Imp Team
Description       :	The purpose of Tmobile response process is to update member address in the system with the address 
					received from Tmobile wireless in response to the subponea. 
Frequency         :	This job will be run once a quater when the file is received from the T-MOBILE wireless.
Developed On      :	07/13/2011
Called BY         :	None
Called On		  :	
-------------------------------------------------------------------------------------------------------------------						
Modified BY       :
Modified On       :
Version No        :	0.01
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_LOC_INCOMING_TMOBILE$SP_PROCESS_TMOBILE]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusFailed_CODE				CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE			CHAR(1) = 'S',
          @Lc_StatusAbnormalend_CODE		CHAR(1) = 'A',
          @Lc_MailingTypeAddress_CODE		CHAR(1) = 'M',
          @Lc_PendingStatus_CODE			CHAR(1) = 'P',
          @Lc_IndNote_TEXT					CHAR(1) = 'N',
          @Lc_TypeErrorE_CODE				CHAR(1) = 'E',
          @Lc_ActiveCaseMemberStatus_CODE	CHAR(1) = 'A',
          @Lc_OpenStatusCase_CODE			CHAR(1) = 'O',
          @Lc_ProcessY_INDC					CHAR(1) = 'Y',
          @Lc_ProcessN_INDC					CHAR(1) = 'N',
          @Lc_StatusCaseOpen_CODE			CHAR(1) = 'O',
          @Lc_StatusCaseClose_CODE			CHAR(1) = 'C',
          @Lc_TypeCaseNivd_CODE				CHAR(1) = 'H',
          @Lc_CaseRelationshipNcp_CODE		CHAR(1) = 'A',
          @Lc_CaseRelationshipPutative_CODE CHAR(1) = 'P',
          @Lc_CaseRelationshipCp_CODE		CHAR(1) = 'C',
          @Lc_Country_ADDR					CHAR(2) = 'US',
          @Lc_RsnStatusCaseUc_CODE			CHAR(2) = 'UC',
          @Lc_RsnStatusCaseUb_CODE			CHAR(2) = 'UB',
          @Lc_SourceVerified_CODE			CHAR(3) = 'P',
          @Lc_Subsystem_CODE				CHAR(3) = 'LO',
          @Lc_TmbSourceLoc_CODE				CHAR(3) = 'TMB',
          @Lc_ActivityMajor_CODE			CHAR(4) = 'CASE',
          @Lc_TypeReference_IDNO			CHAR(4) = ' ',
          @Lc_BatchRunUser_TEXT				CHAR(5) = 'BATCH',
          @Lc_ErrorE0085_CODE				CHAR(5) = 'E0085',
          @Lc_ErrorE1405_CODE				CHAR(5) = 'E1405',
          @Lc_ErrorE0907_CODE				CHAR(5) = 'E0907',
          @Lc_ErrorE1373_CODE				CHAR(5) = 'E1373',
          @Lc_ErrorE1374_CODE				CHAR(5) = 'E1374',
          @Lc_ErrorE1424_CODE				CHAR(5) = 'E1424',
          @Lc_ErrorE1089_CODE				CHAR(5) = 'E1089',
          @Lc_ErrorE0944_CODE				CHAR(5) = 'E0944',
          @Lc_ActivityMinorRunca_CODE		CHAR(5) = 'RUNCA',
          @Lc_Job_ID						CHAR(7) = 'DEB8078',
          @Lc_Process_ID					CHAR(7) = 'DEB8078',
          @Lc_Successful_TEXT				CHAR(20) = 'SUCCESSFUL',
          @Lc_Err0002_TEXT					CHAR(30) = 'UPDATE NOT SUCCESSFUL',
          @Lc_WorkerDelegate_ID				CHAR(30) = ' ',
          @Lc_Reference_ID					CHAR(30) = ' ',
          @Lc_Attn_ADDR						CHAR(40) = ' ',
          @Ls_ParmDateProblem_TEXT			VARCHAR(50) = 'PARM DATE PROBLEM',
          @Ls_Process_NAME					VARCHAR(100) = 'BATCH_LOC_INCOMING_TMOBILE',
          @Ls_Procedure_NAME				VARCHAR(100) = 'SP_PROCESS_TMOBILE',
          @Ls_DescriptionComments_TEXT		VARCHAR(1000) = ' ',
          @Ls_XmlTextIn_TEXT				VARCHAR(8000) = ' ',
          @Ld_Low_DATE						DATE = '01/01/0001',
          @Ld_High_DATE						DATE = '12/31/9999';
  DECLARE @Ln_Zero_NUMB                        NUMERIC(1) = 0,
          @Ln_TopicIn_IDNO                     NUMERIC(1) = 0,
          @Ln_Office_IDNO                      NUMERIC(3) = 0,
          @Ln_ExceptionThreshold_QNTY          NUMERIC(5) = 0,
          @Ln_ExceptionThresholdParm_QNTY      NUMERIC(5) = 0,
          @Ln_CommitFreq_QNTY                  NUMERIC(5) = 0,
          @Ln_CommitFreqParm_QNTY              NUMERIC(5) = 0,
          @Ln_RestartLine_NUMB                 NUMERIC(5) = 0,
          @Ln_MajorIntSeq_NUMB                 NUMERIC(5) = 0,
          @Ln_MinorIntSeq_NUMB                 NUMERIC(5) = 0,
          @Ln_OrderSeq_NUMB                    NUMERIC(5) = 0,
          @Ln_ProcessedRecordCount_QNTY        NUMERIC(6) = 0,
          @Ln_ProcessedRecordsCommit_QNTY      NUMERIC(6) = 0,
          @Ln_OthpLocation_IDNO                NUMERIC(9) = 0,
          @Ln_OthpSource_IDNO                  NUMERIC(9) = 0,
          @Ln_Schedule_NUMB                    NUMERIC(10) = 0,
          @Ln_RecCount_NUMB                    NUMERIC(10) = 0,
          @Ln_MemberMci_IDNO                   NUMERIC(10) = 0,
          @Ln_Topic_IDNO                       NUMERIC(10) = 0,
          @Ln_Error_NUMB                       NUMERIC(11) = 0,
          @Ln_ErrorLine_NUMB                   NUMERIC(11) = 0,
          @Ln_TransactionEventSeq_NUMB         NUMERIC(18) = 0,
          @Li_FetchStatus_QNTY                 SMALLINT,
          @Li_RowsCount_QNTY                   SMALLINT,
          @Lc_Space_TEXT                       CHAR(1) = '',
          @Lc_OthStateFips_CODE                CHAR(2) = '',
          @Lc_ReasonStatus_CODE                CHAR(2) = '',
          @Lc_Msg_CODE                         CHAR(5) = '',
          @Lc_BateError_CODE                   CHAR(5) = '',
          @Lc_Notice_ID                        CHAR(8) = '',
          @Lc_Schedule_Member_IDNO             CHAR(10) = '',
          @Lc_Schedule_Worker_IDNO             CHAR(30) = '',
          @Ls_CursorLocation_TEXT              VARCHAR(200) = '',
          @Ls_DescriptionServiceDirection_TEXT VARCHAR(1000) = '',
          @Ls_Sql_TEXT                         VARCHAR(2000) = '',
          @Ls_ErrorMessage_TEXT                VARCHAR(4000) = '',
          @Ls_DescriptionError_TEXT            VARCHAR(4000),
          @Ls_BateRecord_TEXT                  VARCHAR(4000),
          @Ls_Sqldata_TEXT                     VARCHAR(5000) = '',
          @Ld_Run_DATE                         DATE,
          @Ld_LastRun_DATE                     DATE,
          @Ld_Start_DATE                       DATETIME2,
          @Ld_BeginSch_DTTM                    DATETIME2;
  DECLARE Tmobile_CUR INSENSITIVE CURSOR FOR
   SELECT a.Seq_IDNO,
          a.Request_DATE,
          a.FileSeq_IDNO,
          a.FirstNcp_NAME,
          a.MiddleNcp_NAME,
          a.LastNcp_NAME,
          a.MemberSsn_NUMB,
          a.Birth_DATE,
          a.MemberMci_IDNO,
          a.Company_NAME,
          a.First_NAME,
          a.Middle_NAME,
          a.Last_NAME,
          a.MemberSsn_CODE,
          a.Name_CODE,
          a.Birth_CODE,
          a.CellPhone_NUMB,
          a.HomePhone_NUMB,
          a.Update_DATE,
          a.Normalization_CODE,
          a.Line1_ADDR,
          a.Line2_ADDR,
          a.City_ADDR,
          a.State_ADDR,
          a.Zip_ADDR
     FROM LTMOB_Y1 a
    WHERE a.Process_INDC = @Lc_ProcessN_INDC;
  DECLARE @Ln_TmobileCur_Seq_IDNO           NUMERIC(19),
          @Lc_TmobileCur_RequestDate_TEXT   CHAR(8),
          @Lc_TmobileCur_FileSeqIdno_TEXT   CHAR(7),
          @Lc_TmobileCur_FirstNcp_NAME      CHAR(15),
          @Lc_TmobileCur_MiddleNcp_NAME     CHAR(15),
          @Lc_TmobileCur_LastNcp_NAME       CHAR(16),
          @Lc_TmobileCur_MemberSsnNumb_TEXT CHAR(9),
          @Lc_TmobileCur_BirthDate_TEXT     CHAR(8),
          @Lc_TmobileCur_MemberMciIdno_TEXT CHAR(7),
          @Lc_TmobileCur_Company_NAME       CHAR(30),
          @Lc_TmobileCur_First_NAME         CHAR(32),
          @Lc_TmobileCur_Middle_NAME        CHAR(15),
          @Ls_TmobileCur_Last_NAME          VARCHAR(60),
          @Lc_TmobileCur_MemberSsn_CODE     CHAR(1),
          @Lc_TmobileCur_Name_CODE          CHAR(1),
          @Lc_TmobileCur_Birth_CODE         CHAR(1),
          @Lc_TmobileCur_CellPhoneNumb_TEXT CHAR(10),
          @Lc_TmobileCur_HomePhoneNumb_TEXT CHAR(10),
          @Lc_TmobileCur_UpdateDate_TEXT    CHAR(8),
          @Lc_TmobileCur_Normalization_CODE CHAR(1),
          @Ls_TmobileCur_Line1_ADDR         VARCHAR(50),
          @Ls_TmobileCur_Line2_ADDR         VARCHAR(50),
          @Lc_TmobileCur_City_ADDR          CHAR(28),
          @Lc_TmobileCur_State_ADDR         CHAR(2),
          @Lc_TmobileCur_Zip_ADDR           CHAR(15),
          @Ln_CaseMemberCur_Case_IDNO       NUMERIC(6),
          @Ln_CaseMemberCur_MemberMci_IDNO  NUMERIC(10);
  DECLARE @Ln_TmobileCurMemberMci_IDNO NUMERIC(7),
          @Ln_TmobileCurMemberSsn_NUMB NUMERIC(9),
          @Ln_TmobileCurCellPhone_NUMB NUMERIC(10),
          @Ln_TmobileCurHomePhone_NUMB NUMERIC(10);

  BEGIN TRY
   SET @Ls_Sql_TEXT = 'GET BATCH START DATE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;
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

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'RUN DATE AND LAST RUN DATE VALIDATION';
   SET @Ls_Sqldata_TEXT = 'LAST RUN DATE = ' + CAST(@Ld_LastRun_DATE AS VARCHAR) + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   IF DATEADD(D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_DescriptionError_TEXT = @Ls_ParmDateProblem_TEXT;

     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'TRASACTION BEGINS - 1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   BEGIN TRANSACTION TMOBILE_PROCESS;

   SET @Ls_Sql_TEXT = 'CHECK KEY EXISTS';
   SET @Ls_Sqldata_TEXT ='Job_ID = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   SELECT @Ln_RestartLine_NUMB = CAST(RestartKey_TEXT AS NUMERIC)
     FROM RSTL_Y1 r
    WHERE Job_ID = @Lc_Job_ID
      AND Run_DATE = @Ld_Run_DATE;

   SET @Li_RowsCount_QNTY = @@ROWCOUNT;

   IF @Li_RowsCount_QNTY = 0
    BEGIN
     SET @Ln_RestartLine_NUMB = 0;
    END;

   SET @Ls_Sql_TEXT = 'DELETE DUPLICATE BATE RECORDS';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', Line_NUMB = ' + CAST(@Ln_RestartLine_NUMB AS VARCHAR);

   DELETE BATE_Y1
    WHERE Job_ID = @Lc_Job_ID
      AND EffectiveRun_DATE = @Ld_Run_DATE
      AND Line_NUMB > @Ln_RestartLine_NUMB;

   SET @Ls_Sql_TEXT = 'OPEN Tmobile_CUR';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;

   OPEN Tmobile_CUR;

   SET @Ls_Sql_TEXT = 'FETCH Tmobile_CUR - 1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   FETCH NEXT FROM Tmobile_CUR INTO @Ln_TmobileCur_Seq_IDNO, @Lc_TmobileCur_RequestDate_TEXT, @Lc_TmobileCur_FileSeqIdno_TEXT, @Lc_TmobileCur_FirstNcp_NAME, @Lc_TmobileCur_MiddleNcp_NAME, @Lc_TmobileCur_LastNcp_NAME, @Lc_TmobileCur_MemberSsnNumb_TEXT, @Lc_TmobileCur_BirthDate_TEXT, @Lc_TmobileCur_MemberMciIdno_TEXT, @Lc_TmobileCur_Company_NAME, @Lc_TmobileCur_First_NAME, @Lc_TmobileCur_Middle_NAME, @Ls_TmobileCur_Last_NAME, @Lc_TmobileCur_MemberSsn_CODE, @Lc_TmobileCur_Name_CODE, @Lc_TmobileCur_Birth_CODE, @Lc_TmobileCur_CellPhoneNumb_TEXT, @Lc_TmobileCur_HomePhoneNumb_TEXT, @Lc_TmobileCur_UpdateDate_TEXT, @Lc_TmobileCur_Normalization_CODE, @Ls_TmobileCur_Line1_ADDR, @Ls_TmobileCur_Line2_ADDR, @Lc_TmobileCur_City_ADDR, @Lc_TmobileCur_State_ADDR, @Lc_TmobileCur_Zip_ADDR;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;

   IF @Li_FetchStatus_QNTY <> 0
    BEGIN
     SET @Lc_BateError_CODE = @Lc_ErrorE0944_CODE;
    END;

   -- Curosor will fetch each record and process
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
     BEGIN TRY
      SAVE TRANSACTION SAVETMOBILE_PROCESS;

      SET @Lc_BateError_CODE = @Lc_ErrorE1424_CODE;
      SET @Lc_Msg_CODE = @Lc_Space_TEXT;
      SET @Ln_RecCount_NUMB = @Ln_RecCount_NUMB + 1;
      SET @Ln_CommitFreq_QNTY = @Ln_CommitFreq_QNTY + 1;
      SET @Ls_CursorLocation_TEXT = 'Tmobile - CURSOR COUNT - ' + CAST(@Ln_RecCount_NUMB AS VARCHAR);
      SET @Ls_Sql_TEXT = 'CHECK FOR KEY MEMBER IDENTIFIER';
      SET @Ls_Sqldata_TEXT = 'MemberSsn_NUMB = ' + @Lc_TmobileCur_MemberSsnNumb_TEXT;
      SET @Ls_BateRecord_TEXT = 'Sequence Number = ' + CAST(@Ln_TmobileCur_Seq_IDNO AS VARCHAR) + ', Request Date = ' + @Lc_TmobileCur_RequestDate_TEXT + ', File Sequence Number = ' + @Lc_TmobileCur_FileSeqIdno_TEXT + ', First Name = ' + @Lc_TmobileCur_FirstNcp_NAME + ', Middle Name = ' + @Lc_TmobileCur_MiddleNcp_NAME + ', Last Name = ' + @Lc_TmobileCur_LastNcp_NAME + ', MemberSsn_NUMB = ' + @Lc_TmobileCur_MemberSsnNumb_TEXT + ', Birth Date = ' + @Lc_TmobileCur_BirthDate_TEXT + ', MemberMci_NUMB = ' + @Lc_TmobileCur_MemberMciIdno_TEXT + ', Company Name = ' + @Lc_TmobileCur_Company_NAME + ', Account holder First Name = ' + @Lc_TmobileCur_First_NAME + ', Account holder Middle Name = ' + @Lc_TmobileCur_Middle_NAME + ', Account holder Last Name = ' + @Ls_TmobileCur_Last_NAME + ', Member SSN Code = ' + @Lc_TmobileCur_MemberSsn_CODE + ', Member Name match code = ' + @Lc_TmobileCur_Name_CODE + ', Member Birth code = ' + @Lc_TmobileCur_Birth_CODE + ', Phone Number = ' + @Lc_TmobileCur_CellPhoneNumb_TEXT + ', Home Phone number = ' + @Lc_TmobileCur_HomePhoneNumb_TEXT + ', Member Last Update date = ' + @Lc_TmobileCur_UpdateDate_TEXT + ', Member Address Normalization Code = ' + @Lc_TmobileCur_Normalization_CODE + ', Line 1 Address = ' + @Ls_TmobileCur_Line1_ADDR + ', Line 2 Address = ' + @Ls_TmobileCur_Line2_ADDR + ', City Address = ' + @Lc_TmobileCur_City_ADDR + ', State Address = ' + @Lc_TmobileCur_State_ADDR + ', Zip Code Address = ' + @Lc_TmobileCur_Zip_ADDR;

      IF @Lc_TmobileCur_CellPhoneNumb_TEXT = ''
       BEGIN
        SET @Lc_TmobileCur_CellPhoneNumb_TEXT = '0';
       END

      IF @Lc_TmobileCur_HomePhoneNumb_TEXT = ''
       BEGIN
        SET @Lc_TmobileCur_HomePhoneNumb_TEXT = '0';
       END

      IF ISNUMERIC(@Lc_TmobileCur_MemberSsnNumb_TEXT) = 1
         AND ISNUMERIC(@Lc_TmobileCur_MemberMciIdno_TEXT) = 1
         AND ISNUMERIC(@Lc_TmobileCur_CellPhoneNumb_TEXT) = 1
         AND ISNUMERIC(@Lc_TmobileCur_HomePhoneNumb_TEXT) = 1
       BEGIN
        SET @Ln_TmobileCurMemberSsn_NUMB = CAST(@Lc_TmobileCur_MemberSsnNumb_TEXT AS NUMERIC);
        SET @Ln_TmobileCurMemberMci_IDNO = CAST(@Lc_TmobileCur_MemberMciIdno_TEXT AS NUMERIC);
        SET @Ln_TmobileCurCellPhone_NUMB = CAST(@Lc_TmobileCur_CellPhoneNumb_TEXT AS NUMERIC);
        SET @Ln_TmobileCurHomePhone_NUMB = CAST(@Lc_TmobileCur_HomePhoneNumb_TEXT AS NUMERIC);
       END
      ELSE
       BEGIN
        SET @Lc_BateError_CODE = @Lc_ErrorE0085_CODE;

        RAISERROR (50001,16,1);
       END

      IF NOT EXISTS (SELECT 1
                       FROM DEMO_Y1
                      WHERE MemberSsn_NUMB = @Ln_TmobileCurMemberSsn_NUMB)
          OR @Ln_TmobileCurMemberSsn_NUMB = 0
       BEGIN
        SET @Ls_Sql_TEXT = 'Check the Member SSN in DEMO table';
        SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL (@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL (CAST (@Ld_Run_DATE AS VARCHAR), '');
        SET @Lc_BateError_CODE = @Lc_ErrorE0907_CODE;

        RAISERROR (50001,16,1);
       END
      ELSE IF NOT EXISTS (SELECT 1
                       FROM DEMO_Y1
                      WHERE MemberSsn_NUMB = @Ln_TmobileCurMemberSsn_NUMB
                        AND LEFT(Last_NAME, 5) = LEFT(@Lc_TmobileCur_LastNcp_NAME, 5))
       BEGIN
        SET @Ls_Sql_TEXT = 'Check with Member SSN and Last Name';
        SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL (@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL (CAST (@Ld_Run_DATE AS VARCHAR), '');
        SET @Lc_BateError_CODE = @Lc_ErrorE1373_CODE;

        RAISERROR (50001,16,1);
       END
      ELSE IF @Ln_TmobileCurCellPhone_NUMB = 0
       BEGIN
        SET @Ls_Sql_TEXT = 'INVALID PHONE NUMBER';
        SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL (@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL (CAST (@Ld_Run_DATE AS VARCHAR), '');
        SET @Lc_BateError_CODE = @Lc_ErrorE1374_CODE;

        RAISERROR (50001,16,1);
       END
      ELSE IF NOT EXISTS (SELECT 1
                       FROM CASE_Y1 C
                            JOIN CMEM_Y1 M
                             ON C.Case_IDNO = M.Case_IDNO
                      WHERE C.StatusCase_CODE = @Lc_StatusCaseOpen_CODE
                        AND C.TypeCase_CODE <> @Lc_TypeCaseNivd_CODE
                        AND RIGHT(MemberMci_IDNO, 7) = @Ln_TmobileCurMemberMci_IDNO)
         AND NOT EXISTS (SELECT 1
                           FROM CASE_Y1 C
                                JOIN CMEM_Y1 M
                                 ON C.CASE_IDNO = M.CASE_IDNO
                          WHERE C.StatusCase_CODE = @Lc_StatusCaseClose_CODE
                            AND C.RsnStatusCase_CODE IN (@Lc_RsnStatusCaseUc_CODE, @Lc_RsnStatusCaseUb_CODE)
                            AND M.CaseRelationship_CODE = @Lc_CaseRelationshipNcp_CODE
                            AND RIGHT(MemberMci_IDNO, 7) = @Ln_TmobileCurMemberMci_IDNO)
       BEGIN
        SET @Ls_Sql_TEXT = 'DATA REJECTED, NO VALID CASE FOUND TO LOAD DATA';
        SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL (@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL (CAST (@Ld_Run_DATE AS VARCHAR), '');
        SET @Lc_BateError_CODE = @Lc_ErrorE1405_CODE;

        RAISERROR (50001,16,1);
       END
      ELSE
       BEGIN
        SET @Ln_MemberMci_IDNO = (SELECT MemberMci_IDNO
                                    FROM DEMO_Y1
                                   WHERE MemberSsn_NUMB = @Ln_TmobileCurMemberSsn_NUMB
                                     AND RIGHT(MemberMci_IDNO, 7) = @Ln_TmobileCurMemberMci_IDNO);
       END

      IF @Ls_TmobileCur_Line1_ADDR <> @Lc_Space_TEXT
          OR @Ls_TmobileCur_Line2_ADDR <> @Lc_Space_TEXT
          OR @Lc_TmobileCur_City_ADDR <> @Lc_Space_TEXT
          OR @Lc_TmobileCur_State_ADDR <> @Lc_Space_TEXT
          OR @Lc_TmobileCur_Zip_ADDR <> @Lc_Space_TEXT
       BEGIN
        SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT - 1';
        SET @Ls_Sqldata_TEXT = 'Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', Process_ID = ' + ISNULL(@Lc_Job_ID, '') + ', EffectiveEvent_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Note_INDC = ' + ISNULL(@Lc_IndNote_TEXT, '') + ', EventFunctionalSeq_NUMB = ' + ISNULL('0', '');

        EXEC BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
         @Ac_Worker_ID                = @Lc_BatchRunUser_TEXT,
         @Ac_Process_ID               = @Lc_Process_ID,
         @Ad_EffectiveEvent_DATE      = @Ld_Run_DATE,
         @Ac_Note_INDC                = @Lc_IndNote_TEXT,
         @An_EventFunctionalSeq_NUMB  = 0,
         @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
         @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
         @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

        IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
         BEGIN
          RAISERROR (50001,16,1);
         END

        SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_ADDRESS_UPDATE - 1';
        SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR), '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', TypeAddress_CODE = ' + ISNULL(@Lc_MailingTypeAddress_CODE, '') + ', Begin_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', End_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '') + ', Attn_ADDR = ' + ISNULL(@Lc_Attn_ADDR, '') + ', Line1_ADDR = ' + ISNULL(@Ls_TmobileCur_Line1_ADDR, '') + ', Line2_ADDR = ' + ISNULL(@Ls_TmobileCur_Line2_ADDR, '') + ', City_ADDR = ' + ISNULL(@Lc_TmobileCur_City_ADDR, '') + ', State_ADDR = ' + ISNULL(@Lc_TmobileCur_State_ADDR, '') + ', Zip_ADDR = ' + ISNULL(@Lc_TmobileCur_Zip_ADDR, '') + ', Country_ADDR = ' + ISNULL(@Lc_Country_ADDR, '') + ', Phone_NUMB = ' + ISNULL(CAST(@Ln_TmobileCurCellPhone_NUMB AS VARCHAR), '') + ', SourceLoc_CODE = ' + ISNULL(@Lc_TmbSourceLoc_CODE, '') + ', SourceReceived_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Status_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Status_CODE = ' + ISNULL(@Lc_PendingStatus_CODE, '') + ', SourceVerified_CODE = ' + ISNULL(@Lc_SourceVerified_CODE, '') + ', DescriptionComments_TEXT = ' + ISNULL(@Ls_DescriptionComments_TEXT, '') + ', DescriptionServiceDirection_TEXT = ' + ISNULL(@Ls_DescriptionServiceDirection_TEXT, '') + ', Process_ID = ' + ISNULL(@Lc_Process_ID, '') + ', SignedOnWorker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', OfficeSignedOn_IDNO = ' + ISNULL(CAST(@Ln_Office_IDNO AS VARCHAR), '') + ', Normalization_CODE = ' + ISNULL(@Lc_TmobileCur_Normalization_CODE, '') + ', CcrtMemberAddress_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', CcrtCaseRelationship_CODE = ' + ISNULL(@Lc_Space_TEXT, '');

        EXECUTE BATCH_COMMON$SP_ADDRESS_UPDATE
         @An_MemberMci_IDNO                   = @Ln_MemberMci_IDNO,
         @Ad_Run_DATE                         = @Ld_Run_DATE,
         @Ac_TypeAddress_CODE                 = @Lc_MailingTypeAddress_CODE,
         @Ad_Begin_DATE                       = @Ld_Run_DATE,
         @Ad_End_DATE                         = @Ld_High_DATE,
         @Ac_Attn_ADDR                        = @Lc_Attn_ADDR,
         @As_Line1_ADDR                       = @Ls_TmobileCur_Line1_ADDR,
         @As_Line2_ADDR                       = @Ls_TmobileCur_Line2_ADDR,
         @Ac_City_ADDR                        = @Lc_TmobileCur_City_ADDR,
         @Ac_State_ADDR                       = @Lc_TmobileCur_State_ADDR,
         @Ac_Zip_ADDR                         = @Lc_TmobileCur_Zip_ADDR,
         @Ac_Country_ADDR                     = @Lc_Country_ADDR,
         @An_Phone_NUMB                       = @Ln_TmobileCurCellPhone_NUMB,
         @Ac_SourceLoc_CODE                   = @Lc_TmbSourceLoc_CODE,
         @Ad_SourceReceived_DATE              = @Ld_Run_DATE,
         @Ad_Status_DATE                      = @Ld_Run_DATE,
         @Ac_Status_CODE                      = @Lc_PendingStatus_CODE,
         @Ac_SourceVerified_CODE              = @Lc_SourceVerified_CODE,
         @As_DescriptionComments_TEXT         = @Ls_DescriptionComments_TEXT,
         @As_DescriptionServiceDirection_TEXT = @Ls_DescriptionServiceDirection_TEXT,
         @Ac_Process_ID                       = @Lc_Process_ID,
         @Ac_SignedOnWorker_ID                = @Lc_BatchRunUser_TEXT,
         @An_TransactionEventSeq_NUMB         = @Ln_TransactionEventSeq_NUMB,
         @An_OfficeSignedOn_IDNO              = @Ln_Office_IDNO,
         @Ac_Normalization_CODE               = @Lc_TmobileCur_Normalization_CODE,
         @Ac_CcrtMemberAddress_CODE           = @Lc_Space_TEXT,
         @Ac_CcrtCaseRelationship_CODE        = @Lc_Space_TEXT,
         @Ac_Msg_CODE                         = @Lc_Msg_CODE OUTPUT,
         @As_DescriptionError_TEXT            = @Ls_DescriptionError_TEXT OUTPUT;

        IF @Lc_Msg_CODE NOT IN (@Lc_StatusSuccess_CODE, @Lc_ErrorE1089_CODE)
         BEGIN
          RAISERROR (50001,16,1);
         END;
        ELSE IF @Lc_Msg_CODE = @Lc_StatusSuccess_CODE
           AND EXISTS (SELECT 1
                         FROM AHIS_Y1 a
                        WHERE a.MemberMci_IDNO = @Ln_MemberMci_IDNO
                          AND a.TypeAddress_CODE = @Lc_MailingTypeAddress_CODE
                          AND a.SourceLoc_CODE = @Lc_TmbSourceLoc_CODE
                          AND a.Begin_DATE = @Ld_Run_DATE
                          AND a.Status_CODE = @Lc_PendingStatus_CODE)
         BEGIN
          DECLARE CaseMember_Cur INSENSITIVE CURSOR FOR
           SELECT a.Case_IDNO,
                  a.MemberMci_IDNO
             FROM CMEM_Y1 a,
                  CASE_Y1 b
            WHERE a.MemberMci_IDNO = @Ln_MemberMci_IDNO
              AND a.CaseMemberStatus_CODE = @Lc_ActiveCaseMemberStatus_CODE
			  AND a.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutative_CODE, @Lc_CaseRelationshipCp_CODE)
              AND a.Case_IDNO = b.Case_IDNO
              AND b.StatusCase_CODE = @Lc_OpenStatusCase_CODE;

          SET @Ls_Sql_TEXT = 'OPEN CaseMember_Cur';
          SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + @Lc_TmobileCur_MemberMciIdno_TEXT + ', Job_ID = ' + ISNULL (@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL (CAST (@Ld_Run_DATE AS VARCHAR), '');

          OPEN CaseMember_Cur;

          SET @Ls_Sql_TEXT = 'FETCH CaseMember_Cur - 1';
          SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + @Lc_TmobileCur_MemberMciIdno_TEXT + ', Job_ID = ' + ISNULL (@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL (CAST (@Ld_Run_DATE AS VARCHAR), '');

          FETCH NEXT FROM CaseMember_Cur INTO @Ln_CaseMemberCur_Case_IDNO, @Ln_CaseMemberCur_MemberMci_IDNO;

          SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;

          -- Case journal entry for every case.
          WHILE @Li_FetchStatus_QNTY = 0
           BEGIN
            SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_ACTIVITY ';
            SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_CaseMemberCur_Case_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_CaseMemberCur_MemberMci_IDNO AS VARCHAR), '') + ', ActivityMajor_CODE = ' + ISNULL(@Lc_ActivityMajor_CODE, '') + ', ActivityMinor_CODE = ' + ISNULL(@Lc_ActivityMinorRunca_CODE, '') + ', ReasonStatus_CODE = ' + ISNULL(@Lc_ReasonStatus_CODE, '') + ', Subsystem_CODE = ' + ISNULL(@Lc_Subsystem_CODE, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', WorkerUpdate_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', WorkerDelegate_ID = ' + ISNULL(@Lc_WorkerDelegate_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', TypeReference_CODE = ' + ISNULL(@Lc_TypeReference_IDNO, '') + ', Reference_ID = ' + ISNULL(@Lc_Reference_ID, '') + ', Notice_ID = ' + ISNULL(@Lc_Notice_ID, '') + ', TopicIn_IDNO = ' + ISNULL(CAST(@Ln_TopicIn_IDNO AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Xml_TEXT = ' + ISNULL(@Ls_XmlTextIn_TEXT, '') + ', MajorIntSeq_NUMB = ' + ISNULL(CAST(@Ln_MajorIntSeq_NUMB AS VARCHAR), '') + ', MinorIntSeq_NUMB = ' + ISNULL(CAST(@Ln_MinorIntSeq_NUMB AS VARCHAR), '') + ', Schedule_NUMB = ' + ISNULL(CAST(@Ln_Schedule_NUMB AS VARCHAR), '') + ', Schedule_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '') + ', BeginSch_DTTM = ' + ISNULL(CAST(@Ld_BeginSch_DTTM AS VARCHAR), '') + ', OthpLocation_IDNO = ' + ISNULL(CAST(@Ln_OthpLocation_IDNO AS VARCHAR), '') + ', ScheduleWorker_ID = ' + ISNULL(@Lc_Schedule_Worker_IDNO, '') + ', ScheduleListMemberMci_ID = ' + ISNULL(@Lc_Schedule_Member_IDNO, '') + ', OthpSource_IDNO = ' + ISNULL(CAST(@Ln_OthpSource_IDNO AS VARCHAR), '') + ', IVDOutOfStateFips_CODE = ' + ISNULL(@Lc_OthStateFips_CODE, '') + ', TransHeader_IDNO = ' + ISNULL(CAST(@Ln_Schedule_NUMB AS VARCHAR), '') + ', OrderSeq_NUMB = ' + ISNULL(CAST(@Ln_OrderSeq_NUMB AS VARCHAR), '');

            EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
             @An_Case_IDNO                = @Ln_CaseMemberCur_Case_IDNO,
             @An_MemberMci_IDNO           = @Ln_CaseMemberCur_MemberMci_IDNO,
             @Ac_ActivityMajor_CODE       = @Lc_ActivityMajor_CODE,
             @Ac_ActivityMinor_CODE       = @Lc_ActivityMinorRunca_CODE,
             @Ac_ReasonStatus_CODE        = @Lc_ReasonStatus_CODE,
             @Ac_Subsystem_CODE           = @Lc_Subsystem_CODE,
             @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
             @Ac_WorkerUpdate_ID          = @Lc_BatchRunUser_TEXT,
             @Ac_WorkerDelegate_ID        = @Lc_WorkerDelegate_ID,
             @Ad_Run_DATE                 = @Ld_Run_DATE,
             @Ac_TypeReference_CODE       = @Lc_TypeReference_IDNO,
             @Ac_Reference_ID             = @Lc_Reference_ID,
             @Ac_Notice_ID                = @Lc_Notice_ID,
             @An_TopicIn_IDNO             = @Ln_TopicIn_IDNO,
             @Ac_Job_ID                   = @Lc_Job_ID,
             @As_Xml_TEXT                 = @Ls_XmlTextIn_TEXT,
             @An_MajorIntSeq_NUMB         = @Ln_MajorIntSeq_NUMB,
             @An_MinorIntSeq_NUMB         = @Ln_MinorIntSeq_NUMB,
             @An_Schedule_NUMB            = @Ln_Schedule_NUMB,
             @Ad_Schedule_DATE            = @Ld_Low_DATE,
             @Ad_BeginSch_DTTM            = @Ld_BeginSch_DTTM,
             @An_OthpLocation_IDNO        = @Ln_OthpLocation_IDNO,
             @Ac_ScheduleWorker_ID        = @Lc_Schedule_Worker_IDNO,
             @As_ScheduleListMemberMci_ID = @Lc_Schedule_Member_IDNO,
             @An_OthpSource_IDNO          = @Ln_OthpSource_IDNO,
             @Ac_IVDOutOfStateFips_CODE   = @Lc_OthStateFips_CODE,
             @An_TransHeader_IDNO         = @Ln_Schedule_NUMB,
             @An_OrderSeq_NUMB            = @Ln_OrderSeq_NUMB,
             @An_Topic_IDNO               = @Ln_Topic_IDNO OUTPUT,
             @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
             @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

            IF @Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
             BEGIN
              RAISERROR (50001,16,1);
             END

            SET @Ls_Sql_TEXT = 'FETCH CaseMember_Cur - 2';
            SET @Ls_Sqldata_TEXT = 'Cursor CaseMember_Cur Previous Record Case_IDNO = ' + CAST (@Ln_CaseMemberCur_Case_IDNO AS VARCHAR) + ', MemberMci_IDNO = ' + CAST(@Ln_CaseMemberCur_MemberMci_IDNO AS VARCHAR);

            FETCH NEXT FROM CaseMember_Cur INTO @Ln_CaseMemberCur_Case_IDNO, @Ln_CaseMemberCur_MemberMci_IDNO;

            SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
           END;

          CLOSE CaseMember_Cur;

          DEALLOCATE CaseMember_Cur;
         END

        SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_DEMO';
        SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(@Lc_TmobileCur_MemberMciIdno_TEXT, '') + ', BirthCity_NAME = ' + ISNULL(@Lc_Space_TEXT, '') + ', HomePhone_NUMB = ' + ISNULL(CAST(@Ln_TmobileCurHomePhone_NUMB AS VARCHAR), '') + ', CellPhone_NUMB = ' + ISNULL(CAST(@Ln_TmobileCurCellPhone_NUMB AS VARCHAR), '') + ', WorkPhone_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Birth_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '') + ', Process_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Process_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', WorkerUpdate_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '');

        EXECUTE BATCH_COMMON$SP_UPDATE_DEMO
         @An_MemberMci_IDNO        = @Lc_TmobileCur_MemberMciIdno_TEXT,
         @Ac_BirthCity_NAME        = @Lc_Space_TEXT,
         @An_HomePhone_NUMB        = @Ln_TmobileCurHomePhone_NUMB,
         @An_CellPhone_NUMB        = @Ln_TmobileCurCellPhone_NUMB,
         @An_WorkPhone_NUMB        = @Ln_Zero_NUMB,
         @Ad_Birth_DATE            = @Ld_Low_DATE,
         @Ac_Process_ID            = @Lc_Process_ID,
         @Ad_Process_DATE          = @Ld_Run_DATE,
         @Ac_WorkerUpdate_ID       = @Lc_BatchRunUser_TEXT,
         @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
         @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

        IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
         BEGIN
          RAISERROR (50001,16,1);
         END
       END
     END TRY

     BEGIN CATCH
      BEGIN
       IF XACT_STATE() = 1
        BEGIN
         ROLLBACK TRANSACTION SAVETMOBILE_PROCESS;
        END
       ELSE
        BEGIN
         SET @Ls_DescriptionError_TEXT = @Ls_DescriptionError_TEXT + SUBSTRING (ERROR_MESSAGE (), 1, 200);

         RAISERROR( 50001,16,1);
        END

       IF CURSOR_STATUS ('LOCAL', 'CaseMember_Cur') IN (0, 1)
        BEGIN
         CLOSE CaseMember_Cur;

         DEALLOCATE CaseMember_Cur;
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

       IF @Lc_Msg_CODE IN (@Lc_StatusFailed_CODE, @Lc_StatusSuccess_CODE, @Lc_Space_TEXT)
        BEGIN
         SET @Lc_Msg_CODE = @Lc_BateError_CODE;
        END

       SET @Ls_BateRecord_TEXT = 'Error Record = ' + @Ls_BateRecord_TEXT + ', Error Description = ' + @Ls_DescriptionError_TEXT;
       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG';
       SET @Ls_Sqldata_TEXT = ' Member SSN = ' + @Lc_TmobileCur_MemberSsnNumb_TEXT + ', Job_ID = ' + ISNULL (@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL (CAST (@Ld_Run_DATE AS VARCHAR), '');

       EXECUTE BATCH_COMMON$SP_BATE_LOG
        @As_Process_NAME             = @Ls_Process_NAME,
        @As_Procedure_NAME           = @Ls_Procedure_NAME,
        @Ac_Job_ID                   = @Lc_Job_ID,
        @Ad_Run_DATE                 = @Ld_Run_DATE,
        @Ac_TypeError_CODE           = @Lc_TypeErrorE_CODE,
        @An_Line_NUMB                = @Ln_RestartLine_NUMB,
        @Ac_Error_CODE               = @Lc_Msg_CODE,
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

     SET @Ls_Sql_TEXT = 'UPDATE LTMOB_Y1';
     SET @Ls_Sqldata_TEXT = 'Seq_IDNO = ' + CAST(@Ln_TmobileCur_Seq_IDNO AS VARCHAR) + ', Job_ID = ' + ISNULL (@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL (CAST (@Ld_Run_DATE AS VARCHAR), '');

     UPDATE LTMOB_Y1
        SET Process_INDC = @Lc_ProcessY_INDC
      WHERE Seq_IDNO = @Ln_TmobileCur_Seq_IDNO;

     SET @Li_RowsCount_QNTY = @@ROWCOUNT;

     IF @Li_RowsCount_QNTY = 0
      BEGIN
       SET @Ls_DescriptionError_TEXT = @Lc_Err0002_TEXT;

       RAISERROR (50001,16,1);
      END

     SET @Ln_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY + 1;

     IF @Ln_CommitFreqParm_QNTY <> 0
        AND @Ln_CommitFreq_QNTY >= @Ln_CommitFreqParm_QNTY
      BEGIN
       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATCH_RESTART_UPDATE';
       SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL (@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL (CAST (@Ld_Run_DATE AS VARCHAR), '') + ', Restart Key = ' + ISNULL (CAST (@Ln_RecCount_NUMB AS VARCHAR), '');

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

       COMMIT TRANSACTION TMOBILE_PROCESS;

       SET @Ln_ProcessedRecordsCommit_QNTY = @Ln_ProcessedRecordsCommit_QNTY + @Ln_CommitFreqParm_QNTY;

       BEGIN TRANSACTION TMOBILE_PROCESS;

       SET @Ln_CommitFreq_QNTY = 0;
      END;

     IF @Ln_ExceptionThreshold_QNTY > @Ln_ExceptionThresholdParm_QNTY
      BEGIN
       SET @Ln_ProcessedRecordsCommit_QNTY = @Ln_ProcessedRecordCount_QNTY;

       COMMIT TRANSACTION TMOBILE_PROCESS;

       SET @Ls_Sql_TEXT = 'REACHED EXCEPTION THRESHOLD';
       SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL (@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL (CAST (@Ld_Run_DATE AS VARCHAR), '');

       RAISERROR (50001,16,1);
      END

     SET @Ls_Sql_TEXT = 'FETCH Tmobile_CUR - 2';
     SET @Ls_Sqldata_TEXT = 'Cursor Previous Record = ' + SUBSTRING(@Ls_BateRecord_TEXT, 1, 970);

     FETCH NEXT FROM Tmobile_CUR INTO @Ln_TmobileCur_Seq_IDNO, @Lc_TmobileCur_RequestDate_TEXT, @Lc_TmobileCur_FileSeqIdno_TEXT, @Lc_TmobileCur_FirstNcp_NAME, @Lc_TmobileCur_MiddleNcp_NAME, @Lc_TmobileCur_LastNcp_NAME, @Lc_TmobileCur_MemberSsnNumb_TEXT, @Lc_TmobileCur_BirthDate_TEXT, @Lc_TmobileCur_MemberMciIdno_TEXT, @Lc_TmobileCur_Company_NAME, @Lc_TmobileCur_First_NAME, @Lc_TmobileCur_Middle_NAME, @Ls_TmobileCur_Last_NAME, @Lc_TmobileCur_MemberSsn_CODE, @Lc_TmobileCur_Name_CODE, @Lc_TmobileCur_Birth_CODE, @Lc_TmobileCur_CellPhoneNumb_TEXT, @Lc_TmobileCur_HomePhoneNumb_TEXT, @Lc_TmobileCur_UpdateDate_TEXT, @Lc_TmobileCur_Normalization_CODE, @Ls_TmobileCur_Line1_ADDR, @Ls_TmobileCur_Line2_ADDR, @Lc_TmobileCur_City_ADDR, @Lc_TmobileCur_State_ADDR, @Lc_TmobileCur_Zip_ADDR;

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

   CLOSE Tmobile_CUR;

   DEALLOCATE Tmobile_CUR;

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL (@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL (CAST (@Ld_Run_DATE AS VARCHAR), '');

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
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Start_DATE = ' + ISNULL(CAST(@Ld_Start_DATE AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Process_NAME = ' + ISNULL(@Ls_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', CursorLocation_TEXT = ' + ISNULL(@Ls_CursorLocation_TEXT, '') + ', ExecLocation_TEXT = ' + ISNULL(@Lc_Successful_TEXT, '') + ', ListKey_TEXT = ' + ISNULL(@Lc_Successful_TEXT, '') + ', DescriptionError_TEXT = ' + ISNULL(@Ls_DescriptionError_TEXT, '') + ', Status_CODE = ' + ISNULL(@Lc_StatusSuccess_CODE, '') + ', Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', ProcessedRecordCount_QNTY = ' + ISNULL(CAST(@Ln_ProcessedRecordCount_QNTY AS VARCHAR), '');

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

   SET @Ls_Sql_TEXT = 'TRASACTION COMMIT - 3';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   COMMIT TRANSACTION TMOBILE_PROCESS;
  END TRY

  BEGIN CATCH
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION TMOBILE_PROCESS;
    END

   IF CURSOR_STATUS ('LOCAL', 'Tmobile_CUR') IN (0, 1)
    BEGIN
     CLOSE Tmobile_CUR;

     DEALLOCATE Tmobile_CUR;
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
