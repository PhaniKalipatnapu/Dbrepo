/****** Object:  StoredProcedure [dbo].[BATCH_RPT_OCSE34A$SP_INSERT_OC34]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_RPT_OCSE34A$SP_INSERT_OC34
Programmer Name 	: IMP Team
Description			: The process loads the summary data required for the OCSE34A - Report
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
CREATE PROCEDURE [dbo].[BATCH_RPT_OCSE34A$SP_INSERT_OC34]
 @Ad_BeginQtr_DATE         DATE,
 @Ad_EndQtr_DATE           DATE,
 @Ac_TypeReport_CODE       CHAR,
 @Ad_PrevBeginQtr_DATE     DATE,
 @Ad_PrevEndQtr_DATE       DATE,
 @Ac_Msg_CODE              CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusSuccess_CODE CHAR (1) = 'S',
          @Lc_Space_TEXT         CHAR (1) = ' ',
          @Lc_StatusFailed_CODE  CHAR (1) = 'F',
          @Lc_Lineno9a_TEXT      CHAR (2) = '9A',
          @Lc_Lineno03_TEXT      CHAR (2) = '3',
          @Lc_Lineno04_TEXT      CHAR (2) = '4',
          @Lc_Lineno05_TEXT      CHAR (2) = '5',
          @Lc_Lineno06_TEXT      CHAR (2) = '6',
          @Lc_Lineno07_TEXT      CHAR (2) = '7',
          @Lc_Lineno09_TEXT      CHAR (2) = '9',
          @Lc_Lineno10_TEXT      CHAR (2) = '10',
          @Lc_Lineno11_TEXT      CHAR (2) = '11',
          @Lc_Lineno12_TEXT      CHAR (2) = '12',
          @Lc_Lineno13_TEXT      CHAR (2) = '13',
          @Lc_Lineno14_TEXT      CHAR (2) = '14',
          @Lc_Lineno15_TEXT      CHAR (2) = '15',
          @Lc_Lineno16_TEXT      CHAR (2) = '16',
          @Lc_Lineno17_TEXT      CHAR (2) = '17',
          @Lc_Lineno18_TEXT      CHAR (2) = '18',
          @Lc_Lineno19_TEXT      CHAR (2) = '19',
          @Lc_Lineno20_TEXT      CHAR (2) = '20',
          @Ls_Procedure_NAME     VARCHAR (60) = 'SP_INSERT_OC34',
          @Ld_Low_DATE           DATE = '01/01/0001';
  DECLARE @Ln_Line7aaamount_NUMB NUMERIC (11, 2),
          @Ln_Line7acamount_NUMB NUMERIC (11, 2),
          @Ln_Error_NUMB         NUMERIC (11),
          @Ln_ErrorLine_NUMB     NUMERIC (11),
          @Ls_Sql_TEXT           VARCHAR (100),
          @Ls_Sqldata_TEXT       VARCHAR (1000),
          @Ls_ErrorMessage_TEXT  VARCHAR (4000) = '';

  BEGIN TRY
   SET @Ac_Msg_CODE = '';
   SET @As_DescriptionError_TEXT = '';
   SET @Ls_Sql_TEXT = 'INSERT ROC34_Y1';
   SET @Ls_Sqldata_TEXT = 'BeginQtr_DATE = ' + CAST(@Ad_BeginQtr_DATE AS VARCHAR) + ', EndQtr_DATE = ' + CAST(@Ad_EndQtr_DATE AS VARCHAR) + ', RepType_CODE = ' + ISNULL(@Ac_TypeReport_CODE, '');
   INSERT ROC34_Y1
          (BeginQtr_DATE,
           EndQtr_DATE,
           TypeReport_CODE,
           Line1_AMNT,
           Line2a_AMNT,
           Line2b_AMNT,
           Line2c_AMNT,
           Line2d_AMNT,
           Line2e_AMNT,
           Line2f_AMNT,
           Line2g_AMNT,
           Line2h_AMNT,
           Line3_AMNT,
           Line4a_AMNT,
           Line4ba_AMNT,
           Line4bb_AMNT,
           Line4bc_AMNT,
           Line4bd_AMNT,
           Line4be_AMNT,
           Line4bf_AMNT,
           Line4c_AMNT,
           Line5_AMNT,
           Line7aa_AMNT,
           Line7ac_AMNT,
           Line7ba_AMNT,
           Line7bb_AMNT,
           Line7bc_AMNT,
           Line7bd_AMNT,
           Line7ca_AMNT,
           Line7cb_AMNT,
           Line7cc_AMNT,
           Line7cd_AMNT,
           Line7ce_AMNT,
           Line7cf_AMNT,
           Line7da_AMNT,
           Line7db_AMNT,
           Line7dc_AMNT,
           Line7dd_AMNT,
           Line7de_AMNT,
           Line7df_AMNT,
           Line7ee_AMNT,
           Line7ef_AMNT,
           Line11_AMNT,
           Line9a_AMNT,
           Line9b_AMNT,
           Line3P2_AMNT,
           Line4P2_AMNT,
           Line5P2_AMNT,
           Line6P2_AMNT,
           Line7P2_AMNT,
           Line9P2_AMNT,
           Line10P2_AMNT,
           Line11P2_AMNT,
           Line12P2_AMNT,
           Line13P2_AMNT,
           Line14P2_AMNT,
           Line15P2_AMNT,
           Line16P2_AMNT,
           Line17P2_AMNT,
           Line18P2_AMNT,
           Line19P2_AMNT,
           Line20P2_AMNT)
   SELECT @Ad_BeginQtr_DATE AS BeginQtr_DATE,
          @Ad_EndQtr_DATE AS EndQtr_DATE,
          @Ac_TypeReport_CODE AS TypeReport_CODE,
          ISNULL(ROUND (SUM(r.LineNo1_AMNT), 0), 0) AS LineNo1_AMNT,
          ISNULL(ROUND (SUM(r.LineNo2a_AMNT), 0), 0) AS LineNo2a_AMNT,
          ISNULL(ROUND (SUM(r.LineNo2b_AMNT), 0), 0) AS LineNo2b_AMNT,
          ISNULL(ROUND (SUM(r.LineNo2c_AMNT), 0), 0) AS LineNo2c_AMNT,
          ISNULL(ROUND (SUM(r.LineNo2d_AMNT), 0), 0) AS LineNo2d_AMNT,
          ISNULL(ROUND (SUM(r.LineNo2e_AMNT), 0), 0) AS LineNo2e_AMNT,
          ISNULL(ROUND (SUM(r.LineNo2f_AMNT), 0), 0) AS LineNo2f_AMNT,
          ISNULL(ROUND (SUM(r.LineNo2g_AMNT), 0), 0) AS LineNo2g_AMNT,
          ISNULL(ROUND (SUM(r.LineNo2h_AMNT), 0), 0) AS LineNo2h_AMNT,
          ISNULL(ROUND (SUM(r.LineNo3_AMNT), 0), 0) AS LineNo3_AMNT,
          ISNULL(ROUND (SUM(r.LineNo4a_AMNT), 0), 0) AS LineNo4a_AMNT,
          ISNULL(ROUND (SUM(r.LineNo4ba_AMNT), 0), 0) AS LineNo4ba_AMNT,
          ISNULL(ROUND (SUM(r.LineNo4bb_AMNT), 0), 0) AS LineNo4bb_AMNT,
          ISNULL(ROUND (SUM(r.LineNo4bc_AMNT), 0), 0) AS LineNo4bc_AMNT,
          ISNULL(ROUND (SUM(r.LineNo4bd_AMNT), 0), 0) AS LineNo4bd_AMNT,
          ISNULL(ROUND (SUM(r.LineNo4be_AMNT), 0), 0) AS LineNo4be_AMNT,
          ISNULL(ROUND (SUM(r.LineNo4bf_AMNT), 0), 0) AS LineNo4bf_AMNT,
          ISNULL(ROUND (SUM(r.LineNo4c_AMNT), 0), 0) AS LineNo4c_AMNT,
          ISNULL(ROUND (SUM(r.LineNo5_AMNT), 0), 0) AS LineNo5_AMNT,
          ISNULL(ROUND (SUM(r.LineNo7aa_AMNT), 0), 0) AS LineNo7aa_AMNT,
          ISNULL(ROUND (SUM(r.LineNo7ac_AMNT), 0), 0) AS LineNo7ac_AMNT,
          ISNULL(ROUND (SUM(r.LineNo7ba_AMNT), 0), 0) AS LineNo7ba_AMNT,
          ISNULL(ROUND (SUM(r.LineNo7bb_AMNT), 0), 0) AS LineNo7bb_AMNT,
          ISNULL(ROUND (SUM(r.LineNo7bc_AMNT), 0), 0) AS LineNo7bc_AMNT,
          ISNULL(ROUND (SUM(r.LineNo7bd_AMNT), 0), 0) AS LineNo7bd_AMNT,
          ISNULL(ROUND (SUM(r.LineNo7ca_AMNT), 0), 0) AS LineNo7ca_AMNT,
          ISNULL(ROUND (SUM(r.LineNo7cb_AMNT), 0), 0) AS LineNo7cb_AMNT,
          ISNULL(ROUND (SUM(r.LineNo7cc_AMNT), 0), 0) AS LineNo7cc_AMNT,
          ISNULL(ROUND (SUM(r.LineNo7cd_AMNT), 0), 0) AS LineNo7cd_AMNT,
          ISNULL(ROUND (SUM(r.LineNo7ce_AMNT), 0), 0) AS LineNo7ce_AMNT,
          ISNULL(ROUND (SUM(r.LineNo7cf_AMNT), 0), 0) AS LineNo7cf_AMNT,
          ISNULL(ROUND (SUM(r.LineNo7da_AMNT), 0), 0) AS LineNo7da_AMNT,
          ISNULL(ROUND (SUM(r.LineNo7db_AMNT), 0), 0) AS LineNo7db_AMNT,
          ISNULL(ROUND (SUM(r.LineNo7dc_AMNT), 0), 0) AS LineNo7dc_AMNT,
          ISNULL(ROUND (SUM(r.LineNo7dd_AMNT), 0), 0) AS LineNo7dd_AMNT,
          ISNULL(ROUND (SUM(r.LineNo7de_AMNT), 0), 0) AS LineNo7de_AMNT,
          ISNULL(ROUND (SUM(r.LineNo7df_AMNT), 0), 0) AS LineNo7df_AMNT,
          ISNULL(ROUND (SUM(r.LineNo7ee_AMNT), 0), 0) AS LineNo7ee_AMNT,
          ISNULL(ROUND (SUM(r.LineNo7ef_AMNT), 0), 0) AS LineNo7ef_AMNT,
          ISNULL(ROUND (SUM(r.LineNo11_AMNT), 0), 0) AS LineNo11_AMNT,
          0 AS Line9a_AMNT,
          0 AS Line9b_AMNT,
          0 AS Line3P2_AMNT,
          0 AS Line4P2_AMNT,
          0 AS Line5P2_AMNT,
          0 AS Line6P2_AMNT,
          0 AS Line7P2_AMNT,
          0 AS Line9P2_AMNT,	
          0 AS Line10P2_AMNT,
          0 AS Line11P2_AMNT,
          0 AS Line12P2_AMNT,
          0 AS Line13P2_AMNT,
          0 AS Line14P2_AMNT,
          0 AS Line15P2_AMNT,
          0 AS Line16P2_AMNT,
          0 AS Line17P2_AMNT,
          0 AS Line18P2_AMNT,
          0 AS Line19P2_AMNT,
          0 AS Line20P2_AMNT
     FROM R34RT_Y1 r
    WHERE r.BeginQtr_DATE = @Ad_BeginQtr_DATE
      AND r.EndQtr_DATE = @Ad_EndQtr_DATE;
      
   SET @Ls_Sql_TEXT = 'INSERT R34UD_Y1';
   SET @Ls_Sqldata_TEXT = ' CALCULATE Defra_AMNT - LINE 7AA' + ' BeginQtr_DATE = ' + ISNULL(CAST( @Ad_BeginQtr_DATE AS VARCHAR ),'') + ', EndQtr_DATE = ' + ISNULL(CAST( @Ad_EndQtr_DATE AS VARCHAR ),'') + ', RepType_CODE = ' + ISNULL(@Ac_TypeReport_CODE, '')+ ', ObligationKey_ID = ' + ISNULL(@Lc_Space_TEXT,'')+ ', CheckNo_TEXT = ' + ISNULL(@Lc_Space_TEXT,'')+ ', TypeDisburse_CODE = ' + ISNULL(@Lc_Space_TEXT,'')+ ', ReasonHold_CODE = ' + ISNULL(@Lc_Space_TEXT,'');

   INSERT R34UD_Y1
          (BeginQtr_DATE,
           EndQtr_DATE,
           LineP1No_TEXT,
           LookIn_TEXT,
           Case_IDNO,
           Batch_DATE,
           SourceBatch_CODE,
           Batch_NUMB,
           SeqReceipt_NUMB,
           Trans_DATE,
           Trans_AMNT,
           Hold_DATE,
           PayorMci_IDNO,
           ObligationKey_ID,
           CheckNo_TEXT,
           Receipt_DATE ,
           TypeDisburse_CODE,
           ReasonHold_CODE,
           IvaCase_ID,
           LineP2A1No_TEXT,
           EventGlobalSeq_NUMB,
           LineP2B1No_TEXT
           )
   SELECT	BeginQtr_DATE,
			EndQtr_DATE,
			LineP1No_TEXT,
			LookIn_TEXT,
			Case_IDNO,
			Batch_DATE,
			SourceBatch_CODE,
			Batch_NUMB,
			SeqReceipt_NUMB,
			Trans_DATE,
			Trans_AMNT,
			Hold_DATE,
			PayorMci_IDNO,
			ObligationKey_ID,
			CheckNo_TEXT,
			Receipt_DATE,
			TypeDisburse_CODE,
			ReasonHold_CODE,
			IvaCase_ID,
			LineP2A1No_TEXT,
			EventGlobalSeq_NUMB + ROW_NUMBER () OVER (ORDER BY rnm) EventGlobalSeq_NUMB,
			LineP2B1No_TEXT
	FROM	
   (
   SELECT @Ad_BeginQtr_DATE AS BeginQtr_DATE,
          @Ad_EndQtr_DATE AS EndQtr_DATE,
          '7AA' AS LineP1No_TEXT,
          'Defra - ' + ISNULL(CAST(a.WelfareYearMonth_NUMB AS VARCHAR), '') AS LookIn_TEXT,
          0 AS Case_IDNO,
          @Ld_Low_DATE AS Batch_DATE,
          ' ' AS SourceBatch_CODE,
          0 AS Batch_NUMB,
          '0' AS SeqReceipt_NUMB,
          --Last day of the month
          DATEADD(s, -1, DATEADD(mm, DATEDIFF(m, 0, CONVERT(DATETIME, ISNULL(CAST(a.WelfareYearMonth_NUMB AS VARCHAR), '') + '01', 112)) + 1, 0)) AS Trans_DATE,
          ISNULL(a.Defra_AMNT, 0) AS Trans_AMNT,
          @Ld_Low_DATE AS Hold_DATE,
          0 AS PayorMci_IDNO,
          @Lc_Space_TEXT AS ObligationKey_ID,
          @Lc_Space_TEXT AS CheckNo_TEXT,
          @Ld_Low_DATE AS Receipt_DATE,
          @Lc_Space_TEXT AS TypeDisburse_CODE,
          @Lc_Space_TEXT AS ReasonHold_CODE,
          a.CaseWelfare_IDNO AS IvaCase_ID,
          '0' AS LineP2A1No_TEXT,
          -- Batch abends when quarterly report is run due to non uniqueness of seq_event_global when cleanup scripts are executed on ivmg
          --This code has been added to maintain uniqueness of 34ud table and avoid abend
          CaseWelfare_IDNO AS EventGlobalSeq_NUMB,
          '0' AS LineP2B1No_TEXT,
          0 AS Rnm
     FROM IVMG_Y1 a
    WHERE a.WelfareYearMonth_NUMB BETWEEN CONVERT(VARCHAR(6), @Ad_BeginQtr_DATE, 112) AND CONVERT(VARCHAR(6), @Ad_EndQtr_DATE, 112)
      AND a.WelfareElig_CODE = 'A'
      AND a.EventGlobalSeq_NUMB = (SELECT MAX(x.EventGlobalSeq_NUMB)
                                     FROM IVMG_Y1 x
                                    WHERE a.CaseWelfare_IDNO = x.CaseWelfare_IDNO
									  AND a.CpMci_IDNO = x.CpMci_IDNO	
                                      AND a.WelfareElig_CODE = x.WelfareElig_CODE
                                      AND a.WelfareYearMonth_NUMB = x.WelfareYearMonth_NUMB)
      AND a.Defra_AMNT != 0
      )A;
   
   SET @Ls_Sql_TEXT = 'SELECT Line7aaamount_NUMB FROM R34UD_Y1';
   SET @Ls_Sqldata_TEXT = 'BeginQtr_DATE = ' + ISNULL(CAST(@Ad_BeginQtr_DATE AS VARCHAR), '') + ', EndQtr_DATE = ' + ISNULL(CAST(@Ad_EndQtr_DATE AS VARCHAR), '') + ', LineP1No_TEXT = ' + '7AA'; 	
   SELECT @Ln_Line7aaamount_NUMB = ISNULL(SUM(r.Trans_AMNT), 0)
     FROM R34UD_Y1 r
    WHERE r.BeginQtr_DATE = @Ad_BeginQtr_DATE
      AND r.EndQtr_DATE = @Ad_EndQtr_DATE
      AND r.LineP1No_TEXT = '7AA';

   SET @Ls_Sql_TEXT = 'UPDATE ROC34_Y1 - LINE 7A 7B';
   SET @Ls_Sqldata_TEXT = 'BeginQtr_DATE = ' + CAST(@Ad_BeginQtr_DATE AS VARCHAR) + ', EndQtr_DATE = ' + CAST(@Ad_EndQtr_DATE AS VARCHAR) + ', RepType_CODE = ' + ISNULL(@Ac_TypeReport_CODE, '');
   SET @Ln_Line7acamount_NUMB = 0;
   UPDATE ROC34_Y1
      SET Line7aa_AMNT = ROUND (ISNULL(@Ln_Line7aaamount_NUMB, 0), 0),
          Line7ac_AMNT = ROUND (ISNULL(@Ln_Line7acamount_NUMB, 0), 0),
          Line7ba_AMNT = ROUND ((ISNULL(a.Line7ba_AMNT, 0) - ISNULL(@Ln_Line7aaamount_NUMB, 0)), 0),
          Line7bc_AMNT = ROUND (ISNULL(a.Line7bc_AMNT, 0) - ISNULL(@Ln_Line7acamount_NUMB, 0), 0)
     FROM ROC34_Y1 a
    WHERE a.BeginQtr_DATE = @Ad_BeginQtr_DATE
      AND a.EndQtr_DATE = @Ad_EndQtr_DATE
      AND a.TypeReport_CODE = @Ac_TypeReport_CODE;
      
   SET @Ls_Sql_TEXT = 'UPDATE ROC34_Y1 - PAGE 2';
   SET @Ls_Sqldata_TEXT = 'BeginQtr_DATE = ' + CAST(@Ad_BeginQtr_DATE AS VARCHAR) + ', EndQtr_DATE = ' + CAST(@Ad_EndQtr_DATE AS VARCHAR) + ', RepType_CODE = ' + ISNULL(@Ac_TypeReport_CODE, '');
   UPDATE a
      SET Line9a_AMNT = (SELECT ISNULL(ROUND (SUM(b.Trans_AMNT), 0), 0)
                           FROM R34UD_Y1 b
                          WHERE b.LineP1No_TEXT = @Lc_Lineno9a_TEXT
                            AND a.BeginQtr_DATE = b.BeginQtr_DATE
                            AND a.EndQtr_DATE = b.EndQtr_DATE),
          Line3P2_AMNT = (SELECT ISNULL(ROUND (SUM(b.Trans_AMNT), 0), 0)
                            FROM R34UD_Y1 b
                           WHERE b.LineP2A1No_TEXT = @Lc_Lineno03_TEXT
                             AND a.BeginQtr_DATE = b.BeginQtr_DATE
                             AND a.EndQtr_DATE = b.EndQtr_DATE
                             AND b.LookIn_TEXT <> '999999962'
                             AND b.LineP1No_TEXT <> @Lc_Lineno9a_TEXT),
          Line4P2_AMNT = (SELECT ISNULL(ROUND (SUM(b.Trans_AMNT), 0), 0)
                            FROM R34UD_Y1 b
                           WHERE b.LineP2A1No_TEXT = @Lc_Lineno04_TEXT
                             AND a.BeginQtr_DATE = b.BeginQtr_DATE
                             AND a.EndQtr_DATE = b.EndQtr_DATE
                             AND b.LookIn_TEXT <> '999999962'
                             AND b.LineP1No_TEXT <> @Lc_Lineno9a_TEXT),
          Line5P2_AMNT = (SELECT ISNULL(ROUND (SUM(b.Trans_AMNT), 0), 0)
                            FROM R34UD_Y1 b
                           WHERE b.LineP2A1No_TEXT = @Lc_Lineno05_TEXT
                             AND a.BeginQtr_DATE = b.BeginQtr_DATE
                             AND a.EndQtr_DATE = b.EndQtr_DATE
                             AND b.LookIn_TEXT <> '999999962'
                             AND b.LineP1No_TEXT <> @Lc_Lineno9a_TEXT),
          Line6P2_AMNT = (SELECT ISNULL(ROUND (SUM(b.Trans_AMNT), 0), 0)
                            FROM R34UD_Y1 b
                           WHERE b.LineP2A1No_TEXT = @Lc_Lineno06_TEXT
                             AND a.BeginQtr_DATE = b.BeginQtr_DATE
                             AND a.EndQtr_DATE = b.EndQtr_DATE
                             AND b.LookIn_TEXT <> '999999962'
                             AND b.LineP1No_TEXT <> @Lc_Lineno9a_TEXT),
          Line7P2_AMNT = (SELECT ISNULL(ROUND (SUM(b.Trans_AMNT), 0), 0)
                            FROM R34UD_Y1 b
                           WHERE b.LineP2A1No_TEXT = @Lc_Lineno07_TEXT
                             AND a.BeginQtr_DATE = b.BeginQtr_DATE
                             AND a.EndQtr_DATE = b.EndQtr_DATE
                             AND b.LookIn_TEXT <> '999999962'
                             AND b.LineP1No_TEXT <> @Lc_Lineno9a_TEXT),
          Line9P2_AMNT = (SELECT ISNULL(ROUND (SUM(b.Trans_AMNT), 0), 0)
                            FROM R34UD_Y1 b
                           WHERE b.LineP2A1No_TEXT = @Lc_Lineno09_TEXT
                             AND a.BeginQtr_DATE = b.BeginQtr_DATE
                             AND a.EndQtr_DATE = b.EndQtr_DATE
                             AND b.LookIn_TEXT <> '999999962'
                             AND b.LineP1No_TEXT <> @Lc_Lineno9a_TEXT),
          Line10P2_AMNT = (SELECT ISNULL(ROUND (SUM(b.Trans_AMNT), 0), 0)
                             FROM R34UD_Y1 b
                            WHERE b.LineP2A1No_TEXT = @Lc_Lineno10_TEXT
                              AND a.BeginQtr_DATE = b.BeginQtr_DATE
                              AND a.EndQtr_DATE = b.EndQtr_DATE
                              AND b.LookIn_TEXT <> '999999962'
                              AND b.LineP1No_TEXT <> @Lc_Lineno9a_TEXT),
          Line11P2_AMNT = (SELECT ISNULL(ROUND (SUM(b.Trans_AMNT), 0), 0)
                             FROM R34UD_Y1 b
                            WHERE b.LineP2A1No_TEXT = @Lc_Lineno11_TEXT
                              AND a.BeginQtr_DATE = b.BeginQtr_DATE
                              AND a.EndQtr_DATE = b.EndQtr_DATE
                              AND b.LookIn_TEXT <> '999999962'
                              AND b.LineP1No_TEXT <> @Lc_Lineno9a_TEXT),
          Line12P2_AMNT = (SELECT ISNULL(ROUND (SUM(b.Trans_AMNT), 0), 0)
                             FROM R34UD_Y1 b
                            WHERE b.LineP2A1No_TEXT = @Lc_Lineno12_TEXT
                              AND a.BeginQtr_DATE = b.BeginQtr_DATE
                              AND a.EndQtr_DATE = b.EndQtr_DATE
                              AND b.LookIn_TEXT <> '999999962'
                              AND b.LineP1No_TEXT <> @Lc_Lineno9a_TEXT),
          Line13P2_AMNT = (SELECT ISNULL(ROUND (SUM(b.Trans_AMNT), 0), 0)
                             FROM R34UD_Y1 b
                            WHERE b.LineP2A1No_TEXT = @Lc_Lineno13_TEXT
                              AND a.BeginQtr_DATE = b.BeginQtr_DATE
                              AND a.EndQtr_DATE = b.EndQtr_DATE
                              AND b.LookIn_TEXT <> '999999962'
                              AND b.LineP1No_TEXT <> @Lc_Lineno9a_TEXT),
          Line14P2_AMNT = (SELECT ISNULL(ROUND (SUM(b.Trans_AMNT), 0), 0)
                             FROM R34UD_Y1 b
                            WHERE b.LineP2B1No_TEXT = @Lc_Lineno14_TEXT
                              AND a.BeginQtr_DATE = b.BeginQtr_DATE
                              AND a.EndQtr_DATE = b.EndQtr_DATE
                              AND b.LookIn_TEXT <> '999999962'
                              AND b.LineP1No_TEXT <> @Lc_Lineno9a_TEXT),
          Line15P2_AMNT = (SELECT ISNULL(ROUND (SUM(b.Trans_AMNT), 0), 0)
                             FROM R34UD_Y1 b
                            WHERE b.LineP2B1No_TEXT = @Lc_Lineno15_TEXT
                              AND a.BeginQtr_DATE = b.BeginQtr_DATE
                              AND a.EndQtr_DATE = b.EndQtr_DATE
                              AND b.LookIn_TEXT <> '999999962'
                              AND b.LineP1No_TEXT <> @Lc_Lineno9a_TEXT),
          Line16P2_AMNT = (SELECT ISNULL(ROUND (SUM(b.Trans_AMNT), 0), 0)
                             FROM R34UD_Y1 b
                            WHERE b.LineP2B1No_TEXT = @Lc_Lineno16_TEXT
                              AND a.BeginQtr_DATE = b.BeginQtr_DATE
                              AND a.EndQtr_DATE = b.EndQtr_DATE
                              AND b.LookIn_TEXT <> '999999962'
                              AND b.LineP1No_TEXT <> @Lc_Lineno9a_TEXT),
          Line17P2_AMNT = (SELECT ISNULL(ROUND (SUM(b.Trans_AMNT), 0), 0)
                             FROM R34UD_Y1 b
                            WHERE b.LineP2B1No_TEXT = @Lc_Lineno17_TEXT
                              AND a.BeginQtr_DATE = b.BeginQtr_DATE
                              AND a.EndQtr_DATE = b.EndQtr_DATE
                              AND b.LookIn_TEXT <> '999999962'
                              AND b.LineP1No_TEXT <> @Lc_Lineno9a_TEXT),
          Line18P2_AMNT = (SELECT ISNULL(ROUND (SUM(b.Trans_AMNT), 0), 0)
                             FROM R34UD_Y1 b
                            WHERE b.LineP2B1No_TEXT = @Lc_Lineno18_TEXT
                              AND a.BeginQtr_DATE = b.BeginQtr_DATE
                              AND a.EndQtr_DATE = b.EndQtr_DATE
                              AND b.LookIn_TEXT <> '999999962'
                              AND b.LineP1No_TEXT <> @Lc_Lineno9a_TEXT),
          Line19P2_AMNT = (SELECT ISNULL(ROUND (SUM(b.Trans_AMNT), 0), 0)
                             FROM R34UD_Y1 b
                            WHERE b.LineP2B1No_TEXT = @Lc_Lineno19_TEXT
                              AND a.BeginQtr_DATE = b.BeginQtr_DATE
                              AND a.EndQtr_DATE = b.EndQtr_DATE
                              AND b.LookIn_TEXT <> '999999962'
                              AND b.LineP1No_TEXT <> @Lc_Lineno9a_TEXT),
          Line20P2_AMNT = (SELECT ISNULL(ROUND (SUM(b.Trans_AMNT), 0), 0)
                             FROM R34UD_Y1 b
                            WHERE b.LineP2B1No_TEXT = @Lc_Lineno20_TEXT
                              AND a.BeginQtr_DATE = b.BeginQtr_DATE
                              AND a.EndQtr_DATE = b.EndQtr_DATE
                              AND b.LookIn_TEXT <> '999999962'
                              AND b.LineP1No_TEXT <> @Lc_Lineno9a_TEXT)
     FROM ROC34_Y1 a
    WHERE a.BeginQtr_DATE = @Ad_BeginQtr_DATE
      AND a.EndQtr_DATE = @Ad_EndQtr_DATE
      AND a.TypeReport_CODE = @Ac_TypeReport_CODE;

   SET @Ls_Sql_TEXT = 'UPDATE OCSE34_Y1 - KUBE 9B';
   SET @Ls_Sqldata_TEXT = 'BeginQtr_DATE = ' + CAST(@Ad_BeginQtr_DATE AS VARCHAR) + ', EndQtr_DATE = ' + CAST(@Ad_EndQtr_DATE AS VARCHAR) + ', RepType_CODE = ' + ISNULL(@Ac_TypeReport_CODE, '');
   UPDATE a
      SET Line9b_AMNT = (SELECT ((((Line1_AMNT + Line2a_AMNT + Line2b_AMNT + Line2c_AMNT + Line2d_AMNT + Line2e_AMNT + Line2f_AMNT + Line2h_AMNT + Line2g_AMNT + Line3_AMNT) - (Line4a_AMNT + Line4ba_AMNT + Line4bb_AMNT + Line4bc_AMNT + Line4bd_AMNT + Line4be_AMNT + Line4bf_AMNT + Line4c_AMNT)) - (Line7aa_AMNT + Line7ac_AMNT + Line7ba_AMNT + Line7bb_AMNT + Line7bc_AMNT + Line7bd_AMNT + Line7ca_AMNT + Line7cb_AMNT + Line7cc_AMNT + Line7cd_AMNT + Line7ce_AMNT + Line7cf_AMNT + Line7da_AMNT + Line7db_AMNT + Line7dc_AMNT + Line7dd_AMNT + Line7de_AMNT + Line7df_AMNT + Line7ee_AMNT + Line7ef_AMNT)) - Line9a_AMNT)
                           FROM ROC34_Y1 b
                          WHERE b.BeginQtr_DATE = @Ad_BeginQtr_DATE
                            AND b.EndQtr_DATE = @Ad_EndQtr_DATE
                            AND b.TypeReport_CODE = @Ac_TypeReport_CODE)
     FROM ROC34_Y1 a
    WHERE a.BeginQtr_DATE = @Ad_BeginQtr_DATE
      AND a.EndQtr_DATE = @Ad_EndQtr_DATE
      AND a.TypeReport_CODE = @Ac_TypeReport_CODE;

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = @Lc_Space_TEXT;
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
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
