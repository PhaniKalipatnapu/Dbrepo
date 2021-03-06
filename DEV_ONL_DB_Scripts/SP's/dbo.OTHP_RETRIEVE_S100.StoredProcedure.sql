/****** Object:  StoredProcedure [dbo].[OTHP_RETRIEVE_S100]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[OTHP_RETRIEVE_S100] (
 @Ac_TypeOthp_CODE CHAR(1),
 @Ac_State_ADDR    CHAR(2),
 @Ai_Count_QNTY    INT OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : OTHP_RETRIEVE_S100
  *     DESCRIPTION       : Retrieve the row count for an Other Party Type and State.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 21-SEP-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @Ai_Count_QNTY = NULL;

  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT @Ai_Count_QNTY = COUNT(1)
    FROM OTHP_Y1 O
   WHERE O.TypeOthp_CODE = @Ac_TypeOthp_CODE
     AND O.State_ADDR = @Ac_State_ADDR
     AND O.EndValidity_DATE = @Ld_High_DATE;
 END; --END OF OTHP_RETRIEVE_S100 



GO
