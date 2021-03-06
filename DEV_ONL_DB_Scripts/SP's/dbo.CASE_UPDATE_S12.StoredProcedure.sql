/****** Object:  StoredProcedure [dbo].[CASE_UPDATE_S12]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CASE_UPDATE_S12](
 @An_Case_IDNO                NUMERIC(6, 0),
 @Ac_StatusCase_CODE          CHAR(1),
 @Ac_TypeCase_CODE            CHAR(1),
 @Ac_RsnStatusCase_CODE       CHAR(2),
 @Ac_RespondInit_CODE         CHAR(1),
 @Ac_SourceRfrl_CODE          CHAR(3),
 @Ad_Opened_DATE              DATE,
 @Ad_StatusCurrent_DATE       DATE,
 @An_County_IDNO              NUMERIC(3, 0),
 @Ac_GoodCause_CODE           CHAR(1),
 @Ad_GoodCause_DATE           DATE,
 @Ac_MedicalOnly_INDC         CHAR(1),
 @Ac_IvdApplicant_CODE        CHAR(3),
 @An_Application_IDNO         NUMERIC(15, 0),
 @Ad_AppSent_DATE             DATE,
 @Ad_AppReq_DATE              DATE,
 @Ad_AppRetd_DATE             DATE,
 @Ad_AppSigned_DATE           DATE,
 @As_DescriptionComments_TEXT VARCHAR(200),
 @Ac_NonCoop_CODE             CHAR(1),
 @Ad_NonCoop_DATE             DATE,
 @Ac_SignedOnWorker_ID        CHAR(30),
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0),
 @Ad_Referral_DATE            DATE,
 @Ac_CaseCategory_CODE        CHAR(2),
 @Ac_ApplicationFee_CODE      CHAR(1),
 @Ad_FeePaid_DATE             DATE,
 @Ac_ServiceRequested_CODE    CHAR(1),
 @Ac_StatusEnforce_CODE       CHAR(4),
 @Ac_FeeCheckNo_TEXT          CHAR(20),
 @Ac_ReasonFeeWaived_CODE     CHAR(2)
 )
AS
 /*
 *     PROCEDURE NAME    : CASE_UPDATE_S12
  *     DESCRIPTION       : Update the Worker Idno, the Worker Id who created/modified this record, Transaction sequence, Begin Validity Date and effective Date with Time at which this record was inserted / modified in this table to system date for a Case Idno.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-NOV-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ld_Systemdatetime_DTTM DATETIME2(0) = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
          @Ln_RowsAffected_NUMB   NUMERIC(10);

  UPDATE CASE_Y1
     SET StatusCase_CODE = @Ac_StatusCase_CODE,
         TypeCase_CODE = @Ac_TypeCase_CODE,
         RsnStatusCase_CODE = @Ac_RsnStatusCase_CODE,
         RespondInit_CODE = @Ac_RespondInit_CODE,
         SourceRfrl_CODE = @Ac_SourceRfrl_CODE,
         Opened_DATE = @Ad_Opened_DATE,
         StatusCurrent_DATE = @Ad_StatusCurrent_DATE,
         County_IDNO = @An_County_IDNO,
         GoodCause_CODE = @Ac_GoodCause_CODE,
         GoodCause_DATE = @Ad_GoodCause_DATE,
         MedicalOnly_INDC = @Ac_MedicalOnly_INDC,
         IvdApplicant_CODE = @Ac_IvdApplicant_CODE,
         Application_IDNO = @An_Application_IDNO,
         AppSent_DATE = @Ad_AppSent_DATE,
         AppReq_DATE = @Ad_AppReq_DATE,
         AppRetd_DATE = @Ad_AppRetd_DATE,
         AppSigned_DATE = @Ad_AppSigned_DATE,
         DescriptionComments_TEXT = @As_DescriptionComments_TEXT,
         NonCoop_CODE = @Ac_NonCoop_CODE,
         NonCoop_DATE = @Ad_NonCoop_DATE,
         BeginValidity_DATE = @Ld_Systemdatetime_DTTM,
         WorkerUpdate_ID = @Ac_SignedOnWorker_ID,
         TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB,
         Update_DTTM = @Ld_Systemdatetime_DTTM,
         Referral_DATE = @Ad_Referral_DATE,
         CaseCategory_CODE = @Ac_CaseCategory_CODE,
         ApplicationFee_CODE = @Ac_ApplicationFee_CODE,
         FeePaid_DATE = @Ad_FeePaid_DATE,
         ServiceRequested_CODE = @Ac_ServiceRequested_CODE,
         StatusEnforce_CODE = @Ac_StatusEnforce_CODE,
         FeeCheckNo_TEXT = @Ac_FeeCheckNo_TEXT,
         ReasonFeeWaived_CODE = @Ac_ReasonFeeWaived_CODE
	  OUTPUT Deleted.Case_IDNO,
         Deleted.StatusCase_CODE,
         Deleted.TypeCase_CODE,
         Deleted.RsnStatusCase_CODE,
         Deleted.RespondInit_CODE,
         Deleted.SourceRfrl_CODE,
         Deleted.Opened_DATE,
         Deleted.Marriage_DATE,
         Deleted.Divorced_DATE,
         Deleted.StatusCurrent_DATE,
         Deleted.AprvIvd_DATE,
         Deleted.County_IDNO,
         Deleted.Office_IDNO,
         Deleted.AssignedFips_CODE,
         Deleted.GoodCause_CODE,
         Deleted.GoodCause_DATE,
         Deleted.Restricted_INDC,
         Deleted.MedicalOnly_INDC,
         Deleted.Jurisdiction_INDC,
         Deleted.IvdApplicant_CODE,
         Deleted.Application_IDNO,
         Deleted.AppSent_DATE,
         Deleted.AppReq_DATE,
         Deleted.AppRetd_DATE,
         Deleted.CpRelationshipToNcp_CODE,
         Deleted.Worker_ID,
         Deleted.AppSigned_DATE,
         Deleted.ClientLitigantRole_CODE,
         Deleted.DescriptionComments_TEXT,
         Deleted.NonCoop_CODE,
         Deleted.NonCoop_DATE,
         Deleted.BeginValidity_DATE,
         @Ld_Systemdatetime_DTTM AS EndValidity_DATE,
         Deleted.WorkerUpdate_ID,
         Deleted.TransactionEventSeq_NUMB,
         Deleted.Update_DTTM,
         Deleted.Referral_DATE,
         Deleted.CaseCategory_CODE,
         Deleted.File_ID,
         Deleted.ApplicationFee_CODE,
         Deleted.FeePaid_DATE,
         Deleted.ServiceRequested_CODE,
         Deleted.StatusEnforce_CODE,
         Deleted.FeeCheckNo_TEXT,
         Deleted.ReasonFeeWaived_CODE,
         Deleted.Intercept_CODE
    INTO HCASE_Y1
   WHERE Case_IDNO = @An_Case_IDNO;

  SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;

  SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB;
 END; --End of CASE_UPDATE_S12


GO
