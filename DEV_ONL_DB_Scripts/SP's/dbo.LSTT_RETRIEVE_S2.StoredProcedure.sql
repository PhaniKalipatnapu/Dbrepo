/****** Object:  StoredProcedure [dbo].[LSTT_RETRIEVE_S2]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[LSTT_RETRIEVE_S2](
 @An_MemberMci_IDNO           NUMERIC(10, 0),
 @Ac_ReferLocate_INDC         CHAR(1) OUTPUT,
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : LSTT_RETRIEVE_S2
  *     DESCRIPTION       : Retrieve whether the referred NCP is located or not for a unique Member ID when End Validity Date is equal to High Date.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-NOV-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @Ac_ReferLocate_INDC = NULL;

  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT @Ac_ReferLocate_INDC = L.ReferLocate_INDC,
         @An_TransactionEventSeq_NUMB = L.TransactionEventSeq_NUMB
    FROM LSTT_Y1 L
   WHERE L.MemberMci_IDNO = @An_MemberMci_IDNO
     AND L.EndValidity_DATE = @Ld_High_DATE;
 END; --End of LSTT_RETRIEVE_S2


GO
