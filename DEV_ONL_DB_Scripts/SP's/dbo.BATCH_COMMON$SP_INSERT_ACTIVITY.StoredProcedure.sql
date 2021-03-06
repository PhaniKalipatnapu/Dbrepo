/****** Object:  StoredProcedure [dbo].[BATCH_COMMON$SP_INSERT_ACTIVITY]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
 ------------------------------------------------------------------------------------------------------------------------------------------------------
 Procedure Name				: BATCH_COMMON$SP_INSERT_ACTIVITY
 Programmer Name			: IMP Team.
 Description     			: This procedure is used to insert the activity in DMJR_Y1 and DMNR_Y1 tables for the
                                 case and member combination.
 Frequency					:
 Developed On				: 04/12/2011
 Called By					: BATCH_COMMON$SP_LOAD_NOTICE_XML_DATA
 Called On			        : BATCH_COMMON_GETS$SP_GET_DUE_ALERT_DATE, BATCH_GEN_NOTICE_UTIL$SP_GET_NOTICE_RECIPIENTS,
							  BATCH_GEN_NOTICE_UTIL$SP_GET_RECIPIENT_ADDRESS,BATCH_COMMON$SP_LOAD_NOTICE_XML_DATA, BATCH_GEN_NOTICES$SP_GENERATE_NOTICE
 ------------------------------------------------------------------------------------------------------------------------------------------------------------
 Modified By				:
 Modified On				:
 Version No					: 1.0
 -----------------------------------------------------------------------------------------------------------------------------------------------------------
 
 */
CREATE PROCEDURE [dbo].[BATCH_COMMON$SP_INSERT_ACTIVITY] (
 @An_Case_IDNO								NUMERIC(6),
 @An_MemberMci_IDNO							NUMERIC(10),
 @Ac_ActivityMajor_CODE						CHAR(4),
 @Ac_ActivityMinor_CODE						CHAR(5),
 @Ac_ReasonStatus_CODE						CHAR(2)				= NULL,
 @As_DescriptionNote_TEXT					VARCHAR(4000)		= NULL,
 @Ac_Subsystem_CODE							CHAR(2),
 @An_TransactionEventSeq_NUMB				NUMERIC(19),
 @Ac_WorkerUpdate_ID						CHAR(30),
 @Ac_WorkerDelegate_ID						CHAR(30)			= NULL,
 @Ac_SignedonWorker_ID						CHAR(30)			= NULL,
 @Ad_Run_DATE								DATETIME2			= NULL,
 @Ac_TypeReference_CODE						CHAR(5)				= ' ',
 @Ac_Reference_ID							CHAR(30)			= ' ',
 @Ac_Notice_ID								CHAR(8)				= NULL,
 @An_TopicIn_IDNO							NUMERIC(10)			= 0,
 @Ac_Job_ID									CHAR(7)				= ' ',
 @As_Xml_TEXT								VARCHAR(MAX)		= ' ',
 @An_MajorIntSeq_NUMB						NUMERIC				= 0,
 @An_MinorIntSeq_NUMB						NUMERIC				= 0,
 @An_Schedule_NUMB							NUMERIC				= NULL,
 @Ad_Schedule_DATE							DATE				= NULL,
 @Ad_BeginSch_DTTM							DATETIME2			= NULL,
 @An_OthpLocation_IDNO						NUMERIC(9)			= 0,
 @Ac_ScheduleWorker_ID						CHAR(30)			= NULL,
 @As_ScheduleListMemberMci_ID				VARCHAR(100)		= NULL,
 @An_OthpSource_IDNO						NUMERIC(10)			= NULL,
 @Ac_IVDOutOfStateFips_CODE					CHAR(7)				= NULL,
 @An_TransHeader_IDNO						NUMERIC(12)			= 0,
 @An_OrderSeq_NUMB							NUMERIC(5)			= 0,
 @An_BarcodeIn_NUMB							NUMERIC(12)			= 0,
 @An_Topic_IDNO								NUMERIC(10)			OUTPUT,
 @Ac_Msg_CODE								CHAR(5)				OUTPUT,
 @As_DescriptionError_TEXT					VARCHAR(MAX)		OUTPUT
 )
