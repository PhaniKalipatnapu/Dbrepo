/****** Object:  StoredProcedure [dbo].[BATCH_COMMON_MHIS$SP_UPDATE_CASE_CATEGORY]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
 --------------------------------------------------------------------------------------------------------------------
 Procedure Name   : BATCH_COMMON_MHIS$SP_UPDATE_CASE_CATEGORY
 Programmer Name  : IMP Team
 Description      :
 Frequency        :
 Developed On     :	04/12/2011
 Called By        :
 Called On        :
 --------------------------------------------------------------------------------------------------------------------
 Modified By      :
 Modified On      :
 Version No       : 1.0
 --------------------------------------------------------------------------------------------------------------------
 */
CREATE PROCEDURE [dbo].[BATCH_COMMON_MHIS$SP_UPDATE_CASE_CATEGORY] (
 @An_Case_IDNO             NUMERIC (6),
 @An_MemberMci_IDNO        NUMERIC (10),
 @As_WorkerSignedOn_IDNO   CHAR (30),
 @Ad_Run_DATE              DATE,
 @Ac_Job_ID                CHAR(7) = 'MHISUCC',
 @Ac_Msg_CODE              CHAR (1) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR (4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  /*
  Mhis Program Type	Case Case Type	Case Category	
  ===============================================
   H	       H	    DP (Direct pay)	Sord Direct pay exists
   H	       H	     CO (Collection only )	No Sord Direct pay exists
   A,F,J,N	   A,F,J,N	FS (Full Service)	
   M	       N    	MO (Medical Only)	
  */
  DECLARE @Li_CaseCategoryIsChanged5050_NUMB INT = 5050,
          @Lc_WelfareTypeTanf_CODE           CHAR (1) = 'A',
          @Lc_WelfareTypeMedicaid_CODE       CHAR (1) = 'M',
          @Lc_WelfareTypeNonTanf_CODE        CHAR (1) = 'N',
          @Lc_WelfareTypeNonIve_CODE         CHAR (1) = 'F',
          @Lc_WelfareTypeFosterCare_CODE     CHAR (1) = 'J',
          @Lc_WelfareTypeNonIvd_CODE         CHAR (1) = 'H',
          @Lc_RelationshipCaseDp_CODE        CHAR(1) = 'D',
          @Lc_StatusCaseMemberActive_CODE    CHAR(1) = 'A',
          @Lc_Yes_INDC                       CHAR (1) = 'Y',
          @Lc_No_INDC                        CHAR (1) = 'N',
          @Lc_StatusFailed_CODE              CHAR (1) = 'F',
          @Lc_StatusSuccess_CODE             CHAR (1) = 'S',
          @Lc_PastMhis_CODE                  CHAR (1) = 'P',
          @Lc_CurrentMhis_CODE               CHAR (1) = 'C',
          @Lc_IiwoP1_CODE                    CHAR (1) = 'P',
          @Lc_IiwoI1_CODE                    CHAR (1) = 'I',
          @Lc_IiwoC1_CODE                    CHAR (1) = 'C',
          @Lc_ObleExists_INDC                CHAR (1) = 'N',
          @Lc_ValidObleExists_INDC           CHAR (1) = 'N',
          @Lc_CaseCategoryCn_CODE            CHAR (2) = 'CN',
          @Lc_CaseCategoryCa_CODE            CHAR (2) = 'CA',
          @Lc_CaseCategoryMn_CODE            CHAR (2) = 'MN',
          @Lc_CaseCategoryMa_CODE            CHAR (2) = 'MA',
          @Lc_CaseCategoryPn_CODE            CHAR (2) = 'PN',
          @Lc_CaseCategoryPa_CODE            CHAR (2) = 'PA',
          @Lc_CaseCategoryFn_CODE            CHAR (2) = 'FN',
          @Lc_CaseCategoryFa_CODE            CHAR (2) = 'FA',
          @Lc_CaseCategoryXn_CODE            CHAR (2) = 'XN',
          @Lc_CaseCategoryXa_CODE            CHAR (2) = 'XN',
          @Lc_CaseCategoryAn_CODE            CHAR (2) = 'AN',
          @Lc_CaseCategoryAa_CODE            CHAR (2) = 'AA',
          @Lc_CaseCategoryDn_CODE            CHAR (2) = 'DN',
          @Lc_CaseCategoryDa_CODE            CHAR (2) = 'DA',
          @Lc_CaseCategoryWn_CODE            CHAR (2) = 'WN',
          @Lc_CaseCategoryWa_CODE            CHAR (2) = 'WA',
          @Lc_CaseCategoryMr_CODE            CHAR (2) = 'MR',
          @Lc_CaseCategoryNn_CODE            CHAR (2) = 'NN',
          @Lc_CaseCategoryNa_CODE            CHAR (2) = 'NA',
          @Lc_DebtTypeAlimony_CODE           CHAR (2) = 'AL',
          @Lc_SubsystemCI_CODE               CHAR (2) = 'CI',
          @Lc_SourceRfrlFamis_CODE           CHAR (3) = 'F',
          @Lc_TableMhis_IDNO                 CHAR (4) = 'MHIS',
          @Lc_TableSubPgty_IDNO              CHAR (4) = 'PGTY',
          @Lc_TableCcrt_IDNO                 CHAR (4) = 'CCRT',
          @Lc_TableSubCctg_IDNO              CHAR (4) = 'CCTG',
          @Lc_MajorActivityCase_CODE         CHAR (4) = 'CASE',
          @Lc_ActivityMinorCcrct_CODE        CHAR (5) = 'CCRCT',
          @Lc_ActivityMinorCcrce_CODE        CHAR (5) = 'CCRCE',
          @Lc_Process_ID                     CHAR (7) = '',
          @Lc_WorkerSignedOn_IDNO            CHAR (30) = @As_WorkerSignedOn_IDNO,
          @Ls_Procedure_NAME                 VARCHAR (100) = 'SPKG_MHIS$SP_UPDATE_CASE_CATEGORY',
          @Ld_High_DATE                      DATE = '12/31/9999';
  DECLARE @Ln_Zero_NUMB                NUMERIC = 0,
          @Ln_RowsCount_NUMB           NUMERIC,
          @Ln_SordDirectPay_NUMB       NUMERIC (2),
          @Ln_IncomeWithHolding_QNTY   NUMERIC (2),
          @Ln_PastTanfChild_QNTY       NUMERIC (2),
          @Ln_Topic_IDNO               NUMERIC (10),
          @Ln_Error_NUMB               NUMERIC (11, 0),
          @Ln_ErrorLine_NUMB           NUMERIC (11, 0),
          @Ln_TransactionEventSeq_NUMB NUMERIC (19),
          @Lc_TypeCase_CODE            CHAR (1),
          @Lc_OldTypeCase_CODE         CHAR (1),
          @Lc_Msg_CODE                 CHAR (1) = '',
          @Lc_CaseCategory_CODE        CHAR (2),
          @Lc_OldCaseCategory_CODE     CHAR (2),
          @Lc_CaseWorker_ID            CHAR (30),
          @Ls_Sql_TEXT                 VARCHAR (400),
          @Ls_Sqldata_TEXT             VARCHAR (1000),
          @Ls_Errormessage_TEXT        VARCHAR (4000),
          @Ls_DescriptionNote_TEXT     VARCHAR (4000),
          @Ls_DescriptionError_TEXT    VARCHAR (4000);

  BEGIN TRY
   SET @Ac_Msg_CODE = NULL;
   SET @As_DescriptionError_TEXT = NULL;
   SET @Lc_Process_ID = @Ac_Job_ID;
   SET @Ls_Sqldata_TEXT = ' CASE ID = ' + ISNULL (CAST (@An_Case_IDNO AS VARCHAR (6)), '') + ', MEMBER ID = ' + ISNULL (CAST (@An_MemberMci_IDNO AS VARCHAR (10)), '');
   SET @Ls_Sql_TEXT = ' SELECT CASE_Y1 ';

   SELECT @Lc_OldTypeCase_CODE = C.TypeCase_CODE,
          @Lc_OldCaseCategory_CODE = C.CaseCategory_CODE,
          @Lc_CaseWorker_ID = C.Worker_ID
     FROM CASE_Y1 C
    WHERE C.Case_IDNO = @An_Case_IDNO;

   WITH RefTab_CTE
        AS (SELECT 'A' TypeWelfare_CODE,
                   'A' TypeCase_CODE,
                   'FS' CaseCategory_CODE
            UNION
            SELECT 'F' TypeWelfare_CODE,
                   'F' TypeCase_CODE,
                   'FS' CaseCategory_CODE
            UNION
            SELECT 'H' TypeWelfare_CODE,
                   'H' TypeCase_CODE,
                   CASE
                    WHEN EXISTS (SELECT 1
                                   FROM SORD_Y1 S
                                  WHERE S.Case_IDNO = @An_Case_IDNO)
                     THEN
                     CASE
                      WHEN EXISTS(SELECT 1
                                    FROM SORD_Y1 S
                                   WHERE S.Case_IDNO = @An_Case_IDNO
                                     AND S.DirectPay_INDC = @Lc_Yes_INDC
                                     AND S.EndValidity_DATE = @Ld_High_DATE)
                       THEN 'DP'
                      ELSE 'CO'
                     END
                    ELSE 'CO'
                   END CaseCategory_CODE
            UNION
            SELECT 'J' TypeWelfare_CODE,
                   'J' TypeCase_CODE,
                   'FS' CaseCategory_CODE
            UNION
            SELECT 'M' TypeWelfare_CODE,
                   'N' TypeCase_CODE,
                   'MO' CaseCategory_CODE
            UNION
            SELECT 'N' TypeWelfare_CODE,
                   'N' TypeCase_CODE,
                   'FS' CaseCategory_CODE)
   SELECT @Lc_TypeCase_CODE = B.TypeCase_CODE,
          @Lc_CaseCategory_CODE = B.CaseCategory_CODE
     FROM (SELECT TypeWelfare_CODE,
                  ROW_NUMBER() OVER(ORDER BY (CASE WHEN MH.TypeWelfare_CODE='A' THEN 1 WHEN MH.TypeWelfare_CODE='F' THEN 2 WHEN MH.TypeWelfare_CODE='H' THEN 3 WHEN MH.TypeWelfare_CODE='J' THEN 4 WHEN MH.TypeWelfare_CODE='M' THEN 5 WHEN MH.TypeWelfare_CODE='N' THEN 6 END ) ) TypeWelfareRank_NUMB
             FROM MHIS_Y1 MH
                  JOIN CMEM_Y1 CM
                   ON MH.Case_IDNO = CM.Case_IDNO
                      AND MH.MemberMci_IDNO = CM.MemberMci_IDNO
            WHERE MH.Case_IDNO = @An_Case_IDNO
              AND CM.CaseRelationship_CODE = @Lc_RelationshipCaseDp_CODE
              AND CM.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE
              AND MH.End_DATE = @Ld_High_DATE) A,
          RefTab_CTE B
    WHERE TypeWelfareRank_NUMB = 1
      AND A.TypeWelfare_CODE = B.TypeWelfare_CODE;

   --If the old case category is purchase of care(PO) and casetype is N , then the new case category will be PO  
   IF (@Lc_OldCaseCategory_CODE = 'PO'
       AND @Lc_TypeCase_CODE = 'N')
    BEGIN
     SET @Lc_CaseCategory_CODE = @Lc_OldCaseCategory_CODE;
    END

   --  if case type modidied or case category mofified BEGIN
   IF (@Lc_OldTypeCase_CODE <> @Lc_TypeCase_CODE
        OR @Lc_CaseCategory_CODE <> @Lc_OldCaseCategory_CODE)
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT';

     EXEC BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
      @Ac_Worker_ID                = @As_WorkerSignedOn_IDNO,
      @Ac_Process_ID               = @Lc_Process_ID,
      @Ad_EffectiveEvent_DATE      = @Ad_Run_DATE,
      @Ac_Note_INDC                = @Lc_No_INDC,
      @An_EventFunctionalSeq_NUMB  = @Li_CaseCategoryIsChanged5050_NUMB,
      @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

     IF (@Lc_Msg_CODE = @Lc_StatusFailed_CODE)
      BEGIN
       RAISERROR (50001,16,1);
      END

     SET @Ls_Sql_TEXT = 'UPDATE CASE_Y1';
     SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '');

     UPDATE CASE_Y1
        SET TypeCase_CODE = @Lc_TypeCase_CODE,
            CaseCategory_CODE = @Lc_CaseCategory_CODE,
            WorkerUpdate_ID = @As_WorkerSignedOn_IDNO,
            TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
            BeginValidity_DATE = @Ad_Run_DATE,
            Update_DTTM = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME()
     OUTPUT Deleted.Case_IDNO,
            Deleted.StatusCase_CODE,
            Deleted.TypeCase_CODE,
            Deleted.RsnStatusCase_CODE,
            Deleted.RespondInit_CODE,
            Deleted.SourceRfrl_CODE,
            Deleted.Opened_DATE,
            Deleted.Marriage_DATE,
            Deleted.Divorced_DATE,
            Deleted.StatusCurrent_DATE,
            Deleted.AprvIvd_DATE,
            Deleted.County_IDNO,
            Deleted.Office_IDNO,
            Deleted.AssignedFips_CODE,
            Deleted.GoodCause_CODE,
            Deleted.GoodCause_DATE,
            Deleted.Restricted_INDC,
            Deleted.MedicalOnly_INDC,
            Deleted.Jurisdiction_INDC,
            Deleted.IvdApplicant_CODE,
            Deleted.Application_IDNO,
            Deleted.AppSent_DATE,
            Deleted.AppReq_DATE,
            Deleted.AppRetd_DATE,
            Deleted.CpRelationshipToNcp_CODE,
            Deleted.Worker_ID,
            Deleted.AppSigned_DATE,
            Deleted.ClientLitigantRole_CODE,
            Deleted.DescriptionComments_TEXT,
            Deleted.NonCoop_CODE,
            Deleted.NonCoop_DATE,
            Deleted.BeginValidity_DATE,
            @Ad_Run_DATE AS EndValidity_DATE,
            Deleted.WorkerUpdate_ID,
            Deleted.TransactionEventSeq_NUMB,
            Deleted.Update_DTTM,
            Deleted.Referral_DATE,
            Deleted.CaseCategory_CODE,
            Deleted.File_ID,
            Deleted.ApplicationFee_CODE,
            Deleted.FeePaid_DATE,
            Deleted.ServiceRequested_CODE,
            Deleted.StatusEnforce_CODE,
            Deleted.FeeCheckNo_TEXT,
            Deleted.ReasonFeeWaived_CODE,
            Deleted.Intercept_CODE
     INTO HCASE_Y1
      WHERE CASE_Y1.Case_IDNO = @An_Case_IDNO;

     SET @Ln_RowsCount_NUMB = @@ROWCOUNT;

     IF @Ln_RowsCount_NUMB = @Ln_Zero_NUMB
      BEGIN
       SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

       RAISERROR (50001,16,1);
      END

     --For case type change
     IF @Lc_TypeCase_CODE != @Lc_OldTypeCase_CODE
      BEGIN
       --13736 - Assigning description note text to variable -START-
       SET @Ls_DescriptionNote_TEXT = 'CASE TYPE HAS BEEN CHANGED FROM ' + @Lc_OldTypeCase_CODE + ' - ' + ISNULL (dbo.BATCH_COMMON_GETS$SF_GET_REFMDESC (@Lc_TableMhis_IDNO, @Lc_TableSubPgty_IDNO, @Lc_OldTypeCase_CODE), '') + ' TO ' + @Lc_TypeCase_CODE + ' - ' + ISNULL (dbo.BATCH_COMMON_GETS$SF_GET_REFMDESC (@Lc_TableMhis_IDNO, @Lc_TableSubPgty_IDNO, @Lc_TypeCase_CODE), '');
       --13736 - Assigning description note text to variable -END-
       SET @Ls_Sql_TEXT = 'INSERTING ACTIVITY - FOR CCRCT - FOR CASE TYPE CHANGE';
       SET @Ls_Sqldata_TEXT = 'CASE ID = ' + ISNULL (CAST (@An_Case_IDNO AS VARCHAR (6)), '');

       EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
        @An_Case_IDNO                = @An_Case_IDNO,
        @An_MemberMci_IDNO           = @An_MemberMci_IDNO,
        @Ac_ActivityMajor_CODE       = @Lc_MajorActivityCase_CODE,
        @Ac_ActivityMinor_CODE       = @Lc_ActivityMinorCcrct_CODE,
        @Ac_Subsystem_CODE           = @Lc_SubsystemCI_CODE,
        @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
        @Ac_WorkerUpdate_ID          = @Lc_WorkerSignedOn_IDNO,
        @Ac_WorkerDelegate_ID        = @Lc_CaseWorker_ID,
        @Ac_Job_ID                   = @Lc_Process_ID,
        @An_Topic_IDNO               = @Ln_Topic_IDNO OUTPUT,
        @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         SET @Ls_Sql_TEXT = 'INSERTING DMNR_Y1 TABLE - FOR CCRCT - FAILED';

         RAISERROR (50001,16,1);
        END
 
       EXECUTE BATCH_COMMON_NOTE$SP_CREATE_NOTE
        @Ac_Process_ID               = @Lc_Process_ID,
        @Ac_Case_IDNO                = @An_Case_IDNO,
        @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
        @An_Topic_IDNO               = @Ln_Topic_IDNO,
        @As_DescriptionNote_TEXT     = @Ls_DescriptionNote_TEXT,
        @Ac_Category_CODE            = @Lc_SubsystemCI_CODE,
        @Ac_Subject_CODE             = @Lc_ActivityMinorCcrct_CODE,
        @As_WorkerSignedOn_IDNO      = @Lc_WorkerSignedOn_IDNO,
        @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;
 
       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         SET @Ls_Sql_TEXT = 'INSERT_VNOTE FAILED--1';

         RAISERROR (50001,16,1);
        END
      END

     -- For Case Category change BEGIN
     IF @Lc_CaseCategory_CODE <> @Lc_OldCaseCategory_CODE
      BEGIN
       --13736 - Assigning description note text to variable -START-
       SET @Ls_DescriptionNote_TEXT = 'CASE CATEGORY HAS BEEN CHANGED FROM ' + @Lc_OldCaseCategory_CODE + ' - ' + ISNULL (dbo.BATCH_COMMON_GETS$SF_GET_REFMDESC (@Lc_TableCcrt_IDNO, @Lc_TableSubCctg_IDNO, @Lc_OldCaseCategory_CODE), '') + ' TO ' + @Lc_CaseCategory_CODE + ' - ' +  + ISNULL (dbo.BATCH_COMMON_GETS$SF_GET_REFMDESC (@Lc_TableCcrt_IDNO, @Lc_TableSubCctg_IDNO, @Lc_CaseCategory_CODE), '');
       --13736 - Assigning description note text to variable -END-
       SET @Ls_Sql_TEXT = 'INSERTING ACTIVITY - FOR CCRCC - FOR CASE CATEGORY CHANGE';
       SET @Ls_Sqldata_TEXT = 'CASE Seq_IDNO = ' + ISNULL (CAST (@An_Case_IDNO AS VARCHAR), '');

       EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
        @An_Case_IDNO                = @An_Case_IDNO,
        @An_MemberMci_IDNO           = @An_MemberMci_IDNO,
        @Ac_ActivityMajor_CODE       = @Lc_MajorActivityCase_CODE,
        @Ac_ActivityMinor_CODE       = @Lc_ActivityMinorCcrce_CODE,
        @Ac_Subsystem_CODE           = @Lc_SubsystemCI_CODE,
        @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
        @Ac_WorkerUpdate_ID          = @Lc_WorkerSignedOn_IDNO,
        @Ac_WorkerDelegate_ID        = @Lc_CaseWorker_ID,
        @Ac_Job_ID                   = @Lc_Process_ID,
        @An_Topic_IDNO               = @Ln_Topic_IDNO OUTPUT,
        @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

       IF (@Lc_Msg_CODE = @Lc_StatusFailed_CODE)
        BEGIN
         SET @Ls_Sql_TEXT = 'INSERTING DMNR_Y1 TABLE - FOR CCRCC - FAILED';

         RAISERROR (50001,16,1);
        END
 
       --   if case category changed, insert notes into NOTE Table
       EXECUTE BATCH_COMMON_NOTE$SP_CREATE_NOTE
        @Ac_Case_IDNO                = @An_Case_IDNO,
        @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
        @As_DescriptionNote_TEXT     = @Ls_DescriptionNote_TEXT,
        @An_Topic_IDNO               = @Ln_Topic_IDNO,
        @Ac_Category_CODE            = @Lc_SubsystemCI_CODE,
        @Ac_Subject_CODE             = @Lc_ActivityMinorCcrce_CODE,
        @As_WorkerSignedOn_IDNO      = @Lc_WorkerSignedOn_IDNO,
        @Ac_Process_ID               = @Lc_Process_ID,
        @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;
 
       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         SET @Ls_Sql_TEXT = 'INSERT_VNOTE FAILED --2';

         RAISERROR (50001,16,1);
        END
      END
    END

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = '';
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   SET @Ln_Error_NUMB = ERROR_NUMBER ();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE ();

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
  END CATCH
 END


GO
