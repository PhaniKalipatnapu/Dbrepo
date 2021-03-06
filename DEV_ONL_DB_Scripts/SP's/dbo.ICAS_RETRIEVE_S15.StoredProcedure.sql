/****** Object:  StoredProcedure [dbo].[ICAS_RETRIEVE_S15]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ICAS_RETRIEVE_S15] (
 @An_Case_IDNO                NUMERIC(6, 0),
 @Ac_IVDOutOfStateFips_CODE   CHAR(2),
 @Ac_Reason_CODE              CHAR(5),
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0),
 @An_RespondentMci_IDNO       NUMERIC(10, 0),
 @Ai_Count_QNTY               INT OUTPUT
 )
AS
 /*
 *      PROCEDURE NAME    : ICAS_RETRIEVE_S15
  *     DESCRIPTION       : To Check whether Given Case exists in Interstate Case Table.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 04-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @Ai_Count_QNTY = NULL;

  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT @Ai_Count_QNTY = COUNT(1)
    FROM ICAS_Y1 i
   WHERE i.Case_IDNO = @An_Case_IDNO
     AND i.IVDOutOfStateFips_CODE = @Ac_IVDOutOfStateFips_CODE
     AND i.Reason_CODE = @Ac_Reason_CODE
     AND i.TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB
     AND i.RespondentMci_IDNO=@An_RespondentMci_IDNO 
     AND i.EndValidity_DATE = @Ld_High_DATE;
 END; -- END OF ICAS_RETRIEVE_S15

GO
