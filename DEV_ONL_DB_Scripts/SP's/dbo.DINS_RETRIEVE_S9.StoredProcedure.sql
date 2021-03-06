/****** Object:  StoredProcedure [dbo].[DINS_RETRIEVE_S9]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DINS_RETRIEVE_S9](
 @An_Case_IDNO			NUMERIC(6, 0),
 @An_MemberMci_IDNO		NUMERIC(10, 0),
 @Ad_Status_DATE		DATE	OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : DINS_RETRIEVE_S9
  *     DESCRIPTION       : Retrieves the date NCP provided medical coverage for his or her children.  
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 14-OCT-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  SELECT @Ad_Status_DATE = NULL;

  DECLARE @Lc_CaseMembeStatusActive_CODE CHAR(1) = 'A',
		  @Lc_CaseRelationshipDp_CODE    CHAR(1) = 'D',
          @Ld_High_DATE  DATE = '12/31/9999';

	SELECT TOP 1 @Ad_Status_DATE = B.Status_DATE
	FROM MINS_Y1 A INNER JOIN DINS_Y1 B 
		ON A.OthpInsurance_IDNO  = B.OthpInsurance_IDNO
		AND A.InsuranceGroupNo_TEXT  = B.InsuranceGroupNo_TEXT
		AND A.PolicyInsNo_TEXT  = B.PolicyInsNo_TEXT
		INNER JOIN CMEM_Y1 C
		ON C.MemberMci_IDNO  = B.MemberMci_IDNO
	WHERE A.MemberMci_IDNO  = @An_MemberMci_IDNO
		AND	C.Case_IDNO  = @An_Case_IDNO
		--AND	C.CaseRelationship_CODE  = @Lc_CaseRelationshipDp_CODE
		AND	C.CaseMemberStatus_CODE  = @Lc_CaseMembeStatusActive_CODE
		AND	A.EndValidity_DATE  = @Ld_High_DATE
		AND	B.EndValidity_DATE  = @Ld_High_DATE
		AND	B.End_DATE  = @Ld_High_DATE;
				 
 END -- End of DINS_RETRIEVE_S9

GO
