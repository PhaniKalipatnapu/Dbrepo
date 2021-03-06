/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICE_FIN$SP_GET_TOTAL_OVERPAYAY_AMNT]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICE_FIN$SP_GET_TOTAL_OVERPAYAY_AMNT
Programmer Name	:	IMP Team.
Description		:	The procedure gets total amount which needs to be recovered from CP
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
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICE_FIN$SP_GET_TOTAL_OVERPAYAY_AMNT] (
 @An_Case_IDNO             NUMERIC(6),
 @Ac_Notice_ID             CHAR (8),
 @Ac_CheckRecipient_ID     CHAR (10),
 @Ad_Run_DATE              DATE,
 @Ac_Msg_CODE              CHAR (5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR (4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Li_Error_NUMB            INT = NULL,
          @Li_ErrorLine_NUMB        INT = NULL,
          @Lc_StatusFailed_CODE  CHAR (1) = 'F',
          @Lc_StatusSuccess_CODE CHAR (1) = 'S',
          @Lc_Fin_39_Notice_ID  CHAR(8) = 'FIN-39',
          @Ls_Total_Balance_Due_Cp_Amnt_NAME      VARCHAR(45)= 'TOTAL_BALANCE_DUE_CP_AMNT',
          @Ls_Procedure_NAME     VARCHAR (100) = 'BATCH_GEN_NOTICE_FIN$SP_GET_TOTAL_OVERPAYAY_AMNT ';
  DECLARE @Ls_Sql_TEXT              VARCHAR (100) = '',
          @Ls_Sqldata_TEXT          VARCHAR (1000) = '',
          @Ls_DescriptionError_TEXT VARCHAR (4000);

  BEGIN TRY
      IF @Ac_Notice_ID = @Lc_Fin_39_Notice_ID
      BEGIN
      SET @Ls_Sql_TEXT = 'SELECT DATE';
      SET @Ls_Sqldata_TEXT = ' CHECKRECIPIENT_IDNO = ' + ISNULL (@Ac_CheckRecipient_ID, '') + 'Case_IDNO ='+ CAST(ISNULL(@An_Case_IDNO,0) AS VARCHAR(6))+ 'TOTAL_BALANCE_DUE_CP_AMNT= '+ @Ls_Total_Balance_Due_Cp_Amnt_NAME;
      INSERT INTO #NoticeElementsData_P1
			(Element_NAME,
			Element_Value)
      SELECT @Ls_Total_Balance_Due_Cp_Amnt_NAME AS Element_NAME,  
          SUM (Transaction_AMNT) AS Element_Value  
		  FROM CPNO_Y1 A  
		WHERE A.CheckRecipient_ID = @Ac_CheckRecipient_ID  
      AND A.CheckRecipient_CODE = 1  
      AND A.Case_IDNO = @An_Case_IDNO   
      AND A.Notice_ID IN (SELECT TOP 1 c.Notice_ID  
							FROM CPNO_Y1 c 
							WHERE c.Case_IDNO=A.Case_IDNO  
							ORDER BY c.StatusUpdate_DATE DESC);  
	  END
	  ELSE
	  BEGIN
			SET @Ls_Sql_TEXT = 'SELECT DATE';
			SET @Ls_Sqldata_TEXT = ' CheckRecipient_ID = ' + ISNULL (@Ac_CheckRecipient_ID, '') +'CheckRecipient_CODE = 1 Case_IDNO ='+ CAST(ISNULL(@An_Case_IDNO,0) AS VARCHAR(6))+'Notice_ID = ' + ISNULL (@Ac_Notice_ID, '') +' Notice_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + 'TOTAL_BALANCE_DUE_CP_AMNT= '+ @Ls_Total_Balance_Due_Cp_Amnt_NAME;;
			INSERT INTO #NoticeElementsData_P1
				(Element_NAME,
				Element_Value)
			SELECT @Ls_Total_Balance_Due_Cp_Amnt_NAME AS Element_NAME,
				  SUM (Transaction_AMNT) AS Element_Value 
				  FROM CPNO_Y1 A
			WHERE A.CheckRecipient_ID = @Ac_CheckRecipient_ID
			AND A.CheckRecipient_CODE = 1
			AND A.Case_IDNO = @An_Case_IDNO 
			AND A.Notice_ID  = @Ac_Notice_ID 
			AND A.Notice_DATE =  @Ad_Run_DATE;
	  END
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
