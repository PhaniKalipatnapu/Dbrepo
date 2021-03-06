/****** Object:  StoredProcedure [dbo].[RCTH_RETRIEVE_S31]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RCTH_RETRIEVE_S31]  
 (
     @Ad_Batch_DATE				DATE,
     @Ac_SourceBatch_CODE		CHAR(3),
     @An_Batch_NUMB             NUMERIC(4,0),
     @An_SeqReceipt_NUMB		NUMERIC(6,0)               
 )
AS

/*
*     PROCEDURE NAME    : RCTH_RETRIEVE_S31
*     DESCRIPTION       : This procedure is used to get the receipt history information of particular receipt.
                    	  This is used for tracking of all the updates relating to the selected receipt,
          				  from the point of original posting till date.
*     DEVELOPED BY      : IMP Team
*     DEVELOPED ON      : 02-AUG-2011
*     MODIFIED BY       : 
*     MODIFIED ON       : 
*     VERSION NO        : 1
*/
BEGIN

      
         SELECT R.Case_IDNO ,   
         R.ToDistribute_AMNT ,       
         R.Distribute_DATE,   
         R.StatusReceipt_CODE,  
         R.ReasonStatus_CODE,  
         R.BeginValidity_DATE,    
         R.EndValidity_DATE,   
         R.EventGlobalBeginSeq_NUMB,  
         MIN(R.EventGlobalBeginSeq_NUMB) OVER() EventGlobalBeginSeqMin_NUMB,  
         G.Worker_ID ,   
         N.DescriptionNote_TEXT   
      FROM GLEV_Y1  G
           JOIN
           RCTH_Y1  R 
           ON  
           r.EventGlobalBeginSeq_NUMB = g.EventGlobalSeq_NUMB                      
           LEFT OUTER JOIN UNOT_Y1   N   
           ON 
		   N.EventGlobalSeq_NUMB = R.EventGlobalBeginSeq_NUMB                   
      WHERE   
         r.Batch_DATE = @Ad_Batch_DATE   
      AND r.SourceBatch_CODE = @Ac_SourceBatch_CODE  
      AND r.Batch_NUMB = @An_Batch_NUMB    
      AND r.SeqReceipt_NUMB = @An_SeqReceipt_NUMB   
      ORDER BY r.EventGlobalBeginSeq_NUMB DESC; 
                  
END;   --End of  RCTH_RETRIEVE_S31


GO
