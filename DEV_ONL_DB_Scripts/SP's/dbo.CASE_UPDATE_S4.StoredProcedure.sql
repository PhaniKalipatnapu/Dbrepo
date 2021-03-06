/****** Object:  StoredProcedure [dbo].[CASE_UPDATE_S4]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CASE_UPDATE_S4] (
 @An_Case_IDNO                NUMERIC(6, 0),
 @Ac_RespondInit_CODE         CHAR(1),
 @Ac_SignedOnWorker_ID        CHAR(30),
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0)
 )
AS
 /*
 *      PROCEDURE NAME    : CASE_UPDATE_S4
  *     DESCRIPTION       : While Creating ISIN Record if a CASE is not an Intergovermental CASE then change the CASE to Intergovermental Case
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 04-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ln_RowsAffected_NUMB   NUMERIC(10),
          @Ld_Systemdatetime_DTTM DATETIME2= DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(); 

  UPDATE CASE_Y1 
     SET RespondInit_CODE = @Ac_RespondInit_CODE,
         BeginValidity_DATE = @Ld_Systemdatetime_DTTM,
         WorkerUpdate_ID = @Ac_SignedOnWorker_ID,
         TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB,
         Update_DTTM = @Ld_Systemdatetime_DTTM
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
 END; -- END OF CASE_UPDATE_S4

GO
