/****** Object:  StoredProcedure [dbo].[CMEM_RETRIEVE_S162]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CMEM_RETRIEVE_S162]  
(
     @An_Case_IDNO			NUMERIC(6),
     @An_MemberMci_IDNO		NUMERIC(10),
     @Ai_Count_QNTY			INT OUTPUT
)
AS

 /*
  *     PROCEDURE NAME    : CMEM_RETRIEVE_S162
  *     DESCRIPTION       : Check if given Case ID and Member Mci ID is valid combination.
  *     DEVELOPED BY      : IMP TEAM
  *     DEVELOPED ON      : 02-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
	BEGIN

	SET @Ai_Count_QNTY = NULL;

	SELECT @Ai_Count_QNTY = COUNT(1)
	FROM CMEM_Y1 C
	  WHERE C.MemberMci_IDNO = @An_MemberMci_IDNO 
	  AND C.Case_IDNO = @An_Case_IDNO;

                  
END;-- End of CMEM_RETRIEVE_S162


GO
