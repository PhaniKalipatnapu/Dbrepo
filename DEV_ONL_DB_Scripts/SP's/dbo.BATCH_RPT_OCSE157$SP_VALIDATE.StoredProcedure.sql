/****** Object:  StoredProcedure [dbo].[BATCH_RPT_OCSE157$SP_VALIDATE]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name          : BATCH_RPT_OCSE157$SP_VALIDATE
Programmer Name			: IMP Team
Description             : This procedure performs the OCSE157 internal edits and to validate a case in BATCH_RPT_OCSE157$SP_INSERT_ASSIST_DETAILS
Frequency               : YEARLY
Developed On            : 06/16/2011
Called BY               : None
Called On               : 
--------------------------------------------------------------------------------------------------------------------
Modified BY             :
Modified On             :
Version No              : 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_RPT_OCSE157$SP_VALIDATE] (
 @Ad_BeginFiscal_DATE      DATE,
 @Ad_EndFiscal_DATE        DATE,
 @Ac_TypeReport_CODE       CHAR(1),
 @Ac_Job_ID                CHAR(7),
 @As_Procedure_NAME        VARCHAR(100),
 @Ad_Run_DATE              DATE,
 @Ac_Msg_CODE              CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Li_Line_NUMB             SMALLINT = 1,
          @Lc_Msg_CODE              CHAR(1) = NULL,
          @Lc_Space_TEXT            CHAR(1) = ' ',
          @Lc_ErrorTypeError_CODE   CHAR(1) = 'E',
          @Lc_StatusFailed_CODE     CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE    CHAR(1) = 'S',
          @Lc_LineNo1_TEXT          CHAR(3) = '1',
          @Lc_LineNo1a_TEXT         CHAR(3) = '1A',
          @Lc_LineNo1b_TEXT         CHAR(3) = '1B',
          @Lc_LineNo1c_TEXT         CHAR(3) = '1C',
          @Lc_LineNo1d_TEXT         CHAR(3) = '1D',
          @Lc_LineNo1e_TEXT         CHAR(3) = '1E',
          @Lc_LineNo1f_TEXT         CHAR(3) = '1F',
          @Lc_LineNo1g_TEXT         CHAR(3) = '1G',
          @Lc_LineNo2_TEXT          CHAR(3) = '2',
          @Lc_LineNo2a_TEXT         CHAR(3) = '2A',
          @Lc_LineNo2b_TEXT         CHAR(3) = '2B',
          @Lc_LineNo2c_TEXT         CHAR(3) = '2C',
          @Lc_LineNo2d_TEXT         CHAR(3) = '2D',
          @Lc_LineNo2e_TEXT         CHAR(3) = '2E',
          @Lc_LineNo2f_TEXT         CHAR(3) = '2F',
          @Lc_LineNo2g_TEXT         CHAR(3) = '2G',
          @Lc_LineNo2h_TEXT         CHAR(3) = '2H',
          @Lc_LineNo2i_TEXT         CHAR(3) = '2I',
          @Lc_LineNo3_TEXT          CHAR(3) = '3',
          @Lc_LineNo4_TEXT          CHAR(3) = '4',
          @Lc_LineNo5_TEXT          CHAR(3) = '5',
          @Lc_LineNo7_TEXT          CHAR(3) = '7',
          @Lc_LineNo9_TEXT          CHAR(3) = '9',
          @Lc_LineNo10_TEXT         CHAR(3) = '10',
          @Lc_LineNo18_TEXT         CHAR(3) = '18',
          @Lc_LineNo18a_TEXT        CHAR(3) = '18A',
          @Lc_LineNo21_TEXT         CHAR(3) = '21',
          @Lc_LineNo22_TEXT         CHAR(3) = '22',
          @Lc_LineNo23_TEXT         CHAR(3) = '23',
          @Lc_LineNo28_TEXT         CHAR(3) = '28',
          @Lc_LineNo29_TEXT         CHAR(3) = '29',
          @Lc_ErrorO157Edit_CODE    CHAR(5) = 'E1257',
          @Ls_Process_NAME          VARCHAR(100) = 'BATCH_RPT_OCSE157',
          @Ls_Procedure_NAME        VARCHAR(100) = 'BATCH_RPT_OCSE157$SP_VALIDATE',
          @Ls_DescriptionErrorOut_TEXT        VARCHAR(4000) = NULL,
          @Ls_DescriptionError_TEXT VARCHAR(4000) = ' ';
     DECLARE            
          @Ln_Tot1_QNTY            NUMERIC(9),
          @Ln_Tot1a_QNTY           NUMERIC(9),
          @Ln_Tot1b_QNTY           NUMERIC(9),
          @Ln_Tot1c_QNTY           NUMERIC(9),
          @Ln_Tot1d_QNTY           NUMERIC(9),
          @Ln_Tot1e_QNTY           NUMERIC(9),
          @Ln_Tot1f_QNTY           NUMERIC(9),
          @Ln_Tot1g_QNTY           NUMERIC(9),
          @Ln_Tot2_QNTY            NUMERIC(9),
          @Ln_Tot2a_QNTY           NUMERIC(9),
          @Ln_Tot2b_QNTY           NUMERIC(9),
          @Ln_Tot2c_QNTY           NUMERIC(9),
          @Ln_Tot2d_QNTY           NUMERIC(9),
          @Ln_Tot2e_QNTY           NUMERIC(9),
          @Ln_Tot2f_QNTY           NUMERIC(9),
          @Ln_Tot2g_QNTY           NUMERIC(9),
          @Ln_Tot2h_QNTY           NUMERIC(9),
          @Ln_Tot2i_QNTY           NUMERIC(9),
          @Ln_Tot3_QNTY            NUMERIC(9),
          @Ln_Tot4_QNTY            NUMERIC(9),
          @Ln_Tot5_QNTY            NUMERIC(9),
          @Ln_Tot7_QNTY            NUMERIC(9),
          @Ln_Tot9_QNTY            NUMERIC(9),
          @Ln_Tot10_QNTY           NUMERIC(9),
          @Ln_Tot18_QNTY           NUMERIC(9),
          @Ln_Tot18a_QNTY          NUMERIC(9),
          @Ln_Tot21_QNTY           NUMERIC(9),
          @Ln_Tot22_QNTY           NUMERIC(9),
          @Ln_Tot23_QNTY           NUMERIC(9),
          @Ln_Tot28_QNTY           NUMERIC(9),
          @Ln_Tot29_QNTY           NUMERIC(9),
          @Ls_Sql_TEXT              VARCHAR(4000),
          @Ls_Sqldata_TEXT          VARCHAR(4000);      

  CREATE TABLE #LineTab_P1
   (
     LineNo_TEXT VARCHAR(3),
     Tot_QNTY    NUMERIC(11, 2),
     Ca_AMNT     NUMERIC(11, 2),
     Fa_AMNT     NUMERIC(11, 2),
     Na_AMNT     NUMERIC(11, 2)
   );

  BEGIN TRY
   SET @Ls_Sql_TEXT = 'STORING THE COUNTS';
   SET @Ls_SqlData_TEXT = 'BeginFiscal DATE = '+CAST(@Ad_BeginFiscal_DATE AS VARCHAR)+',EndFiscal DATE = '+CAST(@Ad_EndFiscal_DATE AS VARCHAR)+',TypeReport CODE = '+ISNULL(@Ac_TypeReport_CODE,'');
   INSERT INTO #LineTab_P1
               (LineNo_TEXT,
                Tot_QNTY,
                Ca_AMNT,
                Fa_AMNT,
                Na_AMNT)
   SELECT r.LineNo_TEXT,
          SUM(r.Tot_QNTY) AS Tot_QNTY,
          SUM(r.Ca_AMNT) AS Ca_AMNT,
          SUM(r.Fa_AMNT) AS Fa_AMNT,
          SUM(r.Na_AMNT) AS Na_AMNT
     FROM RO157_Y1 r
    WHERE r.BeginFiscal_DATE = @Ad_BeginFiscal_DATE
      AND r.EndFiscal_DATE = @Ad_EndFiscal_DATE
      AND r.TypeReport_CODE = @Ac_TypeReport_CODE
    GROUP BY r.LineNo_TEXT;

   SET @Ls_Sql_TEXT = 'CHECK - LINE 1A IS GREATER OR EQUAL THAN LINE 1';
   SET @Ls_SqlData_TEXT ='LineNo TEXT : '+ @Lc_LineNo1_TEXT;
   SET @Ln_Tot1_QNTY = (SELECT Tot_QNTY
                           FROM #LineTab_P1
                          WHERE LineNo_TEXT = @Lc_LineNo1_TEXT);
   SET @Ln_Tot1a_QNTY = (SELECT Tot_QNTY AS Tot_QNTY_1
                            FROM #LineTab_P1
                           WHERE LineNo_TEXT = @Lc_LineNo1a_TEXT);

   IF (@Ln_Tot1a_QNTY >= @Ln_Tot1_QNTY)
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG-1';
     SET @Ls_SqlData_TEXT = ' Process_NAME  = ' + @Ls_Process_NAME +' , Procedure_NAME  = ' + @As_Procedure_NAME + ' , Job_ID = ' + @Ac_Job_ID +  ' ,Run DATE = '+CAST( @Ad_Run_DATE AS VARCHAR)+',TypeError CODE = ' + @Lc_ErrorTypeError_CODE+ ',Line NUMB = ' +CAST(@Li_Line_NUMB AS VARCHAR)+',Error CODE = ' +@Lc_ErrorO157Edit_CODE+',DescriptionError TEXT = ' +@Ls_DescriptionError_TEXT+',ListKey TEXT = '+@Lc_Space_TEXT;
  
     SET @Ls_DescriptionError_TEXT = 'LINE 1A IS GREATER OR EQUAL THAN LINE 1 ';
     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Ls_Process_NAME,
      @As_Procedure_NAME           = @As_Procedure_NAME,
      @Ac_Job_ID                   = @Ac_Job_ID,
      @Ad_Run_DATE                 = @Ad_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_ErrorTypeError_CODE,
      @An_Line_NUMB                = @Li_Line_NUMB,
      @Ac_Error_CODE               = @Lc_ErrorO157Edit_CODE,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
      @As_ListKey_TEXT             = @Lc_Space_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionErrorOut_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END
    END

   SET @Ls_Sql_TEXT = 'CHECK - LINE 1B IS GREATER OR EQUAL THAN LINE 1';
   SET @Ls_SqlData_TEXT='LineNo TEXT = '+ @Lc_LineNo1b_TEXT;
   SET @Ln_Tot1b_QNTY = (SELECT Tot_QNTY AS Tot_QNTY_1
                            FROM #LineTab_P1
                           WHERE LineNo_TEXT = @Lc_LineNo1b_TEXT);
 
   IF (@Ln_Tot1b_QNTY >= @Ln_Tot1_QNTY)
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG-2';
     SET @Ls_SqlData_TEXT ='Process_NAME = '+ @Ls_Process_NAME + ' , Procedure_NAME = '+ @As_Procedure_NAME  + ' , Job_ID = '+ @Ac_Job_ID + ' , Run DATE = '+CAST( @Ad_Run_DATE AS VARCHAR)+',TypeError CODE = ' +@Lc_ErrorTypeError_CODE+',Line NUMB = ' +CAST(@Li_Line_NUMB AS VARCHAR)+',Error CODE = ' +@Lc_ErrorO157Edit_CODE+',DescriptionError TEXT = ' +@Ls_DescriptionError_TEXT+',ListKey TEXT = '+@Lc_Space_TEXT;
     
     SET @Ls_DescriptionError_TEXT = 'LINE 1B IS GREATER THAN LINE 1 ';

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Ls_Process_NAME,
      @As_Procedure_NAME           = @As_Procedure_NAME,
      @Ac_Job_ID                   = @Ac_Job_ID,
       @Ad_Run_DATE                 =@Ad_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_ErrorTypeError_CODE,
      @An_Line_NUMB                = @Li_Line_NUMB,
      @Ac_Error_CODE               = @Lc_ErrorO157Edit_CODE,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
      @As_ListKey_TEXT             = @Lc_Space_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionErrorOut_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END
    END

   SET @Ls_Sql_TEXT = 'CHECK - LINE 1C IS GREATER OR EQUAL THAN LINE 1';
   SET @Ls_SqlData_TEXT = 'LineNo TEXT = '+@Lc_LineNo1c_TEXT;
   SET @Ln_Tot1c_QNTY = (SELECT Tot_QNTY
                            FROM #LineTab_P1
                           WHERE LineNo_TEXT = @Lc_LineNo1c_TEXT);

   IF (@Ln_Tot1c_QNTY >= @Ln_Tot1_QNTY)
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG-3';
     SET @Ls_SqlData_TEXT ='Process_NAME = '+ @Ls_Process_NAME + ' , Procedure_NAME = '+ @As_Procedure_NAME  + ' , Job_ID = '+ @Ac_Job_ID +' , Run DATE = '+CAST( @Ad_Run_DATE AS VARCHAR)+',TypeError CODE = ' +@Lc_ErrorTypeError_CODE+',Line NUMB = ' +CAST(@Li_Line_NUMB AS VARCHAR)+',Error CODE = ' +@Lc_ErrorO157Edit_CODE+',DescriptionError TEXT = ' +@Ls_DescriptionError_TEXT+',ListKey TEXT = '+@Lc_Space_TEXT;
     
     SET @Ls_DescriptionError_TEXT = 'LINE 1C IS GREATER THAN LINE 1 ';
 
     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Ls_Process_NAME,
      @As_Procedure_NAME           = @As_Procedure_NAME,
      @Ac_Job_ID                   = @Ac_Job_ID,
       @Ad_Run_DATE                = @Ad_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_ErrorTypeError_CODE,
      @An_Line_NUMB                = @Li_Line_NUMB,
      @Ac_Error_CODE               = @Lc_ErrorO157Edit_CODE,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
      @As_ListKey_TEXT             = @Lc_Space_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionErrorOut_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END
    END

   SET @Ls_Sql_TEXT = 'CHECK - LINE 1D IS GREATER OR EQUAL THAN LINE 1';
   SET @Ls_SqlData_TEXT = 'LineNo TEXT = '+@Lc_LineNo1d_TEXT;
   SET @Ln_Tot1d_QNTY = (SELECT Tot_QNTY
                            FROM #LineTab_P1
                           WHERE LineNo_TEXT = @Lc_LineNo1d_TEXT);
 
   IF (@Ln_Tot1d_QNTY >= @Ln_Tot1_QNTY)
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG-4';
     SET @Ls_SqlData_TEXT ='Process_NAME = '+ @Ls_Process_NAME + ' , Procedure_NAME = '+ @As_Procedure_NAME  + ' , Job_ID = '+ @Ac_Job_ID +' , Run DATE = '+CAST( @Ad_Run_DATE AS VARCHAR)+',TypeError CODE = ' +@Lc_ErrorTypeError_CODE+',Line NUMB = ' +CAST(@Li_Line_NUMB AS VARCHAR)+',Error CODE = ' +@Lc_ErrorO157Edit_CODE+',DescriptionError TEXT = ' +@Ls_DescriptionError_TEXT+',ListKey TEXT = '+@Lc_Space_TEXT;
     
     SET @Ls_DescriptionError_TEXT = 'LINE 1D IS GREATER THAN LINE 1 ';

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Ls_Process_NAME,
      @As_Procedure_NAME           = @As_Procedure_NAME,
      @Ac_Job_ID                   = @Ac_Job_ID,
       @Ad_Run_DATE                = @Ad_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_ErrorTypeError_CODE,
      @An_Line_NUMB                = @Li_Line_NUMB,
      @Ac_Error_CODE               = @Lc_ErrorO157Edit_CODE,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
      @As_ListKey_TEXT             = @Lc_Space_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionErrorOut_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END;
    END;

   SET @Ls_Sql_TEXT = 'CHECK - LINE 1E IS GREATER OR EQUAL THAN LINE 1';
   SET @Ls_SqlData_TEXT = 'LineNo TEXT = '+@Lc_LineNo1e_TEXT;
   SET @Ln_Tot1e_QNTY = (SELECT Tot_QNTY
                            FROM #LineTab_P1
                           WHERE LineNo_TEXT = @Lc_LineNo1e_TEXT);
 
   IF (@Ln_Tot1e_QNTY >= @Ln_Tot1_QNTY)
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG-5';
     SET @Ls_SqlData_TEXT = 'Process_NAME = '+ @Ls_Process_NAME + ' , Procedure_NAME = '+ @As_Procedure_NAME  + ' , Job_ID = '+ @Ac_Job_ID + ' , Run DATE = '+CAST( @Ad_Run_DATE AS VARCHAR)+',TypeError CODE = ' +@Lc_ErrorTypeError_CODE+',Line NUMB = ' +CAST(@Li_Line_NUMB AS VARCHAR)+',Error CODE = ' +@Lc_ErrorO157Edit_CODE+',DescriptionError TEXT = ' +@Ls_DescriptionError_TEXT+',ListKey TEXT = '+@Lc_Space_TEXT;
     
     SET @Ls_DescriptionError_TEXT = 'LINE 1E IS GREATER THAN LINE 1 ';

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Ls_Process_NAME,
      @As_Procedure_NAME           = @As_Procedure_NAME,
      @Ac_Job_ID                   = @Ac_Job_ID,
       @Ad_Run_DATE                = @Ad_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_ErrorTypeError_CODE,
      @An_Line_NUMB                = @Li_Line_NUMB,
      @Ac_Error_CODE               = @Lc_ErrorO157Edit_CODE,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
      @As_ListKey_TEXT             = @Lc_Space_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionErrorOut_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END;
    END;

   SET @Ls_Sql_TEXT = 'CHECK - LINE 1F IS GREATER OR EQUAL THAN LINE 1';
   SET @Ls_SqlData_TEXT = 'LineNo TEXT = '+@Lc_LineNo1f_TEXT;
   SET @Ln_Tot1f_QNTY = (SELECT Tot_QNTY
                            FROM #LineTab_P1
                           WHERE LineNo_TEXT = @Lc_LineNo1f_TEXT);

   IF (@Ln_Tot1f_QNTY >= @Ln_Tot1_QNTY)
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG-6';
     SET @Ls_SqlData_TEXT ='Process_NAME = '+ @Ls_Process_NAME + ' , Procedure_NAME = '+ @As_Procedure_NAME  + ' , Job_ID = '+ @Ac_Job_ID + ' , Run_DATE = '+ CAST( @Ad_Run_DATE AS VARCHAR)+ ' , TypeError CODE = ' +@Lc_ErrorTypeError_CODE+',Line NUMB = ' +CAST(@Li_Line_NUMB AS VARCHAR)+',Error CODE = ' +@Lc_ErrorO157Edit_CODE+',DescriptionError TEXT = ' +@Ls_DescriptionError_TEXT+',ListKey TEXT = '+@Lc_Space_TEXT;
     
     SET @Ls_DescriptionError_TEXT = 'LINE 1F IS GREATER THAN LINE 1 ';

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Ls_Process_NAME,
      @As_Procedure_NAME           = @As_Procedure_NAME,
      @Ac_Job_ID                   = @Ac_Job_ID,
      @Ad_Run_DATE                 = @Ad_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_ErrorTypeError_CODE,
      @An_Line_NUMB                = @Li_Line_NUMB,
      @Ac_Error_CODE               = @Lc_ErrorO157Edit_CODE,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
      @As_ListKey_TEXT             = @Lc_Space_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionErrorOut_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END;
    END;

   SET @Ls_Sql_TEXT = 'CHECK - LINE 1G IS GREATER OR EQUAL THAN LINE 1';
   SET @Ls_SqlData_TEXT = 'LineNo TEXT = '+@Lc_LineNo1g_TEXT;
   SET @Ln_Tot1g_QNTY = (SELECT Tot_QNTY
                            FROM #LineTab_P1
                           WHERE LineNo_TEXT = @Lc_LineNo1g_TEXT);

   IF (@Ln_Tot1g_QNTY >= @Ln_Tot1_QNTY)
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG-7';
     SET @Ls_SqlData_TEXT ='Process_NAME = '+ @Ls_Process_NAME + ' , Procedure_NAME = '+ @As_Procedure_NAME  + ' , Job_ID = '+ @Ac_Job_ID + ' , Run_DATE = '+ CAST( @Ad_Run_DATE AS VARCHAR)+' , TypeError CODE = ' +@Lc_ErrorTypeError_CODE+',Line NUMB = ' +CAST(@Li_Line_NUMB AS VARCHAR)+',Error CODE = ' +@Lc_ErrorO157Edit_CODE+',DescriptionError TEXT = ' +@Ls_DescriptionError_TEXT+',ListKey TEXT = '+@Lc_Space_TEXT;
     
     SET @Ls_DescriptionError_TEXT = 'LINE 1G IS GREATER THAN LINE 1 ';
 
     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Ls_Process_NAME,
      @As_Procedure_NAME           = @As_Procedure_NAME,
      @Ac_Job_ID                   = @Ac_Job_ID,
       @Ad_Run_DATE                 =  @Ad_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_ErrorTypeError_CODE,
      @An_Line_NUMB                = @Li_Line_NUMB,
      @Ac_Error_CODE               = @Lc_ErrorO157Edit_CODE,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
      @As_ListKey_TEXT             = @Lc_Space_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionErrorOut_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END;
    END;

   SET @Ls_Sql_TEXT = 'CHECK - LINE 3 IS GREATER OR EQUAL THAN LINE 1';
   SET @Ls_SqlData_TEXT = 'LineNo TEXT = '+@Lc_LineNo3_TEXT;
   SET @Ln_Tot3_QNTY = (SELECT Tot_QNTY
                           FROM #LineTab_P1
                          WHERE LineNo_TEXT = @Lc_LineNo3_TEXT);
 
   IF (@Ln_Tot3_QNTY >= @Ln_Tot1_QNTY)
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG-8';
     SET @Ls_SqlData_TEXT ='Process_NAME = '+ @Ls_Process_NAME + ' , Procedure_NAME = '+ @As_Procedure_NAME  + ' , Job_ID = '+ @Ac_Job_ID + ' , Run_DATE = '+ CAST( @Ad_Run_DATE AS VARCHAR)+ ' , TypeError CODE = ' +@Lc_ErrorTypeError_CODE+',Line NUMB = ' +CAST(@Li_Line_NUMB AS VARCHAR)+',Error CODE = ' +@Lc_ErrorO157Edit_CODE+',DescriptionError TEXT = ' +@Ls_DescriptionError_TEXT+',ListKey TEXT = '+@Lc_Space_TEXT;
     
     SET @Ls_DescriptionError_TEXT = 'LINE 3 IS GREATER THAN LINE 1 ';
 
     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Ls_Process_NAME,
      @As_Procedure_NAME           = @As_Procedure_NAME,
      @Ac_Job_ID                   = @Ac_Job_ID,
      @Ad_Run_DATE                = @Ad_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_ErrorTypeError_CODE,
      @An_Line_NUMB                = @Li_Line_NUMB,
      @Ac_Error_CODE               = @Lc_ErrorO157Edit_CODE,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
      @As_ListKey_TEXT             = @Lc_Space_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionErrorOut_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END;
    END;

   SET @Ls_Sql_TEXT = 'CHECK - LINE 1A + 1B + 1C + 1D + 1E + 1F + 1G IS EQUAL TO LINE 1';
   SET @Ls_SqlData_TEXT = 'Tot1 QNTY'+CAST(@Ln_Tot1_QNTY AS VARCHAR);
   
   IF ((@Ln_Tot1a_QNTY + @Ln_Tot1b_QNTY + @Ln_Tot1c_QNTY + @Ln_Tot1d_QNTY + @Ln_Tot1e_QNTY + @Ln_Tot1f_QNTY + @Ln_Tot1g_QNTY) = @Ln_Tot1_QNTY)
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG-9';
     SET @Ls_SqlData_TEXT ='Process_NAME = '+ @Ls_Process_NAME + ' , Procedure_NAME = '+ @As_Procedure_NAME  + ' , Job_ID = '+ @Ac_Job_ID + ' , Run_DATE = '+ CAST( @Ad_Run_DATE AS VARCHAR)+ ' , TypeError CODE = ' +@Lc_ErrorTypeError_CODE+',Line NUMB = ' +CAST(@Li_Line_NUMB AS VARCHAR)+',Error CODE = ' +@Lc_ErrorO157Edit_CODE+',DescriptionError TEXT = ' +@Ls_DescriptionError_TEXT+',ListKey TEXT = '+@Lc_Space_TEXT;
     SET @Ls_DescriptionError_TEXT = 'LINE 1A + 1B + 1C + 1D + 1E + 1F + 1G IS EQUAL TO LINE 1';

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Ls_Process_NAME,
      @As_Procedure_NAME           = @As_Procedure_NAME,
      @Ac_Job_ID                   = @Ac_Job_ID,
      @Ad_Run_DATE                 = @Ad_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_ErrorTypeError_CODE,
      @An_Line_NUMB                = @Li_Line_NUMB,
      @Ac_Error_CODE               = @Lc_ErrorO157Edit_CODE,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
      @As_ListKey_TEXT             = @Lc_Space_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionErrorOut_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END;
    END;

   SET @Ls_Sql_TEXT = 'CHECK - LINE 2A IS GREATER OR EQUAL THAN LINE 2';
   SET @Ls_SqlData_TEXT = 'LineNo TEXT = '+@Lc_LineNo2a_TEXT;
   SET @Ln_Tot2a_QNTY = (SELECT Tot_QNTY
                            FROM #LineTab_P1
                           WHERE LineNo_TEXT = @Lc_LineNo2a_TEXT);
   SET @Ln_Tot2_QNTY = (SELECT Tot_QNTY
                           FROM #LineTab_P1
                          WHERE LineNo_TEXT = @Lc_LineNo2_TEXT);

   IF (@Ln_Tot2a_QNTY >= @Ln_Tot2_QNTY)
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG-10';
     SET @Ls_SqlData_TEXT ='Process_NAME = '+ @Ls_Process_NAME + ' , Procedure_NAME = '+ @As_Procedure_NAME  + ' , Job_ID = '+ @Ac_Job_ID + ' , Run_DATE = '+ CAST( @Ad_Run_DATE AS VARCHAR)+',TypeError CODE = ' +@Lc_ErrorTypeError_CODE+',Line NUMB = ' +CAST(@Li_Line_NUMB AS VARCHAR)+',Error CODE = ' +@Lc_ErrorO157Edit_CODE+',DescriptionError TEXT = ' +@Ls_DescriptionError_TEXT+',ListKey TEXT = '+@Lc_Space_TEXT;
     
     SET @Ls_DescriptionError_TEXT = 'LINE 2A IS GREATER THAN LINE 2 ';
 
     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Ls_Process_NAME,
      @As_Procedure_NAME           = @As_Procedure_NAME,
      @Ac_Job_ID                   = @Ac_Job_ID,
      @Ad_Run_DATE                 = @Ad_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_ErrorTypeError_CODE,
      @An_Line_NUMB                = @Li_Line_NUMB,
      @Ac_Error_CODE               = @Lc_ErrorO157Edit_CODE,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
      @As_ListKey_TEXT             = @Lc_Space_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionErrorOut_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END;
    END;

   SET @Ls_Sql_TEXT = 'CHECK - LINE 2B IS GREATER OR EQUAL THAN LINE 2';
   SET @Ls_SqlData_TEXT = 'LineNo TEXT = '+@Lc_LineNo2b_TEXT;
   SET @Ln_Tot2b_QNTY = (SELECT Tot_QNTY
                            FROM #LineTab_P1
                           WHERE LineNo_TEXT = @Lc_LineNo2b_TEXT);

   IF (@Ln_Tot2b_QNTY >= @Ln_Tot2_QNTY)
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG-11';
     SET @Ls_SqlData_TEXT ='Process_NAME = '+ @Ls_Process_NAME + ' , Procedure_NAME = '+ @As_Procedure_NAME  + ' , Job_ID = '+ @Ac_Job_ID + ' , Run_DATE = '+ CAST( @Ad_Run_DATE AS VARCHAR)+ ' , TypeError CODE = ' +@Lc_ErrorTypeError_CODE+',Line NUMB = ' +CAST(@Li_Line_NUMB AS VARCHAR)+',Error CODE = ' +@Lc_ErrorO157Edit_CODE+',DescriptionError TEXT = ' +@Ls_DescriptionError_TEXT+',ListKey TEXT = '+@Lc_Space_TEXT;
     
     SET @Ls_DescriptionError_TEXT = 'LINE 2B IS GREATER THAN LINE 2 ';

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Ls_Process_NAME,
      @As_Procedure_NAME           = @As_Procedure_NAME,
      @Ac_Job_ID                   = @Ac_Job_ID,
      @Ad_Run_DATE                 = @Ad_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_ErrorTypeError_CODE,
      @An_Line_NUMB                = @Li_Line_NUMB,
      @Ac_Error_CODE               = @Lc_ErrorO157Edit_CODE,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
      @As_ListKey_TEXT             = @Lc_Space_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionErrorOut_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END;
    END;

   SET @Ls_Sql_TEXT = 'CHECK - LINE 2C IS GREATER OR EQUAL THAN LINE 2';
   SET @Ls_SqlData_TEXT = 'LineNo TEXT = '+@Lc_LineNo2c_TEXT;
   SET @Ln_Tot2c_QNTY = (SELECT Tot_QNTY
                            FROM #LineTab_P1
                           WHERE LineNo_TEXT = @Lc_LineNo2c_TEXT);

   IF (@Ln_Tot2c_QNTY >= @Ln_Tot2_QNTY)
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG-12';
     SET @Ls_SqlData_TEXT ='Process_NAME = '+ @Ls_Process_NAME + ' , Procedure_NAME = '+ @As_Procedure_NAME  + ' , Job_ID = '+ @Ac_Job_ID + ' , Run_DATE = '+ CAST( @Ad_Run_DATE AS VARCHAR)+' , TypeError CODE = ' +@Lc_ErrorTypeError_CODE+',Line NUMB = ' +CAST(@Li_Line_NUMB AS VARCHAR)+',Error CODE = ' +@Lc_ErrorO157Edit_CODE+',DescriptionError TEXT = ' +@Ls_DescriptionError_TEXT+',ListKey TEXT = '+@Lc_Space_TEXT;
     
     SET @Ls_DescriptionError_TEXT = 'LINE 2C IS GREATER THAN LINE 2 ';

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Ls_Process_NAME,
      @As_Procedure_NAME           = @As_Procedure_NAME,
      @Ac_Job_ID                   = @Ac_Job_ID,
      @Ad_Run_DATE                 = @Ad_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_ErrorTypeError_CODE,
      @An_Line_NUMB                = @Li_Line_NUMB,
      @Ac_Error_CODE               = @Lc_ErrorO157Edit_CODE,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
      @As_ListKey_TEXT             = @Lc_Space_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionErrorOut_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END;
    END;

   SET @Ls_Sql_TEXT = 'CHECK - LINE 2D IS GREATER OR EQUAL THAN LINE 2';
   SET @Ls_SqlData_TEXT = 'LineNo TEXT = '+@Lc_LineNo2d_TEXT;
   SET @Ln_Tot2d_QNTY = (SELECT Tot_QNTY
                            FROM #LineTab_P1
                           WHERE LineNo_TEXT = @Lc_LineNo2d_TEXT);

   IF (@Ln_Tot2d_QNTY >= @Ln_Tot2_QNTY)
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG-13';
     SET @Ls_SqlData_TEXT ='Process_NAME = '+ @Ls_Process_NAME + ' , Procedure_NAME = '+ @As_Procedure_NAME  + ' , Job_ID = '+ @Ac_Job_ID + ' , Run_DATE = '+ CAST( @Ad_Run_DATE AS VARCHAR)+ ' , TypeError CODE = ' +@Lc_ErrorTypeError_CODE+',Line NUMB = ' +CAST(@Li_Line_NUMB AS VARCHAR)+',Error CODE = ' +@Lc_ErrorO157Edit_CODE+',DescriptionError TEXT = ' +@Ls_DescriptionError_TEXT+',ListKey TEXT = '+@Lc_Space_TEXT;
     
     SET @Ls_DescriptionError_TEXT = 'LINE 2D IS GREATER THAN LINE 2 ';

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Ls_Process_NAME,
      @As_Procedure_NAME           = @As_Procedure_NAME,
      @Ac_Job_ID                   = @Ac_Job_ID,
      @Ad_Run_DATE                 = @Ad_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_ErrorTypeError_CODE,
      @An_Line_NUMB                = @Li_Line_NUMB,
      @Ac_Error_CODE               = @Lc_ErrorO157Edit_CODE,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
      @As_ListKey_TEXT             = @Lc_Space_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionErrorOut_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END;
    END;

   SET @Ls_Sql_TEXT = 'CHECK - LINE 2E IS GREATER OR EQUAL THAN LINE 2';
   SET @Ls_SqlData_TEXT = 'LineNo TEXT = '+@Lc_LineNo2e_TEXT;
   SET @Ln_Tot2e_QNTY = (SELECT Tot_QNTY
                            FROM #LineTab_P1
                           WHERE LineNo_TEXT = @Lc_LineNo2e_TEXT);

   IF (@Ln_Tot2e_QNTY >= @Ln_Tot2_QNTY)
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG-14';
     SET @Ls_SqlData_TEXT ='Process_NAME = '+ @Ls_Process_NAME + ' , Procedure_NAME = '+ @As_Procedure_NAME  + ' , Job_ID = '+ @Ac_Job_ID + ' , Run_DATE = '+ CAST( @Ad_Run_DATE AS VARCHAR)+ ' , TypeError CODE = ' +@Lc_ErrorTypeError_CODE+',Line NUMB = ' +CAST(@Li_Line_NUMB AS VARCHAR)+',Error CODE = ' +@Lc_ErrorO157Edit_CODE+',DescriptionError TEXT = ' +@Ls_DescriptionError_TEXT+',ListKey TEXT = '+@Lc_Space_TEXT;
     
     SET @Ls_DescriptionError_TEXT = 'LINE 2E IS GREATER THAN LINE 2 ';

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Ls_Process_NAME,
      @As_Procedure_NAME           = @As_Procedure_NAME,
      @Ac_Job_ID                   = @Ac_Job_ID,
      @Ad_Run_DATE                 = @Ad_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_ErrorTypeError_CODE,
      @An_Line_NUMB                = @Li_Line_NUMB,
      @Ac_Error_CODE               = @Lc_ErrorO157Edit_CODE,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
      @As_ListKey_TEXT             = @Lc_Space_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionErrorOut_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END;
    END;

   SET @Ls_Sql_TEXT = 'CHECK - LINE 2F IS GREATER OR EQUAL THAN LINE 2';
   SET @Ls_SqlData_TEXT = 'LineNo TEXT = '+@Lc_LineNo2f_TEXT;
   SET @Ln_Tot2f_QNTY = (SELECT Tot_QNTY
                            FROM #LineTab_P1
                           WHERE LineNo_TEXT = @Lc_LineNo2f_TEXT);

   IF (@Ln_Tot2f_QNTY >= @Ln_Tot2_QNTY)
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG-15';
     SET @Ls_SqlData_TEXT = 'Process_NAME = '+ @Ls_Process_NAME + ' , Procedure_NAME = '+ @As_Procedure_NAME  + ' , Job_ID = '+ @Ac_Job_ID + ' , Run_DATE = '+ CAST( @Ad_Run_DATE AS VARCHAR)+ ', TypeError CODE = ' +@Lc_ErrorTypeError_CODE+',Line NUMB = ' +CAST(@Li_Line_NUMB AS VARCHAR)+',Error CODE = ' +@Lc_ErrorO157Edit_CODE+',DescriptionError TEXT = ' +@Ls_DescriptionError_TEXT+',ListKey TEXT = '+@Lc_Space_TEXT;
     
     SET @Ls_DescriptionError_TEXT = 'LINE 2F IS GREATER THAN LINE 2 ';

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Ls_Process_NAME,
      @As_Procedure_NAME           = @As_Procedure_NAME,
      @Ac_Job_ID                   = @Ac_Job_ID,
      @Ad_Run_DATE                 = @Ad_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_ErrorTypeError_CODE,
      @An_Line_NUMB                = @Li_Line_NUMB,
      @Ac_Error_CODE               = @Lc_ErrorO157Edit_CODE,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
      @As_ListKey_TEXT             = @Lc_Space_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionErrorOut_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END;
    END;

   SET @Ls_Sql_TEXT = 'CHECK - LINE 2G IS GREATER OR EQUAL THAN LINE 2';
   SET @Ls_SqlData_TEXT = 'LineNo TEXT = '+@Lc_LineNo2g_TEXT;
   SET @Ln_Tot2g_QNTY = (SELECT Tot_QNTY
                            FROM #LineTab_P1
                           WHERE LineNo_TEXT = @Lc_LineNo2g_TEXT);

   IF (@Ln_Tot2g_QNTY >= @Ln_Tot2_QNTY)
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG-16';
     SET @Ls_SqlData_TEXT ='Process_NAME = '+ @Ls_Process_NAME + ' , Procedure_NAME = '+ @As_Procedure_NAME  + ' , Job_ID = '+ @Ac_Job_ID + ' , Run_DATE = '+ CAST( @Ad_Run_DATE AS VARCHAR)+ ' ,TypeError CODE = ' +@Lc_ErrorTypeError_CODE+',Line NUMB = ' +CAST(@Li_Line_NUMB AS VARCHAR)+',Error CODE = ' +@Lc_ErrorO157Edit_CODE+',DescriptionError TEXT = ' +@Ls_DescriptionError_TEXT+',ListKey TEXT = '+@Lc_Space_TEXT;
     
     SET @Ls_DescriptionError_TEXT = 'LINE 2G IS GREATER THAN LINE 2 ';

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Ls_Process_NAME,
      @As_Procedure_NAME           = @As_Procedure_NAME,
      @Ac_Job_ID                   = @Ac_Job_ID,
      @Ad_Run_DATE                 = @Ad_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_ErrorTypeError_CODE,
      @An_Line_NUMB                = @Li_Line_NUMB,
      @Ac_Error_CODE               = @Lc_ErrorO157Edit_CODE,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
      @As_ListKey_TEXT             = @Lc_Space_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionErrorOut_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END;
    END;

   SET @Ls_Sql_TEXT = 'CHECK - LINE 2H IS GREATER OR EQUAL THAN LINE 2';
   SET @Ls_SqlData_TEXT = 'LineNo TEXT = '+@Lc_LineNo2h_TEXT;
   SET @Ln_Tot2h_QNTY = (SELECT Tot_QNTY
                            FROM #LineTab_P1
                           WHERE LineNo_TEXT = @Lc_LineNo2h_TEXT);

   IF (@Ln_Tot2h_QNTY >= @Ln_Tot2_QNTY)
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG-17';
     SET @Ls_SqlData_TEXT ='Process_NAME = '+ @Ls_Process_NAME + ' , Procedure_NAME = '+ @As_Procedure_NAME  + ' , Job_ID = '+ @Ac_Job_ID + ' , Run_DATE = '+ CAST( @Ad_Run_DATE AS VARCHAR)+',TypeError CODE = ' +@Lc_ErrorTypeError_CODE+',Line NUMB = ' +CAST(@Li_Line_NUMB AS VARCHAR)+',Error CODE = ' +@Lc_ErrorO157Edit_CODE+',DescriptionError TEXT = ' +@Ls_DescriptionError_TEXT+',ListKey TEXT = '+@Lc_Space_TEXT;
     
     SET @Ls_DescriptionError_TEXT = 'LINE 2H IS GREATER THAN LINE 2 ';

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Ls_Process_NAME,
      @As_Procedure_NAME           = @As_Procedure_NAME,
      @Ac_Job_ID                   = @Ac_Job_ID,
      @Ad_Run_DATE                 = @Ad_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_ErrorTypeError_CODE,
      @An_Line_NUMB                = @Li_Line_NUMB,
      @Ac_Error_CODE               = @Lc_ErrorO157Edit_CODE,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
      @As_ListKey_TEXT             = @Lc_Space_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionErrorOut_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END;
    END;

   SET @Ls_Sql_TEXT = 'CHECK - LINE 2I IS GREATER OR EQUAL THAN LINE 2';
   SET @Ls_SqlData_TEXT = 'LineNo TEXT = '+@Lc_LineNo2i_TEXT;
   SET @Ln_Tot2i_QNTY = (SELECT Tot_QNTY
                            FROM #LineTab_P1
                           WHERE LineNo_TEXT = @Lc_LineNo2i_TEXT);

   IF (@Ln_Tot2i_QNTY >= @Ln_Tot2_QNTY)
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG-18';
     SET @Ls_SqlData_TEXT ='Process_NAME = '+ @Ls_Process_NAME + ' , Procedure_NAME = '+ @As_Procedure_NAME  + ' , Job_ID = '+ @Ac_Job_ID + ' , Run_DATE = '+ CAST( @Ad_Run_DATE AS VARCHAR)+' , TypeError CODE = ' +@Lc_ErrorTypeError_CODE+',Line NUMB = ' +CAST(@Li_Line_NUMB AS VARCHAR)+',Error CODE = ' +@Lc_ErrorO157Edit_CODE+',DescriptionError TEXT = ' +@Ls_DescriptionError_TEXT+',ListKey TEXT = '+@Lc_Space_TEXT;
     
     SET @Ls_DescriptionError_TEXT = 'LINE 2I IS GREATER THAN LINE 2 ';

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Ls_Process_NAME,
      @As_Procedure_NAME           = @As_Procedure_NAME,
      @Ac_Job_ID                   = @Ac_Job_ID,
      @Ad_Run_DATE                 = @Ad_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_ErrorTypeError_CODE,
      @An_Line_NUMB                = @Li_Line_NUMB,
      @Ac_Error_CODE               = @Lc_ErrorO157Edit_CODE,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
      @As_ListKey_TEXT             = @Lc_Space_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionErrorOut_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END;
    END;

   SET @Ls_Sql_TEXT = 'CHECK - LINE 2A + 2B + 2C + 2D + 2E + 2F + 2G + 2H + 2I IS EQUAL TO LINE 2';
   SET @Ls_SqlData_TEXT='Tot2 QNTY'+CAST(@Ln_Tot2_QNTY AS VARCHAR);

   IF ((@Ln_Tot2a_QNTY + @Ln_Tot2b_QNTY + @Ln_Tot2c_QNTY + @Ln_Tot2d_QNTY + @Ln_Tot2e_QNTY + @Ln_Tot2f_QNTY + @Ln_Tot2g_QNTY + @Ln_Tot2h_QNTY + @Ln_Tot2i_QNTY) = @Ln_Tot2_QNTY)
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG-19';
     SET @Ls_SqlData_TEXT ='Process_NAME = '+ @Ls_Process_NAME + ' , Procedure_NAME = '+ @As_Procedure_NAME  + ' , Job_ID = '+ @Ac_Job_ID + ' , Run_DATE = '+ CAST( @Ad_Run_DATE AS VARCHAR)+' , TypeError CODE = ' +@Lc_ErrorTypeError_CODE+',Line NUMB = ' +CAST(@Li_Line_NUMB AS VARCHAR)+',Error CODE = ' +@Lc_ErrorO157Edit_CODE+',DescriptionError TEXT = ' +@Ls_DescriptionError_TEXT+',ListKey TEXT = '+@Lc_Space_TEXT;
     
     SET @Ls_DescriptionError_TEXT = 'LINE 2A + 2B + 2C + 2D + 2E + 2F + 2G + 2H + 2I IS EQUAL TO LINE 2 ';

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Ls_Process_NAME,
      @As_Procedure_NAME           = @As_Procedure_NAME,
      @Ac_Job_ID                   = @Ac_Job_ID,
      @Ad_Run_DATE                 = @Ad_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_ErrorTypeError_CODE,
      @An_Line_NUMB                = @Li_Line_NUMB,
      @Ac_Error_CODE               = @Lc_ErrorO157Edit_CODE,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
      @As_ListKey_TEXT             = @Lc_Space_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionErrorOut_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END;
    END;

   SET @Ls_Sql_TEXT = 'CHECK - LINE 5 IS GREATER OR EQUAL THAN LINE 4';
   SET @Ls_SqlData_TEXT = 'LineNo TEXT = '+@Lc_LineNo4_TEXT;
   SET @Ln_Tot4_QNTY = (SELECT Tot_QNTY
                           FROM #LineTab_P1
                          WHERE LineNo_TEXT = @Lc_LineNo4_TEXT);
   SET @Ln_Tot5_QNTY = (SELECT Tot_QNTY
                           FROM #LineTab_P1
                          WHERE LineNo_TEXT = @Lc_LineNo5_TEXT);

   IF (@Ln_Tot5_QNTY >= @Ln_Tot4_QNTY)
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG-21';
     SET @Ls_SqlData_TEXT ='Process_NAME = '+ @Ls_Process_NAME + ' , Procedure_NAME = '+ @As_Procedure_NAME  + ' , Job_ID = '+ @Ac_Job_ID + ' , Run_DATE = '+ CAST( @Ad_Run_DATE AS VARCHAR)+' , TypeError CODE = ' +@Lc_ErrorTypeError_CODE+',Line NUMB = ' +CAST(@Li_Line_NUMB AS VARCHAR)+',Error CODE = ' +@Lc_ErrorO157Edit_CODE+',DescriptionError TEXT = ' +@Ls_DescriptionError_TEXT+',ListKey TEXT = '+@Lc_Space_TEXT;
     
     SET @Ls_DescriptionError_TEXT = 'LINE 5 IS GREATER THAN LINE 4 ';

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Ls_Process_NAME,
      @As_Procedure_NAME           = @As_Procedure_NAME,
      @Ac_Job_ID                   = @Ac_Job_ID,
      @Ad_Run_DATE                 = @Ad_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_ErrorTypeError_CODE,
      @An_Line_NUMB                = @Li_Line_NUMB,
      @Ac_Error_CODE               = @Lc_ErrorO157Edit_CODE,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
      @As_ListKey_TEXT             = @Lc_Space_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionErrorOut_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END;
    END;

   SET @Ls_Sql_TEXT = 'CHECK - LINE 7 IS GREATER OR EQUAL THAN LINE 4';
   SET @Ls_SqlData_TEXT = 'LineNo TEXT = '+@Lc_LineNo7_TEXT;
   SET @Ln_Tot7_QNTY = (SELECT Tot_QNTY
                           FROM #LineTab_P1
                          WHERE LineNo_TEXT = @Lc_LineNo7_TEXT);

   IF (@Ln_Tot7_QNTY >= @Ln_Tot4_QNTY)
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG-20';
     SET @Ls_SqlData_TEXT ='Process_NAME = '+ @Ls_Process_NAME + ' , Procedure_NAME = '+ @As_Procedure_NAME  + ' , Job_ID = '+ @Ac_Job_ID + ' , Run_DATE = '+ CAST( @Ad_Run_DATE AS VARCHAR)+' , TypeError CODE = ' +@Lc_ErrorTypeError_CODE+',Line NUMB = ' +CAST(@Li_Line_NUMB AS VARCHAR)+',Error CODE = ' +@Lc_ErrorO157Edit_CODE+',DescriptionError TEXT = ' +@Ls_DescriptionError_TEXT+',ListKey TEXT = '+@Lc_Space_TEXT;
     
     SET @Ls_DescriptionError_TEXT = 'LINE 7 IS GREATER THAN LINE 4 ';
 
     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Ls_Process_NAME,
      @As_Procedure_NAME           = @As_Procedure_NAME,
      @Ac_Job_ID                   = @Ac_Job_ID,
      @Ad_Run_DATE                 = @Ad_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_ErrorTypeError_CODE,
      @An_Line_NUMB                = @Li_Line_NUMB,
      @Ac_Error_CODE               = @Lc_ErrorO157Edit_CODE,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
      @As_ListKey_TEXT             = @Lc_Space_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionErrorOut_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END;
    END;

   SET @Ls_Sql_TEXT = 'CHECK - LINE 10 IS GREATER OR EQUAL THAN LINE 9';
   SET @Ls_SqlData_TEXT = 'LineNo TEXT = '+@Lc_LineNo10_TEXT;
   SET @Ln_Tot10_QNTY = (SELECT Tot_QNTY
                            FROM #LineTab_P1
                           WHERE LineNo_TEXT = @Lc_LineNo10_TEXT);
   SET @Ln_Tot9_QNTY = (SELECT Tot_QNTY
                           FROM #LineTab_P1
                          WHERE LineNo_TEXT = @Lc_LineNo9_TEXT);

   IF (@Ln_Tot10_QNTY >= @Ln_Tot9_QNTY)
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG-22';
     SET @Ls_SqlData_TEXT ='Process_NAME = '+ @Ls_Process_NAME + ' , Procedure_NAME = '+ @As_Procedure_NAME  + ' , Job_ID = '+ @Ac_Job_ID + ' , Run_DATE = '+ CAST( @Ad_Run_DATE AS VARCHAR)+' , TypeError CODE = ' +@Lc_ErrorTypeError_CODE+',Line NUMB = ' +CAST(@Li_Line_NUMB AS VARCHAR)+',Error CODE = ' +@Lc_ErrorO157Edit_CODE+',DescriptionError TEXT = ' +@Ls_DescriptionError_TEXT+',ListKey TEXT = '+@Lc_Space_TEXT;
     
     SET @Ls_DescriptionError_TEXT = 'LINE 10 IS GREATER THAN LINE 9';

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Ls_Process_NAME,
      @As_Procedure_NAME           = @As_Procedure_NAME,
      @Ac_Job_ID                   = @Ac_Job_ID,
      @Ad_Run_DATE                 = @Ad_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_ErrorTypeError_CODE,
      @An_Line_NUMB                = @Li_Line_NUMB,
      @Ac_Error_CODE               = @Lc_ErrorO157Edit_CODE,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
      @As_ListKey_TEXT             = @Lc_Space_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionErrorOut_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END;
    END;

   SET @Ls_Sql_TEXT = 'CHECK - LINE 18A IS GREATER OR EQUAL THAN LINE 18';
   SET @Ls_SqlData_TEXT = 'LineNo TEXT = '+@Lc_LineNo18a_TEXT;
   SET @Ln_Tot18a_QNTY = (SELECT Tot_QNTY
                             FROM #LineTab_P1
                            WHERE LineNo_TEXT = @Lc_LineNo18a_TEXT);
   SET @Ln_Tot18_QNTY = (SELECT Tot_QNTY
                            FROM #LineTab_P1
                           WHERE LineNo_TEXT = @Lc_LineNo18_TEXT);

   IF (@Ln_Tot18a_QNTY >= @Ln_Tot18_QNTY)
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG-23';
     SET @Ls_SqlData_TEXT ='Process_NAME = '+ @Ls_Process_NAME + ' , Procedure_NAME = '+ @As_Procedure_NAME  + ' , Job_ID = '+ @Ac_Job_ID + ' , Run_DATE = '+ CAST( @Ad_Run_DATE AS VARCHAR)+' , TypeError CODE = ' +@Lc_ErrorTypeError_CODE+',Line NUMB = ' +CAST(@Li_Line_NUMB AS VARCHAR)+',Error CODE = ' +@Lc_ErrorO157Edit_CODE+',DescriptionError TEXT = ' +@Ls_DescriptionError_TEXT+',ListKey TEXT = '+@Lc_Space_TEXT;
     
     SET @Ls_DescriptionError_TEXT = 'LINE 18A IS GREATER THAN LINE 18 ';
 
     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Ls_Process_NAME,
      @As_Procedure_NAME           = @As_Procedure_NAME,
      @Ac_Job_ID                   = @Ac_Job_ID,
      @Ad_Run_DATE                 = @Ad_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_ErrorTypeError_CODE,
      @An_Line_NUMB                = @Li_Line_NUMB,
      @Ac_Error_CODE               = @Lc_ErrorO157Edit_CODE,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
      @As_ListKey_TEXT             = @Lc_Space_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionErrorOut_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END;
    END;

   SET @Ls_Sql_TEXT = 'CHECK - LINE 22 IS GREATER THAN LINE 21';
   SET @Ls_SqlData_TEXT = 'LineNo TEXT = '+@Lc_LineNo22_TEXT;
   SET @Ln_Tot22_QNTY = (SELECT Tot_QNTY
                            FROM #LineTab_P1
                           WHERE LineNo_TEXT = @Lc_LineNo22_TEXT);
   SET @Ln_Tot21_QNTY = (SELECT Tot_QNTY
                            FROM #LineTab_P1
                           WHERE LineNo_TEXT = @Lc_LineNo21_TEXT);

   IF (@Ln_Tot22_QNTY >= @Ln_Tot21_QNTY)
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG-24';
     SET @Ls_SqlData_TEXT ='Process_NAME = '+ @Ls_Process_NAME + ' , Procedure_NAME = '+ @As_Procedure_NAME  + ' , Job_ID = '+ @Ac_Job_ID + ' , Run_DATE = '+ CAST( @Ad_Run_DATE AS VARCHAR)+' , TypeError CODE = ' +@Lc_ErrorTypeError_CODE+',Line NUMB = ' +CAST(@Li_Line_NUMB AS VARCHAR)+',Error CODE = ' +@Lc_ErrorO157Edit_CODE+',DescriptionError TEXT = ' +@Ls_DescriptionError_TEXT+',ListKey TEXT = '+@Lc_Space_TEXT;
     
     SET @Ls_DescriptionError_TEXT = 'LINE 22 IS GREATER THAN LINE 21 ';

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Ls_Process_NAME,
      @As_Procedure_NAME           = @As_Procedure_NAME,
      @Ac_Job_ID                   = @Ac_Job_ID,
      @Ad_Run_DATE                 = @Ad_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_ErrorTypeError_CODE,
      @An_Line_NUMB                = @Li_Line_NUMB,
      @Ac_Error_CODE               = @Lc_ErrorO157Edit_CODE,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
      @As_ListKey_TEXT             = @Lc_Space_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionErrorOut_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END;
    END;

   SET @Ls_Sql_TEXT = 'CHECK - LINE 23 IS GREATER THAN LINE 22';
   SET @Ls_SqlData_TEXT = 'LineNo TEXT = '+@Lc_LineNo23_TEXT;
   SET @Ln_Tot23_QNTY = (SELECT Tot_QNTY
                            FROM #LineTab_P1
                           WHERE LineNo_TEXT = @Lc_LineNo23_TEXT);

   IF (@Ln_Tot23_QNTY >= @Ln_Tot22_QNTY)
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG-25';
     SET @Ls_SqlData_TEXT ='Process_NAME = '+ @Ls_Process_NAME + ' , Procedure_NAME = '+ @As_Procedure_NAME  + ' , Job_ID = '+ @Ac_Job_ID + ' , Run_DATE = '+ CAST( @Ad_Run_DATE AS VARCHAR)+' , TypeError CODE = ' +@Lc_ErrorTypeError_CODE+',Line NUMB = ' +CAST(@Li_Line_NUMB AS VARCHAR)+',Error CODE = ' +@Lc_ErrorO157Edit_CODE+',DescriptionError TEXT = ' +@Ls_DescriptionError_TEXT+',ListKey TEXT = '+@Lc_Space_TEXT;
     
     SET @Ls_DescriptionError_TEXT = 'LINE 23 IS GREATER THAN LINE 22';

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Ls_Process_NAME,
      @As_Procedure_NAME           = @As_Procedure_NAME,
      @Ac_Job_ID                   = @Ac_Job_ID,
      @Ad_Run_DATE                 = @Ad_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_ErrorTypeError_CODE,
      @An_Line_NUMB                = @Li_Line_NUMB,
      @Ac_Error_CODE               = @Lc_ErrorO157Edit_CODE,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
      @As_ListKey_TEXT             = @Lc_Space_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionErrorOut_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END;
    END;

   SET @Ls_Sql_TEXT = 'CHECK - LINE 29 IS GREATER THAN LINE 28';
   SET @Ls_SqlData_TEXT = 'LineNo TEXT = '+@Lc_LineNo29_TEXT;
   SET @Ln_Tot29_QNTY = (SELECT Tot_QNTY
                            FROM #LineTab_P1
                           WHERE LineNo_TEXT = @Lc_LineNo29_TEXT);
   SET @Ln_Tot28_QNTY = (SELECT Tot_QNTY
                            FROM #LineTab_P1
                           WHERE LineNo_TEXT = @Lc_LineNo28_TEXT);

   IF (@Ln_Tot29_QNTY >= @Ln_Tot28_QNTY)
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG-26';
     SET @Ls_SqlData_TEXT ='Process_NAME = '+ @Ls_Process_NAME + ' , Procedure_NAME = '+ @As_Procedure_NAME  + ' , Job_ID = '+ @Ac_Job_ID + ' , Run_DATE = '+ CAST( @Ad_Run_DATE AS VARCHAR)+' , TypeError CODE = ' +@Lc_ErrorTypeError_CODE+',Line NUMB = ' +CAST(@Li_Line_NUMB AS VARCHAR)+',Error CODE = ' +@Lc_ErrorO157Edit_CODE+',DescriptionError TEXT = ' +@Ls_DescriptionError_TEXT+',ListKey TEXT = '+@Lc_Space_TEXT;
     
     SET @Ls_DescriptionError_TEXT = 'LINE 29 IS GREATER THAN LINE 28';

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Ls_Process_NAME,
      @As_Procedure_NAME           = @As_Procedure_NAME,
      @Ac_Job_ID                   = @Ac_Job_ID,
      @Ad_Run_DATE                 = @Ad_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_ErrorTypeError_CODE,
      @An_Line_NUMB                = @Li_Line_NUMB,
      @Ac_Error_CODE               = @Lc_ErrorO157Edit_CODE,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
      @As_ListKey_TEXT             = @Lc_Space_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionErrorOut_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END;
    END;

   DROP TABLE #LineTab_P1;

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   IF OBJECT_ID('tempdb..#LineTab_P1') IS NOT NULL
    BEGIN
     DROP TABLE #LineTab_P1;
    END;

   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   DECLARE
		@Li_Error_NUMB INT = ERROR_NUMBER (),
		@Li_ErrorLine_NUMB INT = ERROR_LINE ();

   IF (@Li_Error_NUMB <> 50001)
   BEGIN
	 SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
   END;

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION @As_Procedure_NAME = @Ls_Procedure_NAME,
                                   @As_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT,
                                   @As_Sql_TEXT = @Ls_Sql_TEXT,
                                   @As_Sqldata_TEXT = @Ls_SqlData_TEXT,
                                   @An_Error_NUMB = @Li_Error_NUMB,
                                   @An_ErrorLine_NUMB = @Li_ErrorLine_NUMB,
                                   @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT ;

   SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
  END CATCH;
 END;


GO
