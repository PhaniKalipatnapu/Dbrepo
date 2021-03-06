/****** Object:  StoredProcedure [dbo].[FIPS_RETRIEVE_S10]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[FIPS_RETRIEVE_S10] (
 @Ac_Fips_CODE                CHAR(7),
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0),
 @Ai_Count_QNTY               INT OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : FIPS_RETRIEVE_S10
  *     DESCRIPTION       : Retrives the Row Count for a Given FIPS 
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 09-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @Ai_Count_QNTY = NULL;

  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT @Ai_Count_QNTY = COUNT(1)
    FROM FIPS_Y1 F
   WHERE F.Fips_CODE = @Ac_Fips_CODE
     AND F.TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB
     AND F.EndValidity_DATE = @Ld_High_DATE;
 END; -- END OF FIPS_RETRIEVE_S10


GO
