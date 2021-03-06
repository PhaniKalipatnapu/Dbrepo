/****** Object:  StoredProcedure [dbo].[BATCH_FIN_DISBURSEMENT$SP_CHECK_ADDRESS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name    :	BATCH_FIN_DISBURSEMENT$SP_CHECK_ADDRESS
Programmer Name   :	Imp Team
Description       :	Procedure to find out the disbursement medium.
Frequency         :	'DAILY'
Developed On      :	01/31/2012
Called BY         :	BATCH_FIN_DISBURSEMENT$SP_DISB_RECOUP
Called On		  :	
-------------------------------------------------------------------------------------------------------------------						
Modified BY       :
Modified On       :
Version No        :	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_FIN_DISBURSEMENT$SP_CHECK_ADDRESS]
 @Ad_Batch_DATE            DATE,
 @An_Batch_NUMB            NUMERIC(4),
 @Ac_SourceBatch_CODE      CHAR(3),
 @An_SeqReceipt_NUMB       NUMERIC(6),
 @Ac_MediumDisburse_CODE   CHAR (1) OUTPUT,
 @Ac_CdEftChk_INDC         CHAR (1) OUTPUT,
 @Ac_CpDeceInstInca_CODE   CHAR (1) OUTPUT,
 @Ac_Msg_CODE              CHAR(1) OUTPUT,
 @Ac_CheckRecipient_CODE   CHAR(1) OUTPUT,
 @Ac_TypeDisburse_CODE     CHAR(5) OUTPUT,
 @Ac_CheckRecipient_ID     CHAR(10) OUTPUT,
 @Ad_Run_DATE              DATE OUTPUT,
 @Ac_ReasonStatusOld_CODE  CHAR (4) OUTPUT,
 @Ac_SourceReceipt_CODE    CHAR (2) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Ln_CheckRecipientDSS999999994_IDNO NUMERIC(10) = 999999994,
          @Lc_Space_TEXT                      CHAR(1) = ' ',
          @Lc_No_INDC                         CHAR(1) = 'N',
          @Lc_RecipientTypeCpNcp_CODE         CHAR(1) = '1',
          @Lc_Yes_INDC                        CHAR(1) = 'Y',
          @Lc_StatusActive_CODE               CHAR(1) = 'A',
          @Lc_TypeAddressMailing_CODE         CHAR(1) = 'M',
          @Lc_StatusGood_CODE                 CHAR(1) = 'Y',
          @Lc_CheckRecipientFips_CODE         CHAR(1) = '2',
          @Lc_RecipientTypeOthp_CODE          CHAR(1) = '3',
          @Lc_StatusSuccess_CODE              CHAR(1) = 'S',
          @Lc_StatusFailed_CODE               CHAR(1) = 'F',
          @Lc_CpInstInca_CODE                 CHAR(1) = 'I',
          @Lc_MediumDisburseEft_CODE          CHAR(1) = 'E',
          @Lc_MediumDisburseSvc_CODE          CHAR(1) = 'B',
          @Lc_MediumDisburseCheck_CODE        CHAR(1) = 'C',
          @Lc_TypeOthpOffice_CODE             CHAR(1) = 'O',
          @Lc_StatusEftActive_CODE            CHAR(2) = 'AC',
          @Lc_SourceReceiptSC_CODE            CHAR(2) = 'SC',
          @Lc_SourceLocIrs_CODE               CHAR(3) = 'IRS',
          @Lc_TypeAddressState_CODE           CHAR(3) = 'STA',
          @Lc_SubTypeAddressSdu_CODE          CHAR(3) = 'SDU',
          @Lc_TypeAddressInt_CODE             CHAR(3) = 'INT',
          @Lc_SubTypeAddressFrc_CODE          CHAR(3) = 'FRC',
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
		  @Lc_InstitutionDSH_NAME			  CHAR (3) = 'DSH',
		  @Lc_InstitutionFED_NAME			  CHAR (3) = 'FED',
		  @Lc_InstitutionSCI_NAME			  CHAR (3) = 'SCI',		  
		  @Lc_InstitutionWCF_NAME			  CHAR (3) = 'WCF',	
		  @Lc_InstitutionBWCI_NAME			  CHAR (4) = 'BWCI',
		  -- Bug 13518 - SDCI Hold based on 7 Facility names and Run Date is between the Incarceration date and the Release Date logic Change - End -	          
          @Lc_ReasonStatusSdde_CODE           CHAR(4) = 'SDDE',
          @Lc_ReasonStatusSdci_CODE           CHAR(4) = 'SDCI',
          @Lc_TableOthp_ID                    CHAR(4) = 'OTHP',
          @Lc_TableSubRtyp_ID                 CHAR(4) = 'RTYP',
          @Lc_TypeDisburseRefund_CODE         CHAR(5) = 'REFND',
          @Lc_TypeDisbursementRothp_CODE      CHAR(5) = 'ROTHP',
		  -- Bug 13518 - SDCI Hold based on 7 Facility names and Run Date is between the Incarceration date and the Release Date logic Change - Start -
		  @Lc_InstitutionJTVCC_NAME			  CHAR (5) = 'JTVCC',
		  @Lc_InstitutionHRYCI_NAME			  CHAR (5) = 'HRYCI',
		  -- Bug 13518 - SDCI Hold based on 7 Facility names and Run Date is between the Incarceration date and the Release Date logic Change - End -	          
          @Ls_Procedure_NAME                  VARCHAR(100) = 'SP_CHECK_ADDRESS',
          @Ld_Low_DATE                        DATE = '01/01/0001',
          @Ld_High_DATE                       DATE = '12/31/9999';
  DECLARE @Ln_Error_NUMB        NUMERIC(11),
          @Ln_ErrorLine_NUMB    NUMERIC(11),
          @Li_Rowcount_QNTY     SMALLINT,
          @Lc_StatusEft_CODE    CHAR(2),
          @Ls_Sql_TEXT          VARCHAR(100) = '',
          @Ls_Sqldata_TEXT      VARCHAR(1000) = '',
          @Ls_ErrorMessage_TEXT NVARCHAR(4000);

  BEGIN TRY
   SET @Ac_MediumDisburse_CODE = '';
   SET @Ac_CdEftChk_INDC = '';
   SET @Ac_CpDeceInstInca_CODE = '';
   SET @Ac_Msg_CODE = '';
   SET @Ac_MediumDisburse_CODE = @Lc_Space_TEXT;
   SET @Ac_CdEftChk_INDC = @Lc_No_INDC;
   SET @Ac_CpDeceInstInca_CODE = @Lc_No_INDC;

   --Call eft/debit validation only if recipient is CP AND it is not a refund.
   IF @Ac_CheckRecipient_CODE = @Lc_RecipientTypeCpNcp_CODE
      AND @Ac_TypeDisburse_CODE != @Lc_TypeDisburseRefund_CODE
    BEGIN
     IF @Ac_ReasonStatusOld_CODE NOT IN (@Lc_ReasonStatusSdde_CODE, @Lc_ReasonStatusSdci_CODE)
      BEGIN
       SET @Ls_Sql_TEXT = 'SELECT_MDET_Y1';
       SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(@Ac_CheckRecipient_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

       SELECT @Ac_CpDeceInstInca_CODE = @Lc_CpInstInca_CODE
         FROM MDET_Y1 a
        WHERE MemberMci_IDNO = @Ac_CheckRecipient_ID
	    -- Bug 13518 - SDCI Hold based on 7 Facility names and Run Date is between the Incarceration date and the Release Date logic Change - Start -
	    /* If the CP has a record in MDET_Y1 table with the Institution Name that starts with one of the 7 values () (5 digit code plus name of facility), 
	       with the EndValidity_Date as high date and the Run Date is between the Incarceration date and the Release Date, then place the disbursement 
	       on "SDCI – CP hold - CP Incarcerated" in the DHLD_Y1 table with the Hold Type "P – CP Hold" and the Release Date the same date as the Release Date 
	       in the MDET_Y1 table.
	    */
	    AND LTRIM(RTRIM(SUBSTRING(a.Institution_NAME,1,5))) IN (@Lc_InstitutionBWCI_NAME,@Lc_InstitutionJTVCC_NAME,@Lc_InstitutionSCI_NAME,@Lc_InstitutionFED_NAME,@Lc_InstitutionWCF_NAME,@Lc_InstitutionHRYCI_NAME,@Lc_InstitutionDSH_NAME)
	    AND @Ad_Run_DATE BETWEEN Incarceration_DATE AND Release_DATE
	    -- Bug 13518 - SDCI Hold based on 7 Facility names and Run Date is between the Incarceration date and the Release Date logic Change - End -
        AND EndValidity_DATE = @Ld_High_DATE;

       SET @Li_Rowcount_QNTY = @@ROWCOUNT;

       IF @Li_Rowcount_QNTY = 0
        BEGIN
         SET @Ls_Sql_TEXT = 'SELECT_DEMO_Y1 RECPT 1';
         SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(@Ac_CheckRecipient_ID, '');
		-- CONVERT DECEASED DATE AS 'DD/MM/YYYY' FORMAT and check in DEMO table
         SELECT @Ac_CpDeceInstInca_CODE = CASE ISNULL(CONVERT(VARCHAR(10), a.Deceased_DATE, 101), '')
                                           WHEN @Ld_Low_DATE
                                            THEN @Lc_No_INDC
                                           ELSE @Lc_Yes_INDC
                                          END
           FROM DEMO_Y1 a
          WHERE MemberMci_IDNO = @Ac_CheckRecipient_ID;
        END;
      END;

     IF (@Ac_CpDeceInstInca_CODE = @Lc_Yes_INDC)
         OR (@Ac_CpDeceInstInca_CODE = @Lc_CpInstInca_CODE)
      BEGIN
       SET @Ac_CdEftChk_INDC = @Lc_No_INDC;
      END;
     ELSE
      BEGIN
       --First check whether CP has Active EFT Status_CODE
       SET @Ls_Sql_TEXT = 'SELECT_EFTR_Y1 RECPT 1';
       SET @Ls_Sqldata_TEXT = 'CheckRecipient_ID = ' + ISNULL(@Ac_CheckRecipient_ID, '') + ', CheckRecipient_CODE = ' + ISNULL(@Ac_CheckRecipient_CODE, '') + ', StatusEft_CODE = ' + ISNULL(@Lc_StatusEftActive_CODE, '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

       SELECT @Ac_CdEftChk_INDC = @Lc_Yes_INDC,
              @Ac_MediumDisburse_CODE = @Lc_MediumDisburseEft_CODE
         FROM EFTR_Y1 a
        WHERE CheckRecipient_ID = @Ac_CheckRecipient_ID
          AND CheckRecipient_CODE = @Ac_CheckRecipient_CODE
          AND StatusEft_CODE = @Lc_StatusEftActive_CODE
          AND EndValidity_DATE = @Ld_High_DATE;

       SET @Li_Rowcount_QNTY = @@ROWCOUNT;

       IF @Li_Rowcount_QNTY = 0
        BEGIN
         --If not EFT then,check whether CP has Debit Card
         SET @Ls_Sql_TEXT = 'SELECT_DCRS_Y1 RECPT 1';
         SET @Ls_Sqldata_TEXT = 'CheckRecipient_ID = ' + ISNULL(@Ac_CheckRecipient_ID, '') + ', Status_CODE = ' + ISNULL(@Lc_StatusActive_CODE, '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

         SELECT @Ac_CdEftChk_INDC = @Lc_Yes_INDC,
                @Ac_MediumDisburse_CODE = @Lc_MediumDisburseSvc_CODE
           FROM DCRS_Y1 a
          WHERE CheckRecipient_ID = @Ac_CheckRecipient_ID
            AND Status_CODE = @Lc_StatusActive_CODE
            AND EndValidity_DATE = @Ld_High_DATE;

         SET @Li_Rowcount_QNTY = @@ROWCOUNT;

         IF @Li_Rowcount_QNTY = 0
          BEGIN
           SET @Ls_Sql_TEXT = 'SELECT_AHIS_Y1 RECPT 1';
           SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(@Ac_CheckRecipient_ID, '') + ', TypeAddress_CODE = ' + ISNULL(@Lc_TypeAddressMailing_CODE, '') + ', End_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '') + ', Status_CODE = ' + ISNULL(@Lc_StatusGood_CODE, '');

           SELECT TOP 1 @Ac_CdEftChk_INDC = @Lc_Yes_INDC,
                        @Ac_MediumDisburse_CODE = @Lc_MediumDisburseCheck_CODE
             FROM AHIS_Y1 a
            WHERE MemberMci_IDNO = @Ac_CheckRecipient_ID
              AND TypeAddress_CODE = @Lc_TypeAddressMailing_CODE
              AND @Ad_Run_DATE BETWEEN Begin_DATE AND End_DATE
              AND End_DATE = @Ld_High_DATE
              AND Status_CODE = @Lc_StatusGood_CODE;

           SET @Li_Rowcount_QNTY = @@ROWCOUNT;

           IF @Li_Rowcount_QNTY = 0
            BEGIN
             SET @Ac_CdEftChk_INDC = @Lc_No_INDC;
            END
          END;
        END;
      END;
    END;
   ELSE IF @Ac_CheckRecipient_CODE = @Lc_RecipientTypeCpNcp_CODE
      AND @Ac_TypeDisburse_CODE = @Lc_TypeDisburseRefund_CODE
    BEGIN
     -- For SPC refund, get the address from TRIP address table for the initial refund and 
     -- if check is returned & void&Reissued then Confirmed Mailing address should be select from AHIS table. 
     IF @Ac_SourceReceipt_CODE = @Lc_SourceReceiptSC_CODE
      BEGIN

	   SET @Ls_Sql_TEXT = 'SELECT_TADR_Y1 RECPT REFND IR';
	   SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST(@Ad_Batch_DATE AS VARCHAR), '') + ', SourceBatch_CODE = ' + ISNULL(@Ac_SourceBatch_CODE, '') + ', Batch_NUMB = ' + ISNULL(CAST(@An_Batch_NUMB AS VARCHAR), '') + ', SeqReceipt_NUMB = ' + ISNULL(CAST(@An_SeqReceipt_NUMB AS VARCHAR), '');

	   SELECT TOP 1 @Ac_CdEftChk_INDC = @Lc_Yes_INDC,
					@Ac_MediumDisburse_CODE = @Lc_MediumDisburseCheck_CODE
		 FROM TADR_Y1 a
		WHERE Batch_DATE = @Ad_Batch_DATE
		  AND SourceBatch_CODE = @Ac_SourceBatch_CODE
		  AND Batch_NUMB = @An_Batch_NUMB
		  AND SeqReceipt_NUMB = @An_SeqReceipt_NUMB;

	   SET @Li_Rowcount_QNTY = @@ROWCOUNT;

	   IF @Li_Rowcount_QNTY = 0
		BEGIN
		 SET @Ac_CdEftChk_INDC = @Lc_No_INDC;
		END

     IF @Ac_CdEftChk_INDC = @Lc_No_INDC
      BEGIN
       SET @Ls_Sql_TEXT = 'SELECT_AHIS_Y1 RECPT REFND IR';
       SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(@Ac_CheckRecipient_ID, '') + ', TypeAddress_CODE = ' + ISNULL(@Lc_TypeAddressMailing_CODE, '') + ', End_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '') + ', Status_CODE = ' + ISNULL(@Lc_StatusGood_CODE, '') + ', SourceLoc_CODE = ' + ISNULL(@Lc_SourceLocIrs_CODE, '');

       SELECT TOP 1 @Ac_CdEftChk_INDC = @Lc_Yes_INDC,
                    @Ac_MediumDisburse_CODE = @Lc_MediumDisburseCheck_CODE
         FROM AHIS_Y1 a
        WHERE MemberMci_IDNO = @Ac_CheckRecipient_ID
          AND TypeAddress_CODE = @Lc_TypeAddressMailing_CODE
          AND @Ad_Run_DATE BETWEEN Begin_DATE AND End_DATE
          AND End_DATE = @Ld_High_DATE
          AND Status_CODE = @Lc_StatusGood_CODE
          AND SourceLoc_CODE = @Lc_SourceLocIrs_CODE;

       SET @Li_Rowcount_QNTY = @@ROWCOUNT;

       IF @Li_Rowcount_QNTY = 0
        BEGIN
         SET @Ac_CdEftChk_INDC = @Lc_No_INDC;
        END
        END
      END

     IF @Ac_CdEftChk_INDC = @Lc_No_INDC
      BEGIN
       SET @Ls_Sql_TEXT = 'SELECT_AHIS_Y1 RECPT 1 REFND';
       SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(@Ac_CheckRecipient_ID, '') + ', TypeAddress_CODE = ' + ISNULL(@Lc_TypeAddressMailing_CODE, '') + ', End_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '') + ', Status_CODE = ' + ISNULL(@Lc_StatusGood_CODE, '');

       SELECT TOP 1 @Ac_CdEftChk_INDC = @Lc_Yes_INDC,
                    @Ac_MediumDisburse_CODE = @Lc_MediumDisburseCheck_CODE
         FROM AHIS_Y1 a
        WHERE MemberMci_IDNO = @Ac_CheckRecipient_ID
          AND TypeAddress_CODE = @Lc_TypeAddressMailing_CODE
          AND @Ad_Run_DATE BETWEEN Begin_DATE AND End_DATE
          AND End_DATE = @Ld_High_DATE
          AND Status_CODE = @Lc_StatusGood_CODE;

       SET @Li_Rowcount_QNTY = @@ROWCOUNT;

       IF @Li_Rowcount_QNTY = 0
        BEGIN
         SET @Ac_CdEftChk_INDC = @Lc_No_INDC;
        END
      END
    END;
   ELSE IF @Ac_CheckRecipient_CODE = @Lc_CheckRecipientFips_CODE
      AND @Ac_TypeDisburse_CODE NOT IN (@Lc_TypeDisburseRefund_CODE, @Lc_TypeDisbursementRothp_CODE)
    --Check in EFTR_Y1 whether the FIPS is having active EFT
    BEGIN
     SET @Ls_Sql_TEXT = 'SELECT_EFTR_Y1 RECPT 2';
     SET @Ls_Sqldata_TEXT = 'CheckRecipient_ID = ' + ISNULL(@Ac_CheckRecipient_ID,'')+ ', CheckRecipient_CODE = ' + ISNULL(@Ac_CheckRecipient_CODE,'')+ ', StatusEft_CODE = ' + ISNULL(@Lc_StatusEftActive_CODE,'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');

     SELECT TOP 1 @Lc_StatusEft_CODE = StatusEft_CODE
       FROM EFTR_Y1 a
      WHERE CheckRecipient_ID = @Ac_CheckRecipient_ID
        AND CheckRecipient_CODE = @Ac_CheckRecipient_CODE
        AND StatusEft_CODE = @Lc_StatusEftActive_CODE
        AND EndValidity_DATE = @Ld_High_DATE;

     SET @Li_Rowcount_QNTY = @@ROWCOUNT;

     IF @Li_Rowcount_QNTY = 0
      BEGIN
       SET @Ls_Sql_TEXT = 'SELECT_FIPS_Y1 RECPT 2';
       SET @Ls_Sqldata_TEXT = 'Fips_CODE = ' + ISNULL(@Ac_CheckRecipient_ID, '') + ', TypeAddress_CODE = ' + ISNULL(@Lc_TypeAddressState_CODE, '') + ', SubTypeAddress_CODE = ' + ISNULL(@Lc_SubTypeAddressSdu_CODE, '') + ', TypeAddress_CODE = ' + ISNULL(@Lc_TypeAddressInt_CODE, '') + ', SubTypeAddress_CODE = ' + ISNULL(@Lc_SubTypeAddressFrc_CODE, '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

       SELECT @Ac_CdEftChk_INDC = @Lc_Yes_INDC,
              @Ac_MediumDisburse_CODE = @Lc_MediumDisburseCheck_CODE
         FROM FIPS_Y1 a
        WHERE Fips_CODE = @Ac_CheckRecipient_ID
          AND ((TypeAddress_CODE = @Lc_TypeAddressState_CODE
                AND SubTypeAddress_CODE = @Lc_SubTypeAddressSdu_CODE)
                OR (TypeAddress_CODE = @Lc_TypeAddressInt_CODE
                    AND SubTypeAddress_CODE = @Lc_SubTypeAddressFrc_CODE))
          AND EndValidity_DATE = @Ld_High_DATE;

       SET @Li_Rowcount_QNTY = @@ROWCOUNT;

       IF @Li_Rowcount_QNTY = 0
        BEGIN
         SET @Ac_CdEftChk_INDC = @Lc_No_INDC;
        END
      END
     ELSE IF @Li_Rowcount_QNTY <> 0
      BEGIN
       IF @Lc_StatusEft_CODE = @Lc_StatusEftActive_CODE
        BEGIN
         SET @Ac_CdEftChk_INDC = @Lc_Yes_INDC;
         SET @Ac_MediumDisburse_CODE = @Lc_MediumDisburseEft_CODE;
        END
       ELSE
        BEGIN
         SET @Ac_CdEftChk_INDC = @Lc_No_INDC;
        END
      END
    END;
   ELSE IF @Ac_CheckRecipient_CODE = @Lc_CheckRecipientFips_CODE
      AND @Ac_TypeDisburse_CODE IN (@Lc_TypeDisburseRefund_CODE, @Lc_TypeDisbursementRothp_CODE)
    BEGIN
     SET @Ls_Sql_TEXT = 'SELECT_FIPS_Y1 RECPT 2 REFND';
     SET @Ls_Sqldata_TEXT = 'Fips_CODE = ' + ISNULL(@Ac_CheckRecipient_ID, '') + ', TypeAddress_CODE = ' + ISNULL(@Lc_TypeAddressState_CODE, '') + ', SubTypeAddress_CODE = ' + ISNULL(@Lc_SubTypeAddressSdu_CODE, '') + ', TypeAddress_CODE = ' + ISNULL(@Lc_TypeAddressInt_CODE, '') + ', SubTypeAddress_CODE = ' + ISNULL(@Lc_SubTypeAddressFrc_CODE, '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

     SELECT @Ac_CdEftChk_INDC = @Lc_Yes_INDC,
            @Ac_MediumDisburse_CODE = @Lc_MediumDisburseCheck_CODE
       FROM FIPS_Y1 a
      WHERE Fips_CODE = @Ac_CheckRecipient_ID
        AND ((TypeAddress_CODE = @Lc_TypeAddressState_CODE
              AND SubTypeAddress_CODE = @Lc_SubTypeAddressSdu_CODE)
              OR (TypeAddress_CODE = @Lc_TypeAddressInt_CODE
                  AND SubTypeAddress_CODE = @Lc_SubTypeAddressFrc_CODE))
        AND EndValidity_DATE = @Ld_High_DATE;

     SET @Li_Rowcount_QNTY = @@ROWCOUNT;

     IF @Li_Rowcount_QNTY = 0
      BEGIN
       SET @Ac_CdEftChk_INDC = @Lc_No_INDC;
      END;
    END;
   ELSE IF @Ac_CheckRecipient_CODE = @Lc_RecipientTypeOthp_CODE
      AND @Ac_TypeDisburse_CODE NOT IN (@Lc_TypeDisburseRefund_CODE, @Lc_TypeDisbursementRothp_CODE)
    BEGIN
     SET @Ls_Sql_TEXT = 'SELECT_EFTR_Y1 RECPT 3';
     SET @Ls_Sqldata_TEXT = 'CheckRecipient_ID = ' + ISNULL(@Ac_CheckRecipient_ID,'')+ ', CheckRecipient_CODE = ' + ISNULL(@Ac_CheckRecipient_CODE,'')+ ', StatusEft_CODE = ' + ISNULL(@Lc_StatusEftActive_CODE,'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');

     SELECT TOP 1 @Lc_StatusEft_CODE = StatusEft_CODE
       FROM EFTR_Y1 a
      WHERE CheckRecipient_ID = @Ac_CheckRecipient_ID
        AND CheckRecipient_CODE = @Ac_CheckRecipient_CODE
        AND StatusEft_CODE = @Lc_StatusEftActive_CODE
        AND EndValidity_DATE = @Ld_High_DATE;

     SET @Li_Rowcount_QNTY = @@ROWCOUNT;

     IF @Li_Rowcount_QNTY = 0
      BEGIN
       SET @Ls_Sql_TEXT = 'SELECT_OTHP_Y1 RECPT 3';
       SET @Ls_Sqldata_TEXT = 'OtherParty_IDNO = ' + ISNULL(@Ac_CheckRecipient_ID, '') + ', TypeOthp_CODE = ' + ISNULL(@Lc_TypeOthpOffice_CODE, '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

       SELECT @Ac_CdEftChk_INDC = @Lc_Yes_INDC,
              @Ac_MediumDisburse_CODE = @Lc_MediumDisburseCheck_CODE
         FROM OTHP_Y1 a
        WHERE OtherParty_IDNO = @Ac_CheckRecipient_ID
          AND TypeOthp_CODE = @Lc_TypeOthpOffice_CODE
          AND EndValidity_DATE = @Ld_High_DATE;

       SET @Li_Rowcount_QNTY = @@ROWCOUNT;

       IF @Li_Rowcount_QNTY = 0
        BEGIN
         SET @Ac_CdEftChk_INDC = @Lc_No_INDC;
        END;
      END;
     ELSE
      BEGIN
       IF @Lc_StatusEft_CODE = @Lc_StatusEftActive_CODE
        BEGIN
         SET @Ac_CdEftChk_INDC = @Lc_Yes_INDC;
         SET @Ac_MediumDisburse_CODE = @Lc_MediumDisburseEft_CODE;
        END
       ELSE
        BEGIN
         SET @Ac_CdEftChk_INDC = @Lc_No_INDC;
        END
      END
    END;
   -- Consider ROTHP also
   ELSE IF @Ac_CheckRecipient_CODE = @Lc_RecipientTypeOthp_CODE
      AND @Ac_TypeDisburse_CODE IN (@Lc_TypeDisburseRefund_CODE, @Lc_TypeDisbursementRothp_CODE)
      AND @Ac_CheckRecipient_ID LIKE @Ln_CheckRecipientDSS999999994_IDNO -- @Lc_CheckRecipientOffice_IDNO
    BEGIN
     SET @Ls_Sql_TEXT = 'SELECT_OTHP_Y1 RECPT 3 REFND';
     SET @Ls_Sqldata_TEXT = 'OtherParty_IDNO = ' + ISNULL(@Ac_CheckRecipient_ID, '') + ', TypeOthp_CODE = ' + ISNULL(@Lc_TypeOthpOffice_CODE, '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

     SELECT @Ac_CdEftChk_INDC = @Lc_Yes_INDC,
            @Ac_MediumDisburse_CODE = @Lc_MediumDisburseCheck_CODE
       FROM OTHP_Y1 a
      WHERE OtherParty_IDNO = @Ac_CheckRecipient_ID
        AND TypeOthp_CODE = @Lc_TypeOthpOffice_CODE
        AND EndValidity_DATE = @Ld_High_DATE;

     SET @Li_Rowcount_QNTY = @@ROWCOUNT;

     IF @Li_Rowcount_QNTY = 0
      BEGIN
       SET @Ac_CdEftChk_INDC = @Lc_No_INDC;
      END;
    END;
   ELSE IF @Ac_CheckRecipient_CODE = @Lc_RecipientTypeOthp_CODE
      AND @Ac_TypeDisburse_CODE = @Lc_TypeDisbursementRothp_CODE
      AND @Ac_CheckRecipient_ID NOT LIKE @Ln_CheckRecipientDSS999999994_IDNO -- @Lc_CheckRecipientOffice_IDNO
    BEGIN
     SET @Ls_Sql_TEXT = 'SELECT_OTHP_Y1 RECPT 3 ROTHP';
     SET @Ls_Sqldata_TEXT = 'OtherParty_IDNO = ' + ISNULL(@Ac_CheckRecipient_ID, '') + ', Table_ID = ' + ISNULL(@Lc_TableOthp_ID, '') + ', TableSub_ID = ' + ISNULL(@Lc_TableSubRtyp_ID, '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

     SELECT @Ac_CdEftChk_INDC = @Lc_Yes_INDC,
            @Ac_MediumDisburse_CODE = @Lc_MediumDisburseCheck_CODE
       FROM OTHP_Y1 a
      WHERE OtherParty_IDNO = @Ac_CheckRecipient_ID
        AND TypeOthp_CODE IN (SELECT r.Value_CODE
                                FROM REFM_Y1 r
                               WHERE r.Table_ID = @Lc_TableOthp_ID
                                 AND r.TableSub_ID = @Lc_TableSubRtyp_ID)
        AND --Allow refund to All othp types defined in OTHP/RTYP
        EndValidity_DATE = @Ld_High_DATE;

     SET @Li_Rowcount_QNTY = @@ROWCOUNT;

     IF @Li_Rowcount_QNTY = 0
      BEGIN
       SET @Ac_CdEftChk_INDC = @Lc_No_INDC;
      END
    END

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
