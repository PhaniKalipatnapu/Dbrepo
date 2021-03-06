/****** Object:  StoredProcedure [dbo].[OBLE_RETRIEVE_S52]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[OBLE_RETRIEVE_S52]  
(
     @An_Case_IDNO				NUMERIC(6,0),
     @An_OrderSeq_NUMB			NUMERIC(2,0),
     @An_ObligationSeq_NUMB		NUMERIC(2,0),
     @Ad_EndObligation_DATE		DATE,
     @Ad_BeginObligation_DATE	DATE			OUTPUT,
     @Ac_FreqPeriodic_CODE		CHAR(1)			OUTPUT,
     @An_Periodic_AMNT			NUMERIC(11,2)	OUTPUT,
     @An_ExpectToPay_AMNT       NUMERIC(11,2)   OUTPUT,
     @Ad_AccrualNext_DATE		DATE			OUTPUT
   )
AS

/*
*     PROCEDURE NAME	 : OBLE_RETRIEVE_S52
 *     DESCRIPTION       : Retrieve the Obligation information from OBLE_Y1 for Obligation sequence number and case id.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 19-DEC-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/   BEGIN

      SELECT @Ad_AccrualNext_DATE = NULL,
			 @Ad_BeginObligation_DATE = NULL,
			 @An_ExpectToPay_AMNT = NULL,
			 @An_Periodic_AMNT = NULL,
			 @Ac_FreqPeriodic_CODE = NULL;

      DECLARE
			 @Li_One_NUMB  INT	= 1,
			 @Ld_High_DATE DATE = '12/31/9999';
        
       SELECT @An_Periodic_AMNT = a.Periodic_AMNT, 
	          @Ac_FreqPeriodic_CODE = a.FreqPeriodic_CODE, 
	 		  @Ad_BeginObligation_DATE = a.BeginObligation_DATE, 
			  @Ad_EndObligation_DATE = a.EndObligation_DATE, 
			  @An_ExpectToPay_AMNT = a.ExpectToPay_AMNT, 
			  @Ad_AccrualNext_DATE = a.AccrualNext_DATE
        FROM OBLE_Y1  a
       WHERE a.Case_IDNO = @An_Case_IDNO 
         AND a.OrderSeq_NUMB = @An_OrderSeq_NUMB 
         AND a.ObligationSeq_NUMB = @An_ObligationSeq_NUMB 
         AND a.BeginObligation_DATE = DATEADD(D,@Li_One_NUMB, @Ad_EndObligation_DATE) 
         AND a.EndValidity_DATE = @Ld_High_DATE;
                  
END;--End of OBLE_RETRIEVE_S52


GO
