/****** Object:  StoredProcedure [dbo].[APCM_RETRIEVE_S10]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[APCM_RETRIEVE_S10](
 @An_TransactionEventSeq_NUMB NUMERIC(19),
 @An_Application_IDNO         NUMERIC(15),
 @An_MemberMci_IDNO           NUMERIC(10),
 @Ai_Count_QNTY               INT OUTPUT
 )
AS
 /*
 *     PROCEDURE NAME    : APCM_RETRIEVE_S10
  *     DESCRIPTION       : gets the record count for the given Application Id, Member Id, Transaction Event sequence.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-MAR-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @Ai_Count_QNTY = NULL;

  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT @Ai_Count_QNTY = COUNT(1)
    FROM APCM_Y1 AC
   WHERE AC.Application_IDNO = @An_Application_IDNO
     AND AC.MemberMci_IDNO = @An_MemberMci_IDNO
     AND AC.EndValidity_DATE = @Ld_High_DATE
     AND AC.TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB;
 END; --End of APCM_RETRIEVE_S10


GO
