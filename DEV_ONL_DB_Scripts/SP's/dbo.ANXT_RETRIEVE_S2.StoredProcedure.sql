/****** Object:  StoredProcedure [dbo].[ANXT_RETRIEVE_S2]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ANXT_RETRIEVE_S2] (
 @Ac_ActivityMajor_CODE CHAR(4)
 )
AS
 /*
  *     PROCEDURE NAME    : ANXT_RETRIEVE_S2
  *     DESCRIPTION       : Fetch  the list of all activities, reasons and next activities for the code which represent the major and minor activity and End Validity date is equal to High date
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 09-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT A1.ActivityMajor_CODE,
         A1.ActivityMinor_CODE,
         A1.Reason_CODE,
         A1.TransactionEventSeq_NUMB,
         A1.ActivityOrder_QNTY,
         A1.ActivityMajorNext_CODE,
         A1.ActivityMinorNext_CODE,
         A1.GROUP_ID,
         A2.DescriptionActivity_TEXT,
         ISNULL(A2.DayToComplete_QNTY,0) AS DayToComplete_QNTY,
         A3.DescriptionActivity_TEXT AS DescriptionNextActivity_TEXT
    FROM ANXT_Y1 A1
         LEFT OUTER JOIN AMNR_Y1 A2
          ON A1.ActivityMinor_CODE = A2.ActivityMinor_CODE
         LEFT OUTER JOIN AMNR_Y1 A3
          ON A3.ActivityMinor_CODE = A1.ActivityMinorNext_CODE
		  -- 13524 - ANXT display issue Fix -Start
          AND A3.EndValidity_DATE = @Ld_High_DATE
		  -- 13524 - ANXT display issue Fix -End
   WHERE A1.ActivityMajor_CODE = @Ac_ActivityMajor_CODE
     AND A1.EndValidity_DATE = @Ld_High_DATE
     AND A2.EndValidity_DATE = @Ld_High_DATE
   ORDER BY A1.ActivityOrder_QNTY,
            A1.ReasonOrder_QNTY;
 END; -- End Of ANXT_RETRIEVE_S2


GO
