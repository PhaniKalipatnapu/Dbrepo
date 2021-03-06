/****** Object:  StoredProcedure [dbo].[BATCH_COMMON$SP_UPDATE_MINOR_ACTIVITY]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_COMMON$SP_UPDATE_MINOR_ACTIVITY
Programmer Name		: IMP Team
Description			: This process updates the DMNR_Y1 table with the reason selected by the
					  BATCH_COMMON$SF_GET_REASON PROCEDURE and inserts the next activity and also generates
					  notices defined for the next activity
Frequency			: 
Developed On		: 04/12/2011
Called By			:
Called On			:
--------------------------------------------------------------------------------------------------------------------
Modified By			:
Modified On			:
Version No			: 1.0	
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_COMMON$SP_UPDATE_MINOR_ACTIVITY]
 @An_Case_IDNO                NUMERIC(6),
 @An_OrderSeq_NUMB            NUMERIC(2),
 @An_MemberMci_IDNO           NUMERIC(10),
 @An_Forum_IDNO               NUMERIC(10),
 @An_Topic_IDNO               NUMERIC(10)		= 0,
 @An_MajorIntSeq_NUMB         NUMERIC(5),
 @An_MinorIntSeq_NUMB         NUMERIC(5),
 @Ac_ActivityMajor_CODE       CHAR(4),
 @Ac_ActivityMinor_CODE       CHAR(5),
 @Ac_ReasonStatus_CODE        CHAR(2),
 @An_Schedule_NUMB            NUMERIC(10)		= 0,
 @As_DescriptionNote_TEXT     VARCHAR(4000)		= NULL,
 @An_TransactionEventSeq_NUMB NUMERIC(19),
 @Ac_WorkerUpdate_ID          CHAR(30),
 @Ad_Run_DATE                 DATETIME2,
 @Ac_Process_ID               CHAR(10),
 @Ac_Msg_CODE                 CHAR(5)			OUTPUT,
 @As_DescriptionError_TEXT    VARCHAR(4000)		OUTPUT
AS
 BEGIN 
  SET NOCOUNT ON;
  
   DECLARE @Lc_Space_TEXT					CHAR(1)		= ' ',
           @Lc_StatusSuccess_CODE			CHAR(1)		= 'S',
           @Lc_StatusFailed_CODE			CHAR(1)		= 'F',
           @Lc_RespondInitResponding_CODE	CHAR(1)		= 'R',
           @Lc_Yes_INDC						CHAR(1)		= 'Y',
           @Lc_No_INDC						CHAR(1)		= 'N',
           @Lc_TypeOthpX1_CODE				CHAR(1)		= 'X',
           @Lc_ValueNo_INDC					CHAR(1)		= 'N',
           @Lc_ScheduleConducted_INDC		CHAR(1)		= 'D',
           @Lc_StateInState_CODE			CHAR(2)		= 'DE',
           @Lc_ReasonStatusSy_CODE			CHAR(2)		= 'SY',
           @Lc_ReasonStatusBc_CODE			CHAR(2)		= 'BC',
           @Lc_ApptStatusReScheduled_CODE	CHAR(2)		= 'RS',
           @Lc_ApptStatusScheduled_CODE		CHAR(2)		= 'SC',
           @Lc_ApptStatusConducted_CODE		CHAR(2)		= 'CD',
           @Lc_RecipientSi_CODE				CHAR(2)		= 'SI',
           @Lc_RemedyStatusStart_CODE		CHAR(4)		= 'STRT',
           @Lc_RemedyStatusComplete_CODE	CHAR(4)		= 'COMP',
           @Lc_TableEiwo_ID					CHAR(4)		= 'EIWO',
           @Lc_TableSubSkip_ID				CHAR(4)		= 'SKIP',
           @Lc_ActivityMajorImiw_CODE		CHAR(4)		= 'IMIW',
           @Lc_ActivityMajorCsln_CODE		CHAR(4)		= 'CSLN',
           @Lc_ActivityMajorFidm_CODE		CHAR(4)		= 'FIDM', 
           @Lc_ActivityMajorLsnr_CODE		CHAR(4)		= 'LSNR', 
           @Lc_ActivityMajorCpls_CODE		CHAR(4)		= 'CPLS', 
           @Lc_ActivityMajorNmsn_CODE		CHAR(4)		= 'NMSN',
           @Lc_ActivityMajorCclo_CODE		CHAR(4)		= 'CCLO',
           @Lc_ActivityMinorRmdcy_CODE		CHAR(5)		= 'RMDCY',
           @Lc_NoticeEnf01_ID				CHAR(6)		= 'ENF-01',
           @Ls_Routine_TEXT					VARCHAR(75) = 'BATCH_COMMON$SP_UPDATE_MINOR_ACTIVITY',
           @Ld_Low_DATE						DATE		= '01/01/0001',
           @Ld_High_DATE					DATE		= '12/31/9999';
  DECLARE  @Li_Error_NUMB					INT,
           @Li_RowCount_QNTY				INT,
           @Ln_NoticeCount_NUMB				NUMERIC(3)	= 0,
           @Ln_Value_QNTY					NUMERIC(4),
           @Ln_MajorIntSeq_NUMB				NUMERIC(5),
           @Ln_MinorIntSeq_NUMB				NUMERIC(5),
           @Ln_OthpSource_IDNO				NUMERIC(9),
           @Ln_Schedule_NUMB				NUMERIC(10) = 0,
           @Ln_Forum_IDNO					NUMERIC(10),
           @Ln_Topic_IDNO					NUMERIC(10),
           @Ln_TopicIn_IDNO					NUMERIC(10),
           @Ln_TopicOut_IDNO				NUMERIC(10),
           @Ln_ErrorLine_NUMB				NUMERIC(11),
           @Ln_TransactionEventSeq_NUMB		NUMERIC(19),
           @Lc_TypeOthp_CODE				CHAR(1)		= '',
           @Lc_RespondInit_CODE				CHAR(1)		= '',
           @Lc_TypeOthpSource_CODE			CHAR(1),
           @Lc_Schedule_INDC				CHAR(1),
           @Lc_ReasonStatus_CODE			CHAR(2),
           @Lc_Subsystem_CODE				CHAR(2),
           @Lc_State_ADDR					CHAR(2)		= '',
           @Lc_Status2_CODE					CHAR(4),
           @Lc_TypeReference_CODE			CHAR(5),
           @Lc_ActivityMinor_CODE			CHAR(5),
           @Lc_ActivityMinorNext_CODE		CHAR(5)		= '',
           @Lc_Reference_ID					CHAR(30),
           @Ls_DescriptionValue_TEXT		VARCHAR(70) = '',
           @Ls_Sql_TEXT						VARCHAR(100),
           @Ls_Sqldata_TEXT					VARCHAR(1000),
           @Ls_ErrorMessage_TEXT			VARCHAR(4000),
           @Ld_Temp_DATE					DATE,
           @Ld_Status_DATE					DATE,
           @Ld_DueActivity_DATE				DATETIME2,
           @Ld_DueAlertWarn_DATE			DATETIME2,
           @Ld_Current_DTTM					DATETIME2	= dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();


  BEGIN TRY
   SET @Ac_Msg_CODE = '';
   SET @As_DescriptionError_TEXT = '';
   SET @Ln_Forum_IDNO = @An_Forum_IDNO;
   SET @Ln_MajorIntSeq_NUMB = @An_MajorIntSeq_NUMB;
   SET @Ln_MinorIntSeq_NUMB = @An_MinorIntSeq_NUMB;
   SET @Lc_ActivityMinor_CODE = @Ac_ActivityMinor_CODE;
   SET @Lc_ReasonStatus_CODE = @Ac_ReasonStatus_CODE;
   SET @Ln_TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB;
   SET @Ln_TopicIn_IDNO = @An_Topic_IDNO;
  -- WHILE LOOP
   WHILE 1 = 1
    BEGIN
     SET @Ls_Sql_TEXT = 'SELECT NEXT Topic_IDNO SEQUENCE VALUE';
     SET @Ls_Sqldata_TEXT = '';

     INSERT INTO 
		IdentSeqTopic_T1
		(Entered_DATE)
       VALUES 
		(@Ld_Current_DTTM);

     SET @Ln_Topic_IDNO = @@IDENTITY;

     SET @Ls_Sql_TEXT = 'GET NEXT ACTIVITY DETAILS OF IN-PROGRESS ACTIVITY';
     SET @Ls_Sqldata_TEXT = 'ActivityMajor_CODE = ' + @Ac_ActivityMajor_CODE+ ', ActivityMinor_CODE = ' + @Lc_ActivityMinor_CODE;

     SELECT @Lc_ActivityMinorNext_CODE	= n.ActivityMinorNext_CODE,
            @Lc_ReasonStatus_CODE		= n.Reason_CODE,
            @Lc_Schedule_INDC			= n.Error_CODE			
       FROM ANXT_Y1 n,
            AMNR_Y1 a
      WHERE n.ActivityMinorNext_CODE = a.ActivityMinor_CODE
        AND n.ActivityMajor_CODE = @Ac_ActivityMajor_CODE
        AND n.ActivityMinor_CODE = @Lc_ActivityMinor_CODE
        AND n.Reason_CODE = ISNULL (@Lc_ReasonStatus_CODE, n.Reason_CODE)
        AND n.EndValidity_DATE = @Ld_High_DATE
        AND a.EndValidity_DATE = @Ld_High_DATE;

     SET @Ld_Temp_DATE = dbo.BATCH_COMMON$SF_GET_DURATION_START_DATE (@An_Case_IDNO, @Ln_MajorIntSeq_NUMB, @Lc_ActivityMinorNext_CODE, NULL, @Ad_Run_DATE );
     
     SET @Ls_Sql_TEXT = 'BATCH_COMMON_GETS$SP_GET_DUE_ALERT_DATE';
     SET @Ls_Sqldata_TEXT = 'ActivityMinorNext_CODE = ' + ISNULL(@Lc_ActivityMinorNext_CODE,'')+ ', Run_DATE = ' + ISNULL(CAST( @Ld_Temp_DATE AS VARCHAR ),'');

     EXECUTE BATCH_COMMON_GETS$SP_GET_DUE_ALERT_DATE
      @Ac_ActivityMinor_CODE    = @Lc_ActivityMinorNext_CODE,
      @Ad_Run_DATE              = @Ld_Temp_DATE,
      @Ad_DueActivity_DATE      = @Ld_DueActivity_DATE OUTPUT,
      @Ad_DueAlertWarn_DATE     = @Ld_DueAlertWarn_DATE OUTPUT,
      @Ac_Msg_CODE              = @Ac_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

     IF @Ac_Msg_CODE != @Lc_StatusSuccess_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END
      
     SET @Ls_Sql_TEXT = 'UPDATE DMNR_Y1';
     SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + CAST( @An_Case_IDNO AS CHAR(6) )+ ', MajorIntSeq_NUMB = ' + CAST( @Ln_MajorIntSeq_NUMB AS VARCHAR )+ ', MinorIntSeq_NUMB = ' + CAST( @Ln_MinorIntSeq_NUMB AS VARCHAR )+ ', Topic_IDNO = ' + CAST( @Ln_TopicIn_IDNO AS VARCHAR );

     UPDATE DMNR_Y1
        SET Status_CODE = @Lc_RemedyStatusComplete_CODE,
            Status_DATE = @Ad_Run_DATE,
            ActivityMinorNext_CODE = @Lc_ActivityMinorNext_CODE,
            ReasonStatus_CODE = @Lc_ReasonStatus_CODE,
            BeginValidity_DATE = @Ad_Run_DATE,
            WorkerUpdate_ID = @Ac_WorkerUpdate_ID,
            Update_DTTM = @Ld_Current_DTTM,
            TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB
     OUTPUT DELETED.Case_IDNO,
            DELETED.OrderSeq_NUMB,
            DELETED.MajorIntSeq_NUMB,
            DELETED.MinorIntSeq_NUMB,
            DELETED.MemberMci_IDNO,
            DELETED.ActivityMinor_CODE,
            DELETED.ActivityMinorNext_CODE,
            DELETED.Entered_DATE,
            DELETED.Due_DATE,
            DELETED.Status_DATE,
            DELETED.Status_CODE,
            DELETED.ReasonStatus_CODE,
            DELETED.Schedule_NUMB,
            DELETED.Forum_IDNO,
            DELETED.Topic_IDNO,
            DELETED.TotalReplies_QNTY,
            DELETED.[TotalViews_QNTY],
            DELETED.PostLastPoster_IDNO,
            DELETED.UserLastPoster_ID,
            DELETED.LastPost_DTTM,
            DELETED.AlertPrior_DATE,
            DELETED.BeginValidity_DATE,
            @Ad_Run_DATE AS EndValidity_DATE,
            DELETED.WorkerUpdate_ID,
            DELETED.Update_DTTM,
            DELETED.TransactionEventSeq_NUMB,
            DELETED.WorkerDelegate_ID,
            DELETED.Subsystem_CODE,
            DELETED.ActivityMajor_CODE
            INTO HDMNR_Y1
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
             EndValidity_DATE,
             WorkerUpdate_ID,
             Update_DTTM,
             TransactionEventSeq_NUMB,
             WorkerDelegate_ID,
             Subsystem_CODE,
             ActivityMajor_CODE)
      WHERE Case_IDNO = @An_Case_IDNO
        AND MajorIntSeq_NUMB = @Ln_MajorIntSeq_NUMB
        AND MinorIntSeq_NUMB = @Ln_MinorIntSeq_NUMB
        AND Status_CODE = @Lc_RemedyStatusStart_CODE
        AND Topic_IDNO = @Ln_TopicIn_IDNO;

     SET @Li_RowCount_QNTY = @@ROWCOUNT;

     IF @Li_RowCount_QNTY = 0
      BEGIN
       SET @Ls_ErrorMessage_TEXT = 'DMNR_Y1 UPDATE FAILED';
       RAISERROR (50001,16,1);
      END
     
     -- Checks whether any activity needs to be conducted by System .
     IF ( @Lc_Schedule_INDC IN (@Lc_ScheduleConducted_INDC, @Lc_Space_TEXT) )
     BEGIN 
     
		SET @Ls_Sql_TEXT = 'SELECT DMNR_Y1, SWKS_Y1';
		SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + CAST( @An_Case_IDNO AS CHAR(6) )+', MajorIntSeq_NUMB = ' + CAST( @An_MajorIntSeq_NUMB AS VARCHAR );
		 SELECT @Ln_Schedule_NUMB = ISNULL( MAX(n.Schedule_NUMB),0) 
		   FROM DMNR_Y1 n
			 JOIN SWKS_Y1 s
			  ON n.Schedule_NUMB = s.Schedule_NUMB
				 AND n.Case_IDNO = s.Case_IDNO
		  WHERE n.Case_IDNO = @An_Case_IDNO
			 AND n.MajorIntSeq_NUMB = @An_MajorIntSeq_NUMB
			 AND s.ApptStatus_CODE IN (@Lc_ApptStatusScheduled_CODE, @Lc_ApptStatusReScheduled_CODE)
			 AND s.Worker_ID != @Lc_Space_TEXT;
			 
		IF (@Ln_Schedule_NUMB > 0)
	    BEGIN 
			SET @Ls_Sql_TEXT = 'UPDATE SWKS_Y1';
			SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + CAST( @An_Case_IDNO AS CHAR(6) )+', Schedule_NUMB = ' + CAST( @Ln_Schedule_NUMB AS VARCHAR );
			  UPDATE SWKS_Y1  
				SET ApptStatus_CODE = @Lc_ApptStatusConducted_CODE,  
				 WorkerUpdate_ID = @Ac_WorkerUpdate_ID,  
				 BeginValidity_DATE = @Ad_Run_DATE,  
				 Update_DTTM = @Ld_Current_DTTM,  
				 TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB  
				OUTPUT
     			Deleted.Schedule_NUMB,  
				Deleted.Case_IDNO,  
				Deleted.Worker_ID,  
				Deleted.MemberMci_IDNO,  
				Deleted.OthpLocation_IDNO,  
				Deleted.ActivityMajor_CODE,  
				Deleted.ActivityMinor_CODE,  
				Deleted.TypeActivity_CODE,  
				Deleted.WorkerDelegateTo_ID,  
				Deleted.Schedule_DATE,  
				Deleted.BeginSch_DTTM,  
				Deleted.EndSch_DTTM,  
				Deleted.ApptStatus_CODE,  
				Deleted.SchParent_NUMB,  
				Deleted.SchPrev_NUMB,  
				Deleted.WorkerUpdate_ID,  
				Deleted.BeginValidity_DATE,  
				@Ad_Run_DATE AS EndValidity_DATE,  
				Deleted.Update_DTTM,  
				Deleted.TransactionEventSeq_NUMB,  
				Deleted.TypeFamisProceeding_CODE,  
				Deleted.ReasonAdjourn_CODE,  
				Deleted.Worker_NAME,  
				Deleted.SchedulingUnit_CODE  
			INTO HSWKS_Y1
			WHERE Schedule_NUMB = @Ln_Schedule_NUMB; 
			
			SET @Li_RowCount_QNTY = @@ROWCOUNT;

			 IF @Li_RowCount_QNTY = 0
			 BEGIN
			   SET @Ls_ErrorMessage_TEXT = 'SWKS_Y1 UPDATE FAILED';
			   RAISERROR (50001,16,1);
			 END
		END;
	END;

     /*
        selecting the max(MinorIntSeq_NUMB) value from UDMNR_V1 (Union of DMNR and CJNR),
        instead of selecting the value from vdmnr
     */
     SET @Ls_Sql_TEXT = 'SELECT MinorIntSeq_NUMB FROM UDMNR_V1';
     SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + CAST( @An_Case_IDNO AS CHAR(6) )+ ', MajorIntSeq_NUMB = ' + CAST( @Ln_MajorIntSeq_NUMB AS VARCHAR );

     SELECT @Ln_MinorIntSeq_NUMB = ISNULL (MAX (MinorIntSeq_NUMB), 0) + 1
	  FROM (SELECT MAX(MinorIntSeq_NUMB) MinorIntSeq_NUMB
			  FROM DMNR_Y1 u
			 WHERE u.Case_IDNO = @An_Case_IDNO
			   AND u.MajorIntSeq_NUMB = @Ln_MajorIntSeq_NUMB
			UNION ALL
			SELECT MAX(MinorIntSeq_NUMB) MinorIntSeq_NUMB
			  FROM CJNR_Y1 u
			 WHERE u.Case_IDNO = @An_Case_IDNO
			   AND u.MajorIntSeq_NUMB = @Ln_MajorIntSeq_NUMB) A; 

     IF @Lc_ActivityMinorNext_CODE = @Lc_ActivityMinorRmdcy_CODE
      BEGIN
       SET @Lc_Status2_CODE = @Lc_RemedyStatusComplete_CODE;
       SET @Ld_Status_DATE = @Ad_Run_DATE;
      END
     ELSE
      BEGIN
       SET @Lc_Status2_CODE = @Lc_RemedyStatusStart_CODE;
       SET @Ld_Status_DATE = @Ld_High_DATE;
      END

     SET @Ls_Sql_TEXT = 'SELECT DMJR_Y1 - 1';
     SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + CAST( @An_Case_IDNO AS CHAR(6) )+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @An_OrderSeq_NUMB AS VARCHAR ),'')+ ', MajorIntSeq_NUMB = ' + CAST( @Ln_MajorIntSeq_NUMB AS VARCHAR );

     SELECT @Lc_Subsystem_CODE = d.Subsystem_CODE,
            @Ln_OthpSource_IDNO = d.OthpSource_IDNO,
            @Lc_TypeOthpSource_CODE = d.TypeOthpSource_CODE,
            @Lc_TypeReference_CODE = d.TypeReference_CODE,
            @Lc_Reference_ID = d.Reference_ID
       FROM DMJR_Y1 d
      WHERE d.Case_IDNO = @An_Case_IDNO
        AND d.OrderSeq_NUMB = @An_OrderSeq_NUMB
        AND d.MajorIntSeq_NUMB = @Ln_MajorIntSeq_NUMB;

     SET @Ls_Sql_TEXT = 'INSERT DMNR_Y1 - 1';
     SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + CAST( @An_Case_IDNO AS CHAR(6) )+ ', MajorIntSeq_NUMB = ' + CAST( @Ln_MajorIntSeq_NUMB AS VARCHAR )+ ', MinorIntSeq_NUMB = ' + CAST( @Ln_MinorIntSeq_NUMB AS VARCHAR )+ ', MemberMci_IDNO = ' + CAST( @An_MemberMci_IDNO AS VARCHAR )+ ', ActivityMinor_CODE = ' + ISNULL(@Lc_ActivityMinorNext_CODE,'')+ ', Entered_DATE = ' + CAST( @Ad_Run_DATE AS VARCHAR )+ ', Status_DATE = ' + ISNULL(CAST( @Ld_Status_DATE AS VARCHAR ),'')+ ', Status_CODE = ' + ISNULL(@Lc_Status2_CODE,'')+ ', Schedule_NUMB = ' + ISNULL(CAST( @An_Schedule_NUMB AS VARCHAR ),'')+ ', Forum_IDNO = ' + ISNULL(CAST( @Ln_Forum_IDNO AS VARCHAR ),'')+ ', Topic_IDNO = ' + ISNULL(CAST( @Ln_Topic_IDNO AS VARCHAR ),'')+ ', UserLastPoster_ID = ' + ISNULL(@Ac_WorkerUpdate_ID,'')+ ', BeginValidity_DATE = ' + CAST( @Ad_Run_DATE AS VARCHAR )+ ', WorkerUpdate_ID = ' + ISNULL(@Ac_WorkerUpdate_ID,'')+ ', TransactionEventSeq_NUMB = ' + ISNULL(CAST( @Ln_TransactionEventSeq_NUMB AS VARCHAR ),'')+ ', Subsystem_CODE = ' + ISNULL(@Lc_Subsystem_CODE,'')+ ', ActivityMajor_CODE = ' + ISNULL(@Ac_ActivityMajor_CODE,'');

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
     VALUES ( @An_Case_IDNO,   --Case_IDNO
              ISNULL (@An_OrderSeq_NUMB, 0),   --OrderSeq_NUMB
              @Ln_MajorIntSeq_NUMB,   --MajorIntSeq_NUMB
              @Ln_MinorIntSeq_NUMB,   --MinorIntSeq_NUMB
              @An_MemberMci_IDNO,   --MemberMci_IDNO
              @Lc_ActivityMinorNext_CODE,   --ActivityMinor_CODE
              @Lc_Space_TEXT,   --ActivityMinorNext_CODE
              @Ad_Run_DATE,   --Entered_DATE
              CAST(CONVERT(VARCHAR(10), ISNULL(@Ld_DueActivity_DATE, ' '), 101) AS DATETIME2),   --Due_DATE
              @Ld_Status_DATE,   --Status_DATE
              @Lc_Status2_CODE,   --Status_CODE
              CASE @Lc_ActivityMinorNext_CODE
               WHEN @Lc_ActivityMinorRmdcy_CODE
                THEN @Lc_ReasonStatusSy_CODE
               ELSE @Lc_Space_TEXT
              END,   --ReasonStatus_CODE
              @An_Schedule_NUMB,   --Schedule_NUMB
              @Ln_Forum_IDNO,   --Forum_IDNO
              @Ln_Topic_IDNO,   --Topic_IDNO
              0,   --TotalReplies_QNTY
              0,   --TotalViews_QNTY
              0,   --PostLastPoster_IDNO
              @Ac_WorkerUpdate_ID,   --UserLastPoster_ID
              @Ld_Current_DTTM,   --LastPost_DTTM
              ISNULL(CASE
               WHEN @Ld_DueAlertWarn_DATE < @Ad_Run_DATE
                THEN @Ad_Run_DATE
               ELSE @Ld_DueAlertWarn_DATE
              END, ' '),   --AlertPrior_DATE
              @Ad_Run_DATE,   --BeginValidity_DATE
              @Ac_WorkerUpdate_ID,   --WorkerUpdate_ID
              @Ld_Current_DTTM,   --Update_DTTM
              @Ln_TransactionEventSeq_NUMB,   --TransactionEventSeq_NUMB
              @Lc_Space_TEXT,   --WorkerDelegate_ID
              --0,
              @Lc_Subsystem_CODE,   --Subsystem_CODE
              @Ac_ActivityMajor_CODE  --ActivityMajor_CODE
              );

     SET @Li_RowCount_QNTY = @@ROWCOUNT;

     IF @Li_RowCount_QNTY = 0
      BEGIN
       SET @Ls_ErrorMessage_TEXT = 'DMNR_Y1 INSERT FAILED';

       RAISERROR (50001,16,1);
      END

     IF LTRIM(RTRIM(@As_DescriptionNote_TEXT)) IS NOT NULL
        AND LTRIM(RTRIM(@As_DescriptionNote_TEXT)) != ''
      BEGIN
       SET @Ls_Sql_TEXT = 'INSERT NOTE_Y1';
       SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + CAST( @An_Case_IDNO AS CHAR(6) )+ ', Topic_IDNO = ' + CAST( @Ln_Topic_IDNO AS VARCHAR )+ ', MajorIntSeq_NUMB = ' + CAST( @Ln_MajorIntSeq_NUMB AS VARCHAR )+ ', MinorIntSeq_NUMB = ' + CAST( @Ln_MinorIntSeq_NUMB AS VARCHAR )+ ', Category_CODE = ' + ISNULL(@Lc_Subsystem_CODE,'')+ ', Subject_CODE = ' + ISNULL(@Lc_ActivityMinorNext_CODE,'')+ ', WorkerCreated_ID = ' + @Ac_WorkerUpdate_ID + ', DescriptionNote_TEXT = ' + ISNULL(@As_DescriptionNote_TEXT,'')+ ', BeginValidity_DATE = ' + CAST( @Ad_Run_DATE AS VARCHAR )+ ', TransactionEventSeq_NUMB = ' + ISNULL(CAST( @Ln_TransactionEventSeq_NUMB AS VARCHAR ),'');

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
            VALUES ( @An_Case_IDNO,   --Case_IDNO
                     @Ln_Topic_IDNO,   --Topic_IDNO
                     1,   --Post_IDNO
                     @Ln_MajorIntSeq_NUMB,   --MajorIntSeq_NUMB
                     @Ln_MinorIntSeq_NUMB,   --MinorIntSeq_NUMB
                     0,   --Office_IDNO
                     @Lc_Subsystem_CODE,   --Category_CODE
                     @Lc_ActivityMinorNext_CODE,   --Subject_CODE
                     @Lc_Space_TEXT,   --CallBack_INDC
                     @Lc_ValueNo_INDC,   --NotifySender_INDC
                     @Lc_Space_TEXT,   --TypeContact_CODE
                     @Lc_Space_TEXT,   --SourceContact_CODE
                     @Lc_Space_TEXT,   --MethodContact_CODE
                     @Lc_Space_TEXT,   --Status_CODE
                     @Lc_Space_TEXT,   --TypeAssigned_CODE
                     @Lc_Space_TEXT,   --WorkerAssigned_ID
                     @Lc_Space_TEXT,   --RoleAssigned_ID
                     @Ac_WorkerUpdate_ID,   --WorkerCreated_ID
                     @Ld_Low_DATE,   --Start_DATE
                     @Ld_Low_DATE,   --Due_DATE
                     @Ld_High_DATE,   --Action_DATE
                     @Ld_High_DATE,   --Received_DATE
                     @Lc_Space_TEXT,   --OpenCases_CODE
                     @As_DescriptionNote_TEXT,   --DescriptionNote_TEXT
                     @Ad_Run_DATE,   --BeginValidity_DATE
                     @Ld_High_DATE,   --EndValidity_DATE
                     @Ac_WorkerUpdate_ID,   --WorkerUpdate_ID
                     @Ln_TransactionEventSeq_NUMB,   --TransactionEventSeq_NUMB
                     0,   --EventGlobalSeq_NUMB
                     @Ld_Current_DTTM,   --Update_DTTM
                     0,   --TotalReplies_QNTY
                     0  --TotalViews_QNTY
					);
					
	   SET @Li_RowCount_QNTY = @@ROWCOUNT;
	   		
       IF @Li_RowCount_QNTY = 0
        BEGIN
         SET @Ac_Msg_CODE = 'E0113'; 
         SET @As_DescriptionError_TEXT = ISNULL(@Ls_Routine_TEXT, '') + ISNULL(@Lc_Space_TEXT, '') + ISNULL(@Ls_Sql_TEXT, '') + ISNULL(@Lc_Space_TEXT, '') + 'NOTE_Y1 INSERT FAILED' + ISNULL(@Lc_Space_TEXT, '') + ISNULL(@Ls_Sqldata_TEXT, '');
         RETURN;
        END
      END    
	 -- 13570 Procedure name correction	- Start
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_ALERT_WORKER';
     -- 13570 Procedure name correction	- End
     SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + CAST( @An_Case_IDNO AS CHAR(6) )+ ', Subsystem_CODE = ' + ISNULL(@Lc_Subsystem_CODE,'')+ ', ActivityMajor_CODE = ' + ISNULL(@Ac_ActivityMajor_CODE,'')+ ', ActivityMinor_CODE = ' + ISNULL(@Lc_ActivityMinor_CODE,'')+ ', ReasonStatus_CODE = ' + ISNULL(@Lc_ReasonStatus_CODE,'')+ ', MajorIntSeq_NUMB = ' + CAST( @Ln_MajorIntSeq_NUMB AS VARCHAR )+ ', MinorIntSeq_NUMB = ' + CAST( @Ln_MinorIntSeq_NUMB AS VARCHAR )+ ', SignedonWorker_ID = ' + ISNULL(@Ac_WorkerUpdate_ID,'')+ ', TransactionEventSeq_NUMB = ' + ISNULL(CAST( @Ln_TransactionEventSeq_NUMB AS VARCHAR ),'')+ ', Run_DATE = ' + CAST( @Ad_Run_DATE AS VARCHAR )+ ', Job_ID = ' + ISNULL(@Ac_Process_ID,'');
     /* the below procedure is called to insert a worker in CWRK_Y1, if a worker with a role that
      matches with the role for the activity in ACRL_Y1 does not exist */
     EXECUTE BATCH_COMMON$SP_ALERT_WORKER
      @An_Case_IDNO                = @An_Case_IDNO,
      @Ac_Subsystem_CODE           = @Lc_Subsystem_CODE,
      @Ac_ActivityMajor_CODE       = @Ac_ActivityMajor_CODE,
      @Ac_ActivityMinor_CODE       = @Lc_ActivityMinor_CODE,
      @Ac_ReasonStatus_CODE        = @Lc_ReasonStatus_CODE,
      @An_MajorIntSeq_NUMB         = @Ln_MajorIntSeq_NUMB,
      @An_MinorIntSeq_NUMB         = @Ln_MinorIntSeq_NUMB,
      @Ac_SignedonWorker_ID        = @Ac_WorkerUpdate_ID,
      @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
      @Ad_Run_DATE                 = @Ad_Run_DATE,
      @Ac_Job_ID                   = @Ac_Process_ID,
      @Ac_Msg_CODE                 = @Ac_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT    = @Ls_ErrorMessage_TEXT OUTPUT;

     IF @Ac_Msg_CODE != @Lc_StatusSuccess_CODE
      BEGIN
       IF @Ac_Msg_CODE = @Lc_StatusFailed_CODE
		BEGIN
			RAISERROR(50001,16,1);
		END
		RETURN;
      END

     SET @Ls_Sql_TEXT = 'BATCH_ENF_EMON$SP_SYSTEM_UPDATE';
     SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + CAST( @An_Case_IDNO AS CHAR(6) )+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @An_OrderSeq_NUMB AS VARCHAR ),'')+ ', MemberMci_IDNO = ' + CAST( @An_MemberMci_IDNO AS VARCHAR )+ ', TypeOthpSource_CODE = ' + ISNULL(@Lc_TypeOthpSource_CODE,'')+ ', OthpSource_IDNO = ' + ISNULL(CAST( @Ln_OthpSource_IDNO AS VARCHAR ),'')+ ', TypeReference_CODE = ' + ISNULL(@Lc_TypeReference_CODE,'')+ ', Reference_ID = ' + ISNULL(@Lc_Reference_ID,'')+ ', Subsystem_CODE = ' + ISNULL(@Lc_Subsystem_CODE,'')+ ', ActivityMajor_CODE = ' + ISNULL(@Ac_ActivityMajor_CODE,'')+ ', ActivityMinor_CODE = ' + ISNULL(@Lc_ActivityMinor_CODE,'')+ ', ReasonStatus_CODE = ' + ISNULL(@Lc_ReasonStatus_CODE,'')+ ', MajorIntSeq_NUMB = ' + CAST( @Ln_MajorIntSeq_NUMB AS VARCHAR )+ ', MinorIntSeq_NUMB = ' + ISNULL(CAST( @An_MinorIntSeq_NUMB AS VARCHAR ),'')+ ', TransactionEventSeq_NUMB = ' + ISNULL(CAST( @Ln_TransactionEventSeq_NUMB AS VARCHAR ),'')+ ', WorkerUpdate_ID = ' + ISNULL(@Ac_WorkerUpdate_ID,'')+ ', Run_DATE = ' + CAST( @Ad_Run_DATE AS VARCHAR )+ ', Status_DATE = ' + CAST( @Ad_Run_DATE AS VARCHAR )+ ', Process_ID = ' + ISNULL(@Ac_Process_ID,'');
     
     EXECUTE BATCH_ENF_EMON$SP_SYSTEM_UPDATE
      @An_Case_IDNO                = @An_Case_IDNO,
      @An_OrderSeq_NUMB            = @An_OrderSeq_NUMB,
      @An_MemberMci_IDNO           = @An_MemberMci_IDNO,
      @Ac_TypeOthpSource_CODE      = @Lc_TypeOthpSource_CODE,
      @An_OthpSource_IDNO          = @Ln_OthpSource_IDNO,
      @Ac_TypeReference_CODE       = @Lc_TypeReference_CODE,
      @Ac_Reference_ID             = @Lc_Reference_ID,
      @Ac_Subsystem_CODE           = @Lc_Subsystem_CODE,
      @Ac_ActivityMajor_CODE       = @Ac_ActivityMajor_CODE,
      @Ac_ActivityMinor_CODE       = @Lc_ActivityMinor_CODE,
      @Ac_ReasonStatus_CODE        = @Lc_ReasonStatus_CODE,
      @An_MajorIntSeq_NUMB         = @Ln_MajorIntSeq_NUMB,
      @An_MinorIntSeq_NUMB         = @An_MinorIntSeq_NUMB,
      @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
      @Ac_WorkerUpdate_ID          = @Ac_WorkerUpdate_ID,
      @Ad_Run_DATE                 = @Ad_Run_DATE,
      @Ad_Status_DATE              = @Ad_Run_DATE,
      @Ac_Process_ID               = @Ac_Process_ID,
      @Ac_Msg_CODE                 = @Ac_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT    = @Ls_ErrorMessage_TEXT OUTPUT;

	IF @Ac_Msg_CODE != @Lc_StatusSuccess_CODE
	BEGIN
		IF @Ac_Msg_CODE = @Lc_StatusFailed_CODE
		BEGIN
			RAISERROR(50001,16,1);
		END
		RETURN;
	END

     SET @An_MinorIntSeq_NUMB = @Ln_MinorIntSeq_NUMB;
     SET @Ln_TopicIn_IDNO = @Ln_Topic_IDNO;
	 
	 -- 13383 - CR0379 Capias License Suspension on Non-Ordered Cases - Starts
     IF @Ac_ActivityMajor_CODE IN (@Lc_ActivityMajorCsln_CODE, @Lc_ActivityMajorFidm_CODE, @Lc_ActivityMajorImiw_CODE, 
			@Lc_ActivityMajorLsnr_CODE, @Lc_ActivityMajorCpls_CODE, @Lc_ActivityMajorNmsn_CODE)
     -- 13383 - CR0379 Capias License Suspension on Non-Ordered Cases - Ends
      BEGIN
       SET @Ls_Sql_TEXT = 'GET EMPLOYER TYPE AND STATE FROM OTHP_Y1';
       SET @Ls_Sqldata_TEXT = 'OtherParty_IDNO = ' + ISNULL(CAST( @Ln_OthpSource_IDNO AS VARCHAR ),'');

       SELECT @Lc_TypeOthp_CODE = o.TypeOthp_CODE,
              @Lc_State_ADDR = o.State_ADDR
         FROM OTHP_Y1 o
        WHERE o.OtherParty_IDNO = @Ln_OthpSource_IDNO
          AND o.EndValidity_DATE = @Ld_High_DATE;
      END

     SET @Ls_Sql_TEXT = 'GET EIWO SKIP INDICATOR FROM REFM_Y1';
     SET @Ls_Sqldata_TEXT = 'Table_ID = ' + @Lc_TableEiwo_ID + ', TableSub_ID = ' + @Lc_TableSubSkip_ID;

     SELECT @Ls_DescriptionValue_TEXT = r.DescriptionValue_TEXT
       FROM REFM_Y1 r
      WHERE r.Table_ID = @Lc_TableEiwo_ID
        AND r.TableSub_ID = @Lc_TableSubSkip_ID;

     SET @Ls_Sql_TEXT = 'SELECT AFMS_Y1,OTHP_Y1 AND REFM_Y1';
     SET @Ls_Sqldata_TEXT = 'ActivityMajor_CODE = ' + ISNULL(@Ac_ActivityMajor_CODE,'')+ ', ActivityMinor_CODE = ' + ISNULL(@Lc_ActivityMinor_CODE,'')+ ', Reason_CODE = ' + ISNULL(@Lc_ReasonStatus_CODE,'')+ ', ActivityMinorNext_CODE = ' + ISNULL(@Lc_ActivityMinorNext_CODE,'');
     
     SELECT @Ln_NoticeCount_NUMB = COUNT(1)
       FROM AFMS_Y1 a
      WHERE a.ActivityMajor_CODE = @Ac_ActivityMajor_CODE
        AND a.ActivityMinor_CODE = @Lc_ActivityMinor_CODE
        AND a.Reason_CODE = @Lc_ReasonStatus_CODE
        AND a.ActivityMinorNext_CODE = @Lc_ActivityMinorNext_CODE
        AND a.Notice_ID != @Lc_Space_TEXT
        -- Defect 13263 - CR0365 e-IWO Notice to NCP 20140217 Fix - Start --
        AND ( a.Notice_ID != @Lc_NoticeEnf01_ID
				OR a.Recipient_CODE != @Lc_RecipientSi_CODE
				OR NOT EXISTS (SELECT 1
								 FROM OTHP_Y1 o
							    WHERE o.OtherParty_IDNO = @Ln_OthpSource_IDNO
								  AND o.EndValidity_DATE = @Ld_High_DATE
								  AND o.Eiwn_INDC = @Lc_Yes_INDC
								  AND @Ls_DescriptionValue_TEXT = @Lc_No_INDC));
		-- Defect 13263 - CR0365 e-IWO Notice to NCP 20140217 Fix - End --

     IF @Ln_NoticeCount_NUMB > 0
      BEGIN
       IF NOT ((@Lc_TypeOthp_CODE = @Lc_TypeOthpX1_CODE
            AND @Lc_State_ADDR = @Lc_StateInState_CODE)
            OR (@Lc_RespondInit_CODE = @Lc_RespondInitResponding_CODE
                AND @Ac_ActivityMajor_CODE = @Lc_ActivityMajorCclo_CODE))
        BEGIN
         SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_ACTIVITY';
         SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + CAST( @An_Case_IDNO AS CHAR(6) )+ ', MemberMci_IDNO = ' + CAST( @An_MemberMci_IDNO AS VARCHAR )+ ', ActivityMajor_CODE = ' + ISNULL(@Ac_ActivityMajor_CODE,'')+ ', ActivityMinor_CODE = ' + ISNULL(@Lc_ActivityMinor_CODE,'')+ ', ReasonStatus_CODE = ' + ISNULL(@Lc_ReasonStatus_CODE,'')+ ', Subsystem_CODE = ' + ISNULL(@Lc_Subsystem_CODE,'')+ ', TransactionEventSeq_NUMB = ' + ISNULL(CAST( @Ln_TransactionEventSeq_NUMB AS VARCHAR ),'')+ ', WorkerUpdate_ID = ' + ISNULL(@Ac_WorkerUpdate_ID,'')+ ', WorkerDelegate_ID = ' + ISNULL(@Lc_Space_TEXT,'')+ ', Run_DATE = ' + CAST( @Ad_Run_DATE AS VARCHAR )+ ', Reference_ID = ' + ISNULL(@Lc_Reference_ID,'')+ ', TopicIn_IDNO = ' + ISNULL(CAST( @Ln_Topic_IDNO AS VARCHAR ),'')+ ', MajorIntSeq_NUMB = ' + CAST( @Ln_MajorIntSeq_NUMB AS VARCHAR )+ ', MinorIntSeq_NUMB = ' + CAST( @Ln_MinorIntSeq_NUMB AS VARCHAR )+ ', OthpSource_IDNO = ' + ISNULL(CAST( @Ln_OthpSource_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @An_OrderSeq_NUMB AS VARCHAR ),'')+ ', Job_ID = ' + ISNULL(@Ac_Process_ID,'');
         
         EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
          @An_Case_IDNO               = @An_Case_IDNO,
          @An_MemberMci_IDNO          = @An_MemberMci_IDNO,
          @Ac_ActivityMajor_CODE      = @Ac_ActivityMajor_CODE,
          @Ac_ActivityMinor_CODE      = @Lc_ActivityMinor_CODE,
          @Ac_ReasonStatus_CODE       = @Lc_ReasonStatus_CODE,
          @Ac_Subsystem_CODE          = @Lc_Subsystem_CODE,
          @An_TransactionEventSeq_NUMB= @Ln_TransactionEventSeq_NUMB,
          @Ac_WorkerUpdate_ID         = @Ac_WorkerUpdate_ID,
          @Ac_WorkerDelegate_ID       = @Lc_Space_TEXT,
          @Ad_Run_DATE                = @Ad_Run_DATE,
          @Ac_Reference_ID            = @Lc_Reference_ID,
          @An_TopicIn_IDNO            = @Ln_Topic_IDNO,
          @An_MajorIntSeq_NUMB        = @Ln_MajorIntSeq_NUMB,
          @An_MinorIntSeq_NUMB        = @Ln_MinorIntSeq_NUMB,
          @An_OthpSource_IDNO         = @Ln_OthpSource_IDNO,
          @An_OrderSeq_NUMB           = @An_OrderSeq_NUMB,
          @Ac_Job_ID                  = @Ac_Process_ID,
          @An_Topic_IDNO              = @Ln_TopicOut_IDNO OUTPUT,
          @Ac_Msg_CODE                = @Ac_Msg_CODE OUTPUT,
          @As_DescriptionError_TEXT   = @As_DescriptionError_TEXT OUTPUT;

         IF @Ac_Msg_CODE <> @Lc_StatusSuccess_CODE
         BEGIN
			IF @Ac_Msg_CODE = @Lc_StatusFailed_CODE
			BEGIN
				SET @Ls_ErrorMessage_TEXT = 'EMON063B : BATCH_COMMON$SP_INSERT_ACTIVITY FAILED' + ISNULL(@As_DescriptionError_TEXT, '');
				RAISERROR(50001,16,1);
			END
			RETURN;
         END
        END
      END

     IF @Lc_ActivityMinorNext_CODE = @Lc_ActivityMinorRmdcy_CODE
      BEGIN
      
       SET @Ls_Sql_TEXT = 'UPDATE DMJR_Y1';
       SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + CAST( @An_Case_IDNO AS CHAR(6) )+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @An_OrderSeq_NUMB AS VARCHAR ),'')+ ', Status_CODE = ' + ISNULL(@Lc_RemedyStatusStart_CODE,'')+ ', MajorIntSeq_NUMB = ' + CAST( @Ln_MajorIntSeq_NUMB AS VARCHAR );

       UPDATE DMJR_Y1
          SET Status_CODE = @Lc_RemedyStatusComplete_CODE,
              ReasonStatus_CODE = @Lc_ReasonStatusBc_CODE,
              Status_DATE = @Ad_Run_DATE,
              BeginValidity_DATE = @Ad_Run_DATE,
              WorkerUpdate_ID = @Ac_WorkerUpdate_ID,
              Update_DTTM = @Ld_Current_DTTM,
              TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB
		OUTPUT DELETED.Case_IDNO,
              DELETED.OrderSeq_NUMB,
              DELETED.MajorIntSeq_NUMB,
              DELETED.MemberMci_IDNO,
              DELETED.ActivityMajor_CODE,
              DELETED.Subsystem_CODE,
              DELETED.TypeOthpSource_CODE,
              DELETED.OthpSource_IDNO,
              DELETED.Entered_DATE,
              DELETED.Status_DATE,
              DELETED.Status_CODE,
              DELETED.ReasonStatus_CODE,
              DELETED.BeginExempt_DATE,
              DELETED.EndExempt_DATE,
              DELETED.Forum_IDNO,
              DELETED.TotalTopics_QNTY,
              DELETED.PostLastPoster_IDNO,
              DELETED.UserLastPoster_ID,
              DELETED.SubjectLastPoster_TEXT,
              DELETED.LastPost_DTTM,
              DELETED.BeginValidity_DATE,
              @Ad_Run_DATE AS EndValidity_DATE,
              DELETED.WorkerUpdate_ID,
              DELETED.Update_DTTM,
              DELETED.TransactionEventSeq_NUMB,
              DELETED.TypeReference_CODE,
              DELETED.Reference_ID    
              INTO 
              HDMJR_Y1
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
               Forum_IDNO,
               TotalTopics_QNTY,
               PostLastPoster_IDNO,
               UserLastPoster_ID,
               SubjectLastPoster_TEXT,
               LastPost_DTTM,
               BeginValidity_DATE,
               EndValidity_DATE,
               WorkerUpdate_ID,
               Update_DTTM,
               TransactionEventSeq_NUMB,
               TypeReference_CODE,
               Reference_ID)              
        WHERE Case_IDNO = @An_Case_IDNO
          AND OrderSeq_NUMB = @An_OrderSeq_NUMB
          AND Status_CODE = @Lc_RemedyStatusStart_CODE
          AND MajorIntSeq_NUMB = @Ln_MajorIntSeq_NUMB;

       SET @Li_RowCount_QNTY = @@ROWCOUNT;

       IF @Li_RowCount_QNTY = 0
        BEGIN
         SET @Ls_ErrorMessage_TEXT = 'DMJR_Y1 UPDATE FAILED';

         RAISERROR (50001,16,1);
        END
      END

     IF @Lc_ActivityMinorNext_CODE != @Lc_ActivityMinorRmdcy_CODE
      BEGIN
       IF @Ld_DueActivity_DATE > @Ad_Run_DATE
        BEGIN
         BREAK;
        END

       SET @Lc_ActivityMinor_CODE = @Lc_ActivityMinorNext_CODE;
       SET @Lc_ReasonStatus_CODE = dbo.BATCH_ENF_EMON$SF_GET_REASON (@An_Case_IDNO, @An_OrderSeq_NUMB, @An_MemberMci_IDNO, @Ln_OthpSource_IDNO, @Ac_ActivityMajor_CODE, @Lc_ActivityMinor_CODE, @Ln_MajorIntSeq_NUMB, @Ad_Run_DATE, @Ad_Run_DATE, @Ld_DueActivity_DATE, @Ln_TransactionEventSeq_NUMB, @Lc_Reference_ID);

       IF ISNULL(@Lc_ReasonStatus_CODE,'') = ''
        BEGIN
         BREAK;
        END

       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GENERATE_SEQ_TXN_EVENT';
       SET @Ls_Sqldata_TEXT = 'Worker_ID = ' + ISNULL(@Ac_WorkerUpdate_ID,'')+ ', Process_ID = ' + ISNULL(@Ac_Process_ID,'')+ ', EffectiveEvent_DATE = ' + CAST( @Ad_Run_DATE AS VARCHAR )+ ', Note_INDC = ' + ISNULL(@Lc_No_INDC,'');

       EXECUTE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
        @Ac_Worker_ID                = @Ac_WorkerUpdate_ID,
        @Ac_Process_ID               = @Ac_Process_ID,
        @Ad_EffectiveEvent_DATE      = @Ad_Run_DATE,
        @Ac_Note_INDC                = @Lc_No_INDC,
        @An_EventFunctionalSeq_NUMB  = 0,
        @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
        @Ac_Msg_CODE                 = @Ac_Msg_CODE OUTPUT,
        @As_DescriptionError_Text    = @Ls_ErrorMessage_TEXT OUTPUT;

       IF @Ac_Msg_CODE <> @Lc_StatusSuccess_CODE
        BEGIN
         RAISERROR (50001,16,1);
        END
      END
     ELSE
      BEGIN
       BREAK;
      END
    END

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = @Lc_Space_TEXT;
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   SET @Li_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();

   IF @Li_Error_NUMB <> 50001
    BEGIN
     SET @Ls_ErrorMessage_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Routine_TEXT,
    @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Li_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;   
  END CATCH
 END


GO
