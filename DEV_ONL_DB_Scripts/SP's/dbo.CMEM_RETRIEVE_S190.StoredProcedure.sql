/****** Object:  StoredProcedure [dbo].[CMEM_RETRIEVE_S190]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[CMEM_RETRIEVE_S190] 
	(  
        @An_Case_IDNO		 NUMERIC(6,0) 
     )            
AS

/*
 *     PROCEDURE NAME    : CMEM_RETRIEVE_S190
 *     DESCRIPTION       : Retrieve Respondent Name If Pettioner is CP   
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 04-AUG-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
 */

   BEGIN

     DECLARE
      
         @Lc_RelationshipCaseNcp_CODE       CHAR(1) = 'A', 
         @Lc_RelationshipCasePutFather_CODE CHAR(1) = 'P', 
         @Lc_StatusCaseMemberActive_CODE    CHAR(1) = 'A';
        
         SELECT C.MemberMci_IDNO,
         		D.MemberSsn_NUMB,
				D.Last_NAME,
                D.First_NAME,
                D.Middle_NAME,
                D.Suffix_NAME,
                D.Birth_DATE                                         
               FROM CMEM_Y1 C 
               JOIN
               DEMO_Y1 D
               ON  C.MemberMci_IDNO=D.MemberMci_IDNO                                           
              WHERE C.Case_IDNO = @An_Case_IDNO                         
                AND C.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE
                AND C.CaseRelationship_CODE IN (@Lc_RelationshipCaseNcp_CODE,@Lc_RelationshipCasePutFather_CODE)  ;
               
                
END; -- END OF CMEM_RETRIEVE_S190


GO
