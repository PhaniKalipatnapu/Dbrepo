/****** Object:  StoredProcedure [dbo].[BATCH_EST_OUTGOING_FC$SP_GET_DAG_APPROVED_CASE_PETITIONS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_EST_OUTGOING_FC$SP_GET_DAG_APPROVED_CASE_PETITIONS
Programmer Name	:	IMP Team.
Description		:	The purpose of BATCH_EST_OUTGOING_FC$SP_GET_DAG_APPROVED_CASE_PETITIONS batch process is to 
					  get all petitions that were approved by the DAG in the appropriate activity chain to be filed with Family Court that day
Frequency		:	'DAILY'
Developed On	:	5/3/2012
Called By		:	NONE
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_EST_OUTGOING_FC$SP_GET_DAG_APPROVED_CASE_PETITIONS]
 @Ad_Run_DATE              DATE,
 @Ac_Msg_CODE              CHAR (5) = '' OUTPUT,
 @As_DescriptionError_TEXT VARCHAR (4000) = '' OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_Zero_TEXT                  CHAR = '0',
          @Lc_StatusSuccess_CODE         CHAR(1) = 'S',
          @Lc_StatusFailed_CODE          CHAR(1) = 'F',
          @Lc_GeneratePdfN_INDC          CHAR(1) = 'N',
          @Lc_MergePdfN_INDC             CHAR(1) = 'N',
          @Lc_StatusNoticeFailure_CODE   CHAR(1) = 'F',
          @Lc_StatusNoticeGenerated_CODE CHAR(1) = 'G',
          @Lc_PrintMethodElectronic_CODE CHAR(1) = 'E',
          @Lc_Space_TEXT                 CHAR(1) = ' ',
          @Lc_RecipientFamilyCourt_CODE  CHAR(2) = 'FC',
          @Lc_ActivityMajorEstp_CODE     CHAR(4) = 'ESTP',
          @Lc_ActivityMajorMapp_CODE     CHAR(4) = 'MAPP',
          @Lc_ActivityMajorRofo_CODE     CHAR(4) = 'ROFO',
          @Lc_ActivityMajorImiw_CODE     CHAR(4) = 'IMIW',
          @Lc_StatusStart_CODE           CHAR(4) = 'STRT',
          @Lc_ActivityMinorAftbc_CODE    CHAR(5) = 'AFTBC',
          @Lc_ActivityMinorDocnm_CODE    CHAR(5) = 'DOCNM',
          @Lc_ActivityMinorMpcoa_CODE    CHAR(5) = 'MPCOA',
          @Lc_County_TEXT                CHAR(6) = 'COUNTY',
          @Ls_Procedure_NAME             VARCHAR(100) = 'SP_GET_DAG_APPROVED_CASE_PETITIONS',
          @Ld_High_DATE                  DATE = '12/31/9999';
  DECLARE @Ln_Error_NUMB            NUMERIC(11),
          @Ln_ErrorLine_NUMB        NUMERIC(11),
          @Lc_Empty_TEXT            CHAR = '',
          @Ls_Sql_TEXT              VARCHAR(200) = '',
          @Ls_ErrorMessage_TEXT     VARCHAR(200),
          @Ls_Sqldata_TEXT          VARCHAR(1000) = '',
          @Ls_DescriptionError_TEXT VARCHAR(4000),
          @Ld_Run_DATE              DATE;

  BEGIN TRY
   SET @Ld_Run_DATE = ISNULL(@Ad_Run_DATE, CAST(dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME() AS DATE));
   SET @Ls_Sql_TEXT = 'DELETE PDAFP_Y1';
   SET @Ls_Sqldata_TEXT = '';

   DELETE FROM PDAFP_Y1;

   SET @Ls_Sql_TEXT = 'INSERT PDAFP_Y1';
   SET @Ls_Sqldata_TEXT = '';

   INSERT PDAFP_Y1
          (Case_IDNO,
           County_IDNO,
           MajorIntSeq_NUMB,
           ActivityMajor_CODE,
           ReasonStatus_CODE,
           Barcode_NUMB,
           GeneratePdf_INDC,
           MergePdf_INDC,
           MergedPdf_NAME)
   SELECT C.Case_IDNO,
          RIGHT(REPLICATE(@Lc_Zero_TEXT, 3) + LTRIM(RTRIM(ISNULL(D.County_IDNO, ''))), 3) AS County_IDNO,
          C.MajorIntSeq_NUMB,
          C.ActivityMajor_CODE,
          C.ReasonStatus_CODE,
          B.Barcode_NUMB,
          @Lc_GeneratePdfN_INDC AS GeneratePdf_INDC,
          @Lc_MergePdfN_INDC AS MergePdf_INDC,
          @Lc_Empty_TEXT AS MergedPdf_NAME
     FROM NMRQ_Y1 A,
          FORM_Y1 B,
          DMNR_Y1 C,
          CASE_Y1 D
    WHERE A.Recipient_CODE = @Lc_RecipientFamilyCourt_CODE
      AND A.StatusNotice_CODE IN (@Lc_StatusNoticeFailure_CODE, @Lc_StatusNoticeGenerated_CODE)
      AND A.PrintMethod_CODE = @Lc_PrintMethodElectronic_CODE
      AND B.Barcode_NUMB = A.Barcode_NUMB
      AND B.Recipient_CODE = A.Recipient_CODE
      AND C.Topic_IDNO = B.Topic_IDNO
      AND C.Case_IDNO = A.Case_IDNO
      AND C.ActivityMajor_CODE IN (@Lc_ActivityMajorEstp_CODE, @Lc_ActivityMajorMapp_CODE, @Lc_ActivityMajorRofo_CODE, @Lc_ActivityMajorImiw_CODE)
      AND C.ActivityMinor_CODE = (CASE
                                   WHEN C.ActivityMajor_CODE IN (@Lc_ActivityMajorEstp_CODE, @Lc_ActivityMajorRofo_CODE)
                                    THEN @Lc_ActivityMinorAftbc_CODE
                                   WHEN C.ActivityMajor_CODE IN (@Lc_ActivityMajorImiw_CODE)
                                    THEN @Lc_ActivityMinorMpcoa_CODE
                                   WHEN C.ActivityMajor_CODE IN (@Lc_ActivityMajorMapp_CODE)
                                    THEN @Lc_ActivityMinorDocnm_CODE
                                  END)
      AND C.Status_CODE = @Lc_StatusStart_CODE
      AND C.TransactionEventSeq_NUMB = (SELECT TOP 1 MAX(X.TransactionEventSeq_NUMB)
                                          FROM DMNR_Y1 X
                                         WHERE X.Case_IDNO = C.Case_IDNO
                                           AND X.Topic_IDNO = C.Topic_IDNO
                                           AND X.ActivityMajor_CODE = C.ActivityMajor_CODE
                                           AND X.MajorIntSeq_NUMB = C.MajorIntSeq_NUMB
                                           AND X.ActivityMinor_CODE = C.ActivityMinor_CODE
                                           AND X.MinorIntSeq_NUMB = C.MinorIntSeq_NUMB
                                           AND X.ReasonStatus_CODE = C.ReasonStatus_CODE
                                           AND X.Status_CODE = C.Status_CODE)
      AND D.Case_IDNO = C.Case_IDNO
    ORDER BY C.Case_IDNO,
             C.MajorIntSeq_NUMB,
             C.ActivityMajor_CODE,
             C.ReasonStatus_CODE,
             B.Barcode_NUMB;

   SET @Ls_Sql_TEXT = 'GET_DAG_APPROVED_CASE_PETITIONS';
   SET @Ls_Sqldata_TEXT = '';

   SELECT A.Case_IDNO,
          A.County_IDNO,
          LTRIM(RTRIM(REPLACE(REPLACE(LTRIM(RTRIM(B.County_NAME)), @Lc_County_TEXT, ''), @Lc_Space_TEXT, ''))) AS County_NAME,
          A.MajorIntSeq_NUMB,
          A.ActivityMajor_CODE,
          A.ReasonStatus_CODE,
          C.Notice_ID,
          A.Barcode_NUMB,
          ISNULL(E.Xml_TEXT, '') AS Xml_TEXT,
          ISNULL(F.XslTemplate_TEXT, '') AS Xsl_TEXT,
          A.GeneratePdf_INDC,
          A.MergePdf_INDC,
          A.MergedPdf_NAME
     FROM PDAFP_Y1 A
          JOIN COPT_Y1 B
           ON B.County_IDNO = A.County_IDNO
          JOIN FORM_Y1 C
           ON C.Barcode_NUMB = A.Barcode_NUMB
          LEFT OUTER JOIN NMRQ_Y1 D
           ON D.Barcode_NUMB = C.Barcode_NUMB
          LEFT OUTER JOIN NXML_Y1 E
           ON E.Barcode_NUMB = D.Barcode_NUMB
          LEFT OUTER JOIN NVER_Y1 F
           ON F.Notice_ID = D.Notice_ID
              AND F.NoticeVersion_NUMB = D.NoticeVersion_NUMB
    ORDER BY A.Case_IDNO,
             A.MajorIntSeq_NUMB,
             A.ActivityMajor_CODE,
             A.ReasonStatus_CODE,
             A.Barcode_NUMB;

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = @Lc_Empty_TEXT;
  END TRY

  BEGIN CATCH
   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_ErrorMessage_TEXT = SUBSTRING(ERROR_MESSAGE(), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_SqlData_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
  END CATCH
 END


GO
