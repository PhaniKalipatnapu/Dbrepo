/****** Object:  StoredProcedure [dbo].[STMS_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[STMS_RETRIEVE_S1]
AS
 /*
  *     PROCEDURE NAME    : STMS_RETRIEVE_S1
  *     DESCRIPTION       : Retrieve the default slot timings which will be used in displaying Day view from Schedule Times Reference table.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 26-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SELECT s.SchdTime_DTTM
    FROM STMS_Y1 s;
 END; --END OF STMS_RETRIEVE_S1


GO
