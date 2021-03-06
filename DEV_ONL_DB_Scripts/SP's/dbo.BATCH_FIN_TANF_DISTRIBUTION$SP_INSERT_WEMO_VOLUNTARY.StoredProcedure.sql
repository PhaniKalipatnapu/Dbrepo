/****** Object:  StoredProcedure [dbo].[BATCH_FIN_TANF_DISTRIBUTION$SP_INSERT_WEMO_VOLUNTARY]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_FIN_TANF_DISTRIBUTION$SP_INSERT_WEMO_VOLUNTARY
Programmer Name 	: IMP Team
Description			: Procedure to insert WEMO records for voluntary payments on current assistance cases.
Frequency			: 'MONTHLY'
Developed On		: 03/24/2011
Called BY			: 
Called On			: 
--------------------------------------------------------------------------------------------------------------------
Modified BY			:
Modified On			:
Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_FIN_TANF_DISTRIBUTION$SP_INSERT_WEMO_VOLUNTARY]
 @An_Case_IDNO             NUMERIC(6),
 @An_OrderSeq_NUMB         NUMERIC(2),
 @An_ObligationSeq_NUMB    NUMERIC(2),
 @An_CaseWelfare_IDNO      NUMERIC(10),
 @An_CpMci_IDNO            NUMERIC(10),
 @An_ReceiptWelfareYearMonth_NUMB NUMERIC (6),
 @An_ProcessWelfareYearMonth_NUMB NUMERIC (6),
 @An_EventGlobalSeq_NUMB   NUMERIC(19),
 @Ac_Msg_CODE              CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT,
 @Ad_Process_DATE          DATE OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE  @Lc_StatusSuccess_CODE        CHAR (1) = 'S',
           @Lc_StatusFailed_CODE         CHAR (1) = 'F',
           @Lc_TypeDebtChildSupp_CODE    CHAR (2) = 'CS',
           @Lc_TypeDebtSpousalSupp_CODE  CHAR (2) = 'SS',
           @Lc_DatePart01_CODE			 CHAR (2) = '01',
           @Ls_Sql_TEXT                  VARCHAR (100) = ' ',
           @Ls_Procedure_NAME            VARCHAR (100) = 'SP_INSERT_WEMO_VOLUNTARY',
           @Ls_Sqldata_TEXT              VARCHAR (1000) = ' ',
           @Ld_High_DATE                 DATE = '12/31/9999';
  DECLARE  @Ln_WelfareYearMonth_NUMB  NUMERIC (6),
           @Ln_MtdAssistExpend_AMNT   NUMERIC (11,2),
           @Ln_LtdAssistExpend_AMNT   NUMERIC (11,2),
           @Ln_MtdAssistRecoup_AMNT   NUMERIC (11,2),
           @Ln_LtdAssistRecoup_AMNT   NUMERIC (11,2),
           @Ln_Error_NUMB             NUMERIC (11),
           @Ln_ErrorLine_NUMB         NUMERIC (11),
           @Ls_ErrorMessage_TEXT      VARCHAR (200),
           @Ls_DescriptionError_TEXT  VARCHAR (4000);
  BEGIN TRY
   SET @Ac_Msg_CODE = '';
   SET @Ls_Sql_TEXT = 'SELECT_IVMG_VOL';
   SET @Ls_Sqldata_TEXT = 'CaseWelfare_IDNO = ' + ISNULL(CAST( @An_CaseWelfare_IDNO AS VARCHAR ),'')+ ', WelfareYearMonth_NUMB = ' + ISNULL(CAST( @An_ReceiptWelfareYearMonth_NUMB AS VARCHAR ),'')+ ', CpMci_IDNO = ' + ISNULL(CAST( @An_CpMci_IDNO AS VARCHAR ),'')+ ', CaseWelfare_IDNO = ' + ISNULL(CAST( @An_CaseWelfare_IDNO AS VARCHAR ),'')+ ', WelfareYearMonth_NUMB = ' + ISNULL(CAST( @An_ReceiptWelfareYearMonth_NUMB AS VARCHAR ),'') + ', CpMci_IDNO = ' + ISNULL(CAST( @An_CpMci_IDNO AS VARCHAR ),'');

   SELECT @Ln_MtdAssistExpend_AMNT = b.MtdAssistExpend_AMNT,
          @Ln_LtdAssistExpend_AMNT = b.LtdAssistExpend_AMNT,
          @Ln_MtdAssistRecoup_AMNT = b.MtdAssistRecoup_AMNT,
          @Ln_LtdAssistRecoup_AMNT = b.LtdAssistRecoup_AMNT
     FROM IVMG_Y1 b
    WHERE b.CaseWelfare_IDNO = @An_CaseWelfare_IDNO
      AND b.WelfareYearMonth_NUMB = @An_ReceiptWelfareYearMonth_NUMB
      AND b.MtdAssistExpend_AMNT > 0
      AND b.CpMci_IDNO = @An_CpMci_IDNO
      AND b.EventGlobalSeq_NUMB = (SELECT MAX (c.EventGlobalSeq_NUMB)
                                     FROM IVMG_Y1 c
                                    WHERE c.CaseWelfare_IDNO = @An_CaseWelfare_IDNO
                                      AND c.WelfareYearMonth_NUMB = @An_ReceiptWelfareYearMonth_NUMB
                                      AND c.CpMci_IDNO = @An_CpMci_IDNO
                                      AND c.WelfareElig_CODE = b.WelfareElig_CODE);
   --Insert WEMO for RCTH_Y1 month	
   SET @Ls_Sql_TEXT = 'INSERT_WEMO_VOL-1';   
   SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @An_Case_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @An_OrderSeq_NUMB AS VARCHAR ),'') + ', ObligationSeq_NUMB = ' + ISNULL (CAST (@An_ObligationSeq_NUMB AS VARCHAR), '') + ', CaseWelfare_IDNO = ' + ISNULL(CAST( @An_CaseWelfare_IDNO AS VARCHAR ),'')+ ', WelfareYearMonth_NUMB = ' + ISNULL(CAST( @An_ReceiptWelfareYearMonth_NUMB AS VARCHAR ),'')+ ', MtdAssistRecoup_AMNT = ' + ISNULL('0','')+ ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST( @An_EventGlobalSeq_NUMB AS VARCHAR ),'')+ ', EventGlobalEndSeq_NUMB = ' + ISNULL('0','')+ ', BeginValidity_DATE = ' + ISNULL(CAST( @Ad_Process_DATE AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');

   INSERT INTO WEMO_Y1
               (Case_IDNO,
                OrderSeq_NUMB,
                ObligationSeq_NUMB,
                CaseWelfare_IDNO,
                WelfareYearMonth_NUMB,
                TransactionAssistExpend_AMNT,
                MtdAssistExpend_AMNT,
                LtdAssistExpend_AMNT,
                TransactionAssistRecoup_AMNT,
                MtdAssistRecoup_AMNT,
                LtdAssistRecoup_AMNT,
                EventGlobalBeginSeq_NUMB,
                EventGlobalEndSeq_NUMB,
                BeginValidity_DATE,
                EndValidity_DATE)
   SELECT @An_Case_IDNO AS Case_IDNO,
          @An_OrderSeq_NUMB AS OrderSeq_NUMB,
          x.ObligationSeq_NUMB,
          @An_CaseWelfare_IDNO AS CaseWelfare_IDNO,
          @An_ReceiptWelfareYearMonth_NUMB AS WelfareYearMonth_NUMB,
          MtdExpnd_AMNT AS TransactionAssistExpend_AMNT,
          MtdExpnd_AMNT AS MtdAssistExpend_AMNT,
          LtdExpnd_AMNT AS LtdAssistExpend_AMNT,
          LtdRecoup_AMNT AS TransactionAssistRecoup_AMNT,
          0 AS MtdAssistRecoup_AMNT,
          LtdRecoup_AMNT AS LtdAssistRecoup_AMNT,
          @An_EventGlobalSeq_NUMB AS EventGlobalBeginSeq_NUMB,
          0 AS EventGlobalEndSeq_NUMB,
          @Ad_Process_DATE AS BeginValidity_DATE,
          @Ld_High_DATE AS EndValidity_DATE
     FROM (SELECT ObligationSeq_NUMB,
                  ROUND ((@Ln_MtdAssistExpend_AMNT / MemberCount_QNTY), 2) + (CASE
                                                                        WHEN ROWNUM = 1
                                                                         THEN @Ln_MtdAssistExpend_AMNT - ROUND ((@Ln_MtdAssistExpend_AMNT / MemberCount_QNTY), 2) * MemberCount_QNTY
                                                                        ELSE 0
                                                                       END) MtdExpnd_AMNT,
                  ROUND ((@Ln_LtdAssistExpend_AMNT / MemberCount_QNTY), 2) + (CASE
                                                                        WHEN ROWNUM = 1
                                                                         THEN @Ln_LtdAssistExpend_AMNT - ROUND ((@Ln_LtdAssistExpend_AMNT / MemberCount_QNTY), 2) * MemberCount_QNTY
                                                                        ELSE 0
                                                                       END) LtdExpnd_AMNT,
                  ROUND ((@Ln_LtdAssistRecoup_AMNT / MemberCount_QNTY), 2) + (CASE
                                                                        WHEN ROWNUM = 1
                                                                         THEN @Ln_LtdAssistRecoup_AMNT - ROUND ((@Ln_LtdAssistRecoup_AMNT / MemberCount_QNTY), 2) * MemberCount_QNTY
                                                                        ELSE 0
                                                                       END) LtdRecoup_AMNT
             FROM (SELECT DISTINCT o.ObligationSeq_NUMB,
                          COUNT (1) OVER () MemberCount_QNTY,
                          ROW_NUMBER () OVER (ORDER BY NUM) AS ROWNUM
                     FROM OBLE_Y1 o,
                          (SELECT 1 NUM) AS NM
                    WHERE o.Case_IDNO = @An_Case_IDNO
                      AND o.OrderSeq_NUMB = @An_OrderSeq_NUMB
                      AND o.EndValidity_DATE = @Ld_High_DATE
                      AND o.TypeDebt_CODE IN (@Lc_TypeDebtChildSupp_CODE, @Lc_TypeDebtSpousalSupp_CODE)) Y) x;

   SET @Ln_WelfareYearMonth_NUMB = @An_ReceiptWelfareYearMonth_NUMB;
   SET @Ls_Sql_TEXT = 'WHILE LOOP -1';   
   SET @Ls_Sqldata_TEXT = '';
   
   --Carry forward records from RCTH_Y1 month to current month
   WHILE @An_ProcessWelfareYearMonth_NUMB > @Ln_WelfareYearMonth_NUMB
    BEGIN
     SET @Ln_WelfareYearMonth_NUMB = SUBSTRING(CONVERT(VARCHAR(6),(DATEADD (m, 1, CAST(CAST(@Ln_WelfareYearMonth_NUMB AS VARCHAR)+@Lc_DatePart01_CODE AS DATE))),112),1,6);

     SET @Ls_Sql_TEXT = 'INSERT_WEMO_VOL-2';     
     SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @An_Case_IDNO AS VARCHAR ),'') + ', OrderSeq_NUMB = ' + ISNULL(CAST( @An_OrderSeq_NUMB AS VARCHAR ),'') + ', ReceiptWelfareYearMonth_NUMB = ' + ISNULL(CAST( @An_ReceiptWelfareYearMonth_NUMB AS VARCHAR ),'') + ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST( @An_EventGlobalSeq_NUMB AS VARCHAR ),'') + ', WelfareYearMonth_NUMB = ' + ISNULL(CAST( @Ln_WelfareYearMonth_NUMB AS VARCHAR ),'')+ ', TransactionAssistExpend_AMNT = ' + ISNULL('0','')+ ', MtdAssistExpend_AMNT = ' + ISNULL('0','')+ ', TransactionAssistRecoup_AMNT = ' + ISNULL('0','')+ ', MtdAssistRecoup_AMNT = ' + ISNULL('0','')+ ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST( @An_EventGlobalSeq_NUMB AS VARCHAR ),'')+ ', EventGlobalEndSeq_NUMB = ' + ISNULL('0','')+ ', BeginValidity_DATE = ' + ISNULL(CAST( @Ad_Process_DATE AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');
     INSERT WEMO_Y1
            (Case_IDNO,
             OrderSeq_NUMB,
             ObligationSeq_NUMB,
             CaseWelfare_IDNO,
             WelfareYearMonth_NUMB,
             TransactionAssistExpend_AMNT,
             MtdAssistExpend_AMNT,
             LtdAssistExpend_AMNT,
             TransactionAssistRecoup_AMNT,
             MtdAssistRecoup_AMNT,
             LtdAssistRecoup_AMNT,
             EventGlobalBeginSeq_NUMB,
             EventGlobalEndSeq_NUMB,
             BeginValidity_DATE,
             EndValidity_DATE)
     SELECT a.Case_IDNO,
            a.OrderSeq_NUMB,
            a.ObligationSeq_NUMB,
            a.CaseWelfare_IDNO,
            @Ln_WelfareYearMonth_NUMB AS WelfareYearMonth_NUMB,
            0 AS TransactionAssistExpend_AMNT,
            0 AS MtdAssistExpend_AMNT,
            a.LtdAssistExpend_AMNT,
            0 AS TransactionAssistRecoup_AMNT,
            0 AS MtdAssistRecoup_AMNT,
            a.LtdAssistRecoup_AMNT,
            @An_EventGlobalSeq_NUMB AS EventGlobalBeginSeq_NUMB,
            0 AS EventGlobalEndSeq_NUMB,
            @Ad_Process_DATE AS BeginValidity_DATE,
            @Ld_High_DATE AS EndValidity_DATE
       FROM WEMO_Y1 a
      WHERE a.Case_IDNO = @An_Case_IDNO
        AND a.OrderSeq_NUMB = @An_OrderSeq_NUMB
        AND a.WelfareYearMonth_NUMB = @An_ReceiptWelfareYearMonth_NUMB
        AND a.EndValidity_DATE = @Ld_High_DATE
        AND a.EventGlobalBeginSeq_NUMB = @An_EventGlobalSeq_NUMB;
    END

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   SET @Ln_Error_NUMB = ERROR_NUMBER ();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE ();
   SET @Ls_ErrorMessage_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);

   --Check for Exception information to log the description text based on the error
   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
  END CATCH
 END


GO
