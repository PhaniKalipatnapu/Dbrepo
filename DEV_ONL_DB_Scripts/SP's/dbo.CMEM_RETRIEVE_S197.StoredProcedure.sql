/****** Object:  StoredProcedure [dbo].[CMEM_RETRIEVE_S197]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CMEM_RETRIEVE_S197]  
(
     @An_MemberMci_IDNO     NUMERIC(10,0)       ,
     @An_Case_IDNO          NUMERIC(6,0)  OUTPUT  
)     
AS

/*
 *     PROCEDURE NAME    : CMEM_RETRIEVE_S197
 *     DESCRIPTION       : It Retrieve the Case id for the member cp. 
 *     DEVELOPED BY      : IMP Team  
 *     DEVELOPED ON      : 24-AUG-2011 
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/

BEGIN

    SET @An_Case_IDNO=NULL;

    DECLARE @Lc_CaseRelationshipCp_CODE     CHAR(1) = 'C', 
       	    @Lc_CaseMemberStatusActive_CODE CHAR(1) = 'A',
       	    @Lc_CaseStatusOpen_CODE			CHAR(1) = 'O';
        
    SELECT @An_Case_IDNO= C1.Case_IDNO
      FROM CMEM_Y1 C JOIN CASE_Y1 C1
           ON
           C.Case_IDNO =  C1.Case_IDNO
     WHERE C.MemberMci_IDNO = @An_MemberMci_IDNO 
       AND C.CaseRelationship_CODE = @Lc_CaseRelationshipCp_CODE 
       AND C.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
       AND C1.StatusCase_CODE=@Lc_CaseStatusOpen_CODE;
                  
END;--End Of CMEM_RETRIEVE_S197


GO
