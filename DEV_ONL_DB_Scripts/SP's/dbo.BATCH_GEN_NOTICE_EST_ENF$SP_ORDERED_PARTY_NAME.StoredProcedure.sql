/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICE_EST_ENF$SP_ORDERED_PARTY_NAME]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
---------------------------------------------------------
 Procedure Name     : BATCH_GEN_NOTICE_EST_ENF$SP_ORDERED_PARTY_NAME
 Programmer Name    : IMP Team
 Description        : This procedure is used to get ordered Party Name, address, Phone Number, FEIN ID Number and Member SSN Number.
 Frequency          :
 Developed On       : 02-08-2011
 Called By          : BATCH_COMMON$SP_FORMAT_BUILD_XML
 Called On          :
---------------------------------------------------------
 Modified By        :
 Modified On        :
 Version No         : 1.0  
---------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICE_EST_ENF$SP_ORDERED_PARTY_NAME](
 @An_Case_IDNO					NUMERIC(6),
 @An_MajorIntSeq_NUMB			NUMERIC(5),
 @Ac_Msg_CODE					CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT		VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
 SET NOCOUNT ON;
  DECLARE @Lc_Space_TEXT  CHAR(1) = ' ', 
		  @Lc_StatusSuccess_CODE     CHAR(1)		= 'S',
          @Lc_StatusFailed_CODE      CHAR(1)		= 'F',
          @Lc_NoticeEnf04_ID		 CHAR(8)		= 'ENF-04',
          @Lc_NoticeEnf12_ID		 CHAR(8)		= 'ENF-12',
          @Lc_Notice_ID				 CHAR(8)		= '',
          @Ls_Sql_TEXT               VARCHAR(200)	= 'SELECT DEMO_Y1,DMJR_Y1,OTHP_Y1,EHIS_Y1',
          @Ls_SqlData_TEXT           VARCHAR(400)	= ' Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS CHAR), ''),
          @Ld_High_DATE              DATE			= '12/31/9999',
          @Ld_Today_DATE			 DATE			= DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();          
  DECLARE @Ls_DescriptionError_TEXT  VARCHAR(4000);
  BEGIN TRY
   SET @Ac_Msg_CODE = NULL;
   SET @As_DescriptionError_TEXT = NULL;
   
   SET @Ls_Sql_TEXT = 'SELECT Notice_ID FROM #NoticeElementsData_P1';
   
   SELECT @Lc_Notice_ID = Element_VALUE FROM #NoticeElementsData_P1 WHERE Element_NAME = 'Notice_ID'
   
   SET @Ls_Sql_TEXT = 'INSERT #NoticeElementsData_P1';
   SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + CAST(ISNULL(@An_Case_IDNO, 0) AS VARCHAR(6)) +' MajorIntSeq_NUMB = ' + CAST(ISNULL(@An_MajorIntSeq_NUMB, 0) AS VARCHAR);
   INSERT INTO #NoticeElementsData_P1
               (Element_NAME,
                Element_VALUE)
   (SELECT pvt.Element_NAME,
           pvt.Element_VALUE
      FROM (SELECT TOP 1 CONVERT(VARCHAR(100), a.First_NAME) AS ORDERED_PARTY_FIRST_NAME,
                   CONVERT(VARCHAR(100), a.Last_NAME) AS ORDERED_PARTY_LAST_NAME,
                   CONVERT(VARCHAR(100), a.Middle_NAME) AS ORDERED_PARTY_MIDDLE_NAME,
                   CONVERT(VARCHAR(100), a.Suffix_NAME) AS ORDERED_PARTY_SUFFIX_NAME,
                   CONVERT(VARCHAR(100), a.OtherParty_NAME) AS ORDERED_PARTY_EMPL_NAME,
                   CONVERT(VARCHAR(100), a.Attn_ADDR) AS ORDERED_PARTY_EMPL_ATTN_ADDR,
                   CONVERT(VARCHAR(100), a.Line1_ADDR) AS ORDERED_PARTY_EMPL_LINE1_ADDR,
                   CONVERT(VARCHAR(100), a.Line2_ADDR) AS ORDERED_PARTY_EMPL_LINE2_ADDR,
                   CONVERT(VARCHAR(100), a.City_ADDR) AS ORDERED_PARTY_EMPL_CITY_ADDR,
                   CONVERT(VARCHAR(100), a.State_ADDR) AS ORDERED_PARTY_EMPL_STATE_ADDR,
                   CONVERT(VARCHAR(100), a.Country_ADDR) AS ORDERED_PARTY_EMPL_COUNTRY_ADDR,
                   CONVERT(VARCHAR(100), a.Zip_ADDR) AS ORDERED_PARTY_EMPL_ZIP_ADDR,
                   CONVERT(VARCHAR(100), a.Attn_ADDR_MEMBER) AS ORDERED_PARTY_ATTN_ADDR,
                   CONVERT(VARCHAR(100), a.Line1_ADDR_MEMBER) AS ORDERED_PARTY_LINE1_ADDR,
                   CONVERT(VARCHAR(100), a.Line2_ADDR_MEMBER) AS ORDERED_PARTY_LINE2_ADDR,
                   CONVERT(VARCHAR(100), a.City_ADDR_MEMBER) AS ORDERED_PARTY_CITY_ADDR,
                   CONVERT(VARCHAR(100), a.State_ADDR_MEMBER) AS ORDERED_PARTY_STATE_ADDR,
                   CONVERT(VARCHAR(100), a.Country_ADDR_MEMBER) AS ORDERED_PARTY_COUNTRY_ADDR,
                   CONVERT(VARCHAR(100), a.Zip_ADDR_MEMBER) AS ORDERED_PARTY_ZIP_ADDR,
                   CONVERT(VARCHAR(100), a.Phone_NUMB) AS ORDERED_PARTY_EMPL_PHONE_NUMB,
                   CONVERT(VARCHAR(100), a.Fein_IDNO) AS ORDERED_PARTY_EMPL_FEIN_IDNO,
                   CONVERT(VARCHAR(100), a.MemberSsn_NUMB) AS ORDERED_PARTY_MEMBER_SSN_NUMB
              FROM (SELECT d.First_NAME,
						   d.Last_NAME,
                           d.Middle_NAME,
                           d.Suffix_NAME,
                           o.OtherParty_NAME,
                           o.Attn_ADDR,
                           o.Line1_ADDR,
                           o.Line2_ADDR,
                           o.City_ADDR,
                           o.State_ADDR,
                           o.Country_ADDR,
                           o.Zip_ADDR,
                           n.Attn_ADDR AS Attn_ADDR_MEMBER,
                           n.Line1_ADDR AS Line1_ADDR_MEMBER,
                           n.Line2_ADDR AS Line2_ADDR_MEMBER,
                           n.City_ADDR AS City_ADDR_MEMBER,
                           @Lc_Space_TEXT  +  RTRIM(n.State_ADDR)  + @Lc_Space_TEXT AS State_ADDR_MEMBER,
                           n.Country_ADDR AS Country_ADDR_MEMBER,
                           n.Zip_ADDR AS Zip_ADDR_MEMBER,
                           o.Phone_NUMB,
                           o.Fein_IDNO,
                           d.MemberSsn_NUMB,
                           CASE WHEN n.TypeAddress_CODE = 'M' AND n.Status_CODE  = 'Y' AND n.End_DATE >= @Ld_Today_DATE THEN 1  
               WHEN n.TypeAddress_CODE = 'R' AND n.Status_CODE  = 'Y' AND n.End_DATE >= @Ld_Today_DATE THEN 2  
               WHEN n.TypeAddress_CODE = 'C' AND n.Status_CODE  = 'Y' AND n.End_DATE >= @Ld_Today_DATE THEN 3  
               WHEN n.TypeAddress_CODE = 'M' AND n.Status_CODE  = 'P' AND n.End_DATE >= @Ld_Today_DATE THEN 4  
               WHEN n.TypeAddress_CODE = 'R' AND n.Status_CODE  = 'P' AND n.End_DATE >= @Ld_Today_DATE THEN 5  
               WHEN n.TypeAddress_CODE = 'M' AND n.End_DATE < @Ld_Today_DATE THEN 6  
               WHEN n.TypeAddress_CODE = 'R' THEN 7 
			   ELSE 8  
			   END AS addr_hrchy
			   FROM (SELECT OthpSource_IDNO,
                                   CAST(m.Reference_ID AS NUMERIC) Reference_ID
                              FROM DMJR_Y1 m
                             WHERE m.MajorIntSeq_NUMB = @An_MajorIntSeq_NUMB
                               AND m.Case_IDNO = @An_Case_IDNO
                               AND ISNUMERIC(m.Reference_ID) = 1) m
                           JOIN DEMO_Y1 d
                            ON m.Reference_ID = d.MemberMci_IDNO
                           JOIN EHIS_Y1 e
                            ON e.MemberMci_IDNO = d.MemberMci_IDNO
                           JOIN OTHP_Y1 o
                            ON o.OtherParty_IDNO = e.OthpPartyEmpl_IDNO
                               AND m.OthpSource_IDNO = o.OtherParty_IDNO
                               AND o.EndValidity_DATE = @Ld_High_DATE
                           JOIN AHIS_Y1 n
                            ON n.MemberMci_IDNO = d.MemberMci_IDNO
                               AND (@Lc_Notice_ID IN (@Lc_NoticeEnf04_ID,@Lc_NoticeEnf12_ID) OR (@Ld_Today_DATE BETWEEN n.Begin_DATE AND n.End_DATE))
                     WHERE e.EndEmployment_DATE > @Ld_Today_DATE)a   
                 ORDER BY addr_hrchy) up UNPIVOT (Element_VALUE FOR Element_NAME IN (ORDERED_PARTY_FIRST_NAME, 
																									  ORDERED_PARTY_LAST_NAME, 
																									  ORDERED_PARTY_MIDDLE_NAME, 
																									  ORDERED_PARTY_SUFFIX_NAME,
																									  ORDERED_PARTY_EMPL_NAME,
																									  ORDERED_PARTY_EMPL_ATTN_ADDR, 
																									  ORDERED_PARTY_EMPL_LINE1_ADDR, 
																									  ORDERED_PARTY_EMPL_LINE2_ADDR, 
																									  ORDERED_PARTY_EMPL_CITY_ADDR, 
																									  ORDERED_PARTY_EMPL_STATE_ADDR, 
																									  ORDERED_PARTY_EMPL_COUNTRY_ADDR, 
																									  ORDERED_PARTY_EMPL_ZIP_ADDR,
																									  ORDERED_PARTY_ATTN_ADDR, 
																									  ORDERED_PARTY_LINE1_ADDR, 
																									  ORDERED_PARTY_LINE2_ADDR, 
																									  ORDERED_PARTY_CITY_ADDR, 
																									  ORDERED_PARTY_STATE_ADDR, 
																									  ORDERED_PARTY_COUNTRY_ADDR, 
																									  ORDERED_PARTY_ZIP_ADDR,
																									  ORDERED_PARTY_EMPL_PHONE_NUMB, 
																									  ORDERED_PARTY_EMPL_FEIN_IDNO,
																									  ORDERED_PARTY_MEMBER_SSN_NUMB
																									  )) AS pvt);

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
    DECLARE	@Li_Error_NUMB				INT = ERROR_NUMBER (),
			@Li_ErrorLine_NUMB		    INT =  ERROR_LINE ();
         SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
         IF (@Li_Error_NUMB <> 50001)
            BEGIN
               SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
            END
         EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION @As_Procedure_NAME = @Ls_Sql_TEXT,
                                                       @As_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT,
                                                       @As_Sql_TEXT = @Ls_Sql_TEXT,
                                                       @As_Sqldata_TEXT = @Ls_SqlData_TEXT,
                                                       @An_Error_NUMB = @Li_Error_NUMB,
                                                       @An_ErrorLine_NUMB = @Li_ErrorLine_NUMB,
                                                       @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;
  END CATCH
 END


GO
