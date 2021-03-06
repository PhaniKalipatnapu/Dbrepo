/****** Object:  StoredProcedure [dbo].[SLSD_RETRIEVE_S5]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SLSD_RETRIEVE_S5] (
 @An_OthpLocation_IDNO        NUMERIC(9, 0),
 @Ac_Day_CODE                 CHAR(1),
 @Ac_TypeActivity_CODE        CHAR(1),
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0),
 @Ai_Count_QNTY               INT OUTPUT
 )
AS
 /*
  *	PROCEDURE NAME    : SLSD_RETRIEVE_S5
  *	DESCRIPTION       : Returns 1 if any record exists for the given location id,  Weekday , and Proceeding type.
  *	DEVELOPED BY      : IMP Team
  *	DEVELOPED ON      : 02-MAR-2011
  *	MODIFIED BY       : 
  *	MODIFIED ON       : 
  *	VERSION NO        : 1
 */
 BEGIN
  SET @Ai_Count_QNTY = NULL;

  DECLARE @Ld_High_DATE DATE = '12/31/9999';
        

  SELECT @Ai_Count_QNTY = COUNT(1)
    FROM SLSD_Y1 S
   WHERE S.TypeActivity_CODE = @Ac_TypeActivity_CODE
     AND S.OthpLocation_IDNO = @An_OthpLocation_IDNO
     AND S.Day_CODE = @Ac_Day_CODE
     AND S.EndValidity_DATE = @Ld_High_DATE
     AND S.TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB;
 END; -- END OF SLSD_RETRIEVE_S5


GO
