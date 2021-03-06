/****** Object:  StoredProcedure [dbo].[BATCH_EST_OUTGOING_FC$SP_EXTRACT_NSA]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_EST_OUTGOING_FC$SP_EXTRACT_NSA
Programmer Name	:	IMP Team.
Description		:	The purpose of BATCH_EST_OUTGOING_FC$SP_EXTRACT_NSA batch process is to to provide FAMIS 
					  with a new address for the respondent on a new petition for service, which will allow for 
					  data synchronization and alleviation of dual data entry. The supporting documents, such as 
					  an imaged 'Post Master Letter' or 'Reinstatement Letter,' will be passed electronically 
					  through the DTI SFTP server to expedite the process and move toward an electronic document 
					  exchange.
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
CREATE PROCEDURE [dbo].[BATCH_EST_OUTGOING_FC$SP_EXTRACT_NSA]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_Space_TEXT                 CHAR(1) = ' ',
          @Lc_StatusSuccess_CODE         CHAR(1) = 'S',
          @Lc_StatusFailed_CODE          CHAR(1) = 'F',
          @Lc_StatusAbnormalEnd_CODE     CHAR(1) = 'A',
          @Lc_MemberNcp_CODE             CHAR(1) = 'A',
          @Lc_MemberPutFather_CODE       CHAR(1) = 'P',
          @Lc_ConfirmedGood_INDC         CHAR(1) = 'Y',
          @Lc_Yes_TEXT                   CHAR(1) = 'Y',
          @Lc_StringZero_TEXT            CHAR(1) = '0',
          @Lc_TypeAddressMailing_CODE    CHAR(1) = 'M',
          @Lc_GeneratePdfN_INDC          CHAR(1) = 'N',
          @Lc_MergePdfY_INDC             CHAR(1) = 'Y',
          @Lc_MergePdfN_INDC             CHAR(1) = 'N',
          @Lc_StatusNoticeFailure_CODE   CHAR(1) = 'F',
          @Lc_StatusNoticeGenerated_CODE CHAR(1) = 'G',
          @Lc_Zero_TEXT                  CHAR(1) = '0',
          @Lc_Note_INDC                  CHAR(1) = 'N',
          @Lc_ReasonStatusDa_CODE        CHAR(2) = 'DA',
          @Lc_SubsystemEs_CODE           CHAR(3) = 'ES',
          @Lc_TotalRecordType_TEXT       CHAR(4) = 'NSAT',
          @Lc_RecordType_CODE            CHAR(4) = 'NSAR',
          @Lc_StatusComplete_CODE        CHAR(4) = 'COMP',
          @Lc_ActivityMajorCase_CODE     CHAR(4) = 'CASE',
          @Lc_TypeReference_IDNO         CHAR(4) = ' ',
          @Lc_BatchRunUser_TEXT          CHAR(5) = 'BATCH',
          @Lc_ActivityMinorAnddi_CODE    CHAR(5) = 'ANDDI',
          @Lc_ActivityMajorEstp_CODE     CHAR(5) = 'ESTP',
          @Lc_ActivityMajorRofo_CODE     CHAR(5) = 'ROFO',
          @Lc_BateError_CODE             CHAR(5) = 'E0944',
          @Lc_ActivityMinorRsstf_CODE    CHAR(5) = 'RSSTF',
          @Lc_Job_ID                     CHAR(7) = 'DEB0703',
          @Lc_Notice_ID                  CHAR(8) = NULL,
          @Lc_Successful_TEXT            CHAR(20) = 'SUCCESSFUL',
          @Lc_WorkerDelegate_ID          CHAR(30) = ' ',
          @Lc_Reference_ID               CHAR(30) = ' ',
          @Ls_Procedure_NAME             VARCHAR(100) = 'SP_EXTRACT_NSA',
          @Ls_Process_NAME               VARCHAR(100) = 'Dhss.Ivd.Decss.Batch.EstOutgoingFc',
          @Ls_BateError_TEXT             VARCHAR(4000) = 'NO RECORD(S) TO PROCESS',
          @Ls_XmlIn_TEXT                 VARCHAR(4000) = ' ',
          @Ld_High_DATE                  DATE = '12/31/9999';
  DECLARE @Ln_CommitFreqParm_QNTY         NUMERIC(5),
          @Ln_ExceptionThresholdParm_QNTY NUMERIC(5),
          @Ln_RestartLine_NUMB            NUMERIC(5, 0) = 0,
          @Ln_MajorIntSeq_NUMB            NUMERIC(5) = 0,
          @Ln_MinorIntSeq_NUMB            NUMERIC(5) = 0,
          @Ln_ProcessedRecordCount_QNTY   NUMERIC(6) = 0,
          @Ln_FileTotRecCount_NUMB        NUMERIC(7),
          @Ln_TopicIn_IDNO                NUMERIC(10) = 0,
          @Ln_Schedule_NUMB               NUMERIC(10) = 0,
          @Ln_Topic_IDNO                  NUMERIC(10),
          @Ln_Error_NUMB                  NUMERIC(11),
          @Ln_ErrorLine_NUMB              NUMERIC(11),
          @Ln_TransactionEventSeq_NUMB    NUMERIC(19) = 0,
          @Li_FetchStatus_QNTY            SMALLINT,
          @Li_RowCount_QNTY               SMALLINT,
          @Lc_Empty_TEXT                  CHAR(1) = '',
          @Lc_TypeError_CODE              CHAR(1),
          @Lc_Msg_CODE                    CHAR(5),
          @Ls_File_NAME                   VARCHAR(50),
          @Ls_FileLocation_TEXT           VARCHAR(80),
          @Ls_Sql_TEXT                    VARCHAR(100) = '',
          @Ls_ErrorMessage_TEXT           VARCHAR(200),
          @Ls_SqlData_TEXT                VARCHAR(1000) = '',
          @Ls_Query_TEXT                  VARCHAR(1000),
          @Ls_DescriptionError_TEXT       VARCHAR(4000),
          @Ld_Run_DATE                    DATE,
          @Ld_LastRun_DATE                DATE,
          @Ld_Start_DATE                  DATETIME2;
  DECLARE @Ln_NrrqAxmlCur_Barcode_NUMB   NUMERIC(12),
          @Lc_CaseJrnActCur_Case_IDNO    CHAR(6),
          @Ln_UpdateNmrqCur_Barcode_NUMB NUMERIC(12);

  BEGIN TRY
   SET @Ls_Sql_TEXT = 'CREATE ##ExtractFcNsa_P1';
   SET @Ls_SqlData_TEXT = '';

   CREATE TABLE ##ExtractFcNsa_P1
    (
      Record_TEXT VARCHAR(812)
    );

   SET @Ls_Sql_TEXT = 'BEGIN TRANSACTION TXN_EXTRACT_NSA';
   SET @Ls_SqlData_TEXT = '';

   BEGIN TRANSACTION TXN_EXTRACT_NSA;

   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS2';
   SET @Ls_SqlData_TEXT = 'Job_ID = ' + @Lc_Job_ID;

   EXECUTE BATCH_COMMON$SP_GET_BATCH_DETAILS2
    @Ac_Job_ID                  = @Lc_Job_ID,
    @Ad_Run_DATE                = @Ld_Run_DATE OUTPUT,
    @Ad_LastRun_DATE            = @Ld_LastRun_DATE OUTPUT,
    @An_CommitFreq_QNTY         = @Ln_CommitFreqParm_QNTY OUTPUT,
    @An_ExceptionThreshold_QNTY = @Ln_ExceptionThresholdParm_QNTY OUTPUT,
    @As_File_NAME               = @Ls_File_NAME OUTPUT,
    @As_FileLocation_TEXT       = @Ls_FileLocation_TEXT OUTPUT,
    @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT   = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT='DELETE EFNSA_Y1';
   SET @Ls_SqlData_TEXT = '';

   DELETE FROM EFNSA_Y1;

   SET @Ls_Sql_TEXT='INSERT EFNSA_Y1';
   SET @Ls_SqlData_TEXT = '';

   INSERT INTO EFNSA_Y1
               (Rec_ID,
                Case_IDNO,
                Create_DTTM,
                Petition_IDNO,
                MajorIntSeq_NUMB,
                DocReference_CODE,
                Entered_DATE,
                File_ID,
                Last_NAME,
                First_NAME,
                Middle_NAME,
                MemberMci_IDNO,
                MemberSsn_NUMB,
                Birth_DATE,
                DescriptionIdentifyingMarks_TEXT,
                Line1_ADDR,
                Line2_ADDR,
                City_ADDR,
                State_ADDR,
                Zip_ADDR,
                Update_DTTM,
                DescriptionServiceDirection_TEXT,
                ServiceDocFile_NAME)
   SELECT DISTINCT
          @Lc_RecordType_CODE AS Rec_ID,
          a.Case_IDNO,
          CONVERT(CHAR(8), @Ld_Run_DATE, 112) + REPLACE(CONVERT(CHAR(8), @Ld_Start_DATE, 108), ':', '') AS Create_DTTM,
          ISNULL(CAST(d.Petition_IDNO AS CHAR(7)), @Lc_Space_TEXT) AS Petition_IDNO,
          ISNULL(CAST(d.MajorIntSeq_NUMB AS CHAR(2)), @Lc_Space_TEXT) AS MajorIntSeq_NUMB,
          ISNULL(d.DocReference_CODE, @Lc_Space_TEXT) AS DocReference_CODE,
          ISNULL(CONVERT(CHAR(8), d.Filed_DATE, 112), @Lc_Space_TEXT) AS Entered_DATE,
          ISNULL(d.File_ID, @Lc_Space_TEXT) AS File_ID,
          c.Last_NAME,
          c.First_NAME,
          c.Middle_NAME,
          c.MemberMci_IDNO,
          c.MemberSsn_NUMB,
          ISNULL(CONVERT(CHAR(8), c.Birth_DATE, 112), @Lc_Space_TEXT) AS Birth_DATE,
          c.DescriptionIdentifyingMarks_TEXT,
          ISNULL(b.Line1_ADDR, @Lc_Space_TEXT) AS Line1_ADDR,
          ISNULL(b.Line2_ADDR, @Lc_Space_TEXT) AS Line2_ADDR,
          ISNULL(b.City_ADDR, @Lc_Space_TEXT) AS City_ADDR,
          ISNULL(b.State_ADDR, @Lc_Space_TEXT) AS State_ADDR,
          ISNULL(SUBSTRING(b.Zip_ADDR, 1, 9), @Lc_Space_TEXT) AS Zip_ADDR,
          ISNULL(CONVERT(CHAR(8), @Ld_Run_DATE, 112), @Lc_Space_TEXT) AS Update_DTTM,
          ISNULL(SUBSTRING(b.DescriptionServiceDirection_TEXT, 1, 400), @Lc_Space_TEXT) AS DescriptionServiceDirection_TEXT,
          ('NSA-' + ISNULL(CONVERT(CHAR(8), @Ld_Run_DATE, 112), @Lc_Space_TEXT) + '-' + RIGHT(REPLICATE('0', 3) + LTRIM(RTRIM(ISNULL(CAST(e.County_IDNO AS VARCHAR), ''))), 3) + '-' + CAST(a.Case_IDNO AS CHAR(6)) + '.PDF') AS ServiceDocFile_NAME
     FROM DMNR_Y1 a
          LEFT OUTER JOIN (SELECT x.MemberMci_IDNO,
                                  x.Line1_ADDR,
                                  x.Line2_ADDR,
                                  x.City_ADDR,
                                  x.State_ADDR,
                                  x.Zip_ADDR,
                                  x.DescriptionServiceDirection_TEXT
                             FROM AHIS_Y1 x
                            WHERE x.Status_CODE = @Lc_ConfirmedGood_INDC
                              AND x.TypeAddress_CODE = @Lc_TypeAddressMailing_CODE
                              AND x.End_DATE = @Ld_High_DATE) b
           ON b.MemberMci_IDNO = a.MemberMci_IDNO
          LEFT OUTER JOIN (SELECT x.Last_NAME,
                                  SUBSTRING(x.First_NAME, 1, 15) AS First_NAME,
                                  SUBSTRING(x.Middle_NAME, 1, 1) AS Middle_NAME,
                                  x.MemberMci_IDNO,
                                  x.MemberSsn_NUMB,
                                  ISNULL(CONVERT(CHAR(8), x.Birth_DATE, 112), @Lc_Space_TEXT) AS Birth_DATE,
                                  x.DescriptionIdentifyingMarks_TEXT
                             FROM DEMO_Y1 x) AS c
           ON c.MemberMci_IDNO = a.MemberMci_IDNO
          LEFT OUTER JOIN (SELECT x.Case_IDNO,
                                  x.County_IDNO
                             FROM CASE_Y1 x) AS e
           ON e.Case_IDNO = a.Case_IDNO
          LEFT OUTER JOIN (SELECT x.Case_IDNO,
                                  x.Petition_IDNO,
                                  CAST(x.MajorIntSeq_NUMB AS CHAR(2)) AS MajorIntSeq_NUMB,
                                  x.DocReference_CODE,
                                  x.Filed_DATE,
                                  x.File_ID,
                                  x.TransactionEventSeq_NUMB
                             FROM FDEM_Y1 x
                            WHERE x.EndValidity_DATE = '12/31/9999') AS d
           ON d.Case_IDNO = a.Case_IDNO
              AND d.MajorIntSeq_NUMB = a.MajorIntSeq_NUMB
    WHERE ((a.ActivityMajor_CODE = @Lc_ActivityMajorEstp_CODE
            AND a.MemberMci_IDNO IN (SELECT j.OthpSource_IDNO
                                       FROM DMJR_Y1 j
                                      WHERE j.Case_IDNO = a.Case_IDNO
                                        AND j.ActivityMajor_CODE = a.ActivityMajor_CODE
                                        AND j.MajorIntSeq_NUMB = a.MajorIntSeq_NUMB
                                        AND j.TypeOthpSource_CODE IN (@Lc_MemberNcp_CODE, @Lc_MemberPutFather_CODE)))
            OR (a.ActivityMajor_CODE = @Lc_ActivityMajorRofo_CODE))
      AND a.ActivityMinor_CODE = @Lc_ActivityMinorAnddi_CODE
      AND a.ReasonStatus_CODE = @Lc_ReasonStatusDa_CODE
      AND a.Status_CODE = @Lc_StatusComplete_CODE
      AND a.TransactionEventSeq_NUMB IN (SELECT MAX(p.TransactionEventSeq_NUMB)
                                           FROM DMNR_Y1 p
                                          WHERE p.Case_IDNO = a.Case_IDNO
                                            AND p.MemberMci_IDNO = a.MemberMci_IDNO
                                            AND p.OrderSeq_NUMB = a.OrderSeq_NUMB
                                            AND p.MajorIntSEQ_NUMB = a.MajorIntSEQ_NUMB
                                            AND p.ActivityMinor_CODE = a.ActivityMinor_CODE
                                            AND p.ActivityMajor_CODE = a.ActivityMajor_CODE
                                            AND p.ReasonStatus_CODE = a.ReasonStatus_CODE
                                            AND p.Status_CODE = a.Status_CODE)
      AND EXISTS (SELECT 1
                    FROM PDAFP_Y1 x
                   WHERE x.Case_IDNO = a.Case_IDNO
                     AND x.MajorIntSeq_NUMB = a.MajorIntSeq_NUMB
                     AND x.ActivityMajor_CODE = a.ActivityMajor_CODE
                     AND x.MergePdf_INDC = @Lc_MergePdfY_INDC
                     AND LEN(LTRIM(RTRIM(ISNULL(x.MergedPdf_NAME, @Lc_Empty_TEXT)))) > 0
                     AND NOT EXISTS (SELECT 1
                                       FROM PDAFP_Y1 y
                                      WHERE y.Case_IDNO = x.Case_IDNO
                                        AND y.County_IDNO = x.County_IDNO
                                        AND y.MajorIntSeq_NUMB = x.MajorIntSeq_NUMB
                                        AND y.ActivityMajor_CODE = x.ActivityMajor_CODE
                                        AND y.GeneratePdf_INDC = @Lc_GeneratePdfN_INDC));

   SET @Li_RowCount_QNTY = @@ROWCOUNT;

   IF @Li_RowCount_QNTY = 0
    BEGIN
     SET @Ls_Sql_TEXT='BATCH_COMMON$SP_BATE_LOG';
     SET @Ls_Sqldata_TEXT = '';

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Ls_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_TypeError_CODE,
      @An_Line_NUMB                = @Ln_RestartLine_NUMB,
      @Ac_Error_CODE               = @Lc_BateError_CODE,
      @As_DescriptionError_TEXT    = @Ls_BateError_TEXT,
      @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

       RAISERROR (50001,16,1);
      END;
    END

   SET @Ls_Sql_TEXT = 'INSERT ##ExtractFcNsa_P1 - NSAR - NSA Detail Record Type';
   SET @Ls_Sqldata_TEXT = '';

   INSERT INTO ##ExtractFcNsa_P1
               (Record_TEXT)
   SELECT (LEFT((LTRIM(RTRIM(a.Rec_ID)) + REPLICATE(@Lc_Space_TEXT, 4)), 4) + RIGHT((REPLICATE(@Lc_StringZero_TEXT, 6) + LTRIM(RTRIM(a.Case_IDNO))), 6) + (CONVERT(CHAR(8), @Ld_Run_DATE, 112) + CONVERT(CHAR(8), @Ld_Start_DATE, 108)) + RIGHT((REPLICATE(@Lc_StringZero_TEXT, 7) + LTRIM(RTRIM(a.Petition_IDNO))), 7) + RIGHT((REPLICATE(@Lc_StringZero_TEXT, 2) + LTRIM(RTRIM(a.MajorIntSeq_NUMB))), 2) + LEFT((LTRIM(RTRIM(a.DocReference_CODE)) + REPLICATE(@Lc_Space_TEXT, 4)), 4) + LEFT((LTRIM(RTRIM(a.Entered_DATE)) + REPLICATE(@Lc_Space_TEXT, 8)), 8) + LEFT((LTRIM(RTRIM(a.File_ID)) + REPLICATE(@Lc_Space_TEXT, 10)), 10) + LEFT((LTRIM(RTRIM(a.Last_NAME)) + REPLICATE(@Lc_Space_TEXT, 20)), 20) + LEFT((LTRIM(RTRIM(a.First_NAME)) + REPLICATE(@Lc_Space_TEXT, 15)), 15) + LEFT((LTRIM(RTRIM(a.Middle_NAME)) + REPLICATE(@Lc_Space_TEXT, 1)), 1) + RIGHT((REPLICATE(@Lc_StringZero_TEXT, 10) + LTRIM(RTRIM(a.MemberMci_IDNO))), 10) + RIGHT((REPLICATE(@Lc_StringZero_TEXT, 9) + LTRIM(RTRIM(a.MemberSsn_NUMB))), 9) + LEFT((LTRIM(RTRIM(a.Birth_DATE)) + REPLICATE(@Lc_Space_TEXT, 8)), 8) + LEFT((LTRIM(RTRIM(a.DescriptionIdentifyingMarks_TEXT)) + REPLICATE(@Lc_Space_TEXT, 40)), 40) + LEFT((LTRIM(RTRIM(a.Line1_ADDR)) + REPLICATE(@Lc_Space_TEXT, 50)), 50) + LEFT((LTRIM(RTRIM(a.Line2_ADDR)) + REPLICATE(@Lc_Space_TEXT, 50)), 50) + LEFT((LTRIM(RTRIM(a.City_ADDR)) + REPLICATE(@Lc_Space_TEXT, 28)), 28) + LEFT((LTRIM(RTRIM(a.State_ADDR)) + REPLICATE(@Lc_Space_TEXT, 2)), 2) + LEFT((LTRIM(RTRIM(a.Zip_ADDR)) + REPLICATE(@Lc_Space_TEXT, 9)), 9) + LEFT((LTRIM(RTRIM(a.Update_DTTM)) + REPLICATE(@Lc_Space_TEXT, 8)), 8) + LEFT((LTRIM(RTRIM(a.DescriptionServiceDirection_TEXT)) + REPLICATE(@Lc_Space_TEXT, 400)), 400) + LEFT((LTRIM(RTRIM(a.ServiceDocFile_NAME)) + REPLICATE(@Lc_Space_TEXT, 27)), 27) + REPLICATE(@Lc_Space_TEXT, 78)) AS Record_TEXT
     FROM EFNSA_Y1 a
    ORDER BY Case_IDNO;

   SET @Li_RowCount_QNTY = @@ROWCOUNT;
   SET @Ln_ProcessedRecordCount_QNTY = @Li_RowCount_QNTY;
   SET @Ln_FileTotRecCount_NUMB = RIGHT(('0000000' + LTRIM(RTRIM(@Li_RowCount_QNTY))), 7);
   SET @Ls_Sql_TEXT='INSERT ##ExtractFcNsa_P1 - NSAT - NSA Total Record Type';
   SET @Ls_Sqldata_TEXT = 'FileTotRecCount_NUMB = ' + CAST(@Ln_FileTotRecCount_NUMB AS VARCHAR);

   INSERT INTO ##ExtractFcNsa_P1
               (Record_TEXT)
   SELECT (LEFT((LTRIM(RTRIM(@Lc_TotalRecordType_TEXT)) + REPLICATE(@Lc_Space_TEXT, 4)), 4) + RIGHT((REPLICATE(@Lc_StringZero_TEXT, 7) + LTRIM(RTRIM(@Ln_FileTotRecCount_NUMB))), 7) + REPLICATE(@Lc_Space_TEXT, 801)) AS Record_TEXT;

   SET @Ls_Sql_TEXT = 'COMMIT TRANSACTION TXN_EXTRACT_NSA';
   SET @Ls_SqlData_TEXT = '';

   COMMIT TRANSACTION TXN_EXTRACT_NSA;

   SET @Ls_Query_TEXT = 'SELECT Record_TEXT FROM ##ExtractFcNsa_P1';
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_EXTRACT_DATA';
   SET @Ls_SqlData_TEXT = 'FileLocation_TEXT = ' + @Ls_FileLocation_TEXT + ', File_NAME = ' + @Ls_File_NAME + ', Query_TEXT = ' + @Ls_Query_TEXT;

   EXECUTE BATCH_COMMON$SP_EXTRACT_DATA
    @As_FileLocation_TEXT     = @Ls_FileLocation_TEXT,
    @As_File_NAME             = @Ls_File_NAME,
    @As_Query_TEXT            = @Ls_Query_TEXT,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'BEGIN TRANSACTION TXN_EXTRACT_NSA';
   SET @Ls_SqlData_TEXT = '';

   BEGIN TRANSACTION TXN_EXTRACT_NSA;

   SET @Ls_Sql_TEXT='DECLARE NrrqAxml_CUR';
   SET @Ls_SqlData_TEXT = '';

   DECLARE NrrqAxml_CUR INSENSITIVE CURSOR FOR
    SELECT D.Barcode_NUMB
      FROM PDAFP_Y1 D
     WHERE D.MergePdf_INDC = @Lc_MergePdfY_INDC
       AND LEN(LTRIM(RTRIM(ISNULL(D.MergedPdf_NAME, @Lc_Empty_TEXT)))) > 0
       AND NOT EXISTS (SELECT 1
                         FROM PDAFP_Y1 X
                        WHERE X.Case_IDNO = D.Case_IDNO
                          AND X.County_IDNO = D.County_IDNO
                          AND X.MajorIntSeq_NUMB = D.MajorIntSeq_NUMB
                          AND X.ActivityMajor_CODE = D.ActivityMajor_CODE
                          AND X.GeneratePdf_INDC = @Lc_GeneratePdfN_INDC)
       AND D.ActivityMajor_CODE IN (@Lc_ActivityMajorEstp_CODE, @Lc_ActivityMajorRofo_CODE)
     ORDER BY D.Case_IDNO,
              D.County_IDNO,
              D.MajorIntSeq_NUMB,
              D.ActivityMajor_CODE,
              D.ReasonStatus_CODE,
              D.Barcode_NUMB;

   SET @Ls_Sql_TEXT = 'OPEN NrrqAxml_CUR';
   SET @Ls_SqlData_TEXT = '';

   OPEN NrrqAxml_CUR;

   SET @Ls_Sql_TEXT = 'FETCH NEXT FROM NrrqAxml_CUR - 1';
   SET @Ls_SqlData_TEXT = '';

   FETCH NEXT FROM NrrqAxml_CUR INTO @Ln_NrrqAxmlCur_Barcode_NUMB;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
   SET @Ls_Sql_TEXT = 'FOR EACH RECORD IN NrrqAxml_CUR';
   SET @Ls_SqlData_TEXT = '';

   --LOOP THROUGH NrrqAxml_CUR
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
     SET @Ls_Sql_TEXT = 'INSERT NRRQ_Y1';
     SET @Ls_Sqldata_TEXT = 'Barcode_NUMB = ' + CAST(@Ln_NrrqAxmlCur_Barcode_NUMB AS VARCHAR);

     INSERT NRRQ_Y1
            (Notice_ID,
             Case_IDNO,
             Recipient_ID,
             Barcode_NUMB,
             Recipient_CODE,
             NoticeVersion_NUMB,
             StatusNotice_CODE,
             Request_DTTM,
             WorkerRequest_ID,
             WorkerPrinted_ID,
             Generate_DTTM,
             Job_ID,
             Copies_QNTY,
             TransactionEventSeq_NUMB,
             Update_DTTM,
             File_ID,
             LoginWrkOficAttn_ADDR,
             LoginWorkersOffice_NAME,
             LoginWrkOficLine1_ADDR,
             LoginWrkOficLine2_ADDR,
             LoginWrkOficCity_ADDR,
             LoginWrkOficState_ADDR,
             LoginWrkOficZip_ADDR,
             LoginWorkerOfficeCountry_ADDR,
             RecipientAttn_ADDR,
             Recipient_NAME,
             RecipientLine1_ADDR,
             RecipientLine2_ADDR,
             RecipientCity_ADDR,
             RecipientState_ADDR,
             RecipientZip_ADDR,
             RecipientCountry_ADDR,
             PrintMethod_CODE,
             TypeService_CODE)
     SELECT A.Notice_ID,
            A.Case_IDNO,
            A.Recipient_ID,
            A.Barcode_NUMB,
            A.Recipient_CODE,
            A.NoticeVersion_NUMB,
            @Lc_StatusNoticeGenerated_CODE AS StatusNotice_CODE,
            A.Request_DTTM,
            A.WorkerRequest_ID,
            @Lc_Space_TEXT AS WorkerPrinted_ID,
            @Ld_Start_DATE AS Generate_DTTM,
            A.Job_ID,
            A.Copies_QNTY,
            A.TransactionEventSeq_NUMB,
            A.Update_DTTM,
            A.File_ID,
            A.LoginWrkOficAttn_ADDR,
            A.LoginWorkersOffice_NAME,
            A.LoginWrkOficLine1_ADDR,
            A.LoginWrkOficLine2_ADDR,
            A.LoginWrkOficCity_ADDR,
            A.LoginWrkOficState_ADDR,
            A.LoginWrkOficZip_ADDR,
            A.LoginWorkerOfficeCountry_ADDR,
            A.RecipientAttn_ADDR,
            A.Recipient_NAME,
            A.RecipientLine1_ADDR,
            A.RecipientLine2_ADDR,
            A.RecipientCity_ADDR,
            A.RecipientState_ADDR,
            A.RecipientZip_ADDR,
            A.RecipientCountry_ADDR,
            A.PrintMethod_CODE,
            A.TypeService_CODE
       FROM NMRQ_Y1 A
      WHERE A.Barcode_NUMB = @Ln_NrrqAxmlCur_Barcode_NUMB;

     SET @Li_RowCount_QNTY = @@ROWCOUNT;

     IF @Li_RowCount_QNTY > 0
      BEGIN
       SET @Ls_Sql_TEXT = 'DELETE NMRQ_Y1';
       SET @Ls_Sqldata_TEXT = 'Barcode_NUMB = ' + CAST(@Ln_NrrqAxmlCur_Barcode_NUMB AS VARCHAR);

       DELETE FROM NMRQ_Y1
        WHERE Barcode_NUMB = @Ln_NrrqAxmlCur_Barcode_NUMB;
      END

     SET @Ls_Sql_TEXT = 'INSERT AXML_Y1';
     SET @Ls_Sqldata_TEXT = 'Barcode_NUMB = ' + CAST(@Ln_NrrqAxmlCur_Barcode_NUMB AS VARCHAR);

     INSERT AXML_Y1
            (Barcode_NUMB,
             Xml_TEXT)
     SELECT A.Barcode_NUMB,
            A.Xml_TEXT
       FROM NXML_Y1 A
      WHERE A.Barcode_NUMB = @Ln_NrrqAxmlCur_Barcode_NUMB;

     SET @Li_RowCount_QNTY = @@ROWCOUNT;

     IF @Li_RowCount_QNTY > 0
      BEGIN
       SET @Ls_Sql_TEXT = 'DELETE NXML_Y1';
       SET @Ls_Sqldata_TEXT = 'Barcode_NUMB = ' + CAST(@Ln_NrrqAxmlCur_Barcode_NUMB AS VARCHAR);

       DELETE FROM NXML_Y1
        WHERE Barcode_NUMB = @Ln_NrrqAxmlCur_Barcode_NUMB;
      END

     SET @Ls_Sql_TEXT='FETCH NEXT FROM NrrqAxml_CUR - 2';
     SET @Ls_SqlData_TEXT = '';

     FETCH NEXT FROM NrrqAxml_CUR INTO @Ln_NrrqAxmlCur_Barcode_NUMB;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END

   SET @Ls_Sql_TEXT='CLOSE NrrqAxml_CUR';
   SET @Ls_SqlData_TEXT = '';

   CLOSE NrrqAxml_CUR;

   SET @Ls_Sql_TEXT='DEALLOCATE NrrqAxml_CUR';
   SET @Ls_SqlData_TEXT = '';

   DEALLOCATE NrrqAxml_CUR;

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT';
   SET @Ls_SqlData_TEXT = '';

   EXEC BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
    @Ac_Worker_ID                = @Lc_BatchRunUser_TEXT,
    @Ac_Process_ID               = @Lc_Job_ID,
    @Ad_EffectiveEvent_DATE      = @Ld_Run_DATE,
    @Ac_Note_INDC                = @Lc_Note_INDC,
    @An_EventFunctionalSeq_NUMB  = 0,
    @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
    @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

     RAISERROR (50001,16,1);
    END

   SET @Ls_Sql_TEXT='DECLARE CaseJrnAct_CUR';
   SET @Ls_SqlData_TEXT = '';

   DECLARE CaseJrnAct_CUR INSENSITIVE CURSOR FOR
    SELECT DISTINCT
           D.Case_IDNO
      FROM PDAFP_Y1 D
     WHERE D.MergePdf_INDC = @Lc_MergePdfY_INDC
       AND LEN(LTRIM(RTRIM(ISNULL(D.MergedPdf_NAME, @Lc_Empty_TEXT)))) > 0
       AND NOT EXISTS (SELECT 1
                         FROM PDAFP_Y1 X
                        WHERE X.Case_IDNO = D.Case_IDNO
                          AND X.County_IDNO = D.County_IDNO
                          AND X.MajorIntSeq_NUMB = D.MajorIntSeq_NUMB
                          AND X.ActivityMajor_CODE = D.ActivityMajor_CODE
                          AND X.GeneratePdf_INDC = @Lc_GeneratePdfN_INDC)
       AND D.ActivityMajor_CODE IN (@Lc_ActivityMajorEstp_CODE, @Lc_ActivityMajorRofo_CODE)
     ORDER BY D.Case_IDNO;

   SET @Ls_Sql_TEXT = 'OPEN CaseJrnAct_CUR';
   SET @Ls_SqlData_TEXT = '';

   OPEN CaseJrnAct_CUR;

   SET @Ls_Sql_TEXT = 'FETCH NEXT FROM CaseJrnAct_CUR - 1';
   SET @Ls_SqlData_TEXT = '';

   FETCH NEXT FROM CaseJrnAct_CUR INTO @Lc_CaseJrnActCur_Case_IDNO;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
   SET @Ls_Sql_TEXT = 'FOR EACH RECORD IN CaseJrnAct_CUR';
   SET @Ls_SqlData_TEXT = '';

   --LOOP THROUGH CaseJrnAct_CUR
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_ACTIVITY';
     SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + @Lc_CaseJrnActCur_Case_IDNO;

     EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
      @An_Case_IDNO                = @Lc_CaseJrnActCur_Case_IDNO,
      @An_MemberMci_IDNO           = @Lc_Zero_TEXT,
      @Ac_ActivityMajor_CODE       = @Lc_ActivityMajorCase_CODE,
      @Ac_ActivityMinor_CODE       = @Lc_ActivityMinorRsstf_CODE,
      @Ac_Subsystem_CODE           = @Lc_SubsystemEs_CODE,
      @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
      @Ac_WorkerUpdate_ID          = @Lc_BatchRunUser_TEXT,
      @Ac_WorkerDelegate_ID        = @Lc_WorkerDelegate_ID,
      @Ad_Run_DATE                 = @Ld_Run_DATE,
      @Ac_TypeReference_CODE       = @Lc_TypeReference_IDNO,
      @Ac_Reference_ID             = @Lc_Reference_ID,
      @Ac_Notice_ID                = @Lc_Notice_ID,
      @An_TopicIn_IDNO             = @Ln_TopicIn_IDNO,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @As_Xml_TEXT                 = @Ls_XmlIn_TEXT,
      @An_MajorIntSeq_NUMB         = @Ln_MajorIntSeq_NUMB,
      @An_MinorIntSeq_NUMB         = @Ln_MinorIntSeq_NUMB,
      @An_Schedule_NUMB            = @Ln_Schedule_NUMB,
      @An_Topic_IDNO               = @Ln_Topic_IDNO OUTPUT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

       RAISERROR (50001,16,1);
      END;

     SET @Ls_Sql_TEXT='FETCH NEXT FROM CaseJrnAct_CUR - 2';
     SET @Ls_SqlData_TEXT = '';

     FETCH NEXT FROM CaseJrnAct_CUR INTO @Lc_CaseJrnActCur_Case_IDNO;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END

   SET @Ls_Sql_TEXT='CLOSE CaseJrnAct_CUR';
   SET @Ls_SqlData_TEXT = '';

   CLOSE CaseJrnAct_CUR;

   SET @Ls_Sql_TEXT='DEALLOCATE CaseJrnAct_CUR';
   SET @Ls_SqlData_TEXT = '';

   DEALLOCATE CaseJrnAct_CUR;

   SET @Ls_Sql_TEXT='DECLARE UpdateNmrq_CUR';
   SET @Ls_SqlData_TEXT = '';

   DECLARE UpdateNmrq_CUR INSENSITIVE CURSOR FOR
    SELECT D.Barcode_NUMB
      FROM PDAFP_Y1 D
     WHERE D.ActivityMajor_CODE IN (@Lc_ActivityMajorEstp_CODE, @Lc_ActivityMajorRofo_CODE)
       AND ((D.MergePdf_INDC = @Lc_MergePdfN_INDC
             AND LEN(LTRIM(RTRIM(ISNULL(D.MergedPdf_NAME, @Lc_Empty_TEXT)))) = 0)
             OR (D.MergePdf_INDC = @Lc_MergePdfY_INDC
                 AND LEN(LTRIM(RTRIM(ISNULL(D.MergedPdf_NAME, @Lc_Empty_TEXT)))) > 0
                 AND EXISTS (SELECT 1
                               FROM PDAFP_Y1 X
                              WHERE X.Case_IDNO = D.Case_IDNO
                                AND X.County_IDNO = D.County_IDNO
                                AND X.MajorIntSeq_NUMB = D.MajorIntSeq_NUMB
                                AND X.ActivityMajor_CODE = D.ActivityMajor_CODE
                                AND X.GeneratePdf_INDC = @Lc_GeneratePdfN_INDC)))
     ORDER BY D.Case_IDNO,
              D.County_IDNO,
              D.MajorIntSeq_NUMB,
              D.ActivityMajor_CODE,
              D.ReasonStatus_CODE,
              D.Barcode_NUMB;

   SET @Ls_Sql_TEXT = 'OPEN UpdateNmrq_CUR';
   SET @Ls_SqlData_TEXT = '';

   OPEN UpdateNmrq_CUR;

   SET @Ls_Sql_TEXT = 'FETCH NEXT FROM UpdateNmrq_CUR - 1';
   SET @Ls_SqlData_TEXT = '';

   FETCH NEXT FROM UpdateNmrq_CUR INTO @Ln_UpdateNmrqCur_Barcode_NUMB;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
   SET @Ls_Sql_TEXT = 'FOR EACH RECORD IN UpdateNmrq_CUR';
   SET @Ls_SqlData_TEXT = '';

   --LOOP THROUGH UpdateNmrq_CUR
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
     SET @Ls_Sql_TEXT = 'UPDATE NMRQ_Y1';
     SET @Ls_Sqldata_TEXT = 'Barcode_NUMB = ' + CAST(@Ln_UpdateNmrqCur_Barcode_NUMB AS VARCHAR);

     UPDATE NMRQ_Y1
        SET StatusNotice_CODE = @Lc_StatusNoticeFailure_CODE
      WHERE Barcode_NUMB = @Ln_UpdateNmrqCur_Barcode_NUMB;

     SET @Ls_Sql_TEXT='FETCH NEXT FROM UpdateNmrq_CUR - 2';
     SET @Ls_SqlData_TEXT = '';

     FETCH NEXT FROM UpdateNmrq_CUR INTO @Ln_UpdateNmrqCur_Barcode_NUMB;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END

   SET @Ls_Sql_TEXT='CLOSE UpdateNmrq_CUR';
   SET @Ls_SqlData_TEXT = '';

   CLOSE UpdateNmrq_CUR;

   SET @Ls_Sql_TEXT='DEALLOCATE UpdateNmrq_CUR';
   SET @Ls_SqlData_TEXT = '';

   DEALLOCATE UpdateNmrq_CUR;

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE';
   SET @Ls_SqlData_TEXT = 'Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BSTL_LOG';
   SET @Ls_SqlData_TEXT = 'Status_CODE = ' + @Lc_StatusSuccess_CODE;

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CURsorLocation_TEXT       = @Lc_Empty_TEXT,
    @As_ExecLocation_TEXT         = @Lc_Successful_TEXT,
    @As_ListKey_TEXT              = @Lc_Successful_TEXT,
    @As_DescriptionError_TEXT     = @Lc_Empty_TEXT,
    @Ac_Status_CODE               = @Lc_StatusSuccess_CODE,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT;

   SET @Ls_Sql_TEXT = 'COMMIT TRANSACTION TXN_EXTRACT_NSA';
   SET @Ls_SqlData_TEXT = '';

   COMMIT TRANSACTION TXN_EXTRACT_NSA;

   SET @Ls_Sql_TEXT = 'DROP TABLE ##ExtractFcNsa_P1';
   SET @Ls_SqlData_TEXT = '';

   DROP TABLE ##ExtractFcNsa_P1;
  END TRY

  BEGIN CATCH
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION TXN_EXTRACT_NSA;
    END

   IF OBJECT_ID('tempdb..##ExtractFcNsa_P1') IS NOT NULL
    BEGIN
     DROP TABLE ##ExtractFcNsa_P1;
    END;

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

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Lc_Empty_TEXT,
    @As_ExecLocation_TEXT         = @Ls_Sql_TEXT,
    @As_ListKey_TEXT              = @Ls_SqlData_TEXT,
    @As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE               = @Lc_StatusAbnormalEnd_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH;
 END;


GO
