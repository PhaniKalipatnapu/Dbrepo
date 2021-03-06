/****** Object:  StoredProcedure [dbo].[DEMO_RETRIEVE_S112]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DEMO_RETRIEVE_S112] (
 @An_MemberMci_IDNO   NUMERIC(10, 0),
 @Ac_Restricted_INDC  CHAR(1),
 @Ai_Count_QNTY		  INT OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : DEMO_RETRIEVE_S112
  *     DESCRIPTION       : Checks if given Member is restricted or not.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 03-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @Ai_Count_QNTY = NULL;

  SELECT @Ai_Count_QNTY = COUNT(1)
    FROM DEMO_Y1 D
   WHERE D.MemberMci_IDNO = @An_MemberMci_IDNO
     AND D.Restricted_INDC <> @Ac_Restricted_INDC;
 END


GO
