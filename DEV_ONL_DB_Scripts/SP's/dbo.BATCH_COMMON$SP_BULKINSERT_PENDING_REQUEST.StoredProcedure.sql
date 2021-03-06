/****** Object:  StoredProcedure [dbo].[BATCH_COMMON$SP_BULKINSERT_PENDING_REQUEST]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_COMMON$SP_BULKINSERT_PENDING_REQUEST
Programmer Name		: IMP Team
Description			: This procedure is used to check the records in ICAS_Y1 for open cases for the given case id 
					  and calls BATCH_COMMON$SP_INSERT_PENDING_REQUEST for every record
Frequency			: 
Developed On		:	04/12/2011
Called By			:
Called On			:
--------------------------------------------------------------------------------------------------------------------
Modified By			:
Modified On			:
Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_COMMON$SP_BULKINSERT_PENDING_REQUEST]
 @An_Case_IDNO                NUMERIC(6),
 @Ac_Reason_CODE              CHAR(5),
 @An_TransactionEventSeq_NUMB NUMERIC(10),
 @Ad_Run_DATE                 DATE,
 @Ac_Job_ID                   CHAR(10),
 @Ac_SignedOnWorker_ID        CHAR(30),
 @Ac_Msg_CODE                 CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT    VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusFailed_CODE              CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE             CHAR(1) = 'S',
          @Lc_CaseMemberStatusActive_CODE    CHAR(1) = 'A',
          @Lc_CaseRelationshipNCP_CODE       CHAR(1) = 'A',
          @Lc_CaseRelationshipPutFather_CODE CHAR(1) = 'P',
          @Lc_CaseStatusOpen_CODE            CHAR(1) = 'O',
          @Lc_RespondInitInstate_CODE        CHAR(1) = 'N',
          @Lc_ActionProvide_CODE             CHAR(1) = 'P',
          @Lc_No_INDC                        CHAR(1) = 'N',
          @Lc_Space_TEXT                     CHAR(1) = ' ',
          @Lc_FunctionManageStateCase_CODE   CHAR(3) = 'MSC',
          @Lc_ErrorE0001_CODE                CHAR(5) = 'E0001',
          @Ls_Routine_TEXT                   VARCHAR(100) = 'BATCH_COMMON$SP_BULKINSERT_PENDING_REQUEST',
          @Ld_High_DATE                      DATE = '12/31/9999',
          @Ld_Low_DATE                       DATE = '01/01/0001';
  DECLARE @Ln_Error_NUMB           NUMERIC,
          @Ln_IcasFetchStatus_NUMB NUMERIC(2) = 0,
          @Ln_ErrorLine_NUMB       NUMERIC(11),
          @Lc_File_ID              CHAR(10),
          @Ls_Sql_TEXT             VARCHAR(100),
          @Ls_Sqldata_TEXT         VARCHAR(1000),
          @Ls_ErrorMessage_TEXT    VARCHAR(4000) = '',
          @Ld_Update_DTTM          DATE;
  DECLARE @Lc_IcasCur_IVDOutOfStateCase_ID         CHAR(15),
          @Lc_IcasCUR_IVDOutOfStateFips_CODE       CHAR(2),
          @Lc_IcasCUR_IVDOutOfStateOfficeFips_CODE CHAR(2),
          @Lc_IcasCUR_IVDOutOfStateCountyFips_CODE CHAR(3),
          @Ln_IcasCUR_MemberMci_IDNO               NUMERIC(10);
  DECLARE Icas_Cur INSENSITIVE CURSOR FOR
   SELECT DISTINCT
          ic.IVDOutOfStateCase_ID,
          ic.IVDOutOfStateFips_CODE,
          ic.IVDOutOfStateOfficeFips_CODE,
          ic.IVDOutOfStateCountyFips_CODE,
          c.MemberMci_IDNO
     FROM ICAS_Y1 ic
     JOIN CMEM_Y1 c
       ON c.Case_IDNO = ic.Case_IDNO
      AND c.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
      AND c.CaseRelationShip_CODE IN (@Lc_CaseRelationshipNCP_CODE, @Lc_CaseRelationshipPutFather_CODE) 
      AND c.MemberMCI_IDNO IN (ic.PetitionerMci_IDNO,ic.RespondentMci_IDNO)
    WHERE ic.Case_IDNO = @An_Case_IDNO
      AND ic.Status_CODE = @Lc_CaseStatusOpen_CODE
      AND ic.EndValidity_DATE = @Ld_High_DATE
      AND ic.IVDOutOfStateCase_ID != @Lc_Space_TEXT
      AND ic.Create_DATE < @Ad_Run_DATE;

  BEGIN TRY
   SET @Ld_Update_DTTM = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

   SELECT @Lc_File_ID = File_ID
     FROM CASE_Y1 cs
    WHERE Case_IDNO = @An_Case_IDNO
      AND StatusCase_CODE = @Lc_CaseStatusOpen_CODE
      AND RespondInit_CODE != @Lc_RespondInitInstate_CODE;

   OPEN Icas_Cur;

   FETCH NEXT FROM Icas_Cur INTO @Lc_IcasCur_IVDOutOfStateCase_ID, @Lc_IcasCUR_IVDOutOfStateFips_CODE, @Lc_IcasCUR_IVDOutOfStateOfficeFips_CODE, @Lc_IcasCUR_IVDOutOfStateCountyFips_CODE, @Ln_IcasCUR_MemberMci_IDNO;

   SET @Ln_IcasFetchStatus_NUMB = @@FETCH_STATUS;

   /*Icas_Cur cursor count*/
   WHILE @Ln_IcasFetchStatus_NUMB = 0
    BEGIN
     -- Update DelegateWorker_ID in DMNR_Y1
     SET @Ls_Sql_TEXT = 'EXECUTE BATCH_COMMON$SP_INSERT_PENDING_REQUEST';
     SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + CAST(@An_Case_IDNO AS VARCHAR) + ', TransactionEventSeq_NUMB = ' + CAST(@An_TransactionEventSeq_NUMB AS VARCHAR);

     EXECUTE BATCH_COMMON$SP_INSERT_PENDING_REQUEST
      @An_Case_IDNO                    = @An_Case_IDNO,
      @An_RespondentMci_IDNO           = @Ln_IcasCUR_MemberMci_IDNO,
      @Ac_Function_CODE                = @Lc_FunctionManageStateCase_CODE,
      @Ac_Action_CODE                  = @Lc_ActionProvide_CODE,
      @Ac_Reason_CODE                  = @Ac_Reason_CODE,
      @Ac_IVDOutOfStateFips_CODE       = @Lc_IcasCUR_IVDOutOfStateFips_CODE,
      @Ac_IVDOutOfStateCountyFips_CODE = @Lc_IcasCUR_IVDOutOfStateCountyFips_CODE,
      @Ac_IVDOutOfStateOfficeFips_CODE = @Lc_IcasCUR_IVDOutOfStateOfficeFips_CODE,
      @Ac_IVDOutOfStateCase_ID         = @Lc_IcasCur_IVDOutOfStateCase_ID,
      @Ad_Generated_DATE               = @Ad_Run_DATE,
      @Ac_Form_ID                      = @Lc_Space_TEXT,
      @As_FormWeb_URL                  = @Lc_Space_TEXT,
      @An_TransHeader_IDNO             = 0,
      @As_DescriptionComments_TEXT     = @Lc_Space_TEXT,
      @Ac_CaseFormer_ID                = @Lc_Space_TEXT,
      @Ac_InsCarrier_NAME              = @Lc_Space_TEXT,
      @Ac_InsPolicyNo_TEXT             = @Lc_Space_TEXT,
      @Ad_Hearing_DATE                 = @Ld_Low_DATE,
      @Ad_Dismissal_DATE               = @Ld_Low_DATE,
      @Ad_GeneticTest_DATE             = @Ld_Low_DATE,
      @Ad_PfNoShow_DATE                = @Ld_Low_DATE,
      @Ac_Attachment_INDC              = @Lc_No_INDC,
      @Ac_File_ID                      = @Lc_File_ID,
      @Ad_ArrearComputed_DATE          = @Ld_Low_DATE,
      @An_TotalArrearsOwed_AMNT        = 0,
      @An_TotalInterestOwed_AMNT       = 0,
      @Ac_Process_ID                   = @Ac_Job_ID,
      @Ad_BeginValidity_DATE           = @Ad_Run_DATE,
      @Ac_SignedOnWorker_ID            = @Ac_SignedOnWorker_ID,
      @Ad_Update_DTTM                  = @Ld_Update_DTTM,
      @Ac_Msg_CODE                     = @Ac_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT        = @As_DescriptionError_TEXT OUTPUT;

     IF @Ac_Msg_CODE != @Lc_StatusSuccess_CODE
      BEGIN
       SET @Ac_Msg_CODE = @Lc_ErrorE0001_CODE;
       SET @As_DescriptionError_TEXT = 'Error IN ' + 'BATCH_COMMON$SP_BULKINSERT_PENDING_REQUEST' + ' PROCEDURE ' + '. Error DESC - ' + @As_DescriptionError_TEXT + '. Error EXECUTE Location - ' + @Ls_Sql_TEXT + ' . Error List KEY - ' + @Ls_Sqldata_TEXT;

       RETURN;
      END

     FETCH NEXT FROM Icas_Cur INTO @Lc_IcasCur_IVDOutOfStateCase_ID, @Lc_IcasCUR_IVDOutOfStateFips_CODE, @Lc_IcasCUR_IVDOutOfStateOfficeFips_CODE, @Lc_IcasCUR_IVDOutOfStateCountyFips_CODE, @Ln_IcasCUR_MemberMci_IDNO;

     SET @Ln_IcasFetchStatus_NUMB = @@FETCH_STATUS;
    END

   CLOSE Icas_Cur;

   DEALLOCATE Icas_Cur;

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   BEGIN
    IF CURSOR_STATUS ('VARIABLE', 'Icas_Cur') IN (0, 1)
     BEGIN
      CLOSE Icas_Cur;

      DEALLOCATE Icas_Cur;
     END

    SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
    SET @Ls_ErrorMessage_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    SET @Ln_Error_NUMB = ERROR_NUMBER();
    SET @Ln_ErrorLine_NUMB = ERROR_LINE();

    --Check for Exception information to log the description text based on the error
    EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
     @As_Procedure_NAME        = @Ls_Routine_TEXT,
     @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
     @As_Sql_TEXT              = @Ls_Sql_TEXT,
     @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
     @An_Error_NUMB            = @Ln_Error_NUMB,
     @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
     @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;
   END
  END CATCH
 END


GO
