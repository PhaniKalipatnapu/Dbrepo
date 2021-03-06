/****** Object:  StoredProcedure [dbo].[BATCH_ENF_OUTGOING_DOR$SP_EXTRACT_DOR]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_ENF_OUTGOING_DOR$SP_EXTRACT_DOR
Programmer Name	:	IMP Team.
Description		:	The batch process reads the data from the database table, 
                     checks reason code equals suspension  or lift from the license suspension activity and 
                     generates a record in outgoing Division of Revenue (DOR) file.
Frequency		:	DAILY
Developed On	:	4/19/2012
Called By		:	NONE
Called On		:	BATCH_COMMON$SP_GET_BATCH_DETAILS ,
                     BATCH_COMMON$BSTL_LOG,
                     BATCH_COMMON$SP_EXTRACT_DATA,
                     BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_ENF_OUTGOING_DOR$SP_EXTRACT_DOR]
AS

 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusFailed_CODE        CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE       CHAR(1) = 'S',
          @Lc_StatusAbnormalend_CODE   CHAR(1) = 'A',
          @Lc_Header_CODE              CHAR(1) = 'H',
          @Lc_Trailer_CODE             CHAR(1) = 'T',
          @Lc_ErrrorTypeW_CODE         CHAR(1) = 'W',
          @Lc_DorPrefixSsn_NUMB        CHAR(1) = '2',
          @Lc_ActionCodeS_CODE         CHAR(1) = 'S',
          @Lc_ActionCodeL_CODE         CHAR(1) = 'L',
          @Lc_TypeOwnership_CODE       CHAR(2) = '01',
          @Lc_ReasonStatusLg_CODE      CHAR(2) = 'LG',
          @Lc_ReasonStatusFs_CODE      CHAR(2) = 'FS',
          @Lc_ReasonStatusLs_CODE      CHAR(2) = 'LS',
          @Lc_ReasonStatusGb_CODE      CHAR(2) = 'GB',
          @Lc_ReasonStatusNy_CODE      CHAR(2) = 'NY',
          @Lc_ReasonStatusEy_CODE      CHAR(2) = 'EY',
          @Lc_ReasonStatusNr_CODE      CHAR(2) = 'NR',
          @Lc_ReasonStatusZj_CODE      CHAR(2) = 'ZJ',
          @Lc_IssuingStateDe_CODE      CHAR(2) = 'DE',
          @Lc_StatusConfirmedGood_CODE CHAR(2) = 'CG',
          @Lc_ReasonStatusLf_CODE      CHAR(2) = 'LF',
          @Lc_DescriptionDor_CODE      CHAR(3) = 'DOR',
          @Lc_TableIdnoPlic_CODE       CHAR(4) = 'PLIC',
          @Lc_TableSubIdnoAgnc_CODE    CHAR(4) = 'AGNC',
          @Lc_StatusComp_CODE          CHAR(4) = 'COMP',
          @Lc_StatusStrt_CODE          CHAR(4) = 'STRT',
          @Lc_MajorActivityLsnr_CODE   CHAR(4) = 'LSNR',
          @Lc_MajorActivityCpls_CODE   CHAR(4) = 'CPLS',
          @Lc_BatchRunUser_TEXT        CHAR(5) = 'BATCH',
          @Lc_MinorActivityCelis_CODE  CHAR(5) = 'CELIS',
          @Lc_MinorActivityRncpl_CODE  CHAR(5) = 'RNCPL',
          @Lc_MinorActivityRradh_CODE  CHAR(5) = 'RRADH',
          @Lc_MinorActivityMofre_CODE  CHAR(5) = 'MOFRE',
          @Lc_MinorActivityInfff_CODE  CHAR(5) = 'INFFF',
          @Lc_ErrorE0944_CODE          CHAR(5) = 'E0944',
          @Lc_Job_ID                   CHAR(7) = 'DEB0701',
          @Lc_Successful_TEXT          CHAR(20) = 'SUCCESSFUL',
          @Ls_ParmDateProblem_TEXT     VARCHAR(50) = 'PARM DATE PROBLEM',
          @Ls_Procedure_NAME           VARCHAR(100) = 'SP_EXTRACT_DOR',
          @Ls_Process_NAME             VARCHAR(100) = 'BATCH_ENF_OUTGOING_DOR',
          @Ld_High_DATE                DATE = '12/31/9999';
  DECLARE @Ln_DorSuffix_NUMB              NUMERIC(3) = 0,
		  @Ln_CommitFreqParm_QNTY         NUMERIC(5) = 0,
          @Ln_ExceptionThresholdParm_QNTY NUMERIC(5) = 0,
          @Ln_ProcessedRecordCount_QNTY   NUMERIC(6) = 0,
          @Ln_Error_NUMB                  NUMERIC(10) = 0,
          @Ln_ErrorLine_NUMB              NUMERIC(10) = 0,
          @Lc_Msg_CODE                    CHAR(1),
          @Lc_Space_TEXT                  CHAR(1) = '',
          @Lc_FileTotRecCount_TEXT        CHAR(8),
          @Ls_File_NAME                   VARCHAR(50),
          @Ls_FileLocation_TEXT           VARCHAR(100),
          @Ls_Sql_TEXT                    VARCHAR(200) = '',
          @Ls_CursorLocation_TEXT         VARCHAR(200) = '',
          @Ls_Sqldata_TEXT                VARCHAR(1000) = '',
          @Ls_BcpCommand_TEXT             VARCHAR(1000),
          @Ls_DescriptionError_TEXT       VARCHAR(4000),
          @Ls_ErrorMessage_TEXT           VARCHAR(4000) = '',
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

   BEGIN TRANSACTION ExtractDor;

   SET @Ls_Sql_TEXT ='CREATE TEMPORARY TABLE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   CREATE TABLE ##ExtractDor_P1
    (
      Record_TEXT VARCHAR(156)
    );

   SET @Ls_Sql_TEXT ='BATCH_COMMON$SP_GET_BATCH_DETAILS2';
   SET @Ls_Sqldata_TEXT ='JOB ID = ' + @Lc_Job_ID;

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

   SET @Ls_Sql_TEXT='DELETE FROM ELDOR_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   DELETE FROM ELDOR_Y1;

   SET @Ls_Sql_TEXT ='BULK INSERT INTO ELDOR_Y1';
   SET @Ls_Sqldata_TEXT = 'OwnerShipType_CODE = ' + ISNULL(@Lc_TypeOwnership_CODE, '');

   INSERT INTO ELDOR_Y1
               (Rec_ID,
                TaxPayor_IDNO,
                Suffix_NAME,
                Business_NAME,
                Trade_NAME,
                Business_CODE,
                OwnerShipType_CODE,
                LicenseNo_TEXT,
                MemberMci_IDNO,
                SupLiftRequest_DATE,
                OwnerPrefixSsn_NUMB,
                OwnerSsn_NUMB,
                Owner_NAME)
   SELECT r.Action_CODE AS Rec_ID,
          CAST(r.TaxPayor_IDNO AS VARCHAR) AS TaxPayor_IDNO,
          r.Suffix_NAME,
          r.Business_NAME AS Business_NAME,
          r.Trade_NAME AS Trade_NAME,
          r.Profession_CODE AS Business_CODE,
          r.OwnerShipType_CODE,
          r.LicenceNo_TEXT AS LicenseNo_TEXT,
          CAST(r.MemberMci_IDNO AS VARCHAR) AS MemberMci_IDNO,
          r.LicSuspLift_DATE AS SupLiftRequest_DATE,
          CAST(@Lc_DorPrefixSsn_NUMB AS VARCHAR) AS OwnerPrefixSsn_NUMB,
          CAST(r.NcpPfSsn_NUMB AS VARCHAR) AS OwnerSsn_NUMB,
          SUBSTRING(r.Ncp_NAME,1,32) AS Owner_NAME
     FROM (SELECT CASE
                   WHEN mn.ReasonStatus_CODE IN (SELECT el.Reason_CODE
                                                   FROM @SuspensionElig_P1 EL)
                    THEN @Lc_ActionCodeS_CODE
                   ELSE @Lc_ActionCodeL_CODE
                  END AS Action_CODE,
				  ISNULL(i.TaxPayor_ID,0) AS TaxPayor_IDNO,
				  ISNULL(i.SuffixSsnNo_TEXT,'') AS Suffix_NAME,
				  ISNULL(i.OwnerShipType_CODE,'') AS OwnerShipType_CODE,                  
                  LEFT(P.Business_NAME, 32) AS Business_NAME,
                  LEFT(mj.Reference_ID, 10) AS LicenceNo_TEXT,
                  mj.MemberMci_IDNO AS MemberMci_IDNO,
                  CONVERT (VARCHAR, mn.Status_DATE, 112) AS LicSuspLift_DATE,
                  s.NcpPfSsn_NUMB AS NcpPfSsn_NUMB,
                  LTRIM(RTRIM(s.LastNcp_NAME)) + ', ' + LTRIM(RTRIM(s.FirstNcp_NAME)) + ' ' + LTRIM(RTRIM(s.MiddleNcp_NAME)) AS Ncp_NAME,
                  LEFT(p.Trade_NAME,32) AS Trade_NAME,
                  p.Profession_CODE AS Profession_CODE,
                  ROW_NUMBER() OVER(PARTITION BY S.NcpPf_IDNO, P.TypeLicense_CODE, P.LicenseNo_TEXT ORDER BY mn.BeginValidity_DATE DESC, mn.TransactionEventSeq_NUMB DESC) Row_COUNT
             FROM DMJR_Y1 mj
                  JOIN DMNR_Y1 mn
                   ON mn.Case_IDNO = mj.Case_IDNO
                      AND mj.OrderSeq_NUMB = mn.OrderSeq_NUMB
                      AND mj.MajorIntSEQ_NUMB = mn.MajorIntSEQ_NUMB
                  JOIN ENSD_Y1 s
                   ON S.Case_IDNO = mj.Case_IDNO
                  JOIN PLIC_Y1 p
                   ON P.MemberMci_IDNO = S.NcpPf_IDNO
                      AND P.LicenseNo_TEXT = mj.Reference_ID
                      AND P.TypeLicense_CODE = mj.TypeReference_CODE
                      AND P.EndValidity_DATE = @Ld_High_DATE
                  LEFT JOIN DSPT_Y1 i 
				   ON i.LicenseNo_TEXT = P.LicenseNo_TEXT
				   AND i.MemberMci_IDNO = p.MemberMci_IDNO                      
           WHERE mj.ActivityMajor_CODE IN (@Lc_MajorActivityLsnr_CODE, @Lc_MajorActivityCpls_CODE)
              AND mj.Status_CODE IN (@Lc_StatusStrt_CODE, @Lc_StatusComp_CODE)
              AND mn.Status_DATE > @Ld_LastRun_DATE 
              AND mn.Status_DATE <= @Ld_Run_DATE
              AND P.IssuingState_CODE = @Lc_IssuingStateDe_CODE
              AND P.Status_CODE = @Lc_StatusConfirmedGood_CODE
              AND S.NcpPfSsn_NUMB <> 0
			AND mj.TypeReference_CODE IN (SELECT Rm.Value_CODE
                                              FROM REFM_Y1 Rm
                                             WHERE Rm.Table_ID = @Lc_TableIdnoPlic_CODE
                                               AND Rm.TableSub_ID = @Lc_TableSubIdnoAgnc_CODE
                                               AND Rm.DescriptionValue_TEXT = @Lc_DescriptionDor_CODE)
              AND (EXISTS (SELECT 1
                             FROM @SuspensionElig_P1 el
                            WHERE el.ActivityMinor_CODE = mn.ActivityMinor_CODE
                              AND el.Reason_CODE = mn.ReasonStatus_CODE)
                    OR (mn.ActivityMinor_CODE = @Lc_MinorActivityMofre_CODE
                        AND mn.ReasonStatus_CODE IN (@Lc_ReasonStatusGb_CODE, @Lc_ReasonStatusNy_CODE, @Lc_ReasonStatusLf_CODE)
                        AND NOT EXISTS (SELECT 1
                                          FROM DMJR_Y1 ji
                                               JOIN DMNR_Y1 ni
                                                ON ji.Case_IDNO = ni.Case_IDNO
                                                   AND ji.MajorIntSEQ_NUMB = ni.MajorIntSEQ_NUMB
                                         WHERE ji.MemberMci_IDNO = mj.MemberMci_IDNO
                                           AND ji.Reference_ID = mj.Reference_ID
                                           AND ji.OthpSource_IDNO = mj.OthpSource_IDNO
                                           AND ji.MajorIntSEQ_NUMB != mj.MajorIntSEQ_NUMB
                                           AND ji.ActivityMajor_CODE IN (@Lc_MajorActivityLsnr_CODE, @Lc_MajorActivityCpls_CODE)
                                           AND ji.Status_CODE IN (@Lc_StatusStrt_CODE)
                                           AND ni.Status_DATE > @Ld_LastRun_DATE 
                                           AND ni.Status_DATE <= @Ld_Run_DATE
                                           AND ni.TransactionEventSeq_NUMB > mn.TransactionEventSeq_NUMB
                                           AND EXISTS (SELECT 1
                                                         FROM @SuspensionElig_P1 el
                                                        WHERE el.ActivityMinor_CODE = mn.ActivityMinor_CODE
                                                          AND el.Reason_CODE = mn.ReasonStatus_CODE))))
             AND NOT EXISTS (SELECT 1
                                FROM DMJR_Y1 j
                                     JOIN DMNR_Y1 n
                                      ON j.Case_IDNO = N.Case_IDNO
                                         AND j.MajorIntSEQ_NUMB = n.MajorIntSEQ_NUMB
                               WHERE j.MemberMci_IDNO = mj.MemberMci_IDNO
                                 AND j.Reference_ID = mj.Reference_ID
                                 AND j.OthpSource_IDNO = mj.OthpSource_IDNO
                                 AND j.TypeReference_CODE = mj.TypeReference_CODE
                                 AND j.Case_IDNO <> mj.Case_IDNO
                                 AND j.ActivityMajor_CODE IN (@Lc_MajorActivityLsnr_CODE, @Lc_MajorActivityCpls_CODE)
                                 AND j.Status_CODE IN (@Lc_StatusStrt_CODE)
                                 AND n.ActivityMinor_CODE = @Lc_MinorActivityMofre_CODE
                                 AND n.Status_CODE IN (@Lc_StatusStrt_CODE))
   ) r
   WHERE Row_COUNT = 1;

   SET @Ln_ProcessedRecordCount_QNTY = (SELECT COUNT(1)
                                          FROM ELDOR_Y1 e);

   IF @Ln_ProcessedRecordCount_QNTY = 0
    BEGIN
     SET @Ls_Sql_TEXT = 'NO RECORDS TO EXTRACT';
     SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + ISNULL(@Ls_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', TypeError_CODE = ' + ISNULL(@Lc_ErrrorTypeW_CODE, '') + ', Line_NUMB = ' + ISNULL(CAST(@Ln_ProcessedRecordCount_QNTY AS VARCHAR), '') + ', Error_CODE = ' + ISNULL(@Lc_ErrorE0944_CODE, '') + ', DescriptionError_TEXT = ' + ISNULL(@Ls_Sql_TEXT, '') + ', ListKey_TEXT = ' + ISNULL(@Ls_Sqldata_TEXT, '');

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Ls_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_ErrrorTypeW_CODE,
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

   SET @Ls_Sql_TEXT='INSERT HEADER';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   INSERT INTO ##ExtractDor_P1
               (Record_TEXT)
        VALUES ( @Lc_Header_CODE + CONVERT(VARCHAR(8), @Ld_Run_DATE, 112) + REPLICATE(@Lc_Space_TEXT, 156) -- Record_TEXT
   );

   SET @Ls_Sql_TEXT = 'INSERT ##ExtractDor_P1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   INSERT INTO ##ExtractDor_P1
               (Record_TEXT)
   SELECT CONVERT(CHAR(1), el.Rec_ID) + RIGHT('0000000000' + LTRIM(RTRIM(el.TaxPayor_IDNO)), 10) + CONVERT(CHAR(3), el.Suffix_NAME) + CONVERT(CHAR(32), el.Business_NAME) + CONVERT(CHAR(32), el.Trade_NAME) + CONVERT(CHAR(3), el.Business_CODE) + CONVERT(CHAR(2), el.OwnerShipType_CODE) + CONVERT(CHAR(10), el.LicenseNo_TEXT) + RIGHT('0000000000' + LTRIM(RTRIM(el.MemberMci_IDNO)), 10) + CONVERT(CHAR(8), el.SupLiftRequest_DATE) + CONVERT(CHAR(1), el.OwnerPrefixSsn_NUMB) + RIGHT('0000000000' + LTRIM(RTRIM(el.OwnerSsn_NUMB)), 9) + CONVERT(CHAR(32), el.Owner_NAME) + REPLICATE(@Lc_Space_TEXT, 3) AS Record_TEXT
     FROM ELDOR_Y1 el;

   SET @Lc_FileTotRecCount_TEXT = CAST(RIGHT(('00000000' + LTRIM(RTRIM(@Ln_ProcessedRecordCount_QNTY))), 8) AS VARCHAR);
   SET @Ls_Sql_TEXT ='INSERT ##ExtractDor_P1 - 2';
   SET @Ls_Sqldata_TEXT = 'FILE RECORD COUNT = ' + @Lc_FileTotRecCount_TEXT;

   INSERT INTO ##ExtractDor_P1
               (Record_TEXT)
        VALUES ( @Lc_Trailer_CODE + CONVERT(VARCHAR(8), @Ld_Run_DATE, 112) + @Lc_FileTotRecCount_TEXT + REPLICATE(@Lc_Space_TEXT, 156) -- Record_TEXT
   );

   SET @Ls_BcpCommand_TEXT = 'SELECT Record_TEXT FROM ##ExtractDor_P1';

   COMMIT TRANSACTION ExtractDor;

   SET @Ls_Sql_TEXT='BATCH_COMMON$SP_EXTRACT_DATA';
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

   BEGIN TRANSACTION ExtractDor;

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

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
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Start_DATE = ' + ISNULL(CAST(@Ld_Start_DATE AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Process_NAME = ' + ISNULL(@Ls_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', CursorLocation_TEXT = ' + ISNULL(@Ls_CursorLocation_TEXT, '') + ', ExecLocation_TEXT = ' + ISNULL(@Lc_Successful_TEXT, '') + ', ListKey_TEXT = ' + ISNULL(@Lc_Successful_TEXT, '') + ', DescriptionError_TEXT = ' + ISNULL(@Ls_DescriptionError_TEXT, '') + ', Status_CODE = ' + ISNULL(@Lc_StatusSuccess_CODE, '') + ', Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', ProcessedRecordCount_QNTY = ' + ISNULL(CAST(@Ln_ProcessedRecordCount_QNTY AS VARCHAR), '');

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

   COMMIT TRANSACTION ExtractDor;

   SET @Ls_Sql_TEXT = 'DROP ##ExtractDor_P1 TABLE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   DROP TABLE ##ExtractDor_P1;
  END TRY

  BEGIN CATCH
   IF OBJECT_ID('tempdb..##ExtractDor_P1') IS NOT NULL
    BEGIN
     DROP TABLE ##ExtractDor_P1;
    END

   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION ExtractDor;
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
