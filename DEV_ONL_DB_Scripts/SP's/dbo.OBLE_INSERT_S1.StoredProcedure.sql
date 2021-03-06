/****** Object:  StoredProcedure [dbo].[OBLE_INSERT_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[OBLE_INSERT_S1] (
 @An_Case_IDNO                NUMERIC(6, 0),
 @An_OrderSeq_NUMB            NUMERIC(2, 0),
 @An_ObligationSeq_NUMB       NUMERIC(2, 0),
 @Ad_BeginObligation_DATE     DATE,
 @An_EventGlobalBeginSeq_NUMB NUMERIC(19, 0),
 @An_MemberMci_IDNO           NUMERIC(10, 0),
 @Ac_TypeDebt_CODE            CHAR(2),
 @Ac_Fips_CODE                CHAR(7),
 @Ac_FreqPeriodic_CODE        CHAR(1),
 @An_Periodic_AMNT            NUMERIC(11, 2),
 @An_ExpectToPay_AMNT         NUMERIC(11, 2),
 @Ac_ExpectToPay_CODE         CHAR(1),
 @Ac_ReasonChange_CODE        CHAR(2),
 @Ad_EndObligation_DATE       DATE,
 @Ad_AccrualLast_DATE         DATE,
 @Ad_AccrualNext_DATE         DATE,
 @Ac_CheckRecipient_ID        CHAR(10),
 @Ac_CheckRecipient_CODE      CHAR(1),
 @Ad_BeginValidity_DATE       DATE
 )
AS
 /*
  *     PROCEDURE NAME    : OBLE_INSERT_S1
  *     DESCRIPTION       : Inserting the record into the OBLE_Y1.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 22-DEC-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Li_Zero_NUMB SMALLINT = 0,
          @Ld_High_DATE DATE = '12/31/9999';

  INSERT OBLE_Y1
         (Case_IDNO,
          OrderSeq_NUMB,
          ObligationSeq_NUMB,
          MemberMci_IDNO,
          TypeDebt_CODE,
          Fips_CODE,
          FreqPeriodic_CODE,
          Periodic_AMNT,
          ExpectToPay_AMNT,
          ExpectToPay_CODE,
          ReasonChange_CODE,
          BeginObligation_DATE,
          EndObligation_DATE,
          AccrualLast_DATE,
          AccrualNext_DATE,
          CheckRecipient_ID,
          CheckRecipient_CODE,
          EventGlobalBeginSeq_NUMB,
          EventGlobalEndSeq_NUMB,
          BeginValidity_DATE,
          EndValidity_DATE)
  VALUES ( @An_Case_IDNO,
           @An_OrderSeq_NUMB,
           @An_ObligationSeq_NUMB,
           @An_MemberMci_IDNO,
           @Ac_TypeDebt_CODE,
           @Ac_Fips_CODE,
           @Ac_FreqPeriodic_CODE,
           @An_Periodic_AMNT,
           @An_ExpectToPay_AMNT,
           @Ac_ExpectToPay_CODE,
           @Ac_ReasonChange_CODE,
           @Ad_BeginObligation_DATE,
           @Ad_EndObligation_DATE,
           @Ad_AccrualLast_DATE,
           @Ad_AccrualNext_DATE,
           @Ac_CheckRecipient_ID,
           @Ac_CheckRecipient_CODE,
           @An_EventGlobalBeginSeq_NUMB,
           @Li_Zero_NUMB,
           @Ad_BeginValidity_DATE,
           @Ld_High_DATE );
 END; --END OF OBLE_INSERT_S1 

GO
