/****** Object:  StoredProcedure [dbo].[BATCH_FIN_IVA_UPDATES$SP_INSERT_MHIS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_FIN_IVA_UPDATES$SP_INSERT_MHIS
Programmer Name	:	IMP Team.
Description		:	Insert Member Welfare Details with the provided values.
Frequency		:	
Developed On	:	04/12/2012
Called By		:	BATCH_FIN_IVA_UPDATES$SP_PROCESS_UPDATE_IVA_REFERRALS
Called On		:	BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_FIN_IVA_UPDATES$SP_INSERT_MHIS] (
 @An_MemberMci_IDNO           NUMERIC(10),
 @An_Case_IDNO                NUMERIC(6),
 @Ad_Start_DATE               DATE,
 @Ad_End_DATE                 DATE = '12/31/9999',
 @Ac_TypeWelfare_CODE         CHAR(1) = ' ',
 @An_CaseWelfare_IDNO         NUMERIC(10) = 0,
 @An_WelfareMemberMci_IDNO    NUMERIC(10) = 0,
 @Ac_CaseHead_INDC            CHAR(1) = ' ',
 @Ac_Reason_CODE              CHAR(2) = ' ',
 @An_EventGlobalBeginSeq_NUMB NUMERIC(19),
 @Ac_Msg_CODE                 CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT    VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  --SET NOCOUNT ON After BEGIN Statement:
  SET NOCOUNT ON;

  --Variable Declarations After SET NOCOUNT ON Statement:
  DECLARE @Li_Zero_NUMB             SMALLINT = 0,
          @Lc_StatusFailed_CODE     CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE    CHAR(1) = 'S',
          @Ls_Procedure_NAME        VARCHAR(100) = 'BATCH_FIN_IVA_UPDATES$SP_INSERT_MHIS',
          @Ls_Sql_TEXT              VARCHAR(2000) = ' ',
          @Ls_ErrorMessage_TEXT     VARCHAR(4000) = ' ',
          @Ls_DescriptionError_TEXT VARCHAR(4000) = ' ',
          @Ls_Sqldata_TEXT          VARCHAR(5000) = ' ',
          @Ld_Current_DATE          DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
  DECLARE @Ln_Rowcount_QNTY  NUMERIC,
          @Ln_Error_NUMB     NUMERIC(11) = 0,
          @Ln_ErrorLine_NUMB NUMERIC(11) = 0;

  BEGIN TRY
   SET @Ls_Sql_TEXT = 'INSERT MHIS_Y1';
   SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@An_MemberMci_IDNO AS VARCHAR), '') + ', Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '') + ', Start_DATE = ' + ISNULL(CAST(@Ad_Start_DATE AS VARCHAR), '') + ', End_DATE = ' + ISNULL(CAST(@Ad_End_DATE AS VARCHAR), '') + ', TypeWelfare_CODE = ' + ISNULL(@Ac_TypeWelfare_CODE, '') + ', CaseWelfare_IDNO = ' + ISNULL(CAST(@An_CaseWelfare_IDNO AS VARCHAR), '') + ', WelfareMemberMci_IDNO = ' + ISNULL(CAST(@An_WelfareMemberMci_IDNO AS VARCHAR), '') + ', CaseHead_INDC = ' + ISNULL(@Ac_CaseHead_INDC, '') + ', Reason_CODE = ' + ISNULL(@Ac_Reason_CODE, '') + ', BeginValidity_DATE = ' + ISNULL(CAST(@Ld_Current_DATE AS VARCHAR), '') + ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST(@An_EventGlobalBeginSeq_NUMB AS VARCHAR), '') + ', EventGlobalEndSeq_NUMB = ' + ISNULL(CAST(@Li_Zero_NUMB AS VARCHAR), '');

   INSERT MHIS_Y1
          (MemberMci_IDNO,
           Case_IDNO,
           Start_DATE,
           End_DATE,
           TypeWelfare_CODE,
           CaseWelfare_IDNO,
           WelfareMemberMci_IDNO,
           CaseHead_INDC,
           Reason_CODE,
           BeginValidity_DATE,
           EventGlobalBeginSeq_NUMB,
           EventGlobalEndSeq_NUMB)
   VALUES ( @An_MemberMci_IDNO,--MemberMci_IDNO
            @An_Case_IDNO,--Case_IDNO
            @Ad_Start_DATE,--Start_DATE
            @Ad_End_DATE,--End_DATE
            @Ac_TypeWelfare_CODE,--TypeWelfare_CODE
            @An_CaseWelfare_IDNO,--CaseWelfare_IDNO
            @An_WelfareMemberMci_IDNO,--WelfareMemberMci_IDNO
            @Ac_CaseHead_INDC,--CaseHead_INDC
            @Ac_Reason_CODE,--Reason_CODE
            @Ld_Current_DATE,--BeginValidity_DATE
            @An_EventGlobalBeginSeq_NUMB,--EventGlobalBeginSeq_NUMB
            @Li_Zero_NUMB--EventGlobalEndSeq_NUMB
   );

   SET @Ln_Rowcount_QNTY = @@ROWCOUNT;

   IF @Ln_Rowcount_QNTY = @Li_Zero_NUMB
    BEGIN
     SET @Ls_DescriptionError_TEXT = 'INSERT FAILED';

     RAISERROR (50001,16,1);
    END

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = '';
  END TRY

  BEGIN CATCH
   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();
   SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_ErrorMessage_TEXT = SUBSTRING(ERROR_MESSAGE(), 1, 200);
    END

   --Check for Exception information to log the description text based on the error
   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
  END CATCH
 END;


GO
