/****** Object:  StoredProcedure [dbo].[DSBL_RETRIEVE_S2]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DSBL_RETRIEVE_S2]  
  (
	@Ac_CheckRecipient_CODE	 CHAR(1),
	@Ac_CheckRecipient_ID  CHAR(10),      
	@Ad_Disburse_DATE		 DATE,
	@An_DisburseSeq_NUMB	 NUMERIC(4,0)
  )  
AS

/*
 *     PROCEDURE NAME    : DSBL_RETRIEVE_S2
 *     DESCRIPTION       : Retrieves the Disbursement Batch details for the respective Check Recipient Id.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 04-AUG-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/

BEGIN

	SELECT DISTINCT D.Batch_DATE, 
			D.SourceBatch_CODE, 
			D.Batch_NUMB, 
			D.SeqReceipt_NUMB
	  FROM  DSBL_Y1 D
	    WHERE
			D.CheckRecipient_ID = @Ac_CheckRecipient_ID
			AND D.CheckRecipient_CODE = @Ac_CheckRecipient_CODE
			AND D.Disburse_DATE = @Ad_Disburse_DATE
			AND D.DisburseSeq_NUMB = @An_DisburseSeq_NUMB;
		
END; -- End Of Procedure DSBL_RETRIEVE_S2





GO
