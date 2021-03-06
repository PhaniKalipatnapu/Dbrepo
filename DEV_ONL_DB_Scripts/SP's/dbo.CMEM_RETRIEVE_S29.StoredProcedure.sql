/****** Object:  StoredProcedure [dbo].[CMEM_RETRIEVE_S29]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[CMEM_RETRIEVE_S29]  
(
     @An_Case_IDNO          NUMERIC(6)        ,
     @An_MemberMci_IDNO 	NUMERIC(10)       ,
     @Ac_Exists_INDC        CHAR(1) 	OUTPUT
     )
AS

/*
 *     PROCEDURE NAME    : CMEM_RETRIEVE_S29
 *     DESCRIPTION       : This sp is used to get the count of records present in the CMEM_Y1 table for the particular case id or member id.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 02-AUG-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
 */

   BEGIN

      DECLARE
         @Lc_CaseRelationshipDp_CODE 		CHAR(1) = 'D', 
         @Lc_CaseStatusMemberActive_CODE 	CHAR(1) = 'A',
         @Lc_Yes_TEXT                       CHAR(1) = 'Y',  
         @Lc_No_TEXT                        CHAR(1) = 'N';  
         
      SET @Ac_Exists_INDC    = @Lc_No_TEXT;
                                                    
      SELECT @Ac_Exists_INDC    = @Lc_Yes_TEXT
      FROM   CMEM_Y1 a
      WHERE  a.Case_IDNO             = @An_Case_IDNO 
      AND 	 a.MemberMci_IDNO        = @An_MemberMci_IDNO 
      AND	 a.CaseRelationship_CODE = @Lc_CaseRelationshipDp_CODE 
      AND	 a.CaseMemberStatus_CODE = @Lc_CaseStatusMemberActive_CODE;

                  
END   -- End of CMEM_RETRIEVE_S29;


GO
