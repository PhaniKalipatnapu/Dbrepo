/****** Object:  StoredProcedure [dbo].[OBLE_RETRIEVE_S84]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[OBLE_RETRIEVE_S84]
	(
	 @An_Case_IDNO					NUMERIC(6,0),
	 @An_OrderSeq_NUMB				NUMERIC(2,0),
	 @An_ObligationSeq_NUMB			NUMERIC(2,0),
	 @Ad_BeginObligation_DATE		DATE,
	 @An_EventGlobalEndSeq_NUMB		NUMERIC(19,0),
	 @Ad_AccrualLast_DATE			DATE			OUTPUT,
     @Ad_AccrualNext_DATE			DATE			OUTPUT
    )
AS

/*
 *     PROCEDURE NAME    : OBLE_RETRIEVE_S84
 *     DESCRIPTION       : This procedure returns the Accural init amount,last and next date from the OBLE_Y1.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 19-DEC-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
   BEGIN

      SELECT @Ad_AccrualLast_DATE = NULL,
			 @Ad_AccrualNext_DATE = NULL;
			
     DECLARE @Ld_Current_DATE  DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

      SELECT @Ad_AccrualLast_DATE = O.AccrualLast_DATE, 
             @Ad_AccrualNext_DATE = O.AccrualNext_DATE
		FROM OBLE_Y1 O
       WHERE O.Case_IDNO			 = @An_Case_IDNO 
         AND O.OrderSeq_NUMB		 = @An_OrderSeq_NUMB 
         AND O.ObligationSeq_NUMB	 = @An_ObligationSeq_NUMB 
         AND O.BeginObligation_DATE	 = @Ad_BeginObligation_DATE 
         AND O.EventGlobalEndSeq_NUMB = @An_EventGlobalEndSeq_NUMB 
         AND O.EndValidity_DATE		 = @Ld_Current_DATE ; 

                  
END; --END OF OBLE_RETRIEVE_S84


GO
