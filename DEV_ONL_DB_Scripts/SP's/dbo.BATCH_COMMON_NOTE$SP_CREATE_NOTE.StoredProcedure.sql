/****** Object:  StoredProcedure [dbo].[BATCH_COMMON_NOTE$SP_CREATE_NOTE]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_COMMON_NOTE$SP_CREATE_NOTE
Programmer Name		: IMP Team
Description			: 
Frequency			: 
Developed On		:	04/12/2011
Called By			:
Called On			:
--------------------------------------------------------------------------------------------------------------------
Modified By			:
Modified On			:
Version No			: 
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_COMMON_NOTE$SP_CREATE_NOTE]
 @An_Topic_IDNO                     NUMERIC(10) = 0,
 @Ac_Case_IDNO                      CHAR(6),
 @Ac_Category_CODE                  CHAR(2) = ' ',
 @Ac_Subject_CODE                   CHAR(5) = ' ',
 @Ac_TypeContact_CODE               CHAR(3) = ' ',
 @Ac_MethodContact_CODE             CHAR(2) = ' ',
 @Ac_SourceContact_CODE             CHAR(2) = ' ',
 @Ac_TypeAssigned_CODE              CHAR(1) = ' ',
 @Ac_WorkerAssigned_ID              CHAR(30) = ' ',
 @Ac_RoleAssigned_ID                CHAR(10) = ' ',
 @Ad_Received_DATE                  DATE = '12/31/9999',
 @Ac_CallBack_INDC                  CHAR(1) = ' ',
 @Ac_NotifySender_INDC              CHAR(1) = ' ',
 @An_Office_IDNO                    NUMERIC(3) = 0,
 @Ac_OpenCasesCaseRelationship_CODE CHAR(1) = ' ',
 @As_DescriptionNote_TEXT           VARCHAR(4000),
 @As_WorkerSignedOn_IDNO            CHAR(30),
 @Ac_Process_ID                     CHAR(10),
 @An_EventGlobalSeq_NUMB            NUMERIC(19) = 0,
 @An_TransactionEventSeq_NUMB       NUMERIC(19) = 0,
 @As_AddReferral_TEXT               VARCHAR(MAX) = ' ',
 @An_Check_NUMB                     NUMERIC(19) = 0,
 @An_Check_AMNT                     NUMERIC(9, 2) = 0,
 @Ad_Check_DATE                     DATE = '12/31/9999',
 @Ad_Receipt_DATE                   DATE = '12/31/9999',
 @As_DisbursedTo_CODE               VARCHAR(MAX) = ' ',
 @An_MemberMci_IDNO                 NUMERIC(10) = 0,
 @Ac_Msg_CODE                       CHAR(3) OUTPUT,
 @As_DescriptionError_TEXT          VARCHAR(4000) OUTPUT
