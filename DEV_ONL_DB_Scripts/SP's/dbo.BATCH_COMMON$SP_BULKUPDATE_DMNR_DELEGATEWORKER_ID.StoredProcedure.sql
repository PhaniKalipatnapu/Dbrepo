/****** Object:  StoredProcedure [dbo].[BATCH_COMMON$SP_BULKUPDATE_DMNR_DELEGATEWORKER_ID]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_COMMON$SP_BULKUPDATE_DMNR_DELEGATEWORKER_ID
Programmer Name		: IMP Team
Description			: This procedure is used to check the records in DMNR_Y1 where DelegateWorker_ID is not the new Worker_ID
Frequency			: 
Developed On		: 04/12/2011
Called By			: BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
Called On			: BATCH_COMMON$SP_PROCESS_WORKER_TRANSFER
--------------------------------------------------------------------------------------------------------------------
Modified By			:
Modified On			:
Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_COMMON$SP_BULKUPDATE_DMNR_DELEGATEWORKER_ID]
 @An_Case_IDNO						NUMERIC(6),
 @Ac_Role_ID						CHAR(5),
 @Ac_AssignedWorker_ID				CHAR(30)		= ' ',
 @An_MajorIntSeq_NUMB				NUMERIC(5)		= 0,
 @An_MinorIntSeq_NUMB				NUMERIC(5)		= 0,
 @An_TransactionEventSeq_NUMB		NUMERIC(10),
 @Ad_Run_DATE						DATE,
 @Ac_SignedOnWorker_ID				CHAR(30),
 @Ac_Msg_CODE						CHAR(5)			OUTPUT,
 @As_DescriptionError_TEXT			VARCHAR(4000)	OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Li_Zero_NUMB				INT				= 0,
		  @Li_ModifyAlerts5750_NUMB INT				= 5750,
		  @Lc_Empty_TEXT			CHAR(1)			= '',
          @Lc_StatusFailed_CODE     CHAR(1)			= 'F',
          @Lc_StatusSuccess_CODE    CHAR(1)			= 'S',
          @Lc_Yes_INDC              CHAR(1)			= 'Y',
          @Lc_WorkerAssignS_CODE    CHAR(1)			= 'S',
          @Lc_ActionAlertA_CODE     CHAR(1)			= 'A',
          @Lc_ActionAlertI_CODE     CHAR(1)			= 'I',
          @Lc_StatusStart_CODE      CHAR(4)			= 'STRT',
          @Ls_Procedure_NAME        VARCHAR(100)	= 'BATCH_COMMON$SP_BULKUPDATE_DMNR_DELEGATEWORKER_ID',
          @Ld_High_DATE             DATE			= '12/31/9999';
          
  DECLARE @Li_FetchStatus_QNTY		INT,
          @Ln_Error_NUMB			NUMERIC(11),
          @Ln_ErrorLine_NUMB		NUMERIC(11),
          @Lc_Role_ID				CHAR(5),
          @Ls_Sql_TEXT				VARCHAR(100),
          @Ls_Sqldata_TEXT			VARCHAR(1000),
          @Ls_ErrorMessage_TEXT		VARCHAR(4000)	= '';
          
  BEGIN TRY
  
  SET @Ls_Sql_TEXT = 'UPDATE DMNR_Y1';
  SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + CAST(@An_Case_IDNO AS CHAR(6))+ ', MajorIntSeq_NUMB = ' + CAST( @An_MajorIntSeq_NUMB AS CHAR(5) ) + ', MinorIntSeq_NUMB = ' + CAST( @An_MinorIntSeq_NUMB AS CHAR(5) )+ ', Worker_ID = ' + @Ac_AssignedWorker_ID + ', Role_ID = '+ ISNULL(@Ac_Role_ID,'') + ',TransactionEventSeq_NUMB = ' + CAST( @An_TransactionEventSeq_NUMB AS CHAR(19) )+ ', Run_DATE = ' + CAST( @Ad_Run_DATE AS CHAR(10) ) + ', SignedOnWorker_ID = ' + @Ac_SignedOnWorker_ID;
  
  -- Updates DMNR workerDelegate ID bulk when reassigning Case Primary or secondary worker based on Role.
  IF (@An_MajorIntSeq_NUMB = @Li_Zero_NUMB AND @An_MinorIntSeq_NUMB = @Li_Zero_NUMB)
  BEGIN
  
   SET @Lc_Role_ID = CASE WHEN EXISTS ( SELECT 1
										FROM #PrimaryRole_P1
									   WHERE Role_ID = @Ac_Role_ID )
						   THEN @Lc_Empty_TEXT
						   ELSE	@Ac_Role_ID
					  END;
   UPDATE mn
      SET mn.WorkerDelegate_ID = @Ac_AssignedWorker_ID,
          mn.TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB,
          mn.BeginValidity_DATE = @Ad_Run_DATE,
          mn.WorkerUpdate_ID = @Ac_SignedOnWorker_ID,
          mn.Update_DTTM = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME()
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
		 DELETED.TotalViews_QNTY,
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
		 DELETED.ActivityMajor_CODE,
         DELETED.Subsystem_CODE
    INTO HDMNR_Y1 
     FROM DMNR_Y1 mn
     JOIN AMNR_Y1 an
       ON mn.ActivityMinor_CODE = an.ActivityMinor_CODE
      AND an.ActionAlert_CODE IN ( @Lc_ActionAlertA_CODE, @Lc_ActionAlertI_CODE )
      AND an.EndValidity_DATE = @Ld_High_DATE
    WHERE mn.Case_IDNO = @An_Case_IDNO
          AND mn.WorkerDelegate_ID NOT IN ( @Ac_AssignedWorker_ID, @Lc_Empty_TEXT ) 
          AND ( ( an.ActionAlert_CODE =@Lc_ActionAlertA_CODE
			  AND mn.Status_CODE = @Lc_StatusStart_CODE)
            OR ( an.ActionAlert_CODE = @Lc_ActionAlertI_CODE
               AND mn.AlertPrior_DATE != @Ld_High_DATE
			   AND mn.AlertPrior_DATE >= CAST(@Ad_Run_DATE AS DATE) ) )
          AND mn.TransactionEventSeq_NUMB != @An_TransactionEventSeq_NUMB
          AND EXISTS (SELECT 1
                        FROM ACRL_Y1 ac
                       WHERE ac.Category_CODE = mn.Subsystem_CODE
                         AND ac.SubCategory_CODE = mn.ActivityMajor_CODE
                         AND ac.ActivityMinor_CODE = mn.ActivityMinor_CODE
                         AND ac.EndValidity_DATE = @Ld_High_DATE
                         AND ((ac.WorkerAssign_INDC = @Lc_Yes_INDC
                               AND ac.Role_ID IN (@Ac_Role_ID, @Lc_Role_ID))
                               OR ac.WorkerAssign_INDC = @Lc_WorkerAssignS_CODE))
           AND NOT EXISTS (SELECT 1
                            FROM GLEC_Y1 g
                           WHERE mn.TransactionEventSeq_NUMB = g.TransactionEventSeq_NUMB
                             AND g.EventFunctionalSeq_NUMB = @Li_ModifyAlerts5750_NUMB);
   END
   ELSE
	BEGIN
   
	 UPDATE mn
        SET mn.WorkerDelegate_ID = @Ac_AssignedWorker_ID
       FROM DMNR_Y1 mn
      WHERE mn.Case_IDNO = @An_Case_IDNO
        AND mn.MajorIntSeq_NUMB = @An_MajorIntSeq_NUMB
        AND mn.MinorIntSeq_NUMB = @An_MinorIntSeq_NUMB
        AND mn.TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB
        AND EXISTS (SELECT 1
                        FROM ACRL_Y1 ac
                       WHERE ((ac.WorkerAssign_INDC = @Lc_Yes_INDC
                               AND ac.Role_ID = @Ac_Role_ID)
                               OR ac.WorkerAssign_INDC = @Lc_WorkerAssignS_CODE)
                         AND ac.Category_CODE = mn.Subsystem_CODE
                         AND ac.SubCategory_CODE = mn.ActivityMajor_CODE
                         AND ac.ActivityMinor_CODE = mn.ActivityMinor_CODE
                         AND ac.EndValidity_DATE = @Ld_High_DATE);
     END

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH

   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();
   SET @Ls_ErrorMessage_TEXT =  SUBSTRING (ERROR_MESSAGE (), 1, 200) ;

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;
  END CATCH
 END


GO
