/****** Object:  StoredProcedure [dbo].[CASE_RETRIEVE_S74]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CASE_RETRIEVE_S74](
 @An_Case_IDNO                NUMERIC(6, 0),
 @Ac_ApplicationFee_CODE      CHAR(1) OUTPUT,
 @Ac_GoodCause_CODE           CHAR(1) OUTPUT,
 @Ac_RespondInit_CODE         CHAR(1) OUTPUT,
 @Ac_ServiceRequested_CODE    CHAR(1) OUTPUT,
 @Ac_StatusCase_CODE          CHAR(1) OUTPUT,
 @Ac_TypeCase_CODE            CHAR(1) OUTPUT,
 @Ac_MedicalOnly_INDC         CHAR(1) OUTPUT,
 @Ac_NonCoop_CODE             CHAR(1) OUTPUT,
 @Ad_AppReq_DATE              DATE OUTPUT,
 @Ad_AppRetd_DATE             DATE OUTPUT,
 @Ad_AppSent_DATE             DATE OUTPUT,
 @Ad_AppSigned_DATE           DATE OUTPUT,
 @Ad_AprvIvd_DATE             DATE OUTPUT,
 @Ad_FeePaid_DATE             DATE OUTPUT,
 @Ad_GoodCause_DATE           DATE OUTPUT,
 @Ad_NonCoop_DATE             DATE OUTPUT,
 @Ad_Opened_DATE              DATE OUTPUT,
 @Ad_Referral_DATE            DATE OUTPUT,
 @Ad_StatusCurrent_DATE       DATE OUTPUT,
 @Ad_Update_DTTM              DATETIME2 OUTPUT,
 @Ac_CaseCategory_CODE        CHAR(2) OUTPUT,
 @An_County_IDNO              NUMERIC(3, 0) OUTPUT,
 @Ac_RsnStatusCase_CODE       CHAR(2) OUTPUT,
 @Ac_SourceRfrl_CODE          CHAR(3) OUTPUT,
 @As_DescriptionComments_TEXT VARCHAR(200) OUTPUT,
 @An_Application_IDNO         NUMERIC(15, 0) OUTPUT,
 @Ac_File_ID                  CHAR(10) OUTPUT,
 @Ac_WorkerUpdate_ID          CHAR(30) OUTPUT,
 @Ac_IvdApplicant_CODE        CHAR(3) OUTPUT,
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0) OUTPUT,
 @Ac_StatusEnforce_CODE       CHAR(4) OUTPUT,
 @Ac_ReasonFeeWaived_CODE	  CHAR(2) OUTPUT,
 @Ac_FeeCheckNo_TEXT		  CHAR(20) OUTPUT
 
 )
AS
 /*  
  *     PROCEDURE NAME    : CASE_RETRIEVE_S74  
  *     DESCRIPTION       : Retrieve all Case details for a Case ID.  
  *     DEVELOPED BY      : IMP Team  
  *     DEVELOPED ON      : 20-SEP-2011  
  *     MODIFIED BY       :   
  *     MODIFIED ON       :   
  *     VERSION NO        : 1  
 */
 BEGIN
  SELECT @Ac_ApplicationFee_CODE = NULL,
	  @Ac_GoodCause_CODE = NULL,
	  @Ac_RespondInit_CODE = NULL,
	  @Ac_ServiceRequested_CODE = NULL,
	  @Ac_StatusCase_CODE = NULL,
	  @Ac_TypeCase_CODE = NULL,
	  @Ac_MedicalOnly_INDC = NULL,
	  @Ac_NonCoop_CODE = NULL,
	  @Ad_AppReq_DATE = NULL,
	  @Ad_AppRetd_DATE = NULL,
	  @Ad_AppSent_DATE = NULL,
	  @Ad_AppSigned_DATE = NULL,
	  @Ad_AprvIvd_DATE = NULL,
	  @Ad_FeePaid_DATE = NULL,
	  @Ad_GoodCause_DATE = NULL,
	  @Ad_NonCoop_DATE = NULL,
	  @Ad_Opened_DATE = NULL,
	  @Ad_Referral_DATE = NULL,
	  @Ad_StatusCurrent_DATE = NULL,
	  @Ad_Update_DTTM = NULL,
	  @Ac_CaseCategory_CODE = NULL,
	  @An_County_IDNO = NULL,
	  @Ac_RsnStatusCase_CODE = NULL,
	  @Ac_SourceRfrl_CODE = NULL,
	  @As_DescriptionComments_TEXT = NULL,
	  @An_Application_IDNO = NULL,
	  @Ac_File_ID = NULL,
	  @Ac_WorkerUpdate_ID = NULL,
	  @Ac_IvdApplicant_CODE = NULL,
	  @An_TransactionEventSeq_NUMB = NULL,
	  @Ac_StatusEnforce_CODE = NULL,
	  @Ac_ReasonFeeWaived_CODE	= NULL,
	  @Ac_FeeCheckNo_TEXT = NULL;	  

  SELECT @Ac_TypeCase_CODE = C.TypeCase_CODE,
         @Ad_Opened_DATE = C.Opened_DATE,
         @Ac_StatusCase_CODE = C.StatusCase_CODE,
         @Ad_StatusCurrent_DATE = C.StatusCurrent_DATE,
         @Ac_RsnStatusCase_CODE = C.RsnStatusCase_CODE,
         @Ac_File_ID = C.File_ID,
         @An_County_IDNO = C.County_IDNO,
         @Ac_SourceRfrl_CODE = C.SourceRfrl_CODE,
         @Ac_RespondInit_CODE = C.RespondInit_CODE,
         @Ac_MedicalOnly_INDC = C.MedicalOnly_INDC,
         @Ac_GoodCause_CODE = C.GoodCause_CODE,
         @Ad_AprvIvd_DATE = C.AprvIvd_DATE,
         @Ac_NonCoop_CODE = C.NonCoop_CODE,
         @Ad_NonCoop_DATE = C.NonCoop_DATE,
         @Ac_WorkerUpdate_ID = C.WorkerUpdate_ID,
         @Ad_Update_DTTM = C.Update_DTTM,
         @Ac_IvdApplicant_CODE = C.IvdApplicant_CODE,
         @Ad_AppReq_DATE = C.AppReq_DATE,
         @Ad_AppSent_DATE = C.AppSent_DATE,
         @Ad_AppRetd_DATE = C.AppRetd_DATE,
         @Ad_AppSigned_DATE = C.AppSigned_DATE,
         @As_DescriptionComments_TEXT = C.DescriptionComments_TEXT,
         @An_TransactionEventSeq_NUMB = C.TransactionEventSeq_NUMB,
         @Ad_GoodCause_DATE = C.GoodCause_DATE,
         @An_Application_IDNO = C.Application_IDNO,
         @Ac_CaseCategory_CODE = C.CaseCategory_CODE,
         @Ad_Referral_DATE = C.Referral_DATE,
         @Ac_ServiceRequested_CODE = C.ServiceRequested_CODE,
         @Ac_ApplicationFee_CODE = C.ApplicationFee_CODE,
         @Ad_FeePaid_DATE = C.FeePaid_DATE,
         @Ac_StatusEnforce_CODE = C.StatusEnforce_CODE,
         @Ac_ReasonFeeWaived_CODE = C.ReasonFeeWaived_CODE,
         @Ac_FeeCheckNo_TEXT = C.FeeCheckNo_Text         
    FROM CASE_Y1 C
   WHERE C.Case_IDNO = @An_Case_IDNO;
 END; -- End Of CASE_RETRIEVE_S74


GO
