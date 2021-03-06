/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICES$SP_GET_COUNTY_DTLS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
---------------------------------------------------------
 Procedure Name    : BATCH_GEN_NOTICES$SP_GET_COUNTY_DTLS
 Programmer Name   : IMP Team
 Description       : This procedure gets the county details.
 Frequency         :
 Developed On      : 02-08-2011
 Called By         : BATCH_COMMON$SP_FORMAT_BUILD_XML
 Called On         :
---------------------------------------------------------
 Modified By       :
 Modified On       :
 Version No        : 1.0
---------------------------------------------------------
*/  

CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICES$SP_GET_COUNTY_DTLS] (
 @An_Case_IDNO             NUMERIC (6),
 @Ac_Msg_CODE              CHAR (5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR (4000) OUTPUT
 )
AS
 BEGIN
 SET NOCOUNT ON;
  DECLARE @Lc_StatusSuccess_CODE		CHAR (1)	= 'S',
          @Lc_StatusFailed_CODE			CHAR (1)	= 'F',
          @Lc_NoticeEst19_ID			CHAR (8)	= 'EST-19',
          @Lc_NoticeEnf39_ID			CHAR (8)	= 'ENF-39',
          @Lc_Notice_ID					CHAR (8)	= '',
          @Lc_PrefixCounty_TEXT			CHAR (9)	= 'CNTY_OFIC',
          @Lc_Element_Name				CHAR (10)	= 'Notice_ID',
          @Lc_Element_Cnty_Name			CHAR (15)   = 'cnty_ofic_name',
          @Ln_OtherParty_IDNO			NUMERIC(9)	= NULL,
		  @Ln_OtherPartyCentral_IDNO    NUMERIC(9)	= 999999981;
  DECLARE @Ls_Sql_TEXT					VARCHAR(200)= '',
          @Ls_SqlData_TEXT				VARCHAR(400)= '',
          @Ls_DescriptionError_TEXT		VARCHAR(4000);

  BEGIN TRY
   SET @Ac_Msg_CODE = NULL;
   SET @As_DescriptionError_TEXT = NULL;
   SET @Ls_Sql_TEXT     = 'SELECT OTHP_Y1';
   SET @Ls_SqlData_TEXT = 'Case_IDNO = ' + ISNULL (CAST(@An_Case_IDNO AS VARCHAR(6)), '') + ', OtherParty_IDNO = ' + ISNULL(CAST (@Ln_OtherParty_IDNO AS VARCHAR(9)), '');

 SELECT @Lc_Notice_ID = Element_VALUE
      FROM #NoticeElementsData_P1
       WHERE Element_NAME= @Lc_Element_Name
 
 
 /* For EST-19 to populate the county court address*/      
 --12051 - CR0234 ENF-39 PSOC Form Mapping Changes 20130710 - Fix - START
   IF  @Lc_Notice_ID = @Lc_NoticeEst19_ID
     BEGIN
        SET @Ln_OtherParty_IDNO = (SELECT OthpLawSer_IDNO
                                       FROM COPT_Y1
                                        WHERE County_IDNO = (SELECT County_IDNO
                                                              FROM Case_Y1
                                                                WHERE Case_IDNO = @An_Case_IDNO));
      END
   ELSE IF  @Lc_Notice_ID = @Lc_NoticeEnf39_ID
     BEGIN
        SET @Ln_OtherParty_IDNO = @Ln_OtherPartyCentral_IDNO
      END
     ELSE
      BEGIN                                               
        SET @Ln_OtherParty_IDNO = DBO.BATCH_COMMON_GETS$SF_GETCOUNTYOTHERPARTY (@An_Case_IDNO);
      END  
   IF (@Ln_OtherParty_IDNO IS NOT NULL)
    BEGIN
     EXEC BATCH_GEN_NOTICE_CM$SP_GET_OTHP_DTLS
      @An_OtherParty_IDNO       = @Ln_OtherParty_IDNO,
      @As_Prefix_TEXT           = @Lc_PrefixCounty_TEXT,
      @Ac_Msg_CODE              = @Ac_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;

     IF @Ac_Msg_CODE != @Lc_StatusSuccess_CODE
      BEGIN
       RAISERROR (50001,16,1);

       RETURN;
      END
    END

   SET @AC_Msg_CODE = @LC_StatusSuccess_CODE;
   
  --12051 - CR0234 ENF-39 PSOC Form Mapping Changes 20130710 - Fix - START
  
  END TRY
	
  BEGIN CATCH
   DECLARE @Li_Error_NUMB     INT = ERROR_NUMBER (),
           @Li_ErrorLine_NUMB INT = ERROR_LINE ();

   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

   IF (@Li_Error_NUMB <> 50001)
    BEGIN
     SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Sql_TEXT,
    @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_SqlData_TEXT,
    @An_Error_NUMB            = @Li_Error_NUMB,
    @An_ErrorLine_NUMB        = @Li_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;
  END CATCH
 END


GO
