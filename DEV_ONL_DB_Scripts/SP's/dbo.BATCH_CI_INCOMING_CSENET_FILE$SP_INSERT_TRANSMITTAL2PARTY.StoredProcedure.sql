/****** Object:  StoredProcedure [dbo].[BATCH_CI_INCOMING_CSENET_FILE$SP_INSERT_TRANSMITTAL2PARTY]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_CI_INCOMING_CSENET_FILE$SP_INSERT_TRANSMITTAL2PARTY
Programmer Name	:	IMP Team.
Description		:	This procedure is used to insert the transmittal2 to the party.
Frequency		:	DAILY
Developed On	:	04/04/2011
Called By		:	BATCH_CI_INCOMING_CSENET_FILE$SP_PROCESS_CSENET
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_CI_INCOMING_CSENET_FILE$SP_INSERT_TRANSMITTAL2PARTY] (
 @Ac_JobProcess_IDNO       CHAR(7),
 @Ad_Run_DATE              DATE,
 @Ac_BatchRunUser_TEXT     CHAR(30),
 @Ac_Subsystem_CODE        CHAR(3),
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusSuccess_CODE             CHAR(1) = 'S',
          @Lc_Yes_INDC                       CHAR(1) = 'Y',
          @Lc_CaseStatusOpen_CODE            CHAR(1) = 'O',
          @Lc_StatusCaseMemberActive_CODE    CHAR(1) = 'A',
          @Lc_RelationshipCaseNcp_INDC       CHAR(1) = 'A',
          @Lc_RelationshipCasePutFather_INDC CHAR(1) = 'P',
          @Lc_RelationshipCaseCp_INDC        CHAR(1) = 'C',
          @Lc_ErrorTypeInformation_CODE      CHAR(1) = 'I',
          @Lc_StatusFailed_CODE              CHAR(1) = 'F',
          @Lc_InitiateState_CODE             CHAR(1) = 'I',
          @Lc_InitiateInternational_CODE     CHAR(1) = 'C',
          @Lc_InitiateTribal_CODE            CHAR(1) = 'T',
          @Lc_RespondingState_CODE           CHAR(1) = 'R',
          @Lc_RespondingInternational_CODE   CHAR(1) = 'Y',
          @Lc_RespondingTribal_CODE          CHAR(1) = 'S',
          @Lc_MajorActivityCase_CODE         CHAR(4) = 'CASE',
          @Lc_ErrorAddNotsuccess_TEXT        CHAR(5) = 'E0113',
          @Lc_MinorActivity_CODE             CHAR(5) = 'CSNET',
          @Ls_Procedure_NAME                 VARCHAR(100) = 'BATCH_CI_INCOMING_CSENET_FILE$SP_INSERT_TRANSMITTAL2PARTY';
  DECLARE @Ln_MemberMci_IDNO           NUMERIC(10),
          @Ln_Topic_IDNO               NUMERIC(10) = 0,
          @Ln_Value_QNTY               NUMERIC(10) = 0,
          @Ln_TransHeader_IDNO         NUMERIC(12),
          @Ln_TransactionEventSeq_NUMB NUMERIC(19),
          @Li_Error_NUMB               INT,
          @Li_ErrorLine_NUMB           INT,
          @Li_FetchStatus_NUMB         SMALLINT,
          @Lc_Msg_CODE                 CHAR(5),
          @Lc_Fips_CODE                CHAR(7),
          @Lc_Notice_ID                CHAR(8) = '',
          @Ls_Sql_TEXT                 VARCHAR(100),
          @Ls_DescriptionError_TEXT    VARCHAR(4000),
          @Ls_Sqldata_TEXT             VARCHAR(4000);
  DECLARE @Ln_ActivityCur_Case_IDNO                    NUMERIC(6),
          @Ln_ActivityCur_TransHeader_IDNO             NUMERIC(12),
          @Ld_ActivityCur_Transaction_DATE             DATE,
          @Lc_ActivityCur_IVDOutOfStateFips_CODE       CHAR(2),
          @Lc_ActivityCur_IVDOutOfStateCountyFips_CODE CHAR(3),
          @Lc_ActivityCur_IVDOutOfStateOfficeFips_CODE CHAR(2),
          @Lc_ActivityCur_Function_CODE                CHAR(3),
          @Lc_ActivityCur_Action_CODE                  CHAR(1),
          @Lc_ActivityCur_Reason_CODE                  CHAR(5);

  BEGIN TRY
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT';
   SET @Ls_Sqldata_TEXT = 'JobProcess_IDNO: ' + @Ac_JobProcess_IDNO + ', Run_DATE: ' + CAST(@Ad_Run_DATE AS VARCHAR) + ', Subsystem_CODE: ' + @Ac_Subsystem_CODE;

   EXECUTE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
    @Ac_Worker_ID                = @Ac_BatchRunUser_TEXT,
    @Ac_Process_ID               = @Ac_JobProcess_IDNO,
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

   SET @Ls_Sql_TEXT = 'ACTIVITY CURSOR';
   SET @Ls_Sqldata_TEXT = 'JobProcess_IDNO: ' + @Ac_JobProcess_IDNO + ', Run_DATE: ' + CAST(@Ad_Run_DATE AS VARCHAR) + ', Subsystem_CODE: ' + @Ac_Subsystem_CODE;

   DECLARE Activity_CUR INSENSITIVE CURSOR FOR
    SELECT CAST((CASE LTRIM(a.Case_IDNO)
                  WHEN ''
                   THEN '0'
                  ELSE a.Case_IDNO
                 END) AS NUMERIC) AS Case_IDNO,
           a.TransHeader_IDNO,
           CONVERT(DATE, a.Transaction_DATE, 112) AS Transaction_DATE,
           a.IVDOutOfStateFips_CODE,
           a.IVDOutOfStateCountyFips_CODE,
           a.IVDOutOfStateOfficeFips_CODE,
           a.Function_CODE,
           a.Action_CODE,
           a.Reason_CODE
      FROM LTHBL_Y1 AS a
     WHERE a.Process_INDC = @Lc_Yes_INDC
       AND LTRIM(a.RejectReason_CODE) = ''
       AND ((a.Function_CODE = 'ENF'
             AND a.Action_CODE = 'P'
             AND a.Reason_CODE = 'GIHER')
             OR (a.Function_CODE = 'MSC'
                 AND a.Action_CODE = 'P'
                 AND a.Reason_CODE = 'GIHER')
             OR (a.Function_CODE = 'EST'
                 AND a.Action_CODE = 'P'
                 AND a.Reason_CODE = 'SICHS')
             OR (a.Function_CODE = 'PAT'
                 AND a.Action_CODE = 'P'
                 AND a.Reason_CODE = 'PICHS')
             OR (a.Function_CODE = 'EST'
                 AND a.Action_CODE = 'R'
                 AND a.Reason_CODE = 'SRADJ')
             OR (a.Function_CODE = 'EST'
                 AND a.Action_CODE = 'R'
                 AND a.Reason_CODE = 'SRMOD'));

   OPEN Activity_CUR;

   FETCH NEXT FROM Activity_CUR INTO @Ln_ActivityCur_Case_IDNO, @Ln_ActivityCur_TransHeader_IDNO, @Ld_ActivityCur_Transaction_DATE, @Lc_ActivityCur_IVDOutOfStateFips_CODE, @Lc_ActivityCur_IVDOutOfStateCountyFips_CODE, @Lc_ActivityCur_IVDOutOfStateOfficeFips_CODE, @Lc_ActivityCur_Function_CODE, @Lc_ActivityCur_Action_CODE, @Lc_ActivityCur_Reason_CODE;

   SET @Li_FetchStatus_NUMB = @@FETCH_STATUS;

   -- Insert activity for Hearing schedules and adjustment/modification
   WHILE @Li_FetchStatus_NUMB = 0
    BEGIN
     SET @Ln_Value_QNTY = @Ln_Value_QNTY + 1;
     SET @Ls_Sql_TEXT = 'SELECT CFAR_Y1';
     SET @Ls_Sqldata_TEXT = 'Function_CODE: ' + @Lc_ActivityCur_Function_CODE + ', Action_CODE: ' + @Lc_ActivityCur_Action_CODE + ', Reason_CODE: ' + @Lc_ActivityCur_Reason_CODE;

     SELECT @Lc_MinorActivity_CODE = a.ActivityMinorIn_CODE
       FROM CFAR_Y1 a
      WHERE a.Function_CODE = @Lc_ActivityCur_Function_CODE
        AND a.Action_CODE = @Lc_ActivityCur_Action_CODE
        AND a.Reason_CODE = @Lc_ActivityCur_Reason_CODE;

     SET @Ln_MemberMci_IDNO = 0;

     IF @Lc_ActivityCur_Reason_CODE = 'GIHER'
         OR @Lc_ActivityCur_Reason_CODE = 'SICHS'
         OR @Lc_ActivityCur_Reason_CODE = 'PICHS'
      BEGIN
       SET @Lc_Notice_ID = 'INT-11';
      END
     ELSE IF @Lc_ActivityCur_Reason_CODE = 'SRADJ'
         OR @Lc_ActivityCur_Reason_CODE = 'SRMOD'
      BEGIN
       SET @Lc_Notice_ID = 'INT-12';
      END;

     SET @Ls_Sql_TEXT = 'SELECT CMEM_Y1, CASE_Y1';
     SET @Ls_Sqldata_TEXT = 'TransHeader_IDNO ' + CAST(@Ln_ActivityCur_TransHeader_IDNO AS VARCHAR) + ' Transaction_DATE ' + ISNULL(CONVERT(VARCHAR(20), @Ld_ActivityCur_Transaction_DATE, 101), '') + ' IVDOutOfStateFips_CODE ' + ISNULL(@Lc_ActivityCur_IVDOutOfStateFips_CODE, '') + 'Case_IDNO ' + CAST(@Ln_ActivityCur_Case_IDNO AS VARCHAR) + ' ActivityMinorIn_CODE  ' + @Lc_MinorActivity_CODE;

     SELECT TOP 1 @Ln_MemberMci_IDNO = a.MemberMci_IDNO
       FROM CMEM_Y1 AS a,
            CASE_Y1 AS b
      WHERE a.Case_IDNO = @Ln_ActivityCur_Case_IDNO
        AND b.Case_IDNO = a.Case_IDNO
        AND a.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE
        AND ((b.RespondInit_CODE IN (@Lc_RespondingState_CODE, @Lc_RespondingInternational_CODE, @Lc_RespondingTribal_CODE)
              AND a.CaseRelationship_CODE IN (@Lc_RelationshipCaseNcp_INDC, @Lc_RelationshipCasePutFather_INDC))
              OR (b.RespondInit_CODE IN (@Lc_InitiateState_CODE, @Lc_InitiateInternational_CODE, @Lc_InitiateTribal_CODE)
                  AND a.CaseRelationship_CODE IN (@Lc_RelationshipCaseCp_INDC)))
      ORDER BY a.CaseRelationship_CODE DESC;

     IF @Ln_MemberMci_IDNO = 0
      BEGIN
       SET @Ls_Sql_TEXT = 'NCP/PF - MEMBER Seq_IDNO NOT FOUND' + ISNULL(@Ls_Sql_TEXT, '');

       EXECUTE BATCH_COMMON$SP_BATE_LOG
        @As_Process_NAME             = 'BATCH_CI_INCOMING_CSENET_FILE',
        @As_Procedure_NAME           = 'SP_INSERT_TRANSMITTAL2PARTY',
        @Ac_Job_ID                   = @Ac_JobProcess_IDNO,
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
     ELSE
      BEGIN
       SET @Lc_Fips_CODE = @Lc_ActivityCur_IVDOutOfStateFips_CODE + @Lc_ActivityCur_IVDOutOfStateCountyFips_CODE + @Lc_ActivityCur_IVDOutOfStateOfficeFips_CODE;
       SET @Ls_Sql_TEXT = 'SELECT TRANSHEADER_IDNO FROM CTHB_Y1';
       SET @Ls_Sqldata_TEXT = 'CsenetTran_ID: ' + CAST(@Ln_ActivityCur_TransHeader_IDNO AS VARCHAR);

       SELECT TOP 1 @Ln_TransHeader_IDNO = a.TransHeader_IDNO
         FROM CTHB_Y1 a
        WHERE a.CsenetTran_ID LIKE ('%' + CAST(@Ln_ActivityCur_TransHeader_IDNO AS VARCHAR));

       SET @Ls_Sql_TEXT = ' BATCH_COMMON$SP_INSERT_ACTIVITY ';
       SET @Ls_Sqldata_TEXT = 'Case_IDNO: ' + CAST(@Ln_ActivityCur_Case_IDNO AS VARCHAR) + ', MemberMci_IDNO: ' + CAST(@Ln_MemberMci_IDNO AS VARCHAR) + ', MajorActivityCase_CODE: ' + @Lc_MajorActivityCase_CODE + ', MinorActivity_CODE: ' + @Lc_MinorActivity_CODE + ', Subsystem_CODE: ' + @Ac_Subsystem_CODE + ', TransactionEventSeq_NUMB: ' + CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR) + ', Run_DATE: ' + CAST(@Ad_Run_DATE AS VARCHAR) + ', Notice_ID: ' + @Lc_Notice_ID + ', OthpSource_IDNO: ' + CAST(@Ln_MemberMci_IDNO AS VARCHAR) + ', Fips_CODE: ' + @Lc_Fips_CODE + ', TransHeader_IDNO: ' + CAST(@Ln_TransHeader_IDNO AS VARCHAR);

       EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
        @An_Case_IDNO                = @Ln_ActivityCur_Case_IDNO,
        @An_MemberMci_IDNO           = @Ln_MemberMci_IDNO,
        @Ac_ActivityMajor_CODE       = @Lc_MajorActivityCase_CODE,
        @Ac_ActivityMinor_CODE       = @Lc_MinorActivity_CODE,
        @Ac_Subsystem_CODE           = @Ac_Subsystem_CODE,
        @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
        @Ac_WorkerUpdate_ID          = @Ac_BatchRunUser_TEXT,
        @Ad_Run_DATE                 = @Ad_Run_DATE,
        @Ac_Notice_ID                = @Lc_Notice_ID,
        @An_TopicIn_IDNO             = 0,
        @Ac_Job_ID                   = @Ac_JobProcess_IDNO,
        @An_OthpSource_IDNO          = @Ln_MemberMci_IDNO,
        @Ac_IVDOutOfStateFips_CODE   = @Lc_Fips_CODE,
        @An_TransHeader_IDNO         = @Ln_TransHeader_IDNO,
        @An_Topic_IDNO               = @Ln_Topic_IDNO OUTPUT,
        @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

       IF (@Lc_Msg_CODE <> @Lc_StatusSuccess_CODE)
        BEGIN
         SET @Ls_DescriptionError_TEXT = 'Error IN ' + @Ls_Procedure_NAME + ' PROCEDURE' + '. Error DESC - ' + @Ls_DescriptionError_TEXT + '. Error EXECUTE Location - ' + @Ls_Sql_TEXT + '. Error List KEY - ' + @Ls_Sqldata_TEXT;

         EXECUTE BATCH_COMMON$SP_BATE_LOG
          @As_Process_NAME             = 'BATCH_CI_INCOMING_CSENET_FILE',
          @As_Procedure_NAME           = @Ls_Procedure_NAME,
          @Ac_Job_ID                   = @Ac_JobProcess_IDNO,
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
      END;

     FETCH NEXT FROM Activity_CUR INTO @Ln_ActivityCur_Case_IDNO, @Ln_ActivityCur_TransHeader_IDNO, @Ld_ActivityCur_Transaction_DATE, @Lc_ActivityCur_IVDOutOfStateFips_CODE, @Lc_ActivityCur_IVDOutOfStateCountyFips_CODE, @Lc_ActivityCur_IVDOutOfStateOfficeFips_CODE, @Lc_ActivityCur_Function_CODE, @Lc_ActivityCur_Action_CODE, @Lc_ActivityCur_Reason_CODE;

     SET @Li_FetchStatus_NUMB = @@FETCH_STATUS;
    END;

   IF CURSOR_STATUS('LOCAL', 'Activity_CUR') IN (0, 1)
    BEGIN
     CLOSE Activity_CUR;

     DEALLOCATE Activity_CUR;
    END;

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   IF CURSOR_STATUS('LOCAL', 'Activity_CUR') IN (0, 1)
    BEGIN
     CLOSE Activity_CUR;

     DEALLOCATE Activity_CUR;
    END;

   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   SET @Li_Error_NUMB = ERROR_NUMBER ();
   SET @Li_ErrorLine_NUMB = ERROR_LINE ();

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
