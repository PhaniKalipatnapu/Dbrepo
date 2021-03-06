/****** Object:  StoredProcedure [dbo].[STAT_RETRIEVE_S2]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[STAT_RETRIEVE_S2]
AS
 /*
 *      PROCEDURE NAME    : STAT_RETRIEVE_S2
  *     DESCRIPTION       : Procedure used to Populate State Lov.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : OCT-3-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SELECT s.StateFips_CODE,
         s.State_NAME
    FROM STAT_Y1 s
   ORDER BY State_NAME;
 END -- END OF STAT_RETRIEVE_S2

GO
