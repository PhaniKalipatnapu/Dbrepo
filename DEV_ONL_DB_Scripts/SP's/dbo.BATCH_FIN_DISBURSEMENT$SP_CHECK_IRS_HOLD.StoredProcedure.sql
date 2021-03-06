/****** Object:  StoredProcedure [dbo].[BATCH_FIN_DISBURSEMENT$SP_CHECK_IRS_HOLD]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name    :	BATCH_FIN_DISBURSEMENT$SP_CHECK_IRS_HOLD
Programmer Name   :	Imp Team
Description       :	PROCEDURE to create SNJT hold for IRS joint receipts.
Frequency         :	'DAILY'
Developed On      :	01/31/2012
Called BY         :	None
Called On		  :	
-------------------------------------------------------------------------------------------------------------------						
Modified BY       :
Modified On       :
Version No        :	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_FIN_DISBURSEMENT$SP_CHECK_IRS_HOLD] (
 @Ad_Batch_DATE                 DATE,
 @An_Batch_NUMB                 NUMERIC(4),
 @Ac_SourceBatch_CODE           CHAR(3),
 @An_SeqReceipt_NUMB            NUMERIC(6),
 @Ad_Run_DATE                   DATE,
 @An_EventGlobalSeq_NUMB        NUMERIC (19),
 @Ac_CheckRecipient_ID          CHAR(10),
 @Ac_CheckRecipient_CODE        CHAR(1),
 @An_Case_IDNO                  NUMERIC(6),
 @An_OrderSeq_NUMB              NUMERIC(2),
 @An_ObligationSeq_NUMB         NUMERIC(2),
 @An_EventGlobalSupportSeq_NUMB NUMERIC(19),
 @Ac_TypeDisburse_CODE          CHAR(5),
 @Ad_Disburse_DATE              DATE,
 @An_DisburseSeq_NUMB           NUMERIC(4),
 @Ac_ChldCheckRecipient_ID      CHAR(10),
 @An_Remaining_AMNT             NUMERIC (11, 2) OUTPUT, 
 @Ac_Msg_CODE                   CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT      VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE  @Li_PayeeHold1960_NUMB    INT = 1960,
           @Lc_Yes_TEXT              CHAR(1) = 'Y',
           @Lc_No_TEXT               CHAR(1) = 'N',
           @Lc_TaxJointJ_CODE        CHAR(1) = 'J',
           @Lc_StatusSuccess_CODE    CHAR(1) = 'S',
           @Lc_StatusFailed_CODE     CHAR(1) = 'F',
           @Lc_StatusH_CODE          CHAR(1) = 'H',
           @Lc_TypeHoldI_CODE        CHAR(1) = 'I',
           @Lc_Space_TEXT            CHAR(1) = ' ',
           @Lc_UdcSnjt_CODE          CHAR(4) = 'SNJT',
           @Lc_TypeEntityCase_CODE   CHAR(4) = 'CASE',
           @Lc_TypeEntityRctno_CODE  CHAR(5) = 'RCTNO',
           @Lc_TypeEntityDthld_CODE  CHAR(5) = 'DTHLD',
           @Lc_TypeEntityRcpid_CODE  CHAR(5) = 'RCPID',
           @Lc_TypeEntityRcpcd_CODE  CHAR(5) = 'RCPCD',
           @Ls_Procedure_NAME        VARCHAR(100) = 'SP_CHECK_IRS_HOLD',
           @Ld_High_DATE             DATE = '12/31/9999';
  DECLARE  @Ln_NumDaysHold_QNTY       NUMERIC(9),
           @Ln_Error_NUMB             NUMERIC(11),
           @Ln_ErrorLine_NUMB         NUMERIC(11),
           @Ln_Rowcount_QNTY          NUMERIC(19),
           @Lc_Tanf_CODE              CHAR(1),
           @Lc_TaxJoint_CODE          CHAR(1),
           @Lc_InjuredSpouse_INDC     CHAR(1),
           @Lc_Receipt_IDNO			  CHAR(30),
           @Ls_Sql_TEXT               VARCHAR(100) = '',
           @Ls_SqlData_TEXT           VARCHAR(1000),
           @Ls_ErrorMessage_TEXT      VARCHAR(2000),
           @Ld_Receipt_DATE           DATE,
           @Ld_Release_DATE           DATE;

  BEGIN TRY
   SET @Ls_Sql_TEXT = 'SELECT RCTH_Y1 IRS';
   SET @Ls_SqlData_TEXT = 'Batch_DATE = ' + ISNULL(CAST( @Ad_Batch_DATE AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Ac_SourceBatch_CODE,'')+ ', Batch_NUMB = ' + ISNULL(CAST( @An_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @An_SeqReceipt_NUMB AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');

   SELECT TOP 1 @Ld_Receipt_DATE = Receipt_DATE,
                @Lc_Tanf_CODE = Tanf_CODE,
                @Lc_TaxJoint_CODE = TaxJoint_CODE
     FROM RCTH_Y1 z
    WHERE Batch_DATE = @Ad_Batch_DATE
      AND SourceBatch_CODE = @Ac_SourceBatch_CODE
      AND Batch_NUMB = @An_Batch_NUMB
      AND SeqReceipt_NUMB = @An_SeqReceipt_NUMB
      AND EndValidity_DATE = @Ld_High_DATE;

   SET @Ls_Sql_TEXT = 'SELECT TADR_Y1 IRS';
   SET @Ls_SqlData_TEXT = 'Batch_DATE = ' + ISNULL(CAST(@Ad_Batch_DATE AS VARCHAR), '') + ', SourceBatch_CODE = ' + ISNULL(@Ac_SourceBatch_CODE, '') + ', Batch_NUMB = ' + ISNULL(CAST(@An_Batch_NUMB AS VARCHAR), '') + ', SeqReceipt_NUMB = ' + ISNULL(CAST(@An_SeqReceipt_NUMB AS VARCHAR), '');

   SELECT @Lc_InjuredSpouse_INDC = InjuredSpouse_INDC
     FROM TADR_Y1 a
    WHERE Batch_DATE = @Ad_Batch_DATE
      AND SourceBatch_CODE = @Ac_SourceBatch_CODE
      AND Batch_NUMB = @An_Batch_NUMB
      AND SeqReceipt_NUMB = @An_SeqReceipt_NUMB;

   IF @Lc_Tanf_CODE = @Lc_No_TEXT
      AND @Lc_TaxJoint_CODE = @Lc_TaxJointJ_CODE
      AND @Lc_InjuredSpouse_INDC = @Lc_No_TEXT
    BEGIN
     SET @Ln_NumDaysHold_QNTY = 0;
     SET @Ls_Sql_TEXT = 'SELECT UCAT_Y1';
     SET @Ls_SqlData_TEXT = 'Udc_CODE = ' + ISNULL(@Lc_UdcSnjt_CODE, '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

     SELECT @Ln_NumDaysHold_QNTY = ISNULL (u.NumDaysHold_QNTY, 9999)
       FROM UCAT_Y1 u
      WHERE u.Udc_CODE = @Lc_UdcSnjt_CODE
        AND u.EndValidity_DATE = @Ld_High_DATE;

     SET @Ln_Rowcount_QNTY = @@ROWCOUNT;

     IF @Ln_Rowcount_QNTY = 0
      BEGIN
       SET @Ln_NumDaysHold_QNTY = 0;
      END
    END;

   -- Also check whether the ad_Receipt_DATE + num_of_days_hold >  run date then hold the Receipt otherwise don't.
   IF DATEADD(d, @Ln_NumDaysHold_QNTY, @Ld_Receipt_DATE) > @Ad_Run_DATE
    BEGIN
     SET @Ls_Sql_TEXT = 'SELECT_DUAL_SNJT';
     SET @Ls_SqlData_TEXT = '';

     SELECT @Ld_Release_DATE = CASE
                                WHEN @Ln_NumDaysHold_QNTY = 9999
                                 THEN @Ld_High_DATE
                                ELSE DATEADD(d, @Ln_NumDaysHold_QNTY, @Ld_Receipt_DATE)
                               END;

     SET @Ls_Sql_TEXT = 'INSERT_DHLD_Y1_IRS_HOLD';
     SET @Ls_SqlData_TEXT = 'CheckRecipient_ID = ' + ISNULL(@Ac_CheckRecipient_ID,'')+ ', CheckRecipient_CODE = ' + ISNULL(@Ac_CheckRecipient_CODE,'')+ ', Case_IDNO = ' + ISNULL(CAST( @An_Case_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @An_OrderSeq_NUMB AS VARCHAR ),'')+ ', ObligationSeq_NUMB = ' + ISNULL(CAST( @An_ObligationSeq_NUMB AS VARCHAR ),'')+ ', Batch_DATE = ' + ISNULL(CAST( @Ad_Batch_DATE AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Ac_SourceBatch_CODE,'')+ ', Batch_NUMB = ' + ISNULL(CAST( @An_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @An_SeqReceipt_NUMB AS VARCHAR ),'')+ ', EventGlobalSupportSeq_NUMB = ' + ISNULL(CAST( @An_EventGlobalSupportSeq_NUMB AS VARCHAR ),'')+ ', TypeDisburse_CODE = ' + ISNULL(@Ac_TypeDisburse_CODE,'')+ ', Transaction_AMNT = ' + ISNULL(CAST( @An_Remaining_AMNT AS VARCHAR ),'')+ ', Status_CODE = ' + ISNULL(@Lc_StatusH_CODE,'')+ ', TypeHold_CODE = ' + ISNULL(@Lc_TypeHoldI_CODE,'')+ ', ReasonStatus_CODE = ' + ISNULL(@Lc_UdcSnjt_CODE,'')+ ', ProcessOffset_INDC = ' + ISNULL(@Lc_Yes_TEXT,'')+ ', Transaction_DATE = ' + ISNULL(CAST( @Ad_Run_DATE AS VARCHAR ),'')+ ', Release_DATE = ' + ISNULL(CAST( @Ld_Release_DATE AS VARCHAR ),'')+ ', BeginValidity_DATE = ' + ISNULL(CAST( @Ad_Run_DATE AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST( @An_EventGlobalSeq_NUMB AS VARCHAR ),'')+ ', EventGlobalEndSeq_NUMB = ' + ISNULL('0','')+ ', Disburse_DATE = ' + ISNULL(CAST( @Ad_Disburse_DATE AS VARCHAR ),'')+ ', DisburseSeq_NUMB = ' + ISNULL(CAST( @An_DisburseSeq_NUMB AS VARCHAR ),'')+ ', StatusEscheat_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', StatusEscheat_CODE = ' + ISNULL(@Lc_Space_TEXT,'');

     INSERT DHLD_Y1
            (CheckRecipient_ID,
             CheckRecipient_CODE,
             Case_IDNO,
             OrderSeq_NUMB,
             ObligationSeq_NUMB,
             Batch_DATE,
             SourceBatch_CODE,
             Batch_NUMB,
             SeqReceipt_NUMB,
             EventGlobalSupportSeq_NUMB,
             TypeDisburse_CODE,
             Transaction_AMNT,
             Status_CODE,
             TypeHold_CODE,
             ReasonStatus_CODE,
             ProcessOffset_INDC,
             Transaction_DATE,
             Release_DATE,
             BeginValidity_DATE,
             EndValidity_DATE,
             EventGlobalBeginSeq_NUMB,
             EventGlobalEndSeq_NUMB,
             Disburse_DATE,
             DisburseSeq_NUMB,
             StatusEscheat_DATE,
             StatusEscheat_CODE)             
     VALUES ( @Ac_CheckRecipient_ID,--CheckRecipient_ID
              @Ac_CheckRecipient_CODE,--CheckRecipient_CODE
              @An_Case_IDNO,--Case_IDNO
              @An_OrderSeq_NUMB,--OrderSeq_NUMB
              @An_ObligationSeq_NUMB,--ObligationSeq_NUMB
              @Ad_Batch_DATE,--Batch_DATE
              @Ac_SourceBatch_CODE,--SourceBatch_CODE
              @An_Batch_NUMB,--Batch_NUMB
              @An_SeqReceipt_NUMB,--SeqReceipt_NUMB
              @An_EventGlobalSupportSeq_NUMB,--EventGlobalSupportSeq_NUMB
              @Ac_TypeDisburse_CODE,--TypeDisburse_CODE
              @An_Remaining_AMNT,--Transaction_AMNT
              @Lc_StatusH_CODE,--Status_CODE
              @Lc_TypeHoldI_CODE,--TypeHold_CODE
              @Lc_UdcSnjt_CODE,--ReasonStatus_CODE
              @Lc_Yes_TEXT,--ProcessOffset_INDC
              @Ad_Run_DATE,--Transaction_DATE
              @Ld_Release_DATE,--Release_DATE
              @Ad_Run_DATE,--BeginValidity_DATE
              @Ld_High_DATE,--EndValidity_DATE
              @An_EventGlobalSeq_NUMB,--EventGlobalBeginSeq_NUMB
              0,--EventGlobalEndSeq_NUMB
              @Ad_Disburse_DATE,--Disburse_DATE
              @An_DisburseSeq_NUMB, --DisburseSeq_NUMB
              @Ld_High_DATE,--StatusEscheat_DATE
              @Lc_Space_TEXT --StatusEscheat_CODE
     );

     SET @Ln_Rowcount_QNTY = @@ROWCOUNT;

     IF @Ln_Rowcount_QNTY = 0
      BEGIN
       SET @Ls_ErrorMessage_TEXT = 'INSERT_DHLD_Y1_IRS_HOLD FAILED';

       RAISERROR(50001,16,1);
      END

  	 SET @Ls_Sql_TEXT = 'INSERT_ESEM_Y1_IRS_HOLD-RCTNO-CHECK';
  	 SET @Lc_Receipt_IDNO = dbo.BATCH_COMMON$SF_GET_RECEIPT_NO (@Ad_Batch_DATE, @Ac_SourceBatch_CODE, @An_Batch_NUMB, @An_SeqReceipt_NUMB);
	 SET @Ls_SqlData_TEXT = 'Entity_ID = '+ @Lc_Receipt_IDNO + ', TypeEntity_CODE = ' + ISNULL(@Lc_TypeEntityRctno_CODE, '') + ', EventFunctionalSeq_NUMB = ' + ISNULL(CAST(@Li_PayeeHold1960_NUMB AS VARCHAR), '');
	 IF NOT EXISTS(SELECT 1 FROM ESEM_Y1 WHERE Entity_ID = @Lc_Receipt_IDNO AND EventGlobalSeq_NUMB = @An_EventGlobalSeq_NUMB AND TypeEntity_CODE = @Lc_TypeEntityRctno_CODE AND EventFunctionalSeq_NUMB = @Li_PayeeHold1960_NUMB)
	 BEGIN
     SET @Ls_Sql_TEXT = 'INSERT_ESEM_Y1_IRS_HOLD-RCTNO';
     SET @Lc_Receipt_IDNO = dbo.BATCH_COMMON$SF_GET_RECEIPT_NO (@Ad_Batch_DATE, @Ac_SourceBatch_CODE, @An_Batch_NUMB, @An_SeqReceipt_NUMB);
     SET @Ls_SqlData_TEXT = 'Entity_ID = ' + ISNULL(@Lc_Receipt_IDNO,'')+ ', EventGlobalSeq_NUMB = ' + ISNULL(CAST( @An_EventGlobalSeq_NUMB AS VARCHAR ),'')+ ', TypeEntity_CODE = ' + ISNULL(@Lc_TypeEntityRctno_CODE,'')+ ', EventFunctionalSeq_NUMB = ' + ISNULL(CAST( @Li_PayeeHold1960_NUMB AS VARCHAR ),'');
     INSERT INTO ESEM_Y1
                 (Entity_ID,
                  EventGlobalSeq_NUMB,
                  TypeEntity_CODE,
                  EventFunctionalSeq_NUMB)
          VALUES ( @Lc_Receipt_IDNO,--Entity_ID
                   @An_EventGlobalSeq_NUMB,--EventGlobalSeq_NUMB
                   @Lc_TypeEntityRctno_CODE,--TypeEntity_CODE
                   @Li_PayeeHold1960_NUMB --EventFunctionalSeq_NUMB
				 );
     END

  	 SET @Ls_Sql_TEXT = 'INSERT_ESEM_Y1_IRS_HOLD-DTHLD-CHECK';
	 SET @Ls_SqlData_TEXT = 'Entity_ID = ' + ISNULL(REPLACE(CONVERT(VARCHAR(10), @Ad_Run_DATE, 101), '/', ''), '') + ', EventGlobalSeq_NUMB = ' + ISNULL(CAST(@An_EventGlobalSeq_NUMB AS VARCHAR), '') + ', TypeEntity_CODE = ' + ISNULL(@Lc_TypeEntityDthld_CODE, '') + ', EventFunctionalSeq_NUMB = ' + ISNULL(CAST(@Li_PayeeHold1960_NUMB AS VARCHAR), '');
	 IF NOT EXISTS(SELECT 1 FROM ESEM_Y1 WHERE Entity_ID = ISNULL(REPLACE(CONVERT(VARCHAR(10), @Ad_Run_DATE, 101), '/', ''), '') AND EventGlobalSeq_NUMB = @An_EventGlobalSeq_NUMB AND TypeEntity_CODE = @Lc_TypeEntityDthld_CODE AND EventFunctionalSeq_NUMB = @Li_PayeeHold1960_NUMB)
	 BEGIN
		 SET @Ls_Sql_TEXT = 'INSERT_ESEM_Y1_IRS_HOLD-DTHLD';
		 SET @Ls_SqlData_TEXT = 'Entity_ID = ' + ISNULL(REPLACE(CONVERT(VARCHAR(10), @Ad_Run_DATE, 101), '/', ''), '') + ', EventGlobalSeq_NUMB = ' + ISNULL(CAST(@An_EventGlobalSeq_NUMB AS VARCHAR), '') + ', TypeEntity_CODE = ' + ISNULL(@Lc_TypeEntityDthld_CODE, '') + ', EventFunctionalSeq_NUMB = ' + ISNULL(CAST(@Li_PayeeHold1960_NUMB AS VARCHAR), '');

		 INSERT INTO ESEM_Y1
					 (Entity_ID,
					  EventGlobalSeq_NUMB,
					  TypeEntity_CODE,
					  EventFunctionalSeq_NUMB)
			  VALUES ( ISNULL(REPLACE(CONVERT(VARCHAR(10), @Ad_Run_DATE, 101), '/', ''), ''),--Entity_ID
					   @An_EventGlobalSeq_NUMB,--EventGlobalSeq_NUMB
					   @Lc_TypeEntityDthld_CODE,--TypeEntity_CODE
					   @Li_PayeeHold1960_NUMB --EventFunctionalSeq_NUMB
		 );
	END

  	 SET @Ls_Sql_TEXT = 'INSERT_ESEM_Y1_IRS_HOLD-CASE-CHECK';
  	 SET @Ls_SqlData_TEXT = 'Entity_ID = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '') + ', EventGlobalSeq_NUMB = ' + ISNULL(CAST(@An_EventGlobalSeq_NUMB AS VARCHAR), '') + ', TypeEntity_CODE = ' + ISNULL(@Lc_TypeEntityCase_CODE, '') + ', EventFunctionalSeq_NUMB = ' + ISNULL(CAST(@Li_PayeeHold1960_NUMB AS VARCHAR), '');
	 IF NOT EXISTS(SELECT 1 FROM ESEM_Y1 WHERE Entity_ID = @An_Case_IDNO AND EventGlobalSeq_NUMB = @An_EventGlobalSeq_NUMB AND TypeEntity_CODE = @Lc_TypeEntityCase_CODE AND EventFunctionalSeq_NUMB = @Li_PayeeHold1960_NUMB)
	 BEGIN	
		 SET @Ls_Sql_TEXT = 'INSERT_ESEM_Y1_IRS_HOLD-CASE';
		 SET @Ls_SqlData_TEXT = 'Entity_ID = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '') + ', EventGlobalSeq_NUMB = ' + ISNULL(CAST(@An_EventGlobalSeq_NUMB AS VARCHAR), '') + ', TypeEntity_CODE = ' + ISNULL(@Lc_TypeEntityCase_CODE, '') + ', EventFunctionalSeq_NUMB = ' + ISNULL(CAST(@Li_PayeeHold1960_NUMB AS VARCHAR), '');

		 INSERT INTO ESEM_Y1
					 (Entity_ID,
					  EventGlobalSeq_NUMB,
					  TypeEntity_CODE,
					  EventFunctionalSeq_NUMB)
			  VALUES (@An_Case_IDNO,--Entity_ID
					  @An_EventGlobalSeq_NUMB,--EventGlobalSeq_NUMB
					  @Lc_TypeEntityCase_CODE,--TypeEntity_CODE
					  @Li_PayeeHold1960_NUMB --EventFunctionalSeq_NUMB
		 );
	END

  	 SET @Ls_Sql_TEXT = 'INSERT_ESEM_Y1_IRS_HOLD-RCPID-CHECK';
  	 SET @Ls_SqlData_TEXT = 'Entity_ID = ' + ISNULL(@Ac_ChldCheckRecipient_ID, '') + ', EventGlobalSeq_NUMB = ' + ISNULL(CAST(@An_EventGlobalSeq_NUMB AS VARCHAR), '') + ', TypeEntity_CODE = ' + ISNULL(@Lc_TypeEntityRcpid_CODE, '') + ', EventFunctionalSeq_NUMB = ' + ISNULL(CAST(@Li_PayeeHold1960_NUMB AS VARCHAR), '');
	 IF NOT EXISTS(SELECT 1 FROM ESEM_Y1 WHERE Entity_ID = @Ac_ChldCheckRecipient_ID AND EventGlobalSeq_NUMB = @An_EventGlobalSeq_NUMB AND TypeEntity_CODE = @Lc_TypeEntityRcpid_CODE AND EventFunctionalSeq_NUMB = @Li_PayeeHold1960_NUMB)
	 BEGIN	
		 SET @Ls_Sql_TEXT = 'INSERT_ESEM_Y1_IRS_HOLD-RCPID';
		 SET @Ls_SqlData_TEXT = 'Entity_ID = ' + ISNULL(@Ac_ChldCheckRecipient_ID, '') + ', EventGlobalSeq_NUMB = ' + ISNULL(CAST(@An_EventGlobalSeq_NUMB AS VARCHAR), '') + ', TypeEntity_CODE = ' + ISNULL(@Lc_TypeEntityRcpid_CODE, '') + ', EventFunctionalSeq_NUMB = ' + ISNULL(CAST(@Li_PayeeHold1960_NUMB AS VARCHAR), '');

		 INSERT INTO ESEM_Y1
					 (Entity_ID,
					  EventGlobalSeq_NUMB,
					  TypeEntity_CODE,
					  EventFunctionalSeq_NUMB)
			  VALUES (@Ac_ChldCheckRecipient_ID,--Entity_ID
					  @An_EventGlobalSeq_NUMB,--EventGlobalSeq_NUMB
					  @Lc_TypeEntityRcpid_CODE,--TypeEntity_CODE
					  @Li_PayeeHold1960_NUMB --EventFunctionalSeq_NUMB
		 );
     END

     SET @Ls_Sql_TEXT = 'INSERT_ESEM_Y1_IRS_HOLD-RCPCD-CHECK';
     SET @Ls_SqlData_TEXT = 'Entity_ID = ' + ISNULL(@Ac_CheckRecipient_CODE, '') + ', EventGlobalSeq_NUMB = ' + ISNULL(CAST(@An_EventGlobalSeq_NUMB AS VARCHAR), '') + ', TypeEntity_CODE = ' + ISNULL(@Lc_TypeEntityRcpcd_CODE, '') + ', EventFunctionalSeq_NUMB = ' + ISNULL(CAST(@Li_PayeeHold1960_NUMB AS VARCHAR), '');
	 IF NOT EXISTS(SELECT 1 FROM ESEM_Y1 WHERE Entity_ID = @Ac_CheckRecipient_CODE AND EventGlobalSeq_NUMB = @An_EventGlobalSeq_NUMB AND TypeEntity_CODE = @Lc_TypeEntityRcpcd_CODE AND EventFunctionalSeq_NUMB = @Li_PayeeHold1960_NUMB)
	 BEGIN	
     SET @Ls_Sql_TEXT = 'INSERT_ESEM_Y1_IRS_HOLD-RCPCD';
     SET @Ls_SqlData_TEXT = 'Entity_ID = ' + ISNULL(@Ac_CheckRecipient_CODE, '') + ', EventGlobalSeq_NUMB = ' + ISNULL(CAST(@An_EventGlobalSeq_NUMB AS VARCHAR), '') + ', TypeEntity_CODE = ' + ISNULL(@Lc_TypeEntityRcpcd_CODE, '') + ', EventFunctionalSeq_NUMB = ' + ISNULL(CAST(@Li_PayeeHold1960_NUMB AS VARCHAR), '');

     INSERT INTO ESEM_Y1
                 (Entity_ID,
                  EventGlobalSeq_NUMB,
                  TypeEntity_CODE,
                  EventFunctionalSeq_NUMB)
          VALUES (@Ac_CheckRecipient_CODE,--Entity_ID
                  @An_EventGlobalSeq_NUMB,--EventGlobalSeq_NUMB
                  @Lc_TypeEntityRcpcd_CODE,--TypeEntity_CODE
                  @Li_PayeeHold1960_NUMB --EventFunctionalSeq_NUMB
     );
     END

     SET @An_Remaining_AMNT = 0;
    END

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
