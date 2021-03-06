/****** Object:  StoredProcedure [dbo].[APMH_UPDATE_S4]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[APMH_UPDATE_S4](
 @An_Application_IDNO         NUMERIC(15, 0),
 @An_MemberMci_IDNO           NUMERIC(10, 0),
 @Ac_TypeWelfare_CODE         CHAR(1),
 @Ad_Begin_DATE               DATE,
 @Ad_End_DATE                 DATE,
 @An_CaseWelfare_IDNO         NUMERIC(10, 0),
 @Ac_SignedOnWorker_ID        CHAR(30),
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0)
 )
AS
 /*    
  *     PROCEDURE NAME    : APMH_UPDATE_S4    
  *     DESCRIPTION       : Updates the enddate validity to current date time for the given Application Id, Member Id, Transaction Event Sequence where enddate validity is highdate.    
  *     DEVELOPED BY      : IMP Team    
  *     DEVELOPED ON      : 22-AUG-2011    
  *     MODIFIED BY       :     
  *     MODIFIED ON       :     
  *     VERSION NO        : 1    
 */
 BEGIN
  DECLARE @Ld_Systemdatetime_DTTM DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
          @Ln_RowsAffected_NUMB   NUMERIC(10),
          @Ld_High_DATE           DATE = '12/31/9999';

  UPDATE APMH_Y1
     SET EndValidity_DATE = @Ld_Systemdatetime_DTTM
  OUTPUT @An_Application_IDNO,
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
         DELETED.WelfareMemberMci_IDNO
  INTO APMH_Y1
   WHERE Application_IDNO = @An_Application_IDNO
     AND MemberMci_IDNO = @An_MemberMci_IDNO;

  SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;

  SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB;
 END; -- End Of APMH_UPDATE_S4


GO
