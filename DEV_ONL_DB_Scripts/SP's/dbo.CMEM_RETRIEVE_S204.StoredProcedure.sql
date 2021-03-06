/****** Object:  StoredProcedure [dbo].[CMEM_RETRIEVE_S204]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CMEM_RETRIEVE_S204] (
 @An_Case_IDNO      NUMERIC(6),
 @An_MemberMci_IDNO NUMERIC(10) = NULL,
 @Ai_Count_QNTY     INT OUTPUT
 )
AS
 /*
   *     PROCEDURE NAME    : CMEM_RETRIEVE_S204
   *     DESCRIPTION       : Retrieve Indicator for an Case ID with Relation Ship CP or Dependent and Type Welfare is (A/F/J).
   *     DEVELOPED BY      : IMP Team
   *     DEVELOPED ON      : 11-JAN-2012
   *     MODIFIED BY       : 
   *     MODIFIED ON       : 
   *     VERSION NO        : 1
  */
 BEGIN
  SET @Ai_Count_QNTY = NULL;

  DECLARE @Lc_CaseRelationshipCp_CODE       CHAR(1) = 'C',
          @Lc_CaseRelationshipDp_CODE       CHAR(1) = 'D',
          @Lc_WelfareTypeNonFosterCare_CODE CHAR(1) = 'J',
          @Lc_WelfareTypeFosterCare_CODE    CHAR(1) = 'F',
          @Lc_WelfareTypeTanf_CODE          CHAR(1) = 'A';

  SELECT @Ai_Count_QNTY = COUNT(1)
    FROM CMEM_Y1 C
         JOIN MHIS_Y1 M
          ON C.Case_IDNO = M.Case_IDNO
             AND C.MemberMci_IDNO = M.MemberMci_IDNO
   WHERE C.MemberMci_IDNO = @An_MemberMci_IDNO
     AND C.Case_IDNO = @An_Case_IDNO 
     AND C.CaseRelationship_CODE IN (@Lc_CaseRelationshipCp_CODE, @Lc_CaseRelationshipDp_CODE)
     AND M.TypeWelfare_CODE IN (@Lc_WelfareTypeTanf_CODE, @Lc_WelfareTypeFosterCare_CODE, @Lc_WelfareTypeNonFosterCare_CODE);
 END;


GO
