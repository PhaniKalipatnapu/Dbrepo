/****** Object:  StoredProcedure [dbo].[BATCH_ENF_OUTGOING_STATE_TAX_OFFSET$SP_INSERT_NMRQ_ENF26]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_ENF_OUTGOING_STATE_TAX_OFFSET$SP_INSERT_NMRQ_ENF26
Programmer Name	:	IMP Team.
Description		:	The purpose of BATCH_ENF_OUTGOING_STATE_TAX_OFFSET$SP_INSERT_NMRQ_ENF26 is 
					  to insert into NMRQ table to generate ENF26 notice
Frequency		:	'WEEKLY'
Developed On	:	4/19/2012
Called By		:	NONE
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_ENF_OUTGOING_STATE_TAX_OFFSET$SP_INSERT_NMRQ_ENF26]
 @Ad_Run_DATE              DATE,
 @Ac_Job_ID                CHAR(07),
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusSuccess_CODE      CHAR(1) = 'S',
          @Lc_StatusFailed_CODE       CHAR(1) = 'F',
          @Lc_TypeError_CODE          CHAR(1) = 'E',
          @Lc_Note_INDC               CHAR(1) = 'N',
          @Lc_SubsystemEn_CODE        CHAR(2) = 'EN',
          @Lc_ActivityMajorCase_CODE  CHAR(4) = 'CASE',
          @Lc_BatchRunUser_TEXT       CHAR(5) = 'BATCH',
          @Lc_BateErrorE1424_CODE     CHAR(5) = 'E1424',
          @Lc_ActivityMinorNopri_CODE CHAR(5) = 'NOPRI',
          @Lc_Job_ID                  CHAR(7) = @Ac_Job_ID,
          @Lc_NoticeEnf26_ID          CHAR(8) = 'ENF-26',
--13683 - Code changed for CR0428 to create case journal entry for all the cases listed in the notice -START-
          @Lc_Notice_ID					CHAR(8) = '',
          @Lc_FindCaseId_TEXT           CHAR(11) = '<case_idno>',
--13683 - Code changed for CR0428 to create case journal entry for all the cases listed in the notice -END-
          @Ls_Procedure_NAME          VARCHAR(100) = 'SP_INSERT_NMRQ_ENF26',
          @Ls_Process_NAME            VARCHAR(100) = 'BATCH_ENF_OUTGOING_STATE_TAX_OFFSET',
          @Ld_Run_DATE                DATE = @Ad_Run_DATE;
  DECLARE @Ln_Zero_NUMB                NUMERIC = 0,
--13683 - Code changed for CR0428 to create case journal entry for all the cases listed in the notice -START-
          @Ln_FoundPosition_NUMB       NUMERIC(5) = 0,
          @Ln_FoundCase_IDNO		   NUMERIC(6) = 0,
--13683 - Code changed for CR0428 to create case journal entry for all the cases listed in the notice -END-          
          @Ln_RecordCount_QNTY         NUMERIC(10, 0) = 0,
          @Ln_Error_NUMB               NUMERIC(11),
          @Ln_ErrorLine_NUMB           NUMERIC(11),
          @Ln_TotalCaseArrears_AMNT    NUMERIC(11, 2) = 0,
          @Ln_Topic_IDNO               NUMERIC(18),
          @Ln_TopicIn26_IDNO           NUMERIC(18) = 0,
          @Ln_TransactionEventSeq_NUMB NUMERIC(19) = 0,
          @Li_FetchStatus_QNTY         SMALLINT,
          @Li_RowCount_QNTY            SMALLINT,
          @Lc_Empty_TEXT               CHAR = '',
          @Lc_CpSuffix_NAME            CHAR(4) = '',
          @Lc_Msg_CODE                 CHAR(5),
          @Lc_BateError_CODE           CHAR(5),
          @Lc_CpFirst_NAME             CHAR(15) = '',
          @Lc_CpLast_NAME              CHAR(20) = '',
          @Lc_CpMiddle_NAME            CHAR(20) = '',
          @Ls_Sql_TEXT                 VARCHAR(100) = '',
          @Ls_SqlData_TEXT             VARCHAR(1000) = '',
          @Ls_ErrorMessage_TEXT        VARCHAR(4000) = '',
          @Ls_RowXml_TEXT              VARCHAR(4000) = '',
          @Ls_BateRecord_TEXT          VARCHAR(4000) = '',
--13683 - Code changed for CR0428 to create case journal entry for all the cases listed in the notice -START-         
          @Ls_NoticeInputXml_TEXT	   VARCHAR(MAX) = '',
          @Ls_InputXml_TEXT			   VARCHAR(MAX) = '',
--13683 - Code changed for CR0428 to create case journal entry for all the cases listed in the notice -END-          
          @Ls_DescriptionError_TEXT    VARCHAR(MAX);
  DECLARE @Ln_NoticeCur_MemberMci_IDNO     NUMERIC(10) = 0,
          @Lc_NoticeCur_County_CODE        CHAR(03),
          @Ln_NoticeCur_Case_IDNO          NUMERIC(6),
          @Ln_NoticeCur_MemberSsn_NUMB     NUMERIC(09),
          @Ln_NoticeCur_TanfArrear_AMNT    NUMERIC(11, 2),
          @Ln_NoticeCur_NonTanfArrear_AMNT NUMERIC(11, 2),
          @Ls_NoticeCur_InputXml_TEXT      VARCHAR(MAX);
  DECLARE Notice_CUR INSENSITIVE CURSOR FOR
   SELECT A.MemberMci_IDNO,
          A.County_CODE,
          A.Case_IDNO,
          A.MemberSsn_NUMB,
          A.TanfArrear_AMNT,
          A.NonTanfArrear_AMNT
     FROM #InsertPreOffset_P1 A
    WHERE A.Create_DATE >= @Ad_Run_DATE
      AND (A.TanfArrear_AMNT > 0
            OR A.NonTanfArrear_AMNT > 0)
    ORDER BY A.MemberMci_IDNO,
             A.Case_IDNO;

  BEGIN TRY
--13683 - Code changed for CR0428 to create case journal entry for all the cases listed in the notice -START-  
   IF OBJECT_ID('tempdb..##PrepStxEnf26Notice_P1') IS NOT NULL
    BEGIN
     DROP TABLE ##PrepStxEnf26Notice_P1;
    END;
--13683 - Code changed for CR0428 to create case journal entry for all the cases listed in the notice -END-
      
   SET @Ac_Msg_CODE = '';
   SET @As_DescriptionError_TEXT = '';
--13634 - Code changed as part of CR0411 to make it more notice specific and to handle transactions without any runtime error -START-
   SET @Ls_Sql_TEXT = 'CREATE ##PrepStxEnf26Notice_P1';

   CREATE TABLE ##PrepStxEnf26Notice_P1
    (
      IgnoreMember_INDC  CHAR(1),
      MemberMci_IDNO     NUMERIC(10),
      Case_IDNO          NUMERIC(6),
      TanfArrear_AMNT    NUMERIC(11, 2),
      NonTanfArrear_AMNT NUMERIC(11, 2),
      TotalArrears_AMNT  NUMERIC(11, 2),
      RowXml_TEXT        VARCHAR(MAX),
      CpCount_QNTY       NUMERIC,
      InputXml_TEXT      VARCHAR(MAX)
    );

   SET @Ls_Sql_TEXT = 'BEGIN TRANSACTION TRAN_GEN_STX_ENF26_NOTICE';
   SET @Ls_SqlData_TEXT = '';

   BEGIN TRANSACTION TRAN_GEN_STX_ENF26_NOTICE;
--13634 - Code changed as part of CR0411 to make it more notice specific and to handle transactions without any runtime error -END-
   SET @Ln_RecordCount_QNTY = 0;
   SET @Ls_Sql_TEXT = 'OPEN Notice_CUR';

   OPEN Notice_CUR;

   SET @Ls_Sql_TEXT = 'FETCH NEXT FROM Notice_CUR - 1';

   FETCH NEXT FROM Notice_CUR INTO @Ln_NoticeCur_MemberMci_IDNO, @Lc_NoticeCur_County_CODE, @Ln_NoticeCur_Case_IDNO, @Ln_NoticeCur_MemberSsn_NUMB, @Ln_NoticeCur_TanfArrear_AMNT, @Ln_NoticeCur_NonTanfArrear_AMNT;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;

   --
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
     BEGIN TRY
--13634 - Code changed as part of CR0411 to make it more notice specific and to handle transactions without any runtime error -START-     
      SET @Ls_Sql_TEXT = 'SAVE TRANSACTION SAVE_PREP_STX_ENF26_INPUT_XML';
      SET @Ls_SqlData_TEXT = '';

	  SAVE TRANSACTION SAVE_PREP_STX_ENF26_INPUT_XML;
     
      SET @Lc_BateError_CODE = @Lc_BateErrorE1424_CODE;
      SET @Ln_RecordCount_QNTY = @Ln_RecordCount_QNTY + 1;
      SET @Ls_BateRecord_TEXT = 'MemberMci_IDNO = ' + CAST(@Ln_NoticeCur_MemberMci_IDNO AS VARCHAR) + ', County_CODE = ' + @Lc_NoticeCur_County_CODE + ', Case_IDNO = ' + CAST(@Ln_NoticeCur_Case_IDNO AS VARCHAR) + ', MemberSsn_NUMB = ' + CAST(@Ln_NoticeCur_MemberSsn_NUMB AS VARCHAR) + ', TanfArrear_AMNT = ' + CAST(@Ln_NoticeCur_TanfArrear_AMNT AS VARCHAR) + ', NonTanfArrear_AMNT = ' + CAST(@Ln_NoticeCur_NonTanfArrear_AMNT AS VARCHAR);

      IF NOT EXISTS (SELECT 1
                       FROM ##PrepStxEnf26Notice_P1 A
                      WHERE A.MemberMci_IDNO = @Ln_NoticeCur_MemberMci_IDNO)
       BEGIN
        SET @Ls_Sql_TEXT = 'INSERT INTO ##PrepStxEnf26Notice_P1';
        SET @Ls_SqlData_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_NoticeCur_MemberMci_IDNO AS VARCHAR), '') + ', Case_IDNO = ' + ISNULL(CAST(@Ln_NoticeCur_Case_IDNO AS VARCHAR), '');

        INSERT INTO ##PrepStxEnf26Notice_P1
--13634 - Code changed as part of CR0411 to make it more notice specific and to handle transactions without any runtime error -END-        
                    (IgnoreMember_INDC,
                     MemberMci_IDNO,
                     Case_IDNO,
                     TanfArrear_AMNT,
                     NonTanfArrear_AMNT,
                     TotalArrears_AMNT,
                     RowXml_TEXT,
                     CpCount_QNTY,
                     InputXml_TEXT)
        SELECT 'N' AS IgnoreMember_INDC,
               @Ln_NoticeCur_MemberMci_IDNO AS MemberMci_IDNO,
               @Ln_NoticeCur_Case_IDNO AS Case_IDNO,
               0 AS TanfArrear_AMNT,
               0 AS NonTanfArrear_AMNT,
               0 AS TotalArrears_AMNT,
               '' AS RowXml_TEXT,
               0 AS CpCount_QNTY,
               '' AS InputXml_TEXT;
       END

      SET @Ls_Sql_TEXT = 'SELECT DEMO';
      SET @Ls_SqlData_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_NoticeCur_Case_IDNO AS VARCHAR), '');

      SELECT TOP 1 @Lc_CpLast_NAME = ISNULL(B.Last_NAME, ''),
                   @Lc_CpFirst_NAME = ISNULL(B.First_NAME, ''),
                   @Lc_CpMiddle_NAME = ISNULL(B.Middle_NAME, ''),
                   @Lc_CpSuffix_NAME = ISNULL(B.Suffix_NAME, '')
        FROM DEMO_Y1 B
       WHERE B.MemberMci_IDNO = (SELECT TOP 1 MemberMci_IDNO
                                   FROM CMEM_Y1 C
                                  WHERE C.Case_IDNO = @Ln_NoticeCur_Case_IDNO
                                    AND C.CaseRelationship_CODE = 'C'
                                    AND C.CaseMemberStatus_CODE = 'A');

      SET @Ln_TotalCaseArrears_AMNT = @Ln_NoticeCur_TanfArrear_AMNT + @Ln_NoticeCur_NonTanfArrear_AMNT;
      SET @Ls_Sql_TEXT = 'PREPARE CP XML';
      SET @Ls_RowXml_TEXT = '<row>';
      SET @Ls_RowXml_TEXT = @Ls_RowXml_TEXT + '<cp_first_name>' + REPLACE(@Lc_CpFirst_NAME, '''', '''''') + '</cp_first_name>';
      SET @Ls_RowXml_TEXT = @Ls_RowXml_TEXT + '<cp_middle_name>' + REPLACE(@Lc_CpMiddle_NAME, '''', '''''') + '</cp_middle_name>';
      SET @Ls_RowXml_TEXT = @Ls_RowXml_TEXT + '<cp_last_name>' + REPLACE(@Lc_CpLast_NAME, '''', '''''') + '</cp_last_name>';
      SET @Ls_RowXml_TEXT = @Ls_RowXml_TEXT + '<cp_suffix_name>' + REPLACE(@Lc_CpSuffix_NAME, '''', '''''') + '</cp_suffix_name>';
      SET @Ls_RowXml_TEXT = @Ls_RowXml_TEXT + '<case_idno>' + CAST(@Ln_NoticeCur_Case_IDNO AS VARCHAR) + '</case_idno>';
      SET @Ls_RowXml_TEXT = @Ls_RowXml_TEXT + '<foster_care_arrears>' + CONVERT(CHAR(14), @Ln_NoticeCur_TanfArrear_AMNT) + '</foster_care_arrears>';
      SET @Ls_RowXml_TEXT = @Ls_RowXml_TEXT + '<med_sup_arrears>' + CONVERT(CHAR(14), @Ln_NoticeCur_NonTanfArrear_AMNT) + '</med_sup_arrears>';
      SET @Ls_RowXml_TEXT = @Ls_RowXml_TEXT + '<tot_arrears>' + CONVERT(CHAR(14), @Ln_TotalCaseArrears_AMNT) + '</tot_arrears>';
      SET @Ls_RowXml_TEXT = @Ls_RowXml_TEXT + '</row>';
--13634 - Code changed as part of CR0411 to make it more notice specific and to handle transactions without any runtime error -START-
      IF EXISTS (SELECT 1
                   FROM ##PrepStxEnf26Notice_P1 A
                  WHERE A.MemberMci_IDNO = @Ln_NoticeCur_MemberMci_IDNO
                    AND A.IgnoreMember_INDC = 'N')
       BEGIN
        SET @Ls_Sql_TEXT = 'UPDATE ##PrepStxEnf26Notice_P1';
        SET @Ls_SqlData_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_NoticeCur_MemberMci_IDNO AS VARCHAR), '');

        UPDATE ##PrepStxEnf26Notice_P1
--13634 - Code changed as part of CR0411 to make it more notice specific and to handle transactions without any runtime error -END-        
           SET TanfArrear_AMNT = TanfArrear_AMNT + @Ln_NoticeCur_TanfArrear_AMNT,
               NonTanfArrear_AMNT = NonTanfArrear_AMNT + @Ln_NoticeCur_NonTanfArrear_AMNT,
               TotalArrears_AMNT = TotalArrears_AMNT + @Ln_NoticeCur_TanfArrear_AMNT + @Ln_NoticeCur_NonTanfArrear_AMNT,
               RowXml_TEXT = RowXml_TEXT + @Ls_RowXml_TEXT,
               CpCount_QNTY = CpCount_QNTY + 1,
               InputXml_TEXT = '<InputParameters>' + '<cp_list COUNT="' + CAST((CpCount_QNTY + 1) AS VARCHAR) + '">' + RowXml_TEXT + @Ls_RowXml_TEXT + '</cp_list>' + '<total_foster_care_arrears>' + CONVERT(CHAR(14), (TanfArrear_AMNT + @Ln_NoticeCur_TanfArrear_AMNT)) + '</total_foster_care_arrears>' + '<total_med_sup_arrears>' + CONVERT(CHAR(14), (NonTanfArrear_AMNT + @Ln_NoticeCur_NonTanfArrear_AMNT)) + '</total_med_sup_arrears>' + '<total_Case_Arrears>' + CONVERT(CHAR(14), (TotalArrears_AMNT + @Ln_NoticeCur_TanfArrear_AMNT + @Ln_NoticeCur_NonTanfArrear_AMNT)) + '</total_Case_Arrears>' + '</InputParameters>'
         WHERE MemberMci_IDNO = @Ln_NoticeCur_MemberMci_IDNO;
       END
     END TRY

     BEGIN CATCH
--13634 - Code changed as part of CR0411 to make it more notice specific and to handle transactions without any runtime error -START-     
      IF XACT_STATE() = 1
       BEGIN
        ROLLBACK TRANSACTION SAVE_PREP_STX_ENF26_INPUT_XML;
       END
      ELSE
       BEGIN
        SET @Ls_ErrorMessage_TEXT = @Ls_ErrorMessage_TEXT + ' ' + SUBSTRING(ERROR_MESSAGE(), 1, 200);

        RAISERROR(50001,16,1);
       END
       
      IF LEN(LTRIM(RTRIM(ISNULL(@Lc_BateError_CODE, '')))) = 0
       BEGIN
        SET @Lc_BateError_CODE = @Lc_BateErrorE1424_CODE;
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
       @As_SqlData_TEXT          = @Ls_SqlData_TEXT,
       @An_Error_NUMB            = @Ln_Error_NUMB,
       @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
       @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

      SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG';
      SET @Ls_SqlData_TEXT = 'BateError_CODE = ' + @Lc_BateError_CODE + ', DescriptionError_TEXT = ' + @Ls_DescriptionError_TEXT + ', BateRecord_TEXT = ' + @Ls_BateRecord_TEXT;

      EXECUTE BATCH_COMMON$SP_BATE_LOG
       @As_Process_NAME             = @Ls_Process_NAME,
       @As_Procedure_NAME           = @Ls_Procedure_NAME,
       @Ac_Job_ID                   = @Lc_Job_ID,
       @Ad_Run_DATE                 = @Ld_Run_DATE,
       @Ac_TypeError_CODE           = @Lc_TypeError_CODE,
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
     
      SET @Ls_Sql_TEXT = 'UPDATE ##PrepStxEnf26Notice_P1 TO IGNORE MEMBER';
      SET @Ls_SqlData_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_NoticeCur_MemberMci_IDNO AS VARCHAR), '');

      IF EXISTS (SELECT 1
                   FROM ##PrepStxEnf26Notice_P1 A
                  WHERE A.MemberMci_IDNO = @Ln_NoticeCur_MemberMci_IDNO)
       BEGIN
        UPDATE ##PrepStxEnf26Notice_P1
           SET IgnoreMember_INDC = 'Y'
         WHERE MemberMci_IDNO = @Ln_NoticeCur_MemberMci_IDNO;
       END
--13634 - Code changed as part of CR0411 to make it more notice specific and to handle transactions without any runtime error -END-       
     END CATCH;

     SET @Ls_Sql_TEXT = 'FETCH NEXT FROM CURSOR Notice_CUR - 2';

     FETCH NEXT FROM Notice_CUR INTO @Ln_NoticeCur_MemberMci_IDNO, @Lc_NoticeCur_County_CODE, @Ln_NoticeCur_Case_IDNO, @Ln_NoticeCur_MemberSsn_NUMB, @Ln_NoticeCur_TanfArrear_AMNT, @Ln_NoticeCur_NonTanfArrear_AMNT;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END

   SET @Ls_Sql_TEXT = 'CLOSE Notice_CUR';

   CLOSE Notice_CUR;

   SET @Ls_Sql_TEXT = 'DEALLOCATE Notice_CUR';

   DEALLOCATE Notice_CUR;
--13634 - Code changed as part of CR0411 to make it more notice specific and to handle transactions without any runtime error -START-
   SET @Ls_Sql_TEXT = 'COMMIT TRANSACTION TRAN_GEN_STX_ENF26_NOTICE';
   SET @Ls_SqlData_TEXT = '';

   COMMIT TRANSACTION TRAN_GEN_STX_ENF26_NOTICE;

   DECLARE Notice1_CUR INSENSITIVE CURSOR FOR
    SELECT A.MemberMci_IDNO,
           A.Case_IDNO,
           A.InputXml_TEXT
      FROM ##PrepStxEnf26Notice_P1 A
     WHERE A.IgnoreMember_INDC = 'N'
     ORDER BY A.MemberMci_IDNO,
              A.Case_IDNO;

   SET @Ls_Sql_TEXT = 'BEGIN TRANSACTION TRAN_GEN_STX_ENF26_NOTICE';
   SET @Ls_SqlData_TEXT = '';

   BEGIN TRANSACTION TRAN_GEN_STX_ENF26_NOTICE;
--13634 - Code changed as part of CR0411 to make it more notice specific and to handle transactions without any runtime error -END-
   SET @Ln_RecordCount_QNTY = 0;
   SET @Ls_Sql_TEXT = 'OPEN Notice1_CUR';

   OPEN Notice1_CUR;

   SET @Ls_Sql_TEXT = 'FETCH NEXT FROM Notice1_CUR - 1';

   FETCH NEXT FROM Notice1_CUR INTO @Ln_NoticeCur_MemberMci_IDNO, @Ln_NoticeCur_Case_IDNO, @Ls_NoticeCur_InputXml_TEXT;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;

   --
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
     BEGIN TRY
--13634 - Code changed as part of CR0411 to make it more notice specific and to handle transactions without any runtime error -START-     
      SET @Ls_Sql_TEXT = 'SAVE TRANSACTION SAVE_GEN_STX_ENF26_NOTICE';
      SET @Ls_SqlData_TEXT = '';

      SAVE TRANSACTION SAVE_GEN_STX_ENF26_NOTICE;
     
      SET @Lc_BateError_CODE = @Lc_BateErrorE1424_CODE;
      SET @Ln_RecordCount_QNTY = @Ln_RecordCount_QNTY + 1;
      SET @Ls_BateRecord_TEXT = 'MemberMci_IDNO = ' + CAST(@Ln_NoticeCur_MemberMci_IDNO AS VARCHAR) + ', Case_IDNO = ' + CAST(@Ln_NoticeCur_Case_IDNO AS VARCHAR) + ', InputXml_TEXT = ' + @Ls_NoticeCur_InputXml_TEXT;

      SELECT @Ln_TopicIn26_IDNO = 0;
--13634 - Code changed as part of CR0411 to make it more notice specific and to handle transactions without any runtime error -END-
      SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT';
      SET @Ls_SqlData_TEXT = '';

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
--13683 - Code changed for CR0428 to create case journal entry for all the cases listed in the notice -START-
	SET @Ln_Topic_IDNO = @Ln_Zero_NUMB;
	SET @Ln_TopicIn26_IDNO = @Ln_Zero_NUMB;
	SET @Lc_Notice_ID = @Lc_NoticeEnf26_ID;
	SET @Ls_NoticeInputXml_TEXT = @Ls_NoticeCur_InputXml_TEXT;
	SET @Ls_InputXml_TEXT = @Ls_NoticeCur_InputXml_TEXT;
	SET @Ln_FoundPosition_NUMB = CHARINDEX(@Lc_FindCaseId_TEXT, @Ls_InputXml_TEXT);
	--SELECT @Ls_InputXml_TEXT Ls_InputXml_TEXT, @Ln_FoundPosition_NUMB Ln_FoundPosition_NUMB
	WHILE @Ln_FoundPosition_NUMB > @Ln_Zero_NUMB
	BEGIN
		IF @Ln_Topic_IDNO > @Ln_Zero_NUMB
		BEGIN
			SET @Lc_Notice_ID = @Lc_Empty_TEXT;
			SET @Ls_NoticeInputXml_TEXT = @Lc_Empty_TEXT;
		END
		SET @Ln_FoundCase_IDNO = SUBSTRING(@Ls_InputXml_TEXT, @Ln_FoundPosition_NUMB + LEN(@Lc_FindCaseId_TEXT), 6);
		SET @Ln_TopicIn26_IDNO = @Ln_Topic_IDNO;
		SET @Ln_Topic_IDNO = @Ln_Zero_NUMB;
		--SELECT @Lc_Notice_ID Lc_Notice_ID, @Ls_NoticeInputXml_TEXT Ls_NoticeInputXml_TEXT
		--, @Ln_FoundCase_IDNO Ln_FoundCase_IDNO, @Ln_TopicIn26_IDNO Ln_TopicIn24_IDNO

      SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_ACTIVITY - ENF-26';
--13634 - Code changed as part of CR0411 to make it more notice specific and to handle transactions without any runtime error -START-      
      SET @Ls_SqlData_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_FoundCase_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_NoticeCur_MemberMci_IDNO AS VARCHAR), '') + ', ActivityMajor_CODE = ' + ISNULL(@Lc_ActivityMajorCase_CODE, '') + ', ActivityMinor_CODE = ' + ISNULL(@Lc_ActivityMinorNopri_CODE, '') + ', Subsystem_CODE = ' + ISNULL(@Lc_SubsystemEn_CODE, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', WorkerUpdate_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', Xml_TEXT = ' + ISNULL(@Ls_NoticeInputXml_TEXT, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Notice_ID = ' + ISNULL(@Lc_Notice_ID, '') + ', TopicIn_IDNO = ' + ISNULL(CAST(@Ln_TopicIn26_IDNO AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '');
--13634 - Code changed as part of CR0411 to make it more notice specific and to handle transactions without any runtime error -END-      

      EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
       @An_Case_IDNO                = @Ln_FoundCase_IDNO,
--13683 - Code changed for CR0428 to create case journal entry for all the cases listed in the notice -END-
	   @An_MemberMci_IDNO           = @Ln_NoticeCur_MemberMci_IDNO,
       @Ac_ActivityMajor_CODE       = @Lc_ActivityMajorCase_CODE,
       @Ac_ActivityMinor_CODE       = @Lc_ActivityMinorNopri_CODE,
       @Ac_Subsystem_CODE           = @Lc_SubsystemEn_CODE,
       @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
       @Ac_WorkerUpdate_ID          = @Lc_BatchRunUser_TEXT,
--13683 - Code changed for CR0428 to create case journal entry for all the cases listed in the notice -START-			 
	   @As_Xml_TEXT                 = @Ls_NoticeInputXml_TEXT,
	   @Ad_Run_DATE                 = @Ld_Run_DATE,
	   @Ac_Notice_ID                = @Lc_Notice_ID,
--13683 - Code changed for CR0428 to create case journal entry for all the cases listed in the notice -END-			 
	   @An_TopicIn_IDNO             = @Ln_TopicIn26_IDNO,
       @Ac_Job_ID                   = @Lc_Job_ID,
       @An_Topic_IDNO               = @Ln_Topic_IDNO OUTPUT,
       @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
       @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

      IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
       BEGIN
        SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

        RAISERROR (50001,16,1);
       END
      ELSE IF @Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
       BEGIN
        SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;
        SET @Lc_BateError_CODE = @Lc_Msg_CODE;

        RAISERROR (50001,16,1);
       END

--13683 - Code changed for CR0428 to create case journal entry for all the cases listed in the notice -START-
		SET @Ls_InputXml_TEXT = RIGHT(@Ls_InputXml_TEXT, LEN(@Ls_InputXml_TEXT) - (@Ln_FoundPosition_NUMB + LEN(@Lc_FindCaseId_TEXT) + 6));
		SET @Ln_FoundPosition_NUMB = CHARINDEX(@Lc_FindCaseId_TEXT, @Ls_InputXml_TEXT);
		--SELECT @Ls_InputXml_TEXT Ls_InputXml_TEXT, @Ln_FoundPosition_NUMB Ln_FoundPosition_NUMB
	END
--13683 - Code changed for CR0428 to create case journal entry for all the cases listed in the notice -END-

      SET @Ls_Sql_TEXT = 'INSERT ISTX_Y1 - ENF-26';
      SET @Ls_SqlData_TEXT = 'MemberMci_IDNO = ' + CAST(@Ln_NoticeCur_MemberMci_IDNO AS VARCHAR);

      INSERT INTO ISTX_Y1
                  (MemberMci_IDNO,
                   Case_IDNO,
                   MemberSsn_NUMB,
                   TaxYear_NUMB,
                   TypeTransaction_CODE,
                   TypeArrear_CODE,
                   Transaction_AMNT,
                   SubmitLast_DATE,
                   WorkerUpdate_ID,
                   Update_DTTM,
                   TransactionEventSeq_NUMB,
                   ExcludeState_CODE,
                   CountyFips_CODE)
      SELECT A.MemberMci_IDNO,
             A.Case_IDNO,
             A.MemberSsn_NUMB,
             A.TaxYear_NUMB,
             A.TypeTransaction_CODE,
             A.TypeArrear_CODE,
             A.Transaction_AMNT,
             A.SubmitLast_DATE,
             A.WorkerUpdate_ID,
             A.Update_DTTM,
             A.TransactionEventSeq_NUMB,
             A.ExcludeState_CODE,
             RIGHT(('000' + LTRIM(RTRIM(A.CountyFips_CODE))), 3) AS CountyFips_CODE
        FROM #IstxData_P1 A
       WHERE A.MemberMci_IDNO = @Ln_NoticeCur_MemberMci_IDNO
         AND A.TypeTransaction_CODE = 'L';

      SET @Li_RowCount_QNTY = @@ROWCOUNT

      IF @Li_RowCount_QNTY = 0
       BEGIN
        SET @Ls_ErrorMessage_TEXT = 'INSERT ISTX_Y1 FAILED! - ENF-26'

        RAISERROR(50001,16,1);
       END
--13634 - Code changed as part of CR0411 to make it more notice specific and to handle transactions without any runtime error -START-
      SET @Ls_Sql_TEXT = 'COMMIT TRANSACTION TRAN_GEN_STX_ENF26_NOTICE';
      SET @Ls_SqlData_TEXT = '';

      COMMIT TRANSACTION TRAN_GEN_STX_ENF26_NOTICE;

      SET @Ls_Sql_TEXT = 'BEGIN TRANSACTION TRAN_GEN_STX_ENF26_NOTICE';
      SET @Ls_SqlData_TEXT = '';

      BEGIN TRANSACTION TRAN_GEN_STX_ENF26_NOTICE;
     END TRY

     BEGIN CATCH
      IF XACT_STATE() = 1
       BEGIN
        ROLLBACK TRANSACTION SAVE_GEN_STX_ENF26_NOTICE;
       END
      ELSE
       BEGIN
        SET @Ls_ErrorMessage_TEXT = @Ls_ErrorMessage_TEXT + ' ' + SUBSTRING(ERROR_MESSAGE(), 1, 200);

        RAISERROR(50001,16,1);
       END
--13634 - Code changed as part of CR0411 to make it more notice specific and to handle transactions without any runtime error -END-
      IF LEN(LTRIM(RTRIM(ISNULL(@Lc_BateError_CODE, '')))) = 0
       BEGIN
        SET @Lc_BateError_CODE = @Lc_BateErrorE1424_CODE;
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
       @As_SqlData_TEXT          = @Ls_SqlData_TEXT,
       @An_Error_NUMB            = @Ln_Error_NUMB,
       @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
       @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

      SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG';
      SET @Ls_SqlData_TEXT = 'BateError_CODE = ' + @Lc_BateError_CODE + ', DescriptionError_TEXT = ' + @Ls_DescriptionError_TEXT + ', BateRecord_TEXT = ' + @Ls_BateRecord_TEXT;

      EXECUTE BATCH_COMMON$SP_BATE_LOG
       @As_Process_NAME             = @Ls_Process_NAME,
       @As_Procedure_NAME           = @Ls_Procedure_NAME,
       @Ac_Job_ID                   = @Lc_Job_ID,
       @Ad_Run_DATE                 = @Ld_Run_DATE,
       @Ac_TypeError_CODE           = @Lc_TypeError_CODE,
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
     END CATCH;

     SET @Ls_Sql_TEXT = 'FETCH NEXT FROM Notice1_CUR - 2';

     FETCH NEXT FROM Notice1_CUR INTO @Ln_NoticeCur_MemberMci_IDNO, @Ln_NoticeCur_Case_IDNO, @Ls_NoticeCur_InputXml_TEXT;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END

   SET @Ls_Sql_TEXT = 'CLOSE Notice1_CUR';

   CLOSE Notice1_CUR;

   SET @Ls_Sql_TEXT = 'DEALLOCATE Notice1_CUR';

   DEALLOCATE Notice1_CUR;
--13634 - Code changed as part of CR0411 to make it more notice specific and to handle transactions without any runtime error -START-
   SET @Ls_Sql_TEXT = 'COMMIT TRANSACTION TRAN_GEN_STX_ENF26_NOTICE';
   SET @Ls_SqlData_TEXT = '';

   COMMIT TRANSACTION TRAN_GEN_STX_ENF26_NOTICE;

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = @Lc_Empty_TEXT;

   IF OBJECT_ID('tempdb..##PrepStxEnf26Notice_P1') IS NOT NULL
    BEGIN
     DROP TABLE ##PrepStxEnf26Notice_P1;
    END;
  END TRY

  BEGIN CATCH
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION TRAN_GEN_STX_ENF26_NOTICE;
    END;
  
   IF OBJECT_ID('tempdb..##PrepStxEnf26Notice_P1') IS NOT NULL
    BEGIN
     DROP TABLE ##PrepStxEnf26Notice_P1;
    END;
--13634 - Code changed as part of CR0411 to make it more notice specific and to handle transactions without any runtime error -END-
   IF CURSOR_STATUS('Local', 'Notice1_CUR') IN (0, 1)
    BEGIN
     CLOSE Notice1_CUR;

     DEALLOCATE Notice1_CUR;
    END;

   IF CURSOR_STATUS('Local', 'Notice_CUR') IN (0, 1)
    BEGIN
     CLOSE Notice_CUR;

     DEALLOCATE Notice_CUR;
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
    @As_SqlData_TEXT          = @Ls_SqlData_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
  END CATCH
 END


GO
