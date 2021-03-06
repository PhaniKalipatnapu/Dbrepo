/****** Object:  StoredProcedure [dbo].[CMEM_RETRIEVE_S20]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CMEM_RETRIEVE_S20] (
 @An_MemberMci_IDNO NUMERIC(10, 0),
 @Ai_Count_QNTY     INT OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : CMEM_RETRIEVE_S20
  *     DESCRIPTION       : Retrieve the count of records from Case Members table for the Active Member who is a Non-Custodial Parent (A) or Putative Father (P) whose Case does exist in Major Activity Diary table with Code with in the system for the Major Activity equal to Bench Warrant Processing (BWNT) / Financial Institution Data Match (FIDM) / Project Save Our Children - Federal Criminal Non-Support (PSOC) and Status of the Remedy equal to START (STRT).
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 06-SEP-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @Ai_Count_QNTY = NULL;

  DECLARE @Lc_CaseRelationshipNcp_CODE       CHAR(1) = 'A',
          @Lc_CaseRelationshipPutFather_CODE CHAR(1) = 'P',
          @Lc_CaseMemberStatusActive_CODE    CHAR(1) = 'A',
          @Lc_ActivityMajorFidm_CODE         CHAR(4) = 'FIDM',
          @Lc_ActivityMajorPsoc_CODE         CHAR(4) = 'PSOC',
          @Lc_StatusStart_CODE               CHAR(4) = 'STRT';

  SELECT @Ai_Count_QNTY = COUNT(1)
    FROM DMJR_Y1 j
         JOIN CMEM_Y1 m
          ON m.Case_IDNO = j.Case_IDNO
   WHERE m.MemberMci_IDNO = @An_MemberMci_IDNO
     AND m.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE)
     AND m.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
     AND j.ActivityMajor_CODE IN (@Lc_ActivityMajorFidm_CODE, @Lc_ActivityMajorPsoc_CODE)
     AND j.Status_CODE = @Lc_StatusStart_CODE;
 END; -- END OF  CMEM_RETRIEVE_S20


GO
