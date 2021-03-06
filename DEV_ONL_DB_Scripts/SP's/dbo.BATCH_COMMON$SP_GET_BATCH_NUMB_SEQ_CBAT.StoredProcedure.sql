/****** Object:  StoredProcedure [dbo].[BATCH_COMMON$SP_GET_BATCH_NUMB_SEQ_CBAT]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_COMMON$SP_GET_BATCH_NUMB_SEQ_CBAT
Programmer Name		: IMP Team
Description			: This procedure returns next sequence batch number from ICBAT_Y1 (IdentSeqCbat_T1) table as Batch_NUMB.
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
CREATE PROCEDURE [dbo].[BATCH_COMMON$SP_GET_BATCH_NUMB_SEQ_CBAT] (
 @An_Batch_NUMB				NUMERIC(19)		OUTPUT,
 @Ac_Msg_CODE				CHAR(1)			OUTPUT,
 @As_DescriptionError_TEXT	VARCHAR(4000)	OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;
  
  DECLARE @Li_BatchMax_NUMB				INT				= 9999,
		  @Lc_StatusFailed_CODE         CHAR(1)			= 'F',
          @Lc_StatusSuccess_CODE        CHAR(1)			= 'S',
          @Ls_Procedure_NAME			VARCHAR(50)		= 'BATCH_COMMON$SP_GET_BATCH_NUMB_SEQ_CBAT';
  DECLARE @Ln_Error_NUMB				NUMERIC(11),
		  @Ln_ErrorLine_NUMB			NUMERIC(11),
		  @Ln_Batch_NUMB				NUMERIC(19),
          @Ls_Sql_TEXT					VARCHAR(100),
          @Ls_Sqldata_TEXT				VARCHAR(1000)	= '',
          @Ls_ErrorMessage_TEXT			VARCHAR(4000);  
  BEGIN TRY
	  SET @An_Batch_NUMB = 0;
		
	  SET @Ls_Sql_TEXT = 'DELETE ICBAT_Y1';
	  DELETE FROM ICBAT_Y1;

	  SET @Ls_Sql_TEXT = 'INSERT ICBAT_Y1';
	  INSERT INTO ICBAT_Y1
				 (Entered_DATE)
		   VALUES (dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME()--Entered_DATE
				  );

	  SET @Ls_Sql_TEXT = 'SELECT ICBAT_Y1';
	  SELECT @Ln_Batch_NUMB = i.Seq_IDNO
		FROM ICBAT_Y1 i;

	  -- Check Whether Bacth Number reached to 9999 or not. If yes, Truncate the table to restart the seed value from 8201.
	  IF @Ln_Batch_NUMB >= @Li_BatchMax_NUMB
	   BEGIN
			SET @Ls_Sql_TEXT = 'TRUNCATE ICBAT_Y1';
			SET @Ls_Sqldata_TEXT = 'Batch_NUMB = '+CAST(@Ln_Batch_NUMB AS CHAR(5));
			TRUNCATE TABLE IdentSeqCbat_T1;
	   END

	  SET @An_Batch_NUMB = @Ln_Batch_NUMB;
	  SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
	  SET @As_DescriptionError_TEXT = '';
  END TRY
  
  BEGIN CATCH
	SET @An_Batch_NUMB = 0;
	SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

	SET @Ln_Error_NUMB  = ERROR_NUMBER ();
	SET @Ln_ErrorLine_NUMB  = ERROR_LINE ();

	IF (@Ln_Error_NUMB <> 50001)
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
	  @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;

  END CATCH
  
 END;


GO
