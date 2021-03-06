/****** Object:  StoredProcedure [dbo].[BATCH_COMMON_PRORATE_GRANT$SP_GRANT_SPLIT_OBLE]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_COMMON_PRORATE_GRANT$SP_GRANT_SPLIT_OBLE
Programmer Name		: IMP Team
Description			: Procedure is to modify and insert the obligation details.
Frequency			: 
Developed On		: 04/12/2011
Called By			:
Called On			:
--------------------------------------------------------------------------------------------------------------------
Modified By			:
Modified On			:
Version No			: 1.0	
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_COMMON_PRORATE_GRANT$SP_GRANT_SPLIT_OBLE] (
 @An_Case_IDNO             NUMERIC(6),
 @An_MemberMci_IDNO        NUMERIC(10),
 @Ad_BeginObligation_DATE  DATE,
 @Ac_SignedOnWorker_ID     CHAR(30),
 @Ac_Screen_ID             CHAR(7) = '',
 @Ad_Run_DATE              DATE,
 @Ac_Msg_CODE              CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  CREATE TABLE #TPRCP_P1
   (
     Seq_IDNO           NUMERIC(19),
     MemberMci_IDNO     NUMERIC(10),
     Case_IDNO          NUMERIC(6),
     OrderSeq_NUMB      NUMERIC(2),
     ObligationSeq_NUMB NUMERIC(2),
     TypeBucket_CODE    CHAR(5),
     CaseWelfare_IDNO   NUMERIC(10),
     ArrPaid_AMNT       NUMERIC(11, 2),
     ArrRecoup_AMNT     NUMERIC(11, 2),
     Rounded_AMNT       NUMERIC(11, 2),
     RoundedRecoup_AMNT NUMERIC(11, 2),
     ArrToBePaid_AMNT   NUMERIC(11, 2),
     ArrPaidMtd_AMNT    NUMERIC(11, 2),
     ArrRecoupMtd_AMNT  NUMERIC(11, 2),
     ArrPaidUrg_AMNT    NUMERIC(11, 2),
     ArrPaidMtdUrg_AMNT NUMERIC(11, 2)
   );

  DECLARE @Ln_MtdAssistExpend_AMNT                                NUMERIC(11, 2) = 0,
          @Ln_LtdAssistExpend_AMNT                                NUMERIC(11, 2) = 0,
          @Ln_LtdAssistRecoup_AMNT                                NUMERIC(11, 2) = 0,
          @Ln_MtdAssistRecoup_AMNT                                NUMERIC(11, 2) = 0,
          @Ln_MtdExpend_AMNT                                      NUMERIC(11, 2) = 0,
          @Ln_Recoup_AMNT                                         NUMERIC(11, 2) = 0,
          @Ln_AdjustRecoup_AMNT                                   NUMERIC(11, 2) = 0,
          @Ln_IvmgAdjust_AMNT                                     NUMERIC(11, 2) = 0,
          @Ln_MtdRecoup_AMNT                                      NUMERIC(11, 2) = 0,
          @Ln_MtdPrevIvmg_AMNT                                    NUMERIC(11, 2) = 0,
          @Ln_MtdPrevRecoup_AMNT                                  NUMERIC(11, 2) = 0,
          @Ln_WhileCount_NUMB                                     NUMERIC(11, 2) = 0,
          @Ln_LtdUrg_AMNT                                         NUMERIC(11, 2) = 0,
          @Ln_MtdUrg_AMNT                                         NUMERIC(11, 2) = 0,
          @Li_TanfGrantSplitAfterParticipantStatusChange2750_NUMB INT = 2750,
          @Li_Zero_NUMB                                           SMALLINT = 0,
          @Li_One_NUMB                                            SMALLINT = 1,
          @Lc_Space_TEXT                                          CHAR(1) = '',
          @Lc_NO_INDC                                             CHAR(1) = 'N',
          @Lc_CaseRelationShipCP_CODE                             CHAR(1) = 'C',
          @Lc_CaseMemberStatusActive_CODE						  CHAR(1) = 'A',
          @Lc_Yes_INDC                                            CHAR(1) = 'Y',
          @Lc_SeqGenerate_INDC                                    CHAR(1) = 'N',
          @Lc_TypeWelfareTanf_CODE                                CHAR(1) = 'A',
          @Lc_StatusFailed_CODE                                   CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE                                  CHAR(1) = 'S',
          @Lc_TypeDebtChildSupp_CODE                              CHAR(2) = 'CS',
          @Lc_TypeDebtSpousalSupp_CODE                            CHAR(2) = 'SS',
          @Lc_TypeDebtIntChildSupp_CODE                           CHAR(2) = 'CI',
          @Lc_TypeDebtIntSpousalSupp_CODE                         CHAR(2) = 'SI',
		  @Lc_Grantmhis_CODE                                      CHAR(3) = 'GSO',
          @Lc_ScreenOble_CODE                                     CHAR(4) = 'OWIZ',
          @Lc_ScreenNipa_CODE                                     CHAR(4) = 'NIPA',
          @Lc_DateFormatYyyymm_CODE                               CHAR(6) = 'YYYYMM',
          @Lc_Process_ID										  CHAR(10) = '',
          @Ls_Procedure_NAME                                      VARCHAR(100) = 'SPKG_PRORATE_GRANT$SP_GRANT_SPLIT_OBLE',
          @Ld_High_DATE                                           DATE = '12/31/9999',
          @Ld_End_DATE                                            DATE = ISNULL(@Ad_Run_DATE, DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME()),
          @Ld_Run_DATE                                            DATE = ISNULL(@Ad_Run_DATE, DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME());
  DECLARE @Ln_GrantDataCur_Case_IDNO             NUMERIC(6, 0),
          @Ln_GrantDataCur_OrderSeq_NUMB         NUMERIC(2, 0),
          @Ln_GrantDataCur_ObligationSeq_NUMB    NUMERIC(2, 0),
          @Ln_WemoCur_Case_IDNO                  NUMERIC(6, 0),
          @Ln_WemoCur_OrderSeq_NUMB              NUMERIC(2, 0),
          @Ln_WemoCur_ObligationSeq_NUMB         NUMERIC(2, 0),
          @Ln_GrantDataCur_SupportYearMonth_NUMB NUMERIC(6, 0),
          @Ln_MhisCur_CaseWelfare_IDNO           NUMERIC(10, 0),
          @Ln_WemoCur_CaseWelfare_IDNO           NUMERIC(10, 0),
          @Ln_WemoCur_ArrPaid_AMNT               NUMERIC(11, 2),
          @Ln_WemoCur_ArrRecoup_AMNT             NUMERIC(11, 2),
          @Ln_WemoCur_ArrPaidMtd_AMNT            NUMERIC(11, 2),
          @Ln_WemoCur_ArrRecoupMtd_AMNT          NUMERIC(11, 2),
          @Ln_WemoCur_ArrPaidUrg_AMNT            NUMERIC(11, 2),
          @Ln_WemoCur_ArrPaidMtdUrg_AMNT         NUMERIC(11, 2);
  DECLARE @Ln_AdjustYearMonth_NUMB  NUMERIC(6, 0),
          @Ln_WelfareYearMonth_NUMB NUMERIC(6, 0),
          @Ln_RowCount_QNTY         NUMERIC(10, 0),
          @Ln_CaseWelfare_IDNO      NUMERIC(10, 0),
          @Ln_CpMCI_IDNO            NUMERIC(10, 0),
          @Ln_EventGlobalSeq_NUMB   NUMERIC(19, 0),
          @Li_FetchStatus_QNTY      INT,
          @Li_Error_NUMB            INT,
          @Li_ErrorLine_NUMB        INT,
          @Li_Exist_NUMB            SMALLINT,
          @Lc_Process_INDC          CHAR(1),
          @Lc_Exist_INDC            CHAR(1),
          @Lc_ChangeOvpy_INDC       CHAR(1),
          @Ls_Sql_TEXT              VARCHAR(400),
          @Ls_Sqldata_TEXT          VARCHAR(400),
          @Ls_ErrorMessage_TEXT     VARCHAR(2000),
          @Ls_DescriptionError_TEXT VARCHAR(4000),
          @Ld_Start_DATE            DATE,
          @Ld_MinStart_DATE         DATE;
  DECLARE @WelfDistOverride_P1 TABLE(
   --[TmpWelfDistOverride_P1] --#TIVAL_P1
   CaseWelfare_IDNO NUMERIC(10),
   ChangeOvpy_INDC  CHAR(1));
  DECLARE @GrantTab_P1 TABLE (
   Case_IDNO             NUMERIC(6, 0),
   OrderSeq_NUMB         NUMERIC(2),
   ObligationSeq_NUMB    NUMERIC(2),
   SupportYearMonth_NUMB NUMERIC(6));
  DECLARE MHIS_CUR INSENSITIVE CURSOR FOR
   SELECT DISTINCT a.CaseWelfare_IDNO
     FROM MHIS_Y1 a
    WHERE a.Case_IDNO = @An_Case_IDNO
      AND a.MemberMci_IDNO = @An_MemberMci_IDNO
      AND a.TypeWelfare_CODE = @Lc_TypeWelfareTanf_CODE;

  BEGIN TRY
   SET @Lc_SeqGenerate_INDC = 'N';
   
   SET @Ls_Sql_TEXT = 'GETTING CP MCI IDNO'
   SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + CAST(@An_Case_IDNO AS VARCHAR) ;

   SET @Ln_CpMci_IDNO = ISNULL((SELECT MemberMci_IDNO 
							FROM CMEM_Y1 a
						   WHERE a.Case_IDNO = @An_Case_IDNO
						     AND a.CaseRelationship_CODE = @Lc_CaseRelationShipCP_CODE
						     AND a.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE),0);     

   DELETE FROM @GrantTab_P1;

   OPEN MHIS_CUR;

   FETCH NEXT FROM MHIS_CUR INTO @Ln_MhisCur_CaseWelfare_IDNO;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;

   --This while loop is for retriving the MHIS_CUR
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
     MHIS_LOOP:;

     SET @Ln_CaseWelfare_IDNO = @Ln_MhisCur_CaseWelfare_IDNO;
     SET @Ls_Sql_TEXT = 'SELECT TIVAL_P1';
     SET @Ls_Sqldata_TEXT = 'CaseWelfare_IDNO = ' + ISNULL(CAST(@Ln_CaseWelfare_IDNO AS VARCHAR), @Lc_Space_TEXT);

     SELECT @Lc_ChangeOvpy_INDC = t.ChangeOvpy_INDC
       FROM @WelfDistOverride_P1 t
      WHERE t.CaseWelfare_IDNO = @Ln_CaseWelfare_IDNO;

     SET @Ln_RowCount_QNTY = @@ROWCOUNT;

     IF @Ln_RowCount_QNTY = 0
      BEGIN
       SET @Ls_Sql_TEXT = 'INSERT TIVAL_P1';
       SET @Ls_Sqldata_TEXT = ' CaseWelfare_IDNO = ' + ISNULL(CAST(@Ln_CaseWelfare_IDNO AS VARCHAR), @Lc_Space_TEXT) + ', ChangeOvpy_INDC = ' + ISNULL(@Lc_Yes_INDC, @Lc_Space_TEXT);

       INSERT @WelfDistOverride_P1
              (CaseWelfare_IDNO,
               ChangeOvpy_INDC)
       VALUES ( @Ln_CaseWelfare_IDNO,-- CaseWelfare_IDNO	
                @Lc_Yes_INDC -- ChangeOvpy_INDC
       );
      END

     IF @Lc_ChangeOvpy_INDC = @Lc_No_INDC
      BEGIN
       GOTO NEXT_MHIS_REC;
      END

     IF dbo.BATCH_COMMON_SCALAR$SF_TO_CHAR_DATE(@Ad_BeginObligation_DATE, @Lc_DateFormatYyyymm_CODE) = dbo.BATCH_COMMON_SCALAR$SF_TO_CHAR_DATE(@Ld_End_DATE, @Lc_DateFormatYyyymm_CODE)
      BEGIN
       SET @Ld_Start_DATE = @Ld_End_DATE;
      END
     ELSE
      BEGIN
       SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_LAST_DAY(@Ad_BeginObligation_DATE);
      END

     IF @Ac_Screen_ID = @Lc_ScreenOble_CODE
      BEGIN
       SET @Ls_Sql_TEXT = 'SELECT MHIS_Y1 1';
       SET @Ls_Sqldata_TEXT = ' CaseWelfare_IDNO = ' + ISNULL(CAST(@Ln_CaseWelfare_IDNO AS VARCHAR), @Lc_Space_TEXT) + ', Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), @Lc_Space_TEXT);

       SELECT @Ld_MinStart_DATE = MIN (a.Start_DATE)
         FROM MHIS_Y1 a
        WHERE a.CaseWelfare_IDNO = @Ln_CaseWelfare_IDNO
          AND a.Case_IDNO = @An_Case_IDNO
          AND a.TypeWelfare_CODE = @Lc_TypeWelfareTanf_CODE
          AND EXISTS (SELECT 1
                        FROM OBLE_Y1 b
                       WHERE b.Case_IDNO = a.Case_IDNO
                         AND b.TypeDebt_CODE IN (@Lc_TypeDebtChildSupp_CODE, @Lc_TypeDebtSpousalSupp_CODE, @Lc_TypeDebtIntChildSupp_CODE, @Lc_TypeDebtIntSpousalSupp_CODE)
                         AND b.MemberMci_IDNO = a.MemberMci_IDNO
                         AND b.EndValidity_DATE = @Ld_High_DATE);
      END
     ELSE
      BEGIN
       SET @Ls_Sql_TEXT = 'SELECT MHIS_Y1 2';
       SET @Ls_Sqldata_TEXT = ' CaseWelfare_IDNO = ' + ISNULL(CAST(@Ln_CaseWelfare_IDNO AS VARCHAR), @Lc_Space_TEXT) + ', Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), @Lc_Space_TEXT) + ', MemberMci_IDNO = ' + ISNULL(CAST(@An_MemberMci_IDNO AS VARCHAR), @Lc_Space_TEXT);

       SELECT @Ld_MinStart_DATE = MIN (a.Start_DATE)
         FROM MHIS_Y1 a
        WHERE a.CaseWelfare_IDNO = @Ln_CaseWelfare_IDNO
          AND a.Case_IDNO = @An_Case_IDNO
          AND a.MemberMci_IDNO = @An_MemberMci_IDNO
          AND a.TypeWelfare_CODE = @Lc_TypeWelfareTanf_CODE;
      END

     IF @Ld_MinStart_DATE > @Ld_Start_DATE
      BEGIN
       SET @Ld_Start_DATE = @Ld_MinStart_DATE;
      END

     --This is main while loop is for calculating IvmgAdjust_AMNT from IVMG_Y1 
     WHILE dbo.BATCH_COMMON_SCALAR$SF_TO_CHAR_DATE(@Ld_Start_DATE, @Lc_DateFormatYyyymm_CODE) <= dbo.BATCH_COMMON_SCALAR$SF_TO_CHAR_DATE(@Ld_End_DATE, @Lc_DateFormatYyyymm_CODE)
      BEGIN --2ND DATE WHILE
       MAIN_WHILE_LOOP:;

       SELECT @Ln_WhileCount_NUMB = @Ln_WhileCount_NUMB + 1,
              @Ln_AdjustYearMonth_NUMB = dbo.BATCH_COMMON_SCALAR$SF_TO_CHAR_DATE(@Ld_Start_DATE, @Lc_DateFormatYyyymm_CODE),
              @Ln_MtdPrevIvmg_AMNT = @Li_Zero_NUMB,
              @Ln_MtdPrevRecoup_AMNT = @Li_Zero_NUMB;

       SET @Ls_Sql_TEXT = 'SELECT_VIVMG 1';
       SET @Ls_Sqldata_TEXT = 'CaseWelfare_IDNO = ' + ISNULL(CAST(@Ln_CaseWelfare_IDNO AS VARCHAR), @Lc_Space_TEXT) + ', WelfareYearMonth_NUMB = ' + ISNULL(CAST(@Ln_AdjustYearMonth_NUMB AS VARCHAR), @Lc_Space_TEXT);

       -- Fetch the Amount to be adjusted with the Cases.
       SELECT @Ln_IvmgAdjust_AMNT = ISNULL (a.LtdAssistExpend_AMNT, @Li_Zero_NUMB) - ISNULL(a.MtdAssistExpend_AMNT, @Li_Zero_NUMB),
              @Ln_AdjustRecoup_AMNT = ISNULL (a.LtdAssistRecoup_AMNT, @Li_Zero_NUMB) - ISNULL(a.MtdAssistRecoup_AMNT, @Li_Zero_NUMB),
              @Ln_MtdExpend_AMNT = ISNULL (a.MtdAssistExpend_AMNT, @Li_Zero_NUMB),
              @Ln_MtdRecoup_AMNT = ISNULL (a.MtdAssistRecoup_AMNT, @Li_Zero_NUMB)
         FROM IVMG_Y1 a
        WHERE a.CaseWelfare_IDNO = @Ln_CaseWelfare_IDNO
          AND a.CpMcI_IDNO = @Ln_CpMCI_IDNO
          AND a.WelfareElig_CODE = @Lc_TypeWelfareTanf_CODE
          AND a.WelfareYearMonth_NUMB = @Ln_AdjustYearMonth_NUMB
          AND a.EventGlobalSeq_NUMB = (SELECT MAX (c.EventGlobalSeq_NUMB)
                                         FROM IVMG_Y1 c
                                        WHERE c.CaseWelfare_IDNO = a.CaseWelfare_IDNO
                                          AND c.CpMcI_IDNO = @Ln_CpMCI_IDNO
                                          AND c.WelfareElig_CODE = @Lc_TypeWelfareTanf_CODE
                                          AND c.WelfareYearMonth_NUMB = a.WelfareYearMonth_NUMB);

       SET @Ln_RowCount_QNTY = @@ROWCOUNT;

       -- Insert records in WEMO, only if the Records exists in VIVMG for the given month_adjust.	  
       SELECT @Li_Exist_NUMB = @Li_One_NUMB,
              @Ln_LtdUrg_AMNT = @Ln_IvmgAdjust_AMNT - @Ln_AdjustRecoup_AMNT,
              @Ln_MtdUrg_AMNT = @Ln_MtdExpend_AMNT - @Ln_MtdRecoup_AMNT,
              @Ln_IvmgAdjust_AMNT = @Ln_AdjustRecoup_AMNT,
              @Ln_MtdExpend_AMNT = @Ln_MtdRecoup_AMNT;

       IF (@Ln_RowCount_QNTY = 0)
        BEGIN
         SELECT @Ln_IvmgAdjust_AMNT = @Li_Zero_NUMB,
                @Ln_AdjustRecoup_AMNT = @Li_Zero_NUMB,
                @Ln_MtdExpend_AMNT = @Li_Zero_NUMB,
                @Ln_MtdRecoup_AMNT = @Li_Zero_NUMB,
                @Li_Exist_NUMB = @Li_Zero_NUMB,
                @Ln_MtdUrg_AMNT = @Li_Zero_NUMB,
                @Ln_LtdUrg_AMNT = @Li_Zero_NUMB;

         SET @Ls_Sql_TEXT = 'SELECT_VIVMG 2';
         SET @Ls_Sqldata_TEXT = 'CaseWelfare_IDNO = ' + ISNULL(CAST(@Ln_CaseWelfare_IDNO AS VARCHAR), @Lc_Space_TEXT) + ', WelfareElig_CODE = ' + @Lc_TypeWelfareTanf_CODE;

         SELECT @Ln_IvmgAdjust_AMNT = ISNULL (a.LtdAssistExpend_AMNT, @Li_Zero_NUMB),
                @Ln_AdjustRecoup_AMNT = ISNULL (a.LtdAssistRecoup_AMNT, @Li_Zero_NUMB)
           FROM IVMG_Y1 a
          WHERE a.CaseWelfare_IDNO = @Ln_CaseWelfare_IDNO
            AND a.CpMcI_IDNO = @Ln_CpMCI_IDNO
            AND a.WelfareElig_CODE = @Lc_TypeWelfareTanf_CODE
            AND a.WelfareYearMonth_NUMB = (SELECT MAX (b.WelfareYearMonth_NUMB)
                                             FROM IVMG_Y1 b
                                            WHERE b.CaseWelfare_IDNO = @Ln_CaseWelfare_IDNO
                                              AND b.CpMcI_IDNO = @Ln_CpMCI_IDNO
                                              AND b.WelfareElig_CODE = @Lc_TypeWelfareTanf_CODE
                                              AND b.WelfareYearMonth_NUMB <= @Ln_AdjustYearMonth_NUMB)
            AND a.EventGlobalSeq_NUMB = (SELECT MAX (c.EventGlobalSeq_NUMB)
                                           FROM IVMG_Y1 c
                                          WHERE c.CaseWelfare_IDNO = a.CaseWelfare_IDNO
                                            AND c.CpMcI_IDNO = @Ln_CpMCI_IDNO
                                            AND c.WelfareElig_CODE = @Lc_TypeWelfareTanf_CODE
                                            AND c.WelfareYearMonth_NUMB = a.WelfareYearMonth_NUMB);

         SET @Ln_RowCount_QNTY = @@ROWCOUNT;

         IF @Ln_RowCount_QNTY = 0
          BEGIN
           GOTO NEXT_FETCH;
          END

         SELECT @Ln_LtdUrg_AMNT = @Ln_IvmgAdjust_AMNT - @Ln_AdjustRecoup_AMNT,
                @Ln_IvmgAdjust_AMNT = @Ln_AdjustRecoup_AMNT;
        END

       IF @Lc_SeqGenerate_INDC = @Lc_No_INDC
        BEGIN
		 SET @Lc_Process_ID = @Lc_Grantmhis_CODE + @Ac_Screen_ID;
         IF @Ac_Screen_ID = @Lc_ScreenNipa_CODE
          BEGIN
           SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GENERATE_SEQ1';
           SET @Ls_Sqldata_TEXT = 'EventFunctionalSeq_NUMB = ' + ISNULL(CAST(@Li_TanfGrantSplitAfterParticipantStatusChange2750_NUMB AS VARCHAR), @Lc_Space_TEXT) + ', Process_ID = ' + ISNULL(@Lc_Process_ID, @Lc_Space_TEXT) + ', EffectiveEvent_DATE = ' + ISNULL(CONVERT(VARCHAR, @Ld_End_DATE, 101), '');

           EXECUTE BATCH_COMMON$SP_GENERATE_SEQ
            @An_EventFunctionalSeq_NUMB = @Li_TanfGrantSplitAfterParticipantStatusChange2750_NUMB,
            @Ac_Process_ID              = @Lc_Process_ID,
            @Ad_EffectiveEvent_DATE     = @Ld_End_DATE,
            @Ac_Note_INDC               = @Lc_No_INDC,
            @Ac_Worker_ID               = @Ac_SignedOnWorker_ID,
            @An_EventGlobalSeq_NUMB     = @Ln_EventGlobalSeq_NUMB OUTPUT,
            @Ac_Msg_CODE                = @Ac_Msg_CODE OUTPUT,
            @As_DescriptionError_TEXT   = @As_DescriptionError_TEXT OUTPUT;

           IF @Ac_Msg_CODE = @Lc_StatusFailed_CODE
            BEGIN
             SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GENERATE_SEQ1  FAILED';

             RAISERROR(50001,16,1);
            END
          END
         ELSE
          BEGIN
           SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GENERATE_SEQ2';
           SET @Ls_Sqldata_TEXT = 'EventFunctionalSeq_NUMB = ' + ISNULL(CAST(@Li_TanfGrantSplitAfterParticipantStatusChange2750_NUMB AS VARCHAR), @Lc_Space_TEXT) + ', Process_ID = ' + ISNULL(@Lc_Process_ID, @Lc_Space_TEXT) + ', EffectiveEvent_DATE = ' + ISNULL(CONVERT(VARCHAR, @Ld_End_DATE, 101), '');

           EXECUTE BATCH_COMMON$SP_GENERATE_SEQ
            @An_EventFunctionalSeq_NUMB = @Li_TanfGrantSplitAfterParticipantStatusChange2750_NUMB,
            @Ac_Process_ID              = @Lc_Process_ID,
            @Ad_EffectiveEvent_DATE     = @Ld_End_DATE,
            @Ac_Note_INDC               = @Lc_No_INDC,
            @Ac_Worker_ID               = @Ac_SignedOnWorker_ID,
            @An_EventGlobalSeq_NUMB     = @Ln_EventGlobalSeq_NUMB OUTPUT,
            @Ac_Msg_CODE                = @Ac_Msg_CODE OUTPUT,
            @As_DescriptionError_TEXT   = @As_DescriptionError_TEXT OUTPUT;

           IF @Ac_Msg_CODE = @Lc_StatusFailed_CODE
            BEGIN
             SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GENERATE_SEQ2 FAILED';

             RAISERROR(50001,16,1);
            END
          END

         SET @Lc_SeqGenerate_INDC = @Lc_Yes_INDC;
        END

       SET @Lc_Process_INDC = @Lc_No_INDC;

       SET @Ls_Sql_TEXT = 'BATCH_COMMON_PRORATE_GRANT$SP_PRORATE_IVA_GRANT';
       SET @Ls_Sqldata_TEXT = 'CaseWelfare_IDNO  = ' + ISNULL(CAST(@Ln_CaseWelfare_IDNO AS VARCHAR), @Lc_Space_TEXT) + ', Start_DATE = ' + ISNULL(CAST(@Ld_Start_DATE AS VARCHAR), @Lc_Space_TEXT) + ', WelfareYearMonth_NUMB = ' + ISNULL(CAST(@Ln_AdjustYearMonth_NUMB AS VARCHAR), '');

       EXECUTE BATCH_COMMON_PRORATE_GRANT$SP_PRORATE_IVA_GRANT
        @An_CaseWelfare_IDNO      = @Ln_CaseWelfare_IDNO,
        @An_CpMCI_IDNO            = @Ln_CpMCI_IDNO,
        @Ad_Start_DATE            = @Ld_Start_DATE,
        @An_WelfareYearMonth_NUMB = @Ln_AdjustYearMonth_NUMB,
        @An_LtdExpend_AMNT        = @Ln_IvmgAdjust_AMNT OUTPUT,
        @An_LtdRecoup_AMNT        = @Ln_AdjustRecoup_AMNT OUTPUT,
        @An_LtdUrg_AMNT           = @Ln_LtdUrg_AMNT OUTPUT,
        @An_MtdExpend_AMNT        = @Ln_MtdExpend_AMNT OUTPUT,
        @An_MtdRecoup_AMNT        = @Ln_MtdRecoup_AMNT OUTPUT,
        @An_MtdUrg_AMNT           = @Ln_MtdUrg_AMNT OUTPUT,
        @Ad_Run_DATE              = @Ld_Run_DATE,
        @Ac_Process_INDC          = @Lc_Process_INDC OUTPUT,
        @Ac_Msg_CODE              = @Ac_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;

       IF @Ac_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         SET @Ls_Sql_TEXT = 'BATCH_COMMON_PRORATE_GRANT$SP_PRORATE_IVA_GRANT FAILED';

         RAISERROR(50001,16,1);
        END

       IF @Lc_Process_INDC = @Lc_No_INDC
        BEGIN
         GOTO NEXT_FETCH;
        END

       DECLARE WEMO_CUR INSENSITIVE CURSOR FOR
        SELECT p.Case_IDNO,
               p.OrderSeq_NUMB,
               p.ObligationSeq_NUMB,
               p.CaseWelfare_IDNO,
               ISNULL(SUM(p.ArrPaid_AMNT), 0),
               ISNULL(SUM(p.ArrRecoup_AMNT), 0),
               ISNULL(SUM(p.ArrPaidMtd_AMNT), 0),
               ISNULL(SUM(p.ArrRecoupMtd_AMNT), 0),
               ISNULL(SUM(p.ArrPaidUrg_AMNT), 0),
               ISNULL(SUM(p.ArrPaidMtdUrg_AMNT), 0)
          FROM #TPRCP_P1 p
         GROUP BY p.Case_IDNO,
                  p.OrderSeq_NUMB,
                  p.ObligationSeq_NUMB,
                  p.CaseWelfare_IDNO;

       OPEN WEMO_CUR;

       FETCH NEXT FROM WEMO_CUR INTO @Ln_WemoCur_Case_IDNO, @Ln_WemoCur_OrderSeq_NUMB, @Ln_WemoCur_ObligationSeq_NUMB, @Ln_WemoCur_CaseWelfare_IDNO, @Ln_WemoCur_ArrPaid_AMNT, @Ln_WemoCur_ArrRecoup_AMNT, @Ln_WemoCur_ArrPaidMtd_AMNT, @Ln_WemoCur_ArrRecoupMtd_AMNT, @Ln_WemoCur_ArrPaidUrg_AMNT, @Ln_WemoCur_ArrPaidMtdUrg_AMNT;

       SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;

       --This while loop is for retriving the WEMO_CUR	   
       WHILE @Li_FetchStatus_QNTY = 0
        BEGIN --3RD WHILE
         SET @Ls_Sql_TEXT = 'SELECT WEMO_Y1 1';
         SET @Ls_Sqldata_TEXT = 'Case_IDNO  = ' + ISNULL(CAST(@Ln_WemoCur_Case_IDNO AS VARCHAR), @Lc_Space_TEXT) + ', OrderSeq_NUMB = ' + ISNULL(CAST(@Ln_WemoCur_OrderSeq_NUMB AS VARCHAR), @Lc_Space_TEXT) + ', ObligationSeq_NUMB = ' + ISNULL(CAST(@Ln_WemoCur_ObligationSeq_NUMB AS VARCHAR), @Lc_Space_TEXT) + ', CaseWelfare_IDNO = ' + ISNULL(CAST(@Ln_WemoCur_CaseWelfare_IDNO AS VARCHAR), @Lc_Space_TEXT) + ', WelfareYearMonth_NUMB = ' + ISNULL(CAST(@Ln_AdjustYearMonth_NUMB AS VARCHAR), @Lc_Space_TEXT);

         SELECT TOP 1 @Lc_Exist_INDC = @Lc_Yes_INDC
           FROM WEMO_Y1 w
          WHERE w.Case_IDNO = @Ln_WemoCur_Case_IDNO
            AND w.OrderSeq_NUMB = @Ln_WemoCur_OrderSeq_NUMB
            AND w.ObligationSeq_NUMB = @Ln_WemoCur_ObligationSeq_NUMB
            AND w.CaseWelfare_IDNO = @Ln_WemoCur_CaseWelfare_IDNO
            AND w.EventGlobalBeginSeq_NUMB != @Ln_EventGlobalSeq_NUMB;

         SET @Ln_RowCount_QNTY = @@ROWCOUNT;

         IF @Ln_RowCount_QNTY = 0
          BEGIN
           SET @Ls_Sql_TEXT = 'SELECT WEMO_Y1 2';

           SELECT @Ln_WelfareYearMonth_NUMB = MIN (e.WelfareYearMonth_NUMB)
             FROM WEMO_Y1 e
            WHERE e.CaseWelfare_IDNO = @Ln_WemoCur_CaseWelfare_IDNO
              AND e.EventGlobalBeginSeq_NUMB != @Ln_EventGlobalSeq_NUMB
              AND e.EndValidity_DATE = @Ld_High_DATE;

           SET @Lc_Exist_INDC = @Lc_No_INDC;
          END

         SET @Ls_Sql_TEXT = 'SELECT WEMO_Y1 3';

         SELECT @Ln_MtdAssistExpend_AMNT = y.MtdAssistExpend_AMNT,
                @Ln_LtdAssistExpend_AMNT = y.LtdAssistExpend_AMNT,
                @Ln_MtdAssistRecoup_AMNT = y.MtdAssistRecoup_AMNT,
                @Ln_LtdAssistRecoup_AMNT = y.LtdAssistRecoup_AMNT
           FROM WEMO_Y1 y
          WHERE y.Case_IDNO = @Ln_WemoCur_Case_IDNO
            AND y.OrderSeq_NUMB = @Ln_WemoCur_OrderSeq_NUMB
            AND y.ObligationSeq_NUMB = @Ln_WemoCur_ObligationSeq_NUMB
            AND y.CaseWelfare_IDNO = @Ln_WemoCur_CaseWelfare_IDNO
            AND y.WelfareYearMonth_NUMB = @Ln_AdjustYearMonth_NUMB
            AND y.EndValidity_DATE = @Ld_High_DATE;

         SET @Ln_RowCount_QNTY = @@ROWCOUNT;

         IF (@Ln_RowCount_QNTY = 0)
          BEGIN
           SET @Ls_Sql_TEXT = 'SELECT WEMO_Y1 4';

           SELECT @Ln_LtdAssistExpend_AMNT = a.LtdAssistExpend_AMNT,
                  @Ln_LtdAssistRecoup_AMNT = a.LtdAssistRecoup_AMNT
             FROM WEMO_Y1 a
            WHERE a.Case_IDNO = @Ln_WemoCur_Case_IDNO
              AND a.OrderSeq_NUMB = @Ln_WemoCur_OrderSeq_NUMB
              AND a.ObligationSeq_NUMB = @Ln_WemoCur_ObligationSeq_NUMB
              AND a.CaseWelfare_IDNO = @Ln_WemoCur_CaseWelfare_IDNO
              AND a.WelfareYearMonth_NUMB = (SELECT MAX (b.WelfareYearMonth_NUMB)
                                               FROM WEMO_Y1 b
                                              WHERE b.Case_IDNO = a.Case_IDNO
                                                AND b.OrderSeq_NUMB = a.OrderSeq_NUMB
                                                AND b.ObligationSeq_NUMB = a.ObligationSeq_NUMB
                                                AND b.CaseWelfare_IDNO = a.CaseWelfare_IDNO
                                                AND b.WelfareYearMonth_NUMB <= @Ln_AdjustYearMonth_NUMB
                                                AND b.EndValidity_DATE = @Ld_High_DATE)
              AND a.EndValidity_DATE = @Ld_High_DATE;

           SET @Ln_RowCount_QNTY = @@ROWCOUNT;

           IF (@Ln_RowCount_QNTY = 0)
            BEGIN
             SELECT @Ln_MtdAssistExpend_AMNT = @Li_Zero_NUMB,
                    @Ln_LtdAssistExpend_AMNT = @Li_Zero_NUMB,
                    @Ln_MtdAssistRecoup_AMNT = @Li_Zero_NUMB,
                    @Ln_LtdAssistRecoup_AMNT = @Li_Zero_NUMB,
                    @Ln_Recoup_AMNT = @Li_Zero_NUMB;
            END
          END

         SET @Ls_Sql_TEXT = 'UPDATE_VWEMO1';
         SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_WemoCur_Case_IDNO AS NVARCHAR(6)), '') + ', OrderSeq_NUMB = ' + ISNULL(CAST(@Ln_WemoCur_OrderSeq_NUMB AS NVARCHAR(2)), '') + ', ObligationSeq_NUMB = ' + ISNULL(CAST(@Ln_WemoCur_ObligationSeq_NUMB AS NVARCHAR(2)), '') + ', CaseWelfare_IDNO = ' + ISNULL(CAST(@Ln_WemoCur_CaseWelfare_IDNO AS NVARCHAR(10)), '') + ', WelfareYearMonth_NUMB = ' + ISNULL(CAST(@Ln_AdjustYearMonth_NUMB AS NVARCHAR(6)), '');

         UPDATE WEMO_Y1
            SET EndValidity_DATE = @Ld_End_DATE,
                EventGlobalEndSeq_NUMB = @Ln_EventGlobalSeq_NUMB
          WHERE Case_IDNO = @Ln_WemoCur_Case_IDNO
            AND OrderSeq_NUMB = @Ln_WemoCur_OrderSeq_NUMB
            AND ObligationSeq_NUMB = @Ln_WemoCur_ObligationSeq_NUMB
            AND CaseWelfare_IDNO = @Ln_WemoCur_CaseWelfare_IDNO
            AND WelfareYearMonth_NUMB = @Ln_AdjustYearMonth_NUMB
            AND EndValidity_DATE = @Ld_High_DATE;

         SET @Ln_RowCount_QNTY = @@ROWCOUNT;

         IF @Ln_RowCount_QNTY != @Li_Zero_NUMB
             OR (@Ln_RowCount_QNTY = @Li_Zero_NUMB
                 AND (@Ln_WemoCur_ArrPaid_AMNT <> @Li_Zero_NUMB
                       OR @Ln_WemoCur_ArrRecoup_AMNT <> @Li_Zero_NUMB
                       OR @Ln_WemoCur_ArrPaidMtd_AMNT <> @Li_Zero_NUMB
                       OR @Ln_WemoCur_ArrRecoupMtd_AMNT <> @Li_Zero_NUMB
                       OR @Ln_WemoCur_ArrPaidUrg_AMNT <> @Li_Zero_NUMB
                       OR @Ln_WemoCur_ArrPaidMtdUrg_AMNT <> @Li_Zero_NUMB))
          BEGIN
           SET @Ls_Sql_TEXT = 'INSERT_VWEMO1';
           SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + ISNULL(CAST(@Ln_WemoCur_Case_IDNO AS NVARCHAR(6)), '') + ', OrderSeq_NUMB = ' + ISNULL(CAST(@Ln_WemoCur_OrderSeq_NUMB AS NVARCHAR(2)), '') + ', ObligationSeq_NUMB = ' + ISNULL(CAST(@Ln_WemoCur_ObligationSeq_NUMB AS NVARCHAR(2)), '') + ', CaseWelfare_IDNO = ' + ISNULL(CAST(@Ln_WemoCur_CaseWelfare_IDNO AS NVARCHAR(10)), '') + ', WelfareYearMonth_NUMB = ' + ISNULL(CAST(@Ln_AdjustYearMonth_NUMB AS NVARCHAR(6)), '');

           INSERT WEMO_Y1
                  (Case_IDNO,
                   OrderSeq_NUMB,
                   ObligationSeq_NUMB,
                   CaseWelfare_IDNO,
                   WelfareYearMonth_NUMB,
                   MtdAssistExpend_AMNT,
                   TransactionAssistExpend_AMNT,
                   LtdAssistExpend_AMNT,
                   MtdAssistRecoup_AMNT,
                   TransactionAssistRecoup_AMNT,
                   LtdAssistRecoup_AMNT,
                   BeginValidity_DATE,
                   EndValidity_DATE,
                   EventGlobalBeginSeq_NUMB,
                   EventGlobalEndSeq_NUMB)
           VALUES ( @Ln_WemoCur_Case_IDNO,--Case_IDNO
                    @Ln_WemoCur_OrderSeq_NUMB,--OrderSeq_NUMB 
                    @Ln_WemoCur_ObligationSeq_NUMB,--ObligationSeq_NUMB
                    @Ln_WemoCur_CaseWelfare_IDNO,--CaseWelfare_IDNO 
                    @Ln_AdjustYearMonth_NUMB,--WelfareYearMonth_NUMB
                    (@Ln_WemoCur_ArrPaidMtd_AMNT + @Ln_WemoCur_ArrPaidMtdUrg_AMNT),--MtdAssistExpend_AMNT
                    (@Ln_WemoCur_ArrPaid_AMNT - @Ln_LtdAssistExpend_AMNT + @Ln_WemoCur_ArrPaidMtd_AMNT + @Ln_WemoCur_ArrPaidMtdUrg_AMNT + @Ln_WemoCur_ArrPaidUrg_AMNT),--TransactionAssistExpend_AMNT
                    (@Ln_WemoCur_ArrPaid_AMNT + @Ln_WemoCur_ArrPaidMtd_AMNT + @Ln_WemoCur_ArrPaidMtdUrg_AMNT + @Ln_WemoCur_ArrPaidUrg_AMNT),--LtdAssistExpend_AMNT
                    @Ln_WemoCur_ArrRecoupMtd_AMNT,--MtdAssistRecoup_AMNT
                    (@Ln_WemoCur_ArrRecoup_AMNT - @Ln_LtdAssistRecoup_AMNT + @Ln_WemoCur_ArrRecoupMtd_AMNT),--TransactionAssistRecoup_AMNT
                    (@Ln_WemoCur_ArrRecoup_AMNT + @Ln_WemoCur_ArrRecoupMtd_AMNT),--LtdAssistRecoup_AMNT
                    @Ld_End_DATE,--BeginValidity_DATE 
                    @Ld_High_DATE,--EndValidity_DATE 
                    @Ln_EventGlobalSeq_NUMB,--EventGlobalBeginSeq_NUMB
                    @Li_Zero_NUMB --EventGlobalEndSeq_NUMB
           );

           SET @Ln_RowCount_QNTY = @@ROWCOUNT;

           IF @Ln_RowCount_QNTY = @Li_Zero_NUMB
            BEGIN
             SET @Ls_Sql_TEXT = 'INSERT_VWEMO1 FAILED';

             RAISERROR(50001,16,1);
            END
          END

         IF NOT EXISTS (SELECT 1
                          FROM @GrantTab_P1
                         WHERE Case_IDNO = @Ln_WemoCur_Case_IDNO
                           AND OrderSeq_NUMB = @Ln_WemoCur_OrderSeq_NUMB
                           AND ObligationSeq_NUMB = @Ln_WemoCur_ObligationSeq_NUMB
                           AND SupportYearMonth_NUMB = @Ln_AdjustYearMonth_NUMB)
          BEGIN
           SET @Ls_Sql_TEXT = 'INSERT GrantTab_P1';
           SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + ISNULL(CAST(@Ln_WemoCur_Case_IDNO AS NVARCHAR(6)), '') + ', OrderSeq_NUMB = ' + ISNULL(CAST(@Ln_WemoCur_OrderSeq_NUMB AS NVARCHAR(2)), '') + ', ObligationSeq_NUMB = ' + ISNULL(CAST(@Ln_WemoCur_ObligationSeq_NUMB AS NVARCHAR(2)), '') + ', SupportYearMonth_NUMB = ' + ISNULL(CAST(@Ln_AdjustYearMonth_NUMB AS NVARCHAR(6)), '');

           INSERT INTO @GrantTab_P1
                       (Case_IDNO,
                        OrderSeq_NUMB,
                        ObligationSeq_NUMB,
                        SupportYearMonth_NUMB)
                VALUES (@Ln_WemoCur_Case_IDNO,-- Case_IDNO
                        @Ln_WemoCur_OrderSeq_NUMB,-- OrderSeq_NUMB
                        @Ln_WemoCur_ObligationSeq_NUMB,-- ObligationSeq_NUMB
                        @Ln_AdjustYearMonth_NUMB ); -- SupportYearMonth_NUMB 

           SET @Ln_RowCount_QNTY = @@ROWCOUNT;

           IF @Ln_RowCount_QNTY = @Li_Zero_NUMB
            BEGIN
             SET @Ls_Sql_TEXT = 'INSERT_GrantTab_P1 FAILED';

             RAISERROR(50001,16,1);
            END
          END

         FETCH NEXT FROM WEMO_CUR INTO @Ln_WemoCur_Case_IDNO, @Ln_WemoCur_OrderSeq_NUMB, @Ln_WemoCur_ObligationSeq_NUMB, @Ln_WemoCur_CaseWelfare_IDNO, @Ln_WemoCur_ArrPaid_AMNT, @Ln_WemoCur_ArrRecoup_AMNT, @Ln_WemoCur_ArrPaidMtd_AMNT, @Ln_WemoCur_ArrRecoupMtd_AMNT, @Ln_WemoCur_ArrPaidUrg_AMNT, @Ln_WemoCur_ArrPaidMtdUrg_AMNT;

         SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
        END --3RD WHILE   	            

       CLOSE WEMO_CUR;

       DEALLOCATE WEMO_CUR;

       SET @Ls_Sql_TEXT = 'INSERT_ZERO_VWEMO';
       SET @Ls_Sqldata_TEXT = ' CaseWelfare_IDNO = ' + ISNULL (CAST (@Ln_CaseWelfare_IDNO AS NVARCHAR(10)), '') + ', EventGlobalSeq_NUMB = ' + ISNULL (CAST (@Ln_EventGlobalSeq_NUMB AS NVARCHAR(19)), '') + ', WelfareYearMonth_NUMB = ' + ISNULL (CAST (@Ln_AdjustYearMonth_NUMB AS NVARCHAR(6)), '');

       INSERT WEMO_Y1
              (Case_IDNO,
               OrderSeq_NUMB,
               ObligationSeq_NUMB,
               CaseWelfare_IDNO,
               WelfareYearMonth_NUMB,
               MtdAssistExpend_AMNT,
               TransactionAssistExpend_AMNT,
               LtdAssistExpend_AMNT,
               MtdAssistRecoup_AMNT,
               TransactionAssistRecoup_AMNT,
               LtdAssistRecoup_AMNT,
               BeginValidity_DATE,
               EndValidity_DATE,
               EventGlobalBeginSeq_NUMB,
               EventGlobalEndSeq_NUMB)
       SELECT a.Case_IDNO,
              a.OrderSeq_NUMB,
              a.ObligationSeq_NUMB,
              a.CaseWelfare_IDNO,
              a.WelfareYearMonth_NUMB,
              @Li_Zero_NUMB AS MtdAssistExpend_AMNT,
              @Li_Zero_NUMB AS TransactionAssistExpend_AMNT,
              @Li_Zero_NUMB AS LtdAssistExpend_AMNT,
              @Li_Zero_NUMB AS MtdAssistRecoup_AMNT,
              @Li_Zero_NUMB AS TransactionAssistRecoup_AMNT,
              @Li_Zero_NUMB AS LtdAssistRecoup_AMNT,
              @Ld_End_DATE AS BeginValidity_DATE,
              @Ld_High_DATE AS EndValidity_DATE,
              @Ln_EventGlobalSeq_NUMB AS EventGlobalBeginSeq_NUMB,
              @Li_Zero_NUMB AS EventGlobalEndSeq_NUMB
         FROM WEMO_Y1 a
        WHERE a.CaseWelfare_IDNO = @Ln_CaseWelfare_IDNO
          AND a.WelfareYearMonth_NUMB = @Ln_AdjustYearMonth_NUMB
          AND a.EndValidity_DATE = @Ld_High_DATE
          AND a.WelfareYearMonth_NUMB = (SELECT MAX (c.WelfareYearMonth_NUMB)
                                           FROM WEMO_Y1 c
                                          WHERE c.CaseWelfare_IDNO = a.CaseWelfare_IDNO
                                            AND c.Case_IDNO = a.Case_IDNO
                                            AND c.OrderSeq_NUMB = a.OrderSeq_NUMB
                                            AND c.ObligationSeq_NUMB = a.ObligationSeq_NUMB
                                            AND c.EndValidity_DATE = @Ld_High_DATE)
          AND a.Case_IDNO IN ( SELECT Case_IDNO FROM CMEM_Y1 b
                            WHERE b.MemberMci_IDNO = @Ln_CpMci_IDNO
                            AND b.CaseRelationship_CODE = @Lc_CaseRelationShipCP_CODE
                            AND b.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE)   
          AND NOT EXISTS (SELECT 1
                            FROM #TPRCP_P1 b
                           WHERE b.CaseWelfare_IDNO = a.CaseWelfare_IDNO
                             AND b.Case_IDNO = a.Case_IDNO
                             AND b.OrderSeq_NUMB = a.OrderSeq_NUMB
                             AND b.ObligationSeq_NUMB = a.ObligationSeq_NUMB);

       SET @Ls_Sql_TEXT = 'UPDATE_VWEMO2';
       SET @Ls_Sqldata_TEXT = ' CaseWelfare_IDNO  = ' + ISNULL(CAST(@Ln_CaseWelfare_IDNO AS VARCHAR(10)), '') + ', EventGlobalSeq_NUMB = ' + ISNULL(CAST(@Ln_EventGlobalSeq_NUMB AS VARCHAR(19)), '') + ', WelfareYearMonth_NUMB = ' + ISNULL(CAST(@Ln_AdjustYearMonth_NUMB AS VARCHAR(6)), '');

       UPDATE WEMO_Y1
          SET EndValidity_DATE = @Ld_End_DATE,
              EventGlobalEndSeq_NUMB = @Ln_EventGlobalSeq_NUMB
         FROM WEMO_Y1 a
        WHERE a.CaseWelfare_IDNO = @Ln_CaseWelfare_IDNO
          AND a.WelfareYearMonth_NUMB = @Ln_AdjustYearMonth_NUMB
          AND a.EndValidity_DATE = @Ld_High_DATE
          AND a.EventGlobalBeginSeq_NUMB < @Ln_EventGlobalSeq_NUMB
          AND NOT EXISTS(SELECT 1
                           FROM #TPRCP_P1 b
                          WHERE b.CaseWelfare_IDNO = a.CaseWelfare_IDNO
                            AND b.Case_IDNO = a.Case_IDNO
                            AND b.OrderSeq_NUMB = a.OrderSeq_NUMB
                            AND b.ObligationSeq_NUMB = a.ObligationSeq_NUMB)
         AND a.Case_IDNO IN ( SELECT Case_IDNO FROM CMEM_Y1 b
                            WHERE b.MemberMci_IDNO = @Ln_CpMci_IDNO
                            AND b.CaseRelationship_CODE = @Lc_CaseRelationShipCP_CODE
                            AND b.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE);

       DELETE #TPRCP_P1;

       NEXT_FETCH:;

       SET @Ld_Start_DATE = DATEADD(m, 1, @Ld_Start_DATE);

       IF dbo.BATCH_COMMON_SCALAR$SF_TO_CHAR_DATE(@Ld_Start_DATE, @Lc_DateFormatYyyymm_CODE) = dbo.BATCH_COMMON_SCALAR$SF_TO_CHAR_DATE(@Ld_Run_DATE, @Lc_DateFormatYyyymm_CODE)
        BEGIN
         SET @Ld_Start_DATE = @Ld_Run_DATE;
        END
      END--2ND DATE WHILE 

     NEXT_MHIS_REC:;

     FETCH NEXT FROM MHIS_CUR INTO @Ln_MhisCur_CaseWelfare_IDNO;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END--1ST MAIN WHILE 
   CLOSE MHIS_CUR;

   DEALLOCATE MHIS_CUR;

   SET @Ls_Sql_TEXT = ' UPDATE_TIVAL_Y1';
   SET @Ls_Sqldata_TEXT = 'CaseWelfare_IDNO = ' + ISNULL(CAST(@Ln_CaseWelfare_IDNO AS NVARCHAR(10)), '');

   UPDATE @WelfDistOverride_P1
      SET ChangeOvpy_INDC = @Lc_No_INDC
    WHERE CaseWelfare_IDNO = @Ln_CaseWelfare_IDNO;

   DECLARE GrantData_Cur INSENSITIVE CURSOR FOR
    SELECT a.Case_IDNO,
           a.OrderSeq_NUMB,
           a.ObligationSeq_NUMB,
           a.SupportYearMonth_NUMB
      FROM @GrantTab_P1 a;

   OPEN GrantData_Cur;

   FETCH NEXT FROM GrantData_Cur INTO @Ln_GrantDataCur_Case_IDNO, @Ln_GrantDataCur_OrderSeq_NUMB, @Ln_GrantDataCur_ObligationSeq_NUMB, @Ln_GrantDataCur_SupportYearMonth_NUMB;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;

   --This while loop is for retriving the GrantData_Cur        
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_REASSIGN_ARREARS';
     SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + ISNULL(CAST(@Ln_GrantDataCur_Case_IDNO AS NVARCHAR(6)), '') + ', OrderSeq_NUMB = ' + ISNULL(CAST(@Ln_GrantDataCur_OrderSeq_NUMB AS NVARCHAR(4)), '') + ', ObligationSeq_NUMB = ' + ISNULL(CAST(@Ln_GrantDataCur_ObligationSeq_NUMB AS NVARCHAR(4)), '');

     EXECUTE BATCH_COMMON$SP_REASSIGN_ARREARS
      @An_Case_IDNO             = @Ln_GrantDataCur_Case_IDNO,
      @An_OrderSeq_NUMB         = @Ln_GrantDataCur_OrderSeq_NUMB,
      @An_ObligationSeq_NUMB    = @Ln_GrantDataCur_ObligationSeq_NUMB,
      @An_SupportYearMonth_NUMB = @Ln_GrantDataCur_SupportYearMonth_NUMB,
      @An_CpMCI_IDNO            = @Ln_CpMCI_IDNO,
      @An_EventGlobalSeq_NUMB   = @Ln_EventGlobalSeq_NUMB,
      @Ac_Screen_ID             = @Ac_Screen_ID,
      @Ad_Process_DATE          = @Ld_Run_DATE,
      @Ac_Msg_CODE              = @Ac_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;

     IF @Ac_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_REASSIGN_ARREARS FAILED';

       RAISERROR(50001,16,1);
      END

     FETCH NEXT FROM GrantData_Cur INTO @Ln_GrantDataCur_Case_IDNO, @Ln_GrantDataCur_OrderSeq_NUMB, @Ln_GrantDataCur_ObligationSeq_NUMB, @Ln_GrantDataCur_SupportYearMonth_NUMB;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END

   CLOSE GrantData_Cur;

   DEALLOCATE GrantData_Cur;

   DELETE FROM @GrantTab_P1;

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

   IF CURSOR_STATUS ('local', 'WEMO_CUR') IN (0, 1)
    BEGIN
     CLOSE WEMO_CUR;

     DEALLOCATE WEMO_CUR;
    END

   IF CURSOR_STATUS ('local', 'MHIS_CUR') IN (0, 1)
    BEGIN
     CLOSE MHIS_CUR;

     DEALLOCATE MHIS_CUR;
    END

   IF CURSOR_STATUS ('local', 'GrantData_Cur') IN (0, 1)
    BEGIN
     CLOSE GrantData_Cur;

     DEALLOCATE GrantData_Cur;
    END

   SET @Li_Error_NUMB = ERROR_NUMBER();
   SET @Li_ErrorLine_NUMB = ERROR_LINE();

   IF @Li_Error_NUMB <> 50001
    BEGIN
     SET @Ls_ErrorMessage_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END
   ELSE
    BEGIN
     SET @Ls_DescriptionError_TEXT = @As_DescriptionError_TEXT;
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Li_Error_NUMB,
    @An_ErrorLine_NUMB        = @Li_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
  END CATCH
 END;


GO
