/****** Object:  StoredProcedure [dbo].[BATCH_COMMON$SP_GENERATE_SEQ]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_COMMON$SP_GENERATE_SEQ
Programmer Name		: IMP Team
Description			: A record is inserted in the GLEV_Y1 Table and a sequence is used to generate a value
                      for the EventGlobalSeq_NUMB Column
Frequency			: 
Developed On		:	04/12/2011
Called By			:
Called On			:
--------------------------------------------------------------------------------------------------------------------
Modified By			:
Modified On			:
Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_COMMON$SP_GENERATE_SEQ](
 @An_EventFunctionalSeq_NUMB NUMERIC(4),
 @Ac_Process_ID              CHAR(10),
 @Ad_EffectiveEvent_DATE     DATE,
 @Ac_Note_INDC               CHAR(1),
 @Ac_Worker_ID               CHAR(30),
 @An_EventGlobalSeq_NUMB     NUMERIC(19) OUTPUT,
 @Ac_Msg_CODE                CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT   VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusFailed_CODE  CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE CHAR(1) = 'S',
          @Ls_Routine_TEXT       VARCHAR(60) = 'BATCH_COMMON$SP_CREATE_SDER_HOLD';
  DECLARE @Ln_Error_NUMB            NUMERIC,
          @Ln_Rowcount_QNTY         NUMERIC,
          @Ln_Zero_NUMB             NUMERIC(1) = 0,
          @Ln_ErrorLine_NUMB        NUMERIC(11),
          @Ls_Sql_TEXT              VARCHAR(200) = '',
          @Ls_Sqldata_TEXT          VARCHAR(200) = '',
          @Ls_ErrorMessage_TEXT     VARCHAR(4000) = '';

  BEGIN TRY
   SET @An_EventGlobalSeq_NUMB = 0;
   SET @Ac_Msg_CODE = '';
   SET @As_DescriptionError_TEXT = '';
   SET @Ls_Sql_TEXT = 'INSERT INTO GLEV_Y1';
   SET @Ls_Sqldata_TEXT = 'EffectiveEvent_DATE = ' + CAST(@Ad_EffectiveEvent_DATE AS VARCHAR) + ', Event_DTTM = ' + CAST(dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME() AS VARCHAR) + ', Note_INDC = ' + ISNULL (@Ac_Note_INDC, 'N') + ', Worker_ID = ' + @Ac_Worker_ID + ', Process_ID = ' + ISNULL(@Ac_Process_ID, ' ') + ', EventFunctionalSeq_NUMB = ' + CAST(@An_EventFunctionalSeq_NUMB AS VARCHAR);

   INSERT GLEV_Y1
          (EffectiveEvent_DATE,
           Event_DTTM,
           Note_INDC,
           Worker_ID,
           Process_ID,
           EventFunctionalSeq_NUMB)
   VALUES (@Ad_EffectiveEvent_DATE,--EffectiveEvent_DATE
           dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),--Event_DTTM
           ISNULL (@Ac_Note_INDC, 'N'),--Note_INDC
           @Ac_Worker_ID,--Worker_ID
           ISNULL(@Ac_Process_ID, ' '),--Process_ID
           @An_EventFunctionalSeq_NUMB); --EventFunctionalSeq_NUMB
   SET @Ln_Rowcount_QNTY = @@ROWCOUNT;

   IF @Ln_Rowcount_QNTY = @Ln_Zero_NUMB
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'INSERT GLEV_Y1 FAILED';

     RAISERROR (50001,16,1);
    END

   SET @An_EventGlobalSeq_NUMB = @@IDENTITY;
   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
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
