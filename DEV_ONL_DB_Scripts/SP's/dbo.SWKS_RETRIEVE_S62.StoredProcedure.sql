/****** Object:  StoredProcedure [dbo].[SWKS_RETRIEVE_S62]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SWKS_RETRIEVE_S62] (
  @An_Schedule_NUMB      NUMERIC(10, 0),
  @Ac_Exists_INDC        CHAR(1) OUTPUT
 )
AS
 /*
  *  PROCEDURE NAME    : SWKS_RETRIEVE_S62
  *  DESCRIPTION       : Server too busy for an Appointment Schedule Number and Status of the Appointment is Scheduled or Re-Scheduled.
  *  DEVELOPED BY      : IMP Team
  *  DEVELOPED ON      : 06-JUL-2012
  *  MODIFIED BY       : 
  *  MODIFIED ON       : 
  *  VERSION NO        : 1
 */
 BEGIN
 
     DECLARE
	   @Lc_No_TEXT	CHAR(1)	= 'N',
	   @Lc_Yes_TEXT	CHAR(1)	= 'Y';
 
   SET @Ac_Exists_INDC=@Lc_No_TEXT;

  SELECT @Ac_Exists_INDC =@Lc_Yes_TEXT
    FROM SWKS_Y1 S
   WHERE S.Schedule_NUMB = @An_Schedule_NUMB;
     
 END; -- END OF SWKS_RETRIEVE_S62


GO
