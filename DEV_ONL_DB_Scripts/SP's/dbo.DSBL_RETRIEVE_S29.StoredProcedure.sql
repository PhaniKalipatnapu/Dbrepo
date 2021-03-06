/****** Object:  StoredProcedure [dbo].[DSBL_RETRIEVE_S29]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
CREATE PROCEDURE [dbo].[DSBL_RETRIEVE_S29]
(
	@Ac_SourceBatch_CODE	CHAR(3),
	@Ad_Batch_DATE			DATE,
	@An_Batch_NUMB			NUMERIC(4,0),
	@An_SeqReceipt_NUMB		NUMERIC(6,0),
	@Ad_Disburse_DATE		DATE  OUTPUT
)
AS
 
 /*                                                                                   
  *     PROCEDURE NAME    : DSBL_RETRIEVE_S29                                          
  *     DESCRIPTION       : This procedure is used to retrieve the Disburse date.
  *     DEVELOPED BY      : IMP TEAM                                              
  *     DEVELOPED ON      : 03/07/2012
  *     MODIFIED BY       :                                                           
  *     MODIFIED ON       :                                                           
  *     VERSION NO        : 1                                                         
  */
BEGIN

	    SET @Ad_Disburse_DATE = NULL;
 
	DECLARE @Ld_Low_DATE			DATE = '01/01/0001';
 
	 SELECT @Ad_Disburse_DATE	= ISNULL(MIN (b.Disburse_DATE),@Ld_Low_DATE)
	   FROM DSBL_Y1 b
	  WHERE b.Batch_DATE		= @Ad_Batch_DATE
	    AND b.SourceBatch_CODE	= @Ac_SourceBatch_CODE
	    AND b.Batch_NUMB		= @An_Batch_NUMB
	    AND b.SeqReceipt_NUMB	= @An_SeqReceipt_NUMB;
 
END --End Of Procedure DSBL_RETRIEVE_S29
 

GO
