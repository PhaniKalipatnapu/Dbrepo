/****** Object:  StoredProcedure [dbo].[ICAS_RETRIEVE_S2]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ICAS_RETRIEVE_S2] (
 @An_MemberMci_IDNO NUMERIC(10, 0)
 )
AS
 /*
  *     PROCEDURE NAME    : ICAS_RETRIEVE_S2
  *     DESCRIPTION       : Retrieve IVD Case, Interstate Case State, Petitioner Name and Respondent Name from Interstate Cases table for a Member in Case Members table who is an Active Custodial Parent (C) /  Non-Custodial Parent (A) / Putative Father (P) with an Open (O) Case in Interstate Cases table.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 10-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Lc_StatusOpen_CODE                CHAR(1) = 'O',
          @Lc_CaseRelationshipCp_CODE        CHAR(1) = 'C',
          @Lc_CaseRelationshipNcp_CODE       CHAR(1) = 'A',
          @Lc_CaseRelationshipPutFather_CODE CHAR(1) = 'P',
          @Lc_CaseMemberStatusActive_CODE    CHAR(1) = 'A',
          @Ld_High_DATE                      DATE = '12/31/9999';

  SELECT DISTINCT I.Case_IDNO,
                  I.IVDOutOfStateFips_CODE,
                  I.Respondent_NAME,
                  I.Petitioner_NAME
    FROM CMEM_Y1 C
         JOIN ICAS_Y1 I
          ON C.Case_IDNO = I.Case_IDNO
   WHERE C.MemberMci_IDNO = @An_MemberMci_IDNO
     AND C.CaseRelationship_CODE IN (@Lc_CaseRelationshipCp_CODE, @Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE)
     AND C.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
     AND I.Status_CODE = @Lc_StatusOpen_CODE
     AND I.EndValidity_DATE = @Ld_High_DATE;
 END; -- END of ICAS_RETRIEVE_S2


GO
