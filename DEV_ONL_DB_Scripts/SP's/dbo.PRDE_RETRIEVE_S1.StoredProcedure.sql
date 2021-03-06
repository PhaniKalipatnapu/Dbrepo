/****** Object:  StoredProcedure [dbo].[PRDE_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[PRDE_RETRIEVE_S1](
 @An_CaseWelfare_IDNO         NUMERIC(10,0),
 @An_AgSequence_NUMB          NUMERIC(4,0), 
 @An_TransactionEventSeq_NUMB NUMERIC(19,0),
 @Ac_CaseRelationship_CODE    CHAR(1)
)     
AS

/*
 *     PROCEDURE NAME    : PRDE_RETRIEVE_S1
 *     DESCRIPTION       : Retrieve iV-A case member details.
 *     DEVELOPED BY      : IMP Team 
 *     DEVELOPED ON      : 02-FEB-2012
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
BEGIN
	 DECLARE	@Lc_RelationshipCaseCp_CODE        CHAR(1) = 'C',
				@Lc_RelationshipCaseNcp_CODE       CHAR(1) = 'A',
				@Lc_RelationshipCasePutFather_CODE CHAR(1) = 'P',
				@Lc_RelationshipCaseDep_CODE       CHAR(1) = 'D';

	 SELECT A.Program_CODE,
	        A.SubProgram_CODE,
            A.MemberElig_DATE,
			A.MemberMci_IDNO,
	        A.First_NAME,
	        A.Middle_NAME,
	        A.Last_NAME,
	        A.Suffix_NAME,
			A.Birth_DATE,
			A.MemberSsn_NUMB,
			A.MemberSex_CODE,
			A.Race_CODE,
			A.ChildPaternityStatus_CODE,
            A.CpRelationshipToChild_CODE,
            A.NcpRelationshipToChild_CODE,
			B.Line1_ADDR,	
            B.Line2_ADDR,	
            B.City_ADDR,
            B.State_ADDR,	
            B.Zip_ADDR
      FROM PRDE_Y1 A
	       LEFT OUTER JOIN 
	       PRAH_Y1 B
	       ON ( A.CaseWelfare_IDNO=B.CaseWelfare_IDNO 
				AND A.MemberMci_IDNO=B.MemberMci_IDNO 
				AND A.ReferralReceived_DATE = B.ReferralReceived_DATE )    
     WHERE A.CaseWelfare_IDNO =@An_CaseWelfare_IDNO
       AND A.AgSequence_NUMB=@An_AgSequence_NUMB
	   AND A.TransactionEventSeq_NUMB = ISNULL(@An_TransactionEventSeq_NUMB,A.TransactionEventSeq_NUMB)
       AND ((@Ac_CaseRelationship_CODE = @Lc_RelationshipCaseCp_CODE AND A.CaseRelationship_CODE = @Lc_RelationshipCaseCp_CODE)
			OR (@Ac_CaseRelationship_CODE IN (@Lc_RelationshipCaseNcp_CODE, @Lc_RelationshipCasePutFather_CODE) 
				AND A.CaseRelationship_CODE IN (@Lc_RelationshipCaseNcp_CODE, @Lc_RelationshipCasePutFather_CODE))
			OR (@Ac_CaseRelationship_CODE = @Lc_RelationshipCaseDep_CODE AND A.CaseRelationship_CODE = @Lc_RelationshipCaseDep_CODE));
				                   
END; --End of PRDE_RETRIEVE_S1


GO
