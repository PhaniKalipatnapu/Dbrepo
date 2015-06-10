/****** Object:  StoredProcedure [dbo].[CMEM_RETRIEVE_S146]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CMEM_RETRIEVE_S146] ( 
     @An_Case_IDNO		 NUMERIC(6,0)               
)
AS
/*
 *     PROCEDURE NAME    : CMEM_RETRIEVE_S146
 *     DESCRIPTION       : This procedue returns the member id from CMEM_Y1 for case whose relation ship code is D.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 16-DEC-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
BEGIN
        DECLARE @Lc_RelationshipCaseDp_CODE     CHAR(1) = 'D', 
                @Lc_StatusCaseMemberActive_CODE CHAR(1) = 'A';
        
        SELECT a.MemberMci_IDNO,
               b.Last_NAME,  	   
               b.Suffix_NAME,
               b.First_NAME, 
               b.Middle_NAME 
          FROM CMEM_Y1  a 
			JOIN DEMO_Y1  b
            ON a.MemberMci_IDNO = b.MemberMci_IDNO  
        WHERE a.Case_IDNO = @An_Case_IDNO 
          AND a.CaseRelationship_CODE = @Lc_RelationshipCaseDp_CODE 
          AND a.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE         
        ORDER BY a.MemberMci_IDNO;
                  
END;--END OF CMEM_RETRIEVE_S146


GO
