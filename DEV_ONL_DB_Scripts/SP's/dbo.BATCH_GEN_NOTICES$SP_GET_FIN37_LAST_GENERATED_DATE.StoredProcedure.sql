/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICES$SP_GET_FIN37_LAST_GENERATED_DATE]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
 -----------------------------------------------------------------------------------------
 Procedure Name     :BATCH_GEN_NOTICES$SP_GET_FIN37_LAST_GENERATED_DATE
 Programmer Name    : IMP Team
 Description        :The procedure gets FIN37 last generated date
 Frequency          :
 Developed On       :12/23/2011
 Called By          :
 Called On          :
------------------------------------------------------------------------------------------
 Modified By        :
 Modified On        :
 Version No         :  1.0
 -----------------------------------------------------------------------------------------
*/

CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICES$SP_GET_FIN37_LAST_GENERATED_DATE] (
   @An_Case_IDNO                      NUMERIC (6),
   @Ac_Msg_CODE                       CHAR (5) OUTPUT,
   @As_DescriptionError_TEXT          VARCHAR (4000) OUTPUT
   )
AS
   BEGIN
      SET  NOCOUNT ON;
      DECLARE
         @Li_RowCount_NUMB         INT=0,
         @Lc_StatusFailed_CODE CHAR (1) = 'F',
         @Lc_StatusSuccess_CODE CHAR (1) = 'S',
         @Lc_NoticeFin37_ID CHAR (10) = 'FIN-37',
         @Ls_Procedure_NAME VARCHAR (100) = 'BATCH_GEN_NOTICES$SP_GET_FIN37_LAST_GENERATED_DATE';

      DECLARE
         @Ls_Sql_TEXT VARCHAR (100) = '',
         @Ls_Sqldata_TEXT VARCHAR (1000) = '',
         @Ls_DescriptionError_TEXT VARCHAR (4000);

      BEGIN TRY
         SET @Ls_Sql_TEXT = 'SELECT NRRQ_Y1';
         SET @Ls_Sqldata_TEXT =
                  ' Case_IDNO = '        + CAST (ISNULL (@An_Case_IDNO, '') AS VARCHAR (6));
		INSERT INTO #NoticeElementsData_P1
		             (Element_NAME,
		              Element_Value)
            (SELECT Element_NAME, Element_Value
               FROM (SELECT CONVERT (CHAR (10), FIN37_Last_Generated_Date) AS  FIN37_Last_Generated_Date
                       FROM ( SELECT CAST( MAX(NR.Generate_DTTM)  AS DATE) AS FIN37_Last_Generated_Date
                               FROM NRRQ_Y1 NR
                              WHERE Notice_ID = @Lc_NoticeFin37_ID
                              AND NR.Case_IDNO= @An_Case_IDNO) 
                               a )
                               up UNPIVOT (Element_Value
                                      FOR Element_NAME IN  (FIN37_Last_Generated_Date)) AS pvt);
           SET @Li_RowCount_NUMB  = @@ROWCOUNT;
        IF @Li_RowCount_NUMB  = 0
			BEGIN
			SET @Ls_Sql_TEXT = 'SELECT NMRQ_Y1';
            SET @Ls_Sqldata_TEXT =
                  ' Case_IDNO = '        + CAST (ISNULL (@An_Case_IDNO, '') AS VARCHAR (6));
				INSERT INTO #NoticeElementsData_P1 
				            (Element_NAME, 
				             Element_Value)
				(SELECT Element_NAME, Element_Value
				   FROM (SELECT CONVERT (CHAR (10), FIN37_Last_Generated_Date) AS  FIN37_Last_Generated_Date
						   FROM ( SELECT CAST( MAX(NR.UPDATE_DTTM)  AS DATE) AS FIN37_Last_Generated_Date
								   FROM NMRQ_Y1 NR
                              WHERE Notice_ID = @Lc_NoticeFin37_ID
                              AND NR.Case_IDNO= @An_Case_IDNO) 
								a )
                               up UNPIVOT (Element_Value
                                      FOR Element_NAME IN  (FIN37_Last_Generated_Date)) AS pvt);
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
               SET @Ls_DescriptionError_TEXT =   SUBSTRING (ERROR_MESSAGE (), 1, 200);
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
