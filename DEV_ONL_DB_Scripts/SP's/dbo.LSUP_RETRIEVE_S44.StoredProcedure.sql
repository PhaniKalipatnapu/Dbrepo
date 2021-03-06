/****** Object:  StoredProcedure [dbo].[LSUP_RETRIEVE_S44]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[LSUP_RETRIEVE_S44]  (
     @Ad_Distribute_DATE     DATE,
     @An_Case_IDNO           NUMERIC(6,0),
     @An_OrderSeq_NUMB       NUMERIC(2,0),
     @Ac_TypeDebt_CODE       CHAR(2),
     @Ac_Fips_CODE           CHAR(7),
     @Ad_Receipt_DATE        DATE OUTPUT
  )   
AS
/*
 *     PROCEDURE NAME    : LSUP_RETRIEVE_S44
 *     DESCRIPTION       : This procedure returns the receipt date for case 
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 02-JAN-2012
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
   BEGIN
         SET @Ad_Receipt_DATE = NULL;
         
     DECLARE @Li_ManuallyDistributeReceipt1810_NUMB 	INT = 1810, 
			 @Li_ReceiptDistributed1820_NUMB			INT = 1820, 
			 @Li_FutureHoldRelease1825_NUMB				INT = 1825,
             @Lc_TypeRecordOriginal_CODE				CHAR(1) = 'O', 
			 @Lc_Yes_INDC								CHAR(1) = 'Y', 
			 @Ld_High_DATE								DATE = '12/31/9999', 
			 @Ld_Low_DATE								DATE = '01/01/0001', 
			 @Ld_Current_DATE							DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

      SELECT TOP 1 @Ad_Receipt_DATE = a.Receipt_DATE
        FROM LSUP_Y1 a 
             JOIN OBLE_Y1 x 			
          ON a.Case_IDNO = x.Case_IDNO 
         AND a.OrderSeq_NUMB = x.OrderSeq_NUMB 
         AND a.ObligationSeq_NUMB = x.ObligationSeq_NUMB                        
       WHERE x.Case_IDNO = @An_Case_IDNO 
         AND x.OrderSeq_NUMB = @An_OrderSeq_NUMB 
	     AND x.TypeDebt_CODE = @Ac_TypeDebt_CODE 
		 AND x.Fips_CODE = @Ac_Fips_CODE 
		 AND x.EndValidity_DATE = @Ld_High_DATE
         AND a.Batch_DATE <> @Ld_Low_DATE 
         AND a.EventFunctionalSeq_NUMB IN ( @Li_ManuallyDistributeReceipt1810_NUMB , @Li_ReceiptDistributed1820_NUMB, @Li_FutureHoldRelease1825_NUMB ) 
         AND a.TypeRecord_CODE = @Lc_TypeRecordOriginal_CODE 
         AND a.Distribute_DATE BETWEEN @Ad_Distribute_DATE AND @Ld_Current_DATE 
         AND NOT EXISTS (SELECT 1 
						  FROM RCTH_Y1  d
						 WHERE d.Batch_DATE = a.Batch_DATE 
						   AND d.SourceBatch_CODE = a.SourceBatch_CODE 
						   AND d.Batch_NUMB = a.Batch_NUMB 
						   AND d.SeqReceipt_NUMB = a.SeqReceipt_NUMB 
						   AND d.EndValidity_DATE = @Ld_High_DATE 
						   AND d.BackOut_INDC = @Lc_Yes_INDC);

                  
END;-- End of LSUP_RETRIEVE_S44


GO
