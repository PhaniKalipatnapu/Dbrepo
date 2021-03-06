/****** Object:  StoredProcedure [dbo].[BATCH_CI_INCOMING_CSENET_FILE$SP_CSENET_INSERT_ALERT]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
-----------------------------------------------------------------------------------------------------
Procedure Name         : BATCH_CI_INCOMING_CSENET_FILE$SP_CSENET_INSERT_ALERT 
Programmer Name        : IMP Team
Description            : This procedure is used to insert the alert for the incoming transactions.
Frequency              : DAILY
Developed On           : 04/04/2011
Called By              : BATCH_CI_INCOMING_CSENET_FILE$SP_PROCESS_CSENET
Called On              :
-------------------------------------------------------------------------------------------------------
Modified By            :
Modified On            :
Version No             :  
------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_CI_INCOMING_CSENET_FILE$SP_CSENET_INSERT_ALERT] (
 @Ac_Job_ID                CHAR(7),
 @Ad_Run_DATE              DATE,
 @Ac_Subsystem_CODE        CHAR(3),
 @Ac_BatchRunUser_TEXT     CHAR(30),
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusCaseMemberActive_CODE    CHAR = 'A',
          @Lc_ErrorTypeInformation_CODE      CHAR = 'I',
          @Lc_StatusFailed_CODE              CHAR = 'F',
          @Lc_No_INDC                        CHAR = 'N',
          @Lc_StatusSuccess_CODE             CHAR(1) = 'S',
          @Lc_Space_TEXT                     CHAR(1) = ' ',
          @Lc_CaseStatusOpen_CODE            CHAR(1) = 'O',
          @Lc_RelationshipCaseNcp_CODE       CHAR(1) = 'A',
          @Lc_RelationshipCasePutFather_CODE CHAR(1) = 'P',
          @Lc_DuplicateX_INDC                CHAR(1) = 'X',
          @Lc_HyphenWithSpace_TEXT           CHAR(3) = ' - ',
          @Lc_MajorActivityCase_CODE         CHAR(4) = 'CASE',
          @Lc_StartBreak_TEXT                CHAR(4) = '<BR>',
          @Lc_ErrorAddNotsuccess_TEXT        CHAR(5) = 'E0113',
          @Lc_BatchRunUser_TEXT              CHAR(30) = 'BATCH',
          @Ls_Procedure_NAME                 VARCHAR(100) = 'BATCH_CI_INCOMING_CSENET_FILE$SP_CSENET_INSERT_ALERT',
          @Ld_Low_DATE                       DATE = '01/01/0001',
          @Ld_High_DATE                      DATE = '12/31/9999';
  DECLARE @Ln_MajorIntSeq_NUMB         NUMERIC(5),
          @Ln_MinorIntSeq_NUMB         NUMERIC(5),
          @Ln_MemberMci_IDNO           NUMERIC(10),
          @Ln_Topic_IDNO               NUMERIC(10) = 0,
          @Ln_Value_QNTY               NUMERIC(10) = 0,
          @Ln_TransactionEventSeq_NUMB NUMERIC(19),
          @Li_RowCount_QNTY            INT,
          @Li_Zero_NUMB                SMALLINT = 0,
          @Li_FetchStatus_NUMB         SMALLINT,
          @Lc_Empty_TEXT               CHAR(1) = '',
          @Lc_Msg_CODE                 CHAR(5),
          @Ls_Sql_TEXT                 VARCHAR(100),
          @Ls_DescriptionError_TEXT    VARCHAR(4000),
          @Ls_Sqldata_TEXT             VARCHAR(4000),
          @Ls_CsenetNotes_TEXT         VARCHAR(4000);
  DECLARE @Ln_CnActCur_Case_IDNO              NUMERIC(6) = 0,
          @Ld_CnActCur_Transaction_DATE       DATE,
          @Lc_CnActCur_IVDOutOfStateFips_CODE CHAR(2) = @Lc_Empty_TEXT,
          @Lc_CnActCur_ActivityMinorIn_CODE   CHAR(5) = @Lc_Empty_TEXT,
          @Lc_CnActCur_Function_CODE          CHAR(3) = @Lc_Empty_TEXT,
          @Lc_CnActCur_Action_CODE            CHAR(1) = @Lc_Empty_TEXT,
          @Lc_CnActCur_Reason_CODE            CHAR(5) = @Lc_Empty_TEXT,
          @Ls_CnActCur_DescriptionFar_TEXT    VARCHAR(1000) = @Lc_Empty_TEXT,
          @Lc_CnActCur_Fips_NAME              CHAR(40) = @Lc_Empty_TEXT,
          @Ls_CnActCur_InfoLine1_TEXT         VARCHAR(80) = @Lc_Empty_TEXT,
          @Ls_CnActCur_InfoLine2_TEXT         VARCHAR(80) = @Lc_Empty_TEXT,
          @Ls_CnActCur_InfoLine3_TEXT         VARCHAR(80) = @Lc_Empty_TEXT,
          @Ls_CnActCur_InfoLine4_TEXT         VARCHAR(80) = @Lc_Empty_TEXT,
          @Ls_CnActCur_InfoLine5_TEXT         VARCHAR(80) = @Lc_Empty_TEXT;

  BEGIN TRY
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT';
   SET @Ls_Sqldata_TEXT = 'BatchRunUser_TEXT: ' + @Ac_BatchRunUser_TEXT + ', Job_ID: ' + @Ac_Job_ID + ', Run_DATE: ' + CAST(@Ad_Run_DATE AS VARCHAR) + ', Subsystem_CODE: ' + @Ac_Subsystem_CODE;

   EXECUTE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
    @Ac_Worker_ID                = @Ac_BatchRunUser_TEXT,
    @Ac_Process_ID               = @Ac_Job_ID,
    @Ad_EffectiveEvent_DATE      = @Ad_Run_DATE,
    @Ac_Note_INDC                = 'N',
    @An_EventFunctionalSeq_NUMB  = 0,
    @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
    @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Ac_Msg_CODE != @Lc_StatusSuccess_CODE
    BEGIN
     RAISERROR(50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'CSENET ALERT CURSOR';
   SET @Ls_Sqldata_TEXT = 'BatchRunUser_TEXT: ' + @Ac_BatchRunUser_TEXT + ', Job_ID: ' + @Ac_Job_ID + ', Run_DATE: ' + CAST(@Ad_Run_DATE AS VARCHAR) + ', Subsystem_CODE: ' + @Ac_Subsystem_CODE;

   DECLARE CnAct_CUR INSENSITIVE CURSOR FOR
    SELECT DISTINCT
           CAST((CASE LTRIM(a.Case_IDNO)
                  WHEN ''
                   THEN '0'
                  ELSE a.Case_IDNO
                 END) AS NUMERIC) AS Case_IDNO,
           CONVERT(VARCHAR(8), a.Transaction_DATE, 112) AS Transaction_DATE,
           a.IVDOutOfStateFips_CODE,
           b.ActivityMinorIn_CODE,
           b.Function_CODE,
           b.Action_CODE,
           b.Reason_CODE,
           b.DescriptionFar_TEXT,
           (SELECT s.State_NAME
              FROM STAT_Y1 s
             WHERE s.StateFips_CODE = a.IVDOutOfStateFips_CODE) AS Fips_NAME,
           c.InfoLine1_TEXT,
           c.InfoLine2_TEXT,
           c.InfoLine3_TEXT,
           c.InfoLine4_TEXT,
           c.InfoLine5_TEXT
      FROM LTHBL_Y1 AS a
           LEFT OUTER JOIN LIBLK_Y1 AS c
            ON a.TransHeader_IDNO = c.TransHeader_IDNO
               AND a.IVDOutOfStateFips_CODE = c.IVDOutOfStateFips_CODE
               AND a.Transaction_DATE = c.Transaction_DATE,
           CFAR_Y1 AS b
     WHERE a.RejectReason_CODE = @Lc_Space_TEXT
       AND a.Function_CODE = b.Function_CODE
       AND a.Action_CODE = b.Action_CODE
       AND a.Reason_CODE = b.Reason_CODE
       AND a.Process_INDC <> @Lc_DuplicateX_INDC
       AND b.ActivityMinorIn_CODE <> @Lc_Space_TEXT
       AND EXISTS (SELECT 1
                     FROM CASE_Y1 d
                    WHERE CAST(d.Case_IDNO AS VARCHAR) = a.Case_IDNO
                      AND d.StatusCase_CODE = @Lc_CaseStatusOpen_CODE)
     ORDER BY 2 DESC;

   OPEN CnAct_CUR;

   FETCH NEXT FROM CnAct_CUR INTO @Ln_CnActCur_Case_IDNO, @Ld_CnActCur_Transaction_DATE, @Lc_CnActCur_IVDOutOfStateFips_CODE, @Lc_CnActCur_ActivityMinorIn_CODE, @Lc_CnActCur_Function_CODE, @Lc_CnActCur_Action_CODE, @Lc_CnActCur_Reason_CODE, @Ls_CnActCur_DescriptionFar_TEXT, @Lc_CnActCur_Fips_NAME, @Ls_CnActCur_InfoLine1_TEXT, @Ls_CnActCur_InfoLine2_TEXT, @Ls_CnActCur_InfoLine3_TEXT, @Ls_CnActCur_InfoLine4_TEXT, @Ls_CnActCur_InfoLine5_TEXT;

   SET @Li_FetchStatus_NUMB = @@FETCH_STATUS;

   -- Insert alert for the processed records
   WHILE @Li_FetchStatus_NUMB = 0
    BEGIN
     SET @Ln_Value_QNTY = @Ln_Value_QNTY + 1;
     SET @Ln_MemberMci_IDNO = @Li_Zero_NUMB;
     SET @Ls_Sql_TEXT = 'SELECT CMEM_Y1';
     SET @Ls_Sqldata_TEXT = 'BatchRunUser_TEXT: ' + @Ac_BatchRunUser_TEXT + ', Job_ID: ' + @Ac_Job_ID + ', Run_DATE: ' + CAST(@Ad_Run_DATE AS VARCHAR) + ', Subsystem_CODE: ' + @Ac_Subsystem_CODE;

     SELECT TOP 1 @Ln_MemberMci_IDNO = a.MemberMci_IDNO
       FROM CMEM_Y1 a
      WHERE a.Case_IDNO = @Ln_CnActCur_Case_IDNO
        AND a.CaseRelationship_CODE IN (@Lc_RelationshipCaseNcp_CODE, @Lc_RelationshipCasePutFather_CODE)
        AND a.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE
      ORDER BY a.CaseRelationship_CODE DESC;

     IF @Ln_MemberMci_IDNO = @Li_Zero_NUMB
      BEGIN
       SET @Ls_Sql_TEXT = 'NCP/PF - MEMBER Seq_IDNO NOT FOUND' + ISNULL(@Ls_Sql_TEXT, @Lc_Empty_TEXT);

       EXECUTE BATCH_COMMON$SP_BATE_LOG
        @As_Process_NAME             = 'BATCH_CI_INCOMING_CSENET_FILE',
        @As_Procedure_NAME           = 'BATCH_CI_INCOMING_CSENET_FILE$SP_CSENET_INSERT_ALERT',
        @Ac_Job_ID                   = @Ac_Job_ID,
        @Ad_Run_DATE                 = @Ad_Run_DATE,
        @Ac_TypeError_CODE           = @Lc_ErrorTypeInformation_CODE,
        @An_Line_NUMB                = @Ln_Value_QNTY,
        @Ac_Error_CODE               = @Lc_ErrorAddNotsuccess_TEXT,
        @As_DescriptionError_TEXT    = @Ls_Sql_TEXT,
        @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
        @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         RAISERROR(50001,16,1);
        END;
      END;
     ELSE IF NOT EXISTS (SELECT 1
                      FROM DMNR_Y1
                     WHERE Case_IDNO = @Ln_CnActCur_Case_IDNO
                       AND MemberMci_IDNO = @Ln_MemberMci_IDNO
                       AND ActivityMajor_CODE = @Lc_MajorActivityCase_CODE
                       AND ActivityMinor_CODE = @Lc_CnActCur_ActivityMinorIn_CODE
                       AND TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB)
      BEGIN
       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_ACTIVITY';
       SET @Ls_Sqldata_TEXT = 'BatchRunUser_TEXT: ' + @Ac_BatchRunUser_TEXT + ', Job_ID: ' + @Ac_Job_ID + ', Run_DATE: ' + CAST(@Ad_Run_DATE AS VARCHAR) + ', Subsystem_CODE: ' + @Ac_Subsystem_CODE;

       EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
        @An_Case_IDNO                = @Ln_CnActCur_Case_IDNO,
        @An_MemberMci_IDNO           = @Ln_MemberMci_IDNO,
        @Ac_ActivityMajor_CODE       = @Lc_MajorActivityCase_CODE,
        @Ac_ActivityMinor_CODE       = @Lc_CnActCur_ActivityMinorIn_CODE,
        @Ac_Subsystem_CODE           = @Ac_Subsystem_CODE,
        @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
        @Ac_WorkerUpdate_ID          = @Lc_BatchRunUser_TEXT,
        @Ad_Run_DATE                 = @Ad_Run_DATE,
        @Ac_Job_ID                   = @Ac_Job_ID,
        @An_Topic_IDNO               = @Ln_Topic_IDNO OUTPUT,
        @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

       IF (@Lc_Msg_CODE <> @Lc_StatusSuccess_CODE)
        BEGIN
         SET @Ls_Sql_TEXT = 'INSERT ACTIVITY FAILED. ';
         SET @Ls_DescriptionError_TEXT = @Ls_Sql_TEXT + ISNULL(@Ls_DescriptionError_TEXT, @Lc_Empty_TEXT);

         EXECUTE BATCH_COMMON$SP_BATE_LOG
          @As_Process_NAME             = 'BATCH_CI_INCOMING_CSENET_FILE',
          @As_Procedure_NAME           = @Ls_Procedure_NAME,
          @Ac_Job_ID                   = @Ac_Job_ID,
          @Ad_Run_DATE                 = @Ad_Run_DATE,
          @Ac_TypeError_CODE           = @Lc_ErrorTypeInformation_CODE,
          @An_Line_NUMB                = @Ln_Value_QNTY,
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
       ELSE
        BEGIN
         SET @Ls_Sql_TEXT = 'INSERT ACTIVITY';
         SET @Ls_Sqldata_TEXT = 'Case_IDNO: ' + CAST(@Ln_CnActCur_Case_IDNO AS VARCHAR) + ', Topic_IDNO: ' + CAST(@Ln_Topic_IDNO AS VARCHAR);

         SELECT @Ln_MajorIntSeq_NUMB = a.MajorIntSEQ_NUMB,
                @Ln_MinorIntSeq_NUMB = a.MinorIntSeq_NUMB
           FROM DMNR_Y1 a
          WHERE a.Case_IDNO = @Ln_CnActCur_Case_IDNO
            AND a.Topic_IDNO = @Ln_Topic_IDNO;

         SET @Ls_CsenetNotes_TEXT = @Lc_StartBreak_TEXT + ' Request Received FROM: ' + ISNULL(@Lc_CnActCur_IVDOutOfStateFips_CODE, @Lc_Empty_TEXT) + ISNULL(@Lc_HyphenWithSpace_TEXT, @Lc_Empty_TEXT) + ISNULL(@Lc_CnActCur_Fips_NAME, @Lc_Empty_TEXT) + @Lc_StartBreak_TEXT + ' DATE Requested: ' + ISNULL(CAST(@Ld_CnActCur_Transaction_DATE AS VARCHAR), @Lc_Empty_TEXT) + @Lc_StartBreak_TEXT + ' Requested Details: ' + ' Function - ' + ISNULL(@Lc_CnActCur_Function_CODE, @Lc_Empty_TEXT) + ';   ' + ' Action_TEXT - ' + ISNULL(@Lc_CnActCur_Action_CODE, @Lc_Empty_TEXT) + ';   ' + ' Reason - ' + ISNULL (@Lc_CnActCur_Reason_CODE, @Lc_Empty_TEXT) + ';   ' + '(' + ISNULL (@Ls_CnActCur_DescriptionFar_TEXT, @Lc_Empty_TEXT) + ')' + @Lc_StartBreak_TEXT + ' Miscellaneous Details: ';

         IF LTRIM(@Ls_CnActCur_InfoLine1_TEXT) <> @Lc_Empty_TEXT
          BEGIN
           SET @Ls_CsenetNotes_TEXT = @Ls_CsenetNotes_TEXT + @Lc_StartBreak_TEXT + @Ls_CnActCur_InfoLine1_TEXT;
          END;

         IF LTRIM(@Ls_CnActCur_InfoLine2_TEXT) <> @Lc_Empty_TEXT
          BEGIN
           SET @Ls_CsenetNotes_TEXT = @Ls_CsenetNotes_TEXT + @Lc_StartBreak_TEXT + @Ls_CnActCur_InfoLine2_TEXT;
          END;

         IF LTRIM(@Ls_CnActCur_InfoLine3_TEXT) <> @Lc_Empty_TEXT
          BEGIN
           SET @Ls_CsenetNotes_TEXT = @Ls_CsenetNotes_TEXT + @Lc_StartBreak_TEXT + @Ls_CnActCur_InfoLine3_TEXT;
          END;

         IF LTRIM(@Ls_CnActCur_InfoLine4_TEXT) <> @Lc_Empty_TEXT
          BEGIN
           SET @Ls_CsenetNotes_TEXT = @Ls_CsenetNotes_TEXT + @Lc_StartBreak_TEXT + @Ls_CnActCur_InfoLine4_TEXT;
          END;

         IF LTRIM(@Ls_CnActCur_InfoLine5_TEXT) <> @Lc_Empty_TEXT
          BEGIN
           SET @Ls_CsenetNotes_TEXT = @Ls_CsenetNotes_TEXT + @Lc_StartBreak_TEXT + @Ls_CnActCur_InfoLine5_TEXT;
          END;

         SET @Ls_Sql_TEXT = 'INSERT NOTE_Y1';
         SET @Ls_Sqldata_TEXT = @Lc_StartBreak_TEXT + ' Request Received FROM: ' + ISNULL(@Lc_CnActCur_IVDOutOfStateFips_CODE, @Lc_Empty_TEXT) + ISNULL(@Lc_HyphenWithSpace_TEXT, @Lc_Empty_TEXT) + ISNULL(@Lc_CnActCur_Fips_NAME, @Lc_Empty_TEXT) + @Lc_StartBreak_TEXT + ' DATE Requested: ' + ISNULL(CAST(@Ld_CnActCur_Transaction_DATE AS VARCHAR), @Lc_Empty_TEXT) + @Lc_StartBreak_TEXT + ' Requested Details: ' + ' Function - ' + ISNULL(@Lc_CnActCur_Function_CODE, @Lc_Empty_TEXT) + ';   ' + ' Action_TEXT - ' + ISNULL(@Lc_CnActCur_Action_CODE, @Lc_Empty_TEXT) + ';   ' + ' Reason - ' + ISNULL (@Lc_CnActCur_Reason_CODE, @Lc_Empty_TEXT) + ';   ' + '(' + ISNULL (@Ls_CnActCur_DescriptionFar_TEXT, @Lc_Empty_TEXT) + ')' + @Lc_StartBreak_TEXT + ' Miscellaneous Details: ';

         IF (@Ln_Topic_IDNO IS NOT NULL)
          BEGIN
           INSERT NOTE_Y1
                  (Case_IDNO,
                   Topic_IDNO,
                   Post_IDNO,
                   MajorIntSEQ_NUMB,
                   MinorIntSeq_NUMB,
                   Office_IDNO,
                   Category_CODE,
                   Subject_CODE,
                   CallBack_INDC,
                   NotifySender_INDC,
                   TypeContact_CODE,
                   SourceContact_CODE,
                   MethodContact_CODE,
                   Status_CODE,
                   TypeAssigned_CODE,
                   WorkerAssigned_ID,
                   RoleAssigned_ID,
                   WorkerCreated_ID,
                   Start_DATE,
                   Due_DATE,
                   Action_DATE,
                   Received_DATE,
                   OpenCases_CODE,
                   DescriptionNote_TEXT,
                   BeginValidity_DATE,
                   EndValidity_DATE,
                   WorkerUpdate_ID,
                   TransactionEventSeq_NUMB,
                   EventGlobalSeq_NUMB,
                   Update_DTTM,
                   TotalReplies_QNTY,
                   TotalViews_QNTY)
           VALUES ( @Ln_CnActCur_Case_IDNO,
                    @Ln_Topic_IDNO,
                    1,
                    @Ln_MajorIntSeq_NUMB,
                    @Ln_MinorIntSeq_NUMB,
                    @Li_Zero_NUMB,
                    @Lc_Space_TEXT,
                    @Lc_CnActCur_ActivityMinorIn_CODE,
                    @Lc_Space_TEXT,
                    @Lc_No_INDC,
                    @Lc_Space_TEXT,
                    @Lc_Space_TEXT,
                    @Lc_Space_TEXT,
                    @Lc_Space_TEXT,
                    @Lc_Space_TEXT,
                    @Lc_Space_TEXT,
                    @Lc_Space_TEXT,
                    @Lc_BatchRunUser_TEXT,
                    @Ld_Low_DATE,
                    @Ld_Low_DATE,
                    @Ld_High_DATE,
                    @Ld_High_DATE,
                    @Lc_Space_TEXT,
                    @Ls_CsenetNotes_TEXT,
                    @Ad_Run_DATE,
                    @Ld_High_DATE,
                    @Lc_BatchRunUser_TEXT,
                    @Ln_TransactionEventSeq_NUMB,
                    @Li_Zero_NUMB,
                    dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
                    @Li_Zero_NUMB,
                    @Li_Zero_NUMB);

           SET @Li_RowCount_QNTY = @@ROWCOUNT;

           IF @Li_RowCount_QNTY = 0
            BEGIN
             SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
             SET @As_DescriptionError_TEXT = @Ls_Procedure_NAME + @Lc_Space_TEXT + ISNULL(@Ls_Sql_TEXT, @Lc_Empty_TEXT) + @Lc_Space_TEXT + 'NOTE_Y1 INSERT FAILED' + @Lc_Space_TEXT + ISNULL(@Ls_Sqldata_TEXT, @Lc_Empty_TEXT);

             RAISERROR(50001,16,1);
            END;
          END;
        END;
      END;

     FETCH NEXT FROM CnAct_CUR INTO @Ln_CnActCur_Case_IDNO, @Ld_CnActCur_Transaction_DATE, @Lc_CnActCur_IVDOutOfStateFips_CODE, @Lc_CnActCur_ActivityMinorIn_CODE, @Lc_CnActCur_Function_CODE, @Lc_CnActCur_Action_CODE, @Lc_CnActCur_Reason_CODE, @Ls_CnActCur_DescriptionFar_TEXT, @Lc_CnActCur_Fips_NAME, @Ls_CnActCur_InfoLine1_TEXT, @Ls_CnActCur_InfoLine2_TEXT, @Ls_CnActCur_InfoLine3_TEXT, @Ls_CnActCur_InfoLine4_TEXT, @Ls_CnActCur_InfoLine5_TEXT;

     SET @Li_FetchStatus_NUMB = @@FETCH_STATUS;
    END;

   IF CURSOR_STATUS('LOCAL', 'CnAct_CUR') IN (0, 1)
    BEGIN
     CLOSE CnAct_CUR;

     DEALLOCATE CnAct_CUR;
    END;

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

   IF CURSOR_STATUS('LOCAL', 'CnAct_CUR') IN (0, 1)
    BEGIN
     CLOSE CnAct_CUR;

     DEALLOCATE CnAct_CUR;
    END;

   DECLARE @Li_Error_NUMB     INT = ERROR_NUMBER (),
           @Li_ErrorLine_NUMB INT = ERROR_LINE ();

   IF (@Li_Error_NUMB <> 50001)
    BEGIN
     SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
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
