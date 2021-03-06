/****** Object:  StoredProcedure [dbo].[FFCL_RETRIEVE_S8]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[FFCL_RETRIEVE_S8] (
 @Ac_Function_CODE CHAR(3),
 @Ac_Action_CODE   CHAR(1),
 @Ac_Reason_CODE   CHAR(5),
 @Ai_Count_QNTY    INT OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : FFCL_RETRIEVE_S8
  *     DESCRIPTION       : Retrieve the Notice Idno for a Function Code, Action Code, and Reason Code.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 04-OCT-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  SET @Ai_Count_QNTY = NULL;

  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT @Ai_Count_QNTY = COUNT(1)
    FROM FFCL_Y1 f
   WHERE f.Function_CODE = @Ac_Function_CODE
     AND f.Action_CODE = @Ac_Action_CODE
     AND f.Reason_CODE = @Ac_Reason_CODE
     AND f.EndValidity_DATE = @Ld_High_DATE;
 END; -- End of FFCL_RETRIEVE_S8

GO
