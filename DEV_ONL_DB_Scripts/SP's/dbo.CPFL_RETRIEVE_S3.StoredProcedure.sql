/****** Object:  StoredProcedure [dbo].[CPFL_RETRIEVE_S3]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CPFL_RETRIEVE_S3] (
 @Ad_Batch_DATE				DATE,
 @Ac_SourceBatch_CODE		CHAR(3),
 @An_BATCH_NUMB				NUMERIC(4,0),
 @An_SeqReceipt_NUMB		NUMERIC(6,0),  
 @An_Transaction_AMNT       NUMERIC(11,2) OUTPUT	    
 )
AS
/*
 *     PROCEDURE NAME    : CPFL_RETRIEVE_S3
 *     DESCRIPTION       : Procedure is used to get the recouped cp fees amount from the given receipt.
 *     DEVELOPED BY      : IMP Team    
 *     DEVELOPED ON      : 10-AUG-2011 
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
BEGIN
	DECLARE @Lc_TransactionSrec_CODE CHAR(4) = 'SREC',
			@Lc_TransactionRdcr_CODE CHAR(4) = 'RDCR';
			
		SET @An_Transaction_AMNT = 0;
			
	 SELECT @An_Transaction_AMNT = ISNULL (SUM (C.Transaction_AMNT), 0)  	             
	   FROM CPFL_Y1 C
	  WHERE C.Batch_DATE		= @Ad_Batch_DATE
		AND C.SourceBatch_CODE  = @Ac_SourceBatch_CODE
		AND C.BATCH_NUMB		= @An_BATCH_NUMB
		AND C.SeqReceipt_NUMB   = @An_SeqReceipt_NUMB
		AND C.Transaction_CODE IN ( @Lc_TransactionSrec_CODE, @Lc_TransactionRdcr_CODE); 
      
END;--End Of CPFL_RETRIEVE_S3


GO
