/****** Object:  StoredProcedure [dbo].[DSBC_RETRIEVE_S2]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DSBC_RETRIEVE_S2]
 @Ad_Disburse_DATE       DATETIME2(0),
 @An_DisburseSeq_NUMB    NUMERIC(22, 0),
 @Ac_CheckRecipient_CODE CHAR(1),
 @Ac_CheckRecipient_ID   CHAR(10),
 @Ai_Count_QNTY          SMALLINT OUTPUT
AS
 /*
   *     PROCEDURE NAME    : DSBC_RETRIEVE_S2
   *     DESCRIPTION       : Check Record Exists in DSBC
   *     DEVELOPED BY      : IMP Team
   *     DEVELOPED ON      : 14-FEB-2012
   *     MODIFIED BY       : 
   *     MODIFIED ON       : 
   *     VERSION NO        : 1
  */
 BEGIN
  SET @Ai_Count_QNTY = NULL;

  SELECT @Ai_Count_QNTY = COUNT(1)
    FROM DSBC_Y1 DS
   WHERE DS.CheckRecipient_ID = @Ac_CheckRecipient_ID
     AND DS.CheckRecipient_CODE = @Ac_CheckRecipient_CODE
     AND DS.Disburse_DATE = @Ad_Disburse_DATE
     AND DS.DisburseSeq_NUMB = @An_DisburseSeq_NUMB;
 END


GO
