/****** Object:  StoredProcedure [dbo].[BATCH_COMMON$SP_INSERT_MATRIX]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_COMMON$SP_INSERT_MATRIX
Programmer Name		: IMP Team
Description			: Add the functional event into the system.
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
CREATE PROCEDURE [dbo].[BATCH_COMMON$SP_INSERT_MATRIX] (
 @Ac_TypeEntity_CODE         CHAR(5),
 @Ac_Entity_ID               CHAR(30),
 @An_EventFunctionalSeq_NUMB NUMERIC(4),
 @An_EventGlobalSeq_NUMB     NUMERIC(19),
 @Ac_Msg_CODE                CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT   VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusSuccess_CODE CHAR(1) = 'S',
          @Lc_StatusFailure_CODE CHAR(1) = 'F',
          @Ls_Procedure_NAME     VARCHAR(100) = 'BATCH_COMMON$SP_INSERT_MATRIX';
  DECLARE @Ln_RowsCount_QNTY    NUMERIC,
          @Ln_Error_NUMB        NUMERIC(11),
          @Ln_ErrorLine_NUMB    NUMERIC(11),
          @Ls_Sql_TEXT          VARCHAR(400),
          @Ls_Sqldata_TEXT      VARCHAR(400),
          @Ls_ErrorMessage_TEXT VARCHAR(4000);

  BEGIN TRY
   SET @Ac_Msg_CODE = '';
   SET @As_DescriptionError_TEXT = '';
   SET @Ls_Sql_TEXT = 'INSERT_ESEM_Y1';
   SET @Ls_Sqldata_TEXT = 'TypeEntity_CODE = ' + ISNULL (@Ac_TypeEntity_CODE, '') + ', EventGlobalSeq_NUMB = ' + ISNULL (CAST (@An_EventGlobalSeq_NUMB AS VARCHAR), '') + ', EventFunctionalSeq_NUMB = ' + ISNULL (CAST (@An_EventFunctionalSeq_NUMB AS VARCHAR), '') + ', Entity_ID = ' + ISNULL (@Ac_Entity_ID, '');

   IF (RTRIM(@Ac_Entity_ID) = ''
        OR RTRIM(@Ac_TypeEntity_CODE) = ''
        OR @An_EventFunctionalSeq_NUMB = 0)
    BEGIN

     SET @Ls_ErrorMessage_TEXT = 'INVALID INPUT';
     RAISERROR (50001,16,1);
    END

   INSERT INTO ESEM_Y1
               (TypeEntity_CODE,
                EventGlobalSeq_NUMB,
                Entity_ID,
                EventFunctionalSeq_NUMB)
        VALUES (@Ac_TypeEntity_CODE,--TypeEntity_CODE
                @An_EventGlobalSeq_NUMB,--EventGlobalSeq_NUMB
                @Ac_Entity_ID,--Entity_ID
                @An_EventFunctionalSeq_NUMB); --EventFunctionalSeq_NUMB
   SET @Ln_RowsCount_QNTY = @@ROWCOUNT;

   IF (@Ln_RowsCount_QNTY = 0)
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'INSERT_ESEM_Y1 FAILED';    
     RAISERROR (50001,16,1);
    END

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailure_CODE;
   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_ErrorMessage_TEXT = SUBSTRING(ERROR_MESSAGE(), 1, 200);
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
