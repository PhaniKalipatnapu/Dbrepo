/****** Object:  StoredProcedure [dbo].[ACEN_RETRIEVE_S4]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ACEN_RETRIEVE_S4]  
(
     @An_Case_IDNO					NUMERIC(6,0),
     @Ad_BeginExempt_DATE			DATE	 OUTPUT,
     @An_TransactionEventSeq_NUMB	NUMERIC(19,0)	 OUTPUT
)
AS

/*
 *     PROCEDURE NAME    : ACEN_RETRIEVE_S4
 *     DESCRIPTION       : Retrieves the active transaction event and begin exempt for the given case id.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 12/13/2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/

   BEGIN
      SELECT @Ad_BeginExempt_DATE         = NULL,
             @An_TransactionEventSeq_NUMB = NULL;
     DECLARE @Ld_High_DATE DATE = '12/31/9999';
        
        SELECT @An_TransactionEventSeq_NUMB = A.TransactionEventSeq_NUMB, 
			   @Ad_BeginExempt_DATE         = A.BeginExempt_DATE
          FROM ACEN_Y1 A
         WHERE A.Case_IDNO        = @An_Case_IDNO 
		   AND A.EndValidity_DATE = @Ld_High_DATE;
                  
END;--End of ACEN_RETRIEVE_S4


GO
