/****** Object:  StoredProcedure [dbo].[BATCH_COMMON_PRORATE_GRANT$SP_GRANT_SPLIT_IVMG]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name   : BATCH_COMMON_PRORATE_GRANT$SP_GRANT_SPLIT_IVMG
Programmer Name  : IMP Team
Description      :
Frequency        :
Developed On     : 4/12/2011
Called By        : None
Called On        : BATCH_COMMON_PRORATE_GRANT$SP_PRORATE_IVA_GRANT,BATCH_COMMON$SP_REASSIGN_ARREARS
------------------------------------------------------------------------------------------------------------------------
Modified By      :
Modified On      :
Version No       : 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_COMMON_PRORATE_GRANT$SP_GRANT_SPLIT_IVMG]
 @An_CaseWelfare_IDNO      NUMERIC(10),
 @An_CpMci_IDNO            NUMERIC(10),
 @An_WelfareYearMonth_NUMB NUMERIC(6),
 @Ac_SignedOnWorker_ID     CHAR(30),
 @Ad_Run_DATE              DATE,
 @Ac_Job_ID				   CHAR(7)= '',
 @Ac_Msg_CODE              CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
 BEGIN
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

  CREATE TABLE #TPRCP_P2
   (
     Seq_IDNO              NUMERIC(19),
     MemberMci_IDNO        NUMERIC(10),
     Case_IDNO             NUMERIC(6),
     OrderSeq_NUMB         NUMERIC(2),
     ObligationSeq_NUMB    NUMERIC(2),
     TypeBucket_CODE       CHAR(5),
     CaseWelfare_IDNO      NUMERIC(10),
     ArrPaid_AMNT          NUMERIC(11, 2),
     ArrRecoup_AMNT        NUMERIC(11, 2),
     Rounded_AMNT          NUMERIC(11, 2),
     RoundedRecoup_AMNT    NUMERIC(11, 2),
     ArrToBePaid_AMNT      NUMERIC(11, 2),
     ArrPaidMtd_AMNT       NUMERIC(11, 2),
     ArrRecoupMtd_AMNT     NUMERIC(11, 2),
     ArrPaidUrg_AMNT       NUMERIC(11, 2),
     ArrPaidMtdUrg_AMNT    NUMERIC(11, 2),
     SupportYearMonth_NUMB NUMERIC (6)
   );

  SET @Ad_Run_DATE = ISNULL (@Ad_Run_DATE, dbo.BATCH_COMMON_SCALAR$SF_TRUNC_DATETIME (dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME()));

  DECLARE @Lc_DateFormatYyyymm_TEXT CHAR(6) = 'YYYYMM',
          @Lc_NO_INDC               CHAR (1) = 'N',
          @Ln_Error_NUMB            NUMERIC(11),
          @Ln_ErrorLine_NUMB        NUMERIC(11),
          @Lc_StatusFailed_CODE     CHAR(1) = 'F',
          @Ld_High_DATE             DATE = '12/31/9999',
          @Lc_WelfareTypeTanf_CODE  CHAR (1) = 'A',
          @Lc_StatusSuccess_CODE    CHAR(1) = 'S',
          @Lc_Grantivmg_ID          CHAR (3) = 'GSI',
		  @Lc_Process_ID			CHAR(10) = '',
          @Ls_Sql_TEXT              VARCHAR(100),
          @Ls_Sqldata_TEXT          VARCHAR(1000),
          @Ls_Procedure_NAME        VARCHAR(100) = 'BATCH_COMMON_PRORATE_GRANT$SP_GRANT_SPLIT_IVMG';
  DECLARE @Ln_EventGlobalSeq_NUMB          NUMERIC(19),
          @Ld_Start_DATE                   DATE,
          @Ln_IvmgAdjust_AMNT              NUMERIC (11, 2) = 0,
          @Ln_SupportYearMonth_NUMB        NUMERIC (6),
          @Ln_CaseWelfare_IDNO             NUMERIC(10),
          @Ln_IvmgPrior_AMNT               NUMERIC (11, 2) =0,
          @Ln_MtdAssistExpend_AMNT         NUMERIC(11, 2) = 0,
          @Ln_LtdAssistExpend_AMNT         NUMERIC(11, 2) = 0,
          @Ln_LtdAssistWemoRecoup_AMNT     NUMERIC (11, 2)= 0,
          @Ln_MtdAssistWemoRecoup_AMNT     NUMERIC (11, 2) = 0,
          @Ln_IvmgRecoup_AMNT              NUMERIC (11, 2) = 0,
          @Ln_AdjustRecoup_AMNT            NUMERIC (11, 2) = 0,
          @Ln_LtdAssistExpandWemo_AMNT     NUMERIC (11, 2) = 0,
          @Ln_TransactionAssistExpend_AMNT NUMERIC(11, 2) = 0,
          @Ln_MtdPrevIvmg_AMNT             NUMERIC (11, 2) = 0,
          @Ln_MtdPrevRecoup_AMNT           NUMERIC (11, 2) = 0,
          @Ln_ExpandPrior_AMNT             NUMERIC (11, 2) = 0,
          @Ln_RecoupPrior_AMNT             NUMERIC (11, 2) = 0,
          @Lc_Process_INDC                 CHAR(1),
          @Ln_Latest_DTYM                  NUMERIC (6) = 0,
          @Ln_LtdUrg_AMNT                  NUMERIC (11, 2) = 0,
          @Ln_MtdUrg_AMNT                  NUMERIC (11, 2) = 0,
          @Ln_MemberMtd_QNTY               NUMERIC (10) = 0,
          @Ld_Run_DATE                     DATE = ISNULL (@Ad_Run_DATE, dbo.BATCH_COMMON_SCALAR$SF_TRUNC_DATETIME (dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME())),
          @Ls_ErrorMessage_TEXT            VARCHAR(4000),
          @Lc_Msg_CODE                     CHAR(1),
          @Ln_RowCount_QNTY                SMALLINT;
  DECLARE @Low_QNTY         NUMERIC (5) = 0,
          @Low_Current_NUMB NUMERIC (5) = 1;
  DECLARE @Ln_Case_IDNO          NUMERIC(6),
          @Ln_MemberMci_IDNO     NUMERIC(10),
          @Ln_OrderSeq_NUMB      NUMERIC(2),
          @Ln_ObligationSeq_NUMB NUMERIC(2),
          @Ln_ArrPaid_AMNT       NUMERIC(11, 2),
          @Ln_ArrRecoup_AMNT     NUMERIC(11, 2),
          @Ln_ArrPaidMtd_AMNT    NUMERIC(11, 2),
          @Ln_ArrRecoupMtd_AMNT  NUMERIC(11, 2),
          @Ln_ArrPaidUrg_AMNT    NUMERIC(11, 2),
          @Ln_ArrPaidMtdUrg_AMNT NUMERIC(11, 2);
  DECLARE @WemoCur_P1 TABLE (
   Case_IDNO          NUMERIC(6) NOT NULL,
   OrderSeq_NUMB      NUMERIC(2) NOT NULL,
   ObligationSeq_NUMB NUMERIC(2) NOT NULL,
   CaseWelfare_IDNO   NUMERIC(10) NOT NULL,
   ArrPaid_AMNT       NUMERIC(11, 2) NOT NULL,
   ArrRecoup_AMNT     NUMERIC(11, 2) NOT NULL,
   ArrPaidMtd_AMNT    NUMERIC(11, 2) NOT NULL,
   ArrRecoupMtd_AMNT  NUMERIC(11, 2) NOT NULL,
   ArrPaidUrg_AMNT    NUMERIC(11, 2) NOT NULL,
   ArrPaidMtdUrg_AMNT NUMERIC(11, 2) NOT NULL,
   ROW_NUMB           NUMERIC (19));
  DECLARE @LsupCur_P1 TABLE (
   Case_IDNO             NUMERIC(6) NOT NULL,
   OrderSeq_NUMB         NUMERIC(2) NOT NULL,
   ObligationSeq_NUMB    NUMERIC(2) NOT NULL,
   SupportYearMonth_NUMB NUMERIC (6),
   ROW_NUMB              NUMERIC (19));

  BEGIN TRY
   SELECT @Ac_Msg_CODE = '',
          @As_DescriptionError_TEXT = '',
          @Ls_Sql_TEXT = '',
          @Ls_Sqldata_TEXT = '',
          @Ls_ErrorMessage_TEXT = ''

   SET @Ln_CaseWelfare_IDNO = @An_CaseWelfare_IDNO;
   SET @Ln_SupportYearMonth_NUMB = @An_WelfareYearMonth_NUMB;
   SET @Ln_MemberMci_IDNO = @An_CpMci_IDNO

   -- IVA Updates need to use effetive date instead of Sysdate - Starts
   IF @An_WelfareYearMonth_NUMB = dbo.BATCH_COMMON_SCALAR$SF_TO_CHAR_DATE (@Ld_Run_DATE, @Lc_DateFormatYyyymm_TEXT)
    BEGIN
     SET @Ld_Start_DATE = @Ld_Run_DATE;
    END
   ELSE
    BEGIN
     SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_LAST_DAY (dbo.BATCH_COMMON_SCALAR$SF_TO_DATE2 (CAST (@An_WelfareYearMonth_NUMB AS NVARCHAR (4000)), @Lc_DateFormatYyyymm_TEXT));
    END

   SET @Lc_Process_ID = @Lc_Grantivmg_ID + @Ac_Job_ID;
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GENERATE_SEQ';
   SET @Ls_Sqldata_TEXT = '@as_id_process = ' + @Lc_Grantivmg_ID
      
   EXECUTE BATCH_COMMON$SP_GENERATE_SEQ
    @An_EventFunctionalSeq_NUMB = 2750,
    @Ac_Process_ID              = @Lc_Process_ID,
    -- IVA Updates need to use effetive date instead of Sysdate - Starts
    @Ad_EffectiveEvent_DATE     = @Ld_Run_DATE,
    -- Ends
    @Ac_Note_INDC               = @Lc_NO_INDC,
    @Ac_Worker_ID               = @Ac_SignedOnWorker_ID,
    @An_EventGlobalSeq_NUMB     = @Ln_EventGlobalSeq_NUMB OUTPUT,
    @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT   = @Ls_ErrorMessage_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GENERATE_SEQ FAILED';

     RAISERROR (50001,16,1);
    END;

   DELETE FROM #TPRCP_P1;

   DELETE FROM @WemoCur_P1;

   -- Modified the follwing code to pick the latest month from WEMO or from IVMG or use the passed month
   SET @Ls_Sql_TEXT = 'SELECT_VWEMO MONTH WELFARE';
   SET @Ls_Sqldata_TEXT = ' CaseWelfare_IDNO  ' + ISNULL (CAST(@Ln_CaseWelfare_IDNO AS VARCHAR), '')

   SELECT @Ln_Latest_DTYM = ISNULL(MAX (w.WelfareYearMonth_NUMB), 0)
     FROM WEMO_Y1 AS w
    WHERE w.CaseWelfare_IDNO = @Ln_CaseWelfare_IDNO
      AND w.EndValidity_DATE = @Ld_High_DATE;

   IF @Ln_Latest_DTYM = 0
    BEGIN
     SET @Ls_Sql_TEXT = 'SELECT_IVMG_Y1 MONTH WELFARE';
     SET @Ls_Sqldata_TEXT = ' CaseWelfare_IDNO  ' + ISNULL (CAST(@Ln_CaseWelfare_IDNO AS VARCHAR), '')

     SELECT @Ln_Latest_DTYM = ISNULL(MAX (i.WelfareYearMonth_NUMB), 0)
       FROM IVMG_Y1 AS i
      WHERE i.CaseWelfare_IDNO = @Ln_CaseWelfare_IDNO
        AND i.CpMci_IDNO = @Ln_MemberMci_IDNO
        AND i.WelfareElig_CODE = @Lc_WelfareTypeTanf_CODE;

     IF @Ln_Latest_DTYM = 0
      BEGIN
       SET @Ln_Latest_DTYM = @Ln_SupportYearMonth_NUMB;
      END
    END;

   IF @Ln_Latest_DTYM < @Ln_SupportYearMonth_NUMB
    BEGIN
     SET @Ln_Latest_DTYM = @Ln_SupportYearMonth_NUMB;
    END

   WHILE @Ln_SupportYearMonth_NUMB <= @Ln_Latest_DTYM
    BEGIN
     BEGIN
      SET @Ln_ExpandPrior_AMNT = 0;
      SET @Ln_RecoupPrior_AMNT = 0;
      SET @Ln_IvmgAdjust_AMNT = 0;
      SET @Ln_AdjustRecoup_AMNT = 0;
      SET @Ls_Sql_TEXT = 'SELECT_IVMG_Y1';
      SET @Ls_Sqldata_TEXT = ' CaseWelfare_IDNO  ' + ISNULL (CAST(@Ln_CaseWelfare_IDNO AS VARCHAR), '') + '  WelfareYearMonth_NUMB  ' + ISNULL (CAST (@Ln_SupportYearMonth_NUMB AS VARCHAR), '');

      SELECT @Ln_ExpandPrior_AMNT = a.LtdAssistExpend_AMNT - a.MtdAssistExpend_AMNT,
             @Ln_RecoupPrior_AMNT = a.LtdAssistRecoup_AMNT - a.MtdAssistRecoup_AMNT,
             @Ln_IvmgAdjust_AMNT = a.MtdAssistExpend_AMNT,
             @Ln_AdjustRecoup_AMNT = a.MtdAssistRecoup_AMNT
        FROM IVMG_Y1 AS a
       WHERE a.CaseWelfare_IDNO = @Ln_CaseWelfare_IDNO
         AND a.CpMci_IDNO = @Ln_MemberMci_IDNO
         AND a.WelfareElig_CODE = @Lc_WelfareTypeTanf_CODE
         AND a.WelfareYearMonth_NUMB = @Ln_SupportYearMonth_NUMB
         AND a.EventGlobalSeq_NUMB = (SELECT MAX (b.EventGlobalSeq_NUMB) AS expr
                                        FROM IVMG_Y1 AS b
                                       WHERE b.CaseWelfare_IDNO = a.CaseWelfare_IDNO
                                         AND b.CpMci_IDNO = a.CpMci_IDNO
                                         AND b.WelfareElig_CODE = @Lc_WelfareTypeTanf_CODE
                                         AND b.WelfareYearMonth_NUMB = a.WelfareYearMonth_NUMB);

      SET @Ln_RowCount_QNTY = @@ROWCOUNT;

      IF @Ln_RowCount_QNTY = 0
       BEGIN
        SET @Ls_Sql_TEXT = 'SELECT_IVMG_Y1 1';
        SET @Ls_Sqldata_TEXT = ' CaseWelfare_IDNO  ' + ISNULL (CAST(@Ln_CaseWelfare_IDNO AS VARCHAR), '') + '  WelfareYearMonth_NUMB  ' + ISNULL (CAST (@Ln_SupportYearMonth_NUMB AS VARCHAR), '');

        SELECT @Ln_ExpandPrior_AMNT = a.LtdAssistExpend_AMNT,
               @Ln_RecoupPrior_AMNT = a.LtdAssistRecoup_AMNT
          FROM IVMG_Y1 AS a
         WHERE a.CaseWelfare_IDNO = @Ln_CaseWelfare_IDNO
           AND a.CpMci_IDNO = @Ln_MemberMci_IDNO
           AND a.WelfareElig_CODE = @Lc_WelfareTypeTanf_CODE
           AND a.WelfareYearMonth_NUMB = (SELECT MAX (b.WelfareYearMonth_NUMB) AS expr
                                            FROM IVMG_Y1 AS b
                                           WHERE b.CaseWelfare_IDNO = @Ln_CaseWelfare_IDNO
                                             AND b.CpMci_IDNO = a.CpMci_IDNO
                                             AND b.WelfareElig_CODE = @Lc_WelfareTypeTanf_CODE
                                             AND b.WelfareYearMonth_NUMB <= @Ln_SupportYearMonth_NUMB)
           AND a.EventGlobalSeq_NUMB = (SELECT MAX (b.EventGlobalSeq_NUMB) AS expr
                                          FROM IVMG_Y1 AS b
                                         WHERE b.CaseWelfare_IDNO = a.CaseWelfare_IDNO
                                           AND b.CpMci_IDNO = a.CpMci_IDNO
                                           AND b.WelfareElig_CODE = @Lc_WelfareTypeTanf_CODE
                                           AND b.WelfareYearMonth_NUMB = a.WelfareYearMonth_NUMB);

        SET @Ln_RowCount_QNTY = @@ROWCOUNT;

        IF @Ln_RowCount_QNTY = 0
         BEGIN
          GOTO Next_Fetch
         END

        SET @Ln_LtdUrg_AMNT = @Ln_ExpandPrior_AMNT - @Ln_RecoupPrior_AMNT;
        SET @Ln_MtdUrg_AMNT = 0;
        SET @Ln_ExpandPrior_AMNT = @Ln_RecoupPrior_AMNT;
       END
      ELSE
       BEGIN
        SET @Ln_LtdUrg_AMNT = @Ln_ExpandPrior_AMNT - @Ln_RecoupPrior_AMNT;
        SET @Ln_MtdUrg_AMNT = @Ln_IvmgAdjust_AMNT - @Ln_AdjustRecoup_AMNT;
        SET @Ln_ExpandPrior_AMNT = @Ln_RecoupPrior_AMNT;
        SET @Ln_IvmgAdjust_AMNT = @Ln_AdjustRecoup_AMNT;
       END
     END

     SET @Lc_Process_INDC = @Lc_NO_INDC
     SET @Ls_Sql_TEXT = 'BATCH_COMMON_PRORATE_GRANT$SP_PRORATE_IVA_GRANT '
     SET @Ls_Sqldata_TEXT = '@An_CaseWelfare_IDNO = ' + CAST(@Ln_CaseWelfare_IDNO AS VARCHAR) + ' @ad_dt_start = ' + CAST (@Ld_Start_DATE AS VARCHAR) + ' @Ln_SupportYearMonth_NUMB = ' + CAST (@Ln_SupportYearMonth_NUMB AS VARCHAR)

     EXECUTE BATCH_COMMON_PRORATE_GRANT$SP_PRORATE_IVA_GRANT
      @An_CaseWelfare_IDNO      = @Ln_CaseWelfare_IDNO,
      @An_CpMci_IDNO            = @Ln_MemberMci_IDNO,
      @Ad_Start_DATE            = @Ld_Start_DATE,
      @An_WelfareYearMonth_NUMB = @Ln_SupportYearMonth_NUMB,
      @An_LtdExpend_AMNT        = @Ln_ExpandPrior_AMNT OUTPUT,
      @An_LtdRecoup_AMNT        = @Ln_RecoupPrior_AMNT OUTPUT,
      @An_LtdUrg_AMNT           = @Ln_LtdUrg_AMNT OUTPUT,
      @An_MtdExpend_AMNT        = @Ln_IvmgAdjust_AMNT OUTPUT,
      @An_MtdRecoup_AMNT        = @Ln_AdjustRecoup_AMNT OUTPUT,
      @An_MtdUrg_AMNT           = @Ln_MtdUrg_AMNT OUTPUT,
      -- IVA Updates need to use effetive date instead of Sysdate - Starts
      @Ad_Run_DATE              = @Ld_Run_DATE,
      -- Ends
      @Ac_Process_INDC          = @Lc_Process_INDC OUTPUT,
      @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       SET @Ls_Sql_TEXT = 'BATCH_COMMON_PRORATE_GRANT$SP_PRORATE_IVA_GRANT  FAILED'

       RAISERROR (50001,16,1)
      END

     IF @Lc_Process_INDC = @Lc_NO_INDC
      BEGIN
       GOTO Next_Fetch
      END

     DELETE FROM @WemoCur_P1;

     SET @Ls_Sql_TEXT = 'INSERT INTO @WemoCur_P1';

     INSERT INTO @WemoCur_P1
                 (Case_IDNO,
                  OrderSeq_NUMB,
                  ObligationSeq_NUMB,
                  CaseWelfare_IDNO,
                  ArrPaid_AMNT,
                  ArrRecoup_AMNT,
                  ArrPaidMtd_AMNT,
                  ArrRecoupMtd_AMNT,
                  ArrPaidUrg_AMNT,
                  ArrPaidMtdUrg_AMNT,
                  ROW_NUMB)
     SELECT a.Case_IDNO,
            a.OrderSeq_NUMB,
            a.ObligationSeq_NUMB,
            a.CaseWelfare_IDNO,
            ISNULL (SUM (a.ArrPaid_AMNT), 0) AS ArrPaid_AMNT,
            ISNULL (SUM (a.ArrRecoup_AMNT), 0) AS ArrRecoup_AMNT,
            ISNULL (SUM (a.ArrPaidMtd_AMNT), 0) AS ArrPaidMtd_AMNT,
            ISNULL (SUM (a.ArrRecoupMtd_AMNT), 0) AS ArrRecoupMtd_AMNT,
            ISNULL (SUM (a.ArrPaidUrg_AMNT), 0) AS ArrPaidUrg_AMNT,
            ISNULL (SUM (a.ArrPaidMtdUrg_AMNT), 0) AS ArrPaidMtdUrg_AMNT,
            ROW_NUMBER() OVER (ORDER BY a.Case_IDNO, a.OrderSeq_NUMB, a.ObligationSeq_NUMB) ROW_NUMB
       FROM #TPRCP_P1 AS a
      GROUP BY a.Case_IDNO,
               a.OrderSeq_NUMB,
               a.ObligationSeq_NUMB,
               a.CaseWelfare_IDNO;

     INSERT INTO #TPRCP_P2
     SELECT *,
            @Ln_SupportYearMonth_NUMB
       FROM #TPRCP_P1 a

     DELETE FROM #TPRCP_P1;

     SET @Low_QNTY = 0;
     SET @Low_Current_NUMB = 1;

     SELECT @Low_QNTY = COUNT (m.ROW_NUMB)
       FROM @WemoCur_P1 AS m;

     WHILE @Low_Current_NUMB <= @Low_QNTY
      BEGIN
       SET @Ls_Sql_TEXT = 'SELECT FROM @WemoCur_P1';

       SELECT @Ln_Case_IDNO = m.Case_IDNO,
              @Ln_OrderSeq_NUMB = m.OrderSeq_NUMB,
              @Ln_ObligationSeq_NUMB = m.ObligationSeq_NUMB,
              @Ln_CaseWelfare_IDNO = m.CaseWelfare_IDNO,
              @Ln_ArrPaid_AMNT = m.ArrPaid_AMNT,
              @Ln_ArrRecoup_AMNT = m.ArrRecoup_AMNT,
              @Ln_ArrPaidMtd_AMNT = m.ArrPaidMtd_AMNT,
              @Ln_ArrRecoupMtd_AMNT = m.ArrRecoupMtd_AMNT,
              @Ln_ArrPaidUrg_AMNT = m.ArrPaidUrg_AMNT,
              @Ln_ArrPaidMtdUrg_AMNT = m.ArrPaidMtdUrg_AMNT
         FROM @WemoCur_P1 AS m
        WHERE ROW_NUMB = @Low_Current_NUMB;

       BEGIN
        SET @Ls_Sql_TEXT = 'SELECT_VWEMO';
        SET @Ls_Sqldata_TEXT = 'Case_IDNO ' + ISNULL (CAST(@Ln_Case_IDNO AS VARCHAR), '') + ' OrderSeq_NUMB  ' + ISNULL (CAST (@Ln_OrderSeq_NUMB AS VARCHAR), '') + ' ObligationSeq_NUMB  ' + ISNULL (CAST (@Ln_ObligationSeq_NUMB AS VARCHAR), '') + ' CaseWelfare_IDNO  ' + ISNULL (CAST(@Ln_CaseWelfare_IDNO AS VARCHAR), '') + '  WelfareYearMonth_NUMB  ' + ISNULL (CAST (@Ln_SupportYearMonth_NUMB AS VARCHAR), '');

        SELECT @Ln_MtdAssistExpend_AMNT = w.MtdAssistExpend_AMNT,
               @Ln_LtdAssistExpend_AMNT = w.LtdAssistExpend_AMNT,
               @Ln_MtdAssistWemoRecoup_AMNT = w.MtdAssistRecoup_AMNT,
               @Ln_LtdAssistWemoRecoup_AMNT = w.LtdAssistRecoup_AMNT
          FROM WEMO_Y1 AS w
         WHERE w.Case_IDNO = @Ln_Case_IDNO
           AND w.OrderSeq_NUMB = @Ln_OrderSeq_NUMB
           AND w.ObligationSeq_NUMB = @Ln_ObligationSeq_NUMB
           AND w.CaseWelfare_IDNO = @Ln_CaseWelfare_IDNO
           AND w.WelfareYearMonth_NUMB = @Ln_SupportYearMonth_NUMB
           AND w.EndValidity_DATE = @Ld_High_DATE;

        SET @Ln_RowCount_QNTY = @@ROWCOUNT;

        IF @Ln_RowCount_QNTY = 0
         BEGIN
          SET @Ls_Sql_TEXT = 'SELECT_VWEMO1';
          SET @Ls_Sqldata_TEXT = 'Case_IDNO ' + ISNULL (CAST(@Ln_Case_IDNO AS VARCHAR), '') + ' OrderSeq_NUMB  ' + ISNULL (CAST (@Ln_OrderSeq_NUMB AS VARCHAR), '') + ' ObligationSeq_NUMB  ' + ISNULL (CAST (@Ln_ObligationSeq_NUMB AS VARCHAR), '') + ' CaseWelfare_IDNO  ' + ISNULL (CAST(@Ln_CaseWelfare_IDNO AS VARCHAR), '') + '  WelfareYearMonth_NUMB  ' + ISNULL (CAST (@Ln_SupportYearMonth_NUMB AS VARCHAR), '');

          SELECT @Ln_LtdAssistExpend_AMNT = a.LtdAssistExpend_AMNT,
                 @Ln_LtdAssistWemoRecoup_AMNT = a.LtdAssistRecoup_AMNT
            FROM WEMO_Y1 AS a
           WHERE a.Case_IDNO = @Ln_Case_IDNO
             AND a.OrderSeq_NUMB = @Ln_OrderSeq_NUMB
             AND a.ObligationSeq_NUMB = @Ln_ObligationSeq_NUMB
             AND a.CaseWelfare_IDNO = @Ln_CaseWelfare_IDNO
             AND a.WelfareYearMonth_NUMB = (SELECT MAX (b.WelfareYearMonth_NUMB) AS expr
                                              FROM WEMO_Y1 AS b
                                             WHERE b.Case_IDNO = a.Case_IDNO
                                               AND b.OrderSeq_NUMB = a.OrderSeq_NUMB
                                               AND b.ObligationSeq_NUMB = a.ObligationSeq_NUMB
                                               AND b.CaseWelfare_IDNO = a.CaseWelfare_IDNO
                                               AND b.WelfareYearMonth_NUMB <= @Ln_SupportYearMonth_NUMB
                                               AND b.EndValidity_DATE = @Ld_High_DATE)
             AND a.EndValidity_DATE = @Ld_High_DATE;

          SET @Ln_RowCount_QNTY = @@ROWCOUNT;

          IF @Ln_RowCount_QNTY = 0
           BEGIN
            SET @Ln_MtdAssistExpend_AMNT = 0;
            SET @Ln_LtdAssistExpend_AMNT = 0;
            SET @Ln_MtdAssistWemoRecoup_AMNT = 0;
            SET @Ln_LtdAssistWemoRecoup_AMNT = 0;
            SET @Ln_IvmgRecoup_AMNT = 0;
           END
         END
       END

       SET @Ls_Sql_TEXT = 'UPDATE_VWEMO1';
       SET @Ls_Sqldata_TEXT = 'Case_IDNO ' + ISNULL (CAST(@Ln_Case_IDNO AS VARCHAR), '') + ' OrderSeq_NUMB  ' + ISNULL (CAST (@Ln_OrderSeq_NUMB AS VARCHAR), '') + ' ObligationSeq_NUMB  ' + ISNULL (CAST (@Ln_ObligationSeq_NUMB AS VARCHAR), '') + ' CaseWelfare_IDNO  ' + ISNULL (CAST(@Ln_CaseWelfare_IDNO AS VARCHAR), '') + '  WelfareYearMonth_NUMB  ' + ISNULL (CAST (@Ln_SupportYearMonth_NUMB AS VARCHAR), '') + ' EventGlobalSeq_NUMB  ' + ISNULL (CAST (@Ln_EventGlobalSeq_NUMB AS VARCHAR), '');

       UPDATE WEMO_Y1
          --  IVA Updates need to use effetive date instead of Sysdate - Starts
          SET EndValidity_DATE = @Ld_Run_DATE,
              -- Ends
              EventGlobalEndSeq_NUMB = @Ln_EventGlobalSeq_NUMB
        WHERE WEMO_Y1.Case_IDNO = @Ln_Case_IDNO
          AND WEMO_Y1.OrderSeq_NUMB = @Ln_OrderSeq_NUMB
          AND WEMO_Y1.ObligationSeq_NUMB = @Ln_ObligationSeq_NUMB
          AND WEMO_Y1.CaseWelfare_IDNO = @Ln_CaseWelfare_IDNO
          AND WEMO_Y1.WelfareYearMonth_NUMB = @Ln_SupportYearMonth_NUMB
          AND WEMO_Y1.EndValidity_DATE = @Ld_High_DATE;

       SET @Ln_RowCount_QNTY = @@ROWCOUNT;

       IF @Ln_RowCount_QNTY != 0
           OR (@Ln_RowCount_QNTY = 0
               AND (@Ln_ArrPaid_AMNT <> 0
                     OR @Ln_ArrRecoup_AMNT <> 0
                     OR @Ln_ArrPaidMtd_AMNT <> 0
                     OR @Ln_ArrRecoupMtd_AMNT <> 0
                     OR @Ln_ArrPaidUrg_AMNT <> 0
                     OR @Ln_ArrPaidMtdUrg_AMNT <> 0))
        BEGIN
         SET @Ls_Sql_TEXT = 'INSERT_VWEMO1';
         SET @Ls_Sqldata_TEXT = 'Case_IDNO ' + ISNULL (CAST(@Ln_Case_IDNO AS VARCHAR), '') + ' OrderSeq_NUMB  ' + ISNULL (CAST (@Ln_OrderSeq_NUMB AS VARCHAR), '') + ' ObligationSeq_NUMB  ' + ISNULL (CAST (@Ln_ObligationSeq_NUMB AS VARCHAR), '') + ' CaseWelfare_IDNO  ' + ISNULL (CAST(@Ln_CaseWelfare_IDNO AS VARCHAR), '') + '  WelfareYearMonth_NUMB  ' + ISNULL (CAST (@Ln_SupportYearMonth_NUMB AS VARCHAR), '');

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
         VALUES ( @Ln_Case_IDNO,
                  @Ln_OrderSeq_NUMB,
                  @Ln_ObligationSeq_NUMB,
                  @Ln_CaseWelfare_IDNO,
                  @Ln_SupportYearMonth_NUMB,
                  @Ln_ArrPaidMtd_AMNT + @Ln_ArrPaidMtdUrg_AMNT,-- MtdAssistExpend_AMNT
                  @Ln_ArrPaid_AMNT + @Ln_ArrPaidMtd_AMNT + @Ln_ArrPaidMtdUrg_AMNT + @Ln_ArrPaidUrg_AMNT - @Ln_LtdAssistExpend_AMNT,
                  -- TransactionAssistExpend_AMNT
                  @Ln_ArrPaid_AMNT + @Ln_ArrPaidMtd_AMNT + @Ln_ArrPaidMtdUrg_AMNT + @Ln_ArrPaidUrg_AMNT,
                  -- LtdAssistExpend_AMNT
                  @Ln_ArrRecoupMtd_AMNT,-- MtdAssistRecoup_AMNT
                  @Ln_ArrRecoup_AMNT + @Ln_ArrRecoupMtd_AMNT - @Ln_LtdAssistWemoRecoup_AMNT,
                  -- TransactionAssistRecoup_AMNT
                  @Ln_ArrRecoup_AMNT + @Ln_ArrRecoupMtd_AMNT,-- LtdAssistRecoup_AMNT
                  --  IVA Updates need to use effetive date instead of Sysdate - Starts
                  @Ld_Run_DATE,
                  --Ends
                  @Ld_High_DATE,
                  @Ln_EventGlobalSeq_NUMB,
                  0);

         SET @Ln_RowCount_QNTY = @@ROWCOUNT;

         IF @Ln_RowCount_QNTY = 0
          BEGIN
           SET @Ls_Sql_TEXT = 'INSERT_VWEMO1 FAILED'

           RAISERROR (50001,16,1);
          END
        END

       SET @Ls_Sql_TEXT = ' BATCH_COMMON$SP_REASSIGN_ARREARS'
       SET @Ls_Sqldata_TEXT = '	 Case_IDNO ' + ISNULL (CAST(@Ln_Case_IDNO AS VARCHAR), '') + '  OrderSeq_NUMB ' + ISNULL (CAST (@Ln_OrderSeq_NUMB AS VARCHAR), '') + '  ObligationSeq_NUMB  ' + ISNULL (CAST (@Ln_ObligationSeq_NUMB AS VARCHAR), '') + '  MTH_ADJUST  ' + ISNULL (CAST (@Ln_SupportYearMonth_NUMB AS VARCHAR), '')
       SET @Low_Current_NUMB = @Low_Current_NUMB + 1
      END

     -- We have to insert a record with Zero amounts for the obligation that are no longer getting prorated.
     -- Many programs pick up the latest record of a given obligation, at that point of time this obligation should have zero amounts.
     SET @Ls_Sql_TEXT = 'INSERT_ZERO_VWEMO'

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
            0,
            0,
            0,
            0,
            0,
            0,
            --  IVA Updates need to use effetive date instead of Sysdate - Starts
            @Ld_Run_DATE,
            -- Ends
            @Ld_High_DATE,
            @Ln_EventGlobalSeq_NUMB,
            0
       FROM WEMO_Y1 AS a
      WHERE a.CaseWelfare_IDNO = @An_CaseWelfare_IDNO
        AND a.WelfareYearMonth_NUMB = @Ln_SupportYearMonth_NUMB
        AND a.EndValidity_DATE = @Ld_High_DATE
        AND a.WelfareYearMonth_NUMB = (SELECT MAX (c.WelfareYearMonth_NUMB) AS expr
                                         FROM WEMO_Y1 AS c
                                        WHERE c.CaseWelfare_IDNO = a.CaseWelfare_IDNO
                                          AND c.Case_IDNO = a.Case_IDNO
                                          AND c.OrderSeq_NUMB = a.OrderSeq_NUMB
                                          AND c.ObligationSeq_NUMB = a.ObligationSeq_NUMB
                                          AND c.EndValidity_DATE = @Ld_High_DATE)
        AND NOT EXISTS (SELECT 1 AS expr
                          FROM @WemoCur_P1 AS b
                         WHERE b.CaseWelfare_IDNO = a.CaseWelfare_IDNO
                           AND b.Case_IDNO = a.Case_IDNO
                           AND b.OrderSeq_NUMB = a.OrderSeq_NUMB
                           AND b.ObligationSeq_NUMB = a.ObligationSeq_NUMB)
        AND EXISTS (SELECT 1 AS expr
                      FROM IVMG_Y1 AS c,
                           CMEM_Y1 AS d
                     WHERE c.CpMci_IDNO = @An_CpMci_IDNO
                       AND c.CaseWelfare_IDNO = @An_CaseWelfare_IDNO
                       AND c.CpMci_IDNO = d.MemberMci_IDNO
                       AND d.CaseRelationship_CODE = 'C'
                       AND d.Case_IDNO = a.Case_IDNO);

     SET @Ls_Sql_TEXT = 'UPDATE_WEMO_2';

     UPDATE WEMO_Y1
        --  IVA Updates need to use effetive date instead of Sysdate - Starts
        SET EndValidity_DATE = @Ld_Run_DATE,
            EventGlobalEndSeq_NUMB = @Ln_EventGlobalSeq_NUMB
       FROM WEMO_Y1 AS a
      WHERE a.CaseWelfare_IDNO = @An_CaseWelfare_IDNO
        AND a.WelfareYearMonth_NUMB = @Ln_SupportYearMonth_NUMB
        AND a.EndValidity_DATE = @Ld_High_DATE
        AND a.EventGlobalBeginSeq_NUMB < @Ln_EventGlobalSeq_NUMB
        AND NOT EXISTS (SELECT 1 AS expr
                          FROM @WemoCur_P1 AS b
                         WHERE b.CaseWelfare_IDNO = a.CaseWelfare_IDNO
                           AND b.Case_IDNO = a.Case_IDNO
                           AND b.OrderSeq_NUMB = a.OrderSeq_NUMB
                           AND b.ObligationSeq_NUMB = a.ObligationSeq_NUMB)
        AND EXISTS (SELECT 1 AS expr
                      FROM IVMG_Y1 AS c,
                           CMEM_Y1 AS d
                     WHERE c.CpMci_IDNO = @An_CpMci_IDNO
                       AND c.CaseWelfare_IDNO = @An_CaseWelfare_IDNO
                       AND c.CpMci_IDNO = d.MemberMci_IDNO
                       AND d.CaseRelationship_CODE = 'C'
                       AND d.Case_IDNO = a.Case_IDNO);

     DELETE FROM #TPRCP_P1;

     NEXT_FETCH:

     SET @Ld_Start_DATE = DATEADD (m, 1, @Ld_Start_DATE);

     IF dbo.BATCH_COMMON_SCALAR$SF_TO_CHAR_DATE (@Ld_Start_DATE, @Lc_DateFormatYyyymm_TEXT) = dbo.BATCH_COMMON_SCALAR$SF_TO_CHAR_DATE (@Ld_Run_DATE, @Lc_DateFormatYyyymm_TEXT)
      BEGIN
       SET @Ld_Start_DATE = @Ld_Run_DATE;
      END

     SET @Ln_SupportYearMonth_NUMB = dbo.BATCH_COMMON_SCALAR$SF_TO_CHAR_DATE (@Ld_Start_DATE, @Lc_DateFormatYyyymm_TEXT);
    END

   INSERT INTO @LsupCur_P1
               (Case_IDNO,
                OrderSeq_NUMB,
                ObligationSeq_NUMB,
                SupportYearMonth_NUMB,
                ROW_NUMB)
   SELECT Case_IDNO,
          OrderSeq_NUMB,
          ObligationSeq_NUMB,
          SupportYearMonth_NUMB,
          ROW_NUMBER() OVER (ORDER BY SupportYearMonth_NUMB) AS ROW_NUMB
     FROM #TPRCP_P2
    GROUP BY Case_IDNO,
             OrderSeq_NUMB,
             ObligationSeq_NUMB,
             SupportYearMonth_NUMB

   -- LOOP FOR REASSIGN START
   SET @Low_QNTY = 0;
   SET @Low_Current_NUMB = 1;

   SELECT @Low_QNTY = COUNT (l.ROW_NUMB)
     FROM @LsupCur_P1 AS l;

   WHILE @Low_Current_NUMB <= @Low_QNTY
    BEGIN
     SELECT @Ln_Case_IDNO = l.Case_IDNO,
            @Ln_OrderSeq_NUMB = l.OrderSeq_NUMB,
            @Ln_ObligationSeq_NUMB = l.ObligationSeq_NUMB,
            @Ln_SupportYearMonth_NUMB = l.SupportYearMonth_NUMB
       FROM @LsupCur_P1 AS l
      WHERE ROW_NUMB = @Low_Current_NUMB;

     EXECUTE BATCH_COMMON$SP_REASSIGN_ARREARS
      @An_Case_IDNO             = @Ln_Case_IDNO,
      @An_OrderSeq_NUMB         = @Ln_OrderSeq_NUMB,
      @An_ObligationSeq_NUMB    = @Ln_ObligationSeq_NUMB,
      @An_SupportYearMonth_NUMB = @Ln_SupportYearMonth_NUMB,
      @An_CpMci_IDNO            = @Ln_MemberMci_IDNO,
      @An_EventGlobalSeq_NUMB   = @Ln_EventGlobalSeq_NUMB,
      @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT,
      @Ad_Process_DATE          = @Ld_Run_DATE;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_REASSIGN_ARREARS FAILED';

       RAISERROR (50001,16,1);
      END

     SET @Low_Current_NUMB = @Low_Current_NUMB + 1
    END

   --- LOOP FOR REASSIGN END  
   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE
   --Check for Exception information to log the description text based on the error
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
  END CATCH;
 END


GO
