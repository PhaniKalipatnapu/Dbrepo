/****** Object:  StoredProcedure [dbo].[OBLE_RETRIEVE_S50]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[OBLE_RETRIEVE_S50]  
(
     @An_Case_IDNO              NUMERIC(6,0),
     @An_OrderSeq_NUMB          NUMERIC(2,0),
     @An_ObligationSeq_NUMB		NUMERIC(2,0),
     @Ad_EndObligation_DATE		DATE,
     @An_EventGlobalSeq_NUMB	NUMERIC(19,0)
 )              
AS
/*
 *     PROCEDURE NAME    : OBLE_RETRIEVE_S50
 *     DESCRIPTION       : Retrieve the Obligation information from OBLE_Y1 for Case_id.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 19-DEC-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/   BEGIN
        SELECT a.ObligationSeq_NUMB, 
			   a.MemberMci_IDNO, 
			   a.TypeDebt_CODE, 
			   a.Fips_CODE, 
			   a.FreqPeriodic_CODE, 
			   a.Periodic_AMNT, 
		  	   a.ExpectToPay_AMNT, 
			   a.ExpectToPay_CODE, 
			   a.BeginObligation_DATE, 
			   a.AccrualLast_DATE, 
			   a.AccrualNext_DATE, 
			   a.CheckRecipient_ID , 
			   a.CheckRecipient_CODE  
		  FROM OBLE_Y1 a
         WHERE a.Case_IDNO = @An_Case_IDNO 
           AND a.OrderSeq_NUMB = @An_OrderSeq_NUMB 
           AND a.ObligationSeq_NUMB = @An_ObligationSeq_NUMB 
           AND a.EndObligation_DATE > @Ad_EndObligation_DATE 
           AND a.EndObligation_DATE = 
					 (
						SELECT MIN(b.EndObligation_DATE) 
						  FROM OBLE_Y1  b
						 WHERE a.Case_IDNO = b.Case_IDNO 
						   AND a.OrderSeq_NUMB = b.OrderSeq_NUMB 
						   AND a.ObligationSeq_NUMB = b.ObligationSeq_NUMB 
						   AND b.EventGlobalEndSeq_NUMB = @An_EventGlobalSeq_NUMB
					 ) 
         AND a.EventGlobalEndSeq_NUMB = @An_EventGlobalSeq_NUMB;
                  
END;-- End of OBLE_RETRIEVE_S50


GO
