/****** Object:  StoredProcedure [dbo].[BATCH_BI_MAPCM$SP_PROCESS_BIREMEDY]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_BI_MAPCM$SP_PROCESS_BIREMEDY
Programmer Name	:	IMP Team.
Description		:	This process loads remedy information for all cases.
Frequency		:	'DAILY'
Developed On	:	4/27/2012
Called By		:	NONE
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_BI_MAPCM$SP_PROCESS_BIREMEDY]
 @An_RecordCount_NUMB      NUMERIC(6) OUTPUT,
 @Ac_Msg_CODE              CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Li_RowCount_QNTY             INT = 0,
          @Lc_Space_TEXT                CHAR(1) = ' ',
          @Lc_Success_CODE              CHAR(1) = 'S',
          @Lc_Failed_CODE               CHAR(1) = 'F',
          @Lc_TypeError_CODE            CHAR(1) = 'E',
          @Lc_SubsystemCi_TEXT          CHAR(2) = 'CI',
          @Lc_SubsystemCm_TEXT          CHAR(2) = 'CM',
          @Lc_SubsystemEs_TEXT          CHAR(3) = 'ES',
          @Lc_SubsystemEn_TEXT          CHAR(3) = 'EN',
          @Lc_RemedyStatusComplete_CODE CHAR(4) = 'COMP',
          @Lc_RemedyStatusStart_CODE    CHAR(4) = 'STRT',
          @Lc_RemedyStatusExempt_CODE   CHAR(4) = 'EXMT',
          @Lc_MajorActivityRevw_CODE    CHAR(4) = 'REVW',
          @Lc_StatusMajorStrt_CODE      CHAR(4) = 'STRT',
          @Lc_StatusMinorStrt_CODE      CHAR(4) = 'STRT',
          @Lc_ActivityMajorCase_CODE    CHAR(4) = 'CASE',
          @Lc_BateError_CODE            CHAR(5) = 'E0944',
          @Lc_Job_ID                    CHAR(7) = 'DEB0830',
          @Lc_Process_NAME              CHAR(14) = 'BATCH_BI_MAPCM',
          @Ls_Procedure_NAME            VARCHAR(50) = 'SP_PROCESS_BIREMEDY',
          @Ld_Highdate_DATE             DATE = '12/31/9999',
          @Ld_Lowdate_DATE              DATE = '01/01/0001';
  DECLARE @Ln_Zero_NUMB             NUMERIC(1) = 0,
          @Ln_Error_NUMB            NUMERIC(11),
          @Ln_ErrorLine_NUMB        NUMERIC(11),
          @Lc_Msg_CODE              CHAR(1),
          @Ls_Sql_TEXT              VARCHAR(100),
          @Ls_Sqldata_TEXT          VARCHAR(1000),
          @Ls_ErrorMessage_TEXT     VARCHAR(4000),
          @Ls_DescriptionError_TEXT VARCHAR(4000),
          @Ld_Start_DATE            DATETIME2;

  BEGIN TRY
   SET @Ac_Msg_CODE = @Lc_Success_CODE;
   SET @As_DescriptionError_TEXT = @Lc_Space_TEXT;
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   SET @Ls_Sql_TEXT = 'DELETE FROM BPRMDY_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   DELETE FROM BPRMDY_Y1;

   SET @Ls_Sql_TEXT = 'INSERT INTO BPRMDY_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   INSERT BPRMDY_Y1
          (Case_IDNO,
           OrderSeq_NUMB,
           BiSubsystem_CODE,
           ActivityMajor_CODE,
           ActivityMinor_CODE,
           ActivityOrder_QNTY,
           Status_CODE,
           Status_DATE,
           DaysActivityElapsed_QNTY,
           BeginExempt_DATE,
           EndExempt_DATE,
           MajorIntSeq_NUMB,
           MinorIntSeq_NUMB,
           ReasonStatus_CODE,
           DescriptionActivityMajor_TEXT,
           DescriptionActivityMinor_TEXT,
           MemberMci_IDNO,
           TypeOthpSource_CODE,
           OthpSource_IDNO,
           TransactionEventMajorSeq_NUMB,
           TransactionEventMinorSeq_NUMB,
           StatusMinor_CODE,
           StatusMinor_DATE)
   SELECT a.Case_IDNO,
          a.OrderSeq_NUMB,
          CASE
           WHEN a.Subsystem_CODE IN (@Lc_SubsystemCi_TEXT, @Lc_SubsystemCm_TEXT)
            THEN @Lc_SubsystemEs_TEXT
           ELSE a.Subsystem_CODE
          END AS Subsystem_CODE,
          a.ActivityMajor_CODE,
          ISNULL(b.ActivityMinor_CODE, @Lc_Space_TEXT) AS ActivityMinor_CODE,
          ISNULL((SELECT TOP 1 x.ActivityOrder_QNTY
                    FROM ANXT_Y1 x
                   WHERE x.ActivityMajor_CODE = a.ActivityMajor_CODE
                     AND x.ActivityMinor_CODE = b.ActivityMinor_CODE
                     AND x.EndValidity_DATE = @Ld_Highdate_DATE), @Ln_Zero_NUMB) AS ActivityOrder_QNTY,
          a.Status_CODE,
          a.Status_DATE,
          CASE
           WHEN b.Status_CODE = @Lc_RemedyStatusComplete_CODE
            THEN CAST(ABS(DATEDIFF(DD, b.Status_DATE, b.Entered_DATE)) AS NUMERIC(38))
           WHEN b.Status_CODE = @Lc_RemedyStatusStart_CODE
            THEN CAST(ABS(DATEDIFF(DD, @Ld_Start_DATE, b.Entered_DATE)) AS NUMERIC(38))
           ELSE @Ln_Zero_NUMB
          END AS DaysActivityElapsed_QNTY,
          a.BeginExempt_DATE,
          a.EndExempt_DATE,
          a.MajorIntSeq_NUMB,
          ISNULL(b.MinorIntSeq_NUMB, @Ln_Zero_NUMB) AS MinorIntSeq_NUMB,
          ISNULL(b.ReasonStatus_CODE, @Lc_Space_TEXT) AS ReasonStatus_CODE,
          ISNULL((SELECT TOP 1 x.DescriptionActivity_TEXT
                    FROM AMJR_Y1 x
                   WHERE x.ActivityMajor_CODE = a.ActivityMajor_CODE
                     AND x.Subsystem_CODE = a.Subsystem_CODE
                     AND x.EndValidity_DATE = @Ld_Highdate_DATE), @Lc_Space_TEXT) AS DescriptionActivityMajor_TEXT,
          ISNULL((SELECT TOP 1 x.DescriptionActivity_TEXT
                    FROM AMNR_Y1 x
                   WHERE x.ActivityMinor_CODE = b.ActivityMinor_CODE
                     AND x.EndValidity_DATE = @Ld_Highdate_DATE), @Lc_Space_TEXT) AS DescriptionActivityMinor_TEXT,
          a.MemberMci_IDNO,
          a.TypeOthpSource_CODE,
          CASE
           WHEN a.ActivityMajor_CODE = @Lc_MajorActivityRevw_CODE
            THEN a.Reference_ID
           ELSE a.OthpSource_IDNO
          END AS OthpSource_IDNO,
          a.TransactionEventSeq_NUMB AS TransactionEventSeqMjr_NUMB,
          ISNULL(b.TransactionEventSeq_NUMB, @Ln_Zero_NUMB) AS TransactionEventSeqMnr_NUMB,
          ISNULL(b.Status_CODE, @Lc_Space_TEXT) AS StatusMinor_CODE,
          ISNULL(b.Status_DATE, @Ld_Highdate_DATE) AS StatusMinor_DATE
     FROM (SELECT x.Case_IDNO,
                  x.OrderSeq_NUMB,
                  x.MajorIntSeq_NUMB,
                  x.MemberMci_IDNO,
                  x.ActivityMajor_CODE,
                  x.Subsystem_CODE,
                  x.TypeOthpSource_CODE,
                  x.OthpSource_IDNO,
                  x.Entered_DATE,
                  x.Status_DATE,
                  x.Status_CODE,
                  x.ReasonStatus_CODE,
                  x.BeginExempt_DATE,
                  x.EndExempt_DATE,
                  x.Forum_IDNO,
                  x.TotalTopics_QNTY,
                  x.PostLastPoster_IDNO,
                  x.UserLastPoster_ID,
                  x.SubjectLastPoster_TEXT,
                  x.LastPost_DTTM,
                  x.BeginValidity_DATE,
                  x.WorkerUpdate_ID,
                  x.Update_DTTM,
                  x.TransactionEventSeq_NUMB,
                  x.TypeReference_CODE,
                  x.Reference_ID
             FROM DMJR_Y1 x
            WHERE x.ActivityMajor_CODE <> @Lc_ActivityMajorCase_CODE
              AND x.Subsystem_CODE IN (@Lc_SubsystemEn_TEXT, @Lc_SubsystemEs_TEXT, @Lc_SubsystemCm_TEXT, @Lc_SubsystemCi_TEXT)
              AND (x.Status_CODE = @Lc_RemedyStatusStart_CODE
                    OR (x.Status_CODE = @Lc_RemedyStatusExempt_CODE
                        AND x.BeginExempt_DATE != @Ld_Lowdate_DATE
                        AND @Ld_Start_DATE BETWEEN x.BeginExempt_DATE AND x.EndExempt_DATE))) AS a
          LEFT OUTER JOIN DMNR_Y1 b
           ON a.Case_IDNO = b.Case_IDNO
              AND a.OrderSeq_NUMB = b.OrderSeq_NUMB
              AND a.MajorIntSeq_NUMB = b.MajorIntSeq_NUMB
    WHERE EXISTS (SELECT 1
                    FROM BPCASE_Y1 b
                   WHERE b.Case_IDNO = a.Case_IDNO);       

   SET @Li_RowCount_QNTY = @@ROWCOUNT;

   IF (@Li_RowCount_QNTY = 0)
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG';
     SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + ISNULL(@Lc_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Start_DATE AS VARCHAR), '') + ', TypeError_CODE = ' + ISNULL(@Lc_TypeError_CODE, '') + ', Line_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Error_CODE = ' + ISNULL(@Lc_BateError_CODE, '') + ', DescriptionError_TEXT = ' + ISNULL(@Ls_DescriptionError_TEXT, '');

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Lc_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Start_DATE,
      @Ac_TypeError_CODE           = @Lc_TypeError_CODE,
      @An_Line_NUMB                = @Ln_Zero_NUMB,
      @Ac_Error_CODE               = @Lc_BateError_CODE,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
      @As_ListKey_TEXT             = @Ls_SqlData_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_Failed_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END
    END

   SET @An_RecordCount_NUMB = (SELECT COUNT(*) FROM (SELECT DISTINCT Case_IDNO FROM BPRMDY_Y1) A);

   SET @Ls_Sql_TEXT = 'DELETE FROM BPORDY_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   DELETE FROM BPORDY_Y1;

   SET @Ls_Sql_TEXT = 'INSERT TABLE BPORDY_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   INSERT BPORDY_Y1
          (Case_IDNO,
           OrderSeq_NUMB,
           BiSubsystem_CODE,
           ActivityMajor_CODE,
           ActivityMinor_CODE,
           ActivityOrder_QNTY,
           Status_CODE,
           Status_DATE,
           DaysActivityElapsed_QNTY,
           BeginExempt_DATE,
           EndExempt_DATE,
           MajorIntSeq_NUMB,
           MinorIntSeq_NUMB,
           ReasonStatus_CODE,
           DescriptionActivityMajor_TEXT,
           DescriptionActivityMinor_TEXT,
           MemberMci_IDNO,
           TypeOthpSource_CODE,
           OthpSource_IDNO,
           TransactionEventMajorSeq_NUMB,
           TransactionEventMinorSeq_NUMB,
           StatusMinor_CODE,
           StatusMinor_DATE,
           EnteredMjr_DATE)
   (SELECT a.Case_IDNO,
           a.OrderSeq_NUMB,
           a.BiSubsystem_CODE,
           a.ActivityMajor_CODE,
           a.ActivityMinor_CODE,
           a.ActivityOrder_QNTY,
           a.Status_CODE,
           a.Status_DATE,
           a.DaysActivityElapsed_QNTY,
           a.BeginExempt_DATE,
           a.EndExempt_DATE,
           a.MajorIntSeq_NUMB,
           a.MinorIntSeq_NUMB,
           a.ReasonStatus_CODE,
           a.DescriptionActivityMajor_TEXT,
           a.DescriptionActivityMinor_TEXT,
           a.MemberMci_IDNO,
           a.TypeOthpSource_CODE,
           a.OthpSource_IDNO,
           a.TransactionEventMajorSeq_NUMB,
           a.TransactionEventMinorSeq_NUMB,
           a.StatusMinor_CODE,
           a.StatusMinor_DATE,
           @Lc_Space_TEXT AS EnteredMjr_DATE
      FROM BPRMDY_Y1 a
     WHERE a.Status_CODE = @Lc_StatusMajorStrt_CODE
       AND a.StatusMinor_CODE = @Lc_StatusMinorStrt_CODE);

   SET @Li_RowCount_QNTY = @@ROWCOUNT;

   IF (@Li_RowCount_QNTY = 0)
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG';
     SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + ISNULL(@Lc_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Start_DATE AS VARCHAR), '') + ', TypeError_CODE = ' + ISNULL(@Lc_TypeError_CODE, '') + ', Line_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Error_CODE = ' + ISNULL(@Lc_BateError_CODE, '') + ', DescriptionError_TEXT = ' + ISNULL(@Ls_DescriptionError_TEXT, '');

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Lc_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Start_DATE,
      @Ac_TypeError_CODE           = @Lc_TypeError_CODE,
      @An_Line_NUMB                = @Ln_Zero_NUMB,
      @Ac_Error_CODE               = @Lc_BateError_CODE,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
      @As_ListKey_TEXT             = @Ls_SqlData_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_Failed_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END
    END
   
   SET @An_RecordCount_NUMB = @An_RecordCount_NUMB + (SELECT COUNT(*) FROM (SELECT DISTINCT Case_IDNO FROM BPORDY_Y1) A);

   SET @Ls_Sql_TEXT = 'DELETE FROM BORDY_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   DELETE FROM BORDY_Y1;

   SET @Ls_Sql_TEXT = 'INSERT TABLE BORDY_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   INSERT BORDY_Y1
          (Case_IDNO,
           OrderSeq_NUMB,
           BiSubsystem_CODE,
           ActivityMajor_CODE,
           ActivityMinor_CODE,
           ActivityOrder_QNTY,
           Status_CODE,
           Status_DATE,
           DaysActivityElapsed_QNTY,
           BeginExempt_DATE,
           EndExempt_DATE,
           MajorIntSeq_NUMB,
           MinorIntSeq_NUMB,
           ReasonStatus_CODE,
           DescriptionActivityMajor_TEXT,
           DescriptionActivityMinor_TEXT,
           MemberMci_IDNO,
           TypeOthpSource_CODE,
           OthpSource_IDNO,
           TransactionEventMajorSeq_NUMB,
           TransactionEventMinorSeq_NUMB,
           StatusMinor_CODE,
           StatusMinor_DATE,
           EnteredMjr_DATE)
   SELECT a.Case_IDNO,
          a.OrderSeq_NUMB,
          a.BiSubsystem_CODE,
          a.ActivityMajor_CODE,
          a.ActivityMinor_CODE,
          a.ActivityOrder_QNTY,
          a.Status_CODE,
          a.Status_DATE,
          a.DaysActivityElapsed_QNTY,
          a.BeginExempt_DATE,
          a.EndExempt_DATE,
          a.MajorIntSeq_NUMB,
          a.MinorIntSeq_NUMB,
          a.ReasonStatus_CODE,
          a.DescriptionActivityMajor_TEXT,
          a.DescriptionActivityMinor_TEXT,
          a.MemberMci_IDNO,
          a.TypeOthpSource_CODE,
          a.OthpSource_IDNO,
          a.TransactionEventMajorSeq_NUMB,
          a.TransactionEventMinorSeq_NUMB,
          a.StatusMinor_CODE,
          a.StatusMinor_DATE,
          a.EnteredMjr_DATE
     FROM BPORDY_Y1 a;

   SET @Li_RowCount_QNTY = @@ROWCOUNT;

   IF (@Li_RowCount_QNTY = 0)
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG';
     SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + ISNULL(@Lc_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Start_DATE AS VARCHAR), '') + ', TypeError_CODE = ' + ISNULL(@Lc_TypeError_CODE, '') + ', Line_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Error_CODE = ' + ISNULL(@Lc_BateError_CODE, '') + ', DescriptionError_TEXT = ' + ISNULL(@Ls_DescriptionError_TEXT, '');

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Lc_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Start_DATE,
      @Ac_TypeError_CODE           = @Lc_TypeError_CODE,
      @An_Line_NUMB                = @Ln_Zero_NUMB,
      @Ac_Error_CODE               = @Lc_BateError_CODE,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
      @As_ListKey_TEXT             = @Ls_SqlData_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_Failed_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END
    END
  END TRY

  BEGIN CATCH
   BEGIN
    SET @Ac_Msg_CODE = @Lc_Failed_CODE;
    SET @An_RecordCount_NUMB = 0;
    SET @Ln_Error_NUMB = ERROR_NUMBER ();
    SET @Ln_ErrorLine_NUMB = ERROR_LINE ();
    SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

    IF @Ln_Error_NUMB <> 50001
     BEGIN
      SET @Ls_ErrorMessage_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
     END

    EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
     @As_Procedure_NAME        = @Ls_Procedure_NAME,
     @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
     @As_Sql_TEXT              = @Ls_Sql_TEXT,
     @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
     @An_Error_NUMB            = @Ln_Error_NUMB,
     @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
     @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;
   END
  END CATCH
 END 

GO