AS
 
 CREATE TABLE #NoticeInput_P1
  (
    Notice_ID								CHAR(8),
    Recipient_CODE							CHAR(4),
    Recipient_ID							CHAR(10),
    TypeService_CODE						CHAR(2),
    PrintMethod_CODE						CHAR(2),
    Addr_Type_CODE							CHAR(1),
    Barcode_NUMB							NUMERIC(12),
    Input_Parameters_TEXT					VARCHAR(MAX)
  );

 DECLARE @NoticeOutput_P1 TABLE 
 (
	Notice_ID								CHAR(8),
	Recipient_CODE							CHAR(4),
	Recipient_ID							CHAR(10),
	TypeService_CODE						CHAR(2),
	PrintMethod_CODE						CHAR(2),
	Addr_Type_CODE							CHAR(1),
	Input_Parameters_TEXT					VARCHAR(MAX),
	BarcodeOut_NUMB							NUMERIC(12),
	XmlOut_Text								VARCHAR(MAX),
	Msg_CODE								CHAR(5),
	DescriptionError_TEXT					VARCHAR(MAX)
  );
  
 DECLARE @Lref_Recipient_P1 TABLE 
 (
	Recipient_ID							CHAR(10),
	Recipient_NAME							VARCHAR(60),
	Recipient_CODE							CHAR(4),
	PrintMethod_CODE						CHAR(1),
	TypeService_CODE						CHAR(1)
  );
  
 DECLARE @Lref_ArefRecipient_P1 TABLE 
 (
	Line1_ADDR								VARCHAR(50),
	Line2_ADDR								VARCHAR(50),
	State_ADDR								CHAR(2),
	City_ADDR								CHAR(28),
	Zip_ADDR								CHAR(15),
	TypeAddress_CODE						CHAR(1),
	Status_CODE								CHAR(1),
	Ind_ADDR								NUMERIC(1)
  );
  
 DECLARE 
	@Li_Zero_NUMB							INT					= 0,
	@Lc_Space_TEXT							CHAR(1)				= ' ',
	@Lc_StatusSuccess_CODE					CHAR(1)				= 'S',
	@Lc_StatusFailed_CODE					CHAR(1)				= 'F',
	@Lc_ValueNo_INDC						CHAR(1)				= 'N',
	@Lc_OrderTypeVoluntary_CODE				CHAR(1)				= 'V',
	@Lc_ActionAlertNo_CODE					CHAR(1)				= 'N',
	@Lc_RemedyStatusReasonBi_CODE			CHAR(2)				= 'BI',
	@Lc_RemedyStatusReasonWi_CODE			CHAR(2)				= 'WI',
	@Lc_ReasonStatusSysupd_CODE				CHAR(2)				= 'SY',
	@Lc_TableGn10_ID						CHAR(4)				= 'GN10',
	@Lc_TableSubAlrt_ID						CHAR(4)				= 'ALRT',
	@Lc_RemedyStatusStart_CODE				CHAR(4)				= 'STRT',
	@Lc_RemedyStatusComplete_CODE			CHAR(4)				= 'COMP',
	@Lc_ActivityMajorCase_CODE				CHAR(4)				= 'CASE',
	@Lc_BatchRunUser_TEXT					CHAR(30)			= 'BATCH',
	@Ls_Routine_TEXT						VARCHAR(50)			= 'BATCH_COMMON$SP_INSERT_ACTIVITY',
	@Ld_Low_DATE							DATE				= '01/01/0001',
	@Ld_High_DATE							DATE				= '12/31/9999';
	
 DECLARE
	@Ln_RowCount_BIT						SMALLINT,
	@Ln_FetchStatus_BIT						SMALLINT,
	@Ln_NoticeError_NUMB					NUMERIC(2),
	@Ln_QNTY								NUMERIC(3)			= 0,
	@Ln_MinorIntSeq_NUMB					NUMERIC(5),
	@Ln_MajorIntSeq_NUMB					NUMERIC(5),
	@Ln_Forum_IDNO							NUMERIC(10),
	@Ln_Topic_IDNO							NUMERIC(10),
	@Ln_Error_NUMB							NUMERIC(10),
    @Ln_ErrorLine_NUMB						NUMERIC(10),
	@Ln_BarcodeIn_NUMB						NUMERIC(12)			= 0,
	@Ln_Barcode_NUMB						NUMERIC(12)			= 0,
	@Ln_BarcodeOut_NUMB						NUMERIC(12),
	@Ln_TransactionEventSeq_NUMB			NUMERIC(19),
	@Lc_TypeAddress_IDNO					CHAR(1),
	@Lc_Notice_GenerateYesINDC				CHAR(1)				= 'Y',
	@Ls_CaseJournal_INDC					CHAR(1),
	@Lc_ActionAlert_CODE					CHAR(1),
	@Lc_WorkerAssign_INDC					CHAR(1),
	@Lc_PrintMethod_TEXT					CHAR(2),
	@Lc_TypeService_CODE					CHAR(2),
	@Lc_ReasonStatus_CODE					CHAR(2),
	@Lc_Status_CODE							CHAR(4),
	@Lc_Recipient_CODE						CHAR(4),
	@Lc_Msg_Code							CHAR(5),
	@Lc_Role_ID								CHAR(5)				= '',
	@Lc_Notice_ID							CHAR(8),
	@Lc_Recipient_ID						CHAR(10),
	@Lc_File_ID								CHAR(15),
	@Ls_Recipient_NAME						VARCHAR(65),
	@Ls_Sql_TEXT							VARCHAR(4000),
	@Ls_Sqldata_TEXT						VARCHAR(4000),
	@Ls_XmlOut_Text							VARCHAR(MAX),
	@Ls_DescriptionError_TEXT				VARCHAR(MAX),
	@Ld_Status_DATE							DATE,
	@Ld_Generate_DATE						DATE,
	@Ld_DueActivity_DATE					DATE,
	@Ld_DueAlertWarn_DATE					DATE,
	@Ld_Temp_DATE							DATE,
	@Ld_System_DTTM							DATETIME2			= dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
 DECLARE 
	@Lref_NoticeOut_CUR						CURSOR,
	@Lref_RecipientRcur_CUR					CURSOR,
	@Lref_Notice_CUR						CURSOR,
	@Ln_Notice_Count						NUMERIC(2),
	@Ln_RecipientCount_NUMB					NUMERIC(2),
	@Ln_RecipientAddressCount_NUMB			NUMERIC(2),
	@Ln_Recipient_Count						NUMERIC(2),
	@Ln_Recipient_QNTY						NUMERIC(3),
	@Ln_RecpAddrCursor_QNTY					NUMERIC(5)			= 0,
	@Ln_ForumVal_SEQ						NUMERIC(19),
	@Ln_TopicVal_SEQ						NUMERIC(19),
	@Lc_StatusApprvlRegular_CODE			CHAR(1)				= 'R',
	@Lc_Notice_Generate_INDC				CHAR(1),
	@La_PrintMethod_CODE					CHAR(2),
	@La_Addr_Type_CODE						CHAR(2),
	@Lc_Activity_Forms$Notice_ID			CHAR(8),
	@La_Notice_ID							CHAR(8),
	@Lc_Previous_Notice_ID					CHAR(8),
	@Ls_Xml_TEXT							VARCHAR(MAX)		= ' ',
	@La_Input_Parameters_TEXT				VARCHAR(MAX);
 DECLARE 
	@ConcurrenyCheck_P1 TABLE 
	(
		MinorIntSeq_NUMB   NUMERIC(5, 0)
	);

 BEGIN
  SET NOCOUNT ON;

  BEGIN TRY
   /* @Ac_SignedonWorker_ID value passed from the online screens*/
   IF (LTRIM(RTRIM(@Ac_SignedonWorker_ID)) IS NOT NULL)
      AND (LTRIM(RTRIM(@Ac_SignedonWorker_ID)) != '')
    BEGIN
     SET @Ac_WorkerUpdate_ID = @Ac_SignedonWorker_ID;
    END

   SET @Ad_Run_DATE = ISNULL(@Ad_Run_DATE, @Ld_System_DTTM);
   SET @An_Topic_IDNO = 0;
   SET @Ac_Msg_CODE = '';
   SET @As_DescriptionError_TEXT = '';
   SET @Ac_Notice_ID = LTRIM(RTRIM(ISNULL(@Ac_Notice_ID,'')));
   SET @Ln_TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB;
   SET @Lc_ReasonStatus_CODE = ISNULL(@Ac_ReasonStatus_CODE, @Lc_Space_TEXT);
   SET @Ac_WorkerDelegate_ID = ISNULL(@Ac_WorkerDelegate_ID, @Lc_Space_TEXT);
   SET @As_Xml_TEXT = ISNULL(@As_Xml_TEXT, @Lc_Space_TEXT);
   SET @Ad_BeginSch_DTTM = ISNULL(@Ad_BeginSch_DTTM, @Lc_Space_TEXT);
   SET @An_OthpLocation_IDNO = ISNULL(@An_OthpLocation_IDNO, 0);
   SET @Ac_ScheduleWorker_ID = ISNULL(@Ac_ScheduleWorker_ID, @Lc_Space_TEXT);
   SET @As_ScheduleListMemberMci_ID = ISNULL(@As_ScheduleListMemberMci_ID, @Lc_Space_TEXT);

   IF @Ac_Notice_ID != 'CSI-13'
      AND @An_Case_IDNO != -1
    BEGIN
     -- Check whether the case is open or not
     SET @Ls_Sql_TEXT = 'SELECT FILE_ID FROM CASE_Y1 FOR OPEN CASE ';
     SET @Ls_Sqldata_TEXT = ' Case_IDNO: ' + CAST(@An_Case_IDNO AS CHAR(6));
	 /*ERCCL and ERCCL alert can be generated for closed case's*/
	 /*GNPHG and DNPHG activity can be generated for closed case's from RHIS screen*/
     SELECT @Lc_File_ID = c.File_ID
       FROM CASE_Y1 AS c
      WHERE c.Case_IDNO = @An_Case_IDNO
		-- 13555 - Worker Unable To Write A Note On A Closed Case -- Starts
        AND (c.StatusCase_CODE = 'O' 
        	 OR (c.StatusCase_CODE = 'C' 
					AND ( @Ac_Job_ID = 'NOTE' 
							OR @Ac_ActivityMinor_CODE IN('ARCCL', 'ERCCL','GNPHG','DNPHG','CCRCM')
						)
				)
			);
		-- 13555 - Worker Unable To Write A Note On A Closed Case -- Ends

     SET @Ln_RowCount_BIT = @@ROWCOUNT;

     IF @Ln_RowCount_BIT = @Li_Zero_NUMB
      BEGIN
       SET @Ac_Msg_CODE = 'E0073';
       -- 13691 - Description Error is added for Bate Logging - Start
	   SET @As_DescriptionError_TEXT = 'Case is not open';
	   -- 13691 - Description Error is added for Bate Logging - End
       RETURN;
      END

     -- not to generate the below alerts if the previous generation date is within 10 days of run date 
     SET @Ls_Sql_TEXT = 'SELECT REFM_Y1';
     SET @Ls_Sqldata_TEXT = ' @Lc_TableGn10_ID : ' + @Lc_TableGn10_ID + '@Lc_TableSubAlrt_ID : ' + @Lc_TableSubAlrt_ID + '@Ac_ActivityMinor_CODE : ' + @Ac_ActivityMinor_CODE;

     SELECT @Ln_QNTY = COUNT(1)
       FROM REFM_Y1 AS r
      WHERE r.Table_ID = @Lc_TableGn10_ID
        AND r.TableSub_ID = @Lc_TableSubAlrt_ID
        AND r.Value_CODE = @Ac_ActivityMinor_CODE;

     IF @Ln_QNTY > 0
      BEGIN
       /*   selecting the value from UDMNR_V1 (Union of DMNR_Y1 and CJNR_Y1),
       	  instead of selecting the value from DMNR_Y1
       */
       SELECT @Ld_Generate_DATE = ISNULL(MAX(nw.Entered_DATE), @Ld_Low_DATE)
         FROM UDMNR_V1 AS nw
        WHERE nw.Case_IDNO = @An_Case_IDNO
          AND nw.ActivityMinor_CODE = @Ac_ActivityMinor_CODE;

       IF DATEADD(D, 10, @Ld_Generate_DATE) > @Ad_Run_DATE
        BEGIN
         SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
         RETURN;
        END
      END

     IF @Ac_ActivityMajor_CODE = @Lc_ActivityMajorCase_CODE
        AND @An_MajorIntSeq_NUMB = 0
      BEGIN
       IF (@An_TopicIn_IDNO = 0
            OR (@An_TopicIn_IDNO != 0
                AND @Ac_Notice_ID = ''))
        BEGIN
         SET @Ls_Sql_TEXT = 'SELECT DMJR_Y1'
         SET @Ls_Sqldata_TEXT = ' Case_IDNO : ' + CAST(@An_Case_IDNO AS CHAR(6)) + 'Subsystem_CODE : ' + @Ac_Subsystem_CODE + ' ActivityMajor_CODE : ' + @Ac_ActivityMajor_CODE + ' Status_CODE : ' + @Lc_RemedyStatusStart_CODE;

         SELECT @Ln_QNTY = COUNT(1)
           FROM DMJR_Y1 AS j
          WHERE j.Case_IDNO = @An_Case_IDNO
            AND j.Subsystem_CODE = @Ac_Subsystem_CODE
            AND j.ActivityMajor_CODE = @Ac_ActivityMajor_CODE
            AND j.Status_CODE = @Lc_RemedyStatusStart_CODE;

         IF @Ln_QNTY = 0
          BEGIN
           SET @Ls_Sql_TEXT = 'SELECT NEXT MajorIntSeq_NUMB FROM DMJR_Y1';
           SET @Ls_Sqldata_TEXT = 'Case_IDNO : ' + CAST(@An_Case_IDNO AS CHAR(6));

           SELECT @Ln_MajorIntSeq_NUMB = ISNULL(MAX(a.MajorIntSeq_NUMB), 0) + 1
             FROM DMJR_Y1 AS a
            WHERE a.Case_IDNO = @An_Case_IDNO;

           SET @Ls_Sql_TEXT = 'INSERT DMJR_Y1';
           SET @Ls_Sqldata_TEXT = ' Case_IDNO: ' + CAST(@An_Case_IDNO AS CHAR(6)) + ' OrderSeq_NUMB: 0' + ' MajorIntSeq_NUMB: ' + ISNULL(CAST(@Ln_MajorIntSeq_NUMB AS VARCHAR(10)), '') + ' Subsystem_CODE: ' + @Ac_Subsystem_CODE + ' WorkerUpdate_ID: ' + ISNULL(@Ac_WorkerUpdate_ID, '') + 'TransactionEventSeq_NUMB: ' + CAST(@Ln_TransactionEventSeq_NUMB AS CHAR(19));

           INSERT DMJR_Y1
                  (Case_IDNO,
                   OrderSeq_NUMB,
                   MajorIntSeq_NUMB,
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
           VALUES ( @An_Case_IDNO,
                    0,
                    @Ln_MajorIntSeq_NUMB,
                    0,
                    @Ac_ActivityMajor_CODE,
                    @Ac_Subsystem_CODE,
                    @Lc_Space_TEXT,
                    0,
                    @Ad_Run_DATE,
                    @Ld_High_DATE,
                    @Lc_RemedyStatusStart_CODE,
                    CASE @Ac_WorkerUpdate_ID
                     WHEN @Lc_BatchRunUser_TEXT
                      THEN @Lc_RemedyStatusReasonBi_CODE
                     ELSE @Lc_RemedyStatusReasonWi_CODE
                    END,
                    @Ld_Low_DATE,
                    @Ld_Low_DATE,
                    0,
                    0,
                    @Lc_Space_TEXT,
                    @Lc_Space_TEXT,
                    @Ld_Low_DATE,
                    @Ad_Run_DATE,
                    @Ac_WorkerUpdate_ID,
                    @Ld_System_DTTM,
                    @Ln_TransactionEventSeq_NUMB,
                    ISNULL(@Ac_TypeReference_CODE, @Lc_Space_TEXT),
                    ISNULL(@Ac_Reference_ID, @Lc_Space_TEXT))

           SET @Ln_RowCount_BIT = @@ROWCOUNT;
           SET @Ln_Forum_IDNO = SCOPE_IDENTITY();

           IF @Ln_RowCount_BIT = @Li_Zero_NUMB
            BEGIN
             SET @Ac_Msg_CODE = 'E0113';
             SET @As_DescriptionError_TEXT = @Ls_Routine_TEXT + @Lc_Space_TEXT + @Ls_Sql_TEXT + @Lc_Space_TEXT + 'INSERT DMJR_Y1 FAILED' + @Lc_Space_TEXT + @Ls_Sqldata_TEXT;
             RETURN;
            END
        
          END
         ELSE
          BEGIN
           SET @Ls_Sql_TEXT = 'SELECT Forum_IDNO FROM DMJR_Y1'
           SET @Ls_Sqldata_TEXT = ' Case_IDNO: ' + CAST(@An_Case_IDNO AS CHAR(6)) + 'Subsystem_CODE : ' + @Ac_Subsystem_CODE + ' ActivityMajor_CODE : ' + @Ac_ActivityMajor_CODE + ' Status_CODE : ' + @Lc_RemedyStatusStart_CODE;

           SELECT @Ln_Forum_IDNO = j.Forum_IDNO,
                  @Ln_MajorIntSeq_NUMB = j.MajorIntSeq_NUMB
             FROM DMJR_Y1 AS j
            WHERE j.Case_IDNO = @An_Case_IDNO
              AND j.Subsystem_CODE = @Ac_Subsystem_CODE
              AND j.ActivityMajor_CODE = @Ac_ActivityMajor_CODE
              AND j.Status_CODE = @Lc_RemedyStatusStart_CODE;
          
          END

         /* If any program unit that calls this procedure (BATCH_COMMON$SP_INSERT_ACTIVITY) in a loop with same 
         Case ID, Major Activity, Minor Activity, and Transaction Event Sequence then no need to insert the 
         Minor Activity and related notes once again in DMNR_Y1/CJNR_Y1 and NOTE_Y1 tables. */
         IF (@An_TopicIn_IDNO = 0
              OR (@An_TopicIn_IDNO > 0
                  AND NOT EXISTS (SELECT 1
                                    FROM UDMNR_V1
                                   WHERE Topic_IDNO = @An_TopicIn_IDNO
                                     AND Case_IDNO = @An_Case_IDNO)))
          BEGIN
           IF @Ac_ActivityMinor_CODE NOT IN ('OLWRK', 'NEWRK', 'EDDEL')
            BEGIN
             SET @Ls_Sql_TEXT = 'CHECK RECORD EXIST IN DMNR_Y1 ';
             SET @Ls_Sqldata_TEXT = ' Case_IDNO: ' + CAST(@An_Case_IDNO AS CHAR(6)) + ' ActivityMajor_CODE: ' + @Ac_ActivityMajor_CODE + ' ActivityMinor_CODE: ' + @Ac_ActivityMinor_CODE + ' TransactionEventSeq_NUMB: ' + ISNULL(CAST(@An_TransactionEventSeq_NUMB AS CHAR), '');

             SELECT @Ln_QNTY = COUNT(1)
               FROM DMNR_Y1
              WHERE Case_IDNO = @An_Case_IDNO
                AND MemberMci_IDNO = @An_MemberMci_IDNO
                AND ActivityMajor_CODE = @Ac_ActivityMajor_CODE
                AND ActivityMinor_CODE = @Ac_ActivityMinor_CODE
                AND TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB;
            END
           ELSE
            BEGIN
             SET @Ln_QNTY = 0;
            END

           IF @Ln_QNTY = 0
            BEGIN
             SET @Ls_Sql_TEXT = 'SELECT NEXT SEQUENCE VALUE FOR Topic_IDNO ';
             SET @Ls_Sqldata_TEXT = @Lc_Space_TEXT;

             INSERT INTO IdentSeqTopic_T1
                  VALUES (@Ld_System_DTTM);

             SET @Ln_TopicVal_SEQ = @@IDENTITY;

             SELECT @Ln_Topic_IDNO = @Ln_TopicVal_SEQ;

             SET @Ls_Sql_TEXT = 'SELECT CaseJournal_INDC FROM AMNR_Y1';
             SET @Ls_Sqldata_TEXT = 'ActivityMinor_CODE : ' + @Ac_ActivityMinor_CODE;

             SELECT @Ls_CaseJournal_INDC = CaseJournal_INDC,
                    @Lc_ActionAlert_CODE = ActionAlert_CODE
               FROM AMNR_Y1
              WHERE ActivityMinor_CODE = @Ac_ActivityMinor_CODE
                AND EndValidity_DATE =  @Ld_High_DATE;

             SET @Ln_RowCount_BIT = @@ROWCOUNT;

             IF @Ln_RowCount_BIT = @Li_Zero_NUMB
              BEGIN
               SET @Ac_Msg_CODE = 'E1046';
               SET @As_DescriptionError_TEXT = @Ls_Routine_TEXT + @Lc_Space_TEXT + @Ls_Sql_TEXT + @Lc_Space_TEXT + 'SELECT AMNR_Y1 FAILED' + @Lc_Space_TEXT + @Ls_Sqldata_TEXT;
               RETURN;
              END

             SET @Ls_Sql_TEXT = 'dbo.BATCH_COMMON$SF_GET_DURATION_START_DATE';
             SET @Ls_Sqldata_TEXT = ' Case_IDNO: ' + CAST(@An_Case_IDNO AS CHAR(6)) + ' MajorIntSeq_NUMB: ' + ISNULL(CAST(@Ln_MajorIntSeq_NUMB AS VARCHAR(10)), '') + ' ActivityMinor_CODE: ' + @Ac_ActivityMinor_CODE + ' Run_DATE: ' + ISNULL(CONVERT(VARCHAR(10), @Ad_Run_DATE, 101), '');
             SET @Ld_Temp_DATE = dbo.BATCH_COMMON$SF_GET_DURATION_START_DATE(@An_Case_IDNO, @Ln_MajorIntSeq_NUMB, @Ac_ActivityMinor_CODE, NULL, CAST(@Ad_Run_DATE AS DATE));
             
             SET @Ls_Sql_TEXT = 'BATCH_COMMON_GETS$SP_GET_DUE_ALERT_DATE';
             SET @Ls_Sqldata_TEXT = ' ActivityMinor_CODE: ' + @Ac_ActivityMinor_CODE + ' Run_DATE: ' + CONVERT(CHAR(10), @Ld_Temp_DATE, 101);

             EXECUTE BATCH_COMMON_GETS$SP_GET_DUE_ALERT_DATE
              @Ac_ActivityMinor_CODE    = @Ac_ActivityMinor_CODE,
              @Ad_Run_DATE              = @Ld_Temp_DATE,
              @Ad_DueActivity_DATE      = @Ld_DueActivity_DATE OUTPUT,
              @Ad_DueAlertWarn_DATE     = @Ld_DueAlertWarn_DATE OUTPUT,
              @Ac_Msg_CODE              = @Ac_Msg_CODE OUTPUT,
              @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;

             IF @Ac_Msg_CODE != @Lc_StatusSuccess_CODE
              BEGIN
               RAISERROR (50001,16,1)
              END

             IF (@Ld_DueActivity_DATE = CAST(@Ad_Run_DATE AS DATE)
                  OR @Lc_ActionAlert_CODE = 'I')
              BEGIN
               SET @Lc_Status_CODE = @Lc_RemedyStatusComplete_CODE;
               SET @Ld_Status_DATE = @Ad_Run_DATE;
               SET @Lc_ReasonStatus_CODE = @Lc_ReasonStatusSysupd_CODE;
              END
             ELSE
              BEGIN
               SET @Lc_Status_CODE = @Lc_RemedyStatusStart_CODE;
               SET @Ld_Status_DATE = @Ld_High_DATE;
               SET @Lc_ReasonStatus_CODE = @Lc_Space_TEXT;
              END
              
             IF @Ls_CaseJournal_INDC = @Lc_ValueNo_INDC
              BEGIN
               SET @Ls_Sql_TEXT = 'INSERT DMNR_Y1';
               SET @Ls_Sqldata_TEXT = ' Case_IDNO: ' + CAST(@An_Case_IDNO AS CHAR(6)) + ' OrderSeq_NUMB: 0' + ' MajorIntSeq_NUMB: ' + ISNULL(CAST(@Ln_MajorIntSeq_NUMB AS VARCHAR(10)), '') + ' MinorIntSeq_NUMB: ' + ISNULL(CAST(@Ln_MinorIntSeq_NUMB AS VARCHAR(15)), '') + 'TransactionEventSeq_NUMB: ' + CAST(@Ln_TransactionEventSeq_NUMB AS CHAR(19));

               INSERT DMNR_Y1
                      (Case_IDNO,
                       OrderSeq_NUMB,
                       MajorIntSeq_NUMB,
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
                       OUTPUT INSERTED.MinorIntSeq_NUMB INTO @ConcurrenyCheck_P1
               VALUES ( @An_Case_IDNO,
                        0,
                        @Ln_MajorIntSeq_NUMB,
                        (SELECT ISNULL(MAX(nw.MinorIntSeq_NUMB), 0) + 1
						   FROM UDMNR_V1 nw WITH (READUNCOMMITTED)
						  WHERE nw.Case_IDNO = @An_Case_IDNO
						    AND nw.MajorIntSeq_NUMB = @Ln_MajorIntSeq_NUMB),
                        @An_MemberMci_IDNO,
                        @Ac_ActivityMinor_CODE,
                        @Lc_Space_TEXT,
                        @Ad_Run_DATE,
                        @Ld_DueActivity_DATE,
                        @Ld_Status_DATE,
                        @Lc_Status_CODE,
                        @Lc_ReasonStatus_CODE,
                        0,
                        @Ln_Forum_IDNO,
                        @Ln_Topic_IDNO,
                        0,
                        0,
                        0,
                        @Ac_WorkerUpdate_ID,
                        @Ld_System_DTTM,
                        CASE
                         WHEN @Ld_DueAlertWarn_DATE < CAST(@Ad_Run_DATE AS DATE)
                          THEN @Ad_Run_DATE
                         ELSE @Ld_DueAlertWarn_DATE
                        END,
                        @Ad_Run_DATE,
                        @Ac_WorkerUpdate_ID,
                        @Ld_System_DTTM,
                        @Ln_TransactionEventSeq_NUMB,
                        @Ac_WorkerDelegate_ID,
                        @Ac_Subsystem_CODE,
                        @Ac_ActivityMajor_CODE);
                        
               SET @Ln_RowCount_BIT = @@ROWCOUNT;

               IF @Ln_RowCount_BIT = @Li_Zero_NUMB
                BEGIN
                 SET @Ac_Msg_CODE = 'E0113';
                 SET @As_DescriptionError_TEXT = @Ls_Routine_TEXT + @Lc_Space_TEXT + @Ls_Sql_TEXT + @Lc_Space_TEXT + 'INSERT DMNR_Y1 FAILED' + @Lc_Space_TEXT + @Ls_Sqldata_TEXT;
                 RETURN;
                END
              END
             ELSE
              BEGIN
               SET @Ls_Sql_TEXT = 'INSERT CJNR_Y1';
               SET @Ls_Sqldata_TEXT = ' Case_IDNO: ' + CAST(@An_Case_IDNO AS CHAR(6)) + ' OrderSeq_NUMB: 0' + ' MajorIntSeq_NUMB: ' + ISNULL(CAST(@Ln_MajorIntSeq_NUMB AS VARCHAR(10)), '') + ' MinorIntSeq_NUMB: ' + ISNULL(CAST(@Ln_MinorIntSeq_NUMB AS VARCHAR(15)), '') + 'TransactionEventSeq_NUMB: ' + CAST(@Ln_TransactionEventSeq_NUMB AS CHAR(19));
               
               INSERT CJNR_Y1
                      (Case_IDNO,
                       OrderSeq_NUMB,
                       MajorIntSeq_NUMB,
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
                       OUTPUT INSERTED.MinorIntSeq_NUMB INTO @ConcurrenyCheck_P1
               VALUES ( @An_Case_IDNO,
                        0,
                        @Ln_MajorIntSeq_NUMB,
                        (SELECT ISNULL(MAX(nw.MinorIntSeq_NUMB), 0) + 1
						   FROM UDMNR_V1 nw WITH (READUNCOMMITTED)
						  WHERE nw.Case_IDNO = @An_Case_IDNO
						    AND nw.MajorIntSeq_NUMB = @Ln_MajorIntSeq_NUMB),
                        @An_MemberMci_IDNO,
                        @Ac_ActivityMinor_CODE,
                        @Lc_Space_TEXT,
                        @Ad_Run_DATE,
                        @Ld_DueActivity_DATE,
                        @Ld_Status_DATE,
                        @Lc_Status_CODE,
                        @Lc_ReasonStatus_CODE,
                        0,
                        @Ln_Forum_IDNO,
                        @Ln_Topic_IDNO,
                        0,
                        0,
                        0,
                        @Ac_WorkerUpdate_ID,
                        @Ld_System_DTTM,
                        CASE
                         WHEN @Ld_DueAlertWarn_DATE < CAST(@Ad_Run_DATE AS DATE)
                          THEN @Ad_Run_DATE
                         ELSE @Ld_DueAlertWarn_DATE
                        END,
                        @Ad_Run_DATE,
                        @Ac_WorkerUpdate_ID,
                        @Ld_System_DTTM,
                        @Ln_TransactionEventSeq_NUMB,
                        @Ac_WorkerDelegate_ID,
                        @Ac_Subsystem_CODE,
                        @Ac_ActivityMajor_CODE);
                        
               SET @Ln_RowCount_BIT = @@ROWCOUNT;

               IF @Ln_RowCount_BIT = @Li_Zero_NUMB
                BEGIN
                 SET @Ac_Msg_CODE = 'E0113';
                 SET @As_DescriptionError_TEXT = @Ls_Routine_TEXT + @Lc_Space_TEXT + @Ls_Sql_TEXT + @Lc_Space_TEXT + 'INSERT CJNR_Y1 FAILED' + @Lc_Space_TEXT + @Ls_Sqldata_TEXT;
                 RETURN;
                END
              END
              
             SET @Ls_Sql_TEXT = 'SELECT MinorIntSeq_NUMB FROM @ConcurrenyCheck_P1';
			 SELECT @Ln_MinorIntSeq_NUMB = MinorIntSeq_NUMB
			   FROM @ConcurrenyCheck_P1;
              
             IF LTRIM(RTRIM(@As_DescriptionNote_TEXT)) IS NOT NULL
                AND LTRIM(RTRIM(@As_DescriptionNote_TEXT)) != ''
              BEGIN
               SET @Ls_Sql_TEXT = 'INSERT NOTE_Y1';
               SET @Ls_Sqldata_TEXT = 'Case_IDNO ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '') + ' Topic_IDNO' + ISNULL(CAST(@Ln_Topic_IDNO AS VARCHAR), '') + 'ActivityMinor_CODE :' + @Ac_ActivityMinor_CODE;

               INSERT INTO NOTE_Y1
                           (Case_IDNO,
                            Topic_IDNO,
                            Post_IDNO,
                            MajorIntSeq_NUMB,
                            MinorIntSeq_NUMB,
                            Office_IDNO,
                            Category_CODE,
                            Subject_CODE,
                            CallBack_INDC,
                            NotifySender_INDC,
                            TypeContact_CODE,
                            SourceContact_CODE,
                            MethodContact_CODE,
                            Status_CODE,
                            TypeAssigned_CODE,
                            WorkerAssigned_ID,
                            RoleAssigned_ID,
                            WorkerCreated_ID,
                            Start_DATE,
                            Due_DATE,
                            Action_DATE,
                            Received_DATE,
                            OpenCases_CODE,
                            DescriptionNote_TEXT,
                            BeginValidity_DATE,
                            EndValidity_DATE,
                            WorkerUpdate_ID,
                            TransactionEventSeq_NUMB,
                            EventGlobalSeq_NUMB,
                            Update_DTTM,
                            TotalReplies_QNTY,
                            TotalViews_QNTY)
                    VALUES ( @An_Case_IDNO,
                             @Ln_Topic_IDNO,
                             1,
                             @Ln_MajorIntSeq_NUMB,
                             @Ln_MinorIntSeq_NUMB,
                             @Li_Zero_NUMB,
                             @Ac_Subsystem_CODE,
                             @Ac_ActivityMinor_CODE,
                             @Lc_Space_TEXT,
                             @Lc_ValueNo_INDC,
                             @Lc_Space_TEXT,
                             @Lc_Space_TEXT,
                             @Lc_Space_TEXT,
                             @Lc_Space_TEXT,
                             @Lc_Space_TEXT,
                             @Lc_Space_TEXT,
                             @Lc_Space_TEXT,
                             @Ac_WorkerUpdate_ID,
                             @Ld_Low_DATE,
                             @Ld_Low_DATE,
                             @Ld_High_DATE,
                             @Ld_High_DATE,
                             @Lc_Space_TEXT,
                             @As_DescriptionNote_TEXT,
                             @Ad_Run_DATE,
                             @Ld_High_DATE,
                             @Ac_WorkerUpdate_ID,
                             @Ln_TransactionEventSeq_NUMB,
                             0,
                             @Ld_System_DTTM,
                             @Li_Zero_NUMB,
                             @Li_Zero_NUMB );

               IF @@ROWCOUNT = 0
                BEGIN
                 SET @Ac_Msg_CODE = 'E0113';
                 SET @As_DescriptionError_TEXT = @Ls_Routine_TEXT + @Lc_Space_TEXT + @Ls_Sql_TEXT + @Lc_Space_TEXT + 'NOTE_Y1 INSERT FAILED' + @Lc_Space_TEXT + @Ls_Sqldata_TEXT;
                 RETURN;
                END
              END
            END
           ELSE
            BEGIN
             SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
             SET @As_DescriptionError_TEXT = @Ls_Routine_TEXT + @Lc_Space_TEXT + @Ls_Sql_TEXT + @Lc_Space_TEXT + 'Topic_IDNO Sent As 0, Where As The Given Combination Have Record In DMNR_Y1' + @Lc_Space_TEXT + @Ls_Sqldata_TEXT;
             RETURN;
            END
          END
        END
       ELSE
        BEGIN
         SET @Ln_Topic_IDNO = @An_TopicIn_IDNO;
         SET @Ln_MajorIntSeq_NUMB = @An_MajorIntSeq_NUMB;
         SET @Ln_MinorIntSeq_NUMB = @An_MinorIntSeq_NUMB;
        END
      END
      ELSE
      BEGIN
         SET @Ln_MajorIntSeq_NUMB = @An_MajorIntSeq_NUMB;
         SET @Ln_MinorIntSeq_NUMB = @An_MinorIntSeq_NUMB;
      END
    END
   ELSE
    BEGIN
     SET @Ln_MajorIntSeq_NUMB = @An_MajorIntSeq_NUMB;
     SET @Ln_MinorIntSeq_NUMB = @An_MinorIntSeq_NUMB;
    END
   
   -- 13644 - CR0417 Fed Cert Finding 4.11 Follow up on Manual Locate Requests - Start
   -- Call alert worker batch to generate alerts. 
   IF (ISNULL(@Ac_WorkerDelegate_ID, '') = '' 
		AND @Ac_ActivityMajor_CODE = @Lc_ActivityMajorCase_CODE
		AND EXISTS ( SELECT 1
					   FROM AMNR_Y1 a
					  WHERE a.ActivityMinor_CODE = @Ac_ActivityMinor_CODE
					    AND a.EndValidity_DATE = @Ld_High_DATE
					    AND a.ActionAlert_CODE != @Lc_ActionAlertNo_CODE))
	BEGIN
		SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_ALERT_WORKER';
		SET @Ls_Sqldata_TEXT = 'An_Case_IDNO : ' + CAST(@An_Case_IDNO AS CHAR(6)) + ' Ac_Subsystem_CODE : ' + @Ac_Subsystem_CODE + ' As_ActivityMajor_CODE : ' + @Ac_ActivityMajor_CODE + ' As_ActivityMinor_CODE : ' 
			+ @Ac_ActivityMinor_CODE + ' @Ac_Worker_Signedon_ID : ' + ISNULL(@Ac_WorkerUpdate_ID, '') + ' An_TransactionEventSeq_NUMB : ' + CAST(@Ln_TransactionEventSeq_NUMB AS CHAR(19)) + ' Ad_Run_DATE : ' + CAST(@Ad_Run_DATE AS VARCHAR) 
			+ ' Ac_Worker_ID: ' + ISNULL(@Ac_WorkerDelegate_ID, '')+ ' Ln_MajorIntSeq_NUMB: '+CAST(ISNULL(@Ln_MajorIntSeq_NUMB,0) AS CHAR(6))+ ' Ln_MinorIntSeq_NUMB: '+CAST(ISNULL(@Ln_MinorIntSeq_NUMB,0) AS CHAR(6));
		

		/* The SP_CASE_ASSIGN_REASSIGN PROCEDURE is called to insert a worker in CWRK_Y1,
		if a worker with a role that matches with the role for the activity in ACRL_Y1 does not exist */
		EXECUTE BATCH_COMMON$SP_ALERT_WORKER
		@An_Case_IDNO                = @An_Case_IDNO,
		@Ac_Subsystem_CODE           = @Ac_Subsystem_CODE,
		@Ac_ActivityMajor_CODE       = @Ac_ActivityMajor_CODE,
		@Ac_ActivityMinor_CODE       = @Ac_ActivityMinor_CODE,
		@An_MajorIntSeq_NUMB		 = @Ln_MajorIntSeq_NUMB,
		@An_MinorIntSeq_NUMB		 = @Ln_MinorIntSeq_NUMB,
		@Ac_SignedonWorker_ID        = @Ac_WorkerUpdate_ID,
		@An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
		@Ad_Run_DATE                 = @Ad_Run_DATE,
		@Ac_Job_ID                   = @Ac_Job_ID,
		@Ac_Worker_ID                = @Ac_WorkerDelegate_ID,
		@Ac_Msg_CODE                 = @Ac_Msg_CODE OUTPUT,
		@As_DescriptionError_TEXT    = @As_DescriptionError_TEXT OUTPUT;

		IF @Ac_Msg_CODE != @Lc_StatusSuccess_CODE
		BEGIN
		 SET @As_DescriptionError_TEXT = @Ls_Routine_TEXT + ' ' + 'BATCH_COMMON$SP_ALERT_WORKER FAILED' + ' ' + @Ls_Sqldata_TEXT + ' ' + ISNULL(@As_DescriptionError_TEXT, '');
		 RETURN;
		END;
	END
	-- 13644 - CR0417 Fed Cert Finding 4.11 Follow up on Manual Locate Requests - End
	
   IF @An_BarcodeIn_NUMB = 0
    BEGIN
     -- Insert Notices for the Minor Activity
     -- Generating Notices From Batch other than Activity Chains related
     IF @Ac_Notice_ID != ''
      BEGIN
       SET @Ln_Notice_Count = 1;

       DECLARE activity_forms_cur CURSOR LOCAL FORWARD_ONLY FOR
        SELECT @Ac_Notice_ID;
      END
     -- Generating Notices Through Flow Logic
     ELSE IF (@An_TopicIn_IDNO != 0
         AND @Ac_Notice_ID = ''
         AND @As_Xml_TEXT != ' ')
      BEGIN
       SET @Ln_MajorIntSeq_NUMB = @An_MajorIntSeq_NUMB;
       
       SET @Ls_Sql_TEXT = 'EXECUTE BATCH_COMMON$SP_LOAD_NOTICE_XML_DATA';
       EXEC BATCH_COMMON$SP_LOAD_NOTICE_XML_DATA
        @As_Notice_XML            = @As_Xml_TEXT,
        @Ac_Msg_CODE              = @Ac_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;

       IF @Ac_Msg_CODE != @Lc_StatusSuccess_CODE 
        BEGIN
         RAISERROR (50001,16,1)
        END

       IF (SELECT COUNT(1)
             FROM #NoticeInput_P1) = 0
        BEGIN
         SET @Ac_Msg_CODE = 'E1000';
         SET @As_DescriptionError_TEXT = 'Documents cannot be generated without recipients';
         RETURN;
        END

       SET @Lc_Notice_Generate_INDC = @Lc_Notice_GenerateYesINDC;
       SET @Ln_Topic_IDNO = @An_TopicIn_IDNO;
      END
     ELSE IF @Ac_ActivityMajor_CODE = @Lc_ActivityMajorCase_CODE
        AND @An_TopicIn_IDNO != 0
        AND @Ac_Notice_ID = ''
        AND @As_Xml_TEXT = ' '
      BEGIN
       SET @Ls_Sql_TEXT = 'INSERT FORM_Y1 - 2 '
       SET @Ls_Sqldata_TEXT = 'Topic_IDNO: ' + ISNULL(CAST(@An_TopicIn_IDNO AS VARCHAR(19)), '')

       INSERT INTO FORM_Y1
                   (Topic_IDNO,
                    Notice_ID,
                    Recipient_CODE,
                    WorkerRqst_ID,
                    Barcode_NUMB)
       SELECT @Ln_Topic_IDNO,
              Notice_ID,
              Recipient_CODE,
              WorkerRqst_ID,
              Barcode_NUMB
         FROM FORM_Y1
        WHERE Topic_IDNO = @An_TopicIn_IDNO;

       SET @Ln_RowCount_BIT = @@ROWCOUNT;

       IF @Ln_RowCount_BIT = @Li_Zero_NUMB
        BEGIN
         SET @Ac_Msg_CODE = 'E0113';
         SET @As_DescriptionError_TEXT = @Ls_Routine_TEXT + @Lc_Space_TEXT + @Ls_Sql_TEXT + @Lc_Space_TEXT + 'FORM_Y1 INSERT FAILED' + @Lc_Space_TEXT + @Ls_Sqldata_TEXT;
         RETURN;
        END
      END
     -- Notice Generation for Activity Chains From Batch
     ELSE IF @Ac_ActivityMajor_CODE != @Lc_ActivityMajorCase_CODE
        AND @An_TopicIn_IDNO != 0
        AND @Ac_Notice_ID = ''
        AND @As_Xml_TEXT = ' '
      BEGIN
       SET @Ln_MajorIntSeq_NUMB = @An_MajorIntSeq_NUMB;
       SET @Ln_Topic_IDNO = @An_TopicIn_IDNO;
       
       SELECT @Ln_Notice_Count = COUNT(1)
                  FROM AFMS_Y1 AS a
                 WHERE a.ActivityMajor_CODE = @Ac_ActivityMajor_CODE
                   AND a.ActivityMinor_CODE = @Ac_ActivityMinor_CODE
                   AND a.Reason_CODE = @Lc_ReasonStatus_CODE
                   AND a.Notice_ID <> @Lc_Space_TEXT
                   AND a.EndValidity_DATE =  @Ld_High_DATE

       DECLARE activity_forms_cur CURSOR LOCAL FORWARD_ONLY FOR
        SELECT fci.Notice_ID
          FROM (SELECT DISTINCT
                       LTRIM(RTRIM(a.Notice_ID)) AS Notice_ID,
                       a.NoticeOrder_NUMB
                  FROM AFMS_Y1 AS a
                 WHERE a.ActivityMajor_CODE = @Ac_ActivityMajor_CODE
                   AND a.ActivityMinor_CODE = @Ac_ActivityMinor_CODE
                   AND a.Reason_CODE = @Lc_ReasonStatus_CODE
                   AND a.Notice_ID <> @Lc_Space_TEXT
                   AND a.EndValidity_DATE =  @Ld_High_DATE) AS fci
         ORDER BY fci.NoticeOrder_NUMB;
      END

     IF @Ln_Notice_Count > 0
      BEGIN
       SET @Ls_Sql_TEXT = 'OPEN activity_forms_cur';

       OPEN activity_forms_cur

       SET @Ls_Sql_TEXT = 'FETCH activity_forms_cur - 1';

       FETCH activity_forms_cur INTO @Lc_Activity_Forms$Notice_ID;

       SELECT @Ln_FetchStatus_BIT = @@Fetch_status;

       WHILE @Ln_FetchStatus_BIT = 0
        BEGIN
         IF @Ac_ActivityMajor_CODE IN (@Lc_ActivityMajorCase_CODE, '')
          BEGIN
           SET @Ls_Sql_TEXT = 'SELECT NREP_Y1';
           SET @Ls_Sqldata_TEXT = 'Notice_ID: ' + @Lc_Activity_Forms$Notice_ID;

           SELECT @Ln_Recipient_QNTY = COUNT (a.Recipient_CODE)
             FROM NREP_Y1 AS a
            WHERE a.Notice_ID = @Lc_Activity_Forms$Notice_ID
              AND a.EndValidity_DATE = @Ld_High_DATE;

			 IF @Ln_Recipient_QNTY = 0
			  BEGIN
			   SET @Ac_Msg_CODE = 'E1065';
			   SET @As_DescriptionError_TEXT = 'NO RECIPIENTS FOR THE NOTICE';

			   RAISERROR (50001,16,1);
			  END
		   END

         SET @Ls_Sql_TEXT = 'BATCH_GEN_NOTICE_UTIL$SP_GET_RECIPIENT_CODE_LIST';
         SET @Ls_Sqldata_TEXT = ' Case_IDNO: ' + CAST(@An_Case_IDNO AS CHAR(6)) + ' MemberMci_IDNO: ' + CAST(@An_MemberMci_IDNO AS VARCHAR(10)) + ' OthpSource_IDNO: ' + ISNULL(CAST(@An_OthpSource_IDNO AS VARCHAR), '') + ' Notice_ID: ' + @Lc_Activity_Forms$Notice_ID + ' IVDOutOfStateFips_CODE: ' + ISNULL(@Ac_IVDOutOfStateFips_CODE, '') + ' MajorIntSeq_NUMB: ' + ISNULL(CAST(@Ln_MajorIntSeq_NUMB AS VARCHAR(10)), '') + ' StatusApproval_CODE: ' + ISNULL(@Lc_StatusApprvlRegular_CODE, '') + ' ActivityMajor_CODE: ' + @Ac_ActivityMajor_CODE + ' ActivityMinor_CODE: ' + @Ac_ActivityMinor_CODE + ' ReasonStatus_CODE: ' + ISNULL(@Lc_ReasonStatus_CODE, '');
         INSERT INTO @Lref_Recipient_P1
         EXECUTE BATCH_GEN_NOTICE_UTIL$SP_GET_RECIPIENT_CODE_LIST
          @An_Case_IDNO             = @An_Case_IDNO,
          @An_MemberMci_IDNO        = @An_MemberMci_IDNO,
          @Ac_Notice_ID             = @Lc_Activity_Forms$Notice_ID,
          @An_OthpSource_IDNO       = @An_OthpSource_IDNO,
          @Ac_ActivityMajor_CODE    = @Ac_ActivityMajor_CODE,
          @Ac_ActivityMinor_CODE    = @Ac_ActivityMinor_CODE,
          @Ac_ReasonStatus_CODE     = @Lc_ReasonStatus_CODE,
          @Ac_StatusApproval_CODE   = @Lc_StatusApprvlRegular_CODE,
          @An_MajorIntSeq_NUMB      = @Ln_MajorIntSeq_NUMB,
          @Ac_IVDOutOfStateFips_CODE= @Ac_IVDOutOfStateFips_CODE,
          @Ac_Receipt_ID            = '',
          @Ac_RecipentType_ID       = @Ac_TypeReference_CODE,
          @Ac_Msg_CODE              = @Ac_Msg_CODE OUTPUT,
          @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;

		 SET @Ln_RecipientCount_NUMB = @@ROWCOUNT;

         IF @Ac_Msg_CODE <> @Lc_StatusSuccess_CODE
          BEGIN
           SET @Ac_Msg_CODE = 'E1000';
           SET @As_DescriptionError_TEXT = @Ls_Routine_TEXT + ' ' + 'BATCH_GEN_NOTICE_UTIL$SP_GET_RECIPIENT_CODE_LIST FAILED' + ' ' + @Ls_Sqldata_TEXT + ' ' + ISNULL(@As_DescriptionError_TEXT, '');
           RETURN;
          END

         IF @Ln_RecipientCount_NUMB = 0
          BEGIN
           SET @Ac_Msg_CODE = 'E1000';
           SET @As_DescriptionError_TEXT = @Ls_Routine_TEXT + ' ' + 'BATCH_GEN_NOTICE_UTIL$SP_GET_RECIPIENT_CODE_LIST RETURNED ZERO RECORDS' + ' ' + @Ls_Sqldata_TEXT + ' ' + ISNULL(@As_DescriptionError_TEXT, '');
           RETURN;
          END

         SET @Lref_RecipientRcur_CUR = CURSOR
         FOR SELECT @Lc_Activity_Forms$Notice_ID,
                    Recipient_CODE,
                    Recipient_ID
               FROM @Lref_Recipient_P1;
         SET @Ls_Sql_TEXT='OPEN @Lref_RecipientRcur_CUR -1';

         OPEN @Lref_RecipientRcur_CUR;

         SET @Ls_Sql_TEXT='FETCH @Lref_RecipientRcur_CUR -1';

         FETCH @Lref_RecipientRcur_CUR INTO @Lc_Notice_ID, @Lc_Recipient_CODE, @Lc_Recipient_ID;

         SELECT @Ln_FetchStatus_BIT = @@Fetch_status;

         SET @Ls_Sql_TEXT='WHILE LOOP -1';

         WHILE @Ln_FetchStatus_BIT = 0
          BEGIN
           SET @Ln_RecpAddrCursor_QNTY = 0

           BEGIN
            SET @Ls_Sql_TEXT = 'BATCH_GEN_NOTICE_UTIL$SP_GET_RECIPIENT_ADDRESS';
            SET @Ls_Sqldata_TEXT = ' Notice_ID: ' + ISNULL(@Lc_Notice_ID, '') + ' Recipient_ID: ' + ISNULL(CAST(@Lc_Recipient_ID AS VARCHAR(10)), '');

            INSERT INTO @Lref_ArefRecipient_P1
            EXECUTE BATCH_GEN_NOTICE_UTIL$SP_GET_RECIPIENT_ADDRESS
             @Ac_Notice_ID             = @Lc_Notice_ID,
             @An_Case_IDNO			   = @An_Case_IDNO,
             @Ac_Recipient_ID          = @Lc_Recipient_ID,
             @Ac_Recipient_CODE        = @Lc_Recipient_CODE,
             @Ad_Run_DATE              = @Ad_Run_DATE,
             @Ac_Msg_CODE              = @Ac_Msg_CODE OUTPUT,
             @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;

            IF @Ac_Msg_CODE <> @Lc_StatusSuccess_CODE
             BEGIN
              SET @Ac_Msg_CODE = 'E1001';
              SET @As_DescriptionError_TEXT = @Ls_Routine_TEXT + ' ' + 'BATCH_GEN_NOTICE_UTIL$SP_GET_RECIPIENT_ADDRESS FAILED' + ' ' + @Ls_Sqldata_TEXT + ' ' + ISNULL(@As_DescriptionError_TEXT, '');
              RETURN;
             END

            SELECT @Ln_RecipientAddressCount_NUMB = COUNT(1)
              FROM @Lref_ArefRecipient_P1
             WHERE Ind_ADDR = 1;

            IF @Ln_RecipientAddressCount_NUMB = 0
             BEGIN
              SET @Ac_Msg_CODE = 'E1001';
              SET @As_DescriptionError_TEXT = @Ls_Routine_TEXT + ' ' + 'BATCH_GEN_NOTICE_UTIL$SP_GET_RECIPIENT_ADDRESS RETURNED ZERO RECORDS' + ' ' + @Ls_Sqldata_TEXT+ ' ' + ISNULL(@As_DescriptionError_TEXT, '');
              RETURN;
             END
             
             SET @Ls_Xml_TEXT = CASE WHEN CHARINDEX('<InputParameters>', @As_Xml_TEXT, 0) != 0
													   THEN @As_Xml_TEXT
													   ELSE ''
								END
			
			SET @Ls_Sql_TEXT = 'INSERT #NoticeInput_P1 FROM @Lref_Recipient_P1 AND @Lref_ArefRecipient_P1';
            SET @Ls_Sqldata_TEXT = 'Recipient_ID :' + @Lc_Recipient_ID + ' Notice_ID :' + @Lc_Notice_ID;									
             
             INSERT INTO #NoticeInput_P1
                       (Notice_ID,
                        Recipient_CODE,
                        Recipient_ID,
                        TypeService_CODE,
                        PrintMethod_CODE,
                        Addr_Type_CODE,
                        Barcode_Numb,
                        Input_Parameters_TEXT)
           SELECT @Lc_Activity_Forms$Notice_ID,
                  r.Recipient_CODE,
                  r.Recipient_ID,
                  r.TypeService_CODE,
                  r.PrintMethod_CODE,
                  a.TypeAddress_CODE,
                  0,
                  @Ls_Xml_TEXT
             FROM @Lref_Recipient_P1 r
             JOIN @Lref_ArefRecipient_P1 a
               ON @Lc_Recipient_ID = r.Recipient_ID
              AND a.Ind_ADDR = 1;

              IF @@ROWCOUNT = @Li_Zero_NUMB
               BEGIN
                -- 13545	Bug	Invalid error codes inserted into BATE	-- Starts
                SET @Ac_Msg_CODE = 'E1001';
                -- 13545	Bug	Invalid error codes inserted into BATE	-- Ends
                SET @As_DescriptionError_TEXT = @Ls_Routine_TEXT + @Lc_Space_TEXT + @Ls_Sql_TEXT + @Lc_Space_TEXT + 'INSERT #NoticeInput_P1 FAILED from Address Service' + @Lc_Space_TEXT + @Ls_Sqldata_TEXT;
                RETURN;
               END

              SET @Lc_Notice_Generate_INDC = @Lc_Notice_GenerateYesINDC;
              DELETE FROM @Lref_ArefRecipient_P1;
           END

           SET @Ls_Sql_TEXT='FETCH @Lref_RecipientRcur_CUR -2';

           FETCH @Lref_RecipientRcur_CUR INTO @Lc_Notice_ID, @Lc_Recipient_CODE, @Lc_Recipient_ID;

           SELECT @Ln_FetchStatus_BIT = @@Fetch_status;
          END

         CLOSE @Lref_RecipientRcur_CUR;

         DEALLOCATE @Lref_RecipientRcur_CUR;

		 DELETE FROM @Lref_Recipient_P1;
         SET @Ls_Sql_TEXT = 'FETCH activity_forms_cur - 2';

         FETCH activity_forms_cur INTO @Lc_Activity_Forms$Notice_ID

         SELECT @Ln_FetchStatus_BIT = @@Fetch_status
        END

       CLOSE activity_forms_cur;

       DEALLOCATE activity_forms_cur;
      END
    END
   ELSE
    BEGIN
     INSERT INTO #NoticeInput_P1
     SELECT Notice_ID,
            Recipient_CODE,
            Recipient_ID,
            TypeService_CODE,
            'L' AS PrintMethod_CODE,
            '' AS Addr_Type_CODE,
            @An_BarcodeIn_NUMB,
            ''
       FROM NRRQ_y1
      WHERE Barcode_NUMB = @An_BarcodeIn_NUMB;

     SET @Lc_Notice_Generate_INDC = @Lc_Notice_GenerateYesINDC;
     SET @Ln_BarcodeIn_NUMB = @An_BarcodeIn_NUMB;
    END

   -- Code for Handling Eportal STARTS
   -- Generate the Eportal notice electronically when the notice is getting generated for that particular recipient
   IF @An_BarcodeIn_NUMB = 0
    BEGIN
         INSERT INTO #NoticeInput_P1
         SELECT Notice_ID,
				Recipient_CODE,
				Recipient_ID,
				'O' AS TypeService_CODE,
				'E' AS PrintMethod_CODE,
				Addr_Type_CODE,
				Barcode_Numb,
				Input_Parameters_TEXT
		   FROM #NoticeInput_P1
		  WHERE Recipient_CODE IN ('DG', 'FC', 'FI', 'FS','HA', 'IC', 'NA', 'OE','PA', 'PU', 'SI', 'SS','WR', 'FR_3')
		    AND EXISTS (SELECT 1
							FROM REFM_Y1
						   WHERE Table_ID = 'EPOR'
							 AND TableSub_ID = 'FORM'
							 AND Value_code = Notice_ID)
			AND EXISTS (SELECT 1
							FROM OTHP_Y1
						   WHERE EportalSubscription_INDC = 'Y'
							 AND ReceivePaperForms_INDC ='Y'
							 -- 13577 Notices are failing for International Other state receiptient Fix - Start
							 AND OtherParty_IDNO = CASE WHEN ISNUMERIC( @Lc_Recipient_ID  ) = 1 THEN @Lc_Recipient_ID  ELSE 0 END);
							 -- 13577 Notices are failing for International Other state receiptient Fix - End
    END

   -- Code for Handling Eportal ENDS
   IF @Lc_Notice_Generate_INDC = @Lc_Notice_GenerateYesINDC
    BEGIN
     SET @Lref_Notice_CUR = CURSOR
     FOR SELECT Notice_ID,
                Recipient_CODE,
                Recipient_ID,
                TypeService_CODE,
                PrintMethod_CODE,
                Addr_Type_CODE,
                Barcode_Numb,
                Input_Parameters_TEXT
           FROM #NoticeInput_P1;
     SET @Ls_Sql_TEXT = 'OPEN @Lref_Notice_CUR -1';

     OPEN @Lref_Notice_CUR;

     SET @Ls_Sql_TEXT = 'FETCH @Lref_Notice_CUR -1';

     FETCH @Lref_Notice_CUR INTO @La_Notice_ID, @Lc_Recipient_CODE, @Lc_Recipient_ID, @Lc_TypeService_CODE, @La_PrintMethod_CODE, @La_Addr_Type_CODE, @Ln_Barcode_NUMB, @La_Input_Parameters_TEXT;

     SELECT @Ln_FetchStatus_BIT = @@Fetch_status;

     SET @Ls_Sql_TEXT='WHILE LOOP -1';

     WHILE @Ln_FetchStatus_BIT = 0
      BEGIN
       -- If a notice returns an error xml, then the same notice with another recipient should not be called
       IF @Ac_Msg_CODE = 'E1081'
          AND @Lc_Previous_Notice_ID = @La_Notice_ID
        BEGIN
         GOTO NextNotice;
        END

       IF (@Lc_Previous_Notice_ID IS NULL
            OR @Lc_Previous_Notice_ID != @La_Notice_ID)
          AND @La_Addr_Type_CODE != ''
        BEGIN
         SET @Lc_Previous_Notice_ID = @La_Notice_ID;

         IF @Ln_Barcode_NUMB != 0
            AND ISNUMERIC(@La_Notice_ID) = 0
          BEGIN
           SET @Ln_BarcodeIn_NUMB = @Ln_Barcode_NUMB;
          END
         ELSE
          BEGIN
           SET @Ln_BarcodeIn_NUMB = 0;
          END
        END

       IF @Ln_BarcodeIn_NUMB != 0 AND (@La_Input_Parameters_TEXT = '' OR @La_Input_Parameters_TEXT IS NULL)
        BEGIN
         SET @La_Input_Parameters_TEXT = '';
        END

       SET @Ls_Sql_TEXT = 'BATCH_GEN_NOTICES$SP_GENERATE_NOTICE'
       SET @Ls_Sqldata_TEXT = ' Case_IDNO: ' + CAST(@An_Case_IDNO AS CHAR(6)) + ' OrderSeq_NUMB: ' + ISNULL(CAST(@An_OrderSeq_NUMB AS VARCHAR(9)), '') + ' MemberMci_IDNO: ' + ISNULL(CAST(@An_MemberMci_IDNO AS VARCHAR(10)), '') + ' ID_WORKER_SIGNEDON: ' + ISNULL(@Ac_WorkerUpdate_ID, '') + ' Notice_ID: ' + ISNULL(@La_Notice_ID, '') + ' StatusNotice_CODE: ' + ISNULL(@La_PrintMethod_CODE, '') + ' BARCODEIN: ' + ISNULL(CAST(@Ln_BarcodeIn_NUMB AS VARCHAR(15)), '') + ' XML_TEXTIN: NULL' + ' Schedule_NUMB: ' + ISNULL(CAST(@An_Schedule_NUMB AS VARCHAR(10)), '') + ' Recipient_ID: ' + ISNULL(CAST(@Lc_Recipient_ID AS VARCHAR(10)), '') + ' Recipient_CODE: ' + ISNULL(@Lc_Recipient_CODE, '') + ' CD_TYPE_ADDRESS_RECIPIENT: ' + ISNULL(@La_Addr_Type_CODE, '') + ' MajorIntSeq_NUMB: ' + ISNULL(CAST(@Ln_MajorIntSeq_NUMB AS VARCHAR(10)), '') + ' MinorIntSeq_NUMB: ' + ISNULL(CAST(@Ln_MinorIntSeq_NUMB AS VARCHAR(10)), '') + ' CD_STATUS_APPROVAL: ' + ISNULL(@Lc_StatusApprvlRegular_CODE, '') + ' ReasonStatus_CODE: ' + ISNULL(@Lc_ReasonStatus_CODE, '') + ' Run_DATE: ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR(20)), '') + ' Job_IDNO: ' + ISNULL(@Ac_Job_ID, '') + ' Package_IDNO: NULL' + ' STATUS_APPROVAL: NULL' + ' SERVICE_TYPE: ' + ISNULL(@Lc_TypeService_CODE, '') + ' TransactionEventSeq_NUMB: ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR(15)), '')

       EXECUTE BATCH_GEN_NOTICES$SP_GENERATE_NOTICE
        @An_Case_IDNO                = @An_Case_IDNO,
        @Ac_Notice_ID                = @La_Notice_ID,
        @Ac_Worker_ID                = @Ac_WorkerUpdate_ID,
        @An_MemberMci_IDNO           = @An_MemberMci_IDNO,
        @An_OthpSource_IDNO          = @An_OthpSource_IDNO,
        @Ac_Reference_ID             = @Ac_Reference_ID,
        @Ad_Generate_DATE            = @Ad_Run_DATE,
        @An_Barcode_NUMB             = @Ln_BarcodeIn_NUMB,
        @Ac_Recipient_CODE           = @Lc_Recipient_CODE,
        @Ac_Recipient_ID             = @Lc_Recipient_ID,
        @Ac_ActivityMajor_CODE       = @Ac_ActivityMajor_CODE,
        @Ac_ActivityMinor_CODE       = @Ac_ActivityMinor_CODE,
        @Ac_ReasonStatus_CODE        = @Lc_ReasonStatus_CODE,
        @An_MajorIntSeq_NUMB         = @Ln_MajorIntSeq_NUMB,
        @An_MinorIntSeq_NUMB         = @An_MinorIntSeq_NUMB,
        @An_Schedule_NUMB            = @An_Schedule_NUMB,
        @Ad_Schedule_DATE            = @Ad_Schedule_DATE,
        @Ad_BeginSch_DTTM            = @Ad_BeginSch_DTTM,
        @An_OthpLocation_IDNO        = @An_OthpLocation_IDNO,
        @Ac_ScheduleWorker_ID        = @Ac_ScheduleWorker_ID,
        @As_ScheduleListMemberMci_ID = @As_ScheduleListMemberMci_ID,
        @An_TransHeader_IDNO         = @An_TransHeader_IDNO,
        @Ac_PrintMethod_CODE         = @La_PrintMethod_CODE,
        @Ac_TypeService_CODE         = @Lc_TypeService_CODE,
        @Ac_TypeAddress_CODE         = @La_Addr_Type_CODE,
        @An_OrderSeq_NUMB            = @An_OrderSeq_NUMB,
        @As_XmlInput_TEXT            = @La_Input_Parameters_TEXT,
        @Ac_Job_ID                   = @Ac_Job_ID,
        @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
        @An_BarcodeOut_NUMB          = @Ln_BarcodeOut_NUMB OUTPUT,
        @As_XmlOut_Text              = @Ls_XmlOut_Text OUTPUT,
        @Ac_Msg_CODE                 = @Ac_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT    = @As_DescriptionError_TEXT OUTPUT;

       IF @Ac_Msg_CODE IN (@Lc_StatusFailed_CODE, 'E0077', 'E1056')
        BEGIN
         RAISERROR(50001,16,1);
        END
       ELSE
        BEGIN
         INSERT INTO @NoticeOutput_P1
                     (Notice_ID,
                      Recipient_CODE,
                      Recipient_ID,
                      TypeService_CODE,
                      PrintMethod_CODE,
                      Addr_Type_CODE,
                      Input_Parameters_TEXT,
                      BarcodeOut_NUMB,
                      XmlOut_Text,
                      Msg_CODE,
                      DescriptionError_TEXT)
              VALUES(@La_Notice_ID,
                     @Lc_Recipient_CODE,
                     @Lc_Recipient_ID,
                     @Lc_TypeService_CODE,
                     @La_PrintMethod_CODE,
                     @La_Addr_Type_CODE,
                     @La_Input_Parameters_TEXT,
                     @Ln_BarcodeOut_NUMB,
                     @Ls_XmlOut_Text,
                     @Ac_Msg_CODE,
                     @As_DescriptionError_TEXT);

         -- Insert Into FORM_Y1 Starts
         IF @Ac_Msg_CODE NOT IN ('E1081', 'R')
            AND @Ln_Topic_IDNO IS NOT NULL
          BEGIN
           SET @Ls_Sql_TEXT = 'INSERT FORM_Y1 - 1';
           SET @Ls_Sqldata_TEXT = 'Topic_IDNO: ' + ISNULL(CAST(@Ln_Topic_IDNO AS VARCHAR(19)), '') + ' Notice_ID: ' + @Ac_Notice_ID + ' WorkerRqst_ID: ' + @Ac_WorkerUpdate_ID + ' Recipient_CODE: ' + ISNULL(@Lc_Recipient_CODE, '') + ' Barcode_NUMB: ' + ISNULL(CAST(@Ln_BarcodeOut_NUMB AS VARCHAR(19)), '');

           INSERT INTO FORM_Y1
                       (Topic_IDNO,
                        Notice_ID,
                        WorkerRqst_ID,
                        Recipient_CODE,
                        Barcode_NUMB)
                VALUES ( @Ln_Topic_IDNO,
                         UPPER(@La_Notice_ID),
                         @Ac_WorkerUpdate_ID,
                         SUBSTRING(@Lc_Recipient_CODE, 1, 2),
                         @Ln_BarcodeOut_NUMB);

           SET @Ln_RowCount_BIT = @@ROWCOUNT;

           IF @Ln_RowCount_BIT = @Li_Zero_NUMB
            BEGIN
             SET @Ac_Msg_CODE = 'E0113';
             SET @As_DescriptionError_TEXT = @Ls_Routine_TEXT + @Lc_Space_TEXT + @Ls_Sql_TEXT + @Lc_Space_TEXT + 'FORM_Y1 INSERT FAILED' + @Lc_Space_TEXT + @Ls_Sqldata_TEXT
             RETURN;
            END
          END
        -- Insert Into FORM_Y1 Ends
        END

       SET @Ln_BarcodeIn_NUMB = @Ln_BarcodeOut_NUMB;

       NEXTNOTICE:

       SET @Ls_Sql_TEXT = 'FETCH @Lref_Notice_CUR -1';

       FETCH @Lref_Notice_CUR INTO @La_Notice_ID, @Lc_Recipient_CODE, @Lc_Recipient_ID, @Lc_TypeService_CODE, @La_PrintMethod_CODE, @La_Addr_Type_CODE, @Ln_Barcode_NUMB, @La_Input_Parameters_TEXT;

       SELECT @Ln_FetchStatus_BIT = @@Fetch_status;
      END

     CLOSE @Lref_Notice_CUR;

     DEALLOCATE @Lref_Notice_CUR;

     -- Get the Notice error count
     SELECT @Ln_NoticeError_NUMB = COUNT(1)
       FROM @NoticeOutput_P1
      WHERE Msg_CODE IN ('E1081', 'R');

     IF @Ln_NoticeError_NUMB > 0
      BEGIN
       SET @Ac_Msg_CODE = 'E1081';
       SET @As_DescriptionError_TEXT = '<notices>';
       SET @Lref_NoticeOut_CUR = CURSOR
       FOR SELECT Notice_ID,
                  Recipient_CODE,
                  PrintMethod_CODE,
                  BarcodeOut_NUMB,
                  XmlOut_Text,
                  Msg_CODE,
                  DescriptionError_TEXT
             FROM @NoticeOutput_P1
            WHERE Msg_CODE IN ('E1081', 'R');
       SET @Ls_Sql_TEXT = 'OPEN @Lref_NoticeOut_CUR -1';

       OPEN @Lref_NoticeOut_CUR;

       SET @Ls_Sql_TEXT = 'FETCH @Lref_NoticeOut_CUR -1';

       FETCH @Lref_NoticeOut_CUR INTO @La_Notice_ID, @Lc_Recipient_CODE, @La_PrintMethod_CODE, @Ln_BarcodeOut_NUMB, @Ls_XmlOut_Text, @Lc_Msg_CODE, @Ls_DescriptionError_TEXT;

       SELECT @Ln_FetchStatus_BIT = @@Fetch_Status;

       SET @Ls_Sql_TEXT='WHILE LOOP -1';

       WHILE @Ln_FetchStatus_BIT = 0
        BEGIN
         IF @Ln_NoticeError_NUMB > 0
          BEGIN
           SET @As_DescriptionError_TEXT = @As_DescriptionError_TEXT + '<notice>';

           IF @Ac_Job_ID NOT LIKE 'DEB%'
            BEGIN
             SET @As_DescriptionError_TEXT = @As_DescriptionError_TEXT + '<xmlout>' + ISNULL(@Ls_XmlOut_Text, '<' + @La_Notice_ID + '></' + @La_Notice_ID + '>') + '</xmlout>';
            END

           SET @As_DescriptionError_TEXT = @As_DescriptionError_TEXT + '<errorxml>' + ISNULL(@Ls_DescriptionError_TEXT, '') + '</errorxml>';
           SET @As_DescriptionError_TEXT = @As_DescriptionError_TEXT + '</notice>';
          END

         SET @Ls_Sql_TEXT = 'FETCH @Lref_NoticeOut_CUR -2';

         FETCH @Lref_NoticeOut_CUR INTO @La_Notice_ID, @Lc_Recipient_CODE, @La_PrintMethod_CODE, @Ln_BarcodeOut_NUMB, @Ls_XmlOut_Text, @Lc_Msg_CODE, @Ls_DescriptionError_TEXT;

         SELECT @Ln_FetchStatus_BIT = @@Fetch_Status;
        END

       CLOSE @Lref_NoticeOut_CUR;

       DEALLOCATE @Lref_NoticeOut_CUR;

       SET @As_DescriptionError_TEXT = @As_DescriptionError_TEXT + '</notices>';

       RETURN;
      END
    END

   SET @An_Topic_IDNO = @Ln_Topic_IDNO;
   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = @Lc_Space_TEXT;
  END TRY

  BEGIN CATCH
	-- 13761 - CP Recoup Notices - error E1424 inserted into BATE_Y1 instead of E0077 - START
	IF CURSOR_STATUS ('VARIABLE', '@Lref_RecipientRcur_CUR') IN (0, 1)
	BEGIN
		CLOSE @Lref_RecipientRcur_CUR;
		DEALLOCATE @Lref_RecipientRcur_CUR;
	END

	IF CURSOR_STATUS ('VARIABLE', '@Lref_Notice_CUR') IN (0, 1)
	BEGIN
		CLOSE @Lref_Notice_CUR;
		DEALLOCATE @Lref_Notice_CUR;
	END

	IF LEN(RTRIM(ISNULL(@Ac_Msg_CODE,''))) = ''
	BEGIN
		SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
	END

	--Check for Exception information to log the description text based on the error
	SET @Ln_Error_NUMB = ERROR_NUMBER();
	SET @Ln_ErrorLine_NUMB = ERROR_LINE();

	IF @Ln_Error_NUMB <> 50001
	BEGIN
		SET @As_DescriptionError_TEXT = ISNULL(SUBSTRING(ERROR_MESSAGE(), 1, 200),' ')+ ISNULL(@As_DescriptionError_TEXT,'');
	END

	EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
	@As_Procedure_NAME        = @Ls_Routine_TEXT,
	@As_ErrorMessage_TEXT     = @As_DescriptionError_TEXT,
	@As_Sql_TEXT              = @Ls_Sql_TEXT,
	@As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
	@An_Error_NUMB            = @Ln_Error_NUMB,
	@An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
	@As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;
	-- 13761 - CP Recoup Notices - error E1424 inserted into BATE_Y1 instead of E0077 - END
  END CATCH
 END


GO
