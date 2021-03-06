/****** Object:  StoredProcedure [dbo].[LWEL_RETRIEVE_S19]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[LWEL_RETRIEVE_S19](
 @An_Case_IDNO           NUMERIC(6),
 @An_EventGlobalSeq_NUMB NUMERIC(19),
 @An_CaseWelfare_IDNO    NUMERIC(10) = NULL,
 @Ad_Batch_DATE          DATE        = NULL,
 @Ac_SourceBatch_CODE    CHAR(3)     = NULL,
 @An_Batch_NUMB          NUMERIC(4)  = NULL,
 @An_SeqReceipt_NUMB     NUMERIC(6)  = NULL
 )
AS
 /*                                                                                                                              
  *     PROCEDURE NAME    : LWEL_RETRIEVE_S19                                                                                     
  *     DESCRIPTION       : Procedure to Retrieves the log welfare details for the 
                            given welfare case and receipt number                                                                                                     
  *     DEVELOPED BY      : IMP TEAM                                                                                           
  *     DEVELOPED ON      : 28/11/2011                                                                                          
  *     MODIFIED BY       :                                                                                                      
  *     MODIFIED ON       :                                                                                                      
  *     VERSION NO        : 1                                                                                                    
 */
 BEGIN
  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT LW.Case_IDNO,
         O.MemberMci_IDNO,
         LW.CaseWelfare_IDNO,
         S.Order_IDNO,
         O.TypeDebt_CODE,
         O.Fips_CODE,
         LW.Batch_DATE,
         LW.SourceBatch_CODE,
         LW.Batch_NUMB,
         LW.SeqReceipt_NUMB,
         LW.WelfareYearMonth_NUMB,
         LW.TypeDisburse_CODE,
         LW.Distribute_DATE,
         LW.Distribute_AMNT
    FROM LWEL_Y1 LW
         JOIN OBLE_Y1 o
          ON LW.Case_IDNO = o.Case_IDNO
             AND LW.OrderSeq_NUMB = o.OrderSeq_NUMB
             AND LW.ObligationSeq_NUMB = o.ObligationSeq_NUMB
         JOIN SORD_Y1 s
          ON LW.Case_IDNO = s.Case_IDNO
             AND LW.OrderSeq_NUMB = s.OrderSeq_NUMB
   WHERE LW.Case_IDNO = @An_Case_IDNO
     AND LW.EventGlobalSeq_NUMB = @An_EventGlobalSeq_NUMB
     AND LW.CaseWelfare_IDNO = ISNULL(@An_CaseWelfare_IDNO, LW.CaseWelfare_IDNO)
     AND LW.Batch_DATE = ISNULL(@Ad_Batch_DATE, LW.Batch_DATE)
     AND LW.SourceBatch_CODE = ISNULL(@Ac_SourceBatch_CODE, LW.SourceBatch_CODE)
     AND LW.Batch_NUMB = ISNULL(@An_Batch_NUMB, LW.Batch_NUMB)
     AND LW.SeqReceipt_NUMB = ISNULL(@An_SeqReceipt_NUMB, LW.SeqReceipt_NUMB)
     AND s.EndValidity_DATE = @Ld_High_DATE
     AND o.EndValidity_DATE = @Ld_High_DATE
     AND o.EndObligation_DATE = (SELECT MAX(b.EndObligation_DATE)
                                   FROM OBLE_Y1 b
                                  WHERE b.Case_IDNO = o.Case_IDNO
                                    AND b.OrderSeq_NUMB = o.OrderSeq_NUMB
                                    AND b.ObligationSeq_NUMB = o.ObligationSeq_NUMB
                                    AND b.EndValidity_DATE = @Ld_High_DATE);
                                    
 END; --End Of Procedure LWEL_RETRIEVE_S19 


GO
