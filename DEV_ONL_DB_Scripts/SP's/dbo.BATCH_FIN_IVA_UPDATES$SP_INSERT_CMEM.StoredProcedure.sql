/****** Object:  StoredProcedure [dbo].[BATCH_FIN_IVA_UPDATES$SP_INSERT_CMEM]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_FIN_IVA_UPDATES$SP_INSERT_CMEM
Programmer Name	:	IMP Team.
Description		:	Insert all Case Member details along with Members Case Relation Dependent and Case Member Status Active.
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
CREATE PROCEDURE [dbo].[BATCH_FIN_IVA_UPDATES$SP_INSERT_CMEM] (
 @An_Case_IDNO                   NUMERIC(6, 0),
 @An_MemberMci_IDNO              NUMERIC(10, 0),
 @Ac_CaseRelationship_CODE       CHAR(1),
 @Ac_CaseMemberStatus_CODE       CHAR(1),
 @Ac_CpRelationshipToChild_CODE  CHAR(3) = ' ',
 @Ac_NcpRelationshipToChild_CODE CHAR(3) = ' ',
 @Ac_BenchWarrant_INDC           CHAR(1) = ' ',
 @Ac_ReasonMemberStatus_CODE     CHAR(2) = ' ',
 @Ac_Applicant_CODE              CHAR(1) = ' ',
 @Ac_WorkerUpdate_ID             CHAR(30),
 @An_TransactionEventSeq_NUMB    NUMERIC(19, 0),
 @Ad_FamilyViolence_DATE         DATE = '01/01/0001',
 @Ac_FamilyViolence_INDC         CHAR(1) = ' ',
 @Ac_TypeFamilyViolence_CODE     CHAR(2) = ' ',
 @Ac_Msg_CODE                    CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT       VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  --SET NOCOUNT ON After BEGIN Statement:
  SET NOCOUNT ON;

  --Variable Declarations After SET NOCOUNT ON Statement:
  DECLARE @Li_Zero_NUMB             SMALLINT = 0,
          @Lc_Space_TEXT            CHAR(1) = ' ',
          @Lc_StatusFailed_CODE     CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE    CHAR(1) = 'S',
          @Ls_Procedure_NAME        VARCHAR(100) = 'BATCH_FIN_IVA_UPDATES$SP_INSERT_CMEM',
          @Ls_Sql_TEXT              VARCHAR(2000) = ' ',
          @Ls_ErrorMessage_TEXT     VARCHAR(4000) = ' ',
          @Ls_DescriptionError_TEXT VARCHAR(4000) = ' ',
          @Ls_Sqldata_TEXT          VARCHAR(5000) = ' ',
          @Ld_Current_DTTM          DATETIME2 = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
  DECLARE @Ln_Rowcount_QNTY  NUMERIC,
          @Ln_ErrorLine_NUMB NUMERIC(11) = 0,
          @Ln_Error_NUMB     NUMERIC(11) = 0;

  BEGIN TRY
   SET @Ls_Sql_TEXT = 'INSERT CMEM_Y1';
   SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@An_MemberMci_IDNO AS VARCHAR), '') + ', CaseRelationship_CODE = ' + ISNULL(@Ac_CaseRelationship_CODE, '') + ', CaseMemberStatus_CODE = ' + ISNULL(@Ac_CaseMemberStatus_CODE, '') + ', CpRelationshipToChild_CODE = ' + ISNULL(@Ac_CpRelationshipToChild_CODE, '') + ', NcpRelationshipToChild_CODE = ' + ISNULL(@Ac_NcpRelationshipToChild_CODE, '') + ', BenchWarrant_INDC = ' + ISNULL(@Ac_BenchWarrant_INDC, '') + ', ReasonMemberStatus_CODE = ' + ISNULL(@Ac_ReasonMemberStatus_CODE, '') + ', Applicant_CODE = ' + ISNULL(@Ac_Applicant_CODE, '') + ', BeginValidity_DATE = ' + ISNULL(CAST(@Ld_Current_DTTM AS VARCHAR), '') + ', WorkerUpdate_ID = ' + ISNULL(@Ac_WorkerUpdate_ID, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@An_TransactionEventSeq_NUMB AS VARCHAR), '') + ', Update_DTTM = ' + ISNULL(CAST(@Ld_Current_DTTM AS VARCHAR), '') + ', FamilyViolence_DATE = ' + ISNULL(CAST(@Ad_FamilyViolence_DATE AS VARCHAR), '') + ', FamilyViolence_INDC = ' + ISNULL(@Ac_FamilyViolence_INDC, '') + ', TypeFamilyViolence_CODE = ' + ISNULL(@Ac_TypeFamilyViolence_CODE, '');

   INSERT CMEM_Y1
          (Case_IDNO,
           MemberMci_IDNO,
           CaseRelationship_CODE,
           CaseMemberStatus_CODE,
           CpRelationshipToChild_CODE,
           NcpRelationshipToChild_CODE,
           BenchWarrant_INDC,
           ReasonMemberStatus_CODE,
           Applicant_CODE,
           BeginValidity_DATE,
           WorkerUpdate_ID,
           TransactionEventSeq_NUMB,
           Update_DTTM,
           FamilyViolence_DATE,
           FamilyViolence_INDC,
           TypeFamilyViolence_CODE)
   VALUES ( @An_Case_IDNO,--Case_IDNO
            @An_MemberMci_IDNO,--MemberMci_IDNO
            @Ac_CaseRelationship_CODE,--CaseRelationship_CODE
            @Ac_CaseMemberStatus_CODE,--CaseMemberStatus_CODE
            @Ac_CpRelationshipToChild_CODE,--CpRelationshipToChild_CODE
            @Ac_NcpRelationshipToChild_CODE,--NcpRelationshipToChild_CODE
            @Ac_BenchWarrant_INDC,--BenchWarrant_INDC
            @Ac_ReasonMemberStatus_CODE,--ReasonMemberStatus_CODE
            @Ac_Applicant_CODE,--Applicant_CODE
            @Ld_Current_DTTM,--BeginValidity_DATE
            @Ac_WorkerUpdate_ID,--WorkerUpdate_ID
            @An_TransactionEventSeq_NUMB,--TransactionEventSeq_NUMB
            @Ld_Current_DTTM,--Update_DTTM
            @Ad_FamilyViolence_DATE,--FamilyViolence_DATE
            @Ac_FamilyViolence_INDC,--FamilyViolence_INDC
            @Ac_TypeFamilyViolence_CODE--TypeFamilyViolence_CODE
   );

   SET @Ln_Rowcount_QNTY = @@ROWCOUNT;

   IF @Ln_Rowcount_QNTY = @Li_Zero_NUMB
    BEGIN
     SET @Ls_DescriptionError_TEXT = 'INSERT FAILED';

     RAISERROR (50001,16,1);
    END

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = @Lc_Space_TEXT;
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
