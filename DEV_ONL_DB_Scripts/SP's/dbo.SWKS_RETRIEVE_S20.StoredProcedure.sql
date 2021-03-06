/****** Object:  StoredProcedure [dbo].[SWKS_RETRIEVE_S20]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SWKS_RETRIEVE_S20] (
 @An_Schedule_NUMB				NUMERIC(10),
 @An_Case_IDNO					NUMERIC(6)	OUTPUT,
 @Ac_ActivityMajor_CODE			CHAR(4)		OUTPUT,
 @Ad_Schedule_DATE				DATE		OUTPUT,
 @Ac_TypeActivity_CODE			CHAR(1)		OUTPUT,
 @Ac_TypeFamisProceeding_CODE	CHAR(5)		OUTPUT,
 @An_TransactionEventSeq_NUMB	NUMERIC(19) OUTPUT 
 )
AS
 /*
  *     PROCEDURE NAME    : SWKS_RETRIEVE_S20
  *     DESCRIPTION       : Retrieve the first Appointment Date, Major Activity Code, Case Idno, FAMIS Proceeding type and 
							current transaction event sequence number for a Schedule Number.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-MAR-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  SELECT @Ad_Schedule_DATE = NULL,
         @Ac_ActivityMajor_CODE = NULL,
         @An_Case_IDNO = NULL,
         @Ac_TypeActivity_CODE=NULL;

  SELECT TOP 1 @Ad_Schedule_DATE			= S.Schedule_DATE,
               @Ac_ActivityMajor_CODE		= S.ActivityMajor_CODE,
               @An_Case_IDNO				= S.Case_IDNO,
               @Ac_TypeActivity_CODE		= s.TypeActivity_CODE,
               @Ac_TypeFamisProceeding_CODE = s.TypeFamisProceeding_CODE,
               @An_TransactionEventSeq_NUMB = s.TransactionEventSeq_NUMB
    FROM SWKS_Y1 S
   WHERE S.Schedule_NUMB = @An_Schedule_NUMB;
 END; --END OF  SWKS_RETRIEVE_S20


GO
