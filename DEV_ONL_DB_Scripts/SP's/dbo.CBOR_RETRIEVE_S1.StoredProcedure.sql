/****** Object:  StoredProcedure [dbo].[CBOR_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CBOR_RETRIEVE_S1] (
 @An_Case_IDNO			NUMERIC(6, 0),
 @An_MemberMci_IDNO		NUMERIC(10, 0),
 @Ad_SubmitLast_DATE	DATE  OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : CBOR_RETRIEVE_S1
  *     DESCRIPTION       : Retrieves the most recent date NCP’s was reported to the credit bureaus.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 16-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
	SELECT @Ad_SubmitLast_DATE = NULL;

	DECLARE @Lc_StatusAccount11_CODE	CHAR(2) = '11',
			@Lc_StatusAccount71_CODE	CHAR(2) = '71',
			@Lc_StatusAccount78_CODE	CHAR(2) = '78',
			@Lc_StatusAccount93_CODE	CHAR(2) = '93',
			@Ld_High_DATE				DATE = '12/31/9999';

	SELECT @Ad_SubmitLast_DATE = MAX (A.SubmitLast_DATE)
	FROM CBOR_Y1 A
	WHERE A.StatusAccount_CODE IN (@Lc_StatusAccount11_CODE, @Lc_StatusAccount71_CODE, @Lc_StatusAccount78_CODE, @Lc_StatusAccount93_CODE)
		AND A.EndValidity_DATE = @Ld_High_DATE
		AND A.Case_IDNO = @An_Case_IDNO
		AND A.MemberMci_IDNO = @An_MemberMci_IDNO;

 END; --End Of Procedure CBOR_RETRIEVE_S1


GO
