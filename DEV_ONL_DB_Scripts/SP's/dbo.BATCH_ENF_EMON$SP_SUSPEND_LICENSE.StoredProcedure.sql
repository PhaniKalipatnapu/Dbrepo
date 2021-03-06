/****** Object:  StoredProcedure [dbo].[BATCH_ENF_EMON$SP_SUSPEND_LICENSE]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
  
/*  
--------------------------------------------------------------------------------------------------------------------  
Program Name		: BATCH_ENF_EMON$SP_SUSPEND_LICENSE    
Programmer Name		: IMP Team  
Description			: This procedure is used to update the license status(Suspend Status)  
Frequency			:     
Developed On		: 01/05/2012  
Called By			: BATCH_ENF_EMON$SP_SYSTEM_UPDATE    
Called Procedures	:     
Modified By			:    
Modified On			:    
Version No			: 1.0  
--------------------------------------------------------------------------------------------------------------------  
*/  
CREATE PROCEDURE [dbo].[BATCH_ENF_EMON$SP_SUSPEND_LICENSE]  
 @An_MemberMci_IDNO				NUMERIC(10),	
 @An_OthpSource_IDNO			NUMERIC(10),  
 @Ac_Reference_ID				CHAR(30),
 @Ac_TypeReference_CODE			CHAR(4),  
 @Ac_SignedonWorker_ID			CHAR(30),  
 @Ac_WorkerUpdate_ID			CHAR(30),
 @An_TransactionEventSeq_NUMB	NUMERIC(19) ,  
 @Ad_Run_DATE					DATE,  
 @Ac_Msg_CODE					CHAR(5) OUTPUT,  
 @As_DescriptionError_TEXT		VARCHAR(4000) OUTPUT  
