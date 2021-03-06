/****** Object:  StoredProcedure [dbo].[IVMG_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[IVMG_RETRIEVE_S1]  

     @An_CaseWelfare_IDNO                  NUMERIC(10)              ,
     @Ac_WelfareElig_CODE                  CHAR(1)               ,
     @Ai_Count_QNTY                        NUMERIC(6,0)/*TODO: Arg/Var Names need to analyzed and changed Manually*/             OUTPUT
AS

/*
*     PROCEDURE NAME    : IVMG_RETRIEVE_S1
*     DESCRIPTION       : Gets the record count for the given WelfareCase Idno and Indicator to check if a case is eligible for Welfare.
*     DEVELOPED BY      : Imp Team
*     DEVELOPED ON      : 01-19-2012
*     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/

   BEGIN

      SET @Ai_Count_QNTY = NULL

      SELECT @Ai_Count_QNTY = COUNT(1)
      FROM IVMG_Y1
      WHERE IVMG_Y1.CaseWelfare_IDNO = @An_CaseWelfare_IDNO AND IVMG_Y1.WelfareElig_CODE = @Ac_WelfareElig_CODE;

                  
END


GO
