/****** Object:  StoredProcedure [dbo].[DEMO_RETRIEVE_S133]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DEMO_RETRIEVE_S133] (
 @An_MemberMci_IDNO				NUMERIC(10,0),
 @An_MemberMciSecondary_IDNO	NUMERIC(10,0),
 @Ai_Count_QNTY		 			INT OUTPUT
 )
AS

/*
 *     PROCEDURE NAME    : DEMO_RETRIEVE_S133
 *     DESCRIPTION       : Retrieve the count of records from Member Demographic table for Member primary and secondary sex code do not match.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 20-DEC-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
 BEGIN

	SET @Ai_Count_QNTY = NULL;

 SELECT @Ai_Count_QNTY = COUNT(1)
   FROM DEMO_Y1 dmp
        JOIN
        DEMO_Y1 dms
     ON dmp.MemberSex_CODE != dms.MemberSex_CODE    
  WHERE dmp.MemberMci_IDNO = @An_MemberMci_IDNO 
    AND dms.MemberMci_IDNO = @An_MemberMciSecondary_IDNO;
                     
END; -- END OF DEMO_RETRIEVE_S133


GO
