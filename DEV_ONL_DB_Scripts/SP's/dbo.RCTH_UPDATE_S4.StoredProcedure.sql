/****** Object:  StoredProcedure [dbo].[RCTH_UPDATE_S4]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
                        
CREATE PROCEDURE [dbo].[RCTH_UPDATE_S4] ( 
     @Ad_Batch_DATE				 DATE,   
     @Ac_SourceBatch_CODE		 CHAR(3),    
     @An_Batch_NUMB              NUMERIC(4,0) ,   
     @An_SeqReceipt_NUMB		 NUMERIC(6,0), 
     @An_EventGlobalEndSeq_NUMB	 NUMERIC(19,0)  
     )                  
AS                                                                       

/*
 *     PROCEDURE NAME    : RCTH_UPDATE_S3
 *     DESCRIPTION       : Updates the end validity date in the Receipts table for identified receipts
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 30-SEP-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
 */

   BEGIN
   		 DECLARE @Ln_RowsAffected_NUMB 			NUMERIC(10),
   		 	@Ld_Current_DATE					DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
   		 	@Ld_Low_DATE						DATE = '01/01/0001',
   		 	@Lc_StatusReceiptIdentified_CODE	CHAR(1)='I'; 
   		 
   		 
      UPDATE RCTH_Y1 
         SET 
            EndValidity_DATE = @Ld_Current_DATE, 
            EventGlobalEndSeq_NUMB = @An_EventGlobalEndSeq_NUMB
      WHERE 
         Batch_DATE = @Ad_Batch_DATE AND 
         SourceBatch_CODE = @Ac_SourceBatch_CODE AND 
         Batch_NUMB = @An_Batch_NUMB AND 
         SeqReceipt_NUMB = @An_SeqReceipt_NUMB AND 
         StatusReceipt_CODE = @Lc_StatusReceiptIdentified_CODE AND
         Distribute_DATE = @Ld_Low_DATE;
      
      SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;
     
      SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB ;
END -- END OF RCTH_UPDATE_S4


GO
