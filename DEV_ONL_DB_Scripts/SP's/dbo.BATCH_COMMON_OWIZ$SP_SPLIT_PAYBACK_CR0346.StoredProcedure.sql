/****** Object:  StoredProcedure [dbo].[BATCH_COMMON_OWIZ$SP_SPLIT_PAYBACK_CR0346]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*    
--------------------------------------------------------------------------------------------------------------------    
Procedure Name	 : BATCH_COMMON_OWIZ$SP_SPLIT_PAYBACK_CR0346    
Programmer Name  : IMP Team    
Description		 :  Spliting the Payback amount equally among the Participants and insert the records in OBLE_Y1 and LSUP_Y1    
Frequency		 :     
Developed On	 :     
Called By		 :    
Called On		 :    
--------------------------------------------------------------------------------------------------------------------    
Modified By		 :    
Modified On		 :    
Version No		 :     
--------------------------------------------------------------------------------------------------------------------    
*/    
CREATE PROCEDURE [dbo].[BATCH_COMMON_OWIZ$SP_SPLIT_PAYBACK_CR0346]
 (    
 @An_Case_IDNO                NUMERIC(6),    
 @An_OrderSeq_NUMB            NUMERIC (2, 0) = NULL,    
 @Ac_Fips_CODE				  CHAR(7),     
 @Ac_TypeDebt_CODE			  CHAR(2),     
 @An_Payback_AMNT             NUMERIC(11, 2),    
 @Ac_PaybackType_CODE         CHAR(1),    
 @Ac_PaybackFreq_TEXT         CHAR(1),    
 @An_EventGlobalBeginSeq_NUMB NUMERIC (19, 0),    
 @Ad_Process_DATE             DATE,    
 @Ac_Msg_CODE                 CHAR(1)		OUTPUT,    
 @As_DescriptionError_TEXT    VARCHAR(4000) OUTPUT    
 )    
