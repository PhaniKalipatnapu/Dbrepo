/****** Object:  StoredProcedure [dbo].[BATCH_EST_VDMP$SP_PROCESS_VAP_DOP_PARENT_MATCH]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_EST_VDMP$SP_PROCESS_VAP_DOP_PARENT_MATCH
Programmer Name	:	IMP Team.
Description		:	This batch program runs when there was no match found initially during the Child First process.
Frequency		:	'WEEKLY'
Developed On	:	3/16/2012
Called By		:	NONE
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_EST_VDMP$SP_PROCESS_VAP_DOP_PARENT_MATCH]
 @Ac_Job_ID                   CHAR(7),
 @An_ChildMemberMci_IDNO      NUMERIC,
 @An_ChildMemberSsn_NUMB      NUMERIC,
 @An_MotherMemberMci_IDNO     NUMERIC,
 @An_MotherMemberSsn_NUMB     NUMERIC,
 @An_FatherMemberMci_IDNO     NUMERIC,
 @An_FatherMemberSsn_NUMB     NUMERIC,
 @Ac_DopAttached_CODE         CHAR(1),
 @Ac_ChildBirthCertificate_ID CHAR(7),
 @Ac_ChildFirst_NAME          CHAR(16),
 @Ac_MotherFirst_NAME         CHAR(16),
 @Ac_FatherFirst_NAME         CHAR(16),
 @Ac_ChildLast_NAME           CHAR(20),
 @Ac_MotherLast_NAME          CHAR(20),
 @Ac_FatherLast_NAME          CHAR(20),
 @Ad_ChildBirth_DATE          DATE,
 @Ad_MotherBirth_DATE         DATE,
 @Ad_FatherBirth_DATE         DATE,
 @Ad_MotherSignature_DATE     DATE,
 @Ad_FatherSignature_DATE     DATE,
 @Ad_Run_DATE                 DATE,
 @Ac_Msg_CODE                 CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT    VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusFailed_CODE  CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE CHAR(1) = 'S',
          @Lc_MatchFound_INDC    CHAR(1) = 'N',
          @Lc_Job_ID             CHAR(7) = @Ac_Job_ID,
          @Ls_Procedure_NAME     VARCHAR(100) = 'SP_PROCESS_VAP_DOP_PARENT_MATCH';
  DECLARE @Ln_Error_NUMB                                  NUMERIC(11),
          @Ln_ErrorLine_NUMB                              NUMERIC(11),
          @Li_ParentFirstProcessChildDataMatchPoint_QNTY  INT = 0,
          @Li_ParentFirstProcessParentDataMatchPoint_QNTY INT = 0,
          @Lc_Msg_CODE                                    CHAR(5) = '',
          @Lc_Goto_CODE                                   CHAR(7) = '',
          @Ls_Sql_TEXT                                    VARCHAR(100),
          @Ls_Sqldata_TEXT                                VARCHAR(1000),
          @Ls_ErrorMessage_TEXT                           VARCHAR(4000) = '',
          @Ls_DescriptionError_TEXT                       VARCHAR(4000);

  BEGIN TRY
   SET @Lc_MatchFound_INDC = 'N';
   SET @Li_ParentFirstProcessChildDataMatchPoint_QNTY = 0;
   SET @Li_ParentFirstProcessParentDataMatchPoint_QNTY = 0;

   BEGIN_MOTHER_PROCESS:

   SET @Ls_Sqldata_TEXT = '';
   --SELECT 'No Match Found in CHILD Process, Moving to Mother First Process';
   SET @Ls_Sql_TEXT = 'BATCH_EST_VDMP$SP_PROCESS_VAP_DOP_MOTHER_MATCH';
   SET @Ls_Sqldata_TEXT = 'ChildMemberMci_IDNO = ' + ISNULL(CAST(@An_ChildMemberMci_IDNO AS VARCHAR), '') + ', ChildMemberSsn_NUMB = ' + ISNULL(CAST(@An_ChildMemberSsn_NUMB AS VARCHAR), '') + ', MotherMemberMci_IDNO = ' + ISNULL(CAST(@An_MotherMemberMci_IDNO AS VARCHAR), '') + ', MotherMemberSsn_NUMB = ' + ISNULL(CAST(@An_MotherMemberSsn_NUMB AS VARCHAR), '') + ', FatherMemberMci_IDNO = ' + ISNULL(CAST(@An_FatherMemberMci_IDNO AS VARCHAR), '') + ', FatherMemberSsn_NUMB = ' + ISNULL(CAST(@An_FatherMemberSsn_NUMB AS VARCHAR), '') + ', DopAttached_CODE = ' + ISNULL(@Ac_DopAttached_CODE, '') + ', ChildBirthCertificate_ID = ' + ISNULL(@Ac_ChildBirthCertificate_ID, '') + ', ChildFirst_NAME = ' + ISNULL(@Ac_ChildFirst_NAME, '') + ', MotherFirst_NAME = ' + ISNULL(@Ac_MotherFirst_NAME, '') + ', FatherFirst_NAME = ' + ISNULL(@Ac_FatherFirst_NAME, '') + ', ChildLast_NAME = ' + ISNULL(@Ac_ChildLast_NAME, '') + ', MotherLast_NAME = ' + ISNULL(@Ac_MotherLast_NAME, '') + ', FatherLast_NAME = ' + ISNULL(@Ac_FatherLast_NAME, '') + ', ChildBirth_DATE = ' + ISNULL(CAST(@Ad_ChildBirth_DATE AS VARCHAR), '') + ', MotherBirth_DATE = ' + ISNULL(CAST(@Ad_MotherBirth_DATE AS VARCHAR), '') + ', FatherBirth_DATE = ' + ISNULL(CAST(@Ad_FatherBirth_DATE AS VARCHAR), '') + ', MotherSignature_DATE = ' + ISNULL(CAST(@Ad_MotherSignature_DATE AS VARCHAR), '') + ', FatherSignature_DATE = ' + ISNULL(CAST(@Ad_FatherSignature_DATE AS VARCHAR), '') + ', Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '');

   EXECUTE BATCH_EST_VDMP$SP_PROCESS_VAP_DOP_MOTHER_MATCH
    @Ac_Job_ID                   = @Lc_Job_ID,
    @An_ChildMemberMci_IDNO      = @An_ChildMemberMci_IDNO,
    @An_ChildMemberSsn_NUMB      = @An_ChildMemberSsn_NUMB,
    @An_MotherMemberMci_IDNO     = @An_MotherMemberMci_IDNO,
    @An_MotherMemberSsn_NUMB     = @An_MotherMemberSsn_NUMB,
    @An_FatherMemberMci_IDNO     = @An_FatherMemberMci_IDNO,
    @An_FatherMemberSsn_NUMB     = @An_FatherMemberSsn_NUMB,
    @Ac_DopAttached_CODE         = @Ac_DopAttached_CODE,
    @Ac_ChildBirthCertificate_ID = @Ac_ChildBirthCertificate_ID,
    @Ac_ChildFirst_NAME          = @Ac_ChildFirst_NAME,
    @Ac_MotherFirst_NAME         = @Ac_MotherFirst_NAME,
    @Ac_FatherFirst_NAME         = @Ac_FatherFirst_NAME,
    @Ac_ChildLast_NAME           = @Ac_ChildLast_NAME,
    @Ac_MotherLast_NAME          = @Ac_MotherLast_NAME,
    @Ac_FatherLast_NAME          = @Ac_FatherLast_NAME,
    @Ad_ChildBirth_DATE          = @Ad_ChildBirth_DATE,
    @Ad_MotherBirth_DATE         = @Ad_MotherBirth_DATE,
    @Ad_FatherBirth_DATE         = @Ad_FatherBirth_DATE,
    @Ad_MotherSignature_DATE     = @Ad_MotherSignature_DATE,
    @Ad_FatherSignature_DATE     = @Ad_FatherSignature_DATE,
    @Ad_Run_DATE                 = @Ad_Run_DATE,
    @Ac_Goto_CODE                = @Lc_Goto_CODE OUTPUT,
    @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

     RAISERROR(50001,16,1);
    END

   IF UPPER(LTRIM(RTRIM(@Lc_Goto_CODE))) = 'BEGIN_FATHER_PROCESS'
    BEGIN
     GOTO BEGIN_FATHER_PROCESS;
    END
   ELSE IF UPPER(LTRIM(RTRIM(@Lc_Goto_CODE))) = 'NEXT_RECORD'
    BEGIN
     GOTO NEXT_RECORD;
    END

   BEGIN_FATHER_PROCESS:

   SET @Ls_Sql_TEXT = 'SELECT #VappMappPointQntyInfo_P1';
   SET @Ls_Sqldata_TEXT = 'ChildBirthCertificate_ID = ' + ISNULL(@Ac_ChildBirthCertificate_ID, '');

   SELECT @Li_ParentFirstProcessChildDataMatchPoint_QNTY = A.ParentFirstProcessChildDataMatchPoint_QNTY,
          @Li_ParentFirstProcessParentDataMatchPoint_QNTY = A.ParentFirstProcessParentDataMatchPoint_QNTY,
          @Lc_MatchFound_INDC = A.MatchFound_INDC
     FROM #VappMappPointQntyInfo_P1 A
    WHERE ChildBirthCertificate_ID = @Ac_ChildBirthCertificate_ID;

   IF @Lc_MatchFound_INDC = 'N'
       OR @Li_ParentFirstProcessChildDataMatchPoint_QNTY < 4
       OR @Li_ParentFirstProcessParentDataMatchPoint_QNTY < 4
    BEGIN
     SET @Ls_Sqldata_TEXT = '';
     --SELECT 'No Match Found in MOTHER Process, Moving to Father First Process';
     SET @Ls_Sql_TEXT = 'BATCH_EST_VDMP$SP_PROCESS_VAP_DOP_FATHER_MATCH';
     SET @Ls_Sqldata_TEXT = 'ChildMemberMci_IDNO = ' + ISNULL(CAST(@An_ChildMemberMci_IDNO AS VARCHAR), '') + ', ChildMemberSsn_NUMB = ' + ISNULL(CAST(@An_ChildMemberSsn_NUMB AS VARCHAR), '') + ', MotherMemberMci_IDNO = ' + ISNULL(CAST(@An_MotherMemberMci_IDNO AS VARCHAR), '') + ', MotherMemberSsn_NUMB = ' + ISNULL(CAST(@An_MotherMemberSsn_NUMB AS VARCHAR), '') + ', FatherMemberMci_IDNO = ' + ISNULL(CAST(@An_FatherMemberMci_IDNO AS VARCHAR), '') + ', FatherMemberSsn_NUMB = ' + ISNULL(CAST(@An_FatherMemberSsn_NUMB AS VARCHAR), '') + ', DopAttached_CODE = ' + ISNULL(@Ac_DopAttached_CODE, '') + ', ChildBirthCertificate_ID = ' + ISNULL(@Ac_ChildBirthCertificate_ID, '') + ', ChildFirst_NAME = ' + ISNULL(@Ac_ChildFirst_NAME, '') + ', MotherFirst_NAME = ' + ISNULL(@Ac_MotherFirst_NAME, '') + ', FatherFirst_NAME = ' + ISNULL(@Ac_FatherFirst_NAME, '') + ', ChildLast_NAME = ' + ISNULL(@Ac_ChildLast_NAME, '') + ', MotherLast_NAME = ' + ISNULL(@Ac_MotherLast_NAME, '') + ', FatherLast_NAME = ' + ISNULL(@Ac_FatherLast_NAME, '') + ', ChildBirth_DATE = ' + ISNULL(CAST(@Ad_ChildBirth_DATE AS VARCHAR), '') + ', MotherBirth_DATE = ' + ISNULL(CAST(@Ad_MotherBirth_DATE AS VARCHAR), '') + ', FatherBirth_DATE = ' + ISNULL(CAST(@Ad_FatherBirth_DATE AS VARCHAR), '') + ', MotherSignature_DATE = ' + ISNULL(CAST(@Ad_MotherSignature_DATE AS VARCHAR), '') + ', FatherSignature_DATE = ' + ISNULL(CAST(@Ad_FatherSignature_DATE AS VARCHAR), '') + ', Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '');

     EXECUTE BATCH_EST_VDMP$SP_PROCESS_VAP_DOP_FATHER_MATCH
      @Ac_Job_ID                   = @Lc_Job_ID,
      @An_ChildMemberMci_IDNO      = @An_ChildMemberMci_IDNO,
      @An_ChildMemberSsn_NUMB      = @An_ChildMemberSsn_NUMB,
      @An_MotherMemberMci_IDNO     = @An_MotherMemberMci_IDNO,
      @An_MotherMemberSsn_NUMB     = @An_MotherMemberSsn_NUMB,
      @An_FatherMemberMci_IDNO     = @An_FatherMemberMci_IDNO,
      @An_FatherMemberSsn_NUMB     = @An_FatherMemberSsn_NUMB,
      @Ac_DopAttached_CODE         = @Ac_DopAttached_CODE,
      @Ac_ChildBirthCertificate_ID = @Ac_ChildBirthCertificate_ID,
      @Ac_ChildFirst_NAME          = @Ac_ChildFirst_NAME,
      @Ac_MotherFirst_NAME         = @Ac_MotherFirst_NAME,
      @Ac_FatherFirst_NAME         = @Ac_FatherFirst_NAME,
      @Ac_ChildLast_NAME           = @Ac_ChildLast_NAME,
      @Ac_MotherLast_NAME          = @Ac_MotherLast_NAME,
      @Ac_FatherLast_NAME          = @Ac_FatherLast_NAME,
      @Ad_ChildBirth_DATE          = @Ad_ChildBirth_DATE,
      @Ad_MotherBirth_DATE         = @Ad_MotherBirth_DATE,
      @Ad_FatherBirth_DATE         = @Ad_FatherBirth_DATE,
      @Ad_MotherSignature_DATE     = @Ad_MotherSignature_DATE,
      @Ad_FatherSignature_DATE     = @Ad_FatherSignature_DATE,
      @Ad_Run_DATE                 = @Ad_Run_DATE,
      @Ac_Goto_CODE                = @Lc_Goto_CODE OUTPUT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

       RAISERROR(50001,16,1);
      END

     IF UPPER(LTRIM(RTRIM(@Lc_Goto_CODE))) = 'NEXT_RECORD'
      BEGIN
       GOTO NEXT_RECORD;
      END
    END

   NEXT_RECORD:

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = '';
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
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

   SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
  END CATCH
 END


GO
