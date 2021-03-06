/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICES$SP_GET_LSNR_PYMT_DTLS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICES$SP_GET_LSNR_PYMT_DTLS
Programmer Name	:	IMP Team.
Description		:	This procedure is used to get Payment and compliance date from DMNR_Y1
Frequency		:	
Developed On	:	4/19/2012
Called By		:	BATCH_COMMON$SP_FORMAT_BUILD_XML
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICES$SP_GET_LSNR_PYMT_DTLS]
 @An_Case_IDNO             NUMERIC(6),
 @An_MajorIntSeq_NUMB      NUMERIC(5),
 @Ad_Run_DATE              DATE,
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
 BEGIN
 SET NOCOUNT ON;
  DECLARE @Lc_StatusFailed_CODE       CHAR = 'F',
          @Lc_StatusSuccess_CODE      CHAR = 'S',
          @Lc_Empty_TEXT              CHAR = '',
          @Lc_ReasonStatusZo_CODE     CHAR(2) = 'ZO',
          @Lc_ActivityMajorLsnr_CODE  CHAR(4) = 'LSNR',
          @Lc_StatusStrt_CODE         CHAR(4) = 'STRT';
          
         
 DECLARE  @Ls_Procedure_NAME          VARCHAR(100),
          @Ls_Sql_TEXT                VARCHAR(200),
          @Ls_Sqldata_TEXT            VARCHAR(400),
          @Ls_Err_Description_TEXT    VARCHAR(4000),
          @Ld_PymtInitiated_DATE      DATE,
          @Ld_NonCompliance_DATE      DATE;

  BEGIN TRY
   SET @Ac_Msg_CODE = NULL;
   SET @As_DescriptionError_TEXT = NULL;
   SET @Ls_Procedure_NAME = 'BATCH_GEN_NOTICES$SP_GET_LSNR_PYMT_DTLS ';
   SET @Ls_Sql_TEXT = 'SELECT DMJR_Y1';
   SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '') + ', MajorIntSeq_NUMB = ' + ISNULL(CAST(@An_MajorIntSeq_NUMB AS VARCHAR (5)), '') + ', Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR (20)), '');
   SELECT @Ld_PymtInitiated_DATE = Status_DATE
     FROM DMNR_Y1 d
    WHERE d.Case_idno = @An_Case_IDNO
      AND d.MajorIntseq_NUMB = @An_MajorIntSeq_NUMB
      AND d.ActivityMajor_CODE = @Lc_ActivityMajorLsnr_CODE
      AND d.ReasonStatus_CODE = @Lc_ReasonStatusZo_CODE;

	IF ISNULL(@Ld_PymtInitiated_DATE,@Lc_Empty_TEXT)=@Lc_Empty_TEXT OR @Ld_PymtInitiated_DATE=@Lc_Empty_TEXT
	BEGIN
	  SELECT @Ld_PymtInitiated_DATE = Entered_DATE
		FROM DMNR_Y1 d
	   WHERE d.Case_idno = @An_Case_IDNO
       AND d.MajorIntseq_NUMB = @An_MajorIntSeq_NUMB
       AND d.ActivityMajor_CODE = @Lc_ActivityMajorLsnr_CODE
       AND d.Status_CODE = @Lc_StatusStrt_CODE
	END
   SET @Ld_NonCompliance_DATE = @Ad_Run_DATE;

   INSERT INTO #NoticeElementsData_P1
               (Element_NAME,
                ELEMENT_VALUE)
   (SELECT tag_name,
           tag_value
      FROM (SELECT CONVERT(VARCHAR(70), Compliance_DATE) NonCompliance_DATE,
                   CONVERT(VARCHAR(70), PymtInitiated_DATE) PymtInitiated_DATE
              FROM (SELECT @Ld_NonCompliance_DATE AS Compliance_DATE,
                           @Ld_PymtInitiated_DATE AS PymtInitiated_DATE)a) up UNPIVOT (tag_value FOR tag_name IN ( NonCompliance_DATE, PymtInitiated_DATE)) AS pvt);

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

   DECLARE @Li_Error_NUMB     INT = ERROR_NUMBER (),
           @Li_ErrorLine_NUMB INT = ERROR_LINE ();

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
