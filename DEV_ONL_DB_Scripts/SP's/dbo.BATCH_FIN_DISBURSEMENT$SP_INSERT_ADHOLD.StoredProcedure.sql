/****** Object:  StoredProcedure [dbo].[BATCH_FIN_DISBURSEMENT$SP_INSERT_ADHOLD]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_FIN_DISBURSEMENT$SP_INSERT_ADHOLD
Programmer Name 	: IMP Team
Description			: This procedure is to get over disbursed Value_AMNT and recoupment payee from the original RCTH_Y1.
Frequency			: 'DAILY'
Developed On		: 01/31/2012
Called BY			: BATCH_FIN_DISBURSEMENT$SP_DISB_RECOUP
Called On			: None
--------------------------------------------------------------------------------------------------------------------
Modified BY			:
Modified On			:
Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_FIN_DISBURSEMENT$SP_INSERT_ADHOLD]
 @An_Remaining_AMNT             NUMERIC (11, 2) OUTPUT,
 @Ac_CpDeceInstInca_CODE        CHAR (1),
 @Ac_Msg_CODE                   CHAR(1) OUTPUT,
 @Ac_CheckRecipient_ID          CHAR(10) OUTPUT,
 @Ac_CheckRecipient_CODE        CHAR(1) OUTPUT,
 @An_Case_IDNO                  NUMERIC(6) OUTPUT,
 @An_OrderSeq_NUMB              NUMERIC(2) OUTPUT,
 @An_ObligationSeq_NUMB         NUMERIC(2) OUTPUT,
 @Ad_Batch_DATE                 DATE OUTPUT,
 @Ac_SourceBatch_CODE           CHAR(3) OUTPUT,
 @An_Batch_NUMB                 NUMERIC(4) OUTPUT,
 @An_SeqReceipt_NUMB            NUMERIC(6) OUTPUT,
 @An_EventGlobalSupportSeq_NUMB NUMERIC(19) OUTPUT,
 @Ac_TypeDisburse_CODE          CHAR(5) OUTPUT,
 @Ad_Run_DATE                   DATE OUTPUT,
 @An_EventGlobalSeq_NUMB        NUMERIC(19) OUTPUT,
 @Ad_Disburse_DATE              DATE OUTPUT,
 @An_DisburseSeq_NUMB           NUMERIC(4) OUTPUT,
 @As_DescriptionError_TEXT      VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

    DECLARE @Li_PayeeHold1960_NUMB         INT = 1960,
           @Li_AddressHold1930_NUMB       INT = 1930,
           @Lc_Yes_INDC                   CHAR(1) = 'Y',
           @Lc_RecipientTypeFips_CODE     CHAR(1) = '2',
           @Lc_RecipientTypeOthp_CODE     CHAR(1) = '3',
           @Lc_No_INDC                    CHAR(1) = 'N',
           @Lc_Space_TEXT                 CHAR(1) = ' ',
           @Lc_StatusSuccess_CODE         CHAR(1) = 'S',
           @Lc_StatusH_CODE               CHAR(1) = 'H',
           @Lc_CpInstInca_CODE            CHAR(1) = 'I',
           @Lc_TypeHoldP_IDNO             CHAR(1) = 'P',
           @Lc_TypeHoldA_IDNO             CHAR(1) = 'A',
           @Lc_StatusFailed_CODE          CHAR(1) = 'F',
           @Lc_PartReasonStatusSd_CODE    CHAR(2) = 'SD',
           @Lc_PartReasonStatusFa_CODE    CHAR(2) = 'FA',
           @Lc_PartReasonStatusOa_CODE    CHAR(2) = 'OA',
           @Lc_PartReasonStatusNa_CODE    CHAR(2) = 'NA',
           @Lc_PartReasonStatusCa_CODE    CHAR(2) = 'CA',
		   -- Bug 13518 - SDCI Hold based on 7 Facility names and Run Date is between the Incarceration date and the Release Date logic Change - Start -
		   /*
			  BWCI	Delores Baylor - Women's Correctional Institution
			  JTVCC	James T. Vaughn Correctional Institution
			  SCI	Sussex Correctional Institution
			  FED	Federal Institution
			  WCF	John L. Webb Correctional Facility
			  HRYCI	Howard R. Young Correctional Institution
			  DSH	Delaware State Hospital
		   */
		   @Lc_InstitutionDSH_NAME		  CHAR (3) = 'DSH',
		   @Lc_InstitutionFED_NAME		  CHAR (3) = 'FED',
		   @Lc_InstitutionSCI_NAME		  CHAR (3) = 'SCI',
		   @Lc_InstitutionWCF_NAME		  CHAR (3) = 'WCF',	
		   @Lc_InstitutionBWCI_NAME		  CHAR (4) = 'BWCI',
		   -- Bug 13518 - SDCI Hold based on 7 Facility names and Run Date is between the Incarceration date and the Release Date logic Change - End -           
           @Lc_PartReasonStatusSdde_CODE  CHAR(4) = 'SDDE',
           @Lc_PartReasonStatusSdci_CODE  CHAR(4) = 'SDCI',
           @Lc_TypeDisburseRefund_CODE    CHAR(5) = 'REFND',
		   -- Bug 13518 - SDCI Hold based on 7 Facility names and Run Date is between the Incarceration date and the Release Date logic Change - Start -
		   @Lc_InstitutionJTVCC_NAME	  CHAR (5) = 'JTVCC',
		   @Lc_InstitutionHRYCI_NAME	  CHAR (5) = 'HRYCI',
		   -- Bug 13518 - SDCI Hold based on 7 Facility names and Run Date is between the Incarceration date and the Release Date logic Change - End -	           
           @Lc_TypeEntityRctno_CODE       CHAR(30) = 'RCTNO',
           @Lc_TypeEntityCase_CODE        CHAR(30) = 'CASE',
           @Lc_TypeEntityRcpid_CODE       CHAR(30) = 'RCPID',
           @Lc_TypeEntityRcpcd_CODE       CHAR(30) = 'RCPCD',
           @Lc_TypeEntityDthld_CODE       CHAR(30) = 'DTHLD',
           @Ls_Procedure_NAME             VARCHAR(100) = 'SP_INSERT_ADHOLD',
           @Ld_High_DATE                  DATE = '12/31/9999';
  DECLARE  @Ln_Error_NUMB         NUMERIC(11),
           @Ln_ErrorLine_NUMB     NUMERIC(11),
           @Li_Rowcount_QNTY      SMALLINT,
           @Lc_Receipt_IDNO       CHAR(30),
           @Ls_Sql_TEXT           VARCHAR(100) = '',
           @Ls_Sqldata_TEXT       VARCHAR(1000) = '',
           @Ls_ErrorMessage_TEXT  VARCHAR(4000),
		   -- Bug 13518 - SDCI Hold based on 7 Facility names and Run Date is between the Incarceration date and the Release Date logic Change - Start -
		   @Ld_Release_DATE		  DATE;	
		   -- Bug 13518 - SDCI Hold based on 7 Facility names and Run Date is between the Incarceration date and the Release Date logic Change - End -

  BEGIN TRY
   SET @Ac_Msg_CODE = '';

    -- Bug 13518 - SDCI Hold based on 7 Facility names and Run Date is between the Incarceration date and the Release Date logic Change - Start -
    SET @Ld_Release_DATE = @Ld_High_DATE;
    
    IF @Ac_CpDeceInstInca_CODE = @Lc_CpInstInca_CODE
    BEGIN
    /* If the CP has a record in MDET_Y1 table with the Institution Name that starts with one of the 7 values () (5 digit code plus name of facility), 
       with the EndValidity_Date as high date and the Run Date is between the Incarceration date and the Release Date, then place the disbursement 
       on "SDCI – CP hold - CP Incarcerated" in the DHLD_Y1 table with the Hold Type "P – CP Hold" and the Release Date the same date as the Release Date 
       in the MDET_Y1 table.
    */
	   SET @Ls_Sql_TEXT = 'SELECT_MDET_Y1';
	   SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(@Ac_CheckRecipient_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

       SELECT @Ld_Release_DATE = Release_DATE
         FROM MDET_Y1 a
        WHERE MemberMci_IDNO = @Ac_CheckRecipient_ID
	    AND LTRIM(RTRIM(SUBSTRING(a.Institution_NAME,1,5))) IN (@Lc_InstitutionBWCI_NAME,@Lc_InstitutionJTVCC_NAME,@Lc_InstitutionSCI_NAME,@Lc_InstitutionFED_NAME,@Lc_InstitutionWCF_NAME,@Lc_InstitutionHRYCI_NAME,@Lc_InstitutionDSH_NAME)
	    AND @Ad_Run_DATE BETWEEN Incarceration_DATE AND Release_DATE
        AND EndValidity_DATE = @Ld_High_DATE;
	    -- Bug 13518 - SDCI Hold based on 7 Facility names and Run Date is between the Incarceration date and the Release Date logic Change - End -        
   END 

   SET @Ls_Sql_TEXT = 'INSERT_DHLD_Y1';
   SET @Ls_Sqldata_TEXT = 'CheckRecipient_ID = ' + ISNULL(CAST(@Ac_CheckRecipient_ID AS VARCHAR), '') + ', CheckRecipient_CODE = ' + ISNULL(@Ac_CheckRecipient_CODE, '') + ', Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '') + ', OrderSeq_NUMB = ' + ISNULL(CAST(@An_OrderSeq_NUMB AS VARCHAR), '') + ', ObligationSeq_NUMB = ' + ISNULL(CAST(@An_ObligationSeq_NUMB AS VARCHAR), '') + ', Batch_DATE = ' + ISNULL(CAST(@Ad_Batch_DATE AS VARCHAR), '') + ', SourceBatch_CODE = ' + ISNULL(@Ac_SourceBatch_CODE, '') + ', Batch_NUMB = ' + ISNULL(CAST(@An_Batch_NUMB AS VARCHAR), '') + ', SeqReceipt_NUMB = ' + ISNULL(CAST(@An_SeqReceipt_NUMB AS VARCHAR), '') + ', EventGlobalSupportSeq_NUMB = ' + ISNULL(CAST(@An_EventGlobalSupportSeq_NUMB AS VARCHAR), '') + ', TypeDisburse_CODE = ' + ISNULL(@Ac_TypeDisburse_CODE, '') + ', Transaction_AMNT = ' + ISNULL(CAST(@An_Remaining_AMNT AS VARCHAR), '') + ', Status_CODE = ' + ISNULL(@Lc_StatusH_CODE, '') + ', ProcessOffset_INDC = ' + ISNULL(@Lc_No_INDC, '') + ', Transaction_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', Release_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '') + ', BeginValidity_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '') + ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST(@An_EventGlobalSeq_NUMB AS VARCHAR), '') + ', EventGlobalEndSeq_NUMB = ' + ISNULL('0', '') + ', Disburse_DATE = ' + ISNULL(CAST(@Ad_Disburse_DATE AS VARCHAR), '') + ', DisburseSeq_NUMB = ' + ISNULL(CAST(@An_DisburseSeq_NUMB AS VARCHAR), '') + ', StatusEscheat_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', StatusEscheat_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

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
           StatusEscheat_CODE,
           StatusEscheat_DATE)
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
            CASE
             WHEN (@Ac_CpDeceInstInca_CODE = @Lc_Yes_INDC)
                   OR (@Ac_CpDeceInstInca_CODE = @Lc_CpInstInca_CODE)
              THEN @Lc_TypeHoldP_IDNO
             ELSE @Lc_TypeHoldA_IDNO
            END,--TypeHold_CODE
            CASE @Ac_CpDeceInstInca_CODE
             WHEN @Lc_Yes_INDC
              THEN @Lc_PartReasonStatusSdde_CODE
             WHEN @Lc_CpInstInca_CODE
              THEN @Lc_PartReasonStatusSdci_CODE
             ELSE ISNULL (@Lc_PartReasonStatusSd_CODE, '') + ISNULL (CASE @Ac_CheckRecipient_CODE
                                                                      WHEN @Lc_RecipientTypeFips_CODE
                                                                       THEN @Lc_PartReasonStatusFa_CODE
                                                                      WHEN @Lc_RecipientTypeOthp_CODE
                                                                       THEN @Lc_PartReasonStatusOa_CODE
                                                                      ELSE
                                                                       CASE @Ac_TypeDisburse_CODE
                                                                        WHEN @Lc_TypeDisburseRefund_CODE
                                                                         THEN @Lc_PartReasonStatusNa_CODE
                                                                        ELSE @Lc_PartReasonStatusCa_CODE
                                                                       END
                                                                     END, '')
            END,--ReasonStatus_CODE
            @Lc_No_INDC,--ProcessOffset_INDC
            @Ad_Run_DATE,--Transaction_DATE
			-- Bug 13518 - SDCI Hold based on 7 Facility names and Run Date is between the Incarceration date and the Release Date logic Change - Start -
            CASE
             WHEN (@Ac_CpDeceInstInca_CODE = @Lc_CpInstInca_CODE)
              THEN @Ld_Release_DATE
             ELSE @Ld_High_DATE
            END,--Release_DATE
            -- Bug 13518 - SDCI Hold based on 7 Facility names and Run Date is between the Incarceration date and the Release Date logic Change - End -        
            @Ad_Run_DATE,--BeginValidity_DATE
            @Ld_High_DATE,--EndValidity_DATE
            @An_EventGlobalSeq_NUMB,--EventGlobalBeginSeq_NUMB
            0,--EventGlobalEndSeq_NUMB
            @Ad_Disburse_DATE,--Disburse_DATE
            @An_DisburseSeq_NUMB,--DisburseSeq_NUMB
            @Lc_Space_TEXT,--StatusEscheat_CODE
            @Ld_High_DATE --StatusEscheat_DATE
   );

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;

   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'INSERT_DHLD_Y1 FAILED';

     RAISERROR (50001,16,1);
    END;

   IF (@Ac_CpDeceInstInca_CODE = @Lc_Yes_INDC)
       OR (@Ac_CpDeceInstInca_CODE = @Lc_CpInstInca_CODE)
    BEGIN
     SET @Ls_Sql_TEXT = 'INSERT_PESEM_CPHOLD';
     SET @Lc_Receipt_IDNO = dbo.BATCH_COMMON$SF_GET_RECEIPT_NO (@Ad_Batch_DATE, @Ac_SourceBatch_CODE, @An_Batch_NUMB, @An_SeqReceipt_NUMB);
     SET @Ls_Sqldata_TEXT = '';

     INSERT INTO PESEM_Y1
                 (Entity_ID,
                  EventGlobalSeq_NUMB,
                  TypeEntity_CODE,
                  EventFunctionalSeq_NUMB)
     SELECT @Lc_Receipt_IDNO,
            @An_EventGlobalSeq_NUMB,
            @Lc_TypeEntityRctno_CODE,
            @Li_PayeeHold1960_NUMB
     UNION ALL
     SELECT CAST(@An_Case_IDNO AS VARCHAR),
            @An_EventGlobalSeq_NUMB,
            @Lc_TypeEntityCase_CODE,
            @Li_PayeeHold1960_NUMB
     UNION ALL
     SELECT @Ac_CheckRecipient_ID,
            @An_EventGlobalSeq_NUMB,
            @Lc_TypeEntityRcpid_CODE,
            @Li_PayeeHold1960_NUMB
     UNION ALL
     SELECT @Ac_CheckRecipient_CODE,
            @An_EventGlobalSeq_NUMB,
            @Lc_TypeEntityRcpcd_CODE,
            @Li_PayeeHold1960_NUMB
     UNION ALL
     SELECT REPLACE(CONVERT(VARCHAR(10), @Ad_Run_DATE, 101), '/', ''),
            @An_EventGlobalSeq_NUMB,
            @Lc_TypeEntityDthld_CODE,
            @Li_PayeeHold1960_NUMB;

     SET @Li_Rowcount_QNTY = @@ROWCOUNT;

     IF @Li_Rowcount_QNTY = 0
      BEGIN
       SET @Ls_ErrorMessage_TEXT = 'INSERT_PESEM_CPHOLD FAILED';

       RAISERROR (50001,16,1);
      END;
    END;
   ELSE
    BEGIN
     SET @Ls_Sql_TEXT = 'INSERT_PESEM_ADHOLD';
     SET @Lc_Receipt_IDNO = dbo.BATCH_COMMON$SF_GET_RECEIPT_NO (@Ad_Batch_DATE, @Ac_SourceBatch_CODE, @An_Batch_NUMB, @An_SeqReceipt_NUMB);
     SET @Ls_Sqldata_TEXT = '';

     INSERT INTO PESEM_Y1
                 (Entity_ID,
                  EventGlobalSeq_NUMB,
                  TypeEntity_CODE,
                  EventFunctionalSeq_NUMB)
     SELECT @Lc_Receipt_IDNO,
            @An_EventGlobalSeq_NUMB,
            @Lc_TypeEntityRctno_CODE,
            @Li_AddressHold1930_NUMB
     UNION ALL
     SELECT CAST(@An_Case_IDNO AS VARCHAR),
            @An_EventGlobalSeq_NUMB,
            @Lc_TypeEntityCase_CODE,
            @Li_AddressHold1930_NUMB
     UNION ALL
     SELECT @Ac_CheckRecipient_ID,
            @An_EventGlobalSeq_NUMB,
            @Lc_TypeEntityRcpid_CODE,
            @Li_AddressHold1930_NUMB
     UNION ALL
     SELECT @Ac_CheckRecipient_CODE,
            @An_EventGlobalSeq_NUMB,
            @Lc_TypeEntityRcpcd_CODE,
            @Li_AddressHold1930_NUMB
     UNION ALL
     SELECT REPLACE(CONVERT(VARCHAR(10), @Ad_Run_DATE, 101), '/', ''),
            @An_EventGlobalSeq_NUMB,
            @Lc_TypeEntityDthld_CODE,
            @Li_AddressHold1930_NUMB;

     SET @Li_Rowcount_QNTY = @@ROWCOUNT;

     IF @Li_Rowcount_QNTY = 0
      BEGIN
       SET @Ls_ErrorMessage_TEXT = 'INSERT_PESEM_ADHOLD FAILED';

       RAISERROR (50001,16,1);
      END;
    END;

   SET @An_Remaining_AMNT = 0;
   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
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
  END CATCH;
 END;


GO
