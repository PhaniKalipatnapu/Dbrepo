/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICE_MEMBER$SP_MEM_RECENT_PROF_LIC_DTLS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICE_MEMBER$SP_MEM_RECENT_PROF_LIC_DTLS
Programmer Name	:	IMP Team.
Description		:	This procedure is used to get NCP Professional License Details to show on ENF-39 and LOC-07 Notices.
Frequency		:	
Developed On	:	4/27/2012
Called By		:	BATCH_GEN_NOTICE_MEMBER$SP_NCP_PROF_LIC_DTLS
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICE_MEMBER$SP_MEM_RECENT_PROF_LIC_DTLS](
 @An_MemberMci_IDNO        NUMERIC(10),
 @Ad_Run_DATE              DATE,
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
 )
AS
 BEGIN

  SET NOCOUNT ON;
  DECLARE 
          @Lc_StatusSuccess_CODE       CHAR(1) = 'S',             
          @Lc_StatusFailed_CODE        CHAR(1) = 'F', 
          @Lc_Licensestatusactive_CODE CHAR(1) = 'A',
          @Lc_Confirmedgoodstatus_CODE CHAR(2) = 'CG', 
          @Lc_Licensetypecode1000_CODE CHAR(4) ='1000',
          @Lc_Licensetypecode8999_CODE CHAR(4) ='8999',           
          @Lc_TableLict_ID             CHAR(4) = 'LICT',    
          @Lc_TableSubType_ID          CHAR(4) = 'TYPE',    
          @Ls_Procedure_NAME           VARCHAR(100) ='BATCH_GEN_NOTICE_MEMBER$SP_MEM_RECENT_PROF_LIC_DTLS',        
          @Ld_Highdate_DATE            DATE = '12/31/9999';
          
  DECLARE @Ln_Error_NUMB             NUMERIC(11),
          @Ln_ErrorLine_NUMB         NUMERIC(11),       
          @Ls_Sql_TEXT               VARCHAR(200),
          @Ls_Sqldata_TEXT           VARCHAR(400),
          @Ls_DescriptionError_TEXT  VARCHAR(4000);
          
  BEGIN TRY
  
   SET @Ls_Sql_TEXT = 'SELECT PLIC_Y1';
   SET @Ls_Sqldata_TEXT = ' MemberMci_IDNO = ' + ISNULL(CAST(@An_MemberMci_IDNO AS VARCHAR), '');
   
  /* License Type BETWEEN 1000 AND 8999 indicates Professional License.
   If NCP has More than one Professional License, Professional License which is Recently issued will be displayed in Notice.*/
  INSERT INTO #NoticeElementsData_P1
               (Element_Name,
                Element_Value)
   (SELECT pvt.Element_Name,
           pvt.Element_Value
      FROM (SELECT CONVERT(VARCHAR(100), LicenseNo_TEXT) NCP_PROF_LICENSENO_TEXT,
                   CONVERT(VARCHAR(100), IssuingState_CODE) NCP_PROF_LICENSE_ISSUINGSTATE_CODE,
                   ISNULL(CONVERT(VARCHAR(100), DescriptionLicense_TEXT),'') NCP_PROF_LICENSE_DESCRIPTION_TEXT,
                   CONVERT(VARCHAR(100), OtherParty_NAME) NCP_PROF_LIC_AGENCY_NAME
              FROM (SELECT a.LicenseNo_TEXT,
						   a.IssuingState_CODE,
						   a.DescriptionLicense_TEXT,
						   a.OthpLicAgent_IDNO,
						   o.OtherParty_NAME
						   FROM 
							(SELECT TOP 1  p.LicenseNo_TEXT,
										   p.IssuingState_CODE,
										   (SELECT r.DescriptionValue_TEXT
											  FROM REFM_Y1 r
											 WHERE Table_ID = @Lc_TableLict_ID
											   AND TableSub_ID = @Lc_TableSubType_ID
											   AND Value_CODE = p.TypeLicense_CODE) + ' - ' + RTRIM(p.LicenseNo_TEXT) AS DescriptionLicense_TEXT,
										OthpLicAgent_IDNO as OthpLicAgent_IDNO
							  FROM PLIC_Y1 p
							 WHERE p.MemberMci_IDNO = @An_MemberMci_IDNO
							   AND p.TypeLicense_CODE BETWEEN @Lc_Licensetypecode1000_CODE AND @Lc_Licensetypecode8999_CODE
							   AND p.TypeLicense_CODE NOT IN ('DR', 'FIS', 'HUN')
							   AND LEN(RTRIM(p.TypeLicense_CODE)) = 4 
							   AND p.ExpireLicense_DATE > @Ad_Run_DATE
							   AND p.LicenseStatus_CODE = @Lc_Licensestatusactive_CODE
							   AND p.Status_CODE = @Lc_Confirmedgoodstatus_CODE
							   AND p.EndValidity_DATE = @Ld_Highdate_DATE
							   AND p.IssueLicense_DATE = (SELECT TOP 1 MAX(l.IssueLicense_DATE)
														  FROM PLIC_Y1 l
														 WHERE l.MemberMci_IDNO = @An_MemberMci_IDNO
														   AND l.TypeLicense_CODE BETWEEN @Lc_Licensetypecode1000_CODE AND @Lc_Licensetypecode8999_CODE
														   AND l.TypeLicense_CODE NOT IN ('DR', 'FIS', 'HUN')
														   AND LEN(RTRIM(l.TypeLicense_CODE)) = 4
														   AND l.ExpireLicense_DATE > @Ad_Run_DATE
														   AND l.LicenseStatus_CODE = @Lc_Licensestatusactive_CODE
														   AND l.Status_CODE = @Lc_Confirmedgoodstatus_CODE
														   AND l.EndValidity_DATE = @Ld_Highdate_DATE)
							) a, OTHP_Y1 o
						WHERE a.OthpLicAgent_IDNO = o.OtherParty_IDNO
						--13485 - ENF-39 PSOC fields not populating as mapped - Start
						AND o.EndValidity_DATE = @Ld_Highdate_DATE) b
						--13485 - ENF-39 PSOC fields not populating as mapped - End
				) up UNPIVOT (Element_Value FOR Element_Name IN ( NCP_PROF_LICENSENO_TEXT, NCP_PROF_LICENSE_ISSUINGSTATE_CODE, NCP_PROF_LICENSE_DESCRIPTION_TEXT,NCP_PROF_LIC_AGENCY_NAME )) AS pvt);

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   SET @Ln_Error_NUMB = ERROR_NUMBER ();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE ();
   
   IF (@Ln_Error_NUMB <> 50001)
            BEGIN
               SET @Ls_DescriptionError_TEXT =SUBSTRING (ERROR_MESSAGE (), 1, 200);
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
