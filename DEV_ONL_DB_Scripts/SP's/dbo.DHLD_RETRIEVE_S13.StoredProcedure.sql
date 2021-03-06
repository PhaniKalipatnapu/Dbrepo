/****** Object:  StoredProcedure [dbo].[DHLD_RETRIEVE_S13]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DHLD_RETRIEVE_S13](
 @Ad_Release_DATE           DATE,
 @Ac_ReasonStatus_CODE      CHAR(4),
 @An_EventGlobalEndSeq_NUMB NUMERIC(19, 0),
 @An_MemberMci_IDNO         NUMERIC(10, 0)
 )
AS
 /*    
  *     PROCEDURE NAME    : DHLD_RETRIEVE_S13    
  *     DESCRIPTION       : Retrieves the disbursement hold details for a case idno, check recipient code, event global sequence for the end validity date which equals high date.   
  *     DEVELOPED BY      : IMP Team    
  *     DEVELOPED ON      : 22-SEP-2011    
  *     MODIFIED BY       :     
  *     MODIFIED ON       :     
  *     VERSION NO        : 1    
  */
 BEGIN
  DECLARE @Lc_CheckRecipientTypeCpNcp_CODE   CHAR(1) = '1',
          @Lc_CheckRecipientTypeFips_CODE    CHAR(1) = '2',
          @Lc_CaseRelationshipCp_CODE        CHAR(1) = 'C',
          @Lc_CaseRelationshipNcp_CODE       CHAR(1) = 'A',
          @Lc_CaseRelationshipPutFather_CODE CHAR(1) = 'P',
          @Lc_StatusHeld_CODE                CHAR(1) = 'H',
          @Lc_StatusReady_CODE               CHAR(1) = 'R',
          @Lc_RevrsnDistributionError_CODE   CHAR(2) = 'DR',
          @Ld_Current_DATE                   DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME ();

  SELECT a.Case_IDNO,
         a.OrderSeq_NUMB,
         a.ObligationSeq_NUMB,
         a.Batch_DATE,
         a.SourceBatch_CODE,
         a.Batch_NUMB,
         a.SeqReceipt_NUMB,
         a.TypeDisburse_CODE,
         a.Transaction_AMNT,
         CASE @Ad_Release_DATE
          WHEN @Ld_Current_DATE
           THEN @Lc_StatusReady_CODE
          ELSE @Lc_StatusHeld_CODE
         END AS Status_CODE,
         a.TypeHold_CODE,
         a.ProcessOffset_INDC,
         a.CheckRecipient_ID,
         a.CheckRecipient_CODE,
         CASE @Ad_Release_DATE
          WHEN @Ld_Current_DATE
           THEN @Lc_RevrsnDistributionError_CODE
          ELSE @Ac_ReasonStatus_CODE
         END AS ReasonStatus_CODE,
         a.EventGlobalSupportSeq_NUMB,
         a.Disburse_DATE,
         a.DisburseSeq_NUMB,
         a.StatusEscheat_DATE,
         a.StatusEscheat_CODE
    FROM DHLD_Y1 a
   WHERE a.Case_IDNO IN (SELECT c.Case_IDNO
                           FROM CMEM_Y1 c
                          WHERE c.MemberMci_IDNO = @An_MemberMci_IDNO
                            AND c.CaseRelationship_CODE IN (@Lc_CaseRelationshipCp_CODE, @Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE))
     AND a.CheckRecipient_CODE IN (@Lc_CheckRecipientTypeCpNcp_CODE, @Lc_CheckRecipientTypeFips_CODE)
     AND a.EndValidity_DATE = @Ld_Current_DATE
     AND a.EventGlobalEndSeq_NUMB = @An_EventGlobalEndSeq_NUMB;
 END; --End of DHLD_RETRIEVE_S13

GO
