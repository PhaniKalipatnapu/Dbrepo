/****** Object:  StoredProcedure [dbo].[BATCH_COMMON$SP_UPDATE_ACTION_ALERT]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_COMMON$SP_UPDATE_ACTION_ALERT
Programmer Name		: IMP Team
Description			: This procedure is used to close the Action Alerts under CASE Remedy
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
CREATE PROCEDURE [dbo].[BATCH_COMMON$SP_UPDATE_ACTION_ALERT]
 @An_Case_IDNO                NUMERIC(6),
 @Ac_Subsystem_CODE           CHAR(3),
 @Ac_ActivityMajor_CODE       CHAR(4),
 @Ac_ActivityMinor_CODE       CHAR(5),
 @An_MajorIntSeq_NUMB		  NUMERIC(5)	= NULL, 
 @An_MinorIntSeq_NUMB		  NUMERIC(5)	= NULL,
 @An_MemberMci_IDNO			  NUMERIC(10)	= NULL,
 @An_TransactionEventSeq_NUMB NUMERIC(19),
 @Ac_SignedonWorker_ID        CHAR(30),
 @Ad_Run_DATE                 DATE,
 @Ac_Msg_CODE                 CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT    VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusFailed_CODE         CHAR(1)			= 'F',
          @Lc_StatusSuccess_CODE        CHAR(1)			= 'S',
          @Lc_ReasonStatusSy_CODE		CHAR(2)			= 'SY',
          @Lc_RemedyStatusStart_CODE    CHAR(4)			= 'STRT',
          @Lc_RemedyStatusComplete_CODE CHAR(4)			= 'COMP',
          @Ls_Routine_TEXT              VARCHAR(75)		= 'BATCH_COMMON$SP_UPDATE_ACTION_ALERT';
          
  DECLARE @Ln_Rowcount_QNTY				NUMERIC(9),
          @Ln_Error_NUMB				NUMERIC(9),
          @Ln_ErrorLine_NUMB			NUMERIC(11),
          @Ls_Sql_TEXT					VARCHAR(100),
          @Ls_Sqldata_TEXT				VARCHAR(1000),
          @Ls_ErrorMessage_TEXT			VARCHAR(4000)	= '';

  BEGIN TRY
   SET @Ac_Msg_CODE = '';
   SET @As_DescriptionError_TEXT = '';
   SET @Ad_Run_DATE = ISNULL (@Ad_Run_DATE, CAST (dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME() AS DATE));
   SET @Ls_Sql_TEXT = 'INSERT HDMNR_Y1';
   SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + CAST(@An_Case_IDNO AS CHAR) + ', Subsystem_CODE = ' + ISNULL (@Ac_Subsystem_CODE, '') + ', ActivityMajor_CODE = ' + @Ac_ActivityMajor_CODE + ', ActivityMinor_CODE = ' + @Ac_ActivityMinor_CODE + ', MajorIntSeq_NUMB = '+CAST(ISNULL (@An_MajorIntSeq_NUMB, 0) AS CHAR) + ', MinorIntSeq_NUMB = '+CAST(ISNULL (@An_MinorIntSeq_NUMB, 0) AS CHAR) + ', MemberMci_IDNO = '+CAST(ISNULL (@An_MemberMci_IDNO, 0) AS CHAR);

   SET @Ac_Subsystem_CODE = CASE WHEN @Ac_Subsystem_CODE IS NULL OR @Ac_Subsystem_CODE = ''
								 THEN NULL
								 ELSE @Ac_Subsystem_CODE
							END;
   SET @An_MajorIntSeq_NUMB = CASE WHEN @An_MajorIntSeq_NUMB IS NULL OR @An_MajorIntSeq_NUMB = 0
								 THEN NULL
								 ELSE @An_MajorIntSeq_NUMB
							  END;
   SET @An_MinorIntSeq_NUMB = CASE WHEN @An_MinorIntSeq_NUMB IS NULL OR @An_MinorIntSeq_NUMB = 0
								 THEN NULL
								 ELSE @An_MinorIntSeq_NUMB
							  END;
	SET @An_MemberMci_IDNO = CASE WHEN @An_MemberMci_IDNO IS NULL OR @An_MemberMci_IDNO = 0
								 THEN NULL
								 ELSE @An_MemberMci_IDNO
							  END;	
	
	-- 13786 - CSWI - CSWI Alerts - START
	IF NOT EXISTS ( SELECT 1 FROM DMNR_Y1 n
				WHERE n.Case_IDNO = @An_Case_IDNO
					  AND n.Subsystem_CODE = ISNULL(@Ac_Subsystem_CODE, n.Subsystem_CODE)
					  AND n.ActivityMajor_CODE = @Ac_ActivityMajor_CODE
					  AND n.ActivityMinor_CODE = @Ac_ActivityMinor_CODE
					  AND n.MemberMci_IDNO = ISNULL (@An_MemberMci_IDNO, n.MemberMci_IDNO)
					  AND n.MajorIntSeq_NUMB = ISNULL (@An_MajorIntSeq_NUMB, n.MajorIntSeq_NUMB)
					  AND n.MinorIntSeq_NUMB = ISNULL (@An_MinorIntSeq_NUMB, n.MinorIntSeq_NUMB)
					  AND n.Status_CODE = @Lc_RemedyStatusStart_CODE )
	BEGIN
		SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
		RETURN;
	END	
	-- 13786 - CSWI - CSWI Alerts - END

   -- Updating the current In-Progress Activity to insert Next Activity - STARTS
   INSERT HDMNR_Y1
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
   SELECT n.Case_IDNO,
          n.OrderSeq_NUMB,
          n.MajorIntSeq_NUMB,
          n.MinorIntSeq_NUMB,
          n.MemberMci_IDNO,
          n.ActivityMinor_CODE,
          n.ActivityMinorNext_CODE,
          n.Entered_DATE,
          n.Due_DATE,
          n.Status_DATE,
          n.Status_CODE,
          n.ReasonStatus_CODE,
          n.Schedule_NUMB,
          n.Forum_IDNO,
          n.Topic_IDNO,
          n.TotalReplies_QNTY,
          n.[TotalViews_QNTY],
          n.PostLastPoster_IDNO,
          n.UserLastPoster_ID,
          n.LastPost_DTTM,
          n.AlertPrior_DATE,
          n.BeginValidity_DATE,
          @Ad_Run_DATE AS EndValidity_DATE,
          n.WorkerUpdate_ID,
          n.Update_DTTM,
          n.TransactionEventSeq_NUMB,
          n.WorkerDelegate_ID,
          n.Subsystem_CODE,
          n.ActivityMajor_CODE
     FROM DMNR_Y1 n
    WHERE n.Case_IDNO = @An_Case_IDNO
      AND n.Subsystem_CODE = ISNULL(@Ac_Subsystem_CODE, n.Subsystem_CODE)
      AND n.ActivityMajor_CODE = @Ac_ActivityMajor_CODE
      AND n.ActivityMinor_CODE = @Ac_ActivityMinor_CODE
      AND n.MemberMci_IDNO = ISNULL (@An_MemberMci_IDNO, n.MemberMci_IDNO)
      AND n.MajorIntSeq_NUMB = ISNULL (@An_MajorIntSeq_NUMB, n.MajorIntSeq_NUMB)
      AND n.MinorIntSeq_NUMB = ISNULL (@An_MinorIntSeq_NUMB, n.MinorIntSeq_NUMB)
      AND n.Status_CODE = @Lc_RemedyStatusStart_CODE;

   SET @Ln_Rowcount_QNTY = @@ROWCOUNT;

   IF @Ln_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'HDMNR_Y1 INSERT FAILED';

     RAISERROR (50001,16,1);
    END

   -- Code changed to put SY as reason when the Action alerts of CASE remedy are updated
   SET @Ls_Sql_TEXT = 'UPDATE DMNR_Y1';
   SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + CAST(@An_Case_IDNO AS CHAR) + ', Subsystem_CODE = ' + ISNULL (@Ac_Subsystem_CODE, '') + ', ActivityMajor_CODE = ' + @Ac_ActivityMajor_CODE + ', ActivityMinor_CODE = ' + @Ac_ActivityMinor_CODE + ', MajorIntSeq_NUMB = '+CAST(ISNULL (@An_MajorIntSeq_NUMB, 0) AS CHAR) + ', MinorIntSeq_NUMB = '+CAST(ISNULL (@An_MinorIntSeq_NUMB, 0) AS CHAR);

   UPDATE DMNR_Y1
      SET Status_CODE = @Lc_RemedyStatusComplete_CODE,
          ReasonStatus_CODE = @Lc_ReasonStatusSy_CODE,
          Status_DATE = @Ad_Run_DATE,
          BeginValidity_DATE = @Ad_Run_DATE,
          WorkerUpdate_ID = @Ac_SignedonWorker_ID,
          Update_DTTM = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
          TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB
     FROM DMNR_Y1 n
    WHERE n.Case_IDNO = @An_Case_IDNO
      AND n.Subsystem_CODE = ISNULL(@Ac_Subsystem_CODE, n.Subsystem_CODE)
      AND n.ActivityMajor_CODE = @Ac_ActivityMajor_CODE
      AND n.ActivityMinor_CODE = @Ac_ActivityMinor_CODE
      AND n.MemberMci_IDNO = ISNULL (@An_MemberMci_IDNO, n.MemberMci_IDNO)
      AND n.MajorIntSeq_NUMB = ISNULL (@An_MajorIntSeq_NUMB, n.MajorIntSeq_NUMB)
      AND n.MinorIntSeq_NUMB = ISNULL (@An_MinorIntSeq_NUMB, n.MinorIntSeq_NUMB)
      AND n.Status_CODE = @Lc_RemedyStatusStart_CODE;

   SET @Ln_Rowcount_QNTY = @@ROWCOUNT;

   IF @Ln_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'DMNR_Y1 UPDATE FAILED';

     RAISERROR (50001,16,1);
    END

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();
   
   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_ErrorMessage_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END;

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Routine_TEXT,
    @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;
  END CATCH
 END


GO
