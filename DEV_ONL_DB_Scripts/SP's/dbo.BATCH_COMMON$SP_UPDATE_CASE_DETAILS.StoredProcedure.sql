/****** Object:  StoredProcedure [dbo].[BATCH_COMMON$SP_UPDATE_CASE_DETAILS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_COMMON$SP_UPDATE_CASE_DETAILS
Programmer Name		: IMP Team
Description			: Update CASE_Y1 table details.
Frequency			: None
Developed On		: 04/12/2011
Called By			: BATCH_ENF_EMON$SP_PROCESS_CASE_CLOSURE, BATCH_ENF_EMON$SP_UPDATE_CASE_COOPERATION,
					  BATCH_ENF_EMON$SP_UPDATE_COOPERATION_ESTP and BATCH_ENF_EMON$SP_UPDATE_GOODCAUSE_VAPP
Called On			: BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
--------------------------------------------------------------------------------------------------------------------
Modified By			:
Modified On			:
Version No			: 1.0	
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_COMMON$SP_UPDATE_CASE_DETAILS] (
 @An_Case_IDNO                NUMERIC(6),
 @Ac_StatusCase_CODE          CHAR(1) = NULL,
 @Ac_RespondInit_CODE         CHAR(1) = NULL,
 @An_RsnStatusCase_CODE       CHAR(2) = NULL,
 @An_StatusCurrent_DATE       DATE = NULL,
 @Ac_GoodCause_CODE           CHAR(1),
 @Ad_GoodCause_DATE           DATE = NULL,
 @Ac_NonCoop_CODE             CHAR(1),
 @Ad_NonCoop_DATE             DATE,
 @Ac_StatusEnforce_CODE       CHAR(4) = NULL,
 @Ac_WorkerUpdate_ID          CHAR(30),
 @An_TransactionEventSeq_NUMB NUMERIC(19),
 @Ac_Msg_CODE                 CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT    VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusSuccess_CODE CHAR(1) = 'S',
          @Lc_StatusFail_CODE    CHAR(1) = 'F',
          @Ls_Routine_TEXT       VARCHAR(60) = 'BATCH_COMMON$SP_UPDATE_CASE_DETAILS',
          @Ld_Start_DATE         DATETIME2 = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
  DECLARE @Ln_RowCount_QNTY     NUMERIC(10),
          @Ln_Error_NUMB        NUMERIC(10),
          @Ln_ErrorLine_NUMB    NUMERIC(11),
          @Ls_Sql_TEXT          VARCHAR(300),
          @Ls_Sqldata_TEXT      VARCHAR(3000),
          @Ls_ErrorMessage_TEXT VARCHAR(4000) = '';

  BEGIN TRY
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_CASE_DETAILS UPDATE CASE_Y1';
   SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR(6)), '');

   UPDATE CASE_Y1
      SET StatusCase_CODE = ISNULL(@Ac_StatusCase_CODE, StatusCase_CODE),
          Respondinit_CODE = ISNULL(@Ac_RespondInit_CODE, RespondInit_CODE),
          RsnStatusCase_CODE = ISNULL(@An_RsnStatusCase_CODE, RsnStatusCase_CODE),
          StatusCurrent_DATE = ISNULL(@An_StatusCurrent_DATE, StatusCurrent_DATE),
          NonCoop_CODE = @Ac_NonCoop_CODE,
          NonCoop_DATE = @Ad_NonCoop_DATE,
          GoodCause_CODE = @Ac_GoodCause_CODE,
          GoodCause_DATE = ISNULL(@Ad_GoodCause_DATE, GoodCause_DATE),
          StatusEnforce_CODE = ISNULL(@Ac_StatusEnforce_CODE, StatusEnforce_CODE),
          TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB,
          WorkerUpdate_ID = @Ac_WorkerUpdate_ID,
          BeginValidity_DATE = @Ld_Start_DATE,
          Update_DTTM = @Ld_Start_DATE
   OUTPUT deleted.Case_IDNO,
          deleted.StatusCase_CODE,
          deleted.TypeCase_CODE,
          deleted.RsnStatusCase_CODE,
          deleted.RespondInit_CODE,
          deleted.SourceRfrl_CODE,
          deleted.Opened_DATE,
          deleted.Marriage_DATE,
          deleted.Divorced_DATE,
          deleted.StatusCurrent_DATE,
          deleted.AprvIvd_DATE,
          deleted.County_IDNO,
          deleted.Office_IDNO,
          deleted.AssignedFips_CODE,
          deleted.GoodCause_CODE,
          deleted.GoodCause_DATE,
          deleted.Restricted_INDC,
          deleted.MedicalOnly_INDC,
          deleted.Jurisdiction_INDC,
          deleted.IvdApplicant_CODE,
          deleted.Application_IDNO,
          deleted.AppSent_DATE,
          deleted.AppReq_DATE,
          deleted.AppRetd_DATE,
          deleted.CpRelationshipToNcp_CODE,
          deleted.Worker_ID,
          deleted.AppSigned_DATE,
          deleted.ClientLitigantRole_CODE,
          deleted.DescriptionComments_TEXT,
          deleted.NonCoop_CODE,
          deleted.NonCoop_DATE,
          deleted.BeginValidity_DATE,
          @Ld_Start_DATE AS EndValidity_DATE,
          deleted.WorkerUpdate_ID,
          deleted.TransactionEventSeq_NUMB,
          deleted.Update_DTTM,
          deleted.Referral_DATE,
          deleted.CaseCategory_CODE,
          deleted.File_ID,
          deleted.ApplicationFee_CODE,
          deleted.FeePaid_DATE,
          deleted.ServiceRequested_CODE,
          deleted.StatusEnforce_CODE,
          deleted.FeeCheckNo_TEXT,
          deleted.ReasonFeeWaived_CODE,
          deleted.Intercept_CODE
   INTO HCASE_Y1
    WHERE Case_IDNO = @An_Case_IDNO;

   SET @Ln_RowCount_QNTY = @@ROWCOUNT;

   IF @Ln_RowCount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'UPDATE CASE_Y1 FAILED';

     RAISERROR (50001,16,1);
    END

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = '';
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFail_CODE;
   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_ErrorMessage_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END;

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Routine_TEXT,
    @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;
  END CATCH
 END


GO
