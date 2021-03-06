/****** Object:  StoredProcedure [dbo].[APMH_RETRIEVE_S3]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[APMH_RETRIEVE_S3](
 @An_Application_IDNO         NUMERIC(15, 0),
 @An_MemberMci_IDNO           NUMERIC(10, 0),
 @Ad_Begin_DATE               DATE OUTPUT,
 @Ad_End_DATE                 DATE OUTPUT,
 @Ac_TypeWelfare_CODE         CHAR(1) OUTPUT,
 @An_CaseWelfare_IDNO         NUMERIC(10, 0) OUTPUT,
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0) OUTPUT
 )
AS
 /*  
  *     PROCEDURE NAME    : APMH_RETRIEVE_S3  
  *     DESCRIPTION       : Retrieve Welfare Type, Welfare Case ID, Begin & End Date of the Public Assistance and Unique Sequence Number generated for any Transaction for an Application ID, Member ID and Member ID is not equal to F9999999.  
  *     DEVELOPED BY      : IMP Team  
  *     DEVELOPED ON      : 22-MAR-2011  
  *     MODIFIED BY       :   
  *     MODIFIED ON       :   
  *     VERSION NO        : 1  
 */
 BEGIN
  SELECT @Ad_Begin_DATE = NULL,
         @Ad_End_DATE = NULL,
         @An_TransactionEventSeq_NUMB = NULL,
         @Ac_TypeWelfare_CODE = NULL,
         @An_CaseWelfare_IDNO = NULL;

  DECLARE @Ld_High_DATE            DATE= '12/31/9999',
          @Ln_MemberMciFoster_IDNO NUMERIC(10) = 0000999998;

  SELECT @Ac_TypeWelfare_CODE = A.TypeWelfare_CODE,
         @An_CaseWelfare_IDNO = A.CaseWelfare_IDNO,
         @Ad_Begin_DATE = A.Begin_DATE,
         @Ad_End_DATE = A.End_DATE,
         @An_TransactionEventSeq_NUMB = A.TransactionEventSeq_NUMB
    FROM APMH_Y1 A
   WHERE A.Application_IDNO = @An_Application_IDNO
     AND A.MemberMci_IDNO = @An_MemberMci_IDNO
     AND A.MemberMci_IDNO != @Ln_MemberMciFoster_IDNO
     AND A.EndValidity_DATE = @Ld_High_DATE;
 END; -- End Of APMH_RETRIEVE_S3


GO
