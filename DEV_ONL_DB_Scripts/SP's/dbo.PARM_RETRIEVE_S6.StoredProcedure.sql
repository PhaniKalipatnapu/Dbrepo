/****** Object:  StoredProcedure [dbo].[PARM_RETRIEVE_S6]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[PARM_RETRIEVE_S6] (
 @Ac_Job_ID                   CHAR(7),
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0) OUTPUT,
 @As_Process_NAME             VARCHAR(100) OUTPUT,
 @As_Procedure_NAME           VARCHAR(100) OUTPUT,
 @As_DescriptionJob_TEXT      VARCHAR(50) OUTPUT,
 @Ac_JobFreq_CODE             CHAR(1) OUTPUT,
 @Ad_Run_DATE                 DATE OUTPUT,
 @An_CommitFreq_QNTY          NUMERIC(5, 0) OUTPUT,
 @Ac_DayRun_CODE              CHAR(3) OUTPUT,
 @An_ExceptionThreshold_QNTY  NUMERIC(5, 0) OUTPUT,
 @Ac_FileIo_CODE              CHAR(1) OUTPUT,
 @As_File_NAME                VARCHAR(60) OUTPUT,
 @As_Server_NAME              VARCHAR(50) OUTPUT,
 @As_ServerPath_NAME          VARCHAR(60) OUTPUT,
 @An_Thread_NUMB              NUMERIC(2, 0) OUTPUT,
 @An_StartSeq_NUMB            NUMERIC(5, 0) OUTPUT,
 @An_TotalSeq_QNTY            NUMERIC(5, 0) OUTPUT,
 @An_ResponseTime_QNTY        NUMERIC(6, 0) OUTPUT,
 @As_DescriptionMisc_TEXT     VARCHAR(100) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : PARM_RETRIEVE_S6
  *     DESCRIPTION       : Retrieve Job Parm details for a given JobId.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 03-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT @An_TransactionEventSeq_NUMB = NULL,
         @As_Process_NAME = NULL,
         @As_Procedure_NAME = NULL,
         @As_DescriptionJob_TEXT = NULL,
         @Ac_JobFreq_CODE = NULL,
         @Ad_Run_DATE = NULL,
         @An_CommitFreq_QNTY = NULL,
         @Ac_DayRun_CODE = NULL,
         @An_ExceptionThreshold_QNTY = NULL,
         @Ac_FileIo_CODE = NULL,
         @As_File_NAME = NULL,
         @As_Server_NAME = NULL,
         @As_ServerPath_NAME = NULL,
         @An_Thread_NUMB = NULL,
         @An_StartSeq_NUMB = NULL,
         @An_TotalSeq_QNTY = NULL,
         @An_ResponseTime_QNTY = NULL,
         @As_DescriptionMisc_TEXT = NULL;

  SELECT @An_TransactionEventSeq_NUMB = P.TransactionEventSeq_NUMB,
         @As_Process_NAME = P.Process_NAME,
         @As_Procedure_NAME = P.Procedure_NAME,
         @As_DescriptionJob_TEXT = P.DescriptionJob_TEXT,
         @Ac_JobFreq_CODE = P.JobFreq_CODE,
         @Ad_Run_DATE = P.Run_DATE,
         @An_CommitFreq_QNTY = P.CommitFreq_QNTY,
         @Ac_DayRun_CODE = P.DayRun_CODE,
         @An_ExceptionThreshold_QNTY = P.ExceptionThreshold_QNTY,
         @Ac_FileIo_CODE = P.FileIo_CODE,
         @As_File_NAME = P.File_NAME,
         @As_Server_NAME = P.Server_NAME,
         @As_ServerPath_NAME = P.ServerPath_NAME,
         @An_Thread_NUMB = P.Thread_NUMB,
         @An_StartSeq_NUMB = P.StartSeq_NUMB,
         @An_TotalSeq_QNTY = P.TotalSeq_QNTY,
         @An_ResponseTime_QNTY = P.ResponseTime_QNTY,
         @As_DescriptionMisc_TEXT = P.DescriptionMisc_TEXT
    FROM PARM_Y1 P
   WHERE P.Job_ID = @Ac_Job_ID
     AND P.EndValidity_DATE = @Ld_High_DATE;
 END; --End of PARM_RETRIEVE_S6


GO
