/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICE_CM$SP_GET_CASE_WORKER_OFIC_DTLS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICE_CM$SP_GET_CASE_WORKER_OFIC_DTLS
Programmer Name	:	IMP Team.
Description		:	This Procedure returns worker office details
Frequency		:	
Developed On	:	2/17/2012
Called By		:	BATCH_GEN_NOTICES$SP_FORMAT_BUILD_XML
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICE_CM$SP_GET_CASE_WORKER_OFIC_DTLS]
 @An_Case_IDNO             NUMERIC (6),
 @Ad_Run_DATE              DATE,
 @As_Prefix_TEXT           VARCHAR (70) = 'WORKER',
 @Ac_Msg_CODE              CHAR (5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR (4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusSuccess_CODE CHAR (1) = 'S',
          @Lc_StatusFailed_CODE  CHAR (1) = 'F',
          @Lc_Space_TEXT         CHAR (1) = ' ',
          @Ls_Procedure_NAME     VARCHAR (100) = 'BATCH_GEN_NOTICE_CM$SP_GET_CASE_WORKER_OFIC_DTLS',
          @Ld_High_DATE          DATE = '12/31/9999';
  DECLARE @Ln_Office_IDNO           NUMERIC (3),
          @Ln_County_IDNO           NUMERIC (3),
          @Ln_OficOthp_IDNO         NUMERIC (9),
          @Lc_County_NAME           CHAR (40) = '',
          @Ls_Office_NAME           VARCHAR (60) = '',
          @Ls_Sql_TEXT              VARCHAR (200) = '',
          @Ls_Sqldata_TEXT          VARCHAR (400) = '',
          @Ls_DescriptionError_TEXT VARCHAR (4000) = '',
          @Ld_CloseOffice_DTTM      DATETIME2;

  BEGIN TRY
   SET @Ac_Msg_CODE = NULL;
   SET @As_DescriptionError_TEXT = NULL;
   SET @Ad_Run_DATE = ISNULL (@Ad_Run_DATE, dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME());
   SET @Ls_Sql_TEXT = 'SELECT CASE_Y1 OFIC_Y1';
   SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + CAST (ISNULL (@An_Case_IDNO, 0) AS VARCHAR);

   INSERT INTO #NoticeElementsData_P1
               (Element_NAME,
                Element_VALUE)
   (SELECT pvt.Element_NAME,
           pvt.Element_VALUE
      FROM (SELECT CONVERT (VARCHAR (100), OtherParty_IDNO) OFICOTHP_IDNO,
                   CONVERT (VARCHAR (100), StartOffice_DTTM) OFFICESTART_DTTM,
                   CONVERT (VARCHAR (100), @Ld_CloseOffice_DTTM) OFFICECLOSE_DTTM,
                   CONVERT (VARCHAR (100), Worker_ID) CASE_WORKER_IDNO,
                   CONVERT (VARCHAR (100), WorkerPh_NUMB) CASE_WRK_PH_NUMB
              FROM (SELECT d.OtherParty_IDNO,
                           d.StartOffice_DTTM,
                           d.CloseOffice_DTTM,
                           a.Worker_ID,
                           (SELECT ISNULL (b.WorkPhone_NUMB, @Lc_Space_TEXT)
                              FROM UASM_Y1 b
                             WHERE b.Worker_ID = a.Worker_ID
                               AND b.Office_IDNO = a.Office_IDNO
                               AND @Ad_Run_DATE BETWEEN b.Effective_DATE AND b.Expire_DATE
                               AND b.EndValidity_DATE = @Ld_High_DATE) AS WorkerPh_NUMB
                      FROM CASE_Y1 a
                           JOIN OFIC_Y1 d
                            ON a.Office_IDNO = d.Office_IDNO
                               AND d.EndValidity_DATE = @Ld_High_DATE
                     WHERE a.Case_IDNO = @An_Case_IDNO) a) up UNPIVOT (Element_VALUE FOR Element_NAME IN (OFICOTHP_IDNO, OFFICESTART_DTTM, OFFICECLOSE_DTTM, CASE_WORKER_IDNO, CASE_WRK_PH_NUMB)) AS pvt);

   SELECT TOP 1 @Ln_County_IDNO = NE.ELEMENT_VALUE
     FROM #NoticeElementsData_P1 NE
    WHERE NE.Element_NAME = 'County_IDNO';

   IF (@Ln_County_IDNO IS NOT NULL)
    BEGIN
     SET @Lc_County_NAME = dbo.BATCH_COMMON_GETS$SF_GETCOUNTYNAME (@Ln_County_IDNO);
    END

   SET @Ls_Sql_TEXT = 'Insert into #NoticeElementsData_P1';
   SET @Ls_Sqldata_TEXT = 'County_NAME = ' + @Lc_County_NAME;

   INSERT INTO #NoticeElementsData_P1
               (Element_NAME,
                Element_VALUE)
        VALUES ('County_NAME',
                @Lc_County_NAME);

   SELECT TOP 1 @Ln_Office_IDNO = NE.ELEMENT_VALUE
     FROM #NoticeElementsData_P1 NE
    WHERE NE.Element_NAME = 'Office_IDNO';

   IF @Ln_Office_IDNO IS NOT NULL
    BEGIN
     SET @Ls_Office_NAME = dbo.BATCH_COMMON_GETS$SF_GET_OFFICECODE (@Ln_Office_IDNO);
    END

   SET @Ls_Sql_TEXT = 'Insert into #NoticeElementsData_P1';
   SET @Ls_Sqldata_TEXT = 'Office_NAME = ' + @Ls_Office_NAME;

   INSERT INTO #NoticeElementsData_P1
               (Element_NAME,
                Element_VALUE)
        VALUES ('Office_NAME',
                @Ls_Office_NAME);

   SET @Ln_OficOthp_IDNO = (SELECT TOP 1 ELEMENT_VALUE
                              FROM #NoticeElementsData_P1
                             WHERE Element_NAME = 'OFICOTHP_IDNO');

   IF (@Ln_OficOthp_IDNO IS NOT NULL)
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_GEN_NOTICE_CM$SP_GET_OTHP_DTLS';
     SET @Ls_Sqldata_TEXT = ' OFIC_ID_OTHP = ' + ISNULL (CAST (@Ln_OficOthp_IDNO AS VARCHAR), '');

     IF (@As_Prefix_TEXT IS NULL
          OR @As_Prefix_TEXT = '')
      BEGIN
       SET @As_Prefix_TEXT = 'case_wrk_ofic';
      END

     EXECUTE BATCH_GEN_NOTICE_CM$SP_GET_OTHP_DTLS
      @An_OtherParty_IDNO       = @Ln_OficOthp_IDNO,
      @As_Prefix_TEXT           = @As_Prefix_TEXT,
      @Ac_Msg_CODE              = @Ac_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;

     IF @Ac_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END
    END

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   DECLARE @Li_Error_NUMB     INT,
           @Li_ErrorLine_NUMB INT;

   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   SET @Li_Error_NUMB = ERROR_NUMBER ();
   SET @Li_ErrorLine_NUMB = ERROR_LINE ();

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
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
  END CATCH
 END


GO
