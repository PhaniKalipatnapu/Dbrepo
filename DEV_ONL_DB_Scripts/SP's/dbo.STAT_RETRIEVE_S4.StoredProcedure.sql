/****** Object:  StoredProcedure [dbo].[STAT_RETRIEVE_S4]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[STAT_RETRIEVE_S4] (
 @Ac_StateFips_CODE CHAR(2),
 @Ac_State_CODE     CHAR(2) OUTPUT,
 @As_State_NAME     VARCHAR(60) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : STAT_RETRIEVE_S4
  *     DESCRIPTION       : Retrieving the state code and State name details.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 11/29/2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1.0
  */
 BEGIN
  SET @Ac_State_CODE = NULL;
  SET @As_State_NAME = NULL;

  SELECT @Ac_State_CODE = S.State_CODE,
         @As_State_NAME = S.State_NAME
    FROM STAT_Y1 S
   WHERE S.StateFips_CODE = @Ac_StateFips_CODE;
 END


GO
