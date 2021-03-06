/****** Object:  StoredProcedure [dbo].[USEM_RETRIEVE_S60]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[USEM_RETRIEVE_S60] (
 @Ac_Worker_ID  CHAR(30),
 @Ai_Count_QNTY INT OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : USEM_RETRIEVE_S60
  *     DESCRIPTION       : Retrieve the Record Count for a Worker ID where Employment end date is greater than or equal to system date and end date validity is high date.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @Ai_Count_QNTY = NULL;

  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT TOP 1 @Ai_Count_QNTY = COUNT(1)
    FROM USEM_Y1 u
   WHERE u.Worker_ID = @Ac_Worker_ID
     AND u.EndEmployment_DATE >= CONVERT(DATE, DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME())
     AND u.EndValidity_DATE = @Ld_High_DATE;
 END; --End of USEM_RETRIEVE_S60


GO
