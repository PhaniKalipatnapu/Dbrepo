/****** Object:  StoredProcedure [dbo].[BATCH_COMMON$SP_GET_THREAD_DETAILS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_COMMON$SP_GET_THREAD_DETAILS
Programmer Name		: IMP Team
Description			: This procedure is used get the starting and ending records numbers
					  which are needs to processed by the given thread number.
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
CREATE PROCEDURE [dbo].[BATCH_COMMON$SP_GET_THREAD_DETAILS]
   @Ac_Job_ID                  CHAR(7),
   @Ad_Run_DATE                DATE,
   @An_Thread_NUMB             NUMERIC(15),
   @An_RecRestart_NUMB         NUMERIC(15) OUTPUT,
   @An_RecEnd_NUMB             NUMERIC(15) OUTPUT,
   @An_RecStart_NUMB           NUMERIC(15) OUTPUT,
   @Ac_Msg_CODE                CHAR(1) OUTPUT,
   @As_DescriptionError_TEXT   VARCHAR(4000) OUTPUT
AS
   BEGIN
   SET NOCOUNT ON;
  DECLARE  @Lc_StatusSuccess_CODE  CHAR(1) = 'S',
           @Lc_StatusFailed_CODE   CHAR(1) = 'F',
           @Lc_ThreadLocked_INDC   CHAR(1) = 'L',
           @Lc_ThreadAbort_INDC    CHAR(1) = 'A',
           @Lc_ThreadN_INDC        CHAR(1) = 'N',
           @Ls_Routine_TEXT        VARCHAR(60) = 'BATCH_COMMON$SP_GET_THREAD_DETAILS';
  DECLARE  @Ln_Error_NUMB                  NUMERIC,
		   @Ln_RowCount_QNTY               NUMERIC,
           @Ln_ErrorLine_NUMB              NUMERIC(11),           
           @Ls_Sql_TEXT                    VARCHAR(100),
           @Ls_Sqldata_TEXT                VARCHAR(1000),
           @Ls_ErrorMessage_TEXT           VARCHAR(4000) = '';
           
      -- SET  IMPLICIT_TRANSACTIONS  ON
      BEGIN TRY
         SET @An_RecRestart_NUMB = 0;
         SET @An_RecEnd_NUMB = 0;
         SET @An_RecStart_NUMB = 0;
         SET @Ac_Msg_CODE = '';
         SET @As_DescriptionError_TEXT = '';
         
         --Select starting reoord no and ending record no for the passed thread
         SET @Ls_Sql_TEXT = 'SELECT START SEQUENCE RECORD';
         SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL (@Ac_Job_ID, '') + ', Run_DATE = ' + ISNULL (CAST (@Ad_Run_DATE AS VARCHAR), '') + ', THREAD NO = ' + ISNULL (CAST (@An_Thread_NUMB AS VARCHAR), '');

         SELECT @An_RecRestart_NUMB = RecRestart_NUMB,
                @An_RecEnd_NUMB = RecEnd_NUMB,
                @An_RecStart_NUMB = RecStart_NUMB
           FROM JRTL_Y1 j
          WHERE j.Job_ID = @Ac_Job_ID
                AND j.Run_DATE = @Ad_Run_DATE
                AND j.Thread_NUMB = @An_Thread_NUMB
                AND j.ThreadProcess_CODE IN
                       (@Lc_ThreadN_INDC, @Lc_ThreadAbort_INDC);

         --Thread should be processed only if the thread process indicator is 'N' which means the thread is
         --not executed today or if the thread process indicator is 'A' which means thread was aborted
         --and it is going to process again
         SET @Ln_RowCount_QNTY = @@ROWCOUNT;
         IF @Ln_RowCount_QNTY = 0
            BEGIN
               SET @Ls_ErrorMessage_TEXT = 'THIS THREAD IS EITHER NOT AVAILABLE OR ALREADY STARTED';
               
               RAISERROR (50001, 16, 1);
            END
            
         SET @Ls_Sql_TEXT = 'UPDATING JRTL_Y1 FOR THE LOCKING THE STARTING THREAD';
         SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL (@Ac_Job_ID, '') + ', Run_DATE = ' + ISNULL (CAST (@Ad_Run_DATE AS VARCHAR), '') + ', THREAD NO = ' + ISNULL (CAST (@An_Thread_NUMB AS VARCHAR), '');

         UPDATE JRTL_Y1
            SET ThreadProcess_CODE = @Lc_ThreadLocked_INDC
          WHERE     Job_ID = @Ac_Job_ID
                AND Run_DATE = @Ad_Run_DATE
                AND Thread_NUMB = @An_Thread_NUMB;
                
         SET @Ln_RowCount_QNTY = @@ROWCOUNT;
         IF @Ln_RowCount_QNTY = 0
            BEGIN
               SET @Ls_ErrorMessage_TEXT = 'UPDATE JRTL_Y1 FAILED';
               RAISERROR (50001, 16, 1);
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
	@As_Procedure_NAME		  = @Ls_Routine_TEXT,  
	@As_ErrorMessage_TEXT	  = @Ls_ErrorMessage_TEXT,
	@As_Sql_TEXT			  = @Ls_Sql_TEXT,
	@As_Sqldata_TEXT	      = @Ls_Sqldata_TEXT,
	@An_Error_NUMB			  = @Ln_Error_NUMB,
	@An_ErrorLine_NUMB		  = @Ln_ErrorLine_NUMB,  
	@As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT; 
	         
  END CATCH
   END

GO
