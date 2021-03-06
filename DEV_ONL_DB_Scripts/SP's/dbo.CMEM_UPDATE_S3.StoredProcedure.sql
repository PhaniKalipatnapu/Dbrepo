/****** Object:  StoredProcedure [dbo].[CMEM_UPDATE_S3]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CMEM_UPDATE_S3] (
 @An_Case_IDNO                NUMERIC(6, 0),
 @An_MemberMci_IDNO           NUMERIC(10, 0),
 @Ac_CaseRelationship_CODE    CHAR(1),
 @Ac_SignedOnWorker_ID        CHAR(30),
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0)
 )
AS
 /*
  *     PROCEDURE NAME    : CMEM_UPDATE_S3
  *     DESCRIPTION       : Update Case Members Relationship Code for the retrieved Case and Members Case Relation other than Dependant (D) and Custodial Parent (C).
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 10-MAy-2012
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Lc_CaseRelationshipCp_CODE CHAR(1) = 'C',
          @Lc_CaseRelationshipDp_CODE CHAR(1) = 'D',
          @Ld_Systemdatetime_DTTM     DATETIME2 = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
          @Lc_CaseMemberStatusActive_CODE CHAR(1) = 'A',
          @Ln_RowsAffected_NUMB       NUMERIC(10);

  UPDATE CMEM_Y1
     SET CaseRelationship_CODE = @Ac_CaseRelationship_CODE,
         BeginValidity_DATE = @Ld_Systemdatetime_DTTM,
         WorkerUpdate_ID = @Ac_SignedOnWorker_ID,
         TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB,
         Update_DTTM = @Ld_Systemdatetime_DTTM
  OUTPUT DELETED.Case_IDNO,
		 DELETED.MemberMci_IDNO,
		 DELETED.CaseRelationship_CODE,
		 DELETED.CaseMemberStatus_CODE,
		 DELETED.CpRelationshipToChild_CODE,
		 DELETED.NcpRelationshipToChild_CODE,
		 DELETED.BenchWarrant_INDC,
		 DELETED.ReasonMemberStatus_CODE,
		 DELETED.Applicant_CODE,
		 DELETED.BeginValidity_DATE,
		 DELETED.WorkerUpdate_ID,
		 DELETED.TransactionEventSeq_NUMB,
		 DELETED.Update_DTTM,
		 DELETED.FamilyViolence_DATE,
		 DELETED.FamilyViolence_INDC,
		 DELETED.TypeFamilyViolence_CODE
   WHERE Case_IDNO = @An_Case_IDNO
     AND MemberMci_IDNO = @An_MemberMci_IDNO
     AND CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
     AND CaseRelationship_CODE NOT IN (@Lc_CaseRelationshipDp_CODE, @Lc_CaseRelationshipCp_CODE);

  SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;

  SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB;
 END; -- END OF CMEM_UPDATE_S3


GO
