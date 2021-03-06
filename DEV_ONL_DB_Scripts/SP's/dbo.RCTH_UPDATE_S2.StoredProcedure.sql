/****** Object:  StoredProcedure [dbo].[RCTH_UPDATE_S2]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[RCTH_UPDATE_S2] ( 
 
     @Ad_Batch_DATE		         DATE,
     @An_Batch_NUMB              NUMERIC(4,0),
     @An_SeqReceipt_NUMB		 NUMERIC(6,0),
     @Ac_SourceBatch_CODE		 CHAR(3),
     @An_EventGlobalEndSeq_NUMB  NUMERIC(19,0)   
  ) AS
  
/*
 * PROCEDURE NAME    : RCTH_UPDATE_S2
 * DESCRIPTION       : Update the Receipt from Current record to Historical record. 
 * DEVELOPED BY      : IMP Team
 * DEVELOPED ON      : 02-MAR-2011
 * MODIFIED BY       : 
 * MODIFIED ON       : 
 * VERSION NO        : 1
*/
   BEGIN 
   
    DECLARE
     @Ld_High_DATE          DATE = '12/31/9999',
     @Ld_Current_DATE       DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
     @Ln_RowsAffected_NUMB  NUMERIC(10); 
     
   UPDATE RCTH_Y1
     SET EndValidity_DATE = @Ld_Current_DATE,
     EventGlobalEndSeq_NUMB = @An_EventGlobalEndSeq_NUMB
     WHERE Batch_DATE = @Ad_Batch_DATE 
       AND  Batch_NUMB = @An_Batch_NUMB 
       AND  SeqReceipt_NUMB = @An_SeqReceipt_NUMB 
       AND  SourceBatch_CODE = @Ac_SourceBatch_CODE 
       AND  EndValidity_DATE = @Ld_High_DATE;     
     
   SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;

  SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB;   
       
     
END; -- END OF RCTH_UPDATE_S2    
     

GO
