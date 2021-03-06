/****** Object:  StoredProcedure [dbo].[SP_ACCRUAL_NEXT_DATE]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_ACCRUAL_NEXT_DATE]
AS
 BEGIN
  DECLARE @An_Case_IDNO                NUMERIC(10),
          @An_OrderSeq_NUMB            NUMERIC(5),
          @An_ObligationSeq_NUMB       NUMERIC(5),
          @Ac_FreqPeriodic_CODE        CHAR(1) ='M',
          @An_Periodic_AMNT            NUMERIC(11, 2),
          @An_ExpectToPay_AMNT         NUMERIC(11, 2),
          @Ad_BeginObligation_DATE     DATE,
          @Ad_EndObligation_DATE       DATE,
          @Ad_AccrualEnd_DATE          DATE,
          @Ad_Conv_AccrualNext_DATE    DATE,
          @Ad_AccrualNext_DATE         DATE,
          @Ad_AccrualLast_DATE         DATE,
          @Ad_Conv_AccrualLast_DATE    DATE,
          @An_TransactionCurSup_AMNT   NUMERIC(11, 2),
          @An_TransactionExptPay_AMNT  NUMERIC(11, 2),
          @An_MtdAccrual_AMNT          NUMERIC(11, 2),
          @Ac_MtdProcess_INDC          CHAR(1),
          @Ac_Msg_CODE                 CHAR(1),
          @As_DescriptionError_TEXT    VARCHAR(4000),
          @Li_FetchStatus_QNTY         SMALLINT,
          @Ld_RUN_DATE                 DATE='10/31/2013',
          @Ln_MemberMci_IDNO           NUMERIC(10),
          @Lc_TypeDebt_CODE            CHAR(5),
          @Ln_EventGlobalBeginSeq_NUMB NUMERIC(19),
          @Ln_EventGlobalEndSeq_NUMB   NUMERIC(19),
          @Ld_BeginValidity_DATE       DATE,
          @Ld_EndValidity_DATE         DATE

  --drop table Accrual_P1
  /*IF EXISTS (SELECT 1
               FROM SYS.OBJECTS
              WHERE NAME = 'Accrual_P1'
                AND TYPE = 'U')
   BEGIN
    DROP TABLE Accrual_P1
   END
*/