AS  
  DECLARE  @Lc_StatusSuccess_CODE			CHAR(1)		= 'S',
           @Lc_Space_TEXT					CHAR(1)		= ' ',
           @Lc_StatusFailed_CODE			CHAR(1)		= 'F',
           @Lc_LicenseStatusActive_CODE		CHAR(1)		= 'A',
           @Lc_LicenseStatusInactive_CODE	CHAR(1)		= 'I',
           @Ls_Procedure_NAME				VARCHAR(35) = 'BATCH_ENF_EMON$SP_SUSPEND_LICENSE',
           @Ld_High_DATE					DATE		= '12/31/9999',
           @Ld_Low_DATE						DATE		= '01/01/0001',
           @Ld_Current_DTTM					DATETIME	= dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
  DECLARE  @Ln_Error_NUMB					NUMERIC(10),
		   @Ln_ErrorLine_NUMB				NUMERIC(10),
		   @Ls_Sql_TEXT						VARCHAR(50)	= '',
           @Ls_SqlData_TEXT					VARCHAR(400)= '';
  
 BEGIN  
  BEGIN TRY    
      /* @Ac_SignedonWorker_ID value passed from the online screens*/
   IF (LTRIM(RTRIM(@Ac_SignedonWorker_ID)) IS NOT NULL)
       OR (LTRIM(RTRIM(@Ac_SignedonWorker_ID)) != '')
    BEGIN
     SET @Ac_WorkerUpdate_ID = @Ac_SignedonWorker_ID;
    END
    ELSE
		BEGIN
			SET @Ac_SignedonWorker_ID = @Ac_WorkerUpdate_ID;
		END
    
		
  
   SET @Ls_SqlData_TEXT = ' MemberMci_IDNO :' + CAST(@An_MemberMci_IDNO AS CHAR(10)) + 
						  ' LicenseStatus_CODE :' + @Lc_LicenseStatusActive_CODE + 
						  ' TypeLicense_CODE :' + @Ac_TypeReference_CODE +
						  ' LicenseNo_TEXT :' + @Ac_Reference_ID + 
						  ' TransactionEventSeq_NUMB :' + CAST(@An_TransactionEventSeq_NUMB AS CHAR(19)) + 
						  ' SuspLicense_DATE :' + CAST (@Ad_Run_DATE AS VARCHAR)  + 
						  ' WorkerUpdate_ID :' + @Ac_WorkerUpdate_ID;  
						  
						  
  
  SET @Ls_Sql_TEXT = 'LICENSE STATUS INACTIVE';    
  
  IF EXISTS (SELECT 1 
			  FROM PLIC_Y1 p WITH(READUNCOMMITTED) 
				WHERE p.MemberMci_IDNO  = @An_MemberMci_IDNO 
				  AND p.OthpLicAgent_IDNO = @An_OthpSource_IDNO  
				  AND p.LicenseNo_TEXT = @Ac_Reference_ID
				  AND p.TypeLicense_CODE = @Ac_TypeReference_CODE  
				  AND p.EndValidity_DATE = @Ld_High_DATE  
				  AND p.LicenseStatus_CODE = @Lc_LicenseStatusInactive_CODE)
				  

	BEGIN
		SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;  
		SET @As_DescriptionError_TEXT = @Lc_Space_TEXT; 
		RETURN;
	END				  
     
   SET @Ls_Sql_TEXT = 'EMON167 : UPDATE PLIC_Y1';  
   SET @Ls_SqlData_TEXT = 'MemberMci_IDNO' + CAST(@An_MemberMci_IDNO AS CHAR(10)) + 'LicenseStatus_CODE ' + @Lc_LicenseStatusActive_CODE + 'TypeLicense_CODE ' + @Ac_TypeReference_CODE + 'EndValidity_DATE :' + CAST (@Ad_Run_DATE AS VARCHAR);  
  
   UPDATE PLIC_Y1
        SET EndValidity_DATE = @Ad_Run_DATE 
     OUTPUT   DELETED.MemberMci_IDNO,
			  DELETED.TypeLicense_CODE,
			  DELETED.LicenseNo_TEXT,
			  DELETED.IssuingState_CODE,
			  @Lc_LicenseStatusInactive_CODE LicenseStatus_CODE, 
			  DELETED.OthpLicAgent_IDNO,
			  DELETED.IssueLicense_DATE,
			  DELETED.ExpireLicense_DATE,
			  @Ad_Run_DATE SuspLicense_DATE,
			  DELETED.Status_CODE,
			  DELETED.Status_DATE,
			  DELETED.SourceVerified_CODE,
			  @Ad_Run_DATE BeginValidity_DATE,  
			  @Ld_High_DATE EndValidity_DATE,  
			  @Ac_WorkerUpdate_ID WorkerUpdate_ID,  
			  @Ld_Current_DTTM Update_DTTM,  
			  @An_TransactionEventSeq_NUMB TransactionEventSeq_NUMB,
			  DELETED.Profession_CODE,
			  DELETED.Business_NAME,
			  DELETED.Trade_NAME
     INTO PLIC_Y1 (MemberMci_IDNO,TypeLicense_CODE, LicenseNo_TEXT,IssuingState_CODE,LicenseStatus_CODE,OthpLicAgent_IDNO,IssueLicense_DATE,ExpireLicense_DATE,SuspLicense_DATE,Status_CODE,Status_DATE,SourceVerified_CODE,BeginValidity_DATE,EndValidity_DATE,WorkerUpdate_ID,Update_DTTM,TransactionEventSeq_NUMB,Profession_CODE,Business_NAME,Trade_NAME)        
    WHERE MemberMci_IDNO  = @An_MemberMci_IDNO  
      AND OthpLicAgent_IDNO = @An_OthpSource_IDNO  
      AND TypeLicense_CODE = @Ac_TypeReference_CODE
      -- 13160 - CR0347 License Suspension Changes - Start
      AND LicenseNo_TEXT = @Ac_Reference_ID  
      -- 13160 - CR0347 License Suspension Changes - End
      AND EndValidity_DATE = @Ld_High_DATE  
      AND LicenseStatus_CODE IN(@Lc_LicenseStatusActive_CODE); 
  
   IF @@ROWCOUNT = 0  
    BEGIN  
     SET @As_DescriptionError_TEXT = 'UPDATE PLIC_Y1 FAILED';  
	 RAISERROR (50001,16,1);
    END  
  
   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;  
   SET @As_DescriptionError_TEXT = @Lc_Space_TEXT;  
  END TRY  
  
  BEGIN CATCH  
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
  
   --Check for Exception information to log the description text based on the error
   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @As_DescriptionError_TEXT = ISNULL(SUBSTRING(ERROR_MESSAGE(), 1, 200),' ')+ ISNULL(@As_DescriptionError_TEXT,'');
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @As_DescriptionError_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;
  END CATCH;  
 END  
  
GO
