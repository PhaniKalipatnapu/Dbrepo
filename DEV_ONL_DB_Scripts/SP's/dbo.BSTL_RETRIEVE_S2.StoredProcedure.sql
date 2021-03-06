/****** Object:  StoredProcedure [dbo].[BSTL_RETRIEVE_S2]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[BSTL_RETRIEVE_S2] (
 @An_BatchLogSeq_NUMB          NUMERIC(10, 0),
 @Ac_Job_ID                    CHAR(7) OUTPUT,
 @As_Process_NAME              VARCHAR(100) OUTPUT,
 @As_Procedure_NAME            VARCHAR(100) OUTPUT,
 @Ad_EffectiveRun_DATE         DATE OUTPUT,
 @As_CursorLocation_TEXT       VARCHAR(200) OUTPUT,
 @As_ExecLocation_TEXT         VARCHAR(100) OUTPUT,
 @As_ListKey_TEXT              VARCHAR(1000) OUTPUT,
 @Ac_Status_CODE               CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT     VARCHAR(4000) OUTPUT,
 @Ac_Worker_ID                 CHAR(30) OUTPUT,
 @Ad_JobStart_DTTM             DATETIME2 OUTPUT,
 @Ad_JobEnd_DTTM               DATETIME2 OUTPUT,
 @An_ProcessedRecordCount_QNTY NUMERIC(6, 0) OUTPUT,
 @As_DescriptionJob_TEXT       VARCHAR(50) OUTPUT
 )
AS
 /*
 *     PROCEDURE NAME    : BSTL_RETRIEVE_S2
  *     DESCRIPTION       : Retrieve Batch Status Log details for a Row Idno.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SELECT @Ac_Status_CODE = NULL,
         @Ac_Job_ID = NULL,
         @As_DescriptionJob_TEXT = NULL,
         @As_Process_NAME = NULL,
         @As_Procedure_NAME = NULL,
         @Ad_JobEnd_DTTM = NULL,
         @Ad_JobStart_DTTM = NULL,
         @Ad_EffectiveRun_DATE = NULL,
         @As_CursorLocation_TEXT = NULL,
         @As_DescriptionError_TEXT = NULL,
         @As_ExecLocation_TEXT = NULL,
         @As_ListKey_TEXT = NULL,
         @Ac_Worker_ID = NULL,
         @An_ProcessedRecordCount_QNTY = NULL;

  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT @Ac_Job_ID = BS.Job_ID,
         @As_Process_NAME = BS.Process_NAME,
         @As_Procedure_NAME = BS.Procedure_NAME,
         @Ad_EffectiveRun_DATE = BS.EffectiveRun_DATE,
         @As_CursorLocation_TEXT = BS.CursorLocation_TEXT,
         @As_ExecLocation_TEXT = BS.ExecLocation_TEXT,
         @As_ListKey_TEXT = BS.ListKey_TEXT,
         @Ac_Status_CODE = BS.Status_CODE,
         @Ad_JobStart_DTTM = BS.JobStart_DTTM,
         @Ad_JobEnd_DTTM = BS.JobEnd_DTTM,
         @As_DescriptionError_TEXT = BS.DescriptionError_TEXT,
         @Ac_Worker_ID = BS.Worker_ID,
         @An_ProcessedRecordCount_QNTY = BS.ProcessedRecordCount_QNTY,
         @As_DescriptionJob_TEXT = (SELECT JP.DescriptionJob_TEXT
                                      FROM PARM_Y1 JP
                                     WHERE JP.Job_ID = BS.Job_ID
                                       AND JP.EndValidity_DATE = @Ld_High_DATE)
    FROM BSTL_Y1 BS
   WHERE BS.BatchLogSeq_NUMB = @An_BatchLogSeq_NUMB;
 END; --End of BSTL_RETRIEVE_S2

GO
