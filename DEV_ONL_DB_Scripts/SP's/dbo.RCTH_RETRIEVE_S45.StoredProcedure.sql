/****** Object:  StoredProcedure [dbo].[RCTH_RETRIEVE_S45]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RCTH_RETRIEVE_S45] (
 @Ad_Batch_DATE					DATE,
 @Ac_SourceBatch_CODE		 	CHAR(3),
 @An_Batch_NUMB              	NUMERIC(4),
 @An_SeqReceipt_NUMB		 	NUMERIC(6),
 @An_EventGlobalBeginSeq_NUMB	NUMERIC(19),
 @Ac_StatusReceipt_CODE		 	CHAR(1),
 @Ac_ReasonStatus_CODE       	CHAR(4),     
 @Ai_Count_QNTY					INT OUTPUT
 )
AS

/*
 *     PROCEDURE NAME    : RCTH_RETRIEVE_S45
 *     DESCRIPTION       : Retrieves the record count from the receipts table.
 *     DEVELOPED BY      : IMP Team  
 *     DEVELOPED ON      : 29-SEP-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
 */
   BEGIN
      
      DECLARE  @Ld_High_DATE  DATE = '12/31/9999';
        
        SELECT @Ai_Count_QNTY = COUNT(1)
         FROM RCTH_Y1 r                                       
        WHERE r.Batch_DATE = @Ad_Batch_DATE                    
          AND r.SourceBatch_CODE = @Ac_SourceBatch_CODE        
          AND r.Batch_NUMB = @An_Batch_NUMB                    
          AND r.SeqReceipt_NUMB = @An_SeqReceipt_NUMB          
          AND r.StatusReceipt_CODE = @Ac_StatusReceipt_CODE    
          AND r.EventGlobalBeginSeq_NUMB = @An_EventGlobalBeginSeq_NUMB
          AND r.ReasonStatus_CODE = ISNULL(@Ac_ReasonStatus_CODE,r.ReasonStatus_CODE)      
          AND r.EndValidity_DATE = @Ld_High_DATE;          
         
END; -- END OF RCTH_RETRIEVE_S45


GO
