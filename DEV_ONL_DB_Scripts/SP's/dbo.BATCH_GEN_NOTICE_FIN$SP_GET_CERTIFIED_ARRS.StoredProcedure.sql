/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICE_FIN$SP_GET_CERTIFIED_ARRS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICE_FIN$SP_GET_CERTIFIED_ARRS
Programmer Name	:	IMP Team.
Description		:	
Frequency		:	
Developed On	:	2/17/2012
Called By		:	
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICE_FIN$SP_GET_CERTIFIED_ARRS](
 @An_Case_IDNO             NUMERIC(6),
 @An_NcpMemberMci_IDNO	   NUMERIC(10),
 @An_OrderSeq_NUMB         NUMERIC(2),
 @Ac_Msg_CODE              VARCHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE 
          @Lc_StatusSuccess_CODE     CHAR(1) = 'S',
          @Lc_StatusFailed_CODE      CHAR(1) = 'F',
          @Ls_Procedure_NAME         VARCHAR(100) ='BATCH_GEN_NOTICE_FIN.BATCH_GEN_NOTICE_FIN$SP_GET_CERTIFIED_ARRS ' ,
          @Ld_High_DATE              DATE = '12/31/9999';
   DECLARE    
          @Ls_Sql_TEXT               VARCHAR(200),
          @Ls_Sqldata_TEXT           VARCHAR(1000),
          @Ls_DescriptionError_TEXT  VARCHAR(4000),
          @Ln_Arrear_AMNT            NUMERIC(11, 2),
          @Ld_SubmitLast_DATE        DATE;
         

  BEGIN TRY
   SET @Ln_Arrear_AMNT = NULL;
   SET @Ld_SubmitLast_DATE = NULL;
   SET @Ac_Msg_CODE = NULL;
   SET @As_DescriptionError_TEXT = NULL;
   SET @Ln_Arrear_AMNT = NULL;
   SET @Ld_SubmitLast_DATE = NULL;
   SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + CAST(ISNULL(@An_Case_IDNO, 0) AS CHAR(6)) 
         + ' OrderSeq_NUMB = ' + ISNULL(CAST(@An_OrderSeq_NUMB AS CHAR(3)), '');
   SET @Ls_Sql_TEXT = 'SELECT CBOR_Y1';

   IF (@An_Case_IDNO IS NOT NULL
       AND @An_Case_IDNO <> 0 )
   BEGIN    
    SELECT @Ln_Arrear_AMNT = c.Arrear_AMNT,
           @Ld_SubmitLast_DATE = c.SubmitForm_DATE
      FROM CBOR_Y1 c
     WHERE c.Case_IDNO = @An_Case_IDNO
       AND c.MemberMci_IDNO = @An_NcpMemberMci_IDNO 
       AND c.OrderSeq_NUMB = @An_OrderSeq_NUMB
       AND c.EndValidity_DATE = @Ld_High_DATE

   INSERT INTO #NoticeElementsData_P1
               (Element_NAME,
                Element_Value)
   (SELECT Element_NAME,
           Element_Value
      FROM (SELECT CONVERT(VARCHAR(100), CERTIFIED_ARREARS) CERTIFIED_ARREARS,
                   CONVERT(VARCHAR(100), DT_CERTIFIED_ARREARS) DT_CERTIFIED_ARREARS
              FROM (SELECT @Ln_Arrear_AMNT AS CERTIFIED_ARREARS,
                           @Ld_SubmitLast_DATE AS DT_CERTIFIED_ARREARS) h)up UNPIVOT (Element_Value FOR Element_NAME IN ( CERTIFIED_ARREARS, DT_CERTIFIED_ARREARS )) AS pvt);
    END
   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
    SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
         DECLARE @Li_Error_NUMB INT, @Li_ErrorLine_NUMB INT;

         SET @Li_Error_NUMB = ERROR_NUMBER ();
         SET @Li_ErrorLine_NUMB = ERROR_LINE ();

         IF (@Li_Error_NUMB <> 50001)
            BEGIN
               SET @Ls_DescriptionError_TEXT =  SUBSTRING (ERROR_MESSAGE (), 1, 200);
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
