/****** Object:  StoredProcedure [dbo].[STAT_INSERT_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[STAT_INSERT_S1] (
 @Ac_State_CODE     CHAR(2),
 @As_State_NAME     VARCHAR(60),
 @Ac_StateFips_CODE CHAR(2)
 )
AS
 /*
  *     PROCEDURE NAME    : STAT_INSERT_S1
  *     DESCRIPTION       : Inserting the State details 
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  INSERT STAT_Y1
         (State_CODE,
          State_NAME,
          StateFips_CODE)
  VALUES ( @Ac_State_CODE,
           @As_State_NAME,
           @Ac_StateFips_CODE );
 END; -- END OF STAT_INSERT_S1


GO
