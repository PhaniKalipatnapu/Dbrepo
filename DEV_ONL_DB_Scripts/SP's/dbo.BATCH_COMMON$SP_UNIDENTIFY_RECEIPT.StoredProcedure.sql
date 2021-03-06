/****** Object:  StoredProcedure [dbo].[BATCH_COMMON$SP_UNIDENTIFY_RECEIPT]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*  
--------------------------------------------------------------------------------------------------------------------  
Procedure Name  : BATCH_COMMON$SP_UNIDENTIFY_RECEIPT
Programmer Name : IMP Team  
Description     : This procedure is used to place the receipt back on Unidentified status
				  for the receipt associated with the given check details.
Frequency       :   
Developed On    : 04/12/2011
Called By       :   
Called ON       :  
--------------------------------------------------------------------------------------------------------------------  
Modified By     :  
Modified On     :  
Version No      : 1.0   
--------------------------------------------------------------------------------------------------------------------  
*/
CREATE PROCEDURE [dbo].[BATCH_COMMON$SP_UNIDENTIFY_RECEIPT] (
 @Ac_CheckRecipient_ID     CHAR(10),
 @Ac_CheckRecipient_CODE   CHAR(1),
 @Ad_Disburse_DATE         DATE,
 @An_DisburseSeq_NUMB      NUMERIC(4, 0),
 @An_EventGlobalSeq_NUMB   NUMERIC(19, 0),
 @Ad_Run_DATE              DATE,
 @Ac_msg_CODE              CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;
  
  DECLARE  @Lc_CheckRecipient3_CODE            CHAR(1) = '3',
           @Lc_CheckRecipient2_CODE            CHAR(1) = '2',
           @Lc_IdentificationStatusO_CODE      CHAR(1) = 'O',
           @Lc_IdentificationStatusU_CODE      CHAR(1) = 'U',
           @Lc_Space_TEXT                      CHAR(1) = ' ',
           @Lc_StatusReceiptUnidentified_CODE  CHAR(1) = 'U',
           @Lc_StatusSuccess_CODE              CHAR(1) = 'S',
           @Lc_StatusFailed_CODE               CHAR(1) = 'F',
           @Lc_ReasonStatusUNID_CODE           CHAR(4) = 'UNID',
           @Ls_Procedure_NAME                  VARCHAR(100) = 'BATCH_COMMON$SP_UNIDENTIFY_RECEIPT',
           @Ld_High_DATE                       DATE = '12/31/9999',
           @Ld_Low_DATE                        DATE = '01/01/0001';
  DECLARE  @Ln_Error_NUMB          NUMERIC,
           @Ln_ErrorLine_NUMB      NUMERIC,
           @Ln_OrderSeq_NUMB       NUMERIC(2,0),
           @Ln_ObligationSeq_NUMB  NUMERIC(2,0),
           @Ln_Batch_NUMB          NUMERIC(4,0),
           @Ln_SeqReceipt_NUMB     NUMERIC(6,0),
           @Ln_RowsAffected_NUMB   NUMERIC(10),
           @Lc_SourceBatch_CODE    CHAR(3),
           @Ls_Sql_TEXT            VARCHAR(200),
           @Ls_SqlData_TEXT        VARCHAR(1000),
           @Ls_ErrorMessage_TEXT   VARCHAR(4000) = '',
           @Ld_Batch_DATE          DATE;

  BEGIN TRY
   SET @Ls_Sql_TEXT = 'SELECT DSBL_Y1';
   SET @Ls_SqlData_TEXT = 'CheckRecipient_ID = ' + CONVERT(VARCHAR, @Ac_CheckRecipient_ID) + ', CheckRecipient_CODE = ' + CONVERT(VARCHAR, @Ac_CheckRecipient_CODE) + ', Disburse_DATE = ' + CONVERT(VARCHAR, @Ad_Disburse_DATE) + ', DisburseSeq_NUMB = ' + CONVERT(VARCHAR, @An_DisburseSeq_NUMB);

   SELECT @Ld_Batch_DATE = D.Batch_DATE,
          @Lc_SourceBatch_CODE = D.SourceBatch_CODE,
          @Ln_Batch_NUMB = D.Batch_NUMB,
          @Ln_SeqReceipt_NUMB = D.SeqReceipt_NUMB,
          @Ln_OrderSeq_NUMB = D.OrderSeq_NUMB,
          @Ln_ObligationSeq_NUMB = D.ObligationSeq_NUMB
     FROM DSBL_Y1 D
    WHERE D.CheckRecipient_ID = @Ac_CheckRecipient_ID
      AND D.CheckRecipient_CODE = @Ac_CheckRecipient_CODE
      AND D.Disburse_DATE = @Ad_Disburse_DATE
      AND D.DisburseSeq_NUMB = @An_DisburseSeq_NUMB
      AND D.DisburseSubSeq_NUMB = 1;

   IF (@Ac_CheckRecipient_CODE IN (@Lc_CheckRecipient3_CODE, @Lc_CheckRecipient2_CODE)
       AND @Ln_OrderSeq_NUMB = 0
       AND @Ln_ObligationSeq_NUMB = 0
       AND @Ld_Batch_DATE != @Ld_Low_DATE)
    BEGIN
     SET @Ls_Sql_TEXT = 'UPDATE URCT_Y1';
     SET @Ls_SqlData_TEXT = 'Batch_DATE = ' + ISNULL(CAST( @Ld_Batch_DATE AS VARCHAR ),'')+ ', Batch_NUMB = ' + ISNULL(CAST( @Ln_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @Ln_SeqReceipt_NUMB AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Lc_SourceBatch_CODE,'')+ ', IdentificationStatus_CODE = ' + ISNULL(@Lc_IdentificationStatusO_CODE,'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');

     UPDATE URCT_Y1
        SET EndValidity_DATE = @Ad_Run_DATE,
            EventGlobalEndSeq_NUMB = @An_EventGlobalSeq_NUMB
      WHERE Batch_DATE = @Ld_Batch_DATE
        AND Batch_NUMB = @Ln_Batch_NUMB
        AND SeqReceipt_NUMB = @Ln_SeqReceipt_NUMB
        AND SourceBatch_CODE = @Lc_SourceBatch_CODE
        AND IdentificationStatus_CODE = @Lc_IdentificationStatusO_CODE
        AND EndValidity_DATE = @Ld_High_DATE;

     SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;

     IF @Ln_RowsAffected_NUMB <> 1
      BEGIN
       SET @Ls_ErrorMessage_TEXT = 'UPDATE URCT_Y1 FAILED';

       RAISERROR (50001,16,1);
      END

     SET @Ls_Sql_TEXT = 'INSERT URCT_Y1';
     SET @Ls_SqlData_TEXT = 'EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST( @An_EventGlobalSeq_NUMB AS VARCHAR ),'')+ ', Identified_DATE = ' + ISNULL(CAST( @Ld_Low_DATE AS VARCHAR ),'')+ ', IdentificationStatus_CODE = ' + ISNULL(@Lc_IdentificationStatusU_CODE,'')+ ', BeginValidity_DATE = ' + ISNULL(CAST( @Ad_Run_DATE AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', StatusEscheat_DATE = ' + ISNULL(CAST( @Ld_Low_DATE AS VARCHAR ),'')+ ', StatusEscheat_CODE = ' + ISNULL(@Lc_Space_TEXT,'');

     INSERT URCT_Y1
            (Batch_DATE,
             SourceBatch_CODE,
             Batch_NUMB,
             SeqReceipt_NUMB,
             EventGlobalBeginSeq_NUMB,
             SourceReceipt_CODE,
             Payor_NAME,
             PayorLine1_ADDR,
             PayorLine2_ADDR,
             PayorCity_ADDR,
             PayorState_ADDR,
             PayorZip_ADDR,
             PayorCountry_ADDR,
             Bank_NAME,
             Bank1_ADDR,
             Bank2_ADDR,
             BankCity_ADDR,
             BankState_ADDR,
             BankZip_ADDR,
             BankCountry_ADDR,
             Bank_IDNO,
             BankAcct_NUMB,
             Remarks_TEXT,
             CaseIdent_IDNO,
             IdentifiedPayorMci_IDNO,
             Identified_DATE,
             OtherParty_IDNO,
             IdentificationStatus_CODE,
             Employer_IDNO,
             IvdAgency_IDNO,
             UnidentifiedMemberMci_IDNO,
             UnidentifiedSsn_NUMB,
             EventGlobalEndSeq_NUMB,
             BeginValidity_DATE,
             EndValidity_DATE,
             StatusEscheat_DATE,
             StatusEscheat_CODE)
     SELECT u.Batch_DATE,-- Batch_DATE											
            u.SourceBatch_CODE,-- SourceBatch_CODE							
            u.Batch_NUMB,-- Batch_NUMB							
            u.SeqReceipt_NUMB,-- SeqReceipt_NUMB							
            @An_EventGlobalSeq_NUMB AS EventGlobalBeginSeq_NUMB,-- EventGlobalBeginSeq_NUMB				
            u.SourceReceipt_CODE,-- SourceReceipt_CODE					
            u.Payor_NAME,-- Payor_NAME							
            u.PayorLine1_ADDR,-- PayorLine1_ADDR							
            u.PayorLine2_ADDR,-- PayorLine2_ADDR							
            u.PayorCity_ADDR,-- PayorCity_ADDR						
            u.PayorState_ADDR,-- PayorState_ADDR							
            u.PayorZip_ADDR,-- PayorZip_ADDR						
            u.PayorCountry_ADDR,-- PayorCountry_ADDR					
            u.Bank_NAME,-- Bank_NAME							
            u.Bank1_ADDR,-- Bank1_ADDR							
            u.Bank2_ADDR,-- Bank2_ADDR							
            u.BankCity_ADDR,-- BankCity_ADDR						
            u.BankState_ADDR,-- BankState_ADDR						
            u.BankZip_ADDR,-- BankZip_ADDR								
            u.BankCountry_ADDR,-- BankCountry_ADDR							
            u.Bank_IDNO,-- Bank_IDNO							
            u.BankAcct_NUMB,-- BankAcct_NUMB						
            u.Remarks_TEXT,-- Remarks_TEXT								
            0 AS CaseIdent_IDNO,-- CaseIdent_IDNO						
            0 AS IdentifiedPayorMci_IDNO,-- IdentifiedPayorMci_IDNO				
            @Ld_Low_DATE AS Identified_DATE,-- Identified_DATE						
            0 AS OtherParty_IDNO,-- OtherParty_IDNO						
            @Lc_IdentificationStatusU_CODE AS IdentificationStatus_CODE,-- IdentificationStatus_CODE			
            u.Employer_IDNO,-- Employer_IDNO						
            u.IvdAgency_IDNO,-- IvdAgency_IDNO						
            u.UnidentifiedMemberMci_IDNO,-- UnidentifiedMemberMci_IDNO			
            u.UnidentifiedSsn_NUMB,-- UnidentifiedSsn_NUMB
            0 AS EventGlobalEndSeq_NUMB,-- EventGlobalEndSeq_NUMB
            @Ad_Run_DATE AS BeginValidity_DATE,-- BeginValidity_DATE
            @Ld_High_DATE AS EndValidity_DATE,-- EndValidity_DATE
            @Ld_Low_DATE AS StatusEscheat_DATE,-- StatusEscheat_DATE
            @Lc_Space_TEXT AS StatusEscheat_CODE -- StatusEscheat_CODE
       FROM URCT_Y1 u
      WHERE u.Batch_DATE = @Ld_Batch_DATE
        AND u.Batch_NUMB = @Ln_Batch_NUMB
        AND u.SourceBatch_CODE = @Lc_SourceBatch_CODE
        AND u.SeqReceipt_NUMB = @Ln_SeqReceipt_NUMB
        AND u.IdentificationStatus_CODE = @Lc_IdentificationStatusO_CODE
        AND u.EndValidity_DATE = @Ad_Run_DATE
        AND u.EventGlobalEndSeq_NUMB = @An_EventGlobalSeq_NUMB;

     SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;

     IF @Ln_RowsAffected_NUMB = 0
      BEGIN
       SET @Ls_ErrorMessage_TEXT = 'INSERT URCT_Y1 FAILED';

       RAISERROR (50001,16,1);
      END

     SET @Ls_Sql_TEXT = 'UPDATE RCTH_Y1 ';
     SET @Ls_SqlData_TEXT = 'Batch_DATE = ' + ISNULL(CAST( @Ld_Batch_DATE AS VARCHAR ),'')+ ', Batch_NUMB = ' + ISNULL(CAST( @Ln_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @Ln_SeqReceipt_NUMB AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Lc_SourceBatch_CODE,'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');

     UPDATE RCTH_Y1
        SET EndValidity_DATE = @Ad_Run_DATE,
            EventGlobalEndSeq_NUMB = @An_EventGlobalSeq_NUMB
      WHERE Batch_DATE = @Ld_Batch_DATE
        AND Batch_NUMB = @Ln_Batch_NUMB
        AND SeqReceipt_NUMB = @Ln_SeqReceipt_NUMB
        AND SourceBatch_CODE = @Lc_SourceBatch_CODE
        AND EndValidity_DATE = @Ld_High_DATE;

     SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;

     IF @Ln_RowsAffected_NUMB <> 1
      BEGIN
       SET @Ls_ErrorMessage_TEXT = 'UPDATE RCTH_Y1 FAILED';

       RAISERROR (50001,16,1);
      END

     SET @Ls_Sql_TEXT = 'INSERT RCTH_Y1';
     SET @Ls_SqlData_TEXT = 'Distribute_DATE = ' + ISNULL(CAST( @Ld_Low_DATE AS VARCHAR ),'')+ ', StatusReceipt_CODE = ' + ISNULL(@Lc_StatusReceiptUnidentified_CODE,'')+ ', ReasonStatus_CODE = ' + ISNULL(@Lc_ReasonStatusUNID_CODE,'')+ ', ReasonBackOut_CODE = ' + ISNULL(@Lc_Space_TEXT,'')+ ', Refund_DATE = ' + ISNULL(CAST( @Ld_Low_DATE AS VARCHAR ),'')+ ', RefundRecipient_ID = ' + ISNULL(@Lc_Space_TEXT,'')+ ', RefundRecipient_CODE = ' + ISNULL(@Lc_Space_TEXT,'')+ ', BeginValidity_DATE = ' + ISNULL(CAST( @Ad_Run_DATE AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST( @An_EventGlobalSeq_NUMB AS VARCHAR ),'');

     INSERT RCTH_Y1
            (Batch_DATE,
             SourceBatch_CODE,
             Batch_NUMB,
             SeqReceipt_NUMB,
             SourceReceipt_CODE,
             TypeRemittance_CODE,
             TypePosting_CODE,
             Case_IDNO,
             PayorMCI_IDNO,
             Receipt_AMNT,
             ToDistribute_AMNT,
             Fee_AMNT,
             Employer_IDNO,
             Fips_CODE,
             Check_DATE,
             CheckNo_Text,
             Receipt_DATE,
             Distribute_DATE,
             Tanf_CODE,
             TaxJoint_CODE,
             TaxJoint_NAME,
             StatusReceipt_CODE,
             ReasonStatus_CODE,
             BackOut_INDC,
             ReasonBackOut_CODE,
             Refund_DATE,
             Release_DATE,
             ReferenceIrs_IDNO,
             RefundRecipient_ID,
             RefundRecipient_CODE,
             BeginValidity_DATE,
             EndValidity_DATE,
             EventGlobalBeginSeq_NUMB,
             EventGlobalEndSeq_NUMB)
     SELECT R.Batch_DATE,--Batch_DATE								
            R.SourceBatch_CODE,--SourceBatch_CODE								
            R.Batch_NUMB,--Batch_NUMB								
            R.SeqReceipt_NUMB,--SeqReceipt_NUMB								
            R.SourceReceipt_CODE,--SourceReceipt_CODE						
            R.TypeRemittance_CODE,--TypeRemittance_CODE							
            R.TypePosting_CODE,--TypePosting_CODE								
            0 AS Case_IDNO,--Case_IDNO									
            0 AS PayorMCI_IDNO,--PayorMCI_IDNO								
            R.Receipt_AMNT,--Receipt_AMNT									
            R.ToDistribute_AMNT,--ToDistribute_AMNT							
            R.Fee_AMNT,--Fee_AMNT										
            R.Employer_IDNO,--Employer_IDNO								
            R.Fips_CODE,--Fips_CODE									
            R.Check_DATE,--Check_DATE								
            R.CheckNo_TEXT,--CheckNo_Text									
            R.Receipt_DATE,--Receipt_DATE									
            @Ld_Low_DATE AS Distribute_DATE,--Distribute_DATE							
            R.Tanf_CODE,--Tanf_CODE									
            R.TaxJoint_CODE,--TaxJoint_CODE								
            R.TaxJoint_NAME,--TaxJoint_NAME								
            @Lc_StatusReceiptUnidentified_CODE AS StatusReceipt_CODE,--StatusReceipt_CODE						
            @Lc_ReasonStatusUNID_CODE AS ReasonStatus_CODE,--ReasonStatus_CODE							
            R.BackOut_INDC,--BackOut_INDC								
            @Lc_Space_TEXT AS ReasonBackOut_CODE,--ReasonBackOut_CODE						
            @Ld_Low_DATE AS Refund_DATE,--Refund_DATE								
            R.Release_DATE,--Release_DATE								   
            R.ReferenceIrs_IDNO,--ReferenceIrs_IDNO 			
            @Lc_Space_TEXT AS RefundRecipient_ID,--RefundRecipient_ID 
            @Lc_Space_TEXT AS RefundRecipient_CODE,--RefundRecipient_CODE 
            @Ad_Run_DATE AS BeginValidity_DATE,--BeginValidity_DATE
            @Ld_High_DATE AS EndValidity_DATE,--EndValidity_DATE
            @An_EventGlobalSeq_NUMB AS EventGlobalBeginSeq_NUMB,--EventGlobalBeginSeq_NUMB
            0 AS EventGlobalEndSeq_NUMB --EventGlobalEndSeq_NUMB
       FROM RCTH_Y1 R
      WHERE R.Batch_DATE = @Ld_Batch_DATE
        AND R.Batch_NUMB = @Ln_Batch_NUMB
        AND R.SeqReceipt_NUMB = @Ln_SeqReceipt_NUMB
        AND R.SourceBatch_CODE = @Lc_SourceBatch_CODE
        AND R.EndValidity_DATE = @Ad_Run_DATE
        AND R.EventGlobalEndSeq_NUMB = @An_EventGlobalSeq_NUMB;

     SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;

     IF @Ln_RowsAffected_NUMB = 0
      BEGIN
       SET @Ls_ErrorMessage_TEXT = 'INSERT RCTH_Y1 FAILED';

       RAISERROR(50001,16,1);
      END
    END

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = '';
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

  END CATCH;
 END;


GO
