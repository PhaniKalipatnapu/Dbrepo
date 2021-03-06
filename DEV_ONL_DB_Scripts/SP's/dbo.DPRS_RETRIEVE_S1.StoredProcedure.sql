/****** Object:  StoredProcedure [dbo].[DPRS_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[DPRS_RETRIEVE_S1]( 
	@An_Case_IDNO		NUMERIC(6),
	@Ac_File_ID			CHAR(10)
	)   
AS

/*
 *     PROCEDURE NAME    : DPRS_RETRIEVE_S1
 *     DESCRIPTION       : Retrieve common Docket persons between File ID and Case ID.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 10-AUG-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/

   BEGIN
      DECLARE
         @Lc_CaseMemberStatusActive_CODE	CHAR(1) = 'A', 
         @Lc_CaseRelationshipA_CODE			CHAR(1) = 'A',
		 @Lc_CaseRelationshipC_CODE			CHAR(1) = 'C',
		 @Lc_CaseRelationshipP_CODE			CHAR(1) = 'P',
		 @Lc_CaseRelationshipD_CODE			CHAR(1) = 'D',
		 @Lc_TypePersonChild_CODE			CHAR(2) = 'CI',
		 @Lc_TypePersonCp_CODE				CHAR(2) = 'CP',
		 @Lc_TypePersonNcp_CODE				CHAR(3) = 'NCP',
		 @Ld_High_DATE 						DATE	= '12/31/9999';
	  DECLARE
		 @Ld_Current_DATE					DATE	= DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

         SELECT a.DocketPerson_IDNO, 
                a.TypePerson_CODE
            FROM DPRS_Y1  a
               	JOIN CMEM_Y1  c
               		ON c.Case_IDNO = @An_Case_IDNO
               	   AND c.MemberMci_IDNO = a.DocketPerson_IDNO
               	   AND c.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE 
            WHERE a.File_ID = @Ac_File_ID 
              AND @Ld_Current_DATE BETWEEN a.EffectiveStart_DATE AND a.EffectiveEnd_DATE
              AND a.EndValidity_DATE = @Ld_High_DATE
              AND a.TypePerson_CODE IN (@Lc_TypePersonCp_CODE, @Lc_TypePersonNcp_CODE, @Lc_TypePersonChild_CODE )
              AND a.TypePerson_CODE =  CASE c.CaseRelationship_CODE 
											WHEN @Lc_CaseRelationshipD_CODE THEN @Lc_TypePersonChild_CODE
											WHEN @Lc_CaseRelationshipC_CODE THEN @Lc_TypePersonCp_CODE
											WHEN @Lc_CaseRelationshipA_CODE THEN @Lc_TypePersonNcp_CODE
											WHEN @Lc_CaseRelationshipP_CODE THEN @Lc_TypePersonNcp_CODE END;
                    

                  
END; --END OF DPRS_RETRIEVE_S14


GO
