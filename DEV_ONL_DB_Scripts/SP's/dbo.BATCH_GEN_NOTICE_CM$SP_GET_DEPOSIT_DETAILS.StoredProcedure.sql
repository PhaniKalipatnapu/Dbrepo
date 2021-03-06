/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICE_CM$SP_GET_DEPOSIT_DETAILS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICE_CM$SP_GET_DEPOSIT_DETAILS](
 @Ac_CheckRecipient_ID     CHAR(10),
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
 )
AS
/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name          : BATCH_GEN_NOTICE_CM$SP_GET_DEPOSIT_DETAILS
Programmer Name         : IMP Team
Description             : Get Deposit details
Frequency               :
Developed On            : 12/23/2011
Called BY               :
Called On               :
-------------------------------------------------------------------------------------------------------------------------
Modified BY             :
Modified On             :
Version No              : 1.0
--------------------------------------------------------------------------------------------------------------------
*/

 BEGIN
  SET NOCOUNT ON;
  DECLARE @Li_Error_NUMB			INT    = NULL,
          @Li_ErrorLine_NUMB		INT = NULL,
          @Li_RowCount_NUMB			INT = 0,
          @Lc_StatusSuccess_CODE   CHAR(1) = 'S',
          @Lc_StatusFailed_CODE    CHAR(1) = 'F',
          @Lc_StatusActive_CODE   CHAR(1) = 'A' ,
          @Lc_Checked_TEXT CHAR(1) = 'X',
          @Ls_Procedure_NAME         VARCHAR(100) = 'BATCH_GEN_NOTICE_CM$SP_GET_DEPOSIT_DETAILS ',
          @Ld_High_DATE           DATE = '12/31/9999';
          
 DECLARE  @Lc_Dcrs_CODE				CHAR(1) = '',
          @Lc_Eftr_CODE				CHAR(1) = '',
          @Ls_Sql_TEXT				VARCHAR(200) = '',
          @Ls_Sqldata_TEXT			VARCHAR(400) = '',
          @Ls_DescriptionError_TEXT VARCHAR(4000);
         
  BEGIN TRY
   SET @Ac_Msg_CODE = NULL;
   SET @As_DescriptionError_TEXT = NULL;
   SET @Ls_Sql_TEXT = 'SELECT DCRS_Y1';
   SET @Ls_Sqldata_TEXT = ' CheckRecipient_ID = ' + ISNULL(CAST(@Ac_CheckRecipient_ID AS VARCHAR), '');

   SELECT @Lc_Dcrs_CODE = @Lc_Checked_TEXT
     FROM DCRS_Y1 a
    WHERE A.CheckRecipient_ID = @Ac_CheckRecipient_ID
      AND A.Status_CODE       = @Lc_StatusActive_CODE 
      AND a.EndValidity_Date = @Ld_High_DATE;

   SET @Ls_Sql_TEXT = 'SELECT EFTR_Y1';

   SELECT @Lc_Eftr_CODE = @Lc_Checked_TEXT
     FROM EFTR_Y1 b
    WHERE b.CheckRecipient_ID = @Ac_CheckRecipient_ID
      AND b.StatusEft_CODE = 'AC'
      AND b.EndValidity_Date = @Ld_High_DATE;
 
   INSERT INTO #NoticeElementsData_P1
               (Element_NAME,
                Element_Value)
   (SELECT pvt.Element_NAME,
           pvt.Element_Value
      FROM (SELECT  H.IND_DIRECT_DEPOSIT_CODE,
                    H.IND_STATE_FAMILY_CARD_CODE
              FROM (SELECT @Lc_Eftr_CODE AS IND_DIRECT_DEPOSIT_CODE,
                           @Lc_Dcrs_CODE AS IND_STATE_FAMILY_CARD_CODE) h)up 
                 UNPIVOT (Element_Value FOR Element_NAME IN ( IND_DIRECT_DEPOSIT_CODE, IND_STATE_FAMILY_CARD_CODE )) AS pvt);
      SET @Li_RowCount_NUMB  = @@ROWCOUNT;
      
      IF (@Li_RowCount_NUMB != 0 )
            BEGIN
                  SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
                  RETURN;
            END
    ELSE IF( @Li_RowCount_NUMB = 0 )
            BEGIN
                  SET @Ac_Msg_CODE = 'E0058';
                  SET @As_DescriptionError_TEXT = 'No Data Found';
                  RETURN;
            END
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   SET @Li_Error_NUMB = ERROR_NUMBER();
   SET @Li_ErrorLine_NUMB = ERROR_LINE();

   IF (@Li_Error_NUMB <> 50001 )
    BEGIN
     SET @Ls_DescriptionError_TEXT = SUBSTRING(ERROR_MESSAGE(), 1, 200);
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
