/****** Object:  StoredProcedure [dbo].[DEMO_RETRIEVE_S137]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DEMO_RETRIEVE_S137] (
	@An_Case_IDNO		NUMERIC(6,0),
	@An_MemberMci_IDNO	NUMERIC(10,0)	OUTPUT,	
	@Ac_First_NAME		CHAR(16)		OUTPUT,
	@Ac_Last_NAME		CHAR(20)		OUTPUT
)
AS
/*
 *     PROCEDURE NAME    : DEMO_RETRIEVE_S137
 *     DESCRIPTION       : This procedure is used to get the NCP member details for the given case id.
 *     DEVELOPED BY      : IMP TEAM
 *     DEVELOPED ON      : 16-FEB-2012
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
 */
BEGIN
	 SELECT @An_MemberMci_IDNO		= NULL,
			@Ac_First_NAME			= NULL,
			@Ac_Last_NAME			= NULL;

	DECLARE @Lc_CaseRelationshipNCP_CODE	CHAR(1) = 'A',
			@Lc_CaseRelationshipPF_CODE		CHAR(1) = 'P',
			@Lc_CaseMemberStatus_CODE		CHAR(1)	= 'A';

	 SELECT @An_MemberMci_IDNO	= b.MemberMci_IDNO, 
			@Ac_First_NAME		= b.First_NAME, 
			@Ac_Last_NAME		= b.Last_NAME
       FROM CMEM_Y1 a JOIN DEMO_Y1 b
         ON b.MemberMci_IDNO		= a.MemberMci_IDNO
      WHERE a.Case_IDNO				= @An_Case_IDNO
        AND a.CaseRelationship_CODE IN (@Lc_CaseRelationshipNCP_CODE ,@Lc_CaseRelationshipPF_CODE)
        AND a.CaseMemberStatus_CODE = @Lc_CaseMemberStatus_CODE;
           
END  --END OF DEMO_RETRIEVE_S137


GO
