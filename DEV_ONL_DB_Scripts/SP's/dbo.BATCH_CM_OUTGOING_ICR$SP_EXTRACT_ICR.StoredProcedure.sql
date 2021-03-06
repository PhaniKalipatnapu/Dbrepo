/****** Object:  StoredProcedure [dbo].[BATCH_CM_OUTGOING_ICR$SP_EXTRACT_ICR]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*-----------------------------------------------------------------------------------------------------------------
Procedure Name    :	BATCH_CM_OUTGOING_ICR$SP_EXTRACT_ICR
Programmer Name   :	IMP Team
Description       :	batch process sends Case and Member data File to OCSE for National Interstate Reconciliation Project. 
					This is a two step process, in step one, DACSES selects all open and closed interstate cases, 
					i.e., all DACSES cases that had another state involved in the establishment or enforcement process 
					in the past or present. The second step reads the temporary table and writes to the ICR submission 
					File to be sent to OCSE.
Frequency         :	Daily
Developed On      :	01/20/2011
Called BY         :	None
Called On		  :	BATCH_COMMON$SP_GET_BATCH_DETAILS2,
					BATCH_COMMON$BATE_LOG,  
					BATCH_COMMON$BSTL_LOG,
					BATCH_COMMON$SP_BATCH_RESTART_UPDATE 
--------------------------------------------------------------------------------------------------------------------
Modified BY       :
Modified On       :
Version No        :	0.01
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_CM_OUTGOING_ICR$SP_EXTRACT_ICR]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Ln_Zero_NUMB              NUMERIC(1) = 0,
		  @Lc_StatusFailed_CODE      CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE     CHAR(1) = 'S',
          @Lc_StatusAbnormalend_CODE CHAR(1) = 'A',
          @Lc_ErrrorTypeE_CODE       CHAR(1) = 'E',
          @Lc_FipsState_CODE         CHAR(2) = '10',
          @Lc_BatchRunUser_TEXT      CHAR(5) = 'BATCH',
          @Lc_ErrorE0944_CODE        CHAR(5) = 'E0944',
          @Lc_Job_ID                 CHAR(7) = 'DEB9306',
          @Lc_Successful_TEXT        CHAR(20) = 'SUCCESSFUL',
          @Ls_Procedure_NAME         VARCHAR(100) = 'SP_EXTRACT_ICR',
          @Ls_Process_NAME           VARCHAR(100) = 'BATCH_CM_OUTGOING_ICR',
          @Ld_HighDate_DATE          DATE = '12/31/9999';
  DECLARE @Ln_CommitFreqParm_QNTY         NUMERIC(5),
          @Ln_ExceptionThresholdParm_QNTY NUMERIC(5),
          @Ln_ProcessedRecordCount_QNTY   NUMERIC(10) = 0,
          @Ln_Error_NUMB                  NUMERIC(10),
          @Ln_ErrorLine_NUMB              NUMERIC(10),
          @Lc_Msg_CODE                    CHAR(1),
          @Lc_Space_TEXT                  CHAR(1) = '',
          @Ls_File_NAME                   VARCHAR(50),
          @Ls_FileLocation_TEXT           VARCHAR(100),
          @Ls_Sql_TEXT                    VARCHAR(200) = '',
          @Ls_CursorLocation_TEXT         VARCHAR(200) = '',
          @Ls_Sqldata_TEXT                VARCHAR(1000) = '',
          @Ls_BcpCommand_TEXT             VARCHAR(1000),
          @Ls_DescriptionError_TEXT       VARCHAR(4000),
          @Ld_Run_DATE                    DATE,
          @Ld_LastRun_DATE                DATE,
          @Ld_Start_DATE                  DATETIME2;

  BEGIN TRY
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   SET @Ls_Sql_TEXT ='GET BATCH DETAILS';
   SET @Ls_Sqldata_TEXT='GET BATCH DETAILS ' + @Lc_Job_ID;

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
     RAISERROR(50001,16,1);
    END;

   IF DATEADD (D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_DescriptionError_TEXT = 'PARM DATE PROBLEM';

     RAISERROR(50001,16,1);
    END;

   BEGIN TRANSACTION ExtractIcr;

   --Delete all the records from ExtractIcr_T1
   SET @Ls_Sql_TEXT='DELETE FROM EXTRACTICR_T1';
   SET @Ls_Sqldata_TEXT = 'Job_ID  = ' + @Lc_Job_ID;

   DELETE FROM EIGCR_Y1;

   --Create Temperorary Table
   CREATE TABLE ##ExtIcr_P1
    (
      Record_TEXT VARCHAR(550)
    );

   --Bulk Insert into ExtractIcr_T1
   SET @Ls_Sql_TEXT ='BULK INSERT INTO EXTRACTICR_T1 TABLE';
   SET @Ls_Sqldata_TEXT = 'Job Id = ' + @Lc_Job_ID;

   INSERT INTO EIGCR_Y1
               (Case_IDNO,
                RespondInit_CODE,
                StateFips_CODE,
                CountyFips_CODE,
                OfficeFips_CODE,
                MemberSsn_NUMB,
                MemberMci_IDNO,
                CaseRelationShip_CODE,
                StatusCase_CODE,
                Last_NAME,
                First_NAME,
                Middle_NAME,
                Birth_DATE,
                MemberSex_CODE,
                IVDOutOfStateCase_IDNO,
                IVDOutOfStateFips_CODE,
                IVDOutOfStateCountyFips_CODE,
                IVDOutOfStateOfficeFips_CODE,
                Contact_NAME,
                Phone_NUMB,
                Contact_EML)
   SELECT DISTINCT
          CONVERT(VARCHAR, C.Case_IDNO) AS Case_IDNO,
          CASE WHEN IC.RespondInit_CODE IN ('T','C','I')
				THEN 'I'
			   WHEN IC.RespondInit_CODE IN ('Y', 'S', 'R')
			    THEN 'R'
			   END AS RespondInit_CODE,
          @Lc_FipsState_CODE AS StateFips_CODE,
          CONVERT(VARCHAR, C.County_IDNO) AS CountyFips_CODE,
          '' AS OfficeFips_CODE,
          CONVERT(VARCHAR, D.MemberSsn_NUMB) AS MemberSsn_NUMB,
          CONVERT(VARCHAR, D.MemberMci_IDNO) AS MemberMci_IDNO,
          CASE
           WHEN CM.CaseRelationship_CODE IN ('C')
            THEN 'CP'
           WHEN CM.CaseRelationship_CODE IN ('A')
            THEN 'NP'
           WHEN CM.CaseRelationship_CODE IN ('D')
            THEN 'CH'
           WHEN CM.CaseRelationship_CODE IN ('P')
            THEN 'PF'
           WHEN CM.CaseRelationship_CODE IN ('G')
            THEN 'CP'
          END AS CaseRelationShip_CODE,
          IC.Status_CODE,
          D.Last_NAME,
          D.First_NAME,
          LEFT(D.Middle_NAME,16) AS Middle_NAME,
          CONVERT (VARCHAR(8), D.Birth_DATE, 112) AS Birth_DATE,
          D.MemberSex_CODE,
          IC.IVDOutOfStateCase_ID,
          IC.IVDOutOfStateFips_CODE,
          IC.IVDOutOfStateCountyFips_CODE,
          IC.IVDOutOfStateOfficeFips_CODE,
          LEFT(ISNULL((RTRIM(U.First_NAME) + ' ' + U.Last_NAME), ''), 40) AS Contact_NAME,
          CASE UO.WorkPhone_NUMB WHEN 0 
			THEN ''
           ELSE ISNULL(CONVERT(VARCHAR(10), LEFT(UO.WorkPhone_NUMB,10)), '') END 
           AS Phone_NUMB,
          LEFT(ISNULL(U.Contact_EML, ''), 30) AS Contact_EML
     FROM ICAS_Y1 IC
          JOIN CASE_Y1 C
           ON IC.Case_IDNO = C.Case_IDNO
          LEFT OUTER JOIN USEM_Y1 U
           ON C.Worker_ID = U.Worker_ID
              AND U.EndValidity_DATE = @Ld_HighDate_DATE
              AND @Ld_Run_DATE BETWEEN U.BeginEmployment_DATE AND U.EndEmployment_DATE
          LEFT OUTER JOIN UASM_Y1 UO
           ON C.Worker_ID = UO.Worker_ID
              AND UO.EndValidity_DATE = @Ld_HighDate_DATE
              AND @Ld_Run_DATE BETWEEN UO.Effective_DATE AND UO.Expire_DATE
          JOIN CMEM_Y1 CM
           ON CM.Case_IDNO = IC.Case_IDNO
          JOIN DEMO_Y1 D
           ON D.MemberMci_IDNO = CM.MemberMci_IDNO
    WHERE IC.IVDOutOfStateFips_CODE NOT IN('07', '10', '14', '43',
                                           '57', '58', '59', '60',
                                           '61', '62', ' 63', '64',
                                           '65', '67', '68', '69',
                                           '70', '71', '73', '74',
                                           '75', ' 76', '77')
      AND IC.IVDOutOfStateFips_CODE < '78'
      AND IC.EndValidity_DATE = @Ld_HighDate_DATE
      AND IC.TransactionEventSeq_NUMB = (SELECT MAX(TransactionEventSeq_NUMB)
                                           FROM ICAS_Y1 B
                                          WHERE IC.Case_IDNO = B.Case_IDNO
                                            AND IC.IVDOutOfStateFips_CODE = B.IVDOutOfStateFips_CODE
                                            AND IC.IVDOutOfStateFile_ID = B.IVDOutOfStateFile_ID
                                            AND B.EndValidity_DATE = @Ld_HighDate_DATE
                                            AND IC.Status_CODE = B.Status_CODE)
      AND D.MemberSsn_NUMB != @Ln_Zero_NUMB;

   SELECT @Ln_ProcessedRecordCount_QNTY = COUNT(1)
     FROM EIGCR_Y1 E;

   --If rowcount is Zero insert into Bate 
   IF @Ln_ProcessedRecordCount_QNTY = @Ln_Zero_NUMB
    BEGIN
     SET @Ls_Sql_TEXT = 'NO RECORDS SELECTED IN ICR EXTRACT OUTGOING FILE, ProcessedRecordCount_QNTY = ' + CAST(@Ln_ProcessedRecordCount_QNTY AS VARCHAR);
     SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + ISNULL(@Ls_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', TypeError_CODE = ' + ISNULL(@Lc_ErrrorTypeE_CODE, '') + ', Line_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Error_CODE = ' + ISNULL(@Lc_ErrorE0944_CODE, '') + ', DescriptionError_TEXT = ' + ISNULL(@Lc_Space_TEXT, '') + ', ListKey_TEXT = ' + ISNULL(@Ls_Sql_TEXT, '');

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Ls_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_ErrrorTypeE_CODE,
      @An_Line_NUMB                = @Ln_Zero_NUMB,
      @Ac_Error_CODE               = @Lc_ErrorE0944_CODE,
      @As_DescriptionError_TEXT    = @Lc_Space_TEXT,
      @As_ListKey_TEXT             = @Ls_Sql_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;
      
      COMMIT TRANSACTION ExtractIcr;
      
      RAISERROR (50001,16,1);
    END
   ELSE
    BEGIN
     SET @Ls_Sql_TEXT = 'INSERT ##EXTICR_P1';
     SET @Ls_Sqldata_TEXT = 'JOb ID = ' + @Lc_Job_ID;

     INSERT INTO ##ExtIcr_P1
                 (Record_TEXT)
     SELECT (CONVERT(CHAR(15), IG.Case_IDNO) + IG.RespondInit_CODE + CONVERT(CHAR(2), IG.StateFips_CODE) + RIGHT('000' + LTRIM(RTRIM(IG.CountyFips_CODE)), 3) + CONVERT(CHAR(2), IG.OfficeFips_CODE) + RIGHT('000000000' + LTRIM(RTRIM(IG.MemberSsn_NUMB)), 9) + CONVERT(CHAR(15), RIGHT('0000000000' + LTRIM(RTRIM(IG.MemberMci_IDNO)), 10)) + CONVERT(CHAR(2), IG.CaseRelationship_CODE) + CONVERT(CHAR(1), IG.StatusCase_CODE) + CONVERT(CHAR(30), IG.Last_NAME) + CONVERT(CHAR(16), IG.First_NAME) + CONVERT(CHAR(16), IG.Middle_NAME) + CONVERT (VARCHAR(8), IG.Birth_DATE, 112) + CONVERT(CHAR(1), IG.MemberSex_CODE) + CONVERT(CHAR(15), IG.IVDOutofStateCase_IDNO) + REPLICATE(@Lc_Space_TEXT, 1) + CONVERT(CHAR(2), IG.IVDOutofStateFips_CODE) + CONVERT(CHAR(3), IG.IVDOutofStateCountyFips_CODE) + CONVERT(CHAR(2), IG.IVDOutofStateOfficeFips_CODE) + REPLICATE(@Lc_Space_TEXT, 17) + CONVERT(CHAR(40), IG.Contact_NAME) + CONVERT(CHAR(10), IG.Phone_NUMB) + CONVERT(CHAR(30), IG.Contact_EML) + REPLICATE(@Lc_Space_TEXT, 309)) AS Record_TEXT
       FROM EIGCR_Y1 IG;

     SET @Ls_Sql_TEXT = 'EXTRACT TO FILE';
     SET @Ls_BcpCommand_TEXT = 'SELECT Record_TEXT FROM ##ExtIcr_P1';
     SET @Ls_Sqldata_TEXT ='QUERY : ' + @Ls_BcpCommand_TEXT;

     COMMIT TRANSACTION ExtractIcr;

     SET @Ls_Sql_TEXT='BATCH_COMMON$SP_EXTRACT_DATA';
     SET @Ls_Sqldata_TEXT = 'FileLocation_TEXT = ' + @Ls_FileLocation_TEXT + ', File_NAME = ' + @Ls_File_NAME + ', BcpCommand_TEXT = ' + @Ls_BcpCommand_TEXT;

     EXECUTE BATCH_COMMON$SP_EXTRACT_DATA
      @As_FileLocation_TEXT     = @Ls_FileLocation_TEXT,
      @As_File_NAME             = @Ls_File_NAME,
      @As_Query_TEXT            = @Ls_BcpCommand_TEXT,
      @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END

     BEGIN TRANSACTION ExtractIcr;
    END

   -- Update the parameter table with the job run date as the current system date
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE';
   SET @Ls_Sqldata_TEXT = 'JOb ID = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END

   -- Log the Status of job in BSTL_Y1 as Success	
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BSTL_LOG';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Start_DATE = ' + ISNULL(CAST(@Ld_Start_DATE AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Process_NAME = ' + ISNULL(@Ls_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', CursorLocation_TEXT = ' + ISNULL(@Ls_CursorLocation_TEXT, '') + ', ExecLocation_TEXT = ' + ISNULL(@Lc_Successful_TEXT, '') + ', ListKey_TEXT = ' + ISNULL(@Lc_Successful_TEXT, '') + ', DescriptionError_TEXT = ' + ISNULL(@Ls_DescriptionError_TEXT, '') + ', Status_CODE = ' + ISNULL(@Lc_StatusSuccess_CODE, '') + ', Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', ProcessedRecordCount_QNTY = ' + ISNULL(CAST(@Ln_ProcessedRecordCount_QNTY AS VARCHAR), '');

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Ls_CursorLocation_TEXT,
    @As_ExecLocation_TEXT         = @LC_Successful_TEXT,
    @As_ListKey_TEXT              = @LC_Successful_TEXT,
    @As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE               = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;

   COMMIT TRANSACTION ExtractIcr;

   DROP TABLE ##ExtIcr_P1;
  END TRY

  BEGIN CATCH
   --Drop temporary table if exists
   IF OBJECT_ID('tempdb..##ExtIcr_P1') IS NOT NULL
    BEGIN
     DROP TABLE ##ExtIcr_P1;
    END

   --Commit the Transaction 		
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION ExtractIcr;
    END

   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();

   IF (@Ln_Error_NUMB <> 50001)
    BEGIN
     SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
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
    @As_ListKey_TEXT              = @Ls_Sqldata_TEXT,
    @As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE               = @Lc_StatusAbnormalend_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = 0;

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH
 END


GO
