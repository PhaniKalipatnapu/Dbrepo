/****** Object:  StoredProcedure [dbo].[BATCH_COMMON$SP_GENERATE_TOPICIDNO]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_COMMON$SP_GENERATE_TOPICIDNO
Programmer Name		: IMP Team
Description			: Generate New TOPIC_IDNO.
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
CREATE PROCEDURE [dbo].[BATCH_COMMON$SP_GENERATE_TOPICIDNO](
 @An_Topic_IDNO            NUMERIC(10) OUTPUT,
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;
  DECLARE  @Lc_StatusFailed_CODE   CHAR(1) = 'F',
           @Lc_StatusSuccess_CODE  CHAR(1) = 'S',
           @Lc_Space_TEXT          CHAR(1) = ' ',
           @Ls_Routine_TEXT        VARCHAR(60) = 'BATCH_COMMON$SP_GENERATE_TOPICIDNO';
  DECLARE  @Ln_Error_NUMB         NUMERIC,
		   @Ln_ErrorLine_NUMB     NUMERIC(11),
           @Ls_Sql_TEXT           VARCHAR(200) = '',
           @Ls_Sqldata_TEXT       VARCHAR(200) = '',
           @Ls_ErrorMessage_TEXT  VARCHAR(4000) = '';
  BEGIN TRY
   

   SET @Ls_Sql_TEXT = 'INSERT INTO ITOPC_Y1';
   SET @Ls_Sqldata_TEXT = '';
   
   INSERT INTO ITOPC_Y1
        (Entered_DATE)
        VALUES (dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME()--Entered_DATE
        );


   SET @Ls_Sql_TEXT = 'ASSIGN TOPIC IDNO';
   SET @Ls_Sqldata_TEXT = '';
   
   SET @An_Topic_IDNO = @@IDENTITY;
   
   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = @Lc_Space_TEXT;
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();
  
   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_ErrorMessage_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END
  
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
