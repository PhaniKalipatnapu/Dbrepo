/****** Object:  StoredProcedure [dbo].[CMEM_RETRIEVE_S123]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CMEM_RETRIEVE_S123] (
 @An_Case_IDNO NUMERIC(6, 0)
 )
AS
 /*
  *     PROCEDURE NAME    : CMEM_RETRIEVE_S123
  *     DESCRIPTION       : Retrieve Child MCI Number,Name,DOB,SSN and Paternity Status Indicator for a given Case.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Lc_CaseRelationshipDependentD_CODE CHAR(1) = 'D',
          @Lc_CaseMemberStatusActiveA_CODE    CHAR(1) = 'A';

  SELECT c.MemberMci_IDNO,
         d.Last_NAME,
         d.Suffix_NAME,
         d.First_NAME,
         d.Middle_NAME,
         d.Birth_DATE,
         d.MemberSsn_NUMB,
         m.PaternityEst_INDC
    FROM CMEM_Y1 c
         JOIN DEMO_Y1 d
          ON d.MemberMci_IDNO = c.MemberMci_IDNO
         LEFT OUTER JOIN MPAT_Y1 m
          ON d.MemberMci_IDNO = m.MemberMci_IDNO
   WHERE c.Case_IDNO = @An_Case_IDNO
     AND c.CaseRelationship_CODE = @Lc_CaseRelationshipDependentD_CODE
     AND c.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActiveA_CODE;
 END; --End Of CMEM_RETRIEVE_S123

GO
