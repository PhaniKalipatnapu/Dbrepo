/****** Object:  StoredProcedure [dbo].[LSUP_RETRIEVE_S5]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[LSUP_RETRIEVE_S5]  
    (
     @An_Case_IDNO		     NUMERIC(6,0),
     @An_OrderSeq_NUMB		 NUMERIC(2,0),
     @An_ObligationSeq_NUMB	 NUMERIC(2,0),
     @An_EventGlobalSeq_NUMB NUMERIC(19,0)	 OUTPUT
     )
AS
/*
*     PROCEDURE NAME    : LSUP_RETRIEVE_S5
 *     DESCRIPTION       : Procedure to Selecting the maximum seq event global for that obligation to check for locks while updating.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 02-SEP-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
BEGIN

         SET @An_EventGlobalSeq_NUMB = NULL;

      SELECT @An_EventGlobalSeq_NUMB = MAX(a.EventGlobalSeq_NUMB)
        FROM LSUP_Y1 a
       WHERE a.Case_IDNO = @An_Case_IDNO 
         AND a.OrderSeq_NUMB = @An_OrderSeq_NUMB 
         AND a.ObligationSeq_NUMB = @An_ObligationSeq_NUMB 
         AND a.SupportYearMonth_NUMB = 
						 (
							SELECT MAX(b.SupportYearMonth_NUMB)
							  FROM LSUP_Y1 b
							 WHERE b.Case_IDNO = @An_Case_IDNO 
							   AND b.OrderSeq_NUMB = @An_OrderSeq_NUMB 
							   AND b.ObligationSeq_NUMB = @An_ObligationSeq_NUMB
						 );

END; --End of LSUP_RETRIEVE_S5


GO
