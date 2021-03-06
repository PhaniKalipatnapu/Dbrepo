/****** Object:  StoredProcedure [dbo].[CMEM_RETRIEVE_S175]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CMEM_RETRIEVE_S175] (
 @An_Case_IDNO             NUMERIC(6, 0),
 @Ac_CaseRelationship_CODE CHAR(1)
 )
AS
 /*
  *     PROCEDURE NAME    : CMEM_RETRIEVE_S175
  *     DESCRIPTION       : Retrieve Active Member ID and Name for a Case ID and Case relationship code.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 10-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Li_Zero_NUMB                           SMALLINT = 0,
          @Lc_CaseRelationshipDependant_CODE      CHAR(1) = 'D',
          @Lc_CaseMemberStatusActive_CODE         CHAR(1) = 'A',
          @Lc_TypeDebtCs_CODE                     CHAR(2) = 'CS',
          @Lc_TypeDebtMs_CODE                     CHAR(2) = 'MS',
          @Ld_Highdate_DATE                       DATE = '12/31/9999';
          

  SELECT C.MemberMci_IDNO,
         D.First_Name,
         D.Middle_Name,
         D.Last_Name,
         D.Suffix_Name
    FROM CMEM_Y1 C
         JOIN DEMO_Y1 D
          ON (D.MemberMci_IDNO = C.MemberMci_IDNO)
   WHERE C.Case_IDNO = @An_Case_IDNO
     AND ((C.CaseRelationship_CODE = @Ac_CaseRelationship_CODE
           AND (C.CaseRelationship_CODE = @Lc_CaseRelationshipDependant_CODE
                AND EXISTS (SELECT 1
                              FROM OBLE_Y1 o
                             WHERE o.Case_IDNO = @An_Case_IDNO
                               AND o.MemberMci_IDNO = c.MemberMci_IDNO
                               AND o.EndValidity_DATE = @Ld_Highdate_DATE
                               AND dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME() BETWEEN o.BeginObligation_DATE AND EndObligation_DATE
                               AND o.TypeDebt_CODE IN (@Lc_TypeDebtCs_CODE, @Lc_TypeDebtMs_CODE)
                               AND o.Periodic_AMNT > @Li_Zero_NUMB)))
           OR (C.CaseRelationship_CODE = @Ac_CaseRelationship_CODE
               AND @Ac_CaseRelationship_CODE != @Lc_CaseRelationshipDependant_CODE))
     AND C.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE;
 END; --END OF CMEM_RETRIEVE_S175


GO
