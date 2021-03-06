/****** Object:  StoredProcedure [dbo].[RCTH_RETRIEVE_S130]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE PROCEDURE [dbo].[RCTH_RETRIEVE_S130](
     @An_Case_IDNO		NUMERIC(6,0),  
     @An_PayorMCI_IDNO	NUMERIC(10,0),  
     @Ai_Count_QNTY		INT	 OUTPUT  
     )
AS  
  
/*  
 *     PROCEDURE NAME    : RCTH_RETRIEVE_S130  
 *     DESCRIPTION       : It check the record existance for the given payor and case Id.  This service check the existance of payor Id
                           in the vrcth and vlsup for the case Id. 
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 04-AUG-2011  
 *     MODIFIED BY       :   
 *     MODIFIED ON       :   
 *     VERSION NO        : 1  
*/  
    BEGIN  
  
      SET @Ai_Count_QNTY = NULL;  
  
      DECLARE  
         @Lc_TypeRecordOriginal_CODE			CHAR(1)      = 'O',   
         @Ld_High_DATE							DATE = '12/31/9999',   
         @Li_ReceiptReversed1250_NUMB			INT = 1250,   
         @Li_ManuallyDistributeReceipt1810_NUMB INT = 1810,   
         @Li_ReceiptDistributed1820_NUMB		INT = 1820;  
  
      SELECT @Ai_Count_QNTY = COUNT(1)  
      FROM RCTH_Y1 a  
      WHERE  a.PayorMCI_IDNO = @An_PayorMCI_IDNO 
        AND (( a.Case_IDNO IS NULL 
        AND EXISTS   
         (  SELECT 1 
            FROM LSUP_Y1 b
            WHERE b.Case_IDNO = @An_Case_IDNO 
              AND b.Batch_DATE = a.Batch_DATE 
              AND b.SourceBatch_CODE = a.SourceBatch_CODE 
              AND b.Batch_NUMB = a.Batch_NUMB 
              AND b.SeqReceipt_NUMB = a.SeqReceipt_NUMB 
              AND b.TypeRecord_CODE = @Lc_TypeRecordOriginal_CODE 
              AND b.EventFunctionalSeq_NUMB IN (@Li_ReceiptDistributed1820_NUMB, @Li_ManuallyDistributeReceipt1810_NUMB, @Li_ReceiptReversed1250_NUMB)  
         ))  
         OR a.Case_IDNO = @An_Case_IDNO) 
        AND a.EndValidity_DATE = @Ld_High_DATE;  
  
END;--End of RCTH_RETRIEVE_S130  
  

GO
