/****** Object:  StoredProcedure [dbo].[CMEM_RETRIEVE_S214]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CMEM_RETRIEVE_S214] (
	 @An_Case_IDNO					NUMERIC(6,0),
     @Ac_File_ID					CHAR(10),
     @An_TransactionEventSeq_NUMB	NUMERIC(19,0)
     )
AS

/*
 *     PROCEDURE NAME    : CMEM_RETRIEVE_S214
 *     DESCRIPTION       : Retrieves NCP/PF Member MCI for the given Case_ID and File_ID combination whose status is Active.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 02-MAR-2011
 *     MODIFIED BY       :
 *     MODIFIED ON       :
 *     VERSION NO        : 1
*/
BEGIN

	DECLARE @Lc_RelationshipCaseNcp_CODE 		CHAR(1) = 'A',
			@Lc_RelationshipCasePutFather_CODE	CHAR(1) = 'P',
			@Lc_StatusCaseMemberActive_CODE 	CHAR(1) = 'A',
			@Ld_High_DATE						DATE	= '12/31/9999';

      SELECT M.MemberMci_IDNO
       FROM FDEM_Y1 F
      			JOIN CMEM_Y1 M
      				ON F.Case_IDNO = M.Case_IDNO
      			JOIN DPRS_Y1 D
      				ON F.File_ID = D.File_ID
      				AND M.MemberMci_IDNO = D.DocketPerson_IDNO
      WHERE F.File_ID = @Ac_File_ID
		AND F.Case_IDNO = @An_Case_IDNO
		AND F.EndValidity_DATE = @Ld_High_DATE
        AND F.TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB
        AND M.CaseRelationship_CODE IN ( @Lc_RelationshipCaseNcp_CODE, @Lc_RelationshipCasePutFather_CODE )
        AND M.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE
        AND D.EndValidity_DATE = @Ld_High_DATE
        AND D.EffectiveEnd_DATE = @Ld_High_DATE;


END; --END OF CMEM_RETRIEVE_S214


GO
