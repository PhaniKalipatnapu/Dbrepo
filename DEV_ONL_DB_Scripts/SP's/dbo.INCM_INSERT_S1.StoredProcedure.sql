/****** Object:  StoredProcedure [dbo].[INCM_INSERT_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[INCM_INSERT_S1] (
 @An_MemberMci_IDNO           NUMERIC(10, 0),
 @Ac_SourceIncome_CODE        CHAR(2),
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0),
 @An_Income_AMNT              NUMERIC(11, 2),
 @Ac_FreqIncome_CODE          CHAR(1),
 @An_OtherParty_IDNO          NUMERIC(9, 0),
 @Ad_Begin_DATE               DATE,
 @Ad_End_DATE                 DATE,
 @Ad_BeginValidity_DATE       DATE,
 @Ac_SignedOnWorker_ID        CHAR(30),
 @Ac_TypeIncome_CODE          CHAR(3)
 )
AS
 /*
 *     PROCEDURE NAME    : INCM_INSERT_S1
  *     DESCRIPTION       : Insert record with new Sequence Event Transaction for a Member Idno, Income Expense Code, Income Expense Type Code and related information.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-SEP-2011
  *     MODIFIED BY       :
  *     MODIFIED ON       :
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ld_Current_DATE DATETIME2(0) = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
          @Ld_High_DATE    DATE ='12/31/9999';

  INSERT INCM_Y1
         (MemberMci_IDNO,
          Income_AMNT,
          FreqIncome_CODE,
          SourceIncome_CODE,
          OtherParty_IDNO,
          Begin_DATE,
          End_DATE,
          BeginValidity_DATE,
          EndValidity_DATE,
          WorkerUpdate_ID,
          TransactionEventSeq_NUMB,
          Update_DTTM,
          TypeIncome_CODE)
  VALUES ( @An_MemberMci_IDNO,
           @An_Income_AMNT,
           @Ac_FreqIncome_CODE,
           @Ac_SourceIncome_CODE,
           @An_OtherParty_IDNO,
           @Ad_Begin_DATE,
           @Ad_End_DATE,
           @Ad_BeginValidity_DATE,
           @Ld_High_DATE,
           @Ac_SignedOnWorker_ID,
           @An_TransactionEventSeq_NUMB,
           @Ld_Current_DATE,
           @Ac_TypeIncome_CODE );
 END; --End of INCM_INSERT_S1


GO
