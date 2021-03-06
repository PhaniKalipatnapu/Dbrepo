/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICE_FIN$SP_TOTAL_QUERY_LSUP]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICE_FIN$SP_TOTAL_QUERY_LSUP
Programmer Name	:	IMP Team.
Description		:	
Frequency		:	
Developed On	:	5/3/2012
Called By		:	
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICE_FIN$SP_TOTAL_QUERY_LSUP] (
 @An_Case_IDNO             NUMERIC (6),
 @An_OrderSeq_NUMB         NUMERIC (2),
 @Ac_Msg_CODE              CHAR (5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR (4000) OUTPUT
 )
AS

 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusFailed_CODE  CHAR (1) = 'F',
          @Lc_StatusSuccess_CODE CHAR (1) = 'S',
          @Ls_Procedure_NAME     VARCHAR (100) = 'BATCH_GEN_NOTICE_FIN$SP_TOTAL_QUERY_LSUP';
  DECLARE @Ls_Sql_TEXT              VARCHAR (100) = '',
          @Ls_Sqldata_TEXT          VARCHAR (1000) = '',
          @Ls_DescriptionError_TEXT VARCHAR (4000);
          
  BEGIN TRY
   SET @Ls_Sql_TEXT = 'SELECT LSUP_Y1';
   SET @Ls_Sqldata_TEXT = ' OrderSeq_NUMB = ' + ISNULL (CAST (@An_OrderSeq_NUMB AS VARCHAR(10)), '') + ', Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR(6)), '');

   INSERT INTO #NoticeElementsData_P1
               (pvt.Element_NAME,
                pvt.Element_VALUE)
   SELECT Element_NAME,
          Element_VALUE
    FROM 
     (SELECT SUM(CsPaid_AMNT)AS Total_AppTotCurSup_AMNT,
           SUM(CurrentSupport_AMNT) AS Total_MtdCurSupOwed_AMNT,
           SUM(CurrentSupport_AMNT - CsPaid_AMNT)AS Total_CurSupBalance_AMNT
     FROM 
      (SELECT (CASE
             WHEN RIGHT(a.SupportYearMonth_NUMB, 2) = 01
                THEN'Jan'
                  WHEN RIGHT(a.SupportYearMonth_NUMB, 2) = 02
                    THEN 'Feb'
                  WHEN RIGHT(a.SupportYearMonth_NUMB, 2) = 03
                    THEN 'Mar'
                  WHEN RIGHT(a.SupportYearMonth_NUMB, 2) = 04
                    THEN 'Apr'
                  WHEN RIGHT(a.SupportYearMonth_NUMB, 2) = 05
                    THEN 'May'
                  WHEN RIGHT(a.SupportYearMonth_NUMB, 2) = 06
                    THEN 'Jun'
                  WHEN RIGHT(a.SupportYearMonth_NUMB, 2) = 07
                    THEN 'Jly'
                  WHEN RIGHT(a.SupportYearMonth_NUMB, 2) = 08
                   THEN 'Aug'
                  WHEN RIGHT(a.SupportYearMonth_NUMB, 2) = 09
                   THEN 'Sep'
                  WHEN RIGHT(a.SupportYearMonth_NUMB, 2) = 10
                   THEN 'Oct'
                  WHEN RIGHT(a.SupportYearMonth_NUMB, 2) = 11
                   THEN 'Nov'
                  WHEN RIGHT(a.SupportYearMonth_NUMB, 2) = 12
                   THEN 'Dec'
                       ELSE ''
                        END) AS SupportYearMonth_TEXT,
                          SupportYearMonth_NUMB,
                          SUM(a.OweTotCurSup_AMNT) AS CurrentSupport_AMNT,
                          SUM(a.AppTotCurSup_AMNT) AS CsPaid_AMNT,
                          SUM(dbo.BATCH_COMMON$SF_GET_ARREAR_PAID (a.Case_IDNO, a.OrderSeq_NUMB, a.ObligationSeq_NUMB, a.SupportYearMonth_NUMB)) AS ArrearPaid_AMNT,
                          SUM((a.OweTotNaa_AMNT - a.AppTotNaa_AMNT) + (a.OweTotPaa_AMNT - a.AppTotPaa_AMNT) + (a.OweTotTaa_AMNT - a.AppTotTaa_AMNT) + (a.OweTotCaa_AMNT - a.AppTotCaa_AMNT) + (a.OweTotUpa_AMNT - a.AppTotUpa_AMNT) + (a.OweTotUda_AMNT - a.AppTotUda_AMNT) + (a.OweTotIvef_AMNT - a.AppTotIvef_AMNT) + (a.OweTotNffc_AMNT - a.AppTotNffc_AMNT) + (a.OweTotNonIvd_AMNT - a.AppTotNonIvd_AMNT) + (a.OweTotMedi_AMNT - a.AppTotMedi_AMNT) - a.AppTotFuture_AMNT) AS Total_QNTY,
                          SUM(a.OweTotExptPay_AMNT) AS AotExptPay_AMNT,
                          SUM(DBO.BATCH_COMMON$SF_GET_TXN_AMT(a.Case_IDNO, a.OrderSeq_NUMB, a.ObligationSeq_NUMB, a.SupportYearMonth_NUMB, 'A')) AS MonthlyAdj_AMNT,
                          ROW_NUMBER() OVER( ORDER BY a.SupportYearMonth_NUMB DESC) AS ROWNUM
            FROM LSUP_Y1 a
            WHERE a.Case_IDNO = @An_Case_IDNO
                      AND a.OrderSeq_NUMB = @An_OrderSeq_NUMB
                      AND a.SupportYearMonth_NUMB <= (SELECT ISNULL(MAX(b.SupportYearMonth_NUMB), 0)
                                                        FROM LSUP_Y1 b
                                                       WHERE a.Case_IDNO = b.Case_IDNO
                                                         AND a.OrderSeq_NUMB = b.OrderSeq_NUMB
                                                         AND a.ObligationSeq_NUMB = b.ObligationSeq_NUMB)
                      AND a.EventGlobalSeq_NUMB = (SELECT MAX(b.EventGlobalSeq_NUMB)
                                                     FROM LSUP_Y1 b
                                                    WHERE a.Case_IDNO = b.Case_IDNO
                                                      AND a.OrderSeq_NUMB = b.OrderSeq_NUMB
                                                      AND a.ObligationSeq_NUMB = b.ObligationSeq_NUMB
                                                      AND a.SupportYearMonth_NUMB = b.SupportYearMonth_NUMB)
                    GROUP BY SupportYearMonth_NUMB)d)up UNPIVOT (Element_VALUE FOR Element_NAME IN (Total_AppTotCurSup_AMNT, Total_MtdCurSupOwed_AMNT, Total_CurSupBalance_AMNT)) AS pvt;

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

   DECLARE @Li_Error_NUMB     INT,
           @Li_ErrorLine_NUMB INT;

   SET @Li_Error_NUMB = ERROR_NUMBER ();
   SET @Li_ErrorLine_NUMB = ERROR_LINE ();

   IF (@Li_Error_NUMB <> 50001)
    BEGIN
     SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_SqlData_TEXT,
    @An_Error_NUMB            = @Li_Error_NUMB,
    @An_ErrorLine_NUMB        = @Li_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
  END CATCH
 END


GO
