/****** Object:  StoredProcedure [dbo].[PRREP_RETRIEVE_S6]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[PRREP_RETRIEVE_S6] ( 
			 @Ac_Session_ID				 CHAR(30)              
			)
AS
/*
 *     PROCEDURE NAME    : PRREP_RETRIEVE_S6
 *     DESCRIPTION       : This procedure returns the receipt details from PRREP_Y1 table for the Session_ID
 *     DEVELOPED BY      : IMP TEAM
 *     DEVELOPED ON      : 07-OCT-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
 */  BEGIN
	DECLARE @Ld_High_DATE	   DATE	=	'12/31/9999';
	
       SELECT p.BackOut_INDC, 
			  p.RePost_INDC, 
			  p.Refund_INDC, 
			  p.Batch_DATE, 
			  p.SourceBatch_CODE,
			  p.Batch_NUMB, 
			  p.SeqReceipt_NUMB,
			  p.Receipt_DATE, 
			  p.PayorMCI_IDNO, 
			  p.CasePayorMCI_IDNO, 
			  p.Ncp_NAME, 
			  p.Receipt_AMNT, 
			  p.Held_AMNT, 
			  p.Distributed_AMNT, 
			  p.Refund_AMNT, 
			  p.CasePayorMCIReposted_IDNO, 
			  p.MultiCase_INDC, 
			  p.ClosedCase_INDC, 
			  p.Distd_INDC, 
			  p.EventGlobalBeginSeq_NUMB, 
			  p.RepostedPayorMci_IDNO, 
			  p.SourceReceipt_CODE,
			  h.TypePosting_CODE 			 
		FROM PRREP_Y1 p
		JOIN HIMS_Y1 h
		  ON p.SourceReceipt_CODE = h.SourceReceipt_CODE
		 AND h.EndValidity_DATE = @Ld_High_DATE
	   WHERE p.Session_ID = @Ac_Session_ID
	ORDER BY Receipt_DATE DESC;

END; -- END OF PRREP_RETRIEVE_S6                                    


GO
