/****** Object:  StoredProcedure [dbo].[APDM_RETRIEVE_S23]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[APDM_RETRIEVE_S23](
 @An_Application_IDNO NUMERIC(15, 0),
 @Ai_RowFrom_NUMB     INT=1,
 @Ai_RowTo_NUMB       INT=10
 )
AS
 /*
  *     PROCEDURE NAME    : APDM_RETRIEVE_S23
  *     DESCRIPTION       : Retrieve case member informations for an Application IA.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 10-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT Y.Last_NAME,
         Y.First_NAME,
         Y.Middle_NAME,
         Y.CaseRelationship_CODE,
         Y.CpRelationshipToChild_CODE,
         Y.NcpRelationshipToChild_CODE,
         Y.PaternityEst_CODE,
         Y.FamilyViolence_INDC,
         Y.MemberSsn_NUMB,
         Y.Birth_DATE,
         Y.MemberSex_CODE,
         Y.Race_CODE,
         Y.MemberMci_IDNO,
         Y.CreateMemberMci_CODE,
         Y.RowCount_NUMB
    FROM (SELECT Last_NAME,
                 First_NAME,
                 Middle_NAME,
                 X.CaseRelationship_CODE,
                 X.CpRelationshipToChild_CODE,
                 X.NcpRelationshipToChild_CODE,
                 X.PaternityEst_CODE,
                 X.FamilyViolence_INDC,
                 X.MemberSsn_NUMB,
                 X.Birth_DATE,
                 X.MemberSex_CODE,
                 X.Race_CODE,
                 X.MemberMci_IDNO,
                 CreateMemberMci_CODE,
                 COUNT(1) OVER() AS RowCount_NUMB,
                 X.ORD_ROWNUM AS Row_Num
            FROM (SELECT A.Last_NAME,
                         A.First_NAME,
                         A.Middle_NAME,
                         A1.CaseRelationship_CODE,
                         A1.CpRelationshipToChild_CODE,
                         A1.NcpRelationshipToChild_CODE,
                         A.PaternityEst_CODE,
                         A1.FamilyViolence_INDC,
                         A.MemberSsn_NUMB,
                         A.Birth_DATE,
                         A.MemberSex_CODE,
                         A.Race_CODE,
                         A1.MemberMci_IDNO,
                         A1.CreateMemberMci_CODE,
                         ROW_NUMBER() OVER( ORDER BY A1.CaseRelationship_CODE, A1.CpRelationshipToChild_CODE) AS ORD_ROWNUM
                    FROM APDM_Y1 A
                         JOIN APCM_Y1 A1
                          ON (A.MemberMci_IDNO = A1.MemberMci_IDNO)
                         JOIN APCS_Y1 A2
                          ON (A.Application_IDNO = A2.Application_IDNO)
                   WHERE A2.Application_IDNO = @An_Application_IDNO
                     AND A1.Application_IDNO = @An_Application_IDNO
                     AND A.EndValidity_DATE = @Ld_High_DATE
                     AND A1.EndValidity_DATE = @Ld_High_DATE
                     AND A2.EndValidity_DATE = @Ld_High_DATE) AS X
           WHERE X.ORD_ROWNUM <= @Ai_RowTo_NUMB) AS Y
   WHERE Y.Row_Num >= @Ai_RowFrom_NUMB
   ORDER BY ROW_NUM;
 END; -- End Of APDM_RETRIEVE_S23

GO
