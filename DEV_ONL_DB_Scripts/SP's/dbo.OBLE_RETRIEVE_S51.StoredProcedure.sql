/****** Object:  StoredProcedure [dbo].[OBLE_RETRIEVE_S51]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[OBLE_RETRIEVE_S51]
	(
	 @An_Case_IDNO					NUMERIC(6,0),
	 @An_OrderSeq_NUMB				NUMERIC(2,0),
	 @An_ObligationSeq_NUMB			NUMERIC(2,0),
	 @Ad_BegObligation_DATE			DATE,
	 @Ad_BeginObligation_DATE		DATE			OUTPUT,
	 @An_EventGlobalBeginSeq_NUMB	NUMERIC(19,0)	OUTPUT,     
     @An_MemberMci_IDNO				NUMERIC(10,0)	OUTPUT,
     @Ac_FreqPeriodic_CODE		    CHAR(1)			OUTPUT,
     @An_Periodic_AMNT				NUMERIC(11,2)	OUTPUT,
     @An_ExpectToPay_AMNT			NUMERIC(11,2)   OUTPUT,
     @Ac_ExpectToPay_CODE			CHAR(1)			OUTPUT,
     @Ad_EndObligation_DATE			DATE			OUTPUT,
     @Ad_AccrualNext_DATE			DATE			OUTPUT,
     @Ac_CheckRecipient_ID			CHAR(10)	    OUTPUT,
     @Ac_CheckRecipient_CODE		CHAR(1)			OUTPUT
    )
AS
/*
 *     PROCEDURE NAME    : OBLE_RETRIEVE_S51
 *     DESCRIPTION       : Retrieve the Obligation information from OBLE_Y1 for Obligation sequence number and case id.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 17-DEC-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/   BEGIN
		  SELECT @Ac_ExpectToPay_CODE = NULL,
				 @Ac_CheckRecipient_CODE = NULL,
				 @Ad_AccrualNext_DATE = NULL,
				 @Ad_BeginObligation_DATE = NULL,
				 @Ad_EndObligation_DATE = NULL,
				 @An_ExpectToPay_AMNT = NULL,
				 @An_Periodic_AMNT = NULL,
				 @An_EventGlobalBeginSeq_NUMB = NULL,
				 @Ac_FreqPeriodic_CODE = NULL,
				 @Ac_CheckRecipient_ID = NULL,
				 @An_MemberMci_IDNO = NULL;

		  DECLARE
			 @Ld_High_DATE		DATE = '12/31/9999',
			 @Ld_Current_DATE   DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
        
        SELECT @An_MemberMci_IDNO = a.MemberMci_IDNO, 
			   @An_Periodic_AMNT = a.Periodic_AMNT, 
			   @Ac_FreqPeriodic_CODE = a.FreqPeriodic_CODE, 
			   @Ad_BeginObligation_DATE = a.BeginObligation_DATE, 
			   @Ad_EndObligation_DATE = a.EndObligation_DATE, 
			   @An_ExpectToPay_AMNT = a.ExpectToPay_AMNT, 
               @Ad_AccrualNext_DATE = a.AccrualNext_DATE, 
               @Ac_CheckRecipient_ID = a.CheckRecipient_ID, 
               @Ac_CheckRecipient_CODE = a.CheckRecipient_CODE, 
               @An_EventGlobalBeginSeq_NUMB = a.EventGlobalBeginSeq_NUMB, 
               @Ac_ExpectToPay_CODE = a.ExpectToPay_CODE
		  FROM OBLE_Y1  a
		 WHERE a.Case_IDNO = @An_Case_IDNO 
		   AND a.OrderSeq_NUMB = @An_OrderSeq_NUMB 
		   AND a.ObligationSeq_NUMB = @An_ObligationSeq_NUMB 
		   AND a.BeginObligation_DATE = @Ad_BegObligation_DATE
		  AND a.EndValidity_DATE = @Ld_High_DATE;
                  
END; --END OF OBLE_RETRIEVE_S51


GO
