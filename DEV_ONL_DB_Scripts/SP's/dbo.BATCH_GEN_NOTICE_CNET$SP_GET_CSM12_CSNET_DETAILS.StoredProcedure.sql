/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICE_CNET$SP_GET_CSM12_CSNET_DETAILS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
---------------------------------------------------------
 Procedure Name    :BATCH_GEN_NOTICE_CNET$SP_GET_CSM12_CSNET_DETAILS
 Programmer Name   : IMP Team
 Description       :This procedure is to check whether any of the transactions are triggered from ISND
 Frequency         :
 Developed On      :02-AUG-2011
 Called By         :BATCH_COMMON$SP_FORMAT_BUILD_XML
 Called On         :
---------------------------------------------------------
 Modified By       :
 Modified On       :
 Version No        :1.0  
---------------------------------------------------------
*/ 
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICE_CNET$SP_GET_CSM12_CSNET_DETAILS](
 @An_Case_IDNO             NUMERIC(6),
 @Ac_Msg_CODE              CHAR(5)			OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000)	OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusSuccess_CODE			CHAR(1)			= 'S',
          @Lc_StatusFailed_CODE				CHAR(1)			= 'F',
          @Lc_CheckBoxValue_TEXT			CHAR(1)			= 'X',
          @Lc_ActionR_CODE					CHAR(1)			= 'R',
          @Lc_StatusRequestPn_CODE			CHAR(2)			= 'PN',
          @Lc_FunctionMsc_CODE				CHAR(3)			= 'MSC',
          @Lc_FunctionEnf_CODE				CHAR(3)			= 'ENF',
          @Lc_FunctionEst_CODE				CHAR(3)			= 'EST',
          @Lc_FunctionPat_CODE				CHAR(3)			= 'PAT',
          @Lc_ReasonErall_CODE				CHAR(5)			= 'ERALL',
          @Lc_ReasonErarr_CODE				CHAR(5)			= 'ERARR',
          @Lc_ReasonErmee_CODE				CHAR(5)			= 'ERMEE',
          @Lc_ReasonErmem_CODE				CHAR(5)			= 'ERMEM',
          @Lc_ReasonErmeo_CODE				CHAR(5)			= 'ERMEO',
          @Lc_ReasonErreg_CODE				CHAR(5)			= 'ERREG',
          @Lc_ReasonErreo_CODE				CHAR(5)			= 'ERREO',
          @Lc_ReasonErres_CODE				CHAR(5)			= 'ERRES',
          @Lc_ReasonGrupd_CODE				CHAR(5)			= 'GRUPD',
          @Lc_ReasonSradj_CODE				CHAR(5)			= 'SRADJ',
          @Lc_ReasonSrmod_CODE				CHAR(5)			= 'SRMOD',
          @Lc_ReasonSromc_CODE				CHAR(5)			= 'SROMC',
          @Lc_ReasonSropp_CODE				CHAR(5)			= 'SROPP',
          @Lc_ReasonSrord_CODE				CHAR(5)			= 'SRORD',
          @Lc_ReasonSrpat_CODE				CHAR(5)			= 'SRPAT',
          @Lc_ElfcJob_ID					CHAR(7)			= 'DEB0665',
          @Ls_Procedure_NAME				VARCHAR(100)	= 'BATCH_GEN_NOTICE_CNET$SP_GET_CSM12_CSNET_DETAILS';
          
  DECLARE @Lc_OutOfStateCorrespondence_TEXT CHAR(1)			= '',
          @Lc_ReciprocalPetition_TEXT       CHAR(1)			= '',
          @Lc_StatusRequest_TEXT            CHAR(1)			= '',
          @Lc_EnforcementRequest_TEXT       CHAR(1)			= '',
          @Ls_Sql_TEXT                      VARCHAR(200)	= 'SELECT CSPR_Y1',
          @Ls_SqlData_TEXT                  VARCHAR(400)	= '  Case_IDNO = ' + CAST(@An_Case_IDNO AS CHAR(6)),
          @Ls_DescriptionError_TEXT         VARCHAR(4000),
          @Ld_PrevioudRun_DATE              DATE;

  BEGIN TRY
   SET @Ac_Msg_CODE = '';
   SET @As_DescriptionError_TEXT = '';

   SELECT @Ld_PrevioudRun_DATE = Run_DATE
     FROM PARM_Y1
    WHERE Job_ID = @Lc_ElfcJob_ID;

   IF EXISTS(SELECT 1
               FROM CSPR_Y1 c
              WHERE c.Case_IDNO = @An_Case_IDNO
                AND c.Generated_DATE >= @Ld_PrevioudRun_DATE
                AND c.StatusRequest_CODE = @Lc_StatusRequestPn_CODE
                AND c.Function_CODE IN (@Lc_FunctionEst_CODE, @Lc_FunctionPat_CODE)
                AND c.Action_CODE = @Lc_ActionR_CODE
                AND c.Reason_CODE IN(@Lc_ReasonSradj_Code, @Lc_ReasonSrmod_Code, @Lc_ReasonSromc_Code, @Lc_ReasonSropp_Code, 
                                     @Lc_ReasonSrord_Code, @Lc_ReasonSrpat_Code, ''))
    BEGIN
     SET @Lc_ReciprocalPetition_TEXT = @Lc_CheckBoxValue_TEXT;
    END

   IF EXISTS(SELECT 1
               FROM CSPR_Y1 c
              WHERE c.Case_IDNO = @An_Case_IDNO
                AND c.Generated_DATE >= @Ld_PrevioudRun_DATE
                AND c.StatusRequest_CODE = @Lc_StatusRequestPn_CODE
                AND c.Function_CODE = @Lc_FunctionMsc_CODE
                AND c.Action_CODE = @Lc_ActionR_CODE
                AND c.Reason_CODE = @Lc_ReasonGrupd_Code)
    BEGIN
     SET @Lc_StatusRequest_TEXT = @Lc_CheckBoxValue_TEXT;
    END;

   IF EXISTS(SELECT 1
               FROM CSPR_Y1 c
              WHERE c.Case_IDNO = @An_Case_IDNO
                AND c.Generated_DATE >= @Ld_PrevioudRun_DATE
                AND c.StatusRequest_CODE = @Lc_StatusRequestPn_CODE
                AND c.Function_CODE = @Lc_FunctionEnf_CODE
                AND c.Action_CODE = @Lc_ActionR_CODE
                AND c.Reason_CODE IN (@Lc_ReasonErmeo_Code, @Lc_ReasonErreg_Code, @Lc_ReasonErreo_Code, @Lc_ReasonErres_Code,
                                      @Lc_ReasonErall_Code, @Lc_ReasonErarr_Code, @Lc_ReasonErmee_Code, @Lc_ReasonErmem_Code))
   BEGIN
     SET @Lc_EnforcementRequest_TEXT = @Lc_CheckBoxValue_TEXT;
   END;

   IF ((@Lc_ReciprocalPetition_TEXT = @Lc_CheckBoxValue_TEXT)
        OR (@Lc_StatusRequest_TEXT = @Lc_CheckBoxValue_TEXT)
        OR (@Lc_EnforcementRequest_TEXT = @Lc_CheckBoxValue_TEXT))
   BEGIN
     SET @Lc_OutOfStateCorrespondence_TEXT = @Lc_CheckBoxValue_TEXT;
   END;
   SET @Ls_Sql_TEXT = 'SELECT #NoticeElementsData_P1';
   SET @Ls_SqlData_TEXT = 'Element_NAME = ' ;
   INSERT INTO #NoticeElementsData_P1
               (Element_NAME,
                Element_VALUE)
   (SELECT Element_NAME,
           Element_VALUE
      FROM (SELECT CONVERT(VARCHAR(100), out_of_state_correspondence_code) out_of_state_correspondence_code,
                   CONVERT(VARCHAR(100), reciprocal_petition_code) reciprocal_petition_code,
                   CONVERT(VARCHAR(100), status_request_code) status_request_code,
                   CONVERT(VARCHAR(100), enforcement_request_text) enforcement_request_text
              FROM (SELECT @Lc_OutOfStateCorrespondence_TEXT AS out_of_state_correspondence_code,
                           @Lc_ReciprocalPetition_TEXT AS reciprocal_petition_code,
                           @Lc_StatusRequest_TEXT AS status_request_code,
                           @Lc_EnforcementRequest_TEXT AS enforcement_request_text) h) up UNPIVOT (Element_VALUE FOR Element_NAME IN ( out_of_state_correspondence_code, reciprocal_petition_code, status_request_code, enforcement_request_text ) ) AS pvt);

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

   DECLARE @Li_Error_NUMB     INT = ERROR_NUMBER (),
           @Li_ErrorLine_NUMB INT = ERROR_LINE ();

   IF (@Li_Error_NUMB <> 50001)
    BEGIN
     SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END;

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_SqlData_TEXT,
    @An_Error_NUMB            = @Li_Error_NUMB,
    @An_ErrorLine_NUMB        = @Li_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;
  END CATCH;
 END;


GO
