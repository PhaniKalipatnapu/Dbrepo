/****** Object:  StoredProcedure [dbo].[BATCH_CI_OUTGOING_CSENET_FILE$SP_CSENET_INSERT_ALERT]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_CI_OUTGOING_CSENET_FILE$SP_CSENET_INSERT_ALERT
Programmer Name	:	IMP Team.
Description		:	This procedure is used to send the alert for the worker.
Frequency		:	DAILY
Developed On	:	04/04/2011
Called By		:	BATCH_CI_OUTGOING_CSENET_FILE$SP_CSENET_INIT_TRAN
Called On		:	BATCH_COMMON$SP_BATE_LOG
		            BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
		            BATCH_COMMON$SP_INSERT_ACTIVITY
--------------------------------------------------------------------------------------------------------------------
Modified By		:
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_CI_OUTGOING_CSENET_FILE$SP_CSENET_INSERT_ALERT]
 @Ad_LastRun_DATE          DATE,
 @Ad_Run_DATE              DATE,
 @Ac_Job_ID                CHAR(7),
 @Ac_BatchRunUser_TEXT     CHAR(30),
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_Space_TEXT                     CHAR(1) = ' ',
          @Lc_CaseStatusOpen_CODE            CHAR(1) = 'O',
          @Lc_RelationshipCaseNcp_TEXT       CHAR(1) = 'A',
          @Lc_RelationshipCasePutFather_TEXT CHAR(1) = 'P',
          @Lc_StatusCaseMemberActive_CODE    CHAR(1) = 'A',
          @Lc_ErrorTypeError_CODE            CHAR(1) = 'E',
          @Lc_StatusFailed_CODE              CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE             CHAR(1) = 'S',
          @Lc_NoteN_INDC                     CHAR(1) = 'N',
          @Lc_Subsystem_CODE                 CHAR(2) = 'IN',
          @Lc_StatusRequestPN_CODE           CHAR(2) = 'PN',
          @Lc_StatusRequestBE_CODE           CHAR(2) = 'BE',
          @Lc_StatusRequestSS_CODE           CHAR(2) = 'SS',
          @Lc_HyphenWithSpace_TEXT           CHAR(3) = ' - ',
          @Lc_MajorActivityCase_CODE         CHAR(4) = 'CASE',
          @Lc_ActivityMinorCsoer_CODE        CHAR(5) = 'CSOER',
          @Lc_ErrorE0113_CODE                CHAR(5) = 'E0113',
          @Ls_Process_NAME                   VARCHAR(100) = 'BATCH_CI_OUTGOING_CSENET_FILE',
          @Ls_Procedure_NAME                 VARCHAR(100) = 'SP_CSENET_INSERT_ALERT',
          @Ls_Sql_TEXT                       VARCHAR(2000) = ' ',
          @Ls_Sqldata_TEXT                   VARCHAR(4000) = ' ',
          @Ld_High_DATE                      DATE = '12/31/9999';
  DECLARE @Ln_MemberMci_IDNO           NUMERIC(10) = 0,
          @Ln_Topic_IDNO               NUMERIC(10) = 0,
          @Ln_QNTY                     NUMERIC(10) = 0,
          @Ln_TransactionEventSeq_NUMB NUMERIC(19),
          @Li_Error_NUMB               INT = 0,
          @Li_ErrorLine_NUMB           INT = 0,
          @Li_FetchStatus_NUMB         SMALLINT,
          @Li_Rowcount_QNTY            SMALLINT,
          @Lc_Msg_CODE                 CHAR(5),
          @Lc_Fips_CODE                CHAR(7),
          @Ls_DescriptionError_TEXT    VARCHAR(4000);
  DECLARE @Ln_AlertCur_Request_IDNO                 NUMERIC(9),
          @Ld_AlertCur_Generated_DATE               DATE,
          @Lc_AlertCur_IVDOutOfStateFips_CODE       CHAR(2),
          @Lc_AlertCur_IVDOutOfStateCountyFips_CODE CHAR(3),
          @Lc_AlertCur_IVDOutOfStateOfficeFips_CODE CHAR(2),
          @Ln_AlertCur_Case_IDNO                    NUMERIC(6),
          @Ln_AlertCur_RespondentMci_IDNO           NUMERIC(10),
          @Lc_AlertCur_ActivityMinorOut_CODE        CHAR(5),
          @Lc_AlertCur_Function_CODE                CHAR(3),
          @Lc_AlertCur_Action_CODE                  CHAR(1),
          @Lc_AlertCur_Reason_CODE                  CHAR(5),
          @Ls_AlertCur_DescriptionFar_TEXT          VARCHAR(1000),
          @Lc_AlertCur_Fips_NAME                    CHAR(40),
          @Lc_AlertCur_Worker_ID                    CHAR(30),
          @Ls_AlertCur_InfoLine1_TEXT               VARCHAR(80),
          @Ls_AlertCur_InfoLine2_TEXT               VARCHAR(80),
          @Ls_AlertCur_InfoLine3_TEXT               VARCHAR(80),
          @Ls_AlertCur_InfoLine4_TEXT               VARCHAR(80),
          @Ls_AlertCur_InfoLine5_TEXT               VARCHAR(80);

  BEGIN TRY
   SET @Ln_QNTY = 0;

   -- To Insert Case Journal entry for all incoming, outgoing CSENET transaction
   DECLARE Alert_CUR INSENSITIVE CURSOR FOR
    SELECT a.Request_IDNO,
           a.Generated_DATE,
           a.IVDOutOfStateFips_CODE,
           a.IVDOutOfStateCountyFips_CODE,
           a.IVDOutOfStateOfficeFips_CODE,
           a.Case_IDNO,
           a.RespondentMci_IDNO,
           @Lc_ActivityMinorCsoer_CODE AS ActivityMinorOut_CODE,
           b.Function_CODE,
           b.Action_CODE,
           b.Reason_CODE,
           b.DescriptionFar_TEXT,
           (SELECT d.State_NAME
              FROM STAT_Y1 d
             WHERE d.StateFips_CODE = a.IVDOutOfStateFips_CODE) AS Fips_NAME,
           (SELECT TOP 1 u.Worker_ID + @Lc_HyphenWithSpace_TEXT + u.Last_NAME + @Lc_Space_TEXT + u.First_NAME + @Lc_Space_TEXT + u.Middle_NAME
              FROM CSPR_Y1 b,
                   USEM_Y1 u
             WHERE StatusRequest_CODE = @Lc_StatusRequestPN_CODE
               AND b.Request_IDNO = a.Request_IDNO
               AND u.Worker_ID = b.WorkerUpdate_ID
               AND u.EndValidity_DATE = @Ld_High_DATE) AS Worker_ID,
           c.InfoLine1_TEXT,
           c.InfoLine2_TEXT,
           c.InfoLine3_TEXT,
           c.InfoLine4_TEXT,
           c.InfoLine5_TEXT
      FROM CSPR_Y1 a
           LEFT OUTER JOIN EIBLK_Y1 c
            ON a.Request_IDNO = c.TransHeader_IDNO
               AND a.IVDOutOfStateFips_CODE = c.IVDOutOfStateFips_CODE
           JOIN CFAR_Y1 b
            ON b.Action_CODE = a.Action_CODE
               AND b.Reason_CODE = a.Reason_CODE
               AND b.Function_CODE = a.Function_CODE
           JOIN CASE_Y1 d
            ON a.Case_IDNO = d.Case_IDNO
     WHERE a.Generated_DATE BETWEEN CONVERT(DATE, (DATEADD(D, 1, @Ad_LastRun_DATE)), 102) AND @Ad_Run_DATE
       AND a.StatusRequest_CODE = @Lc_StatusRequestBE_CODE
       AND a.EndValidity_DATE = @Ld_High_DATE
       AND d.StatusCase_CODE = @Lc_CaseStatusOpen_CODE
    UNION
    SELECT a.Request_IDNO,
           a.Generated_DATE,
           a.IVDOutOfStateFips_CODE,
           a.IVDOutOfStateCountyFips_CODE,
           a.IVDOutOfStateOfficeFips_CODE,
           a.Case_IDNO,
           a.RespondentMci_IDNO,
           b.ActivityMinorOut_CODE,
           b.Function_CODE,
           b.Action_CODE,
           b.Reason_CODE,
           b.DescriptionFar_TEXT,
           (SELECT s.State_NAME
              FROM STAT_Y1 s
             WHERE s.StateFips_CODE = a.IVDOutOfStateFips_CODE) AS Fips_NAME,
           (SELECT TOP 1 u.Worker_ID + ' - ' + u.Last_NAME + @Lc_Space_TEXT + u.First_NAME + @Lc_Space_TEXT + u.Middle_NAME
              FROM CSPR_Y1 b,
                   USEM_Y1 u
             WHERE b.StatusRequest_CODE = @Lc_StatusRequestPN_CODE
               AND b.Request_IDNO = a.Request_IDNO
               AND u.Worker_ID = b.WorkerUpdate_ID
               AND u.EndValidity_DATE = @Ld_High_DATE) AS Worker_ID,
           c.InfoLine1_TEXT,
           c.InfoLine2_TEXT,
           c.InfoLine3_TEXT,
           c.InfoLine4_TEXT,
           c.InfoLine5_TEXT
      FROM CSPR_Y1 a
           LEFT OUTER JOIN EIBLK_Y1 c
            ON a.Request_IDNO = c.TransHeader_IDNO
               AND a.IVDOutOfStateFips_CODE = c.IVDOutOfStateFips_CODE
           JOIN CFAR_Y1 b
            ON b.Action_CODE = a.Action_CODE
               AND b.Reason_CODE = a.Reason_CODE
               AND b.Function_CODE = a.Function_CODE
           JOIN CASE_Y1 d
            ON a.Case_IDNO = d.Case_IDNO
     WHERE a.Generated_DATE BETWEEN CONVERT(DATE, (DATEADD(D, 1, @Ad_LastRun_DATE)), 102) AND @Ad_Run_DATE
       AND a.StatusRequest_CODE = @Lc_StatusRequestSS_CODE
       AND b.ActivityMinorOut_CODE <> @Lc_Space_TEXT
       AND a.EndValidity_DATE = @Ld_High_DATE
       AND d.StatusCase_CODE = @Lc_CaseStatusOpen_CODE;

   SET @Ls_Sql_TEXT = 'OPEN Alert_CUR';
   SET @Ls_Sqldata_TEXT = '';

   OPEN Alert_CUR;

   SET @Ls_Sql_TEXT = 'FETCH Alert_CUR - 1';
   SET @Ls_Sqldata_TEXT = '';

   FETCH NEXT FROM Alert_CUR INTO @Ln_AlertCur_Request_IDNO, @Ld_AlertCur_Generated_DATE, @Lc_AlertCur_IVDOutOfStateFips_CODE, @Lc_AlertCur_IVDOutOfStateCountyFips_CODE, @Lc_AlertCur_IVDOutOfStateOfficeFips_CODE, @Ln_AlertCur_Case_IDNO, @Ln_AlertCur_RespondentMci_IDNO, @Lc_AlertCur_ActivityMinorOut_CODE, @Lc_AlertCur_Function_CODE, @Lc_AlertCur_Action_CODE, @Lc_AlertCur_Reason_CODE, @Ls_AlertCur_DescriptionFar_TEXT, @Lc_AlertCur_Fips_NAME, @Lc_AlertCur_Worker_ID, @Ls_AlertCur_InfoLine1_TEXT, @Ls_AlertCur_InfoLine2_TEXT, @Ls_AlertCur_InfoLine3_TEXT, @Ls_AlertCur_InfoLine4_TEXT, @Ls_AlertCur_InfoLine5_TEXT;

   SET @Li_FetchStatus_NUMB = @@FETCH_STATUS;

   -- Insert Activity Alert 
   WHILE @Li_FetchStatus_NUMB = 0
    BEGIN
     SET @Ln_QNTY = @Ln_QNTY + 1;
     SET @Ls_Sql_TEXT = 'SELECT CMEM_Y1';
     SET @Ls_Sqldata_TEXT = '';

     IF @Ln_AlertCur_RespondentMci_IDNO <> 0
      BEGIN
       SET @Ln_MemberMci_IDNO = @Ln_AlertCur_RespondentMci_IDNO;
      END
     ELSE
      BEGIN
       SELECT TOP (1) @Ln_MemberMci_IDNO = fci.MemberMci_IDNO
         FROM (SELECT a.MemberMci_IDNO,
                      a.CaseRelationship_CODE
                 FROM CMEM_Y1 a
                WHERE a.Case_IDNO = @Ln_AlertCur_Case_IDNO
                  AND a.CaseRelationship_CODE IN (@Lc_RelationshipCaseNcp_TEXT, @Lc_RelationshipCasePutFather_TEXT)
                  AND a.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE) AS fci
        ORDER BY fci.CaseRelationship_CODE DESC;
      END;

     SET @Li_Rowcount_QNTY = @@ROWCOUNT;

     IF (@Li_Rowcount_QNTY = 0)
      BEGIN
       SET @Ln_MemberMci_IDNO = 0;
      END;

     IF @Ln_MemberMci_IDNO = 0
      BEGIN
       SET @Ls_DescriptionError_TEXT = 'MemberMci_IDNO = 0';

       EXECUTE BATCH_COMMON$SP_BATE_LOG
        @As_Process_NAME             = @Ls_Process_NAME,
        @As_Procedure_NAME           = @Ls_Procedure_NAME,
        @Ac_Job_ID                   = @Ac_Job_ID,
        @Ad_Run_DATE                 = @Ad_Run_DATE,
        @Ac_TypeError_CODE           = @Lc_ErrorTypeError_CODE,
        @An_Line_NUMB                = @Ln_QNTY,
        @Ac_Error_CODE               = @Lc_ErrorE0113_CODE,
        @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
        @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
        @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         RAISERROR(50001,16,1);
        END;
      END;
     ELSE
      BEGIN
       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT';
       SET @Ls_Sqldata_TEXT = 'Worker_ID = ' + ISNULL(@Ac_BatchRunUser_TEXT, '') + ', Process_ID = ' + ISNULL(@Ac_Job_ID, '') + ', EffectiveEvent_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '');

       EXEC BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
        @Ac_Worker_ID                = @Ac_BatchRunUser_TEXT,
        @Ac_Process_ID               = @Ac_Job_ID,
        @Ad_EffectiveEvent_DATE      = @Ad_Run_DATE,
        @Ac_Note_INDC                = @Lc_NoteN_INDC,
        @An_EventFunctionalSeq_NUMB  = 0,
        @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
        @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         RAISERROR(50001,16,1);
        END;

       SET @Lc_Fips_CODE = @Lc_AlertCur_IVDOutOfStateFips_CODE + @Lc_AlertCur_IVDOutOfStateCountyFips_CODE + @Lc_AlertCur_IVDOutOfStateOfficeFips_CODE;
       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_ACTIVITY';
       SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_AlertCur_Case_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR), '') + ', ActivityMajor_CODE = ' + ISNULL(@Lc_MajorActivityCase_CODE, '') + ', ActivityMinor_CODE = ' + ISNULL(@Lc_AlertCur_ActivityMinorOut_CODE, '') + ', Subsystem_CODE = ' + ISNULL(@Lc_Subsystem_CODE, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', WorkerUpdate_ID = ' + ISNULL(@Ac_BatchRunUser_TEXT, '') + ', Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', IVDOutOfStateFips_CODE = ' + ISNULL(@Lc_Fips_CODE, '');

       EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
        @An_Case_IDNO                = @Ln_AlertCur_Case_IDNO,
        @An_MemberMci_IDNO           = @Ln_MemberMci_IDNO,
        @Ac_ActivityMajor_CODE       = @Lc_MajorActivityCase_CODE,
        @Ac_ActivityMinor_CODE       = @Lc_AlertCur_ActivityMinorOut_CODE,
        @Ac_Subsystem_CODE           = @Lc_Subsystem_CODE,
        @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
        @Ac_WorkerUpdate_ID          = @Ac_BatchRunUser_TEXT,
        @Ad_Run_DATE                 = @Ad_Run_DATE,
        @Ac_IVDOutOfStateFips_CODE   = @Lc_Fips_CODE,
        @An_Topic_IDNO               = @Ln_Topic_IDNO OUTPUT,
        @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

       IF (@Lc_Msg_CODE <> @Lc_StatusSuccess_CODE)
        BEGIN
         EXECUTE BATCH_COMMON$SP_BATE_LOG
          @As_Process_NAME             = @Ls_Process_NAME,
          @As_Procedure_NAME           = @Ls_Procedure_NAME,
          @Ac_Job_ID                   = @Ac_Job_ID,
          @Ad_Run_DATE                 = @Ad_Run_DATE,
          @Ac_TypeError_CODE           = @Lc_ErrorTypeError_CODE,
          @An_Line_NUMB                = @Ln_QNTY,
          @Ac_Error_CODE               = @Lc_Msg_CODE,
          @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
          @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
          @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
          @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

         IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
          BEGIN
           RAISERROR(50001,16,1);
          END;
        END;
      END;

     SET @Ls_Sql_TEXT = 'FETCH Alert_CUR - 2';
     SET @Ls_Sqldata_TEXT = '';

     FETCH NEXT FROM Alert_CUR INTO @Ln_AlertCur_Request_IDNO, @Ld_AlertCur_Generated_DATE, @Lc_AlertCur_IVDOutOfStateFips_CODE, @Lc_AlertCur_IVDOutOfStateCountyFips_CODE, @Lc_AlertCur_IVDOutOfStateOfficeFips_CODE, @Ln_AlertCur_Case_IDNO, @Ln_AlertCur_RespondentMci_IDNO, @Lc_AlertCur_ActivityMinorOut_CODE, @Lc_AlertCur_Function_CODE, @Lc_AlertCur_Action_CODE, @Lc_AlertCur_Reason_CODE, @Ls_AlertCur_DescriptionFar_TEXT, @Lc_AlertCur_Fips_NAME, @Lc_AlertCur_Worker_ID, @Ls_AlertCur_InfoLine1_TEXT, @Ls_AlertCur_InfoLine2_TEXT, @Ls_AlertCur_InfoLine3_TEXT, @Ls_AlertCur_InfoLine4_TEXT, @Ls_AlertCur_InfoLine5_TEXT;

     SET @Li_FetchStatus_NUMB = @@FETCH_STATUS;
    END;

   IF CURSOR_STATUS('LOCAL', 'Alert_CUR') IN (0, 1)
    BEGIN
     CLOSE Alert_CUR;

     DEALLOCATE Alert_CUR;
    END;

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

   IF CURSOR_STATUS('LOCAL', 'Alert_CUR') IN (0, 1)
    BEGIN
     CLOSE Alert_CUR;

     DEALLOCATE Alert_CUR;
    END;

   SET @Li_Error_NUMB = ERROR_NUMBER();
   SET @Li_ErrorLine_NUMB = ERROR_LINE();

   IF (@Li_Error_NUMB <> 50001)
    BEGIN
     SET @Ls_DescriptionError_TEXT = SUBSTRING(ERROR_MESSAGE(), 1, 200);
    END;

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_SqlData_TEXT,
    @An_Error_NUMB            = @Li_Error_NUMB,
    @An_ErrorLine_NUMB        = @Li_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
  END CATCH;
 END;


GO
