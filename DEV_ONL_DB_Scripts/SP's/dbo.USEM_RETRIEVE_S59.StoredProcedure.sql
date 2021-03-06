/****** Object:  StoredProcedure [dbo].[USEM_RETRIEVE_S59]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[USEM_RETRIEVE_S59] (
 @An_Schedule_NUMB NUMERIC(10, 0),
 @An_Case_IDNO     NUMERIC(6, 0),
 @Ac_Worker_ID     CHAR(30) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : USEM_RETRIEVE_S59
  *     DESCRIPTION       : Retrieve the Highest Worker ID from User Master for a Worker ID retrieved from Schedule details for a Case ID, Worker ID is not empty and Schedule Number.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @Ac_Worker_ID = NULL;

  DECLARE @Lc_Space_TEXT CHAR(1) = ' ';

  SELECT TOP 1 @Ac_Worker_ID = MAX(u.Worker_ID)
    FROM USEM_Y1 u
   WHERE u.Worker_ID IN (SELECT s.Worker_ID
                           FROM SWKS_Y1 s
                          WHERE s.Schedule_NUMB = @An_Schedule_NUMB
                            AND s.Case_IDNO = @An_Case_IDNO
                            AND s.Worker_ID != @Lc_Space_TEXT);
 END; --End of USEM_RETRIEVE_S59


GO
