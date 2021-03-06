/****** Object:  StoredProcedure [dbo].[CASE_RETRIEVE_S61]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CASE_RETRIEVE_S61]
	(
     @An_Case_IDNO				NUMERIC(6,0),
     @Ac_File_ID				CHAR(10),
     @Ac_StatusCase_CODE		CHAR(1)		  OUTPUT,
     @Ac_TypeCase_CODE			CHAR(1)       OUTPUT,
     @An_County_IDNO			NUMERIC(3)    OUTPUT,
     @Ac_County_NAME			CHAR(40)	  OUTPUT,
     @An_NcpMci_IDNO			NUMERIC(10)   OUTPUT,
     @Ac_Last_NAME				CHAR(20)	  OUTPUT,
     @Ac_First_NAME				CHAR(16)	  OUTPUT,
     @Ac_Middle_NAME			CHAR(20)	  OUTPUT,
     @Ac_Suffix_NAME			CHAR(4)		  OUTPUT,
     @An_NcpMemberSsn_NUMB		NUMERIC(9,0)  OUTPUT
    )
AS

/*
 *     PROCEDURE NAME    : CASE_RETRIEVE_S61
 *     DESCRIPTION       : This procedure returns the case member details to pop up in the header
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 02-FEB-2012
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
   BEGIN

      SELECT @Ac_StatusCase_CODE = NULL,
			 @Ac_TypeCase_CODE = NULL,
			 @An_County_IDNO = NULL,
			 @Ac_County_NAME = NULL,		
			 @An_NcpMci_IDNO = NULL,
			 @An_NcpMemberSsn_NUMB = NULL;
			
      DECLARE
         @Lc_CaseRelationshipCp_CODE		CHAR(1) = 'C', 
         @Lc_CaseRelationshipNcp_CODE		CHAR(1) = 'A', 
         @Lc_CaseRelationshipPF_CODE		CHAR(1) = 'P',         
         @Lc_StatusCaseMemberActive_CODE	CHAR(1) = 'A'; 
        
        
        SELECT  @An_NcpMci_IDNO  = c.MemberMci_IDNO, 
				@Ac_Last_NAME = f.Last_NAME,
				@Ac_First_NAME = f.First_NAME,
				@Ac_Middle_NAME = f.Middle_NAME,
				@Ac_Suffix_NAME = f.Suffix_NAME, 
				@An_NcpMemberSsn_NUMB = f.MemberSsn_NUMB, 
				@Ac_TypeCase_CODE = a.TypeCase_CODE, 
		    	@Ac_StatusCase_CODE = a.StatusCase_CODE, 
				@An_County_IDNO = a.County_IDNO,
				@Ac_County_NAME = O.County_NAME				
		FROM CASE_Y1  a 
             LEFT OUTER JOIN DCKT_Y1 b 
          ON b.County_IDNO = a.County_IDNO 
         AND b.File_ID = @Ac_File_ID
			 JOIN CMEM_Y1 c
		  ON c.Case_IDNO = a.Case_IDNO
			 JOIN CMEM_Y1 e
		  ON e.Case_IDNO = a.Case_IDNO 
             JOIN COPT_Y1 o
          ON o.County_IDNO = a.County_IDNO
			 JOIN DEMO_Y1 f
		  ON f.MemberMci_IDNO = c.MemberMci_IDNO
     WHERE  a.Case_IDNO = @An_Case_IDNO      
      AND   c.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPF_CODE )
      AND   c.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE 
      AND   e.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE 
      AND   e.CaseRelationship_CODE = @Lc_CaseRelationshipCp_CODE;
                  
END; --END OF CASE_RETRIEVE_S61 


GO
