/****** Object:  StoredProcedure [dbo].[DEMO_RETRIEVE_S97]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DEMO_RETRIEVE_S97] (
 @An_Case_IDNO NUMERIC(6, 0)
 )
AS
 /*
  *     PROCEDURE NAME    : DEMO_RETRIEVE_S97
  *     DESCRIPTION       : 
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 23-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Lc_CaseRelationShipDep_CODE			CHAR(1) = 'D',
			@Lc_CaseMemberStatusActive_CODE		CHAR(1) = 'A',
			@Lc_StatusEstablishDisEstablished_CODE	CHAR(1) = 'D',
			@Lc_StatusEstablishToBeEstablished_CODE	CHAR(1) = 'T';

	SELECT A.Last_NAME, 
		A.First_NAME, 
		A.Middle_NAME, 
		C.PaternityEst_DATE,
		COUNT(1) OVER () AS RowCount_NUMB
	FROM DEMO_Y1 A, CMEM_Y1 B, MPAT_Y1 C
	WHERE B.Case_IDNO = @An_Case_IDNO
		AND A.MemberMci_IDNO = B.MemberMci_IDNO
		AND A.MemberMci_IDNO = C.MemberMci_IDNO
		AND B.CaseRelationship_CODE = @Lc_CaseRelationShipDep_CODE
		AND B.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
		AND C.StatusEstablish_CODE IN (@Lc_StatusEstablishDisEstablished_CODE,@Lc_StatusEstablishToBeEstablished_CODE)
	GROUP BY A.Last_NAME,
		A.First_NAME,
		A.Middle_NAME,
		C.PaternityEst_DATE;	
		
					
 END; --End Of DEMO_RETRIEVE_S97

GO
