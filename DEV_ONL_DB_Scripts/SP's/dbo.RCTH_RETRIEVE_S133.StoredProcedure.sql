/****** Object:  StoredProcedure [dbo].[RCTH_RETRIEVE_S133]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE PROCEDURE [dbo].[RCTH_RETRIEVE_S133]( 
     @Ad_BatchOrig_DATE			DATE,
     @Ac_SourceBatchOrig_CODE	CHAR(3),  
     @An_BatchOrig_NUMB			NUMERIC(4,0),  
     @An_SeqReceiptOrig_NUMB	NUMERIC(6,0)
     )  
AS  
/*  
 *     PROCEDURE NAME    : RCTH_RETRIEVE_S133  
 *     DESCRIPTION       : It Retrieve the Repost Reciept Details.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 04-AUG-2011  
 *     MODIFIED BY       :   
 *     MODIFIED ON       :   
 *     VERSION NO        : 1  
*/  
    BEGIN  
  
     
  
      DECLARE  
         @Ld_High_DATE             DATE = '12/31/9999',   
         @Li_Zero_NUMB             SMALLINT     = 0,
         @Lc_Zero000000000_CODE    CHAR(9)='000000000';   
        
          
     SELECT DISTINCT  b.Batch_DATE,
                b.SourceBatch_CODE,
                b.Batch_NUMB,
				b.SeqReceipt_NUMB,
				b.SourceReceipt_CODE,
                b.PayorMCI_IDNO,
                b.Receipt_AMNT, 
                b.Receipt_DATE,
                d.Last_NAME,
                d.First_NAME,
                d.Middle_NAME,
                d.Suffix_NAME,
                ISNULL (d.MemberSsn_NUMB, @Lc_Zero000000000_CODE)AS MemberSsn_NUMB
           FROM RCTR_Y1 a 
             JOIN RCTH_Y1 b
			 ON b.Batch_DATE = a.Batch_DATE
            AND b.SourceBatch_CODE = a.SourceBatch_CODE
            AND b.Batch_NUMB = a.Batch_NUMB
            AND b.SeqReceipt_NUMB = a.SeqReceipt_NUMB
            AND b.EndValidity_DATE = a.EndValidity_DATE
           LEFT OUTER JOIN DEMO_Y1 d
             ON d.MemberMci_IDNO = b.PayorMCI_IDNO
          WHERE a.BatchOrig_DATE = @Ad_BatchOrig_DATE
            AND a.SourceBatchOrig_CODE = @Ac_SourceBatchOrig_CODE
            AND a.BatchOrig_NUMB = @An_BatchOrig_NUMB
            AND a.SeqReceiptOrig_NUMB = @An_SeqReceiptOrig_NUMB
            AND a.EndValidity_DATE = @Ld_High_DATE
            AND b.Receipt_AMNT > @Li_Zero_NUMB ;
  
    END;--End of RCTH_RETRIEVE_S133   
  


GO
