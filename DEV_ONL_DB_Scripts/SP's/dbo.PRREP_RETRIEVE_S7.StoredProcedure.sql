/****** Object:  StoredProcedure [dbo].[PRREP_RETRIEVE_S7]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[PRREP_RETRIEVE_S7] 
			(  

			@Ad_Batch_DATE					 DATE,
			@An_Batch_NUMB                   NUMERIC(4,0),
			@An_EventGlobalBeginSeq_NUMB	 NUMERIC(19,0),
			@An_SeqReceipt_NUMB				 NUMERIC(6,0),
			@Ac_SourceBatch_CODE			 CHAR(3),
			@Ac_Session_ID					 CHAR(30),
			@Ai_Count_QNTY                   INT		OUTPUT,
			@Ac_SourceReceipt_CODE			 CHAR(2)	OUTPUT
			)
AS

/*
 *     PROCEDURE NAME    : PRREP_RETRIEVE_S7
 *     DESCRIPTION       : This procedure returns the ReceiptSource for the Receipt, Session_ID and EventGlobalBegSeq number.
 *							Concurrency Check
 *     DEVELOPED BY      : IMP TEAM
 *     DEVELOPED ON      : 28-NOV-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
 */
   BEGIN

      SELECT @Ai_Count_QNTY			= NULL,
             @Ac_SourceReceipt_CODE = NULL;

      SELECT @Ai_Count_QNTY = 1, 
			 @Ac_SourceReceipt_CODE = p.SourceReceipt_CODE
		FROM PRREP_Y1 p
       WHERE p.Session_ID		= @Ac_Session_ID 
		 AND p.Batch_DATE		= @Ad_Batch_DATE 
		 AND p.SourceBatch_CODE = @Ac_SourceBatch_CODE 
		 AND p.Batch_NUMB		= @An_Batch_NUMB 
		 AND P.SeqReceipt_NUMB	= @An_SeqReceipt_NUMB 
		 AND P.EventGlobalBeginSeq_NUMB = @An_EventGlobalBeginSeq_NUMB;

                  
END; --END OF PRREP_RETRIEVE_S7


GO
