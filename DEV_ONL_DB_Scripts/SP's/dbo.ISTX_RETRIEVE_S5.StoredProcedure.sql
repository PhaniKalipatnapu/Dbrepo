/****** Object:  StoredProcedure [dbo].[ISTX_RETRIEVE_S5]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ISTX_RETRIEVE_S5] (
 @An_Case_IDNO			NUMERIC(6, 0),
 @An_MemberMci_IDNO		NUMERIC(10, 0),
 @Ad_SubmitLast_DATE	DATE  OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : ISTX_RETRIEVE_S5
  *     DESCRIPTION       : Retrieves date NCP was submitted or an update was sent to the State Tax Offset program.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 16-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
	SELECT @Ad_SubmitLast_DATE = NULL;

	SELECT @Ad_SubmitLast_DATE =  MAX (SubmitLast_DATE)
	FROM ISTX_Y1
	WHERE Case_IDNO = @An_Case_IDNO 
		AND MemberMci_IDNO = @An_MemberMci_IDNO;

 END; --End Of Procedure ISTX_RETRIEVE_S5


GO
