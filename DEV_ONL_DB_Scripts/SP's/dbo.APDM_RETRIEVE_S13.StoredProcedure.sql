/****** Object:  StoredProcedure [dbo].[APDM_RETRIEVE_S13]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[APDM_RETRIEVE_S13](
 @An_Application_IDNO           NUMERIC(15, 0),
 @An_MemberMci_IDNO             NUMERIC(10, 0),
 @An_TransactionEventSeq_NUMB   NUMERIC(19, 0),
 @Ac_EverReceivedMedicaid_INDC  CHAR(1) OUTPUT,
 @Ac_ChildCoveredInsurance_INDC CHAR(1) OUTPUT,
 @An_MemberMciKey_IDNO          NUMERIC(10, 0) OUTPUT
 )
AS
 /*      
  *     PROCEDURE NAME    : APDM_RETRIEVE_S13      
  *     DESCRIPTION       : Retrieves the medicaid and insurance details for the respective application and member.
  *     DEVELOPED BY      : IMP Team      
  *     DEVELOPED ON      : 12-AUG-2011      
  *     MODIFIED BY       :       
  *     MODIFIED ON       :       
  *     VERSION NO        : 1      
 */
 BEGIN
  SELECT @Ac_EverReceivedMedicaid_INDC = NULL,
         @Ac_ChildCoveredInsurance_INDC = NULL;

  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT @Ac_EverReceivedMedicaid_INDC = A.EverReceivedMedicaid_INDC,
         @Ac_ChildCoveredInsurance_INDC = A.ChildCoveredInsurance_INDC,
		 @An_MemberMciKey_IDNO = A.MemberMci_IDNO
    FROM APDM_Y1 A
   WHERE A.Application_IDNO = @An_Application_IDNO
     AND A.MemberMci_IDNO = @An_MemberMci_IDNO
     AND A.EndValidity_DATE = @Ld_High_DATE
     AND A.TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB;
 END; -- End Of APDM_RETRIEVE_S13

GO
