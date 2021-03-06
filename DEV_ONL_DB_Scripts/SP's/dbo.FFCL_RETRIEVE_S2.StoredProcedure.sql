/****** Object:  StoredProcedure [dbo].[FFCL_RETRIEVE_S2]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[FFCL_RETRIEVE_S2] (
 @Ac_Function_CODE CHAR(3),
 @Ac_Action_CODE   CHAR(1),
 @Ac_Reason_CODE   CHAR(5),
 @Ac_Notice_ID     CHAR(8),
 @Ai_Count_QNTY    INT OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : FFCL_RETRIEVE_S2
  *     DESCRIPTION       : Retrieve the record count for a seven CSENET function, Action code & Reason code for the request made and name of the forms for a provided FAR combination.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 24-OCT-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @Ai_Count_QNTY = NULL;

  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT @Ai_Count_QNTY = COUNT(1)
    FROM FFCL_Y1 F
   WHERE F.Function_CODE = @Ac_Function_CODE
     AND F.Action_CODE = @Ac_Action_CODE
     AND F.Reason_CODE = @Ac_Reason_CODE
     AND F.Notice_ID = @Ac_Notice_ID
     AND F.EndValidity_DATE = @Ld_High_DATE;
     
  END; --END OF FFCL_RETRIEVE_S2 


GO
