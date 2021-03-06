/****** Object:  StoredProcedure [dbo].[OBLE_RETRIEVE_S30]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE  [dbo].[OBLE_RETRIEVE_S30]  
		(
		 @An_MemberMci_IDNO			NUMERIC(10,0),
		 @Ac_CaseRelationship_CODE  CHAR(1),
		 @Ac_Exists_INDC            CHAR(1)		OUTPUT
		)
AS

/*
 *     PROCEDURE NAME    : OBLE_RETRIEVE_S30
 *     DESCRIPTION       : This procedure is used to check the existance of obligation in OBLE_Y1 at member level and member case relation ship is P.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 15-DEC-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
   BEGIN

          SET @Ac_Exists_INDC  = 'N';

      DECLARE @Lc_RelationshipCasePutFather_CODE	CHAR(1) = 'P', 
			  @Lc_StatusCaseMemberActive_CODE		CHAR(1) = 'A', 
			  @Ld_High_DATE							DATE	= '12/31/9999';
        
        SELECT @Ac_Exists_INDC  = 'Y'
		  FROM OBLE_Y1  a 
		       JOIN 
		       CMEM_Y1 c
		    ON c.Case_IDNO = a.Case_IDNO 			
         WHERE c.MemberMci_IDNO = @An_MemberMci_IDNO 
           AND c.CaseRelationship_CODE IN ( @Ac_CaseRelationship_CODE, @Lc_RelationshipCasePutFather_CODE ) 
           AND c.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE  
           AND a.EndValidity_DATE = @Ld_High_DATE;
                  
END;--END OF OBLE_RETRIEVE_S30


GO
