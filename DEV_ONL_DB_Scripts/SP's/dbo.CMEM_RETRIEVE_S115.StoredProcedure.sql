/****** Object:  StoredProcedure [dbo].[CMEM_RETRIEVE_S115]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CMEM_RETRIEVE_S115](
 @An_Case_IDNO NUMERIC(6, 0)
 )
AS
 /*
  *     PROCEDURE NAME    : CMEM_RETRIEVE_S115
  *     DESCRIPTION       : Combine the Result set of the below. Retrieve Member ID and Dependent Name from Member Demographics for the Case ID, Member Case Relationship is Dependent and Case Member Status is Active. Retrieve Member ID and Dependent Name from Member Demographics Archive for the Case ID, Member Case Relationship is Dependent and Case Member Status is Active.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-NOV-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Lc_RelationshipCaseDp_CODE     CHAR(1) = 'D',
          @Lc_StatusCaseMemberActive_CODE CHAR(1) = 'A';

  SELECT C.MemberMci_IDNO,
         D.Last_NAME,
         D.First_NAME,
         D.Middle_NAME
    FROM CMEM_Y1 C
         JOIN DEMO_Y1 D
          ON (D.MemberMci_IDNO = C.MemberMci_IDNO)
   WHERE C.Case_IDNO = @An_Case_IDNO
     AND C.CaseRelationship_CODE = @Lc_RelationshipCaseDp_CODE
     AND C.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE;
 END; --End of CMEM_RETRIEVE_S115

GO
