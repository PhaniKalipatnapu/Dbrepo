/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICE_WORKER$SP_GET_WORKER_DTLS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICE_WORKER$SP_GET_WORKER_DTLS
Programmer Name	:	IMP Team.
Description		:	This procedure is used to get logged in Worker details
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
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICE_WORKER$SP_GET_WORKER_DTLS] (
 @Ac_Worker_ID             CHAR (30),
 @As_Prefix_TEXT           VARCHAR (100) = 'LOGIN',
 @Ad_Run_DATE              DATE,
 @Ac_Msg_CODE              CHAR (5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR (4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusSuccess_CODE CHAR(1) = 'S',
          @Lc_StatusFailed_CODE  CHAR(1) = 'F',
          @Lc_Space_TEXT         CHAR(1) = ' ',
          @Lc_TableUsem_ID       CHAR(4) = 'USEM',
          @Lc_TableSubTtls_ID    CHAR(4) = 'TTLS',
          @Ls_Procedure_NAME     VARCHAR(100) = 'BATCH_GEN_NOTICE_WORKER$SP_GET_WORKER_DTLS',
          @Ld_Highdate_DATE      DATE = '12/31/9999';
  DECLARE @Ln_Error_NUMB            NUMERIC(11),
          @Ln_ErrorLine_NUMB        NUMERIC(11),
          @Ls_Sql_TEXT              VARCHAR(200),
          @Ls_Sqldata_TEXT          VARCHAR(400),
          @Ls_DescriptionError_TEXT VARCHAR(4000);

  BEGIN TRY
   SET @AC_Msg_CODE = NULL;
   SET @As_DescriptionError_TEXT = NULL;

   IF (@As_Prefix_TEXT IS NULL
        OR @As_Prefix_TEXT = '')
    BEGIN
     SET @As_Prefix_TEXT = 'LOGIN';
    END

   SET @Ls_Sql_TEXT = 'SELECT USEM_Y1';
   SET @Ls_Sqldata_TEXT = ' Worker_IDNO = ' + ISNULL (@Ac_Worker_ID, '');

   DECLARE @NoticeElements_P1 TABLE (
    Element_NAME  VARCHAR (100),
    Element_VALUE VARCHAR (100));

   INSERT INTO @NoticeElements_P1
               (Element_NAME,
                Element_VALUE)
   SELECT Element_NAME,
          Element_VALUE
     FROM(SELECT CONVERT (VARCHAR (100), a.Last_NAME) AS worker_last_name,
                 CONVERT (VARCHAR (100), a.First_NAME) AS worker_first_name,
                 CONVERT (VARCHAR (100), a.Middle_NAME) AS worker_middle_name,
                 CONVERT (VARCHAR (100), a.Contact_EML) AS worker_contact_eml,
                 CONVERT (VARCHAR (100), a.WorkerFull_NAME) AS worker_full_display_name,
				 --13764 - CR0455 Remapping of Worker Name on Documents 20141205 - Fix - Start
                 CONVERT (VARCHAR (100), a.Last_NAME) AS worker_sso_id,
				 --13764 - CR0455 Remapping of Worker Name on Documents 20141205 - Fix - End
                 CONVERT (VARCHAR (100), a.TransactionEventSeq_NUMB) AS esign_login_worker_text,
                 CONVERT (VARCHAR (100), a.WorkerTitle_Desc) AS WorkerTitle_text,
                 CONVERT (VARCHAR (100), a.County_Name) AS worker_County_Name,
                 CONVERT (VARCHAR (100), a.State_Name) AS worker_State_Name
            FROM (SELECT e.Last_NAME,
                         e.First_NAME,
                         e.Middle_NAME,
                         dbo.BATCH_COMMON$SF_GET_REFM_DESC_VALUE(@Lc_TableUsem_ID, @Lc_TableSubTtls_ID, e.WorkerTitle_CODE) AS WorkerTitle_Desc,
                         e.Contact_EML,
                         (ISNULL (LTRIM (RTRIM (e.First_NAME)), '')
                          + @Lc_Space_TEXT + ISNULL (LTRIM (RTRIM (e.Last_NAME)), '')) AS WorkerFull_NAME,
                         lc.County_Name,
                         lc.State_Name,
                         s.TransactionEventSeq_NUMB
                    FROM USEM_Y1 e
                         LEFT OUTER JOIN USES_Y1 s
                          ON e.Worker_ID = s.Worker_ID
                             AND LTRIM (RTRIM (s.ESignature_BIN)) IS NOT NULL
                         OUTER APPLY (SELECT TOP 1 co.County_Name AS County_Name,
                                                   'DE' AS State_Name
                                        FROM UASM_Y1 ua,
                                             COPT_Y1 co
                                       WHERE ua.Worker_ID = e.Worker_ID
                                         AND ua.Office_IDNO = co.County_IDNO
                                         AND @Ad_Run_DATE BETWEEN ua.Effective_DATE AND ua.Expire_DATE
                                         AND ua.EndValidity_DATE = @Ld_Highdate_DATE) lc
                   WHERE e.Worker_ID = @Ac_Worker_ID
                     AND e.EndValidity_DATE = @Ld_Highdate_DATE
                     AND @Ad_Run_DATE BETWEEN e.BeginEmployment_DATE AND e.EndEmployment_DATE) a) up UNPIVOT (Element_VALUE FOR Element_NAME IN (worker_last_name, worker_first_name, worker_middle_name,
                           worker_contact_eml, worker_full_display_name, worker_sso_id, esign_login_worker_text, WorkerTitle_text, worker_County_Name, worker_State_Name)) AS pvt;

   SET @Ls_Sql_TEXT = 'UPDATE @NoticeElements_P1';
   SET @Ls_Sqldata_TEXT = ' @Prefix_TEXT = ' + @As_Prefix_TEXT;

   INSERT INTO #NoticeElementsData_P1
               (Element_NAME,
                Element_VALUE)
   SELECT @As_Prefix_TEXT + '_' + Element_NAME AS Element_NAME,
          TE.Element_VALUE
     FROM @NoticeElements_P1 TE;

   SET @Ls_Sql_TEXT ='SElECT #NoticeElementsData_P1';
   SET @Ls_Sqldata_TEXT='Element_NAME = ' + 'esign_login_worker_text';

   UPDATE #NoticeElementsData_P1
      SET Element_NAME = 'esign_login_worker_text'
    WHERE (Element_NAME = 'case_esign_login_worker_text'
            OR Element_NAME = 'login_esign_login_worker_text')
      AND NOT EXISTS (SELECT 1
                        FROM #NoticeElementsData_P1
                       WHERE Element_NAME = 'esign_login_worker_text');

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
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
