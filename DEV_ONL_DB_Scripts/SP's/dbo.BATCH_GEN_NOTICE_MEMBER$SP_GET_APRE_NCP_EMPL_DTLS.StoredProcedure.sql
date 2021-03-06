/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICE_MEMBER$SP_GET_APRE_NCP_EMPL_DTLS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICE_MEMBER$SP_GET_APRE_NCP_EMPL_DTLS
Programmer Name	:	IMP Team.
Description		:	This procedure is used to get Apre case management details from APCM_Y1.
Frequency		:	
Developed On	:	5/3/2012
Called By		:	BATCH_GEN_NOTICES$SP_EXECUTE_PROC_DYNAMIC
Called On		:	BATCH_COMMON$SF_GET_APRENCPMEMBERFORACTIVECASE
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICE_MEMBER$SP_GET_APRE_NCP_EMPL_DTLS]
 @An_Application_IDNO		NUMERIC(15), 
 @Ac_Msg_CODE				CHAR(5) OUTPUT,  
 @As_DescriptionError_TEXT	VARCHAR(4000) OUTPUT  
AS    
BEGIN
	SET NOCOUNT ON;    
  DECLARE  @Lc_StatusSuccess_CODE  CHAR = 'S',
           @Lc_StatusFailed_CODE   CHAR = 'F',
           @Lc_Space_TEXT          CHAR = ' ',
           @Ls_NcpEmpPrefix_TEXT   CHAR(7) = 'NCP_EMP',
           @Ls_Routine_TEXT        VARCHAR(60) = 'BATCH_GEN_NOTICE_MEMBER$SP_GET_APRE_NCP_EMPL_DTLS',
           @Ld_High_DATE           DATETIME2 = '12-31-9999';
  DECLARE  @Ln_Zero_NUMB             NUMERIC = 0,
           @Ln_Rowcount_QNTY         NUMERIC(5),
           @Ln_ActiveOthpEmpl_IDNO   NUMERIC(9),
           @Ln_NCpMemberMci_IDNO     NUMERIC(10),
           @Ls_SqlQuery_TEXT         VARCHAR(MAX),
           @Ls_SQLString_TEXT        VARCHAR(MAX),
           @Ls_Sqldata_TEXT          VARCHAR(400),
           @Ls_Sql_TEXT              VARCHAR(1000),
           @Ls_Err_Description_TEXT  VARCHAR(4000);
  
  BEGIN TRY 
		SET @As_DescriptionError_TEXT='';    
		SET @Ls_Sql_TEXT = 'SELECT APCM_Y1';

		 SET @Ls_Sqldata_TEXT = ' Applcation_IDNO: ' + ISNULL(CAST(@An_Application_IDNO AS CHAR(15)), '');
		 
		 IF @An_Application_IDNO IS NOT NULL AND @An_Application_IDNO <> 0
			BEGIN
				 SET @Ls_Sql_TEXT = 'SELECT APCM_Y1';
                  SET @Ls_Sqldata_TEXT = 'Application_IDNO =' + ISNULL(CAST(@An_Application_IDNO AS CHAR(15)), '');                  
                  SET @Ln_NCpMemberMci_IDNO = dbo.BATCH_COMMON$SF_GET_APRENCPMEMBERFORACTIVECASE(@An_Application_IDNO);
			END
			
		 IF @Ln_NCpMemberMci_IDNO <> 0 AND @Ln_NCpMemberMci_IDNO IS NOT NULL
			BEGIN
				 INSERT INTO #NoticeElementsData_P1(Element_NAME,Element_Value)
				(SELECT tag_name, tag_value FROM    
                 (     
					SELECT 
						CONVERT(VARCHAR(100),NCP_EMP_CODE_CURRENT)NCP_EMP_CODE_CURRENT,
						CONVERT(VARCHAR(100),NCP_EMP_CODE_LASTKNOWN)NCP_EMP_CODE_LASTKNOWN,
						CONVERT(VARCHAR(100),EmployerAddressAsOf_DATE)NCP_EMP_ADDR_KNOWN_DATE
					FROM
					(
						SELECT (CASE WHEN MemberAddress_CODE = 'L' THEN 'X' ELSE '' END)NCP_EMP_CODE_CURRENT,
							   (CASE WHEN MemberAddress_CODE = 'C' THEN 'X' ELSE '' END)NCP_EMP_CODE_LASTKNOWN,
							   EmployerAddressAsOf_DATE 
						  FROM APEH_Y1 
						  WHERE MemberMci_IDNO = @Ln_NCpMemberMci_IDNO 
						  and Application_IDNO = @An_Application_IDNO
						  AND EndValidity_DATE = @Ld_High_DATE
						  AND dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME() BETWEEN BeginEmployment_DATE AND ENDEmployment_DATE)a
					)up
					UNPIVOT
					(tag_value FOR tag_name IN				  
											  (
											  NCP_EMP_CODE_CURRENT,
											  NCP_EMP_CODE_LASTKNOWN,
											  NCP_EMP_ADDR_KNOWN_DATE))as pvt);
				SET @Ln_ActiveOthpEmpl_IDNO = dbo.BATCH_COMMON$SF_GETAPREACTIVEEMPLOYER(@Ln_NCpMemberMci_IDNO,@An_Application_IDNO);			
				IF 	@Ln_ActiveOthpEmpl_IDNO <> 0
					BEGIN				
						EXEC BATCH_GEN_NOTICE_CM$SP_GET_OTHP_DTLS
								@An_OtherParty_IDNO = @Ln_ActiveOthpEmpl_IDNO,
								@As_Prefix_TEXT     = @Ls_NcpEmpPrefix_TEXT,
								@Ac_Msg_CODE		= @Ac_Msg_CODE OUTPUT,
								@As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;
						
						IF @Ac_Msg_CODE = @Lc_StatusFailed_CODE
							BEGIN
								RAISERROR(50001,16,1);
							 END
		 			END
		 		
			END
    SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE ;    
    END TRY            
    BEGIN CATCH    
     DECLARE @Li_Error_NUMB			   INT = ERROR_NUMBER (),
			@Li_ErrorLine_NUMB		   INT =  ERROR_LINE ();

         SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
		 IF (@Li_Error_NUMB <> 50001)
			BEGIN
			   SET @As_DescriptionError_TEXT =
					  SUBSTRING (ERROR_MESSAGE (), 1, 200);
			END
         EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION @As_Procedure_NAME = @Ls_Sql_TEXT,
                                                       @As_ErrorMessage_TEXT = @As_DescriptionError_TEXT,
                                                       @As_Sql_TEXT = @Ls_Sql_TEXT,
                                                       @As_Sqldata_TEXT = @Ls_SqlData_TEXT,
                                                       @An_Error_NUMB = @Li_Error_NUMB,
                                                       @An_ErrorLine_NUMB = @Li_ErrorLine_NUMB,
                                                       @As_DescriptionError_TEXT = @Ls_Err_Description_TEXT OUTPUT;
         SET @As_DescriptionError_TEXT = @Ls_Err_Description_TEXT; 
    END CATCH    
    
END    
 


GO
