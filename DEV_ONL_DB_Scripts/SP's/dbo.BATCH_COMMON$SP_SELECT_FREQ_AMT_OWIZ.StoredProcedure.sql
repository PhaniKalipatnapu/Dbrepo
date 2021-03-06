/****** Object:  StoredProcedure [dbo].[BATCH_COMMON$SP_SELECT_FREQ_AMT_OWIZ]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_COMMON$SP_SELECT_FREQ_AMT_OWIZ
Programmer Name		: IMP Team
Description			: Procedure returns the Frequency periodic amount and code
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
CREATE PROCEDURE [dbo].[BATCH_COMMON$SP_SELECT_FREQ_AMT_OWIZ] (
 @An_Case_IDNO             NUMERIC(6),
 @An_OrderSeq_NUMB         NUMERIC(2),
 @An_ObligationSeq_NUMB    NUMERIC(2),
 @Ad_BeginObligation_DATE  DATETIME2,
 @Ac_Process_INDC          CHAR(1) = ' ',
 @An_EventGlobalSeq_NUMB   NUMERIC(19),
 @Ac_FreqPeriodic_CODE     CHAR(1) OUTPUT,
 @An_Periodic_AMNT         NUMERIC(11, 2) OUTPUT,
 @Ad_Run_DATE              DATE,
 @Ac_Msg_CODE              CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusSuccess_CODE CHAR (1) = 'S',
          @Lc_StatusFailed_CODE  CHAR (1) = 'F',
          @Ls_Routine_TEXT       VARCHAR (60) = 'BATCH_COMMON$SP_SELECT_FREQ_AMT_OWIZ',
          @Ld_High_DATE          DATE = '12/31/9999';
  DECLARE @Ln_Error_NUMB        NUMERIC,
          @Ln_ErrorLine_NUMB    NUMERIC (11),
          @Ls_Sql_TEXT          VARCHAR (400) = '',
          @Ls_Sqldata_TEXT      VARCHAR (4000) = '',
          @Ls_ErrorMessage_TEXT VARCHAR (4000) = '',
          @Ld_Run_DATE          DATE;

  BEGIN TRY
   SET @Ac_Msg_CODE = '';
   SET @As_DescriptionError_TEXT = '';
   
   SET @Ld_Run_DATE = ISNULL(@Ad_Run_DATE, dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME());
  

   SET @Ls_Sql_TEXT = 'SELECT_OBLE_Y1 1';
   SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @An_Case_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @An_OrderSeq_NUMB AS VARCHAR ),'')+ ', ObligationSeq_NUMB = ' + ISNULL(CAST( @An_ObligationSeq_NUMB AS VARCHAR ),'')+ ', BeginObligation_DATE = ' + ISNULL(CAST( @Ad_BeginObligation_DATE AS VARCHAR ),'')+ ', EventGlobalEndSeq_NUMB = ' + ISNULL(CAST( @An_EventGlobalSeq_NUMB AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ad_Run_DATE AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST( @An_EventGlobalSeq_NUMB AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');

   SELECT @Ac_FreqPeriodic_CODE = a.FreqPeriodic_CODE,
          @An_Periodic_AMNT = a.Periodic_AMNT
     FROM OBLE_Y1 a
    WHERE a.Case_IDNO = @An_Case_IDNO
      AND a.OrderSeq_NUMB = @An_OrderSeq_NUMB
      AND a.ObligationSeq_NUMB = @An_ObligationSeq_NUMB
      AND a.BeginObligation_DATE = @Ad_BeginObligation_DATE
      AND ((@Ac_Process_INDC = 'L'
            AND ((a.EventGlobalEndSeq_NUMB = @An_EventGlobalSeq_NUMB
                  AND a.EndValidity_DATE = @Ad_Run_DATE)
                  OR (a.EventGlobalBeginSeq_NUMB != @An_EventGlobalSeq_NUMB
                      AND a.EndValidity_DATE = @Ld_High_DATE)))
            OR (a.EventGlobalBeginSeq_NUMB = @An_EventGlobalSeq_NUMB
                AND a.EndValidity_DATE = @Ld_High_DATE
                AND @Ac_Process_INDC != 'L')
            OR (a.EndValidity_DATE = @Ld_High_DATE
                AND @Ac_Process_INDC != 'L'));

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = '';
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();
   SET @Ls_ErrorMessage_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);

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
