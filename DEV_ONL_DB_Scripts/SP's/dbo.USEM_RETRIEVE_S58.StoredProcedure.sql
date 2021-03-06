/****** Object:  StoredProcedure [dbo].[USEM_RETRIEVE_S58]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[USEM_RETRIEVE_S58] (
 @Ac_Worker_ID  CHAR(30),
 @Ai_Count_QNTY INT OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : USEM_RETRIEVE_S58
  *     DESCRIPTION       : Retrieve the Row Count for a Worker Idno.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-MAR-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @Ai_Count_QNTY = NULL;

  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT @Ai_Count_QNTY = COUNT(1)
    FROM USEM_Y1 U
   WHERE U.Worker_ID = @Ac_Worker_ID
     AND U.EndEmployment_DATE = @Ld_High_DATE
     AND U.EndValidity_DATE = @Ld_High_DATE;
 END; --END OF USEM_RETRIEVE_S58



GO