AS
 BEGIN
  DECLARE @Ln_Error_NUMB                  NUMERIC(11),
          @Ln_ErrorLine_NUMB              NUMERIC(11),
          @Ls_ErrorMessage_TEXT           VARCHAR(200),
          @Ls_DescriptionError_TEXT       VARCHAR(4000),
          @Ln_FetchStatus_QNTY            NUMERIC(10, 0),
          @Ln_Zero_NUMB                   FLOAT(53) = 0,
          @Lc_Space_TEXT                  CHAR = ' ',
          @Ld_High_DATE                   DATE = '12/31/9999',
          @Lc_CaseMemberStatusActive_CODE CHAR = 'A',
          @Lc_CaseStatusOpen_CODE         CHAR(1) = 'O',
          @Lc_No_TEXT                     CHAR = 'N',
          @Lc_StatusSuccess_CODE          CHAR = 'S',
          @Lc_StatusFailed_CODE           CHAR = 'F',
          @Lc_CaseRelationshipNcp_CODE    CHAR(1) = 'A',
          @Lc_CaseRelationshipPf_CODE     CHAR(1) = 'P',
          @Ld_Low_DATE                    DATE = '01/01/0001',
          @Lc_Process_ID                  CHAR(10) = 'NOTE',
          @Lc_Category_CODE               CHAR(2) = 'FM',
          @Lc_StatusResolvedFm_CODE       CHAR(1) = 'P',
          @Lc_SubjectNtenf_CODE           CHAR(5) = 'NTENF',
          @Lc_StatusResolvedCs_CODE       CHAR(1) = 'V',
          @Lc_StatusNf_CODE               CHAR(1) = 'V',
          @Lc_StatusCsS1_CODE             CHAR(1) = 'S',
          @Lc_StatusCsT1_CODE             CHAR(1) = 'T',
          @Lc_ProcessNotc_ID              CHAR(10) = 'NOTC',
          @Ln_EventFunctionalSeq2340_NUMB NUMERIC(4, 0) = 2340,
          @Lc_ActivityMajor_CODE          CHAR(4) = 'CASE',
          @Ln_One_NUMB                    FLOAT(53) = 1,
          @Lc_StatusFn_CODE               CHAR(1) = 'N',
          @Lc_SubjectFaovo_CODE           CHAR(5) = 'FAOVO',
          @Lc_SubjectFaovr_CODE           CHAR(5) = 'FAOVR',
          @Ls_Procedure_NAME              VARCHAR(60),
          @Ls_Sql_TEXT                    VARCHAR(100),
          @Ls_Sqldata_TEXT                VARCHAR(200),
          @Ln_TransactionEventSeq_NUMB    NUMERIC(19),
          @lx_userdef$exception           NVARCHAR(1000)

  BEGIN TRY
   SET @Ac_Msg_CODE = NULL
   SET @As_DescriptionError_TEXT = NULL

   DECLARE @Ln_TopicCase_IDNO          NUMERIC(10, 0),
           @Ln_Topic_IDNO              NUMERIC(10),
           @Ln_MemberMci_IDNO          NUMERIC(10),
           @Lc_WorkerDelegate_ID       CHAR(30),
           @Ln_MajorIntSeq_NUMB        NUMERIC(5) = 0,
           @Ln_MinorIntSeq_NUMB        NUMERIC(5) = 0,
           @Ld_Due_DATE                DATE,
           @Ln_EventGlobalSeq_NUMB     NUMERIC(19),
           @Lc_Subject_CODE            CHAR(5),
           @Lc_Status_CODE             CHAR(1),
           @Lc_StatusCs_CODE           CHAR(1),
           @Lc_Process2_ID             CHAR(10),
           @Lc_RestrictedNote_TEXT     CHAR(1) = ' ',
           @Ln_OrderSeq_NUMB           NUMERIC(2),
           @Ln_CwicSeq_NUMB            NUMERIC(19),
           @Ln_Check_NUMB              NUMERIC(19),
           @Ln_Check_AMNT              NUMERIC(9, 2),
           @Ld_Check_DATE              DATE,
           @Ld_Receipt_DATE            DATE,
           @Lc_DisbursedTo_CODE        CHAR(1),
           @Lc_MemberAcses_IDNO        CHAR(10),
           @Lc_FosterCareF9999999_TEXT CHAR(8) = 'F9999999',
           @Lc_ActivityMajorCase_CODE  CHAR(4) = 'CASE',
           @Lc_RestrictedFlag_INDC     CHAR(1) = ' '

   SET @Ls_Procedure_NAME = 'SP_CREATE_NOTE '
   SET @Ln_EventGlobalSeq_NUMB = @An_EventGlobalSeq_NUMB
   SET @Ln_TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB

   IF dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NVARCHAR(3, @Ln_TransactionEventSeq_NUMB) IS NULL
       OR @Ln_TransactionEventSeq_NUMB = 0
    BEGIN
     SET @Ls_Sql_TEXT = ' BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT '

     DECLARE @Ld_EffectiveEvent_DATE DATE

     SET @Ld_EffectiveEvent_DATE = dbo.BATCH_COMMON_SCALAR$SF_TRUNC_DATE(dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME())

     EXECUTE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
      @Ac_Worker_ID                = @As_WorkerSignedOn_IDNO,
      @Ac_Process_ID               = @Lc_Process_ID,
      @Ad_EffectiveEvent_DATE      = @Ld_EffectiveEvent_DATE,
      @Ac_Note_INDC                = @Lc_No_TEXT,
      @An_EventFunctionalSeq_NUMB  = @Ln_Zero_NUMB,
      @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
      @Ac_Msg_CODE                 = @Ac_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT    = @As_DescriptionError_TEXT OUTPUT

     IF @Ac_Msg_CODE != @Lc_StatusSuccess_CODE
      RETURN
    END

   SET @Ln_Topic_IDNO = @An_Topic_IDNO
   SET @Ln_TopicCase_IDNO = @An_Topic_IDNO

   IF (@Ac_WorkerAssigned_ID IS NULL
       AND @Ac_RoleAssigned_ID IS NULL)
    SET @Lc_WorkerDelegate_ID = @Lc_Space_TEXT
   ELSE
    SET @Lc_WorkerDelegate_ID = ISNULL(@Ac_WorkerAssigned_ID, @Lc_Space_TEXT)

   DECLARE @Lc_CasesCur_Case_IDNO            CHAR(6),
           @Ln_CasesCur_RecordRowNumber_NUMB NUMERIC(15)
   DECLARE @Lc_Case_IDNO                      CHAR(6),
           @Lc_OpenCasesCaseRelationship_CODE CHAR(1)

   SET @Lc_Case_IDNO = @Ac_Case_IDNO
   SET @Lc_OpenCasesCaseRelationship_CODE = @Ac_OpenCasesCaseRelationship_CODE

   DECLARE Cases_Cur CURSOR LOCAL FORWARD_ONLY FOR
    SELECT @Ac_Case_IDNO AS Case_IDNO,
           0 AS RecordRowNumber_NUMB
    UNION
    SELECT DISTINCT
           a.Case_IDNO,
           1 AS RecordRowNumber_NUMB
      FROM CMEM_Y1 AS a,
           CASE_Y1 AS b
     WHERE dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR(@Ac_OpenCasesCaseRelationship_CODE) IS NOT NULL
       AND a.Case_IDNO != @Ac_Case_IDNO
       AND a.MemberMci_IDNO = (SELECT c.MemberMci_IDNO
                                 FROM CMEM_Y1 AS c
                                WHERE c.Case_IDNO = @Lc_Case_IDNO
                                  AND c.CaseRelationship_CODE = @Lc_OpenCasesCaseRelationship_CODE
                                  AND c.CaseMemberStatus_CODE = 'A')
       AND a.CaseRelationship_CODE = @Lc_OpenCasesCaseRelationship_CODE
       AND a.CaseMemberStatus_CODE = 'A'
       AND a.Case_IDNO = b.Case_IDNO
       AND b.StatusCase_CODE = 'O'
     ORDER BY RecordRowNumber_NUMB

   
   OPEN Cases_Cur

   FETCH Cases_Cur INTO @Lc_CasesCur_Case_IDNO, @Ln_CasesCur_RecordRowNumber_NUMB

   SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS

   
   WHILE @Ln_FetchStatus_QNTY = 0
    BEGIN
     SET @Lc_Subject_CODE = @Ac_Subject_CODE

     IF @Ac_Case_IDNO != @Lc_CasesCur_Case_IDNO
        AND @Ac_Category_CODE = @Lc_Category_CODE
      BEGIN
       SET @Lc_StatusCs_CODE = @Lc_StatusResolvedFm_CODE
       SET @Lc_Subject_CODE = @Lc_SubjectNtenf_CODE
      END
     ELSE IF @Ac_Case_IDNO != @Lc_CasesCur_Case_IDNO
        AND @Ac_Category_CODE != @Lc_Category_CODE
      BEGIN
       SET @Lc_StatusCs_CODE = @Lc_StatusResolvedCs_CODE
       SET @Lc_Subject_CODE = @Lc_SubjectNtenf_CODE
      END
     ELSE IF @Ac_Subject_CODE = @Lc_SubjectNtenf_CODE
        AND @Ac_Category_CODE = @Lc_Category_CODE
      SET @Lc_StatusCs_CODE = @Lc_StatusResolvedFm_CODE
     ELSE IF @Ac_Subject_CODE = @Lc_SubjectNtenf_CODE
        AND @Ac_Category_CODE != @Lc_Category_CODE
      SET @Lc_StatusCs_CODE = @Lc_StatusNf_CODE
     ELSE IF @Ac_WorkerAssigned_ID IS NOT NULL
        AND @Ac_RoleAssigned_ID IS NULL
        AND @Ac_Category_CODE != @Lc_Category_CODE
      SET @Lc_StatusCs_CODE = @Lc_StatusCsS1_CODE
     ELSE IF @Ac_WorkerAssigned_ID IS NULL
        AND @Ac_RoleAssigned_ID IS NOT NULL
        AND @Ac_Category_CODE != @Lc_Category_CODE
      SET @Lc_StatusCs_CODE = @Lc_StatusCsT1_CODE
     ELSE IF @Ac_WorkerAssigned_ID IS NULL
        AND @Ac_RoleAssigned_ID IS NULL
        AND @Ac_Category_CODE != @Lc_Category_CODE
      SET @Lc_StatusCs_CODE = @Lc_StatusCsT1_CODE
     ELSE
      SET @Lc_StatusCs_CODE = @Lc_StatusNf_CODE

     IF @Ac_Process_ID = @Lc_ProcessNotc_ID
      BEGIN
       SET @Lc_Process2_ID = @Lc_Process_ID
       SET @Lc_RestrictedNote_TEXT = @Lc_Space_TEXT
      END
     ELSE
      BEGIN
       SET @Lc_Process2_ID = @Ac_Process_ID
       SET @Lc_RestrictedNote_TEXT = @Lc_Space_TEXT
      END

     IF (@Ln_EventGlobalSeq_NUMB IS NULL
          OR @Ln_EventGlobalSeq_NUMB = 0)
        AND @Ac_Category_CODE = @Lc_Category_CODE
      BEGIN
       SET @Ls_Sql_TEXT = ' BATCH_COMMON$SP_GENERATE_SEQ '
       SET @Ls_Sqldata_TEXT = ' EventFunctionalSeq_NUMB ' + ISNULL(CAST(@Ln_EventFunctionalSeq2340_NUMB AS NVARCHAR(MAX)), '') + ' EffectiveEvent_DATE ' + ISNULL(CAST(dbo.BATCH_COMMON_SCALAR$SF_TRUNC_DATE(dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME()) AS NVARCHAR(MAX)), '')

       DECLARE @Ld_EffectiveEvent2_DATE DATE

       SET @Ld_EffectiveEvent2_DATE = dbo.BATCH_COMMON_SCALAR$SF_TRUNC_DATE(dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME())

       EXECUTE BATCH_COMMON$SP_GENERATE_SEQ
        @An_EventFunctionalSeq_NUMB = @Ln_EventFunctionalSeq2340_NUMB,
        @Ac_Process_ID              = @Lc_Process2_ID,
        @Ad_EffectiveEvent_DATE     = @Ld_EffectiveEvent2_DATE,
        @Ac_Note_INDC               = @Lc_No_TEXT,
        @Ac_Worker_ID               = @As_WorkerSignedOn_IDNO,
        @An_EventGlobalSeq_NUMB     = @Ln_EventGlobalSeq_NUMB OUTPUT,
        @Ac_Msg_CODE                = @Ac_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT   = @As_DescriptionError_TEXT OUTPUT

       IF @Ac_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         SET @Ls_Sql_TEXT = ' BATCH_COMMON$SP_GENERATE_SEQ FAILED '

         RAISERROR(50001,16,1);
        END
      END

     IF @Lc_Process2_ID = @Lc_Process_ID
      BEGIN
       SET @Ls_Sql_TEXT = ' SELECT CMEM_Y1 '
       SET @Ls_Sqldata_TEXT = ' Case_IDNO ' + ISNULL(@Ac_Case_IDNO, '')

       SELECT @Ln_MemberMci_IDNO = CMEM_Y1.MemberMci_IDNO
         FROM CMEM_Y1
        WHERE CMEM_Y1.Case_IDNO = @Ac_Case_IDNO
          AND CMEM_Y1.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPf_CODE)
          AND CMEM_Y1.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE

       SET @Ls_Sql_TEXT = ' BATCH_COMMON$SP_INSERT_ACTIVITY '
       SET @Ls_Sqldata_TEXT = ' Case_IDNO ' + ISNULL(@Ac_Case_IDNO, '') + ' Category_CODE ' + ISNULL(@Ac_Category_CODE, '') + ' Subject_CODE ' + ISNULL(@Ac_Subject_CODE, '')
       --Case Journal Entry For the request
       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_ACTIVITY';

       EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
        @An_Case_IDNO                = @Ac_Case_IDNO,
        @An_MemberMci_IDNO           = @Ln_MemberMci_IDNO,
        @Ac_ActivityMajor_CODE       = @Lc_ActivityMajorCase_CODE,
        @Ac_ActivityMinor_CODE       = @Ac_Subject_CODE,
        @Ac_Subsystem_CODE           = @Ac_Category_CODE,
        @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
        @Ac_WorkerUpdate_ID          = @As_WorkerSignedOn_IDNO,
        @Ac_WorkerDelegate_ID        = @Lc_WorkerDelegate_ID,
        @An_Topic_IDNO               = @Ln_TopicCase_IDNO OUTPUT,
        @Ac_Msg_CODE                 = @Ac_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT

       IF @Ac_Msg_CODE != @Lc_StatusSuccess_CODE
        RETURN

       SET @Ln_Topic_IDNO = @Ln_TopicCase_IDNO
      END

     BEGIN
      BEGIN TRY
       SET @Ls_Sql_TEXT = ' SELECT DMNR_Y1 '
       SET @Ls_Sqldata_TEXT = ' Case_IDNO ' + ISNULL(@Ac_Case_IDNO, '')

       SELECT @Ln_MajorIntSeq_NUMB = DMNR_Y1.MajorIntSEQ_NUMB,
              @Ln_MinorIntSeq_NUMB = DMNR_Y1.MinorIntSeq_NUMB,
              @Ld_Due_DATE = DMNR_Y1.Due_DATE,
              @Ln_OrderSeq_NUMB = DMNR_Y1.OrderSeq_NUMB
         FROM DMNR_Y1
        WHERE DMNR_Y1.Topic_IDNO = @Ln_TopicCase_IDNO
          AND DMNR_Y1.Case_IDNO = @Lc_CasesCur_Case_IDNO
          AND DMNR_Y1.ActivityMinor_CODE = @Lc_Subject_CODE
      END TRY

      BEGIN CATCH
       BEGIN
        SET @Ln_MajorIntSeq_NUMB = 0
        SET @Ln_MinorIntSeq_NUMB = 0
        SET @Ld_Due_DATE = dbo.BATCH_COMMON_SCALAR$SF_TRUNC_DATE(dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME())
       END
      END CATCH
     END

     IF @Lc_Subject_CODE = @Lc_SubjectNtenf_CODE
        AND @Ac_Category_CODE != @Lc_Category_CODE
        AND @Ac_WorkerAssigned_ID IS NULL
        AND @Ac_RoleAssigned_ID IS NULL
      BEGIN
       SET @Ls_Sql_TEXT = ' UPDATE_VDMNR '
       SET @Ls_Sqldata_TEXT = ' Case_IDNO ' + ISNULL(@Ac_Case_IDNO, '') + ' Topic_IDNO ' + ISNULL(CAST(@Ln_TopicCase_IDNO AS NVARCHAR(MAX)), '') + ' Subject_CODE ' + ISNULL(@Lc_Subject_CODE, '') + ' Category_CODE ' + ISNULL (@Ac_Category_CODE, '')

       UPDATE DMNR_Y1
          SET AlertPrior_DATE = @Ld_High_DATE
        WHERE DMNR_Y1.Case_IDNO = @Lc_CasesCur_Case_IDNO
          AND DMNR_Y1.OrderSeq_NUMB = @Ln_OrderSeq_NUMB
          AND DMNR_Y1.MajorIntSEQ_NUMB = @Ln_MajorIntSeq_NUMB
          AND DMNR_Y1.MinorIntSeq_NUMB = @Ln_MinorIntSeq_NUMB
          AND DMNR_Y1.ActivityMinor_CODE = @Lc_Subject_CODE
          AND DMNR_Y1.Topic_IDNO = @Ln_TopicCase_IDNO

       IF @@ROWCOUNT = 0
        BEGIN
         SET @Ls_Sql_TEXT = ' UPDATE_VDMNR FAILED '

         RAISERROR(50001,16,1);
        END
      END

     SET @Ls_Sql_TEXT = ' INSERT NOTE_Y1 '
     SET @Ls_Sqldata_TEXT = ' Case_IDNO ' + ISNULL(@Ac_Case_IDNO, '')

     IF @Ac_Category_CODE = @Lc_Category_CODE
      BEGIN
       SET @Lc_Status_CODE = @Lc_StatusFn_CODE
      END
     ELSE
      BEGIN
       SET @Lc_Status_CODE = @Lc_StatusCs_CODE
      END

     DECLARE @Ln_Nextval_NUMB NUMERIC(38, 0)
     BEGIN TRANSACTION

     DELETE FROM IdentSeqTopic_T1;

     INSERT INTO IdentSeqTopic_T1
          VALUES (dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME());

     SELECT @Ln_Nextval_NUMB = Seq_IDNO
       FROM IdentSeqTopic_T1;

     COMMIT TRANSACTION

     INSERT NOTE_Y1
            (Case_IDNO,
             Topic_IDNO,
             Post_IDNO,
             MajorIntSEQ_NUMB,
             MinorIntSeq_NUMB,
             Office_IDNO,
             Category_CODE,
             Subject_CODE,
             CallBack_INDC,
             NotifySender_INDC,
             TypeContact_CODE,
             SourceContact_CODE,
             MethodContact_CODE,
             Status_CODE,
             TypeAssigned_CODE,
             WorkerAssigned_ID,
             RoleAssigned_ID,
             WorkerCreated_ID,
             Start_DATE,
             Due_DATE,
             Action_DATE,
             Received_DATE,
             OpenCases_CODE,
             DescriptionNote_TEXT,
             BeginValidity_DATE,
             EndValidity_DATE,
             WorkerUpdate_ID,
             TransactionEventSeq_NUMB,
             EventGlobalSeq_NUMB,
             Update_DTTM,
             TotalReplies_QNTY,
             TotalViews_QNTY)
     VALUES ( @Lc_CasesCur_Case_IDNO,
              CASE
               WHEN @Ln_Topic_IDNO = @Ln_Zero_NUMB
                THEN @Ln_Nextval_NUMB
               WHEN @Ln_Topic_IDNO IS NULL
                THEN @Ln_Nextval_NUMB
               ELSE @Ln_Topic_IDNO
              END,
              @Ln_One_NUMB,
              @Ln_MajorIntSeq_NUMB,
              @Ln_MinorIntSeq_NUMB,
              ISNULL(@An_Office_IDNO, @Lc_Space_TEXT),
              ISNULL(@Ac_Category_CODE, @Lc_Space_TEXT),
              @Lc_Subject_CODE,
              ISNULL(@Ac_CallBack_INDC, @Lc_Space_TEXT),
              ISNULL(@Ac_NotifySender_INDC, @Lc_No_TEXT),
              ISNULL(@Ac_TypeContact_CODE, @Lc_Space_TEXT),
              ISNULL(@Ac_SourceContact_CODE, @Lc_Space_TEXT),
              ISNULL(@Ac_MethodContact_CODE, @Lc_Space_TEXT),
              CASE
               WHEN @Ac_Category_CODE = @Lc_Category_CODE
                THEN @Lc_StatusFn_CODE
               ELSE @Lc_StatusCs_CODE
              END,
              ISNULL(@Ac_TypeAssigned_CODE, @Lc_Space_TEXT),
              ISNULL(@Ac_WorkerAssigned_ID, @Lc_Space_TEXT),
              @Lc_Space_TEXT,
              ISNULL(@As_WorkerSignedOn_IDNO, @Lc_Space_TEXT),
              dbo.BATCH_COMMON_SCALAR$SF_TRUNC_DATE(dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME()),
              ISNULL(@Ld_Due_DATE, dbo.BATCH_COMMON_SCALAR$SF_TRUNC_DATE(dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME())),
              dbo.BATCH_COMMON_SCALAR$SF_TRUNC_DATE(dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME()),
              ISNULL(@Ad_Received_DATE, dbo.BATCH_COMMON_SCALAR$SF_TRUNC_DATE(dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME())),
              ISNULL(@Ac_OpenCasesCaseRelationship_CODE, @Lc_Space_TEXT),
              ISNULL(ISNULL(dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR(@As_AddReferral_TEXT), NULL), '') + ISNULL(@As_DescriptionNote_TEXT, ''),
              dbo.BATCH_COMMON_SCALAR$SF_TRUNC_DATE(dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME()),
              @Ld_High_DATE,
              @As_WorkerSignedOn_IDNO,
              @Ln_TransactionEventSeq_NUMB,
              ISNULL(@Ln_EventGlobalSeq_NUMB, 0),
              dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
              @Ln_Zero_NUMB,
              @Ln_Zero_NUMB)

     IF @@ROWCOUNT = @Ln_Zero_NUMB
      BEGIN
       SET @Ls_Sql_TEXT = ' INSERT NOTE_Y1 FAILED '

       RAISERROR(50001,16,1);
      END;

     IF @Ac_Category_CODE = @Lc_Category_CODE
        AND @Ac_Case_IDNO = @Lc_CasesCur_Case_IDNO
        AND @Lc_Subject_CODE IN (@Lc_SubjectFaovo_CODE, @Lc_SubjectFaovr_CODE)
      BEGIN
      
       SET @Ls_Sql_TEXT = ' SELECT CMEM_Y1 '
       SET @Ls_Sqldata_TEXT = ' Case_IDNO ' + ISNULL(@Ac_Case_IDNO, '')

       EXECUTE BATCH_COMMON_NOTE$SP_VOID_REISSUE_ACSES_CHECK
        @An_Topic_IDNO            = @Ln_Topic_IDNO,
        @Ac_Case_IDNO             = @Lc_CasesCur_Case_IDNO,
        @An_OrderSeq_NUMB         = @Ln_OrderSeq_NUMB,
        @Ac_Category_CODE         = @Ac_Category_CODE,
        @Ac_Subject_CODE          = @Lc_Subject_CODE,
        @An_EventGlobalSeq_NUMB   = @Ln_EventGlobalSeq_NUMB,
        @An_MajorIntSeq_NUMB      = @Ln_MajorIntSeq_NUMB,
        @An_MinorIntSeq_NUMB      = @Ln_MinorIntSeq_NUMB,
        @An_CwicSeq_NUMB          = @Ln_CwicSeq_NUMB,
        @An_Check_NUMB            = @An_Check_NUMB,
        @An_Check_AMNT            = @Ln_Check_AMNT,
        @Ad_Check_DATE            = @Ld_Check_DATE,
        @Ad_Receipt_DATE          = @Ld_Receipt_DATE,
        @As_DisbursedTo_CODE      = @As_DisbursedTo_CODE,
        @An_MemberMci_IDNO        = @An_MemberMci_IDNO,
        @As_WorkerSignedOn_IDNO   = @As_WorkerSignedOn_IDNO,
        @Ac_Msg_CODE              = @Ac_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT

       IF @Ac_Msg_CODE != @Lc_StatusSuccess_CODE
        RETURN
      END

     IF @Ac_Category_CODE = @Lc_Category_CODE
      BEGIN
       SET @Ls_Sql_TEXT = ' BATCH_COMMON$SP_ENTITY_MATRIX_2340 '
       SET @Ls_Sqldata_TEXT = ' EventGlobalSeq_NUMB ' + ISNULL(CAST(@Ln_EventGlobalSeq_NUMB AS NVARCHAR(MAX)), '') + ' EventFunctionalSeq_NUMB ' + ISNULL(CAST(@Ln_EventFunctionalSeq2340_NUMB AS NVARCHAR(MAX)), '') + ' Case_IDNO ' + ISNULL(@Ac_Case_IDNO, '')

       EXECUTE BATCH_COMMON$SP_ENTITY_MATRIX
        @An_EventGlobalSeq_NUMB     = @Ln_EventGlobalSeq_NUMB,
        @An_EventFunctionalSeq_NUMB = @Ln_EventFunctionalSeq2340_NUMB,
        @An_EntityCase_IDNO         = @Lc_CasesCur_Case_IDNO,
        @Ac_EntitySubject_IDNO      = @Lc_Subject_CODE,
        @Ac_EntityStatus_CODE       = @Lc_Status_CODE,
        @Ac_Msg_CODE                = @Ac_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT   = @As_DescriptionError_TEXT OUTPUT

       IF @Ac_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         SET @Ls_Sql_TEXT = ' BATCH_COMMON$SP_ENTITY_MATRIX_2340 FAILED '

         RAISERROR(50001,16,1);
        END
      END

     SET @Ln_Topic_IDNO = NULL
     SET @Lc_Status_CODE = NULL
     SET @Lc_Subject_CODE = NULL
     SET @Ln_EventGlobalSeq_NUMB = 0

     FETCH Cases_Cur INTO @Lc_CasesCur_Case_IDNO, @Ln_CasesCur_RecordRowNumber_NUMB

     SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS
    END

   CLOSE Cases_Cur

   DEALLOCATE Cases_Cur

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE

   IF CURSOR_STATUS('LOCAL', 'Cases_Cur') IN (0, 1)
    BEGIN
     CLOSE Cases_Cur

     DEALLOCATE Cases_Cur
    END

   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();
   SET @Ls_ErrorMessage_TEXT = SUBSTRING(ERROR_MESSAGE(), 1, 200);

   -- Retrieve and log the Error Description.
   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;
  END CATCH
 END


GO
