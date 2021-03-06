/****** Object:  StoredProcedure [dbo].[OBLE_RETRIEVE_S66]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE  [dbo].[OBLE_RETRIEVE_S66]  
	(
     @An_Case_IDNO					NUMERIC(6,0),
     @An_OrderSeq_NUMB				NUMERIC(2,0),
     @An_ObligationSeq_NUMB			NUMERIC(2,0),
     @Ac_TypeDebt_CODE				CHAR(2),
     @Ac_Fips_CODE					CHAR(7),
     @Ac_Allocated_INDC				CHAR(1),
     @An_EventGlobalBeginSeq_NUMB	NUMERIC(19,0)	 OUTPUT
    ) 
AS

/*
 *     PROCEDURE NAME    : OBLE_RETRIEVE_S66
 *     DESCRIPTION       : Retrieve the Event global sequence number from OBLE_Y1 for Concurrency Checking 
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 17-DEC-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
   BEGIN

      SET @An_EventGlobalBeginSeq_NUMB = NULL;

     DECLARE @Li_Zero_NUMB		SMALLINT = 0,
             @Lc_No_INDC		CHAR(1)  = 'N', 
             @Lc_Yes_INDC		CHAR(1)  = 'Y', 
             @Ld_High_DATE		DATE     = '12/31/9999';

      SELECT @An_EventGlobalBeginSeq_NUMB = ISNULL(MAX(O.EventGlobalBeginSeq_NUMB), @Li_Zero_NUMB)
		FROM OBLE_Y1 O
       WHERE O.Case_IDNO = @An_Case_IDNO 
         AND O.OrderSeq_NUMB = @An_OrderSeq_NUMB 
         AND ( ( @Ac_Allocated_INDC = @Lc_No_INDC 
				 AND O.ObligationSeq_NUMB IN ( SELECT DISTINCT L.ObligationSeq_NUMB
													FROM OBLE_Y1 L
											   WHERE L.Case_IDNO = @An_Case_IDNO 
											     AND L.OrderSeq_NUMB = @An_OrderSeq_NUMB 
											     AND L.TypeDebt_CODE = @Ac_TypeDebt_CODE 
											     AND L.Fips_CODE = @Ac_Fips_CODE 
												 AND L.EndValidity_DATE = @Ld_High_DATE ) ) 
			  OR ( @Ac_Allocated_INDC = @Lc_Yes_INDC 
				  AND O.ObligationSeq_NUMB = @An_ObligationSeq_NUMB ) ) 
		AND O.EndValidity_DATE = @Ld_High_DATE;
                 
END;--END OF OBLE_RETRIEVE_S66


GO
