/****** Object:  StoredProcedure [dbo].[BATCH_CM_MERG$SP_MEMBER_MERGE]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_CM_MERG$SP_MEMBER_MERGE
Programmer Name	:	IMP Team.
Description		:	This procedure is used to merge duplicate members together.
Frequency		:	DAILY
Developed On	:	5/3/2012
Called By		:	BATCH_CM_MERG$SP_PROCESS_MEMBER_MERGE
Called On		:	BATCH_COMMON$SP_NOTE_INSERT
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_CM_MERG$SP_MEMBER_MERGE] (
 @An_MemberMciSecondary_IDNO  NUMERIC(10),
 @An_MemberMciPrimary_IDNO    NUMERIC(10),
 @An_Cursor_QNTY              NUMERIC(11),
 @Ad_Run_DATE                 DATE,
 @An_TransactionEventSeq_NUMB NUMERIC(19),
 @Ac_Msg_CODE                 VARCHAR(5) OUTPUT,
 @As_DescriptionError_TEXT    VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  DECLARE @Lc_CaseMemberStatusActive_CODE	CHAR(1)		= 'A',
          @Lc_StatusFailed_CODE				CHAR(1)		= 'F',
          @Lc_StatusSuccess_CODE			CHAR(1)		= 'S',
          @Lc_StatusCaseOpen_CODE			CHAR(1)		= 'O',
          @Lc_SubsystemCm_CODE				CHAR(2)		= 'CM',
          @Lc_ActivityMajorCase_CODE		CHAR(4)		= 'CASE',
          @Lc_ActivityMinorMmerg_CODE		CHAR(5)		= 'MMERG',
          @Lc_BatchRunUser_TEXT				CHAR(5)		= 'BATCH',
          @Lc_Job_ID						CHAR(7)		= 'DEB1030',
          @Ls_Procedure_NAME				CHAR(30)	= 'BATCH_CM_MERG$SP_MEMBER_MERGE';
  DECLARE @Ls_FetchStatus_BIT				SMALLINT,
          @Ln_Topic_IDNO					NUMERIC(10),
          @Ln_MemberMciPrimary_IDNO			NUMERIC(10),
          @Ln_MemberMciSecondary_IDNO		NUMERIC(10),
          @Ln_Error_NUMB					NUMERIC(11),
          @Ln_ErrorLine_NUMB				NUMERIC(11),
          @Lc_Msg_CODE						CHAR(5),
          @Lc_MemberMciPrimary_ID			CHAR(10),
          @Lc_MemberMciSecondary_ID			CHAR(10),
          @Lc_WorkerCase_ID					CHAR(30),
          @Ls_Sql_TEXT						VARCHAR(400)	= '',
          @Ls_DescriptionNotes_TEXT			VARCHAR(4000),
          @Ls_Sqldata_TEXT					VARCHAR(4000),
          @Ls_DescriptionError_TEXT			VARCHAR(4000)	= '';
  DECLARE @MemberMerg_CUR CURSOR,
          @i$Case_IDNO    NUMERIC(6);
  
  BEGIN TRY
  
   -- 13588 - Case journal entry not inserting for the secondary case - Start
   CREATE TABLE #CaseList_P1
   (
     Case_IDNO			NUMERIC(6)
   );
   
   -- Inserting case id into temp table
   INSERT INTO #CaseList_P1
               (CASE_IDNO)
   SELECT DISTINCT m.Case_IDNO
     FROM CMEM_Y1 m
    WHERE m.MemberMci_IDNO = @An_MemberMciSecondary_IDNO
      AND m.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
      AND EXISTS (SELECT 1
					FROM CASE_Y1 c
				   WHERE c.Case_IDNO = m.Case_IDNO
				     AND c.StatusCase_CODE = @Lc_StatusCaseOpen_CODE);
	-- 13588 - Case journal entry not inserting for the secondary case - End

   SET @Ac_Msg_CODE = '';
   SET @As_DescriptionError_TEXT = '';
   SET @Ls_Sql_TEXT = 'BATCH_CM_MERG$SP_MEMBER_MERGE';
   SET @Ln_MemberMciPrimary_IDNO = @An_MemberMciPrimary_IDNO;
   SET @Ln_MemberMciSecondary_IDNO = @An_MemberMciSecondary_IDNO;
   SET @Lc_MemberMciPrimary_ID = CAST (@Ln_MemberMciPrimary_IDNO AS CHAR(10));
   SET @Lc_MemberMciSecondary_ID = CAST (@Ln_MemberMciSecondary_IDNO AS CHAR(10));
   
   SET @Ls_Sql_TEXT = 'BATCH_CM_MERG$SP_MEMBER_CASEMANAGEMENT_MERGE';
   SET @Ls_Sqldata_TEXT = 'MemberMciPrimary_IDNO = ' + @Lc_MemberMciPrimary_ID + ', MemberMciSecondary_IDNO = ' + @Lc_MemberMciSecondary_ID + ', Cursor_QNTY = ' + ISNULL(CAST(@An_Cursor_QNTY AS CHAR(11)), '') + ', Run_DATE = ' + CAST(@Ad_Run_DATE AS CHAR(10)) + ', TransactionEventSeq_NUMB = ' + CAST(@An_TransactionEventSeq_NUMB AS CHAR(19));

   --- Merge CaseManagement table
   EXEC BATCH_CM_MERG$SP_MEMBER_CASEMANAGEMENT_MERGE
    @An_MemberMciSecondary_IDNO  = @Ln_MemberMciSecondary_IDNO,
    @An_MemberMciPrimary_IDNO    = @Ln_MemberMciPrimary_IDNO,
    @An_Cursor_QNTY              = @An_Cursor_QNTY,
    @Ad_Run_DATE                 = @Ad_Run_DATE,
    @An_TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB,
    @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE != @Lc_StatusSuccess_CODE
    BEGIN
     SET @Ls_DescriptionError_TEXT = 'BATCH_CM_MERG$SP_MEMBER_CASEMANAGEMENT_MERGE FAILED : '+ISNULL(@Ls_DescriptionError_TEXT,'');
     RAISERROR(50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'BATCH_CM_MERG$SP_MEMBER_ESTABLISHMENT_MERGE';
   
   --- Merge Establishment table
   EXEC BATCH_CM_MERG$SP_MEMBER_ESTABLISHMENT_MERGE
    @An_MemberMciSecondary_IDNO  = @Ln_MemberMciSecondary_IDNO,
    @An_MemberMciPrimary_IDNO    = @Ln_MemberMciPrimary_IDNO,
    @An_Cursor_QNTY              = @An_Cursor_QNTY,
    @Ad_Run_DATE                 = @Ad_Run_DATE,
    @An_TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB,
    @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE != @Lc_StatusSuccess_CODE
    BEGIN
     SET @Ls_DescriptionError_TEXT = 'BATCH_CM_MERG$SP_MEMBER_ESTABLISHMENT_MERGE FAILED : '+ISNULL(@Ls_DescriptionError_TEXT,'');
     RAISERROR(50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'BATCH_CM_MERG$SP_MEMBER_ENFORCEMENT_MERGE';
   
   --- Merge Enforcement table
   EXEC BATCH_CM_MERG$SP_MEMBER_ENFORCEMENT_MERGE
    @An_MemberMciSecondary_IDNO  = @Ln_MemberMciSecondary_IDNO,
    @An_MemberMciPrimary_IDNO    = @Ln_MemberMciPrimary_IDNO,
    @An_Cursor_QNTY              = @An_Cursor_QNTY,
    @Ad_Run_DATE                 = @Ad_Run_DATE,
    @An_TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB,
    @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE != @Lc_StatusSuccess_CODE
    BEGIN
     SET @Ls_DescriptionError_TEXT = 'BATCH_CM_MERG$SP_MEMBER_ENFORCEMENT_MERGE FAILED : '+ISNULL(@Ls_DescriptionError_TEXT,'');
     RAISERROR(50001,16,1);
    END

   -- 13588 - Case journal entry not inserting for the secondary case - Start
   -- Defining the cursor @MemberMerg_CUR
   SET @MemberMerg_CUR = CURSOR LOCAL FORWARD_ONLY STATIC
   FOR SELECT c.Case_IDNO
         FROM #CaseList_P1 c;
   -- 13588 - Case journal entry not inserting for the secondary case - End
      
   -- Case Journal Entries must be created for the following activities When the Member is merged                                         				
   SET @Ls_Sql_TEXT = 'OPEN @MemberMerg_CUR';

   OPEN @MemberMerg_CUR;

   SET @Ls_Sql_TEXT = 'FETCH @MemberMerg_CUR - 1';

   FETCH NEXT FROM @MemberMerg_CUR INTO @i$Case_IDNO;

   SELECT @Ls_FetchStatus_BIT = @@FETCH_STATUS;

   -- cursor loop Starts @MemberMerg_CUR		
   WHILE @Ls_FetchStatus_BIT = 0
    BEGIN
     SET @Ls_Sqldata_TEXT = 'Case_IDNO: ' + ISNULL (CAST (@i$Case_IDNO AS CHAR(6)), '') + 'MemberMciPrimary_IDNO = ' + @Lc_MemberMciPrimary_ID + ', MemberMciSecondary_IDNO = ' + @Lc_MemberMciSecondary_ID;
     SET @Ls_DescriptionNotes_TEXT = 'SECONDARY MEMBER ' + @Lc_MemberMciSecondary_ID + ' MERGED WITH PRIMARY MEMBER ' + @Lc_MemberMciPrimary_ID;

     SELECT @Lc_WorkerCase_ID = Worker_ID
       FROM CASE_Y1
      WHERE Case_IDNO = @i$Case_IDNO;

     IF @@ROWCOUNT = 0
      BEGIN
       SET @Lc_WorkerCase_ID = ' ';
      END

     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_ACTIVITY';
     SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL (CAST (@i$Case_IDNO AS CHAR(6)), '') + ', MemberMci_IDNO = ' + @Lc_MemberMciPrimary_ID + ', Job_ID = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ad_Run_DATE AS CHAR(10)) + ', TransactionEventSeq_NUMB = ' + CAST(@An_TransactionEventSeq_NUMB AS CHAR(19)) + ', Subsystem_CODE = ' + @Lc_SubsystemCm_CODE + ', ActivityMajor_CODE = ' + @Lc_ActivityMajorCase_CODE + ', ActivityMinor_CODE = ' + @Lc_ActivityMinorMmerg_CODE;

     EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
      @An_Case_IDNO                = @i$Case_IDNO,
	  -- 13588 - Secondary Member replaced with Primary in Case journal entry - Start
      @An_MemberMci_IDNO           = @Lc_MemberMciPrimary_ID,
      -- 13588 - Secondary Member replaced with Primary in Case journal entry - End
      @Ac_ActivityMajor_CODE       = @Lc_ActivityMajorCase_CODE,
      @Ac_ActivityMinor_CODE       = @Lc_ActivityMinorMmerg_CODE,
      @Ac_Subsystem_CODE           = @Lc_SubsystemCm_CODE,
      @As_DescriptionNote_TEXT     = @Ls_DescriptionNotes_TEXT,
      @An_TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB,
      @Ac_WorkerUpdate_ID          = @Lc_BatchRunUser_TEXT,
      @Ac_WorkerDelegate_ID        = @Lc_WorkerCase_ID,
      @Ad_Run_DATE                 = @Ad_Run_DATE,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @An_Topic_IDNO               = @Ln_Topic_IDNO OUTPUT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE != @Lc_StatusSuccess_CODE
      BEGIN
       SET @Ls_DescriptionError_TEXT = 'BATCH_COMMON$SP_INSERT_ACTIVITY FAILED : '+ISNULL(@Ls_DescriptionError_TEXT,'');
       RAISERROR(50001,16,1);
      END

     FETCH NEXT FROM @MemberMerg_CUR INTO @i$Case_IDNO;

     SELECT @Ls_FetchStatus_BIT = @@FETCH_STATUS;
    END

   CLOSE @MemberMerg_CUR;

   DEALLOCATE @MemberMerg_CUR;

   --Cursor loop Ends @MemberMerg_CUR		
   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = ' ';
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END;

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;
  END CATCH
 END


GO
