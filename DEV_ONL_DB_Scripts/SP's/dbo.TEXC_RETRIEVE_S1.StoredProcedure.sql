/****** Object:  StoredProcedure [dbo].[TEXC_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[TEXC_RETRIEVE_S1]  (
     @An_Case_IDNO					NUMERIC(6,0),
     @An_MemberMci_IDNO				NUMERIC(10,0),
     @An_TransactionEventSeq_NUMB	NUMERIC(19,0)	 OUTPUT
     )
AS

/*
 *     PROCEDURE NAME    : TEXC_RETRIEVE_S1
 *     DESCRIPTION       : Retrieves the Event Transaction Sequence NUmber for the given Case ID and Member Mci Id.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 12/06/2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1.0
*/

BEGIN
      SET @An_TransactionEventSeq_NUMB = NULL;

  DECLARE @Ld_High_DATE DATE = '12/31/9999';
        
   SELECT @An_TransactionEventSeq_NUMB = T.TransactionEventSeq_NUMB
     FROM TEXC_Y1 T
    WHERE T.Case_IDNO        = @An_Case_IDNO 
	  AND T.MemberMci_IDNO   = @An_MemberMci_IDNO 
	  AND T.EndValidity_DATE = @Ld_High_DATE;
		
END --END OF TEXC_RETRIEVE_S1


GO
