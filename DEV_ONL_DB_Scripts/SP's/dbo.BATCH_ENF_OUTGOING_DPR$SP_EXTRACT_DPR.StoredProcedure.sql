/****** Object:  StoredProcedure [dbo].[BATCH_ENF_OUTGOING_DPR$SP_EXTRACT_DPR]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[BATCH_ENF_OUTGOING_DPR$SP_EXTRACT_DPR]
AS
 /*
 -----------------------------------------------------------------------------------------------------------------------------------------------
 Procedure Name      : BATCH_ENF_OUTGOING_DPR$SP_EXTRACT_DPR
 Programmer Name   : IMP Team
 Description       : The batch process reads the data from the database table,
                     checks reason code equals suspension for the license suspension activity and 
                     generates a record in outgoing Division of Professional Regulation (DPR) file.
 Frequency         : DAILY
 Developed On      : 01/20/2011
 Called BY         : None
 Called On		   : BATCH_COMMON$SP_GET_BATCH_DETAILS ,
                     BATCH_COMMON$BSTL_LOG,
                     BATCH_COMMON$SP_EXTRACT_DATA,
                     BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
 ----------------------------------------------------------------------------------------------------------------------------------------------                     
 Modified BY       :
 Modified On       :
 Version No        : 0.1
 ----------------------------------------------------------------------------------------------------------------------------------------------
 */
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusFailed_CODE        CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE       CHAR(1) = 'S',
          @Lc_StatusAbnormalend_CODE   CHAR(1) = 'A',
          @Lc_TypeErrorWarning_CODE    CHAR(1) = 'W',
          @Lc_Trailer_CODE             CHAR(1) = 'T',
          @Lc_Header_CODE              CHAR(1) = 'H',
          @Lc_ActionCodeS_CODE         CHAR(1) = 'S',
          @Lc_ActionCodeL_CODE         CHAR(1) = 'L',
          @Lc_Space_TEXT               CHAR(1) = ' ',
          @Lc_ReasonStatusLg_CODE      CHAR(2) = 'LG',
          @Lc_ReasonStatusLs_CODE      CHAR(2) = 'LS',
          @Lc_ReasonStatusFs_CODE      CHAR(2) = 'FS',
          @Lc_ReasonStatusEy_CODE      CHAR(2) = 'EY',
          @Lc_ReasonStatusNr_CODE      CHAR(2) = 'NR',
          @Lc_ReasonStatusZj_CODE      CHAR(2) = 'ZJ',
          @Lc_ReasonStatusGb_CODE      CHAR(2) = 'GB',
          @Lc_ReasonStatusNy_CODE      CHAR(2) = 'NY',
          @Lc_ReasonStatusLf_CODE      CHAR(2) = 'LF',
          @Lc_IssuingStateDe_CODE      CHAR(2) = 'DE',
          @Lc_StatusConfirmedGood_CODE CHAR(2) = 'CG',
          @Lc_DescriptionDpr_CODE      CHAR(3) = 'DPR',
          @Lc_TableIdnoPlic_CODE       CHAR(4) = 'PLIC',
          @Lc_TableSubIdnoAgnc_CODE    CHAR(4) = 'AGNC',
          @Lc_StatusComp_CODE          CHAR(4) = 'COMP',
          @Lc_StatusStrt_CODE          CHAR(4) = 'STRT',
          @Lc_MajorActivityLsnr_CODE   CHAR(4) = 'LSNR',
          @Lc_MajorActivityCpls_CODE   CHAR(4) = 'CPLS',
          @Lc_MinorActivityCelis_CODE  CHAR(5) = 'CELIS',
          @Lc_MinorActivityRncpl_CODE  CHAR(5) = 'RNCPL',
          @Lc_MinorActivityInfff_CODE  CHAR(5) = 'INFFF',
          @Lc_MinorActivityRradh_CODE  CHAR(5) = 'RRADH',
          @Lc_MinorActivityMofre_CODE  CHAR(5) = 'MOFRE',
          @Lc_BatchRunUser_TEXT        CHAR(5) = 'BATCH',
          @Lc_ErrorE0944_CODE          CHAR(5) = 'E0944',
          @Lc_Job_ID                   CHAR(7) = 'DEB0702',
          @Lc_Successful_TEXT          CHAR(20) = 'SUCCESSFUL',
          @Ls_ParmDateProblem_TEXT     VARCHAR(50) = 'PARM DATE PROBLEM',
          @Ls_Procedure_NAME           VARCHAR(100) = 'SP_EXTRACT_DPR',
          @Ls_Process_NAME             VARCHAR(100) = 'BATCH_ENF_OUTGOING_DPR',
          @Ld_High_DATE                DATE = '12/31/9999';
  DECLARE @Ln_CommitFreqParm_QNTY         NUMERIC(5) = 0,
          @Ln_ExceptionThresholdParm_QNTY NUMERIC(5) = 0,
          @Ln_Error_NUMB                  NUMERIC(10) = 0,
          @Ln_ErrorLine_NUMB              NUMERIC(10) = 0,
          @Ln_ProcessedRecordCount_QNTY   NUMERIC(11) = 0,
          @Li_Rowcount_QNTY               SMALLINT,
          @Lc_Msg_CODE                    CHAR(1),
          @Lc_FileTotRecCount_TEXT        CHAR(9),
          @Ls_File_NAME                   VARCHAR(50),
          @Ls_FileLocation_TEXT           VARCHAR(100),
          @Ls_Sql_TEXT                    VARCHAR(200) = '',
          @Ls_CursorLoc_TEXT              VARCHAR(200) = '',
          @Ls_Sqldata_TEXT                VARCHAR(1000) = '',
          @Ls_BcpCommand_TEXT             VARCHAR(1000) = '',
          @Ls_ErrorMessage_TEXT           VARCHAR(4000) = '',
          @Ls_DescriptionError_TEXT       VARCHAR(4000) = '',
          @Ld_Run_DATE                    DATE,
          @Ld_LastRun_DATE                DATE,
          @Ld_Start_DATE                  DATETIME2;

  BEGIN TRY
   SET @Ls_Sql_TEXT = 'GET BATCH START DATE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;
   SET @Ld_Start_DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

   DECLARE @SuspensionElig_P1 TABLE (
    ActivityMinor_CODE CHAR(5),
    Reason_CODE        CHAR(2));

   SET @Ls_Sql_TEXT = 'INSERTION INTO @SuspensionElig_P1';
   SET @Ls_Sqldata_TEXT = 'ActivityMinor_CODE = ' + ISNULL(@Lc_MinorActivityCelis_CODE, '') + ', Reason_CODE = ' + ISNULL(@Lc_ReasonStatusEy_CODE, '');

   INSERT INTO @SuspensionElig_P1
               (ActivityMinor_CODE,
                Reason_CODE)
        VALUES(@Lc_MinorActivityCelis_CODE,--ActivityMinor_CODE
               @Lc_ReasonStatusEy_CODE --Reason_CODE
   );

   SET @Ls_Sql_TEXT = 'INSERTION INTO @SuspensionElig_P1';
   SET @Ls_Sqldata_TEXT = 'ActivityMinor_CODE = ' + ISNULL(@Lc_MinorActivityCelis_CODE, '') + ', Reason_CODE = ' + ISNULL(@Lc_ReasonStatusLs_CODE, '');

   INSERT INTO @SuspensionElig_P1
               (ActivityMinor_CODE,
                Reason_CODE)
        VALUES(@Lc_MinorActivityCelis_CODE,--ActivityMinor_CODE
               @Lc_ReasonStatusLs_CODE --Reason_CODE
   );

   SET @Ls_Sql_TEXT = 'INSERTION INTO @SuspensionElig_P1';
   SET @Ls_Sqldata_TEXT = 'ActivityMinor_CODE = ' + ISNULL(@Lc_MinorActivityRncpl_CODE, '') + ', Reason_CODE = ' + ISNULL(@Lc_ReasonStatusNr_CODE, '');

   INSERT INTO @SuspensionElig_P1
               (ActivityMinor_CODE,
                Reason_CODE)
        VALUES(@Lc_MinorActivityRncpl_CODE,--ActivityMinor_CODE
               @Lc_ReasonStatusNr_CODE --Reason_CODE
   );

   SET @Ls_Sql_TEXT = 'INSERTION INTO @SuspensionElig_P1';
   SET @Ls_Sqldata_TEXT = 'ActivityMinor_CODE = ' + ISNULL(@Lc_MinorActivityInfff_CODE, '') + ', Reason_CODE = ' + ISNULL(@Lc_ReasonStatusFs_CODE, '');

   INSERT INTO @SuspensionElig_P1
               (ActivityMinor_CODE,
                Reason_CODE)
        VALUES(@Lc_MinorActivityInfff_CODE,--ActivityMinor_CODE
               @Lc_ReasonStatusFs_CODE --Reason_CODE
   );

   SET @Ls_Sql_TEXT = 'INSERTION INTO @SuspensionElig_P1';
   SET @Ls_Sqldata_TEXT = 'ActivityMinor_CODE = ' + ISNULL(@Lc_MinorActivityRradh_CODE, '') + ', Reason_CODE = ' + ISNULL(@Lc_ReasonStatusZj_CODE, '');

   INSERT INTO @SuspensionElig_P1
               (ActivityMinor_CODE,
                Reason_CODE)
        VALUES(@Lc_MinorActivityRradh_CODE,--ActivityMinor_CODE
               @Lc_ReasonStatusZj_CODE --Reason_CODE
   );

   SET @Ls_Sql_TEXT = 'INSERTION INTO @SuspensionElig_P1';
   SET @Ls_Sqldata_TEXT = 'ActivityMinor_CODE = ' + ISNULL(@Lc_MinorActivityMofre_CODE, '') + ', Reason_CODE = ' + ISNULL(@Lc_ReasonStatusLg_CODE, '');

   INSERT INTO @SuspensionElig_P1
               (ActivityMinor_CODE,
                Reason_CODE)
        VALUES(@Lc_MinorActivityMofre_CODE,--ActivityMinor_CODE
               @Lc_ReasonStatusLg_CODE --Reason_CODE
   );

   BEGIN TRANSACTION ExtractDpr;

   SET @Ls_Sql_TEXT = 'TABLE CREATION ##ExtractDpr_P1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;

   CREATE TABLE ##ExtractDpr_P1
    (
      Record_TEXT VARCHAR(171)
    );

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

   SET @Ls_Sql_TEXT = @Ls_ParmDateProblem_TEXT;
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', LAST RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   IF DATEADD (D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_DescriptionError_TEXT = @Ls_ParmDateProblem_TEXT;

     RAISERROR(50001,16,1);
    END;

   SET @Ls_Sql_TEXT ='DELETE ELDPR_Y1 ';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + 'Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   DELETE FROM ELDPR_Y1;

   SET @Ls_Sql_TEXT ='INSERT ELDPR_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + 'Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   -- Insert in ELDPR_Y1
   INSERT INTO ELDPR_Y1
               (Action_CODE,
                MemberSsn_NUMB,
                Profession_CODE,
                TypeLicense_CODE,
                LicenseNo_TEXT,
                MemberMci_IDNO,
                Last_NAME,
                First_NAME,
                Middle_NAME,
                Suffix_NAME,
                SuspLiftRequest_DATE)
   SELECT R.ActionCode_INDC,
          R.MemberSsn_NUMB,
          R.Profession_CODE,
          R.TypeLicense_CODE,
          R.LicenseNo_TEXT,
          R.MemberMci_IDNO,
          R.LastNcp_NAME,
          R.FirstNcp_NAME,
          R.MiddleNcp_NAME,
          R.SuffixNcp_NAME,
          R.SuspLift_DATE
     FROM (SELECT CASE
                   WHEN MN.ReasonStatus_CODE IN (SELECT SR.Reason_CODE
                                                   FROM @SuspensionElig_P1 SR)
                    THEN @Lc_ActionCodeS_CODE
                   ELSE @Lc_ActionCodeL_CODE
                  END AS ActionCode_INDC,
                  D.MemberSsn_NUMB,
                  PL.TypeLicense_CODE,
                  LEFT(PL.LicenseNo_TEXT, 10) AS LicenseNo_TEXT,
                  PL.Profession_CODE,
                  MJ.MemberMci_IDNO,
                  ST.LastNcp_NAME,
                  ST.FirstNcp_NAME,
                  ST.MiddleNcp_NAME,
                  ST.SuffixNcp_NAME,
                  CONVERT(VARCHAR, mn.Status_DATE, 112) AS SuspLift_DATE,
                  ROW_NUMBER() OVER(PARTITION BY ST.NcpPf_IDNO, PL.TypeLicense_CODE, PL.LicenseNo_TEXT ORDER BY mn.BeginValidity_DATE DESC, mn.TransactionEventSeq_NUMB DESC) Row_NUMB
             FROM DMJR_Y1 MJ
                  JOIN DMNR_Y1 MN
                   ON MJ.Case_IDNO = MN.Case_IDNO
                      AND MJ.OrderSeq_NUMB = MN.OrderSeq_NUMB
                      AND MJ.MajorIntSEQ_NUMB = MN.MajorIntSEQ_NUMB
                  JOIN PLIC_Y1 PL
                   ON MN.MemberMci_IDNO = PL.MemberMci_IDNO
                      AND PL.LicenseNo_TEXT = MJ.Reference_ID
                      AND PL.TypeLicense_CODE = MJ.TypeReference_CODE
                      AND PL.EndValidity_DATE = @Ld_High_DATE
                      AND PL.IssuingState_CODE = @Lc_IssuingStateDe_CODE
                      AND PL.Status_CODE = @Lc_StatusConfirmedGood_CODE
                  JOIN ENSD_Y1 ST
                   ON ST.Case_IDNO = MJ.Case_IDNO
                  JOIN DEMO_Y1 D
                   ON D.MemberMci_IDNO = ST.NcpPf_idno
            WHERE MJ.ActivityMajor_CODE IN (@Lc_MajorActivityLsnr_CODE, @Lc_MajorActivityCpls_CODE)
              AND MJ.Status_CODE IN (@Lc_StatusStrt_CODE, @Lc_StatusComp_CODE)
              AND MN.Status_DATE BETWEEN @Ld_LastRun_DATE AND @Ld_Run_DATE
              AND MJ.TypeReference_CODE IN (SELECT Rm.Value_CODE
                                              FROM REFM_Y1 Rm
                                             WHERE Rm.Table_ID = @Lc_TableIdnoPlic_CODE
                                               AND Rm.TableSub_ID = @Lc_TableSubIdnoAgnc_CODE
                                               AND Rm.DescriptionValue_TEXT = @Lc_DescriptionDpr_CODE)
              AND (EXISTS (SELECT 1
                             FROM @SuspensionElig_P1 EL
                            WHERE EL.ActivityMinor_CODE = MN.ActivityMinor_CODE
                              AND EL.Reason_CODE = MN.ReasonStatus_CODE)
                    OR (MN.ActivityMinor_CODE = @Lc_MinorActivityMofre_CODE
                        AND MN.ReasonStatus_CODE IN (@Lc_ReasonStatusGb_CODE, @Lc_ReasonStatusNy_CODE, @Lc_ReasonStatusLf_CODE)
                        AND NOT EXISTS (SELECT 1
                                          FROM DMJR_Y1 Ji
                                               JOIN DMNR_Y1 Ni
                                                ON Ji.Case_IDNO = Ni.Case_IDNO
                                                   AND Ji.MajorIntSEQ_NUMB = Ni.MajorIntSEQ_NUMB
                                         WHERE Ji.MemberMci_IDNO = MJ.MemberMci_IDNO
                                           AND Ji.Reference_ID = MJ.Reference_ID
                                           AND Ji.OthpSource_IDNO = MJ.OthpSource_IDNO
                                           AND Ji.MajorIntSEQ_NUMB <> MJ.MajorIntSEQ_NUMB
                                           AND Ji.ActivityMajor_CODE IN (@Lc_MajorActivityLsnr_CODE, @Lc_MajorActivityCpls_CODE)
                                           AND Ji.Status_CODE IN (@Lc_StatusStrt_CODE)
                                           AND Ni.Status_DATE BETWEEN @Ld_LastRun_DATE AND @Ld_Run_DATE
                                           AND Ni.TransactionEventSeq_NUMB > MN.TransactionEventSeq_NUMB
                                           AND EXISTS (SELECT 1
                                                         FROM @SuspensionElig_P1 EL
                                                        WHERE EL.ActivityMinor_CODE = MN.ActivityMinor_CODE
                                                          AND EL.Reason_CODE = MN.ReasonStatus_CODE))))
              AND NOT EXISTS (SELECT 1
                                FROM DMJR_Y1 j
                                     JOIN DMNR_Y1 n
                                      ON j.Case_IDNO = N.Case_IDNO
                                         AND j.MajorIntSEQ_NUMB = N.MajorIntSEQ_NUMB
                               WHERE j.MemberMci_IDNO = MJ.MemberMci_IDNO
                                 AND j.Reference_ID = MJ.Reference_ID
                                 AND j.OthpSource_IDNO = MJ.OthpSource_IDNO
                                 AND j.TypeReference_CODE = MJ.TypeReference_CODE
                                 AND j.Case_IDNO <> MJ.Case_IDNO
                                 AND j.ActivityMajor_CODE IN (@Lc_MajorActivityLsnr_CODE, @Lc_MajorActivityCpls_CODE)
                                 AND j.Status_CODE IN (@Lc_StatusStrt_CODE)
                                 AND n.ActivityMinor_CODE = @Lc_MinorActivityMofre_CODE
                                 AND n.Status_CODE IN (@Lc_StatusStrt_CODE))) R
    WHERE R.Row_NUMB = 1;

   SET @Ln_ProcessedRecordCount_QNTY = (SELECT COUNT(1)
                                          FROM ELDPR_Y1 e);

   IF @Ln_ProcessedRecordCount_QNTY = 0
    BEGIN
     SET @Ls_Sql_TEXT = 'NO RECORDS TO EXTRACT';
     SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + ISNULL(@Ls_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', TypeError_CODE = ' + ISNULL(@Lc_TypeErrorWarning_CODE, '') + ', Line_NUMB = ' + ISNULL(CAST(@Ln_ProcessedRecordCount_QNTY AS VARCHAR), '') + ', Error_CODE = ' + ISNULL(@Lc_ErrorE0944_CODE, '') + ', DescriptionError_TEXT = ' + ISNULL(@Ls_Sql_TEXT, '') + ', ListKey_TEXT = ' + ISNULL(@Ls_Sqldata_TEXT, '');

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Ls_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_TypeErrorWarning_CODE,
      @An_Line_NUMB                = @Ln_ProcessedRecordCount_QNTY,
      @Ac_Error_CODE               = @Lc_ErrorE0944_CODE,
      @As_DescriptionError_TEXT    = @Ls_Sql_TEXT,
      @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END
    END

   SET @Ls_Sql_TEXT = 'INSERT HEADER';
   SET @Ls_Sqldata_TEXT = 'Header Code = ' + @Lc_Header_CODE + 'Run Date = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   INSERT INTO ##ExtractDpr_P1
               (Record_TEXT)
        VALUES ( @Lc_Header_CODE + CONVERT(VARCHAR, @Ld_Run_DATE, 112) + REPLICATE(@Lc_Space_TEXT, 162) -- Record_TEXT
   );

   SET @Ls_Sql_TEXT = 'INSERT ##ExtractDpr_P1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + 'Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   INSERT INTO ##ExtractDpr_P1
               (Record_TEXT)
   SELECT e.Action_CODE + RIGHT(('0000000000' + LTRIM(RTRIM(e.MemberSsn_NUMB))), 9) + CONVERT(CHAR(2), e.Profession_CODE) + CONVERT(CHAR(5), e.TypeLicense_CODE) + CONVERT(CHAR(16), e.LicenseNo_TEXT) + RIGHT(('0000000000' + LTRIM(RTRIM(e.MemberMci_IDNO))), 10) + CONVERT(CHAR(50), e.Last_NAME) + CONVERT(CHAR(30), e.First_NAME) + CONVERT(CHAR(30), e.Middle_NAME) + CONVERT(CHAR(10), e.Suffix_NAME) + e.SuspLiftRequest_DATE AS Record_TEXT
     FROM ELDPR_Y1 e
    ORDER BY e.LicenseNo_TEXT;

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   SET @Lc_FileTotRecCount_TEXT = RIGHT(('000000000' + CAST(@Li_Rowcount_QNTY AS VARCHAR)), 9);
   SET @Ls_Sql_TEXT='INSERT ##ExtractDpr_P1 - 2';
   SET @Ls_Sqldata_TEXT = 'FILE RECORD COUNT = ' + @Lc_FileTotRecCount_TEXT;

   INSERT INTO ##ExtractDpr_P1
               (Record_TEXT)
        VALUES ( @Lc_Trailer_CODE + CONVERT(VARCHAR, @Ld_Run_DATE, 112) + @Lc_FileTotRecCount_TEXT + REPLICATE(@Lc_Space_TEXT, 153) -- Record_TEXT
   );

   SET @Ls_Sql_TEXT = 'EXTRACT TO FILE';
   SET @Ls_Sqldata_TEXT = 'QUERY = ' + @Ls_BcpCommand_TEXT;
   SET @Ls_BcpCommand_TEXT = 'SELECT Record_TEXT FROM ##ExtractDpr_P1';

   COMMIT TRANSACTION ExtractDpr;

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_EXTRACT_DATA';
   SET @Ls_Sqldata_TEXT = 'FileLocation_TEXT = ' + ISNULL(@Ls_FileLocation_TEXT, '') + ', File_NAME = ' + ISNULL(@Ls_File_NAME, '') + ', Query_TEXT = ' + ISNULL(@Ls_BcpCommand_TEXT, '');

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

   BEGIN TRANSACTION ExtractDpr;

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '');

   EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BSTL_LOG';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Start_DATE = ' + ISNULL(CAST(@Ld_Start_DATE AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Process_NAME = ' + ISNULL(@Ls_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', CursorLocation_TEXT = ' + ISNULL(@Ls_CursorLoc_TEXT, '') + ', ExecLocation_TEXT = ' + ISNULL(@LC_Successful_TEXT, '') + ', ListKey_TEXT = ' + ISNULL(@LC_Successful_TEXT, '') + ', DescriptionError_TEXT = ' + ISNULL(@Ls_DescriptionError_TEXT, '') + ', Status_CODE = ' + ISNULL(@Lc_StatusSuccess_CODE, '') + ', Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', ProcessedRecordCount_QNTY = ' + ISNULL(CAST(@Ln_ProcessedRecordCount_QNTY AS VARCHAR), '');

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Ls_CursorLoc_TEXT,
    @As_ExecLocation_TEXT         = @LC_Successful_TEXT,
    @As_ListKey_TEXT              = @LC_Successful_TEXT,
    @As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE               = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;

   DROP TABLE ##ExtractDpr_P1;

   COMMIT TRANSACTION ExtractDpr
  END TRY

  BEGIN CATCH
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION ExtractDpr;
    END

   IF OBJECT_ID('tempdb..##ExtractDpr_P1') IS NOT NULL
    BEGIN
     DROP TABLE ##ExtractDpr_P1;
    END

   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();
   SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_ErrorMessage_TEXT = SUBSTRING(ERROR_MESSAGE(), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
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
    @As_CursorLocation_TEXT       = @Ls_CursorLoc_TEXT,
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
