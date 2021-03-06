/****** Object:  StoredProcedure [dbo].[APDM_UPDATE_S2]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[APDM_UPDATE_S2] (
 @An_Application_IDNO           NUMERIC(15, 0),
 @An_MemberMci_IDNO             NUMERIC(10, 0),
 @Ac_EverReceivedMedicaid_INDC  CHAR(1),
 @Ac_ChildCoveredInsurance_INDC CHAR(1),
 @An_TransactionEventSeq_NUMB   NUMERIC(19, 0)
 )
AS
 /*       
  *     PROCEDURE NAME    : APDM_UPDATE_S2          
  *     DESCRIPTION       : Logically delete the valid record for a Member, Unique Sequence Number when end validity date is equal to high date.             
  *     DEVELOPED BY      : IMP Team          
  *     DEVELOPED ON      : 22-AUG-2011          
  *     MODIFIED BY       :           
  *     MODIFIED ON       :           
  *     VERSION NO        : 1          
 */
 BEGIN
  DECLARE @Ld_High_DATE         DATE = '12/31/9999',
          @Ln_RowsAffected_NUMB NUMERIC(10);

  UPDATE APDM_Y1
     SET EverReceivedMedicaid_INDC = @Ac_EverReceivedMedicaid_INDC,
         ChildCoveredInsurance_INDC = @Ac_ChildCoveredInsurance_INDC
   WHERE Application_IDNO = @An_Application_IDNO
     AND MemberMci_IDNO = @An_MemberMci_IDNO
     AND TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB
     AND EndValidity_DATE = @Ld_High_DATE;

  SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;

  SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB;
 END; -- End Of APDM_UPDATE_S2


GO
