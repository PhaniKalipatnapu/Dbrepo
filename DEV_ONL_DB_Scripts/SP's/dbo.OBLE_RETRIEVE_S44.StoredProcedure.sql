/****** Object:  StoredProcedure [dbo].[OBLE_RETRIEVE_S44]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE  [dbo].[OBLE_RETRIEVE_S44]
	(
	 @An_Case_IDNO					NUMERIC(6,0),
	 @An_OrderSeq_NUMB				NUMERIC(2,0),     
     @An_EventGlobalBeginSeq_NUMB	NUMERIC(19,0)  
    )          
AS

/*
 *     PROCEDURE NAME    : OBLE_RETRIEVE_S44
 *     DESCRIPTION       : Retrieve the Obligation details from OBLE_Y1 for Case ID to display in popup window.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 15-DEC-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
   BEGIN

      DECLARE
         @Ld_High_DATE DATE  = '12/31/9999';
        
        SELECT o.Case_IDNO, 
			   o.OrderSeq_NUMB, 
			   o.ObligationSeq_NUMB, 
			   o.MemberMci_IDNO, 
			   o.TypeDebt_CODE, 
			   o.Fips_CODE, 
			   o.FreqPeriodic_CODE, 
			   o.Periodic_AMNT, 
			   o.ExpectToPay_AMNT, 
			   o.ReasonChange_CODE, 
			   o.BeginObligation_DATE, 
			   o.EndObligation_DATE, 
			   o.AccrualLast_DATE, 
			   o.AccrualNext_DATE, 
			   o.CheckRecipient_ID, 
			   o.CheckRecipient_CODE, 
			   o.EventGlobalBeginSeq_NUMB, 
			   o.EventGlobalEndSeq_NUMB, 
			   o.EndValidity_DATE AS BeginValidity_DATE, 
			   o.EndValidity_DATE, 
			   o.ExpectToPay_CODE 
           FROM OBLE_Y1 o
      WHERE o.Case_IDNO = @An_Case_IDNO 
      AND	o.OrderSeq_NUMB = @An_OrderSeq_NUMB 
      AND	o.EventGlobalBeginSeq_NUMB >= @An_EventGlobalBeginSeq_NUMB 
      AND 	o.EndValidity_DATE = @Ld_High_DATE;
                  
END; --END OF OBLE_RETRIEVE_S44


GO
