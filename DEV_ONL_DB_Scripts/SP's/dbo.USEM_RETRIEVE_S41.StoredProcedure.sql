/****** Object:  StoredProcedure [dbo].[USEM_RETRIEVE_S41]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[USEM_RETRIEVE_S41] (
 @Ac_Last_NAME  CHAR(20),
 @Ai_Count_QNTY INT OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : USEM_RETRIEVE_S41
  *     DESCRIPTION       : Get Worker Count with Last Name
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 10/13/2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1.0
  */
 BEGIN
  SET @Ai_Count_QNTY = NULL;

  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT @Ai_Count_QNTY = COUNT(1)
    FROM USEM_Y1 U
   WHERE U.Last_NAME = @Ac_Last_NAME
     AND U.EndValidity_DATE = @Ld_High_DATE;
 END


GO
