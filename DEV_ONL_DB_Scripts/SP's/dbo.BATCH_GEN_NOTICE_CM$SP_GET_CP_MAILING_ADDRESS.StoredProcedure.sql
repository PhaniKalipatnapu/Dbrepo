/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICE_CM$SP_GET_CP_MAILING_ADDRESS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICE_CM$SP_GET_CP_MAILING_ADDRESS
Programmer Name	:	IMP Team.
Description		:	This procedure is used to get address details from Address History table
Frequency		:	
Developed On	:	2/17/2012
Called By		:	BATCH_COMMON$SP_FORMAT_BUILD_XML
Called On		:	BATCH_GEN_NOTICE_CM$SP_GET_MAILING_ADDRESS
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICE_CM$SP_GET_CP_MAILING_ADDRESS](
 @An_CpMemberMci_IDNO      NUMERIC(10),
 @Ad_Run_DATE              DATE,
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
 )
AS
  BEGIN
   SET NOCOUNT ON;

  DECLARE @Ln_County1_IDNO                  NUMERIC(5)  = 1,
          @Ln_County3_IDNO                  NUMERIC(5)  = 3,
          @Ln_County5_IDNO                  NUMERIC(5)  = 5,
		  @Ln_OtherParty9989_IDNO			NUMERIC(9)  = 999999989,
          @Ln_OtherParty9988_IDNO			NUMERIC(9)  = 999999988,	
          @Ln_OtherParty9987_IDNO			NUMERIC(9)  = 999999987,
          @Lc_Empty_TEXT					CHAR(1)	    = '',
		  @Lc_StatusSuccess_CODE			CHAR(1)	    = 'S',
          @Lc_StatusFailed_CODE				CHAR(1)	    = 'F',
          @Lc_TypeCaseFoster_CODE			CHAR(1)	    = 'F',
          @Lc_TypeCaseNonFedFoster_CODE		CHAR(1)	    = 'J',
          @Lc_StatusCaseOpen_CODE			CHAR(1)     = 'O',
          @Lc_Prefix_TEXT					CHAR(2)	    = 'CP',
          @Lc_Legal_Notices				    CHAR(5)     = '%LEG%',
          @Lc_NoticeLeg154_ID			    VARCHAR(8)  ='LEG-154',
          @Lc_Elem_Case_IDNO				VARCHAR(20) = 'Case_IDNO',
          @Lc_Elem_Notice_ID				VARCHAR(20) = 'Notice_ID',
          @Ls_Procedure_NAME				VARCHAR(100) = 'BATCH_GEN_NOTICE_CM$SP_GET_CP_MAILING_ADDRESS ';
  DECLARE 
		  @Li_Error_NUMB					NUMERIC(11),
          @Li_ErrorLine_NUMB				NUMERIC(11),
          @Ln_County_IDNO					NUMERIC(3),
		  @Ln_Case_IDNO						NUMERIC(6),
		  @Ln_OtherParty_IDNO				NUMERIC(10), 
		  @Lc_TypeCase_CODE					CHAR(1),
		  @Lc_Notice_ID						VARCHAR(8),
          @Ls_Sql_TEXT						VARCHAR(200) = '',
          @Ls_SqlData_TEXT					VARCHAR(400) = '',
          @Ls_DescriptionError_TEXT			VARCHAR(4000) ='';

  BEGIN TRY
   SET @Ac_Msg_CODE = NULL;
   SET @As_DescriptionError_TEXT = NULL;
   
   SELECT @Ln_Case_IDNO = Element_VALUE
       FROM #NoticeElementsData_P1  WHERE Element_NAME = @Lc_Elem_Case_IDNO    
       
	SELECT @Lc_Notice_ID = Element_VALUE
       FROM #NoticeElementsData_P1  WHERE Element_NAME = @Lc_Elem_Notice_ID               
       
    SELECT  @Lc_TypeCase_CODE  = a.TypeCase_CODE, 
			@Ln_County_IDNO = a.County_IDNO
			FROM CASE_Y1 a
			WHERE a.Case_IDNO = @Ln_Case_IDNO
			AND a.StatusCase_CODE = @Lc_StatusCaseOpen_CODE	
			
   IF (@An_CpMemberMci_IDNO IS NOT NULL
       AND @An_CpMemberMci_IDNO <> 0)
    BEGIN
    --13617 CR0407 Revise Mapping for Petitioner in IV-E  Cases to OTHP Records20140825 Fix - Start
     IF (@Lc_TypeCase_CODE IN(@Lc_TypeCaseFoster_CODE,@Lc_TypeCaseNonFedFoster_CODE) 
			AND @Lc_Notice_ID LIKE @Lc_Legal_Notices AND  @Lc_Notice_ID NOT IN(@Lc_NoticeLeg154_ID))
	 BEGIN
		   SET @Ls_Sql_TEXT = 'BATCH_GEN_NOTICE_CM$SP_GET_OTHP_DTLS';	
		   SET @Ls_Sqldata_TEXT = 'County_IDNO = ' + ISNULL(CAST(@Ln_County_IDNO AS VARCHAR), @Lc_Empty_TEXT);
		   
		   SELECT @Ln_OtherParty_IDNO = CASE WHEN @Ln_County_IDNO = @Ln_County1_IDNO THEN @Ln_OtherParty9989_IDNO 
											 WHEN @Ln_County_IDNO = @Ln_County3_IDNO THEN @Ln_OtherParty9988_IDNO
											 WHEN @Ln_County_IDNO = @Ln_County5_IDNO THEN @Ln_OtherParty9987_IDNO
									    END 
		   SET @Ls_Sql_TEXT = 'BATCH_GEN_NOTICE_CM$SP_GET_OTHP_DTLS';
		   SET @Ls_Sqldata_TEXT = 'OtherParty_IDNO = ' + ISNULL(CAST(@Ln_OtherParty_IDNO AS VARCHAR), @Lc_Empty_TEXT);

		   EXEC BATCH_GEN_NOTICE_CM$SP_GET_OTHP_DTLS
			@An_OtherParty_IDNO       = @Ln_OtherParty_IDNO,
			@As_Prefix_TEXT           = @Lc_Prefix_TEXT,
			@Ac_Msg_CODE              = @Ac_Msg_CODE,
			@As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;

		   IF @Ac_Msg_CODE = @Lc_StatusFailed_CODE
			BEGIN
			 RAISERROR(50001,16,1);
			END
		
	 END
	 ELSE
	 BEGIN
     SET @Ls_Sql_TEXT = 'SELECT AHIS_Y1';
     SET @Ls_SqlData_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@An_CpMemberMci_IDNO AS VARCHAR(10)), '');

     EXEC BATCH_GEN_NOTICE_CM$SP_GET_MAILING_ADDRESS
      @An_MemberMci_IDNO        = @An_CpMemberMci_IDNO,
      @Ad_Run_DATE              = @Ad_Run_DATE,
      @As_Prefix_TEXT           = @Lc_Prefix_TEXT,
      @Ac_Msg_CODE              = @Ac_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF (@Ac_Msg_CODE != @Lc_StatusSuccess_CODE)
      BEGIN
       RAISERROR(50001,16,1);
      END
    END
	END
	--13617 CR0407 Revise Mapping for Petitioner in IV-E  Cases to OTHP Records20140825 Fix - End
   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   SET @Li_Error_NUMB = ERROR_NUMBER ();
   SET @Li_ErrorLine_NUMB = ERROR_LINE ();
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

   IF (@Li_Error_NUMB <> 50001)
    BEGIN
     SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_SqlData_TEXT,
    @An_Error_NUMB            = @Li_Error_NUMB,
    @An_ErrorLine_NUMB        = @Li_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;
  END CATCH
 END


GO
