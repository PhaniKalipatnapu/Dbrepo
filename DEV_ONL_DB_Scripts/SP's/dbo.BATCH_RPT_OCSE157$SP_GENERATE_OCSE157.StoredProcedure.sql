/****** Object:  StoredProcedure [dbo].[BATCH_RPT_OCSE157$SP_GENERATE_OCSE157]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name          : BATCH_RPT_OCSE157$SP_GENERATE_OCSE157
Programmer Name			: IMP Team
Description             : This procedure is used for generating monthly OCSE-157 report
Frequency               : Monthly/Annually
Developed On            : 09/07/2012
Called BY               : This procedure is called by BATCH_RPT_OCSE157$SP_PROCESS_DETAIL_OCSE157
Called On               : 
--------------------------------------------------------------------------------------------------------------------
Modified BY             :
Modified On             :
Version No              : 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_RPT_OCSE157$SP_GENERATE_OCSE157] (
 @Ac_Job_ID                CHAR(7),
 @Ad_Run_DATE              DATE,
 @Ac_Frequency_CODE        CHAR(1),
 @Ac_TypeReport_CODE       CHAR(1),
 @Ac_Msg_CODE              CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
 SET NOCOUNT ON;
  DECLARE 
          @Lc_Space_TEXT                                CHAR(1) = ' ',
          @Lc_Annual_TEXT                               CHAR(1) = 'A',
          @Lc_Yes_INDC                                  CHAR(1) = 'Y',
          @Lc_No_INDC                                   CHAR(1) = 'N',
          @Lc_CaseStatusOpen_CODE                       CHAR(1) = 'O',
          @Lc_StatusSuccess_CODE                        CHAR(1) = 'S',
          @Lc_StatusFailed_CODE                         CHAR(1) = 'F',
          @Lc_CaseTypeNonIvd_CODE                       CHAR(1) = 'H',
          @Lc_AsstTypeCurrent_CODE                      CHAR(1) = 'C',
          @Lc_AsstTypeFormer_CODE                       CHAR(1) = 'F',
          @Lc_AsstTypeNever_CODE                        CHAR(1) = 'N',
          @Lc_Unmarried_CODE                            CHAR(1) = 'U',
          @Lc_Msg_CODE                                  CHAR(1) = NULL,
          @Lc_DateFormat01_TEXT                         CHAR(3) = '01-',
          @Lc_LineNo4_TEXT                              CHAR(3) = '4',
          @Lc_LineNo5_TEXT                              CHAR(3) = '5',
          @Lc_LineNo5a_TEXT                             CHAR(3) = '5A',
          @Lc_LineNo6_TEXT                              CHAR(3) = '6',
          @Lc_LineNo7_TEXT                              CHAR(3) = '7',
          @Lc_LineNo8_TEXT                              CHAR(3) = '8',
          @Lc_LineNo8a_TEXT                             CHAR(3) = '8A',
          @Lc_LineNo9_TEXT                              CHAR(3) = '9',
          @Lc_LineNo10_TEXT                             CHAR(3) = '10',
          @Lc_LineNo12_TEXT                             CHAR(3) = '12',
          @Lc_LineNo13_TEXT                             CHAR(3) = '13',
          @Lc_LineNo14_TEXT                             CHAR(3) = '14',
          @Lc_LineNo16_TEXT                             CHAR(3) = '16',
          @Lc_LineNo17_TEXT                             CHAR(3) = '17',
          @Lc_LineNo18_TEXT                             CHAR(3) = '18',
          @Lc_LineNo18a_TEXT                            CHAR(3) = '18A',
          @Lc_LineNo19_TEXT                             CHAR(3) = '19',
          @Lc_LineNo20_TEXT                             CHAR(3) = '20',
          @Lc_LineNo21_TEXT                             CHAR(3) = '21',
          @Lc_LineNo21a_TEXT                            CHAR(3) = '21A',
          @Lc_LineNo22_TEXT                             CHAR(3) = '22',
          @Lc_LineNo23_TEXT                             CHAR(3) = '23',
          @Lc_LineNo24_TEXT                             CHAR(3) = '24',
          @Lc_LineNo25_TEXT                             CHAR(3) = '25',
          @Lc_LineNo26_TEXT                             CHAR(3) = '26',
          @Lc_LineNo27_TEXT                             CHAR(3) = '27',
          @Lc_LineNo28_TEXT                             CHAR(3) = '28',
          @Lc_LineNo29_TEXT                             CHAR(3) = '29',
          @Lc_LineNo33_TEXT                             CHAR(3) = '33',
          @Lc_LineNo34_TEXT                             CHAR(3) = '34',
          @Lc_LineNo35_TEXT                             CHAR(3) = '35',
          @Lc_LineNo36_TEXT                             CHAR(3) = '36',
          @Lc_LineNo37_TEXT                             CHAR(3) = '37',
          @Lc_LineNo38_TEXT                             CHAR(3) = '38',          
          @Lc_RestartLoc_TEXT                           CHAR(5) = ' ',
          @Lc_RestartLoc9_TEXT                          CHAR(5) = 'STEP9',
          @Lc_AnnualBeg01Oct_TEXT                       CHAR(7) = '10/01/',
          @Lc_AnnualEnd30Sep_TEXT                       CHAR(7) = '09/30/',
       	  @Lc_JobDetail_IDNO                            CHAR(7) = 'DEB8630',
       	  @Lc_MonthOct_TEXT                             CHAR(10) = 'October',
          @Lc_MonthNov_TEXT                             CHAR(10) = 'November',
          @Lc_MonthDec_TEXT                             CHAR(10) = 'December',
          @Ls_RoutineDetail_TEXT                        VARCHAR(100) = 'BATCH_RPT_OCSE157$SP_PROCESS_DETAIL_OCSE157',
          @Ls_RoutineMonthly_TEXT                       VARCHAR(100) = 'BATCH_RPT_OCSE157$SP_PROCESS_MANAGEMENT_OCSE157',
          @Ls_Procedure_NAME							VARCHAR(100) = 'BATCH_RPT_OCSE157$SP_GENERATE_OCSE157',
          @Ls_DescriptionError_TEXT                     VARCHAR(4000) = NULL,
          @Ld_2014FiscalEnd_DATE						DATE = '2014-09-30',
          @Ld_2014FiscalBegin_DATE						DATE = '2013-10-01';
                    
   DECLARE
          @Ln_Yyyymm_NUMB                               NUMERIC(6),
          @Ln_RowCount_QNTY                             NUMERIC(10),
          @Lc_Yyyymm_TEXT                               CHAR(6),
          @Lc_Routine_TEXT                              CHAR(30),
          @Ls_Sql_TEXT                                  VARCHAR(200),
          @Ls_Sqldata_TEXT                              VARCHAR(4000), 
          @Ls_ErrorMessage_TEXT                         VARCHAR (4000),         
          @Ld_Begin_DATE                                DATE,
          @Ld_End_DATE                                  DATE,
          @Ld_StFyBegin_DATE                            DATE,
          @Ld_StFyEnd_DATE                              DATE,
          @Ld_PriorFyBegin_DATE                         DATE,
          @Ld_PriorFyEnd_DATE                           DATE,
          @Ld_BeginFiscalLine29_DATE                    DATE,
          @Ld_EndFiscalLine29_DATE                      DATE,
          @Ld_PriorFyLine5ABegin_DATE					DATE,
          @Ld_PriorFyLine5AEND_DATE						DATE;        

  BEGIN TRY
   SET @Ls_Sql_TEXT = 'CHECK RESTART KEY EXISTS';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Ac_Job_ID,'')+ ', Run_DATE = ' + ISNULL(CAST(  @Ad_Run_DATE AS VARCHAR ),'');

   SELECT @Lc_RestartLoc_TEXT = LTRIM(RTRIM(r.RestartKey_TEXT))
     FROM RSTL_Y1 r
    WHERE r.Job_ID = @Ac_Job_ID
      AND r.Run_DATE =  @Ad_Run_DATE;

   IF @Ac_Frequency_CODE = @Lc_Annual_TEXT
    BEGIN
     IF (DATENAME(MONTH,  @Ad_Run_DATE) NOT IN (@Lc_MonthOct_TEXT, @Lc_MonthNov_TEXT, @Lc_MonthDec_TEXT))
      BEGIN
       SET @Ld_PriorFyBegin_DATE = @Lc_AnnualBeg01Oct_TEXT + DATENAME(YEAR, DATEADD(m, -24,  @Ad_Run_DATE));
       SET @Ld_PriorFyEnd_DATE = @Lc_AnnualEnd30Sep_TEXT + DATENAME(YEAR, DATEADD(m, -12,  @Ad_Run_DATE));
       SET @Ld_Begin_DATE = @Lc_AnnualBeg01Oct_TEXT + DATENAME(YEAR, DATEADD(m, -12,  @Ad_Run_DATE));
       SET @Ld_End_DATE = @Lc_AnnualEnd30Sep_TEXT + DATENAME(YEAR,  @Ad_Run_DATE);
      END
     ELSE
      BEGIN
       SET @Ld_PriorFyBegin_DATE = @Lc_AnnualBeg01Oct_TEXT + DATENAME(YEAR, DATEADD(m, -12,  @Ad_Run_DATE));
       SET @Ld_PriorFyEnd_DATE = @Lc_AnnualEnd30Sep_TEXT + DATENAME(YEAR,  @Ad_Run_DATE);
       SET @Ld_Begin_DATE = @Lc_AnnualBeg01Oct_TEXT + DATENAME(YEAR,  @Ad_Run_DATE);
       SET @Ld_End_DATE = @Lc_AnnualEnd30Sep_TEXT + DATENAME(YEAR, DATEADD(m, 3,  @Ad_Run_DATE));
      END

     SET @Ld_StFyBegin_DATE = DATEADD(m, -3, @Ld_Begin_DATE);
     SET @Ld_StFyEnd_DATE = DATEADD(m, -3, @Ld_End_DATE);
    END
   ELSE
    BEGIN
     SET @Ld_Begin_DATE = @Lc_DateFormat01_TEXT + REPLACE(RIGHT(CONVERT(VARCHAR(11),  @Ad_Run_DATE, 106), 8), ' ', '-');
     SET @Ld_PriorFyBegin_DATE = @Lc_DateFormat01_TEXT + REPLACE(RIGHT(CONVERT(VARCHAR(11), DATEADD(m, -1,  @Ad_Run_DATE), 106), 8), ' ', '-');
     SET @Ld_PriorFyEnd_DATE = DATEADD(mm, DATEDIFF(mm, 0, DATEADD(m, -1,  @Ad_Run_DATE)) + 1, -1);
     SET @Ld_End_DATE = DATEADD(mm, DATEDIFF(mm, 0,  @Ad_Run_DATE) + 1, -1);
     SET @Ld_StFyBegin_DATE = @Ld_Begin_DATE;
     SET @Ld_StFyEnd_DATE = @Ld_End_DATE;

     IF (DATENAME(MONTH,  @Ad_Run_DATE) NOT IN (@Lc_MonthOct_TEXT, @Lc_MonthNov_TEXT, @Lc_MonthDec_TEXT))
      BEGIN
       SET @Ld_BeginFiscalLine29_DATE = @Lc_AnnualBeg01Oct_TEXT + DATENAME(YEAR, DATEADD(m, -12,  @Ad_Run_DATE));
       SET @Ld_EndFiscalLine29_DATE = @Lc_AnnualEnd30Sep_TEXT + DATENAME(YEAR,  @Ad_Run_DATE);
      END
     ELSE
      BEGIN
       SET @Ld_BeginFiscalLine29_DATE = @Lc_AnnualBeg01Oct_TEXT + DATENAME(YEAR,  @Ad_Run_DATE);
       SET @Ld_EndFiscalLine29_DATE = @Lc_AnnualEnd30Sep_TEXT + DATENAME(YEAR, DATEADD(m, 3,  @Ad_Run_DATE));
      END;
    END;

   SET @Lc_Yyyymm_TEXT = CONVERT(VARCHAR(6), @Ld_End_DATE, 112);
   SET @Ln_Yyyymm_NUMB = CAST(@Lc_Yyyymm_TEXT AS NUMERIC);
   -- 13352
   IF (DATENAME(MONTH,  @Ad_Run_DATE) NOT IN (@Lc_MonthOct_TEXT, @Lc_MonthNov_TEXT, @Lc_MonthDec_TEXT))
      BEGIN
       SET @Ld_PriorFyLine5ABegin_DATE = @Lc_AnnualBeg01Oct_TEXT + DATENAME(YEAR, DATEADD(m, -24,  @Ad_Run_DATE));
       SET @Ld_PriorFyLine5AEND_DATE = @Lc_AnnualEnd30Sep_TEXT + DATENAME(YEAR, DATEADD(m, -12,  @Ad_Run_DATE));
       
      END
     ELSE
      BEGIN
       SET @Ld_PriorFyLine5ABegin_DATE = @Lc_AnnualBeg01Oct_TEXT + DATENAME(YEAR, DATEADD(m, -12,  @Ad_Run_DATE));
       SET @Ld_PriorFyLine5AEND_DATE = @Lc_AnnualEnd30Sep_TEXT + DATENAME(YEAR,  @Ad_Run_DATE);
       
      END
   -- 13352
	SET @Ls_Sql_TEXT = 'BATCH_RPT_OCSE157$SP_GENERATE_OCSE157_ARUL1';
	SET @Ls_Sqldata_TEXT = 'BeginFiscal_DATE = ' + CAST( @Ld_Begin_DATE AS VARCHAR )+ ', EndFiscal_DATE = ' + CAST( @Ld_End_DATE AS VARCHAR )+ ', TypeReport_CODE = ' + ISNULL(@Ac_TypeReport_CODE,'') + ', SupportYearMonth_NUMB = ' + CAST(@Ln_Yyyymm_NUMB AS VARCHAR) + ', Job_ID = ' + ISNULL(@Ac_Job_ID,' ')+ ', Run_DATE = ' + CAST( @Ad_Run_DATE AS VARCHAR);

EXECUTE BATCH_RPT_OCSE157$SP_INSERT_ASSIST_DETAILS 
 @Ad_BeginFiscal_DATE      = @Ld_Begin_DATE ,    
 @Ad_EndFiscal_DATE        =  @Ld_End_DATE,    
 @Ac_TypeReport_CODE       = @Ac_TypeReport_CODE,
 @An_SupportYearMonth_NUMB = @Ln_Yyyymm_NUMB,
 @Ac_Job_ID			       = @Ac_Job_ID,    
 @Ad_Run_DATE		       = @Ad_Run_DATE,    
 @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,    
 @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;    

IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         RAISERROR (50001,16,1);
        END
    SET @Ls_Sql_TEXT = 'BATCH_RPT_OCSE157$SP_GENERATE_OCSE157_ARUL2';      
    SET @Ls_Sqldata_TEXT = 'BeginFiscal_DATE = ' + CAST( @Ld_Begin_DATE AS VARCHAR )+ ', EndFiscal_DATE = ' + CAST( @Ld_End_DATE AS VARCHAR )+ ', TypeReport_CODE = ' + ISNULL(@Ac_TypeReport_CODE,'') + ', SupportYearMonth_NUMB = ' + CAST(@Ln_Yyyymm_NUMB AS VARCHAR) + ', Job_ID = ' + ISNULL(@Ac_Job_ID,' ')+ ', Run_DATE = ' + CAST( @Ad_Run_DATE AS VARCHAR);

