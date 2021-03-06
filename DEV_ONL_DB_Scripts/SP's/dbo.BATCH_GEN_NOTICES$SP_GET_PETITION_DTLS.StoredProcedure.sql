/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICES$SP_GET_PETITION_DTLS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICES$SP_GET_PETITION_DTLS
Programmer Name	:	IMP Team.
Description		:	This procedure is used to get Petition Id from FDEM Table
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
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICES$SP_GET_PETITION_DTLS](
 @An_Case_IDNO             NUMERIC (6),
 @An_MajorIntSeq_NUMB      NUMERIC (4),
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR (4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusFailed_CODE   CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE  CHAR(1) = 'S',
          @Lc_ServiceResult_CODE  CHAR(1) = 'N',
          @Ls_Procedure_NAME      VARCHAR(100) = 'BATCH_GEN_NOTICES$SP_GET_PETITION_DTLS',
          @Ld_High_DATE           DATE = '12/31/9999';
  DECLARE @Ls_Sql_TEXT             VARCHAR (200),
          @Ls_Sqldata_TEXT         VARCHAR (400),
          @Ls_Err_Description_TEXT VARCHAR(4000);
  DECLARE @Li_Error_NUMB     INT = ERROR_NUMBER (),
          @Li_ErrorLine_NUMB INT = ERROR_LINE ();

  SET @Ls_Sql_TEXT = 'SELECT FDEM';
  SET @Ls_Sqldata_TEXT = 'Case IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '');

  BEGIN TRY
   INSERT INTO #NoticeElementsData_P1
               (Element_NAME,
                Element_VALUE)
   SELECT pvt.Element_NAME,
          pvt.Element_VALUE
     FROM (SELECT CONVERT(VARCHAR(70), Petition_idno) Petition_numb,
                  CONVERT(VARCHAR(70), File_Id) File_numb,
                  CONVERT(VARCHAR(70), Service_date) negative_service_date
                  FROM (SELECT F.Petition_idno,
                               F.File_Id,
                               R.Service_date 
                     FROM FDEM_Y1 F
                       JOIN FSRT_Y1 R
                       ON F.Case_IDNO = R.Case_IDNO
                       AND F.MajorIntSeq_NUMB =R.MajorIntSeq_NUMB
                       AND F.Petition_idno = R.Petition_idno
                      WHERE F.Case_IDNO = @An_Case_IDNO
                      AND F.MajorIntSeq_NUMB = @An_MajorIntSeq_NUMB
                      AND R.ServiceResult_CODE = @Lc_ServiceResult_CODE
                      AND F.EndValidity_DATE = @Ld_High_DATE
                      AND R.EndValidity_DATE = @Ld_High_DATE) z) x UNPIVOT (Element_VALUE FOR Element_NAME IN (Petition_numb, File_numb,negative_service_date)) AS pvt;

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

   IF (@Li_Error_NUMB <> 50001)
    BEGIN
     SET @Ls_Err_Description_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_Err_Description_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_SqlData_TEXT,
    @An_Error_NUMB            = @Li_Error_NUMB,
    @An_ErrorLine_NUMB        = @Li_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_Err_Description_TEXT OUTPUT;

   SET @As_DescriptionError_TEXT = @Ls_Err_Description_TEXT;
  END CATCH
 END


GO
