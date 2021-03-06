/****** Object:  StoredProcedure [dbo].[OTHP_RETRIEVE_S52]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[OTHP_RETRIEVE_S52](
 @An_OtherParty_IDNO	NUMERIC(9,0),
 @As_OtherParty_NAME	VARCHAR(60) OUTPUT
 )
AS

/*
 *     PROCEDURE NAME    : OTHP_RETRIEVE_S52
 *     DESCRIPTION       : Retrieve the Other party name for the given other party number.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 06-DEC-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
 BEGIN
 
 	SET @As_OtherParty_NAME = NULL;
 	
 	DECLARE @Li_One_NUMB	SMALLINT = 1;

      SELECT @As_OtherParty_NAME = X.OtherParty_NAME
        FROM (
               SELECT o.OtherParty_NAME, 
                      ROW_NUMBER() OVER(ORDER BY o.TransactionEventSeq_NUMB DESC) AS rn
                 FROM OTHP_Y1 o
                WHERE o.OtherParty_IDNO = @An_OtherParty_IDNO
             )  AS X
       WHERE X.rn = @Li_One_NUMB;

END; --END OF OTHP_RETRIEVE_S52


GO
