/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICE_FIN$SP_GET_ARREARS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICE_FIN$SP_GET_ARREARS
Programmer Name	:	IMP Team.
Description		:	This function is used to fetch the arrears
Frequency		:	
Developed On	:	4/19/2012
Called By		:	BATCH_GEN_NOTICES$SP_EXECUTE_PROC_DYNAMIC
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICE_FIN$SP_GET_ARREARS] (
 @An_Case_IDNO             NUMERIC(6),
 @Ad_Run_DATE              DATE,
 @Ac_Notice_ID             CHAR(8),
 @Ac_Job_ID                CHAR(7) = ' ',
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
 SET NOCOUNT ON;
  DECLARE @Li_Error_NUMB                INT				= NULL,
          @Li_ErrorLine_NUMB            INT				= NULL,
          @Lc_StatusSuccess_CODE        CHAR(1)			= 'S',
          @Lc_StatusFailed_CODE         CHAR(1)			= 'F',
          @Lc_DebtTypeGeneticTest_CODE  CHAR(2)			= 'GT',
          @Lc_DebtTypeChildSupport_CODE CHAR(2)			= 'CS',
		  @Lc_JobNpro_ID				CHAR(4)			= 'NPRO',
		  @Lc_NoticeEnf01_ID			CHAR(6)			= 'ENF-01',
          @Ld_High_DATE					DATE			= '12/31/9999';
  DECLARE @Ln_Zero_NUMB					NUMERIC(2)		= 0,
          @Ln_Receipt_AMNT				NUMERIC(11, 2),
          @Ln_Total_Arrears_AMNT		NUMERIC(11, 2)	= 0,
          @Ln_Total_ChildSuppArr_AMNT	NUMERIC(11, 2)	= 0,
          @Ls_Procedure_NAME			VARCHAR(100),
          @Ls_Sql_TEXT					VARCHAR(200),
          @Ls_Sqldata_TEXT				VARCHAR(400),
          @Ls_DescriptionError_TEXT		VARCHAR(4000),
          @Ld_ArrearsTo_DATE			DATE,
          @Ld_ArrearsFrom_DATE			DATE;

  BEGIN TRY
   SET @Ln_Receipt_AMNT = NULL;
   SET @Ac_Msg_CODE = NULL;
   SET @As_DescriptionError_TEXT = NULL;
   SET @Ls_Procedure_NAME = 'BATCH_GEN_NOTICE_FIN.BATCH_GEN_NOTICE_FIN$SP_GET_ARREARS ';
   SET @Ls_Sql_TEXT = 'SELECT LSUP_Y1_1';
   SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + CAST(ISNULL(@An_Case_IDNO, 0) AS VARCHAR(6));
   SELECT @Ln_Total_Arrears_AMNT = Y.Total_Arrears_AMNT,
          @Ld_ArrearsTo_DATE = y.ArrearsTo_DATE,
          @Ln_Total_ChildSuppArr_AMNT = y.ChildSuppArr_AMNT,
          @Ld_ArrearsFrom_DATE = MinBeginObligation_DATE
     FROM(SELECT ISNULL(SUM((a.OweTotNaa_AMNT - a.AppTotNaa_AMNT) + (a.OweTotPaa_AMNT - a.AppTotPaa_AMNT) + (a.OweTotTaa_AMNT - a.AppTotTaa_AMNT) + (a.OweTotCaa_AMNT - a.AppTotCaa_AMNT) + (a.OweTotUpa_AMNT - a.AppTotUpa_AMNT) + (a.OweTotUda_AMNT - a.AppTotUda_AMNT) + (a.OweTotIvef_AMNT - a.AppTotIvef_AMNT) + (a.OweTotNffc_AMNT - a.AppTotNffc_AMNT) + (a.OweTotMedi_AMNT - a.AppTotMedi_AMNT) + (a.OweTotNonIvd_AMNT - a.AppTotNonIvd_AMNT) - (a.OweTotCurSup_AMNT - a.AppTotCurSup_AMNT) + CASE
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       WHEN a.MtdCurSupOwed_AMNT < a.AppTotCurSup_AMNT
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        THEN a.AppTotCurSup_AMNT - a.MtdCurSupOwed_AMNT
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       ELSE 0
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      END), @Ln_Zero_NUMB) Total_Arrears_AMNT,
                 MAX(Distribute_DATE) AS ArrearsTo_DATE,
                 ISNULL(SUM(CASE
                             WHEN ChildSupport_INDC = 'Y'
                              THEN ((a.OweTotNaa_AMNT - a.AppTotNaa_AMNT) + (a.OweTotPaa_AMNT - a.AppTotPaa_AMNT) + (a.OweTotTaa_AMNT - a.AppTotTaa_AMNT) + (a.OweTotCaa_AMNT - a.AppTotCaa_AMNT) + (a.OweTotUpa_AMNT - a.AppTotUpa_AMNT) + (a.OweTotUda_AMNT - a.AppTotUda_AMNT) + (a.OweTotIvef_AMNT - a.AppTotIvef_AMNT) + (a.OweTotNffc_AMNT - a.AppTotNffc_AMNT) + (a.OweTotMedi_AMNT - a.AppTotMedi_AMNT) + (a.OweTotNonIvd_AMNT - a.AppTotNonIvd_AMNT) - (a.OweTotCurSup_AMNT - a.AppTotCurSup_AMNT) + CASE
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               WHEN a.MtdCurSupOwed_AMNT < a.AppTotCurSup_AMNT
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                THEN a.AppTotCurSup_AMNT - a.MtdCurSupOwed_AMNT
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               ELSE 0
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              END)
                             ELSE 0
                            END), @Ln_Zero_NUMB) ChildSuppArr_AMNT,
                 MIN(MinBeginObligation_DATE) MinBeginObligation_DATE
            FROM (SELECT a.*,
                         ChildSupport_INDC,
                         MinBeginObligation_DATE,
                         ROW_NUMBER() OVER(partition BY a.Case_IDNO, a.OrderSeq_NUMB, a.ObligationSeq_NUMB ORDER BY A.SupportYearMOnth_NUMB DESC, A.EventGlobalSeq_NUMB DESC) rnm
                    FROM LSUP_Y1 a,
                         (SELECT o.Case_IDNO,
                                 o.OrderSeq_NUMB,
                                 o.ObligationSeq_NUMB,
                                 MAX (CASE
                                       WHEN o.TypeDebt_CODE = @Lc_DebtTypeChildSupport_CODE
                                        THEN 'Y'
                                       ELSE 'N'
                                      END) ChildSupport_INDC,
                                 MIN(MIN(o.BeginObligation_DATE)) OVER() MinBeginObligation_DATE
                            FROM OBLE_Y1 o
                           WHERE o.Case_IDNO = @An_Case_IDNO
                             AND o.TypeDebt_CODE <> @Lc_DebtTypeGeneticTest_CODE
                             AND o.EndValidity_DATE = @Ld_High_DATE
                           GROUP BY o.Case_IDNO,
                                    o.OrderSeq_NUMB,
                                    o.ObligationSeq_NUMB) o
                   WHERE a.Case_IDNO = @An_Case_IDNO
                     AND o.Case_IDNO = @An_Case_IDNO
                     AND o.OrderSeq_NUMB = a.OrderSeq_NUMB
                     AND o.ObligationSeq_NUMB = a.ObligationSeq_NUMB) a
           WHERE rnm = 1)Y;
      
	IF( @Ac_Notice_ID = @Lc_NoticeEnf01_ID AND @Ac_Job_ID != @Lc_JobNpro_ID )
	BEGIN
		SET @Ln_Total_Arrears_AMNT = 0;
	END

   SET @Ls_Sql_TEXT = 'INSERT #NoticeElementsData_P1';
   SET @Ls_Sqldata_TEXT = ' Total_Arrears_AMNT = ' + CAST(ISNULL(@Ln_Total_Arrears_AMNT, 0) AS VARCHAR) +' Total_ChildSupportArrears_AMNT = ' + CAST(ISNULL(@Ln_Total_ChildSuppArr_AMNT, 0) AS VARCHAR) + ' ArrearsFrom_DATE = ' + ISNULL(CAST(@Ld_ArrearsFrom_DATE AS VARCHAR), '')+ 'ArrearsTo_DATE = '+ ISNULL(CAST(@Ld_ArrearsTo_DATE AS VARCHAR), '');
   INSERT INTO #NoticeElementsData_P1
               (Element_NAME,
                Element_Value)
   (SELECT Element_NAME,
           Element_Value
      FROM (SELECT CAST(f.Total_Arrears_AMNT AS VARCHAR(100)) AS Total_Arrears_AMNT,
                   CAST(f.Total_Arrears_AMNT AS VARCHAR(100)) AS Total_ChildSupArrears_AMNT,
                   CAST(f.ArrearsFrom_DATE AS VARCHAR(100)) AS ArrearsFrom_DATE,
                   CAST(f.ArrearsTo_DATE AS VARCHAR(100)) AS ArrearsTo_DATE
              FROM (SELECT @Ln_Total_Arrears_AMNT AS Total_Arrears_AMNT,
                           @Ln_Total_ChildSuppArr_AMNT AS Total_ChildSupportArrears_AMNT,
                           @Ld_ArrearsFrom_DATE AS ArrearsFrom_DATE,
                           @Ld_ArrearsTo_DATE AS ArrearsTo_DATE) f)up UNPIVOT (Element_Value FOR Element_NAME IN (Total_Arrears_AMNT, Total_ChildSupArrears_AMNT, ArrearsFrom_DATE, ArrearsTo_DATE)) AS pvt);

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
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
