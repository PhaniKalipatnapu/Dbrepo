/****** Object:  StoredProcedure [dbo].[BATCH_ENF_EMON$SP_SYSTEM_UPDATE]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	  : BATCH_ENF_EMON$SP_SYSTEM_UPDATE
Programmer Name   : IMP Team
Description       : This is for doing System updates while advancing activity chain in Case processor by calling the mentioned procedures 
					in the Activity chain table.
Frequency         :
Developed On      : 01/05/2012
Called BY         : 
Called On		  : BATCH_ENF_EMON$GENERATES_AMENDED_INCOME_WITHHOLDING,BATCH_ENF_ELFC$SP_INITIATE_REMEDY,
					BATCH_ENF_EMON$SP_INSERT_IWEM, BATCH_ENF_EMON$SP_PROCESS_CASE_CLOSURE, BATCH_ENF_EMON$SP_UPDATE_CASE_COOPERATION,
					BATCH_ENF_EMON$SP_UPDATE_COOPERATION_ESTP, BATCH_ENF_EMON$SP_UPDATE_COOPERATION_GTST, BATCH_ENF_EMON$SP_UPDATE_GOODCAUSE_VAPP
					BATCH_ENF_EMON$SP_UPDATE_REVIEW_DATE
--------------------------------------------------------------------------------------------------------------------
Modified BY       :
Modified On       :
Version No        : 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_ENF_EMON$SP_SYSTEM_UPDATE]
 @An_Case_IDNO                NUMERIC(6),
 @An_OrderSeq_NUMB            NUMERIC(5),
 @An_MemberMci_IDNO           NUMERIC(10) = 0,
 @Ac_TypeOthpSource_CODE      CHAR(1),
 @An_OthpSource_IDNO          NUMERIC(10) = 0,
 @Ac_TypeReference_CODE       CHAR(4),
 @Ac_Reference_ID             CHAR(30),
 @Ac_Subsystem_CODE           CHAR(2),
 @Ac_ActivityMajor_CODE       CHAR(4) = '',
 @Ac_ActivityMinor_CODE       CHAR(5) = '',
 @Ac_ReasonStatus_CODE        CHAR(2) = '',
 @An_MajorIntSeq_NUMB         NUMERIC(5) = 0,
 @An_MinorIntSeq_NUMB         NUMERIC(5) = 0,
 @An_TransactionEventSeq_NUMB NUMERIC(19) = 0,
 @Ac_WorkerUpdate_ID          CHAR(30) = '',
 @Ac_SignedonWorker_ID        CHAR(30) = NULL,
 @Ad_Run_DATE                 DATETIME2,
 @Ad_Status_DATE              DATETIME2,
 @Ac_Process_ID               CHAR(10),
 @Ac_Msg_CODE                 CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT    VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_Space_TEXT                       CHAR(1) = ' ',
          @Lc_StatusSuccess_CODE               CHAR(1) = 'S',
          @Lc_StatusFailed_CODE                CHAR(1) = 'F',
          @Lc_TypeOthpSourceCp_CODE            CHAR(1) = 'C',
          @Lc_CaseMemberStatusActive_CODE      CHAR(1) = 'A',
          @Lc_StatusOpen_CODE                  CHAR(1) = 'O',
          @Lc_RespondInitInstate_CODE          CHAR(1) = 'N',
          @Lc_CaseRelationshipCp_CODE          CHAR(1) = 'C',
          @Lc_CaseRelationshipPf_CODE          CHAR(1) = 'P',
          @Lc_CaseRelationshipNcp_CODE         CHAR(1) = 'A',
          @Lc_CaseRelationshipDependant_CODE   CHAR(1) = 'D',
          @Lc_NegPosPositive_CODE              CHAR(1) = 'P',
          @Lc_TypeActivityA_CODE               CHAR(1) = 'A',
          @Lc_TypeActivityH_CODE               CHAR(1) = 'H',
          @Lc_TypeActivityG_CODE               CHAR(1) = 'G',
          @Lc_ReasonStatusPd_CODE              CHAR(2) = 'PD',
          @Lc_ReasonStatusCg_CODE              CHAR(2) = 'CG',
          @Lc_ReasonStatusSh_CODE              CHAR(2) = 'SH',
          @Lc_ReasonStatusPm_CODE              CHAR(2) = 'PM',
          @Lc_ReasonStatusPs_CODE              CHAR(2) = 'PS',
          @Lc_ReasonStatusPt_CODE              CHAR(2) = 'PT',
          @Lc_ScheduleUnitBt_CODE              CHAR(2) = 'BT',
          @Lc_ReqStatusPending_CODE            CHAR(2) = 'PN',
          @Lc_TypeChangeInformationLetter_CODE CHAR(2) = 'IL',
          @Lc_ActivityMajorEstp_CODE           CHAR(4) = 'ESTP',
          @Lc_ActivityMajorCase_CODE           CHAR(4) = 'CASE',
          @Lc_ActivityMajorMapp_CODE           CHAR(4) = 'MAPP',
          @Lc_ActivityMajorNmsn_CODE           CHAR(4) = 'NMSN',
          @Lc_ActivityMinorPatde_CODE          CHAR(5) = 'PATDE',
          @Lc_ActivityMinorAhsna_CODE          CHAR(5) = 'AHSNA',
          @Ls_ProcedureEmonInitiateRemedy_NAME VARCHAR(100) = 'BATCH_ENF_EMON$SP_INITIATE_REMEDY',
          @Ls_Routine_TEXT                     VARCHAR(100) = 'BATCH_ENF_EMON$SP_SYSTEM_UPDATE',
          @Ld_High_DATE                        DATE = '12/31/9999',
          @Ld_Low_DATE                         DATE = '01/01/0001';
  DECLARE @Li_Error_NUMB                  INT,
          @Li_ErrorLine_NUMB              INT,
          @Li_FetchStatus_QNTY            INT,
          @Li_FetchStatus1_QNTY           INT,
          @Li_RowCount_NUMB               INT,
          @Ln_Topic_IDNO                  NUMERIC(10) = 0,
          @Lc_TypeActivity_CODE           CHAR(1),
          @Lc_Action1_CODE                CHAR(1),
          @Lc_Action2_CODE                CHAR(1),
          @Lc_RespondInit_CODE            CHAR(1) = '',
          @Lc_SchedulingUnit_CODE         CHAR(2) = '',
          @Lc_Function1_CODE              CHAR(3) = '',
          @Lc_Function2_CODE              CHAR(3) = '',
          @Lc_Reason1_CODE                CHAR(5),
          @Lc_Reason2_CODE                CHAR(5),
          @Lc_Alert_CODE                  CHAR(5) = '',
          @Lc_File_ID                     CHAR(15),
          @Ls_Procedure_NAME              VARCHAR(75) = '',
          @Ls_CsenetComment1_TEXT         VARCHAR(300),
          @Ls_CsenetComment2_TEXT         VARCHAR(300),
          @Ls_Sql_TEXT                    VARCHAR(400),
          @Ls_SqlData_TEXT                VARCHAR(800),
          @Ls_DescriptionError_TEXT       VARCHAR(4000),
          @Ls_SQLProcParameterString_TEXT NVARCHAR(4000),
          @Ls_ExecuteString_TEXT          NVARCHAR(4000),
          @Ls_ParamDefinition_TEXT        NVARCHAR(4000),
          @Ld_Schedule_DATE               DATE = @Ld_Low_DATE,
          @Ld_Update_DTTM                 DATETIME2 = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
  DECLARE @Lc_CsnetTrigCur_IVDOutOfStateFips_CODE       CHAR(2),
          @Lc_CsnetTrigCur_IVDOutOfStateCountyFips_CODE CHAR(3),
          @Lc_CsnetTrigCur_IVDOutOfStateOfficeFips_CODE CHAR(2),
          @Lc_CsnetTrigCur_IVDOutOfStateCase_ID         CHAR(15),
          @Lc_Csm12_CUR_Notice_ID                       CHAR(14);

  --DECLARE CsnetTrig_CUR CURSOR;          
  BEGIN TRY
   -- Setup Suspension Reason and from LSNR - License suspension and non-renewal chain
   DECLARE @CSM12Trigger_P1 TABLE (
    ActivityMajor_CODE CHAR(4),
    ActivityMinor_CODE CHAR(5),
    Reason_CODE        CHAR(2),
    Notice_ID          CHAR(14));

   --Reason 1
   INSERT INTO @CSM12Trigger_P1
               (ActivityMajor_CODE,
                ActivityMinor_CODE,
                Reason_CODE,
                Notice_ID)
        VALUES('ESTP',
               'ADAGR',
               'PJ',
               'NOPRI~CSM-12A');

   INSERT INTO @CSM12Trigger_P1
               (ActivityMajor_CODE,
                ActivityMinor_CODE,
                Reason_CODE,
                Notice_ID)
        VALUES('ESTP',
               'ADAGR',
               'PJ',
               'NOPRI~CSM-12B');

   INSERT INTO @CSM12Trigger_P1
               (ActivityMajor_CODE,
                ActivityMinor_CODE,
                Reason_CODE,
                Notice_ID)
        VALUES('MAPP',
               'ADAGR',
               'PJ',
               'NOPRI~CSM-12A');

   INSERT INTO @CSM12Trigger_P1
               (ActivityMajor_CODE,
                ActivityMinor_CODE,
                Reason_CODE,
                Notice_ID)
        VALUES('MAPP',
               'ADAGR',
               'PJ',
               'NOPRI~CSM-12B');

   --Reason 2
   INSERT INTO @CSM12Trigger_P1
               (ActivityMajor_CODE,
                ActivityMinor_CODE,
                Reason_CODE,
                Notice_ID)
        VALUES('OBRA',
               'WTRPA',
               'AF',
               'NOPRI~CSM-12A');

   INSERT INTO @CSM12Trigger_P1
               (ActivityMajor_CODE,
                ActivityMinor_CODE,
                Reason_CODE,
                Notice_ID)
        VALUES('OBRA',
               'MONLS',
               'UN',
               'NOPRI~CSM-12A');

   --Reason 3
   INSERT INTO @CSM12Trigger_P1
               (ActivityMajor_CODE,
                ActivityMinor_CODE,
                Reason_CODE,
                Notice_ID)
        VALUES('IMIW',
               'NSOII',
               'OX',
               'NOPRI~CSM-12A');

   --Reason 4
   -- Checkbox 49a  --Checkbox 49b --49c
   INSERT INTO @CSM12Trigger_P1
               (ActivityMajor_CODE,
                ActivityMinor_CODE,
                Reason_CODE,
                Notice_ID)
        VALUES('LSNR',
               'CELIS',
               'LS',
               'NOPRI~CSM-12A');

   INSERT INTO @CSM12Trigger_P1
               (ActivityMajor_CODE,
                ActivityMinor_CODE,
                Reason_CODE,
                Notice_ID)
        VALUES('LSNR',
               'RNCPL',
               'NR',
               'NOPRI~CSM-12A');

   INSERT INTO @CSM12Trigger_P1
               (ActivityMajor_CODE,
                ActivityMinor_CODE,
                Reason_CODE,
                Notice_ID)
        VALUES('LSNR',
               'INFFF',
               'FS',
               'NOPRI~CSM-12A');

   INSERT INTO @CSM12Trigger_P1
               (ActivityMajor_CODE,
                ActivityMinor_CODE,
                Reason_CODE,
                Notice_ID)
        VALUES('LSNR',
               'RRADH',
               'ZJ',
               'NOPRI~CSM-12A');

   INSERT INTO @CSM12Trigger_P1
               (ActivityMajor_CODE,
                ActivityMinor_CODE,
                Reason_CODE,
                Notice_ID)
        VALUES('LSNR',
               'MONPP',
               'ZQ',
               'NOPRI~CSM-12A');
               
	-- 13383 - CR0379 Capias License Suspension on Non-Ordered Cases - Start
	INSERT INTO @CSM12Trigger_P1
               (ActivityMajor_CODE,
                ActivityMinor_CODE,
                Reason_CODE,
                Notice_ID)
        VALUES('CPLS',
               'INFFF',
               'FS',
               'NOPRI~CSM-12A');
               
	INSERT INTO @CSM12Trigger_P1
               (ActivityMajor_CODE,
                ActivityMinor_CODE,
                Reason_CODE,
                Notice_ID)
        VALUES('CPLS',
               'RRADH',
               'ZJ',
               'NOPRI~CSM-12A');
	-- 13383 - CR0379 Capias License Suspension on Non-Ordered Cases - End

   --Reason 5
   INSERT INTO @CSM12Trigger_P1
               (ActivityMajor_CODE,
                ActivityMinor_CODE,
                Reason_CODE,
                Notice_ID)
        VALUES('LSNR',
               'MOFRE',
               'GB',
               'NOPRI~CSM-12A');

   INSERT INTO @CSM12Trigger_P1
               (ActivityMajor_CODE,
                ActivityMinor_CODE,
                Reason_CODE,
                Notice_ID)
        VALUES('LSNR',
               'MOFRE',
               'LF',
               'NOPRI~CSM-12A');

   INSERT INTO @CSM12Trigger_P1
               (ActivityMajor_CODE,
                ActivityMinor_CODE,
                Reason_CODE,
                Notice_ID)
        VALUES('LSNR',
               'MOFRE',
               'NY',
               'NOPRI~CSM-12A');
               
	-- 13383 - CR0379 Capias License Suspension on Non-Ordered Cases - Start
	INSERT INTO @CSM12Trigger_P1
               (ActivityMajor_CODE,
                ActivityMinor_CODE,
                Reason_CODE,
                Notice_ID)
        VALUES('CPLS',
               'MOFRE',
               'GB',
               'NOPRI~CSM-12A');
	-- 13383 - CR0379 Capias License Suspension on Non-Ordered Cases - End

   --Reason 6
   INSERT INTO @CSM12Trigger_P1
               (ActivityMajor_CODE,
                ActivityMinor_CODE,
                Reason_CODE,
                Notice_ID)
        VALUES('CRPT',
               'RENCP',
               'NR',
               'NOPRI~CSM-12A');

   INSERT INTO @CSM12Trigger_P1
               (ActivityMajor_CODE,
                ActivityMinor_CODE,
                Reason_CODE,
                Notice_ID)
        VALUES('CRPT',
               'SADMH',
               'FS',
               'NOPRI~CSM-12A');

   INSERT INTO @CSM12Trigger_P1
               (ActivityMajor_CODE,
                ActivityMinor_CODE,
                Reason_CODE,
                Notice_ID)
        VALUES('CRPT',
               'INFFF',
               'FS',
               'NOPRI~CSM-12A');

   INSERT INTO @CSM12Trigger_P1
               (ActivityMajor_CODE,
                ActivityMinor_CODE,
                Reason_CODE,
                Notice_ID)
        VALUES('CRPT',
               'RROAH',
               'NM',
               'NOPRI~CSM-12A');

   INSERT INTO @CSM12Trigger_P1
               (ActivityMajor_CODE,
                ActivityMinor_CODE,
                Reason_CODE,
                Notice_ID)
        VALUES('CRPT',
               'RROAH',
               'FS',
               'NOPRI~CSM-12A');

   INSERT INTO @CSM12Trigger_P1
               (ActivityMajor_CODE,
                ActivityMinor_CODE,
                Reason_CODE,
                Notice_ID)
        VALUES('CRPT',
               'ACDNA',
               'UA',
               'NOPRI~CSM-12A');

   INSERT INTO @CSM12Trigger_P1
               (ActivityMajor_CODE,
                ActivityMinor_CODE,
                Reason_CODE,
                Notice_ID)
        VALUES('CRPT',
               'CAFRD',
               'EI',
               'NOPRI~CSM-12A');

   INSERT INTO @CSM12Trigger_P1
               (ActivityMajor_CODE,
                ActivityMinor_CODE,
                Reason_CODE,
                Notice_ID)
        VALUES('CRPT',
               'CAFRD',
               'UI',
               'NOPRI~CSM-12A');

   /* @Ac_SignedonWorker_ID value passed from the online screens*/
   IF (LTRIM(RTRIM(@Ac_SignedonWorker_ID)) IS NOT NULL)
       OR (LTRIM(RTRIM(@Ac_SignedonWorker_ID)) != '')
    BEGIN
     SET @Ac_WorkerUpdate_ID = @Ac_SignedonWorker_ID;
    END
   ELSE
    BEGIN
     SET @Ac_SignedonWorker_ID = @Ac_WorkerUpdate_ID;
    END

   SET @Ls_Sql_TEXT = 'SELECT ANXT_Y1, AMNR_Y1';
   SET @Ls_SqlData_TEXT = @Lc_Space_TEXT;

   SELECT @Ls_Procedure_NAME = y.Procedure_NAME,
          @Lc_Alert_CODE = y.Alert_CODE,
          @Lc_Function1_CODE = y.Function1_CODE,
          @Lc_Action1_CODE = y.Action1_CODE,
          @Lc_Reason1_CODE = y.Reason1_CODE,
          @Lc_Function2_CODE = y.Function2_CODE,
          @Lc_Action2_CODE = y.Action2_CODE,
          @Lc_Reason2_CODE = y.Reason2_CODE,
          @Ls_CsenetComment1_TEXT = y.CsenetComment1_TEXT,
          @Ls_CsenetComment2_TEXT = y.CsenetComment2_TEXT,
          @Lc_TypeActivity_CODE = a.TypeActivity_CODE
     FROM ANXT_Y1 y
          JOIN AMNR_Y1 a
           ON a.ActivityMinor_CODE = y.ActivityMinorNext_CODE
              AND a.EndValidity_DATE = @Ld_High_DATE
    WHERE y.ActivityMajor_CODE = @Ac_ActivityMajor_CODE
      AND y.ActivityMinor_CODE = @Ac_ActivityMinor_CODE
      AND y.Reason_CODE = @Ac_ReasonStatus_CODE
      AND y.EndValidity_DATE = @Ld_High_DATE;

   IF LTRIM(RTRIM(@Ls_Procedure_NAME)) IS NOT NULL
    BEGIN
     SET @Ls_SQLProcParameterString_TEXT = (SELECT STUFF((SELECT ',' + Parameter_NAME + CASE
                                                                                         WHEN Output_INDC = 'Y'
                                                                                          THEN ' output'
                                                                                         ELSE ''
                                                                                        END
                                                            FROM PPRM_Y1
                                                           WHERE Procedure_NAME = @Ls_Procedure_NAME
                                                           ORDER BY ParameterPosition_NUMB
                                                          FOR XML PATH('')), 1, 1, ''));
     SET @Ls_ParamDefinition_TEXT = '@An_Case_IDNO NUMERIC(6),
									@An_OrderSeq_NUMB NUMERIC(5),	
									@An_MemberMci_IDNO NUMERIC(10),		
									@An_OthpSource_IDNO NUMERIC(10),
									@Ac_Subsystem_CODE CHAR(2),
									@Ac_ActivityMajor_CODE CHAR(4),
									@Ac_ActivityMinor_CODE CHAR(5),
									@Ac_ReasonStatus_CODE CHAR(2),
									@An_MajorIntSeq_NUMB NUMERIC(5),
									@An_MinorIntSeq_NUMB NUMERIC(5),
									@Ac_TypeOthpSource_CODE CHAR(1),
									@Ac_TypeReference_CODE CHAR(4),
									@Ac_Reference_ID	CHAR(30),
									@Ac_Process_ID CHAR(10),
									@An_TransactionEventSeq_NUMB NUMERIC(19),
									@Ac_WorkerUpdate_ID CHAR(30),
									@Ac_SignedonWorker_ID CHAR(30),
									@Ac_TypeChange_CODE CHAR(2),
									@Ad_Run_DATE DATETIME2(0),
									@Ad_Status_DATE DATETIME2(0),
									@Ac_Msg_CODE VARCHAR(100)  OUTPUT,
									@As_DescriptionError_TEXT VARCHAR(4000)  OUTPUT';
     SET @Ls_ExecuteString_TEXT = 'EXEC ' + @Ls_Procedure_NAME + ' ' + @Ls_SQLProcParameterString_TEXT;

     MULTIPLEINSTANCE:

     EXECUTE SP_EXECUTESQL
      @Ls_ExecuteString_TEXT,
      @Ls_ParamDefinition_TEXT,
      @An_Case_IDNO               = @An_Case_IDNO,
      @An_OrderSeq_NUMB           = @An_OrderSeq_NUMB,
      @An_MemberMci_IDNO          = @An_MemberMci_IDNO,
      @An_OthpSource_IDNO         = @An_OthpSource_IDNO,
      @Ac_TypeOthpSource_CODE     = @Ac_TypeOthpSource_CODE,
      @Ac_TypeReference_CODE      = @Ac_TypeReference_CODE,
      @Ac_Reference_ID            = @Ac_Reference_ID,
      @Ac_ActivityMajor_CODE      = @Ac_ActivityMajor_CODE,
      @Ac_ActivityMinor_CODE      = @Ac_ActivityMinor_CODE,
      @Ac_ReasonStatus_CODE       = @Ac_ReasonStatus_CODE,
      @Ac_TypeChange_CODE         = '',
      @Ac_Subsystem_CODE          = @Ac_Subsystem_CODE,
      @An_MajorIntSeq_NUMB        = @An_MajorIntSeq_NUMB,
      @An_MinorIntSeq_NUMB        = @An_MinorIntSeq_NUMB,
      @An_TransactionEventSeq_NUMB= @An_TransactionEventSeq_NUMB,
      @Ac_WorkerUpdate_ID         = @Ac_WorkerUpdate_ID,
      @Ac_SignedonWorker_ID       = @Ac_SignedonWorker_ID,
      @Ad_Run_DATE                = @Ad_Run_DATE,
      @Ad_Status_DATE             = @Ad_Status_DATE,
      @Ac_Process_ID              = @Ac_Process_ID,
      @Ac_Msg_CODE                = @Ac_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT   = @Ls_DescriptionError_TEXT OUTPUT;
    END

   IF (@Ac_Msg_CODE != @Lc_StatusSuccess_CODE)
    BEGIN
     IF (LEN(@Ac_Msg_CODE) != 5)
      BEGIN
       RAISERROR(50001,16,1);
      END

     RETURN;
    END

   IF (@Ls_Procedure_NAME = @Ls_ProcedureEmonInitiateRemedy_NAME
       AND @Ac_ActivityMajor_CODE = @Lc_ActivityMajorEstp_CODE
       AND @Ac_ActivityMinor_CODE = @Lc_ActivityMinorPatde_CODE
       AND @Ac_ReasonStatus_CODE = @Lc_ReasonStatusPd_CODE
       AND @Ac_TypeOthpSource_CODE != @Lc_TypeOthpSourceCp_CODE)
    BEGIN
     SET @Ac_TypeOthpSource_CODE = @Lc_TypeOthpSourceCp_CODE;

     SELECT @An_OthpSource_IDNO = c.MemberMci_IDNO
       FROM CMEM_Y1 c
      WHERE c.Case_IDNO = @An_Case_IDNO
        AND c.CaseRelationship_CODE = @Lc_TypeOthpSourceCp_CODE
        AND c.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE;

     GOTO MultipleInstance;
    END

   /* Inserting Additional alerts which are described in Alert_CODE column of ANXT STARTS*/
   IF LTRIM(RTRIM(@Lc_Alert_CODE)) != ''
      AND @Lc_Alert_CODE IS NOT NULL
    BEGIN
     SET @Ls_Sql_TEXT = 'SELECT DPRS_Y1, CASE_Y1';
     SET @Ls_SqlData_TEXT = 'MemberMci_IDNO = ' + CAST(@An_MemberMci_IDNO AS VARCHAR(10)) + ', Case_IDNO = ' + CAST(@An_Case_IDNO AS VARCHAR(6));

     -- Conditionally generate Information Alert only for the Minor Activity 'AHSNA' only when NCP has attorney
     IF (@Lc_Alert_CODE != @Lc_ActivityMinorAhsna_CODE
          OR (@Lc_Alert_CODE = @Lc_ActivityMinorAhsna_CODE
              AND @@ROWCOUNT != 0))
      BEGIN
       -- Getting Membermci_idno from othpsoruce_idno for additional alert            
       IF @Ac_TypeOthpSource_CODE IN (@Lc_CaseRelationshipPf_CODE, @Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipCp_CODE, @Lc_CaseRelationshipDependant_CODE)
        BEGIN
         SET @An_MemberMci_IDNO = @An_OthpSource_IDNO;
        END
       ELSE IF @Ac_ActivityMajor_CODE = @Lc_ActivityMajorNmsn_CODE
        BEGIN
         SET @An_MemberMci_IDNO = CAST(@Ac_Reference_ID AS NUMERIC(10));
        END

       SET @Ls_Sql_TEXT = 'INSERTING ADDITIONAL ALERTS SP_INSERT_ACTIVITY';
       SET @Ls_SqlData_TEXT = 'MemberMci_IDNO = ' + CAST(@An_MemberMci_IDNO AS VARCHAR(10)) + ', Case_IDNO = ' + CAST(@An_Case_IDNO AS VARCHAR(6));

       --Case Journal Entry For the request
       EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
        @An_Case_IDNO                = @An_Case_IDNO,
        @An_MemberMci_IDNO           = @An_MemberMci_IDNO,
        @Ac_ActivityMajor_CODE       = @Lc_ActivityMajorCase_CODE,
        @Ac_ActivityMinor_CODE       = @Lc_Alert_CODE,
        @Ac_Subsystem_CODE           = @Ac_Subsystem_CODE,
        @An_TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB,
        @Ac_WorkerUpdate_ID          = @Ac_WorkerUpdate_ID,
        @Ac_Job_ID                   = @Ac_Process_ID,
        @An_Topic_IDNO               = @Ln_Topic_IDNO OUTPUT,
        @Ac_Msg_CODE                 = @Ac_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

       IF (@Ac_Msg_CODE != @Lc_StatusSuccess_CODE)
        BEGIN
         IF (LEN(@Ac_Msg_CODE) != 5)
          BEGIN
           RAISERROR(50001,16,1);
          END

         RETURN;
        END
      END
    END

  /* Inserting Additional alerts which are described in Alert_CODE column of ANXT ENDS*/
   /*Csnet Trigger - Starts*/
   SET @Ls_Sql_TEXT = 'CsnetTrig_CUR Cursor';
   SET @Ls_SqlData_TEXT = ' Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR(6)), '') + ', Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR(20)), '');

   DECLARE CsnetTrig_CUR INSENSITIVE CURSOR FOR
    SELECT DISTINCT
           e.IVDOutOfStateFips_CODE,
           e.IVDOutOfStateCountyFips_CODE,
           e.IVDOutOfStateOfficeFips_CODE,
           e.IVDOutOfStateCase_ID
      FROM ICAS_Y1 e
     WHERE e.Case_IDNO = @An_Case_IDNO
       AND e.EndValidity_DATE = @Ld_High_DATE
       AND e.Status_CODE = @Lc_StatusOpen_CODE
       AND @Ad_Run_DATE BETWEEN e.Effective_DATE AND e.End_DATE;

   SET @Ls_Sql_TEXT = 'SELECT SORD';
   SET @Ls_SqlData_TEXT = ' Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR(6)), '');
   SET @Ls_Sql_TEXT = 'SELECT CASE_Y1';

   SELECT @Lc_File_ID = c.File_ID,
          @Lc_RespondInit_CODE = c.RespondInit_CODE
     FROM CASE_Y1 c
    WHERE c.Case_IDNO = @An_Case_IDNO;

   --Opening CsnetTrig_CUR Cursor
   SET @Ls_Sql_TEXT = 'OPEN  CsnetTrig_CUR';
   SET @Ls_SqlData_TEXT = @Lc_Space_TEXT;

   OPEN CsnetTrig_CUR;

   SET @Ls_Sql_TEXT = 'SELECT SWKS_Y1,DMNR_Y1';
   SET @Ls_SqlData_TEXT = ' Case_IDNO = ' + CAST(@An_Case_IDNO AS VARCHAR(6)) + ', MajorIntSeq_NUMB = ' + CAST(@An_MajorIntSeq_NUMB AS VARCHAR(6)) + ', MinorIntSeq_NUMB = ' + CAST(@An_MinorIntSeq_NUMB AS VARCHAR(6));

   SELECT @Lc_SchedulingUnit_CODE = s.SchedulingUnit_CODE,
          @Ld_Schedule_DATE = s.Schedule_DATE
     FROM SWKS_Y1 s
      JOIN DMNR_Y1 n
       ON n.Case_IDNO = s.Case_IDNO
          AND n.ActivityMajor_CODE = @Ac_ActivityMajor_CODE
          AND n.Schedule_NUMB = s.Schedule_NUMB
          AND n.MajorIntSeq_NUMB = @An_MajorIntSeq_NUMB
          AND n.MinorIntSeq_NUMB = @An_MinorIntSeq_NUMB
    WHERE s.Case_IDNO = @An_Case_IDNO;

   -- Determine CSNet Transactions for ESTP, MAPP and ROFO activitity chain hearing.
   IF (@Ac_ReasonStatus_CODE IN (@Lc_ReasonStatusCg_CODE, @Lc_ReasonStatusSh_CODE))
    BEGIN
     -- Generate only one CSNet Trigger combination based on the Scheduling Unit Code.
     IF (@Lc_SchedulingUnit_CODE = @Lc_ScheduleUnitBt_CODE)
      BEGIN
       SET @Lc_Function2_CODE = @Lc_Space_TEXT;
       SET @Lc_Action2_CODE = @Lc_Space_TEXT;
       SET @Lc_Reason2_CODE = @Lc_Space_TEXT;
      END
     ELSE
      BEGIN
       SET @Lc_Function1_CODE = @Lc_Space_TEXT;
       SET @Lc_Action1_CODE = @Lc_Space_TEXT;
       SET @Lc_Reason1_CODE = @Lc_Space_TEXT;
      END
    END;

   IF ((@Lc_Function1_CODE != ''
         OR @Lc_Function2_CODE != '')
       AND @Lc_RespondInit_CODE NOT IN (@Lc_RespondInitInstate_CODE))
    BEGIN
     IF @Lc_TypeActivity_CODE IN (@Lc_TypeActivityA_CODE, @Lc_TypeActivityH_CODE, @Lc_TypeActivityG_CODE)
      BEGIN
       SET @Ls_CsenetComment1_TEXT = 'The hearing is scheduled in the State of Delaware on ' + CONVERT(CHAR(10),@Ld_Schedule_DATE, 101);
       SET @Ls_CsenetComment2_TEXT = @Ls_CsenetComment1_TEXT;
      END
     ELSE
      BEGIN
       SET @Ld_Schedule_DATE = @Ld_Low_DATE;
      END

     --Fetch CsnetTrig_CUR Cursor
     FETCH NEXT FROM CsnetTrig_CUR INTO @Lc_CsnetTrigCur_IVDOutOfStateFips_CODE, @Lc_CsnetTrigCur_IVDOutOfStateCountyFips_CODE, @Lc_CsnetTrigCur_IVDOutOfStateOfficeFips_CODE, @Lc_CsnetTrigCur_IVDOutOfStateCase_ID;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;

     -- While Loop Begins		
     WHILE @Li_FetchStatus_QNTY = 0
      BEGIN
       IF (@Lc_Function1_CODE != '')
        BEGIN
         -- First CSENET Trigger  -- Starts
         SET @Ls_Sql_TEXT = 'BATCH_ENF_EMON$SP_SYSTEM_UPDATE BATCH_COMMON$SP_INSERT_PENDING_REQUEST';
         SET @Ls_SqlData_TEXT = ' Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR(6)), '') + ', Generated_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR(15)), '') + ', IVDOutOfStateFips_CODE = ' + ISNULL(CAST(@Lc_CsnetTrigCur_IVDOutOfStateFips_CODE AS VARCHAR(2)), '') + ', IVDOutOfStateCountyFips_CODE = ' + ISNULL(CAST(@Lc_CsnetTrigCur_IVDOutOfStateCountyFips_CODE AS VARCHAR(3)), '') + ', IVDOutOfStateOfficeFips_CODE = ' + ISNULL(CAST(@Lc_CsnetTrigCur_IVDOutOfStateOfficeFips_CODE AS VARCHAR(2)), '') + ', ExchangeMode_CODE  = ' + @Lc_Space_TEXT + ', StatusRequest_CODE  = ' + @Lc_ReqStatusPending_CODE + ', Function_CODE  = ' + @Lc_Function1_CODE + ', Form_ID  = ' + '0' + ', Action_CODE = ' + ISNULL(CAST(@Lc_Action1_CODE AS VARCHAR(1)), '') + ', Reason_CODE = ' + ISNULL(CAST(@Lc_Reason1_CODE AS VARCHAR(5)), '') + ', DescriptionComments_TEXT = ' + ISNULL(CAST(@Ls_CsenetComment1_TEXT AS VARCHAR(40)), '') + ', IVDOutOfStateCase_ID = ' + ISNULL(CAST(@Lc_CsnetTrigCur_IVDOutOfStateCase_ID AS VARCHAR(16)), '') + ', FILE_ID = ' + ISNULL(CAST(@Lc_File_ID AS VARCHAR(15)), '');

         EXEC BATCH_COMMON$SP_INSERT_PENDING_REQUEST
          @An_Case_IDNO                    = @An_Case_IDNO,
          @An_RespondentMci_IDNO           = @An_MemberMci_IDNO,
          @Ac_Function_CODE                = @Lc_Function1_CODE,
          @Ac_Action_CODE                  = @Lc_Action1_CODE,
          @Ac_Reason_CODE                  = @Lc_Reason1_CODE,
          @Ac_IVDOutOfStateFips_CODE       = @Lc_CsnetTrigCur_IVDOutOfStateFips_CODE,
          @Ac_IVDOutOfStateCountyFips_CODE = @Lc_CsnetTrigCur_IVDOutOfStateCountyFips_CODE,
          @Ac_IVDOutOfStateOfficeFips_CODE = @Lc_CsnetTrigCur_IVDOutOfStateOfficeFips_CODE,
          @Ac_IVDOutOfStateCase_ID         = @Lc_CsnetTrigCur_IVDOutOfStateCase_ID,
          @Ad_Generated_DATE               = @Ad_Run_DATE,
          @Ac_Form_ID                      = '',
          @As_FormWeb_URL                  = @Lc_Space_TEXT,
          @An_TransHeader_IDNO             = 0,
          @As_DescriptionComments_TEXT     = @Ls_CsenetComment1_TEXT,
          @Ac_CaseFormer_ID                = @Lc_Space_TEXT,
          @Ac_InsCarrier_NAME              = @Lc_Space_TEXT,
          @Ac_InsPolicyNo_TEXT             = @Lc_Space_TEXT,
          @Ad_Hearing_DATE                 = @Ld_Schedule_DATE,
          @Ad_Dismissal_DATE               = @Ld_Low_DATE,
          @Ad_GeneticTest_DATE             = @Ld_Low_DATE,
          @Ad_PfNoShow_DATE                = @Ld_Low_DATE,
          @Ac_Attachment_INDC              = 'N',
          @Ac_File_ID                      = @Lc_File_ID,
          @Ad_ArrearComputed_DATE          = @Ld_Low_DATE,
          @An_TotalArrearsOwed_AMNT        = 0,
          @An_TotalInterestOwed_AMNT       = 0,
          @Ac_Process_ID                   = @Ac_Process_ID,
          @Ad_BeginValidity_DATE           = @Ad_Run_DATE,
          @Ac_SignedonWorker_ID            = @Ac_WorkerUpdate_ID,
          @Ad_Update_DTTM                  = @Ld_Update_DTTM,
          @Ac_Msg_CODE                     = @Ac_Msg_CODE OUTPUT,
          @As_DescriptionError_TEXT        = @Ls_DescriptionError_TEXT OUTPUT;

         IF @Ac_Msg_CODE <> @Lc_StatusSuccess_CODE
          BEGIN
           SET @Ls_DescriptionError_TEXT = 'BATCH_ENF_EMON$SP_SYSTEM_UPDATE BATCH_COMMON$SP_INSERT_PENDING_REQUEST FAILED 1 ' + ISNULL(LTRIM(RTRIM(@Ls_DescriptionError_TEXT)), ' ');

           RAISERROR (50001,16,1);
          END
        END

       -- First CSENET Trigger  -- Ends
       -- Second CSENET Trigger  -- Starts
       IF (@Lc_Function2_CODE != '')
        BEGIN
         SET @Ls_Sql_TEXT = 'BATCH_ENF_EMON$SP_SYSTEM_UPDATE BATCH_COMMON$SP_INSERT_PENDING_REQUEST';
         SET @Ls_SqlData_TEXT = ' Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR(6)), '') + ', Generated_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR(15)), '') + ', IVDOutOfStateFips_CODE = ' + ISNULL(CAST(@Lc_CsnetTrigCur_IVDOutOfStateFips_CODE AS VARCHAR(2)), '') + ', IVDOutOfStateCountyFips_CODE = ' + ISNULL(CAST(@Lc_CsnetTrigCur_IVDOutOfStateCountyFips_CODE AS VARCHAR(3)), '') + ', IVDOutOfStateOfficeFips_CODE = ' + ISNULL(CAST(@Lc_CsnetTrigCur_IVDOutOfStateOfficeFips_CODE AS VARCHAR(2)), '') + ', ExchangeMode_CODE  = ' + @Lc_Space_TEXT + ', StatusRequest_CODE  = ' + @Lc_ReqStatusPending_CODE + ', Function_CODE  = ' + @Lc_Function1_CODE + ', Form_ID  = ' + '0' + ', Action_CODE = ' + ISNULL(CAST(@Lc_Action1_CODE AS VARCHAR(1)), '') + ', Reason_CODE = ' + ISNULL(CAST(@Lc_Reason1_CODE AS VARCHAR(5)), '') + ', DescriptionComments_TEXT = ' + ISNULL(CAST(@Ls_CsenetComment1_TEXT AS VARCHAR(40)), '') + ', IVDOutOfStateCase_ID = ' + ISNULL(CAST(@Lc_CsnetTrigCur_IVDOutOfStateCase_ID AS VARCHAR(16)), '') + ', FILE_ID = ' + ISNULL(CAST(@Lc_File_ID AS VARCHAR(15)), '');

         EXEC BATCH_COMMON$SP_INSERT_PENDING_REQUEST
          @An_Case_IDNO                    = @An_Case_IDNO,
          @An_RespondentMci_IDNO           = @An_MemberMci_IDNO,
          @Ac_Function_CODE                = @Lc_Function2_CODE,
          @Ac_Action_CODE                  = @Lc_Action2_CODE,
          @Ac_Reason_CODE                  = @Lc_Reason2_CODE,
          @Ac_IVDOutOfStateFips_CODE       = @Lc_CsnetTrigCur_IVDOutOfStateFips_CODE,
          @Ac_IVDOutOfStateCountyFips_CODE = @Lc_CsnetTrigCur_IVDOutOfStateCountyFips_CODE,
          @Ac_IVDOutOfStateOfficeFips_CODE = @Lc_CsnetTrigCur_IVDOutOfStateOfficeFips_CODE,
          @Ac_IVDOutOfStateCase_ID         = @Lc_CsnetTrigCur_IVDOutOfStateCase_ID,
          @Ad_Generated_DATE               = @Ad_Run_DATE,
          @Ac_Form_ID                      = '',
          @As_FormWeb_URL                  = @Lc_Space_TEXT,
          @An_TransHeader_IDNO             = 0,
          @As_DescriptionComments_TEXT     = @Ls_CsenetComment2_TEXT,
          @Ac_CaseFormer_ID                = @Lc_Space_TEXT,
          @Ac_InsCarrier_NAME              = @Lc_Space_TEXT,
          @Ac_InsPolicyNo_TEXT             = @Lc_Space_TEXT,
          @Ad_Hearing_DATE                 = @Ld_Schedule_DATE,
          @Ad_Dismissal_DATE               = @Ld_Low_DATE,
          @Ad_GeneticTest_DATE             = @Ld_Low_DATE,
          @Ad_PfNoShow_DATE                = @Ld_Low_DATE,
          @Ac_Attachment_INDC              = 'N',
          @Ac_File_ID                      = @Lc_File_ID,
          @Ad_ArrearComputed_DATE          = @Ld_Low_DATE,
          @An_TotalArrearsOwed_AMNT        = 0,
          @An_TotalInterestOwed_AMNT       = 0,
          @Ac_Process_ID                   = @Ac_Process_ID,
          @Ad_BeginValidity_DATE           = @Ad_Run_DATE,
          @Ac_SignedonWorker_ID            = @Ac_WorkerUpdate_ID,
          @Ad_Update_DTTM                  = @Ld_Update_DTTM,
          @Ac_Msg_CODE                     = @Ac_Msg_CODE OUTPUT,
          @As_DescriptionError_TEXT        = @Ls_DescriptionError_TEXT OUTPUT;

         IF @Ac_Msg_CODE <> @Lc_StatusSuccess_CODE
          BEGIN
           SET @Ls_DescriptionError_TEXT = 'BATCH_ENF_EMON$SP_SYSTEM_UPDATE BATCH_COMMON$SP_INSERT_PENDING_REQUEST FAILED 2 ' + ISNULL(LTRIM(RTRIM(@Ls_DescriptionError_TEXT)), ' ');

           RAISERROR (50001,16,1);
          END
        END

       -- Second CSENET Trigger  -- Ends
       --Fetch CsnetTrig_CUR Cursor
       FETCH NEXT FROM CsnetTrig_CUR INTO @Lc_CsnetTrigCur_IVDOutOfStateFips_CODE, @Lc_CsnetTrigCur_IVDOutOfStateCountyFips_CODE, @Lc_CsnetTrigCur_IVDOutOfStateOfficeFips_CODE, @Lc_CsnetTrigCur_IVDOutOfStateCase_ID;

       SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
      END
    END

   CLOSE CsnetTrig_CUR;

   DEALLOCATE CsnetTrig_CUR;

  /*Csnet Trigger - Ends*/
   /*CSM-12 Trigger - Starts*/
   SET @Ls_Sql_TEXT = 'CsnetTrig_CUR Cursor';
   SET @Ls_SqlData_TEXT = ' ActivityMajor_CODE = ' + ISNULL(@Ac_ActivityMajor_CODE, ' ') + ', ActivityMinor_CODE = ' + ISNULL(@Ac_ActivityMinor_CODE, '') + ', Reason_CODE = ' + ISNULL(@Ac_ReasonStatus_CODE, ' ');

   DECLARE Csm12_CUR INSENSITIVE CURSOR FOR
    SELECT DISTINCT
           c.Notice_ID
      FROM @CSM12Trigger_P1 c
     WHERE c.ActivityMajor_CODE = @Ac_ActivityMajor_CODE
       AND c.ActivityMinor_CODE = @Ac_ActivityMinor_CODE
       AND c.Reason_CODE = @Ac_ReasonStatus_CODE;

   --Opening Csm12_CUR Cursor    	
   SET @Ls_Sql_TEXT = 'OPEN  Csm12_CUR';
   SET @Ls_SqlData_TEXT = @Lc_Space_TEXT;

   OPEN Csm12_CUR;

   --Fetch Csm12_CUR Cursor 
   FETCH NEXT FROM Csm12_CUR INTO @Lc_Csm12_CUR_Notice_ID;

   SET @Li_FetchStatus1_QNTY = @@FETCH_STATUS;

   -- While Loop Begins		                                                                                                                                                          
   WHILE @Li_FetchStatus1_QNTY = 0
    BEGIN
     SET @Ls_Sql_TEXT = 'SELECT DMNR_Y1';

     SELECT @Li_RowCount_NUMB = COUNT(1)
       FROM DMNR_Y1 d
      WHERE d.Case_IDNO = @An_Case_IDNO
        AND d.ActivityMajor_CODE = @Ac_ActivityMajor_CODE
        AND d.MajorIntSeq_NUMB = @An_MajorIntSeq_NUMB
        AND d.ReasonStatus_CODE IN (@Lc_ReasonStatusPm_CODE, @Lc_ReasonStatusPs_CODE, @Lc_ReasonStatusPt_CODE);

     -- For MAPP activity alone row count should be greater than 0. 
     IF (@Ac_ActivityMajor_CODE != @Lc_ActivityMajorMapp_CODE
          OR (@Ac_ActivityMajor_CODE = @Lc_ActivityMajorMapp_CODE
              AND @Li_RowCount_NUMB > 0))
      BEGIN
       SET @Ls_SqlData_TEXT = ' Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR(6)), '') + ', Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR(20)), '');
       SET @Ls_Sql_TEXT = 'EXEC  BATCH_COMMON$SP_INSERT_ELFC';

       EXECUTE BATCH_COMMON$SP_INSERT_ELFC
        @An_Case_IDNO                = @An_Case_IDNO,
        @An_OrderSeq_NUMB            = @An_OrderSeq_NUMB,
        @An_MemberMci_IDNO           = @An_MemberMci_IDNO,
        @An_OthpSource_IDNO          = 0,
        @Ac_TypeChange_CODE          = @Lc_TypeChangeInformationLetter_CODE,
        @Ac_NegPos_CODE              = @Lc_NegPosPositive_CODE,
        @Ac_Process_ID               = @Ac_Process_ID,
        @Ad_Create_DATE              = @Ad_Run_DATE,
        @Ac_Reference_ID             = @Lc_Csm12_CUR_Notice_ID,
        @An_TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB,
        @Ac_WorkerUpdate_ID          = @Ac_WorkerUpdate_ID,
        @Ac_Msg_CODE                 = @Ac_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

       IF @Ac_Msg_CODE <> @Lc_StatusSuccess_CODE
        BEGIN
         SET @Ls_DescriptionError_TEXT = 'EXEC  BATCH_COMMON$SP_INSERT_ELFC FAILS';

         RAISERROR (50001,16,1);
        END
      END;

     FETCH NEXT FROM Csm12_CUR INTO @Lc_Csm12_CUR_Notice_ID;

     SET @Li_FetchStatus1_QNTY = @@FETCH_STATUS;
    END

   /*CSM-12 Trigger - Ends*/
   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = @Lc_Space_TEXT;
  END TRY

  BEGIN CATCH
   SET @Li_Error_NUMB = ERROR_NUMBER ();
   SET @Li_ErrorLine_NUMB = ERROR_LINE ();
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

   IF CURSOR_STATUS('Local', 'CsnetTrig_CUR') IN (0, 1)
    BEGIN
     CLOSE CsnetTrig_CUR;

     DEALLOCATE CsnetTrig_CUR;
    END

   IF (@Li_Error_NUMB <> 50001)
    BEGIN
     SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Routine_TEXT,
    @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_SqlData_TEXT,
    @An_Error_NUMB            = @Li_Error_NUMB,
    @An_ErrorLine_NUMB        = @Li_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;
  END CATCH
 END


GO