/*IF OBJECT_ID('tempdb..Accrual_P1') IS NOT NULL
    BEGIN
     DROP TABLE Accrual_P1;
    END
   */ 
  
  DECLARE Oble_CUR INSENSITIVE CURSOR FOR
   SELECT Case_IDNO,
          OrderSeq_NUMB,
          ObligationSeq_NUMB,
          FreqPeriodic_CODE,
          Periodic_AMNT,
          ExpectToPay_AMNT,
          BeginObligation_DATE,
          EndObligation_DATE,
          EndObligation_DATE,
          BeginObligation_DATE,
          AccrualNext_DATE Conv_AccrualNext_DATE,
          BeginObligation_DATE,--AccrualNext_DATE,
          MemberMci_IDNO,
          TypeDebt_CODE,
          EventGlobalBeginSeq_NUMB,
          EventGlobalEndSeq_NUMB,
          BeginValidity_DATE,
          EndValidity_DATE,
          AccrualLast_DATE Conv_AccrualLast_DATE
     FROM oble_y1
    WHERE endvalidity_date = '12/31/9999'
      AND FreqPeriodic_CODE <> 'O'
      AND EndObligation_DATE > '10/31/2013'
       
   OPEN Oble_CUR;

  FETCH NEXT FROM Oble_CUR INTO @An_Case_IDNO, @An_OrderSeq_NUMB, @An_ObligationSeq_NUMB, @Ac_FreqPeriodic_CODE, @An_Periodic_AMNT, @An_ExpectToPay_AMNT, @Ad_BeginObligation_DATE, @Ad_EndObligation_DATE, @Ad_AccrualEnd_DATE, @Ad_AccrualLast_DATE, @Ad_Conv_AccrualNext_DATE, @Ad_AccrualNext_DATE, @Ln_MemberMci_IDNO, @Lc_TypeDebt_CODE, @Ln_EventGlobalBeginSeq_NUMB, @Ln_EventGlobalEndSeq_NUMB, @Ld_BeginValidity_DATE, @Ld_EndValidity_DATE, @Ad_Conv_AccrualLast_DATE

  SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;

  WHILE @Li_FetchStatus_QNTY = 0
   BEGIN
    WHILE @Ad_AccrualNext_DATE <='09/30/2013'
     BEGIN
      EXECUTE BATCH_COMMON$SP_ACCRUAL
       @Ac_FreqPeriodic_CODE       = @Ac_FreqPeriodic_CODE,
       @An_Periodic_AMNT           = @An_Periodic_AMNT,
       @An_ExpectToPay_AMNT        = @An_ExpectToPay_AMNT,
       @Ad_BeginObligation_DATE    = @Ad_BeginObligation_DATE,
       @Ad_EndObligation_DATE      = @Ad_EndObligation_DATE,
       @Ad_AccrualEnd_DATE         = @Ad_EndObligation_DATE,
       @Ad_AccrualNext_DATE        = @Ad_AccrualNext_DATE OUTPUT,
       @Ad_AccrualLast_DATE        = @Ad_AccrualLast_DATE OUTPUT,
       @An_TransactionCurSup_AMNT  = @An_TransactionCurSup_AMNT OUTPUT,
       @An_TransactionExptPay_AMNT = @An_TransactionExptPay_AMNT OUTPUT,
       @An_MtdAccrual_AMNT         = @An_MtdAccrual_AMNT OUTPUT,
       @Ac_MtdProcess_INDC         = @Ac_MtdProcess_INDC OUTPUT,
       @Ac_Msg_CODE                = @Ac_Msg_CODE OUTPUT,
       @As_DescriptionError_TEXT   = @As_DescriptionError_TEXT OUTPUT
     END

    
   update oble_y1
    set AccrualNext_DATE=@Ad_AccrualNext_DATE, AccrualLast_DATE=@Ad_AccrualLast_DATE
    where Endvalidity_date='12/31/9999' and 
    Case_IDNO = @An_Case_IDNO and 
    OrderSeq_NUMB =@An_OrderSeq_NUMB and ObligationSeq_NUMB=@An_ObligationSeq_NUMB
    
    INSERT INTO Accrual_P1
    SELECT @An_Case_IDNO,
           @An_OrderSeq_NUMB,
           @An_ObligationSeq_NUMB,
           @Ac_FreqPeriodic_CODE,
           @An_Periodic_AMNT,
           @An_ExpectToPay_AMNT,
           @Ad_BeginObligation_DATE,
           @Ad_EndObligation_DATE,
           @Ad_AccrualNext_DATE,
           @Ad_Conv_AccrualNext_DATE,
           @Ad_AccrualLast_DATE,
           @Ad_Conv_AccrualLast_DATE,
           @Ln_MemberMci_IDNO,
           @Lc_TypeDebt_CODE,
           @Ln_EventGlobalBeginSeq_NUMB,
           @Ln_EventGlobalEndSeq_NUMB,
           @Ld_BeginValidity_DATE,
           @Ld_EndValidity_DATE

    FETCH NEXT FROM Oble_CUR INTO @An_Case_IDNO, @An_OrderSeq_NUMB, @An_ObligationSeq_NUMB, @Ac_FreqPeriodic_CODE, @An_Periodic_AMNT, @An_ExpectToPay_AMNT, @Ad_BeginObligation_DATE, @Ad_EndObligation_DATE, @Ad_AccrualEnd_DATE, @Ad_AccrualLast_DATE, @Ad_Conv_AccrualNext_DATE, @Ad_AccrualNext_DATE, @Ln_MemberMci_IDNO, @Lc_TypeDebt_CODE, @Ln_EventGlobalBeginSeq_NUMB, @Ln_EventGlobalEndSeq_NUMB, @Ld_BeginValidity_DATE, @Ld_EndValidity_DATE, @Ad_Conv_AccrualLast_DATE

    SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
   END

 
 END
GO
