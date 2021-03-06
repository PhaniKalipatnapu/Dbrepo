/****** Object:  StoredProcedure [dbo].[RCTH_RETRIEVE_S68]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RCTH_RETRIEVE_S68] (
 @Ad_Batch_DATE               DATE,
 @An_Batch_NUMB               NUMERIC(4, 0),
 @Ac_SourceBatch_CODE         CHAR(3),
 @An_SeqReceipt_NUMB          NUMERIC(6, 0),
 @Ac_StatusReceipt_CODE       CHAR(1) OUTPUT,
 @Ac_TaxJoint_CODE            CHAR(1) OUTPUT,
 @An_Receipt_AMNT             NUMERIC(11, 2) OUTPUT,
 @Ad_Check_DATE               DATE OUTPUT,
 @An_EventGlobalBeginSeq_NUMB NUMERIC(19, 0) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : RCTH_RETRIEVE_S68
  *     DESCRIPTION       : Procedure To Retrieve The Receipt Status,Receipt Ammount,TaxjointCode,Check Date And EventId, 
 						   Based On BatchDate,EndValidityDate And EventGlobalBeginSeq By Using RCTH_Y1
  *     DEVELOPED BY      : IMP TEAM
  *     DEVELOPED ON      : 17-OCT-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SELECT @Ac_StatusReceipt_CODE = NULL,
         @Ac_TaxJoint_CODE = NULL,
         @An_Receipt_AMNT = NULL,
         @Ad_Check_DATE = NULL,
         @An_EventGlobalBeginSeq_NUMB = NULL;
         
  DECLARE @Ld_High_DATE DATE = '12/31/9999',
          @Li_Zero_AMNT SMALLINT = 0;

  SELECT @Ac_StatusReceipt_CODE = a.StatusReceipt_CODE,
         @Ac_TaxJoint_CODE = a.TaxJoint_CODE,
         @An_Receipt_AMNT = ISNULL(a.Receipt_AMNT, @Li_Zero_AMNT),
         @Ad_Check_DATE = a.Check_DATE,
         @An_EventGlobalBeginSeq_NUMB = a.EventGlobalBeginSeq_NUMB    
    FROM RCTH_Y1 a
   WHERE a.Batch_DATE = @Ad_Batch_DATE
     AND a.SourceBatch_CODE = @Ac_SourceBatch_CODE
     AND a.Batch_NUMB = @An_Batch_NUMB
     AND a.SeqReceipt_NUMB = @An_SeqReceipt_NUMB
     AND a.EndValidity_DATE = @Ld_High_DATE
     AND a.EventGlobalBeginSeq_NUMB = (SELECT MAX(b.EventGlobalBeginSeq_NUMB)
                                         FROM RCTH_Y1 b
                                        WHERE b.Batch_DATE = @Ad_Batch_DATE
                                          AND b.SourceBatch_CODE = @Ac_SourceBatch_CODE
                                          AND b.Batch_NUMB = @An_Batch_NUMB
                                          AND b.SeqReceipt_NUMB = @An_SeqReceipt_NUMB
                                          AND b.Receipt_AMNT > @Li_Zero_AMNT
                                          AND b.EndValidity_DATE = @Ld_High_DATE);
 END; --End Of Procedure RCTH_RETRIEVE_S68 

GO
