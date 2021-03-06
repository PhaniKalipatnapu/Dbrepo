/****** Object:  StoredProcedure [dbo].[BATCH_COMMON$SP_ASSIGN_ARREARS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_COMMON$SP_ASSIGN_ARREARS
Programmer Name		: IMP Team
Description			: BATCH_COMMON$SP_ASSIGN_ARREARS
Frequency			: 
Developed On		: 04/12/2011
Called By			: None
Called On			:
--------------------------------------------------------------------------------------------------------------------
Modified By			:
Modified On			:
Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_COMMON$SP_ASSIGN_ARREARS]
 @An_Case_IDNO             NUMERIC(6),
 @An_OrderSeq_NUMB         NUMERIC(2),
 @An_ObligationSeq_NUMB    NUMERIC(2),
 @An_CpMci_IDNO            NUMERIC(10),
 @Ac_TypeWelfare_CODE      CHAR(1),
 @An_SupportYearMonth_NUMB NUMERIC(6),
 @An_OweCur_AMNT           NUMERIC(11, 2),
 @An_AppCur_AMNT           NUMERIC(11, 2),
 @An_Adjust_AMNT           NUMERIC(11, 2),
 @An_OweNaa_AMNT           NUMERIC(11, 2),
 @An_AppNaa_AMNT           NUMERIC(11, 2),
 @An_TransactionNaa_AMNT   NUMERIC(11, 2) OUTPUT,
 @An_AdjustNaa_AMNT        NUMERIC(11, 2) OUTPUT,
 @An_OwePaa_AMNT           NUMERIC(11, 2),
 @An_AppPaa_AMNT           NUMERIC(11, 2),
 @An_TransactionPaa_AMNT   NUMERIC(11, 2) OUTPUT,
 @An_AdjustPaa_AMNT        NUMERIC(11, 2) OUTPUT,
 @An_OweTaa_AMNT           NUMERIC(11, 2),
 @An_AppTaa_AMNT           NUMERIC(11, 2),
 @An_TransactionTaa_AMNT   NUMERIC(11, 2) OUTPUT,
 @An_AdjustTaa_AMNT        NUMERIC(11, 2) OUTPUT,
 @An_OweCaa_AMNT           NUMERIC(11, 2),
 @An_AppCaa_AMNT           NUMERIC(11, 2),
 @An_TransactionCaa_AMNT   NUMERIC(11, 2) OUTPUT,
 @An_AdjustCaa_AMNT        NUMERIC(11, 2) OUTPUT,
 @An_OweUpa_AMNT           NUMERIC(11, 2),
 @An_AppUpa_AMNT           NUMERIC(11, 2),
 @An_TransactionUpa_AMNT   NUMERIC(11, 2) OUTPUT,
 @An_AdjustUpa_AMNT        NUMERIC(11, 2) OUTPUT,
 @An_OweUda_AMNT           NUMERIC(11, 2),
 @An_AppUda_AMNT           NUMERIC(11, 2),
 @An_TransactionUda_AMNT   NUMERIC(11, 2) OUTPUT,
 @An_AdjustUda_AMNT        NUMERIC(11, 2) OUTPUT,
 @Ac_NipaFlag_INDC         CHAR(1),
 @Ad_Process_DATE          DATE,
 @Ac_Msg_CODE              CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;
  DECLARE  @Lc_TypeWelfareTanf_CODE         CHAR(1) = 'A',
           @Lc_TypeWelfareNonTanf_CODE      CHAR(1) = 'N',
           @Lc_TypeWelfareMedicaid_CODE     CHAR(1) = 'M',
           @Lc_StatusSuccess_CODE           CHAR(1) = 'S',
           @Lc_StatusFailed_CODE            CHAR(1) = 'F',
           @Ls_Procedure_NAME               VARCHAR(100) = 'BATCH_COMMON$SP_ASSIGN_ARREARS',
           @Ld_High_DATE                    DATE = '12/31/9999';
  DECLARE  @Ln_Error_NUMB         NUMERIC(11),
           @Ln_ErrorLine_NUMB     NUMERIC(11),
           @Ln_ArrPaa_AMNT        NUMERIC(11,2) = 0,
           @Ln_ArrTaa_AMNT        NUMERIC(11,2) = 0,
           @Ln_ArrCaa_AMNT        NUMERIC(11,2) = 0,
           @Ln_ArrNaa_AMNT        NUMERIC(11,2) = 0,
           @Ln_ArrUpa_AMNT        NUMERIC(11,2) = 0,
           @Ln_ArrUda_AMNT        NUMERIC(11,2) = 0,
           @Ln_UdaTmp_AMNT        NUMERIC(11,2) = 0,
           @Ln_Urg_AMNT           NUMERIC(11,2) = 0,
           @Ln_TotalUrg_AMNT      NUMERIC(11,2) = 0,
           @Ln_IVDCasePAATotalArrear_AMNT NUMERIC(11,2) = 0,
           @Ln_IVDCasePAAUDATotalArrear_AMNT NUMERIC(11,2) = 0,
           @Ls_Sql_TEXT           VARCHAR(100),
           @Ls_Sqldata_TEXT       VARCHAR(1000),
           @Ls_ErrorMessage_TEXT  VARCHAR(4000) = '',
           @Ld_Process_DATE       DATE;

  BEGIN TRY
   SET @Ln_ArrPaa_AMNT = @An_OwePaa_AMNT - @An_AppPaa_AMNT;
   SET @Ln_ArrTaa_AMNT = @An_OweTaa_AMNT - @An_AppTaa_AMNT;
   SET @Ln_ArrCaa_AMNT = @An_OweCaa_AMNT - @An_AppCaa_AMNT;
   SET @Ln_ArrNaa_AMNT = @An_OweNaa_AMNT - @An_AppNaa_AMNT;
   SET @Ln_ArrUpa_AMNT = @An_OweUpa_AMNT - @An_AppUpa_AMNT;
   SET @Ln_ArrUda_AMNT = @An_OweUda_AMNT - @An_AppUda_AMNT;
   
   SET @Ac_Msg_CODE = '';
   SET @As_DescriptionError_TEXT = '';
   SET @Ld_Process_DATE = ISNULL (@Ad_Process_DATE, dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME());

   -- IVD Case associated Welfare Case URG selection and IVD Case Level URG proration - Start --
   SET @Ls_Sql_TEXT = 'SELECT_IVMG_Total_URG';
   SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @An_Case_IDNO AS VARCHAR ),'')+ ', TypeWelfare_CODE = ' + ISNULL('A','') + ', CpMci_IDNO = ' + ISNULL(CAST( @An_CpMci_IDNO AS VARCHAR ),'') + ', SupportYearMonth_NUMB = ' + ISNULL(CAST( @An_SupportYearMonth_NUMB AS VARCHAR ),'');

   SELECT @Ln_TotalUrg_AMNT = ISNULL(SUM(IVA_Urg_AMNT),0) FROM 
   ( 
	SELECT ISNULL((A.LtdAssistExpend_AMNT - A.LtdAssistRecoup_AMNT), 0) IVA_Urg_AMNT,
			ROW_NUMBER() OVER (PARTITION BY a.CaseWelfare_IDNO,a.CpMci_IDNO,a.WelfareElig_CODE ORDER BY WelfareYearMonth_NUMB DESC, EventGlobalSeq_NUMB DESC) AS RowNum
     FROM IVMG_Y1 A
    WHERE CaseWelfare_IDNO IN(SELECT DISTINCT CaseWelfare_IDNO
                                FROM MHIS_Y1 B
                               WHERE B.Case_IDNO = @An_Case_IDNO
                                 AND B.TypeWelfare_CODE = 'A')
	  AND CpMci_IDNO = @An_CpMci_IDNO
	  AND WelfareYearMonth_NUMB <= @An_SupportYearMonth_NUMB
	) A
	WHERE RowNum = 1

   -- Selecting the IVD case PA arrears, UD arrears
   SET @Ls_Sql_TEXT = 'SELECT_LSUP_Total_IVDCase_PAAUDA_TotalArrear';
   SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @An_Case_IDNO AS VARCHAR ),'') + ', SupportYearMonth_NUMB = ' + ISNULL(CAST( @An_SupportYearMonth_NUMB AS VARCHAR ),'');
   SELECT 	@Ln_IVDCasePAATotalArrear_AMNT = ISNULL(SUM(Oblg_Paa_Arrear_AMNT),0),
			@Ln_IVDCasePAAUDATotalArrear_AMNT = ISNULL(SUM(Oblg_Paa_Uda_Arrear_AMNT),0) FROM 
	(
	SELECT ISNULL((a.OweTotPaa_AMNT - a.AppTotPaa_AMNT), 0) Oblg_Paa_Arrear_AMNT,  
		  ISNULL((a.OweTotPaa_AMNT - a.AppTotPaa_AMNT) + (a.OweTotUda_AMNT - a.AppTotUda_AMNT), 0) Oblg_Paa_Uda_Arrear_AMNT,
		  ROW_NUMBER() OVER (PARTITION BY a.Case_IDNO,a.OrderSeq_NUMB,a.ObligationSeq_NUMB ORDER BY SupportYearMonth_NUMB DESC, a.EventGlobalSeq_NUMB DESC) AS RowNum
	 FROM LSUP_Y1 a
	WHERE a.Case_IDNO = @An_Case_IDNO 
	AND a.SupportYearMonth_NUMB <= @An_SupportYearMonth_NUMB
	) A
	WHERE RowNum = 1	
	
   -- Prorate the Obligation PAA bucket arrear using obligation PAA & UDA and IVD case PAA & UDA when IVD Case PAA is > 0
   IF (@Ln_IVDCasePAATotalArrear_AMNT > 0 )
    BEGIN
		-- Prorating the URG based on obligation PAA, UDA.
		SET @Ls_Sql_TEXT = 'SELECT_Prorated_URG_Calculation';	
		SET @Ls_Sqldata_TEXT = 'Ln_TotalUrg_AMNT = ' + ISNULL(CAST( @Ln_TotalUrg_AMNT AS VARCHAR ),'') + ', Ln_ArrPaa_AMNT = ' + ISNULL(CAST( @Ln_ArrPaa_AMNT AS VARCHAR ),'') + ', Ln_ArrUda_AMNT = ' + ISNULL(CAST( @Ln_ArrUda_AMNT AS VARCHAR ),'') + ', Ln_IVDCasePAATotalArrear_AMNT = ' + ISNULL(CAST( @Ln_IVDCasePAAUDATotalArrear_AMNT AS VARCHAR ),'');	
		
		SET @Ln_Urg_AMNT = ISNULL(@Ln_TotalUrg_AMNT * ((@Ln_ArrPaa_AMNT + @Ln_ArrUda_AMNT) /@Ln_IVDCasePAAUDATotalArrear_AMNT),0)
	   -- IVD Case associated Welfare Case URG selection and IVD Case Level URG proration - End --
    END 
	
   IF @Ac_TypeWelfare_CODE = @Lc_TypeWelfareTanf_CODE
    BEGIN
     SET @Ln_ArrPaa_AMNT = @Ln_ArrPaa_AMNT + @An_AdjustPaa_AMNT + @An_Adjust_AMNT;
     SET @An_AdjustPaa_AMNT = @An_AdjustPaa_AMNT + @An_Adjust_AMNT;
     SET @An_TransactionPaa_AMNT = @An_TransactionPaa_AMNT + @An_AdjustPaa_AMNT;
     SET @An_TransactionNaa_AMNT = @An_AdjustNaa_AMNT;
     SET @Ln_ArrNaa_AMNT = @Ln_ArrNaa_AMNT + @An_TransactionNaa_AMNT;
     SET @An_TransactionUda_AMNT = @An_AdjustUda_AMNT;
     SET @Ln_ArrUda_AMNT = @Ln_ArrUda_AMNT + @An_TransactionUda_AMNT;
    END
   ELSE
    BEGIN
     IF @Ac_TypeWelfare_CODE IN (@Lc_TypeWelfareNonTanf_CODE, @Lc_TypeWelfareMedicaid_CODE)
      BEGIN
       SET @Ln_ArrPaa_AMNT = @An_AdjustPaa_AMNT + @Ln_ArrPaa_AMNT;
       SET @Ln_ArrUda_AMNT = @An_AdjustUda_AMNT + @Ln_ArrUda_AMNT;
       SET @An_TransactionPaa_AMNT = @An_AdjustPaa_AMNT;
       SET @An_AdjustPaa_AMNT = @An_AdjustPaa_AMNT;
       SET @An_TransactionUda_AMNT = @An_AdjustUda_AMNT;
       SET @An_AdjustNaa_AMNT = @An_AdjustNaa_AMNT + @An_Adjust_AMNT;
       SET @An_TransactionNaa_AMNT = @An_AdjustNaa_AMNT + @An_TransactionNaa_AMNT;
       SET @Ln_ArrNaa_AMNT = @An_AdjustNaa_AMNT + @Ln_ArrNaa_AMNT;

       IF @Ln_ArrPaa_AMNT >= @Ln_Urg_AMNT
          AND @Ln_ArrPaa_AMNT > 0
        BEGIN
         SET @Ln_UdaTmp_AMNT = @Ln_ArrPaa_AMNT - @Ln_Urg_AMNT;
         SET @An_AdjustUda_AMNT = @An_AdjustUda_AMNT + @Ln_UdaTmp_AMNT - @Ln_ArrUda_AMNT;
         SET @An_AdjustPaa_AMNT = @An_AdjustPaa_AMNT - @Ln_UdaTmp_AMNT;
         SET @Ln_ArrUda_AMNT = @Ln_ArrUda_AMNT + @Ln_UdaTmp_AMNT;
         SET @An_TransactionUda_AMNT = @An_TransactionUda_AMNT + @Ln_UdaTmp_AMNT;
         SET @Ln_ArrPaa_AMNT = @Ln_ArrPaa_AMNT - @Ln_UdaTmp_AMNT;
         SET @An_TransactionPaa_AMNT = @An_TransactionPaa_AMNT - @Ln_UdaTmp_AMNT;
         SET @Ln_UdaTmp_AMNT = 0;
        END

       SET @An_AdjustTaa_AMNT = 0;
      END
    END

   IF @An_SupportYearMonth_NUMB = ISNULL(CONVERT(CHAR(6), @Ld_Process_DATE, 112), '')
 
    BEGIN
     IF @Ac_TypeWelfare_CODE = @Lc_TypeWelfareTanf_CODE
      BEGIN
       SET @Ln_ArrPaa_AMNT = @Ln_ArrPaa_AMNT - (@An_OweCur_AMNT - @An_AppCur_AMNT);
      END
     ELSE
      BEGIN
       IF @Ac_TypeWelfare_CODE IN (@Lc_TypeWelfareNonTanf_CODE, @Lc_TypeWelfareMedicaid_CODE)
        BEGIN
         SET @Ln_ArrNaa_AMNT = @Ln_ArrNaa_AMNT - (@An_OweCur_AMNT - @An_AppCur_AMNT);
        END
      END
    END

   -- DRA Changes Move any pending TA arrears to Na_AMNT
   IF @Ln_ArrTaa_AMNT > 0
    BEGIN
     SET @An_TransactionTaa_AMNT = (@Ln_ArrTaa_AMNT) * (-1);
     SET @An_TransactionNaa_AMNT = @An_TransactionNaa_AMNT + @Ln_ArrTaa_AMNT;
     SET @Ln_ArrNaa_AMNT = @Ln_ArrNaa_AMNT + @An_TransactionNaa_AMNT;
     SET @Ln_ArrTaa_AMNT = 0;
    END

   --DRA changes Move any pending Ca_AMNT arrears to Na_AMNT
   IF @Ln_ArrCaa_AMNT > 0
    BEGIN
     SET @An_TransactionCaa_AMNT = (@Ln_ArrCaa_AMNT) * (-1); 
     SET @An_TransactionNaa_AMNT = @An_TransactionNaa_AMNT + @Ln_ArrCaa_AMNT;
     SET @Ln_ArrNaa_AMNT = @Ln_ArrNaa_AMNT + @An_TransactionNaa_AMNT;
     SET @Ln_ArrCaa_AMNT = 0;
    END

   --DRA changes Move any pending UPA arrears to Na_AMNT
   IF @Ln_ArrUpa_AMNT > 0
    BEGIN
     SET @An_TransactionUpa_AMNT = (@Ln_ArrUpa_AMNT) * (-1);
     SET @An_TransactionNaa_AMNT = @An_TransactionNaa_AMNT + @Ln_ArrUpa_AMNT;
     SET @Ln_ArrNaa_AMNT = @Ln_ArrNaa_AMNT + @An_TransactionNaa_AMNT;
     SET @Ln_ArrUpa_AMNT = 0;
    END

   IF @Ln_ArrPaa_AMNT < 0
       OR @Ln_ArrUda_AMNT < 0
       OR @Ln_ArrNaa_AMNT < 0
       OR @Ln_ArrCaa_AMNT < 0
       OR @Ln_ArrUpa_AMNT < 0
       OR @Ln_ArrTaa_AMNT < 0
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_CIRCULAR_RULE';
	 SET @Ls_Sqldata_TEXT = '';
     EXECUTE BATCH_COMMON$SP_CIRCULAR_RULE
      @An_ArrPaa_AMNT         = @Ln_ArrPaa_AMNT OUTPUT,
      @An_TransactionPaa_AMNT = @An_TransactionPaa_AMNT OUTPUT,
      @An_ArrUda_AMNT         = @Ln_ArrUda_AMNT OUTPUT,
      @An_TransactionUda_AMNT = @An_TransactionUda_AMNT OUTPUT,
      @An_ArrNaa_AMNT         = @Ln_ArrNaa_AMNT OUTPUT,
      @An_TransactionNaa_AMNT = @An_TransactionNaa_AMNT OUTPUT,
      @An_ArrCaa_AMNT         = @Ln_ArrCaa_AMNT OUTPUT,
      @An_TransactionCaa_AMNT = @An_TransactionCaa_AMNT OUTPUT,
      @An_ArrUpa_AMNT         = @Ln_ArrUpa_AMNT OUTPUT,
      @An_TransactionUpa_AMNT = @An_TransactionUpa_AMNT OUTPUT,
      @An_ArrTaa_AMNT         = @Ln_ArrTaa_AMNT OUTPUT,
      @An_TransactionTaa_AMNT = @An_TransactionTaa_AMNT OUTPUT;
    END

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();
   SET @Ls_ErrorMessage_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
   
   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;
    
  END CATCH
 END


GO
