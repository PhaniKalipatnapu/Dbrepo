/****** Object:  StoredProcedure [dbo].[BATCH_RPT_PERFORMANCE_MEASURES$SP_PROCESS_FED_MEASURES]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_RPT_PERFORMANCE_MEASURES$SP_PROCESS_FED_MEASURES
Programmer Name	:	IMP Team.
Description		:	The purpose of this batch is to calculate individual Caseworker, County, and Statewide 
                          performance in five areas defined as federal performance measures.
Frequency		:	'MONTHLY'
Developed On	:	4/24/2012
Called By		:	NONE
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_RPT_PERFORMANCE_MEASURES$SP_PROCESS_FED_MEASURES]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Ln_Line24_NUMB                 	NUMERIC(2) = 24,
          @Ln_Line25_NUMB                 	NUMERIC(2) = 25,   
          -- 13785 - RWPRF_Y1 - Unable to View Data on O157 Screen for Current FFY -START-
          @Ln_MaxPercentage_NUMB			NUMERIC(3) = 999,     
          -- 13785 - RWPRF_Y1 - Unable to View Data on O157 Screen for Current FFY -END-  
		  @Li_RowCount_QNTY					INT = 0,
		  @Li_Zero_NUMB                   	SMALLINT = 0,
		  @Lc_StatusSuccess_CODE			CHAR(1) = 'S',
          @Lc_StatusFailed_CODE				CHAR(1) = 'F',
          @Lc_StatusAbnormalend_CODE		CHAR(1) = 'A',
          @Lc_Space_TEXT					CHAR(1)= ' ',
          @Lc_Yes_TEXT						CHAR(1) = 'Y',
          @Lc_No_TEXT						CHAR(1) = 'N',
          @Lc_TypeReport_TEXT				CHAR(1) = 'I',
          @Lc_LineNo5A_TEXT					CHAR(2) = '5A',
          -- 13785 - RWPRF_Y1 - Unable to View Data on O157 Screen for Current FFY -START-
          @Lc_RpmTableId_TEXT				CHAR(4) = 'VRPM',
          @Lc_FederalSupportOrderPct_TEXT	CHAR(4) = 'FSOP',
          @Lc_FederalPaternityEstbPct_TEXT  CHAR(4) = 'FPEP',
          @Lc_FederalCollectionCurrPct_TEXT	CHAR(4) = 'FCCP',
          @Lc_FederalCollectionArrPct_TEXT	CHAR(4) = 'FCAP',
          @Lc_FederalMedicalSupportPct_TEXT	CHAR(4) = 'FMSP',
          -- 13785 - RWPRF_Y1 - Unable to View Data on O157 Screen for Current FFY -END-
          @Lc_BatchRunUser_TEXT				CHAR(5) = 'BATCH',
          @Lc_BateError_CODE				CHAR(5) = 'E0944',
          @Lc_Job_ID                        CHAR(7) = 'DEB0008',
          @Lc_Successful_TEXT               CHAR(10) = 'SUCCESSFUL',
          @Ls_Process_NAME                  VARCHAR(50) = 'BATCH_RPT_PERFORMANCE_MEASURES',
          @Ls_Procedure_NAME                VARCHAR(55) = 'BATCH_RPT_PERFORMANCE_MEASURES$SP_PROCESS_FED_MEASURES',
          -- 13785 - RWPRF_Y1 - Unable to View Data on O157 Screen for Current FFY -START-
          @Ld_LastLine5aUpdate_DATE			DATE = '10/01/2013';    
          -- 13785 - RWPRF_Y1 - Unable to View Data on O157 Screen for Current FFY -END-
  DECLARE @Ln_CommitFreqParm_QNTY         NUMERIC(5),
          @Ln_ExceptionThresholdParm_QNTY NUMERIC(5),
          @Ln_MonthYear_NUMB              NUMERIC(6),
          @Ln_Error_NUMB                  NUMERIC(11),
          @Ln_ErrorLine_NUMB              NUMERIC(11),
          @Lc_Msg_CODE                    CHAR(1),
          @Ls_Sql_TEXT                    VARCHAR(200),
          @Ls_Sqldata_TEXT                VARCHAR(1000),
          @Ls_ErrorMessage_TEXT           VARCHAR(4000),
          @Ls_DescriptionError_TEXT       VARCHAR(4000),
          @Ls_BateRecord_TEXT             VARCHAR(4000),
          @Ld_Run_DATE                    DATE,
          @Ld_LastRun_DATE                DATE,
          @Ld_CurrMthLast_DATE            DATE,
          @Ld_CurrMthFirst_DATE			  DATE,
          @Ld_Begin_DATE				  DATE,
          @Ld_End_DATE					  DATE,
          @Ld_Start_DATE                  DATETIME2(0);

  BEGIN TRY
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   SET @Ls_Sql_TEXT = 'BATCH_COMMON.SP_GET_BATCH_DETAILS';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, @Lc_Space_TEXT);

   EXECUTE BATCH_COMMON$SP_GET_BATCH_DETAILS
    @Ac_Job_ID                  = @Lc_Job_ID,
    @Ad_Run_DATE                = @Ld_Run_DATE OUTPUT,
    @Ad_LastRun_DATE            = @Ld_LastRun_DATE OUTPUT,
    @An_CommitFreq_QNTY         = @Ln_CommitFreqParm_QNTY OUTPUT,
    @An_ExceptionThreshold_QNTY = @Ln_ExceptionThresholdParm_QNTY OUTPUT,
    @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT   = @Ls_DescriptionError_TEXT OUTPUT;
      
   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     SET @Ls_DescriptionError_TEXT = 'PARM DATE CHECK';

     RAISERROR(50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'RUN DATE AND LAST RUN DATE VALIDATION';
   SET @Ls_Sqldata_TEXT = 'LAST RUN DATE = ' + CAST(@Ld_LastRun_DATE AS VARCHAR) + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   IF DATEADD (D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_DescriptionError_TEXT = 'PARM DATE PROBLEM';

     RAISERROR (50001,16,1);
    END;

   SET @Ld_CurrMthLast_DATE = dbo.BATCH_COMMON_SCALAR$SF_LAST_DAY(@Ld_Run_DATE);
   SET @Ln_MonthYear_NUMB = CONVERT(VARCHAR(6), @Ld_Run_DATE, 112);
   SET @Ld_CurrMthFirst_DATE = CAST(@Ln_MonthYear_NUMB AS CHAR(6)) + '01'; 
     
   BEGIN TRANSACTION LOAD_FED_MEASURES;
   
   SET @Ld_End_DATE = CONVERT(VARCHAR(11), dbo.BATCH_COMMON_SCALAR$SF_LAST_DAY(@Ld_Start_DATE),112);
   SET @Ld_Begin_DATE = DATEADD(m, -13, @Ld_End_DATE); 
   
   SET @Ls_Sql_TEXT = 'DELETE FROM RWPRF_Y1 WHERE BEGIN_DATE IS A YEAR FROM CURRENT DATE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, @Lc_Space_TEXT);
   
   DELETE FROM RWPRF_Y1
    WHERE Begin_DATE < @Ld_Begin_DATE;
     
   SET @Ls_Sql_TEXT = 'DELETE FROM RWPRF_Y1 FOR CURRENT MONTH';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, @Lc_Space_TEXT) + ', Begin_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   DELETE FROM RWPRF_Y1
    WHERE Begin_DATE = @Ld_CurrMthFirst_DATE;    

   SET @Ls_Sql_TEXT = 'INSERT INTO RWPRF_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, @Lc_Space_TEXT) + ', Begin_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   INSERT INTO RWPRF_Y1
               (County_IDNO,
                Begin_DATE,
                Worker_ID,
                SupportOrder_PCT,
                FederalSupportOrder_PCT,
                PaternityEstablishment_PCT,
                FederalPaternityEstablishment_PCT,
                CollectionCurrency_PCT,
                FederalCollectionCurrency_PCT,
                Supervisor_ID,
                CollectionArrear_PCT,
                FederalCollectionArrear_PCT,
                MedicalSupport_PCT,
                FederalMedicalSupport_PCT,
                TotalCases_NUMB)
    SELECT  z.County_IDNO,
          @Ld_CurrMthFirst_DATE AS Begin_DATE,
          z.Worker_ID,
          CASE
           	WHEN z.Line1_NUMB = @Li_Zero_NUMB
             THEN @Li_Zero_NUMB
            WHEN z.Line2_NUMB = @Li_Zero_NUMB
             THEN @Li_Zero_NUMB
           ELSE -- 13785 - RWPRF_Y1 - Unable to View Data on O157 Screen for Current FFY -START-
				CASE
				 WHEN CAST(ROUND((z.Line2_NUMB * 100) / CAST(z.Line1_NUMB AS DECIMAL),0) AS INT) > @Ln_MaxPercentage_NUMB
				  THEN @Ln_MaxPercentage_NUMB
				 ELSE CAST(ROUND((z.Line2_NUMB * 100) / CAST(z.Line1_NUMB AS DECIMAL),0) AS INT)
				END
				-- 13785 - RWPRF_Y1 - Unable to View Data on O157 Screen for Current FFY -END-
          END SupportOrder_PCT,
          (SELECT r.Value_CODE
             FROM REFM_Y1 r
            -- 13785 - RWPRF_Y1 - Unable to View Data on O157 Screen for Current FFY -START-
            WHERE r.Table_ID = @Lc_RpmTableId_TEXT
              AND r.TableSub_ID = @Lc_FederalSupportOrderPct_TEXT) AS FederalSupportOrder_PCT,
            -- 13785 - RWPRF_Y1 - Unable to View Data on O157 Screen for Current FFY -END-
          CASE
           WHEN z.Line5_NUMB = @Li_Zero_NUMB
            THEN @Li_Zero_NUMB
           WHEN z.Line6_NUMB = @Li_Zero_NUMB
            THEN @Li_Zero_NUMB
           ELSE -- 13785 - RWPRF_Y1 - Unable to View Data on O157 Screen for Current FFY -START-
			    CASE
				 WHEN CAST(ROUND((z.Line6_NUMB * 100) / CAST(z.Line5_NUMB AS DECIMAL),0) AS INT) > @Ln_MaxPercentage_NUMB
				  THEN @Ln_MaxPercentage_NUMB
				 ELSE CAST(ROUND((z.Line6_NUMB * 100) / CAST(z.Line5_NUMB AS DECIMAL),0) AS INT)
				END
			    -- 13785 - RWPRF_Y1 - Unable to View Data on O157 Screen for Current FFY -END-
          END PaternityEstablishment_PCT,
          (SELECT r.Value_CODE
             FROM REFM_Y1 r
            -- 13785 - RWPRF_Y1 - Unable to View Data on O157 Screen for Current FFY -START-
            WHERE r.Table_ID = @Lc_RpmTableId_TEXT
              AND r.TableSub_ID = @Lc_FederalPaternityEstbPct_TEXT) AS FederalPaternityEstablishment_PCT,
            -- 13785 - RWPRF_Y1 - Unable to View Data on O157 Screen for Current FFY -END-
          CASE
           WHEN z.Line24_AMNT = @Li_Zero_NUMB
            THEN @Li_Zero_NUMB
           WHEN z.Line25_AMNT = @Li_Zero_NUMB
            THEN @Li_Zero_NUMB
           ELSE -- 13785 - RWPRF_Y1 - Unable to View Data on O157 Screen for Current FFY -START-
				CASE
				 WHEN CAST(ROUND((z.Line25_AMNT * 100) / CAST(z.Line24_AMNT AS DECIMAL),0) AS INT) > @Ln_MaxPercentage_NUMB
				  THEN @Ln_MaxPercentage_NUMB
				 ELSE CAST(ROUND((z.Line25_AMNT * 100) / CAST(z.Line24_AMNT AS DECIMAL),0) AS INT)
				END
				-- 13785 - RWPRF_Y1 - Unable to View Data on O157 Screen for Current FFY -END-
          END CollectionCurrency_PCT,
          (SELECT r.Value_CODE
             FROM REFM_Y1 r
            -- 13785 - RWPRF_Y1 - Unable to View Data on O157 Screen for Current FFY -START-
            WHERE r.Table_ID = @Lc_RpmTableId_TEXT
              AND r.TableSub_ID = @Lc_FederalCollectionCurrPct_TEXT) AS FederalCollectionCurrency_PCT,
            -- 13785 - RWPRF_Y1 - Unable to View Data on O157 Screen for Current FFY -END-
          @Lc_Space_TEXT AS Supervisor_ID,          
          CASE
           WHEN z.Line28_NUMB = @Li_Zero_NUMB
            THEN @Li_Zero_NUMB
           WHEN z.Line29_NUMB = @Li_Zero_NUMB
            THEN @Li_Zero_NUMB
           ELSE -- 13785 - RWPRF_Y1 - Unable to View Data on O157 Screen for Current FFY -START-
				CASE
				 WHEN CAST(ROUND((z.Line29_NUMB * 100) / CAST(z.Line28_NUMB AS DECIMAL),0) AS INT) > @Ln_MaxPercentage_NUMB
				  THEN @Ln_MaxPercentage_NUMB
				 ELSE CAST(ROUND((z.Line29_NUMB * 100) / CAST(z.Line28_NUMB AS DECIMAL),0) AS INT)
				END
				-- 13785 - RWPRF_Y1 - Unable to View Data on O157 Screen for Current FFY -END-
          END CollectionArrear_PCT,
          (SELECT r.Value_CODE
             FROM REFM_Y1 r
            -- 13785 - RWPRF_Y1 - Unable to View Data on O157 Screen for Current FFY -START-
            WHERE r.Table_ID = @Lc_RpmTableId_TEXT
              AND r.TableSub_ID = @Lc_FederalCollectionArrPct_TEXT) AS FederalCollectionArrear_PCT,
            -- 13785 - RWPRF_Y1 - Unable to View Data on O157 Screen for Current FFY -END-
          @Li_Zero_NUMB AS MedicalSupport_PCT,
          (SELECT r.Value_CODE
             FROM REFM_Y1 r
            -- 13785 - RWPRF_Y1 - Unable to View Data on O157 Screen for Current FFY -START-
            WHERE r.Table_ID = @Lc_RpmTableId_TEXT
              AND r.TableSub_ID = @Lc_FederalMedicalSupportPct_TEXT) AS FederalMedicalSupport_PCT,
            -- 13785 - RWPRF_Y1 - Unable to View Data on O157 Screen for Current FFY -END-
         (SELECT ISNULL(SUM(AB.Case_COUNT), @Li_Zero_NUMB)
			FROM (SELECT XY.Worker_ID, COUNT(DISTINCT xy.Case_IDNO) Case_COUNT
					FROM (
						  SELECT DISTINCT a.Worker_ID, a.Case_IDNO
							FROM RC157_Y1 a 
						   WHERE a.BeginFiscal_DATE = @Ld_CurrMthFirst_DATE
							AND a.EndFiscal_DATE   = @Ld_CurrMthLast_DATE
							AND a.TypeReport_CODE  = @Lc_TypeReport_TEXT
							AND (a.Line1_INDC = @Lc_Yes_TEXT OR a.Line2_INDC = @Lc_Yes_TEXT) 						  
						) as xy
				  WHERE xy.WORKER_ID = Z.Worker_ID
				  GROUP BY xy.WORKER_ID) ab) TotalCases_NUMB
		 FROM (SELECT         a.Worker_ID Worker_ID,
			                  a.County_IDNO County_IDNO,
			                  ISNULL(a.Line1_NUMB, @Li_Zero_NUMB)  Line1_NUMB,
			                  ISNULL(a.Line2_NUMB, @Li_Zero_NUMB)  Line2_NUMB,
			                  CASE
			                   -- 13785 - RWPRF_Y1 - Unable to View Data on O157 Screen for Current FFY -START-
			                   WHEN DATEADD(YYYY, -1, @Ld_CurrMthFirst_DATE) < @Ld_LastLine5aUpdate_DATE
			                   -- 13785 - RWPRF_Y1 - Unable to View Data on O157 Screen for Current FFY -END-
			                    THEN ISNULL(e.Line5_NUMB, @Li_Zero_NUMB)
			                   ELSE ISNULL(f.Line5_NUMB, @Li_Zero_NUMB)
			                  END Line5_NUMB,
			                  ISNULL(b.Line6_NUMB, @Li_Zero_NUMB)  Line6_NUMB,
			                  ISNULL(c.Line24_AMNT, @Li_Zero_NUMB) Line24_AMNT,
			                  ISNULL(d.Line25_AMNT, @Li_Zero_NUMB) Line25_AMNT,
			                  ISNULL(a.Line28_NUMB, @Li_Zero_NUMB) Line28_NUMB,
			                  ISNULL(a.Line29_NUMB, @Li_Zero_NUMB) Line29_NUMB
			             FROM (SELECT x.Worker_ID,
			                          x.County_IDNO,			                          			                          
			                          SUM(CAST(CASE x.Line1_INDC
			                                WHEN @Lc_Yes_TEXT
			                                 THEN 1
			                                WHEN @Lc_No_TEXT
			                                 THEN @Li_Zero_NUMB
			                               END AS NUMERIC(1))) Line1_NUMB,
			                          SUM(CAST(CASE x.Line2_INDC
			                                WHEN @Lc_Yes_TEXT
			                                 THEN 1
			                                WHEN @Lc_No_TEXT
			                                 THEN @Li_Zero_NUMB
			                               END AS NUMERIC(1))) Line2_NUMB,
			                          SUM(CAST(CASE x.Line28_INDC
			                                WHEN @Lc_Yes_TEXT
			                                 THEN 1
			                                WHEN @Lc_No_TEXT
			                                 THEN @Li_Zero_NUMB
			                               END AS NUMERIC(1))) Line28_NUMB,
			                          SUM(CAST(CASE x.Line29_INDC
			                                WHEN @Lc_Yes_TEXT
			                                 THEN 1
			                                WHEN @Lc_No_TEXT
			                                 THEN @Li_Zero_NUMB
			                               END AS NUMERIC(1))) Line29_NUMB
			                     FROM RC157_Y1 x
			                    WHERE x.BeginFiscal_DATE = @Ld_CurrMthFirst_DATE
			                      AND x.EndFiscal_DATE   = @Ld_CurrMthLast_DATE
			                      AND x.TypeReport_CODE  = @Lc_TypeReport_TEXT
			                      AND (x.Line1_INDC = @Lc_Yes_TEXT 
									   OR x.Line2_INDC = @Lc_Yes_TEXT
									   OR x.Line28_INDC = @Lc_Yes_TEXT
									   OR x.Line29_INDC = @Lc_Yes_TEXT)
			                      GROUP BY  x.Worker_ID,
											x.County_IDNO) a
			                  LEFT OUTER JOIN (SELECT x.Worker_ID,
			                                          x.County_IDNO,			                                          
			                                          SUM(CAST(CASE x.Line6_INDC
			                                                WHEN @Lc_Yes_TEXT
			                                                 THEN 1
			                                                WHEN @Lc_No_TEXT
			                                                 THEN @Li_Zero_NUMB
			                                               END AS NUMERIC(1))) Line6_NUMB
												  FROM(    SELECT x.Worker_ID,
													  			  x.County_IDNO,
																  Line5a_INDC Line5a_INDC,
																  Line6_INDC Line6_INDC
															 FROM RD157_Y1 x
															WHERE x.BeginFiscal_DATE = @Ld_CurrMthFirst_DATE
															  AND x.EndFiscal_DATE = @Ld_CurrMthLast_DATE
															  AND x.TypeReport_CODE = @Lc_TypeReport_TEXT
															  AND x.Line6_INDC = @Lc_Yes_TEXT
													  ) x
			                                      GROUP BY  x.Worker_ID,
															x.County_IDNO) b
			                   ON a.Worker_ID = b.Worker_ID
			                      AND a.County_IDNO = b.County_IDNO
			                  LEFT OUTER JOIN (SELECT x.Worker_ID,
			                                          x.County_IDNO,
			                                          x.Tot_QNTY Line5_NUMB
			                                     FROM RO157_Y1 x
												WHERE x.BeginFiscal_DATE = @Ld_CurrMthFirst_DATE
												 AND x.EndFiscal_DATE = @Ld_CurrMthLast_DATE
												 AND x.TypeReport_CODE = @Lc_TypeReport_TEXT
												 AND x.LineNo_TEXT = @Lc_LineNo5A_TEXT
											   ) e 			                                      
			                   ON a.Worker_ID = e.Worker_ID
			                      AND a.County_IDNO = e.County_IDNO
			                  LEFT OUTER JOIN (SELECT x.Worker_ID,
			                                          x.County_IDNO,
			                                          SUM(CAST(CASE x.Line5_INDC
			                                                WHEN @Lc_Yes_TEXT
			                                                 THEN 1
			                                                WHEN @Lc_No_TEXT
			                                                 THEN @Li_Zero_NUMB
			                                               END AS NUMERIC(1))) Line5_NUMB			                                          
												  FROM(    SELECT x.Worker_ID,
													  			  x.County_IDNO,
																  Line5_INDC Line5_INDC
															 FROM RD157_Y1 x
															WHERE x.BeginFiscal_DATE = DATEADD(YYYY, -1, @Ld_CurrMthFirst_DATE)
															  AND x.EndFiscal_DATE = DATEADD(YYYY, -1, @Ld_CurrMthLast_DATE)
															  AND x.TypeReport_CODE = @Lc_TypeReport_TEXT
															  AND x.Line5_INDC = @Lc_Yes_TEXT
													  ) x
			                                      GROUP BY  x.Worker_ID,
															x.County_IDNO) f
			                   ON a.Worker_ID = f.Worker_ID
			                      AND a.County_IDNO = f.County_IDNO
			                  LEFT OUTER JOIN (SELECT x.Worker_ID,
			                                          x.County_IDNO,
			                                          SUM(x.Trans_AMNT) Line24_AMNT
			                                     FROM R2426_Y1 x
			                                    WHERE x.BeginFiscal_DATE = @Ld_CurrMthFirst_DATE
			                                      AND x.EndFiscal_DATE = @Ld_CurrMthLast_DATE
			                                      AND x.TypeReport_CODE = @Lc_TypeReport_TEXT
			                                      AND x.Line_NUMB = @Ln_Line24_NUMB
			                                      GROUP BY x.Worker_ID,
			                                               x.County_IDNO) c
			                   ON a.Worker_ID = c.Worker_ID
			                      AND a.County_IDNO = c.County_IDNO
			                  LEFT OUTER JOIN (SELECT x.Worker_ID,
			                                          x.County_IDNO,
			                                          SUM(x.Trans_AMNT) Line25_AMNT
			                                     FROM R2527_Y1 x
			                                    WHERE x.BeginFiscal_DATE = @Ld_CurrMthFirst_DATE
			                                      AND x.EndFiscal_DATE = @Ld_CurrMthLast_DATE
			                                      AND x.TypeReport_CODE = @Lc_TypeReport_TEXT
			                                      AND x.Line_NUMB = @Ln_Line25_NUMB
			                                      GROUP BY  x.Worker_ID,
			                                          		x.County_IDNO) d
			                   ON a.Worker_ID = d.Worker_ID
			                      AND a.County_IDNO = d.County_IDNO) z;

   SET @Li_RowCount_QNTY = @@ROWCOUNT;

   IF(@Li_RowCount_QNTY = @Li_Zero_NUMB)
    BEGIN
     SET @Ls_DescriptionError_TEXT = 'INSERT EXDOL_Y1 FAILED';
     SET @Ls_BateRecord_TEXT = 'BateRecord_TEXT = ' + @Ls_BateRecord_TEXT + ', DescriptionErrorOut_TEXT = ' + @Ls_DescriptionError_TEXT + ', Process_NAME = ' + @Ls_Process_NAME + ', Procedure_NAME = ' + @Ls_Procedure_NAME + ', Job_ID = ' + @Lc_Job_ID +' , Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', TypeError_CODE = ' + @Lc_Space_TEXT + ', Line_NUMB = ' + CAST(@Li_RowCount_QNTY AS VARCHAR) + ', Error_CODE = ' + @Lc_BateError_CODE + ', DescriptionError_TEXT = ' + @Ls_BateRecord_TEXT + ', ListKey_TEXT = ' + @Ls_Sqldata_TEXT;
     
     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Ls_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_Space_TEXT,
      @An_Line_NUMB                = @Li_RowCount_QNTY,
      @Ac_Error_CODE               = @Lc_BateError_CODE,
      @As_DescriptionError_TEXT    = @Ls_BateRecord_TEXT,
      @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;
    END

   COMMIT TRANSACTION LOAD_FED_MEASURES;

   BEGIN TRANSACTION LOAD_FED_MEASURES;

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE';
   SET @Ls_Sqldata_TEXT = 'JOB ID = ' + @Lc_Job_ID + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
    @Ac_Job_ID                = @Lc_Job_ID,
     @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BSTL_LOG';
   SET @Ls_Sqldata_TEXT ='Job_ID = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', Start_DATE = ' + CAST(@Ld_Start_DATE AS VARCHAR) + ', Process_NAME = ' + @Ls_Process_NAME + ', Procedure_NAME = ' + @Ls_Procedure_NAME + ', CursorLocation_TEXT = ' + @Lc_Space_TEXT + ', ExecLocation_TEXT = '+ @Lc_Successful_TEXT + ', ListKey_TEXT = ' + @Lc_Successful_TEXT + ', DescriptionError_TEXT = ' + @Lc_Space_TEXT + ', Status_CODE = ' + @Lc_StatusSuccess_CODE + ', Worker_ID = ' + @Lc_BatchRunUser_TEXT + ', ProcessedRecordCount_QNTY = ' + CAST(@Li_RowCount_QNTY AS VARCHAR);
   
   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Lc_Space_TEXT,
    @As_ExecLocation_TEXT         = @Lc_Successful_TEXT,
    @As_ListKey_TEXT              = @Lc_Successful_TEXT,
    @As_DescriptionError_TEXT     = @Lc_Space_TEXT,
    @Ac_Status_CODE               = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Li_RowCount_QNTY;

   COMMIT TRANSACTION LOAD_FED_MEASURES;
  END TRY

  BEGIN CATCH
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION LOAD_FED_MEASURES;
    END

   SET @Ln_Error_NUMB = ERROR_NUMBER ();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE ();
   SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_ErrorMessage_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
     @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Lc_Space_TEXT,
    @As_ExecLocation_TEXT         = @Ls_Sql_TEXT,
    @As_ListKey_TEXT              = @Ls_Sqldata_TEXT,
    @As_DescriptionError_TEXT     = @Ls_ErrorMessage_TEXT,
    @Ac_Status_CODE               = @Lc_StatusAbnormalend_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Li_RowCount_QNTY;

   RAISERROR(@Ls_DescriptionError_TEXT,16,1);
  END CATCH
 END


GO
