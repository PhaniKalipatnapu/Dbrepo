/****** Object:  StoredProcedure [dbo].[CSPR_RETRIEVE_S3]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CSPR_RETRIEVE_S3] (
 @An_Case_IDNO                NUMERIC(6, 0),
 @Ac_Function_CODE            CHAR(3),
 @Ac_Action_CODE              CHAR(1),
 @Ac_Reason_CODE              CHAR(5),
 @Ac_IVDOutOfStateFips_CODE   CHAR(2),
 @An_RespondentMci_IDNO       NUMERIC(10, 0),
 @An_Request_IDNO             NUMERIC(9, 0) OUTPUT,
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0) OUTPUT,
 @Ad_Generated_DATE           DATE OUTPUT,
 @An_TransHeader_IDNO         NUMERIC(12, 0) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : CSPR_RETRIEVE_S3
  *     DESCRIPTION       : Retrieve Transaction Header Idno, Request Idno, Transaction sequence, Generated Date, and Other State Fips Code for a Case Idno, Function Code, Action Code, Reason Code, and Generated Date.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      :20-OCT-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  SELECT @Ad_Generated_DATE = NULL,
         @An_Request_IDNO = NULL,
         @An_TransactionEventSeq_NUMB = NULL,
         @An_TransHeader_IDNO = NULL;

  DECLARE @Ld_High_DATE    DATE= '12/31/9999',
          @Ld_Current_DATE DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

  SELECT @An_Request_IDNO = a.Request_IDNO,
         @An_TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB,
         @Ad_Generated_DATE = a.Generated_DATE
    FROM CSPR_Y1 a
   WHERE a.Case_IDNO = @An_Case_IDNO
     AND a.Function_CODE = @Ac_Function_CODE
     AND a.Action_CODE = @Ac_Action_CODE
     AND a.Reason_CODE = @Ac_Reason_CODE
     AND a.IVDOutOfStateFips_CODE = @Ac_IVDOutOfStateFips_CODE
     AND a.RespondentMci_IDNO = @An_RespondentMci_IDNO
     AND a.Generated_DATE = @Ld_Current_DATE
     AND a.EndValidity_DATE = @Ld_High_DATE;
 END; -- End of CSPR_RETRIEVE_S3

GO
