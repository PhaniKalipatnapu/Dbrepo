/****** Object:  StoredProcedure [dbo].[BATCH_COMMON$SP_MOD_ALLOCATED_OBLE_OWIZ]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_COMMON$SP_MOD_ALLOCATED_OBLE_OWIZ
Programmer Name		: IMP Team
Description			: This procedure is used to update allocated obligation internally called by SP_MOD_ALLOCATED.
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
CREATE PROCEDURE [dbo].[BATCH_COMMON$SP_MOD_ALLOCATED_OBLE_OWIZ] (
 @An_Case_IDNO             NUMERIC(6, 0),
 @An_OrderSeq_NUMB         NUMERIC(2, 0),
 @An_ObligationSeq_NUMB    NUMERIC(2, 0),
 @An_MemberMci_IDNO        NUMERIC(10, 0),
 @Ac_TypeDebt_CODE         CHAR(2),
 @Ac_Fips_CODE             CHAR(7),
 @Ac_ReasonChange_CODE     CHAR(2),
 @Ac_FreqPeriodic_CODE     CHAR(1),
 @An_Periodic_AMNT         NUMERIC(11, 2),
 @Ad_BeginObleOld_DATE     DATE,
 @Ad_MaxEndOble_DATE       DATE,
 @Ad_BeginObligation_DATE  DATE,
 @Ad_EndObligation_DATE    DATE,
 @Ac_CheckRecipient_ID     CHAR(10),
 @Ac_CheckRecipient_CODE   CHAR(1),
 @An_EventGlobalSeq_NUMB   NUMERIC(19, 0),
 @Ad_Run_DATE              DATE,
 @Ac_Msg_CODE              CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;
  DECLARE  @Lc_StatusSuccess_CODE  CHAR(1) = 'S',
           @Lc_StatusFailed_CODE   CHAR(1) = 'F',
           @Lc_Space_TEXT          CHAR(1) = ' ',
           @Ld_High_DATE           DATE = '12/31/9999',
           @Ld_Low_DATE            DATE = '01/01/0001';
           
  DECLARE  @Ln_RowCount_QNTY      NUMERIC,
           @Ln_Error_NUMB         NUMERIC(11),
           @Ln_ErrorLine_NUMB     NUMERIC(11),
           @Ln_Payback_AMNT       NUMERIC(11,2),
           @Li_Rowcount_QNTY      SMALLINT,
           @Lc_TypePayback_CODE   CHAR(1),
           @Ls_Routine_TEXT       VARCHAR(100) = '',
           @Ls_Sql_TEXT           VARCHAR(400) = '',
           @Ls_ErrorMessage_TEXT  VARCHAR(4000),
           @Ls_Sqldata_TEXT       VARCHAR(4000) = '',
           @Ld_AccrualNext_DATE   DATE,
           @Ld_AccrualLast_DATE   DATE,
           @Ld_Run_DATE           DATE;

  BEGIN TRY
   SET @Ac_Msg_CODE = '';
   SET @As_DescriptionError_TEXT = '';
   SET @Ls_Routine_TEXT = 'BATCH_COMMON$SP_MOD_ALLOCATED_OBLE_OWIZ';
   SET @Ld_Run_DATE = ISNULL(@Ad_Run_DATE, dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME());
   
   SET @Ls_Sql_TEXT = 'SELECT_OBLE_Y1';
   SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @An_Case_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @An_OrderSeq_NUMB AS VARCHAR ),'')+ ', ObligationSeq_NUMB = ' + ISNULL(CAST( @An_ObligationSeq_NUMB AS VARCHAR ),'')+ ', BeginObligation_DATE = ' + ISNULL(CAST( @Ad_BeginObligation_DATE AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');

   SELECT @Ld_AccrualLast_DATE = A.AccrualLast_DATE,
          @Ld_AccrualNext_DATE = A.AccrualNext_DATE,
          @Ln_Payback_AMNT = A.ExpectToPay_AMNT,
          @Lc_TypePayback_CODE = A.ExpectToPay_CODE
     FROM OBLE_Y1 A
    WHERE A.Case_IDNO = @An_Case_IDNO
      AND A.OrderSeq_NUMB = @An_OrderSeq_NUMB
      AND A.ObligationSeq_NUMB = @An_ObligationSeq_NUMB
      AND A.BeginObligation_DATE = @Ad_BeginObligation_DATE
      AND A.EndValidity_DATE = @Ld_High_DATE;

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;

   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ld_AccrualLast_DATE = @Ld_Low_DATE;
     SET @Ld_AccrualNext_DATE = @Ld_Low_DATE;
     SET @Ln_Payback_AMNT = 0;
     SET @Lc_TypePayback_CODE = @Lc_Space_TEXT;
    END

   SET @Ls_Sql_TEXT = ' UPDATE_OBLE_Y1 - 1';
   SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @An_Case_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @An_OrderSeq_NUMB AS VARCHAR ),'')+ ', ObligationSeq_NUMB = ' + ISNULL(CAST( @An_ObligationSeq_NUMB AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');

   UPDATE OBLE_Y1
      SET EndValidity_DATE = @Ld_Run_DATE,
          EventGlobalEndSeq_NUMB = @An_EventGlobalSeq_NUMB
    WHERE Case_IDNO = @An_Case_IDNO
      AND OrderSeq_NUMB = @An_OrderSeq_NUMB
      AND ObligationSeq_NUMB = @An_ObligationSeq_NUMB
      AND BeginObligation_DATE >= @Ad_BeginObleOld_DATE
      AND EndObligation_DATE <= @Ad_MaxEndOble_DATE
      AND EventGlobalBeginSeq_NUMB != @An_EventGlobalSeq_NUMB
      AND EndValidity_DATE = @Ld_High_DATE;

   SET @Ls_Sql_TEXT = ' INSERT_OBLE_Y1 ';
   SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @An_Case_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @An_OrderSeq_NUMB AS VARCHAR ),'')+ ', ObligationSeq_NUMB = ' + ISNULL(CAST( @An_ObligationSeq_NUMB AS VARCHAR ),'')+ ', MemberMci_IDNO = ' + ISNULL(CAST( @An_MemberMci_IDNO AS VARCHAR ),'')+ ', TypeDebt_CODE = ' + ISNULL(@Ac_TypeDebt_CODE,'')+ ', Fips_CODE = ' + ISNULL(@Ac_Fips_CODE,'')+ ', Periodic_AMNT = ' + ISNULL(CAST( @An_Periodic_AMNT AS VARCHAR ),'')+ ', FreqPeriodic_CODE = ' + ISNULL(@Ac_FreqPeriodic_CODE,'')+ ', ExpectToPay_AMNT = ' + ISNULL(CAST( @Ln_Payback_AMNT AS VARCHAR ),'')+ ', BeginObligation_DATE = ' + ISNULL(CAST( @Ad_BeginObligation_DATE AS VARCHAR ),'')+ ', EndObligation_DATE = ' + ISNULL(CAST( @Ad_EndObligation_DATE AS VARCHAR ),'')+ ', CheckRecipient_ID = ' + ISNULL(@Ac_CheckRecipient_ID,'')+ ', CheckRecipient_CODE = ' + ISNULL(@Ac_CheckRecipient_CODE,'')+ ', BeginValidity_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST( @An_EventGlobalSeq_NUMB AS VARCHAR ),'')+ ', EventGlobalEndSeq_NUMB = ' + ISNULL(CAST( 0 AS VARCHAR ),'')+ ', ExpectToPay_CODE = ' + ISNULL(@Lc_TypePayback_CODE,'');

   INSERT OBLE_Y1
          (Case_IDNO,
           OrderSeq_NUMB,
           ObligationSeq_NUMB,
           MemberMci_IDNO,
           TypeDebt_CODE,
           ReasonChange_CODE,
           Fips_CODE,
           Periodic_AMNT,
           FreqPeriodic_CODE,
           ExpectToPay_AMNT,
           BeginObligation_DATE,
           EndObligation_DATE,
           AccrualLast_DATE,
           AccrualNext_DATE,
           CheckRecipient_ID,
           CheckRecipient_CODE,
           BeginValidity_DATE,
           EndValidity_DATE,
           EventGlobalBeginSeq_NUMB,
           EventGlobalEndSeq_NUMB,
           ExpectToPay_CODE)
   VALUES ( @An_Case_IDNO,--Case_IDNO
            @An_OrderSeq_NUMB,--OrderSeq_NUMB
            @An_ObligationSeq_NUMB,--ObligationSeq_NUMB
            @An_MemberMci_IDNO,--MemberMci_IDNO
            @Ac_TypeDebt_CODE,--TypeDebt_CODE
            ISNULL(@Ac_ReasonChange_CODE, @Lc_Space_TEXT),--ReasonChange_CODE
            @Ac_Fips_CODE,--Fips_CODE
            @An_Periodic_AMNT,--Periodic_AMNT
            @Ac_FreqPeriodic_CODE,--FreqPeriodic_CODE
            @Ln_Payback_AMNT,--ExpectToPay_AMNT
            @Ad_BeginObligation_DATE,--BeginObligation_DATE
            @Ad_EndObligation_DATE,--EndObligation_DATE
            CASE @Ld_AccrualLast_DATE
             WHEN @Ld_Low_DATE
              THEN @Ad_BeginObligation_DATE
             ELSE @Ld_AccrualLast_DATE
            END,--AccrualLast_DATE
            CASE @Ld_AccrualNext_DATE
             WHEN @Ld_Low_DATE
              THEN @Ad_BeginObligation_DATE
             ELSE @Ld_AccrualNext_DATE
            END,--AccrualNext_DATE
            @Ac_CheckRecipient_ID,--CheckRecipient_ID
            @Ac_CheckRecipient_CODE,--CheckRecipient_CODE
            @Ld_Run_DATE,--BeginValidity_DATE
            @Ld_High_DATE,--EndValidity_DATE
            @An_EventGlobalSeq_NUMB,--EventGlobalBeginSeq_NUMB
            0,--EventGlobalEndSeq_NUMB
            @Lc_TypePayback_CODE); --ExpectToPay_CODE
   SET @Ln_RowCount_QNTY = @@ROWCOUNT;

   IF @Ln_RowCount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'INSERT INTO OBLE_Y1 FAILED';
     
     RAISERROR(50001,16,1);
    END

   SET @Ls_Sql_TEXT = ' UPDATE_OBLE_Y1 - 2';
   SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @An_Case_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @An_OrderSeq_NUMB AS VARCHAR ),'')+ ', ObligationSeq_NUMB = ' + ISNULL(CAST( @An_ObligationSeq_NUMB AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');

   UPDATE OBLE_Y1
      SET AccrualNext_DATE = BeginObligation_DATE
    WHERE Case_IDNO = @An_Case_IDNO
      AND OrderSeq_NUMB = @An_OrderSeq_NUMB
      AND ObligationSeq_NUMB = @An_ObligationSeq_NUMB
      AND BeginObligation_DATE > @Ld_Run_DATE
      AND EndValidity_DATE = @Ld_High_DATE;

   IF @Ln_RowCount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'UPDATE_OBLE_Y1 - 2 FAILED';     
     RAISERROR(50001,16,1);
    END

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_ErrorMessage_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END;

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
