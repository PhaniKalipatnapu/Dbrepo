/****** Object:  StoredProcedure [dbo].[CFAR_RETRIEVE_S12]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CFAR_RETRIEVE_S12] (
 @Ac_Function_CODE CHAR(3),
 @Ac_Action_CODE   CHAR(1),
 @Ac_Reason_CODE   CHAR(5),
 @Ai_Count_QNTY    INT OUTPUT
 )
AS
 /*    
  *     PROCEDURE NAME    : CFAR_RETRIEVE_S12    
  *     DESCRIPTION       : Retrieve the Row Count for a Function Code, Action Code, Reason Code, and Referral Indicator is Active.    
  *     DEVELOPED BY      : IMP Team    
  *     DEVELOPED ON      : 01-SEP-2011    
  *     MODIFIED BY       :     
  *     MODIFIED ON       :     
  *     VERSION NO        : 1    
  */
 BEGIN
  DECLARE @Lc_RefAssistA_CODE CHAR(1)='A';

  SET @Ai_Count_QNTY = NULL;

  SELECT @Ai_Count_QNTY = COUNT(1)
    FROM CFAR_Y1 C
   WHERE C.Function_CODE = @Ac_Function_CODE
     AND C.Action_CODE = @Ac_Action_CODE
     AND C.Reason_CODE = @Ac_Reason_CODE
     AND C.RefAssist_CODE = @Lc_RefAssistA_CODE;
 END --End of CFAR_RETRIEVE_S12

GO