EXECUTE BATCH_RPT_OCSE157$SP_INSERT_LINE_2527 
 @Ad_BeginFiscal_DATE      = @Ld_Begin_DATE ,    
 @Ad_EndFiscal_DATE        =  @Ld_End_DATE, 
 @An_SupportYearMonth_NUMB = @Ln_Yyyymm_NUMB,     
 @Ac_TypeReport_CODE       = @Ac_TypeReport_CODE,
 @Ac_Job_ID			       = @Ac_Job_ID, 
 @Ad_Run_DATE		       = @Ad_Run_DATE,   
 @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,    
 @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;  
 
 IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         RAISERROR (50001,16,1);
        END

  SET @Ls_Sql_TEXT = 'SUM UP THE COUNT AND INSERT RO157_Y1 LINE 4';
     SET @Ls_Sqldata_TEXT = 'BeginFiscal_DATE : ' + CAST(@Ld_Begin_DATE AS VARCHAR) + ' EndFiscal_DATE : ' + CAST(@Ld_End_DATE AS VARCHAR) + ' Line_NUMB : ' + @Lc_LineNo4_TEXT + ' TypeAsst_CODE : ' + @Lc_AsstTypeCurrent_CODE + ' TypeReport_CODE : ' + @Ac_TypeReport_CODE + ' Line4_INDC : ' + @Lc_Yes_INDC + ' SupportYearMonth_NUMB : ' + CAST(@Ln_Yyyymm_NUMB AS VARCHAR);
   
     INSERT RO157_Y1
            (BeginFiscal_DATE,
             EndFiscal_DATE,
             TypeReport_CODE,
             Office_IDNO,
             County_IDNO,
             Worker_ID,
             LineNo_TEXT,
             Tot_QNTY,
             Ca_AMNT,
             Fa_AMNT,
             Na_AMNT)
     SELECT @Ld_Begin_DATE AS BeginFiscal_DATE,
            @Ld_End_DATE AS EndFiscal_DATE,
            a.TypeReport_CODE,
            a.Office_IDNO,
            a.County_IDNO,
            a.Worker_ID,
            @Lc_LineNo4_TEXT AS LineNo_TEXT,
            SUM(1) AS Tot_QNTY,
            0 AS Ca_AMNT,
            0 AS Fa_AMNT,
            0 AS Na_AMNT
       FROM RD157_Y1 a,
            RASST_Y1 b
      WHERE b.Case_IDNO = a.Case_IDNO
        AND a.Line4_INDC = @Lc_Yes_INDC
        AND b.SupportYearMonth_NUMB = @Ln_Yyyymm_NUMB
        AND a.BeginFiscal_DATE = @Ld_Begin_DATE
        AND a.EndFiscal_DATE = @Ld_End_DATE
        AND a.TypeReport_CODE = @Ac_TypeReport_CODE
      GROUP BY a.TypeReport_CODE,
               a.County_IDNO,
               a.Office_IDNO,
               a.Worker_ID;

     SET @Ln_RowCount_QNTY = @@ROWCOUNT;

     IF @Ln_RowCount_QNTY = 0
      BEGIN
       SET @Ls_Sql_TEXT = 'BATCH_RPT_OCSE157$SP_INSERT_LINE-LINENO-4';
	   SET @Ls_Sqldata_TEXT = 'BeginFiscal_DATE : ' + CAST(@Ld_Begin_DATE AS VARCHAR) + ' EndFiscal_DATE : ' + CAST(@Ld_End_DATE AS VARCHAR) + ' TypeReport_CODE : ' + ISNULL(@Ac_TypeReport_CODE,'') + ' Line_NUMB : ' + @Lc_LineNo4_TEXT;
	   
       EXECUTE BATCH_RPT_OCSE157$SP_POPULATE_EMPTY_LINES
        @Ad_BeginFiscal_DATE        = @Ld_Begin_DATE,
        @Ad_EndFiscal_DATE          = @Ld_End_DATE,
        @Ac_TypeReport_CODE         = @Ac_TypeReport_CODE,
        @Ac_Line_NUMB               = @Lc_LineNo4_TEXT,
        @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT   = @Ls_ErrorMessage_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
        SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');
         RAISERROR (50001,16,1);
        END
      END

     SET @Ls_Sql_TEXT = 'SUM UP THE COUNT AND INSERT RO157_Y1 LINE 5';
     SET @Ls_Sqldata_TEXT = 'BeginFiscal_DATE : ' + CAST(@Ld_Begin_DATE AS VARCHAR) + ' EndFiscal_DATE : ' + CAST(@Ld_End_DATE AS VARCHAR) + ' Line_NUMB : ' + @Lc_LineNo5_TEXT + ' TypeAsst_CODE : ' + @Lc_AsstTypeCurrent_CODE + ' TypeReport_CODE : ' + ISNULL(@Ac_TypeReport_CODE,'') + ' Line5_INDC : ' + @Lc_Yes_INDC + ' SupportYearMonth_NUMB : ' + CAST(@Ln_Yyyymm_NUMB AS VARCHAR);
   
     INSERT RO157_Y1
            (BeginFiscal_DATE,
             EndFiscal_DATE,
             TypeReport_CODE,
             Office_IDNO,
             County_IDNO,
             Worker_ID,
             LineNo_TEXT,
             Tot_QNTY,
             Ca_AMNT,
             Fa_AMNT,
             Na_AMNT)
     SELECT @Ld_Begin_DATE AS BeginFiscal_DATE,
            @Ld_End_DATE AS EndFiscal_DATE,
            a.TypeReport_CODE,
            a.Office_IDNO,
            a.County_IDNO,
            a.Worker_ID,
            @Lc_LineNo5_TEXT AS LineNo_TEXT,
            SUM(1) AS Tot_QNTY,
            0 AS Ca_AMNT,
            0 AS Fa_AMNT,
            0 AS Na_AMNT
       FROM RD157_Y1 a,
            RASST_Y1 b
      WHERE b.Case_IDNO = a.Case_IDNO
        AND a.Line5_INDC = @Lc_Yes_INDC
        AND b.SupportYearMonth_NUMB = @Ln_Yyyymm_NUMB
        AND a.BeginFiscal_DATE = @Ld_Begin_DATE
        AND a.EndFiscal_DATE = @Ld_End_DATE
        AND a.TypeReport_CODE = @Ac_TypeReport_CODE
      GROUP BY a.TypeReport_CODE,
               a.County_IDNO,
               a.Office_IDNO,
               a.Worker_ID;

     SET @Ln_RowCount_QNTY = @@ROWCOUNT;

     IF @Ln_RowCount_QNTY = 0
      BEGIN
       SET @Ls_Sql_TEXT = 'BATCH_RPT_OCSE157$SP_INSERT_LINE-LINENO-5';
	   SET @Ls_Sqldata_TEXT = 'BeginFiscal_DATE : ' + CAST(@Ld_Begin_DATE AS VARCHAR) + ' EndFiscal_DATE : ' + CAST(@Ld_End_DATE AS VARCHAR) + ' TypeReport_CODE : ' + ISNULL(@Ac_TypeReport_CODE,'') + ' Line_NUMB : ' + @Lc_LineNo5_TEXT;
	   
       EXECUTE BATCH_RPT_OCSE157$SP_POPULATE_EMPTY_LINES
        @Ad_BeginFiscal_DATE = @Ld_Begin_DATE,
        @Ad_EndFiscal_DATE   = @Ld_End_DATE,
        @Ac_TypeReport_CODE  = @Ac_TypeReport_CODE,
        @Ac_Line_NUMB        = @Lc_LineNo5_TEXT,
        @Ac_Msg_CODE         = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT       = @Ls_ErrorMessage_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
        SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');
         RAISERROR (50001,16,1);
        END
      END
      
     -- Code to update the line 5A from last fiscal year (2013)line 5
     SET @Ls_Sql_TEXT = 'SUM UP THE COUNT AND INSERT RO157_Y1 LINE 5A';
     SET @Ls_Sqldata_TEXT = 'BeginFiscal_DATE : ' + ISNULL(CAST(@Ld_Begin_DATE AS VARCHAR),'') + ' EndFiscal_DATE : ' + ISNULL(CAST(@Ld_End_DATE AS VARCHAR),'') + ' Line_NUMB : ' + ISNULL(@Lc_LineNo5a_TEXT,'') + ' TypeAsst_CODE : ' + ISNULL(@Lc_AsstTypeCurrent_CODE,'') + ' TypeReport_CODE : ' + ISNULL(@Ac_TypeReport_CODE,'') + ' SupportYearMonth_NUMB : ' + ISNULL(CAST(@Ln_Yyyymm_NUMB AS VARCHAR),'') + ' BeginValidity_DATE : ' + ISNULL(CAST(@Ld_PriorFyEnd_DATE AS VARCHAR),'') + ' EndValidity_DATE : ' + ISNULL(CAST(@Ld_PriorFyBegin_DATE AS VARCHAR),'');	
    
	 INSERT RO157_Y1 
             (BeginFiscal_DATE,
             EndFiscal_DATE,
             TypeReport_CODE,
             Office_IDNO,
             County_IDNO,
             Worker_ID,
             LineNo_TEXT,
             Tot_QNTY,
             Ca_AMNT,
             Fa_AMNT,
             Na_AMNT)
     SELECT @Ld_Begin_DATE AS BeginFiscal_DATE,
            @Ld_End_DATE AS EndFiscal_DATE,
            @Ac_TypeReport_CODE AS TypeReport_CODE,
            a.Office_IDNO,
            a.County_IDNO,
            a.Worker_ID,
            @Lc_LineNo5a_TEXT AS LineNo_TEXT,
            a.Tot_QNTY AS Tot_QNTY,
            0 AS Ca_AMNT,
            0 AS Fa_AMNT,
            0 AS Na_AMNT
        FROM RO157_Y1 a
       WHERE  a.BeginFiscal_DATE		= @Ld_PriorFyLine5ABegin_DATE
        AND a.EndFiscal_DATE			= @Ld_PriorFyLine5AEND_DATE
        AND a.TypeReport_CODE		= 
				(SELECT MAX (r.TypeReport_CODE)
				   FROM RO157_Y1 r
				  WHERE r.BeginFiscal_DATE	= @Ld_PriorFyLine5ABegin_DATE
				    AND r.EndFiscal_DATE	= @Ld_PriorFyLine5AEND_DATE)
	    AND a.LineNo_TEXT = @Lc_LineNo5_TEXT 
							     
      
     SET @Ln_RowCount_QNTY = @@ROWCOUNT;

     IF @Ln_RowCount_QNTY = 0
      BEGIN
       SET @Ls_Sql_TEXT = 'BATCH_RPT_OCSE157$SP_INSERT_LINE-LINENO-5A';
	   SET @Ls_Sqldata_TEXT = 'BeginFiscal_DATE : ' + CAST(@Ld_Begin_DATE AS VARCHAR) + ' EndFiscal_DATE : ' + CAST(@Ld_End_DATE AS VARCHAR) + ' TypeReport_CODE : ' + ISNULL(@Ac_TypeReport_CODE,'') + ' Line_NUMB : ' + @Lc_LineNo5a_TEXT;
	   
       EXECUTE BATCH_RPT_OCSE157$SP_POPULATE_EMPTY_LINES
        @Ad_BeginFiscal_DATE        = @Ld_Begin_DATE,
        @Ad_EndFiscal_DATE          = @Ld_End_DATE,
        @Ac_TypeReport_CODE         = @Ac_TypeReport_CODE,
        @Ac_Line_NUMB               = @Lc_LineNo5a_TEXT,
        @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT   = @Ls_ErrorMessage_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
        SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');
         RAISERROR (50001,16,1);
        END
      END

     SET @Ls_Sql_TEXT = 'SUM UP THE COUNT AND INSERT RO157_Y1 LINE 6';
     SET @Ls_Sqldata_TEXT = 'BeginFiscal_DATE : ' + CAST(@Ld_Begin_DATE AS VARCHAR) + ' EndFiscal_DATE : ' + CAST(@Ld_End_DATE AS VARCHAR) + ' Line_NUMB : ' + @Lc_LineNo6_TEXT + ' TypeAsst_CODE : ' + @Lc_AsstTypeCurrent_CODE + ' TypeReport_CODE : ' + @Ac_TypeReport_CODE + ' Line6_INDC : ' + @Lc_Yes_INDC + ' SupportYearMonth_NUMB : ' + CAST(@Ln_Yyyymm_NUMB AS VARCHAR);
   
     INSERT RO157_Y1
            (BeginFiscal_DATE,
             EndFiscal_DATE,
             TypeReport_CODE,
             Office_IDNO,
             County_IDNO,
             Worker_ID,
             LineNo_TEXT,
             Tot_QNTY,
             Ca_AMNT,
             Fa_AMNT,
             Na_AMNT)
     SELECT @Ld_Begin_DATE AS BeginFiscal_DATE,
            @Ld_End_DATE AS EndFiscal_DATE,
            a.TypeReport_CODE,
            a.Office_IDNO,
            a.County_IDNO,
            a.Worker_ID,
            @Lc_LineNo6_TEXT AS LineNo_TEXT,
            SUM(1) AS Tot_QNTY,
            0 AS Ca_AMNT,
            0 AS Fa_AMNT,
            0 AS Na_AMNT
       FROM RD157_Y1 a,
            RASST_Y1 b
      WHERE b.Case_IDNO = a.Case_IDNO
        AND a.Line6_INDC = @Lc_Yes_INDC
        AND b.SupportYearMonth_NUMB = @Ln_Yyyymm_NUMB
        AND a.BeginFiscal_DATE = @Ld_Begin_DATE
        AND a.EndFiscal_DATE = @Ld_End_DATE
        AND a.TypeReport_CODE = @Ac_TypeReport_CODE
      GROUP BY a.TypeReport_CODE,
               a.County_IDNO,
               a.Office_IDNO,
               a.Worker_ID;

     SET @Ln_RowCount_QNTY = @@ROWCOUNT;

     IF @Ln_RowCount_QNTY = 0
      BEGIN
       SET @Ls_Sql_TEXT = 'BATCH_RPT_OCSE157$SP_INSERT_LINE-LINENO-6';
	   SET @Ls_Sqldata_TEXT = 'BeginFiscal_DATE : ' + CAST(@Ld_Begin_DATE AS VARCHAR) + ' EndFiscal_DATE : ' + CAST(@Ld_End_DATE AS VARCHAR) + ' TypeReport_CODE : ' + @Ac_TypeReport_CODE + ' Line_NUMB : ' + @Lc_LineNo6_TEXT;
	   
       EXECUTE BATCH_RPT_OCSE157$SP_POPULATE_EMPTY_LINES
        @Ad_BeginFiscal_DATE          = @Ld_Begin_DATE,
        @Ad_EndFiscal_DATE            = @Ld_End_DATE,
        @Ac_TypeReport_CODE           = @Ac_TypeReport_CODE,
        @Ac_Line_NUMB                 = @Lc_LineNo6_TEXT,
        @Ac_Msg_CODE                  = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT     = @Ls_ErrorMessage_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
        SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');
         RAISERROR (50001,16,1);
        END
      END

     SET @Ls_Sql_TEXT = 'SUM UP THE COUNT AND INSERT RO157_Y1 LINE 7';
     SET @Ls_Sqldata_TEXT = 'BeginFiscal_DATE : ' + CAST(@Ld_Begin_DATE AS VARCHAR) + ' EndFiscal_DATE : ' + CAST(@Ld_End_DATE AS VARCHAR) + ' Line_NUMB : ' + @Lc_LineNo7_TEXT + ' TypeAsst_CODE : ' + @Lc_AsstTypeCurrent_CODE + ' TypeReport_CODE : ' + @Ac_TypeReport_CODE + ' Line7_INDC : ' + @Lc_Yes_INDC + ' SupportYearMonth_NUMB : ' + CAST(@Ln_Yyyymm_NUMB AS VARCHAR);
   
     INSERT RO157_Y1
            (BeginFiscal_DATE,
             EndFiscal_DATE,
             TypeReport_CODE,
             Office_IDNO,
             County_IDNO,
             Worker_ID,
             LineNo_TEXT,
             Tot_QNTY,
             Ca_AMNT,
             Fa_AMNT,
             Na_AMNT)
     SELECT @Ld_Begin_DATE AS BeginFiscal_DATE,
            @Ld_End_DATE AS EndFiscal_DATE,
            a.TypeReport_CODE,
            a.Office_IDNO,
            a.County_IDNO,
            a.Worker_ID,
            @Lc_LineNo7_TEXT AS LineNo_TEXT,
            SUM(1) AS Tot_QNTY,
            0 AS Ca_AMNT,
            0 AS Fa_AMNT,
            0 AS Na_AMNT
       FROM RD157_Y1 a,
            RASST_Y1 b
      WHERE b.Case_IDNO = a.Case_IDNO
        AND a.Line7_INDC = @Lc_Yes_INDC
        AND b.SupportYearMonth_NUMB = @Ln_Yyyymm_NUMB
        AND a.BeginFiscal_DATE = @Ld_Begin_DATE
        AND a.EndFiscal_DATE = @Ld_End_DATE
        AND a.TypeReport_CODE = @Ac_TypeReport_CODE
      GROUP BY a.TypeReport_CODE,
               a.County_IDNO,
               a.Office_IDNO,
               a.Worker_ID;

     SET @Ln_RowCount_QNTY = @@ROWCOUNT;

     IF @Ln_RowCount_QNTY = 0
      BEGIN
       SET @Ls_Sql_TEXT = 'BATCH_RPT_OCSE157$SP_INSERT_LINE-LINENO-7';
	   SET @Ls_Sqldata_TEXT = 'BeginFiscal_DATE : ' + CAST(@Ld_Begin_DATE AS VARCHAR) + ' EndFiscal_DATE : ' + CAST(@Ld_End_DATE AS VARCHAR) + ' TypeReport_CODE : ' + @Ac_TypeReport_CODE + ' Line_NUMB : ' + @Lc_LineNo7_TEXT;
	   
       EXECUTE BATCH_RPT_OCSE157$SP_POPULATE_EMPTY_LINES
        @Ad_BeginFiscal_DATE         = @Ld_Begin_DATE,
        @Ad_EndFiscal_DATE           = @Ld_End_DATE,
        @Ac_TypeReport_CODE          = @Ac_TypeReport_CODE,
        @Ac_Line_NUMB                = @Lc_LineNo7_TEXT,
        @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT    = @Ls_ErrorMessage_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
        SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');
         RAISERROR (50001,16,1);
        END
      END

     SET @Ls_Sql_TEXT = 'SUM UP THE COUNT AND INSERT RO157_Y1 LINE 8';
     SET @Ls_Sqldata_TEXT = 'BeginFiscal_DATE : ' + CAST(@Ld_Begin_DATE AS VARCHAR) + ' EndFiscal_DATE : ' + CAST(@Ld_End_DATE AS VARCHAR) + ' Line_NUMB : ' + @Lc_LineNo8_TEXT + ' TypeAsst_CODE : ' + @Lc_AsstTypeCurrent_CODE + ' TypeReport_CODE : ' + @Ac_TypeReport_CODE + ' Line8_INDC : ' + @Lc_Yes_INDC + ' SupportYearMonth_NUMB : ' + CAST(@Ln_Yyyymm_NUMB AS VARCHAR);
   
     INSERT RO157_Y1
            (BeginFiscal_DATE,
             EndFiscal_DATE,
             TypeReport_CODE,
             Office_IDNO,
             County_IDNO,
             Worker_ID,
             LineNo_TEXT,
             Tot_QNTY,
             Ca_AMNT,
             Fa_AMNT,
             Na_AMNT)
     SELECT @Ld_Begin_DATE AS BeginFiscal_DATE,
            @Ld_End_DATE AS EndFiscal_DATE,
            a.TypeReport_CODE,
            a.Office_IDNO,
            a.County_IDNO,
            a.Worker_ID,
            @Lc_LineNo8_Text AS LineNo_TEXT,
            SUM(1) Tot_QNTY,
            0 Ca_AMNT,
            0 Fa_AMNT,
            0 Na_AMNT
       FROM RD157_Y1 a,
            RASST_Y1 b
      WHERE b.Case_IDNO = a.Case_IDNO
        AND a.Line8_INDC = @Lc_Yes_INDC
        AND b.SupportYearMonth_NUMB = @Ln_Yyyymm_NUMB
        AND a.BeginFiscal_DATE = @Ld_Begin_DATE
        AND a.EndFiscal_DATE = @Ld_End_DATE
        AND a.TypeReport_CODE = @Ac_TypeReport_CODE
      GROUP BY a.TypeReport_CODE,
               a.County_IDNO,
               a.Office_IDNO,
               a.Worker_ID;

     SET @Ln_RowCount_QNTY = @@ROWCOUNT;

     IF @Ln_RowCount_QNTY = 0
      BEGIN
       SET @Ls_Sql_TEXT = 'BATCH_RPT_OCSE157$SP_INSERT_LINE-LINENO-8';
	   SET @Ls_Sqldata_TEXT = 'BeginFiscal_DATE : ' + CAST(@Ld_Begin_DATE AS VARCHAR) + ' EndFiscal_DATE : ' + CAST(@Ld_End_DATE AS VARCHAR) + ' TypeReport_CODE : ' + @Ac_TypeReport_CODE + ' Line_NUMB : ' + @Lc_LineNo8_TEXT;
	   
       EXECUTE BATCH_RPT_OCSE157$SP_POPULATE_EMPTY_LINES
        @Ad_BeginFiscal_DATE          = @Ld_Begin_DATE,
        @Ad_EndFiscal_DATE            = @Ld_End_DATE,
        @Ac_TypeReport_CODE           = @Ac_TypeReport_CODE,
        @Ac_Line_NUMB                 = @Lc_LineNo8_TEXT,
        @Ac_Msg_CODE                  = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT     = @Ls_ErrorMessage_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
        SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');
         RAISERROR (50001,16,1);
        END
      END

     SET @Ls_Sql_TEXT = 'SUM UP THE COUNT AND INSERT RO157_Y1 LINE 8A';
     SET @Ls_Sqldata_TEXT = 'BeginFiscal_DATE : ' + CAST(@Ld_Begin_DATE AS VARCHAR) + ' EndFiscal_DATE : ' + CAST(@Ld_End_DATE AS VARCHAR) + ' Line_NUMB : ' + @Lc_LineNo8a_TEXT + ' TypeAsst_CODE : ' + @Lc_AsstTypeCurrent_CODE + ' TypeReport_CODE : ' + @Ac_TypeReport_CODE + ' Line8a_INDC : ' + @Lc_Yes_INDC + ' SupportYearMonth_NUMB : ' + CAST(@Ln_Yyyymm_NUMB AS VARCHAR);
   
     INSERT RO157_Y1
            (BeginFiscal_DATE,
             EndFiscal_DATE,
             TypeReport_CODE,
             Office_IDNO,
             County_IDNO,
             Worker_ID,
             LineNo_TEXT,
             Tot_QNTY,
             Ca_AMNT,
             Fa_AMNT,
             Na_AMNT)
     SELECT @Ld_Begin_DATE AS BeginFiscal_DATE,
            @Ld_End_DATE AS EndFiscal_DATE,
            a.TypeReport_CODE,
            a.Office_IDNO,
            a.County_IDNO,
            a.Worker_ID,
            @Lc_LineNo8a_Text AS LineNo_TEXT,
            SUM(1) AS Tot_QNTY,
            0 AS Ca_AMNT,
            0 AS Fa_AMNT,
            0 AS Na_AMNT
       FROM RD157_Y1 a,
            RASST_Y1 b
      WHERE b.Case_IDNO = a.Case_IDNO
        AND a.Line8a_INDC = @Lc_Yes_INDC
        AND b.SupportYearMonth_NUMB = @Ln_Yyyymm_NUMB
        AND a.BeginFiscal_DATE = @Ld_Begin_DATE
        AND a.EndFiscal_DATE = @Ld_End_DATE
        AND a.TypeReport_CODE = @Ac_TypeReport_CODE
      GROUP BY a.TypeReport_CODE,
               a.County_IDNO,
               a.Office_IDNO,
               a.Worker_ID;

     SET @Ln_RowCount_QNTY = @@ROWCOUNT;

     IF @Ln_RowCount_QNTY = 0
      BEGIN
       SET @Ls_Sql_TEXT = 'BATCH_RPT_OCSE157$SP_INSERT_LINE-LINENO-8A';
	   SET @Ls_Sqldata_TEXT = 'BeginFiscal_DATE : ' + CAST(@Ld_Begin_DATE AS VARCHAR) + ' EndFiscal_DATE : ' + CAST(@Ld_End_DATE AS VARCHAR) + ' TypeReport_CODE : ' + ISNULL(@Ac_TypeReport_CODE,'') + ' Line_NUMB : ' + @Lc_LineNo8a_TEXT;
	   
       EXECUTE BATCH_RPT_OCSE157$SP_POPULATE_EMPTY_LINES
        @Ad_BeginFiscal_DATE            = @Ld_Begin_DATE,
        @Ad_EndFiscal_DATE              = @Ld_End_DATE,
        @Ac_TypeReport_CODE             = @Ac_TypeReport_CODE,
        @Ac_Line_NUMB                   = @Lc_LineNo8a_TEXT,
        @Ac_Msg_CODE                    = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT       = @Ls_ErrorMessage_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
        SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');
         RAISERROR (50001,16,1);
        END
      END

     SET @Ls_Sql_TEXT = 'SUM UP THE COUNT AND INSERT RO157_Y1 LINE 9';
     SET @Ls_Sqldata_TEXT = 'BeginFiscal_DATE : ' + CAST(@Ld_Begin_DATE AS VARCHAR) + ' EndFiscal_DATE : ' + CAST(@Ld_End_DATE AS VARCHAR) + ' Line_NUMB : ' + @Lc_LineNo9_TEXT + ' TypeAsst_CODE : ' + @Lc_AsstTypeCurrent_CODE + ' TypeReport_CODE : ' + ISNULL(@Ac_TypeReport_CODE,'') + ' Line9_INDC : ' + @Lc_Yes_INDC + ' SupportYearMonth_NUMB : ' + CAST(@Ln_Yyyymm_NUMB AS VARCHAR);
     
     INSERT RO157_Y1
            (BeginFiscal_DATE,
             EndFiscal_DATE,
             TypeReport_CODE,
             Office_IDNO,
             County_IDNO,
             Worker_ID,
             LineNo_TEXT,
             Tot_QNTY,
             Ca_AMNT,
             Fa_AMNT,
             Na_AMNT)
     SELECT @Ld_Begin_DATE AS BeginFiscal_DATE,
            @Ld_End_DATE AS EndFiscal_DATE,
            a.TypeReport_CODE,
            a.Office_IDNO,
            a.County_IDNO,
            a.Worker_ID,
            @Lc_LineNo9_TEXT AS LineNo_TEXT,
            SUM(1) AS Tot_QNTY,
            0 AS Ca_AMNT,
            0 AS Fa_AMNT,
            0 AS Na_AMNT
       FROM RD157_Y1 a,
            RASST_Y1 b
      WHERE b.Case_IDNO = a.Case_IDNO
        AND a.Line9_INDC = @Lc_Yes_INDC
        AND b.SupportYearMonth_NUMB = @Ln_Yyyymm_NUMB
        AND a.BeginFiscal_DATE = @Ld_Begin_DATE
        AND a.EndFiscal_DATE = @Ld_End_DATE
        AND a.TypeReport_CODE = @Ac_TypeReport_CODE
      GROUP BY a.TypeReport_CODE,
               a.County_IDNO,
               a.Office_IDNO,
               a.Worker_ID;

     SET @Ln_RowCount_QNTY = @@ROWCOUNT;

     IF @Ln_RowCount_QNTY = 0
      BEGIN
       SET @Ls_Sql_TEXT = 'BATCH_RPT_OCSE157$SP_INSERT_LINE-LINENO-9';
	   SET @Ls_Sqldata_TEXT = 'BeginFiscal_DATE : ' + CAST(@Ld_Begin_DATE AS VARCHAR) + ' EndFiscal_DATE : ' + CAST(@Ld_End_DATE AS VARCHAR) + ' TypeReport_CODE : ' + ISNULL(@Ac_TypeReport_CODE,'') + ' Line_NUMB : ' + @Lc_LineNo9_TEXT;
	   
       EXECUTE BATCH_RPT_OCSE157$SP_POPULATE_EMPTY_LINES
        @Ad_BeginFiscal_DATE          = @Ld_Begin_DATE,
        @Ad_EndFiscal_DATE            = @Ld_End_DATE,
        @Ac_TypeReport_CODE           = @Ac_TypeReport_CODE,
        @Ac_Line_NUMB                 = @Lc_LineNo9_TEXT,
        @Ac_Msg_CODE                  = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT     = @Ls_ErrorMessage_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
        SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');
         RAISERROR (50001,16,1);
        END
      END

     SET @Ls_Sql_TEXT = 'SUM UP THE COUNT AND INSERT RO157_Y1 LINE 10';
     SET @Ls_Sqldata_TEXT = 'BeginFiscal_DATE : ' + CAST(@Ld_Begin_DATE AS VARCHAR) + ' EndFiscal_DATE : ' + CAST(@Ld_End_DATE AS VARCHAR) + ' Line_NUMB : ' + @Lc_LineNo10_TEXT + ' TypeAsst_CODE : ' + @Lc_AsstTypeCurrent_CODE + ' TypeReport_CODE : ' + ISNULL(@Ac_TypeReport_CODE,'') + ' Line10_INDC : ' + @Lc_Yes_INDC + ' SupportYearMonth_NUMB : ' + CAST(@Ln_Yyyymm_NUMB AS VARCHAR);
   
     INSERT RO157_Y1
            (BeginFiscal_DATE,
             EndFiscal_DATE,
             TypeReport_CODE,
             Office_IDNO,
             County_IDNO,
             Worker_ID,
             LineNo_TEXT,
             Tot_QNTY,
             Ca_AMNT,
             Fa_AMNT,
             Na_AMNT)
     SELECT @Ld_Begin_DATE AS BeginFiscal_DATE,
            @Ld_End_DATE AS EndFiscal_DATE,
            a.TypeReport_CODE,
            a.Office_IDNO,
            a.County_IDNO,
            a.Worker_ID,
            @Lc_LineNo10_Text AS LineNo_TEXT,
            SUM(1) AS Tot_QNTY,
            0 AS Ca_AMNT,
            0 AS Fa_AMNT,
            0 AS Na_AMNT
       FROM RD157_Y1 a,
            RASST_Y1 b
      WHERE b.Case_IDNO = a.Case_IDNO
        AND a.Line10_INDC = @Lc_Yes_INDC
        AND b.SupportYearMonth_NUMB = @Ln_Yyyymm_NUMB
        AND a.BeginFiscal_DATE = @Ld_Begin_DATE
        AND a.EndFiscal_DATE = @Ld_End_DATE
        AND a.TypeReport_CODE = @Ac_TypeReport_CODE
      GROUP BY a.TypeReport_CODE,
               a.County_IDNO,
               a.Office_IDNO,
               a.Worker_ID;

     SET @Ln_RowCount_QNTY = @@ROWCOUNT;

     IF @Ln_RowCount_QNTY = 0
      BEGIN
       SET @Ls_Sql_TEXT = 'BATCH_RPT_OCSE157$SP_INSERT_LINE-LINENO-10';
	   SET @Ls_Sqldata_TEXT = 'BeginFiscal_DATE : ' + CAST(@Ld_Begin_DATE AS VARCHAR) + ' EndFiscal_DATE : ' + CAST(@Ld_End_DATE AS VARCHAR) + ' TypeReport_CODE : ' + ISNULL(@Ac_TypeReport_CODE,'') + ' Line_NUMB : ' + @Lc_LineNo10_TEXT;
	   
       EXECUTE BATCH_RPT_OCSE157$SP_POPULATE_EMPTY_LINES
        @Ad_BeginFiscal_DATE         = @Ld_Begin_DATE,
        @Ad_EndFiscal_DATE           = @Ld_End_DATE,
        @Ac_TypeReport_CODE          = @Ac_TypeReport_CODE,
        @Ac_Line_NUMB                = @Lc_LineNo10_TEXT,
        @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT    = @Ls_ErrorMessage_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
        SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');
         RAISERROR (50001,16,1);
        END
      END

     SET @Ls_Sql_TEXT = 'SUM UP THE COUNT AND INSERT RO157_Y1 LINE 12';
     SET @Ls_Sqldata_TEXT = 'BeginFiscal_DATE : ' + CAST(@Ld_Begin_DATE AS VARCHAR) + ' EndFiscal_DATE : ' + CAST(@Ld_End_DATE AS VARCHAR) + ' Line_NUMB : ' + @Lc_LineNo12_TEXT + ' TypeAsst_CODE : ' + @Lc_AsstTypeCurrent_CODE + ' TypeReport_CODE : ' + ISNULL(@Ac_TypeReport_CODE,'') + ' Line12_INDC : ' + @Lc_Yes_INDC + ' SupportYearMonth_NUMB : ' + CAST(@Ln_Yyyymm_NUMB AS VARCHAR);
   
     INSERT RO157_Y1
            (BeginFiscal_DATE,
             EndFiscal_DATE,
             TypeReport_CODE,
             Office_IDNO,
             County_IDNO,
             Worker_ID,
             LineNo_TEXT,
             Tot_QNTY,
             Ca_AMNT,
             Fa_AMNT,
             Na_AMNT)
     SELECT @Ld_Begin_DATE AS BeginFiscal_DATE,
            @Ld_End_DATE AS EndFiscal_DATE,
            a.TypeReport_CODE,
            a.Office_IDNO,
            a.County_IDNO,
            a.Worker_ID,
            @Lc_LineNo12_TEXT AS LineNo_TEXT,
            ISNULL(SUM(CASE b.TypeAsst_CODE
                        WHEN @Lc_AsstTypeCurrent_CODE
                         THEN 1
                        WHEN @Lc_AsstTypeFormer_CODE
                         THEN 1
                        WHEN @Lc_AsstTypeNever_CODE
                         THEN 1
                        ELSE 0
                       END), 0) AS Tot_QNTY,
            ISNULL(SUM(CASE b.TypeAsst_CODE
                        WHEN @Lc_AsstTypeCurrent_CODE
                         THEN 1
                        ELSE 0
                       END), 0) AS Ca_AMNT,
            ISNULL(SUM(CASE b.TypeAsst_CODE
                        WHEN @Lc_AsstTypeFormer_CODE
                         THEN 1
                        ELSE 0
                       END), 0) AS Fa_AMNT,
            ISNULL(SUM(CASE b.TypeAsst_CODE
                        WHEN @Lc_AsstTypeNever_CODE
                         THEN 1
                        ELSE 0
                       END), 0) AS Na_AMNT
       FROM RC157_Y1 a,
            RASST_Y1 b
      WHERE b.Case_IDNO = a.Case_IDNO
        AND a.Line12_INDC = @Lc_Yes_INDC
        AND b.SupportYearMonth_NUMB = @Ln_Yyyymm_NUMB
        AND a.BeginFiscal_DATE = @Ld_Begin_DATE
        AND a.EndFiscal_DATE = @Ld_End_DATE
        AND a.TypeReport_CODE = @Ac_TypeReport_CODE
      GROUP BY a.TypeReport_CODE,
               a.County_IDNO,
               a.Office_IDNO,
               a.Worker_ID;

     SET @Ln_RowCount_QNTY = @@ROWCOUNT;

     IF @Ln_RowCount_QNTY = 0
      BEGIN
       SET @Ls_Sql_TEXT = 'BATCH_RPT_OCSE157$SP_INSERT_LINE-LINENO-12';
	   SET @Ls_Sqldata_TEXT = 'BeginFiscal_DATE : ' + CAST(@Ld_Begin_DATE AS VARCHAR) + ' EndFiscal_DATE : ' + CAST(@Ld_End_DATE AS VARCHAR) + ' TypeReport_CODE : ' + ISNULL(@Ac_TypeReport_CODE,'') + ' Line_NUMB : ' + @Lc_LineNo12_TEXT;
	   
       EXECUTE BATCH_RPT_OCSE157$SP_POPULATE_EMPTY_LINES
        @Ad_BeginFiscal_DATE        = @Ld_Begin_DATE,
        @Ad_EndFiscal_DATE          = @Ld_End_DATE,
        @Ac_TypeReport_CODE         = @Ac_TypeReport_CODE,
        @Ac_Line_NUMB               = @Lc_LineNo12_TEXT,
        @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT   = @Ls_ErrorMessage_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
        SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');
         RAISERROR (50001,16,1);
        END
      END

     SET @Ls_Sql_TEXT = 'SUM UP THE COUNT AND INSERT RO157_Y1 LINE 13';
     SET @Ls_Sqldata_TEXT = 'BeginFiscal_DATE : ' + CAST(@Ld_Begin_DATE AS VARCHAR) + ' EndFiscal_DATE : ' + CAST(@Ld_End_DATE AS VARCHAR) + ' Line_NUMB : ' + @Lc_LineNo13_TEXT + ' TypeAsst_CODE : ' + @Lc_AsstTypeCurrent_CODE + ' TypeReport_CODE : ' + ISNULL(@Ac_TypeReport_CODE,'') + ' Line13_INDC : ' + @Lc_Yes_INDC + ' SupportYearMonth_NUMB : ' + CAST(@Ln_Yyyymm_NUMB AS VARCHAR);
   
     INSERT RO157_Y1
            (BeginFiscal_DATE,
             EndFiscal_DATE,
             TypeReport_CODE,
             Office_IDNO,
             County_IDNO,
             Worker_ID,
             LineNo_TEXT,
             Tot_QNTY,
             Ca_AMNT,
             Fa_AMNT,
             Na_AMNT)
     SELECT @Ld_Begin_DATE AS BeginFiscal_DATE,
            @Ld_End_DATE AS EndFiscal_DATE,
            a.TypeReport_CODE,
            a.Office_IDNO,
            a.County_IDNO,
            a.Worker_ID,
            @Lc_LineNo13_TEXT AS LineNo_TEXT,
            ISNULL(SUM(CASE b.TypeAsst_CODE
                        WHEN @Lc_AsstTypeCurrent_CODE
                         THEN 1
                        WHEN @Lc_AsstTypeFormer_CODE
                         THEN 1
                        WHEN @Lc_AsstTypeNever_CODE
                         THEN 1
                        ELSE 0
                       END), 0) AS Tot_QNTY,
            ISNULL(SUM(CASE b.TypeAsst_CODE
                        WHEN @Lc_AsstTypeCurrent_CODE
                         THEN 1
                        ELSE 0
                       END), 0) AS Ca_AMNT,
            ISNULL(SUM(CASE b.TypeAsst_CODE
                        WHEN @Lc_AsstTypeFormer_CODE
                         THEN 1
                        ELSE 0
                       END), 0) AS Fa_AMNT,
            ISNULL(SUM(CASE b.TypeAsst_CODE
                        WHEN @Lc_AsstTypeNever_CODE
                         THEN 1
                        ELSE 0
                       END), 0) AS Na_AMNT
       FROM RD157_Y1 a,
            RASST_Y1 b
      WHERE b.Case_IDNO = a.Case_IDNO
        AND a.Line13_INDC = @Lc_Yes_INDC
        AND b.SupportYearMonth_NUMB = @Ln_Yyyymm_NUMB
        AND a.BeginFiscal_DATE = @Ld_Begin_DATE
        AND a.EndFiscal_DATE = @Ld_End_DATE
        AND a.TypeReport_CODE = @Ac_TypeReport_CODE
      GROUP BY a.TypeReport_CODE,
               a.County_IDNO,
               a.Office_IDNO,
               a.Worker_ID;

     SET @Ln_RowCount_QNTY = @@ROWCOUNT;

     IF @Ln_RowCount_QNTY = 0
      BEGIN
       SET @Ls_Sql_TEXT = 'BATCH_RPT_OCSE157$SP_INSERT_LINE-LINENO-13';
	   SET @Ls_Sqldata_TEXT = 'BeginFiscal_DATE : ' + CAST(@Ld_Begin_DATE AS VARCHAR) + ' EndFiscal_DATE : ' + CAST(@Ld_End_DATE AS VARCHAR) + ' TypeReport_CODE : ' + ISNULL(@Ac_TypeReport_CODE,'') + ' Line_NUMB : ' + @Lc_LineNo13_TEXT;
	   
       EXECUTE BATCH_RPT_OCSE157$SP_POPULATE_EMPTY_LINES
        @Ad_BeginFiscal_DATE        = @Ld_Begin_DATE,
        @Ad_EndFiscal_DATE          = @Ld_End_DATE,
        @Ac_TypeReport_CODE         = @Ac_TypeReport_CODE,
        @Ac_Line_NUMB               = @Lc_LineNo12_TEXT,
        @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT   = @Ls_ErrorMessage_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
        SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');
         RAISERROR (50001,16,1);
        END
      END

     SET @Ls_Sql_TEXT = 'SUM UP THE COUNT AND INSERT RO157_Y1 LINE 14';
     SET @Ls_Sqldata_TEXT = 'BeginFiscal_DATE : ' + CAST(@Ld_Begin_DATE AS VARCHAR) + ' EndFiscal_DATE : ' + CAST(@Ld_End_DATE AS VARCHAR) + ' Line_NUMB : ' + @Lc_LineNo14_TEXT + ' TypeAsst_CODE : ' + @Lc_AsstTypeCurrent_CODE + ' TypeReport_CODE : ' + ISNULL(@Ac_TypeReport_CODE,'') + ' Line14_INDC : ' + @Lc_Yes_INDC + ' SupportYearMonth_NUMB : ' + CAST(@Ln_Yyyymm_NUMB AS VARCHAR);
   
     INSERT RO157_Y1
            (BeginFiscal_DATE,
             EndFiscal_DATE,
             TypeReport_CODE,
             Office_IDNO,
             County_IDNO,
             Worker_ID,
             LineNo_TEXT,
             Tot_QNTY,
             Ca_AMNT,
             Fa_AMNT,
             Na_AMNT)
     SELECT @Ld_Begin_DATE AS BeginFiscal_DATE,
            @Ld_End_DATE AS EndFiscal_DATE,
            a.TypeReport_CODE,
            a.Office_IDNO,
            a.County_IDNO,
            a.Worker_ID,
            @Lc_LineNo14_TEXT AS LineNo_TEXT,
            SUM(1) AS Tot_QNTY,
            0 AS Ca_AMNT,
            0 AS Fa_AMNT,
            0 AS Na_AMNT
       FROM RC157_Y1 a,
            RASST_Y1 b
      WHERE b.Case_IDNO = a.Case_IDNO
        AND a.Line14_INDC = @Lc_Yes_INDC
        AND b.SupportYearMonth_NUMB = @Ln_Yyyymm_NUMB
        AND a.BeginFiscal_DATE = @Ld_Begin_DATE
        AND a.EndFiscal_DATE = @Ld_End_DATE
        AND a.TypeReport_CODE = @Ac_TypeReport_CODE
      GROUP BY a.TypeReport_CODE,
               a.County_IDNO,
               a.Office_IDNO,
               a.Worker_ID;

     SET @Ln_RowCount_QNTY = @@ROWCOUNT;

     IF @Ln_RowCount_QNTY = 0
      BEGIN
       SET @Ls_Sql_TEXT = 'BATCH_RPT_OCSE157$SP_INSERT_LINE-LINENO-14';
	   SET @Ls_Sqldata_TEXT = 'BeginFiscal_DATE : ' + CAST(@Ld_Begin_DATE AS VARCHAR) + ' EndFiscal_DATE : ' + CAST(@Ld_End_DATE AS VARCHAR) + ' TypeReport_CODE : ' + ISNULL(@Ac_TypeReport_CODE,'') + ' Line_NUMB : ' + @Lc_LineNo14_TEXT;
	   
       EXECUTE BATCH_RPT_OCSE157$SP_POPULATE_EMPTY_LINES
        @Ad_BeginFiscal_DATE        = @Ld_Begin_DATE,
        @Ad_EndFiscal_DATE          = @Ld_End_DATE,
        @Ac_TypeReport_CODE         = @Ac_TypeReport_CODE,
        @Ac_Line_NUMB               = @Lc_LineNo12_TEXT,
        @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT   = @Ls_ErrorMessage_TEXT OUTPUT;
        
       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
        SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');
         RAISERROR (50001,16,1);
        END
      END

     SET @Ls_Sql_TEXT = 'SUM UP THE COUNT AND INSERT RO157_Y1 LINE 16';
     SET @Ls_Sqldata_TEXT = 'BeginFiscal_DATE : ' + CAST(@Ld_Begin_DATE AS VARCHAR) + ' EndFiscal_DATE : ' + CAST(@Ld_End_DATE AS VARCHAR) + ' Line_NUMB : ' + @Lc_LineNo16_TEXT + ' TypeAsst_CODE : ' + @Lc_AsstTypeCurrent_CODE + ' TypeReport_CODE : ' + ISNULL(@Ac_TypeReport_CODE,'') + ' Line16_INDC : ' + @Lc_Yes_INDC + ' SupportYearMonth_NUMB : ' + CAST(@Ln_Yyyymm_NUMB AS VARCHAR);
   
     INSERT RO157_Y1
            (BeginFiscal_DATE,
             EndFiscal_DATE,
             TypeReport_CODE,
             Office_IDNO,
             County_IDNO,
             Worker_ID,
             LineNo_TEXT,
             Tot_QNTY,
             Ca_AMNT,
             Fa_AMNT,
             Na_AMNT)
     SELECT @Ld_Begin_DATE AS BeginFiscal_DATE,
            @Ld_End_DATE AS EndFiscal_DATE,
            a.TypeReport_CODE,
            a.Office_IDNO,
            a.County_IDNO,
            a.Worker_ID,
            @Lc_LineNo16_TEXT AS LineNo_TEXT,
            ISNULL(SUM(CASE b.TypeAsst_CODE
                        WHEN @Lc_AsstTypeCurrent_CODE
                         THEN 1
                        WHEN @Lc_AsstTypeFormer_CODE
                         THEN 1
                        WHEN @Lc_AsstTypeNever_CODE
                         THEN 1
                        ELSE 0
                       END), 0) AS Tot_QNTY,
            ISNULL(SUM(CASE b.TypeAsst_CODE
                        WHEN @Lc_AsstTypeCurrent_CODE
                         THEN 1
                        ELSE 0
                       END), 0) AS Ca_AMNT,
            ISNULL(SUM(CASE b.TypeAsst_CODE
                        WHEN @Lc_AsstTypeFormer_CODE
                         THEN 1
                        ELSE 0
                       END), 0) AS Fa_AMNT,
            ISNULL(SUM(CASE b.TypeAsst_CODE
                        WHEN @Lc_AsstTypeNever_CODE
                         THEN 1
                        ELSE 0
                       END), 0) AS Na_AMNT
       FROM RD157_Y1 a,
            RASST_Y1 b
      WHERE b.Case_IDNO = a.Case_IDNO
        AND a.Line16_INDC = @Lc_Yes_INDC
        AND b.SupportYearMonth_NUMB = @Ln_Yyyymm_NUMB
        AND a.BeginFiscal_DATE = @Ld_Begin_DATE
        AND a.EndFiscal_DATE = @Ld_End_DATE
        AND a.TypeReport_CODE = @Ac_TypeReport_CODE
      GROUP BY a.TypeReport_CODE,
               a.County_IDNO,
               a.Office_IDNO,
               a.Worker_ID;

     SET @Ln_RowCount_QNTY = @@ROWCOUNT;

     IF @Ln_RowCount_QNTY = 0
      BEGIN
       SET @Ls_Sql_TEXT = 'BATCH_RPT_OCSE157$SP_INSERT_LINE-LINENO-16';
	   SET @Ls_Sqldata_TEXT = 'BeginFiscal_DATE : ' + CAST(@Ld_Begin_DATE AS VARCHAR) + ' EndFiscal_DATE : ' + CAST(@Ld_End_DATE AS VARCHAR) + ' TypeReport_CODE : ' + ISNULL(@Ac_TypeReport_CODE,'') + ' Line_NUMB : ' + @Lc_LineNo16_TEXT;
	   
       EXECUTE BATCH_RPT_OCSE157$SP_POPULATE_EMPTY_LINES
        @Ad_BeginFiscal_DATE        = @Ld_Begin_DATE,
        @Ad_EndFiscal_DATE          = @Ld_End_DATE,
        @Ac_TypeReport_CODE         = @Ac_TypeReport_CODE,
        @Ac_Line_NUMB               = @Lc_LineNo12_TEXT,
        @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT   = @Ls_ErrorMessage_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
        SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');
         RAISERROR (50001,16,1);
        END
      END

     SET @Ls_Sql_TEXT = 'SUM UP THE COUNT AND INSERT RO157_Y1 LINE 17';
     SET @Ls_Sqldata_TEXT = 'BeginFiscal_DATE : ' + CAST(@Ld_Begin_DATE AS VARCHAR) + ' EndFiscal_DATE : ' + CAST(@Ld_End_DATE AS VARCHAR) + ' Line_NUMB : ' + @Lc_LineNo17_TEXT + ' TypeAsst_CODE : ' + @Lc_AsstTypeCurrent_CODE + ' TypeReport_CODE : ' + ISNULL(@Ac_TypeReport_CODE,'') + ' Line17_INDC : ' + @Lc_Yes_INDC + ' SupportYearMonth_NUMB : ' + CAST(@Ln_Yyyymm_NUMB AS VARCHAR);
   
     INSERT RO157_Y1
            (BeginFiscal_DATE,
             EndFiscal_DATE,
             TypeReport_CODE,
             Office_IDNO,
             County_IDNO,
             Worker_ID,
             LineNo_TEXT,
             Tot_QNTY,
             Ca_AMNT,
             Fa_AMNT,
             Na_AMNT)
     SELECT @Ld_Begin_DATE AS BeginFiscal_DATE,
            @Ld_End_DATE AS EndFiscal_DATE,
            a.TypeReport_CODE,
            a.Office_IDNO,
            a.County_IDNO,
            a.Worker_ID,
            @Lc_LineNo17_TEXT AS LineNo_TEXT,
            ISNULL(SUM(CASE b.TypeAsst_CODE
                        WHEN @Lc_AsstTypeCurrent_CODE
                         THEN 1
                        WHEN @Lc_AsstTypeFormer_CODE
                         THEN 1
                        WHEN @Lc_AsstTypeNever_CODE
                         THEN 1
                        ELSE 0
                       END), 0) AS Tot_QNTY,
            ISNULL(SUM(CASE b.TypeAsst_CODE
                        WHEN @Lc_AsstTypeCurrent_CODE
                         THEN 1
                        ELSE 0
                       END), 0) AS Ca_AMNT,
            ISNULL(SUM(CASE b.TypeAsst_CODE
                        WHEN @Lc_AsstTypeFormer_CODE
                         THEN 1
                        ELSE 0
                       END), 0) AS Fa_AMNT,
            ISNULL(SUM(CASE b.TypeAsst_CODE
                        WHEN @Lc_AsstTypeNever_CODE
                         THEN 1
                        ELSE 0
                       END), 0) AS Na_AMNT
       FROM RC157_Y1 a,
            RASST_Y1 b
      WHERE b.Case_IDNO = a.Case_IDNO
        AND a.Line17_INDC = @Lc_Yes_INDC
        AND b.SupportYearMonth_NUMB = @Ln_Yyyymm_NUMB
        AND a.BeginFiscal_DATE = @Ld_Begin_DATE
        AND a.EndFiscal_DATE = @Ld_End_DATE
        AND a.TypeReport_CODE = @Ac_TypeReport_CODE
      GROUP BY a.TypeReport_CODE,
               a.County_IDNO,
               a.Office_IDNO,
               a.Worker_ID;

     SET @Ln_RowCount_QNTY = @@ROWCOUNT;

     IF @Ln_RowCount_QNTY = 0
      BEGIN
       SET @Ls_Sql_TEXT = 'BATCH_RPT_OCSE157$SP_INSERT_LINE-LINENO-17';
	   SET @Ls_Sqldata_TEXT = 'BeginFiscal_DATE : ' + CAST(@Ld_Begin_DATE AS VARCHAR) + ' EndFiscal_DATE : ' + CAST(@Ld_End_DATE AS VARCHAR) + ' TypeReport_CODE : ' + ISNULL(@Ac_TypeReport_CODE,'') + ' Line_NUMB : ' + @Lc_LineNo17_TEXT;
	   
       EXECUTE BATCH_RPT_OCSE157$SP_POPULATE_EMPTY_LINES
        @Ad_BeginFiscal_DATE        = @Ld_Begin_DATE,
        @Ad_EndFiscal_DATE          = @Ld_End_DATE,
        @Ac_TypeReport_CODE         = @Ac_TypeReport_CODE,
        @Ac_Line_NUMB               = @Lc_LineNo12_TEXT,
        @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT   = @Ls_ErrorMessage_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
        SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');
         RAISERROR (50001,16,1);
        END
      END

     SET @Ls_Sql_TEXT = 'SUM UP THE COUNT AND INSERT RO157_Y1 LINE 18';
     SET @Ls_Sqldata_TEXT = 'BeginFiscal_DATE : ' + CAST(@Ld_Begin_DATE AS VARCHAR) + ' EndFiscal_DATE : ' + CAST(@Ld_End_DATE AS VARCHAR) + ' Line_NUMB : ' + @Lc_LineNo18_TEXT + ' TypeAsst_CODE : ' + @Lc_AsstTypeCurrent_CODE + ' TypeReport_CODE : ' + ISNULL(@Ac_TypeReport_CODE,'') + ' Line18_INDC : ' + @Lc_Yes_INDC + ' SupportYearMonth_NUMB : ' + CAST(@Ln_Yyyymm_NUMB AS VARCHAR);
     INSERT RO157_Y1
            (BeginFiscal_DATE,
             EndFiscal_DATE,
             TypeReport_CODE,
             Office_IDNO,
             County_IDNO,
             Worker_ID,
             LineNo_TEXT,
             Tot_QNTY,
             Ca_AMNT,
             Fa_AMNT,
             Na_AMNT)
     SELECT @Ld_Begin_DATE AS BeginFiscal_DATE,
            @Ld_End_DATE AS EndFiscal_DATE,
            a.TypeReport_CODE,
            a.Office_IDNO,
            a.County_IDNO,
            a.Worker_ID,
            @Lc_LineNo18_TEXT AS LineNo_TEXT,
            ISNULL(SUM(CASE b.TypeAsst_CODE
                        WHEN @Lc_AsstTypeCurrent_CODE
                         THEN 1
                        WHEN @Lc_AsstTypeFormer_CODE
                         THEN 1
                        WHEN @Lc_AsstTypeNever_CODE
                         THEN 1
                        ELSE 0
                       END), 0) AS Tot_QNTY,
            ISNULL(SUM(CASE b.TypeAsst_CODE
                        WHEN @Lc_AsstTypeCurrent_CODE
                         THEN 1
                        ELSE 0
                       END), 0) AS Ca_AMNT,
            ISNULL(SUM(CASE b.TypeAsst_CODE
                        WHEN @Lc_AsstTypeFormer_CODE
                         THEN 1
                        ELSE 0
                       END), 0) AS Fa_AMNT,
            ISNULL(SUM(CASE b.TypeAsst_CODE
                        WHEN @Lc_AsstTypeNever_CODE
                         THEN 1
                        ELSE 0
                       END), 0) AS Na_AMNT
       FROM RC157_Y1 a,
            RASST_Y1 b
      WHERE b.Case_IDNO = a.Case_IDNO
        AND a.Line18_INDC = @Lc_Yes_INDC
        AND b.SupportYearMonth_NUMB = @Ln_Yyyymm_NUMB
        AND a.BeginFiscal_DATE = @Ld_Begin_DATE
        AND a.EndFiscal_DATE = @Ld_End_DATE
        AND a.TypeReport_CODE = @Ac_TypeReport_CODE
      GROUP BY a.TypeReport_CODE,
               a.County_IDNO,
               a.Office_IDNO,
               a.Worker_ID;

     SET @Ln_RowCount_QNTY = @@ROWCOUNT;

     IF @Ln_RowCount_QNTY = 0
      BEGIN
       SET @Ls_Sql_TEXT = 'BATCH_RPT_OCSE157$SP_INSERT_LINE-LINENO-18';
	   SET @Ls_Sqldata_TEXT = 'BeginFiscal_DATE : ' + CAST(@Ld_Begin_DATE AS VARCHAR) + ' EndFiscal_DATE : ' + CAST(@Ld_End_DATE AS VARCHAR) + ' TypeReport_CODE : ' + ISNULL(@Ac_TypeReport_CODE,'') + ' Line_NUMB : ' + @Lc_LineNo18_TEXT;
	   
       EXECUTE BATCH_RPT_OCSE157$SP_POPULATE_EMPTY_LINES
        @Ad_BeginFiscal_DATE        = @Ld_Begin_DATE,
        @Ad_EndFiscal_DATE          = @Ld_End_DATE,
        @Ac_TypeReport_CODE         = @Ac_TypeReport_CODE,
        @Ac_Line_NUMB               = @Lc_LineNo12_TEXT,
        @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT   = @Ls_ErrorMessage_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
        SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');
         RAISERROR (50001,16,1);
        END
      END

     SET @Ls_Sql_TEXT = 'SUM UP THE COUNT AND INSERT RO157_Y1 LINE 18A';
     SET @Ls_Sqldata_TEXT = 'BeginFiscal_DATE : ' + CAST(@Ld_Begin_DATE AS VARCHAR) + ' EndFiscal_DATE : ' + CAST(@Ld_End_DATE AS VARCHAR) + ' Line_NUMB : ' + @Lc_LineNo18a_TEXT + ' TypeAsst_CODE : ' + @Lc_AsstTypeCurrent_CODE + ' TypeReport_CODE : ' + ISNULL(@Ac_TypeReport_CODE,'') + ' Line18a_INDC : ' + @Lc_Yes_INDC + ' SupportYearMonth_NUMB : ' + CAST(@Ln_Yyyymm_NUMB AS VARCHAR);
   
     INSERT RO157_Y1
            (BeginFiscal_DATE,
             EndFiscal_DATE,
             TypeReport_CODE,
             Office_IDNO,
             County_IDNO,
             Worker_ID,
             LineNo_TEXT,
             Tot_QNTY,
             Ca_AMNT,
             Fa_AMNT,
             Na_AMNT)
     SELECT @Ld_Begin_DATE AS BeginFiscal_DATE,
            @Ld_End_DATE AS EndFiscal_DATE,
            a.TypeReport_CODE,
            a.Office_IDNO,
            a.County_IDNO,
            a.Worker_ID,
            @Lc_LineNo18a_TEXT AS LineNo_TEXT,
            ISNULL(SUM(CASE b.TypeAsst_CODE
                        WHEN @Lc_AsstTypeCurrent_CODE
                         THEN 1
                        WHEN @Lc_AsstTypeFormer_CODE
                         THEN 1
                        WHEN @Lc_AsstTypeNever_CODE
                         THEN 1
                        ELSE 0
                       END), 0) AS Tot_QNTY,
            ISNULL(SUM(CASE b.TypeAsst_CODE
                        WHEN @Lc_AsstTypeCurrent_CODE
                         THEN 1
                        ELSE 0
                       END), 0) AS Ca_AMNT,
            ISNULL(SUM(CASE b.TypeAsst_CODE
                        WHEN @Lc_AsstTypeFormer_CODE
                         THEN 1
                        ELSE 0
                       END), 0) AS Fa_AMNT,
            ISNULL(SUM(CASE b.TypeAsst_CODE
                        WHEN @Lc_AsstTypeNever_CODE
                         THEN 1
                        ELSE 0
                       END), 0) AS Na_AMNT
       FROM RC157_Y1 a,
            RASST_Y1 b
      WHERE b.Case_IDNO = a.Case_IDNO
        AND a.Line18a_INDC = @Lc_Yes_INDC
        AND b.SupportYearMonth_NUMB = @Ln_Yyyymm_NUMB
        AND a.BeginFiscal_DATE = @Ld_Begin_DATE
        AND a.EndFiscal_DATE = @Ld_End_DATE
        AND a.TypeReport_CODE = @Ac_TypeReport_CODE
      GROUP BY a.TypeReport_CODE,
               a.County_IDNO,
               a.Office_IDNO,
               a.Worker_ID;

     SET @Ln_RowCount_QNTY = @@ROWCOUNT;

     IF @Ln_RowCount_QNTY = 0
      BEGIN
       SET @Ls_Sql_TEXT = 'BATCH_RPT_OCSE157$SP_INSERT_LINE-LINENO-18A';
	   SET @Ls_Sqldata_TEXT = 'BeginFiscal_DATE : ' + CAST(@Ld_Begin_DATE AS VARCHAR) + ' EndFiscal_DATE : ' + CAST(@Ld_End_DATE AS VARCHAR) + ' TypeReport_CODE : ' + ISNULL(@Ac_TypeReport_CODE,'') + ' Line_NUMB : ' + @Lc_LineNo18a_TEXT;     
	   
       EXECUTE BATCH_RPT_OCSE157$SP_POPULATE_EMPTY_LINES
        @Ad_BeginFiscal_DATE        = @Ld_Begin_DATE,
        @Ad_EndFiscal_DATE          = @Ld_End_DATE,
        @Ac_TypeReport_CODE         = @Ac_TypeReport_CODE,
        @Ac_Line_NUMB               = @Lc_LineNo12_TEXT,
        @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT   = @Ls_ErrorMessage_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
        SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');
         RAISERROR (50001,16,1);
        END
      END

     SET @Ls_Sql_TEXT = 'SUM UP THE COUNT AND INSERT RO157_Y1 LINE 19';
     SET @Ls_Sqldata_TEXT = 'BeginFiscal_DATE : ' + CAST(@Ld_Begin_DATE AS VARCHAR) + ' EndFiscal_DATE : ' + CAST(@Ld_End_DATE AS VARCHAR) + ' Line_NUMB : ' + @Lc_LineNo19_TEXT + ' TypeAsst_CODE : ' + @Lc_AsstTypeCurrent_CODE + ' TypeReport_CODE : ' + ISNULL(@Ac_TypeReport_CODE,'') + ' Line19_INDC : ' + @Lc_Yes_INDC + ' SupportYearMonth_NUMB : ' + CAST(@Ln_Yyyymm_NUMB AS VARCHAR);
   
     INSERT RO157_Y1
            (BeginFiscal_DATE,
             EndFiscal_DATE,
             TypeReport_CODE,
             Office_IDNO,
             County_IDNO,
             Worker_ID,
             LineNo_TEXT,
             Tot_QNTY,
             Ca_AMNT,
             Fa_AMNT,
             Na_AMNT)
     SELECT @Ld_Begin_DATE AS BeginFiscal_DATE,
            @Ld_End_DATE AS EndFiscal_DATE,
            a.TypeReport_CODE,
            a.Office_IDNO,
            a.County_IDNO,
            a.Worker_ID,
            @Lc_LineNo19_TEXT AS LineNo_TEXT,
            ISNULL(SUM(CASE b.TypeAsst_CODE
                        WHEN @Lc_AsstTypeCurrent_CODE
                         THEN 1
                        WHEN @Lc_AsstTypeFormer_CODE
                         THEN 1
                        WHEN @Lc_AsstTypeNever_CODE
                         THEN 1
                        ELSE 0
                       END), 0) AS Tot_QNTY,
            ISNULL(SUM(CASE b.TypeAsst_CODE
                        WHEN @Lc_AsstTypeCurrent_CODE
                         THEN 1
                        ELSE 0
                       END), 0) AS Ca_AMNT,
            ISNULL(SUM(CASE b.TypeAsst_CODE
                        WHEN @Lc_AsstTypeFormer_CODE
                         THEN 1
                        ELSE 0
                       END), 0) AS Fa_AMNT,
            ISNULL(SUM(CASE b.TypeAsst_CODE
                        WHEN @Lc_AsstTypeNever_CODE
                         THEN 1
                        ELSE 0
                       END), 0) AS Na_AMNT
       FROM RC157_Y1 a,
            RASST_Y1 b
      WHERE b.Case_IDNO = a.Case_IDNO
        AND a.Line19_INDC = @Lc_Yes_INDC
        AND b.SupportYearMonth_NUMB = @Ln_Yyyymm_NUMB
        AND a.BeginFiscal_DATE = @Ld_Begin_DATE
        AND a.EndFiscal_DATE = @Ld_End_DATE
        AND a.TypeReport_CODE = @Ac_TypeReport_CODE
      GROUP BY a.TypeReport_CODE,
               a.County_IDNO,
               a.Office_IDNO,
               a.Worker_ID;

     SET @Ln_RowCount_QNTY = @@ROWCOUNT;

     IF @Ln_RowCount_QNTY = 0
      BEGIN
       SET @Ls_Sql_TEXT = 'BATCH_RPT_OCSE157$SP_INSERT_LINE-LINENO-19';
	   SET @Ls_Sqldata_TEXT = 'BeginFiscal_DATE : ' + CAST(@Ld_Begin_DATE AS VARCHAR) + ' EndFiscal_DATE : ' + CAST(@Ld_End_DATE AS VARCHAR) + ' TypeReport_CODE : ' + ISNULL(@Ac_TypeReport_CODE,'') + ' Line_NUMB : ' + @Lc_LineNo19_TEXT;     
	   
       EXECUTE BATCH_RPT_OCSE157$SP_POPULATE_EMPTY_LINES
        @Ad_BeginFiscal_DATE        = @Ld_Begin_DATE,
        @Ad_EndFiscal_DATE          = @Ld_End_DATE,
        @Ac_TypeReport_CODE         = @Ac_TypeReport_CODE,
        @Ac_Line_NUMB               = @Lc_LineNo12_TEXT,
        @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT   = @Ls_ErrorMessage_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
        SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');
         RAISERROR (50001,16,1);
        END
      END

     SET @Ls_Sql_TEXT = 'SUM UP THE COUNT AND INSERT RO157_Y1 LINE 20';
     SET @Ls_Sqldata_TEXT = 'BeginFiscal_DATE : ' + CAST(@Ld_Begin_DATE AS VARCHAR) + ' EndFiscal_DATE : ' + CAST(@Ld_End_DATE AS VARCHAR) + ' Line_NUMB : ' + @Lc_LineNo20_TEXT + ' TypeAsst_CODE : ' + @Lc_AsstTypeCurrent_CODE + ' TypeReport_CODE : ' + ISNULL(@Ac_TypeReport_CODE,'') + ' Line20_INDC : ' + @Lc_Yes_INDC + ' SupportYearMonth_NUMB : ' + CAST(@Ln_Yyyymm_NUMB AS VARCHAR);
   
     INSERT RO157_Y1
            (BeginFiscal_DATE,
             EndFiscal_DATE,
             TypeReport_CODE,
             Office_IDNO,
             County_IDNO,
             Worker_ID,
             LineNo_TEXT,
             Tot_QNTY,
             Ca_AMNT,
             Fa_AMNT,
             Na_AMNT)
     SELECT @Ld_Begin_DATE AS BeginFiscal_DATE,
            @Ld_End_DATE AS EndFiscal_DATE,
            a.TypeReport_CODE,
            a.Office_IDNO,
            a.County_IDNO,
            a.Worker_ID,
            @Lc_LineNo20_TEXT AS LineNo_TEXT,
            ISNULL(SUM(CASE b.TypeAsst_CODE
                        WHEN @Lc_AsstTypeCurrent_CODE
                         THEN 1
                        WHEN @Lc_AsstTypeFormer_CODE
                         THEN 1
                        WHEN @Lc_AsstTypeNever_CODE
                         THEN 1
                        ELSE 0
                       END), 0) AS Tot_QNTY,
            ISNULL(SUM(CASE b.TypeAsst_CODE
                        WHEN @Lc_AsstTypeCurrent_CODE
                         THEN 1
                        ELSE 0
                       END), 0) AS Ca_AMNT,
            ISNULL(SUM(CASE b.TypeAsst_CODE
                        WHEN @Lc_AsstTypeFormer_CODE
                         THEN 1
                        ELSE 0
                       END), 0) AS Fa_AMNT,
            ISNULL(SUM(CASE b.TypeAsst_CODE
                        WHEN @Lc_AsstTypeNever_CODE
                         THEN 1
                        ELSE 0
                       END), 0) AS Na_AMNT
       FROM RC157_Y1 a,
            RASST_Y1 b
      WHERE b.Case_IDNO = a.Case_IDNO
        AND a.Line20_INDC = @Lc_Yes_INDC
        AND b.SupportYearMonth_NUMB = @Ln_Yyyymm_NUMB
        AND a.BeginFiscal_DATE = @Ld_Begin_DATE
        AND a.EndFiscal_DATE = @Ld_End_DATE
        AND a.TypeReport_CODE = @Ac_TypeReport_CODE
      GROUP BY a.TypeReport_CODE,
               a.County_IDNO,
               a.Office_IDNO,
               a.Worker_ID;

     SET @Ln_RowCount_QNTY = @@ROWCOUNT;

     IF @Ln_RowCount_QNTY = 0
      BEGIN
       SET @Ls_Sql_TEXT = 'BATCH_RPT_OCSE157$SP_INSERT_LINE-LINENO-20';
	   SET @Ls_Sqldata_TEXT = 'BeginFiscal_DATE : ' + CAST(@Ld_Begin_DATE AS VARCHAR) + ' EndFiscal_DATE : ' + CAST(@Ld_End_DATE AS VARCHAR) + ' TypeReport_CODE : ' + ISNULL(@Ac_TypeReport_CODE,'') + ' Line_NUMB : ' + @Lc_LineNo20_TEXT;     
	   
       EXECUTE BATCH_RPT_OCSE157$SP_POPULATE_EMPTY_LINES
        @Ad_BeginFiscal_DATE        = @Ld_Begin_DATE,
        @Ad_EndFiscal_DATE          = @Ld_End_DATE,
        @Ac_TypeReport_CODE         = @Ac_TypeReport_CODE,
        @Ac_Line_NUMB               = @Lc_LineNo12_TEXT,
        @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT   = @Ls_ErrorMessage_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
        SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');
         RAISERROR (50001,16,1);
        END
      END

     SET @Ls_Sql_TEXT = 'SUM UP THE COUNT AND INSERT RO157_Y1 LINE 21';
     SET @Ls_Sqldata_TEXT = 'BeginFiscal_DATE : ' + CAST(@Ld_Begin_DATE AS VARCHAR) + ' EndFiscal_DATE : ' + CAST(@Ld_End_DATE AS VARCHAR) + ' Line_NUMB : ' + @Lc_LineNo21_TEXT + ' TypeAsst_CODE : ' + @Lc_AsstTypeCurrent_CODE + ' TypeReport_CODE : ' + ISNULL(@Ac_TypeReport_CODE,'') + ' Line21_INDC : ' + @Lc_Yes_INDC + ' SupportYearMonth_NUMB : ' + CAST(@Ln_Yyyymm_NUMB AS VARCHAR);
   
     INSERT RO157_Y1
            (BeginFiscal_DATE,
             EndFiscal_DATE,
             TypeReport_CODE,
             Office_IDNO,
             County_IDNO,
             Worker_ID,
             LineNo_TEXT,
             Tot_QNTY,
             Ca_AMNT,
             Fa_AMNT,
             Na_AMNT)
     SELECT @Ld_Begin_DATE AS BeginFiscal_DATE,
            @Ld_End_DATE AS EndFiscal_DATE,
            a.TypeReport_CODE,
            a.Office_IDNO,
            a.County_IDNO,
            a.Worker_ID,
            @Lc_LineNo21_TEXT AS LineNo_TEXT,
            SUM(1) AS Tot_QNTY,
            0 AS Ca_AMNT,
            0 AS Fa_AMNT,
            0 AS Na_AMNT
       FROM RC157_Y1 a,
            RASST_Y1 b
      WHERE b.Case_IDNO = a.Case_IDNO
        AND a.Line21_INDC = @Lc_Yes_INDC
        AND b.SupportYearMonth_NUMB = @Ln_Yyyymm_NUMB
        AND a.BeginFiscal_DATE = @Ld_Begin_DATE
        AND a.EndFiscal_DATE = @Ld_End_DATE
        AND a.TypeReport_CODE = @Ac_TypeReport_CODE
      GROUP BY a.TypeReport_CODE,
               a.County_IDNO,
               a.Office_IDNO,
               a.Worker_ID;

     SET @Ln_RowCount_QNTY = @@ROWCOUNT;

     IF @Ln_RowCount_QNTY = 0
      BEGIN
       SET @Ls_Sql_TEXT = 'BATCH_RPT_OCSE157$SP_INSERT_LINE-LINENO-21';
	   SET @Ls_Sqldata_TEXT = 'BeginFiscal_DATE : ' + CAST(@Ld_Begin_DATE AS VARCHAR) + ' EndFiscal_DATE : ' + CAST(@Ld_End_DATE AS VARCHAR) + ' TypeReport_CODE : ' + ISNULL(@Ac_TypeReport_CODE,'') + ' Line_NUMB : ' + @Lc_LineNo21_TEXT;     
	   
       EXECUTE BATCH_RPT_OCSE157$SP_POPULATE_EMPTY_LINES
        @Ad_BeginFiscal_DATE        = @Ld_Begin_DATE,
        @Ad_EndFiscal_DATE          = @Ld_End_DATE,
        @Ac_TypeReport_CODE         = @Ac_TypeReport_CODE,
        @Ac_Line_NUMB               = @Lc_LineNo12_TEXT,
        @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT   = @Ls_ErrorMessage_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
        SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');
         RAISERROR (50001,16,1);
        END
      END

     SET @Ls_Sql_TEXT = 'SUM UP THE COUNT AND INSERT RO157_Y1 LINE 21A';
     SET @Ls_Sqldata_TEXT = 'BeginFiscal_DATE : ' + CAST(@Ld_Begin_DATE AS VARCHAR) + ' EndFiscal_DATE : ' + CAST(@Ld_End_DATE AS VARCHAR) + ' Line_NUMB : ' + @Lc_LineNo21a_TEXT + ' TypeAsst_CODE : ' + @Lc_AsstTypeCurrent_CODE + ' TypeReport_CODE : ' + ISNULL(@Ac_TypeReport_CODE,'') + ' Line21a_INDC : ' + @Lc_Yes_INDC + ' SupportYearMonth_NUMB : ' + CAST(@Ln_Yyyymm_NUMB AS VARCHAR);
   
     INSERT RO157_Y1
            (BeginFiscal_DATE,
             EndFiscal_DATE,
             TypeReport_CODE,
             Office_IDNO,
             County_IDNO,
             Worker_ID,
             LineNo_TEXT,
             Tot_QNTY,
             Ca_AMNT,
             Fa_AMNT,
             Na_AMNT)
     SELECT @Ld_Begin_DATE AS BeginFiscal_DATE,
            @Ld_End_DATE AS EndFiscal_DATE,
            a.TypeReport_CODE,
            a.Office_IDNO,
            a.County_IDNO,
            a.Worker_ID,
            @Lc_LineNo21a_TEXT AS LineNo_TEXT,
            SUM(1) AS Tot_QNTY,
            0 AS Ca_AMNT,
            0 AS Fa_AMNT,
            0 AS Na_AMNT
       FROM RC157_Y1 a,
            RASST_Y1 b
      WHERE b.Case_IDNO = a.Case_IDNO
        AND a.Line21a_INDC = @Lc_Yes_INDC
        AND b.SupportYearMonth_NUMB = @Ln_Yyyymm_NUMB
        AND a.BeginFiscal_DATE = @Ld_Begin_DATE
        AND a.EndFiscal_DATE = @Ld_End_DATE
        AND a.TypeReport_CODE = @Ac_TypeReport_CODE
      GROUP BY a.TypeReport_CODE,
               a.County_IDNO,
               a.Office_IDNO,
               a.Worker_ID;

     SET @Ln_RowCount_QNTY = @@ROWCOUNT;

     IF @Ln_RowCount_QNTY = 0
      BEGIN
       SET @Ls_Sql_TEXT = 'BATCH_RPT_OCSE157$SP_INSERT_LINE-LINENO-21A';
	   SET @Ls_Sqldata_TEXT = 'BeginFiscal_DATE : ' + CAST(@Ld_Begin_DATE AS VARCHAR) + ' EndFiscal_DATE : ' + CAST(@Ld_End_DATE AS VARCHAR) + ' TypeReport_CODE : ' + ISNULL(@Ac_TypeReport_CODE,'') + ' Line_NUMB : ' + @Lc_LineNo21a_TEXT;     
	   
       EXECUTE BATCH_RPT_OCSE157$SP_POPULATE_EMPTY_LINES
        @Ad_BeginFiscal_DATE        = @Ld_Begin_DATE,
        @Ad_EndFiscal_DATE          = @Ld_End_DATE,
        @Ac_TypeReport_CODE         = @Ac_TypeReport_CODE,
        @Ac_Line_NUMB               = @Lc_LineNo12_TEXT,
        @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT   = @Ls_ErrorMessage_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
        SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');
         RAISERROR (50001,16,1);
        END
      END

     SET @Ls_Sql_TEXT = 'SUM UP THE COUNT AND INSERT RO157_Y1 LINE 22';
     SET @Ls_Sqldata_TEXT = 'BeginFiscal_DATE : ' + CAST(@Ld_Begin_DATE AS VARCHAR) + ' EndFiscal_DATE : ' + CAST(@Ld_End_DATE AS VARCHAR) + ' Line_NUMB : ' + @Lc_LineNo22_TEXT + ' TypeAsst_CODE : ' + @Lc_AsstTypeCurrent_CODE + ' TypeReport_CODE : ' + ISNULL(@Ac_TypeReport_CODE,'') + ' Line22_INDC : ' + @Lc_Yes_INDC + ' SupportYearMonth_NUMB : ' + CAST(@Ln_Yyyymm_NUMB AS VARCHAR);
     
     INSERT RO157_Y1
            (BeginFiscal_DATE,
             EndFiscal_DATE,
             TypeReport_CODE,
             Office_IDNO,
             County_IDNO,
             Worker_ID,
             LineNo_TEXT,
             Tot_QNTY,
             Ca_AMNT,
             Fa_AMNT,
             Na_AMNT)
     SELECT @Ld_Begin_DATE AS BeginFiscal_DATE,
            @Ld_End_DATE AS EndFiscal_DATE,
            a.TypeReport_CODE,
            a.Office_IDNO,
            a.County_IDNO,
            a.Worker_ID,
            @Lc_LineNo22_TEXT AS LineNo_TEXT,
            SUM(1) AS Tot_QNTY,
            0 AS Ca_AMNT,
            0 AS Fa_AMNT,
            0 AS Na_AMNT
       FROM RC157_Y1 a,
            RASST_Y1 b
      WHERE b.Case_IDNO = a.Case_IDNO
        AND a.Line22_INDC = @Lc_Yes_INDC
        AND b.SupportYearMonth_NUMB = @Ln_Yyyymm_NUMB
        AND a.BeginFiscal_DATE = @Ld_Begin_DATE
        AND a.EndFiscal_DATE = @Ld_End_DATE
        AND a.TypeReport_CODE = @Ac_TypeReport_CODE
      GROUP BY a.TypeReport_CODE,
               a.County_IDNO,
               a.Office_IDNO,
               a.Worker_ID;

     SET @Ln_RowCount_QNTY = @@ROWCOUNT;

     IF @Ln_RowCount_QNTY = 0
      BEGIN
       SET @Ls_Sql_TEXT = 'BATCH_RPT_OCSE157$SP_INSERT_LINE-LINENO-22';
	   SET @Ls_Sqldata_TEXT = 'BeginFiscal_DATE : ' + CAST(@Ld_Begin_DATE AS VARCHAR) + ' EndFiscal_DATE : ' + CAST(@Ld_End_DATE AS VARCHAR) + ' TypeReport_CODE : ' + ISNULL(@Ac_TypeReport_CODE,'') + ' Line_NUMB : ' + @Lc_LineNo22_TEXT;     
	   
       EXECUTE BATCH_RPT_OCSE157$SP_POPULATE_EMPTY_LINES
        @Ad_BeginFiscal_DATE        = @Ld_Begin_DATE,
        @Ad_EndFiscal_DATE          = @Ld_End_DATE,
        @Ac_TypeReport_CODE         = @Ac_TypeReport_CODE,
        @Ac_Line_NUMB               = @Lc_LineNo12_TEXT,
        @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT   = @Ls_ErrorMessage_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
        SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');
         RAISERROR (50001,16,1);
        END
      END

     SET @Ls_Sql_TEXT = 'SUM UP THE COUNT AND INSERT RO157_Y1 LINE 23';
     SET @Ls_Sqldata_TEXT = 'BeginFiscal_DATE : ' + CAST(@Ld_Begin_DATE AS VARCHAR) + ' EndFiscal_DATE : ' + CAST(@Ld_End_DATE AS VARCHAR) + ' Line_NUMB : ' + @Lc_LineNo23_TEXT + ' TypeAsst_CODE : ' + @Lc_AsstTypeCurrent_CODE + ' TypeReport_CODE : ' + ISNULL(@Ac_TypeReport_CODE,'') + ' Line23_INDC : ' + @Lc_Yes_INDC + ' SupportYearMonth_NUMB : ' + CAST(@Ln_Yyyymm_NUMB AS VARCHAR);
   
     INSERT RO157_Y1
            (BeginFiscal_DATE,
             EndFiscal_DATE,
             TypeReport_CODE,
             Office_IDNO,
             County_IDNO,
             Worker_ID,
             LineNo_TEXT,
             Tot_QNTY,
             Ca_AMNT,
             Fa_AMNT,
             Na_AMNT)
     SELECT @Ld_Begin_DATE AS BeginFiscal_DATE,
            @Ld_End_DATE AS EndFiscal_DATE,
            a.TypeReport_CODE,
            a.Office_IDNO,
            a.County_IDNO,
            a.Worker_ID,
            @Lc_LineNo23_TEXT AS LineNo_TEXT,
            SUM(1) AS Tot_QNTY,
            0 AS Ca_AMNT,
            0 AS Fa_AMNT,
            0 AS Na_AMNT
       FROM RC157_Y1 a,
            RASST_Y1 b
      WHERE b.Case_IDNO = a.Case_IDNO
        AND a.Line23_INDC = @Lc_Yes_INDC
        AND b.SupportYearMonth_NUMB = @Ln_Yyyymm_NUMB
        AND a.BeginFiscal_DATE = @Ld_Begin_DATE
        AND a.EndFiscal_DATE = @Ld_End_DATE
        AND a.TypeReport_CODE = @Ac_TypeReport_CODE
      GROUP BY a.TypeReport_CODE,
               a.County_IDNO,
               a.Office_IDNO,
               a.Worker_ID;

     SET @Ln_RowCount_QNTY = @@ROWCOUNT;

     IF @Ln_RowCount_QNTY = 0
      BEGIN
       SET @Ls_Sql_TEXT = 'BATCH_RPT_OCSE157$SP_INSERT_LINE-LINENO-23';
	   SET @Ls_Sqldata_TEXT = 'BeginFiscal_DATE : ' + CAST(@Ld_Begin_DATE AS VARCHAR) + ' EndFiscal_DATE : ' + CAST(@Ld_End_DATE AS VARCHAR) + ' TypeReport_CODE : ' + ISNULL(@Ac_TypeReport_CODE,'') + ' Line_NUMB : ' + @Lc_LineNo23_TEXT;     

       EXECUTE BATCH_RPT_OCSE157$SP_POPULATE_EMPTY_LINES
        @Ad_BeginFiscal_DATE        = @Ld_Begin_DATE,
        @Ad_EndFiscal_DATE          = @Ld_End_DATE,
        @Ac_TypeReport_CODE         = @Ac_TypeReport_CODE,
        @Ac_Line_NUMB               = @Lc_LineNo12_TEXT,
        @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT   = @Ls_ErrorMessage_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
        SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');
         RAISERROR (50001,16,1);
        END
      END

     SET @Ls_Sql_TEXT = 'SUM UP THE COUNT AND INSERT RO157_Y1 LINE 24';
     SET @Ls_Sqldata_TEXT = 'BeginFiscal_DATE : ' + CAST(@Ld_Begin_DATE AS VARCHAR) + ' EndFiscal_DATE : ' + CAST(@Ld_End_DATE AS VARCHAR) + ' Line_NUMB : ' + @Lc_LineNo24_TEXT + ' TypeAsst_CODE : ' + @Lc_AsstTypeCurrent_CODE + ' TypeReport_CODE : ' + ISNULL(@Ac_TypeReport_CODE,'') + ' Line24_INDC : ' + @Lc_Yes_INDC + ' SupportYearMonth_NUMB : ' + CAST(@Ln_Yyyymm_NUMB AS VARCHAR);
   
     INSERT RO157_Y1
            (BeginFiscal_DATE,
             EndFiscal_DATE,
             TypeReport_CODE,
             Office_IDNO,
             County_IDNO,
             Worker_ID,
             LineNo_TEXT,
             Tot_QNTY,
             Ca_AMNT,
             Fa_AMNT,
             Na_AMNT)
     SELECT @Ld_Begin_DATE AS BeginFiscal_DATE,
            @Ld_End_DATE AS EndFiscal_DATE,
            @Ac_TypeReport_CODE AS TypeReport_CODE,
            a.Office_IDNO,
            a.County_IDNO,
            a.Worker_ID,
            @Lc_LineNo24_TEXT AS LineNo_TEXT,
            ISNULL(SUM(CASE b.TypeAsst_CODE
                        WHEN @Lc_AsstTypeCurrent_CODE
                         THEN a.Trans_AMNT
                        WHEN @Lc_AsstTypeFormer_CODE
                         THEN a.Trans_AMNT
                        WHEN @Lc_AsstTypeNever_CODE
                         THEN a.Trans_AMNT
                        ELSE 0
                       END), 0) AS Tot_QNTY,
            ISNULL(SUM(CASE b.TypeAsst_CODE
                        WHEN @Lc_AsstTypeCurrent_CODE
                         THEN a.Trans_AMNT
                        ELSE 0
                       END), 0) AS Ca_AMNT,
            ISNULL(SUM(CASE b.TypeAsst_CODE
                        WHEN @Lc_AsstTypeFormer_CODE
                         THEN a.Trans_AMNT
                        ELSE 0
                       END), 0) AS Fa_AMNT,
            ISNULL(SUM(CASE b.TypeAsst_CODE
                        WHEN @Lc_AsstTypeNever_CODE
                         THEN a.Trans_AMNT
                        ELSE 0
                       END), 0) AS Na_AMNT
       FROM R2426_Y1 a,
            RASST_Y1 b
      WHERE b.Case_IDNO = a.Case_IDNO
        AND a.Line_NUMB = @Lc_LineNo24_TEXT
        AND b.SupportYearMonth_NUMB = @Ln_Yyyymm_NUMB
        AND a.BeginFiscal_DATE = @Ld_Begin_DATE
        AND a.EndFiscal_DATE = @Ld_End_DATE
        AND a.TypeReport_CODE = @Ac_TypeReport_CODE
      GROUP BY a.County_IDNO,
               a.Office_IDNO,
               a.Worker_ID;

     SET @Ln_RowCount_QNTY = @@ROWCOUNT;

     IF @Ln_RowCount_QNTY = 0
      BEGIN
       SET @Ls_Sql_TEXT = 'BATCH_RPT_OCSE157$SP_INSERT_LINE-LINENO-24';
	   SET @Ls_Sqldata_TEXT = 'BeginFiscal_DATE : ' + CAST(@Ld_Begin_DATE AS VARCHAR) + ' EndFiscal_DATE : ' + CAST(@Ld_End_DATE AS VARCHAR) + ' TypeReport_CODE : ' + ISNULL(@Ac_TypeReport_CODE,'') + ' Line_NUMB : ' + @Lc_LineNo24_TEXT;     
       
       EXECUTE BATCH_RPT_OCSE157$SP_POPULATE_EMPTY_LINES
        @Ad_BeginFiscal_DATE        = @Ld_Begin_DATE,
        @Ad_EndFiscal_DATE          = @Ld_End_DATE,
        @Ac_TypeReport_CODE         = @Ac_TypeReport_CODE,
        @Ac_Line_NUMB               = @Lc_LineNo12_TEXT,
        @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT   = @Ls_ErrorMessage_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
        SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');
         RAISERROR (50001,16,1);
        END
      END

     SET @Ls_Sql_TEXT = 'SUM UP THE COUNT AND INSERT RO157_Y1 LINE 25';
     SET @Ls_Sqldata_TEXT = 'BeginFiscal_DATE : ' + CAST(@Ld_Begin_DATE AS VARCHAR) + ' EndFiscal_DATE : ' + CAST(@Ld_End_DATE AS VARCHAR) + ' Line_NUMB : ' + @Lc_LineNo25_TEXT + ' TypeAsst_CODE : ' + @Lc_AsstTypeCurrent_CODE + ' TypeReport_CODE : ' + ISNULL(@Ac_TypeReport_CODE,'') + ' Line25_INDC : ' + @Lc_Yes_INDC + ' SupportYearMonth_NUMB : ' + CAST(@Ln_Yyyymm_NUMB AS VARCHAR);
   
     INSERT RO157_Y1
            (BeginFiscal_DATE,
             EndFiscal_DATE,
             TypeReport_CODE,
             Office_IDNO,
             County_IDNO,
             Worker_ID,
             LineNo_TEXT,
             Tot_QNTY,
             Ca_AMNT,
             Fa_AMNT,
             Na_AMNT)
     SELECT @Ld_Begin_DATE AS BeginFiscal_DATE,
            @Ld_End_DATE AS EndFiscal_DATE,
            @Ac_TypeReport_CODE AS TypeReport_CODE,
            a.Office_IDNO,
            a.County_IDNO,
            a.Worker_ID,
            @Lc_LineNo25_Text AS LineNo_TEXT,
            ISNULL(SUM(CASE b.TypeAsst_CODE
                        WHEN @Lc_AsstTypeCurrent_CODE
                         THEN a.Trans_AMNT
                        WHEN @Lc_AsstTypeFormer_CODE
                         THEN a.Trans_AMNT
                        WHEN @Lc_AsstTypeNever_CODE
                         THEN a.Trans_AMNT
                        ELSE 0
                       END), 0) AS Tot_QNTY,
            ISNULL(SUM(CASE b.TypeAsst_CODE
                        WHEN @Lc_AsstTypeCurrent_CODE
                         THEN a.Trans_AMNT
                        ELSE 0
                       END), 0) AS Ca_AMNT,
            ISNULL(SUM(CASE b.TypeAsst_CODE
                        WHEN @Lc_AsstTypeFormer_CODE
                         THEN a.Trans_AMNT
                        ELSE 0
                       END), 0) AS Fa_AMNT,
            ISNULL(SUM(CASE b.TypeAsst_CODE
                        WHEN @Lc_AsstTypeNever_CODE
                         THEN a.Trans_AMNT
                        ELSE 0
                       END), 0) AS Na_AMNT
       FROM R2527_Y1 a,
            RASST_Y1 b
      WHERE b.Case_IDNO = a.Case_IDNO
        AND a.Line_NUMB = @Lc_LineNo25_Text
        AND b.SupportYearMonth_NUMB = @Ln_Yyyymm_NUMB
        AND a.BeginFiscal_DATE = @Ld_Begin_DATE
        AND a.EndFiscal_DATE = @Ld_End_DATE
        AND a.TypeReport_CODE = @Ac_TypeReport_CODE
      GROUP BY a.County_IDNO,
               a.Office_IDNO,
               a.Worker_ID;

     SET @Ln_RowCount_QNTY = @@ROWCOUNT;

     IF @Ln_RowCount_QNTY = 0
      BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_RPT_OCSE157$SP_INSERT_LINE-LINENO-25';
	 SET @Ls_Sqldata_TEXT = 'BeginFiscal_DATE : ' + CAST(@Ld_Begin_DATE AS VARCHAR) + ' EndFiscal_DATE : ' + CAST(@Ld_End_DATE AS VARCHAR) + ' TypeReport_CODE : ' + ISNULL(@Ac_TypeReport_CODE,'') + ' Line_NUMB : ' + @Lc_LineNo25_TEXT;     
	 
       EXECUTE BATCH_RPT_OCSE157$SP_POPULATE_EMPTY_LINES
        @Ad_BeginFiscal_DATE        = @Ld_Begin_DATE,
        @Ad_EndFiscal_DATE          = @Ld_End_DATE,
        @Ac_TypeReport_CODE         = @Ac_TypeReport_CODE,
        @Ac_Line_NUMB               = @Lc_LineNo12_TEXT,
        @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT   = @Ls_ErrorMessage_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
        SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');
         RAISERROR (50001,16,1);
        END
      END

     SET @Ls_Sql_TEXT = 'SUM UP THE COUNT AND INSERT RO157_Y1 LINE 26';
     SET @Ls_Sqldata_TEXT = 'BeginFiscal_DATE : ' + CAST(@Ld_Begin_DATE AS VARCHAR) + ' EndFiscal_DATE : ' + CAST(@Ld_End_DATE AS VARCHAR) + ' Line_NUMB : ' + @Lc_LineNo26_TEXT + ' TypeAsst_CODE : ' + @Lc_AsstTypeCurrent_CODE + ' TypeReport_CODE : ' + ISNULL(@Ac_TypeReport_CODE,'') + ' Line26_INDC : ' + @Lc_Yes_INDC + ' SupportYearMonth_NUMB : ' + CAST(@Ln_Yyyymm_NUMB AS VARCHAR);
   
     INSERT RO157_Y1
            (BeginFiscal_DATE,
             EndFiscal_DATE,
             TypeReport_CODE,
             Office_IDNO,
             County_IDNO,
             Worker_ID,
             LineNo_TEXT,
             Tot_QNTY,
             Ca_AMNT,
             Fa_AMNT,
             Na_AMNT)
     SELECT @Ld_Begin_DATE AS BeginFiscal_DATE,
            @Ld_End_DATE AS EndFiscal_DATE,
            @Ac_TypeReport_CODE AS TypeReport_CODE,
            a.Office_IDNO,
            a.County_IDNO,
            a.Worker_ID,
            @Lc_LineNo26_Text AS LineNo_TEXT,
            ISNULL(SUM(CASE b.TypeAsst_CODE
                        WHEN @Lc_AsstTypeCurrent_CODE
                         THEN a.Trans_AMNT
                        WHEN @Lc_AsstTypeFormer_CODE
                         THEN a.Trans_AMNT
                        WHEN @Lc_AsstTypeNever_CODE
                         THEN a.Trans_AMNT
                        ELSE 0
                       END), 0) AS Tot_QNTY,
            ISNULL(SUM(CASE b.TypeAsst_CODE
                        WHEN @Lc_AsstTypeCurrent_CODE
                         THEN a.Trans_AMNT
                        ELSE 0
                       END), 0) AS Ca_AMNT,
            ISNULL(SUM(CASE b.TypeAsst_CODE
                        WHEN @Lc_AsstTypeFormer_CODE
                         THEN a.Trans_AMNT
                        ELSE 0
                       END), 0) AS Fa_AMNT,
            ISNULL(SUM(CASE b.TypeAsst_CODE
                        WHEN @Lc_AsstTypeNever_CODE
                         THEN a.Trans_AMNT
                        ELSE 0
                       END), 0) AS Na_AMNT
       FROM R2426_Y1 a,
            RASST_Y1 b
      WHERE b.Case_IDNO = a.Case_IDNO
        AND a.Line_NUMB = @Lc_LineNo26_Text
        AND b.SupportYearMonth_NUMB = @Ln_Yyyymm_NUMB
        AND a.BeginFiscal_DATE = @Ld_Begin_DATE
        AND a.EndFiscal_DATE = @Ld_End_DATE
        AND a.TypeReport_CODE = @Ac_TypeReport_CODE
      GROUP BY a.County_IDNO,
               a.Office_IDNO,
               a.Worker_ID;

     SET @Ln_RowCount_QNTY = @@ROWCOUNT;

     IF @Ln_RowCount_QNTY = 0
      BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_RPT_OCSE157$SP_INSERT_LINE-LINENO-26';
	 SET @Ls_Sqldata_TEXT = 'BeginFiscal_DATE : ' + CAST(@Ld_Begin_DATE AS VARCHAR) + ' EndFiscal_DATE : ' + CAST(@Ld_End_DATE AS VARCHAR) + ' TypeReport_CODE : ' + ISNULL(@Ac_TypeReport_CODE,'') + ' Line_NUMB : ' + @Lc_LineNo26_TEXT;     
	 
       EXECUTE BATCH_RPT_OCSE157$SP_POPULATE_EMPTY_LINES
        @Ad_BeginFiscal_DATE        = @Ld_Begin_DATE,
        @Ad_EndFiscal_DATE          = @Ld_End_DATE,
        @Ac_TypeReport_CODE         = @Ac_TypeReport_CODE,
        @Ac_Line_NUMB               = @Lc_LineNo12_TEXT,
        @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT   = @Ls_ErrorMessage_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
        SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');
         RAISERROR (50001,16,1);
        END
      END

     SET @Ls_Sql_TEXT = 'SUM UP THE COUNT AND INSERT RO157_Y1 LINE 27';
     SET @Ls_Sqldata_TEXT = 'BeginFiscal_DATE : ' + CAST(@Ld_Begin_DATE AS VARCHAR) + ' EndFiscal_DATE : ' + CAST(@Ld_End_DATE AS VARCHAR) + ' Line_NUMB : ' + @Lc_LineNo27_TEXT + ' TypeAsst_CODE : ' + @Lc_AsstTypeCurrent_CODE + ' TypeReport_CODE : ' + ISNULL(@Ac_TypeReport_CODE,'') + ' Line27_INDC : ' + @Lc_Yes_INDC + ' SupportYearMonth_NUMB : ' + CAST(@Ln_Yyyymm_NUMB AS VARCHAR);
   
     INSERT RO157_Y1
            (BeginFiscal_DATE,
             EndFiscal_DATE,
             TypeReport_CODE,
             Office_IDNO,
             County_IDNO,
             Worker_ID,
             LineNo_TEXT,
             Tot_QNTY,
             Ca_AMNT,
             Fa_AMNT,
             Na_AMNT)
     SELECT @Ld_Begin_DATE AS BeginFiscal_DATE,
            @Ld_End_DATE AS EndFiscal_DATE,
            @Ac_TypeReport_CODE AS TypeReport_CODE,
            a.Office_IDNO,
            a.County_IDNO,
            a.Worker_ID,
            @Lc_LineNo27_TEXT AS LineNo_TEXT,
            ISNULL(SUM(CASE b.TypeAsst_CODE
                        WHEN @Lc_AsstTypeCurrent_CODE
                         THEN a.Trans_AMNT
                        WHEN @Lc_AsstTypeFormer_CODE
                         THEN a.Trans_AMNT
                        WHEN @Lc_AsstTypeNever_CODE
                         THEN a.Trans_AMNT
                        ELSE 0
                       END), 0) AS Tot_QNTY,
            ISNULL(SUM(CASE b.TypeAsst_CODE
                        WHEN @Lc_AsstTypeCurrent_CODE
                         THEN a.Trans_AMNT
                        ELSE 0
                       END), 0) AS Ca_AMNT,
            ISNULL(SUM(CASE b.TypeAsst_CODE
                        WHEN @Lc_AsstTypeFormer_CODE
                         THEN a.Trans_AMNT
                        ELSE 0
                       END), 0) AS Fa_AMNT,
            ISNULL(SUM(CASE b.TypeAsst_CODE
                        WHEN @Lc_AsstTypeNever_CODE
                         THEN a.Trans_AMNT
                        ELSE 0
                       END), 0) AS Na_AMNT
       FROM R2527_Y1 a,
            RASST_Y1 b
      WHERE b.Case_IDNO = a.Case_IDNO
        AND a.Line_NUMB = @Lc_LineNo27_TEXT
        AND b.SupportYearMonth_NUMB = @Ln_Yyyymm_NUMB
        AND a.BeginFiscal_DATE = @Ld_Begin_DATE
        AND a.EndFiscal_DATE = @Ld_End_DATE
        AND a.TypeReport_CODE = @Ac_TypeReport_CODE
      GROUP BY a.County_IDNO,
               a.Office_IDNO,
               a.Worker_ID;

     SET @Ln_RowCount_QNTY = @@ROWCOUNT;

     IF @Ln_RowCount_QNTY = 0
      BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_RPT_OCSE157$SP_INSERT_LINE-LINENO-27';
	 SET @Ls_Sqldata_TEXT = 'BeginFiscal_DATE : ' + CAST(@Ld_Begin_DATE AS VARCHAR) + ' EndFiscal_DATE : ' + CAST(@Ld_End_DATE AS VARCHAR) + ' TypeReport_CODE : ' + ISNULL(@Ac_TypeReport_CODE,'') + ' Line_NUMB : ' + @Lc_LineNo27_TEXT;     
	 
       EXECUTE BATCH_RPT_OCSE157$SP_POPULATE_EMPTY_LINES
        @Ad_BeginFiscal_DATE        = @Ld_Begin_DATE,
        @Ad_EndFiscal_DATE          = @Ld_End_DATE,
        @Ac_TypeReport_CODE         = @Ac_TypeReport_CODE,
        @Ac_Line_NUMB               = @Lc_LineNo12_TEXT,
        @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT   = @Ls_ErrorMessage_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
        SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');
         RAISERROR (50001,16,1);
        END
      END

     SET @Ls_Sql_TEXT = 'SUM UP THE COUNT AND INSERT RO157_Y1 LINE 28';
     SET @Ls_Sqldata_TEXT = 'BeginFiscal_DATE : ' + CAST(@Ld_Begin_DATE AS VARCHAR) + ' EndFiscal_DATE : ' + CAST(@Ld_End_DATE AS VARCHAR) + ' Line_NUMB : ' + @Lc_LineNo28_TEXT + ' TypeAsst_CODE : ' + @Lc_AsstTypeCurrent_CODE + ' TypeReport_CODE : ' + ISNULL(@Ac_TypeReport_CODE,'') + ' Line28_INDC : ' + @Lc_Yes_INDC + ' SupportYearMonth_NUMB : ' + CAST(@Ln_Yyyymm_NUMB AS VARCHAR);
   
     INSERT RO157_Y1
            (BeginFiscal_DATE,
             EndFiscal_DATE,
             TypeReport_CODE,
             Office_IDNO,
             County_IDNO,
             Worker_ID,
             LineNo_TEXT,
             Tot_QNTY,
             Ca_AMNT,
             Fa_AMNT,
             Na_AMNT)
     SELECT @Ld_Begin_DATE AS BeginFiscal_DATE,
            @Ld_End_DATE AS EndFiscal_DATE,
            a.TypeReport_CODE,
            a.Office_IDNO,
            a.County_IDNO,
            a.Worker_ID,
            @Lc_LineNo28_TEXT AS LineNo_TEXT,
            SUM(1) AS Tot_QNTY,
            0 AS Ca_AMNT,
            0 AS Fa_AMNT,
            0 AS Na_AMNT
       FROM RC157_Y1 a,
            RASST_Y1 b
      WHERE b.Case_IDNO = a.Case_IDNO
        AND a.Line28_INDC = @Lc_Yes_INDC
        AND b.SupportYearMonth_NUMB = @Ln_Yyyymm_NUMB
        AND a.BeginFiscal_DATE = @Ld_Begin_DATE
        AND a.EndFiscal_DATE = @Ld_End_DATE
        AND a.TypeReport_CODE = @Ac_TypeReport_CODE
      GROUP BY a.TypeReport_CODE,
               a.County_IDNO,
               a.Office_IDNO,
               a.Worker_ID;

     SET @Ln_RowCount_QNTY = @@ROWCOUNT;

     IF @Ln_RowCount_QNTY = 0
      BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_RPT_OCSE157$SP_INSERT_LINE-LINENO-28';
	 SET @Ls_Sqldata_TEXT = 'BeginFiscal_DATE : ' + CAST(@Ld_Begin_DATE AS VARCHAR) + ' EndFiscal_DATE : ' + CAST(@Ld_End_DATE AS VARCHAR) + ' TypeReport_CODE : ' + ISNULL(@Ac_TypeReport_CODE,'') + ' Line_NUMB : ' + @Lc_LineNo28_TEXT;     
	 
       EXECUTE BATCH_RPT_OCSE157$SP_POPULATE_EMPTY_LINES
        @Ad_BeginFiscal_DATE        = @Ld_Begin_DATE,
        @Ad_EndFiscal_DATE          = @Ld_End_DATE,
        @Ac_TypeReport_CODE         = @Ac_TypeReport_CODE,
        @Ac_Line_NUMB               = @Lc_LineNo12_TEXT,
        @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT   = @Ls_ErrorMessage_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
       BEGIN
       SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');
        RAISERROR (50001,16,1);
       END
     END
  
   SET @Ls_Sql_TEXT = 'SUM UP THE COUNT AND INSERT RO157_Y1 LINE 29';
   SET @Ls_Sqldata_TEXT = 'BeginFiscal_DATE : ' + CAST(@Ld_Begin_DATE AS VARCHAR) + ' EndFiscal_DATE : ' + CAST(@Ld_End_DATE AS VARCHAR) + ' Line_NUMB : ' + @Lc_LineNo29_TEXT + ' TypeAsst_CODE : ' + @Lc_AsstTypeCurrent_CODE + ' TypeReport_CODE : ' + ISNULL(@Ac_TypeReport_CODE,'') + ' Line29_INDC : ' + @Lc_Yes_INDC + ' SupportYearMonth_NUMB : ' + CAST(@Ln_Yyyymm_NUMB AS VARCHAR);
   
   INSERT RO157_Y1
          (BeginFiscal_DATE,
           EndFiscal_DATE,
           TypeReport_CODE,
           Office_IDNO,
           County_IDNO,
           Worker_ID,
           LineNo_TEXT,
           Tot_QNTY,
           Ca_AMNT,
           Fa_AMNT,
           Na_AMNT)
   SELECT @Ld_Begin_DATE AS BeginFiscal_DATE,
          @Ld_End_DATE AS EndFiscal_DATE,
          a.TypeReport_CODE,
          a.Office_IDNO,
          a.County_IDNO,
          a.Worker_ID,
          @Lc_LineNo29_TEXT AS LineNo_TEXT,
          SUM(1) AS Tot_QNTY,
          0 AS Ca_AMNT,
          0 AS Fa_AMNT,
          0 AS Na_AMNT
     FROM RC157_Y1 a,
          RASST_Y1 b
    WHERE b.Case_IDNO = a.Case_IDNO
      AND a.Line29_INDC = @Lc_Yes_INDC
      AND b.SupportYearMonth_NUMB = @Ln_Yyyymm_NUMB
      AND a.BeginFiscal_DATE = @Ld_Begin_DATE
      AND a.EndFiscal_DATE = @Ld_End_DATE
      AND a.TypeReport_CODE = @Ac_TypeReport_CODE
    GROUP BY a.TypeReport_CODE,
             a.County_IDNO,
             a.Office_IDNO,
             a.Worker_ID;

   SET @Ln_RowCount_QNTY = @@ROWCOUNT;

   IF @Ln_RowCount_QNTY = 0
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_RPT_OCSE157$SP_INSERT_LINE-LINENO-29';
	 SET @Ls_Sqldata_TEXT = 'BeginFiscal_DATE : ' + CAST(@Ld_Begin_DATE AS VARCHAR) + ' EndFiscal_DATE : ' + CAST(@Ld_End_DATE AS VARCHAR) + ' TypeReport_CODE : ' + ISNULL(@Ac_TypeReport_CODE,'') + ' Line_NUMB : ' + @Lc_LineNo29_TEXT;     
     
     EXECUTE BATCH_RPT_OCSE157$SP_POPULATE_EMPTY_LINES
      @Ad_BeginFiscal_DATE = @Ld_Begin_DATE,
      @Ad_EndFiscal_DATE   = @Ld_End_DATE,
      @Ac_TypeReport_CODE  = @Ac_TypeReport_CODE,
      @Ac_Line_NUMB        = @Lc_LineNo29_TEXT,
      @Ac_Msg_CODE         = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT       = @Ls_ErrorMessage_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
      SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');
       RAISERROR (50001,16,1);
      END
    END

   SET @Ls_Sql_TEXT = 'SUM UP THE COUNT AND INSERT RO157_Y1 LINE 33';
   SET @Ls_Sqldata_TEXT = 'BeginFiscal_DATE : ' + CAST(@Ld_Begin_DATE AS VARCHAR) + ' EndFiscal_DATE : ' + CAST(@Ld_End_DATE AS VARCHAR) + ' Line_NUMB : ' + @Lc_LineNo33_TEXT + ' TypeAsst_CODE : ' + @Lc_AsstTypeCurrent_CODE + ' TypeReport_CODE : ' + ISNULL(@Ac_TypeReport_CODE,'') + ' Line33_INDC : ' + @Lc_Yes_INDC + ' SupportYearMonth_NUMB : ' + CAST(@Ln_Yyyymm_NUMB AS VARCHAR);
   
   INSERT RO157_Y1
          (BeginFiscal_DATE,
           EndFiscal_DATE,
           TypeReport_CODE,
           Office_IDNO,
           County_IDNO,
           Worker_ID,
           LineNo_TEXT,
           Tot_QNTY,
           Ca_AMNT,
           Fa_AMNT,
           Na_AMNT)
   SELECT @Ld_Begin_DATE AS BeginFiscal_DATE,
          @Ld_End_DATE AS EndFiscal_DATE,
          a.TypeReport_CODE,
          a.Office_IDNO,
          a.County_IDNO,
          a.Worker_ID,
          @Lc_LineNo33_TEXT AS LineNo_TEXT,
          SUM(1) AS Tot_QNTY,
          0 AS Ca_AMNT,
          0 AS Fa_AMNT,
          0 AS Na_AMNT
     FROM RD157_Y1 a,
          RASST_Y1 b
    WHERE b.Case_IDNO = a.Case_IDNO
      AND a.Line33_INDC = @Lc_Yes_INDC
      AND b.SupportYearMonth_NUMB = @Ln_Yyyymm_NUMB
      AND a.BeginFiscal_DATE = @Ld_Begin_DATE
      AND a.EndFiscal_DATE = @Ld_End_DATE
      AND a.TypeReport_CODE = @Ac_TypeReport_CODE
    GROUP BY a.TypeReport_CODE,
             a.County_IDNO,
             a.Office_IDNO,
             a.Worker_ID;

   SET @Ln_RowCount_QNTY = @@ROWCOUNT;

   IF @Ln_RowCount_QNTY = 0
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_RPT_OCSE157$SP_INSERT_LINE-LINENO-33';
	 SET @Ls_Sqldata_TEXT = 'BeginFiscal_DATE : ' + CAST(@Ld_Begin_DATE AS VARCHAR) + ' EndFiscal_DATE : ' + CAST(@Ld_End_DATE AS VARCHAR) + ' TypeReport_CODE : ' + ISNULL(@Ac_TypeReport_CODE,'') + ' Line_NUMB : ' + @Lc_LineNo33_TEXT;     
	 
     EXECUTE BATCH_RPT_OCSE157$SP_POPULATE_EMPTY_LINES
        @Ad_BeginFiscal_DATE        = @Ld_Begin_DATE,
        @Ad_EndFiscal_DATE          = @Ld_End_DATE,
        @Ac_TypeReport_CODE         = @Ac_TypeReport_CODE,
        @Ac_Line_NUMB               = @Lc_LineNo12_TEXT,
        @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT   = @Ls_ErrorMessage_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
      SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');
       RAISERROR (50001,16,1);
      END
    END

   SET @Ls_Sql_TEXT = 'SUM UP THE COUNT AND INSERT RO157_Y1 LINE 34';
   SET @Ls_Sqldata_TEXT = 'BeginFiscal_DATE : ' + CAST(@Ld_Begin_DATE AS VARCHAR) + ' EndFiscal_DATE : ' + CAST(@Ld_End_DATE AS VARCHAR) + ' Line_NUMB : ' + @Lc_LineNo34_TEXT + ' TypeAsst_CODE : ' + @Lc_AsstTypeCurrent_CODE + ' TypeReport_CODE : ' + ISNULL(@Ac_TypeReport_CODE,'') + ' Line34_INDC : ' + @Lc_Yes_INDC + ' SupportYearMonth_NUMB : ' + CAST(@Ln_Yyyymm_NUMB AS VARCHAR);
   
   INSERT RO157_Y1
          (BeginFiscal_DATE,
           EndFiscal_DATE,
           TypeReport_CODE,
           Office_IDNO,
           County_IDNO,
           Worker_ID,
           LineNo_TEXT,
           Tot_QNTY,
           Ca_AMNT,
           Fa_AMNT,
           Na_AMNT)
   SELECT @Ld_Begin_DATE AS BeginFiscal_DATE,
          @Ld_End_DATE AS EndFiscal_DATE,
          a.TypeReport_CODE,
          a.Office_IDNO,
          a.County_IDNO,
          a.Worker_ID,
          @Lc_LineNo34_TEXT AS LineNo_TEXT,
          SUM(1) AS Tot_QNTY,
          0 AS Ca_AMNT,
          0 AS Fa_AMNT,
          0 AS Na_AMNT
     FROM RD157_Y1 a,
          RASST_Y1 b
    WHERE b.Case_IDNO = a.Case_IDNO
      AND a.Line34_INDC = @Lc_Yes_INDC
      AND b.SupportYearMonth_NUMB = @Ln_Yyyymm_NUMB
      AND a.BeginFiscal_DATE = @Ld_Begin_DATE
      AND a.EndFiscal_DATE = @Ld_End_DATE
      AND a.TypeReport_CODE = @Ac_TypeReport_CODE
    GROUP BY a.TypeReport_CODE,
             a.County_IDNO,
             a.Office_IDNO,
             a.Worker_ID;

   SET @Ln_RowCount_QNTY = @@ROWCOUNT;

   IF @Ln_RowCount_QNTY = 0
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_RPT_OCSE157$SP_INSERT_LINE-LINENO-34';
	 SET @Ls_Sqldata_TEXT = 'BeginFiscal_DATE : ' + CAST(@Ld_Begin_DATE AS VARCHAR) + ' EndFiscal_DATE : ' + CAST(@Ld_End_DATE AS VARCHAR) + ' TypeReport_CODE : ' + ISNULL(@Ac_TypeReport_CODE,'') + ' Line_NUMB : ' + @Lc_LineNo34_TEXT;     
	 
     EXECUTE BATCH_RPT_OCSE157$SP_POPULATE_EMPTY_LINES
        @Ad_BeginFiscal_DATE        = @Ld_Begin_DATE,
        @Ad_EndFiscal_DATE          = @Ld_End_DATE,
        @Ac_TypeReport_CODE         = @Ac_TypeReport_CODE,
        @Ac_Line_NUMB               = @Lc_LineNo12_TEXT,
        @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT   = @Ls_ErrorMessage_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
      SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');
       RAISERROR (50001,16,1);
      END
    END

   SET @Ls_Sql_TEXT = 'SUM UP THE COUNT AND INSERT RO157_Y1 LINE 35';
   SET @Ls_Sqldata_TEXT = 'BeginFiscal_DATE : ' + CAST(@Ld_Begin_DATE AS VARCHAR) + ' EndFiscal_DATE : ' + CAST(@Ld_End_DATE AS VARCHAR) + ' Line_NUMB : ' + @Lc_LineNo35_TEXT + ' TypeAsst_CODE : ' + @Lc_AsstTypeCurrent_CODE + ' TypeReport_CODE : ' + ISNULL(@Ac_TypeReport_CODE,'') + ' Line35_INDC : ' + @Lc_Yes_INDC + ' SupportYearMonth_NUMB : ' + CAST(@Ln_Yyyymm_NUMB AS VARCHAR);
   
   INSERT RO157_Y1
          (BeginFiscal_DATE,
           EndFiscal_DATE,
           TypeReport_CODE,
           Office_IDNO,
           County_IDNO,
           Worker_ID,
           LineNo_TEXT,
           Tot_QNTY,
           Ca_AMNT,
           Fa_AMNT,
           Na_AMNT)
   SELECT @Ld_Begin_DATE AS BeginFiscal_DATE,
          @Ld_End_DATE AS EndFiscal_DATE,
          a.TypeReport_CODE,
          a.Office_IDNO,
          a.County_IDNO,
          a.Worker_ID,
          @Lc_LineNo35_TEXT AS LineNo_TEXT,
          SUM(1) AS Tot_QNTY,
          0 AS Ca_AMNT,
          0 AS Fa_AMNT,
          0 AS Na_AMNT
     FROM RC157_Y1 a,
          RASST_Y1 b
    WHERE b.Case_IDNO = a.Case_IDNO
      AND a.Line35_INDC = @Lc_Yes_INDC
      AND b.SupportYearMonth_NUMB = @Ln_Yyyymm_NUMB
      AND a.BeginFiscal_DATE = @Ld_Begin_DATE
      AND a.EndFiscal_DATE = @Ld_End_DATE
      AND a.TypeReport_CODE = @Ac_TypeReport_CODE
    GROUP BY a.TypeReport_CODE,
             a.County_IDNO,
             a.Office_IDNO,
             a.Worker_ID;

   SET @Ln_RowCount_QNTY = @@ROWCOUNT;

   IF @Ln_RowCount_QNTY = 0
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_RPT_OCSE157$SP_INSERT_LINE-LINENO-35';
	 SET @Ls_Sqldata_TEXT = 'BeginFiscal_DATE : ' + CAST(@Ld_Begin_DATE AS VARCHAR) + ' EndFiscal_DATE : ' + CAST(@Ld_End_DATE AS VARCHAR) + ' TypeReport_CODE : ' + ISNULL(@Ac_TypeReport_CODE,'') + ' Line_NUMB : ' + @Lc_LineNo35_TEXT;     

     EXECUTE BATCH_RPT_OCSE157$SP_POPULATE_EMPTY_LINES
        @Ad_BeginFiscal_DATE        = @Ld_Begin_DATE,
        @Ad_EndFiscal_DATE          = @Ld_End_DATE,
        @Ac_TypeReport_CODE         = @Ac_TypeReport_CODE,
        @Ac_Line_NUMB               = @Lc_LineNo12_TEXT,
        @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT   = @Ls_ErrorMessage_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
      SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');
       RAISERROR (50001,16,1);
      END
    END

   SET @Ls_Sql_TEXT = 'SUM UP THE COUNT AND INSERT RO157_Y1 LINE 36';
   SET @Ls_Sqldata_TEXT = 'BeginFiscal_DATE : ' + CAST(@Ld_Begin_DATE AS VARCHAR) + ' EndFiscal_DATE : ' + CAST(@Ld_End_DATE AS VARCHAR) + ' Line_NUMB : ' + @Lc_LineNo36_TEXT + ' TypeAsst_CODE : ' + @Lc_AsstTypeCurrent_CODE + ' TypeReport_CODE : ' + ISNULL(@Ac_TypeReport_CODE,'') + ' Line36_INDC : ' + @Lc_Yes_INDC + ' SupportYearMonth_NUMB : ' + CAST(@Ln_Yyyymm_NUMB AS VARCHAR);
   
   INSERT RO157_Y1
          (BeginFiscal_DATE,
           EndFiscal_DATE,
           TypeReport_CODE,
           Office_IDNO,
           County_IDNO,
           Worker_ID,
           LineNo_TEXT,
           Tot_QNTY,
           Ca_AMNT,
           Fa_AMNT,
           Na_AMNT)
   SELECT @Ld_Begin_DATE AS BeginFiscal_DATE,
          @Ld_End_DATE AS EndFiscal_DATE,
          @Ac_TypeReport_CODE AS TypeReport_CODE,
          a.Office_IDNO,
          a.County_IDNO,
          a.Worker_ID,
          @Lc_LineNo36_Text AS LineNo_TEXT,
          ISNULL(SUM(CASE b.TypeAsst_CODE
                      WHEN @Lc_AsstTypeCurrent_CODE
                       THEN a.Trans_AMNT
                      WHEN @Lc_AsstTypeFormer_CODE
                       THEN a.Trans_AMNT
                      WHEN @Lc_AsstTypeNever_CODE
                       THEN a.Trans_AMNT
                      ELSE 0
                     END), 0) AS Tot_QNTY,
          ISNULL(SUM(CASE b.TypeAsst_CODE
                      WHEN @Lc_AsstTypeCurrent_CODE
                       THEN a.Trans_AMNT
                      ELSE 0
                     END), 0) AS Ca_AMNT,
          ISNULL(SUM(CASE b.TypeAsst_CODE
                      WHEN @Lc_AsstTypeFormer_CODE
                       THEN a.Trans_AMNT
                      ELSE 0
                     END), 0) AS Fa_AMNT,
          ISNULL(SUM(CASE b.TypeAsst_CODE
                      WHEN @Lc_AsstTypeNever_CODE
                       THEN a.Trans_AMNT
                      ELSE 0
                     END), 0) AS Na_AMNT
     FROM R2527_Y1 a,
          RASST_Y1 b
    WHERE b.Case_IDNO = a.Case_IDNO
      AND a.Line_NUMB = @Lc_LineNo36_Text
      AND b.SupportYearMonth_NUMB = @Ln_Yyyymm_NUMB
      AND a.BeginFiscal_DATE = @Ld_Begin_DATE
      AND a.EndFiscal_DATE = @Ld_End_DATE
      AND a.TypeReport_CODE = @Ac_TypeReport_CODE
    GROUP BY a.County_IDNO,
             a.Office_IDNO,
             a.Worker_ID;

   SET @Ln_RowCount_QNTY = @@ROWCOUNT;

   IF @Ln_RowCount_QNTY = 0
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_RPT_OCSE157$SP_INSERT_LINE-LINENO-36';
	 SET @Ls_Sqldata_TEXT = 'BeginFiscal_DATE : ' + CAST(@Ld_Begin_DATE AS VARCHAR) + ' EndFiscal_DATE : ' + CAST(@Ld_End_DATE AS VARCHAR) + ' TypeReport_CODE : ' + ISNULL(@Ac_TypeReport_CODE,'') + ' Line_NUMB : ' + @Lc_LineNo36_TEXT;
	 
     EXECUTE BATCH_RPT_OCSE157$SP_POPULATE_EMPTY_LINES
        @Ad_BeginFiscal_DATE        = @Ld_Begin_DATE,
        @Ad_EndFiscal_DATE          = @Ld_End_DATE,
        @Ac_TypeReport_CODE         = @Ac_TypeReport_CODE,
        @Ac_Line_NUMB               = @Lc_LineNo12_TEXT,
        @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT   = @Ls_ErrorMessage_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
      SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');
       RAISERROR (50001,16,1);
      END
    END

   SET @Ls_Sql_TEXT = 'SUM UP THE COUNT AND INSERT RO157_Y1 LINE 37';
   SET @Ls_Sqldata_TEXT = 'BeginFiscal_DATE : ' + CAST(@Ld_Begin_DATE AS VARCHAR) + ' EndFiscal_DATE : ' + CAST(@Ld_End_DATE AS VARCHAR) + ' Line_NUMB : ' + @Lc_LineNo37_TEXT + ' TypeAsst_CODE : ' + @Lc_AsstTypeCurrent_CODE + ' TypeReport_CODE : ' + ISNULL(@Ac_TypeReport_CODE,'') + ' Line37_INDC : ' + @Lc_Yes_INDC + ' SupportYearMonth_NUMB : ' + CAST(@Ln_Yyyymm_NUMB AS VARCHAR);
   
   INSERT RO157_Y1
          (BeginFiscal_DATE,
           EndFiscal_DATE,
           TypeReport_CODE,
           Office_IDNO,
           County_IDNO,
           Worker_ID,
           LineNo_TEXT,
           Tot_QNTY,
           Ca_AMNT,
           Fa_AMNT,
           Na_AMNT)
   SELECT @Ld_Begin_DATE AS BeginFiscal_DATE,
          @Ld_End_DATE AS EndFiscal_DATE,
          a.TypeReport_CODE,
          a.Office_IDNO,
          a.County_IDNO,
          a.Worker_ID,
          @Lc_LineNo37_TEXT AS LineNo_TEXT,
          ISNULL(SUM(CASE b.TypeAsst_CODE
                      WHEN @Lc_AsstTypeCurrent_CODE
                       THEN 1
                      ELSE 0
                     END), 0) AS Tot_QNTY,
          ISNULL(SUM(CASE b.TypeAsst_CODE
                      WHEN @Lc_AsstTypeCurrent_CODE
                       THEN 1
                      ELSE 0
                     END), 0) AS Ca_AMNT,
          0 AS Fa_AMNT,
          0 AS Na_AMNT
     FROM RC157_Y1 a,
          RASST_Y1 b
    WHERE b.Case_IDNO = a.Case_IDNO
      AND a.Line37_INDC = @Lc_Yes_INDC
      AND b.SupportYearMonth_NUMB = @Ln_Yyyymm_NUMB
      AND a.BeginFiscal_DATE = @Ld_Begin_DATE
      AND a.EndFiscal_DATE = @Ld_End_DATE
      AND a.TypeReport_CODE = @Ac_TypeReport_CODE
    GROUP BY a.TypeReport_CODE,
             a.County_IDNO,
             a.Office_IDNO,
             a.Worker_ID;

   SET @Ln_RowCount_QNTY = @@ROWCOUNT;

   IF @Ln_RowCount_QNTY = 0
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_RPT_OCSE157$SP_INSERT_LINE-LINENO-37';
	 SET @Ls_Sqldata_TEXT = 'BeginFiscal_DATE : ' + CAST(@Ld_Begin_DATE AS VARCHAR) + ' EndFiscal_DATE : ' + CAST(@Ld_End_DATE AS VARCHAR) + ' TypeReport_CODE : ' + ISNULL(@Ac_TypeReport_CODE,'') + ' Line_NUMB : ' + @Lc_LineNo37_TEXT;
	 
     EXECUTE BATCH_RPT_OCSE157$SP_POPULATE_EMPTY_LINES
        @Ad_BeginFiscal_DATE        = @Ld_Begin_DATE,
        @Ad_EndFiscal_DATE          = @Ld_End_DATE,
        @Ac_TypeReport_CODE         = @Ac_TypeReport_CODE,
        @Ac_Line_NUMB               = @Lc_LineNo12_TEXT,
        @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT   = @Ls_ErrorMessage_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
      SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');
       RAISERROR (50001,16,1);
      END
    END

   SET @Ls_Sql_TEXT = 'SUM UP THE COUNT AND INSERT RO157_Y1 LINE 38';
   SET @Ls_Sqldata_TEXT = 'BeginFiscal_DATE : ' + CAST(@Ld_Begin_DATE AS VARCHAR) + ' EndFiscal_DATE : ' + CAST(@Ld_End_DATE AS VARCHAR) + ' Line_NUMB : ' + @Lc_LineNo38_TEXT + ' TypeAsst_CODE : ' + @Lc_AsstTypeCurrent_CODE + ' TypeReport_CODE : ' + ISNULL(@Ac_TypeReport_CODE,'') + ' Line38_INDC : ' + @Lc_Yes_INDC + ' SupportYearMonth_NUMB : ' + CAST(@Ln_Yyyymm_NUMB AS VARCHAR);
   
   INSERT RO157_Y1
          (BeginFiscal_DATE,
           EndFiscal_DATE,
           TypeReport_CODE,
           Office_IDNO,
           County_IDNO,
           Worker_ID,
           LineNo_TEXT,
           Tot_QNTY,
           Ca_AMNT,
           Fa_AMNT,
           Na_AMNT)
   SELECT @Ld_Begin_DATE AS BeginFiscal_DATE,
          @Ld_End_DATE AS EndFiscal_DATE,
          a.TypeReport_CODE,
          a.Office_IDNO,
          a.County_IDNO,
          a.Worker_ID,
          @Lc_LineNo38_TEXT AS LineNo_TEXT,
          ISNULL(SUM(CASE b.TypeAsst_CODE
                      WHEN @Lc_AsstTypeCurrent_CODE
                       THEN 1
                      ELSE 0
                     END), 0) AS Tot_QNTY,
          ISNULL(SUM(CASE b.TypeAsst_CODE
                      WHEN @Lc_AsstTypeCurrent_CODE
                       THEN 1
                      ELSE 0
                     END), 0) AS Ca_AMNT,
          0 AS Fa_AMNT,
          0 AS Na_AMNT
     FROM RC157_Y1 a,
          RASST_Y1 b
    WHERE b.Case_IDNO = a.Case_IDNO
      AND a.Line38_INDC = @Lc_Yes_INDC
      AND b.SupportYearMonth_NUMB = @Ln_Yyyymm_NUMB
      AND a.BeginFiscal_DATE = @Ld_Begin_DATE
      AND a.EndFiscal_DATE = @Ld_End_DATE
      AND a.TypeReport_CODE = @Ac_TypeReport_CODE
    GROUP BY a.TypeReport_CODE,
             a.County_IDNO,
             a.Office_IDNO,
             a.Worker_ID;

   SET @Ln_RowCount_QNTY = @@ROWCOUNT;

   IF @Ln_RowCount_QNTY = 0
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_RPT_OCSE157$SP_INSERT_LINE-LINENO-38';
     SET @Ls_Sqldata_TEXT = 'BeginFiscal_DATE : ' + CAST(@Ld_Begin_DATE AS VARCHAR) + ' EndFiscal_DATE : ' + CAST(@Ld_End_DATE AS VARCHAR) + ' TypeReport_CODE : ' + ISNULL(@Ac_TypeReport_CODE,'') + ' Line_NUMB : ' + @Lc_LineNo38_TEXT;
     
     EXECUTE BATCH_RPT_OCSE157$SP_POPULATE_EMPTY_LINES
        @Ad_BeginFiscal_DATE        = @Ld_Begin_DATE,
        @Ad_EndFiscal_DATE          = @Ld_End_DATE,
        @Ac_TypeReport_CODE         = @Ac_TypeReport_CODE,
        @Ac_Line_NUMB               = @Lc_LineNo12_TEXT,
        @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT   = @Ls_ErrorMessage_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
      SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');
       RAISERROR (50001,16,1);
      END
    END

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATCH_RESTART_UPDATE-9';
   SET @Ls_Sqldata_TEXT = 'Job_ID : ' + ISNULL(@Ac_Job_ID, '') + ' Run_DATE : ' + CAST( @Ad_Run_DATE AS VARCHAR) + ' LOCATION : ' + ISNULL(@Lc_RestartLoc9_TEXT, '');

   EXECUTE BATCH_COMMON$SP_BATCH_RESTART_UPDATE
    @Ac_Job_ID                = @Ac_Job_ID,
     @Ad_Run_DATE              =  @Ad_Run_DATE,
    @As_RestartKey_TEXT       = @Lc_RestartLoc9_TEXT,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
    SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');
     RAISERROR (50001,16,1);
    END

   SET @Lc_RestartLoc_TEXT = @Lc_Space_TEXT;

   IF @Ac_Job_ID = @Lc_JobDetail_IDNO
    BEGIN
     SET @Lc_Routine_TEXT = @Ls_RoutineDetail_TEXT;
    END
   ELSE
    BEGIN
     SET @Lc_Routine_TEXT = @Ls_RoutineMonthly_TEXT;
    END

   SET @Ls_Sql_TEXT = 'BATCH_RPT_OCSE157$SP_VALIDATE';
   SET @Ls_Sqldata_TEXT = 'BeginFiscal_DATE : ' + CAST(@Ld_Begin_DATE AS VARCHAR) + ' EndFiscal_DATE : ' + CAST(@Ld_End_DATE AS VARCHAR) + ' TypeReport_CODE : ' + ISNULL(@Ac_TypeReport_CODE,'') + ' Job_ID : ' + @Lc_JobDetail_IDNO + ' Procedure_NAME : ' + @Lc_Routine_TEXT + ' Run_DATE : ' + CAST( @Ad_Run_DATE AS VARCHAR) ;

   EXECUTE BATCH_RPT_OCSE157$SP_VALIDATE
    @Ad_BeginFiscal_DATE      = @Ld_Begin_DATE,
    @Ad_EndFiscal_DATE        = @Ld_End_DATE,
    @Ac_TypeReport_CODE       = @Ac_TypeReport_CODE,
    @Ac_Job_ID                = @Lc_JobDetail_IDNO,
    @As_Procedure_NAME        = @Lc_Routine_TEXT,
    @Ad_Run_DATE              = @Ad_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

    IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
    SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');
     RAISERROR (50001,16,1);
    END

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   DECLARE
		@Li_Error_NUMB INT = ERROR_NUMBER (),
		@Li_ErrorLine_NUMB INT = ERROR_LINE ();

   IF (@Li_Error_NUMB <> 50001)
   BEGIN
	 SET @Ls_ErrorMessage_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
   END;

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION @As_Procedure_NAME = @Ls_Procedure_NAME,
                                   @As_ErrorMessage_TEXT = @Ls_ErrorMessage_TEXT,
                                   @As_Sql_TEXT = @Ls_Sql_TEXT,
                                   @As_Sqldata_TEXT = @Ls_SqlData_TEXT,
                                   @An_Error_NUMB = @Li_Error_NUMB,
                                   @An_ErrorLine_NUMB = @Li_ErrorLine_NUMB,
                                   @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT ;

   SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
  END CATCH;
 END;


GO
