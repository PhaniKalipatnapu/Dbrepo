/****** Object:  StoredProcedure [dbo].[BATCH_RPT_OCSE157$SP_POPULATE_EMPTY_LINES]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name          : BATCH_RPT_OCSE157$SP_POPULATE_EMPTY_LINES
Programmer Name			: IMP Team
Description             : This procedure is used for generating annually OCSE-157 report
Frequency               : YEARLY
Developed On            : 06/16/2011
Called BY               : This procedure is called by BATCH_RPT_OCSE157$SP_GENERATE_OCSE157 and BATCH_RPT_OCSE157$SP_INSERT_LINE_2527
Called On               : 
--------------------------------------------------------------------------------------------------------------------
Modified BY             :
Modified On             :
Version No              : 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_RPT_OCSE157$SP_POPULATE_EMPTY_LINES] (
 @Ad_BeginFiscal_DATE DATE,
 @Ad_EndFiscal_DATE   DATE,
 @Ac_TypeReport_CODE  CHAR(1),
 @Ac_Line_NUMB        CHAR(3),
 @Ac_Msg_CODE         CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE 
          @Li_Value_QNTY         SMALLINT =0,
          @Lc_LineNo8_TEXT       CHAR(1) = '8',
          @Lc_LineNo9_TEXT       CHAR(1) = '9',
          @Lc_Space_TEXT         CHAR(1) = ' ',
          @Lc_StatusFailed_CODE  CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE CHAR(1) = 'S',
          @Lc_Msg_CODE           CHAR(1) = NULL,
          @Lc_LineNo8a_TEXT      CHAR(2) = '8A',
          @Lc_LineNo10_TEXT      CHAR(2) = '10',
          @Ls_Procedure_NAME     VARCHAR(100) = 'BATCH_RPT_OCSE157$SP_POPULATE_EMPTY_LINES',
          @Ls_ErrorDesc_TEXT     VARCHAR(4000) = NULL;
          
   DECLARE
          @Li_RowCount_QNTY      SMALLINT,
          @Ls_Sql_TEXT           VARCHAR(200),
          @Ls_Sqldata_TEXT       VARCHAR(1000);

  BEGIN TRY
   SET @Ls_Sql_TEXT = 'SELECT RC157_Y1';
   SET @Ls_Sqldata_TEXT = 'BeginFiscal_DATE : ' + ISNULL(CAST(@Ad_BeginFiscal_DATE AS VARCHAR), '') + 'EndFiscal_DATE : ' 
			+ ISNULL(CAST(@Ad_EndFiscal_DATE AS VARCHAR), '') + 'TypeReport_CODE :' 
			+ ISNULL(@Ac_TypeReport_CODE, '') + 'LineNo_TEXT : ' + ISNULL(@Ac_Line_NUMB, '');
   SET @Li_Value_QNTY = 0;

   SELECT TOP 1 @Li_Value_QNTY = 1
     FROM RO157_Y1 r
    WHERE r.BeginFiscal_DATE = @Ad_BeginFiscal_DATE
      AND r.EndFiscal_DATE = @Ad_EndFiscal_DATE
      AND (r.TypeReport_CODE = @Ac_TypeReport_CODE
            OR (r.LineNo_TEXT IN (@Lc_LineNo8_TEXT, @Lc_LineNo8a_TEXT, @Lc_LineNo9_TEXT, @Lc_LineNo10_TEXT)))
      AND r.LineNo_TEXT = @Ac_Line_NUMB;

   IF @Li_Value_QNTY = 0
    BEGIN
     SET @Ls_Sql_TEXT = 'INSERT RC157_Y1';
     SET @Ls_Sqldata_TEXT ='BeginFiscal_DATE : '+ISNULL(CAST(@Ad_BeginFiscal_DATE AS VARCHAR), '')+'EndFiscal_DATE : '+ISNULL(CAST(@Ad_EndFiscal_DATE AS VARCHAR), '')+'TypeReport_CODE : '+ISNULL(@Ac_TypeReport_CODE,'')
     +'Office_IDNO : '+'0'+'County_IDNO : '+'0'+'Worker_ID : '+@Lc_Space_TEXT+'LineNo_TEXT : '+CAST(@Ac_Line_NUMB AS VARCHAR)+
     'Tot_QNTY : '+'0'+'Ca_AMNT : '+'0'+'Fa_AMNT : '+'0'+'Na_AMNT : '+'0';
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
     VALUES ( @Ad_BeginFiscal_DATE, --BeginFiscal_DATE
              @Ad_EndFiscal_DATE,  --EndFiscal_DATE
              @Ac_TypeReport_CODE, --TypeReport_CODE
              0,			--Office_IDNO
              0,            --County_IDNO
              @Lc_Space_TEXT,--Worker_ID
              @Ac_Line_NUMB, --LineNo_TEXT
              0,--Tot_QNTY
              0,--Ca_AMNT
              0,--Fa_AMNT
              0 );--Na_AMNT

     SET @Li_RowCount_QNTY = @@ROWCOUNT;

     IF @Li_RowCount_QNTY = 0
      BEGIN
       SET @Lc_Msg_CODE = @Lc_StatusFailed_CODE;
       SET @Ls_ErrorDesc_TEXT = 'INSERT RC157_Y1 FAILED';
       RAISERROR(50001,16,1);
      END;
    END;

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY
  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   DECLARE
		@Li_Error_NUMB INT = ERROR_NUMBER (),
		@Li_ErrorLine_NUMB INT = ERROR_LINE ();
  DECLARE
		@Ls_DescriptionError_TEXT VARCHAR(1000);

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
