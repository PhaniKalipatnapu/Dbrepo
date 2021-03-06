/****** Object:  StoredProcedure [dbo].[CMEM_RETRIEVE_S205]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CMEM_RETRIEVE_S205] (
 @An_MemberMci_IDNO NUMERIC(10, 0),
 @Ad_Birth_DATE     DATE,
 @Ac_Exists_INDC    CHAR(1) OUTPUT
 )
AS
 /*
 *     PROCEDURE NAME    : CMEM_RETRIEVE_S205
 *     DESCRIPTION       : Check Whether the child date of birth must be at least 12 years after the cp and the ncp’s date of birth.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 02-AUG-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Li_Year12_NUMB                 INT = 12,
          @Li_DateDifference_NUMB         INT = 0,
          @Lc_No_TEXT                     CHAR(1) = 'N',
          @Lc_Yes_TEXT                    CHAR(1) = 'Y',
          @Lc_CaseRelationshipD_CODE      CHAR(1) = 'D',
          @Lc_CaseRelationshipC_CODE      CHAR(1) = 'C',
          @Lc_CaseRelationshipA_CODE      CHAR(1) = 'A',
          @Lc_CaseRelationshipP_CODE      CHAR(1) = 'P',
          @Lc_StatusCaseO_CODE            CHAR(1) = 'O',
          @Lc_CaseMemberStatusA_CODE      CHAR(1) = 'A',          
          @Lc_RelationshipToChildMTR_CODE CHAR(3) = 'MTR',
          @Lc_RelationshipToChildFTR_CODE CHAR(3) = 'FTR',
          @Ld_low_DATE                    DATE = '01-JAN-0001',
          @Lc_Space_TEXT                  CHAR(1) = ' ';
          

  SET @Ac_Exists_INDC = @Lc_No_TEXT;

  SELECT TOP 1 @Ac_Exists_INDC = @Lc_Yes_TEXT
    FROM CMEM_Y1 C1,
         CMEM_Y1 C,
         CASE_Y1 C2,
         DEMO_Y1 D
   WHERE C1.MemberMci_IDNO = @An_MemberMci_IDNO
     AND C1.Case_IDNO = C.Case_IDNO
     AND C.Case_IDNO  = C2.Case_IDNO      
     AND C.MemberMci_IDNO = D.MemberMci_IDNO
     AND C2.StatusCase_CODE = @Lc_StatusCaseO_CODE  
     AND C1.CaseMemberStatus_CODE = @Lc_CaseMemberStatusA_CODE
     AND C.CaseMemberStatus_CODE  = @Lc_CaseMemberStatusA_CODE
     AND CASE WHEN 
                C1.CaseRelationship_CODE    = @Lc_CaseRelationshipD_CODE 
            AND( ( C.CaseRelationship_CODE = @Lc_CaseRelationshipC_CODE
                  AND C1.CpRelationshipToChild_CODE IN(@Lc_RelationshipToChildMTR_CODE,@Lc_RelationshipToChildFTR_CODE,@Lc_Space_TEXT )
                  ) 
				 OR 
				 (
				 C.CaseRelationship_CODE IN( @Lc_CaseRelationshipA_CODE,@Lc_CaseRelationshipP_CODE)
                  AND C1.NcpRelationshipToChild_CODE IN(@Lc_RelationshipToChildMTR_CODE,@Lc_RelationshipToChildFTR_CODE,@Lc_Space_TEXT )
				 )	
                )
           THEN 1
          ELSE 2
         END = CASE
                WHEN C1.CaseRelationship_CODE NOT IN (@Lc_CaseRelationshipC_CODE, @Lc_CaseRelationshipA_CODE, @Lc_CaseRelationshipP_CODE)
                 THEN 1
                WHEN 
                C.CaseRelationship_CODE   = @Lc_CaseRelationshipD_CODE 
                AND( ( C1.CaseRelationship_CODE = @Lc_CaseRelationshipC_CODE
                       AND C.CpRelationshipToChild_CODE IN(@Lc_RelationshipToChildMTR_CODE,@Lc_RelationshipToChildFTR_CODE,@Lc_Space_TEXT )
                     ) 
				 OR 
				 (
				 C1.CaseRelationship_CODE IN(@Lc_CaseRelationshipA_CODE,@Lc_CaseRelationshipP_CODE)
                  AND C.NcpRelationshipToChild_CODE IN(@Lc_RelationshipToChildMTR_CODE,@Lc_RelationshipToChildFTR_CODE,@Lc_Space_TEXT )
				 )	 
                ) THEN 2
               END
     AND ((C1.CaseRelationship_CODE = @Lc_CaseRelationshipD_CODE
           AND ((D.Birth_DATE > @Ad_Birth_DATE AND D.Birth_DATE<> @Ld_low_DATE) 
                 OR (D.Birth_DATE <= @Ad_Birth_DATE
                     AND DATEDIFF(D, DATEADD(YYYY, @Li_Year12_NUMB, D.Birth_DATE), @Ad_Birth_DATE) < @Li_DateDifference_NUMB)))
           OR(C.CaseRelationship_CODE = @Lc_CaseRelationshipD_CODE  
               AND ( (@Ad_Birth_DATE > D.Birth_DATE AND D.Birth_DATE<> @Ld_low_DATE) 
                     OR (@Ad_Birth_DATE <= D.Birth_DATE
                         AND DATEDIFF(D, DATEADD(YYYY, @Li_Year12_NUMB, @Ad_Birth_DATE), D.Birth_DATE) < @Li_DateDifference_NUMB))))
 END; --End of CMEM_RETRIEVE_S205

GO
