/****** Object:  StoredProcedure [dbo].[IFMS_RETRIEVE_S8]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[IFMS_RETRIEVE_S8] (
 @An_Case_IDNO			NUMERIC(6, 0),
 @An_MemberMci_IDNO		NUMERIC(10, 0),
 @Ad_SubmitLast_DATE	DATE  OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : IFMS_RETRIEVE_S8
  *     DESCRIPTION       : Retrieves the most recent date NCP’s was submitted to the Passport Denial program.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 16-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
	SELECT @Ad_SubmitLast_DATE = NULL;

	DECLARE @Lc_ExcludePasN_CODE	CHAR(1) = 'N';

	SELECT @Ad_SubmitLast_DATE = MAX (SubmitLast_DATE)
	FROM IFMS_Y1
	WHERE Case_IDNO = @An_Case_IDNO
		AND MemberMci_IDNO = @An_MemberMci_IDNO
		AND ExcludePas_CODE = @Lc_ExcludePasN_CODE;

 END; --End Of Procedure IFMS_RETRIEVE_S8


GO
