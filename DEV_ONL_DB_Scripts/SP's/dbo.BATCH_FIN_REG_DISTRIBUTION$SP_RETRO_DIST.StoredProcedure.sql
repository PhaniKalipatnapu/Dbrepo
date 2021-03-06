/****** Object:  StoredProcedure [dbo].[BATCH_FIN_REG_DISTRIBUTION$SP_RETRO_DIST]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_FIN_REG_DISTRIBUTION$SP_RETRO_DIST
Programmer Name 	: IMP Team
Description			: This procedure will be executed if the RCTH_Y1 date falls on a prior month.  It loads the Current
					  Arrears and Compares the same with the RCTH_Y1 month Arrear and updates the Correct Arrear that
					  has to be Distributed in the Temporary Table TOWED_Y1
Frequency			: 'DAILY'
Developed On		: 04/12/2011
Called BY			: BATCH_FIN_REG_DISTRIBUTION$SP_REGULAR_DISTRIBUTION
Called On			: 
--------------------------------------------------------------------------------------------------------------------
Modified BY			:
Modified On			:
Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_FIN_REG_DISTRIBUTION$SP_RETRO_DIST]
 @An_TotArrear_AMNT        NUMERIC (11, 2) OUTPUT,
 @Ac_Msg_CODE              CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT,
 @Ad_Process_DATE          DATE OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE  @Lc_TypeWelfareTanf_CODE   CHAR (1) = 'A',
           @Lc_StatusSuccess_CODE     CHAR (1) = 'S',
           @Lc_StatusFailed_CODE      CHAR (1) = 'F',
           @Lc_ExptTypeBucket_CODE    CHAR (1) = 'E',
           @Lc_CsTypeBucket_CODE      CHAR (1) = 'C',
           @Lc_TypeOrderV_CODE		  CHAR (1) = 'V',
           @Lc_TypeDebtMedicaid_CODE  CHAR (2) = 'DS',
           @Lc_PaaTypeBucket_CODE     CHAR (5) = 'APAA',
           @Lc_UdaTypeBucket_CODE     CHAR (5) = 'AUDA',
           @Ls_Procedure_NAME         VARCHAR (100) = 'SP_RETRO_DIST';
  DECLARE  @Ln_OrderSeq_NUMB                  NUMERIC (2),
           @Ln_ObligationSeq_NUMB             NUMERIC (2),
           @Ln_Case_IDNO                      NUMERIC (6),
           @Ln_ArrearT_AMNT                   NUMERIC (11,2),
           @Ln_ArrearN_AMNT                   NUMERIC (11,2),
           @Ln_ArrCumulT_AMNT                 NUMERIC (11,2),
           @Ln_ArrCumulN_AMNT                 NUMERIC (11,2),
           @Ln_Arrear_AMNT                    NUMERIC (11,2),
           @Ln_OblePrCuml_AMNT                NUMERIC (11,2),
           @Ln_Error_NUMB                     NUMERIC (11),
           @Ln_ErrorLine_NUMB                 NUMERIC (11),
           @Li_FetchStatus_QNTY               SMALLINT,
           @Ls_Sql_TEXT                       VARCHAR (100) = '',
           @Ls_Sqldata_TEXT                   VARCHAR (1000) = '',
           @Ls_ErrorMessage_TEXT              VARCHAR (2000);
  DECLARE  @Ln_LsupArrCur_Case_IDNO           NUMERIC (6),
		   @Ln_LsupArrCur_OrderSeq_NUMB       NUMERIC (2),
           @Ln_LsupArrCur_ObligationSeq_NUMB  NUMERIC (2),
           @Ln_LsupArrCur_Owed_AMNT          NUMERIC (11,2);         
  DECLARE  @Ln_LsupPrCur_Case_IDNO            NUMERIC (6),
           @Ln_LsupPrCur_OrderSeq_NUMB        NUMERIC (2),
           @Ln_LsupPrCur_ObligationSeq_NUMB   NUMERIC (2),
           @Ln_LsupPrCur_Owed_AMNT            NUMERIC (11,2),
           @Ln_LsupPrCur_PrDistribute_QNTY    NUMERIC (5);
          
  DECLARE LsupArr_CUR INSENSITIVE CURSOR FOR
   SELECT a.Case_IDNO,
          a.OrderSeq_NUMB,
          a.ObligationSeq_NUMB,
          SUM (a.ArrToBePaid_AMNT) AS ArrOwed_AMNT
     FROM #Towed_P1 a
    WHERE a.TypeOrder_CODE != @Lc_TypeOrderV_CODE
    GROUP BY a.Case_IDNO,
             a.OrderSeq_NUMB,
             a.ObligationSeq_NUMB;
             
  BEGIN TRY
   SET @Ac_Msg_CODE = '';
   SET @An_TotArrear_AMNT = 0;
   SET @Ls_Sql_TEXT = 'OPEN  LsupArr_CUR-1';   
   SET @Ls_Sqldata_TEXT = '';
    
   OPEN LsupArr_CUR;

   SET @Ls_Sql_TEXT = 'FETCH  LsupArr_CUR-1';   
   SET @Ls_Sqldata_TEXT = '';
   
   FETCH NEXT FROM LsupArr_CUR INTO @Ln_LsupArrCur_Case_IDNO, @Ln_LsupArrCur_OrderSeq_NUMB, @Ln_LsupArrCur_ObligationSeq_NUMB, @Ln_LsupArrCur_Owed_AMNT;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
   SET @Ls_Sql_TEXT = 'WHILE -1';   
   SET @Ls_Sqldata_TEXT = '';
   
   -- Cursor Started
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
     SET @Ln_Arrear_AMNT = 0;
     SET @Ln_Case_IDNO = @Ln_LsupArrCur_Case_IDNO;
     SET @Ln_OrderSeq_NUMB = @Ln_LsupArrCur_OrderSeq_NUMB;
     SET @Ln_ObligationSeq_NUMB = @Ln_LsupArrCur_ObligationSeq_NUMB;
     SET @Ln_ArrearT_AMNT = 0;
     SET @Ln_ArrearN_AMNT = 0;
	 
	 SET @Ls_Sql_TEXT = 'SELECT_LSUP_Y1';  
     SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @Ln_LsupArrCur_Case_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @Ln_LsupArrCur_OrderSeq_NUMB AS VARCHAR ),'')+ ', ObligationSeq_NUMB = ' + ISNULL(CAST( @Ln_LsupArrCur_ObligationSeq_NUMB AS VARCHAR ),'')+ ', Case_IDNO = ' + ISNULL(CAST( @Ln_LsupArrCur_Case_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @Ln_LsupArrCur_OrderSeq_NUMB AS VARCHAR ),'')+ ', ObligationSeq_NUMB = ' + ISNULL(CAST( @Ln_LsupArrCur_ObligationSeq_NUMB AS VARCHAR ),'');

     SELECT @Ln_ArrearT_AMNT = ISNULL (SUM ((a.OweTotPaa_AMNT - a.AppTotPaa_AMNT)  - CASE a.TypeWelfare_CODE
                                                                                                         WHEN @Lc_TypeWelfareTanf_CODE
                                                                                                          THEN (a.OweTotCurSup_AMNT - a.AppTotCurSup_AMNT
                                                                                                                 + (CASE
                                                                                                                     WHEN MtdCurSupOwed_AMNT < AppTotCurSup_AMNT
                                                                                                                      THEN AppTotCurSup_AMNT - MtdCurSupOwed_AMNT
                                                                                                                     ELSE 0
                                                                                                                    END)
                                                                                                               )
                                                                                                         ELSE 0
                                                                                                        END), 0),
            @Ln_ArrearN_AMNT = ISNULL (SUM ((a.OweTotNaa_AMNT - a.AppTotNaa_AMNT) + (a.OweTotUda_AMNT - a.AppTotUda_AMNT) + (a.OweTotCaa_AMNT - a.AppTotCaa_AMNT) + (a.OweTotTaa_AMNT - a.AppTotTaa_AMNT) + (a.OweTotUpa_AMNT - a.AppTotUpa_AMNT) + (a.OweTotIvef_AMNT - a.AppTotIvef_AMNT) + (a.OweTotNffc_AMNT - a.AppTotNffc_AMNT) + (a.OweTotNonIvd_AMNT - a.AppTotNonIvd_AMNT) + (a.OweTotMedi_AMNT - a.AppTotMedi_AMNT) - CASE a.TypeWelfare_CODE
                                                                                                                                                                                                                                                                                                                                                                                         WHEN @Lc_TypeWelfareTanf_CODE
                                                                                                                                                                                                                                                                                                                                                                                          THEN 0
                                                                                                                                                                                                                                                                                                                                                                                         ELSE a.OweTotCurSup_AMNT - a.AppTotCurSup_AMNT
                                                                                                                                                                                                                                                                                                                                                                                               + (CASE
                                                                                                                                                                                                                                                                                                                                                                                                   WHEN MtdCurSupOwed_AMNT < AppTotCurSup_AMNT
                                                                                                                                                                                                                                                                                                                                                                                                    THEN AppTotCurSup_AMNT - MtdCurSupOwed_AMNT
                                                                                                                                                                                                                                                                                                                                                                                                   ELSE 0
                                                                                                                                                                                                                                                                                                                                                                                                  END)
                                                                                                                                                                                                                                                                                                                                                                                        END), 0)
       FROM LSUP_Y1 a
      WHERE a.Case_IDNO = @Ln_LsupArrCur_Case_IDNO
        AND a.OrderSeq_NUMB = @Ln_LsupArrCur_OrderSeq_NUMB
        AND a.ObligationSeq_NUMB = @Ln_LsupArrCur_ObligationSeq_NUMB
        AND a.SupportYearMonth_NUMB = SUBSTRING(CONVERT(VARCHAR(6),@Ad_Process_DATE,112),1,6)
        AND a.EventGlobalSeq_NUMB = (SELECT MAX (b.EventGlobalSeq_NUMB) 
                                       FROM LSUP_Y1 b
                                      WHERE b.Case_IDNO = @Ln_LsupArrCur_Case_IDNO
                                        AND b.OrderSeq_NUMB = @Ln_LsupArrCur_OrderSeq_NUMB
                                        AND b.ObligationSeq_NUMB = @Ln_LsupArrCur_ObligationSeq_NUMB
                                        AND b.SupportYearMonth_NUMB = a.SupportYearMonth_NUMB);

     SET @Ln_Arrear_AMNT = 0;
     SET @Ln_Arrear_AMNT = @Ln_ArrearN_AMNT + @Ln_ArrearT_AMNT;

     IF @Ln_ArrearN_AMNT > 0
        AND @Ln_ArrearT_AMNT < 0
      BEGIN
       SET @Ln_ArrearN_AMNT = @Ln_ArrearN_AMNT + @Ln_ArrearT_AMNT;

       IF @Ln_ArrearN_AMNT < 0
        BEGIN
         SET @Ln_ArrearN_AMNT = 0;
        END

       SET @Ln_ArrearT_AMNT = 0;
      END

     IF @Ln_ArrearT_AMNT > 0
        AND @Ln_ArrearN_AMNT < 0
      BEGIN
       SET @Ln_ArrearT_AMNT = @Ln_ArrearT_AMNT + @Ln_ArrearN_AMNT;

       IF @Ln_ArrearT_AMNT < 0
        BEGIN
         SET @Ln_ArrearT_AMNT = 0;
        END

       SET @Ln_ArrearN_AMNT = 0;
      END

     IF @Ln_ArrearT_AMNT < 0
      BEGIN
       SET @Ln_ArrearT_AMNT = 0;
      END

     IF @Ln_ArrearN_AMNT < 0
      BEGIN
       SET @Ln_ArrearN_AMNT = 0;
      END

     IF @Ln_LsupArrCur_Owed_AMNT >= @Ln_ArrearN_AMNT + @Ln_ArrearT_AMNT
      BEGIN
       SET @An_TotArrear_AMNT = @An_TotArrear_AMNT + @Ln_ArrearN_AMNT + @Ln_ArrearT_AMNT;
       SET @Ln_OblePrCuml_AMNT = 0;

       BEGIN
        DECLARE LsupPr_CUR INSENSITIVE CURSOR FOR 
        SELECT a.Case_IDNO,
                   a.OrderSeq_NUMB,
                   a.ObligationSeq_NUMB,
                   SUM (CASE a.TypeBucket_CODE
                         WHEN 'E'
                          THEN 0
                         ELSE a.ArrToBePaid_AMNT
                        END) AS ArrOwed_AMNT,
                   a.PrDistribute_QNTY
              FROM #Towed_P1 a
             WHERE a.Case_IDNO = @Ln_Case_IDNO
               AND a.OrderSeq_NUMB = @Ln_OrderSeq_NUMB
               AND a.ObligationSeq_NUMB = @Ln_ObligationSeq_NUMB
               AND a.TypeOrder_CODE != @Lc_TypeOrderV_CODE
             GROUP BY a.Case_IDNO,
                      a.OrderSeq_NUMB,
                      a.ObligationSeq_NUMB,
                      a.PrDistribute_QNTY;
        SET @Ls_Sql_TEXT = 'OPEN LsupPr_CUR - 1';        
        SET @Ls_Sqldata_TEXT = '';
        
        OPEN LsupPr_CUR;

        SET @Ls_Sql_TEXT = 'FETCH LsupPr_CUR - 1';        
        SET @Ls_Sqldata_TEXT = '';
        
        FETCH NEXT FROM LsupPr_CUR INTO @Ln_LsupPrCur_Case_IDNO, @Ln_LsupPrCur_OrderSeq_NUMB, @Ln_LsupPrCur_ObligationSeq_NUMB, @Ln_LsupPrCur_Owed_AMNT, @Ln_LsupPrCur_PrDistribute_QNTY;

        SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
        SET @Ls_Sql_TEXT = 'WHILE - 2';		
        SET @Ls_Sqldata_TEXT = '';
        -- Cursor Started
        WHILE @Li_FetchStatus_QNTY = 0
         BEGIN
          SET @Ln_ArrCumulT_AMNT = 0;
          SET @Ln_ArrCumulN_AMNT = 0;
          SET @Ls_Sql_TEXT = 'SELECT TOWED_Y1 -1';          
          SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @Ln_LsupPrCur_Case_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @Ln_LsupPrCur_OrderSeq_NUMB AS VARCHAR ),'')+ ', ObligationSeq_NUMB = ' + ISNULL(CAST( @Ln_LsupPrCur_ObligationSeq_NUMB AS VARCHAR ),'');

          SELECT @Ln_ArrCumulT_AMNT = ISNULL (SUM (a.ArrToBePaid_AMNT), 0)
            FROM #Towed_P1 a
           WHERE a.Case_IDNO = @Ln_LsupPrCur_Case_IDNO
             AND a.OrderSeq_NUMB = @Ln_LsupPrCur_OrderSeq_NUMB
             AND a.ObligationSeq_NUMB = @Ln_LsupPrCur_ObligationSeq_NUMB
             AND a.TypeBucket_CODE IN (@Lc_PaaTypeBucket_CODE, @Lc_UdaTypeBucket_CODE)
             AND a.PrDistribute_QNTY < @Ln_LsupPrCur_PrDistribute_QNTY;

          SET @Ls_Sql_TEXT = 'SELECT TOWED_Y1 -2';          
          SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @Ln_LsupPrCur_Case_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @Ln_LsupPrCur_OrderSeq_NUMB AS VARCHAR ),'')+ ', ObligationSeq_NUMB = ' + ISNULL(CAST( @Ln_LsupPrCur_ObligationSeq_NUMB AS VARCHAR ),'')+ ', TypeBucket_CODE = ' + ISNULL(@Lc_CsTypeBucket_CODE,'')+ ', TypeWelfare_CODE = ' + ISNULL(@Lc_TypeWelfareTanf_CODE,'');

          SELECT @Ln_ArrCumulT_AMNT = ISNULL (SUM (a.ArrToBePaid_AMNT), 0) + @Ln_ArrCumulT_AMNT
            FROM #Towed_P1 a
           WHERE a.Case_IDNO = @Ln_LsupPrCur_Case_IDNO
             AND a.OrderSeq_NUMB = @Ln_LsupPrCur_OrderSeq_NUMB
             AND a.ObligationSeq_NUMB = @Ln_LsupPrCur_ObligationSeq_NUMB
             AND a.TypeBucket_CODE = @Lc_CsTypeBucket_CODE
             AND a.TypeWelfare_CODE = @Lc_TypeWelfareTanf_CODE
             AND a.TypeDebt_CODE != @Lc_TypeDebtMedicaid_CODE
             AND a.PrDistribute_QNTY < @Ln_LsupPrCur_PrDistribute_QNTY;

          SET @Ls_Sql_TEXT = 'SELECT TOWED_Y1 -3';          
          SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @Ln_LsupPrCur_Case_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @Ln_LsupPrCur_OrderSeq_NUMB AS VARCHAR ),'')+ ', ObligationSeq_NUMB = ' + ISNULL(CAST( @Ln_LsupPrCur_ObligationSeq_NUMB AS VARCHAR ),'');

          SELECT @Ln_ArrCumulN_AMNT = ISNULL (SUM (a.ArrToBePaid_AMNT), 0)
            FROM #Towed_P1 a
           WHERE a.Case_IDNO = @Ln_LsupPrCur_Case_IDNO
             AND a.OrderSeq_NUMB = @Ln_LsupPrCur_OrderSeq_NUMB
             AND a.ObligationSeq_NUMB = @Ln_LsupPrCur_ObligationSeq_NUMB
             AND a.TypeBucket_CODE NOT IN (@Lc_PaaTypeBucket_CODE, @Lc_UdaTypeBucket_CODE, @Lc_CsTypeBucket_CODE, @Lc_ExptTypeBucket_CODE)
             AND a.PrDistribute_QNTY < @Ln_LsupPrCur_PrDistribute_QNTY;

          SET @Ls_Sql_TEXT = 'SELECT TOWED_Y1 -4';          
          SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @Ln_LsupPrCur_Case_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @Ln_LsupPrCur_OrderSeq_NUMB AS VARCHAR ),'')+ ', ObligationSeq_NUMB = ' + ISNULL(CAST( @Ln_LsupPrCur_ObligationSeq_NUMB AS VARCHAR ),'')+ ', TypeBucket_CODE = ' + ISNULL(@Lc_CsTypeBucket_CODE,'')+ ', TypeDebt_CODE = ' + ISNULL(@Lc_TypeDebtMedicaid_CODE,'');

          SELECT @Ln_ArrCumulN_AMNT = ISNULL (SUM (a.ArrToBePaid_AMNT), 0) + @Ln_ArrCumulN_AMNT
            FROM #Towed_P1 a
           WHERE a.Case_IDNO = @Ln_LsupPrCur_Case_IDNO
             AND a.OrderSeq_NUMB = @Ln_LsupPrCur_OrderSeq_NUMB
             AND a.ObligationSeq_NUMB = @Ln_LsupPrCur_ObligationSeq_NUMB
             AND a.TypeBucket_CODE = @Lc_CsTypeBucket_CODE
             AND (a.TypeWelfare_CODE != @Lc_TypeWelfareTanf_CODE
                   OR a.TypeDebt_CODE = @Lc_TypeDebtMedicaid_CODE)
             AND a.PrDistribute_QNTY < @Ln_LsupPrCur_PrDistribute_QNTY;

          SET @Ls_Sql_TEXT = 'UPDATE TOWED_Y1 -1';          
          SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @Ln_LsupPrCur_Case_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @Ln_LsupPrCur_OrderSeq_NUMB AS VARCHAR ),'')+ ', ObligationSeq_NUMB = ' + ISNULL(CAST( @Ln_LsupPrCur_ObligationSeq_NUMB AS VARCHAR ),'')+ ', PrDistribute_QNTY = ' + ISNULL(CAST( @Ln_LsupPrCur_PrDistribute_QNTY AS VARCHAR ),'')+ ', TypeBucket_CODE = ' + ISNULL(@Lc_CsTypeBucket_CODE,'');

          UPDATE #Towed_P1
             SET ArrToBePaid_AMNT = CASE TypeDebt_CODE
                                     WHEN @Lc_TypeDebtMedicaid_CODE
                                      THEN
                                      CASE SIGN (@Ln_ArrearN_AMNT - ArrToBePaid_AMNT)
                                       WHEN 1
                                        THEN ArrToBePaid_AMNT
                                       ELSE @Ln_ArrearN_AMNT
                                      END
                                     ELSE
                                      CASE TypeWelfare_CODE
                                       WHEN @Lc_TypeWelfareTanf_CODE
                                        THEN
                                        CASE SIGN (@Ln_ArrearT_AMNT - ArrToBePaid_AMNT)
                                         WHEN 1
                                          THEN ArrToBePaid_AMNT
                                         ELSE @Ln_ArrearT_AMNT
                                        END
                                       ELSE
                                        CASE SIGN (@Ln_ArrearN_AMNT - ArrToBePaid_AMNT)
                                         WHEN 1
                                          THEN ArrToBePaid_AMNT
                                         ELSE @Ln_ArrearN_AMNT
                                        END
                                      END
                                    END
           WHERE Case_IDNO = @Ln_LsupPrCur_Case_IDNO
             AND OrderSeq_NUMB = @Ln_LsupPrCur_OrderSeq_NUMB
             AND ObligationSeq_NUMB = @Ln_LsupPrCur_ObligationSeq_NUMB
             AND PrDistribute_QNTY = @Ln_LsupPrCur_PrDistribute_QNTY
             AND TypeBucket_CODE = @Lc_CsTypeBucket_CODE;

          SET @Ls_Sql_TEXT = 'UPDATE TOWED_Y1 -2';          
          SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @Ln_LsupPrCur_Case_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @Ln_LsupPrCur_OrderSeq_NUMB AS VARCHAR ),'')+ ', ObligationSeq_NUMB = ' + ISNULL(CAST( @Ln_LsupPrCur_ObligationSeq_NUMB AS VARCHAR ),'')+ ', PrDistribute_QNTY = ' + ISNULL(CAST( @Ln_LsupPrCur_PrDistribute_QNTY AS VARCHAR ),'');

          UPDATE #Towed_P1
             SET ArrToBePaid_AMNT = CASE SIGN (@Ln_ArrearT_AMNT - @Ln_ArrCumulT_AMNT)
                                     WHEN -1
                                      THEN 0
                                     WHEN 0
                                      THEN 0
                                     ELSE
                                      CASE SIGN ((@Ln_ArrearT_AMNT - @Ln_ArrCumulT_AMNT) - ArrToBePaid_AMNT)
                                       WHEN -1
                                        THEN (@Ln_ArrearT_AMNT - @Ln_ArrCumulT_AMNT)
                                       ELSE ArrToBePaid_AMNT
                                      END
                                    END
           WHERE Case_IDNO = @Ln_LsupPrCur_Case_IDNO
             AND OrderSeq_NUMB = @Ln_LsupPrCur_OrderSeq_NUMB
             AND ObligationSeq_NUMB = @Ln_LsupPrCur_ObligationSeq_NUMB
             AND PrDistribute_QNTY = @Ln_LsupPrCur_PrDistribute_QNTY
             AND TypeBucket_CODE IN (@Lc_PaaTypeBucket_CODE, @Lc_UdaTypeBucket_CODE);

          SET @Ls_Sql_TEXT = 'UPDATE TOWED_Y1 -3';          
          SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @Ln_LsupPrCur_Case_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @Ln_LsupPrCur_OrderSeq_NUMB AS VARCHAR ),'')+ ', ObligationSeq_NUMB = ' + ISNULL(CAST( @Ln_LsupPrCur_ObligationSeq_NUMB AS VARCHAR ),'')+ ', PrDistribute_QNTY = ' + ISNULL(CAST( @Ln_LsupPrCur_PrDistribute_QNTY AS VARCHAR ),'');

          UPDATE #Towed_P1
             SET ArrToBePaid_AMNT = CASE SIGN (@Ln_ArrearN_AMNT - @Ln_ArrCumulN_AMNT)
                                     WHEN -1
                                      THEN 0
                                     WHEN 0
                                      THEN 0
                                     ELSE
                                      CASE SIGN ((@Ln_ArrearN_AMNT - @Ln_ArrCumulN_AMNT) - ArrToBePaid_AMNT)
                                       WHEN -1
                                        THEN (@Ln_ArrearN_AMNT - @Ln_ArrCumulN_AMNT)
                                       ELSE ArrToBePaid_AMNT
                                      END
                                    END
           WHERE Case_IDNO = @Ln_LsupPrCur_Case_IDNO
             AND OrderSeq_NUMB = @Ln_LsupPrCur_OrderSeq_NUMB
             AND ObligationSeq_NUMB = @Ln_LsupPrCur_ObligationSeq_NUMB
             AND PrDistribute_QNTY = @Ln_LsupPrCur_PrDistribute_QNTY
             AND TypeBucket_CODE NOT IN (@Lc_PaaTypeBucket_CODE, @Lc_UdaTypeBucket_CODE, @Lc_ExptTypeBucket_CODE, @Lc_CsTypeBucket_CODE);

          SET @Ln_OblePrCuml_AMNT = @Ln_OblePrCuml_AMNT + @Ln_LsupPrCur_Owed_AMNT;
          
          SET @Ls_Sql_TEXT = 'FETCH LsupPr_CUR - 2';          
          SET @Ls_Sqldata_TEXT = '';
          
          FETCH NEXT FROM LsupPr_CUR INTO @Ln_LsupPrCur_Case_IDNO, @Ln_LsupPrCur_OrderSeq_NUMB, @Ln_LsupPrCur_ObligationSeq_NUMB, @Ln_LsupPrCur_Owed_AMNT, @Ln_LsupPrCur_PrDistribute_QNTY;

          SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
         END

        CLOSE LsupPr_CUR;

        DEALLOCATE LsupPr_CUR;
       END
      END
     ELSE
      BEGIN
       SET @An_TotArrear_AMNT = @An_TotArrear_AMNT + @Ln_LsupArrCur_Owed_AMNT;
      END

     SET @Ln_Arrear_AMNT = 0;
     SET @Ls_Sql_TEXT = ' SELECT TOWED_EXPT ';     
     SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @Ln_LsupArrCur_Case_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @Ln_LsupArrCur_OrderSeq_NUMB AS VARCHAR ),'')+ ', ObligationSeq_NUMB = ' + ISNULL(CAST( @Ln_LsupArrCur_ObligationSeq_NUMB AS VARCHAR ),'');

     SELECT @Ln_Arrear_AMNT = ISNULL (SUM (a.ArrToBePaid_AMNT), 0)
       FROM #Towed_P1 a
      WHERE a.Case_IDNO = @Ln_LsupArrCur_Case_IDNO
        AND a.OrderSeq_NUMB = @Ln_LsupArrCur_OrderSeq_NUMB
        AND a.ObligationSeq_NUMB = @Ln_LsupArrCur_ObligationSeq_NUMB
        AND a.TypeBucket_CODE NOT IN (@Lc_CsTypeBucket_CODE, @Lc_ExptTypeBucket_CODE);

     IF @Ln_Arrear_AMNT < 0
      BEGIN
       SET @Ln_Arrear_AMNT = 0;
      END

     SET @Ls_Sql_TEXT = 'UPDATE TOWED_EXPT ';     
     SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @Ln_LsupArrCur_Case_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @Ln_LsupArrCur_OrderSeq_NUMB AS VARCHAR ),'')+ ', ObligationSeq_NUMB = ' + ISNULL(CAST( @Ln_LsupArrCur_ObligationSeq_NUMB AS VARCHAR ),'')+ ', TypeBucket_CODE = ' + ISNULL(@Lc_ExptTypeBucket_CODE,'');

     UPDATE #Towed_P1
        SET ArrToBePaid_AMNT = CASE SIGN (@Ln_Arrear_AMNT - ArrToBePaid_AMNT)
                                WHEN -1
                                 THEN @Ln_Arrear_AMNT
                                WHEN 0
                                 THEN ArrToBePaid_AMNT
                                WHEN 1
                                 THEN ArrToBePaid_AMNT
                               END
      WHERE Case_IDNO = @Ln_LsupArrCur_Case_IDNO
        AND OrderSeq_NUMB = @Ln_LsupArrCur_OrderSeq_NUMB
        AND ObligationSeq_NUMB = @Ln_LsupArrCur_ObligationSeq_NUMB
        AND TypeBucket_CODE = @Lc_ExptTypeBucket_CODE
        AND ArrToBePaid_AMNT > 0;

     SET @Ls_Sql_TEXT = 'FETCH  LsupPr_CUR-2';
     SET @Ls_Sqldata_TEXT = '';
     FETCH NEXT FROM LsupArr_CUR INTO @Ln_LsupArrCur_Case_IDNO, @Ln_LsupArrCur_OrderSeq_NUMB, @Ln_LsupArrCur_ObligationSeq_NUMB, @Ln_LsupArrCur_Owed_AMNT;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END

   CLOSE LsupArr_CUR;

   DEALLOCATE LsupArr_CUR;

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = '';
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

   IF CURSOR_STATUS ('LOCAL', 'LsupArr_CUR') IN (0, 1)
    BEGIN
     CLOSE LsupArr_CUR;

     DEALLOCATE LsupArr_CUR;
    END

   IF CURSOR_STATUS ('LOCAL', 'LsupPr_CUR') IN (0, 1)
    BEGIN
     CLOSE LsupPr_CUR;

     DEALLOCATE LsupPr_CUR;
    END

   SET @Ln_Error_NUMB = ERROR_NUMBER ();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE ();
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
