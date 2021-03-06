/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICES$SP_GET_NCP_LIC_NUMBER_DETAILS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICES$SP_GET_NCP_LIC_NUMBER_DETAILS](
 @An_Case_IDNO				NUMERIC(6),
 @An_MajorIntSeq_NUMB		NUMERIC(5),
 @Ad_Run_DATE				DATE,
 @Ac_Msg_CODE				CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT  VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusSuccess_CODE			CHAR(1) = 'S',
          @Lc_StatusFailed_CODE				CHAR(1) = 'F',
		  @Lc_TypeLicenseDr_CODE			CHAR(5) = 'DR',
		  @Lc_StatusCg_CODE					CHAR(2) = 'CG',
		  @Lc_LicenseStatusActive_CODE		CHAR(1) = 'A',
		  @Lc_LicenseStatusInactive_CODE	CHAR(1) = 'I',
		  @Lc_TableLict_ID					CHAR(4) = 'LICT',
		  @Lc_TableSubType_ID				CHAR(4) = 'TYPE',
		  @Lc_StatusStrt_CODE				CHAR(4) = 'STRT',
          @Ls_Procedure_NAME				VARCHAR(100) = 'BATCH_GEN_NOTICES$SP_GET_NCP_LIC_NUMBER_DETAILS',
          @Ld_High_DATE						DATE = '12/31/9999';
  DECLARE @Ln_Reference_ID					NUMERIC(10), 
          @Ln_Error_NUMB					NUMERIC(11),
          @Ln_ErrorLine_NUMB				NUMERIC(11),
          @Ls_Sql_TEXT						VARCHAR(200),
          @Ls_Sqldata_TEXT					VARCHAR(400),
          @Ls_DescriptionError_TEXT			VARCHAR(4000) = '';

  BEGIN TRY
	 SET @Ac_Msg_CODE = NULL;
	 SET @As_DescriptionError_TEXT = NULL;

     SET @Ls_Sql_TEXT = ' INSERT #NoticeElementsData_P1 ';
     SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '') + 'MajorIntSeq_NUMB=' + ISNULL(CAST(@An_MajorIntSeq_NUMB AS VARCHAR), '') + 
							'Run_DATE=' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') ;

     INSERT INTO #NoticeElementsData_P1
                 (Element_Name,
                  Element_Value)
     (SELECT Element_Name,
             Element_Value
        FROM (SELECT CONVERT(VARCHAR(100), TypeLicense_CODE) LICENCE_TYPE,
					 CONVERT(VARCHAR(100), LicenseNo_TEXT) LICENCE_NUMB,
					 CONVERT(VARCHAR(100), OtherParty_NAME) LICENCE_AGENCY
                FROM (SELECT dbo.BATCH_COMMON_GETS$SF_GET_REFMDESC (@Lc_TableLict_ID,@Lc_TableSubType_ID,TypeLicense_CODE) AS TypeLicense_CODE,
                  LicenseNo_TEXT,
                  OtherParty_NAME
             FROM PLIC_Y1 P,
                  OTHP_Y1 O,
                  DMJR_Y1 D
            WHERE D.Case_IDNO = @An_Case_IDNO
			  AND D.MajorIntSeq_NUMB = @An_MajorIntSeq_NUMB
              AND P.EndValidity_DATE = @Ld_High_DATE
              AND O.EndValidity_DATE = @Ld_High_DATE
              AND O.OtherParty_IDNO = P.OthpLicAgent_IDNO
              AND P.MemberMci_IDNO =  D.MemberMci_IDNO
              AND D.OthpSource_IDNO = P.OthpLicAgent_IDNO
              AND D.OthpSource_IDNO = O.OtherParty_IDNO
              AND D.Reference_ID = P.LicenseNo_TEXT
              --13790 - ENF-18 - Display issue when more than 1 license type have same license number - Fix - Start
              AND D.TypeReference_CODE = P.TypeLicense_CODE 
              --13790 - ENF-18 - Display issue when more than 1 license type have same license number - Fix - End
              AND d.Status_CODE = @Lc_StatusStrt_CODE
			  --13627 - Comments from BATCH_GEN_NOTICES$SP_GET_NCP_LIC_NUMB_LIST,License Suspension eligibility should not require an active license for DMV Fix -Start
              AND ((P.TypeLicense_CODE = @Lc_TypeLicenseDr_CODE AND P.LicenseStatus_CODE IN(@Lc_LicenseStatusActive_CODE,@Lc_LicenseStatusInactive_CODE)) 
						OR (P.TypeLicense_CODE != @Lc_TypeLicenseDr_CODE AND P.LicenseStatus_CODE !=@Lc_LicenseStatusInactive_CODE)) 
			  --13627 - Comments from BATCH_GEN_NOTICES$SP_GET_NCP_LIC_NUMB_LIST,License Suspension eligibility should not require an active license for DMV Fix -End
              AND P.Status_CODE = @Lc_StatusCg_CODE
              AND @Ad_Run_DATE BETWEEN P.IssueLicense_DATE AND P.ExpireLicense_DATE)a) up UNPIVOT (Element_Value FOR Element_Name IN ( LICENCE_TYPE, LICENCE_NUMB, LICENCE_AGENCY)) AS pvt);

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
 END;


GO
