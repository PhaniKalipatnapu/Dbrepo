/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICE_WORKER$SP_GET_WORKER_ESIGN_DETAILS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICE_WORKER$SP_GET_WORKER_ESIGN_DETAILS
Programmer Name	:	IMP Team.
Description		:	
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
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICE_WORKER$SP_GET_WORKER_ESIGN_DETAILS] (
   @An_Case_IDNO                      NUMERIC (6),
   @Ad_Run_DATE                       DATE,
   @Ac_Role_ID                        CHAR (10),
   @Ac_Worker_ID                      CHAR (6),
   @Ac_Msg_CODE                       CHAR (3) OUTPUT,
   @As_DescriptionError_TEXT          VARCHAR (4000) OUTPUT
   )
AS
   BEGIN
      DECLARE
         @Lc_StatusSuccess_CODE CHAR (1) = 'S',
         @Lc_StatusFailed_CODE CHAR (1) = 'F',
         @Ls_Procedure_NAME VARCHAR (100)   = 'BATCH_GEN_NOTICE_WORKER$SP_GET_WORKER_ESIGN_DETAILS',
         @Ld_High_DATE DATE = '12/31/9999';

      DECLARE
         @Ls_Sql_TEXT VARCHAR (200),
         @Ls_Sqldata_TEXT VARCHAR (400),
         @Ls_Err_Description_TEXT VARCHAR (4000);

      BEGIN TRY
         SET @Ac_Msg_CODE = NULL;
         SET @As_DescriptionError_TEXT = NULL;
         SET @Ls_Sqldata_TEXT =
                  ' Case_IDNO = '
                + ISNULL (@Ac_Worker_ID, '')
                + 'Seq_IDNO ROLE'
                + ISNULL (@Ac_Role_ID, '');
         SET @Ls_Sql_TEXT = ' SELECT CWRK_Y1 USEM_Y1';

         INSERT INTO #NoticeElementsData_P1 (Element_NAME, Element_VALUE)
            (SELECT Element_NAME, Element_VALUE
               FROM (SELECT CONVERT (VARCHAR (100), a.TransactionEventSeq_NUMB) AS  ESIGN_NOTARY,
                            CONVERT (VARCHAR (100), a.Name) AS WORKER_NAME,
                            CONVERT (VARCHAR (100), a.Worker_ID) AS WORKER_ID,
                            CONVERT (VARCHAR (100), a.Role_ID) AS ROLE_ID,
                            CONVERT (VARCHAR (100), a.Case_IDNO) AS   WORKER_CASE_IDNO,
                            CONVERT (VARCHAR (100), a.Effective_DATE) AS   EFFECTIVE_DATE,
                            CONVERT (VARCHAR (100), a.Expire_DATE) AS EXPIRE_DATE,
                            CONVERT (VARCHAR (100), a.EndValidity_DATE) AS   ENDVALIDITY_DATE,
                            CONVERT (VARCHAR (100),a.ESignature_BIN)  AS ESignature_BIN
                       FROM (SELECT DISTINCT TOP 1
                                    c.TransactionEventSeq_NUMB,
                                    (a.First_NAME + ' ' + a.Last_NAME) AS Name,
                                    a.Worker_ID,
                                    b.Role_ID,
                                    b.Case_IDNO,
                                    b.Effective_DATE,
                                    b.Expire_DATE,
                                    b.EndValidity_DATE,
                                    c.ESignature_BIN
                               FROM USEM_Y1 a
                                    LEFT OUTER JOIN CWRK_Y1 b
                                       ON a.Worker_ID = b.Worker_ID
                                    LEFT OUTER JOIN USES_Y1 c
                                       ON c.Worker_ID = b.Worker_ID
                              WHERE b.Role_ID = @Ac_Role_ID
                                    AND b.Case_IDNO = @An_Case_IDNO
                                    AND @Ad_Run_DATE BETWEEN b.Effective_DATE
                                                         AND b.Expire_DATE
                                    AND b.EndValidity_DATE = @Ld_High_DATE
                                    AND a.EndValidity_DATE = @Ld_High_DATE
                                    AND LTRIM (RTRIM ( c.ESignature_BIN)) != ''
                                         ) a) up UNPIVOT (Element_VALUE FOR Element_NAME IN (ESIGN_NOTARY, WORKER_NAME, WORKER_ID,
                                                    ROLE_ID, WORKER_CASE_IDNO, EFFECTIVE_DATE, EXPIRE_DATE,
                                                    ENDVALIDITY_DATE, ESignature_BIN)) AS pvt);

         SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
      END TRY
      BEGIN CATCH
         SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
         DECLARE
            @Li_Error_NUMB INT = ERROR_NUMBER (),
            @Li_ErrorLine_NUMB INT = ERROR_LINE ();

         IF (@Li_Error_NUMB <> 50001)
            BEGIN
               SET @Ls_Err_Description_TEXT =
                      SUBSTRING (ERROR_MESSAGE (), 1, 200);
            END

         EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION @As_Procedure_NAME = @Ls_Procedure_NAME,
                                                       @As_ErrorMessage_TEXT = @Ls_Err_Description_TEXT,
                                                       @As_Sql_TEXT = @Ls_Sql_TEXT,
                                                       @As_Sqldata_TEXT = @Ls_SqlData_TEXT,
                                                       @An_Error_NUMB = @Li_Error_NUMB,
                                                       @An_ErrorLine_NUMB = @Li_ErrorLine_NUMB,
                                                       @As_DescriptionError_TEXT = @Ls_Err_Description_TEXT OUTPUT ;

         SET @As_DescriptionError_TEXT = @Ls_Err_Description_TEXT;
      END CATCH
   END

GO
