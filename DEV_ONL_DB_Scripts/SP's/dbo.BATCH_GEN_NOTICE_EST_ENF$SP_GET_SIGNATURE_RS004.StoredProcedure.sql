/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICE_EST_ENF$SP_GET_SIGNATURE_RS004]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
---------------------------------------------------------
 Procedure Name    :BATCH_GEN_NOTICE_EST_ENF$SP_GET_SIGNATURE_RS004
 Programmer Name   : IMP Team
 Description       :This procedure is used to get the title, name and signature of the IV-D Director whose Role is RS004 from User Signature table.
 Frequency         :
 Developed On      :02-08-2011
 Called By         :BATCH_COMMON$SP_FORMAT_BUILD_XML
 Called On         :
---------------------------------------------------------
 Modified By       :
 Modified On       :
 Version No        : 1.0 
---------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICE_EST_ENF$SP_GET_SIGNATURE_RS004](
 @Ac_Msg_CODE					CHAR(5)			OUTPUT,
 @As_DescriptionError_TEXT		VARCHAR(4000)	OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;
  DECLARE @Lc_StatusSuccess_CODE     CHAR(1)		= 'S',
          @Lc_StatusFailed_CODE      CHAR(1)		= 'F',
          @Lc_TableDtit_ID			 CHAR(4)		= 'DTIT',
          @Lc_RoleRs004_IDNO         CHAR(5)		= 'RS004',
          @Ld_Today_DATE			 DATE			= DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
          @Ld_High_DATE              DATETIME2		= '12/31/9999';
          
  DECLARE @Lc_Space_TEXT			 CHAR(1)		= ' ',
          @Lc_Empty_TEXT			 CHAR(1)		= ' ',
          @Lc_commaSpace_TEXT		 CHAR(2)		= ', ',
          @Ls_DescriptionError_TEXT  VARCHAR(4000)	= ' ';
  DECLARE @Ls_Sql_TEXT               VARCHAR(200)	,
          @Ls_SqlData_TEXT           VARCHAR(400)	;        
  BEGIN TRY
   SET @Ac_Msg_CODE = NULL;
   SET @As_DescriptionError_TEXT = NULL;
   SET @Ls_Sql_TEXT    = 'SELECT OFIC_Y1 USEM_Y1 USRL_Y1';
   SET @Ls_SqlData_TEXT= ' Role_IDNO = ' + ISNULL(@Lc_RoleRs004_IDNO , '');
  
   INSERT INTO #NoticeElementsData_P1
               (Element_NAME,
                Element_VALUE)
   (SELECT pvt.Element_NAME,
           pvt.Element_VALUE
      FROM (SELECT CONVERT(VARCHAR(70), a.TransactionEventSeq_NUMB) AS esign_ivd_dir_text,
                   CONVERT(VARCHAR(70), a.Worker_NAME)				AS ivd_director_name,
                   CONVERT(VARCHAR(70), a.WorkerTitle_CODE)			AS ivd_director_title_code
              FROM (SELECT TOP 1 d.TransactionEventSeq_NUMB,
                                 RTRIM(dbo.BATCH_COMMON$SF_GET_TITLECASE((RTRIM(b.First_NAME) + @Lc_Space_TEXT + RTRIM(ISNULL(b.Middle_NAME, @Lc_Empty_TEXT)) + @Lc_Space_TEXT + RTRIM(b.Last_NAME) + CASE WHEN RTRIM(ISNULL(b.Suffix_NAME, @Lc_Empty_TEXT)) != @Lc_Empty_TEXT THEN @Lc_commaSpace_TEXT + RTRIM(ISNULL(b.Suffix_NAME, @Lc_Empty_TEXT)) ELSE @Lc_Empty_TEXT END))) AS Worker_NAME,
                                 (SELECT SUBSTRING(RTRIM(DescriptionValue_TEXT ), 1, 1) + LOWER(SUBSTRING(RTRIM(DescriptionValue_TEXT ), 2, 70))
                                    FROM REFM_Y1 a
									--13485 - ENF-39 PSOC fields not populating as mapped - Start
                                   WHERE Value_CODE = b.WorkerSubTitle_CODE
								    --13485 - ENF-39 PSOC fields not populating as mapped - End
                                     AND Table_ID = @Lc_TableDtit_ID
                                     AND TableSub_ID = @Lc_TableDtit_ID) AS WorkerTitle_CODE
                      FROM USRL_Y1 a
                           JOIN USEM_Y1 b ON a.Worker_ID = b.Worker_ID
										  AND @Ld_Today_DATE BETWEEN b.BeginEmployment_DATE AND b.EndEmployment_DATE
										  AND b.EndValidity_DATE = @Ld_High_DATE	
                            JOIN USES_Y1 d
								ON  d.Worker_ID = b.Worker_ID
								AND d.ESignature_BIN IS NOT NULL
								AND d.ESignature_BIN <> @Lc_Space_TEXT
                     WHERE a.Role_ID = @Lc_RoleRs004_IDNO
                       AND @Ld_Today_DATE BETWEEN a.Effective_DATE AND a.Expire_DATE
                       AND a.EndValidity_DATE = @Ld_High_DATE
                       ) a)up UNPIVOT (Element_VALUE FOR Element_NAME IN ( esign_ivd_dir_text, ivd_director_name, ivd_director_title_code )) AS pvt);
   
   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   DECLARE	@Li_Error_NUMB				INT = ERROR_NUMBER (),
			@Li_ErrorLine_NUMB		    INT =  ERROR_LINE ();
         SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
         SET @Ls_DescriptionError_TEXT =  SUBSTRING (ERROR_MESSAGE (), 1, 200);
         EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION @As_Procedure_NAME = @Ls_Sql_TEXT,
                                                       @As_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT,
                                                       @As_Sql_TEXT = @Ls_Sql_TEXT,
                                                       @As_Sqldata_TEXT = @Ls_SqlData_TEXT,
                                                       @An_Error_NUMB = @Li_Error_NUMB,
                                                       @An_ErrorLine_NUMB = @Li_ErrorLine_NUMB,
                                                       @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;
  END CATCH
 END


GO
