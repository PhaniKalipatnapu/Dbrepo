/****** Object:  StoredProcedure [dbo].[CMEM_RETRIEVE_S38]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CMEM_RETRIEVE_S38]  
     @An_Case_IDNO		 NUMERIC(6,0),
     @As_Member_NAME     VARCHAR(60) OUTPUT
AS

/*
*     PROCEDURE NAME    : CMEM_RETRIEVE_S38
 *     DESCRIPTION       : Gets the Member Name from Member Idno for the given Case Idno where Members Case Relation is Custodial Parent.
 *     DEVELOPED BY      : Imp Team
 *     DEVELOPED ON      : 02-MAR-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
BEGIN

      SET @As_Member_NAME = NULL;
      DECLARE
         @Ps_RelationshipCaseCp_CNST CHAR(1) = 'C';
        
        SELECT TOP 1 @As_Member_NAME = dbo.BATCH_COMMON_GETS$SF_GET_MEMBER_NAME(X.MemberMci_IDNO)
      FROM 
         (
            SELECT CM.MemberMci_IDNO, ROW_NUMBER() OVER(
               ORDER BY CM.CaseMemberStatus_CODE)  ORDERROW_NUMB
            FROM CMEM_Y1 CM
            WHERE CM.Case_IDNO = @An_Case_IDNO 
            AND CM.CaseRelationship_CODE = @Ps_RelationshipCaseCp_CNST
         )  AS X;
                  
END


GO
