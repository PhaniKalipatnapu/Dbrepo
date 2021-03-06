/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICE_CNET$SP_GET_CSENET_FAR_DTLS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 

/*
---------------------------------------------------------
 Procedure Name    : BATCH_GEN_NOTICE_CNET$SP_GET_CSENET_FAR_DTLS
 Programmer Name   : IMP Team.
 Description       : Get CSENET function action reason detail 
 Frequency         :
 Developed On      : 12/27/2011
 Called By         :
 Called On         :
---------------------------------------------------------
 Modified By       :
 Modified On       :
 Version No        : 1.0
---------------------------------------------------------
*/   

CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICE_CNET$SP_GET_CSENET_FAR_DTLS](
 @An_Request_IDNO           NUMERIC(9),
 @Ac_IVDOutOfStateFips_CODE CHAR(2),
 @Ad_Generated_DATE         DATE,
 @Ac_Msg_CODE               CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT  VARCHAR(4000) OUTPUT)
AS
 BEGIN
  SET NOCOUNT ON;
  DECLARE @Lc_StatusSuccess_CODE     CHAR(1) = 'S',
          @Lc_StatusFailed_CODE      CHAR(1) = 'F',
          @Ls_Procedure_NAME         VARCHAR(100) =  'BATCH_GEN_NOTICE_CNET$SP_GET_CSENET_FAR_DTLS ',
          @Ld_High_DATE              DATE = '12/31/9999',
          @Ls_Sql_TEXT               VARCHAR(200),
          @Ls_Sqldata_TEXT           VARCHAR(400),
          @Ls_DescriptionError_TEXT  VARCHAR(4000);

  BEGIN TRY
   SET @Ac_Msg_CODE = NULL;
   SET @As_DescriptionError_TEXT = NULL;
   SET @Ls_Sqldata_TEXT = '  Request_IDNO = ' + ISNULL(CAST(@An_Request_IDNO AS VARCHAR), '') 
                           + ' IVDOutOfStateFips_CODE=' + ISNULL(@Ac_IVDOutOfStateFips_CODE, '');
   SET @Ls_Sql_TEXT = 'SELECT CSPR_Y1 ';
  
   INSERT INTO #NoticeElementsData_P1
               (Element_NAME,
                Element_VALUE)
   (SELECT pvt.Element_NAME,
           pvt.Element_VALUE
      FROM (SELECT CONVERT(CHAR(5), A.Action_CODE)  AS Action_CODE,
                   CONVERT(CHAR(5), A.Function_CODE) AS Function_CODE,
                   CONVERT(CHAR(5), A.Reason_CODE ) AS Reason_CODE
              FROM (SELECT c.Action_CODE,
                           c.Function_CODE,
                           c.Reason_CODE
                      FROM CSPR_Y1  c
                     WHERE c.Request_IDNO = @An_Request_IDNO
                       AND c.Generated_DATE = @Ad_Generated_DATE
                       AND c.IVDOutOfStateFips_CODE = @Ac_IVDOutOfStateFips_CODE
                       AND c.EndValidity_DATE = @Ld_High_DATE)A) U UNPIVOT (Element_VALUE FOR Element_NAME 
                                                         IN (U.Action_CODE, U.Function_CODE, U.Reason_CODE )
                                                         )  pvt);

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY
  BEGIN CATCH
         SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
         DECLARE  @Li_Error_NUMB INT = ERROR_NUMBER (),
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
