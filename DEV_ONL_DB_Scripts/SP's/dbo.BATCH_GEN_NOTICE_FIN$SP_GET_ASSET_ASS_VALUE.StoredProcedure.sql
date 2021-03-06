/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICE_FIN$SP_GET_ASSET_ASS_VALUE]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICE_FIN$SP_GET_ASSET_ASS_VALUE
Programmer Name	:	IMP Team.
Description		:	
Frequency		:	
Developed On	:	2/17/2012
Called By		:	
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICE_FIN$SP_GET_ASSET_ASS_VALUE](
 @An_CpMemberMci_IDNO       NUMERIC(10),
 @Ac_Msg_CODE              VARCHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR OUTPUT
 )
AS
 BEGIN
  BEGIN TRY
    DECLARE @Ld_High_DATE               DATE = '12/31/9999',
           @Lc_StatusSuccess_CODE      CHAR(1) = 'S',
           @Lc_StatusFailed_CODE       CHAR(1) = 'F',
           @Lc_CaseMemberStatusA_CODE  CHAR(1) = 'A',
           @Lc_CaseRelationshipCP_CODE CHAR(1) = 'C',
           @Ls_AssetRp_CODE            VARCHAR(3)='RP',
           @Ls_Procedure_NAME            VARCHAR(100) ='BATCH_GEN_NOTICE_FIN$SP_GET_ASSET_ASS_VALUE';
  
  DECLARE   @Ls_Sql_TEXT                VARCHAR(200),
           @Ls_Sqldata_TEXT            VARCHAR(400),
           @Ls_DescriptionError_TEXT   VARCHAR(4000),
           @Ln_MemberMci_IDNO          NUMERIC(10),
           @Ln_ValueAsset_AMNT         NUMERIC(11, 2),
           @Ln_Mortgage_AMNT           NUMERIC(11, 2),
           @Ln_Balance_AMNT            NUMERIC(11, 2);
          

   SET @Ln_ValueAsset_AMNT = NULL;
   SET @Ln_Mortgage_AMNT = NULL;
   SET @Ln_Balance_AMNT = NULL;
   SET @Ac_Msg_CODE = NULL;
   SET @As_DescriptionError_TEXT = NULL;
   SET @Ls_AssetRp_CODE = ISNULL(@Ls_AssetRp_CODE, 'RP');
   SET @Ls_Sqldata_TEXT = ' CpMemberMci_IDNO = ' + ISNULL(CAST(@An_CpMemberMci_IDNO AS CHAR(10)), '');
   SET @Ls_Sql_TEXT = 'SELECT ASRE_Y1';
   WITH Asre_CTE
        AS (SELECT CONVERT (VARCHAR (11), a.ValueAsset_AMNT) AS ValueAsset_AMNT,
                   CONVERT (VARCHAR (11), a.Mortgage_AMNT) AS Mortgage_AMNT,
                   CONVERT (VARCHAR (11), a.Balance_AMNT) AS Balance_AMNT
              FROM (SELECT RE.ValueAsset_AMNT, 
                           RE.Mortgage_AMNT,
                           (RE.ValueAsset_AMNT - RE.Mortgage_AMNT) AS Balance_AMNT
                      FROM ASRE_Y1 RE
                     WHERE RE.MemberMci_IDNO = @An_CpMemberMci_IDNO
                       AND RE.Asset_CODE = @Ls_AssetRp_CODE
                       AND RE.EndValidity_DATE = @Ld_High_DATE) A)
      INSERT INTO #NoticeElementsData_P1
               (Element_NAME,
                Element_Value)
		 SELECT pvt.Element_NAME, pvt.Element_Value
			FROM (SELECT RE.ValueAsset_AMNT,
					   RE.Mortgage_AMNT, 
					   RE.Balance_AMNT
				  FROM Asre_CTE RE) up
				  UNPIVOT (Element_Value FOR Element_NAME IN (ValueAsset_AMNT, Mortgage_AMNT, Balance_AMNT)) AS pvt;        

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
    DECLARE @Li_Error_NUMB INT = ERROR_NUMBER (), @Li_ErrorLine_NUMB INT = ERROR_LINE ();

         SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

         IF (@Li_Error_NUMB <> 50001)
            BEGIN
               SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
            END

         EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION @As_Procedure_NAME      = @Ls_Procedure_NAME,
                                                       @As_ErrorMessage_TEXT   = @Ls_DescriptionError_TEXT,
                                                       @As_Sql_TEXT            = @Ls_Sql_TEXT,
                                                       @As_Sqldata_TEXT        = @Ls_SqlData_TEXT,
                                                       @An_Error_NUMB          = @Li_Error_NUMB,
                                                       @An_ErrorLine_NUMB      = @Li_ErrorLine_NUMB,
                                                       @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT ;
    END CATCH
 END


GO
