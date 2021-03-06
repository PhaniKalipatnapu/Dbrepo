/****** Object:  StoredProcedure [dbo].[BATCH_COMMON$SP_INSERT_PENDING_REQUEST]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_COMMON$SP_INSERT_PENDING_REQUEST
Programmer Name	:	IMP Team.
Description		:	This procedure is used to insert the pending request details into csenet_pending_requests table.
Frequency		:	
Developed On	:	04/04/2011
Called By		:	
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_COMMON$SP_INSERT_PENDING_REQUEST](
 @An_Case_IDNO                    NUMERIC(6),
 @An_RespondentMci_IDNO           NUMERIC(10),
 @Ac_Function_CODE                CHAR(3),
 @Ac_Action_CODE                  CHAR(1),
 @Ac_Reason_CODE                  CHAR(5),
 @Ac_IVDOutOfStateFips_CODE       CHAR(2),
 @Ac_IVDOutOfStateCountyFips_CODE CHAR(3),
 @Ac_IVDOutOfStateOfficeFips_CODE CHAR(2),
 @Ac_IVDOutOfStateCase_ID         CHAR(15),
 @Ad_Generated_DATE               DATE,
 @Ac_Form_ID                      CHAR(15),
 @As_FormWeb_URL                  VARCHAR(1000),
 @An_TransHeader_IDNO             NUMERIC(12),
 @As_DescriptionComments_TEXT     VARCHAR(1000),
 @Ac_CaseFormer_ID                CHAR(6),
 @Ac_InsCarrier_NAME              CHAR(36),
 @Ac_InsPolicyNo_TEXT             CHAR(30),
 @Ad_Hearing_DATE                 DATE,
 @Ad_Dismissal_DATE               DATE,
 @Ad_GeneticTest_DATE             DATE,
 @Ad_PfNoShow_DATE                DATE,
 @Ac_Attachment_INDC              CHAR(1),
 @Ac_File_ID                      CHAR(15),
 @Ad_ArrearComputed_DATE          DATE,
 @An_TotalArrearsOwed_AMNT        NUMERIC(11, 2),
 @An_TotalInterestOwed_AMNT       NUMERIC(11, 2),
 @Ac_Process_ID                   CHAR(10),
 @Ad_BeginValidity_DATE           DATE,
 @Ac_SignedonWorker_ID            CHAR(30),
 @Ad_Update_DTTM                  DATETIME2,
 @An_TransactionEventSeq_NUMB     NUMERIC (19) = 0,
 @Ac_Msg_CODE                     CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT        VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_CaseStatusOpen_CODE            CHAR(1) = 'O',
          @Lc_Yes_INDC                       CHAR(1) = 'Y',
          @Lc_ActionRequest_CODE             CHAR(1) = 'R',
          @Lc_StatusSuccessS_CODE            CHAR(1) = 'S',
          @Lc_Space_TEXT                     CHAR(1) = ' ',
          @Lc_StatusFailedF_CODE             CHAR(1) = 'F',
          @Lc_ActionAcknowledgment_CODE      CHAR(1) = 'A',
          @Lc_ExchangeModeCsenet_CODE        CHAR(1) = 'C',
          @Lc_ExchangeModePaper_CODE         CHAR(1) = 'P',
          @Lc_ActionP_CODE                   CHAR(1) = 'P',
          @Lc_No_INDC                        CHAR(1) = 'N',
          @Lc_StatusRequestPending_CODE      CHAR(2) = 'PN',
          @Lc_OthOfficeFips00_CODE           CHAR(2) = '00',
          @Lc_RefAssistR_CODE                CHAR(2) = 'R',
          @Lc_StatusRequestPn_CODE           CHAR(2) = 'PN',
          @Lc_FunctionCasesummary_CODE       CHAR(3) = 'CSI',
          @Lc_FunctionEstablishment_CODE     CHAR(3) = 'EST',
          @Lc_OthCountyFips000_CODE          CHAR(3) = '000',
          @Lc_FunctionMsc_CODE               CHAR(3) = 'MSC',
          @Lc_SubsystemInterstate_CODE       CHAR(3) = 'IN',
          @Lc_RemedyStatusComplete_CODE      CHAR(4) = 'COMP',
          @Lc_RemedyStatusStart_CODE         CHAR(4) = 'STRT',
          @Lc_MajorActivityCase_CODE         CHAR(4) = 'CASE',
          @Lc_FarProvidstatusupdat_CODE      CHAR(5) = 'GSPUD',
          @Lc_FarRequestInterestCharges_CODE CHAR(5) = 'GSTAI',
          @Lc_ActivityMinorCod25_CODE        CHAR(5) = 'COD25',
          @Lc_ActivityMinorCod30_CODE        CHAR(5) = 'COD30',
          @Lc_ActivityMinorEadin_CODE        CHAR(5) = 'EADIN',
          @Lc_ActivityMinorErpou_CODE        CHAR(5) = 'ERPOU',
          @Lc_ActivityMinorLsout_CODE        CHAR(5) = 'LSOUT',
          @Lc_ActivityMinorMrbtr_CODE        CHAR(5) = 'MRBTR',
          @Lc_ActivityMinorMrupd_CODE        CHAR(5) = 'MRUPD',
          @Lc_ActivityMinorMsc14_CODE        CHAR(5) = 'MSC14',
          @Lc_ActivityMinorPadin_CODE        CHAR(5) = 'PADIN',
          @Lc_ActivityMinorPmbla_CODE        CHAR(5) = 'PMBLA',
          @Lc_ActivityMinorPrpou_CODE        CHAR(5) = 'PRPOU',
          @Lc_ActivityMinorPuden_CODE        CHAR(5) = 'PUDEN',
          @Lc_ActivityMinorTadin_CODE        CHAR(5) = 'TADIN',
          @Lc_ActivityMinorTcdis_CODE        CHAR(5) = 'TCDIS',
          @Lc_ActivityMinorTrpou_CODE        CHAR(5) = 'TRPOU',
          @Lc_ActivityMinorGrint_CODE        CHAR(5) = 'GRINT',
          @Lc_ReasonAadin_CODE               CHAR(5) = 'AADIN',
          @Lc_ReasonAnoad_CODE               CHAR(5) = 'ANOAD',
          @Lc_ActivityMinorTradj_CODE        CHAR(5) = 'TRADJ',
          @Lc_ActivityMinorTrmod_CODE        CHAR(5) = 'TRMOD',
          @Lc_ActivityMinorSaout_CODE        CHAR(5) = 'SAOUT',
          @Lc_ErrorW0156_CODE                CHAR(5) = 'W0156',
          @Ls_BatchRunUser_TEXT              VARCHAR(50) = 'BATCH',
          @Ls_Procedure_NAME                 VARCHAR(100) = 'BATCH_COMMON$SP_INSERT_PENDING_REQUEST',
          @Ld_High_DATE                      DATE = '12/31/9999',
          @Ld_Low_DATE                       DATE = '01/01/0001';
  DECLARE @Ln_Rowcount_QNTY                NUMERIC,
          @Ln_FetchStatus_QNTY             NUMERIC,
          @Ln_Error_NUMB                   NUMERIC,
          @Ln_ErrorLine_NUMB               NUMERIC,
          @Ln_Zero_NUMB                    NUMERIC(1) = 0,
          @Ln_Cur_NUMB                     NUMERIC(6) = 0,
          @Ln_QNTY                         NUMERIC(10),
          @Ln_TransactionEventSeq_NUMB     NUMERIC(19),
          @Lc_CertMode_INDC                CHAR(1),
          @Lc_IVDOutOfStateOfficeFips_CODE CHAR(2),
          @Lc_IVDOutOfStateCountyFips_CODE CHAR(3),
          @Lc_Msg_CODE                     CHAR(5),
          @Lc_IVDOutOfStateCase_ID         CHAR(15),
          @Ls_Sql_TEXT                     VARCHAR(100),
          @Ls_Sqldata_TEXT                 VARCHAR(1000),
          @Ls_ErrorMessage_TEXT            VARCHAR(4000);
  DECLARE @Ln_CsenetCur_Request_IDNO             NUMERIC(9),
          @Ld_CsenetCur_Generated_DATE           DATE,
          @Lc_CsenetCur_IVDOutOfStateFips_CODE   CHAR(2),
          @Lc_CsenetCur_Case_IDNO                CHAR(6),
          @Lc_CsenetCur_ActivityMinor_CODE       CHAR(5),
          @Ln_CsenetCur_TransactionEventSeq_NUMB NUMERIC(19);
  DECLARE @Lc_CSFipsCur_IVDOutOfStateFips_CODE       CHAR(2),
          @Lc_CSFipsCur_IVDOutOfStateCountyFips_CODE CHAR(3),
          @Lc_CSFipsCur_IVDOutOfStateOfficeFips_CODE CHAR(2),
          @Lc_CSFipsCur_IVDOutOfStateCase_ID         CHAR(15),
          @Ln_CSFipsCur_RespondentMci_IDNO           NUMERIC(10);

  IF @An_RespondentMci_IDNO = 0
   BEGIN
    SET @Ls_Sql_TEXT = 'ASSIGNING RESPONDENT MCI';
    SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

    SELECT TOP 1 @An_RespondentMci_IDNO = RespondentMci_IDNO
      FROM ICAS_Y1 i
     WHERE Case_IDNO = @An_Case_IDNO
       AND EndValidity_DATE = @Ld_High_DATE;
   END;

  IF @Ac_IVDOutOfStateFips_CODE IS NULL
   BEGIN
    SET @Ac_IVDOutOfStateFips_CODE = @Lc_Space_TEXT;
   END;

  IF @Ad_ArrearComputed_DATE IS NULL
   BEGIN
    SET @Ad_ArrearComputed_DATE = @Ld_Low_DATE;
   END;

  SET @Ac_IVDOutOfStateFips_CODE = LTRIM(RTRIM(@Ac_IVDOutOfStateFips_CODE));

 /* Cursor For State fips, County fips, Office fips selection for Case */
  -- case_state_fips_cur
  DECLARE CSFips_Cur INSENSITIVE CURSOR FOR
   SELECT DISTINCT
          i.IVDOutOfStateFips_CODE,
          i.IVDOutOfStateCountyFips_CODE,
          i.IVDOutOfStateOfficeFips_CODE,
          i.IVDOutOfStateCase_ID,
          i.RespondentMci_IDNO
     FROM ICAS_Y1 i
    WHERE i.Case_IDNO = @An_Case_IDNO
      AND (@An_RespondentMci_IDNO = 0
            OR i.RespondentMci_IDNO = @An_RespondentMci_IDNO)
      AND (@Ac_IVDOutOfStateFips_CODE = @Lc_Space_TEXT
            OR i.IVDOutOfStateFips_CODE = @Ac_IVDOutOfStateFips_CODE)
      AND i.Status_CODE = @Lc_CaseStatusOpen_CODE
      AND i.EndValidity_DATE = @Ld_High_DATE;

  BEGIN TRY
   SET @Ac_Msg_CODE = '';
   SET @As_DescriptionError_TEXT = '';

   IF LTRIM(RTRIM(@Ac_IVDOutOfStateFips_CODE)) != @Lc_Space_TEXT
    BEGIN
     -- To select the exchange mode for the state fips
     SET @Ls_Sql_TEXT = 'SELECT CSEP_Y1.ExchangeMode_CODE - 1';
     SET @Ls_Sqldata_TEXT = 'IVDOutOfStateFips_CODE = ' + ISNULL(@Ac_IVDOutOfStateFips_CODE, '') + ', Function_CODE = ' + ISNULL(@Ac_Function_CODE, '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

     SELECT @Lc_CertMode_INDC = CASE c.CertMode_INDC
                                 WHEN @Lc_Yes_INDC
                                  THEN @Lc_ExchangeModeCsenet_CODE
                                 ELSE @Lc_ExchangeModePaper_CODE
                                END
       FROM CSEP_Y1 c
      WHERE c.IVDOutOfStateFips_CODE = @Ac_IVDOutOfStateFips_CODE
        AND c.Function_CODE = @Ac_Function_CODE
        AND c.EndValidity_DATE = @Ld_High_DATE;

     SET @Ln_Rowcount_QNTY = @@ROWCOUNT;

     IF @Ln_Rowcount_QNTY = @Ln_Zero_NUMB
      BEGIN
       SET @Lc_CertMode_INDC = @Lc_ExchangeModePaper_CODE;
      END;

     IF (@Ac_Function_CODE != @Lc_FunctionCasesummary_CODE
         AND @Ac_Action_CODE = @Lc_ActionRequest_CODE)
      BEGIN
       SET @Ls_Sql_TEXT = 'COUNT - 1';
       SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '') + ', RespondentMci_IDNO = ' + ISNULL(CAST(@An_RespondentMci_IDNO AS VARCHAR), '') + ', Function_CODE = ' + ISNULL(@Ac_Function_CODE, '') + ', Action_CODE = ' + ISNULL(@Ac_Action_CODE, '') + ', Reason_CODE = ' + ISNULL(@Ac_Reason_CODE, '') + ', StatusRequest_CODE = ' + ISNULL(@Lc_StatusRequestPending_CODE, '') + ', IVDOutOfStateFips_CODE = ' + ISNULL(@Ac_IVDOutOfStateFips_CODE, '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

       SELECT @Ln_QNTY = COUNT (1)
         FROM CSPR_Y1 c
        WHERE c.Case_IDNO = @An_Case_IDNO
          AND c.RespondentMci_IDNO = @An_RespondentMci_IDNO
          AND c.Function_CODE = @Ac_Function_CODE
          AND c.Action_CODE = @Ac_Action_CODE
          AND c.Reason_CODE = @Ac_Reason_CODE
          AND c.Generated_DATE = ISNULL (@Ad_Generated_DATE, dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME())
          AND c.StatusRequest_CODE = @Lc_StatusRequestPending_CODE
          AND c.IVDOutOfStateFips_CODE = @Ac_IVDOutOfStateFips_CODE
          AND c.EndValidity_DATE = @Ld_High_DATE;

       IF (@Ln_QNTY > 0)
        BEGIN
         SET @Ac_Msg_CODE = @Lc_StatusSuccessS_CODE;

         RETURN;
        END;
      END;
     ELSE
      BEGIN
       SET @Ls_Sql_TEXT = 'COUNT - 2';
       SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '') + ', RespondentMci_IDNO = ' + ISNULL(CAST(@An_RespondentMci_IDNO AS VARCHAR), '') + ', Function_CODE = ' + ISNULL(@Ac_Function_CODE, '') + ', Action_CODE = ' + ISNULL(@Ac_Action_CODE, '') + ', Reason_CODE = ' + ISNULL(@Ac_Reason_CODE, '') + ', StatusRequest_CODE = ' + ISNULL(@Lc_StatusRequestPending_CODE, '') + ', IVDOutOfStateFips_CODE = ' + ISNULL(@Ac_IVDOutOfStateFips_CODE, '') + ', IVDOutOfStateCase_ID = ' + ISNULL(@Ac_IVDOutOfStateCase_ID, '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

       SELECT @Ln_QNTY = COUNT (1)
         FROM CSPR_Y1 c
        WHERE c.Case_IDNO = @An_Case_IDNO
          AND c.RespondentMci_IDNO = @An_RespondentMci_IDNO
          AND c.Function_CODE = @Ac_Function_CODE
          AND c.Action_CODE = @Ac_Action_CODE
          AND c.Reason_CODE = @Ac_Reason_CODE
          AND c.Generated_DATE = ISNULL (@Ad_Generated_DATE, dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME())
          AND c.StatusRequest_CODE = @Lc_StatusRequestPending_CODE
          AND c.IVDOutOfStateFips_CODE = @Ac_IVDOutOfStateFips_CODE
          AND c.IVDOutOfStateCase_ID = @Ac_IVDOutOfStateCase_ID
          AND c.EndValidity_DATE = @Ld_High_DATE;

       IF (@Ln_QNTY > 0)
        BEGIN
         SET @Ac_Msg_CODE = @Lc_StatusSuccessS_CODE;

         RETURN;
        END;
      END;

     SET @Ln_TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB;

     IF @An_TransactionEventSeq_NUMB = 0
      BEGIN
       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT - 1';
       SET @Ls_Sqldata_TEXT = 'Worker_ID = ' + ISNULL(@Ls_BatchRunUser_TEXT, '') + ', Process_ID = ' + ISNULL(@Ac_Process_ID, '') + ', EffectiveEvent_DATE = ' + ISNULL(CAST(@Ad_Generated_DATE AS VARCHAR), '') + ', Note_INDC = ' + ISNULL(@Lc_No_INDC, '') + ', EventFunctionalSeq_NUMB = ' + ISNULL('0', '');

       EXECUTE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
        @Ac_Worker_ID                = @Ls_BatchRunUser_TEXT,
        @Ac_Process_ID               = @Ac_Process_ID,
        @Ad_EffectiveEvent_DATE      = @Ad_Generated_DATE,
        @Ac_Note_INDC                = @Lc_No_INDC,
        @An_EventFunctionalSeq_NUMB  = 0,
        @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
        @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT    = @Ls_ErrorMessage_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailedF_CODE
        BEGIN
         RAISERROR (50001,16,1);
        END;
      END

     BEGIN
      -- To select the existing county fips, office fips and other state case
      SET @Ls_Sql_TEXT = 'SELECT ICAS_Y1 DETAILS';
      SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '') + ', IVDOutOfStateFips_CODE = ' + ISNULL(@Ac_IVDOutOfStateFips_CODE, '') + ', RespondentMci_IDNO = ' + ISNULL(CAST(@An_RespondentMci_IDNO AS VARCHAR), '') + ', Status_CODE = ' + ISNULL(@Lc_CaseStatusOpen_CODE, '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

      SELECT TOP (1) @Lc_IVDOutOfStateCountyFips_CODE = ISNULL (dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR (i.IVDOutOfStateCountyFips_CODE), @Lc_OthCountyFips000_CODE),
                     @Lc_IVDOutOfStateOfficeFips_CODE = ISNULL (dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR (i.IVDOutOfStateOfficeFips_CODE), @Lc_OthOfficeFips00_CODE),
                     @Lc_IVDOutOfStateCase_ID = i.IVDOutOfStateCase_ID
        FROM ICAS_Y1 i
       WHERE i.Case_IDNO = @An_Case_IDNO
         AND i.IVDOutOfStateFips_CODE = @Ac_IVDOutOfStateFips_CODE
         AND i.RespondentMci_IDNO = @An_RespondentMci_IDNO
         AND i.Status_CODE = @Lc_CaseStatusOpen_CODE
         AND i.EndValidity_DATE = @Ld_High_DATE;

      SET @Ln_Rowcount_QNTY = @@ROWCOUNT;

      IF @Ln_Rowcount_QNTY = @Ln_Zero_NUMB
       BEGIN
        SET @Lc_IVDOutOfStateCountyFips_CODE = @Lc_OthCountyFips000_CODE;
        SET @Lc_IVDOutOfStateOfficeFips_CODE = @Lc_OthOfficeFips00_CODE;
        SET @Lc_IVDOutOfStateCase_ID = @Lc_Space_TEXT;
       END;
     END;

     SET @Ls_Sql_TEXT = 'INSERT INTO CSPR_Y1 - 1';
     SET @Ls_Sqldata_TEXT = 'Generated_DATE = ' + ISNULL(CAST(@Ad_Generated_DATE AS VARCHAR), '') + ', Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '') + ', IVDOutOfStateFips_CODE = ' + ISNULL(@Ac_IVDOutOfStateFips_CODE, '') + ', ExchangeMode_INDC = ' + ISNULL(@Lc_CertMode_INDC, '') + ', StatusRequest_CODE = ' + ISNULL(@Lc_StatusRequestPending_CODE, '') + ', Form_ID = ' + ISNULL(@Ac_Form_ID, '') + ', FormWeb_URL = ' + ISNULL(@As_FormWeb_URL, '') + ', TransHeader_IDNO = ' + ISNULL(CAST(@An_TransHeader_IDNO AS VARCHAR), '') + ', Function_CODE = ' + ISNULL(@Ac_Function_CODE, '') + ', Action_CODE = ' + ISNULL(@Ac_Action_CODE, '') + ', Reason_CODE = ' + ISNULL(@Ac_Reason_CODE, '') + ', CaseFormer_ID = ' + ISNULL(@Ac_CaseFormer_ID, '') + ', InsCarrier_NAME = ' + ISNULL(@Ac_InsCarrier_NAME, '') + ', InsPolicyNo_TEXT = ' + ISNULL(@Ac_InsPolicyNo_TEXT, '') + ', Hearing_DATE = ' + ISNULL(CAST(@Ad_Hearing_DATE AS VARCHAR), '') + ', Dismissal_DATE = ' + ISNULL(CAST(@Ad_Dismissal_DATE AS VARCHAR), '') + ', GeneticTest_DATE = ' + ISNULL(CAST(@Ad_GeneticTest_DATE AS VARCHAR), '') + ', PfNoShow_DATE = ' + ISNULL(CAST(@Ad_PfNoShow_DATE AS VARCHAR), '') + ', Attachment_INDC = ' + ISNULL(@Ac_Attachment_INDC, '') + ', BeginValidity_DATE = ' + ISNULL(CAST(@Ad_BeginValidity_DATE AS VARCHAR), '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '') + ', WorkerUpdate_ID = ' + ISNULL(@Ac_SignedonWorker_ID, '') + ', Update_DTTM = ' + ISNULL(CAST(@Ad_Update_DTTM AS VARCHAR), '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', File_ID = ' + ISNULL(@Ac_File_ID, '') + ', ArrearComputed_DATE = ' + ISNULL(CAST(@Ad_ArrearComputed_DATE AS VARCHAR), '') + ', TotalInterestOwed_AMNT = ' + ISNULL(CAST(@An_TotalInterestOwed_AMNT AS VARCHAR), '') + ', TotalArrearsOwed_AMNT = ' + ISNULL(CAST(@An_TotalArrearsOwed_AMNT AS VARCHAR), '') + ', RespondentMci_IDNO = ' + ISNULL(CAST(@An_RespondentMci_IDNO AS VARCHAR), '');

     --Insert the values to CSPR_Y1
     INSERT CSPR_Y1
            (Generated_DATE,
             Case_IDNO,
             IVDOutOfStateFips_CODE,
             IVDOutOfStateCountyFips_CODE,
             IVDOutOfStateOfficeFips_CODE,
             IVDOutOfStateCase_ID,
             ExchangeMode_INDC,
             StatusRequest_CODE,
             Form_ID,
             FormWeb_URL,
             TransHeader_IDNO,
             Function_CODE,
             Action_CODE,
             Reason_CODE,
             DescriptionComments_TEXT,
             CaseFormer_ID,
             InsCarrier_NAME,
             InsPolicyNo_TEXT,
             Hearing_DATE,
             Dismissal_DATE,
             GeneticTest_DATE,
             PfNoShow_DATE,
             Attachment_INDC,
             BeginValidity_DATE,
             EndValidity_DATE,
             WorkerUpdate_ID,
             Update_DTTM,
             TransactionEventSeq_NUMB,
             File_ID,
             ArrearComputed_DATE,
             TotalInterestOwed_AMNT,
             TotalArrearsOwed_AMNT,
             RespondentMci_IDNO)
     VALUES ( @Ad_Generated_DATE,--Generated_DATE
              @An_Case_IDNO,--Case_IDNO
              RIGHT(REPLICATE('0', 2) + LTRIM(RTRIM(@Ac_IVDOutOfStateFips_CODE)), 2),--IVDOutOfStateFips_CODE
              ISNULL (dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR (RIGHT(REPLICATE('0', 3) + LTRIM(RTRIM(@Ac_IVDOutOfStateCountyFips_CODE)), 3)), @Lc_IVDOutOfStateCountyFips_CODE),--IVDOutOfStateCountyFips_CODE
              ISNULL (dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR (RIGHT(REPLICATE('0', 2) + LTRIM(RTRIM(@Ac_IVDOutOfStateOfficeFips_CODE)), 2)), @Lc_IVDOutOfStateOfficeFips_CODE),--IVDOutOfStateOfficeFips_CODE
              ISNULL (dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR (@Ac_IVDOutOfStateCase_ID), @Lc_IVDOutOfStateCase_ID),--IVDOutOfStateCase_ID
              @Lc_CertMode_INDC,--ExchangeMode_INDC
              @Lc_StatusRequestPending_CODE,--StatusRequest_CODE
              @Ac_Form_ID,--Form_ID
              @As_FormWeb_URL,--FormWeb_URL
              @An_TransHeader_IDNO,--TransHeader_IDNO
              @Ac_Function_CODE,--Function_CODE
              @Ac_Action_CODE,--Action_CODE
              @Ac_Reason_CODE,--Reason_CODE
              REPLACE (REPLACE (@As_DescriptionComments_TEXT, CHAR (10), @Lc_Space_TEXT), CHAR (13), @Lc_Space_TEXT),--DescriptionComments_TEXT
              @Ac_CaseFormer_ID,--CaseFormer_ID
              @Ac_InsCarrier_NAME,--InsCarrier_NAME
              @Ac_InsPolicyNo_TEXT,--InsPolicyNo_TEXT
              @Ad_Hearing_DATE,--Hearing_DATE
              @Ad_Dismissal_DATE,--Dismissal_DATE
              @Ad_GeneticTest_DATE,--GeneticTest_DATE
              @Ad_PfNoShow_DATE,--PfNoShow_DATE
              @Ac_Attachment_INDC,--Attachment_INDC
              @Ad_BeginValidity_DATE,--BeginValidity_DATE
              @Ld_High_DATE,--EndValidity_DATE
              @Ac_SignedonWorker_ID,--WorkerUpdate_ID
              @Ad_Update_DTTM,--Update_DTTM
              @Ln_TransactionEventSeq_NUMB,--TransactionEventSeq_NUMB
              @Ac_File_ID,--File_ID
              @Ad_ArrearComputed_DATE,--ArrearComputed_DATE
              @An_TotalInterestOwed_AMNT,--TotalInterestOwed_AMNT
              @An_TotalArrearsOwed_AMNT,--TotalArrearsOwed_AMNT
              @An_RespondentMci_IDNO); --RespondentMci_IDNO
     SET @Ln_Rowcount_QNTY = @@ROWCOUNT;

     IF @Ln_Rowcount_QNTY = @Ln_Zero_NUMB
      BEGIN
       SET @Ls_ErrorMessage_TEXT = 'INSERT CSPR_Y1 FAILED';

       RAISERROR (50001,16,1);
      END;
    END;
   ELSE
    BEGIN
     OPEN CSFips_Cur;

     FETCH NEXT FROM CSFips_Cur INTO @Lc_CSFipsCur_IVDOutOfStateFips_CODE, @Lc_CSFipsCur_IVDOutOfStateCountyFips_CODE, @Lc_CSFipsCur_IVDOutOfStateOfficeFips_CODE, @Lc_CSFipsCur_IVDOutOfStateCase_ID, @Ln_CSFipsCur_RespondentMci_IDNO;

     SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;

     --FETCH EACH RECORD
     WHILE @Ln_FetchStatus_QNTY = 0
      BEGIN
       SET @Ln_Cur_NUMB = @Ln_Cur_NUMB + 1;
       SET @Ls_Sql_TEXT = 'COUNT - 3';
       SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '') + ', Function_CODE = ' + ISNULL(@Ac_Function_CODE, '') + ', Action_CODE = ' + ISNULL(@Ac_Action_CODE, '') + ', Reason_CODE = ' + ISNULL(@Ac_Reason_CODE, '') + ', RespondentMci_IDNO = ' + ISNULL(CAST(@Ln_CSFipsCur_RespondentMci_IDNO AS VARCHAR), '') + ', StatusRequest_CODE = ' + ISNULL(@Lc_StatusRequestPending_CODE, '') + ', IVDOutOfStateFips_CODE = ' + ISNULL(@Lc_CSFipsCur_IVDOutOfStateFips_CODE, '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

       SELECT @Ln_QNTY = COUNT (1)
         FROM CSPR_Y1 c
        WHERE c.Case_IDNO = @An_Case_IDNO
          AND c.Function_CODE = @Ac_Function_CODE
          AND c.Action_CODE = @Ac_Action_CODE
          AND c.Reason_CODE = @Ac_Reason_CODE
          AND c.RespondentMci_IDNO = @Ln_CSFipsCur_RespondentMci_IDNO
          AND c.Generated_DATE = ISNULL(@Ad_Generated_DATE, dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME())
          AND c.StatusRequest_CODE = @Lc_StatusRequestPending_CODE
          AND c.IVDOutOfStateFips_CODE = @Lc_CSFipsCur_IVDOutOfStateFips_CODE
          AND c.EndValidity_DATE = @Ld_High_DATE;

       IF (@Ln_QNTY = 0)
        BEGIN
         SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT - 2';
         SET @Ls_Sqldata_TEXT = 'Worker_ID = ' + ISNULL(@Ls_BatchRunUser_TEXT, '') + ', Process_ID = ' + ISNULL(@Ac_Process_ID, '') + ', EffectiveEvent_DATE = ' + ISNULL(CAST(@Ad_Generated_DATE AS VARCHAR), '') + ', Note_INDC = ' + ISNULL(@Lc_No_INDC, '') + ', EventFunctionalSeq_NUMB = ' + ISNULL('0', '');

         EXECUTE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
          @Ac_Worker_ID                = @Ls_BatchRunUser_TEXT,
          @Ac_Process_ID               = @Ac_Process_ID,
          @Ad_EffectiveEvent_DATE      = @Ad_Generated_DATE,
          @Ac_Note_INDC                = @Lc_No_INDC,
          @An_EventFunctionalSeq_NUMB  = 0,
          @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
          @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
          @As_DescriptionError_TEXT    = @Ls_ErrorMessage_TEXT OUTPUT;

         IF @Lc_Msg_CODE = @Lc_StatusFailedF_CODE
          BEGIN
           RAISERROR (50001,16,1);
          END;

         BEGIN
          -- To select the exchange mode for the state fips
          SET @Ls_Sql_TEXT = 'SELECT CSEP_Y1.ExchangeMode_CODE - 2';
          SET @Ls_Sqldata_TEXT = 'IVDOutOfStateFips_CODE = ' + ISNULL(@Lc_CSFipsCur_IVDOutOfStateFips_CODE, '') + ', Function_CODE = ' + ISNULL(@Ac_Function_CODE, '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

          SELECT @Lc_CertMode_INDC = CASE c.CertMode_INDC
                                      WHEN @Lc_Yes_INDC
                                       THEN @Lc_ExchangeModeCsenet_CODE
                                      ELSE @Lc_ExchangeModePaper_CODE
                                     END
            FROM CSEP_Y1 c
           WHERE c.IVDOutOfStateFips_CODE = @Lc_CSFipsCur_IVDOutOfStateFips_CODE
             AND c.Function_CODE = @Ac_Function_CODE
             AND c.EndValidity_DATE = @Ld_High_DATE;

          SET @Ln_Rowcount_QNTY = @@ROWCOUNT;

          IF @Ln_Rowcount_QNTY = @Ln_Zero_NUMB
           BEGIN
            SET @Lc_CertMode_INDC = @Lc_ExchangeModePaper_CODE;
           END;
         END;

         SET @Ls_Sql_TEXT = 'INSERT INTO CSPR_Y1 - 2';
         SET @Ls_Sqldata_TEXT = 'Generated_DATE = ' + ISNULL(CAST(@Ad_Generated_DATE AS VARCHAR), '') + ', Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '') + ', IVDOutOfStateFips_CODE = ' + ISNULL(@Lc_CSFipsCur_IVDOutOfStateFips_CODE, '') + ', IVDOutOfStateCase_ID = ' + ISNULL(@Lc_CSFipsCur_IVDOutOfStateCase_ID, '') + ', ExchangeMode_INDC = ' + ISNULL(@Lc_CertMode_INDC, '') + ', StatusRequest_CODE = ' + ISNULL(@Lc_StatusRequestPending_CODE, '') + ', Form_ID = ' + ISNULL(@Ac_Form_ID, '') + ', FormWeb_URL = ' + ISNULL(@As_FormWeb_URL, '') + ', TransHeader_IDNO = ' + ISNULL(CAST(@An_TransHeader_IDNO AS VARCHAR), '') + ', Function_CODE = ' + ISNULL(@Ac_Function_CODE, '') + ', Action_CODE = ' + ISNULL(@Ac_Action_CODE, '') + ', Reason_CODE = ' + ISNULL(@Ac_Reason_CODE, '') + ', DescriptionComments_TEXT = ' + ISNULL(@As_DescriptionComments_TEXT, '') + ', CaseFormer_ID = ' + ISNULL(@Ac_CaseFormer_ID, '') + ', InsCarrier_NAME = ' + ISNULL(@Ac_InsCarrier_NAME, '') + ', InsPolicyNo_TEXT = ' + ISNULL(@Ac_InsPolicyNo_TEXT, '') + ', Hearing_DATE = ' + ISNULL(CAST(@Ad_Hearing_DATE AS VARCHAR), '') + ', Dismissal_DATE = ' + ISNULL(CAST(@Ad_Dismissal_DATE AS VARCHAR), '') + ', GeneticTest_DATE = ' + ISNULL(CAST(@Ad_GeneticTest_DATE AS VARCHAR), '') + ', PfNoShow_DATE = ' + ISNULL(CAST(@Ad_PfNoShow_DATE AS VARCHAR), '') + ', Attachment_INDC = ' + ISNULL(@Ac_Attachment_INDC, '') + ', BeginValidity_DATE = ' + ISNULL(CAST(@Ad_BeginValidity_DATE AS VARCHAR), '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '') + ', WorkerUpdate_ID = ' + ISNULL(@Ac_SignedonWorker_ID, '') + ', Update_DTTM = ' + ISNULL(CAST(@Ad_Update_DTTM AS VARCHAR), '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', File_ID = ' + ISNULL(@Ac_File_ID, '') + ', ArrearComputed_DATE = ' + ISNULL(CAST(@Ad_ArrearComputed_DATE AS VARCHAR), '') + ', TotalInterestOwed_AMNT = ' + ISNULL(CAST(@An_TotalInterestOwed_AMNT AS VARCHAR), '') + ', TotalArrearsOwed_AMNT = ' + ISNULL(CAST(@An_TotalArrearsOwed_AMNT AS VARCHAR), '') + ', RespondentMci_IDNO = ' + ISNULL(CAST(@Ln_CSFipsCur_RespondentMci_IDNO AS VARCHAR), '');

         INSERT CSPR_Y1
                (Generated_DATE,
                 Case_IDNO,
                 IVDOutOfStateFips_CODE,
                 IVDOutOfStateCountyFips_CODE,
                 IVDOutOfStateOfficeFips_CODE,
                 IVDOutOfStateCase_ID,
                 ExchangeMode_INDC,
                 StatusRequest_CODE,
                 Form_ID,
                 FormWeb_URL,
                 TransHeader_IDNO,
                 Function_CODE,
                 Action_CODE,
                 Reason_CODE,
                 DescriptionComments_TEXT,
                 CaseFormer_ID,
                 InsCarrier_NAME,
                 InsPolicyNo_TEXT,
                 Hearing_DATE,
                 Dismissal_DATE,
                 GeneticTest_DATE,
                 PfNoShow_DATE,
                 Attachment_INDC,
                 BeginValidity_DATE,
                 EndValidity_DATE,
                 WorkerUpdate_ID,
                 Update_DTTM,
                 TransactionEventSeq_NUMB,
                 File_ID,
                 ArrearComputed_DATE,
                 TotalInterestOwed_AMNT,
                 TotalArrearsOwed_AMNT,
                 RespondentMci_IDNO)
         VALUES ( @Ad_Generated_DATE,--Generated_DATE
                  @An_Case_IDNO,--Case_IDNO
                  RIGHT(REPLICATE('0', 2) + LTRIM(RTRIM(@Lc_CSFipsCur_IVDOutOfStateFips_CODE)), 2),--IVDOutOfStateFips_CODE
                  ISNULL (dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR (RIGHT(REPLICATE('0', 3) + LTRIM(RTRIM(@Lc_CSFipsCur_IVDOutOfStateCountyFips_CODE)), 3)), @Lc_OthCountyFips000_CODE),--IVDOutOfStateCountyFips_CODE
                  ISNULL (dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR (RIGHT(REPLICATE('0', 2) + LTRIM(RTRIM(@Lc_CSFipsCur_IVDOutOfStateOfficeFips_CODE)), 2)), @Lc_OthOfficeFips00_CODE),--IVDOutOfStateOfficeFips_CODE
                  @Lc_CSFipsCur_IVDOutOfStateCase_ID,--IVDOutOfStateCase_ID
                  @Lc_CertMode_INDC,--ExchangeMode_INDC
                  @Lc_StatusRequestPending_CODE,--StatusRequest_CODE
                  @Ac_Form_ID,--Form_ID
                  @As_FormWeb_URL,--FormWeb_URL
                  @An_TransHeader_IDNO,--TransHeader_IDNO
                  @Ac_Function_CODE,--Function_CODE
                  @Ac_Action_CODE,--Action_CODE
                  @Ac_Reason_CODE,--Reason_CODE
                  @As_DescriptionComments_TEXT,--DescriptionComments_TEXT
                  @Ac_CaseFormer_ID,--CaseFormer_ID
                  @Ac_InsCarrier_NAME,--InsCarrier_NAME
                  @Ac_InsPolicyNo_TEXT,--InsPolicyNo_TEXT
                  @Ad_Hearing_DATE,--Hearing_DATE
                  @Ad_Dismissal_DATE,--Dismissal_DATE
                  @Ad_GeneticTest_DATE,--GeneticTest_DATE
                  @Ad_PfNoShow_DATE,--PfNoShow_DATE
                  @Ac_Attachment_INDC,--Attachment_INDC
                  @Ad_BeginValidity_DATE,--BeginValidity_DATE
                  @Ld_High_DATE,--EndValidity_DATE
                  @Ac_SignedonWorker_ID,--WorkerUpdate_ID
                  @Ad_Update_DTTM,--Update_DTTM
                  @Ln_TransactionEventSeq_NUMB,--TransactionEventSeq_NUMB
                  @Ac_File_ID,--File_ID
                  @Ad_ArrearComputed_DATE,--ArrearComputed_DATE
                  @An_TotalInterestOwed_AMNT,--TotalInterestOwed_AMNT
                  @An_TotalArrearsOwed_AMNT,--TotalArrearsOwed_AMNT
                  @Ln_CSFipsCur_RespondentMci_IDNO); --RespondentMci_IDNO
         SET @Ln_Rowcount_QNTY = @@ROWCOUNT;

         IF @Ln_Rowcount_QNTY = @Ln_Zero_NUMB
          BEGIN
           SET @Ls_ErrorMessage_TEXT = 'INSERT CSPR_Y1 FAILED';

           RAISERROR (50001,16,1);
          END;
        END;

       FETCH NEXT FROM CSFips_Cur INTO @Lc_CSFipsCur_IVDOutOfStateFips_CODE, @Lc_CSFipsCur_IVDOutOfStateCountyFips_CODE, @Lc_CSFipsCur_IVDOutOfStateOfficeFips_CODE, @Lc_CSFipsCur_IVDOutOfStateCase_ID, @Ln_CSFipsCur_RespondentMci_IDNO;

       SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;
      END;

     CLOSE CSFips_Cur;

     DEALLOCATE CSFips_Cur;

     IF @Ln_Cur_NUMB = 0
        AND @Ac_SignedonWorker_ID <> @Ls_BatchRunUser_TEXT
      BEGIN
       SET @Ac_Msg_CODE = @Lc_ErrorW0156_CODE;
       SET @As_DescriptionError_TEXT = 'NO DATA FOUND IN ICAS_Y1';

       RETURN;
      END;
    END;

   --Interstate Action Alerts should be turned off on generating a specific communication
   -- from ISND rather than waiting until succesful process of the pending requset from
   -- CSENet Outgoing batch 
   DECLARE Csenet_Cur INSENSITIVE CURSOR FOR
    SELECT DISTINCT
           a.Request_IDNO,
           a.Generated_DATE,
           a.IVDOutOfStateFips_CODE,
           a.Case_IDNO,
           b.ActivityMinor_CODE,
           a.TransactionEventSeq_NUMB
      --selecting the value from DMNR_Y1 (Union of DMNR_Y1 and CJNR_Y1),
      -- instead of selecting the value from DMNR_Y1
      FROM CSPR_Y1 a,
           DMNR_Y1 b
     WHERE a.Case_IDNO = @An_Case_IDNO
       AND a.Function_CODE = @Lc_FunctionMsc_CODE
       AND a.Action_CODE = @Lc_ActionP_CODE
       AND a.Reason_CODE = @Lc_FarProvidstatusupdat_CODE
       AND a.Generated_DATE = ISNULL (@Ad_Generated_DATE, dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME())
       AND a.StatusRequest_CODE = @Lc_StatusRequestPn_CODE
       AND b.Case_IDNO = a.Case_IDNO
       AND a.EndValidity_DATE = @Ld_High_DATE
       AND b.ActivityMinor_CODE IN (@Lc_ActivityMinorCod25_CODE, @Lc_ActivityMinorCod30_CODE, @Lc_ActivityMinorEadin_CODE, @Lc_ActivityMinorErpou_CODE,
                                    @Lc_ActivityMinorLsout_CODE, @Lc_ActivityMinorMrbtr_CODE, @Lc_ActivityMinorMrupd_CODE, @Lc_ActivityMinorMsc14_CODE,
                                    @Lc_ActivityMinorPadin_CODE, @Lc_ActivityMinorPmbla_CODE, @Lc_ActivityMinorPrpou_CODE, @Lc_ActivityMinorPuden_CODE,
                                    @Lc_ActivityMinorTadin_CODE, @Lc_ActivityMinorTcdis_CODE, @Lc_ActivityMinorTrpou_CODE)
       AND b.Status_CODE <> @Lc_RemedyStatusComplete_CODE
    UNION ALL
    SELECT DISTINCT
           a.Request_IDNO,
           a.Generated_DATE,
           a.IVDOutOfStateFips_CODE,
           a.Case_IDNO,
           b.ActivityMinor_CODE,
           a.TransactionEventSeq_NUMB
      FROM CSPR_Y1 a,
           DMNR_Y1 b
     WHERE a.Case_IDNO = @An_Case_IDNO
       AND a.Function_CODE = @Lc_FunctionEstablishment_CODE
       AND a.Action_CODE = @Lc_ActionAcknowledgment_CODE
       AND a.Reason_CODE IN (@Lc_ReasonAadin_CODE, @Lc_ReasonAnoad_CODE)
       AND a.Generated_DATE = ISNULL (@Ad_Generated_DATE, dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME())
       AND a.StatusRequest_CODE = @Lc_StatusRequestPn_CODE
       AND b.Case_IDNO = a.Case_IDNO
       AND a.EndValidity_DATE = @Ld_High_DATE
       AND b.ActivityMinor_CODE IN (@Lc_ActivityMinorTradj_CODE, @Lc_ActivityMinorTrmod_CODE)
       AND b.Status_CODE <> @Lc_RemedyStatusComplete_CODE
    UNION ALL
    SELECT DISTINCT
           a.Request_IDNO,
           a.Generated_DATE,
           a.IVDOutOfStateFips_CODE,
           a.Case_IDNO,
           b.ActivityMinor_CODE,
           a.TransactionEventSeq_NUMB
      FROM CSPR_Y1 a,
           DMNR_Y1 b,
           CFAR_Y1 c
     WHERE a.Case_IDNO = @An_Case_IDNO
       AND a.Function_CODE = c.Function_CODE
       AND a.Action_CODE = c.Action_CODE
       AND a.Reason_CODE = c.Reason_CODE
       AND c.RefAssist_CODE = @Lc_RefAssistR_CODE
       AND a.Generated_DATE = ISNULL (@Ad_Generated_DATE, dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME())
       AND a.StatusRequest_CODE = @Lc_StatusRequestPn_CODE
       AND b.Case_IDNO = a.Case_IDNO
       AND a.EndValidity_DATE = @Ld_High_DATE
       AND b.ActivityMinor_CODE = @Lc_ActivityMinorSaout_CODE
       AND b.Status_CODE <> @Lc_RemedyStatusComplete_CODE
    UNION ALL
    SELECT DISTINCT
           a.Request_IDNO,
           a.Generated_DATE,
           a.IVDOutOfStateFips_CODE,
           a.Case_IDNO,
           b.ActivityMinor_CODE,
           a.TransactionEventSeq_NUMB
      FROM CSPR_Y1 a,
           DMNR_Y1 b
     WHERE a.Case_IDNO = @An_Case_IDNO
       AND a.Function_CODE = @Lc_FunctionMsc_CODE
       AND a.Action_CODE = @Lc_ActionP_CODE
       AND a.Reason_CODE = @Lc_FarRequestInterestCharges_CODE
       AND a.Generated_DATE = ISNULL (@Ad_Generated_DATE, dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME())
       AND a.StatusRequest_CODE = @Lc_StatusRequestPn_CODE
       AND b.Case_IDNO = a.Case_IDNO
       AND a.EndValidity_DATE = @Ld_High_DATE
       AND b.ActivityMinor_CODE = @Lc_ActivityMinorGrint_CODE
       AND b.Status_CODE <> @Lc_RemedyStatusComplete_CODE;

   OPEN Csenet_Cur;

   FETCH NEXT FROM Csenet_Cur INTO @Ln_CsenetCur_Request_IDNO, @Ld_CsenetCur_Generated_DATE, @Lc_CsenetCur_IVDOutOfStateFips_CODE, @Lc_CsenetCur_Case_IDNO, @Lc_CsenetCur_ActivityMinor_CODE, @Ln_CsenetCur_TransactionEventSeq_NUMB;

   SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;

   --FETCH EACH RECORD
   WHILE @Ln_FetchStatus_QNTY = 0
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_ACTION_ALERT';
     SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(@Lc_CsenetCur_Case_IDNO, '') + ', ActivityMinor_CODE = ' + ISNULL(@Lc_CsenetCur_ActivityMinor_CODE, '') + ', Status_CODE = ' + ISNULL(@Lc_RemedyStatusStart_CODE, '');

     SELECT @Ln_QNTY = COUNT (1)
       FROM DMNR_Y1 w
      WHERE w.Case_IDNO = @Lc_CsenetCur_Case_IDNO
        AND w.ActivityMinor_CODE = @Lc_CsenetCur_ActivityMinor_CODE
        AND w.Status_CODE = @Lc_RemedyStatusStart_CODE;

     IF @Ln_QNTY > 0
      BEGIN
       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_ACTION_ALERT';
       SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(@Lc_CsenetCur_Case_IDNO, '') + ', Subsystem_CODE = ' + ISNULL(@Lc_SubsystemInterstate_CODE, '') + ', ActivityMajor_CODE = ' + ISNULL(@Lc_MajorActivityCase_CODE, '') + ', ActivityMinor_CODE = ' + ISNULL(@Lc_CsenetCur_ActivityMinor_CODE, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_CsenetCur_TransactionEventSeq_NUMB AS VARCHAR), '') + ', SignedonWorker_ID = ' + ISNULL(@Ac_SignedonWorker_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_CsenetCur_Generated_DATE AS VARCHAR), '');

       EXECUTE BATCH_COMMON$SP_UPDATE_ACTION_ALERT
        @An_Case_IDNO                = @Lc_CsenetCur_Case_IDNO,
        @Ac_Subsystem_CODE           = @Lc_SubsystemInterstate_CODE,
        @Ac_ActivityMajor_CODE       = @Lc_MajorActivityCase_CODE,
        @Ac_ActivityMinor_CODE       = @Lc_CsenetCur_ActivityMinor_CODE,
        @An_TransactionEventSeq_NUMB = @Ln_CsenetCur_TransactionEventSeq_NUMB,
        @Ac_SignedonWorker_ID        = @Ac_SignedonWorker_ID,
        @Ad_Run_DATE                 = @Ld_CsenetCur_Generated_DATE,
        @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT    = @Ls_ErrorMessage_TEXT OUTPUT;

       IF (@Lc_Msg_CODE <> @Lc_StatusSuccessS_CODE)
        BEGIN
         RAISERROR (50001,16,1);
        END;
      END;

     FETCH NEXT FROM Csenet_Cur INTO @Ln_CsenetCur_Request_IDNO, @Ld_CsenetCur_Generated_DATE, @Lc_CsenetCur_IVDOutOfStateFips_CODE, @Lc_CsenetCur_Case_IDNO, @Lc_CsenetCur_ActivityMinor_CODE, @Ln_CsenetCur_TransactionEventSeq_NUMB;

     SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;
    END;

   CLOSE Csenet_Cur;

   DEALLOCATE Csenet_Cur;

   SET @Ac_Msg_CODE = @Lc_StatusSuccessS_CODE;
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailedF_CODE;
   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();

   IF CURSOR_STATUS ('LOCAL', 'CSFips_Cur') IN (0, 1)
    BEGIN
     CLOSE CSFips_Cur;

     DEALLOCATE CSFips_Cur;
    END

   IF CURSOR_STATUS ('LOCAL', 'Csenet_Cur') IN (0, 1)
    BEGIN
     CLOSE Csenet_Cur;

     DEALLOCATE Csenet_Cur;
    END

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_ErrorMessage_TEXT = SUBSTRING(ERROR_MESSAGE(), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;
  END CATCH;
 END;


GO
