/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICE_FIN$SP_MEMBER_REALPROPERTY_DETAILS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICE_FIN$SP_MEMBER_REALPROPERTY_DETAILS
Programmer Name	:	IMP Team.
Description		:	This function is used to fetch the property details
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
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICE_FIN$SP_MEMBER_REALPROPERTY_DETAILS]
(
 @An_MemberMci_IDNO				NUMERIC(10),
 @Ad_Run_DATE					DATE,
 @As_Prefix_TEXT				VARCHAR(70),
 @Ac_Msg_CODE					CHAR(5)			OUTPUT,
 @As_DescriptionError_TEXT		VARCHAR(4000)	OUTPUT
 )
AS
 BEGIN
 
  DECLARE  @Li_Error_NUMB            INT = NULL,
           @Li_ErrorLine_NUMB        INT = NULL,
           
           @Lc_StatusSuccess_CODE    CHAR(1) = 'S',
           @Lc_StatusFailed_CODE     CHAR(1) = 'F',
           @Lc_Space_TEXT            CHAR(1) = ' ',
           @Lc_Status_CODE			 CHAR(1) = 'Y',
           @Lc_TableMAST_ID			 CHAR(4) = 'MAST',
           @Lc_TableSubRELP_ID		 CHAR(4) = 'RELP',
           @Ld_Highdate_DATE         DATE = '12/31/9999';
           
  DECLARE  @Ln_RecentOrder_ChildCount_NUMB  NUMERIC(2) = 0,
           @Ln_ExpectToPay_AMNT             NUMERIC(11,2) = 0,
           @Ln_Periodic_AMNT                NUMERIC(11,2) = 0,
           @Ln_ExpectToPay1_AMNT            NUMERIC(11,2) = 0,
           @Ln_Periodic1_AMNT               NUMERIC(11,2) = 0,
           @Ln_CsPeriodic_AMNT              NUMERIC(11,2) = 0,
           @Ln_SsPeriodic_AMNT              NUMERIC(11,2) = 0,
           @Li_RowCount_NUMB                INT = 0,
           @Ls_FrequencyPeriodic1_CODE      VARCHAR(73) = '',
           @Ls_FrequencyPeriodic_CODE       VARCHAR(73) = '',
           @Ls_Procedure_NAME               VARCHAR(100) = 'BATCH_GEN_NOTICE_FIN$SP_MEMBER_REALPROPERTY_DETAILS',
           @Ls_Sql_TEXT                     VARCHAR(400) = '',
           @Ls_Sqldata_TEXT                 VARCHAR(4000) = '',
           @Ls_DescriptionError_TEXT        VARCHAR(4000),
           @Ln_RecentOblicationBegin_DATE   DATE,
           @Ln_InitialOblicationBegin_DATE  DATE;

  BEGIN TRY
 
   SET @Ac_Msg_CODE = NULL;
   SET @As_DescriptionError_TEXT = NULL;

   SET @Ls_Sql_TEXT = ' SELECT ASRE_Y1';
   SET @Ls_Sqldata_TEXT = ' MemberMci_IDNO ' + CAST(ISNULL(@An_MemberMci_IDNO, 0) AS VARCHAR(10)) ;
   
    DECLARE @NoticeElements_P1 TABLE
                                    (
                                       Element_NAME    VARCHAR (100),
                                       Element_VALUE   VARCHAR (100)
                                    );
     
    INSERT INTO @NoticeElements_P1 (Element_NAME, Element_VALUE)
            SELECT pvt.Element_NAME, pvt.Element_VALUE
              FROM (SELECT CONVERT (VARCHAR (100), Asset_Type_TEXT) AS Real_Asset_Type_TEXT,
                           CONVERT (VARCHAR (100), Line1Asset_ADDR) AS Real_Line1Asset_ADDR,
                           CONVERT (VARCHAR (100), Line2Asset_ADDR) AS Real_Line2Asset_ADDR,
                           CONVERT (VARCHAR (100), CityAsset_ADDR) AS  Real_CityAsset_ADDR,
                           CONVERT (VARCHAR (100), StateAsset_ADDR) AS Real_StateAsset_ADDR,
                           CONVERT (VARCHAR (100), CountryAsset_ADDR) AS Real_CountryAsset_ADDR,
                           CONVERT (VARCHAR (100), ZipAsset_ADDR) AS Real_ZipAsset_ADDR,
                           CONVERT (VARCHAR (100), ValueAsset_AMNT) AS RE_ValueAsset_AMNT, 
                           CONVERT (VARCHAR (100), MortgageBalance_AMNT) AS RE_MortgageBalance_AMNT, 
                           CONVERT (VARCHAR (100), Balance_AMNT) AS RE_Balance_AMNT 
       FROM (                               
	   SELECT  TOP 1 dbo.BATCH_COMMON$SF_GET_REFM_DESC_VALUE(@Lc_TableMAST_ID,@Lc_TableSubRELP_ID, c.Asset_CODE) 
				AS Asset_Type_TEXT,
			c.Line1Asset_ADDR,
			c.Line2Asset_ADDR,
			c.CityAsset_ADDR,
			c.StateAsset_ADDR,
			c.CountryAsset_ADDR,
			c.ZipAsset_ADDR,
			c.ValueAsset_AMNT,
			c.MortgageBalance_AMNT,
			(c.ValueAsset_AMNT - c.MortgageBalance_AMNT) AS Balance_AMNT 
			
		FROM ASRE_Y1 C 
		WHERE c.MemberMci_IDNO  = @An_MemberMci_IDNO
		  AND c.EndValidity_DATE = @Ld_Highdate_DATE
		  AND c.Status_CODE = @Lc_Status_CODE) a
         ) up
        UNPIVOT
         (Element_VALUE FOR Element_NAME IN (
				 Real_Asset_Type_TEXT
                ,Real_Line1Asset_ADDR
                ,Real_Line2Asset_ADDR
                ,Real_CityAsset_ADDR
                ,Real_StateAsset_ADDR
                ,Real_CountryAsset_ADDR
                ,Real_ZipAsset_ADDR
                ,RE_ValueAsset_AMNT
                ,RE_MortgageBalance_AMNT
                ,RE_Balance_AMNT
                  ))  AS pvt; 

	SET @Ls_Sql_TEXT = 'INSERT @NoticeElements_P1';
    SET @Ls_Sqldata_TEXT = ' Element_NAME = ' + @As_Prefix_TEXT;

    INSERT INTO #NoticeElementsData_P1 (Element_NAME, Element_VALUE)
    SELECT RTRIM(@As_Prefix_TEXT) + '_' + TE.Element_NAME AS Element_NAME, TE.Element_VALUE
			FROM @NoticeElements_P1 TE;
			
  SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY
  BEGIN CATCH
         SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
         SET @Li_Error_NUMB = ERROR_NUMBER ();
         SET @Li_ErrorLine_NUMB = ERROR_LINE ();

         IF (@Li_Error_NUMB <> 50001)
            BEGIN
               SET @Ls_DescriptionError_TEXT =
                      SUBSTRING (ERROR_MESSAGE (), 1, 200);
            END

         EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION @As_Procedure_NAME = @Ls_Procedure_NAME,
                                                       @As_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT,
                                                       @As_Sql_TEXT = @Ls_Sql_TEXT,
                                                       @As_Sqldata_TEXT = @Ls_SqlData_TEXT,
                                                       @An_Error_NUMB = @Li_Error_NUMB,
                                                       @An_ErrorLine_NUMB = @Li_ErrorLine_NUMB,
                                                       @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT ;

         SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
  END CATCH
 END

GO
