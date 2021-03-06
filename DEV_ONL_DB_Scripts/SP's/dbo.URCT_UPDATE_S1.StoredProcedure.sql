/****** Object:  StoredProcedure [dbo].[URCT_UPDATE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[URCT_UPDATE_S1] (
 @Ad_Batch_DATE             DATE,
 @An_Batch_NUMB             NUMERIC(4, 0),
 @Ac_SourceBatch_CODE       CHAR(3),
 @An_SeqReceipt_NUMB        NUMERIC(6, 0),
 @An_EventGlobalEndSeq_NUMB NUMERIC(19, 0),
 @An_OtherParty_IDNO        NUMERIC(9, 0)
 )
AS
 /*
  *     PROCEDURE NAME    : URCT_UPDATE_S1
  *     DESCRIPTION       : Updates the event global end seq and end validity date for URCT 
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 24-SEP-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  DECLARE @Lc_StatusReceiptUnidentified_CODE CHAR(1) = 'U',
          @Ld_High_DATE                      DATE = '12/31/9999',
          @Ln_RowsAffected_NUMB              NUMERIC(10),
          @Ld_Current_DATE                   DATE =DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
          @Li_Zero_NUMB                      SMALLINT=0,
          @Lc_Space_TEXT                     CHAR(1)=' ',
          @Lc_IdentificationStatusO_CODE     CHAR(1)='O';

  UPDATE URCT_Y1
     SET EventGlobalEndSeq_NUMB = @An_EventGlobalEndSeq_NUMB,
         EndValidity_DATE = @Ld_Current_DATE
  OUTPUT @Ad_Batch_DATE AS Batch_DATE,
         @Ac_SourceBatch_CODE AS SourceBatch_CODE,
         @An_Batch_NUMB AS Batch_NUMB,
         @An_SeqReceipt_NUMB AS SeqReceipt_NUMB,
         @An_EventGlobalEndSeq_NUMB AS EventGlobalEndSeq_NUMB,
         DELETED.SourceReceipt_CODE,
         DELETED.Payor_NAME,
         DELETED.PayorLine1_ADDR,
         DELETED.PayorLine2_ADDR,
         DELETED.PayorCity_ADDR,
         DELETED.PayorState_ADDR,
         DELETED.PayorZip_ADDR,
         DELETED.PayorCountry_ADDR,
         DELETED.Bank_NAME,
         DELETED.Bank1_ADDR,
         DELETED.Bank2_ADDR,
         DELETED.BankCity_ADDR,
         DELETED.BankState_ADDR,
         DELETED.BankZip_ADDR,
         DELETED.BankCountry_ADDR,
         DELETED.Bank_IDNO,
         DELETED.BankAcct_NUMB,
         DELETED.Remarks_TEXT,
         DELETED.CaseIdent_IDNO,
         DELETED.IdentifiedPayorMci_IDNO,
         @Ld_Current_DATE AS Identified_DATE,
         @An_OtherParty_IDNO AS OtherParty_IDNO,
         @Lc_IdentificationStatusO_CODE AS IdentificationStatus_CODE,
         DELETED.Employer_IDNO,
         DELETED.IvdAgency_IDNO,
         DELETED.UnidentifiedMemberMci_IDNO,
         DELETED.UnidentifiedSsn_NUMB,
         @Li_Zero_NUMB AS EventGlobalEndSeq_NUMB,
         @Ld_Current_DATE AS BeginValidity_DATE,
         @Ld_High_DATE AS EndValidity_DATE,
         @Ld_High_DATE AS StatusEscheat_DATE,
         @Lc_Space_TEXT AS StatusEscheat_CODE
  INTO URCT_Y1
   WHERE Batch_DATE = @Ad_Batch_DATE
     AND SourceBatch_CODE = @Ac_SourceBatch_CODE
     AND Batch_NUMB = @An_Batch_NUMB
     AND SeqReceipt_NUMB = @An_SeqReceipt_NUMB
     AND IdentificationStatus_CODE = @Lc_StatusReceiptUnidentified_CODE
     AND EndValidity_DATE = @Ld_High_DATE;

  SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;

  SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB;
 END --END OF URCT_UPDATE_S1

GO
