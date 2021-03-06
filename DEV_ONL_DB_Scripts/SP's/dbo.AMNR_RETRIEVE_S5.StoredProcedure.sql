/****** Object:  StoredProcedure [dbo].[AMNR_RETRIEVE_S5]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[AMNR_RETRIEVE_S5] (
 @Ac_ActivityMinor_CODE       CHAR(5),
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0)
 )
AS
 /*
  *     PROCEDURE NAME    : AMNR_RETRIEVE_S5
  *     DESCRIPTION       : Retrieves Activity information from logically deleted record for the given Minor Activity Code 
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 10-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SELECT A.ActivityMinor_CODE,
         A.DayAlertWarn_QNTY,
         A.ScreenFunction_CODE,
         A.BusinessDays_INDC,
		 A.Element_ID
    FROM AMNR_Y1 A
   WHERE A.ActivityMinor_CODE = @Ac_ActivityMinor_CODE
     AND A.TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB;
 END; --End Of AMNR_RETRIEVE_S5

GO
