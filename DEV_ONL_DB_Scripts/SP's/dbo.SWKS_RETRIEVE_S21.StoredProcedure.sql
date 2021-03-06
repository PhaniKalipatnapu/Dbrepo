/****** Object:  StoredProcedure [dbo].[SWKS_RETRIEVE_S21]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SWKS_RETRIEVE_S21] (
 @An_Schedule_NUMB     NUMERIC(10, 0),
 @An_Case_IDNO         NUMERIC(6, 0) OUTPUT,
 @Ac_TypeActivity_CODE CHAR(1) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : SWKS_RETRIEVE_S21
  *     DESCRIPTION       : Retrieve Case Idno and Activity Type of the Appointment for an Appointment Schedule Number and Status of the Appointment is Scheduled or Re-Scheduled.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-MAR-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SELECT @Ac_TypeActivity_CODE = NULL,
         @An_Case_IDNO = NULL;

  DECLARE @Lc_ApptStatusRescheduled_CODE CHAR(2) = 'RS',
          @Lc_ApptStatusScheduled_CODE   CHAR(2) = 'SC';

  SELECT @An_Case_IDNO = MAX(S.Case_IDNO),
         @Ac_TypeActivity_CODE = MAX(S.TypeActivity_CODE)
    FROM SWKS_Y1 S
   WHERE S.Schedule_NUMB = @An_Schedule_NUMB
     AND S.ApptStatus_CODE IN (@Lc_ApptStatusScheduled_CODE, @Lc_ApptStatusRescheduled_CODE);
     
 END; -- END OF SWKS_RETRIEVE_S21


GO
