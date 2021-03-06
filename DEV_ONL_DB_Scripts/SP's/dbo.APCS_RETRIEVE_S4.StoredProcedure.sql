/****** Object:  StoredProcedure [dbo].[APCS_RETRIEVE_S4]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[APCS_RETRIEVE_S4](
 @An_TransactionEventSeq_NUMB NUMERIC(19),
 @An_Application_IDNO         NUMERIC(15),
 @Ai_Count_QNTY               INT OUTPUT
 )
AS
 /*
 *     PROCEDURE NAME    : APCS_RETRIEVE_S4
  *     DESCRIPTION       : Retrieve Record Count for an Application ID, Unique Sequence Number generated during Transaction when End Validity Date is equal to High Date.
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
    FROM APCS_Y1 AC
   WHERE AC.Application_IDNO = @An_Application_IDNO
     AND AC.TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB
     AND AC.EndValidity_DATE = @Ld_High_DATE;
 END; --End of APCS_RETRIEVE_S4


GO
