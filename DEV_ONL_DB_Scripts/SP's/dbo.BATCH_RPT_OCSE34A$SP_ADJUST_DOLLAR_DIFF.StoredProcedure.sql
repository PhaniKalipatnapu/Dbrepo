/****** Object:  StoredProcedure [dbo].[BATCH_RPT_OCSE34A$SP_ADJUST_DOLLAR_DIFF]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_RPT_OCSE34A$SP_ADJUST_DOLLAR_DIFF
Programmer Name 	: IMP Team
Description			: This procedure will be used to adjust the dollar difference
Frequency			: 'MONTHLY/QUATERLY'
Developed On		: 10/14/2011
Called BY			: None
Called On			: 
--------------------------------------------------------------------------------------------------------------------
Modified BY			:
Modified On			:
Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_RPT_OCSE34A$SP_ADJUST_DOLLAR_DIFF]
 @Ad_BeginQtr_DATE         DATE,
 @Ad_EndQtr_DATE           DATE,
 @Ac_TypeReport_CODE       CHAR(1),
 @Ad_PrevBeginQtr_DATE     DATE,
 @Ad_PrevEndQtr_DATE       DATE,
 @Ac_Msg_CODE              CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR (4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusFailed_CODE             CHAR (1) = 'F',
          @Lc_StatusSuccess_CODE            CHAR (1) = 'S',
		  @Lc_CheckRecipientEsch_IDNO       CHAR (10) = '999999962',
		  @Ls_Procedure_NAME				VARCHAR (100) = 'SP_ADJUST_DOLLAR_DIFF';
  DECLARE @Ln_Line9ab_AMNT					NUMERIC (11, 0),
          @Ln_Line9_AMNT					NUMERIC (11, 0),
          @Ln_Line9b_AMNT					NUMERIC (11, 0),
          @Ln_SecA1P2_AMNT					NUMERIC (11, 0),
          @Ln_SecB1P2_AMNT					NUMERIC (11, 0),
          @Ln_AdjLine_AMNT					NUMERIC (11, 2) = 0,
          @Ln_Error_NUMB					NUMERIC (11),
          @Ln_ErrorLine_NUMB				NUMERIC (11),
          @Li_RowCount_QNTY					SMALLINT,
          @Li_ColumnNumb_QNTY				SMALLINT,
          @Ls_ColumnName_TEXT				VARCHAR (70),          
          @Ls_Sql_TEXT						VARCHAR (1000),
          @Ls_ErrorMessage_TEXT				VARCHAR (1000),
          @Ls_Sqldata_TEXT					VARCHAR (4000);
  DECLARE @AdjustTable_P1 TABLE (
   Column_NAME VARCHAR(70),
   Adjust_AMNT NUMERIC(11, 2));
  DECLARE @LineTwoTable_P1 TABLE (
   Column_NUMB NUMERIC(19),
   Adjust_AMNT NUMERIC(11, 2));
  BEGIN TRY
   SET @Ac_Msg_CODE = '';
   SET @As_DescriptionError_TEXT = '';
   SET @Ls_Sql_TEXT = 'SELECT 9AB, SEC A - TOTAL, SEC B - TOTAL Value_AMNT';
   SET @Ls_Sqldata_TEXT = 'BeginQtr_DATE = ' + ISNULL(CAST(@Ad_BeginQtr_DATE AS VARCHAR), '') + ', EndQtr_DATE = ' + ISNULL (CAST(@Ad_EndQtr_DATE AS VARCHAR), '') + ', TypeReport_CODE = ' + @Ac_TypeReport_CODE;	
   SELECT @Ln_Line9ab_AMNT = (a.Line9a_AMNT + a.Line9b_AMNT),
          @Ln_Line9b_AMNT = a.Line9b_AMNT,
          @Ln_Line9_AMNT = (a.Line1_AMNT + a.Line2a_AMNT + a.Line2b_AMNT + a.Line2c_AMNT + a.Line2d_AMNT + a.Line2e_AMNT + a.Line2f_AMNT + a.Line2g_AMNT + a.Line2h_AMNT + a.Line3_AMNT) - (a.Line4a_AMNT + a.Line4ba_AMNT + a.Line4bb_AMNT + a.Line4bc_AMNT + a.Line4bd_AMNT + a.Line4be_AMNT + a.Line4bf_AMNT + a.Line4c_AMNT) - a.Line5_AMNT - (a.Line7aa_AMNT + a.Line7ac_AMNT + a.Line7ba_AMNT + a.Line7bb_AMNT + a.Line7bc_AMNT + a.Line7bd_AMNT + a.Line7ca_AMNT + a.Line7cb_AMNT + a.Line7cc_AMNT + a.Line7cd_AMNT + a.Line7ce_AMNT + a.Line7cf_AMNT + a.Line7da_AMNT + a.Line7db_AMNT + a.Line7dc_AMNT + a.Line7dd_AMNT + a.Line7de_AMNT + a.Line7df_AMNT + a.Line7ee_AMNT + a.Line7ef_AMNT),
          @Ln_SecA1P2_AMNT = (a.Line3P2_AMNT + a.Line4P2_AMNT + a.Line5P2_AMNT + a.Line6P2_AMNT + a.Line7P2_AMNT + a.Line9P2_AMNT + a.Line10P2_AMNT + a.Line11P2_AMNT + a.Line12P2_AMNT + a.Line13P2_AMNT),
          @Ln_SecB1P2_AMNT = (a.Line14P2_AMNT + a.Line15P2_AMNT + a.Line16P2_AMNT + a.Line17P2_AMNT + a.Line18P2_AMNT + a.Line19P2_AMNT + a.Line20P2_AMNT)
     FROM ROC34_Y1 a
    WHERE a.BeginQtr_DATE = @Ad_BeginQtr_DATE
      AND a.EndQtr_DATE = @Ad_EndQtr_DATE
      AND a.TypeReport_CODE = @Ac_TypeReport_CODE;

	
   SET @Ls_Sql_TEXT = 'SELECT 9AB, SEC A - TOTAL, SEC B - TOTAL Value_AMNT ,COMPARE LINE9 & LINE9AB';
   SET @Ls_Sqldata_TEXT = '';	
   IF(@Ln_Line9_AMNT <> @Ln_Line9ab_AMNT)
    BEGIN
    
     INSERT @AdjustTable_P1
            (Column_NAME,
            Adjust_AMNT)
     SELECT '7BA',
            SUM(a.LineNo7ba_AMNT)
       FROM R34RT_Y1 a
      WHERE a.BeginQtr_DATE = @Ad_BeginQtr_DATE
        AND a.EndQtr_DATE = @Ad_EndQtr_DATE
     UNION
     SELECT '7BB',
            SUM(a.LineNo7ba_AMNT)
       FROM R34RT_Y1 a
      WHERE a.BeginQtr_DATE = @Ad_BeginQtr_DATE
        AND a.EndQtr_DATE = @Ad_EndQtr_DATE
     UNION
     SELECT '7BC',
            SUM(a.LineNo7ba_AMNT)
       FROM R34RT_Y1 a
      WHERE a.BeginQtr_DATE = @Ad_BeginQtr_DATE
        AND a.EndQtr_DATE = @Ad_EndQtr_DATE
     UNION
     SELECT '7BD',
            SUM(a.LineNo7ba_AMNT)
       FROM R34RT_Y1 a
      WHERE a.BeginQtr_DATE = @Ad_BeginQtr_DATE
        AND a.EndQtr_DATE = @Ad_EndQtr_DATE
     UNION
     SELECT '7CA',
            SUM(a.LineNo7ba_AMNT)
       FROM R34RT_Y1 a
      WHERE a.BeginQtr_DATE = @Ad_BeginQtr_DATE
        AND a.EndQtr_DATE = @Ad_EndQtr_DATE
     UNION
     SELECT '7CB',
            SUM(a.LineNo7ba_AMNT)
       FROM R34RT_Y1 a
      WHERE a.BeginQtr_DATE = @Ad_BeginQtr_DATE
        AND a.EndQtr_DATE = @Ad_EndQtr_DATE
     UNION
     SELECT '7CC',
            SUM(a.LineNo7ba_AMNT)
       FROM R34RT_Y1 a
      WHERE a.BeginQtr_DATE = @Ad_BeginQtr_DATE
        AND a.EndQtr_DATE = @Ad_EndQtr_DATE
     UNION
     SELECT '7CD',
            SUM(a.LineNo7ba_AMNT)
       FROM R34RT_Y1 a
      WHERE a.BeginQtr_DATE = @Ad_BeginQtr_DATE
        AND a.EndQtr_DATE = @Ad_EndQtr_DATE
     UNION
     SELECT '7CE',
            SUM(a.LineNo7ba_AMNT)
       FROM R34RT_Y1 a
      WHERE a.BeginQtr_DATE = @Ad_BeginQtr_DATE
        AND a.EndQtr_DATE = @Ad_EndQtr_DATE
     UNION
     SELECT '7CF',
            SUM(a.LineNo7ba_AMNT)
       FROM R34RT_Y1 a
      WHERE a.BeginQtr_DATE = @Ad_BeginQtr_DATE
        AND a.EndQtr_DATE = @Ad_EndQtr_DATE
     UNION
     SELECT '7DA',
            SUM(a.LineNo7ba_AMNT)
       FROM R34RT_Y1 a
      WHERE a.BeginQtr_DATE = @Ad_BeginQtr_DATE
        AND a.EndQtr_DATE = @Ad_EndQtr_DATE
     UNION
     SELECT '7DB',
            SUM(a.LineNo7ba_AMNT)
       FROM R34RT_Y1 a
      WHERE a.BeginQtr_DATE = @Ad_BeginQtr_DATE
        AND a.EndQtr_DATE = @Ad_EndQtr_DATE
     UNION
     SELECT '7DC',
            SUM(a.LineNo7ba_AMNT)
       FROM R34RT_Y1 a
      WHERE a.BeginQtr_DATE = @Ad_BeginQtr_DATE
        AND a.EndQtr_DATE = @Ad_EndQtr_DATE
     UNION
     SELECT '7DD',
            SUM(a.LineNo7ba_AMNT)
       FROM R34RT_Y1 a
      WHERE a.BeginQtr_DATE = @Ad_BeginQtr_DATE
        AND a.EndQtr_DATE = @Ad_EndQtr_DATE
     UNION
     SELECT '7DE',
            SUM(a.LineNo7ba_AMNT)
       FROM R34RT_Y1 a
      WHERE a.BeginQtr_DATE = @Ad_BeginQtr_DATE
        AND a.EndQtr_DATE = @Ad_EndQtr_DATE
     UNION
     SELECT '7DF',
            SUM(a.LineNo7ba_AMNT)
       FROM R34RT_Y1 a
      WHERE a.BeginQtr_DATE = @Ad_BeginQtr_DATE
        AND a.EndQtr_DATE = @Ad_EndQtr_DATE
     UNION
     SELECT '7EE',
            SUM(a.LineNo7ba_AMNT)
       FROM R34RT_Y1 a
      WHERE a.BeginQtr_DATE = @Ad_BeginQtr_DATE
        AND a.EndQtr_DATE = @Ad_EndQtr_DATE
     UNION
     SELECT '7EF',
            SUM(a.LineNo7ba_AMNT)
       FROM R34RT_Y1 a
      WHERE a.BeginQtr_DATE = @Ad_BeginQtr_DATE
        AND a.EndQtr_DATE = @Ad_EndQtr_DATE;
    
     SET @Ls_Sql_TEXT = 'Line9_AMNT < Line9ab_AMNT';
	 SET @Ls_Sqldata_TEXT = 'Line9_AMNT = ' + CAST(@Ln_Line9_AMNT AS VARCHAR) + ', Line9ab_AMNT = ' + CAST(@Ln_Line9ab_AMNT AS VARCHAR);
     IF @Ln_Line9_AMNT < @Ln_Line9ab_AMNT
      BEGIN
      
       -- Subtract 1 from lines 7b through 7e the amount which is Least Cent value among those with more than 50 cents
       WHILE ROUND(@Ln_Line9_AMNT, 0) < ROUND (@Ln_Line9ab_AMNT, 0)
        BEGIN
			
         SET @Ls_Sql_TEXT = 'SELECT @AdjustTable_P1-1';
		 SET @Ls_Sqldata_TEXT = '';
         SELECT @Ls_ColumnName_TEXT = Column_NAME,
                @Ln_AdjLine_AMNT = Adjust_AMNT
           FROM @AdjustTable_P1
          WHERE (Adjust_AMNT - FLOOR(Adjust_AMNT)) = ISNULL((SELECT MIN(Adjust_AMNT - FLOOR(Adjust_AMNT))
                                                        FROM @AdjustTable_P1
                                                       WHERE (Adjust_AMNT - FLOOR(Adjust_AMNT)) >= .50),0);

         SET @Li_RowCount_QNTY = @@ROWCOUNT;
         
         IF @Li_RowCount_QNTY = 0
          BEGIN
           SET @Ls_ColumnName_TEXT = '7BA';
           SELECT @Ln_AdjLine_AMNT = ISNULL(Adjust_AMNT,0) FROM  @AdjustTable_P1 WHERE Column_NAME = @Ls_ColumnName_TEXT;
          END

         SET @Ls_Sql_TEXT = 'UPDATE ROC34_Y1 SEC A LINE : ' + @Ls_ColumnName_TEXT + ' -1';
		 SET @Ls_Sqldata_TEXT = 'UPDATE ROC34_Y1 SET Line' + @Ls_ColumnName_TEXT + '_AMNT = ROUND(CAST('+ CAST(@Ln_AdjLine_AMNT AS VARCHAR) + ' AS NUMERIC(11,2)),0)-1 WHERE BeginQtr_DATE = ''' + CAST(@Ad_BeginQtr_DATE AS VARCHAR) + ''' AND EndQtr_DATE = '''+ CAST(@Ad_EndQtr_DATE AS VARCHAR) + ''' AND TypeReport_CODE = ''' + @Ac_TypeReport_CODE+'''';
		 
		 EXECUTE (@Ls_Sqldata_TEXT);
		 SET @Ls_Sql_TEXT = 'UPDATE @AdjustTable_P1 - 1';
		 SET @Ls_Sqldata_TEXT = 'Column_NAME = ' + @Ls_ColumnName_TEXT;
		 
         UPDATE @AdjustTable_P1
            SET Adjust_AMNT = Adjust_AMNT - 1
          WHERE Column_NAME = @Ls_ColumnName_TEXT;
		 
		 SET @Ls_Sql_TEXT = 'SELECT ROC34_Y1 - Line9_AMNT - 1';
		 SET @Ls_Sqldata_TEXT = 'BeginQtr_DATE = ' + ISNULL(CAST(@Ad_BeginQtr_DATE AS VARCHAR), '') + ', EndQtr_DATE = ' + ISNULL (CAST(@Ad_EndQtr_DATE AS VARCHAR), '') + ', TypeReport_CODE = ' + @Ac_TypeReport_CODE;
         SELECT @Ln_Line9_AMNT = ((a.Line1_AMNT + a.Line2a_AMNT + a.Line2b_AMNT + a.Line2c_AMNT + a.Line2d_AMNT + a.Line2e_AMNT + a.Line2f_AMNT + a.Line2h_AMNT + a.Line2g_AMNT + a.Line3_AMNT) - (a.Line4a_AMNT + a.Line4ba_AMNT + a.Line4bb_AMNT + a.Line4bc_AMNT + a.Line4bd_AMNT + a.Line4be_AMNT + a.Line4bf_AMNT + a.Line4c_AMNT) - a.Line5_AMNT - (a.Line7aa_AMNT + a.Line7ac_AMNT + a.Line7ba_AMNT + a.Line7bb_AMNT + a.Line7bc_AMNT + a.Line7bd_AMNT + a.Line7ca_AMNT + a.Line7cb_AMNT + a.Line7cc_AMNT + a.Line7cd_AMNT + a.Line7ce_AMNT + a.Line7cf_AMNT + a.Line7da_AMNT + a.Line7db_AMNT + a.Line7dc_AMNT + a.Line7dd_AMNT + a.Line7de_AMNT + a.Line7df_AMNT + a.Line7ee_AMNT + a.Line7ef_AMNT))
           FROM ROC34_Y1 a
          WHERE a.BeginQtr_DATE = @Ad_BeginQtr_DATE
            AND a.EndQtr_DATE = @Ad_EndQtr_DATE
            AND a.TypeReport_CODE = @Ac_TypeReport_CODE;
        END
      END

     IF(@Ln_Line9_AMNT > @Ln_Line9ab_AMNT)
      BEGIN
       SET @Ls_Sql_TEXT = 'WHILE Line9_AMNT > Line9ab_AMNT';
	   SET @Ls_Sqldata_TEXT = '';	
       -- Add 1 to lines 7b through 7e the amount which is Least Cent value among those with more than 50 cents
       WHILE ROUND(@Ln_Line9_AMNT, 0) > ROUND (@Ln_Line9ab_AMNT, 0)
        BEGIN
        
         SET @Ls_Sql_TEXT = 'SELECT @AdjustTable_P1-2';
		 SET @Ls_Sqldata_TEXT = '';
		 
         SELECT @Ls_ColumnName_TEXT = Column_NAME,
                @Ln_AdjLine_AMNT = Adjust_AMNT
           FROM @AdjustTable_P1
          WHERE (Adjust_AMNT - FLOOR(Adjust_AMNT)) = ISNULL((SELECT MIN(Adjust_AMNT - FLOOR(Adjust_AMNT))
                                                        FROM @AdjustTable_P1
                                                       WHERE (Adjust_AMNT - FLOOR(Adjust_AMNT)) >= .50),0);

         SET @Li_RowCount_QNTY = @@ROWCOUNT;

         IF @Li_RowCount_QNTY = 0
          BEGIN
           SET @Ls_ColumnName_TEXT = '7BA';
           SELECT @Ln_AdjLine_AMNT = ISNULL(Adjust_AMNT,0) FROM  @AdjustTable_P1 WHERE Column_NAME = @Ls_ColumnName_TEXT;
          END

         SET @Ls_Sql_TEXT = 'UPDATE ROC34_Y1 SEC A LINE = ' + @Ls_ColumnName_TEXT + ' + 1';
		 SET @Ls_Sqldata_TEXT = 'UPDATE ROC34_Y1 SET Line' + @Ls_ColumnName_TEXT + '_AMNT = ROUND(CAST('+ CAST(@Ln_AdjLine_AMNT AS VARCHAR) + ' AS NUMERIC(11,2)),0)+1 WHERE BeginQtr_DATE = ''' + CAST(@Ad_BeginQtr_DATE AS VARCHAR) + ''' AND EndQtr_DATE = '''+ CAST(@Ad_EndQtr_DATE AS VARCHAR) + ''' AND TypeReport_CODE = ''' + @Ac_TypeReport_CODE+'''';
		 
		 EXECUTE (@Ls_Sqldata_TEXT);
         
		 SET @Ls_Sql_TEXT = 'UPDATE @AdjustTable_P1 - 2';
		 SET @Ls_Sqldata_TEXT = 'Column_NAME = ' + @Ls_ColumnName_TEXT;
         UPDATE @AdjustTable_P1
            SET Adjust_AMNT = Adjust_AMNT + 1
          WHERE Column_NAME = @Ls_ColumnName_TEXT;
          
		 SET @Ls_Sql_TEXT = 'SELECT ROC34_Y1 - Line9_AMNT - 2';
		 SET @Ls_Sqldata_TEXT = 'BeginQtr_DATE = ' + ISNULL(CAST(@Ad_BeginQtr_DATE AS VARCHAR), '') + ', EndQtr_DATE = ' + ISNULL (CAST(@Ad_EndQtr_DATE AS VARCHAR), '') + ', TypeReport_CODE = ' + @Ac_TypeReport_CODE;
         SELECT @Ln_Line9_AMNT = ((a.Line1_AMNT + a.Line2a_AMNT + a.Line2b_AMNT + a.Line2c_AMNT + a.Line2d_AMNT + a.Line2e_AMNT + a.Line2f_AMNT + a.Line2h_AMNT + a.Line2g_AMNT + a.Line3_AMNT) - (a.Line4a_AMNT + a.Line4ba_AMNT + a.Line4bb_AMNT + a.Line4bc_AMNT + a.Line4bd_AMNT + a.Line4be_AMNT + a.Line4bf_AMNT + a.Line4c_AMNT) - a.Line5_AMNT - (a.Line7aa_AMNT + a.Line7ac_AMNT + a.Line7ba_AMNT + a.Line7bb_AMNT + a.Line7bc_AMNT + a.Line7bd_AMNT + a.Line7ca_AMNT + a.Line7cb_AMNT + a.Line7cc_AMNT + a.Line7cd_AMNT + a.Line7ce_AMNT + a.Line7cf_AMNT + a.Line7da_AMNT + a.Line7db_AMNT + a.Line7dc_AMNT + a.Line7dd_AMNT + a.Line7de_AMNT + a.Line7df_AMNT + a.Line7ee_AMNT + a.Line7ef_AMNT))
           FROM ROC34_Y1 a
          WHERE a.BeginQtr_DATE = @Ad_BeginQtr_DATE
            AND a.EndQtr_DATE = @Ad_EndQtr_DATE
            AND a.TypeReport_CODE = @Ac_TypeReport_CODE;
            
        END
      END

     IF((@Ln_Line9b_AMNT <> @Ln_SecA1P2_AMNT)
         OR (@Ln_Line9b_AMNT <> @Ln_SecB1P2_AMNT))
      BEGIN
       SET @Ls_Sql_TEXT = 'SELECT ALL AMOUNT PART 2 WITHOUT ROUNDING';
	   SET @Ls_Sqldata_TEXT = 'BeginQtr_DATE = ' + ISNULL(CAST(@Ad_BeginQtr_DATE AS VARCHAR), '') + ', EndQtr_DATE = ' + ISNULL (CAST(@Ad_EndQtr_DATE AS VARCHAR), '') + ', TypeReport_CODE = ' + @Ac_TypeReport_CODE;
       INSERT @LineTwoTable_P1
              (Column_NUMB,
              Adjust_AMNT)
       SELECT 3,
              (SELECT ISNULL(SUM(b.Trans_AMNT), 0)
                 FROM R34UD_Y1 b
                WHERE b.LineP2A1No_TEXT = '3'
                  AND a.BeginQtr_DATE = b.BeginQtr_DATE
                  AND a.EndQtr_DATE = b.EndQtr_DATE
                  AND LookIn_TEXT <> @Lc_CheckRecipientEsch_IDNO
                  AND LineP1No_TEXT <> '9A')
         FROM ROC34_Y1 a
        WHERE a.BeginQtr_DATE = @Ad_BeginQtr_DATE
          AND a.EndQtr_DATE = @Ad_EndQtr_DATE
          AND a.TypeReport_CODE = @Ac_TypeReport_CODE
       UNION
       SELECT 4,
              (SELECT ISNULL(SUM(b.Trans_AMNT), 0)
                 FROM R34UD_Y1 b
                WHERE b.LineP2A1No_TEXT = '4'
                  AND a.BeginQtr_DATE = b.BeginQtr_DATE
                  AND a.EndQtr_DATE = b.EndQtr_DATE
                  AND LookIn_TEXT <> @Lc_CheckRecipientEsch_IDNO
                  AND LineP1No_TEXT <> '9A')
         FROM ROC34_Y1 a
        WHERE a.BeginQtr_DATE = @Ad_BeginQtr_DATE
          AND a.EndQtr_DATE = @Ad_EndQtr_DATE
          AND a.TypeReport_CODE = @Ac_TypeReport_CODE
       UNION
       SELECT 5,
              (SELECT ISNULL(SUM(b.Trans_AMNT), 0)
                 FROM R34UD_Y1 b
                WHERE b.LineP2A1No_TEXT = '5'
                  AND a.BeginQtr_DATE = b.BeginQtr_DATE
                  AND a.EndQtr_DATE = b.EndQtr_DATE
                  AND LookIn_TEXT <> @Lc_CheckRecipientEsch_IDNO
                  AND LineP1No_TEXT <> '9A')
         FROM ROC34_Y1 a
        WHERE a.BeginQtr_DATE = @Ad_BeginQtr_DATE
          AND a.EndQtr_DATE = @Ad_EndQtr_DATE
          AND a.TypeReport_CODE = @Ac_TypeReport_CODE
       UNION
       SELECT 6,
              (SELECT ISNULL(SUM(b.Trans_AMNT), 0)
                 FROM R34UD_Y1 b
                WHERE b.LineP2A1No_TEXT = '6'
                  AND a.BeginQtr_DATE = b.BeginQtr_DATE
                  AND a.EndQtr_DATE = b.EndQtr_DATE
                  AND LookIn_TEXT <> @Lc_CheckRecipientEsch_IDNO
                  AND LineP1No_TEXT <> '9A')
         FROM ROC34_Y1 a
        WHERE a.BeginQtr_DATE = @Ad_BeginQtr_DATE
          AND a.EndQtr_DATE = @Ad_EndQtr_DATE
          AND a.TypeReport_CODE = @Ac_TypeReport_CODE
       UNION
       SELECT 7,
              (SELECT ISNULL(SUM(b.Trans_AMNT), 0)
                 FROM R34UD_Y1 b
                WHERE b.LineP2A1No_TEXT = '7'
                  AND a.BeginQtr_DATE = b.BeginQtr_DATE
                  AND a.EndQtr_DATE = b.EndQtr_DATE
                  AND LookIn_TEXT <> @Lc_CheckRecipientEsch_IDNO
                  AND LineP1No_TEXT <> '9A')
         FROM ROC34_Y1 a
        WHERE a.BeginQtr_DATE = @Ad_BeginQtr_DATE
          AND a.EndQtr_DATE = @Ad_EndQtr_DATE
          AND a.TypeReport_CODE = @Ac_TypeReport_CODE
       UNION
       SELECT 9,
              (SELECT ISNULL(SUM(b.Trans_AMNT), 0)
                 FROM R34UD_Y1 b
                WHERE b.LineP2A1No_TEXT = '9'
                  AND a.BeginQtr_DATE = b.BeginQtr_DATE
                  AND a.EndQtr_DATE = b.EndQtr_DATE
                  AND LookIn_TEXT <> @Lc_CheckRecipientEsch_IDNO
                  AND LineP1No_TEXT <> '9A')
         FROM ROC34_Y1 a
        WHERE a.BeginQtr_DATE = @Ad_BeginQtr_DATE
          AND a.EndQtr_DATE = @Ad_EndQtr_DATE
          AND a.TypeReport_CODE = @Ac_TypeReport_CODE
       UNION
       SELECT 10,
              (SELECT ISNULL(SUM(b.Trans_AMNT), 0)
                 FROM R34UD_Y1 b
                WHERE b.LineP2A1No_TEXT = '10'
                  AND a.BeginQtr_DATE = b.BeginQtr_DATE
                  AND a.EndQtr_DATE = b.EndQtr_DATE
                  AND LookIn_TEXT <> @Lc_CheckRecipientEsch_IDNO
                  AND LineP1No_TEXT <> '9A')
         FROM ROC34_Y1 a
        WHERE a.BeginQtr_DATE = @Ad_BeginQtr_DATE
          AND a.EndQtr_DATE = @Ad_EndQtr_DATE
          AND a.TypeReport_CODE = @Ac_TypeReport_CODE
       UNION
       SELECT 11,
              (SELECT ISNULL(SUM(b.Trans_AMNT), 0)
                 FROM R34UD_Y1 b
                WHERE b.LineP2A1No_TEXT = '11'
                  AND a.BeginQtr_DATE = b.BeginQtr_DATE
                  AND a.EndQtr_DATE = b.EndQtr_DATE
                  AND LookIn_TEXT <> @Lc_CheckRecipientEsch_IDNO
                  AND LineP1No_TEXT <> '9A')
         FROM ROC34_Y1 a
        WHERE a.BeginQtr_DATE = @Ad_BeginQtr_DATE
          AND a.EndQtr_DATE = @Ad_EndQtr_DATE
          AND a.TypeReport_CODE = @Ac_TypeReport_CODE
       UNION
       SELECT 12,
              (SELECT ISNULL(SUM(b.Trans_AMNT), 0)
                 FROM R34UD_Y1 b
                WHERE b.LineP2A1No_TEXT = '12'
                  AND a.BeginQtr_DATE = b.BeginQtr_DATE
                  AND a.EndQtr_DATE = b.EndQtr_DATE
                  AND LookIn_TEXT <> @Lc_CheckRecipientEsch_IDNO
                  AND LineP1No_TEXT <> '9A')
         FROM ROC34_Y1 a
        WHERE a.BeginQtr_DATE = @Ad_BeginQtr_DATE
          AND a.EndQtr_DATE = @Ad_EndQtr_DATE
          AND a.TypeReport_CODE = @Ac_TypeReport_CODE
       UNION
       SELECT 13,
              (SELECT ISNULL(SUM(b.Trans_AMNT), 0)
                 FROM R34UD_Y1 b
                WHERE b.LineP2A1No_TEXT = '13'
                  AND a.BeginQtr_DATE = b.BeginQtr_DATE
                  AND a.EndQtr_DATE = b.EndQtr_DATE
                  AND LookIn_TEXT <> @Lc_CheckRecipientEsch_IDNO
                  AND LineP1No_TEXT <> '9A')
         FROM ROC34_Y1 a
        WHERE a.BeginQtr_DATE = @Ad_BeginQtr_DATE
          AND a.EndQtr_DATE = @Ad_EndQtr_DATE
          AND a.TypeReport_CODE = @Ac_TypeReport_CODE
       UNION
       SELECT 14,
              (SELECT ISNULL(SUM(b.Trans_AMNT), 0)
                 FROM R34UD_Y1 b
                WHERE b.LineP2A1No_TEXT = '14'
                  AND a.BeginQtr_DATE = b.BeginQtr_DATE
                  AND a.EndQtr_DATE = b.EndQtr_DATE
                  AND LookIn_TEXT <> @Lc_CheckRecipientEsch_IDNO
                  AND LineP1No_TEXT <> '9A')
         FROM ROC34_Y1 a
        WHERE a.BeginQtr_DATE = @Ad_BeginQtr_DATE
          AND a.EndQtr_DATE = @Ad_EndQtr_DATE
          AND a.TypeReport_CODE = @Ac_TypeReport_CODE
       UNION
       SELECT 15,
              (SELECT ISNULL(SUM(b.Trans_AMNT), 0)
                 FROM R34UD_Y1 b
                WHERE b.LineP2A1No_TEXT = '15'
                  AND a.BeginQtr_DATE = b.BeginQtr_DATE
                  AND a.EndQtr_DATE = b.EndQtr_DATE
                  AND LookIn_TEXT <> @Lc_CheckRecipientEsch_IDNO
                  AND LineP1No_TEXT <> '9A')
         FROM ROC34_Y1 a
        WHERE a.BeginQtr_DATE = @Ad_BeginQtr_DATE
          AND a.EndQtr_DATE = @Ad_EndQtr_DATE
          AND a.TypeReport_CODE = @Ac_TypeReport_CODE
       UNION
       SELECT 16,
              (SELECT ISNULL(SUM(b.Trans_AMNT), 0)
                 FROM R34UD_Y1 b
                WHERE b.LineP2A1No_TEXT = '16'
                  AND a.BeginQtr_DATE = b.BeginQtr_DATE
                  AND a.EndQtr_DATE = b.EndQtr_DATE
                  AND LookIn_TEXT <> @Lc_CheckRecipientEsch_IDNO
                  AND LineP1No_TEXT <> '9A')
         FROM ROC34_Y1 a
        WHERE a.BeginQtr_DATE = @Ad_BeginQtr_DATE
          AND a.EndQtr_DATE = @Ad_EndQtr_DATE
          AND a.TypeReport_CODE = @Ac_TypeReport_CODE
       UNION
       SELECT 17,
              (SELECT ISNULL(SUM(b.Trans_AMNT), 0)
                 FROM R34UD_Y1 b
                WHERE b.LineP2A1No_TEXT = '17'
                  AND a.BeginQtr_DATE = b.BeginQtr_DATE
                  AND a.EndQtr_DATE = b.EndQtr_DATE
                  AND LookIn_TEXT <> @Lc_CheckRecipientEsch_IDNO
                  AND LineP1No_TEXT <> '9A')
         FROM ROC34_Y1 a
        WHERE a.BeginQtr_DATE = @Ad_BeginQtr_DATE
          AND a.EndQtr_DATE = @Ad_EndQtr_DATE
          AND a.TypeReport_CODE = @Ac_TypeReport_CODE
       UNION
       SELECT 18,
              (SELECT ISNULL(SUM(b.Trans_AMNT), 0)
                 FROM R34UD_Y1 b
                WHERE b.LineP2A1No_TEXT = '18'
                  AND a.BeginQtr_DATE = b.BeginQtr_DATE
                  AND a.EndQtr_DATE = b.EndQtr_DATE
                  AND LookIn_TEXT <> @Lc_CheckRecipientEsch_IDNO
                  AND LineP1No_TEXT <> '9A')
         FROM ROC34_Y1 a
        WHERE a.BeginQtr_DATE = @Ad_BeginQtr_DATE
          AND a.EndQtr_DATE = @Ad_EndQtr_DATE
          AND a.TypeReport_CODE = @Ac_TypeReport_CODE
       UNION
       SELECT 19,
              (SELECT ISNULL(SUM(b.Trans_AMNT), 0)
                 FROM R34UD_Y1 b
                WHERE b.LineP2A1No_TEXT = '19'
                  AND a.BeginQtr_DATE = b.BeginQtr_DATE
                  AND a.EndQtr_DATE = b.EndQtr_DATE
                  AND LookIn_TEXT <> @Lc_CheckRecipientEsch_IDNO
                  AND LineP1No_TEXT <> '9A')
         FROM ROC34_Y1 a
        WHERE a.BeginQtr_DATE = @Ad_BeginQtr_DATE
          AND a.EndQtr_DATE = @Ad_EndQtr_DATE
          AND a.TypeReport_CODE = @Ac_TypeReport_CODE
       UNION
       SELECT 20,
              (SELECT ISNULL(SUM(b.Trans_AMNT), 0)
                 FROM R34UD_Y1 b
                WHERE b.LineP2A1No_TEXT = '20'
                  AND a.BeginQtr_DATE = b.BeginQtr_DATE
                  AND a.EndQtr_DATE = b.EndQtr_DATE
                  AND LookIn_TEXT <> @Lc_CheckRecipientEsch_IDNO
                  AND LineP1No_TEXT <> '9A')
         FROM ROC34_Y1 a
        WHERE a.BeginQtr_DATE = @Ad_BeginQtr_DATE
          AND a.EndQtr_DATE = @Ad_EndQtr_DATE
          AND a.TypeReport_CODE = @Ac_TypeReport_CODE;
	  
      -- Adjusting Section A
      -- comparing Line9b against Sec A instead of Line9AB since Page 2 data
      -- is derived from V34UD that excludes escheatment (Line9a)	   
       IF (@Ln_Line9b_AMNT < @Ln_SecA1P2_AMNT)
        BEGIN
        
         --'Line 9b < Sec A'
         -- Subtract 1 from Sec A amount which is Least Cent value among those with more than 50 cents
         WHILE ROUND(@Ln_Line9b_AMNT, 0) < ROUND (@Ln_SecA1P2_AMNT, 0)
          BEGIN
          
           SET @Ls_Sql_TEXT = 'SELECT @LineTwoTable_P1-1';
           SET @Ls_Sqldata_TEXT =  '';
           SELECT @Li_ColumnNumb_QNTY = Column_NUMB,
                  @Ln_AdjLine_AMNT = Adjust_AMNT
             FROM @LineTwoTable_P1
            WHERE (Adjust_AMNT - FLOOR(Adjust_AMNT)) = ISNULL((SELECT MIN(Adjust_AMNT - FLOOR(Adjust_AMNT))
                                                          FROM @AdjustTable_P1
                                                         WHERE (Adjust_AMNT - FLOOR(Adjust_AMNT)) >= .50),0);

           SET @Li_RowCount_QNTY = @@ROWCOUNT;

           IF @Li_RowCount_QNTY = 0
            BEGIN
             SET @Li_ColumnNumb_QNTY = '3';
             SELECT @Ln_AdjLine_AMNT = ISNULL(Adjust_AMNT,0) FROM  @LineTwoTable_P1 WHERE Column_NUMB = @Li_ColumnNumb_QNTY;
            END

           SET @Ls_Sql_TEXT = 'UPDATE ROC34_Y1 SEC A LINE = ' + CAST(@Li_ColumnNumb_QNTY AS VARCHAR) + ' -1';
		   SET @Ls_Sqldata_TEXT =  'UPDATE ROC34_Y1 SET Line' + CAST(@Li_ColumnNumb_QNTY AS VARCHAR) + 'P2_AMNT = ROUND(CAST('+CAST(@Ln_AdjLine_AMNT AS VARCHAR)+ ' AS NUMERIC(11,2)),0)-1 WHERE BeginQtr_DATE = ''' + CAST(@Ad_BeginQtr_DATE AS VARCHAR)+ ''' AND EndQtr_DATE = '''+ CAST(@Ad_EndQtr_DATE AS VARCHAR)+ ''' AND TypeReport_CODE = ''' +@Ac_TypeReport_CODE+'''';
           EXECUTE (@Ls_Sqldata_TEXT);
		   SET @Ls_Sql_TEXT = 'UPDATE @LineTwoTable_P1 -1';
		   SET @Ls_Sqldata_TEXT =  'Column_NUMB' + CAST(@Li_ColumnNumb_QNTY AS VARCHAR);
           UPDATE @LineTwoTable_P1
              SET Adjust_AMNT = Adjust_AMNT - 1
            WHERE Column_NUMB = @Li_ColumnNumb_QNTY; 

           SET @Ln_SecA1P2_AMNT = @Ln_SecA1P2_AMNT - 1;
          END
        END
       ELSE IF (@Ln_Line9b_AMNT > @Ln_SecA1P2_AMNT)
        BEGIN
         --'Line 9b > Sec A'
         -- Add 1 to Sec A amount which is Max Cent value among those with less than 50 cents        
         WHILE ROUND(@Ln_Line9b_AMNT, 0) > ROUND (@Ln_SecA1P2_AMNT, 0)
          BEGIN
          
           SET @Ls_Sql_TEXT = 'SELECT @LineTwoTable_P1-2';
           SET @Ls_Sqldata_TEXT =  '';
           SELECT @Li_ColumnNumb_QNTY = Column_NUMB,
                  @Ln_AdjLine_AMNT = Adjust_AMNT
             FROM @LineTwoTable_P1
            WHERE (Adjust_AMNT - FLOOR(Adjust_AMNT)) = ISNULL((SELECT MIN(Adjust_AMNT - FLOOR(Adjust_AMNT))
                                                          FROM @AdjustTable_P1
                                                         WHERE (Adjust_AMNT - FLOOR(Adjust_AMNT)) < .50),0);

           SET @Li_RowCount_QNTY = @@ROWCOUNT;

           IF @Li_RowCount_QNTY = 0
            BEGIN
             SET @Li_ColumnNumb_QNTY = '3';
             SELECT @Ln_AdjLine_AMNT = ISNULL(Adjust_AMNT,0) FROM  @LineTwoTable_P1 WHERE Column_NUMB = @Li_ColumnNumb_QNTY;
            END

           SET @Ls_Sql_TEXT = 'UPDATE ROC34_Y1 SEC A LINE : ' + CAST(@Li_ColumnNumb_QNTY AS VARCHAR) + ' +1';
		   SET @Ls_Sqldata_TEXT = 	'UPDATE ROC34_Y1 SET Line' + CAST(@Li_ColumnNumb_QNTY AS VARCHAR) + 'P2_AMNT = ROUND(CAST('+CAST(@Ln_AdjLine_AMNT AS VARCHAR)+ ' AS NUMERIC(11,2)),0)+1 WHERE BeginQtr_DATE = ''' + CAST(@Ad_BeginQtr_DATE AS VARCHAR)+ ''' AND EndQtr_DATE = '''+ CAST(@Ad_EndQtr_DATE AS VARCHAR)+ ''' AND TypeReport_CODE = ''' +@Ac_TypeReport_CODE+'''';
           
		   EXECUTE (@Ls_Sqldata_TEXT);
		   SET @Ls_Sql_TEXT = 'UPDATE @LineTwoTable_P1 - 2';
		   SET @Ls_Sqldata_TEXT = 'Column_NUMB = ' + CAST(@Li_ColumnNumb_QNTY AS VARCHAR);
           UPDATE @LineTwoTable_P1
              SET Adjust_AMNT = Adjust_AMNT + 1
            WHERE Column_NUMB = @Li_ColumnNumb_QNTY;

           SET @Ln_SecA1P2_AMNT = @Ln_SecA1P2_AMNT + 1;
          END
        END

      -- Adjusting Section B
      -- comparing Line9b against Sec B instead of Line9AB since Page 2 data
      -- is derived from V34UD that excludes escheatment (Line9a)
       IF(@Ln_Line9b_AMNT < @Ln_SecB1P2_AMNT)
        BEGIN
         --'Line 9b < Sec B'
         -- Subtract 1 from Sec A amount which is Least Cent value among those with more than 50 cents        
         WHILE ROUND(@Ln_Line9b_AMNT, 0) < ROUND (@Ln_SecB1P2_AMNT, 0)
          BEGIN
          
           SET @Ls_Sql_TEXT = 'SELECT @LineTwoTable_P1-3';
           SET @Ls_Sqldata_TEXT =  '';
           SELECT @Li_ColumnNumb_QNTY = Column_NUMB,
                  @Ln_AdjLine_AMNT = Adjust_AMNT
             FROM @LineTwoTable_P1
            WHERE (Adjust_AMNT - FLOOR(Adjust_AMNT)) = ISNULL((SELECT MIN(Adjust_AMNT - FLOOR(Adjust_AMNT))
                                                          FROM @AdjustTable_P1
                                                         WHERE (Adjust_AMNT - FLOOR(Adjust_AMNT)) >= .50),0);

           SET @Li_RowCount_QNTY = @@ROWCOUNT;

           IF @Li_RowCount_QNTY = 0
            BEGIN
             SET @Li_ColumnNumb_QNTY = '14';
             SELECT @Ln_AdjLine_AMNT = ISNULL(Adjust_AMNT,0) FROM  @LineTwoTable_P1 WHERE Column_NUMB = @Li_ColumnNumb_QNTY;
            END

           SET @Ls_Sql_TEXT = 'UPDATE ROC34_Y1 SEC A LINE = ' + CAST(@Li_ColumnNumb_QNTY AS VARCHAR) + ' -1';
		   SET @Ls_Sqldata_TEXT = 	'UPDATE ROC34_Y1 SET Line' + CAST(@Li_ColumnNumb_QNTY AS VARCHAR) + 'P2_AMNT = ROUND(CAST('+CAST(@Ln_AdjLine_AMNT AS VARCHAR)+ ' AS NUMERIC(11,2)),0)-1 WHERE BeginQtr_DATE = ''' + CAST(@Ad_BeginQtr_DATE AS VARCHAR)+ ''' AND EndQtr_DATE = '''+ CAST(@Ad_EndQtr_DATE AS VARCHAR)+ ''' AND TypeReport_CODE = ''' +@Ac_TypeReport_CODE+'''';
           
           EXECUTE (@Ls_Sqldata_TEXT);
		   
		   SET @Ls_Sql_TEXT = 'UPDATE @LineTwoTable_P1 - 3';
		   SET @Ls_Sqldata_TEXT = 'Column_NUMB = ' + CAST(@Li_ColumnNumb_QNTY AS VARCHAR);
		   
           UPDATE @LineTwoTable_P1
              SET Adjust_AMNT = Adjust_AMNT - 1
            WHERE Column_NUMB = @Li_ColumnNumb_QNTY;

           SET @Ln_SecB1P2_AMNT = @Ln_SecB1P2_AMNT - 1;
          END
        END
       ELSE IF(@Ln_Line9b_AMNT > @Ln_SecB1P2_AMNT)
        BEGIN
         --'Line 9b > Sec B'
         -- Add 1 to Sec A amount which is Max Cent value among those with less than 50 cents        
         WHILE ROUND(@Ln_Line9b_AMNT, 0) > ROUND (@Ln_SecB1P2_AMNT, 0)
          BEGIN
          
           SET @Ls_Sql_TEXT = 'SELECT @LineTwoTable_P1-4';
           SET @Ls_Sqldata_TEXT =  '';
           SELECT @Li_ColumnNumb_QNTY = Column_NUMB,
                  @Ln_AdjLine_AMNT = Adjust_AMNT
             FROM @LineTwoTable_P1
            WHERE (Adjust_AMNT - FLOOR(Adjust_AMNT)) = ISNULL((SELECT MIN(Adjust_AMNT - FLOOR(Adjust_AMNT))
                                                          FROM @AdjustTable_P1
                                                         WHERE (Adjust_AMNT - FLOOR(Adjust_AMNT)) < .50),0);

           SET @Li_RowCount_QNTY = @@ROWCOUNT;

           IF @Li_RowCount_QNTY = 0
            BEGIN
             SET @Li_ColumnNumb_QNTY = '14';
             SELECT @Ln_AdjLine_AMNT = ISNULL(Adjust_AMNT,0) FROM  @LineTwoTable_P1 WHERE Column_NUMB = @Li_ColumnNumb_QNTY;
            END

           SET @Ls_Sql_TEXT = 'UPDATE ROC34_Y1 SEC A LINE : ' + CAST(@Li_ColumnNumb_QNTY AS VARCHAR) + ' +1';
		   SET @Ls_Sqldata_TEXT = 	'UPDATE ROC34_Y1 SET Line' + CAST(@Li_ColumnNumb_QNTY AS VARCHAR) + 'P2_AMNT = ROUND(CAST('+CAST(@Ln_AdjLine_AMNT AS VARCHAR)+ ' AS NUMERIC(11,2)),0)+1 WHERE BeginQtr_DATE = ''' + CAST(@Ad_BeginQtr_DATE AS VARCHAR)+ ''' AND EndQtr_DATE = '''+ CAST(@Ad_EndQtr_DATE AS VARCHAR)+ ''' AND TypeReport_CODE = ''' +@Ac_TypeReport_CODE+'''';
           
           EXECUTE (@Ls_Sqldata_TEXT);
		   
		   SET @Ls_Sql_TEXT = 'UPDATE @LineTwoTable_P1 - 4';
		   SET @Ls_Sqldata_TEXT = 'Column_NUMB = ' + CAST(@Li_ColumnNumb_QNTY AS VARCHAR);	
           UPDATE @LineTwoTable_P1
              SET Adjust_AMNT = Adjust_AMNT + 1
            WHERE Column_NUMB = @Li_ColumnNumb_QNTY;

           SET @Ln_SecB1P2_AMNT = @Ln_SecB1P2_AMNT + 1;
          END
        END
      END
    END

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = '';
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();
   SET @Ls_ErrorMessage_TEXT =  SUBSTRING(ERROR_MESSAGE(), 1, 200);

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
