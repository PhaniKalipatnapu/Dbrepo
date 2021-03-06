/****** Object:  StoredProcedure [dbo].[CASE_UPDATE_S14]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[CASE_UPDATE_S14]
	(
	 @An_Case_IDNO					NUMERIC(6,0),
     @Ac_File_ID					CHAR(10),
     @Ac_SignedOnWorker_ID 			CHAR(30),
     @An_TransactionEventSeq_NUMB	NUMERIC(19,0)
     )
AS

/*
 *     PROCEDURE NAME    : CASE_UPDATE_S14
 *     DESCRIPTION       : Modify the File Number in case table.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 24-DEC-2011
 *     MODIFIED BY       :
 *     MODIFIED ON       :
 *     VERSION NO        : 1
*/
   BEGIN
		DECLARE @Ld_SystemDatetime_DTTM		DATETIME2	= dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
			    @Ln_RowsAffected_NUMB  		NUMERIC(10);

      UPDATE CASE_Y1
         SET File_ID                  = @Ac_File_ID,
         	 WorkerUpdate_ID          = @Ac_SignedonWorker_ID,
         	 BeginValidity_DATE       = @Ld_SystemDatetime_DTTM,
         	 TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB,
         	 Update_DTTM              = @Ld_SystemDatetime_DTTM
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
			 @Ld_SystemDatetime_DTTM AS EndValidity_DATE,
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
	  INTO HCASE_Y1 (Case_IDNO,
					 StatusCase_CODE,
					 TypeCase_CODE,
					 RsnStatusCase_CODE,
					 RespondInit_CODE,
					 SourceRfrl_CODE,
					 Opened_DATE,
					 Marriage_DATE,
					 Divorced_DATE,
					 StatusCurrent_DATE,
					 AprvIvd_DATE,
					 County_IDNO,
					 Office_IDNO,
					 AssignedFips_CODE,
					 GoodCause_CODE,
					 GoodCause_DATE,
					 Restricted_INDC,
					 MedicalOnly_INDC,
					 Jurisdiction_INDC,
					 IvdApplicant_CODE,
					 Application_IDNO,
					 AppSent_DATE,
					 AppReq_DATE,
					 AppRetd_DATE,
					 CpRelationshipToNcp_CODE,
					 Worker_ID,
					 AppSigned_DATE,
					 ClientLitigantRole_CODE,
					 DescriptionComments_TEXT,
					 NonCoop_CODE,
					 NonCoop_DATE,
					 BeginValidity_DATE,
					 EndValidity_DATE,
					 WorkerUpdate_ID,
					 TransactionEventSeq_NUMB,
					 Update_DTTM,
					 Referral_DATE,
					 CaseCategory_CODE,
					 File_ID,
					 ApplicationFee_CODE,
					 FeePaid_DATE,
					 ServiceRequested_CODE,
					 StatusEnforce_CODE,
					 FeeCheckNo_TEXT,
					 ReasonFeeWaived_CODE,
					 Intercept_CODE
    				)
      WHERE Case_IDNO = @An_Case_IDNO;
      
        SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;
     SELECT @Ln_RowsAffected_NUMB AS  RowsAffected_NUMB;

END; --END OF CASE_UPDATE_S14


GO
