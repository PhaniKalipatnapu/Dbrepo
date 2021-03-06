/****** Object:  StoredProcedure [dbo].[LSUP_RETRIEVE_S47]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[LSUP_RETRIEVE_S47]  
(
     @An_Case_IDNO						NUMERIC(6,0),
     @An_OrderSeq_NUMB					NUMERIC(2,0),
     @An_ObligationSeq_NUMB				NUMERIC(2,0),
     @Ac_TypeDebt_CODE					CHAR(2),
     @Ac_Fips_CODE						CHAR(7),
     @Ac_Allocated_INDC					CHAR(1),
     @An_EventGlobalSeq_NUMB			NUMERIC(19,0)	 OUTPUT
)
AS

/*
 *     PROCEDURE NAME    : LSUP_RETRIEVE_S47
 *     DESCRIPTION       : Retrieve the Event global sequence number from LSUP_Y1 for Concurrency Checking
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 15-DEC-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
   BEGIN

      SET @An_EventGlobalSeq_NUMB = NULL;

      DECLARE
         @Li_Zero_NUMB INT       = 0,
         @Lc_No_INDC   CHAR(1)   = 'N', 
         @Lc_Yes_INDC  CHAR(1)   = 'Y', 
         @Ld_High_DATE DATE      = '12/31/9999';         

      SELECT @An_EventGlobalSeq_NUMB = ISNULL(MAX(b.EventGlobalSeq_NUMB), @Li_Zero_NUMB)
        FROM LSUP_Y1  b
       WHERE b.Case_IDNO = @An_Case_IDNO 
         AND b.OrderSeq_NUMB = @An_OrderSeq_NUMB 
         AND ( (@Ac_Allocated_INDC = @Lc_No_INDC 
				AND b.ObligationSeq_NUMB IN (SELECT DISTINCT a.ObligationSeq_NUMB
											  FROM OBLE_Y1  a
											 WHERE a.Case_IDNO = b.Case_IDNO 
											   AND a.OrderSeq_NUMB = b.OrderSeq_NUMB 
											   AND a.TypeDebt_CODE = @Ac_TypeDebt_CODE 
											   AND a.Fips_CODE = @Ac_Fips_CODE 
											   AND a.EndValidity_DATE = @Ld_High_DATE ))
			OR (@Ac_Allocated_INDC = @Lc_Yes_INDC 
				AND b.ObligationSeq_NUMB = @An_ObligationSeq_NUMB)
			) 
         AND b.SupportYearMonth_NUMB = (SELECT MAX(c.SupportYearMonth_NUMB) 
											FROM LSUP_Y1  c
										WHERE c.Case_IDNO = b.Case_IDNO 
										  AND c.OrderSeq_NUMB = b.OrderSeq_NUMB 
										  AND c.ObligationSeq_NUMB = b.ObligationSeq_NUMB);

END;--End of LSUP_RETRIEVE_S47


GO
