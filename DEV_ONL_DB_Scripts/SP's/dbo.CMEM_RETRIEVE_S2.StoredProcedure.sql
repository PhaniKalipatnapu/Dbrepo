/****** Object:  StoredProcedure [dbo].[CMEM_RETRIEVE_S2]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CMEM_RETRIEVE_S2] (
 @An_Case_IDNO             NUMERIC(6),
 @Ad_Birth_DATE            DATE,
 @Ac_CaseRelationship_CODE CHAR(1),
 @Ac_RelationshipToChild_CODE CHAR(1),
 @Ac_Exists_INDC           CHAR(1) OUTPUT
 )
AS
 /*  
  *     PROCEDURE NAME    : CMEM_RETRIEVE_S2  
  *     DESCRIPTION       : Check Whether the child date of birth must be at least 12 years greater than cp and the ncp’s date of birth.  
  *     DEVELOPED BY      : IMP Team  
  *     DEVELOPED ON      : 02-AUG-2011  
  *     MODIFIED BY       :   
  *     MODIFIED ON       :   
  *     VERSION NO        : 1  
  */
 BEGIN
  DECLARE @Lc_No_TEXT                CHAR(1) = 'N',
          @Lc_Yes_TEXT               CHAR(1) = 'Y',
          @Lc_CaseRelationshipD_CODE CHAR(1) = 'D',
          @Lc_CaseRelationshipC_CODE CHAR(1) = 'C',
          @Lc_CaseRelationshipA_CODE CHAR(1) = 'A',
          @Lc_CaseRelationshipP_CODE CHAR(1) = 'P',
		  @Lc_RelationshipToChildB_CODE CHAR(1) = 'B',
		  @Lc_RelationshipToChildC_CODE CHAR(1) = 'C',
		  @Lc_RelationshipToChildA_CODE CHAR(1) = 'A',
		  @Li_DateDifference_NUMB         INT = 0,
          @Li_Twelve_NUMB            SMALLINT = 12;

  SET @Ac_Exists_INDC = @Lc_Yes_TEXT;

  SELECT @Ac_Exists_INDC = @Lc_No_TEXT
    FROM DEMO_Y1 A
         JOIN CMEM_Y1 A1
          ON (A.MemberMci_IDNO = A1.MemberMci_IDNO)
   WHERE A1.Case_IDNO = @An_Case_IDNO
     AND EXISTS (SELECT 1
                   FROM CMEM_Y1 A2
                  WHERE A1.Case_IDNO = A2.Case_IDNO
                     AND ( (@Ac_CaseRelationship_CODE = @Lc_CaseRelationshipD_CODE
							  AND @Ac_RelationshipToChild_CODE  = @Lc_RelationshipToChildB_CODE
                              AND A1.CaseRelationship_CODE IN (@Lc_CaseRelationshipC_CODE, @Lc_CaseRelationshipA_CODE, @Lc_CaseRelationshipP_CODE)                           
						      AND DATEDIFF(D, DATEADD(YYYY, @Li_Twelve_NUMB, A.Birth_DATE), @Ad_Birth_DATE) < @Li_DateDifference_NUMB
						     )
						  OR (@Ac_CaseRelationship_CODE = @Lc_CaseRelationshipD_CODE
							  AND @Ac_RelationshipToChild_CODE  = @Lc_RelationshipToChildC_CODE
							  AND A1.CaseRelationship_CODE = @Lc_CaseRelationshipC_CODE							  
							  AND DATEDIFF(D, DATEADD(YYYY, @Li_Twelve_NUMB, A.BIRTH_DATE), @Ad_Birth_DATE) < @Li_DateDifference_NUMB
							  )
						  OR (@Ac_CaseRelationship_CODE = @Lc_CaseRelationshipD_CODE  
							  AND @Ac_RelationshipToChild_CODE  = @Lc_RelationshipToChildA_CODE
							  AND A1.CaseRelationship_CODE IN (@Lc_CaseRelationshipA_CODE, @Lc_CaseRelationshipP_CODE)							  
							  AND DATEDIFF(D, DATEADD(YYYY, @Li_Twelve_NUMB, A.BIRTH_DATE), @Ad_Birth_DATE) < @Li_DateDifference_NUMB
							  )
                          OR (@Ac_CaseRelationship_CODE IN (@Lc_CaseRelationshipA_CODE, @Lc_CaseRelationshipP_CODE)
                              AND A1.CaseRelationship_CODE = @Lc_CaseRelationshipD_CODE
                              AND DATEDIFF(YY, @Ad_Birth_DATE, A.BIRTH_DATE) < @Li_Twelve_NUMB)));
 END; -- End Of CMEM_RETRIEVE_S2						

 
GO
