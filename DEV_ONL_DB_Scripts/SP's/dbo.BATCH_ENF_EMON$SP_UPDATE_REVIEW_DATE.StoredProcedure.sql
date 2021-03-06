/****** Object:  StoredProcedure [dbo].[BATCH_ENF_EMON$SP_UPDATE_REVIEW_DATE]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/* 
--------------------------------------------------------------------------------------------------- 
Procedure Name			:		BATCH_ENF_EMON$SP_UPDATE_REVIEW_DATE
Programmer Name			: 		IMP Team
Description				:		This procedure is used to update the review date of SORD
Frequency				:
Developed On:			:		01/05/2012
Called By				:		BATCH_ENF_EMON$SP_SYSTEM_UPDATE
Called On				:		BATCH_ENF_EMON$SP_UPDATE_SORD_REVIEW_DATE
-------------------------------------------------------------------------------------------------------
Modified By				:
Modified On				:
Version No				:  		1.0
-----------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_ENF_EMON$SP_UPDATE_REVIEW_DATE] (
 @An_Case_IDNO             NUMERIC(6),
 @An_OrderSeq_NUMB         NUMERIC(2),
 @Ac_ActivityMajor_CODE    CHAR(4),
 @An_MajorIntSeq_NUMB      NUMERIC(5),
 @Ac_WorkerUpdate_ID       CHAR(30),
 @Ad_Run_DATE              DATE,
 @Ac_Msg_CODE              CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusFailed_CODE			CHAR(1)			= 'F',
          @Lc_StatusSuccess_CODE		CHAR(1)			= 'S',
          @Lc_ActivityMajorMapp_CODE	CHAR(4)			= 'MAPP',
          @Lc_TypeReferenceObra_CODE	CHAR(4)			= 'OBRA',
          @Ls_Routine_TEXT				VARCHAR(100)	= 'BATCH_ENF_EMON$SP_UPDATE_REVIEW_DATE';
  DECLARE @Ln_RecordCount_NUMB			NUMERIC			= 0,
          @Ln_Error_NUMB				NUMERIC(11),
          @Ln_ErrorLine_NUMB			NUMERIC(11),
          @Lc_Space_TEXT				CHAR(1)			= '',
          @Ls_Sql_TEXT					VARCHAR(50),
          @Ls_Sqldata_TEXT				VARCHAR(400),
          @Ls_DescriptionError_TEXT		VARCHAR(4000);

  BEGIN TRY
   SET @Ls_Sql_TEXT = 'BATCH_ENF_EMON$SP_UPDATE_REVIEW_DATE SELECT DMJR_Y1';
   SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + CAST(@An_Case_IDNO AS CHAR(6)) + ', MajorIntSeq_NUMB = ' + CAST(@An_MajorIntSeq_NUMB AS CHAR(5)) + ', ActivityMajor_CODE = ' + CAST(@Ac_ActivityMajor_CODE AS CHAR(4));

   SELECT @Ln_RecordCount_NUMB = COUNT(1)
     FROM DMJR_Y1 j
    WHERE j.Case_IDNO = @An_Case_IDNO
      AND j.MajorIntSEQ_NUMB = @An_MajorIntSeq_NUMB
      AND ( (j.ActivityMajor_CODE = @Ac_ActivityMajor_CODE
				AND j.ActivityMajor_CODE != @Lc_ActivityMajorMapp_CODE)
		 OR (j.ActivityMajor_CODE = @Lc_ActivityMajorMapp_CODE
				AND j.TypeReference_CODE = @Lc_TypeReferenceObra_CODE));

   IF @Ln_RecordCount_NUMB > 0
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_ENF_EMON$SP_UPDATE_REVIEW_DATE UPDATE BATCH_ENF_EMON$SP_UPDATE_SORD_REVIEW_DATE';
     SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + CAST(@An_Case_IDNO AS CHAR(6)) + ', OrderSeq_NUMB = ' + CAST(@An_OrderSeq_NUMB AS CHAR(2)) + ', WorkerUpdate_ID = ' + CAST(@Ac_WorkerUpdate_ID AS CHAR(30));

     EXEC BATCH_ENF_EMON$SP_UPDATE_SORD_REVIEW_DATE
      @An_Case_IDNO             = @An_Case_IDNO,
      @An_OrderSeq_NUMB         = @An_OrderSeq_NUMB,
      @Ad_Run_DATE              = @Ad_Run_DATE,
      @Ac_WorkerUpdate_ID       = @Ac_WorkerUpdate_ID,
      @Ac_Msg_CODE              = @Ac_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;

     IF @Ac_Msg_CODE <> @Lc_StatusSuccess_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END
    END

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = @Lc_Space_TEXT;
  END TRY

  BEGIN CATCH
   SET @Ln_Error_NUMB = ERROR_NUMBER ();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE ();
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

   IF (@Ln_Error_NUMB <> 50001)
    BEGIN
     SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Routine_TEXT,
    @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_SqlData_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;
  END CATCH
 END


GO
