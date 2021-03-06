/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICE_FIN$SP_QUERY_LSUP]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICE_FIN$SP_QUERY_LSUP
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
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICE_FIN$SP_QUERY_LSUP] (
   @An_Case_IDNO                      NUMERIC (6),
   @An_SupportYearMonth_NUMB          NUMERIC (6),     --SupportYearMonth_NUMB
   @An_OrderSeq_NUMB                  NUMERIC (2),
   @An_ObligationSeq_NUMB             NUMERIC (2),
   @An_PayorMCI_IDNO                  NUMERIC (10),
   @As_TypeDebt_CODE                  CHAR (2),
   @Ai_RowFrom_NUMB                   INT,
   @Ai_RowTo_NUMB                     INT,
   @Ac_Msg_CODE                       CHAR (5) OUTPUT,
   @As_DescriptionError_TEXT          VARCHAR (4000) OUTPUT)
AS
   BEGIN
      SET  NOCOUNT ON;

      DECLARE
         @Lc_StatusFailed_CODE CHAR (1) = 'F',
         @Lc_StatusSuccess_CODE CHAR (1) = 'S',
         @Ls_Procedure_NAME VARCHAR (100)
            = 'BATCH_GEN_NOTICE_FIN$SP_QUERY_LSUP';


      DECLARE
         @Ln_SupportYearMonth_NUMB NUMERIC (6),
         @Ln_OrderSeq_NUMB NUMERIC (2),
         @Ln_ObligationSeq_NUMB NUMERIC (2),
         @Ls_ErrorDesc_TEXT VARCHAR (4000),
         @Ls_Sql_TEXT VARCHAR (100) = '',
         @Ls_Sqldata_TEXT VARCHAR (1000) = '',
         @Ls_DescriptionError_TEXT VARCHAR (4000),
         @Ls_Select_TEXT VARCHAR (6000),
         @Ls_Select1_TEXT VARCHAR (6000),
         @Ls_Select2_TEXT VARCHAR (6000),
         @Ls_From_TEXT VARCHAR (6000),
         @Ls_Where_TEXT VARCHAR (2000),
         @Ls_Where1_TEXT VARCHAR (2000);


      BEGIN TRY
        
         SET @Ln_SupportYearMonth_NUMB = ISNULL( @An_SupportYearMonth_NUMB ,0);
         SET @Ln_OrderSeq_NUMB =   ISNULL( @An_OrderSeq_NUMB ,0);
         SET @Ln_ObligationSeq_NUMB = ISNULL( @An_ObligationSeq_NUMB,0);
         SET @Ls_Select1_TEXT =
                  ' SELECT   SupportYearMonth_NUMB,    '
                + '          program_type AS TypeWelfare_CODE , '
                + '          current_support AS MtdCurSupOwed_AMNT , '
                + '          naa AS ArrearsNaa_AMNT, '
                + '          paa AS ArrearsPaa_AMNT, '
                + '          taa AS ArrearsTaa_AMNT, '
                + '          caa AS ArrearsCaa_AMNT, '
                + '          upa AS ArrearsUpa_AMNT, '
                + '          uda AS ArrearsUda_AMNT, '
                + '          ivef AS ArrearsIvef_AMNT,'
                + '          nffc AS ArrearsNffc_AMNT, '
                + '          nivd AS ArrearsNivd_AMNT, '
                + '          medi AS ArrearsMedi_AMNT, '
                + '          cs_paid AS AppTotCurSup_AMNT,    '
                + '          arrear_paid AS ArrearPaid_AMNT, '
                + '          total AS ArrearTotal_AMNT, '
                + '          aot_expt_pay AS OweTotExptPay_AMNT, '
                + '          monthly_adj AS MonthlyAdj_AMNT,    '
                + '          interest_charges AS InterestCharges_AMNT, '
                + '          rnm,'
                + '          row_count     '
                + ' FROM ( SELECT   SupportYearMonth_NUMB,    '
                + '             program_type, '
                + '          current_support, '
                + '          naa, '
                + '          paa, '
                + '          taa, '
                + '          caa, '
                + '          upa, '
                + '          uda, '
                + '          ivef,'
                + '          nffc, '
                + '          nivd, '
                + '          medi, '
                + '          cs_paid,    '
                + '          arrear_paid, '
                + '          total, '
                + '          aot_expt_pay, '
                + '          monthly_adj,    '
                + '          interest_charges, '
                + '          REC_NUMB rnm,        '
                + '          row_count     '
                + ' FROM (SELECT SupportYearMonth_NUMB,'
                + '              program_type,        '
                + '              current_support,    '
                + '              naa,                '
                + '              paa,                '
                + '              taa,                '
                + '              caa,                '
                + '              upa,                '
                + '              uda,                '
                + '              ivef,                '
                + '              nffc,                '
                + '              nivd,                '
                + '              medi,                '
                + '              cs_paid,            '
                + '              arrear_paid,        '
                + '              total,            '
                + '              aot_expt_pay,        '
                + '              monthly_adj,        '
                + '              interest_charges,    '
                + '              COUNT(1) OVER() AS row_count ,    '
                + ' ROW_NUMBER () OVER (Order BY SupportYearMonth_NUMB DESC)  AS REC_NUMB'
                + '  FROM ( '
                + 'SELECT SupportYearMonth_NUMB SupportYearMonth_NUMB,
			   '''' program_type,
			   SUM(OweTotCurSup_AMNT) current_support,
			   SUM(OweTotNaa_AMNT - AppTotNaa_AMNT) naa,
			   SUM(OweTotPaa_AMNT - AppTotPaa_AMNT) paa,
			   SUM(OweTotTaa_AMNT - AppTotTaa_AMNT) taa,
			   SUM(OweTotCaa_AMNT - AppTotCaa_AMNT) caa,
			   SUM(OweTotUpa_AMNT - AppTotUpa_AMNT) upa,
			   SUM(OweTotUda_AMNT - AppTotUda_AMNT) uda,
			   SUM(OweTotIvef_AMNT - AppTotIvef_AMNT) ivef,
			   SUM(OweTotNffc_AMNT - AppTotNffc_AMNT) nffc,
			   SUM(OweTotNonIvd_AMNT - AppTotNonIvd_AMNT ) nivd,
			   SUM(OweTotMedi_AMNT - AppTotMedi_AMNT) medi,
			   SUM(AppTotCurSup_AMNT) cs_paid,
			   SUM(BATCH_GEN_NOTICE_FIN$SF_GET_ARREAR_PAID(a.case_idno,a.OrderSeq_NUMB,a.ObligationSeq_NUMB,a.SupportYearMonth_NUMB)) arrear_paid,    
			   SUM(
				(OweTotNaa_AMNT - AppTotNaa_AMNT) +
			   (OweTotPaa_AMNT - AppTotPaa_AMNT)  +
			   (OweTotTaa_AMNT - AppTotTaa_AMNT)  +
			   (OweTotCaa_AMNT - AppTotCaa_AMNT)  +
			   (OweTotUpa_AMNT - AppTotUpa_AMNT)  +
			   (OweTotUda_AMNT - AppTotUda_AMNT)  +
			   (OweTotIvef_AMNT - AppTotIvef_AMNT) + 
			   (OweTotNffc_AMNT - AppTotNffc_AMNT)  +
			   (OweTotNonIvd_AMNT - AppTotNonIvd_AMNT )+  
			   (OweTotMedi_AMNT - AppTotMedi_AMNT) - AppTotFuture_AMNT
			   ) total,
			   SUM(OweTotExptPay_AMNT) aot_expt_pay , 		
	   SUM(BATCH_GEN_NOTICE_FIN$SF_GET_TXN_AMT (a.case_idno,    
                                              a.OrderSeq_NUMB,            
                                                  a.ObligationSeq_NUMB,        
                                             a.SupportYearMonth_NUMB,              
                                            ''A'')) monthly_adj,    
	  SUM(BATCH_GEN_NOTICE_FIN$SF_GET_TXN_AMT(a.case_idno,     
                                             a.OrderSeq_NUMB,          
                                            a.ObligationSeq_NUMB,         
                                               a.SupportYearMonth_NUMB,            
                                          ''I'')) interest_charges ';
         SET @Ls_Select2_TEXT =
                  ' SELECT     SupportYearMonth_NUMB,    '
                + '          program_type AS TypeWelfare_CODE , '
                + '          current_support AS MtdCurSupOwed_AMNT , '
                + '          naa AS ArrearsNaa_AMNT, '
                + '          paa AS ArrearsPaa_AMNT, '
                + '          taa AS ArrearsTaa_AMNT, '
                + '          caa AS ArrearsCaa_AMNT, '
                + '          upa AS ArrearsUpa_AMNT, '
                + '          uda AS ArrearsUda_AMNT, '
                + '          ivef AS ArrearsIvef_AMNT,'
                + '          nffc AS ArrearsNffc_AMNT, '
                + '          nivd AS ArrearsNivd_AMNT, '
                + '          medi AS ArrearsMedi_AMNT, '
                + '          cs_paid AS AppTotCurSup_AMNT,    '
                + '          arrear_paid AS ArrearPaid_AMNT, '
                + '          total AS ArrearTotal_AMNT, '
                + '          aot_expt_pay AS OweTotExptPay_AMNT, '
                + '          monthly_adj AS MonthlyAdj_AMNT,    '
                + '          interest_charges AS InterestCharges_AMNT, '
                + '          rnm,'
                + '          row_count    '
                + ' FROM (SELECT SupportYearMonth_NUMB,     '
                + '              program_type,     '
                + '              current_support, '
                + '              naa, '
                + '              paa, '
                + '              taa, '
                + '              caa, '
                + '              upa, '
                + '              uda, '
                + '              ivef,     '
                + '              nffc,     '
                + '              nivd,  '
                + '              medi,     '
                + '              cs_paid,     '
                + '              arrear_paid, '
                + '              total,    '
                + '              aot_expt_pay, '
                + '              monthly_adj,    '
                + '              interest_charges, '
                + '              REC_NUMB rnm,         '
                + '              row_count    '
                + '  FROM ( '
                + 'SELECT SupportYearMonth_NUMB SupportYearMonth_NUMB,
				   TypeWelfare_CODE program_type,
				   (OweTotCurSup_AMNT) current_support,
				   (OweTotNaa_AMNT - AppTotNaa_AMNT) naa,
				   (OweTotPaa_AMNT - AppTotPaa_AMNT) paa,
				   (OweTotTaa_AMNT - AppTotTaa_AMNT) taa,
				   (OweTotCaa_AMNT - AppTotCaa_AMNT) caa,
				   (OweTotUpa_AMNT - AppTotUpa_AMNT) upa,
				   (OweTotUda_AMNT - AppTotUda_AMNT) uda,
				   (OweTotIvef_AMNT - AppTotIvef_AMNT) ivef,
				   (OweTotNffc_AMNT - AppTotNffc_AMNT) nffc,
				   (OweTotNonIvd_AMNT - AppTotNonIvd_AMNT ) nivd,
				   (OweTotMedi_AMNT - AppTotMedi_AMNT) medi,
				   (AppTotCurSup_AMNT) cs_paid,
				   (BATCH_GEN_NOTICE_FIN$SF_GET_ARREAR_PAID(A.Case_IDNO,a.OrderSeq_NUMB,a.ObligationSeq_NUMB,a.SupportYearMonth_NUMB)) arrear_paid,     
				   SUM(
					(OweTotNaa_AMNT - AppTotNaa_AMNT) +
				   (OweTotPaa_AMNT - AppTotPaa_AMNT)  +
				   (OweTotTaa_AMNT - AppTotTaa_AMNT)  +
				   (OweTotCaa_AMNT - AppTotCaa_AMNT)  +
				   (OweTotUpa_AMNT - AppTotUpa_AMNT)  +
				   (OweTotUda_AMNT - AppTotUda_AMNT)  +
				   (OweTotIvef_AMNT - AppTotIvef_AMNT) + 
				   (OweTotNffc_AMNT - AppTotNffc_AMNT)  +
				   (OweTotNonIvd_AMNT - AppTotNonIvd_AMNT )+  
				   (OweTotMedi_AMNT - AppTotMedi_AMNT) - AppTotFuture_AMNT
				   ) total,
				   (OweTotExptPay_AMNT) aot_expt_pay, 
				 (BATCH_GEN_NOTICE_FIN$SF_GET_TXN_AMT(a.case_idno,     
														a.seq_order,            
														a.seq_obligation,         
														a.mth_support,            
													   ''A'')) monthly_adj,     
				   
				  (BATCH_GEN_NOTICE_FIN$SF_GET_TXN_AMT(A.Case_IDNO,    
														a.seq_order,            
													  a.seq_obligation,        
													   a.mth_support,          
												''I'')) interest_charges,     
				   
					COUNT(1) OVER() AS row_count ,
					ROW_NUMBER () OVER (Order BY SupportYearMonth_NUMB DESC)  AS REC_NUMB';

         SET @Ls_Where_TEXT =
                ' where REC_NUMB <= ' + CAST (@Ai_RowTo_NUMB AS CHAR) + ' ) Z';
         SET @Ls_Where1_TEXT = ' WHERE rnm >= ' + CAST (@Ai_RowFrom_NUMB AS CHAR);

         IF @Ln_SupportYearMonth_NUMB = 0
            BEGIN
               IF @Ln_OrderSeq_NUMB != 0 AND @Ln_ObligationSeq_NUMB != 0
                  BEGIN
                    
                     SET @Ls_Select_TEXT = @Ls_Select2_TEXT;
                     SET @Ls_From_TEXT =
                              '   FROM  LSUP_Y1 a  
									      WHERE a.case_idno = '
                            + CAST (@An_Case_IDNO AS CHAR)
                            + '    AND a.OrderSeq_NUMB = '
                            + CAST (@Ln_OrderSeq_NUMB AS CHAR)
                            + '    AND a.ObligationSeq_NUMB = '
                            + CAST (@Ln_ObligationSeq_NUMB AS CHAR)
                            + '   AND a.SupportYearMonth_NUMB >= (SELECT NVL(MIN(b.SupportYearMonth_NUMB),0) 
									                    FROM  LSUP_Y1 b  
									                   WHERE a.Case_IDNO = b.Case_IDNO  
									                     AND a.OrderSeq_NUMB = b.OrderSeq_NUMB  
									                     AND a.ObligationSeq_NUMB = b.ObligationSeq_NUMB  
									                     AND b.EventFunctionalSeq_NUMB = 9999 )  
											 AND a.seq_event_global = (SELECT MAX(seq_event_global)  
									                                FROM  LSUP_Y1 b 
									                                WHERE a.Case_IDNO = b.Case_IDNO  
									                                  AND a.OrderSeq_NUMB = b.OrderSeq_NUMB  
									                                  AND a.ObligationSeq_NUMB = b.ObligationSeq_NUMB 
									                                  AND a.SupportYearMonth_NUMB = b.SupportYearMonth_NUMB)  
									      
									     )x ';
                  END
               ELSE
                  IF ( (@As_TypeDebt_CODE IS NOT NULL
                        OR @As_TypeDebt_CODE != '')
                      AND @Ln_OrderSeq_NUMB != 0)
                     BEGIN
                        SET @Ls_Select_TEXT = @Ls_Select1_TEXT;
                        SET @Ls_From_TEXT =
                                 ' FROM  LSUP_Y1 a  
									     WHERE a.Case_IDNO =  '
                               + CAST (@An_Case_IDNO AS CHAR)
                               + ' AND a.OrderSeq_NUMB = '
                               + CAST (@Ln_OrderSeq_NUMB AS CHAR)
                               + '   AND a.ObligationSeq_NUMB IN(SELECT DISTINCT ObligationSeq_NUMB 
									                          FROM  oble_y1 
									                         WHERE Case_IDNO = '
                               + CAST (@An_case_idno AS CHAR)
                               + '                                 AND OrderSeq_NUMB = '
                               + CAST (@Ln_OrderSeq_NUMB AS CHAR)
                               + '                               AND TypeDebt_CODE = '
                               + ''''
                               + @As_TypeDebt_CODE
                               + ''''
                               + '                                 AND EndValidity_DATE = ''12/31/9999'') 
									       AND a.SupportYearMonth_NUMB >= (SELECT NVL(MIN(b.SupportYearMonth_NUMB),0)  
									                    FROM  LSUP_Y1 b  
									                    WHERE a.Case_IDNO = b.Case_IDNO  
									                     AND a.OrderSeq_NUMB = b.OrderSeq_NUMB  
									                      AND a.ObligationSeq_NUMB = b.ObligationSeq_NUMB  
									                   AND b.EventFunctionalSeq_NUMB = 9999 )  
									       AND a.EventGlobalSeq_NUMB = (SELECT MAX(b.EventGlobalSeq_NUMB) 
									                    FROM  LSUP_Y1 b  
									                  WHERE a.Case_IDNO = b.Case_IDNO  
									                      AND a.OrderSeq_NUMB = b.OrderSeq_NUMB  
									                      AND a.ObligationSeq_NUMB = b.ObligationSeq_NUMB  
									                      AND a.SupportYearMonth_NUMB = b.SupportYearMonth_NUMB)   
									        GROUP BY SupportYearMonth_NUMB 
									         
									        )x)y ';
                     END
                  ELSE
                     IF ( (@As_TypeDebt_CODE IS NOT NULL
                           OR @As_TypeDebt_CODE != '')
                         AND @Ln_OrderSeq_NUMB = 0)
                        BEGIN
                           SET @Ls_Select_TEXT = @Ls_Select1_TEXT;
                           SET @Ls_From_TEXT =
                                  '  FROM  LSUP_Y1 a  
												 WHERE a.Case_IDNO = '
                                  + CAST (@An_Case_IDNO AS CHAR)
                                  + +'   AND a.ObligationSeq_NUMB IN(SELECT OB.ObligationSeq_NUMB  
										                                FROM  OBLE_Y1  OB 
										                               WHERE OB.Case_IDNO = '
                                  + CAST (@An_Case_IDNO AS CHAR)
                                  + '                              AND OB.TypeDebt_CODE =  '
                                  + ''''
                                  + @As_TypeDebt_CODE
                                  + '                              AND  OB.EndValidity_DATE = ''12/31/9999'')'
                                  + '   AND a.SupportYearMonth_NUMB >= (SELECT ISNULL(MIN(b.SupportYearMonth_NUMB),0)  
										                    FROM  LSUP_Y1 b  
										                   WHERE a.Case_IDNO = b.Case_IDNO  
										                      AND a.OrderSeq_NUMB = b.OrderSeq_NUMB  
										                      AND a.ObligationSeq_NUMB = b.ObligationSeq_NUMB  
										                     AND b.EventFunctionalSeq_NUMB = 9999 )  
										      AND a.EventGlobalSeq_NUMB = (SELECT MAX(b.EventGlobalSeq_NUMB)  
										                                  FROM  LSUP_Y1 b                     
										                                 WHERE a.Case_IDNO = b.Case_IDNO         
										                                    AND a.OrderSeq_NUMB = b.OrderSeq_NUMB  
										                                    AND a.ObligationSeq_NUMB = b.ObligationSeq_NUMB     
										                                    AND a.SupportYearMonth_NUMB = b.SupportYearMonth_NUMB)        
										     GROUP BY SupportYearMonth_NUMB             
										      
										     )x) y';
                        END
                     ELSE
                        BEGIN
                           IF   (  @An_Case_IDNO IS NOT NULL
                              AND @Ln_OrderSeq_NUMB = 0
                              AND @Ln_ObligationSeq_NUMB = 0 )
                              BEGIN
                                 SET @Ls_Select_TEXT = @Ls_Select1_TEXT;
                                 SET @Ls_From_TEXT =
                                        '  FROM  LSUP_Y1 a  
											 WHERE a.Case_IDNO = '
                                        + CAST (@An_Case_IDNO AS CHAR)
                                        + '   AND a.SupportYearMonth_NUMB >= (SELECT ISNULL(MIN(b.SupportYearMonth_NUMB),0)  
										                  FROM  LSUP_Y1 b  
										                  WHERE a.Case_IDNO = b.Case_IDNO  
										                     AND a.OrderSeq_NUMB = b.OrderSeq_NUMB  
										                    AND a.ObligationSeq_NUMB = b.ObligationSeq_NUMB  
										                    AND b.EventFunctionalSeq_NUMB = 9999 ) 
										    AND a.EventGlobalSeq_NUMB = (SELECT MAX(b.EventGlobalSeq_NUMB)  
										                                     FROM  LSUP_Y1 b 
										                                WHERE a.Case_IDNO = b.Case_IDNO  
										                                AND a.OrderSeq_NUMB = b.OrderSeq_NUMB  
										                                   AND a.ObligationSeq_NUMB = b.ObligationSeq_NUMB  
										                                   AND a.SupportYearMonth_NUMB = b.SupportYearMonth_NUMB)  
										    GROUP BY SupportYearMonth_NUMB  
										    
										   )x)y ';
                              END
                           ELSE
                              IF (    @An_Case_IDNO IS NOT NULL
                                 AND @Ln_OrderSeq_NUMB != 0
                                 AND @Ln_ObligationSeq_NUMB = 0 )
                                 BEGIN
                                    SET @Ls_Select_TEXT = @Ls_Select1_TEXT;
                                    SET @Ls_From_TEXT =
                                             ' FROM LSUP_Y1 a '
                                           + 'WHERE A.Case_IDNO = '
                                           + ''''
                                           + CAST (@An_Case_IDNO AS CHAR)
                                           + ''''
                                           + '  AND a.OrderSeq_NUMB = '
                                           + CAST (@Ln_OrderSeq_NUMB AS CHAR)
                                           + '   AND a.SupportYearMonth_NUMB >= (SELECT ISNULL(MIN(b.SupportYearMonth_NUMB),0) '
                                           + '                 FROM  LSUP_Y1 b '
                                           + '                WHERE a.Case_IDNO = b.Case_IDNO '
                                           + '                  AND a.OrderSeq_NUMB = b.OrderSeq_NUMB '
                                           + '                  AND a.ObligationSeq_NUMB = b.ObligationSeq_NUMB '
                                           + '                  AND b.EventFunctionalSeq_NUMB = 9999 ) '
                                           + '  AND a.EventGlobalSeq_NUMB = (SELECT MAX(b.EventGlobalSeq_NUMB) '
                                           + '                                  FROM  LSUP_Y1 b '
                                           + '                              WHERE a.Case_IDNO = b.Case_IDNO '
                                           + '                                  AND a.OrderSeq_NUMB = b.OrderSeq_NUMB '
                                           + '                                  AND a.ObligationSeq_NUMB = b.ObligationSeq_NUMB '
                                           + '                                  AND a.SupportYearMonth_NUMB = b.SupportYearMonth_NUMB) '
                                           + ' GROUP BY SupportYearMonth_NUMB '
                                           + '  
										   )x)y ';
                                 END
                              ELSE
                                 IF ( @An_Case_IDNO IS NULL
                                    AND @An_PayorMCI_IDNO IS NOT NULL )
                                    BEGIN
                                       SET @Ls_Select_TEXT = @Ls_Select1_TEXT;
                                       SET @Ls_From_TEXT =
                                              ' FROM  LSUP_Y1  a '
                                              + ' WHERE a.Case_IDNO IN ( SELECT DISTINCT Case_IDNO '
                                              + '                  FROM  cmem_Y1 '
                                              + '                 WHERE MEMBERMCI_IDNO =  '
                                              + CAST (@An_PayorMCI_IDNO AS CHAR)
                                              + '                   AND CaseRelationship_CODE =''A'' '
                                              + '                   AND CaseMemberStatus_CODE = ''A'' ) '
                                              + '   AND a.SupportYearMonth_NUMB >= (SELECT ISNULL(MIN(b.SupportYearMonth_NUMB),0) '
                                              + '                 FROM  LSUP_Y1 b '
                                              + '                WHERE a.Case_IDNO = b.Case_IDNO '
                                              + '                  AND a.OrderSeq_NUMB = b.OrderSeq_NUMB '
                                              + '                  AND a.ObligationSeq_NUMB = b.ObligationSeq_NUMB '
                                              + '                  AND b.EventFunctionalSeq_NUMB = 9999 ) '
                                              + '  AND a.EventGlobalSeq_NUMB = (SELECT MAX(b.EventGlobalSeq_NUMB) '
                                              + '                              FROM  LSUP_Y1 b '
                                              + '                             WHERE a.Case_IDNO = b.Case_IDNO '
                                              + '                               AND a.OrderSeq_NUMB = b.OrderSeq_NUMB '
                                              + '                               AND a.seq_obligation = b.seq_obligation '
                                              + '                                AND a.SupportYearMonth_NUMB = b.SupportYearMonth_NUMB) '
                                              + ' GROUP BY SupportYearMonth_NUMB '
                                              + '  )x)y ';
                                    END
                        END
            END
         ELSE
            IF ( @Ln_SupportYearMonth_NUMB != 0 )
               BEGIN
                  IF (@Ln_OrderSeq_NUMB != 0 AND @Ln_ObligationSeq_NUMB != 0 )
                     BEGIN
                        SET @Ls_Select_TEXT = @Ls_Select2_TEXT;
                        SET @Ls_From_TEXT =
                                 '   FROM  LSUP_Y1 a '
                               + '  WHERE a.Case_IDNO = '
                               + CAST (@An_Case_IDNO AS CHAR)
                               + '    AND a.OrderSeq_NUMB = '
                               + CAST (@Ln_OrderSeq_NUMB AS CHAR)
                               + '    AND a.ObligationSeq_NUMB = '
                               + CAST (@Ln_ObligationSeq_NUMB AS CHAR)
                               + '    AND a.SupportYearMonth_NUMB <= '
                               + CAST (@Ln_SupportYearMonth_NUMB AS CHAR)
                               + '    AND a.EventFunctionalSeq_NUMB = (SELECT MAX(EventFunctionalSeq_NUMB) '
                               + '                                FROM  LSUP_Y1 b '
                               + '                               WHERE a.Case_IDNO = b.Case_IDNO '
                               + '                                 AND a.OrderSeq_NUMB = b.OrderSeq_NUMB '
                               + '                                 AND a.ObligationSeq_NUMB = b.ObligationSeq_NUMB '
                               + '                                 AND a.SupportYearMonth_NUMB = b.SupportYearMonth_NUMB) '
                               + '  )x ';
                     END
                  ELSE
                     IF ( @As_TypeDebt_CODE IS NOT NULL
                        AND @Ln_OrderSeq_NUMB != 0 )
                        BEGIN
                           SET @Ls_Select_TEXT = @Ls_Select1_TEXT;
                           SET @Ls_From_TEXT =
                                    ' FROM  LSUP_Y1 a '
                                  + 'WHERE a.Case_IDNO = '
                                  + CAST (@An_Case_IDNO AS CHAR)
                                  + '  AND a.OrderSeq_NUMB = '
                                  + CAST (@Ln_OrderSeq_NUMB AS CHAR)
                                  + '  AND a.ObligationSeq_NUMB IN( SELECT ObligationSeq_NUMB '
                                  + '                             FROM  oble_Y1 '
                                  + '                            WHERE Case_IDNO = '
                                  + ''''
                                  + CAST (@An_Case_IDNO AS CHAR)
                                  + ''''
                                  + '                              AND OrderSeq_NUMB = '
                                  + CAST (@Ln_OrderSeq_NUMB AS CHAR)
                                  + '                              AND TypeDebt_CODE = '
                                  + ''''
                                  + @As_TypeDebt_CODE
                                  + ''''
                                  + '                                AND EndValidity_DATE =  ''12/31/9999'') '
                                  + '  AND a.SupportYearMonth_NUMB <= '
                                  + CAST (@Ln_SupportYearMonth_NUMB AS CHAR)
                                  + '  AND a.EventGlobalSeq_NUMB = (SELECT MAX(b.EventGlobalSeq_NUMB) '
                                  + '                              FROM  LSUP_Y1 b '
                                  + '                             WHERE a.Case_IDNO = b.Case_IDNO '
                                  + '                               AND a.OrderSeq_NUMB = b.OrderSeq_NUMB '
                                  + '                               AND a.ObligationSeq_NUMB = b.ObligationSeq_NUMB '
                                  + '                                  AND a.SupportYearMonth_NUMB = b.SupportYearMonth_NUMB) '
                                  + ' GROUP BY SupportYearMonth_NUMB '
                                  + '  )x)y ';
                        END
                     ELSE
                        BEGIN
                           IF  (   @An_Case_IDNO IS NOT NULL
                              AND @Ln_OrderSeq_NUMB = 0
                              AND @Ln_ObligationSeq_NUMB = 0 )

                              BEGIN
                                 SET @Ls_Select_TEXT = @Ls_Select1_TEXT;
                                 SET @Ls_From_TEXT =
                                          ' FROM LSUP_Y1 a '
                                        + 'WHERE A.Case_IDNO =  '
                                        + CAST (@An_Case_IDNO AS CHAR(6))
                                        + '  AND a.mth_support <= '
                                        + CAST (
                                             @Ln_SupportYearMonth_NUMB AS CHAR(6))
                                        + '  AND a.EventGlobalSeq_NUMB = (SELECT MAX(b.EventGlobalSeq_NUMB) '
                                        + '                              FROM  LSUP_Y1 b '
                                        + '                             WHERE a.Case_IDNO = b.Case_IDNO '
                                        + '                               AND a.OrderSeq_NUMB = b.OrderSeq_NUMB '
                                        + '                               AND a.ObligationSeq_NUMB = b.ObligationSeq_NUMB '
                                        + '                                 AND a.SupportYearMonth_NUMB = b.SupportYearMonth_NUMB) '
                                        + ' GROUP BY SupportYearMonth_NUMB '
                                        + '  )x)y ';
                              END
                           ELSE
                              IF  (   @An_Case_IDNO IS NOT NULL
                                 AND @ln_OrderSeq_NUMB != 0
                                 AND @ln_ObligationSeq_NUMB = 0 )
                                 BEGIN
                                    SET @Ls_Select_TEXT = @Ls_Select1_TEXT;
                                    SET @Ls_From_TEXT =
                                             ' FROM  LSUP_Y1 a '
                                           + 'WHERE A.Case_IDNO = '
                                           + CAST (@An_Case_IDNO AS CHAR(6))
                                           + '  AND a.OrderSeq_NUMB = '
                                           + CAST (@ln_OrderSeq_NUMB AS CHAR(6))
                                           + '  AND a.SupportYearMonth_NUMB <= '
                                           + CAST (
                                                @ln_SupportYearMonth_NUMB AS CHAR)
                                           + '  AND a.EventGlobalSeq_NUMB =(SELECT MAX(b.EventGlobalSeq_NUMB) '
                                           + '                             FROM LSUP_Y1 b '
                                           + '                            WHERE a.Case_IDNO = b.Case_IDNO '
                                           + '                              AND a.OrderSeq_NUMB = b.OrderSeq_NUMB '
                                           + '                              AND a.ObligationSeq_NUMB = b.ObligationSeq_NUMB '
                                           + '                                AND a.SupportYearMonth_NUMB = b.SupportYearMonth_NUMB) '
                                           + ' GROUP BY SupportYearMonth_NUMB '
                                           + '  )x)y ';
                                 END
                              ELSE
                                 IF ( @An_Case_IDNO IS NULL
                                    AND @An_PayorMCI_IDNO IS NOT NULL
									)
                                    BEGIN
                                       SET @Ls_Select_TEXT = @Ls_Select1_TEXT;
                                       SET @Ls_From_TEXT =
                                              ' FROM  LSUP_Y1 a '
                                              + ' WHERE a.Case_IDNO IN (SELECT DISTINCT Case_IDNO '
                                              + '                          FROM  cmem_Y1  '
                                              + '                         WHERE MemberMci_IDNO = '
                                              + CAST (@An_PayorMCI_IDNO AS CHAR)
                                              + '                           AND CaseRelationship_CODE =''A'' '
                                              + '                           AND CaseMemberStatus_CODE = ''A'') '
                                              + '   AND a.SupportYearMonth_NUMB <= '
                                              + CAST (
                                                   @ln_SupportYearMonth_NUMB AS CHAR)
                                              + '   AND a.EventGlobalSeq_NUMB = (SELECT MAX(b.EventGlobalSeq_NUMB) '
                                              + '                               FROM LSUP_Y1 b '
                                              + '                             WHERE a.Case_IDNO = b.Case_IDNO '
                                              + '                               AND a.OrderSeq_NUMB = b.OrderSeq_NUMB '
                                              + '                               AND a.ObligationSeq_NUMB = b.ObligationSeq_NUMB '
                                              + '                                 AND a.SupportYearMonth_NUMB =  b.SupportYearMonth_NUMB) '
                                              + ' GROUP BY SupportYearMonth_NUMB '
                                              + '  )x)y ';
                                    END
                        END
               END

      EXEC (@Ls_Select_TEXT + @Ls_From_TEXT + @Ls_Where_TEXT + @Ls_Where1_TEXT);
         SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
      END TRY
      BEGIN CATCH
         SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
         DECLARE @Li_Error_NUMB INT, @Li_ErrorLine_NUMB INT;

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
