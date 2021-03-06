/****** Object:  StoredProcedure [dbo].[HCASE_INSERT_S4]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[HCASE_INSERT_S4]    
( 
   	@An_Case_IDNO		        NUMERIC(6,0),
	@Ac_Restricted_INDC			CHAR(1)  
)          
AS  
  
  /*
   *     PROCEDURE NAME    : HCASE_INSERT_S4
   *     DESCRIPTION       : Inserts the Case details into History. 
   *     DEVELOPED BY      : IMP Team
   *     DEVELOPED ON      : 10/13/2011
   *     MODIFIED BY       :   
   *     MODIFIED ON       :
   *     VERSION NO        : 1
  */  
	BEGIN  
	
	DECLARE
		@Ld_Systemdate_DATE DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
		@Ld_Systemdatetime_DTTM DATETIME2 = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
		
	INSERT 	HCASE_Y1(  
			 Case_IDNO,   
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
			 Intercept_CODE)  
	SELECT A.Case_IDNO, 
		A.StatusCase_CODE, 
		A.TypeCase_CODE, 
		A.RsnStatusCase_CODE, 
		A.RespondInit_CODE, 
		A.SourceRfrl_CODE, 
		A.Opened_DATE, 
		A.Marriage_DATE, 
		A.Divorced_DATE, 
		A.StatusCurrent_DATE, 
		A.AprvIvd_DATE, 
		A.County_IDNO, 
		A.Office_IDNO, 
		A.AssignedFips_CODE, 
		A.GoodCause_CODE, 
		A.GoodCause_DATE, 
		A.Restricted_INDC, 
		A.MedicalOnly_INDC, 
		A.Jurisdiction_INDC, 
		A.IvdApplicant_CODE, 
		A.Application_IDNO, 
		A.AppSent_DATE, 
		A.AppReq_DATE, 
		A.AppRetd_DATE, 
		A.CpRelationshipToNcp_CODE, 
		A.Worker_ID, 
		A.AppSigned_DATE, 
		A.ClientLitigantRole_CODE, 
		A.DescriptionComments_TEXT, 
		A.NonCoop_CODE, 
		A.NonCoop_DATE, 
		A.BeginValidity_DATE, 
		@Ld_Systemdate_DATE,
		A.WorkerUpdate_ID, 
		A.TransactionEventSeq_NUMB, 
		@Ld_Systemdatetime_DTTM, 
		A.Referral_DATE, 
		A.CaseCategory_CODE, 
		A.File_ID, 
		A.ApplicationFee_CODE, 
		A.FeePaid_DATE, 
		A.ServiceRequested_CODE,
		A.StatusEnforce_CODE,			  
		A.FeeCheckNo_TEXT,		
		A.ReasonFeeWaived_CODE,
		A.Intercept_CODE
	FROM CASE_Y1 A
	WHERE A.Case_IDNO = @An_Case_IDNO
   	AND A.Restricted_INDC <> @Ac_Restricted_INDC; 
  
                    
END  
  
  



GO
