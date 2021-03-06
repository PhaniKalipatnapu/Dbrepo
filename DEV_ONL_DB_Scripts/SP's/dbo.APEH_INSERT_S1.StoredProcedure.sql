/****** Object:  StoredProcedure [dbo].[APEH_INSERT_S1]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[APEH_INSERT_S1](
 @An_Application_IDNO         NUMERIC(15, 0),
 @An_MemberMci_IDNO           NUMERIC(10, 0),
 @An_OthpEmpl_IDNO            NUMERIC(9, 0),
 @Ac_FreqIncome_CODE          CHAR(1),
 @Ac_TypeIncome_CODE          CHAR(2),
 @An_IncomeGross_AMNT         NUMERIC(11, 2),
 @Ad_BeginEmployment_DATE     DATE,
 @Ad_EndEmployment_DATE       DATE,
 @Ac_ContactWork_INDC         CHAR(1),
 @Ac_SignedOnWorker_ID        CHAR(30),
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0),
 @Ac_TypeOccupation_CODE      CHAR(3),
 @Ac_MemberAddress_CODE       CHAR(1),
 @Ad_EmployerAddressAsOf_DATE DATE
 )
AS
 /*              
  *     PROCEDURE NAME    : APEH_INSERT_S1              
  *     DESCRIPTION       : Inserts the address details for a particular Member Id.                   
  *     DEVELOPED BY      : IMP Team              
  *     DEVELOPED ON      : 22-AUG-2011              
  *     MODIFIED BY       :               
  *     MODIFIED ON       :               
  *     VERSION NO        : 1              
 */
 BEGIN
  DECLARE @Ld_Systemdatetime_DTTM DATETIME2 = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
          @Ld_High_DATE           DATE = '12/31/9999';

  INSERT APEH_Y1
         (Application_IDNO,
          MemberMci_IDNO,
          OthpEmpl_IDNO,
          FreqIncome_CODE,
          TypeIncome_CODE,
          IncomeGross_AMNT,
          BeginEmployment_DATE,
          EndEmployment_DATE,
          ContactWork_INDC,
          BeginValidity_DATE,
          EndValidity_DATE,
          Update_DTTM,
          WorkerUpdate_ID,
          TransactionEventSeq_NUMB,
          TypeOccupation_CODE,
          MemberAddress_CODE,
          EmployerAddressAsOf_DATE)
  VALUES ( @An_Application_IDNO,
           @An_MemberMci_IDNO,
           @An_OthpEmpl_IDNO,
           @Ac_FreqIncome_CODE,
           @Ac_TypeIncome_CODE,
           @An_IncomeGross_AMNT,
           @Ad_BeginEmployment_DATE,
           @Ad_EndEmployment_DATE,
           @Ac_ContactWork_INDC,
           @Ld_Systemdatetime_DTTM,
           @Ld_High_DATE,
           @Ld_Systemdatetime_DTTM,
           @Ac_SignedOnWorker_ID,
           @An_TransactionEventSeq_NUMB,
           @Ac_TypeOccupation_CODE,
           @Ac_MemberAddress_CODE,
           @Ad_EmployerAddressAsOf_DATE );
 END; -- End Of APEH_INSERT_S1


GO
