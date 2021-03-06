/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICE_CM$SP_GET_LKC_ADDRESS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
------------------------------------------------------------------------------------------------
 Procedure Name     : BATCH_GEN_NOTICE_CM$SP_GET_LKC_ADDRESS
 Programmer Name    : IMP Team
 Description        : This procedure is used to get address details such as line1, line2, city, state, country and zip address.
 Frequency          :
 Developed On       : 02-AUG-2011
 Called By          : BATCH_GEN_NOTICE_CM$SP_GET_NCP_LKC_ADDRESS
 Called On          :
-------------------------------------------------------------------------------------------------
 Modified By        :
 Modified On        :
 Version No         : 1.0 
----------------------------------------------------------------------------------------------------
*/ 

CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICE_CM$SP_GET_LKC_ADDRESS]
 @An_MemberMci_IDNO        NUMERIC(10),
 @Ad_Run_DATE			   DATE,
 @As_Prefix_TEXT           VARCHAR(50),
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(MAX) OUTPUT
AS
 BEGIN
  DECLARE @Li_Zero_NUMB           SMALLINT = 0,
          @Lc_StatusSuccess_CODE  CHAR(1) = 'S',
          @Lc_TypeAddressLkc_CODE CHAR(1) = 'C',
          @Lc_StatusVerified_CODE CHAR(1) = 'Y',
          @Lc_StatusFailed_CODE   CHAR(1) = 'F',
          @Lc_StatusPending_CODE  CHAR(1) = 'P',
          @Lc_PrefixCp_TEXT       CHAR(2) = 'CP',
          @Ls_Routine_TEXT        VARCHAR(100) = 'BATCH_GEN_NOTICE_CM$SP_GET_LKC_ADDRESS',
          @Ls_Sql_TEXT              VARCHAR(200) = 'SELECT AHIS_Y1',
          @Ls_SqlData_TEXT          VARCHAR(400) = 'MemberMci_IDNO =' + ISNULL(CAST(@An_MemberMci_IDNO AS CHAR), ''),
          @Ld_Today_DATE            DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
  DECLARE @Lc_Space_TEXT          CHAR(1) = ' ',
          @Ls_DescriptionError_TEXT VARCHAR(4000) = '';
          

  BEGIN TRY
   SET @Ac_Msg_CODE = '';
   SET @As_DescriptionError_TEXT = '';

   IF (LTRIM(RTRIM(@As_Prefix_TEXT)) IS NULL 
        OR LTRIM(RTRIM(@As_Prefix_TEXT)) = '')
    BEGIN
     SET @As_Prefix_TEXT = @Lc_PrefixCp_TEXT
    END

   IF (@An_MemberMci_IDNO IS NOT NULL
       AND @An_MemberMci_IDNO <> @Li_Zero_NUMB)
    BEGIN
     DECLARE @Ndel_P1 TABLE (
      Element_NAME  VARCHAR(100),
      Element_Value VARCHAR(100));

     INSERT INTO @Ndel_P1
                 (Element_Name,
                  Element_Value)
     SELECT tag_name,
            tag_value
       FROM (SELECT CONVERT(VARCHAR(100), Attn_ADDR) AS lkc_attn_addr,
                    CONVERT(VARCHAR(100), Line1_ADDR) AS lkc_line1_addr,
                    CONVERT(VARCHAR(100), Line2_ADDR) AS lkc_line2_addr,
                    CONVERT(VARCHAR(100), City_ADDR) AS lkc_city_addr,
                    CONVERT(VARCHAR(100), State_ADDR) AS lkc_state_addr,
                    CONVERT(VARCHAR(100), Zip_ADDR) AS lkc_zip_addr,
                    CONVERT(VARCHAR(100), Country_ADDR) AS lkc_country_addr
               FROM (SELECT TOP 1 RTRIM(a.Attn_ADDR) + @Lc_Space_TEXT AS Attn_ADDR,
                                  RTRIM(a.Line1_ADDR) + @Lc_Space_TEXT AS Line1_ADDR,
                                  RTRIM(a.Line2_ADDR) + @Lc_Space_TEXT AS Line2_ADDR,
                                  RTRIM(a.City_ADDR) AS City_ADDR,
                                  @Lc_Space_TEXT + RTRIM(a.State_ADDR) + @Lc_Space_TEXT AS State_ADDR,
                                  RTRIM(a.Zip_ADDR) AS Zip_ADDR,
                                  @Lc_Space_TEXT + RTRIM(a.Country_ADDR) AS Country_ADDR,
                                  Ind_ADDR
                       FROM (SELECT Attn_ADDR,
                                    Line1_ADDR,
                                    Line2_ADDR,
                                    State_ADDR,
                                    Zip_ADDR,
                                    City_ADDR,
                                    Country_ADDR,
                                    Status_CODE,
                                    TypeAddress_CODE,
                                    (CASE
                                      WHEN a.addr_hrchy = 1
                                       THEN 1
                                      ELSE 0
                                     END) Ind_ADDR
                               FROM (SELECT (CASE
                                              WHEN TypeAddress_CODE = 'M'
                                               THEN 1
                                              WHEN TypeAddress_CODE = 'C'
                                               THEN 1
                                              ELSE 2
                                             END) addr_hrchy,
                                            a.*
                                       FROM (SELECT ROW_NUMBER () OVER ( PARTITION BY a.MemberMci_IDNO ORDER BY rnm 
                                                    ) ronm,
                                                    a.*
                                               FROM (SELECT ROW_NUMBER () OVER ( PARTITION BY a.MemberMci_IDNO, TypeAddress_CODE ORDER BY Status_CODE DESC, TransactionEventSeq_NUMB DESC, Update_DTTM DESC) rnm,
                                                            a.*
                                                       FROM (SELECT a.*
                                                               FROM AHIS_Y1 a
                                                              WHERE a.MemberMci_IDNO = @An_MemberMci_IDNO
                                                                AND TypeAddress_CODE IN ('C')
                                                                AND (@Ad_Run_DATE BETWEEN a.Begin_DATE AND a.End_DATE
                                                                     AND Status_CODE IN ('Y')
                                                                     )) AS a) a
                                              WHERE rnm = 1
                                             UNION
                                             SELECT 1 AS ronm,
                                                    1 AS rnm,
                                                    m.*
                                               FROM (SELECT a.*
                                                       FROM AHIS_Y1 a
                                                      WHERE a.MemberMci_IDNO = @An_MemberMci_IDNO
                                                        AND TypeAddress_CODE = 'M'
                                                        AND @Ad_Run_DATE BETWEEN a.Begin_DATE AND a.End_DATE
                                                        AND Status_CODE = 'Y') AS m
                                                    LEFT OUTER JOIN (SELECT a.*
                                                                       FROM AHIS_Y1 a
                                                                      WHERE a.MemberMci_IDNO = @An_MemberMci_IDNO
                                                                            AND TypeAddress_CODE = 'C'
                                                                            AND @Ad_Run_DATE BETWEEN a.Begin_DATE AND a.End_DATE
                                                                            AND Status_CODE = 'Y') AS c
                                                     ON m.MemberMci_IDNO = c.MemberMci_IDNO
                                              WHERE (CASE
                                                      WHEN m.Line1_ADDR = c.Line1_ADDR
                                                           AND m.Line2_ADDR = c.Line2_ADDR
                                                           AND m.City_ADDR = c.City_ADDR
                                                           AND m.State_ADDR = c.State_ADDR
                                                           AND m.Zip_ADDR = c.Zip_ADDR
                                                           AND m.Country_ADDR = c.Country_ADDR
                                                       THEN 0
                                                      WHEN c.Line1_ADDR = ''
                                                       THEN 1
                                                      ELSE 1
                                                     END) = 1) a) a) a
                      WHERE Ind_ADDR = 1)a) up UNPIVOT (tag_value FOR tag_name IN (lkc_attn_addr, lkc_line1_addr, lkc_line2_addr, lkc_city_addr, lkc_state_addr, lkc_zip_addr, lkc_country_addr )) AS pvt;

     INSERT INTO #NoticeElementsData_P1
                 (Element_NAME,
                  Element_Value)
     SELECT @As_Prefix_TEXT + '_' + T.Element_NAME,
            T.Element_Value
       FROM @Ndel_P1 T;

     SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
    END
  END TRY

  BEGIN CATCH
   DECLARE @Li_Error_NUMB     INT = ERROR_NUMBER (),
           @Li_ErrorLine_NUMB INT = ERROR_LINE ();

   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

   IF (@Li_Error_NUMB <> 50001)
    BEGIN
     SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Sql_TEXT,
    @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_SqlData_TEXT,
    @An_Error_NUMB            = @Li_Error_NUMB,
    @An_ErrorLine_NUMB        = @Li_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;
  END CATCH
 END


GO
