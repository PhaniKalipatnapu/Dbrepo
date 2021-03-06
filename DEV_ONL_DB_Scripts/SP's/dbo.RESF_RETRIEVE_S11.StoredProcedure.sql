/****** Object:  StoredProcedure [dbo].[RESF_RETRIEVE_S11]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RESF_RETRIEVE_S11] (
 @Ac_Process_ID	CHAR(10),
 @Ac_Reason_CODE CHAR(5),
 @Ac_Type_CODE	CHAR(5),
 @Ai_Count_QNTY  INT OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : RESF_RETRIEVE_S11
  *     DESCRIPTION       : Retrieve the Row Count for a Process number, Reason and specified Type . 
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 09-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @Ai_Count_QNTY = NULL;

  SELECT @Ai_Count_QNTY = COUNT (1)
    FROM RESF_Y1 R
   WHERE R.Process_ID = @Ac_Process_ID
     AND R.Type_CODE = @Ac_Type_CODE
     AND R.Reason_CODE = @Ac_Reason_CODE;
 END; -- End of RESF_RETRIEVE_S11

GO
