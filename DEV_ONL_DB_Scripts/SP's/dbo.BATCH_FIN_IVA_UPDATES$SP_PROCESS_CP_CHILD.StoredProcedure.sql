/****** Object:  StoredProcedure [dbo].[BATCH_FIN_IVA_UPDATES$SP_PROCESS_CP_CHILD]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_FIN_IVA_UPDATES$SP_PROCESS_CP_CHILD
Programmer Name	:	IMP Team.
Description		:	This process re-opens closed cases and/or adds child to existing case and/or changes child's/cp's program type.
Frequency		:	DAILY
Developed On	:	04/12/2012
Called By		:	BATCH_FIN_IVA_UPDATES$SP_SKIP_UPDATE_IVA_REFERRALS,
Called On		:	BATCH_FIN_IVA_UPDATES$SP_UPDATE_MHIS
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_FIN_IVA_UPDATES$SP_PROCESS_CP_CHILD] (
 @Ad_Run_DATE              DATE,
 @Ac_Job_ID                CHAR(7),
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  -- SET NOCOUNT ON After BEGIN Statement:
  SET NOCOUNT ON;

  -- Variable Declarations After SET NOCOUNT ON Statement:
  DECLARE @Li_FetchStatus_QNTY                  SMALLINT = 0,
          @Lc_StatusFailed_CODE                 CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE                CHAR(1) = 'S',
          @Lc_Percenatage_TEXT                  CHAR(1) = '%',
          @Lc_CaseRelationshipChild_CODE        CHAR(1) = 'D',
          @Lc_CaseRelationshipCp_CODE           CHAR(1) = 'C',
          @Lc_TypeWelfareTANF_CODE              CHAR(1) = 'A',
          @Lc_TypeWelfareMedicaid_CODE          CHAR(1) = 'M',
          @Lc_TypeWelfareNonTanf_CODE           CHAR(1) = 'N',
          @Lc_RespondInitR_CODE                 CHAR(1) = 'R',
          @Lc_RespondInitY_CODE                 CHAR(1) = 'Y',
          @Lc_RespondInitS_CODE                 CHAR(1) = 'S',
          @Lc_Note_INDC                         CHAR(1) = 'N',
          @Lc_TypeWelfareIVAPurchaseOfCare_CODE CHAR(1) = 'C',
          @Lc_CaseMemberStatusActive_CODE       CHAR(1) = 'A',
          @Lc_StatusCaseOpen_CODE               CHAR(1) = 'O',
          @Lc_ProcessN_CODE                     CHAR(1) = 'N',
          @Lc_Space_TEXT                        CHAR(1) = ' ',
          @Lc_TypeCaseF_CODE                    CHAR(1) = 'F',
          @Lc_TypeCaseH_CODE                    CHAR(1) = 'H',
          @Lc_Msg_CODE                          CHAR(5) = ' ',
          @Lc_BatchRunUser_TEXT                 CHAR(5) = 'BATCH',
          @Ls_Process_NAME                      VARCHAR(100) = 'BATCH_FIN_IVA_UPDATES',
          @Ls_Procedure_NAME                    VARCHAR(100) = 'BATCH_FIN_IVA_UPDATES$SP_PROCESS_CP_CHILD',
          @Ls_Sql_TEXT                          VARCHAR(2000) = ' ',
          @Ls_DescriptionError_TEXT             VARCHAR(4000) = ' ',
          @Ls_ErrorMessage_TEXT                 VARCHAR(4000) = ' ',
          @Ls_Sqldata_TEXT                      VARCHAR(5000) = ' ',
          @Ld_High_DATE                         DATE = '12/31/9999';
  DECLARE @Ln_ErrorLine_NUMB           NUMERIC(11) = 0,
          @Ln_Error_NUMB               NUMERIC(11) = 0,
          @Ln_TransactionEventSeq_NUMB NUMERIC(19, 0) = 0,
          @Lc_CpProgamType_CODE        CHAR(1),
          @Ld_Run_DATE                 DATE,
          @Ld_Start_DATE               DATETIME2;
  --CURSOR VARIABLE DECLARATION:
  DECLARE @Ln_ChildCpCurCase_IDNO            NUMERIC(6),
          @Ln_ChildCpCurCaseWelfare_IDNO     NUMERIC(10),
          @Ln_ChildCpCurCpMci_IDNO           NUMERIC(10),
          @Ln_ChildCpCurChildMci_IDNO        NUMERIC(10),
          @Lc_ChildCpCurChildProgamType_CODE CHAR(1);
  DECLARE @TempSeqIdno_P1 TABLE (
   Seq_IDNO NUMERIC(19, 0));

  BEGIN TRY
   --Selecting the Batch Start Time
   SET @Ls_Sql_TEXT = 'GET BATCH START DATE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Ac_Job_ID, '');
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   SET @Ld_Run_DATE = @Ad_Run_DATE;
   SET @Ls_Sql_TEXT = 'INSERT Seq_IDNO';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Ac_Job_ID, '');

   INSERT @TempSeqIdno_P1
          (Seq_IDNO)
   SELECT DISTINCT
          l.Seq_IDNO
     FROM LIVAR_Y1 l,
          CASE_Y1 c,
          CMEM_Y1 cp,
          CMEM_Y1 child,
          MHIS_Y1 m
    WHERE l.Process_CODE = @Lc_ProcessN_CODE
      AND l.NcpMci_IDNO = 0
      AND c.Case_IDNO = cp.Case_IDNO
      AND cp.Case_IDNO = child.Case_IDNO
      AND c.StatusCase_CODE = @Lc_StatusCaseOpen_CODE
      AND cp.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
      AND child.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
      AND cp.CaseRelationship_CODE = @Lc_CaseRelationshipCp_CODE
      AND child.CaseRelationship_CODE = @Lc_CaseRelationshipChild_CODE
      AND l.CpMci_IDNO = cp.MemberMci_IDNO
      AND l.ChildMci_IDNO = child.MemberMci_IDNO
      AND c.TypeCase_CODE NOT IN (@Lc_TypeCaseF_CODE, @Lc_TypeCaseH_CODE)
      AND c.RespondInit_CODE NOT IN (@Lc_RespondInitY_CODE, @Lc_RespondInitR_CODE, @Lc_RespondInitS_CODE)
      AND m.TypeWelfare_CODE IN (@Lc_TypeWelfareTANF_CODE, @Lc_TypeWelfareMedicaid_CODE, @Lc_TypeWelfareNonTanf_CODE)
      AND m.CaseWelfare_IDNO = l.CaseWelfare_IDNO
      AND m.Case_IDNO = c.Case_IDNO
      AND m.MemberMci_IDNO = child.MemberMci_IDNO
      AND m.End_DATE = @Ld_High_DATE
      AND ((l.Program_CODE LIKE @Lc_TypeWelfareTANF_CODE + @Lc_Percenatage_TEXT
            AND m.TypeWelfare_CODE IN (@Lc_TypeWelfareMedicaid_CODE, @Lc_TypeWelfareNonTanf_CODE))
            OR (l.Program_CODE LIKE @Lc_TypeWelfareMedicaid_CODE + @Lc_Percenatage_TEXT
                AND m.TypeWelfare_CODE IN (@Lc_TypeWelfareNonTanf_CODE)));

   DECLARE ChildCp_CUR INSENSITIVE CURSOR FOR
    SELECT DISTINCT
           c.Case_IDNO,
           l.CaseWelfare_IDNO,
           l.CpMci_IDNO,
           l.ChildMci_IDNO,
           CASE
            WHEN l.Program_CODE LIKE @Lc_TypeWelfareTANF_CODE + @Lc_Percenatage_TEXT
             THEN @Lc_TypeWelfareTANF_CODE
            WHEN l.Program_CODE LIKE @Lc_TypeWelfareMedicaid_CODE + @Lc_Percenatage_TEXT
             THEN @Lc_TypeWelfareMedicaid_CODE
            WHEN l.Program_CODE LIKE @Lc_TypeWelfareIVAPurchaseOfCare_CODE + @Lc_Percenatage_TEXT
             THEN @Lc_TypeWelfareNonTanf_CODE
           END AS Program_CODE
      FROM LIVAR_Y1 l,
           CASE_Y1 c,
           CMEM_Y1 cp,
           CMEM_Y1 child,
           MHIS_Y1 m
     WHERE l.Process_CODE = @Lc_ProcessN_CODE
       AND l.NcpMci_IDNO = 0
       AND c.Case_IDNO = cp.Case_IDNO
       AND cp.Case_IDNO = child.Case_IDNO
       AND c.StatusCase_CODE = @Lc_StatusCaseOpen_CODE
       AND cp.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
       AND child.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
       AND cp.CaseRelationship_CODE = @Lc_CaseRelationshipCp_CODE
       AND child.CaseRelationship_CODE = @Lc_CaseRelationshipChild_CODE
       AND l.CpMci_IDNO = cp.MemberMci_IDNO
       AND l.ChildMci_IDNO = child.MemberMci_IDNO
       AND c.TypeCase_CODE NOT IN (@Lc_TypeCaseF_CODE, @Lc_TypeCaseH_CODE)
       AND c.RespondInit_CODE NOT IN (@Lc_RespondInitY_CODE, @Lc_RespondInitR_CODE, @Lc_RespondInitS_CODE)
       AND m.TypeWelfare_CODE IN (@Lc_TypeWelfareTANF_CODE, @Lc_TypeWelfareMedicaid_CODE, @Lc_TypeWelfareNonTanf_CODE)
       AND m.CaseWelfare_IDNO = l.CaseWelfare_IDNO
       AND m.Case_IDNO = c.Case_IDNO
       AND m.MemberMci_IDNO = child.MemberMci_IDNO
       AND m.End_DATE = @Ld_High_DATE
       AND ((l.Program_CODE LIKE @Lc_TypeWelfareTANF_CODE + @Lc_Percenatage_TEXT
             AND m.TypeWelfare_CODE IN (@Lc_TypeWelfareMedicaid_CODE, @Lc_TypeWelfareNonTanf_CODE))
             OR (l.Program_CODE LIKE @Lc_TypeWelfareMedicaid_CODE + @Lc_Percenatage_TEXT
                 AND m.TypeWelfare_CODE IN (@Lc_TypeWelfareNonTanf_CODE)))
     ORDER BY CASE
               WHEN l.Program_CODE LIKE @Lc_TypeWelfareTANF_CODE + @Lc_Percenatage_TEXT
                THEN @Lc_TypeWelfareTANF_CODE
               WHEN l.Program_CODE LIKE @Lc_TypeWelfareMedicaid_CODE + @Lc_Percenatage_TEXT
                THEN @Lc_TypeWelfareMedicaid_CODE
               WHEN l.Program_CODE LIKE @Lc_TypeWelfareIVAPurchaseOfCare_CODE + @Lc_Percenatage_TEXT
                THEN @Lc_TypeWelfareNonTanf_CODE
              END;

   SET @Ls_Sql_TEXT = 'OPEN ChildCp_CUR';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Ac_Job_ID, '');

   OPEN ChildCp_CUR;

   SET @Ls_Sql_TEXT = 'FETCH ChildCp_CUR - 1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Ac_Job_ID, '');

   FETCH NEXT FROM ChildCp_CUR INTO @Ln_ChildCpCurCase_IDNO, @Ln_ChildCpCurCaseWelfare_IDNO, @Ln_ChildCpCurCpMci_IDNO, @Ln_ChildCpCurChildMci_IDNO, @Lc_ChildCpCurChildProgamType_CODE;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;

   --Update Child's Program Type
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT - 1';
     SET @Ls_Sqldata_TEXT = 'Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', Process_ID = ' + ISNULL(@Ac_Job_ID, '') + ', EffectiveEvent_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', Note_INDC = ' + ISNULL(@Lc_Note_INDC, '') + ', EventFunctionalSeq_NUMB = ' + ISNULL('0', '');

     EXECUTE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
      @Ac_Worker_ID                = @Lc_BatchRunUser_TEXT,
      @Ac_Process_ID               = @Ac_Job_ID,
      @Ad_EffectiveEvent_DATE      = @Ad_Run_DATE,
      @Ac_Note_INDC                = @Lc_Note_INDC,
      @An_EventFunctionalSeq_NUMB  = 0,
      @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END

     --Childs MHIS
     SET @Ls_Sql_TEXT = 'EXECUTE BATCH_FIN_IVA_UPDATES$SP_UPDATE_MHIS';
     SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Start_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Ac_Job_ID, '') + ', Case_IDNO = ' + ISNULL(CAST(@Ln_ChildCpCurCase_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_ChildCpCurChildMci_IDNO AS VARCHAR), '') + ', CaseWelfare_IDNO = ' + ISNULL(CAST(@Ln_ChildCpCurCaseWelfare_IDNO AS VARCHAR), '') + ', TypeWelfare_CODE = ' + ISNULL(@Lc_ChildCpCurChildProgamType_CODE, '');

     EXECUTE BATCH_FIN_IVA_UPDATES$SP_UPDATE_MHIS
      @Ad_Run_DATE              = @Ld_Run_DATE,
      @Ad_Start_DATE            = @Ld_Run_DATE,
      @Ac_Job_ID                = @Ac_Job_ID,
      @An_Case_IDNO             = @Ln_ChildCpCurCase_IDNO,
      @An_MemberMci_IDNO        = @Ln_ChildCpCurChildMci_IDNO,
      @An_CaseWelfare_IDNO      = @Ln_ChildCpCurCaseWelfare_IDNO,
      @Ac_TypeWelfare_CODE      = @Lc_ChildCpCurChildProgamType_CODE,
      @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       EXECUTE BATCH_COMMON$SP_BATE_LOG
        @As_Process_NAME             = @Ls_Process_NAME,
        @As_Procedure_NAME           = @Ls_Procedure_NAME,
        @Ac_Job_ID                   = @Ac_Job_ID,
        @Ad_Run_DATE                 = @Ld_Run_DATE,
        @Ac_TypeError_CODE           = 'E',
        @An_Line_NUMB                = 0,
        @Ac_Error_CODE               = @Lc_Msg_CODE,
        @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
        @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
        @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         RAISERROR (50001,16,1);
        END
      END

     --CP MHIS UPDATE CALL
     SET @Lc_CpProgamType_CODE = ISNULL((SELECT a.TypeWelfare_CODE
                                           FROM (SELECT DISTINCT TOP 1
                                                        TypeWelfare_CODE AS TypeWelfare_CODE
                                                   FROM MHIS_Y1
                                                  WHERE Case_IDNO = @Ln_ChildCpCurCase_IDNO
                                                    AND MemberMci_IDNO IN (SELECT DISTINCT
                                                                                  MemberMci_IDNO
                                                                             FROM CMEM_Y1
                                                                            WHERE Case_IDNO = @Ln_ChildCpCurCase_IDNO
                                                                              AND CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
                                                                              AND CaseRelationship_CODE = @Lc_CaseRelationshipChild_CODE)
                                                    AND End_DATE = @Ld_High_DATE
                                                    AND TypeWelfare_CODE IN (@Lc_TypeWelfareTANF_CODE, @Lc_TypeWelfareMedicaid_CODE, @Lc_TypeWelfareNonTanf_CODE)
                                                  ORDER BY TypeWelfare_CODE)a,
                                                (SELECT DISTINCT
                                                        TypeWelfare_CODE AS TypeWelfare_CODE
                                                   FROM MHIS_Y1
                                                  WHERE Case_IDNO = @Ln_ChildCpCurCase_IDNO
                                                    AND MemberMci_IDNO = @Ln_ChildCpCurCpMci_IDNO
                                                    AND End_DATE = @Ld_High_DATE)b
                                          WHERE (b.TypeWelfare_CODE = @Lc_TypeWelfareNonTanf_CODE
                                             AND a.TypeWelfare_CODE IN (@Lc_TypeWelfareTANF_CODE, @Lc_TypeWelfareMedicaid_CODE))
                                             OR (b.TypeWelfare_CODE = @Lc_TypeWelfareMedicaid_CODE
                                                 AND a.TypeWelfare_CODE IN (@Lc_TypeWelfareTANF_CODE))), @Lc_Space_TEXT);

     IF @Lc_CpProgamType_CODE != @Lc_Space_TEXT
        AND NOT EXISTS (SELECT 1
                          FROM LIVAR_Y1 r
                         WHERE r.Process_CODE = @Lc_ProcessN_CODE
                           AND r.CpMci_IDNO = @Ln_ChildCpCurCpMci_IDNO
                           AND r.Seq_IDNO NOT IN (SELECT Seq_IDNO
                                                    FROM @TempSeqIdno_P1))
      BEGIN
       SET @Ls_Sql_TEXT = 'EXECUTE BATCH_FIN_IVA_UPDATES$SP_UPDATE_MHIS FOR CP';
       SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Start_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Ac_Job_ID, '') + ', Case_IDNO = ' + ISNULL(CAST(@Ln_ChildCpCurCase_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_ChildCpCurCpMci_IDNO AS VARCHAR), '') + ', CaseWelfare_IDNO = ' + ISNULL(CAST(@Ln_ChildCpCurCaseWelfare_IDNO AS VARCHAR), '') + ', TypeWelfare_CODE = ' + ISNULL(@Lc_CpProgamType_CODE, '');

       EXECUTE BATCH_FIN_IVA_UPDATES$SP_UPDATE_MHIS
        @Ad_Run_DATE              = @Ld_Run_DATE,
        @Ad_Start_DATE            = @Ld_Run_DATE,
        @Ac_Job_ID                = @Ac_Job_ID,
        @An_Case_IDNO             = @Ln_ChildCpCurCase_IDNO,
        @An_MemberMci_IDNO        = @Ln_ChildCpCurCpMci_IDNO,
        @An_CaseWelfare_IDNO      = @Ln_ChildCpCurCaseWelfare_IDNO,
        @Ac_TypeWelfare_CODE      = @Lc_CpProgamType_CODE,
        @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         EXECUTE BATCH_COMMON$SP_BATE_LOG
          @As_Process_NAME             = @Ls_Process_NAME,
          @As_Procedure_NAME           = @Ls_Procedure_NAME,
          @Ac_Job_ID                   = @Ac_Job_ID,
          @Ad_Run_DATE                 = @Ld_Run_DATE,
          @Ac_TypeError_CODE           = 'E',
          @An_Line_NUMB                = 0,
          @Ac_Error_CODE               = @Lc_Msg_CODE,
          @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
          @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
          @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
          @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

         IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
          BEGIN
           RAISERROR (50001,16,1);
          END
        END
      END

     -------NEXT CASE ID FETCH			
     FETCH NEXT FROM ChildCp_CUR INTO @Ln_ChildCpCurCase_IDNO, @Ln_ChildCpCurCaseWelfare_IDNO, @Ln_ChildCpCurCpMci_IDNO, @Ln_ChildCpCurChildMci_IDNO, @Lc_ChildCpCurChildProgamType_CODE;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END

   CLOSE ChildCp_CUR;

   DEALLOCATE ChildCp_CUR;

   SET @Ls_Sql_TEXT = 'UPDATE LIVAR_Y1 - 1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Ac_Job_ID, '');

   UPDATE LIVAR_Y1
      SET Process_CODE = 'Y'
    WHERE Process_CODE = 'N'
      AND Seq_IDNO IN (SELECT Seq_IDNO
                         FROM @TempSeqIdno_P1);

   SET @Ls_Sql_TEXT = 'UPDATE LIVAR_Y1 - 2';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Ac_Job_ID, '');

   UPDATE LIVAR_Y1
      SET Process_CODE = 'S'
    WHERE Process_CODE = 'N'
      AND NcpMci_IDNO = 0;

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = @Lc_Space_TEXT;
  END TRY

  BEGIN CATCH
   --CLOSE & DEALLOCATE CURSORS
   IF CURSOR_STATUS ('LOCAL', 'ChildCp_CUR') IN (0, 1)
    BEGIN
     CLOSE ChildCp_CUR;

     DEALLOCATE ChildCp_CUR;
    END

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

   SET @Ac_Msg_CODE = ISNULL(@Lc_Msg_CODE, @Lc_StatusFailed_CODE);
   SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
  END CATCH
 END


GO
