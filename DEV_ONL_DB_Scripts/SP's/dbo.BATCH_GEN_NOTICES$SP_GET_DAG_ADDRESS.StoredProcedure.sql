/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICES$SP_GET_DAG_ADDRESS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICES$SP_GET_DAG_ADDRESS
Programmer Name	:	IMP Team.
Description		:	This procedure is used to get address DEPUTY ATTORNEY GENERAL details from OTHP_Y1
Frequency		:	
Developed On	:	3/16/2012
Called By		:	BATCH_COMMON$SP_FORMAT_BUILD_XML
Called On		:	BATCH_GEN_NOTICE_CM$SP_GET_OTHP_DTLS
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICES$SP_GET_DAG_ADDRESS]
 @An_Case_IDNO             NUMERIC(6),
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusSuccess_CODE CHAR(1) = 'S',
          @Lc_StatusFailed_CODE  CHAR(1) = 'F',
          @Lc_DAGPrefix_TEXT     CHAR(3) = 'DAG';
  DECLARE @Ln_DagWorkerOffice_IDNO NUMERIC(9),
          @Ls_Routine_TEXT         VARCHAR(100),
          @Ls_Sql_TEXT             VARCHAR(200),
          @Ls_Sqldata_TEXT         VARCHAR(400),
          @Ls_Err_Description_TEXT VARCHAR(4000);

  BEGIN TRY
   SET @Ac_Msg_CODE = NULL;
   SET @As_DescriptionError_TEXT = NULL;
   SET @Ls_Routine_TEXT = 'BATCH_GEN_NOTICES$SP_GET_DAG_ADDRESS ';
   SET @Ls_Sql_TEXT = 'SELECT OTHP_Y1';
   SET @Ls_Sqldata_TEXT = 'Recipient_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR(9)), '');
   SET @Ln_DagWorkerOffice_IDNO = (SELECT OthpLegSer_IDNO
                                     FROM COPT_Y1
                                    WHERE County_IDNO = (SELECT County_IDNO
                                                           FROM CASE_Y1
                                                          WHERE Case_IDNO = @An_Case_IDNO));

   IF @Ln_DagWorkerOffice_IDNO <> 0
      AND @Ln_DagWorkerOffice_IDNO IS NOT NULL
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_GEN_NOTICE_MEMBER$SP_GET_OTHP_DTLS';
     SET @Ls_Sqldata_TEXT = 'Recipient_IDNO = ' + ISNULL(CAST(@Ln_DagWorkerOffice_IDNO AS VARCHAR), '');

     EXEC BATCH_GEN_NOTICE_CM$SP_GET_OTHP_DTLS
      @An_OtherParty_IDNO       = @Ln_DagWorkerOffice_IDNO,
      @As_Prefix_TEXT           = @Lc_DAGPrefix_TEXT,
      @Ac_Msg_CODE              = @Ac_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;

     IF @Ac_Msg_CODE != @Lc_StatusSuccess_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END
    END

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   DECLARE @Li_Error_NUMB     INT = ERROR_NUMBER (),
           @Li_ErrorLine_NUMB INT = ERROR_LINE ();

   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

   IF (@Li_Error_NUMB <> 50001)
    BEGIN
     SET @As_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Sql_TEXT,
    @As_ErrorMessage_TEXT     = @As_DescriptionError_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_SqlData_TEXT,
    @An_Error_NUMB            = @Li_Error_NUMB,
    @An_ErrorLine_NUMB        = @Li_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_Err_Description_TEXT OUTPUT;

   SET @As_DescriptionError_TEXT = @Ls_Err_Description_TEXT;
  END CATCH
 END


GO
