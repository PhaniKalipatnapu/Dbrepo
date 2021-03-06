/****** Object:  StoredProcedure [dbo].[MECN_RETRIEVE_S4]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[MECN_RETRIEVE_S4] (
 @An_MemberMci_IDNO           NUMERIC(10, 0),
 @An_Contact_IDNO             NUMERIC(9, 0),
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : MECN_RETRIEVE_S4
  *     DESCRIPTION       : Retrieve Unique Sequence Number that will be generated for any given Transaction on the Table from Member Contacts table for Unique Number Assigned by the System to the Member and ID of the Contact.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 20-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @An_TransactionEventSeq_NUMB = NULL;

  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT @An_TransactionEventSeq_NUMB = M.TransactionEventSeq_NUMB
    FROM MECN_Y1 M
   WHERE M.MemberMci_IDNO = @An_MemberMci_IDNO
     AND M.Contact_IDNO = @An_Contact_IDNO
     AND M.EndValidity_DATE = @Ld_High_DATE;
 END -- END of  MECN_RETRIEVE_S4


GO
