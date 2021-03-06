/****** Object:  StoredProcedure [dbo].[APMH_INSERT_S1]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[APMH_INSERT_S1](
 @An_Application_IDNO         NUMERIC(15, 0),
 @An_MemberMci_IDNO           NUMERIC(10, 0),
 @Ac_TypeWelfare_CODE         CHAR(1),
 @Ad_Begin_DATE               DATE,
 @Ad_End_DATE                 DATE,
 @An_CaseWelfare_IDNO         NUMERIC(10, 0),
 @Ac_SignedOnWorker_ID        CHAR(30),
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0),
 @An_WelfareMemberMci_IDNO    NUMERIC(10, 0)
 )
AS
 /*    
  *     PROCEDURE NAME    : APMH_INSERT_S1    
  *     DESCRIPTION       : Inserts the welfare information details of the member.     
  *     DEVELOPED BY      : IMP Team    
  *     DEVELOPED ON      : 29-AUG-2011    
  *     MODIFIED BY       :     
  *     MODIFIED ON       :     
  *     VERSION NO        : 1    
 */
 BEGIN
  DECLARE @Ld_Systemdatetime_DTTM DATETIME2 = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
          @Ld_High_DATE           DATE = '12/31/9999';

  INSERT APMH_Y1
         (Application_IDNO,
          MemberMci_IDNO,
          TypeWelfare_CODE,
          Begin_DATE,
          End_DATE,
          CaseWelfare_IDNO,
          BeginValidity_DATE,
          EndValidity_DATE,
          Update_DTTM,
          WorkerUpdate_ID,
          TransactionEventSeq_NUMB,
          WelfareMemberMci_IDNO)
  VALUES ( @An_Application_IDNO,
           @An_MemberMci_IDNO,
           @Ac_TypeWelfare_CODE,
           @Ad_Begin_DATE,
           @Ad_End_DATE,
           @An_CaseWelfare_IDNO,
           @Ld_Systemdatetime_DTTM,
           @Ld_High_DATE,
           @Ld_Systemdatetime_DTTM,
           @Ac_SignedOnWorker_ID,
           @An_TransactionEventSeq_NUMB,
           @An_WelfareMemberMci_IDNO);
 END; -- End Of APMH_INSERT_S1


GO
