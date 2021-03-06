/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICES$SP_GET_ASFN_LIEN_DETAILS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICES$SP_GET_ASFN_LIEN_DETAILS
Programmer Name	:	IMP Team.
Description		:	The procedure is used to obtain the ASFN LIEN details.
Frequency		:	
Developed On	:	4/19/2012
Called By		:	
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICES$SP_GET_ASFN_LIEN_DETAILS] (
 @An_Case_IDNO             NUMERIC (6),
 @An_MemberMci_IDNO        NUMERIC (10),
 @An_MajorIntSeq_NUMB      NUMERIC (5),
 @Ac_Msg_CODE              CHAR (5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR (4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusSuccess_CODE    CHAR (1) = 'S',
          @Lc_StatusFailed_CODE     CHAR (1) = 'F',
          @Lc_Yes_TEXT              CHAR (1) = 'Y',
          @Ls_Procedure_NAME        VARCHAR (100) = 'BATCH_GEN_NOTICES$SP_GET_ASFN_LIEN_DETAILS',
          @Ld_High_DATE             DATE = '12/31/9999';
  DECLARE @Ln_Error_NUMB     NUMERIC (11),
          @Ln_ErrorLine_NUMB NUMERIC (11),
          
          @Ls_Sql_TEXT       VARCHAR (200),
          @Ls_SqlData_TEXT   VARCHAR (400),
          @Ls_DescriptionError_TEXT VARCHAR (4000) = '';

  BEGIN TRY
   SET @Ac_Msg_CODE = NULL;
   SET @As_DescriptionError_TEXT = NULL;
   SET @Ls_Sql_TEXT = 'INSERT #NoticeElementsData_P1';
   SET @Ls_SqlData_TEXT = 'Case_IDNO =	' + ISNULL (CAST (@An_Case_IDNO AS VARCHAR(6)), '') + ', MemberMci_IDNO = ' + ISNULL (CAST (@An_MemberMci_IDNO AS VARCHAR(10)), '') + ', MajorIntSeq_NUMB = ' + ISNULL (CAST (@An_MajorIntSeq_NUMB AS VARCHAR(10)), '');

	--13512 - CR0392 Amend Mapping of Claim Loss Date 20140616 - Fix - Start
   INSERT INTO #NoticeElementsData_P1
               (ELEMENT_NAME,
                ELEMENT_VALUE)
   (SELECT ELEMENT_NAME,
           ELEMENT_VALUE
      FROM (SELECT CAST (a.AccountAssetNo_TEXT AS VARCHAR (100)) AS LIEN_AccountAssetNo_TEXT,
                   CAST (a.ClaimLoss_DATE AS VARCHAR (100)) AS LIEN_CLAIM_DATE,
                   CAST (a.OtherParty_NAME AS VARCHAR (100)) AS INSURANCECMPNY_OTHP_NAME,
                   CAST (a.Potential_AMNT AS VARCHAR (100)) AS LIEN_AMNT
              FROM (SELECT a.AccountAssetNo_TEXT,
                           a.Potential_AMNT,
                           a.ClaimLoss_DATE,
                           o.OtherParty_NAME
                      FROM ASFN_Y1 a
                           JOIN (SELECT TypeReference_CODE,
                                        Reference_ID,
                                        OthpSource_IDNO,
                                        MemberMci_IDNO
                                   FROM DMJR_Y1 d
                                  WHERE d.Case_IDNO = @An_Case_IDNO
                                    AND d.MemberMci_IDNO = @An_MemberMci_IDNO
                                    AND d.MajorIntSeq_NUMB = @An_MajorIntSeq_NUMB) b
                            ON a.Asset_code = b.TypeReference_CODE
                               AND a.AccountAssetNo_TEXT = b.Reference_ID
                               AND a.OthpInsFin_IDNO = b.OthpSource_IDNO
                               AND a.MemberMci_IDNO = b.MemberMci_IDNO
                           JOIN OTHP_Y1 o
                            ON o.OtherParty_IDNO = a.OthpInsFin_IDNO
                               AND o.EndValidity_DATE = @Ld_High_DATE
                     WHERE a.EndValidity_DATE = @Ld_High_DATE
                       AND a.Status_CODE = @Lc_Yes_TEXT) a) 
                       UP UNPIVOT (ELEMENT_VALUE FOR ELEMENT_NAME IN (LIEN_AccountAssetNo_TEXT, 
																	  LIEN_CLAIM_DATE,
																	  INSURANCECMPNY_OTHP_NAME, 
																	  LIEN_AMNT
																	  )) AS Pvt);
		--13512 - CR0392 Amend Mapping of Claim Loss Date 20140616 - Fix - End
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
