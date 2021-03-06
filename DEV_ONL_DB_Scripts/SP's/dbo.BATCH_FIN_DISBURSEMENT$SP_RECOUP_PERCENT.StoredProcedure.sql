/****** Object:  StoredProcedure [dbo].[BATCH_FIN_DISBURSEMENT$SP_RECOUP_PERCENT]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_FIN_DISBURSEMENT$SP_RECOUP_PERCENT
Programmer Name 	: IMP Team
Description			: Procedure to create refund records in DSBH_Y1 and DSBL_Y1.
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
CREATE PROCEDURE [dbo].[BATCH_FIN_DISBURSEMENT$SP_RECOUP_PERCENT]
 @An_Disbursed_AMNT           NUMERIC (11, 2) OUTPUT,
 @An_Remaining_AMNT           NUMERIC (11, 2) OUTPUT,
 @Ac_Msg_CODE                 CHAR(1) OUTPUT,
 @Ab_RecpQueried_BIT          BIT OUTPUT,
 @Ac_CheckRecipient_ID        CHAR(10) OUTPUT,
 @Ac_CheckRecipient_CODE      CHAR(1) OUTPUT,
 @An_Case_IDNO                NUMERIC(6) OUTPUT,
 @An_DisbursementAllowed_NUMB NUMERIC (5, 2) OUTPUT,
 @As_DescriptionError_TEXT    VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_RecipientTypeFips_CODE   CHAR(1) = '2',
          @Lc_RecipientTypeCpNcp_CODE  CHAR(1) = '1',
          @Lc_CaseRelationshipCp_CODE  CHAR(1) = 'C',
          @Lc_StatusSuccess_CODE       CHAR(1) = 'S',
          @Lc_StatusFailed_CODE        CHAR(1) = 'F',
          @Lc_TableCrec_ID             CHAR(4) = 'CREC',
          @Lc_TableSubCrec_ID          CHAR(4) = 'PERC',
          @Lc_NoDataFound_TEXT         CHAR(20) = ' NO DATA FOUND ',
          @Lc_NoDefaultPercentage_TEXT CHAR(40) = 'NO DEFAULT % FOUND',
          @Ls_Procedure_NAME           VARCHAR(100) = 'SP_RECOUP_PERCENT',
          @Ld_High_DATE                DATE = '12/31/9999';
  DECLARE @Ln_Disbursed_AMNT      NUMERIC(11, 2),
          @Ln_Error_NUMB          NUMERIC(11),
          @Ln_ErrorLine_NUMB      NUMERIC(11),
          @Li_Rowcount_QNTY       SMALLINT,
          @Lc_CheckRecipient_CODE CHAR(1),
          @Lc_CheckRecipient_ID   CHAR(10),
          @Ls_Sql_TEXT            VARCHAR(100) = '',
          @Ls_Sqldata_TEXT        VARCHAR(1000) = '',
          @Ls_ErrorMessage_TEXT   VARCHAR(4000);

  BEGIN TRY
   SET @Ac_Msg_CODE = '';

   IF NOT @Ab_RecpQueried_BIT != 0
    BEGIN
     SET @Lc_CheckRecipient_ID = @Ac_CheckRecipient_ID;
     SET @Lc_CheckRecipient_CODE = @Ac_CheckRecipient_CODE;

     IF @Lc_CheckRecipient_CODE = @Lc_RecipientTypeFips_CODE
      BEGIN
       SET @Ls_Sql_TEXT = 'SELECT VCMEM_RECP';
       SET @Ls_Sqldata_TEXT = '';

       SELECT TOP (1) @Lc_CheckRecipient_ID = f.MemberMci_IDNO,
                      @Lc_CheckRecipient_CODE = @Lc_RecipientTypeCpNcp_CODE
         FROM (SELECT a.MemberMci_IDNO,
                      a.CaseMemberStatus_CODE
                 FROM CMEM_Y1 a
                WHERE a.Case_IDNO = @An_Case_IDNO
                  AND a.CaseRelationship_CODE = @Lc_CaseRelationshipCp_CODE) AS f
        ORDER BY 2;

       SET @Li_Rowcount_QNTY = @@ROWCOUNT;

       IF @Li_Rowcount_QNTY = 0
        BEGIN
         SET @Ls_ErrorMessage_TEXT = @Ls_Sql_TEXT + @Lc_NoDataFound_TEXT;

         RAISERROR (50001,16,1);
        END;
      END

     --Select from table RECP_Y1 for recoupment percentage
     SET @Ls_Sql_TEXT = 'SELECT RECP_Y1';
     SET @Ls_Sqldata_TEXT = 'CheckRecipient_ID = ' + ISNULL(@Lc_CheckRecipient_ID, '') + ', CheckRecipient_CODE = ' + ISNULL(@Lc_CheckRecipient_CODE, '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

     SELECT @An_DisbursementAllowed_NUMB = (100 - Recoupment_PCT)
       FROM RECP_Y1 a
      WHERE CheckRecipient_ID = @Lc_CheckRecipient_ID
        AND CheckRecipient_CODE = @Lc_CheckRecipient_CODE
        AND EndValidity_DATE = @Ld_High_DATE;

     SET @Li_Rowcount_QNTY = @@ROWCOUNT;

     IF @Li_Rowcount_QNTY = 0
      BEGIN
       -- CHeck : get the percentage from REFM_Y1..
       SET @Ls_Sql_TEXT = 'SELECT REFM_Y1';
       SET @Ls_Sqldata_TEXT = 'Table_ID = ' + ISNULL(@Lc_TableCrec_ID, '') + ', TableSub_ID = ' + ISNULL(@Lc_TableSubCrec_ID, '');

       SELECT @An_DisbursementAllowed_NUMB = (100 - CAST (Value_CODE AS FLOAT))
         FROM REFM_Y1 a
        WHERE Table_ID = @Lc_TableCrec_ID
          AND TableSub_ID = @Lc_TableSubCrec_ID;

       SET @Li_Rowcount_QNTY = @@ROWCOUNT;

       IF @Li_Rowcount_QNTY = 0
        BEGIN
         SET @Ls_ErrorMessage_TEXT = @Lc_NoDefaultPercentage_TEXT;

         RAISERROR (50001,16,1);
        END;
      END;
    END;

   SET @Ln_Disbursed_AMNT = @An_Remaining_AMNT * (@An_DisbursementAllowed_NUMB / 100);
   SET @An_Remaining_AMNT = @An_Remaining_AMNT - @Ln_Disbursed_AMNT;
   SET @An_Disbursed_AMNT = @An_Disbursed_AMNT + @Ln_Disbursed_AMNT;
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
 END


GO
