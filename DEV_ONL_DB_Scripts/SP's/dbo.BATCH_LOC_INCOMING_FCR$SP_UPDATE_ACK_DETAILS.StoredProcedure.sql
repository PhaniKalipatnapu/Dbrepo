/****** Object:  StoredProcedure [dbo].[BATCH_LOC_INCOMING_FCR$SP_UPDATE_ACK_DETAILS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
------------------------------------------------------------------------------------------------------------------------
Procedure Name	     : BATCH_LOC_INCOMING_FCR$SP_UPDATE_ACK_DETAILS
Programmer Name		 : IMP Team
Description			 : The procedure updates FCR response in FADT_Y1 table
                       for the acknowledges received.
Frequency			 : Daily
Developed On		 : 04/07/2011
Called By			 : BATCH_LOC_INCOMING_FCR$SP_PROCESS_CASE_ACK_DETAILS
					   BATCH_LOC_INCOMING_FCR$SP_PROCESS_PERSON_ACK_DETAILS
Called On			 : 
------------------------------------------------------------------------------------------------------------------------
Modified By			 : 
Modified On			 :
Version No			 : 1.0
------------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_LOC_INCOMING_FCR$SP_UPDATE_ACK_DETAILS]
 @Ad_Run_DATE              DATE,
 @An_Case_IDNO             NUMERIC(6),
 @An_MemberMci_IDNO        NUMERIC(10),
 @Ac_Response_CODE         CHAR(1),
 @Ac_Msg_CODE              CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE  @Lc_Space_TEXT          CHAR(1) = ' ',
           @Lc_StatusSuccess_CODE  CHAR(1) = 'S',
           @Lc_StatusFailed_CODE   CHAR(1) = 'F',
           @Ls_Procedure_NAME      VARCHAR(60) = 'SP_UPDATE_ACK_DETAILS';
  DECLARE  @Ln_Error_NUMB         NUMERIC(11),
           @Ln_ErrorLine_NUMB     NUMERIC(11),
           @Li_RowCount_QNTY      SMALLINT,
           @Ls_Sql_TEXT           VARCHAR(100),
           @Ls_Sqldata_TEXT       VARCHAR(1000),
           @Ls_ErrorMessage_TEXT  VARCHAR(4000);

  BEGIN TRY
   SET @Ac_Msg_CODE = @Lc_Space_TEXT;
   SET @As_DescriptionError_TEXT = @Lc_Space_TEXT;
   SET @Ls_Sql_TEXT = 'UPDATE FADT_Y1';
   SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR(6)), 0) + ', MemberMci_IDNO = ' + ISNULL(CAST(@An_MemberMci_IDNO AS VARCHAR (10)), 0);
   
   -- Update the FCR audit table with the response code 
   UPDATE FADT_Y1
      SET ResponseFcr_CODE = @Ac_Response_CODE,
          Response_DATE = @Ad_Run_DATE
    WHERE FADT_Y1.Case_IDNO = @An_Case_IDNO
      AND FADT_Y1.MemberMci_IDNO = @An_MemberMci_IDNO;

   SET @Li_RowCount_QNTY = @@ROWCOUNT;

   IF @Li_RowCount_QNTY = 0
    BEGIN
     SET @As_DescriptionError_TEXT = 'UPDATE FAILED FADT_Y1';

     RAISERROR(50001,16,1);
    END

   -- Set the status code to success and error description to spaces
   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = @Lc_Space_TEXT;
  END TRY

  BEGIN CATCH
   --Set Error Description
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   SET @Ln_Error_NUMB = ERROR_NUMBER ();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE ();

   IF @Ln_Error_NUMB <> 50001
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
 END


GO
