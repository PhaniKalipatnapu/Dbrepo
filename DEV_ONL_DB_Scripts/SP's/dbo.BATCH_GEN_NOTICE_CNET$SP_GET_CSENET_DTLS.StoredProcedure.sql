/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICE_CNET$SP_GET_CSENET_DTLS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICE_CNET$SP_GET_CSENET_DTLS
Programmer Name	:	IMP Team.
Description		:	
Frequency		:	
Developed On	:	5/3/2012
Called By		:	
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICE_CNET$SP_GET_CSENET_DTLS](
 @An_TransHeader_IDNO       NUMERIC(12),
 @Ac_IVDOutOfStateFips_CODE CHAR(2),
 @Ad_Transaction_DATE       DATE,
 @Ac_Msg_CODE               CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT  VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  DECLARE @Ls_Space_TEXT             CHAR(1) = ' ',
          @Ls_StringZero_TEXT        CHAR(1) = '0',
          @Lc_StatusSuccess_CODE     CHAR(1) = 'S',
          @Lc_StatusFailed_CODE      CHAR(1) = 'F',
          @Ls_Office00_CODE          CHAR(2) = '00',
          @Ls_Procedure_NAME         VARCHAR(100) = 'BATCH_GEN_NOTICE_CNET.BATCH_GEN_NOTICE_CNET$SP_GET_CSENET_DTLS ',
          @Ls_Sql_TEXT               VARCHAR(200),
          @Ls_Sqldata_TEXT           VARCHAR(400) ,
          @Ls_DescriptionError_TEXT  VARCHAR(4000);

  BEGIN TRY
   SET @Ac_Msg_CODE = NULL;
   SET @As_DescriptionError_TEXT = NULL;
   SET @Ls_Sqldata_TEXT = '  TransHeader_IDNO = ' + CAST(@An_TransHeader_IDNO AS VARCHAR) 
                         + ' IVDOutOfStateFips_CODE=' + ISNULL(@Ac_IVDOutOfStateFips_CODE, '')
   SET @Ls_Sql_TEXT = 'SELECT VCTHB_VICAS ';

   INSERT INTO #NoticeElementsData_P1
               (Element_NAME,
                Element_VALUE)
   (SELECT Element_NAME,
           Element_VALUE
      FROM (SELECT CONVERT(VARCHAR(100), A.Action_CODE) AS Action_CODE,
                   CONVERT(VARCHAR(100), A.Function_CODE) AS Function_CODE,
                   CONVERT(VARCHAR(100), A.Reason_CODE) AS Reason_CODE,
                   CONVERT(VARCHAR(100), A.Fips_CODE) AS InitiateFips_CODE,
                   CONVERT(VARCHAR(100), A.IVDOutOfStateCase_ID) IVDOutOfStateCase_ID
              FROM (SELECT b.Action_CODE,
                           b.Function_CODE,
                           b.Reason_CODE,
                           ISNULL(b.IVDOutOfStateFips_CODE, '') + ISNULL(b.IVDOutOfStateCountyFips_CODE, '') 
								+ ISNULL(CASE b.IVDOutOfStateOfficeFips_CODE
									   WHEN @Ls_Space_TEXT
										THEN @Ls_Office00_CODE
									   WHEN @Ls_StringZero_TEXT
										THEN @Ls_Office00_CODE
									   ELSE b.IVDOutOfStateOfficeFips_CODE
									  END, '') Fips_CODE,
                           b.IVDOutOfStateCase_ID
                      FROM CTHB_Y1 AS b
                     WHERE b.TransHeader_IDNO = @An_TransHeader_IDNO
                       AND b.IVDOutOfStateFips_CODE = @Ac_IVDOutOfStateFips_CODE
                       AND b.Transaction_DATE = @Ad_Transaction_DATE)
                          a
                          ) U
                        UNPIVOT (Element_VALUE FOR Element_NAME IN ( U.Action_CODE,  U.Function_CODE,  U.Reason_CODE, 
                                                                     U.InitiateFips_CODE,  U.IVDOutOfStateCase_ID )) AS pvt)

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY
  BEGIN CATCH
    SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
         DECLARE
            @Li_Error_NUMB INT = ERROR_NUMBER (),
            @Li_ErrorLine_NUMB INT = ERROR_LINE ();

         IF (@Li_Error_NUMB <> 50001)
            BEGIN
               SET @Ls_DescriptionError_TEXT =  SUBSTRING (ERROR_MESSAGE (), 1, 200);
            END;

         EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION @As_Procedure_NAME = @Ls_Procedure_NAME,
                                                       @As_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT,
                                                       @As_Sql_TEXT = @Ls_Sql_TEXT,
                                                       @As_Sqldata_TEXT = @Ls_SqlData_TEXT,
                                                       @An_Error_NUMB = @Li_Error_NUMB,
                                                       @An_ErrorLine_NUMB = @Li_ErrorLine_NUMB,
                                                       @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT ;

         SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
  END CATCH;
 END;


GO