AS    
 BEGIN    
  SET NOCOUNT ON;    
    
    DECLARE     
           @Ln_SupportYearMonth_NUMB	NUMERIC(6)	 = dbo.BATCH_COMMON_SCALAR$SF_TO_CHAR_DATE(@Ad_Process_DATE, 'YYYYMM'),                        
           @Li_Zero_NUMB				INT			  = 0,    
           @Li_One_NUMB					INT			  = 1,    
           @Li_SplitCount_QNTY			INT			  = 0,    
           @Li_PaybackProrate1100_NUMB  INT			  = 1100,                 
     	   @Lc_Space_TEXT               CHAR(1)		 = ' ',    
           @Lc_StringZero_TEXT          CHAR(1)		 = '0',    
           @Lc_TypeRecordOriginal_CODE  CHAR(1)		 = 'O',    
           @Lc_StatusSuccess_CODE       CHAR(1)		 = 'S',    
           @Lc_StatusFailed_CODE		CHAR(1)		 = 'F',    
           @Ls_Routine_TEXT             VARCHAR(400) = 'BATCH_COMMON_OWIZ$SP_SPLIT_PAYBACK_CR0346',    
           @Ld_SystemDate_DATE   		DATE		 = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),   
           @Ld_High_DATE				DATE		 = '12/31/9999',    
           @Ld_Lowdate_DATE             DATE		 = '01/01/0001';    
      
  DECLARE  @Ln_RowCount_QNTY			NUMERIC(9),    
           @Ln_Error_NUMB				NUMERIC(9),   
           @Ln_ErrorLine_NUMB			NUMERIC(11), 
           @Ln_Payback_AMNT				NUMERIC(11,2) = 0,    
           @Ln_Paybackadjument_AMNT		NUMERIC(11,2) = 0,                
           @Li_FetchStatus_QNTY			INT,    
           @Li_CursorCurrentRow_QNTY	INT,            
           @Ls_Sql_TEXT					VARCHAR(400),    
           @Ls_Sqldata_TEXT				VARCHAR(400),    
           @Ls_Errormessage_TEXT		VARCHAR(4000),    
           @Ld_Process_DATE				DATETIME;    
      
   DECLARE @Ln_ObligationSeq_NUMB_CUR	NUMERIC(2),
		   @Ld_EndObligation_DATE_CUR	DATE,  
		   @Ld_BeginObligation_DATE_CUR	DATE,
		   @Ln_EventGlobalBeginSeq_NUMB_CUR	   NUMERIC(19);     
		   
  BEGIN TRY    
   SET @Ac_Msg_CODE = NULL;    
   SET @As_DescriptionError_TEXT = NULL;    
   SET @Ld_Process_DATE = @Ad_Process_DATE;    
       
   SET @Ls_Sql_TEXT = 'SELECT FROM OBLE_Y1';    
   SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '') + ', OrderSeq_NUMB = ' + ISNULL(CAST(@An_OrderSeq_NUMB AS VARCHAR), '') +   ', TypeDebt_CODE = ' + ISNULL(@Ac_TypeDebt_CODE, '') + ', CD_EXPT = ' + ISNULL(@Ac_PaybackType_CODE, '') + ', EXPT = ' + ISNULL(CAST(@An_Payback_AMNT AS VARCHAR), '');    
    
   --Find the Number of obligation members, to divide the Payment on arrear amount among the eligible obligtion member at debt level.    
   SELECT @Li_SplitCount_QNTY = COUNT(1)    
     FROM OBLE_Y1 O    
   WHERE O.Case_IDNO = @An_Case_IDNO     
     AND O.OrderSeq_NUMB = @An_OrderSeq_NUMB     
     AND O.TypeDebt_CODE = @Ac_TypeDebt_CODE     
     AND O.Fips_CODE = @Ac_Fips_CODE          
     AND O.EndValidity_DATE = @Ld_High_DATE        
     AND  (     O.BeginObligation_DATE <= @Ld_Process_DATE       
                 AND O.EndObligation_DATE =       
                        (      
                      SELECT MAX(b.EndObligation_DATE)      
                        FROM OBLE_Y1 b      
                       WHERE b.Case_IDNO = O.Case_IDNO       
      					 AND b.OrderSeq_NUMB = O.OrderSeq_NUMB       
                         AND b.ObligationSeq_NUMB = O.ObligationSeq_NUMB       
                         AND b.BeginObligation_DATE <= @Ld_Process_DATE      
                         AND b.EndValidity_DATE = @Ld_High_DATE      
						)      
			);    
        
   -- If count is zero(Obligation Members is not exist)    
   IF @Li_SplitCount_QNTY = @Li_Zero_NUMB    
    BEGIN    
     SET @Ac_Msg_CODE = 'N';     
    END    
        
   --Equally spliting the Payback amount amoung the obligation members at debt level .     
   SET @Ln_Payback_AMNT = @An_Payback_AMNT / @Li_SplitCount_QNTY;       
   SET @Ln_Paybackadjument_AMNT = @An_Payback_AMNT - (@Ln_Payback_AMNT * @Li_SplitCount_QNTY);       
     
   --Cursor to get the list of obligation member belongs to the debt type    
   DECLARE ObligSeq_CUR INSENSITIVE CURSOR FOR      
  SELECT O.ObligationSeq_NUMB,
		O.BeginObligation_DATE,
		O.EndObligation_date,
		O.EventGlobalBeginSeq_NUMB
		FROM OBLE_Y1 O    
   WHERE O.Case_IDNO = @An_Case_IDNO     
     AND O.OrderSeq_NUMB = @An_OrderSeq_NUMB     
     AND O.TypeDebt_CODE = @Ac_TypeDebt_CODE     
     AND O.Fips_CODE = @Ac_Fips_CODE          
     AND O.EndValidity_DATE = @Ld_High_DATE         
     AND  (     O.BeginObligation_DATE <= @Ld_Process_DATE       
                 AND O.EndObligation_DATE =       
                        (      
                      SELECT MAX(b.EndObligation_DATE)      
                        FROM OBLE_Y1 b      
                       WHERE b.Case_IDNO = O.Case_IDNO       
                         AND b.OrderSeq_NUMB = O.OrderSeq_NUMB       
                         AND b.ObligationSeq_NUMB = O.ObligationSeq_NUMB       
                         AND b.BeginObligation_DATE <= @Ld_Process_DATE       
                         AND b.EndValidity_DATE = @Ld_High_DATE      
                      )      );    
       
   SET @Ls_Sql_TEXT = 'OPEN ObligSeq_CUR';    
   SET @Ls_Sqldata_TEXT = '' ;     
   OPEN ObligSeq_CUR;    
        
   FETCH NEXT FROM ObligSeq_CUR INTO @Ln_ObligationSeq_NUMB_CUR, @Ld_BeginObligation_DATE_CUR,@Ld_EndObligation_DATE_CUR,@Ln_EventGlobalBeginSeq_NUMB_CUR;    
       
   SET @Ls_Sql_TEXT = 'FetchStatus_QNTY - 1';    
   SET @Ls_Sqldata_TEXT = '' ;     
   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;    
   SET @Li_CursorCurrentRow_QNTY = @Li_One_NUMB;    
  
   --Begin of While Loop    
   WHILE(@Li_FetchStatus_QNTY = @Li_Zero_NUMB)    
    BEGIN     
     --for last member adding the adjustment amount    
     IF (@Li_CursorCurrentRow_QNTY = @Li_SplitCount_QNTY)    
      BEGIN    
       SET @Ln_Payback_AMNT = @Ln_Payback_AMNT + @Ln_Paybackadjument_AMNT;    
	  END    
        
	 SET @Ls_Sql_TEXT = 'UPDATE OBLE_Y1';    
     SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '') + ', OrderSeq_NUMB = ' + ISNULL(CAST(@An_OrderSeq_NUMB AS VARCHAR), '') + ', ObligationSeq_NUMB = ' + ISNULL(CAST(@Ln_ObligationSeq_NUMB_CUR AS VARCHAR), '') +  ', TypeDebt_CODE = ' + ISNULL(@Ac_TypeDebt_CODE, '') + ', Fips_CODE = ' + ISNULL(CAST(@Ac_Fips_CODE AS VARCHAR), '') + ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST(@An_EventGlobalBeginSeq_NUMB AS VARCHAR),'');;    
       
  --Updating the Payback amounts in OBLE_Y1 for each Obligation belongs to specific debt type    
  UPDATE OBLE_Y1     
       SET ExpectToPay_AMNT = @Ln_Payback_AMNT,    
           ExpectToPay_CODE =  @Ac_PaybackType_CODE                
  WHERE Case_IDNO = @An_Case_IDNO    
  AND OrderSeq_NUMB = @An_OrderSeq_NUMB    
  AND ObligationSeq_NUMB = @Ln_ObligationSeq_NUMB_CUR    
  AND TypeDebt_CODE = @Ac_TypeDebt_CODE    
  AND Fips_CODE = @Ac_Fips_CODE    
  AND ( ExpectToPay_AMNT <> @Ln_Payback_AMNT    
    OR ExpectTOPay_CODE <> @Ac_PaybackType_CODE)      
  AND ENDOBLIGATION_DATE = @Ld_EndObligation_DATE_CUR 
  AND BeginObligation_DATE = @Ld_BeginObligation_DATE_CUR
  AND Eventglobalbeginseq_numb =  @Ln_EventGlobalBeginSeq_NUMB_CUR
  AND EndValidity_DATE = @Ld_High_DATE;      
  
   SET @Ls_Sql_TEXT = 'UPDATE OBLE_Y1 - 2 ';    
     SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '') + ', OrderSeq_NUMB = ' + ISNULL(CAST(@An_OrderSeq_NUMB AS VARCHAR), '') + ', ObligationSeq_NUMB = ' + ISNULL(CAST(@Ln_ObligationSeq_NUMB_CUR AS VARCHAR), '') +  ', TypeDebt_CODE = ' + ISNULL(@Ac_TypeDebt_CODE, '') + ', Fips_CODE = ' + ISNULL(CAST(@Ac_Fips_CODE AS VARCHAR), '') + ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST(@An_EventGlobalBeginSeq_NUMB AS VARCHAR),'');;    
       
  --Updating the Payback amounts in OBLE_Y1 for Future Obligation belongs to specific debt type    
  UPDATE OBLE_Y1     
       SET ExpectToPay_AMNT = @Ln_Payback_AMNT,    
           ExpectToPay_CODE =  @Ac_PaybackType_CODE                
     WHERE Case_IDNO = @An_Case_IDNO    
  AND OrderSeq_NUMB = @An_OrderSeq_NUMB    
  AND ObligationSeq_NUMB = @Ln_ObligationSeq_NUMB_CUR    
  AND TypeDebt_CODE = @Ac_TypeDebt_CODE    
  AND Fips_CODE = @Ac_Fips_CODE       
  AND ENDOBLIGATION_DATE >  @Ld_SystemDate_DATE  
  AND EndValidity_DATE = @Ld_High_DATE;   
         
  --Updating the payback amounts in LSUP_Y1 for Current month of each Obligation belongs to specific debt type.    
  SET @Ls_Sql_TEXT = 'UPDATE LSUP_Y1';    
     SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '') + ', OrderSeq_NUMB = ' + ISNULL(CAST(@An_OrderSeq_NUMB AS VARCHAR), '') + ', ObligationSeq_NUMB = ' + ISNULL(CAST(@Ln_ObligationSeq_NUMB_CUR AS VARCHAR), '') + ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST(@An_EventGlobalBeginSeq_NUMB AS VARCHAR),'');;    
  UPDATE L    
       SET TransactionExptPay_AMNT = CASE    
                                      WHEN L.AppTotExptPay_AMNT > @Ln_Payback_AMNT    
                                       THEN L.AppTotExptPay_AMNT - L.OweTotExptPay_AMNT    
                                      ELSE @Ln_Payback_AMNT - L.OweTotExptPay_AMNT    
                                     END,    
            OweTotExptPay_AMNT = CASE    
                                  WHEN L.AppTotExptPay_AMNT > @Ln_Payback_AMNT    
                                   THEN L.AppTotExptPay_AMNT    
                                  ELSE @Ln_Payback_AMNT    
                                 END    
       FROM LSUP_Y1 L    
     WHERE Case_IDNO = @An_Case_IDNO    
       AND ObligationSeq_NUMB = @Ln_ObligationSeq_NUMB_CUR    
       AND OrderSeq_NUMB = @An_OrderSeq_NUMB    
       AND SupportYearMonth_NUMB = @Ln_SupportYearMonth_NUMB    
       AND EventGlobalSeq_NUMB = @An_EventGlobalBeginSeq_NUMB
       AND @Ln_Payback_AMNT <> AppTotExptPay_AMNT;    
           
     SET @Ln_RowCount_QNTY = @@ROWCOUNT;    
         
     IF(@Ln_RowCount_QNTY = @Li_Zero_NUMB)    
      BEGIN       		
      	SET @Ls_Sql_TEXT = 'INSERT INTO LSUP_Y1';    
        SET @Ls_Sqldata_TEXT = 'TransactionCurSup_AMNT = ' + ISNULL(CAST( @Li_Zero_NUMB AS VARCHAR ),'')+ ', TransactionNaa_AMNT = ' + ISNULL(CAST( @Li_Zero_NUMB AS VARCHAR ),'')+ ', TransactionPaa_AMNT = ' + ISNULL(CAST( @Li_Zero_NUMB AS VARCHAR ),'')+ ', TransactionTaa_AMNT = ' + ISNULL(CAST( @Li_Zero_NUMB AS VARCHAR ),'')+ ', TransactionCaa_AMNT = ' + ISNULL(CAST( @Li_Zero_NUMB AS VARCHAR ),'')+ ', TransactionUpa_AMNT = ' + ISNULL(CAST( @Li_Zero_NUMB AS VARCHAR ),'')+ ', TransactionUda_AMNT = ' + ISNULL(CAST( @Li_Zero_NUMB AS VARCHAR ),'')+ ', TransactionIvef_AMNT = ' + ISNULL(CAST( @Li_Zero_NUMB AS VARCHAR ),'')+ ', TransactionMedi_AMNT = ' + ISNULL(CAST( @Li_Zero_NUMB AS VARCHAR ),'')+ ', TransactionFuture_AMNT = ' + ISNULL(CAST( @Li_Zero_NUMB AS VARCHAR ),'')+ ', TransactionNffc_AMNT = ' + ISNULL(CAST( @Li_Zero_NUMB AS VARCHAR ),'')+ ', TransactionNonIvd_AMNT = ' + ISNULL(CAST( @Li_Zero_NUMB AS VARCHAR ),'')+ ', Batch_DATE = ' + ISNULL(CAST( @Ld_Lowdate_DATE AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Lc_Space_TEXT,'')+ ', Batch_NUMB = ' + ISNULL(CAST( @Li_Zero_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(@Lc_StringZero_TEXT,'')+ ', Receipt_DATE = ' + ISNULL(CAST( @Ld_Lowdate_DATE AS VARCHAR ),'')+ ', Distribute_DATE = ' + ISNULL(CAST( @Ad_Process_DATE AS VARCHAR ),'')+ ', TypeRecord_CODE = ' + ISNULL(@Lc_TypeRecordOriginal_CODE,'')+ ', EventFunctionalSeq_NUMB = ' + ISNULL(CAST( @Li_PaybackProrate1100_NUMB AS VARCHAR ),'')+ ', EventGlobalSeq_NUMB = ' + ISNULL(CAST( @An_EventGlobalBeginSeq_NUMB AS VARCHAR ),'');    
                INSERT INTO LSUP_Y1    
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
                  CheckRecipient_ID,    
                  CheckRecipient_CODE)    
   SELECT Case_IDNO,                                       --Case_IDNO    
          L.OrderSeq_NUMB,         --OrderSeq_NUMB    
          L.ObligationSeq_NUMB,        --ObligationSeq_NUMB    
          SupportYearMonth_NUMB,        --SupportYearMonth_NUMB    
          L.TypeWelfare_CODE,         --TypeWelfare_CODE    
          @Li_Zero_NUMB AS TransactionCurSup_AMNT,         --TransactionCurSup_AMNT    
          L.OweTotCurSup_AMNT,        --OweTotCurSup_AMNT    
          L.AppTotCurSup_AMNT,        --AppTotCurSup_AMNT    
          L.MtdCurSupOwed_AMNT,        --MtdCurSupOwed_AMNT    
          CASE    
     WHEN L.AppTotExptPay_AMNT > @Ln_Payback_AMNT    
     THEN L.AppTotExptPay_AMNT - L.OweTotExptPay_AMNT    
      ELSE @Ln_Payback_AMNT - L.OweTotExptPay_AMNT    
     END AS TransactionExptPay_AMNT,    --TransactionExptPay_AMNT    
          CASE    
     WHEN L.AppTotExptPay_AMNT > @Ln_Payback_AMNT    
     THEN L.AppTotExptPay_AMNT    
     ELSE @Ln_Payback_AMNT    
     END AS OweTotExptPay_AMNT,      --OweTotExptPay_AMNT    
          L.AppTotExptPay_AMNT,       --AppTotExptPay_AMNT    
          @Li_Zero_NUMB AS TransactionNaa_AMNT,   --TransactionNaa_AMNT    
          L.OweTotNaa_AMNT,        --OweTotNaa_AMNT    
          L.AppTotNaa_AMNT,        --AppTotNaa_AMNT    
          @Li_Zero_NUMB AS TransactionPaa_AMNT,   --TransactionPaa_AMNT    
          L.OweTotPaa_AMNT,        --OweTotPaa_AMNT    
          L.AppTotPaa_AMNT,        --AppTotPaa_AMNT    
          @Li_Zero_NUMB AS TransactionTaa_AMNT,   --TransactionTaa_AMNT    
          L.OweTotTaa_AMNT,        --OweTotTaa_AMNT    
          L.AppTotTaa_AMNT,        --AppTotTaa_AMNT    
          @Li_Zero_NUMB AS TransactionCaa_AMNT,   --TransactionCaa_AMNT    
          L.OweTotCaa_AMNT,        --OweTotCaa_AMNT    
          L.AppTotCaa_AMNT,        --AppTotCaa_AMNT    
          @Li_Zero_NUMB AS TransactionUpa_AMNT,   --TransactionUpa_AMNT    
          L.OweTotUpa_AMNT,        --OweTotUpa_AMNT    
          L.AppTotUpa_AMNT,        --AppTotUpa_AMNT    
          @Li_Zero_NUMB AS TransactionUda_AMNT,   --TransactionUda_AMNT    
          L.OweTotUda_AMNT,        --OweTotUda_AMNT    
          L.AppTotUda_AMNT,        --AppTotUda_AMNT    
          @Li_Zero_NUMB AS TransactionIvef_AMNT,   --TransactionIvef_AMNT    
          L.OweTotIvef_AMNT,        --OweTotIvef_AMNT    
          L.AppTotIvef_AMNT,        --AppTotIvef_AMNT    
          @Li_Zero_NUMB AS TransactionMedi_AMNT,   --TransactionMedi_AMNT    
          L.OweTotMedi_AMNT,        --OweTotMedi_AMNT    
          L.AppTotMedi_AMNT,        --AppTotMedi_AMNT    
          @Li_Zero_NUMB AS TransactionFuture_AMNT,  --TransactionFuture_AMNT    
          L.AppTotFuture_AMNT,       --AppTotFuture_AMNT    
          @Li_Zero_NUMB AS TransactionNffc_AMNT,   --TransactionNffc_AMNT    
          L.OweTotNffc_AMNT,        --OweTotNffc_AMNT    
          L.AppTotNffc_AMNT,        --AppTotNffc_AMNT    
          @Li_Zero_NUMB AS TransactionNonIvd_AMNT,  --TransactionNonIvd_AMNT    
          L.OweTotNonIvd_AMNT,       --OweTotNonIvd_AMNT    
          L.AppTotNonIvd_AMNT,       --AppTotNonIvd_AMNT    
          @Ld_Lowdate_DATE AS Batch_DATE,     --Batch_DATE    
          @Lc_Space_TEXT AS SourceBatch_CODE,    
          @Li_Zero_NUMB AS Batch_NUMB,     --Batch_NUMB    
          @Lc_StringZero_TEXT AS SeqReceipt_NUMB,   --SeqReceipt_NUMB    
          @Ld_Lowdate_DATE AS Receipt_DATE,    --Receipt_DATE    
          @Ad_Process_DATE AS Distribute_DATE,   --Distribute_DATE    
          @Lc_TypeRecordOriginal_CODE AS TypeRecord_CODE, --TypeRecord_CODE    
          @Li_PaybackProrate1100_NUMB AS EventFunctionalSeq_NUMB,    --EventFunctionalSeq_NUMB( we have to derive the new event functional sequence number, Currently we are using 1100 - Proration payback)    
          @An_EventGlobalBeginSeq_NUMB AS EventGlobalSeq_NUMB,--EventGlobalSeq_NUMB    
          L.CheckRecipient_ID,       --CheckRecipient_ID    
          L.CheckRecipient_CODE       --CheckRecipient_CODE    
     FROM LSUP_Y1 L    
    WHERE L.Case_IDNO    = @An_Case_IDNO    
   AND L.OrderSeq_NUMB   = @An_OrderSeq_NUMB    
   AND L.ObligationSeq_NUMB = @Ln_ObligationSeq_NUMB_CUR    
      AND L.EventGlobalSeq_NUMB = (SELECT MAX(EventGlobalSeq_NUMB)     
             FROM LSUP_Y1 S    
            WHERE S.Case_IDNO        = L.Case_IDNO    
              AND S.OrderSeq_NUMB       = L.OrderSeq_NUMB    
              AND S.ObligationSeq_NUMB  = @Ln_ObligationSeq_NUMB_CUR)                 
      AND L.SupportYearMonth_NUMB = (SELECT MAX(SupportYearMonth_NUMB)     
              FROM LSUP_Y1 K    
             WHERE K.Case_IDNO    = L.Case_IDNO    
               AND K.OrderSeq_NUMB   = L.OrderSeq_NUMB    
               AND K.ObligationSeq_NUMB = @Ln_ObligationSeq_NUMB_CUR);    
               
	--Temp Code
   SET @Ls_Sql_TEXT = 'BATCH_ONE_TIME_OWIZ_CLEANUP$SP_PROCESS_DIFFERENCE_OWED_AMT_UPDATE_LSUP_CR0346';
   SET @Ls_SqlData_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @An_Case_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @An_OrderSeq_NUMB AS VARCHAR ),'')+ ', ObligationSeq_NUMB = ' + ISNULL(CAST( @Ln_ObligationSeq_NUMB_CUR AS VARCHAR ),'');
   EXEC BATCH_ONE_TIME_OWIZ_CLEANUP$SP_PROCESS_DIFFERENCE_OWED_AMT_UPDATE_LSUP_CR0346
	@An_Case_IDNO                  = @An_Case_IDNO,
	@An_OrderSeq_NUMB              = @An_OrderSeq_NUMB,
	@An_ObligationSeq_NUMB         = @Ln_ObligationSeq_NUMB_CUR,
	@An_EventGlobalSeq_NUMB        = @An_EventGlobalBeginSeq_NUMB,
	@Ad_ObligationEnd_DATE         = '12/31/2013',
	@Ad_Run_DATE				   = @Ad_Process_DATE,
	@Ac_Msg_CODE				   = @Ac_Msg_CODE OUTPUT,
	@As_DescriptionError_TEXT	   = @Ls_ErrorMessage_TEXT OUTPUT;

	IF @Ac_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END
   --Temp Code
               
   END        
      
     
   FETCH NEXT FROM ObligSeq_CUR INTO @Ln_ObligationSeq_NUMB_CUR, @Ld_BeginObligation_DATE_CUR,@Ld_EndObligation_DATE_CUR,@Ln_EventGlobalBeginSeq_NUMB_CUR;
   SET @Ls_Sql_TEXT = 'FetchStatus_QNTY - 2';    
   SET @Ls_Sqldata_TEXT = '' ;     
      SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;    
      SET @Li_CursorCurrentRow_QNTY = @Li_CursorCurrentRow_QNTY + @Li_One_NUMB;    
 END --End of While Loop     
      
    CLOSE ObligSeq_CUR;    
      
    DEALLOCATE ObligSeq_CUR;    
        
    SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;    
      
  END TRY    
    
  BEGIN CATCH    
       
   IF CURSOR_STATUS('LOCAL','ObligSeq_CUR')IN (0,1)    
    BEGIN    
      CLOSE ObligSeq_CUR;      
	  DEALLOCATE ObligSeq_CUR;    
    END    
       
   SET @Ln_Error_NUMB = ERROR_NUMBER();    
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();    
    
   IF @Ln_Error_NUMB <> 50001    
    BEGIN    
     SET @Ls_Errormessage_TEXT = ERROR_MESSAGE();    
    END    
    
   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION    
    @As_Procedure_NAME        = @Ls_Routine_TEXT,    
    @As_ErrorMessage_TEXT     = @Ls_Errormessage_TEXT,    
    @As_Sql_TEXT              = @Ls_Sql_TEXT,    
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,    
    @An_Error_NUMB            = @Ln_Error_NUMB,    
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,    
    @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;    
  END CATCH    
 END 
GO
