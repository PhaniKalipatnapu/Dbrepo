/****** Object:  StoredProcedure [dbo].[CMEM_UPDATE_S2]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CMEM_UPDATE_S2] (
 @An_Case_IDNO                NUMERIC(6, 0),
 @Ac_CaseRelationship_CODE    CHAR(1),
 @Ac_SignedOnWorker_ID        CHAR(30),
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0)
 )
AS
 /*
  *     PROCEDURE NAME    : CMEM_UPDATE_S2
  *     DESCRIPTION       : Update Case Members table with Members Case Relation for the retrieved Case and Members Case Relation other than Dependant (D) and Custodial Parent (C).
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 08-SEP-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Lc_CaseRelationshipCp_CODE CHAR(1) = 'C',
          @Lc_CaseRelationshipDp_CODE CHAR(1) = 'D',
		  @Lc_CaseRelationshipGu_CODE CHAR(1) = 'G',
          @Ld_Systemdatetime_DTTM     DATETIME2 = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
		  @Lc_CaseMemberStatusActive_CODE CHAR(1) = 'A',
          @Ln_RowsAffected_NUMB       NUMERIC(10);

  UPDATE CMEM_Y1
     SET CaseRelationship_CODE = @Ac_CaseRelationship_CODE,
         BeginValidity_DATE = @Ld_Systemdatetime_DTTM,
         WorkerUpdate_ID = @Ac_SignedOnWorker_ID,
         TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB,
         Update_DTTM = @Ld_Systemdatetime_DTTM
  OUTPUT Deleted.Case_IDNO,
         Deleted.MemberMci_IDNO,
         Deleted.CaseRelationship_CODE,
         Deleted.CaseMemberStatus_CODE,
         Deleted.CpRelationshipToChild_CODE,
         Deleted.NcpRelationshipToChild_CODE,
         Deleted.BenchWarrant_INDC,
         Deleted.ReasonMemberStatus_CODE,
         Deleted.Applicant_CODE,
         Deleted.BeginValidity_DATE,
         @Ld_Systemdatetime_DTTM AS EndValidity_DATE,
         Deleted.WorkerUpdate_ID,
         Deleted.TransactionEventSeq_NUMB,
         Deleted.Update_DTTM,
         Deleted.FamilyViolence_DATE,
         Deleted.FamilyViolence_INDC,
         Deleted.TypeFamilyViolence_CODE
    INTO HCMEM_Y1
   WHERE Case_IDNO = @An_Case_IDNO
     AND CaseRelationship_CODE NOT IN (@Lc_CaseRelationshipDp_CODE, @Lc_CaseRelationshipCp_CODE, @Lc_CaseRelationshipGu_CODE)
	 AND CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE;

  SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;

  SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB;
 END; -- END OF CMEM_UPDATE_S2


GO
