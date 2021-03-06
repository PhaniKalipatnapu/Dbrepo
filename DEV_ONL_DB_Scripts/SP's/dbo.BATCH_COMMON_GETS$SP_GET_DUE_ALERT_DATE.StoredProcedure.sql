/****** Object:  StoredProcedure [dbo].[BATCH_COMMON_GETS$SP_GET_DUE_ALERT_DATE]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_COMMON_GETS$SP_GET_DUE_ALERT_DATE
Programmer Name		: IMP Team
Description			: Get Due Alert Date
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
CREATE PROCEDURE [dbo].[BATCH_COMMON_GETS$SP_GET_DUE_ALERT_DATE]
 @Ac_ActivityMinor_CODE    CHAR(5),
 @Ad_Run_DATE              DATE,
 @Ad_DueActivity_DATE      DATETIME2 OUTPUT,
 @Ad_DueAlertWarn_DATE     DATETIME2 OUTPUT,
 @Ac_Msg_CODE              CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_No_INDC            CHAR(1) = 'N',
          @Lc_Yes_INDC           CHAR(1) = 'Y',
          @Lc_StatusSuccess_CODE CHAR(1) = 'S',
          @Lc_StatusFailed_CODE  CHAR(1) = 'F',
          @Ls_Procedure_NAME     VARCHAR(60) = 'BATCH_COMMON_GETS$SP_GET_DUE_ALERT_DATE',
          @Ld_High_DATE          DATE = '12/31/9999';
  DECLARE @Ln_DayToComplete_NUMB NUMERIC(4),
          @Ln_DayAlertWarn_NUMB  NUMERIC(4),
          @Ln_Error_NUMB         NUMERIC(11),
          @Ln_ErrorLine_NUMB     NUMERIC(11),
          @Lc_BusinessDays_INDC  CHAR(1),
          @Ls_Sqldata_TEXT       VARCHAR(100),
          @Ls_Routine_TEXT       VARCHAR(100),
          @Ls_Sql_TEXT           VARCHAR(1000),
          @Ls_ErrorMessage_TEXT  VARCHAR(2000),
          @Ld_DueActivity_DATE   DATETIME2(0),
          @Ld_DueAlertWarn_DATE  DATETIME2(0);

  BEGIN TRY
   SET @Ad_DueActivity_DATE = NULL;
   SET @Ad_DueAlertWarn_DATE = NULL;
   SET @Ac_Msg_CODE = '';
   SET @As_DescriptionError_TEXT = '';
   SET @Ls_Routine_TEXT = 'BATCH_COMMON_GETS$SP_GET_DUE_ALERT_DATE';
   SET @Ls_Sql_TEXT = 'SELECT_VAMNR';
   SET @Ls_Sqldata_TEXT = 'ActivityMinor_CODE = ' + ISNULL(@Ac_ActivityMinor_CODE, '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

   SELECT @Lc_BusinessDays_INDC = a.BusinessDays_INDC,
          @Ln_DayToComplete_NUMB = a.DayToComplete_QNTY,
          @Ln_DayAlertWarn_NUMB = a.DayAlertWarn_QNTY
     FROM AMNR_Y1 a
    WHERE a.ActivityMinor_CODE = @Ac_ActivityMinor_CODE
      AND a.EndValidity_DATE = @Ld_High_DATE;

   IF @Lc_BusinessDays_INDC = @Lc_No_INDC
    BEGIN
     SET @Ld_DueActivity_DATE = DATEADD(DAY, @Ln_DayToComplete_NUMB, @Ad_Run_DATE);
     SET @Ld_DueAlertWarn_DATE = DATEADD(DAY, (@Ln_DayToComplete_NUMB - @Ln_DayAlertWarn_NUMB), @Ad_Run_DATE);
    END
   ELSE
    BEGIN
     IF @Lc_BusinessDays_INDC = @Lc_Yes_INDC
      BEGIN
       SET @Ld_DueActivity_DATE = dbo.BATCH_COMMON$SF_CALCULATE_NTH_BDAY(@Ad_Run_DATE, @Ln_DayToComplete_NUMB);
      END

     SET @Ld_DueAlertWarn_DATE = dbo.BATCH_COMMON$SF_CALCULATE_NTH_BDAY(@Ad_Run_DATE, (@Ln_DayToComplete_NUMB - @Ln_DayAlertWarn_NUMB));
    END

   SET @Ad_DueActivity_DATE = @Ld_DueActivity_DATE;
   SET @Ad_DueAlertWarn_DATE = @Ld_DueAlertWarn_DATE;
   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
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
