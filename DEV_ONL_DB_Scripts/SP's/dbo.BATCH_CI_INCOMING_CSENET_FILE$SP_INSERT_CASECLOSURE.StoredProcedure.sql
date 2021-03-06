/****** Object:  StoredProcedure [dbo].[BATCH_CI_INCOMING_CSENET_FILE$SP_INSERT_CASECLOSURE]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_CI_INCOMING_CSENET_FILE$SP_INSERT_CASECLOSURE
Programmer Name	:	IMP Team.
Description		:	This procedure is used to insert Case Closure Trigger
Frequency		:	DAILY
Developed On	:	04/04/2011
Called By		:	NONE
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_CI_INCOMING_CSENET_FILE$SP_INSERT_CASECLOSURE] (
 @An_Case_IDNO             NUMERIC(6),
 @Ac_Fips_CODE             CHAR(7),
 @Ac_Reason_CODE           CHAR(5),
 @Ad_Run_DATE              DATE,
 @Ac_TranStatus_CODE       CHAR(2),
 @Ac_JobProcess_IDNO       CHAR(7),
 @Ac_BatchRunUser_TEXT     CHAR(30),
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE  @Li_SordCount_NUMB                  INT = 0,
           @Lc_Space_TEXT                      CHAR(1) = ' ',
           @Lc_TypeErrorE_CODE                 CHAR(1) = 'E',
           @Lc_RelationshipCaseNcp_CODE        CHAR(1) = 'A',
           @Lc_RelationshipCasePutFather_CODE  CHAR(1) = 'P',
           @Lc_StatusActive_CODE               CHAR(1) = 'A',
           @Lc_CaseStatusOpen_CODE             CHAR(1) = 'O',
           @Lc_CaseStatusClosed_CODE           CHAR(1) = 'C',
           @Lc_StatusFailed_CODE               CHAR(1) = 'F',
           @Lc_InitiateState_CODE              CHAR(1) = 'I',
           @Lc_InitiateInternational_CODE      CHAR(1) = 'C',
           @Lc_InitiateTribal_CODE             CHAR(1) = 'T',
           @Lc_RespondingState_CODE            CHAR(1) = 'R',
           @Lc_RespondingInternational_CODE    CHAR(1) = 'Y',
           @Lc_RespondingTribal_CODE           CHAR(1) = 'S',
           @Lc_NoteN_INDC                      CHAR(1) = 'N',
           @Lc_ActionProvide_CODE              CHAR(1) = 'P',
           @Lc_InterstateDirectionInput_INDC   CHAR(1) = 'I',
           @Lc_StatusSuccess_CODE              CHAR(1) = 'S',
           @Lc_Yes_INDC                        CHAR(1) = 'Y',
           @Lc_OrderTypeVoluntary_CODE         CHAR(1) = 'V',
           @Lc_NegPosStartRemedy_TEXT          CHAR(1) = 'P',
           @Lc_OthStateFips00_CODE             CHAR(2) = '00',
           @Lc_ReasonStatusNh_CODE             CHAR(2) = 'NH',
           @Lc_ReasonStatusPb_CODE             CHAR(2) = 'PB',
           @Lc_ReasonStatusFn_CODE             CHAR(2) = 'FN',
           @Lc_ReasonStatusPc_CODE             CHAR(2) = 'PC',
           @Lc_ReasonStatusPk_CODE             CHAR(2) = 'PK',
           @Lc_ReasonStatusPr_CODE             CHAR(2) = 'PR',
           @Lc_ReasonStatusPq_CODE             CHAR(2) = 'PQ',
           @Lc_ReasonStatusUb_CODE             CHAR(2) = 'UB',
           @Lc_ReasonStatusUc_CODE             CHAR(2) = 'UC',
           @Lc_ReasonStatusIk_CODE             CHAR(2) = 'IK',
           @Lc_ReasonStatusUm_CODE             CHAR(2) = 'UM',
           @Lc_ReasonStatusIj_CODE             CHAR(2) = 'IJ',
           @Lc_ReasonStatusIu_CODE             CHAR(2) = 'IU',
           @Lc_ReasonStatusGv_CODE             CHAR(2) = 'GV',
           @Lc_ReasonStatusUv_CODE             CHAR(2) = 'UV',
           @Lc_ReasonStatusDi_CODE             CHAR(2) = 'DI',
           @Lc_ReasonStatusIi_CODE             CHAR(2) = 'II',
           @Lc_ReasonStatusCv_CODE             CHAR(2) = 'CV',
           @Lc_ReasonStatusIs_CODE             CHAR(2) = 'IS',
           @Lc_ReasonStatusSn_CODE             CHAR(2) = 'SN',
           @Lc_TypeChangeCc_CODE               CHAR(2) = 'CC',
           @Lc_SubsystemInterstate_CODE        CHAR(2) = 'IN',
           @Lc_FunctionManagestcases_CODE      CHAR(3) = 'MSC',
           @Lc_RemedyStatusStart_CODE          CHAR(4) = 'STRT',
           @Lc_ActivityMajorCaseClosure_CODE   CHAR(4) = 'CCLO',
           @Lc_MajorActivityCase_CODE          CHAR(4) = 'CASE',
           @Lc_FarGsc02_CODE                   CHAR(5) = 'GSC02',
           @Lc_FarGsc03_CODE                   CHAR(5) = 'GSC03',
           @Lc_FarGsc05_CODE                   CHAR(5) = 'GSC05',
           @Lc_FarGsc4a_CODE                   CHAR(5) = 'GSC4A',
           @Lc_FarGsc4b_CODE                   CHAR(5) = 'GSC4B',
           @Lc_FarGsc4c_CODE                   CHAR(5) = 'GSC4C',
           @Lc_FarGsc4d_CODE                   CHAR(5) = 'GSC4D',
           @Lc_FarGsc5b_CODE                   CHAR(5) = 'GSC5B',
           @Lc_FarGsc06_CODE                   CHAR(5) = 'GSC06',
           @Lc_FarGsc07_CODE                   CHAR(5) = 'GSC07',
           @Lc_FarGsc08_CODE                   CHAR(5) = 'GSC08',
           @Lc_FarGsc09_CODE                   CHAR(5) = 'GSC09',
           @Lc_FarGsc10_CODE                   CHAR(5) = 'GSC10',
           @Lc_FarGsc11_CODE                   CHAR(5) = 'GSC11',
           @Lc_FarGsc12_CODE                   CHAR(5) = 'GSC12',
           @Lc_FarGsc13_CODE                   CHAR(5) = 'GSC13',
           @Lc_FarGsc15_CODE                   CHAR(5) = 'GSC15',
           @Lc_FarGsc16_CODE                   CHAR(5) = 'GSC16',
           @Lc_FarGsc17_CODE                   CHAR(5) = 'GSC17',
           @Lc_FarGsc18_CODE                   CHAR(5) = 'GSC18',
           @Lc_CaseClosureMinorActivity_CODE   CHAR(5) = 'RCCLO',
           @Lc_BatchRunUser_TEXT               CHAR(30) = 'BATCH',
           @Lc_ConversionWorker_IDNO           CHAR(30) = 'CONVERSION',
           @Ls_Procedure_NAME                  VARCHAR(100) = 'SP_INSERT_CASECLOSURE',
           @Ls_Process_NAME                    VARCHAR(100) = 'BATCH_CI_INCOMING_CSENET_FILE',
           @Ld_Low_DATE                        DATE = '01/01/0001',
           @Ld_High_DATE                       DATE = '12/31/9999';
  DECLARE  @Ln_OrderSeq_NUMB             NUMERIC(2) = 0,
           @Ln_Value_QNTY                NUMERIC(10) = 0,
           @Ln_Trans_QNTY                NUMERIC(10) = 0,
           @Ln_MemberMci_IDNO            NUMERIC(10) = 0,
           @Ln_Topic_IDNO                NUMERIC(10) = 0,
           @Ln_TransactionEventSeq_NUMB  NUMERIC(19),
           @Lc_RespondInit_CODE          CHAR(1) = '',
           @Lc_Msg_CODE                  CHAR(5) = '',
           @Lc_MinorActivity_CODE        CHAR(5) = '',
           @Lc_ClosureReason_CODE        CHAR(30) = @Lc_Space_TEXT,
           @Ls_Sql_TEXT                  VARCHAR(100) = '',
           @Ls_DescriptionError_TEXT     VARCHAR(4000) = '',
           @Ls_Sqldata_TEXT              VARCHAR(4000) = '',
           @Ld_Opened_DATE               DATE;

  BEGIN TRY
   
   SET @Ls_Sql_TEXT = 'SELECT CASE_Y1';
   SET @Ls_Sqldata_TEXT = 'Case_IDNO: ' + CAST(@An_Case_IDNO AS VARCHAR) + ', Fips_CODE: ' + @Ac_Fips_CODE + ', Reason_CODE: ' + @Ac_Reason_CODE + ', Run_DATE: ' + CAST(@Ad_Run_DATE AS VARCHAR) + ', TranStatus_CODE: ' + @Ac_TranStatus_CODE + ', JobProcess_IDNO: ' + @Ac_JobProcess_IDNO;

   SELECT TOP 1 @Lc_RespondInit_CODE = a.RespondInit_CODE,
                @Ln_MemberMci_IDNO = b.MemberMci_IDNO
     FROM CASE_Y1 AS a,
          CMEM_Y1 AS b
    WHERE a.Case_IDNO = @An_Case_IDNO
      AND a.Case_IDNO = b.Case_IDNO
      AND b.CaseRelationship_CODE IN (@Lc_RelationshipCaseNcp_CODE, @Lc_RelationshipCasePutFather_CODE)
      AND b.CaseMemberStatus_CODE = @Lc_StatusActive_CODE
      AND a.StatusCase_CODE = @Lc_CaseStatusOpen_CODE
      AND NOT EXISTS (SELECT 1
                        FROM DMJR_Y1 AS e
                       WHERE a.Case_IDNO = e.Case_IDNO
                         AND e.ActivityMajor_CODE = @Lc_ActivityMajorCaseClosure_CODE
                         AND e.Status_CODE = @Lc_RemedyStatusStart_CODE)
    ORDER BY b.CaseRelationship_CODE;

   SET @Ls_Sql_TEXT = 'SELECT UCASE_Y1';
   SET @Ls_Sqldata_TEXT = 'Case_IDNO: ' + CAST(@An_Case_IDNO AS VARCHAR) + ', Fips_CODE: ' + @Ac_Fips_CODE + ', Reason_CODE: ' + @Ac_Reason_CODE + ', Run_DATE: ' + CAST(@Ad_Run_DATE AS VARCHAR) + ', TranStatus_CODE: ' + @Ac_TranStatus_CODE + ', JobProcess_IDNO: ' + @Ac_JobProcess_IDNO;

   SELECT TOP (1) @Ld_Opened_DATE = CASE a.WorkerUpdate_ID
                                     WHEN @Lc_ConversionWorker_IDNO
                                      THEN a.Opened_DATE
                                     ELSE CAST(CONVERT(VARCHAR(10), a.Update_DTTM, 101) AS DATE)
                                    END
     FROM UCASE_V1 AS a
    WHERE a.Case_IDNO = @An_Case_IDNO
      AND a.StatusCase_CODE = @Lc_CaseStatusOpen_CODE
      AND CAST(CONVERT(VARCHAR(10), a.Update_DTTM, 101) AS DATE) >= (SELECT ISNULL(MAX(u.StatusCurrent_DATE), @Ld_Low_DATE) AS expr
                                                                       FROM UCASE_V1 u
                                                                      WHERE u.Case_IDNO = a.Case_IDNO
                                                                        AND u.StatusCase_CODE = @Lc_CaseStatusClosed_CODE)
    ORDER BY a.TransactionEventSeq_NUMB;

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$BATCH_COMMON$SP_GENERATE_SEQ_TXN_EVENT';
   SET @Ls_Sqldata_TEXT = 'BatchRunUser_TEXT: ' + @Ac_BatchRunUser_TEXT + ', JobProcess_IDNO: ' + @Ac_JobProcess_IDNO + ', Run_DATE: ' + CAST(@Ad_Run_DATE AS VARCHAR);

   EXECUTE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
    @Ac_Worker_ID                = @Ac_BatchRunUser_TEXT,
    @Ac_Process_ID               = @Ac_JobProcess_IDNO,
    @Ad_EffectiveEvent_DATE      = @Ad_Run_DATE,
    @Ac_Note_INDC                = @Lc_NoteN_INDC,
    @An_EventFunctionalSeq_NUMB  = 0,
    @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
    @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR(50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'SELECT CFAR_Y1';
   SET @Ls_Sqldata_TEXT = 'Case_IDNO: ' + CAST(@An_Case_IDNO AS VARCHAR) + ', Fips_CODE: ' + @Ac_Fips_CODE + ', Reason_CODE: ' + @Ac_Reason_CODE + ', Run_DATE: ' + CAST(@Ad_Run_DATE AS VARCHAR) + ', TranStatus_CODE: ' + @Ac_TranStatus_CODE + ', JobProcess_IDNO: ' + @Ac_JobProcess_IDNO;

   SELECT TOP 1 @Lc_MinorActivity_CODE = a.ActivityMinorIn_CODE
     FROM CFAR_Y1 a
    WHERE a.Reason_CODE = @Ac_Reason_CODE;

   IF @Ac_Reason_CODE IN (@Lc_FarGsc02_CODE, @Lc_FarGsc03_CODE, @Lc_FarGsc05_CODE, @Lc_FarGsc4a_CODE,
                          @Lc_FarGsc4b_CODE, @Lc_FarGsc4c_CODE, @Lc_FarGsc4d_CODE, @Lc_FarGsc5b_CODE,
                          @Lc_FarGsc06_CODE, @Lc_FarGsc07_CODE, @Lc_FarGsc08_CODE, @Lc_FarGsc09_CODE,
                          @Lc_FarGsc10_CODE, @Lc_FarGsc11_CODE, @Lc_FarGsc12_CODE, @Lc_FarGsc13_CODE,
                          @Lc_FarGsc15_CODE, @Lc_FarGsc16_CODE, @Lc_FarGsc17_CODE, @Lc_FarGsc18_CODE)
    BEGIN
     IF (@Lc_RespondInit_CODE = @Lc_RespondingState_CODE
          OR @Lc_RespondInit_CODE = @Lc_RespondingInternational_CODE
          OR @Lc_RespondInit_CODE = @Lc_RespondingTribal_CODE)
      BEGIN
       IF @Ac_Reason_CODE NOT IN (@Lc_FarGsc13_CODE)
        BEGIN
         SET @Ls_Sql_TEXT = 'SELECT ICAS_Y1';
         SET @Ls_Sqldata_TEXT = 'Case_IDNO: ' + CAST(@An_Case_IDNO AS VARCHAR) + ', Fips_CODE: ' + @Ac_Fips_CODE + ', Reason_CODE: ' + @Ac_Reason_CODE + ', Run_DATE: ' + CAST(@Ad_Run_DATE AS VARCHAR) + ', TranStatus_CODE: ' + @Ac_TranStatus_CODE + ', JobProcess_IDNO: ' + @Ac_JobProcess_IDNO;

         SELECT @Ln_Value_QNTY = COUNT(1)
           FROM ICAS_Y1 AS i
          WHERE i.Case_IDNO = @An_Case_IDNO
            AND i.Status_CODE = @Lc_CaseStatusOpen_CODE
            AND i.IVDOutOfStateFips_CODE <> SUBSTRING(@Ac_Fips_CODE, 1, 2)
            AND i.IVDOutOfStateFips_CODE <> @Lc_OthStateFips00_CODE
            AND i.RespondInit_CODE IN (@Lc_RespondingState_CODE, @Lc_RespondingInternational_CODE, @Lc_RespondingTribal_CODE)
            AND i.EndValidity_DATE = @Ld_High_DATE;

         SET @Ls_Sql_TEXT = 'SELECT CTHB_Y1';
         SET @Ls_Sqldata_TEXT = 'Case_IDNO: ' + CAST(@An_Case_IDNO AS VARCHAR) + ', Fips_CODE: ' + @Ac_Fips_CODE + ', Reason_CODE: ' + @Ac_Reason_CODE + ', Run_DATE: ' + CAST(@Ad_Run_DATE AS VARCHAR) + ', TranStatus_CODE: ' + @Ac_TranStatus_CODE + ', JobProcess_IDNO: ' + @Ac_JobProcess_IDNO;

         SELECT @Ln_Trans_QNTY = COUNT(1)
           FROM (SELECT c.Case_IDNO,
                        c.IVDOutOfStateFips_CODE
                   FROM CTHB_Y1 AS c
                  WHERE c.Case_IDNO = @An_Case_IDNO
                    AND c.IVDOutOfStateFips_CODE <> SUBSTRING(@Ac_Fips_CODE, 1, 2)
                    AND c.IVDOutOfStateFips_CODE <> @Lc_OthStateFips00_CODE
                    AND c.Transaction_DATE <= @Ad_Run_DATE
                    AND c.Transaction_DATE >= @Ld_Opened_DATE
                    AND c.Function_CODE = @Lc_FunctionManagestcases_CODE
                    AND c.Action_CODE = @Lc_ActionProvide_CODE
                    AND c.Reason_CODE IN (@Lc_FarGsc02_CODE, @Lc_FarGsc03_CODE, @Lc_FarGsc05_CODE, @Lc_FarGsc4a_CODE,
                                          @Lc_FarGsc4b_CODE, @Lc_FarGsc4c_CODE, @Lc_FarGsc4d_CODE, @Lc_FarGsc5b_CODE,
                                          @Lc_FarGsc06_CODE, @Lc_FarGsc07_CODE, @Lc_FarGsc08_CODE, @Lc_FarGsc09_CODE,
                                          @Lc_FarGsc10_CODE, @Lc_FarGsc11_CODE, @Lc_FarGsc12_CODE, @Lc_FarGsc15_CODE,
                                          @Lc_FarGsc16_CODE, @Lc_FarGsc17_CODE, @Lc_FarGsc18_CODE)
                    AND c.IoDirection_CODE = @Lc_InterstateDirectionInput_INDC
                    AND c.TranStatus_CODE = @Ac_TranStatus_CODE
                  GROUP BY c.Case_IDNO,
                           c.IVDOutOfStateFips_CODE) AS fci;
        END
       ELSE
        BEGIN
         SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_ACTIVITY - 1';
         SET @Ls_Sqldata_TEXT = 'RespondInit_CODE: ' + @Lc_RespondInit_CODE + ', Case_IDNO: ' + CAST(@An_Case_IDNO AS VARCHAR) + ', MemberMci_IDNO: ' + CAST(@Ln_MemberMci_IDNO AS VARCHAR) + ', MajorActivityCase_CODE: ' + @Lc_MajorActivityCase_CODE + ', MinorActivity_CODE: ' + @Lc_MinorActivity_CODE + ', SubsystemInterstate_CODE: ' + @Lc_SubsystemInterstate_CODE + ', TransactionEventSeq_NUMB: ' + CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR) + ', BatchRunUser_TEXT: ' + @Lc_BatchRunUser_TEXT + ', Fips_CODE: ' + @Ac_Fips_CODE + ', Run_DATE: ' + CAST(@Ad_Run_DATE AS VARCHAR);

         EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
          @An_Case_IDNO                = @An_Case_IDNO,
          @An_MemberMci_IDNO           = @Ln_MemberMci_IDNO,
          @Ac_ActivityMajor_CODE       = @Lc_MajorActivityCase_CODE,
          @Ac_ActivityMinor_CODE       = @Lc_MinorActivity_CODE,
          @Ac_Subsystem_CODE           = @Lc_SubsystemInterstate_CODE,
          @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
          @Ac_WorkerUpdate_ID          = @Lc_BatchRunUser_TEXT,
          @Ac_IVDOutOfStateFips_CODE   = @Ac_Fips_CODE,
          @Ad_Run_DATE                 = @Ad_Run_DATE,
          @An_Topic_IDNO               = @Ln_Topic_IDNO OUTPUT,
          @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
          @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

         IF (@Lc_Msg_CODE <> @Lc_StatusSuccess_CODE)
          BEGIN
           EXECUTE BATCH_COMMON$SP_BATE_LOG
            @As_Process_NAME             = @Ls_Process_NAME,
            @As_Procedure_NAME           = @Ls_Procedure_NAME,
            @Ac_Job_ID                   = @Ac_JobProcess_IDNO,
            @Ad_Run_DATE                 = @Ad_Run_DATE,
            @Ac_TypeError_CODE           = @Lc_TypeErrorE_CODE,
            @An_Line_NUMB                = @Ln_Value_QNTY,
            @Ac_Error_CODE               = @Lc_Space_TEXT,
            @As_DescriptionError_TEXT    = @Ls_Sql_TEXT,
            @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
            @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
            @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

           IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
            BEGIN
             RAISERROR(50001,16,1);
            END;
          END;
        END;
      END;
     ELSE IF (@Lc_RespondInit_CODE = @Lc_InitiateState_CODE
          OR @Lc_RespondInit_CODE = @Lc_InitiateInternational_CODE
          OR @Lc_RespondInit_CODE = @Lc_InitiateTribal_CODE)
      BEGIN
       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_ACTIVITY - 2';
       SET @Ls_Sqldata_TEXT = 'RespondInit_CODE: ' + @Lc_RespondInit_CODE + ', Case_IDNO: ' + CAST(@An_Case_IDNO AS VARCHAR) + ', MemberMci_IDNO: ' + CAST(@Ln_MemberMci_IDNO AS VARCHAR) + ', MajorActivityCase_CODE: ' + @Lc_MajorActivityCase_CODE + ', MinorActivity_CODE: ' + @Lc_MinorActivity_CODE + ', SubsystemInterstate_CODE: ' + @Lc_SubsystemInterstate_CODE + ', TransactionEventSeq_NUMB: ' + CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR) + ', BatchRunUser_TEXT: ' + @Lc_BatchRunUser_TEXT + ', Fips_CODE: ' + @Ac_Fips_CODE + ', Run_DATE: ' + CAST(@Ad_Run_DATE AS VARCHAR);

       EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
        @An_Case_IDNO                = @An_Case_IDNO,
        @An_MemberMci_IDNO           = @Ln_MemberMci_IDNO,
        @Ac_ActivityMajor_CODE       = @Lc_MajorActivityCase_CODE,
        @Ac_ActivityMinor_CODE       = @Lc_MinorActivity_CODE,
        @Ac_Subsystem_CODE           = @Lc_SubsystemInterstate_CODE,
        @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
        @Ac_WorkerUpdate_ID          = @Lc_BatchRunUser_TEXT,
        @Ac_IVDOutOfStateFips_CODE   = @Ac_Fips_CODE,
        @Ad_Run_DATE                 = @Ad_Run_DATE,
        @An_Topic_IDNO               = @Ln_Topic_IDNO OUTPUT,
        @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

       IF (@Lc_Msg_CODE <> @Lc_StatusSuccess_CODE)
        BEGIN
         EXECUTE BATCH_COMMON$SP_BATE_LOG
          @As_Process_NAME             = @Ls_Process_NAME,
          @As_Procedure_NAME           = @Ls_Procedure_NAME,
          @Ac_Job_ID                   = @Ac_JobProcess_IDNO,
          @Ad_Run_DATE                 = @Ad_Run_DATE,
          @Ac_TypeError_CODE           = @Lc_TypeErrorE_CODE,
          @An_Line_NUMB                = @Ln_Value_QNTY,
          @Ac_Error_CODE               = @Lc_Space_TEXT,
          @As_DescriptionError_TEXT    = @Ls_Sql_TEXT,
          @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
          @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
          @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

         IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
          BEGIN
           RAISERROR(50001,16,1);
          END;
        END;
      END;

     IF @Ln_Value_QNTY = 0
         OR (@Ln_Value_QNTY > 0
             AND @Ln_Value_QNTY = @Ln_Trans_QNTY)
      BEGIN
       SET @Ls_Sql_TEXT = 'SELECT SORD_Y1';
       SET @Ls_Sqldata_TEXT = 'Case_IDNO: ' + CAST(@An_Case_IDNO AS VARCHAR);

       SELECT @Li_SordCount_NUMB = COUNT(1)
         FROM SORD_Y1 a
        WHERE a.Case_IDNO = @An_Case_IDNO
          AND a.OrderEnd_DATE = @Ld_High_DATE;

       SET @Lc_ClosureReason_CODE = CASE @Ac_Reason_CODE
                                     WHEN @Lc_FarGsc02_CODE
                                      THEN @Lc_ReasonStatusNh_CODE
                                     WHEN @Lc_FarGsc03_CODE
                                      THEN
                                      CASE
                                       WHEN @Li_SordCount_NUMB > 0
                                        THEN @Lc_ReasonStatusPb_CODE
                                       ELSE @Lc_ReasonStatusFn_CODE
                                      END
                                     WHEN @Lc_FarGsc4a_CODE
                                      THEN @Lc_ReasonStatusPc_CODE
                                     WHEN @Lc_FarGsc4b_CODE
                                      THEN @Lc_ReasonStatusPk_CODE
                                     WHEN @Lc_FarGsc4c_CODE
                                      THEN @Lc_ReasonStatusPr_CODE
                                     WHEN @Lc_FarGsc4d_CODE
                                      THEN @Lc_ReasonStatusPq_CODE
                                     WHEN @Lc_FarGsc05_CODE
                                      THEN @Lc_ReasonStatusUb_CODE
                                     WHEN @Lc_FarGsc5b_CODE
                                      THEN @Lc_ReasonStatusUc_CODE
                                     WHEN @Lc_FarGsc06_CODE
                                      THEN @Lc_ReasonStatusIk_CODE
                                     WHEN @Lc_FarGsc07_CODE
                                      THEN @Lc_ReasonStatusUm_CODE
                                     WHEN @Lc_FarGsc08_CODE
                                      THEN @Lc_ReasonStatusIj_CODE
                                     WHEN @Lc_FarGsc09_CODE
                                      THEN @Lc_ReasonStatusIu_CODE
                                     WHEN @Lc_FarGsc10_CODE
                                      THEN @Lc_ReasonStatusGv_CODE
                                     WHEN @Lc_FarGsc11_CODE
                                      THEN @Lc_ReasonStatusUv_CODE
                                     WHEN @Lc_FarGsc12_CODE
                                      THEN @Lc_ReasonStatusDi_CODE
                                     WHEN @Lc_FarGsc13_CODE
                                      THEN @Lc_ReasonStatusIi_CODE
                                     WHEN @Lc_FarGsc15_CODE
                                      THEN @Lc_ReasonStatusIs_CODE
                                     WHEN @Lc_FarGsc16_CODE
                                      THEN @Lc_ReasonStatusCv_CODE
                                     WHEN @Lc_FarGsc17_CODE
                                      THEN @Lc_ReasonStatusSn_CODE
                                    END;
      END;
    END;

   IF @Lc_ClosureReason_CODE <> @Lc_Space_TEXT
    BEGIN
     IF dbo.BATCH_CM_CASE_CLOSURE_ELIG$SF_CHECK_CREC_ELIG_CASE_CLOSE(@An_Case_IDNO) = @Lc_Yes_INDC
      BEGIN
       SET @Ls_Sql_TEXT = 'SELECT SORD_Y1 - 2';
       SET @Ls_Sqldata_TEXT = 'Case_IDNO: ' + CAST(@An_Case_IDNO AS VARCHAR) + ', Run_DATE: ' + CAST(@Ad_Run_DATE AS VARCHAR);

       SELECT @Ln_OrderSeq_NUMB = ISNULL(a.OrderSeq_NUMB, 0)
         FROM SORD_Y1 a
        WHERE a.Case_IDNO = @An_Case_IDNO
          AND a.TypeOrder_CODE <> @Lc_OrderTypeVoluntary_CODE
          AND @Ad_Run_DATE BETWEEN a.OrderEffective_DATE AND a.OrderEnd_DATE
          AND a.EndValidity_DATE = @Ld_High_DATE;

       SET @Ls_Sql_TEXT = 'SELECT ICAS_Y1';
       SET @Ls_Sqldata_TEXT = 'Case_IDNO: ' + CAST(@An_Case_IDNO AS VARCHAR);

       SELECT @Ln_Trans_QNTY = COUNT(1)
         FROM ICAS_Y1 a
        WHERE a.Case_IDNO = @An_Case_IDNO
          AND a.Status_CODE = @Lc_CaseStatusOpen_CODE
          AND a.End_DATE = @Ld_High_DATE
          AND a.EndValidity_DATE = @Ld_High_DATE;

       -- Exclude cases if a CSENet closure transaction is received and more than one open Intergovernmental Information (ISIN) record exists
       IF @Ln_MemberMci_IDNO <> 0
          AND @Ln_Trans_QNTY <= 1
        BEGIN
         SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_ELFC';
         SET @Ls_Sqldata_TEXT = 'Case_IDNO: ' + CAST(@An_Case_IDNO AS VARCHAR) + ', OrderSeq_NUMB: ' + CAST(@Ln_OrderSeq_NUMB AS VARCHAR) + ', MemberMci_IDNO: ' + CAST(@Ln_MemberMci_IDNO AS VARCHAR) + ', OthpSource_IDNO : 0, TypeChange_CODE: CC, NegPos_CODE: ' + ISNULL(@Lc_NegPosStartRemedy_TEXT, '') + ', ClosureReason_CODE: ' + @Lc_ClosureReason_CODE;

         EXECUTE BATCH_COMMON$SP_INSERT_ELFC
          @An_Case_IDNO                = @An_Case_IDNO,
          @An_OrderSeq_NUMB            = @Ln_OrderSeq_NUMB,
          @An_MemberMci_IDNO           = @Ln_MemberMci_IDNO,
          @An_OthpSource_IDNO          = 0,
          @Ac_TypeChange_CODE          = @Lc_TypeChangeCc_CODE,
          @Ac_NegPos_CODE              = @Lc_NegPosStartRemedy_TEXT,
          @Ac_Process_ID               = @Ac_JobProcess_IDNO,
          @Ad_Create_DATE              = @Ad_Run_DATE,
          @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
          @Ac_WorkerUpdate_ID          = @Lc_BatchRunUser_TEXT,
          @Ac_Reference_ID             = @Lc_ClosureReason_CODE,
          @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
          @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

         IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
          BEGIN
           RAISERROR(50001,16,1);
          END;
        END;
       ELSE IF @Ln_MemberMci_IDNO <> 0
        BEGIN
         SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_ACTIVITY - 3';
         SET @Ls_Sqldata_TEXT = 'Case_IDNO: ' + CAST(@An_Case_IDNO AS VARCHAR) + ', MemberMci_IDNO: ' + CAST(@Ln_MemberMci_IDNO AS VARCHAR) + ', MajorActivityCase_CODE: ' + @Lc_MajorActivityCase_CODE + ', MinorActivity_CODE: ' + @Lc_MinorActivity_CODE + ', SubsystemInterstate_CODE: ' + @Lc_SubsystemInterstate_CODE + ', TransactionEventSeq_NUMB: ' + CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR) + ', BatchRunUser_TEXT: ' + @Lc_BatchRunUser_TEXT + ', Run_DATE: ' + CAST(@Ad_Run_DATE AS VARCHAR) + ', Topci_IDNO: ' + CAST(@Ln_Topic_IDNO AS VARCHAR);

         EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
          @An_Case_IDNO                = @An_Case_IDNO,
          @An_MemberMci_IDNO           = @Ln_MemberMci_IDNO,
          @Ac_ActivityMajor_CODE       = @Lc_MajorActivityCase_CODE,
          @Ac_ActivityMinor_CODE       = @Lc_CaseClosureMinorActivity_CODE,
          @Ac_Subsystem_CODE           = 'CM',
          @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
          @Ac_WorkerUpdate_ID          = @Lc_BatchRunUser_TEXT,
          @Ad_Run_DATE                 = @Ad_Run_DATE,
          @An_Topic_IDNO               = @Ln_Topic_IDNO,
          @Ac_Msg_CODE                 = @Lc_Msg_CODE,
          @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT;

         IF (@Lc_Msg_CODE <> @Lc_StatusSuccess_CODE)
          BEGIN
           EXECUTE BATCH_COMMON$SP_BATE_LOG
            @As_Process_NAME             = @Ls_Process_NAME,
            @As_Procedure_NAME           = @Ls_Procedure_NAME,
            @Ac_Job_ID                   = @Ac_JobProcess_IDNO,
            @Ad_Run_DATE                 = @Ad_Run_DATE,
            @Ac_TypeError_CODE           = @Lc_TypeErrorE_CODE,
            @An_Line_NUMB                = @Ln_Value_QNTY,
            @Ac_Error_CODE               = @Lc_Space_TEXT,
            @As_DescriptionError_TEXT    = @Ls_Sql_TEXT,
            @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
            @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
            @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

           IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
            BEGIN
             RAISERROR(50001,16,1);
            END;
          END;
        END;
      END;
    END;

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

   DECLARE @Li_Error_NUMB     INT = ERROR_NUMBER (),
           @Li_ErrorLine_NUMB INT = ERROR_LINE ();

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
