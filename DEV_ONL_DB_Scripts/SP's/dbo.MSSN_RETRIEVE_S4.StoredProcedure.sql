/****** Object:  StoredProcedure [dbo].[MSSN_RETRIEVE_S4]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[MSSN_RETRIEVE_S4] (
 @An_MemberMci_IDNO           NUMERIC(10, 0),
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0),
 @Ac_Enumeration_CODE         CHAR(1) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : MSSN_RETRIEVE_S4
  *     DESCRIPTION       : Retrieve Unique Sequence Number that will be generated for any given Transaction on the Table, Type Primary Code to indicate whether this is the Primary SSN of the Member and Verification Code Received for SSN Verification from Member SSN table for Unique Number Assigned by the System to the Member and Unique Sequence Number that will be generated for any given Transaction on the Table.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT @Ac_Enumeration_CODE  = NULL;

  SELECT @Ac_Enumeration_CODE =M.Enumeration_CODE
    FROM MSSN_Y1 M
   WHERE M.MemberMci_IDNO = @An_MemberMci_IDNO
     AND M.TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB
     AND M.EndValidity_DATE = @Ld_High_DATE;
 END; -- END of MSSN_RETRIEVE_S4


GO
