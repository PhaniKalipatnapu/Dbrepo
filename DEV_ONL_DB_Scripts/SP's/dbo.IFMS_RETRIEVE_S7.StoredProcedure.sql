/****** Object:  StoredProcedure [dbo].[IFMS_RETRIEVE_S7]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[IFMS_RETRIEVE_S7] (
 @An_Case_IDNO			NUMERIC(6, 0),
 @An_MemberMci_IDNO		NUMERIC(10, 0),
 @Ad_SubmitLast_DATE	DATE  OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : IFMS_RETRIEVE_S7
  *     DESCRIPTION       : Retrieves the date NCP was submitted or an update was sent to the Federal Tax Offset program.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 16-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
	SELECT @Ad_SubmitLast_DATE = NULL;

	DECLARE @Li_Zero_NUMB	INT = 0;

	SELECT @Ad_SubmitLast_DATE = MAX (SubmitLast_DATE)
	FROM IFMS_Y1
	WHERE Case_IDNO = @An_Case_IDNO
		AND MemberMci_IDNO = @An_MemberMci_IDNO
		AND Transaction_AMNT > @Li_Zero_NUMB;

 END; --End Of Procedure IFMS_RETRIEVE_S7


GO
