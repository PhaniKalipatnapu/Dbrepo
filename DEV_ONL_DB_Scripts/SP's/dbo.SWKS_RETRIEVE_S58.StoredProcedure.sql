/****** Object:  StoredProcedure [dbo].[SWKS_RETRIEVE_S58]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SWKS_RETRIEVE_S58] (
  @An_Schedule_NUMB              NUMERIC(10, 0),
  @An_TransactionEventSeq_NUMB   NUMERIC(19,0),
  @Ai_Count_QNTY                 INT  OUTPUT 
 )
AS
 /*
  *  PROCEDURE NAME    : SWKS_RETRIEVE_S58
  *  DESCRIPTION       : Concurrency check for an Appointment Schedule Number and Status of the Appointment is Scheduled or Re-Scheduled.
  *  DEVELOPED BY      : IMP Team
  *  DEVELOPED ON      : 13-FEB-2012
  *  MODIFIED BY       : 
  *  MODIFIED ON       : 
  *  VERSION NO        : 1
 */
 BEGIN
   SET @Ai_Count_QNTY=NULL;

  DECLARE @Lc_ApptStatusRescheduled_CODE CHAR(2) = 'RS',
          @Lc_ApptStatusScheduled_CODE   CHAR(2) = 'SC';

  SELECT @Ai_Count_QNTY =COUNT(1)
    FROM SWKS_Y1 S
   WHERE S.Schedule_NUMB = @An_Schedule_NUMB
     AND S.TransactionEventSeq_NUMB=@An_TransactionEventSeq_NUMB
     AND S.ApptStatus_CODE IN (@Lc_ApptStatusScheduled_CODE, @Lc_ApptStatusRescheduled_CODE);
     
 END; -- END OF SWKS_RETRIEVE_S58


GO
