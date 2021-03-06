/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICE_MEMBER$SP_GET_APRE_CP_EMPL_ADDRESS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICE_MEMBER$SP_GET_APRE_CP_EMPL_ADDRESS
Programmer Name	:	IMP Team.
Description		:	This procedure is used to get Cp Apre Address details
Frequency		:	
Developed On	:	5/3/2012
Called By		:	BATCH_GEN_NOTICES$SP_FORMAT_BUILD_XML
Called On		:	BATCH_COMMON$SF_GET_APRECPMEMBERFORACTIVECASE,BATCH_GEN_NOTICE_CM$SP_GET_OTHP_DTLS
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICE_MEMBER$SP_GET_APRE_CP_EMPL_ADDRESS]
(   
 @An_Application_IDNO		NUMERIC(15), 
 @Ac_Msg_CODE				CHAR(5) OUTPUT,  
 @As_DescriptionError_TEXT	VARCHAR(4000) OUTPUT  
)
AS    
BEGIN
 SET NOCOUNT ON;    
  DECLARE  @Lc_StatusSuccess_CODE  CHAR(1) = 'S',
           @Lc_StatusFailed_CODE   CHAR(1) = 'F',
           @Lc_CpEmpPrefix_TEXT    CHAR(6) = 'CP_EMP',
           @Ls_Routine_TEXT        VARCHAR(100) = 'BATCH_GEN_NOTICE_MEMBER$SP_GET_APRE_CP_EMPL_ADDRESS';
  DECLARE  @Ln_OthpMemberEmpl_IDNO    NUMERIC(9),
		   @Ln_MemberMci_IDNO         NUMERIC(10),
		   @Li_Error_NUMB			  INT,
		   @Li_ErrorLine_NUMB		  INT,
           @Ls_Sqldata_TEXT           VARCHAR(400),
           @Ls_Sql_TEXT               VARCHAR(1000),
           @Ls_DescriptionError_TEXT  VARCHAR(4000);
  BEGIN TRY 
		SET @As_DescriptionError_TEXT='';
		
		SET @Ls_Sql_TEXT = 'BATCH_COMMON$SF_GET_APRECPMEMBERFORACTIVECASE ';
		
		SET @Ls_Sqldata_TEXT = ' Application_IDNO = ' + CAST(ISNULL(@An_Application_IDNO, 0) AS VARCHAR(15));
		 
		SET @Ln_MemberMci_IDNO = dbo.BATCH_COMMON$SF_GET_APRECPMEMBERFORACTIVECASE(@An_Application_IDNO);
		 
		IF @Ln_MemberMci_IDNO <> 0
			BEGIN
				SET @Ln_OthpMemberEmpl_IDNO = dbo.BATCH_GEN_NOTICES$SF_GET_APRE_ACTIVE_EMPLOYER(@Ln_MemberMci_IDNO);
			END

		SET @Ls_Sql_TEXT = 'BATCH_GEN_NOTICE_CM$SP_GET_OTHP_DTLS ';
		SET @Ls_Sqldata_TEXT = ' Application_IDNO = ' + CAST(ISNULL(@An_Application_IDNO, 0) AS VARCHAR(15)) 
							+  ', OthpMemberEmpl_IDNO = ' + CAST(ISNULL(@Ln_OthpMemberEmpl_IDNO, 0) AS VARCHAR(10));
		
		EXEC BATCH_GEN_NOTICE_CM$SP_GET_OTHP_DTLS   
						 @An_OtherParty_IDNO	   = @Ln_OthpMemberEmpl_IDNO,
						 @As_Prefix_TEXT		   = @Lc_CpEmpPrefix_TEXT,
						 @Ac_Msg_CODE			   = @Ac_Msg_CODE OUTPUT,  
						 @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;
						 
		IF @Ac_Msg_CODE = @Lc_StatusFailed_CODE
		BEGIN
			RAISERROR(@Lc_StatusFailed_CODE,16,1);
		END
	SET @Ac_Msg_CODE =  @Lc_StatusSuccess_CODE;
  END TRY  
  BEGIN CATCH    
			 SET @Li_Error_NUMB	= ERROR_NUMBER ();
			 SET @Li_ErrorLine_NUMB =  ERROR_LINE ();

			 SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

			 IF (@Li_Error_NUMB <> 50001)
				BEGIN
				   SET @As_DescriptionError_TEXT =
						  SUBSTRING (ERROR_MESSAGE (), 1, 200);
				END

			 EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION @As_Procedure_NAME = @Ls_Routine_TEXT,
														   @As_ErrorMessage_TEXT = @As_DescriptionError_TEXT,
														   @As_Sql_TEXT = @Ls_Sql_TEXT,
														   @As_Sqldata_TEXT = @Ls_SqlData_TEXT,
														   @An_Error_NUMB = @Li_Error_NUMB,
														   @An_ErrorLine_NUMB = @Li_ErrorLine_NUMB,
														   @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT ;

			 SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT; 
 END CATCH    
END    

GO
