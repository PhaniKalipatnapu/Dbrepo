/****** Object:  StoredProcedure [dbo].[OBLE_RETRIEVE_S80]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE  [dbo].[OBLE_RETRIEVE_S80] (
	 @An_Case_IDNO				NUMERIC(6,0),
	 @An_OrderSeq_NUMB			NUMERIC(2,0),
     @An_ObligationSeq_NUMB		NUMERIC(2,0),
     @Ad_BeginObligation_DATE	DATE			OUTPUT,
     @Ai_Count_QNTY             INT		        OUTPUT
    )
AS

/*
 *     PROCEDURE NAME    : OBLE_RETRIEVE_S80
 *     DESCRIPTION       : Retrieve the maximum obligation date and count of obligation from OBLE_Y1 
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 17-DEC-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
   BEGIN
       SELECT  @Ad_BeginObligation_DATE = NULL,
		       @Ai_Count_QNTY = NULL;

       DECLARE @Ld_Current_DATE  DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
               @Ld_High_DATE	   DATE  = '12/31/9999';
        
         SELECT @Ad_BeginObligation_DATE = MAX(a.BeginObligation_DATE), 
			    @Ai_Count_QNTY = COUNT(1)
	       FROM OBLE_Y1  a
		 WHERE a.Case_IDNO = @An_Case_IDNO 
		   AND a.OrderSeq_NUMB = @An_OrderSeq_NUMB 
		   AND a.ObligationSeq_NUMB = @An_ObligationSeq_NUMB 
		   AND a.EndValidity_DATE = @Ld_High_DATE 
		   AND a.BeginObligation_DATE <=@Ld_Current_DATE;
                  
END; --END OF OBLE_RETRIEVE_S80


GO
