/****** Object:  StoredProcedure [dbo].[RCTH_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RCTH_RETRIEVE_S1] (
 @Ad_Batch_DATE       DATE,
 @Ac_SourceBatch_CODE CHAR(3),
 @An_Batch_NUMB       NUMERIC(4,0),
 @Ai_RowFrom_NUMB     INT=1,
 @Ai_RowTo_NUMB       INT=10
 )
AS
 /*        
  *     PROCEDURE NAME    : RCTH_RETRIEVE_S1        
  *     DESCRIPTION       : Retrieving the receipt details.         
  *     DEVELOPED BY      : IMP Team        
  *     DEVELOPED ON      : 10-AUG-2011       
  *     MODIFIED BY       :         
  *     MODIFIED ON       :         
  *     VERSION NO        : 1        
 */
 BEGIN
  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT Y.Batch_DATE,
         Y.Batch_NUMB,
         Y.SeqReceipt_NUMB,
         Y.SourceBatch_CODE,
         Y.SourceReceipt_CODE,
         Y.TypePosting_CODE,
         Y.Case_IDNO,
         Y.PayorMCI_IDNO,
         Y.Receipt_AMNT,
         Y.Fee_AMNT,
         Y.Fips_CODE,
         Y.CheckNo_Text,
         Y.Receipt_DATE,
         Y.Tanf_CODE,
         Y.TaxJoint_CODE,
         Y.TaxJoint_NAME,
         Y.StatusReceipt_CODE,
         Y.ReasonStatus_CODE,
         Y.Last_NAME,
         Y.Suffix_NAME,
         Y.First_NAME,
         Y.Middle_NAME,
         Y.Worker_ID,
         Y.RowCount_NUMB
    FROM (SELECT X.Batch_DATE,
                 X.Batch_NUMB,
                 X.SeqReceipt_NUMB,
                 X.SourceBatch_CODE,
                 X.Receipt_DATE,
                 X.TypePosting_CODE,
                 X.Case_IDNO,
                 X.PayorMCI_IDNO,
                 X.Last_NAME,
                 X.Suffix_NAME,
                 X.First_NAME,
                 X.Middle_NAME,
                 X.Receipt_AMNT,
                 X.CheckNo_Text,
                 X.Fips_CODE,
                 X.StatusReceipt_CODE,
                 X.Tanf_CODE,
                 X.TaxJoint_CODE,
                 X.TaxJoint_NAME,
                 X.Worker_ID,
                 X.Fee_AMNT,
                 X.SourceReceipt_CODE,
                 X.ReasonStatus_CODE,
                 X.RowCount_NUMB,
                 X.Row_NUMB
            FROM (SELECT a.Batch_DATE,
                         a.Batch_NUMB,
                         a.SeqReceipt_NUMB,
                         a.SourceBatch_CODE,
                         a.Receipt_DATE,
                         a.TypePosting_CODE,
                         a.Case_IDNO,
                         a.PayorMCI_IDNO,
                         d.Last_NAME,
                         d.Suffix_NAME,
                         d.First_NAME,
                         d.Middle_NAME,
                         ABS(a.Receipt_AMNT) AS Receipt_AMNT,
                         a.CheckNo_Text,
                         a.Fips_CODE,
                         a.StatusReceipt_CODE,
                         a.Tanf_CODE,
                         a.TaxJoint_CODE,
                         a.TaxJoint_NAME,
                         c.Worker_ID,
                         a.Fee_AMNT,
                         a.SourceReceipt_CODE,
                         a.ReasonStatus_CODE,
                         COUNT(1) OVER() AS RowCount_NUMB,
                         ROW_NUMBER() OVER( ORDER BY a.SeqReceipt_NUMB) AS Row_NUMB
                    FROM RCTH_Y1 a
                         JOIN GLEV_Y1 c
                          ON (a.EventGlobalBeginSeq_NUMB = c.EventGlobalSeq_NUMB)
                         LEFT OUTER JOIN DEMO_Y1 d
                          ON(d.MemberMci_IDNO = a.PayorMCI_IDNO)
                   WHERE a.Batch_NUMB = @An_Batch_NUMB
                     AND a.Batch_DATE = @Ad_Batch_DATE
                     AND a.SourceBatch_CODE = @Ac_SourceBatch_CODE
                     AND a.EndValidity_DATE = @Ld_High_DATE
                     AND a.EventGlobalBeginSeq_NUMB = (SELECT MAX(d.EventGlobalBeginSeq_NUMB)
                                                         FROM RCTH_Y1 d
                                                        WHERE d.Batch_NUMB = a.Batch_NUMB
                                                          AND d.Batch_DATE = a.Batch_DATE
                                                          AND d.SeqReceipt_NUMB = a.SeqReceipt_NUMB
                                                          AND d.SourceBatch_CODE = a.SourceBatch_CODE
                                                          AND d.EndValidity_DATE = @Ld_High_DATE)) AS X
           WHERE X.Row_NUMB <= @Ai_RowTo_NUMB) AS Y
   WHERE Y.Row_NUMB >= @Ai_RowFrom_NUMB
   ORDER BY Row_NUMB;
 END;--End Of RCTH_RETRIEVE_S1


GO
