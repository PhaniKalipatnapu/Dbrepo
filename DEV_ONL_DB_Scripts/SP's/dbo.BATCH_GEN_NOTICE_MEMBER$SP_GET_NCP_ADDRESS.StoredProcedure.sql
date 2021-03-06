/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICE_MEMBER$SP_GET_NCP_ADDRESS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICE_MEMBER$SP_GET_NCP_ADDRESS
Programmer Name	:	IMP Team.
Description		:	This procedure is used to get NCP address details from AHIS_Y1
Frequency		:	
Developed On	:	2/17/2012
Called By		:	BATCH_COMMON$SP_FORMAT_BUILD_XML
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICE_MEMBER$SP_GET_NCP_ADDRESS]
 @An_Case_IDNO             NUMERIC(6),
 @An_MemberMci_IDNO     NUMERIC(10),
 @Ac_ActivityMajor_CODE	   CHAR(4),
 @An_OtherParty_IDNO	   NUMERIC(10),
 @Ad_Run_DATE              DATE,
 @Ac_Msg_CODE              CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
 BEGIN
	SET NOCOUNT ON; 
    DECLARE  @Li_Error_NUMB   		 INT = ERROR_NUMBER (),
             @Li_ErrorLine_NUMB        INT =  ERROR_LINE (),
             @Lc_StatusFailed_CODE   CHAR = 'F',
             @Lc_StatusSuccess_CODE  CHAR = 'S',
             @Lc_NcpPrefix_TEXT      CHAR(4) = 'NCP',
             @Ls_Procedure_NAME        VARCHAR(100) = 'BATCH_GEN_NOTICE_MEMBER$SP_GET_NCP_ADDRESS ';
             
   DECLARE @Lc_TypeAddress_CODE      CHAR(2),
           @Lc_Recipient_CODE        CHAR(2),
           @Ln_MemberMci_IDNO		 NUMERIC(10),
           @Ls_Sql_TEXT              VARCHAR(200),
           @Ls_Sqldata_TEXT          VARCHAR(400),
           @Ls_DescriptionError_TEXT VARCHAR(4000);
           
  BEGIN TRY 
  
   SET @Ac_Msg_CODE = NULL;
   SET @As_DescriptionError_TEXT = NULL;
   
   IF @An_Case_IDNO IS NOT NULL AND @An_Case_IDNO != 0 AND @Ac_ActivityMajor_CODE != 'ESTP'
    BEGIN
        SET @Ls_Sql_TEXT = 'BATCH_COMMON$SF_GETNCPMEMBERFORACTIVECASE ';    
		SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '');
		SET @Ln_MemberMci_IDNO = @An_MemberMci_IDNO;
    END
   ELSE IF @Ac_ActivityMajor_CODE = 'ESTP'
	BEGIN
		SET @Ln_MemberMci_IDNO = @An_OtherParty_IDNO;
	END
 SELECT @Lc_TypeAddress_CODE = Element_VALUE
       FROM #NoticeElementsData_P1 where Element_NAME='TypeAddress_CODE' 
       
 SELECT @Lc_Recipient_CODE = Element_VALUE
       FROM #NoticeElementsData_P1  where Element_NAME='Recipient_CODE'
             
   If @Lc_Recipient_CODE != 'MN'
     BEGIN
          SET  @Lc_TypeAddress_CODE  = ' '
      END        
     
   IF @An_MemberMci_IDNO <> 0
    BEGIN
		SET @Ls_Sql_TEXT = 'BATCH_GEN_NOTICE_CM$SP_GET_ADDRESS';

		 EXECUTE BATCH_GEN_NOTICE_CM$SP_GET_ADDRESS
		  @An_MemberMci_IDNO        = @Ln_MemberMci_IDNO,
		  @Ac_TypeAddress_CODE      = @Lc_TypeAddress_CODE,
		  @Ad_Run_DATE              = @Ad_Run_DATE,
		  @As_Prefix_TEXT           = @Lc_NcpPrefix_TEXT,
		  @Ac_Msg_CODE              = @Ac_Msg_CODE OUTPUT,
		  @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;

     IF @Ac_Msg_CODE = @Lc_StatusFailed_CODE
		BEGIN
			RAISERROR(50001,16,1);
		END
    END
    
    SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

   IF (@Li_Error_NUMB <> 50001)
   BEGIN
      SET @As_DescriptionError_TEXT =
       SUBSTRING (ERROR_MESSAGE (), 1, 200);
   END
   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION @As_Procedure_NAME = @Ls_Procedure_NAME,
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
