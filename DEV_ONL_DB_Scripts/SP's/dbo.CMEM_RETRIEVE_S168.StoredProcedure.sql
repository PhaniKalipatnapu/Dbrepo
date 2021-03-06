/****** Object:  StoredProcedure [dbo].[CMEM_RETRIEVE_S168]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CMEM_RETRIEVE_S168] (
 @An_Case_IDNO               NUMERIC(6, 0),
 @Ac_MemberCombinations_CODE CHAR(1),
 @Ai_Count_QNTY              INT OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : CMEM_RETRIEVE_S168
  *     DESCRIPTION       : Retrieve the Record Count for a Case and  Member Combinations Code, and Status of the Case Member is Active and Members Case Relation is CP/NCP/PF/DEP for the respective Member Combinations Code.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 26-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @Ai_Count_QNTY = NULL;

  DECLARE @Lc_CaseRelationshipCp_CODE        CHAR(1) = 'C',
          @Lc_CaseRelationshipDp_CODE        CHAR(1) = 'D',
          @Lc_CaseRelationshipNcp_CODE       CHAR(1) = 'A',
          @Lc_CaseRelationshipPutFather_CODE CHAR(1) = 'P',
          @Lc_StatusCaseMemberActive_CODE    CHAR(1) = 'A',
          @Lc_One_NUMB                       CHAR(1) = '1',
          @Lc_Two_NUMB                       CHAR(1) = '2',
          @Lc_Three_NUMB                     CHAR(1) = '3',
          @Lc_Four_NUMB                      CHAR(1) = '4',
          @Lc_Five_NUMB                      CHAR(1) = '5',
          @Lc_Six_NUMB                       CHAR(1) = '6',
          @Lc_Seven_NUMB                     CHAR(1) = '7';

  SELECT @Ai_Count_QNTY = COUNT (1)
    FROM CMEM_Y1 A
   WHERE A.Case_IDNO = @An_Case_IDNO
     AND A.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE
     AND ((A.CaseRelationship_CODE = @Lc_CaseRelationshipCp_CODE
           AND @Ac_MemberCombinations_CODE IN (@Lc_One_NUMB, @Lc_Three_NUMB, @Lc_Five_NUMB, @Lc_Seven_NUMB))
           OR (A.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE)
               AND @Ac_MemberCombinations_CODE IN (@Lc_Two_NUMB, @Lc_Three_NUMB, @Lc_Six_NUMB, @Lc_Seven_NUMB))
           OR (A.CaseRelationship_CODE = @Lc_CaseRelationshipDp_CODE
               AND @Ac_MemberCombinations_CODE IN (@Lc_Four_NUMB, @Lc_Five_NUMB, @Lc_Six_NUMB, @Lc_Seven_NUMB)));
 END; --END OF CMEM_RETRIEVE_S168



GO
