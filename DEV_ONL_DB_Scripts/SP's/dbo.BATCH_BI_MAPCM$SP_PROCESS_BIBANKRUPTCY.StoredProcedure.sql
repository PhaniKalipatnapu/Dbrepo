/****** Object:  StoredProcedure [dbo].[BATCH_BI_MAPCM$SP_PROCESS_BIBANKRUPTCY]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_BI_MAPCM$SP_PROCESS_BIBANKRUPTCY
Programmer Name	:	IMP Team.
Description		:	This process loads bankruptcy details.
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
CREATE PROCEDURE [dbo].[BATCH_BI_MAPCM$SP_PROCESS_BIBANKRUPTCY]
 @An_RecordCount_NUMB      NUMERIC(6) OUTPUT,
 @Ac_Msg_CODE              CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Li_RowCount_QNTY                  INT = 0,
          @Lc_Space_TEXT                     CHAR(1) = ' ',
          @Lc_StatusCaseMemberActive_CODE    CHAR(1) = 'A',
          @Lc_RelationshipCaseNcp_TEXT       CHAR(1) = 'A',
          @Lc_RelationshipCasePutFather_TEXT CHAR(1) = 'P',
          @Lc_StatusFailed_CODE              CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE             CHAR(1) = 'S',
          @Lc_TypeError_CODE                 CHAR(1) = 'E',
          @Lc_BateError_CODE                 CHAR(5) = 'E0944',
          @Lc_Job_ID                         CHAR(7) = 'DEB0836',
          @Lc_Process_NAME                   CHAR(14) = 'BATCH_BI_MAPCM',
          @Ls_Procedure_NAME                 VARCHAR(50) = 'SP_PROCESS_BIBANKRUPTCY',
          @Ld_Highdate_DATE                  DATE = '12/31/9999';
  DECLARE @Ln_Zero_NUMB             NUMERIC(1) = 0,
          @Ln_Error_NUMB            NUMERIC(11),
          @Ln_ErrorLine_NUMB        NUMERIC(11),
          @Lc_Msg_CODE              CHAR(1),
          @Ls_Sql_TEXT              VARCHAR(100),
          @Ls_SqlData_TEXT          VARCHAR(1000),
          @Ls_ErrorMessage_TEXT     VARCHAR(4000),
          @Ls_DescriptionError_TEXT VARCHAR(4000),
          @Ld_Start_DATE            DATETIME2;

  BEGIN TRY
   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = @Lc_Space_TEXT;
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   SET @Ls_Sql_TEXT = 'DELETE FROM BPBKTY_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   DELETE FROM BPBKTY_Y1;

   SET @Ls_Sql_TEXT = 'INSERT INTO BPBKTY_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   INSERT BPBKTY_Y1
          (Case_IDNO,
           MemberMci_IDNO,
           Bankruptcy_CODE,
           FileBankruptcy_DATE)
   SELECT a.Case_IDNO,
          a.MemberMci_IDNO,
          b.TypeBankruptcy_CODE,
          b.Filed_DATE AS FileBankruptcy_DATE
     FROM BPMEMB_Y1 a,
          BNKR_Y1 b
    WHERE a.MemberMci_IDNO = b.MemberMci_IDNO
      AND a.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE
      AND a.CaseRelationship_CODE IN (@Lc_RelationshipCaseNcp_TEXT, @Lc_RelationshipCasePutFather_TEXT)
      AND b.EndValidity_DATE = @Ld_Highdate_DATE;

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

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END
    END
   
   SET @An_RecordCount_NUMB = @An_RecordCount_NUMB + @Li_RowCount_QNTY;

   SET @Ls_Sql_TEXT = 'DELETE FROM BBKTY_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   DELETE FROM BBKTY_Y1;

   SET @Ls_Sql_TEXT = 'INSERT INTO BBKTY_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   INSERT BBKTY_Y1
          (Case_IDNO,
           MemberMci_IDNO,
           Bankruptcy_CODE,
           FileBankruptcy_DATE)
   SELECT a.Case_IDNO,
          a.MemberMci_IDNO,
          a.Bankruptcy_CODE,
          a.FileBankruptcy_DATE
     FROM BPBKTY_Y1 a;

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

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END
    END   
  END TRY

  BEGIN CATCH
   BEGIN
    SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
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
