/****** Object:  StoredProcedure [dbo].[CMEM_INSERT_S1]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CMEM_INSERT_S1](
 @An_Case_IDNO                   NUMERIC(6, 0),
 @An_MemberMci_IDNO              NUMERIC(10, 0),
 @Ac_CaseRelationship_CODE       CHAR(1),
 @Ac_CaseMemberStatus_CODE       CHAR(1),
 @Ac_CpRelationshipToChild_CODE  CHAR(3),
 @Ac_NcpRelationshipToChild_CODE CHAR(3),
 @Ac_BenchWarrant_INDC           CHAR(1),
 @Ac_ReasonMemberStatus_CODE     CHAR(2),
 @Ac_Applicant_CODE              CHAR(1),
 @Ac_SignedOnWorker_ID           CHAR(30),
 @An_TransactionEventSeq_NUMB    NUMERIC(19, 0),
 @Ad_FamilyViolence_DATE         DATE,
 @Ac_FamilyViolence_INDC         CHAR(1),
 @Ac_TypeFamilyViolence_CODE     CHAR(2)
 )
AS
 /*
 *     PROCEDURE NAME    : CMEM_INSERT_S1
  *     DESCRIPTION       : Insert all Case Member details along with Members Case Relation Dependent and Case Member Status Active.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-NOV-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ld_Systemdatetime_DTTM DATETIME2 = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
		  @Lc_CaseRelGuardian_CODE CHAR(1) = 'G',
		  @Lc_MemberStatus_CODE CHAR(1) = 'A';

  INSERT CMEM_Y1
         (Case_IDNO,
          MemberMci_IDNO,
          CaseRelationship_CODE,
          CaseMemberStatus_CODE,
          CpRelationshipToChild_CODE,
          NcpRelationshipToChild_CODE,
          BenchWarrant_INDC,
          ReasonMemberStatus_CODE,
          Applicant_CODE,
          BeginValidity_DATE,
          WorkerUpdate_ID,
          TransactionEventSeq_NUMB,
          Update_DTTM,
          FamilyViolence_DATE,
          FamilyViolence_INDC,
          TypeFamilyViolence_CODE)
  SELECT   @An_Case_IDNO,
           @An_MemberMci_IDNO,
           @Ac_CaseRelationship_CODE,
           @Ac_CaseMemberStatus_CODE,
           @Ac_CpRelationshipToChild_CODE,
           @Ac_NcpRelationshipToChild_CODE,
           @Ac_BenchWarrant_INDC,
           @Ac_ReasonMemberStatus_CODE,
           @Ac_Applicant_CODE,
           @Ld_Systemdatetime_DTTM,
           @Ac_SignedOnWorker_ID,
           @An_TransactionEventSeq_NUMB,
           @Ld_Systemdatetime_DTTM,
           @Ad_FamilyViolence_DATE,
           @Ac_FamilyViolence_INDC,
           @Ac_TypeFamilyViolence_CODE
           WHERE   NOT EXISTS (SELECT 1 FROM CMEM_Y1  A WITH (Readuncommitted )   
           WHERE Case_IDNO=@An_Case_IDNO AND CaseRelationship_CODE = @Lc_CaseRelGuardian_CODE AND  CaseMemberStatus_CODE = @Lc_MemberStatus_CODE);
 END; --End of CMEM_INSERT_S1

GO
