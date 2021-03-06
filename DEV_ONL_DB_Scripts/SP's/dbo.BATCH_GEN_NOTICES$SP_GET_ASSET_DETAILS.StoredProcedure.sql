/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICES$SP_GET_ASSET_DETAILS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICES$SP_GET_ASSET_DETAILS] (
   @An_Case_IDNO                      NUMERIC (6),
   @An_MemberMci_IDNO                 NUMERIC (10),
   @An_MajorIntSeq_NUMB               NUMERIC (5),
   @Ac_ActivityMajor_CODE             CHAR(4),
   @Ac_Msg_CODE                       CHAR (5) OUTPUT,
   @As_DescriptionError_TEXT          VARCHAR (4000) OUTPUT)
AS
   /*
   ------------------------------------------------------------------------------------------------------------------------------
   Procedure Name  : BATCH_GEN_NOTICES$SP_GET_ASSET_DETAILS
   Programmer Name : IMP Team
   Description     :
   Frequency       :
   Developed On    : 01/23/2013
   Called BY       : None
   Called On       :
   -------------------------------------------------------------------------------------------------------------------------------
   Modified BY     :
   Modified On     :
   Version No      : 1.0
   --------------------------------------------------------------------------------------------------------------------------------
   */

   BEGIN
      SET  NOCOUNT ON;
      DECLARE
         @Lc_StatusFailed_CODE		CHAR(1)			= 'F',
         @Lc_StatusSuccess_CODE		CHAR(1)			= 'S',
         @Lc_AcctTypePi_CODE		CHAR(2)			= 'PI',
         @Lc_AcctTypeWc_CODE		CHAR(2)			= 'WC',
         @Ls_Procedure_NAME			VARCHAR(100)	= 'BATCH_GEN_NOTICES$SP_GET_ASSET_DETAILS',
         @Ls_DescriptionError_TEXT	VARCHAR(4000)	= '',
         @Ld_High_DATE				DATE			= '12/31/9999';
       DECLARE
         @Ln_Error_NUMB				NUMERIC(11),
         @Ln_ErrorLine_NUMB			NUMERIC(11),
         @Ls_Sql_TEXT				VARCHAR(200),
         @Ls_Sqldata_TEXT			VARCHAR(400);

      BEGIN TRY
          IF (    @An_MemberMci_IDNO IS NOT NULL
             AND @An_MemberMci_IDNO > 0)
            
            BEGIN
               SET @Ls_Sql_TEXT = 'INSERT #NoticeElements_P1';
               SET @Ls_Sqldata_TEXT =
                      ' Case_IDNO '
                      + ISNULL (CAST (@An_Case_IDNO AS VARCHAR (10)), '')
                      + ', MemberMci_IDNO =	'
                      + ISNULL (CAST (@An_MemberMci_IDNO AS VARCHAR (10)), '')
                      + ', ActivityMajor_CODE = '
                      +  @Ac_ActivityMajor_CODE ;

               DECLARE @NoticeElements_P1 TABLE
                                          (
                                             Element_NAME    VARCHAR (100),
                                             Element_VALUE   VARCHAR (100)
                                          );

               INSERT INTO #NoticeElementsData_P1 (Element_NAME, Element_Value)
                  (SELECT pvt.Element_NAME, pvt.Element_Value
                     FROM (SELECT 
                                  CONVERT (VARCHAR (100), a.PI_CLAIM_INDC) AS NCP_PI_CLAIM_INDC,
                                  CONVERT (VARCHAR (100), a.WC_CLAIM_INDC) AS NCP_WC_CLAIM_INDC
                             FROM ( select  CASE WHEN a.AcctType_CODE IN ('PI') THEN 'X' ELSE '' END
                                             AS PI_CLAIM_INDC,
                                          CASE WHEN a.AcctType_code IN ('WC') THEN 'X' ELSE '' END
                                             AS WC_CLAIM_INDC  
                             FROM ASFN_Y1 a
                             WHERE a.MemberMci_IDNO = (SELECT d.MemberMci_IDNO 
                                                        FROM DMJR_Y1 d 
                                                       WHERE d.MemberMci_IDNO= @An_MemberMci_IDNO 
														  AND d.Case_idno=@An_Case_IDNO
														  And d.ActivityMajor_CODE = @Ac_ActivityMajor_CODE 
														  AND d.MajorIntSeq_NUMB = @An_MajorIntSeq_NUMB  
														  AND d.MemberMci_IDNO = a.MemberMci_IDNO 
														  And d.OthpSource_IDNO	= a.OthpInsFin_IDNO
														  AND d.TypeReference_CODE = a.Asset_CODE
														  AND d.Reference_ID = a.AccountAssetNo_TEXT)
								AND a.EndValidity_DATE =  @Ld_High_DATE
								) a)
                                           up UNPIVOT (Element_Value FOR
                                             Element_NAME IN (NCP_PI_CLAIM_INDC, NCP_WC_CLAIM_INDC)) AS pvt);
              
            END;
            SET @Ac_MSG_CODE = @Lc_StatusSuccess_CODE;
      END TRY
      BEGIN CATCH
         SELECT @Ac_Msg_CODE = @Lc_StatusFailed_CODE,
                @Ln_Error_NUMB = ERROR_NUMBER (),
                @Ln_ErrorLine_NUMB = ERROR_LINE ();

         IF ERROR_NUMBER () <> 50001
            BEGIN
               SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
            END

         EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION @As_Procedure_NAME   = @Ls_Procedure_NAME,
                                                       @As_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT,
                                                       @As_Sql_TEXT         = @Ls_Sql_TEXT,
                                                       @As_Sqldata_TEXT     = @Ls_Sqldata_TEXT,
                                                       @An_Error_NUMB       = @Ln_Error_NUMB,
                                                       @An_ErrorLine_NUMB   = @Ln_ErrorLine_NUMB,
                                                       @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT ;
         SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
      END CATCH
   END;

GO
