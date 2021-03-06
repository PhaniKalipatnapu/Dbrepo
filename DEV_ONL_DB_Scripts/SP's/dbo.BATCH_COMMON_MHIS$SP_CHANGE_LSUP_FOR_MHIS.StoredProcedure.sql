/****** Object:  StoredProcedure [dbo].[BATCH_COMMON_MHIS$SP_CHANGE_LSUP_FOR_MHIS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_COMMON_MHIS$SP_CHANGE_LSUP_FOR_MHIS
Programmer Name		: IMP Team
Description			: This procedure is used to Process the record for Log Support.
Frequency			: DAILY
Developed On		: 04/12/2011
Called By			: None
Called On			:
--------------------------------------------------------------------------------------------------------------------
Modified By			:
Modified On			:
Version No			: 1.0	
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_COMMON_MHIS$SP_CHANGE_LSUP_FOR_MHIS] (
 @An_Case_IDNO             NUMERIC(6),
 @An_MemberMci_IDNO        NUMERIC(10),
 @Ax_MhisChange_XML        XML,
 @Ad_LhsBeginEligible_DATE DATE,
 @Ad_RhsBeginEligible_DATE DATE,
 @Ad_EndEligible_DATE      DATE,
 @An_EventGlobalSeq_NUMB   NUMERIC(19),
 @Ad_Run_DATE              DATE,
 @Ac_Msg_CODE              CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Ln_Array_QNTY                 NUMERIC = 0,
          @Lc_Space_TEXT                 CHAR(1) = ' ',
          @Lc_No_CODE                    CHAR(1) = 'N',
          @Lc_Yes_CODE                   CHAR(1) = 'Y',
          @Lc_StatusSuccess_CODE         CHAR(1) = 'S',
          @Lc_StatusFailed_CODE          CHAR(1) = 'F',
          @Lc_WelfareTypeNonTanf_CODE    CHAR(1) = 'N',
          @Lc_WelfareTypeTanf_CODE       CHAR(1) = 'A',
          @Lc_WelfareTypeMedicaid_CODE   CHAR(1) = 'M',
          @Lc_WelfareTypeNonIve_CODE     CHAR(1) = 'F',
          @Lc_WelfareTypeFosterCare_CODE CHAR(1) = 'J',
          @Lc_WelfareTypeNonIvd_CODE     CHAR(1) = 'H',
          @Lc_InStateFips_CODE           CHAR(2) = '10',
          @Ls_Procedure_NAME             VARCHAR(100) = 'BATCH_COMMON _MHIS$SP_CHANGE_LSUP_FOR_MHIS',
          @Ld_High_DATE                  DATE = '12/31/9999',
          @Ld_Low_DATE                   DATE = '01/01/0001';
  DECLARE @Ln_Error_NUMB            NUMERIC,
          @Ln_RowCount_QNTY         NUMERIC = 0,
          @Ln_Zero_NUMB             NUMERIC = 0,
          @Ln_FetchStatus_QNTY      NUMERIC = 0,
          @Ln_ErrorLine_NUMB        NUMERIC(11),
          @Ls_Sql_TEXT              VARCHAR(100),
          @Ls_Sqldata_TEXT          VARCHAR(300),
          @Ls_ErrorMessage_TEXT     VARCHAR(500) = '',
          @Ls_ErrorDescription_TEXT VARCHAR(4000) = '';
  DECLARE @Ln_CirTransactionTaa_AMNT NUMERIC(11, 2) = 0,
          @Lc_TypeWelfareIn_CODE     CHAR(1) = ' ',
          @Lc_ProcessGap_CODE        CHAR(1) = 'N',
          @Ln_ArrayPos_NUMB          NUMERIC = 0,
          @Ln_ProcessCount_QNTY      NUMERIC = 0,
          @Ln_SupportYearMonth_NUMB  NUMERIC(6),
          @Ln_OweTotCurSup_AMNT      NUMERIC(11, 2),
          @Ln_AppTotCurSup_AMNT      NUMERIC(11, 2),
          @Ln_OweTotExptPay_AMNT     NUMERIC(11, 2),
          @Ln_AppTotExptPay_AMNT     NUMERIC(11, 2),
          @Ln_TransactionNaa_AMNT    NUMERIC(11, 2),
          @Ln_OweTotNaa_AMNT         NUMERIC(11, 2),
          @Ln_AppTotNaa_AMNT         NUMERIC(11, 2),
          @Ln_OweTotTaa_AMNT         NUMERIC(11, 2),
          @Ln_AppTotTaa_AMNT         NUMERIC(11, 2),
          @Ln_TransactionPaa_AMNT    NUMERIC(11, 2),
          @Ln_OweTotPaa_AMNT         NUMERIC(11, 2),
          @Ln_AppTotPaa_AMNT         NUMERIC(11, 2),
          @Ln_OweTotCaa_AMNT         NUMERIC(11, 2),
          @Ln_AppTotCaa_AMNT         NUMERIC(11, 2),
          @Ln_OweTotUpa_AMNT         NUMERIC(11, 2),
          @Ln_AppTotUpa_AMNT         NUMERIC(11, 2),
          @Ln_TransactionUda_AMNT    NUMERIC(11, 2),
          @Ln_OweTotUda_AMNT         NUMERIC(11, 2),
          @Ln_AppTotUda_AMNT         NUMERIC(11, 2),
          @Ln_TransactionIvef_AMNT   NUMERIC(11, 2),
          @Ln_OweTotIvef_AMNT        NUMERIC(11, 2),
          @Ln_AppTotIvef_AMNT        NUMERIC(11, 2),
          @Ln_TransactionMedi_AMNT   NUMERIC(11, 2),
          @Ln_OweTotMedi_AMNT        NUMERIC(11, 2),
          @Ln_AppTotMedi_AMNT        NUMERIC(11, 2),
          @Ln_TransactionNffc_AMNT   NUMERIC(11, 2),
          @Ln_OweTotNffc_AMNT        NUMERIC(11, 2),
          @Ln_AppTotNffc_AMNT        NUMERIC(11, 2),
          @Ln_TransactionNonIvd_AMNT NUMERIC(11, 2),
          @Ln_OweTotNonIvd_AMNT      NUMERIC(11, 2),
          @Ln_AppTotNonIvd_AMNT      NUMERIC(11, 2),
          @Ln_AppTotFuture_AMNT      NUMERIC(11, 2),
          @Ln_AdjNaa_AMNT            NUMERIC(11, 2),
          @Ln_AdjCsNaa_AMNT          NUMERIC(11, 2),
          @Ln_AdjCsPaa_AMNT          NUMERIC(11, 2),
          @Ln_AdjCsIvef_AMNT         NUMERIC(11, 2),
          @Ln_AdjCsNffc_AMNT         NUMERIC(11, 2),
          @Ln_AdjCsNonIvd_AMNT       NUMERIC(11, 2),
          @Ln_AdjPaa_AMNT            NUMERIC(11, 2),
          @Ln_Owed_DTYM              NUMERIC(11, 2),
          @Ln_ArrNaa_AMNT            NUMERIC(11, 2),
          @Ln_ArrPaa_AMNT            NUMERIC(11, 2),
          @Ln_ArrUda_AMNT            NUMERIC(11, 2),
          @Ln_CirArrCaa_AMNT         NUMERIC(11, 2) = 0,
          @Ln_CirTransactionCaa_AMNT NUMERIC(11, 2) = 0,
          @Ln_CirArrUpa_AMNT         NUMERIC(11, 2) = 0,
          @Ln_CirTransactionUpa_AMNT NUMERIC(11, 2) = 0,
          @Ln_CirArrTaa_AMNT         NUMERIC(11, 2) = 0,
          @Ls_OldMemberStatus_CODE   CHAR(1),
          @Lc_StatusChanged_CODE     CHAR(1),
          @Lc_TypeWelfare_CODE       CHAR(1),
          @Lc_TypeWelf_CODE          CHAR(1),
          @Lc_NeverAssigned_TEXT     CHAR(1),
          @Lc_PrevMonthStatus_CODE   CHAR(1),
          @Lc_OldCase_IDNO           CHAR(6),
          @Lc_OldMember_IDNO         CHAR(10),
          @Ld_Start_DATE             DATE,
          @Ld_End_DATE               DATE,
          @Ld_OldStart_DATE          DATE,
          @Ld_OldEnd_DATE            DATE;
  DECLARE @Ln_ObleCur_Case_IDNO          NUMERIC(6),
          @Ln_ObleCur_OrderSeq_NUMB      NUMERIC(4),
          @Ln_ObleCur_ObligationSeq_NUMB NUMERIC(4),
          @Lc_ObleCur_TypeDebt_CODE      CHAR(2),
          @Lc_ObleCur_Fips_CODE          CHAR(7);
  DECLARE @LsupTemp_T1 TABLE(
   Case_IDNO               NUMERIC(6),
   OrderSeq_NUMB           NUMERIC(2),
   ObligationSeq_NUMB      NUMERIC(2),
   SupportYearMonth_NUMB   NUMERIC(6),
   TypeWelfare_CODE        CHAR(1),
   TransactionCurSup_AMNT  NUMERIC(11, 2),
   OweTotCurSup_AMNT       NUMERIC(11, 2),
   AppTotCurSup_AMNT       NUMERIC(11, 2),
   MtdCurSupOwed_AMNT      NUMERIC(11, 2),
   TransactionExptPay_AMNT NUMERIC(11, 2),
   OweTotExptPay_AMNT      NUMERIC(11, 2),
   AppTotExptPay_AMNT      NUMERIC(11, 2),
   TransactionNaa_AMNT     NUMERIC(11, 2),
   OweTotNaa_AMNT          NUMERIC(11, 2),
   AppTotNaa_AMNT          NUMERIC(11, 2),
   TransactionPaa_AMNT     NUMERIC(11, 2),
   OweTotPaa_AMNT          NUMERIC(11, 2),
   AppTotPaa_AMNT          NUMERIC(11, 2),
   TransactionTaa_AMNT     NUMERIC(11, 2),
   OweTotTaa_AMNT          NUMERIC(11, 2),
   AppTotTaa_AMNT          NUMERIC(11, 2),
   TransactionCaa_AMNT     NUMERIC(11, 2),
   OweTotCaa_AMNT          NUMERIC(11, 2),
   AppTotCaa_AMNT          NUMERIC(11, 2),
   TransactionUpa_AMNT     NUMERIC(11, 2),
   OweTotUpa_AMNT          NUMERIC(11, 2),
   AppTotUpa_AMNT          NUMERIC(11, 2),
   TransactionUda_AMNT     NUMERIC(11, 2),
   OweTotUda_AMNT          NUMERIC(11, 2),
   AppTotUda_AMNT          NUMERIC(11, 2),
   TransactionIvef_AMNT    NUMERIC(11, 2),
   OweTotIvef_AMNT         NUMERIC(11, 2),
   AppTotIvef_AMNT         NUMERIC(11, 2),
   TransactionMedi_AMNT    NUMERIC(11, 2),
   OweTotMedi_AMNT         NUMERIC(11, 2),
   AppTotMedi_AMNT         NUMERIC(11, 2),
   TransactionFuture_AMNT  NUMERIC(11, 2),
   AppTotFuture_AMNT       NUMERIC(11, 2),
   TransactionNffc_AMNT    NUMERIC(11, 2),
   OweTotNffc_AMNT         NUMERIC(11, 2),
   AppTotNffc_AMNT         NUMERIC(11, 2),
   TransactionNonIvd_AMNT  NUMERIC(11, 2),
   OweTotNonIvd_AMNT       NUMERIC(11, 2),
   AppTotNonIvd_AMNT       NUMERIC(11, 2),
   EventGlobalSeq_NUMB     NUMERIC(19));

  BEGIN TRY
   SET @Ac_Msg_CODE = NULL;
   SET @As_DescriptionError_TEXT = NULL;
   SET @Ln_ArrayPos_NUMB = 1;
   SET @Ln_ProcessCount_QNTY = 1;
   SET @Lc_TypeWelf_CODE = @Lc_Space_TEXT;

   IF @Ad_LhsBeginEligible_DATE < @Ad_RhsBeginEligible_DATE
    BEGIN
     SET @Ld_Start_DATE = @Ad_LhsBeginEligible_DATE;
     SET @Ld_End_DATE = DATEADD(D, -1, @Ad_RhsBeginEligible_DATE);
     SET @Lc_TypeWelfareIn_CODE = @Lc_WelfareTypeNonTanf_CODE;
     SET @Ln_ProcessCount_QNTY = @Ln_Zero_NUMB;
     SET @Lc_ProcessGap_CODE = @Lc_Yes_CODE;
    END
   ELSE
    BEGIN
     SET @Ld_Start_DATE = @Ad_RhsBeginEligible_DATE;
     SET @Lc_ProcessGap_CODE = @Lc_No_CODE;
    END

   DECLARE @Lt_ModifiedMhis_TAB TABLE (
    Seq_IDNO         SMALLINT IDENTITY(1, 1),
    Start_DATE       DATE,
    End_DATE         DATE,
    TypeWelfare_CODE CHAR(1));

   INSERT INTO @Lt_ModifiedMhis_TAB
   SELECT nref.value('Start_DATE[1]', 'DATE') AS Start_DATE,
          nref.value('End_DATE[1]', 'DATE') AS End_DATE,
          nref.value('TypeWelfare_CODE[1]', 'CHAR(1)') AS TypeWelfare_CODE
     FROM @Ax_MhisChange_XML.nodes('//Record') AS R(nref);

   SELECT @Ln_Array_QNTY = MAX(MMH.Seq_IDNO)
     FROM @Lt_ModifiedMhis_TAB MMH;

   DECLARE MhisChangeCur INSENSITIVE CURSOR FOR
    SELECT MMH.Start_DATE,
           MMH.End_DATE,
           MMH.TypeWelfare_CODE
      FROM @Lt_ModifiedMhis_TAB MMH;

   OPEN MhisChangeCur;

   WHILE (@Ln_ProcessCount_QNTY <= @Ln_Array_QNTY)
    BEGIN
     /* Process MHIS Gap */
     IF (@Lc_ProcessGap_CODE = @Lc_No_CODE)
      BEGIN
       FETCH NEXT FROM MhisChangeCur INTO @Ld_Start_DATE, @Ld_End_DATE, @Lc_TypeWelfareIn_CODE;

       IF(@Ld_End_DATE >= @Ad_Run_DATE)
        BEGIN
         SET @Ld_End_DATE = @Ad_Run_DATE;
        END
       ELSE
        BEGIN
         IF @Ld_End_DATE < dbo.BATCH_COMMON_SCALAR$SF_LAST_DAY(@Ld_Start_DATE)
          BEGIN
           FETCH MhisChangeCur INTO @Ld_Start_DATE, @Ld_End_DATE, @Lc_TypeWelfareIn_CODE;

           SET @Ln_ProcessCount_QNTY = @Ln_ProcessCount_QNTY + 1;
          END
        END
      END
     ELSE
      BEGIN
       SET @Lc_ProcessGap_CODE = @Lc_No_CODE;
      END

     IF (@Lc_TypeWelfareIn_CODE = @Lc_WelfareTypeTanf_CODE)
      BEGIN
       SET @Lc_TypeWelf_CODE = @Lc_TypeWelfareIn_CODE;
      END

     DECLARE ObleCur CURSOR LOCAL FORWARD_ONLY FOR
      SELECT OB.Case_IDNO,
             OB.OrderSeq_NUMB,
             OB.ObligationSeq_NUMB,
             OB.TypeDebt_CODE,
             OB.Fips_CODE
        FROM OBLE_Y1 OB
       WHERE OB.Case_IDNO = @An_Case_IDNO
         AND OB.MemberMci_IDNO = @An_MemberMci_IDNO
         AND OB.EndValidity_DATE = @Ld_High_DATE
         AND OB.TypeDebt_CODE IN ('CS', 'CI', 'SI', 'SS',
                                  'MS', 'DS')
         AND OB.BeginObligation_DATE = (SELECT MAX(MOB.BeginObligation_DATE)
                                          FROM OBLE_Y1 MOB
                                         WHERE MOB.Case_IDNO = OB.Case_IDNO
                                           AND MOB.OrderSeq_NUMB = OB.OrderSeq_NUMB
                                           AND MOB.ObligationSeq_NUMB = OB.ObligationSeq_NUMB
                                           AND MOB.BeginObligation_DATE <= @Ad_Run_DATE
                                           AND MOB.EndValidity_DATE = @Ld_High_DATE);

     OPEN ObleCur;

     FETCH NEXT FROM ObleCur INTO @Ln_ObleCur_Case_IDNO, @Ln_ObleCur_OrderSeq_NUMB, @Ln_ObleCur_ObligationSeq_NUMB, @Lc_ObleCur_TypeDebt_CODE, @Lc_ObleCur_Fips_CODE;

     SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;
     SET @Ls_Sql_TEXT = 'LOOP_OBLECUR';

     WHILE (@Ln_FetchStatus_QNTY = 0)
      BEGIN
       IF @Ld_End_DATE >= dbo.BATCH_COMMON_SCALAR$SF_LAST_DAY(@Ld_Start_DATE)
        BEGIN
         SET @Ld_OldStart_DATE = dbo.BATCH_COMMON_SCALAR$SF_LAST_DAY(@Ld_Start_DATE);
        END;
       ELSE
        BEGIN
         IF @Ld_End_DATE >= @Ad_Run_DATE
          BEGIN
           SET @Ld_OldStart_DATE = @Ad_Run_DATE;
          END
         ELSE
          BEGIN
           GOTO next_rec;
          END;
        END;

       SET @Lc_TypeWelfare_CODE = @Lc_TypeWelfareIn_CODE;
       SET @Ld_OldEnd_DATE = @Ld_End_DATE;
       SET @Lc_StatusChanged_CODE = @Lc_No_CODE;
       SET @Ln_AdjCsNaa_AMNT = @Ln_Zero_NUMB;
       SET @Ln_AdjCsPaa_AMNT = @Ln_Zero_NUMB;
       SET @Ln_AdjCsIvef_AMNT = @Ln_Zero_NUMB;
       SET @Ln_AdjCsNffc_AMNT = @Ln_Zero_NUMB;
       SET @Ln_AdjCsNonIvd_AMNT = @Ln_Zero_NUMB;
       SET @Ln_AdjNaa_AMNT = @Ln_Zero_NUMB;
       SET @Ln_AdjPaa_AMNT = @Ln_Zero_NUMB;
       SET @Ln_TransactionNaa_AMNT = @Ln_Zero_NUMB;
       SET @Ln_TransactionPaa_AMNT = @Ln_Zero_NUMB;
       SET @Ln_TransactionUda_AMNT = @Ln_Zero_NUMB;
       SET @Ln_TransactionIvef_AMNT = @Ln_Zero_NUMB;
       SET @Ln_TransactionMedi_AMNT = @Ln_Zero_NUMB;
       SET @Ln_TransactionNffc_AMNT = @Ln_Zero_NUMB;
       SET @Ln_TransactionNonIvd_AMNT = @Ln_Zero_NUMB;

       WHILE ((YEAR(@Ld_OldStart_DATE) * 100 + MONTH(@Ld_OldStart_DATE)) <= (YEAR(@Ad_Run_DATE) * 100 + MONTH(@Ad_Run_DATE)))
        BEGIN
         SET @Ls_Sql_TEXT = 'WHILE_LOOP_DT_START';
         SET @Lc_PrevMonthStatus_CODE = @Ls_OldMemberStatus_CODE;

         BEGIN
          SET @Ls_Sql_TEXT = 'SELECT_V_MHIS';
          SET @Ls_Sqldata_TEXT = '  Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@An_MemberMci_IDNO AS VARCHAR), '') + ', Start_DATE = ' + ISNULL(CAST (@Ld_Start_DATE AS VARCHAR), '') + ', End_DATE = ' + ISNULL(CAST (@Ld_End_DATE AS VARCHAR), '');

          SELECT @Lc_OldCase_IDNO = MH.Case_IDNO,
                 @Lc_OldMember_IDNO = MH.MemberMci_IDNO,
                 @Ls_OldMemberStatus_CODE = MH.TypeWelfare_CODE
            FROM MHIS_Y1 MH
           WHERE MH.Case_IDNO = @An_Case_IDNO
             AND MH.MemberMci_IDNO = @An_MemberMci_IDNO
             AND @Ld_OldStart_DATE BETWEEN MH.Start_DATE AND MH.End_DATE;

          SET @Ln_RowCount_QNTY =@@ROWCOUNT;

          IF(@Ln_RowCount_QNTY = 0)
           BEGIN
            SET @Ls_OldMemberStatus_CODE = dbo.BATCH_COMMON_GETS$SF_GETCASETYPE(@An_Case_IDNO);
           END
         END

         IF (@Ld_OldStart_DATE > @Ld_End_DATE)
          BEGIN
           IF (@Ld_End_DATE > @Ad_EndEligible_DATE)
            BEGIN
             SET @Lc_TypeWelfare_CODE = @Lc_WelfareTypeNonTanf_CODE;
            END;
           ELSE
            BEGIN
             SET @Lc_TypeWelfare_CODE = @Ls_OldMemberStatus_CODE;
            END;
          END;

         IF @Ls_OldMemberStatus_CODE <> @Lc_TypeWelfare_CODE
             OR @Lc_StatusChanged_CODE = @Lc_Yes_CODE
          BEGIN
           SET @Ln_SupportYearMonth_NUMB = YEAR(@Ld_OldStart_DATE) * 100 + MONTH(@Ld_OldStart_DATE);

           BEGIN
            SET @Ls_Sql_TEXT = 'SELECT_TMP_LOG_SUPPORT ';
            SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + ISNULL(CAST(@Ln_ObleCur_Case_IDNO AS VARCHAR), '') + ', OrderSeq_NUMB = ' + ISNULL(CAST(@Ln_ObleCur_OrderSeq_NUMB AS VARCHAR(4)), '') + ', ObligationSeq_NUMB = ' + ISNULL(CAST(@Ln_ObleCur_ObligationSeq_NUMB AS VARCHAR(4)), '') + ', SupportYearMonth_NUMB = ' + ISNULL(CAST(@Ln_SupportYearMonth_NUMB AS VARCHAR(6)), '');

            SELECT @Ln_Owed_DTYM = TL.MtdCurSupOwed_AMNT,
                   @Ln_OweTotCurSup_AMNT = TL.OweTotCurSup_AMNT,
                   @Ln_AppTotCurSup_AMNT = TL.AppTotCurSup_AMNT,
                   @Ln_OweTotExptPay_AMNT = TL.OweTotExptPay_AMNT,
                   @Ln_AppTotExptPay_AMNT = TL.AppTotExptPay_AMNT,
                   @Ln_OweTotNaa_AMNT = TL.OweTotNaa_AMNT,
                   @Ln_AppTotNaa_AMNT = TL.AppTotNaa_AMNT,
                   @Ln_OweTotTaa_AMNT = TL.OweTotTaa_AMNT,
                   @Ln_AppTotTaa_AMNT = TL.AppTotTaa_AMNT,
                   @Ln_OweTotPaa_AMNT = TL.OweTotPaa_AMNT,
                   @Ln_AppTotPaa_AMNT = TL.AppTotPaa_AMNT,
                   @Ln_OweTotCaa_AMNT = TL.OweTotCaa_AMNT,
                   @Ln_AppTotCaa_AMNT = TL.AppTotCaa_AMNT,
                   @Ln_OweTotUpa_AMNT = TL.OweTotUpa_AMNT,
                   @Ln_AppTotUpa_AMNT = TL.AppTotUpa_AMNT,
                   @Ln_OweTotUda_AMNT = TL.OweTotUda_AMNT,
                   @Ln_AppTotUda_AMNT = TL.AppTotUda_AMNT,
                   @Ln_OweTotIvef_AMNT = TL.OweTotIvef_AMNT,
                   @Ln_AppTotIvef_AMNT = TL.AppTotIvef_AMNT,
                   @Ln_OweTotNffc_AMNT = TL.OweTotNffc_AMNT,
                   @Ln_AppTotNffc_AMNT = TL.AppTotNffc_AMNT,
                   @Ln_OweTotNonIvd_AMNT = TL.OweTotNonIvd_AMNT,
                   @Ln_AppTotNonIvd_AMNT = TL.AppTotNonIvd_AMNT,
                   @Ln_OweTotMedi_AMNT = TL.OweTotMedi_AMNT,
                   @Ln_AppTotMedi_AMNT = TL.AppTotMedi_AMNT,
                   @Ln_AppTotFuture_AMNT = TL.AppTotFuture_AMNT
              FROM @LsupTemp_T1 TL
             WHERE TL.Case_IDNO = @Ln_ObleCur_Case_IDNO
               AND TL.OrderSeq_NUMB = @Ln_ObleCur_OrderSeq_NUMB
               AND TL.ObligationSeq_NUMB = @Ln_ObleCur_ObligationSeq_NUMB
               AND TL.SupportYearMonth_NUMB = @Ln_SupportYearMonth_NUMB
               AND TL.EventGlobalSeq_NUMB = (SELECT MAX(MTL.EventGlobalSeq_NUMB) MTL
                                               FROM @LsupTemp_T1 MTL
                                              WHERE MTL.Case_IDNO = TL.Case_IDNO
                                                AND MTL.OrderSeq_NUMB = TL.OrderSeq_NUMB
                                                AND MTL.ObligationSeq_NUMB = TL.ObligationSeq_NUMB
                                                AND MTL.SupportYearMonth_NUMB = TL.SupportYearMonth_NUMB);

            SET @Ln_RowCount_QNTY =@@ROWCOUNT;

            IF(@Ln_RowCount_QNTY = 0)
             BEGIN
              SET @Ls_Sql_TEXT = 'SELECT_TMP_LOG_SUPPORT ';
              SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_ObleCur_Case_IDNO AS VARCHAR), '') + ', OrderSeq_NUMB = ' + ISNULL(CAST(@Ln_ObleCur_OrderSeq_NUMB AS VARCHAR(4)), '') + ', ObligationSeq_NUMB = ' + ISNULL(CAST(@Ln_ObleCur_ObligationSeq_NUMB AS VARCHAR(4)), '') + ', SupportYearMonth_NUMB = ' + ISNULL(CAST(@Ln_SupportYearMonth_NUMB AS NVARCHAR(MAX)), '');

              SELECT @Ln_Owed_DTYM = L.MtdCurSupOwed_AMNT,
                     @Ln_OweTotCurSup_AMNT = L.OweTotCurSup_AMNT,
                     @Ln_AppTotCurSup_AMNT = L.AppTotCurSup_AMNT,
                     @Ln_OweTotExptPay_AMNT = L.OweTotExptPay_AMNT,
                     @Ln_AppTotExptPay_AMNT = L.AppTotExptPay_AMNT,
                     @Ln_OweTotNaa_AMNT = L.OweTotNaa_AMNT,
                     @Ln_AppTotNaa_AMNT = L.AppTotNaa_AMNT,
                     @Ln_OweTotTaa_AMNT = L.OweTotTaa_AMNT,
                     @Ln_AppTotTaa_AMNT = L.AppTotTaa_AMNT,
                     @Ln_OweTotPaa_AMNT = L.OweTotPaa_AMNT,
                     @Ln_AppTotPaa_AMNT = L.AppTotPaa_AMNT,
                     @Ln_OweTotCaa_AMNT = L.OweTotCaa_AMNT,
                     @Ln_AppTotCaa_AMNT = L.AppTotCaa_AMNT,
                     @Ln_OweTotUpa_AMNT = L.OweTotUpa_AMNT,
                     @Ln_AppTotUpa_AMNT = L.AppTotUpa_AMNT,
                     @Ln_OweTotUda_AMNT = L.OweTotUda_AMNT,
                     @Ln_AppTotUda_AMNT = L.AppTotUda_AMNT,
                     @Ln_OweTotIvef_AMNT = L.OweTotIvef_AMNT,
                     @Ln_AppTotIvef_AMNT = L.AppTotIvef_AMNT,
                     @Ln_OweTotNffc_AMNT = L.OweTotNffc_AMNT,
                     @Ln_AppTotNffc_AMNT = L.AppTotNffc_AMNT,
                     @Ln_OweTotNonIvd_AMNT = L.OweTotNonIvd_AMNT,
                     @Ln_AppTotNonIvd_AMNT = L.AppTotNonIvd_AMNT,
                     @Ln_OweTotMedi_AMNT = L.OweTotMedi_AMNT,
                     @Ln_AppTotMedi_AMNT = L.AppTotMedi_AMNT,
                     @Ln_AppTotFuture_AMNT = L.AppTotFuture_AMNT
                FROM LSUP_Y1 L
               WHERE L.Case_IDNO = @Ln_ObleCur_Case_IDNO
                 AND L.OrderSeq_NUMB = @Ln_ObleCur_OrderSeq_NUMB
                 AND L.ObligationSeq_NUMB = @Ln_ObleCur_ObligationSeq_NUMB
                 AND L.SupportYearMonth_NUMB = @Ln_SupportYearMonth_NUMB
                 AND L.EventGlobalSeq_NUMB = (SELECT MAX(ML.EventGlobalSeq_NUMB)
                                                FROM LSUP_Y1 ML
                                               WHERE ML.Case_IDNO = L.Case_IDNO
                                                 AND ML.OrderSeq_NUMB = L.OrderSeq_NUMB
                                                 AND ML.ObligationSeq_NUMB = L.ObligationSeq_NUMB
                                                 AND ML.SupportYearMonth_NUMB = L.SupportYearMonth_NUMB);

              SET @Ln_RowCount_QNTY =@@ROWCOUNT;

              IF(@Ln_RowCount_QNTY = 0)
               BEGIN
                GOTO NEXT_FETCH;
               END
             END
           END

           SET @Lc_StatusChanged_CODE = @Lc_Yes_CODE;
           SET @Ln_ArrNaa_AMNT = @Ln_Zero_NUMB;
           SET @Ln_ArrPaa_AMNT = @Ln_Zero_NUMB;
           SET @Ln_ArrUda_AMNT = @Ln_Zero_NUMB;
           SET @Ln_TransactionNaa_AMNT = @Ln_Zero_NUMB;
           SET @Ln_TransactionPaa_AMNT = @Ln_Zero_NUMB;
           SET @Ln_TransactionUda_AMNT = @Ln_Zero_NUMB;
           SET @Ln_TransactionIvef_AMNT = @Ln_Zero_NUMB;
           SET @Ln_TransactionNffc_AMNT = @Ln_Zero_NUMB;
           SET @Ln_TransactionNonIvd_AMNT = @Ln_Zero_NUMB;
           SET @Ln_TransactionMedi_AMNT = @Ln_Zero_NUMB;

           IF (@Ls_OldMemberStatus_CODE = @Lc_WelfareTypeTanf_CODE)
            BEGIN
             IF (@Lc_TypeWelfare_CODE != @Lc_WelfareTypeTanf_CODE)
              BEGIN
               SET @Ln_AdjCsPaa_AMNT = @Ln_AdjCsPaa_AMNT + (@Ln_OweTotCurSup_AMNT * -1);
              END;

             IF(LEFT(@Lc_ObleCur_Fips_CODE, 2) != @Lc_InStateFips_CODE)
              BEGIN
               IF (@Lc_TypeWelfare_CODE IN (@Lc_WelfareTypeNonTanf_CODE, @Lc_WelfareTypeMedicaid_CODE))
                BEGIN
                 SET @Ln_AdjCsNaa_AMNT = @Ln_AdjCsNaa_AMNT + @Ln_OweTotCurSup_AMNT;
                END;
               ELSE IF (@Lc_TypeWelfare_CODE = @Lc_WelfareTypeNonIve_CODE)
                BEGIN
                 SET @Ln_AdjCsIvef_AMNT = @Ln_AdjCsIvef_AMNT + @Ln_OweTotCurSup_AMNT;
                END;
               ELSE IF (@Lc_TypeWelfare_CODE = @Lc_WelfareTypeFosterCare_CODE)
                BEGIN
                 SET @Ln_AdjCsNffc_AMNT = @Ln_AdjCsNffc_AMNT + @Ln_OweTotCurSup_AMNT;
                END;
               ELSE IF (@Lc_TypeWelfare_CODE = @Lc_WelfareTypeNonIvd_CODE)
                BEGIN
                 SET @Ln_AdjCsNonIvd_AMNT = @Ln_AdjCsNonIvd_AMNT + @Ln_OweTotCurSup_AMNT;
                END;
               ELSE
                BEGIN
                 IF (@Lc_TypeWelfare_CODE = @Lc_WelfareTypeTanf_CODE)
                  BEGIN
                   SET @Ln_ArrPaa_AMNT = @Ln_ArrPaa_AMNT + @Ln_AdjCsPaa_AMNT;
                  END;
                END

               SET @Ln_TransactionPaa_AMNT = @Ln_AdjCsPaa_AMNT;
               SET @Ln_TransactionNaa_AMNT = @Ln_AdjCsNaa_AMNT;
              END;
             ELSE IF (@Lc_TypeWelfare_CODE IN (@Lc_WelfareTypeNonTanf_CODE, @Lc_WelfareTypeMedicaid_CODE))
              BEGIN
               SET @Ln_AdjCsNaa_AMNT = @Ln_AdjCsNaa_AMNT + @Ln_OweTotCurSup_AMNT;
              END
             ELSE IF (@Lc_TypeWelfare_CODE = @Lc_WelfareTypeNonIve_CODE)
              BEGIN
               SET @Ln_AdjCsIvef_AMNT = @Ln_AdjCsIvef_AMNT + @Ln_OweTotCurSup_AMNT;
               SET @Ln_TransactionPaa_AMNT = @Ln_AdjCsPaa_AMNT;
               SET @Ln_TransactionNaa_AMNT = @Ln_AdjCsNaa_AMNT;
              END
             ELSE IF (@Lc_TypeWelfare_CODE = @Lc_WelfareTypeFosterCare_CODE)
              BEGIN
               SET @Ln_AdjCsNffc_AMNT = @Ln_AdjCsNffc_AMNT + @Ln_OweTotCurSup_AMNT;
               SET @Ln_TransactionPaa_AMNT = @Ln_AdjCsPaa_AMNT;
               SET @Ln_TransactionNaa_AMNT = @Ln_AdjCsNaa_AMNT;
              END
             ELSE IF(@Lc_TypeWelfare_CODE = @Lc_WelfareTypeNonIvd_CODE)
              BEGIN
               SET @Ln_AdjCsNonIvd_AMNT = @Ln_AdjCsNonIvd_AMNT + @Ln_OweTotCurSup_AMNT;
               SET @Ln_TransactionPaa_AMNT = @Ln_AdjCsPaa_AMNT;
               SET @Ln_TransactionNaa_AMNT = @Ln_AdjCsNaa_AMNT;
              END
             ELSE
              BEGIN
               IF (@Lc_TypeWelfare_CODE = @Lc_WelfareTypeTanf_CODE)
                BEGIN
                 SET @Ln_TransactionPaa_AMNT = @Ln_AdjCsPaa_AMNT;
                 SET @Ln_ArrPaa_AMNT = @Ln_OweTotPaa_AMNT - @Ln_AppTotPaa_AMNT;
                 SET @Ln_ArrPaa_AMNT = @Ln_ArrPaa_AMNT + @Ln_AdjCsPaa_AMNT;
                 SET @Ln_TransactionNaa_AMNT = @Ln_AdjCsNaa_AMNT;
                 SET @Ln_ArrNaa_AMNT = @Ln_OweTotNaa_AMNT - @Ln_AppTotNaa_AMNT + @Ln_AdjCsNaa_AMNT;
                END
              END
            END
           ELSE IF (@Ls_OldMemberStatus_CODE IN (@Lc_WelfareTypeNonTanf_CODE, @Lc_WelfareTypeMedicaid_CODE))
            BEGIN
             IF @Lc_TypeWelfare_CODE NOT IN (@Lc_WelfareTypeNonTanf_CODE, @Lc_WelfareTypeMedicaid_CODE)
              BEGIN
               SET @Ln_AdjCsNaa_AMNT = @Ln_AdjCsNaa_AMNT + (@Ln_OweTotCurSup_AMNT * -1);
              END
             ELSE
              BEGIN
               SET @Lc_NeverAssigned_TEXT = @Lc_No_CODE;
               SET @Ls_Sql_TEXT = ' SELECT_MHIS2 ';
               SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '') + ', MEMBER = ' + ISNULL(CAST(@An_MemberMci_IDNO AS VARCHAR), '') + ', Start_DATE = ' + ISNULL(CAST(@Ld_Start_DATE AS VARCHAR(10)), '');

               IF (EXISTS(SELECT 1
                            FROM MHIS_Y1 MH
                           WHERE MH.Case_IDNO = @An_Case_IDNO
                             AND MH.MemberMci_IDNO = @An_MemberMci_IDNO
                             AND MH.TypeWelfare_CODE = @Lc_WelfareTypeTanf_CODE
                             AND MH.Start_DATE < @Ld_Start_DATE
                             AND @Lc_TypeWelf_CODE != @Lc_WelfareTypeTanf_CODE))
                BEGIN
                 SET @Lc_NeverAssigned_TEXT = @Lc_No_CODE;
                END
               ELSE
                BEGIN
                 IF (@Lc_TypeWelf_CODE != @Lc_WelfareTypeTanf_CODE)
                  BEGIN
                   SET @Lc_NeverAssigned_TEXT = @Lc_Yes_CODE;
                  END
                 ELSE
                  BEGIN
                   SET @Lc_NeverAssigned_TEXT = @Lc_No_CODE;
                  END
                END

               SET @Ln_TransactionNaa_AMNT = @Ln_AdjCsNaa_AMNT;
               SET @Ln_ArrNaa_AMNT = @Ln_OweTotNaa_AMNT - @Ln_AppTotNaa_AMNT;
               SET @Ln_ArrNaa_AMNT = @Ln_ArrNaa_AMNT + @Ln_AdjCsNaa_AMNT;
               SET @Ln_ArrPaa_AMNT = @Ln_OweTotPaa_AMNT - @Ln_AppTotPaa_AMNT;

               IF (@Lc_NeverAssigned_TEXT = @Lc_Yes_CODE
                    OR LEFT(@Lc_ObleCur_Fips_CODE, 2) != @Lc_InStateFips_CODE)
                BEGIN
                 SET @Ln_TransactionPaa_AMNT = @Ln_AdjCsPaa_AMNT;
                 SET @Ln_ArrPaa_AMNT = @Ln_ArrPaa_AMNT + @Ln_AdjCsPaa_AMNT;
                END

               IF (@Ln_AdjCsPaa_AMNT <> @Ln_Zero_NUMB
                   AND @Lc_NeverAssigned_TEXT = @Lc_No_CODE
                   AND LEFT(@Lc_ObleCur_Fips_CODE, 2) = @Lc_InStateFips_CODE)
                BEGIN
                 SET @Ln_TransactionPaa_AMNT = @Ln_AdjCsPaa_AMNT;
                 SET @Ln_ArrPaa_AMNT = @Ln_ArrPaa_AMNT + @Ln_AdjCsPaa_AMNT;
                END
              END

             IF LEFT(@Lc_ObleCur_Fips_CODE, 2) != @Lc_InStateFips_CODE
              BEGIN
               IF @Lc_TypeWelfare_CODE = @Lc_WelfareTypeTanf_CODE
                BEGIN
                 SET @Ln_AdjCsPaa_AMNT = @Ln_AdjCsPaa_AMNT + @Ln_OweTotCurSup_AMNT;
                END
               ELSE IF @Lc_TypeWelfare_CODE = @Lc_WelfareTypeNonIve_CODE
                BEGIN
                 SET @Ln_AdjCsIvef_AMNT = @Ln_AdjCsIvef_AMNT + @Ln_OweTotCurSup_AMNT;
                END
               ELSE IF @Lc_TypeWelfare_CODE = @Lc_WelfareTypeFosterCare_CODE
                BEGIN
                 SET @Ln_AdjCsNffc_AMNT = @Ln_AdjCsNffc_AMNT + @Ln_OweTotCurSup_AMNT;
                END
               ELSE
                BEGIN
                 IF @Lc_TypeWelfare_CODE = @Lc_WelfareTypeNonIvd_CODE
                  BEGIN
                   SET @Ln_AdjCsNonIvd_AMNT = @Ln_AdjCsNonIvd_AMNT + @Ln_OweTotCurSup_AMNT;
                  END
                END

               SET @Ln_TransactionNaa_AMNT = @Ln_AdjCsNaa_AMNT;
               SET @Ln_TransactionPaa_AMNT = @Ln_AdjCsPaa_AMNT;
              END
             ELSE IF @Lc_TypeWelfare_CODE = @Lc_WelfareTypeTanf_CODE
              BEGIN
               SET @Ln_AdjCsPaa_AMNT = @Ln_AdjCsPaa_AMNT + @Ln_OweTotCurSup_AMNT;
              END
             ELSE IF @Lc_TypeWelfare_CODE = @Lc_WelfareTypeNonIve_CODE
              BEGIN
               SET @Ln_AdjCsIvef_AMNT = @Ln_AdjCsIvef_AMNT + @Ln_OweTotCurSup_AMNT;
               SET @Ln_TransactionNaa_AMNT = @Ln_AdjCsNaa_AMNT;
               SET @Ln_TransactionPaa_AMNT = @Ln_AdjCsPaa_AMNT;
              END
             ELSE IF @Lc_TypeWelfare_CODE = @Lc_WelfareTypeFosterCare_CODE
              BEGIN
               SET @Ln_AdjCsNffc_AMNT = @Ln_AdjCsNffc_AMNT + @Ln_OweTotCurSup_AMNT;
               SET @Ln_TransactionNaa_AMNT = @Ln_AdjCsNaa_AMNT;
               SET @Ln_TransactionPaa_AMNT = @Ln_AdjCsPaa_AMNT;
              END
             ELSE
              BEGIN
               IF @Lc_TypeWelfare_CODE = @Lc_WelfareTypeNonIvd_CODE
                BEGIN
                 SET @Ln_AdjCsNonIvd_AMNT = @Ln_AdjCsNonIvd_AMNT + @Ln_OweTotCurSup_AMNT;
                 SET @Ln_TransactionNaa_AMNT = @Ln_AdjCsNaa_AMNT;
                 SET @Ln_TransactionPaa_AMNT = @Ln_AdjCsPaa_AMNT;
                END
              END
            END
           ELSE IF (@Ls_OldMemberStatus_CODE = @Lc_WelfareTypeNonIve_CODE)
            BEGIN
             IF (@Lc_TypeWelfare_CODE != @Lc_WelfareTypeNonIve_CODE)
              BEGIN
               SET @Ln_AdjCsIvef_AMNT = @Ln_AdjCsIvef_AMNT + (@Ln_OweTotCurSup_AMNT * -1);
              END

             IF (@Lc_TypeWelfare_CODE = @Lc_WelfareTypeTanf_CODE)
              BEGIN
               SET @Ln_AdjCsPaa_AMNT = @Ln_AdjCsPaa_AMNT + @Ln_OweTotCurSup_AMNT;
              END
             ELSE IF (@Lc_TypeWelfare_CODE IN (@Lc_WelfareTypeNonTanf_CODE, @Lc_WelfareTypeMedicaid_CODE))
              BEGIN
               SET @Ln_AdjCsNaa_AMNT = @Ln_AdjCsNaa_AMNT + @Ln_OweTotCurSup_AMNT;
              END
             ELSE IF (@Lc_TypeWelfare_CODE = @Lc_WelfareTypeFosterCare_CODE)
              BEGIN
               SET @Ln_AdjCsNffc_AMNT = @Ln_AdjCsNffc_AMNT + @Ln_OweTotCurSup_AMNT;
              END
             ELSE
              BEGIN
               IF (@Lc_TypeWelfare_CODE = @Lc_WelfareTypeNonIvd_CODE)
                BEGIN
                 SET @Ln_AdjCsNonIvd_AMNT = @Ln_AdjCsNonIvd_AMNT + @Ln_OweTotCurSup_AMNT;
                END
              END

             SET @Ln_TransactionPaa_AMNT = @Ln_AdjCsPaa_AMNT;
             SET @Ln_TransactionNaa_AMNT = @Ln_AdjCsNaa_AMNT;
            END
           ELSE IF (@Ls_OldMemberStatus_CODE = @Lc_WelfareTypeFosterCare_CODE)
            BEGIN
             IF (@Lc_TypeWelfare_CODE != @Lc_WelfareTypeFosterCare_CODE)
              BEGIN
               SET @Ln_AdjCsNffc_AMNT = @Ln_AdjCsNffc_AMNT + (@Ln_OweTotCurSup_AMNT * -1);
              END

             IF (@Lc_TypeWelfare_CODE = @Lc_WelfareTypeTanf_CODE)
              BEGIN
               SET @Ln_AdjCsPaa_AMNT = @Ln_AdjCsPaa_AMNT + @Ln_OweTotCurSup_AMNT;
              END
             ELSE IF (@Lc_TypeWelfare_CODE IN (@Lc_WelfareTypeNonTanf_CODE, @Lc_WelfareTypeMedicaid_CODE))
              BEGIN
               SET @Ln_AdjCsNaa_AMNT = @Ln_AdjCsNaa_AMNT + @Ln_OweTotCurSup_AMNT;
              END
             ELSE IF (@Lc_TypeWelfare_CODE = @Lc_WelfareTypeNonIve_CODE)
              BEGIN
               SET @Ln_AdjCsIvef_AMNT = @Ln_AdjCsIvef_AMNT + @Ln_OweTotCurSup_AMNT;
              END
             ELSE IF @Lc_TypeWelfare_CODE = @Lc_WelfareTypeNonIvd_CODE
              BEGIN
               SET @Ln_AdjCsNonIvd_AMNT = @Ln_AdjCsNonIvd_AMNT + @Ln_OweTotCurSup_AMNT;
              END

             SET @Ln_TransactionPaa_AMNT = @Ln_AdjCsPaa_AMNT;
             SET @Ln_TransactionNaa_AMNT = @Ln_AdjCsNaa_AMNT;
            END
           ELSE
            BEGIN
             IF (@Ls_OldMemberStatus_CODE = @Lc_WelfareTypeNonIvd_CODE)
              BEGIN
               IF (@Lc_TypeWelfare_CODE != @Lc_WelfareTypeNonIvd_CODE)
                BEGIN
                 SET @Ln_AdjCsNonIvd_AMNT = @Ln_AdjCsNonIvd_AMNT + (@Ln_OweTotCurSup_AMNT * -1);
                END

               IF (@Lc_TypeWelfare_CODE = @Lc_WelfareTypeTanf_CODE)
                BEGIN
                 SET @Ln_AdjCsPaa_AMNT = @Ln_AdjCsPaa_AMNT + @Ln_OweTotCurSup_AMNT;
                END
               ELSE IF (@Lc_TypeWelfare_CODE IN (@Lc_WelfareTypeNonTanf_CODE, @Lc_WelfareTypeMedicaid_CODE))
                BEGIN
                 SET @Ln_AdjCsNaa_AMNT = @Ln_AdjCsNaa_AMNT + @Ln_OweTotCurSup_AMNT;
                END
               ELSE IF (@Lc_TypeWelfare_CODE = @Lc_WelfareTypeNonIve_CODE)
                BEGIN
                 SET @Ln_AdjCsIvef_AMNT = @Ln_AdjCsIvef_AMNT + @Ln_OweTotCurSup_AMNT;
                END
               ELSE IF (@Lc_TypeWelfare_CODE = @Lc_WelfareTypeFosterCare_CODE)
                BEGIN
                 SET @Ln_AdjCsNffc_AMNT = @Ln_AdjCsNffc_AMNT + @Ln_OweTotCurSup_AMNT;
                END

               SET @Ln_TransactionPaa_AMNT = @Ln_AdjCsPaa_AMNT;
               SET @Ln_TransactionNaa_AMNT = @Ln_AdjCsNaa_AMNT;
              END
            END

           IF (@Lc_TypeWelfare_CODE = @Lc_WelfareTypeTanf_CODE
               AND @Ls_OldMemberStatus_CODE != @Lc_WelfareTypeTanf_CODE
               AND LEFT(@Lc_ObleCur_Fips_CODE, 2) = @Lc_InStateFips_CODE)
            BEGIN
             SET @Ln_TransactionPaa_AMNT = @Ln_AdjCsPaa_AMNT;
             SET @Ln_ArrPaa_AMNT = @Ln_TransactionPaa_AMNT + (@Ln_OweTotPaa_AMNT - @Ln_AppTotPaa_AMNT);
             SET @Ln_TransactionNaa_AMNT = @Ln_AdjCsNaa_AMNT;
             SET @Ln_ArrNaa_AMNT = @Ln_AdjCsNaa_AMNT + (@Ln_OweTotNaa_AMNT - @Ln_AppTotNaa_AMNT);
            END

           IF (@Lc_TypeWelfare_CODE IN (@Lc_WelfareTypeNonTanf_CODE, @Lc_WelfareTypeMedicaid_CODE)
               AND @Ls_OldMemberStatus_CODE NOT IN (@Lc_WelfareTypeNonTanf_CODE, @Lc_WelfareTypeMedicaid_CODE)
               AND LEFT(@Lc_ObleCur_Fips_CODE, 2) = @Lc_InStateFips_CODE)
            BEGIN
             SET @Ln_TransactionNaa_AMNT = @Ln_AdjCsNaa_AMNT;
             SET @Ln_ArrNaa_AMNT = (@Ln_OweTotNaa_AMNT + @Ln_AdjCsNaa_AMNT) - @Ln_AppTotNaa_AMNT;
             SET @Ln_TransactionPaa_AMNT = @Ln_AdjCsPaa_AMNT;
             SET @Ln_ArrPaa_AMNT = @Ln_OweTotPaa_AMNT + @Ln_AdjCsPaa_AMNT - @Ln_AppTotPaa_AMNT;
            END

           SET @Ln_OweTotIvef_AMNT = @Ln_OweTotIvef_AMNT + @Ln_AdjCsIvef_AMNT;
           SET @Ln_OweTotNffc_AMNT = @Ln_OweTotNffc_AMNT + @Ln_AdjCsNffc_AMNT;
           SET @Ln_OweTotNonIvd_AMNT = @Ln_OweTotNonIvd_AMNT + @Ln_AdjCsNonIvd_AMNT;
           SET @Ln_OweTotMedi_AMNT = @Ln_OweTotMedi_AMNT + @Ln_TransactionMedi_AMNT;

           IF (YEAR(@Ld_OldStart_DATE) * 100 + MONTH(@Ld_OldStart_DATE)) = (YEAR(@Ad_Run_DATE) * 100 + MONTH(@Ad_Run_DATE))
            BEGIN
             IF @Lc_TypeWelfare_CODE IN (@Lc_WelfareTypeNonTanf_CODE, @Lc_WelfareTypeMedicaid_CODE)
              BEGIN
               SET @Ln_ArrNaa_AMNT = @Ln_ArrNaa_AMNT - (@Ln_OweTotCurSup_AMNT - @Ln_AppTotCurSup_AMNT);
              END
             ELSE IF @Lc_TypeWelfare_CODE = @Lc_WelfareTypeTanf_CODE
              BEGIN
               SET @Ln_ArrPaa_AMNT = @Ln_ArrPaa_AMNT - (@Ln_OweTotCurSup_AMNT - @Ln_AppTotCurSup_AMNT);
              END
            END

           IF (@Ln_ArrNaa_AMNT < @Ln_Zero_NUMB
                OR @Ln_ArrUda_AMNT < @Ln_Zero_NUMB
                OR @Ln_ArrPaa_AMNT < @Ln_Zero_NUMB)
            BEGIN
             /*TODO : need to look into */
             EXECUTE BATCH_COMMON$SP_CIRCULAR_RULE
              @An_ArrPaa_AMNT         = @Ln_ArrPaa_AMNT OUTPUT,
              @An_TransactionPaa_AMNT = @Ln_TransactionPaa_AMNT OUTPUT,
              @An_ArrUda_AMNT         = @Ln_ArrUda_AMNT OUTPUT,
              @An_TransactionUda_AMNT = @Ln_TransactionUda_AMNT OUTPUT,
              @An_ArrNaa_AMNT         = @Ln_ArrNaa_AMNT OUTPUT,
              @An_TransactionNaa_AMNT = @Ln_TransactionNaa_AMNT OUTPUT,
              @An_ArrCaa_AMNT         = @Ln_CirArrCaa_AMNT OUTPUT,
              @An_TransactionCaa_AMNT = @Ln_CirTransactionCaa_AMNT OUTPUT,
              @An_ArrUpa_AMNT         = @Ln_CirArrUpa_AMNT OUTPUT,
              @An_TransactionUpa_AMNT = @Ln_CirTransactionUpa_AMNT OUTPUT,
              @An_ArrTaa_AMNT         = @Ln_CirArrTaa_AMNT OUTPUT,
              @An_TransactionTaa_AMNT = @Ln_CirTransactionTaa_AMNT OUTPUT;
            END

           IF (@Ln_TransactionPaa_AMNT != @Ln_Zero_NUMB
                OR @Ln_TransactionUda_AMNT != @Ln_Zero_NUMB
                OR @Ln_TransactionNaa_AMNT != @Ln_Zero_NUMB
                OR @Ln_AdjCsNonIvd_AMNT != @Ln_Zero_NUMB
                OR @Ln_AdjCsIvef_AMNT != @Ln_Zero_NUMB
                OR @Ln_AdjCsNffc_AMNT != @Ln_Zero_NUMB
                OR @Ln_TransactionMedi_AMNT != @Ln_Zero_NUMB
                OR @Ls_OldMemberStatus_CODE <> @Lc_TypeWelfare_CODE)
            BEGIN
             SET @Ls_Sql_TEXT = 'INSERT_TMP_LOG_SUPPORT ';
             SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + ISNULL(CAST(@Ln_ObleCur_Case_IDNO AS VARCHAR), '') + ', OrderSeq_NUMB = ' + ISNULL(CAST(@Ln_ObleCur_OrderSeq_NUMB AS CHAR(4)), '') + ', ObligationSeq_NUMB = ' + ISNULL(CAST(@Ln_ObleCur_ObligationSeq_NUMB AS CHAR(4)), '') + ', TypeWelfare_CODE = ' + ISNULL(@Lc_TypeWelfare_CODE, '') + ', SupportYearMonth_NUMB = ' + ISNULL(CAST(@Ln_SupportYearMonth_NUMB AS VARCHAR(6)), '');

             INSERT @LsupTemp_T1
                    (Case_IDNO,
                     OrderSeq_NUMB,
                     ObligationSeq_NUMB,
                     SupportYearMonth_NUMB,
                     TypeWelfare_CODE,
                     MtdCurSupOwed_AMNT,
                     TransactionCurSup_AMNT,
                     OweTotCurSup_AMNT,
                     AppTotCurSup_AMNT,
                     TransactionExptPay_AMNT,
                     OweTotExptPay_AMNT,
                     AppTotExptPay_AMNT,
                     TransactionNaa_AMNT,
                     OweTotNaa_AMNT,
                     AppTotNaa_AMNT,
                     TransactionPaa_AMNT,
                     OweTotPaa_AMNT,
                     AppTotPaa_AMNT,
                     TransactionTaa_AMNT,
                     OweTotTaa_AMNT,
                     AppTotTaa_AMNT,
                     TransactionCaa_AMNT,
                     OweTotCaa_AMNT,
                     AppTotCaa_AMNT,
                     TransactionUpa_AMNT,
                     OweTotUpa_AMNT,
                     AppTotUpa_AMNT,
                     TransactionUda_AMNT,
                     OweTotUda_AMNT,
                     AppTotUda_AMNT,
                     TransactionIvef_AMNT,
                     OweTotIvef_AMNT,
                     AppTotIvef_AMNT,
                     TransactionNffc_AMNT,
                     OweTotNffc_AMNT,
                     AppTotNffc_AMNT,
                     TransactionNonIvd_AMNT,
                     OweTotNonIvd_AMNT,
                     AppTotNonIvd_AMNT,
                     TransactionMedi_AMNT,
                     OweTotMedi_AMNT,
                     AppTotMedi_AMNT,
                     TransactionFuture_AMNT,
                     AppTotFuture_AMNT,
                     EventGlobalSeq_NUMB)
             VALUES ( @Ln_ObleCur_Case_IDNO,--Case_IDNO
                      @Ln_ObleCur_OrderSeq_NUMB,--OrderSeq_NUMB
                      @Ln_ObleCur_ObligationSeq_NUMB,--ObligationSeq_NUMB
                      @Ln_SupportYearMonth_NUMB,--SupportYearMonth_NUMB
                      @Lc_TypeWelfare_CODE,--TypeWelfare_CODE
                      @Ln_Owed_DTYM,--MtdCurSupOwed_AMNT
                      @Ln_Zero_NUMB,--TransactionCurSup_AMNT
                      @Ln_OweTotCurSup_AMNT,--OweTotCurSup_AMNT
                      @Ln_AppTotCurSup_AMNT,--AppTotCurSup_AMNT
                      @Ln_Zero_NUMB,--TransactionExptPay_AMNT
                      @Ln_OweTotExptPay_AMNT,--OweTotExptPay_AMNT
                      @Ln_AppTotExptPay_AMNT,--AppTotExptPay_AMNT
                      @Ln_TransactionNaa_AMNT,--TransactionNaa_AMNT
                      @Ln_OweTotNaa_AMNT + @Ln_TransactionNaa_AMNT,--OweTotNaa_AMNT
                      @Ln_AppTotNaa_AMNT,--AppTotNaa_AMNT
                      @Ln_TransactionPaa_AMNT,--TransactionPaa_AMNT
                      @Ln_OweTotPaa_AMNT + @Ln_TransactionPaa_AMNT,--OweTotPaa_AMNT
                      @Ln_AppTotPaa_AMNT,--AppTotPaa_AMNT
                      0,--TransactionTaa_AMNT
                      @Ln_OweTotTaa_AMNT,--OweTotTaa_AMNT
                      @Ln_AppTotTaa_AMNT,--AppTotTaa_AMNT
                      0,--TransactionCaa_AMNT
                      @Ln_OweTotCaa_AMNT,--OweTotCaa_AMNT
                      @Ln_AppTotCaa_AMNT,--AppTotCaa_AMNT
                      0,--TransactionUpa_AMNT
                      @Ln_OweTotUpa_AMNT,--OweTotUpa_AMNT
                      @Ln_AppTotUpa_AMNT,--AppTotUpa_AMNT
                      @Ln_TransactionUda_AMNT,--TransactionUda_AMNT
                      @Ln_OweTotUda_AMNT + @Ln_TransactionUda_AMNT,--OweTotUda_AMNT
                      @Ln_AppTotUda_AMNT,--AppTotUda_AMNT
                      @Ln_AdjCsIvef_AMNT,--TransactionIvef_AMNT
                      @Ln_OweTotIvef_AMNT,--OweTotIvef_AMNT
                      @Ln_AppTotIvef_AMNT,--AppTotIvef_AMNT
                      @Ln_AdjCsNffc_AMNT,--TransactionNffc_AMNT
                      @Ln_OweTotNffc_AMNT,--OweTotNffc_AMNT
                      @Ln_AppTotNffc_AMNT,--AppTotNffc_AMNT
                      @Ln_AdjCsNonIvd_AMNT,--TransactionNonIvd_AMNT
                      @Ln_OweTotNonIvd_AMNT,--OweTotNonIvd_AMNT
                      @Ln_AppTotNonIvd_AMNT,--AppTotNonIvd_AMNT
                      @Ln_Zero_NUMB,--TransactionMedi_AMNT
                      @Ln_OweTotMedi_AMNT,--OweTotMedi_AMNT
                      @Ln_AppTotMedi_AMNT,--AppTotMedi_AMNT
                      @Ln_Zero_NUMB,--TransactionFuture_AMNT
                      @Ln_AppTotFuture_AMNT,--AppTotFuture_AMNT
                      @Ln_ProcessCount_QNTY); --EventGlobalSeq_NUMB
            END
          END

         NEXT_FETCH:;

         SET @Ld_OldStart_DATE = DATEADD(m, 1, @Ld_OldStart_DATE);

         IF (YEAR(@Ld_OldStart_DATE) * 100 + MONTH(@Ld_OldStart_DATE)) = (YEAR(@Ad_Run_DATE) * 100 + MONTH(@Ad_Run_DATE))
          BEGIN
           SET @Ld_OldStart_DATE = @Ad_Run_DATE;
          END
        END

       NEXT_REC:;

       FETCH NEXT FROM ObleCur INTO @Ln_ObleCur_Case_IDNO, @Ln_ObleCur_OrderSeq_NUMB, @Ln_ObleCur_ObligationSeq_NUMB, @Lc_ObleCur_TypeDebt_CODE, @Lc_ObleCur_Fips_CODE;

       SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;
      END

     CLOSE ObleCur;

     DEALLOCATE ObleCur;

     SET @Ln_ProcessCount_QNTY = @Ln_ProcessCount_QNTY + 1;
    END

   INSERT LSUP_Y1
          (Case_IDNO,
           OrderSeq_NUMB,
           ObligationSeq_NUMB,
           SupportYearMonth_NUMB,
           TypeWelfare_CODE,
           TransactionCurSup_AMNT,
           OweTotCurSup_AMNT,
           AppTotCurSup_AMNT,
           MtdCurSupOwed_AMNT,
           TransactionExptPay_AMNT,
           OweTotExptPay_AMNT,
           AppTotExptPay_AMNT,
           TransactionNaa_AMNT,
           OweTotNaa_AMNT,
           AppTotNaa_AMNT,
           TransactionPaa_AMNT,
           OweTotPaa_AMNT,
           AppTotPaa_AMNT,
           TransactionTaa_AMNT,
           OweTotTaa_AMNT,
           AppTotTaa_AMNT,
           TransactionCaa_AMNT,
           OweTotCaa_AMNT,
           AppTotCaa_AMNT,
           TransactionUpa_AMNT,
           OweTotUpa_AMNT,
           AppTotUpa_AMNT,
           TransactionUda_AMNT,
           OweTotUda_AMNT,
           AppTotUda_AMNT,
           TransactionIvef_AMNT,
           OweTotIvef_AMNT,
           AppTotIvef_AMNT,
           TransactionMedi_AMNT,
           OweTotMedi_AMNT,
           AppTotMedi_AMNT,
           TransactionFuture_AMNT,
           AppTotFuture_AMNT,
           TransactionNffc_AMNT,
           OweTotNffc_AMNT,
           AppTotNffc_AMNT,
           TransactionNonIvd_AMNT,
           OweTotNonIvd_AMNT,
           AppTotNonIvd_AMNT,
           Batch_DATE,
           SourceBatch_CODE,
           Batch_NUMB,
           SeqReceipt_NUMB,
           Receipt_DATE,
           Distribute_DATE,
           TypeRecord_CODE,
           EventFunctionalSeq_NUMB,
           EventGlobalSeq_NUMB,
           CheckRecipient_CODE,
           CheckRecipient_ID)
   (SELECT a.Case_IDNO,
           a.OrderSeq_NUMB,
           a.ObligationSeq_NUMB,
           a.SupportYearMonth_NUMB,
           a.TypeWelfare_CODE,
           STL.TransactionCurSup_AMNT,
           a.OweTotCurSup_AMNT,
           a.AppTotCurSup_AMNT,
           a.MtdCurSupOwed_AMNT,
           a.TransactionExptPay_AMNT,
           a.OweTotExptPay_AMNT,
           a.AppTotExptPay_AMNT,
           STL.TransactionNaa_AMNT,
           a.OweTotNaa_AMNT,
           a.AppTotNaa_AMNT,
           STL.TransactionPaa_AMNT,
           a.OweTotPaa_AMNT,
           a.AppTotPaa_AMNT,
           STL.TransactionTaa_AMNT,
           a.OweTotTaa_AMNT,
           a.AppTotTaa_AMNT,
           STL.TransactionCaa_AMNT,
           a.OweTotCaa_AMNT,
           a.AppTotCaa_AMNT,
           STL.TransactionUpa_AMNT,
           a.OweTotUpa_AMNT,
           a.AppTotUpa_AMNT,
           STL.TransactionUda_AMNT,
           a.OweTotUda_AMNT,
           a.AppTotUda_AMNT,
           STL.TransactionIvef_AMNT,
           a.OweTotIvef_AMNT,
           a.AppTotIvef_AMNT,
           STL.TransactionMedi_AMNT,
           a.OweTotMedi_AMNT,
           a.AppTotMedi_AMNT,
           a.TransactionFuture_AMNT,
           a.AppTotFuture_AMNT,
           STL.TransactionNffc_AMNT,
           a.OweTotNffc_AMNT,
           a.AppTotNffc_AMNT,
           STL.TransactionNonIvd_AMNT,
           a.OweTotNonIvd_AMNT,
           a.AppTotNonIvd_AMNT,
           @Ld_Low_DATE AS Batch_DATE,
           @Lc_Space_TEXT AS SourceBatch_CODE,
           @Ln_Zero_NUMB AS Batch_NUMB,
           @Ln_Zero_NUMB AS SeqReceipt_NUMB,
           @Ld_Low_DATE AS Receipt_DATE,
           @Ad_Run_DATE AS Distribute_DATE,
           @Lc_Space_TEXT AS TypeRecord_CODE,
           1080 AS EventFunctionalSeq_NUMB,
           @An_EventGlobalSeq_NUMB AS EventGlobalSeq_NUMB,
           @Lc_Space_TEXT AS CheckRecipient_CODE,
           @Lc_Space_TEXT AS CheckRecipient_ID
      FROM @LsupTemp_T1 a
           JOIN (SELECT TL.Case_IDNO,
                        TL.OrderSeq_NUMB,
                        TL.ObligationSeq_NUMB,
                        TL.SupportYearMonth_NUMB,
                        SUM(TL.TransactionCurSup_AMNT) AS TransactionCurSup_AMNT,
                        SUM(TL.TransactionNaa_AMNT) AS TransactionNaa_AMNT,
                        SUM(TL.TransactionPaa_AMNT) AS TransactionPaa_AMNT,
                        SUM(TL.TransactionTaa_AMNT) AS TransactionTaa_AMNT,
                        SUM(TL.TransactionCaa_AMNT) AS TransactionCaa_AMNT,
                        SUM(TL.TransactionUpa_AMNT) AS TransactionUpa_AMNT,
                        SUM(TL.TransactionUda_AMNT) AS TransactionUda_AMNT,
                        SUM(TL.TransactionIvef_AMNT) AS TransactionIvef_AMNT,
                        SUM(TL.TransactionMedi_AMNT) AS TransactionMedi_AMNT,
                        SUM(TL.TransactionNffc_AMNT) AS TransactionNffc_AMNT,
                        SUM(TL.TransactionNonIvd_AMNT) AS TransactionNonIvd_AMNT
                   FROM @LsupTemp_T1 TL
                  GROUP BY TL.Case_IDNO,
                           TL.OrderSeq_NUMB,
                           TL.ObligationSeq_NUMB,
                           TL.SupportYearMonth_NUMB) AS STL
            ON a.Case_IDNO = STL.Case_IDNO
               AND a.OrderSeq_NUMB = STL.OrderSeq_NUMB
               AND a.ObligationSeq_NUMB = STL.ObligationSeq_NUMB
               AND a.SupportYearMonth_NUMB = STL.SupportYearMonth_NUMB
     WHERE a.EventGlobalSeq_NUMB = (SELECT MAX(MEV.EventGlobalSeq_NUMB)
                                      FROM @LsupTemp_T1 MEV
                                     WHERE MEV.Case_IDNO = a.Case_IDNO
                                       AND MEV.OrderSeq_NUMB = a.OrderSeq_NUMB
                                       AND MEV.ObligationSeq_NUMB = a.ObligationSeq_NUMB
                                       AND MEV.SupportYearMonth_NUMB = a.SupportYearMonth_NUMB));

   DELETE FROM @LsupTemp_T1;

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   IF CURSOR_STATUS ('local', 'ObleCur') IN (0, 1)
    BEGIN
     CLOSE ObleCur;

     DEALLOCATE ObleCur;
    END

   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

   IF @Ln_Error_NUMB = 50001
    BEGIN
     EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
      @As_Procedure_NAME        = @Ls_Procedure_NAME,
      @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
      @As_Sql_TEXT              = @Ls_Sql_TEXT,
      @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
      @An_Error_NUMB            = @Ln_Error_NUMB,
      @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
      @As_DescriptionError_TEXT = @Ls_ErrorDescription_TEXT OUTPUT;
    END
   ELSE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);

     EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
      @As_Procedure_NAME        = @Ls_Procedure_NAME,
      @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
      @As_Sql_TEXT              = @Ls_Sql_TEXT,
      @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
      @An_Error_NUMB            = @Ln_Error_NUMB,
      @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
      @As_DescriptionError_TEXT = @Ls_ErrorDescription_TEXT OUTPUT;
    END

   SET @As_DescriptionError_TEXT = @Ls_ErrorDescription_TEXT;
  END CATCH
 END


GO
