/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICE_MEMBER$SP_GET_NCP_LOC_ALIAS_DETAILS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICE_MEMBER$SP_GET_NCP_LOC_ALIAS_DETAILS
Programmer Name	:	IMP Team.
Description		:	
Frequency		:	
Developed On	:	5/3/2012
Called By		:	BATCH_COMMON$SP_FORMAT_BUILD_XML
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICE_MEMBER$SP_GET_NCP_LOC_ALIAS_DETAILS]
(
	 @An_NcpMemberMci_IDNO			NUMERIC(10),
	 @Ac_Msg_CODE					CHAR(5) OUTPUT,
	 @As_DescriptionError_TEXT		VARCHAR (4000) OUTPUT
 )
AS
 BEGIN
 SET NOCOUNT ON;
  DECLARE  
           @Lc_StatusSuccess_CODE  CHAR(1) = 'S',
           @Lc_StatusFailed_CODE   CHAR(1) = 'F',
           @Ls_Prefix_TEXT         VARCHAR(70)='NCP',
           @Ls_Procedure_NAME      VARCHAR(100) = 'BATCH_GEN_NOTICE_MEMBER$SP_GET_NCP_LOC_ALIAS_DETAILS';
                      
  DECLARE  @Lc_Msg_CODE               CHAR(5),  
           @Ls_Sql_TEXT               VARCHAR(200),
           @Ls_Sqldata_TEXT           VARCHAR(1000),
           @Ls_DescriptionError_TEXT  VARCHAR(4000);

  BEGIN TRY
   SET @Ac_Msg_CODE = NULL;
   SET @As_DescriptionError_TEXT = NULL;
   SET @Ls_Sql_TEXT = 'BATCH_GEN_NOTICE_MEMBER$SP_GET_LOC_ALIAS_DETAILS';
   SET @Ls_Sqldata_TEXT = ' MemberMci_IDNO = ' + ISNULL(CAST(@An_NcpMemberMci_IDNO AS VARCHAR(10)), '');
  EXEC BATCH_GEN_NOTICE_MEMBER$SP_GET_LOC_ALIAS_DETAILS
                  @An_MemberMci_IDNO         = @An_NcpMemberMci_IDNO,
                  @As_Prefix_TEXT            = @Ls_Prefix_TEXT,
                  @Ac_Msg_CODE               = @Lc_Msg_CODE OUTPUT ,
                  @As_DescriptionError_TEXT  = @Ls_DescriptionError_TEXT OUTPUT;
   IF(@Lc_Msg_CODE != @Lc_StatusSuccess_CODE)
   BEGIN
    RAISERROR(50001,16,1);
   END 
     
     SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY
  BEGIN CATCH  
	  DECLARE  @Ln_Error_NUMB             NUMERIC(11),
           @Ln_ErrorLine_NUMB         NUMERIC(11);
           
  		SELECT @Ac_Msg_CODE = @Lc_StatusFailed_CODE,
		  	   @Ln_Error_NUMB = ERROR_NUMBER(),
   		  	   @Ln_ErrorLine_NUMB = ERROR_LINE();
   		  	   
      IF ERROR_NUMBER () <> 50001  
      BEGIN  
      SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
      END
      EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    					    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    					    @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
    					    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    					    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    					    @An_Error_NUMB            = @Ln_Error_NUMB,
    					    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    					    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;	
	 SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;  
     END CATCH
 END


GO
