/****** Object:  StoredProcedure [dbo].[BATCH_LOC_INCOMING_VAP$SP_PROCESS_VAP]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_LOC_INCOMING_VAP$SP_PROCESS_VAP
Programmer Name 	: IMP Team
Description         : The procedure BATCH_LOC_INCOMING_VAP$SP_PROCESS_VAP processes the VAP and DOP data received from OVS 
				      and makes the appropriate updates in the DECSS Replacement System.
Frequency			: 'WEEKLY'
Developed On		: 07/11/2011
Called BY			: None
Called On			: 
--------------------------------------------------------------------------------------------------------------------
Modified BY			:
Modified On			:
Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_LOC_INCOMING_VAP$SP_PROCESS_VAP]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusFailed_CODE      CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE     CHAR(1) = 'S',
          @Lc_StatusAbnormalEnd_CODE CHAR(1) = 'A',
          @Lc_Note_INDC              CHAR(1) = 'N',
          @Lc_TypeErrorE_CODE        CHAR(1) = 'E',
          @Lc_ProcessY_INDC          CHAR(1) = 'Y',
          @Lc_ProcessN_INDC          CHAR(1) = 'N',
          @Lc_Space_TEXT             CHAR(1) = ' ',
          @Lc_DataRecordStatusI_CODE CHAR(1) = 'I',
          @Lc_DataRecordStatusC_CODE CHAR(1) = 'C',
          @Lc_ImageLinkN_INDC        CHAR(1) = 'N',
          @Lc_TypeDocumentVap_CODE   CHAR(3) = 'VAP',
          @Lc_PlaceOfAckOther_CODE   CHAR(3) = 'O99',
          @Lc_TableVapp_ID           CHAR(4) = 'VAPP',
          @Lc_TableSubEvrs_ID        CHAR(4) = 'EVRS',
          @Lc_BatchRunUser_TEXT      CHAR(5) = 'BATCH',
          @Lc_BateErrorE0944_CODE    CHAR(5) = 'E0944',
          @Lc_BateErrorE1404_CODE    CHAR(5) = 'E1404',
          @Lc_BateErrorE0145_CODE    CHAR(5) = 'E0145',
          @Lc_BateErrorE1424_CODE    CHAR(5) = 'E1424',
          @Lc_BateErrorE1554_CODE    CHAR(5) = 'E1554',
          @Lc_BateErrorE0705_CODE    CHAR(5) = 'E0705',
          @Lc_BateErrorE0085_CODE    CHAR(5) = 'E0085',
          @Lc_PlaceOfAckOther_NAME   CHAR(5) = 'OTHER',
          @Lc_Job_ID                 CHAR(7) = 'DEB9302',
          @Lc_Successful_TEXT        CHAR(20) = 'SUCCESSFUL',
          @Lc_ParmDateProblem_TEXT   CHAR(30) = 'PARM DATE PROBLEM',
          @Ls_Process_NAME           VARCHAR(100) = 'BATCH_LOC_INCOMING_VAP',
          @Ls_Procedure_NAME         VARCHAR(100) = 'SP_PROCESS_VAP',
          @Ld_Low_DATE               DATE = '01/01/0001';
  DECLARE @Ln_Zero_NUMB                       NUMERIC = 0,
          @Ln_CommitFreqParm_QNTY             NUMERIC(5) = 0,
          @Ln_ExceptionThresholdParm_QNTY     NUMERIC(5) = 0,
          @Ln_CommitFreq_QNTY                 NUMERIC(5) = 0,
          @Ln_ExceptionThreshold_QNTY         NUMERIC(5) = 0,
          @Ln_RestartLine_NUMB                NUMERIC(5),
          @Ln_ProcessedRecordCount_QNTY       NUMERIC(6) = 0,
          @Ln_ProcessedRecordCountCommit_QNTY NUMERIC(6) = 0,
          @Ln_RecordCount_QNTY                NUMERIC(10) = 0,
          @Ln_ErrorLine_NUMB                  NUMERIC(11) = 0,
          @Ln_Error_NUMB                      NUMERIC(11),
          @Ln_TransactionEventSeq_NUMB        NUMERIC(19) = 0,
          @Li_FetchStatus_QNTY                SMALLINT,
          @Li_RowCount_QNTY                   SMALLINT,
          @Lc_Empty_TEXT                      CHAR = '',
          @Lc_Msg_CODE                        CHAR(5),
          @Lc_BateError_CODE                  CHAR(5),
          @Lc_PlaceOfAck_CODE                 CHAR(10) = '',
          @Ls_PlaceOfAck_NAME                 VARCHAR(50) = '',
          @Ls_Sql_TEXT                        VARCHAR(200) = '',
          @Ls_CursorLocation_TEXT             VARCHAR(200),
          @Ls_SqlData_TEXT                    VARCHAR(1000) = '',
          @Ls_ErrorMessage_TEXT               VARCHAR(2000),
          @Ls_DescriptionError_TEXT           VARCHAR(4000),
          @Ls_BateRecord_TEXT                 VARCHAR(4000),
          @Ld_Run_DATE                        DATE,
          @Ld_LastRun_DATE                    DATE,
          @Ld_Start_DATE                      DATETIME2;
  DECLARE @Ln_VappCur_Seq_IDNO                     NUMERIC(19, 0),
          @Lc_VappCur_ChildBirthDate_TEXT          CHAR(8),
          @Lc_VappCur_ChildFirstName_TEXT          CHAR(15),
          @Lc_VappCur_ChildLastName_TEXT           CHAR(20),
          @Lc_VappCur_ChildBirthCertificateId_TEXT CHAR(6),
          @Lc_VappCur_MotherFirstName_TEXT         CHAR(15),
          @Lc_VappCur_MotherLastName_TEXT          CHAR(20),
          @Lc_VappCur_MotherSsnNumb_TEXT           CHAR(9),
          @Lc_VappCur_MotherBirthDate_TEXT         CHAR(8),
          @Lc_VappCur_FatherFirstName_TEXT         CHAR(15),
          @Lc_VappCur_FatherLastName_TEXT          CHAR(20),
          @Lc_VappCur_FatherSsnNumb_TEXT           CHAR(9),
          @Lc_VappCur_FatherBirthDate_TEXT         CHAR(8),
          @Ls_VappCur_PlaceAckSignedName_TEXT      VARCHAR(50),
          @Lc_VappCur_ChildBirthStateCode_TEXT     CHAR(2);
  DECLARE @Ln_VappCur_MotherSsn_NUMB                  NUMERIC(9),
          @Ln_VappCur_FatherSsn_NUMB                  NUMERIC(9),
          @Lc_VappCur_ChildBirthYearNumb_TEXT         CHAR(2),
          @Lc_VappCur_NewChildBirthCertificateId_TEXT CHAR(7),
          @Ld_VappCur_ChildBirth_DATE                 DATE,
          @Ld_VappCur_MotherBirth_DATE                DATE,
          @Ld_VappCur_FatherBirth_DATE                DATE;
  /* Commented and kept for future use
    @Lc_VappCur_MotherAddressNormalization_CODE CHAR(1),
    @Ls_VappCur_MotherLine1_ADDR         VARCHAR(50),
    @Ls_VappCur_MotherLine2_ADDR         VARCHAR(50),
    @Lc_VappCur_MotherCity_ADDR          CHAR(28),
    @Lc_VappCur_MotherState_ADDR         CHAR(2),
    @Lc_VappCur_MotherZip_ADDR           CHAR(15),
    @Lc_VappCur_FatherEmplAddressNormalization_CODE CHAR(1),
    @Ls_VappCur_FatherEmplLine1_ADDR VARCHAR(50),
    @Ls_VappCur_FatherEmplLine2_ADDR VARCHAR(50),
    @Lc_VappCur_FatherEmplCity_ADDR CHAR(28),
    @Lc_VappCur_FatherEmplState_ADDR CHAR(2),
    @Lc_VappCur_FatherEmplZip_ADDR CHAR(15),
    @Lc_VappCur_FatherAddressNormalization_CODE CHAR(1),
    @Ls_VappCur_FatherLine1_ADDR         VARCHAR(50),
    @Ls_VappCur_FatherLine2_ADDR         VARCHAR(50),
    @Lc_VappCur_FatherCity_ADDR          CHAR(28),
    @Lc_VappCur_FatherState_ADDR         CHAR(2),
    @Lc_VappCur_FatherZip_ADDR           CHAR(15);
  */
  DECLARE Vapp_CUR INSENSITIVE CURSOR FOR
   SELECT A.Seq_IDNO,
          A.ChildBirth_DATE,
          A.ChildFirst_NAME,
          A.ChildLast_NAME,
          A.ChildBirthCertificate_ID,
          A.MotherFirst_NAME,
          A.MotherLast_NAME,
          A.MotherSsn_NUMB,
          A.MotherBirth_DATE,
          A.FatherFirst_NAME,
          A.FatherLast_NAME,
          A.FatherSsn_NUMB,
          A.FatherBirth_DATE,
          A.PlaceAckSigned_NAME,
          A.ChildBirthState_CODE
     /* Commented and kept for future use          
               MotherAddressNormalization_CODE,
               MotherLine1_ADDR,
               MotherLine2_ADDR,
               MotherCity_ADDR,
               MotherState_ADDR,
               MotherZip_ADDR,
               FatherEmplAddressNormalization_CODE,
               FatherEmplLine1_ADDR,
               FatherEmplLine2_ADDR,
               FatherEmplCity_ADDR,
               FatherEmplState_ADDR,
               FatherEmplZip_ADDR,
               FatherAddressNormalization_CODE,
               FatherLine1_ADDR,
               FatherLine2_ADDR,
               FatherCity_ADDR,
               FatherState_ADDR,
               FatherZip_ADDR
     */
     FROM LVAPP_Y1 A
    WHERE A.Process_INDC = @Lc_ProcessN_INDC
    ORDER BY A.Seq_IDNO;

  BEGIN TRY
   SET @Ls_Sql_TEXT = 'BEGIN TRANSACTION TXN_PROCESS_VAP';
   SET @Ls_SqlData_TEXT = '';

   BEGIN TRANSACTION TXN_PROCESS_VAP;

   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS';
   SET @Ls_SqlData_TEXT = 'Job_ID = ' + @Lc_Job_ID;

   EXECUTE BATCH_COMMON$SP_GET_BATCH_DETAILS
    @Ac_Job_ID                  = @Lc_Job_ID,
    @Ad_Run_DATE                = @Ld_Run_DATE OUTPUT,
    @Ad_LastRun_DATE            = @Ld_LastRun_DATE OUTPUT,
    @An_CommitFreq_QNTY         = @Ln_CommitFreqParm_QNTY OUTPUT,
    @An_ExceptionThreshold_QNTY = @Ln_ExceptionThresholdParm_QNTY OUTPUT,
    @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT   = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'RUN DATE AND LAST RUN DATE VALIDATION';
   SET @Ls_SqlData_TEXT = 'LastRun_DATE = ' + CAST(@Ld_LastRun_DATE AS VARCHAR) + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   IF DATEADD(D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = @Lc_ParmDateProblem_TEXT;

     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'CHECK FOR RECORDS TO PROCESS FROM LVAPP_Y1';
   SET @Ls_SqlData_TEXT = '';

   IF EXISTS (SELECT 1
                FROM LVAPP_Y1 A
               WHERE A.Process_INDC = @Lc_ProcessN_INDC)
    BEGIN
     SET @Ls_Sql_TEXT = 'OPEN Vapp_CUR';
     SET @Ls_SqlData_TEXT = '';

     OPEN Vapp_CUR;

     SET @Ls_Sql_TEXT = 'FETCH NEXT FROM Vapp_CUR - 1';
     SET @Ls_SqlData_TEXT = '';

     FETCH NEXT FROM Vapp_CUR INTO @Ln_VappCur_Seq_IDNO, @Lc_VappCur_ChildBirthDate_TEXT, @Lc_VappCur_ChildFirstName_TEXT, @Lc_VappCur_ChildLastName_TEXT, @Lc_VappCur_ChildBirthCertificateId_TEXT, @Lc_VappCur_MotherFirstName_TEXT, @Lc_VappCur_MotherLastName_TEXT, @Lc_VappCur_MotherSsnNumb_TEXT, @Lc_VappCur_MotherBirthDate_TEXT, @Lc_VappCur_FatherFirstName_TEXT, @Lc_VappCur_FatherLastName_TEXT, @Lc_VappCur_FatherSsnNumb_TEXT, @Lc_VappCur_FatherBirthDate_TEXT, @Ls_VappCur_PlaceAckSignedName_TEXT, @Lc_VappCur_ChildBirthStateCode_TEXT;

     /* Commented and kept for future use   
        @Lc_VappCur_MotherAddressNormalization_CODE,
        @Ls_VappCur_MotherLine1_ADDR, @Ls_VappCur_MotherLine2_ADDR, @Lc_VappCur_MotherCity_ADDR, @Lc_VappCur_MotherState_ADDR, @Lc_VappCur_MotherZip_ADDR,
        @Lc_VappCur_FatherEmplAddressNormalization_CODE,
        @Ls_VappCur_FatherEmplLine1_ADDR,
        @Ls_VappCur_FatherEmplLine2_ADDR,
        @Lc_VappCur_FatherEmplCity_ADDR,
        @Lc_VappCur_FatherEmplState_ADDR,
        @Lc_VappCur_FatherEmplZip_ADDR,
        @Lc_VappCur_FatherAddressNormalization_CODE,
        @Ls_VappCur_FatherLine1_ADDR, @Ls_VappCur_FatherLine2_ADDR, @Lc_VappCur_FatherCity_ADDR, @Lc_VappCur_FatherState_ADDR, @Lc_VappCur_FatherZip_ADDR; 
     */
     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
     SET @Ls_Sql_TEXT = 'LOOP THROUGH Vapp_CUR';
     SET @Ls_SqlData_TEXT = '';

     --Process the VAP and DOP data received from OVS and make the appropriate updates in the DECSS Replacement System.
     WHILE @Li_FetchStatus_QNTY = 0
      BEGIN
       BEGIN TRY
        SAVE TRANSACTION SAVE_PROCESS_VAP;

        SET @Lc_BateError_CODE = @Lc_BateErrorE1424_CODE;
        SET @Ls_ErrorMessage_TEXT = '';
        SET @Ln_RecordCount_QNTY = @Ln_RecordCount_QNTY + 1;
        SET @Ln_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY + 1;
        SET @Ln_CommitFreq_QNTY = @Ln_CommitFreq_QNTY + 1;
        SET @Ls_CursorLocation_TEXT = 'Vapp - CURSOR COUNT - ' + CAST(@Ln_RecordCount_QNTY AS VARCHAR);
        SET @Ls_BateRecord_TEXT = 'Seq_IDNO = ' + CAST(@Ln_VappCur_Seq_IDNO AS VARCHAR) + ', ChildBirth_DATE = ' + @Lc_VappCur_ChildBirthDate_TEXT + ', ChildFirst_NAME = ' + @Lc_VappCur_ChildFirstName_TEXT + ', ChildLast_NAME = ' + @Lc_VappCur_ChildLastName_TEXT + ', ChildBirthCertificate_ID = ' + @Lc_VappCur_ChildBirthCertificateId_TEXT + ', MotherFirst_NAME = ' + @Lc_VappCur_MotherFirstName_TEXT + ', MotherLast_NAME = ' + @Lc_VappCur_MotherLastName_TEXT + ', MotherSsn_NUMB = ' + @Lc_VappCur_MotherSsnNumb_TEXT + ', MotherBirth_DATE = ' + @Lc_VappCur_MotherBirthDate_TEXT + ', FatherFirst_NAME = ' + @Lc_VappCur_FatherFirstName_TEXT + ', FatherLast_NAME = ' + @Lc_VappCur_FatherLastName_TEXT + ', FatherSsn_NUMB = ' + @Lc_VappCur_FatherSsnNumb_TEXT + ', FatherBirth_DATE = ' + @Lc_VappCur_FatherBirthDate_TEXT + ', PlaceAckSigned_NAME = ' + @Ls_VappCur_PlaceAckSignedName_TEXT + ', ChildBirthState_CODE = ' + @Lc_VappCur_ChildBirthStateCode_TEXT;
        /* Commented and kept for future use
                ', MotherLine1_ADDR = ' + @Ls_VappCur_MotherLine1_ADDR + 
                ', MotherLine2_ADDR = ' + @Ls_VappCur_MotherLine2_ADDR + 
                ', MotherCity_ADDR = ' + @Lc_VappCur_MotherCity_ADDR + 
                ', MotherState_ADDR = ' + @Lc_VappCur_MotherState_ADDR + 
                ', MotherZip_ADDR = ' + @Lc_VappCur_MotherZip_ADDR + 
                ', FatherLine1_ADDR = ' + @Ls_VappCur_FatherLine1_ADDR + 
                ', FatherLine2_ADDR = ' + @Ls_VappCur_FatherLine2_ADDR + 
                ', FatherCity_ADDR = ' + @Lc_VappCur_FatherCity_ADDR + 
                ', FatherState_ADDR = ' + @Lc_VappCur_FatherState_ADDR + 
                ', FatherZip_ADDR = ' + @Lc_VappCur_FatherZip_ADDR;
        */
        SET @Ls_Sql_TEXT = 'CHECK FOR MISSING BIRTH CERTIFICATE NUMBER';
        SET @Ls_SqlData_TEXT = 'ChildBirthCertificate_ID = ' + @Lc_VappCur_ChildBirthCertificateId_TEXT;

        IF LEN(LTRIM(RTRIM(ISNULL(@Lc_VappCur_ChildBirthCertificateId_TEXT, @Lc_Empty_TEXT)))) = 0
         BEGIN
          SELECT @Lc_BateError_CODE = @Lc_BateErrorE1404_CODE,
                 @Ls_ErrorMessage_TEXT = 'MISSING BIRTH CERTIFICATE NUMBER';

          RAISERROR(50001,16,1);
         END;
        ELSE IF ISNUMERIC(LTRIM(RTRIM(ISNULL(@Lc_VappCur_ChildBirthCertificateId_TEXT, @Lc_Empty_TEXT)))) = 0
            OR CAST(LTRIM(RTRIM(ISNULL(@Lc_VappCur_ChildBirthCertificateId_TEXT, @Lc_Empty_TEXT))) AS NUMERIC) = 0
         BEGIN
          SET @Lc_BateError_CODE = @Lc_BateErrorE0085_CODE;
          SET @Ls_ErrorMessage_TEXT = 'INVALID VALUE';

          RAISERROR(50001,16,1);
         END;

        SET @Ls_Sql_TEXT = 'CHECK FOR LEADING 0 (ZERO) IN BIRTH CERTIFICATE NUMBER';
        SET @Ls_SqlData_TEXT = 'ChildBirthCertificate_ID = ' + @Lc_VappCur_ChildBirthCertificateId_TEXT;

        IF LEFT(LTRIM(RTRIM(@Lc_VappCur_ChildBirthCertificateId_TEXT)), 1) <> '0'
         BEGIN
          SELECT @Lc_BateError_CODE = @Lc_BateErrorE1554_CODE,
                 @Ls_ErrorMessage_TEXT = 'INVALID BIRTH CERTIFICATE NUMBER. LEADING 0 (ZERO) MISSING.';

          RAISERROR(50001,16,1);
         END;
        ELSE
         BEGIN
          SET @Lc_VappCur_ChildBirthCertificateId_TEXT = RIGHT(LTRIM(RTRIM(@Lc_VappCur_ChildBirthCertificateId_TEXT)), 5);
         END;

        SET @Ls_Sql_TEXT = 'CHECK CHILD BIRTH DATE';
        SET @Ls_SqlData_TEXT = 'ChildBirthDate_TEXT = ' + @Lc_VappCur_ChildBirthDate_TEXT;

        IF LEN(LTRIM(RTRIM(@Lc_VappCur_ChildBirthDate_TEXT))) = 0
            OR ISDATE(LTRIM(RTRIM(@Lc_VappCur_ChildBirthDate_TEXT))) = 0
         BEGIN
          SELECT @Lc_BateError_CODE = @Lc_BateErrorE0705_CODE,
                 @Ls_ErrorMessage_TEXT = 'NO DATE OF BIRTH SPECIFIED FOR THIS CHILD';

          RAISERROR(50001,16,1);
         END;
        ELSE
         BEGIN
          SET @Lc_VappCur_ChildBirthYearNumb_TEXT = SUBSTRING(LTRIM(RTRIM(@Lc_VappCur_ChildBirthDate_TEXT)), 3, 2);
          SET @Ld_VappCur_ChildBirth_DATE = CAST(LTRIM(RTRIM(@Lc_VappCur_ChildBirthDate_TEXT)) AS DATE);
         END;

        SET @Ls_Sql_TEXT = 'DERIVE NEW BIRTH CERTIFICATE ID FROM CHILD BIRTH CERTIFICATE ID AND CHILD YEAR OF BIRTH';
        SET @Ls_SqlData_TEXT = 'ChildBirthYearNumb_TEXT = ' + @Lc_VappCur_ChildBirthYearNumb_TEXT + ', ChildBirthCertificateId_TEXT = ' + @Lc_VappCur_ChildBirthCertificateId_TEXT;
        SET @Lc_VappCur_NewChildBirthCertificateId_TEXT = @Lc_VappCur_ChildBirthYearNumb_TEXT + @Lc_VappCur_ChildBirthCertificateId_TEXT;
        SET @Ls_Sql_TEXT = 'CHECK WHETHER DUPLICATE RECORD EXISTS';
        SET @Ls_SqlData_TEXT = 'ChildBirthCertificate_ID = ' + @Lc_VappCur_NewChildBirthCertificateId_TEXT;

        IF EXISTS (SELECT 1
                     FROM VAPP_Y1 X
                    WHERE UPPER(LTRIM(RTRIM(X.ChildBirthCertificate_ID))) = UPPER(LTRIM(RTRIM(@Lc_VappCur_NewChildBirthCertificateId_TEXT)))
                      AND X.TypeDocument_CODE = @Lc_TypeDocumentVap_CODE
                      AND UPPER(LTRIM(RTRIM(X.DataRecordStatus_CODE))) = @Lc_DataRecordStatusC_CODE)
         BEGIN
          SELECT @Lc_BateError_CODE = @Lc_BateErrorE0145_CODE,
                 @Ls_ErrorMessage_TEXT = 'DUPLICATE RECORD EXISTS';

          RAISERROR(50001,16,1);
         END;

        IF LEN(LTRIM(RTRIM(@Lc_VappCur_MotherSsnNumb_TEXT))) = 0
            OR ISNUMERIC(LTRIM(RTRIM(@Lc_VappCur_MotherSsnNumb_TEXT))) = 0
         BEGIN
          SET @Ln_VappCur_MotherSsn_NUMB = @Ln_Zero_NUMB;
         END;
        ELSE
         BEGIN
          SET @Ln_VappCur_MotherSsn_NUMB = CAST(LTRIM(RTRIM(@Lc_VappCur_MotherSsnNumb_TEXT)) AS NUMERIC);
         END;

        IF LEN(LTRIM(RTRIM(@Lc_VappCur_MotherBirthDate_TEXT))) = 0
            OR ISDATE(LTRIM(RTRIM(@Lc_VappCur_MotherBirthDate_TEXT))) = 0
         BEGIN
          SET @Ld_VappCur_MotherBirth_DATE = @Ld_Low_DATE;
         END;
        ELSE
         BEGIN
          SET @Ld_VappCur_MotherBirth_DATE = CAST(LTRIM(RTRIM(@Lc_VappCur_MotherBirthDate_TEXT)) AS DATE);
         END;

        IF LEN(LTRIM(RTRIM(@Lc_VappCur_FatherSsnNumb_TEXT))) = 0
            OR ISNUMERIC(LTRIM(RTRIM(@Lc_VappCur_FatherSsnNumb_TEXT))) = 0
         BEGIN
          SET @Ln_VappCur_FatherSsn_NUMB = @Ln_Zero_NUMB;
         END;
        ELSE
         BEGIN
          SET @Ln_VappCur_FatherSsn_NUMB = CAST(LTRIM(RTRIM(@Lc_VappCur_FatherSsnNumb_TEXT)) AS NUMERIC);
         END;

        IF LEN(LTRIM(RTRIM(@Lc_VappCur_FatherBirthDate_TEXT))) = 0
            OR ISDATE(LTRIM(RTRIM(@Lc_VappCur_FatherBirthDate_TEXT))) = 0
         BEGIN
          SET @Ld_VappCur_FatherBirth_DATE = @Ld_Low_DATE;
         END;
        ELSE
         BEGIN
          SET @Ld_VappCur_FatherBirth_DATE = CAST(LTRIM(RTRIM(@Lc_VappCur_FatherBirthDate_TEXT)) AS DATE);
         END;

        IF LEN(LTRIM(RTRIM(ISNULL(@Ls_VappCur_PlaceAckSignedName_TEXT, @Lc_Empty_TEXT)))) = 0
         BEGIN
          SET @Ls_PlaceOfAck_NAME = @Lc_PlaceOfAckOther_NAME;
          SET @Lc_PlaceOfAck_CODE = @Lc_PlaceOfAckOther_CODE;
         END;
        ELSE
         BEGIN
          SET @Ls_PlaceOfAck_NAME = LTRIM(RTRIM(@Ls_VappCur_PlaceAckSignedName_TEXT));
          SET @Lc_PlaceOfAck_CODE = ISNULL((SELECT LTRIM(RTRIM(Y.Type_CODE))
                                              FROM REFM_Y1 X,
                                                   RESF_Y1 Y
                                             WHERE X.Table_ID = @Lc_TableVapp_ID
                                               AND X.TableSub_ID = @Lc_TableSubEvrs_ID
                                               AND UPPER(LTRIM(RTRIM(X.DescriptionValue_TEXT))) = UPPER(@Ls_PlaceOfAck_NAME)
                                               AND Y.Process_ID = X.Table_ID
                                               AND Y.Table_ID = X.Table_ID
                                               AND Y.TableSub_ID = X.TableSub_ID
                                               AND UPPER(LTRIM(RTRIM(Y.Reason_CODE))) = UPPER(LTRIM(RTRIM(X.Value_CODE)))), @Lc_PlaceOfAckOther_CODE);
         END;

        SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT';
        SET @Ls_SqlData_TEXT = 'Process_ID = ' + @Lc_Job_ID;

        EXEC BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
         @Ac_Worker_ID                = @Lc_BatchRunUser_TEXT,
         @Ac_Process_ID               = @Lc_Job_ID,
         @Ad_EffectiveEvent_DATE      = @Ld_Run_DATE,
         @Ac_Note_INDC                = @Lc_Note_INDC,
         @An_EventFunctionalSeq_NUMB  = @Ln_Zero_NUMB,
         @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
         @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
         @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

        IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
         BEGIN
          SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

          RAISERROR (50001,16,1);
         END;

        SET @Ls_Sql_TEXT = 'CHECK WHETHER VAPP RECORD ALREADY EXISTS';
        SET @Ls_SqlData_TEXT = 'ChildBirthCertificate_ID = ' + @Lc_VappCur_NewChildBirthCertificateId_TEXT;

        IF EXISTS (SELECT 1
                     FROM VAPP_Y1 X
                    WHERE UPPER(LTRIM(RTRIM(X.TypeDocument_CODE))) = @Lc_TypeDocumentVap_CODE
                      AND UPPER(LTRIM(RTRIM(X.ChildBirthCertificate_ID))) = UPPER(LTRIM(RTRIM(@Lc_VappCur_NewChildBirthCertificateId_TEXT))))
         BEGIN
          SET @Ls_Sql_TEXT = 'MOVE EXISTING RECORD TO HVAPP_Y1';
          SET @Ls_SqlData_TEXT = '';

          INSERT INTO HVAPP_Y1
                      (ChildBirthCertificate_ID,
                       TypeDocument_CODE,
                       ChildMemberMci_IDNO,
                       ChildLast_NAME,
                       ChildFirst_NAME,
                       ChildBirth_DATE,
                       ChildMemberSsn_NUMB,
                       ChildBirthState_CODE,
                       ChildBirthCity_INDC,
                       ChildBirthCounty_INDC,
                       PlaceOfAck_CODE,
                       PlaceOfAck_NAME,
                       Declaration_INDC,
                       GeneticTest_INDC,
                       NoPresumedFather_CODE,
                       VapPresumedFather_CODE,
                       DopPresumedFather_CODE,
                       VapAttached_CODE,
                       DopAttached_CODE,
                       MotherSignature_DATE,
                       FatherSignature_DATE,
                       Match_DATE,
                       DataRecordStatus_CODE,
                       ImageLink_INDC,
                       FatherMemberMci_IDNO,
                       FatherLast_NAME,
                       FatherFirst_NAME,
                       FatherBirth_DATE,
                       FatherMemberSsn_NUMB,
                       FatherAddrExist_INDC,
                       MotherMemberMci_IDNO,
                       MotherLast_NAME,
                       MotherFirst_NAME,
                       MotherBirth_DATE,
                       MotherMemberSsn_NUMB,
                       MotherAddrExist_INDC,
                       Note_TEXT,
                       BeginValidity_DATE,
                       EndValidity_DATE,
                       WorkerUpdate_ID,
                       TransactionEventSeq_NUMB,
                       Update_DTTM,
                       MatchPoint_QNTY)
          SELECT A.ChildBirthCertificate_ID,
                 A.TypeDocument_CODE,
                 A.ChildMemberMci_IDNO,
                 A.ChildLast_NAME,
                 A.ChildFirst_NAME,
                 A.ChildBirth_DATE,
                 A.ChildMemberSsn_NUMB,
                 A.ChildBirthState_CODE,
                 A.ChildBirthCity_INDC,
                 A.ChildBirthCounty_INDC,
                 A.PlaceOfAck_CODE,
                 A.PlaceOfAck_NAME,
                 A.Declaration_INDC,
                 A.GeneticTest_INDC,
                 A.NoPresumedFather_CODE,
                 A.VapPresumedFather_CODE,
                 A.DopPresumedFather_CODE,
                 A.VapAttached_CODE,
                 A.DopAttached_CODE,
                 A.MotherSignature_DATE,
                 A.FatherSignature_DATE,
                 A.Match_DATE,
                 A.DataRecordStatus_CODE,
                 A.ImageLink_INDC,
                 A.FatherMemberMci_IDNO,
                 A.FatherLast_NAME,
                 A.FatherFirst_NAME,
                 A.FatherBirth_DATE,
                 A.FatherMemberSsn_NUMB,
                 A.FatherAddrExist_INDC,
                 A.MotherMemberMci_IDNO,
                 A.MotherLast_NAME,
                 A.MotherFirst_NAME,
                 A.MotherBirth_DATE,
                 A.MotherMemberSsn_NUMB,
                 A.MotherAddrExist_INDC,
                 A.Note_TEXT,
                 A.BeginValidity_DATE,
                 @Ld_Run_DATE AS EndValidity_DATE,
                 A.WorkerUpdate_ID,
                 A.TransactionEventSeq_NUMB,
                 @Ld_Start_DATE AS Update_DTTM,
                 A.MatchPoint_QNTY
            FROM VAPP_Y1 A
           WHERE UPPER(LTRIM(RTRIM(TypeDocument_CODE))) = @Lc_TypeDocumentVap_CODE
             AND UPPER(LTRIM(RTRIM(ChildBirthCertificate_ID))) = UPPER(LTRIM(RTRIM(@Lc_VappCur_NewChildBirthCertificateId_TEXT)));

          SET @Li_RowCount_QNTY = @@ROWCOUNT;

          IF @Li_RowCount_QNTY = 0
           BEGIN
            SET @Ls_ErrorMessage_TEXT = 'INSERT INTO HVAPP_Y1 FAILED';

            RAISERROR(50001,16,1);
           END;

          SET @Ls_Sql_TEXT = 'UPDATE VAPP_Y1';
          SET @Ls_SqlData_TEXT = '';

          UPDATE VAPP_Y1
             SET ChildBirth_DATE = @Ld_VappCur_ChildBirth_DATE,
                 ChildFirst_NAME = LTRIM(RTRIM(ISNULL(@Lc_VappCur_ChildFirstName_TEXT, @Lc_Empty_TEXT))),
                 ChildLast_NAME = LTRIM(RTRIM(ISNULL(@Lc_VappCur_ChildLastName_TEXT, @Lc_Empty_TEXT))),
                 ChildBirthState_CODE = LTRIM(RTRIM(ISNULL(@Lc_VappCur_ChildBirthStateCode_TEXT, @Lc_Empty_TEXT))),
                 PlaceOfAck_NAME = @Ls_PlaceOfAck_NAME,
                 PlaceOfAck_CODE = @Lc_PlaceOfAck_CODE,
                 MotherFirst_NAME = LTRIM(RTRIM(ISNULL(@Lc_VappCur_MotherFirstName_TEXT, @Lc_Empty_TEXT))),
                 MotherLast_NAME = LTRIM(RTRIM(ISNULL(@Lc_VappCur_MotherLastName_TEXT, @Lc_Empty_TEXT))),
                 MotherMemberSsn_NUMB = @Ln_VappCur_MotherSsn_NUMB,
                 MotherBirth_DATE = @Ld_VappCur_MotherBirth_DATE,
                 FatherFirst_NAME = LTRIM(RTRIM(ISNULL(@Lc_VappCur_FatherFirstName_TEXT, @Lc_Empty_TEXT))),
                 FatherLast_NAME = LTRIM(RTRIM(ISNULL(@Lc_VappCur_FatherLastName_TEXT, @Lc_Empty_TEXT))),
                 FatherMemberSsn_NUMB = @Ln_VappCur_FatherSsn_NUMB,
                 FatherBirth_DATE = @Ld_VappCur_FatherBirth_DATE,
                 BeginValidity_DATE = @Ld_Run_DATE,
                 WorkerUpdate_ID = @Lc_BatchRunUser_TEXT,
                 TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
                 Update_DTTM = @Ld_Start_DATE,
                 DataRecordStatus_CODE = @Lc_DataRecordStatusI_CODE
           WHERE UPPER(LTRIM(RTRIM(TypeDocument_CODE))) = @Lc_TypeDocumentVap_CODE
             AND UPPER(LTRIM(RTRIM(ChildBirthCertificate_ID))) = UPPER(LTRIM(RTRIM(@Lc_VappCur_NewChildBirthCertificateId_TEXT)));

          SET @Li_RowCount_QNTY = @@ROWCOUNT;

          IF @Li_RowCount_QNTY = 0
           BEGIN
            SET @Ls_ErrorMessage_TEXT = 'UPDATE VAPP_Y1 FAILED';

            RAISERROR(50001,16,1);
           END;
         END;
        ELSE
         BEGIN
          SET @Ls_Sql_TEXT = 'INSERT NEW RECORD INTO VAPP_Y1';
          SET @Ls_SqlData_TEXT = '';

          INSERT INTO VAPP_Y1
                      (ChildBirthCertificate_ID,
                       TypeDocument_CODE,
                       ChildMemberMci_IDNO,
                       ChildLast_NAME,
                       ChildFirst_NAME,
                       ChildBirth_DATE,
                       ChildMemberSsn_NUMB,
                       ChildBirthState_CODE,
                       ChildBirthCity_INDC,
                       ChildBirthCounty_INDC,
                       PlaceOfAck_CODE,
                       PlaceOfAck_NAME,
                       Declaration_INDC,
                       GeneticTest_INDC,
                       NoPresumedFather_CODE,
                       VapPresumedFather_CODE,
                       DopPresumedFather_CODE,
                       VapAttached_CODE,
                       DopAttached_CODE,
                       MotherSignature_DATE,
                       FatherSignature_DATE,
                       Match_DATE,
                       DataRecordStatus_CODE,
                       ImageLink_INDC,
                       FatherMemberMci_IDNO,
                       FatherLast_NAME,
                       FatherFirst_NAME,
                       FatherBirth_DATE,
                       FatherMemberSsn_NUMB,
                       FatherAddrExist_INDC,
                       MotherMemberMci_IDNO,
                       MotherLast_NAME,
                       MotherFirst_NAME,
                       MotherBirth_DATE,
                       MotherMemberSsn_NUMB,
                       MotherAddrExist_INDC,
                       Note_TEXT,
                       BeginValidity_DATE,
                       WorkerUpdate_ID,
                       TransactionEventSeq_NUMB,
                       Update_DTTM,
                       MatchPoint_QNTY)
               VALUES ( LTRIM(RTRIM(ISNULL(@Lc_VappCur_NewChildBirthCertificateId_TEXT, @Lc_Empty_TEXT))),--ChildBirthCertificate_ID
                        @Lc_TypeDocumentVap_CODE,--TypeDocument_CODE
                        @Ln_Zero_NUMB,--ChildMemberMci_IDNO
                        LTRIM(RTRIM(ISNULL(@Lc_VappCur_ChildLastName_TEXT, @Lc_Empty_TEXT))),--ChildLast_NAME
                        LTRIM(RTRIM(ISNULL(@Lc_VappCur_ChildFirstName_TEXT, @Lc_Empty_TEXT))),--ChildFirst_NAME
                        @Ld_VappCur_ChildBirth_DATE,--ChildBirth_DATE
                        @Ln_Zero_NUMB,--ChildMemberSsn_NUMB
                        LTRIM(RTRIM(ISNULL(@Lc_VappCur_ChildBirthStateCode_TEXT, @Lc_Empty_TEXT))),--ChildBirthState_CODE
                        @Lc_Space_TEXT,--ChildBirthCity_INDC
                        @Lc_Space_TEXT,--ChildBirthCounty_INDC
                        @Lc_PlaceOfAck_CODE,--PlaceOfAck_CODE
                        @Ls_PlaceOfAck_NAME,--PlaceOfAck_NAME
                        @Lc_Space_TEXT,--Declaration_INDC
                        @Lc_Space_TEXT,--GeneticTest_INDC
                        @Lc_Empty_TEXT,--NoPresumedFather_CODE
                        @Lc_Empty_TEXT,--VapPresumedFather_CODE
                        @Lc_Empty_TEXT,--DopPresumedFather_CODE
                        @Lc_Empty_TEXT,--VapAttached_CODE
                        @Lc_Empty_TEXT,--DopAttached_CODE
                        @Ld_Low_DATE,--MotherSignature_DATE
                        @Ld_Low_DATE,--FatherSignature_DATE
                        @Ld_Low_DATE,--Match_DATE
                        @Lc_DataRecordStatusI_CODE,--DataRecordStatus_CODE
                        @Lc_ImageLinkN_INDC,--ImageLink_INDC
                        @Ln_Zero_NUMB,--FatherMemberMci_IDNO
                        LTRIM(RTRIM(ISNULL(@Lc_VappCur_FatherLastName_TEXT, @Lc_Empty_TEXT))),--FatherLast_NAME
                        LTRIM(RTRIM(ISNULL(@Lc_VappCur_FatherFirstName_TEXT, @Lc_Empty_TEXT))),--FatherFirst_NAME
                        @Ld_VappCur_FatherBirth_DATE,--FatherBirth_DATE
                        @Ln_VappCur_FatherSsn_NUMB,--FatherMemberSsn_NUMB
                        @Lc_Space_TEXT,--FatherAddrExist_INDC
                        @Ln_Zero_NUMB,--MotherMemberMci_IDNO
                        LTRIM(RTRIM(ISNULL(@Lc_VappCur_MotherLastName_TEXT, @Lc_Empty_TEXT))),--MotherLast_NAME
                        LTRIM(RTRIM(ISNULL(@Lc_VappCur_MotherFirstName_TEXT, @Lc_Empty_TEXT))),--MotherFirst_NAME
                        @Ld_VappCur_MotherBirth_DATE,--MotherBirth_DATE
                        @Ln_VappCur_MotherSsn_NUMB,--MotherMemberSsn_NUMB
                        @Lc_Space_TEXT,--MotherAddrExist_INDC
                        @Lc_Empty_TEXT,--Note_TEXT
                        @Ld_Run_DATE,--BeginValidity_DATE
                        @Lc_BatchRunUser_TEXT,--WorkerUpdate_ID
                        @Ln_TransactionEventSeq_NUMB,--TransactionEventSeq_NUMB
                        @Ld_Start_DATE,--Update_DTTM
                        @Ln_Zero_NUMB --MatchPoint_QNTY
          );

          SET @Li_RowCount_QNTY = @@ROWCOUNT;

          IF @Li_RowCount_QNTY = 0
           BEGIN
            SET @Ls_ErrorMessage_TEXT = 'INSERT INTO VAPP_Y1 FAILED';

            RAISERROR(50001,16,1);
           END;
         END;
       END TRY

       BEGIN CATCH
        IF XACT_STATE() = 1
         BEGIN
          ROLLBACK TRANSACTION SAVE_PROCESS_VAP;
         END
        ELSE
         BEGIN
          SET @Ls_ErrorMessage_TEXT = @Ls_ErrorMessage_TEXT + ' ' + SUBSTRING(ERROR_MESSAGE(), 1, 200);

          RAISERROR(50001,16,1);
         END

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

        SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG';
        SET @Ls_SqlData_TEXT = '';

        EXECUTE BATCH_COMMON$SP_BATE_LOG
         @As_Process_NAME             = @Ls_Process_NAME,
         @As_Procedure_NAME           = @Ls_Procedure_NAME,
         @Ac_Job_ID                   = @Lc_Job_ID,
         @Ad_Run_DATE                 = @Ld_Run_DATE,
         @Ac_TypeError_CODE           = @Lc_TypeErrorE_CODE,
         @An_Line_NUMB                = @Ln_RecordCount_QNTY,
         @Ac_Error_CODE               = @Lc_BateError_CODE,
         @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
         @As_ListKey_TEXT             = @Ls_BateRecord_TEXT,
         @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
         @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

        IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
         BEGIN
          SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

          RAISERROR(50001,16,1);
         END;

        IF @Lc_Msg_CODE = @Lc_TypeErrorE_CODE
         BEGIN
          SET @Ln_ExceptionThreshold_QNTY = @Ln_ExceptionThreshold_QNTY + 1;
         END
       END CATCH;

       SET @Ls_Sql_TEXT = 'UPDATE LVAPP_Y1';
       SET @Ls_SqlData_TEXT = 'Seq_IDNO = ' + CAST(@Ln_VappCur_Seq_IDNO AS VARCHAR);

       UPDATE LVAPP_Y1
          SET Process_INDC = @Lc_ProcessY_INDC
        WHERE Seq_IDNO = @Ln_VappCur_Seq_IDNO;

       SET @Li_RowCount_QNTY = @@ROWCOUNT;

       IF @Li_RowCount_QNTY = 0
        BEGIN
         SET @Ls_ErrorMessage_TEXT = 'UPDATE LVAPP_Y1 FAILED';

         RAISERROR (50001,16,1);
        END;

       SET @Ls_Sql_TEXT = 'CHECKING COMMIT FREQUENCY';
       SET @Ls_SqlData_TEXT = 'CommitFreqParm_QNTY = ' + CAST(@Ln_CommitFreqParm_QNTY AS VARCHAR) + ', CommitFreq_QNTY = ' + CAST(@Ln_CommitFreq_QNTY AS VARCHAR);

       IF @Ln_CommitFreq_QNTY <> 0
          AND @Ln_CommitFreq_QNTY >= @Ln_CommitFreqParm_QNTY
        BEGIN
         SET @Ls_Sql_TEXT = 'COMMIT TRANSACTION TXN_PROCESS_VAP';
         SET @Ls_SqlData_TEXT = '';

         COMMIT TRANSACTION TXN_PROCESS_VAP;

         SET @Ls_Sql_TEXT = 'NOTING DOWN PROCESSED RECORD COUNT';
         SET @Ls_SqlData_TEXT = '';
         SET @Ln_ProcessedRecordCountCommit_QNTY = @Ln_ProcessedRecordCountCommit_QNTY + @Ln_CommitFreq_QNTY;
         SET @Ls_Sql_TEXT = 'BEGIN TRANSACTION TXN_PROCESS_VAP';
         SET @Ls_SqlData_TEXT = '';

         BEGIN TRANSACTION TXN_PROCESS_VAP;

         SET @Ls_Sql_TEXT = 'RESETTING COMMIT FREQUENCY COUNT';
         SET @Ls_SqlData_TEXT = '';
         SET @Ln_CommitFreq_QNTY = 0;
        END;

       SET @Ls_Sql_TEXT = 'CHECKING EXCEPTION THRESHOLD';
       SET @Ls_SqlData_TEXT = 'ExceptionThresholdParm_QNTY = ' + CAST(@Ln_ExceptionThresholdParm_QNTY AS VARCHAR) + ', ExceptionThreshold_QNTY = ' + CAST(@Ln_ExceptionThreshold_QNTY AS VARCHAR);

       IF @Ln_ExceptionThreshold_QNTY > @Ln_ExceptionThresholdParm_QNTY
        BEGIN
         COMMIT TRANSACTION TXN_PROCESS_VAP;

         SET @Ln_ProcessedRecordCountCommit_QNTY = @Ln_RecordCount_QNTY;
         SET @Ls_ErrorMessage_TEXT = 'REACHED EXCEPTION THRESHOLD';

         RAISERROR(50001,16,1);
        END;

       SET @Ls_Sql_TEXT = 'FETCH NEXT FROM Vapp_CUR - 2';
       SET @Ls_SqlData_TEXT = 'Cursor Previous Record = ' + SUBSTRING(@Ls_BateRecord_TEXT, 1, 970);

       FETCH NEXT FROM Vapp_CUR INTO @Ln_VappCur_Seq_IDNO, @Lc_VappCur_ChildBirthDate_TEXT, @Lc_VappCur_ChildFirstName_TEXT, @Lc_VappCur_ChildLastName_TEXT, @Lc_VappCur_ChildBirthCertificateId_TEXT, @Lc_VappCur_MotherFirstName_TEXT, @Lc_VappCur_MotherLastName_TEXT, @Lc_VappCur_MotherSsnNumb_TEXT, @Lc_VappCur_MotherBirthDate_TEXT, @Lc_VappCur_FatherFirstName_TEXT, @Lc_VappCur_FatherLastName_TEXT, @Lc_VappCur_FatherSsnNumb_TEXT, @Lc_VappCur_FatherBirthDate_TEXT, @Ls_VappCur_PlaceAckSignedName_TEXT, @Lc_VappCur_ChildBirthStateCode_TEXT;

       /* Commented and kept for future use     
            @Lc_VappCur_MotherAddressNormalization_CODE,
            @Ls_VappCur_MotherLine1_ADDR, @Ls_VappCur_MotherLine2_ADDR, @Lc_VappCur_MotherCity_ADDR, @Lc_VappCur_MotherState_ADDR, @Lc_VappCur_MotherZip_ADDR,
            @Lc_VappCur_FatherEmplAddressNormalization_CODE,
            @Ls_VappCur_FatherEmplLine1_ADDR,
            @Ls_VappCur_FatherEmplLine2_ADDR,
            @Lc_VappCur_FatherEmplCity_ADDR,
            @Lc_VappCur_FatherEmplState_ADDR,
            @Lc_VappCur_FatherEmplZip_ADDR,
            @Lc_VappCur_FatherAddressNormalization_CODE,
            @Ls_VappCur_FatherLine1_ADDR, @Ls_VappCur_FatherLine2_ADDR, @Lc_VappCur_FatherCity_ADDR, @Lc_VappCur_FatherState_ADDR, @Lc_VappCur_FatherZip_ADDR; 
       */
       SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
      END;

     SET @Ls_Sql_TEXT = 'CLOSE Vapp_CUR';
     SET @Ls_SqlData_TEXT = '';

     CLOSE Vapp_CUR;

     SET @Ls_Sql_TEXT = 'DEALLOCATE Vapp_CUR';
     SET @Ls_SqlData_TEXT = '';

     DEALLOCATE Vapp_CUR;
    END;
   ELSE
    BEGIN
     SET @Ln_ProcessedRecordCount_QNTY = @Ln_Zero_NUMB;

     SELECT @Lc_BateError_CODE = @Lc_BateErrorE0944_CODE,
            @Ls_DescriptionError_TEXT = 'NO RECORD(S) TO PROCESS';

     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG';
     SET @Ls_SqlData_TEXT = '';

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Ls_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_TypeErrorE_CODE,
      @An_Line_NUMB                = @Ln_Zero_NUMB,
      @Ac_Error_CODE               = @Lc_BateError_CODE,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
      @As_ListKey_TEXT             = @Ls_SqlData_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

       RAISERROR(50001,16,1);
      END;
    END;

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

     RAISERROR(50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BSTL_LOG';
   SET @Ls_SqlData_TEXT = 'Status_CODE = ' + @Lc_StatusSuccess_CODE;

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Ls_CursorLocation_TEXT,
    @As_ExecLocation_TEXT         = @Lc_Successful_TEXT,
    @As_ListKey_TEXT              = @Lc_Successful_TEXT,
    @As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE               = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;

   SET @Ls_Sql_TEXT = 'COMMIT TRANSACTION TXN_PROCESS_VAP';
   SET @Ls_SqlData_TEXT = '';

   COMMIT TRANSACTION TXN_PROCESS_VAP;
  END TRY

  BEGIN CATCH
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION TXN_PROCESS_VAP;
    END;

   IF CURSOR_STATUS('Local', 'Vapp_CUR') IN (0, 1)
    BEGIN
     CLOSE Vapp_CUR;

     DEALLOCATE Vapp_CUR;
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
    @As_CursorLocation_TEXT       = @Ls_CursorLocation_TEXT,
    @As_ExecLocation_TEXT         = @Ls_Sql_TEXT,
    @As_ListKey_TEXT              = @Ls_SqlData_TEXT,
    @As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE               = @Lc_StatusAbnormalEnd_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCountCommit_QNTY;

   RAISERROR(@Ls_DescriptionError_TEXT,16,1);
  END CATCH;
 END;


GO
