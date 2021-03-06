/****** Object:  StoredProcedure [dbo].[DMJR_RETRIEVE_S15]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DMJR_RETRIEVE_S15] (
 @An_OthpSource_IDNO NUMERIC(10),
 @Ai_Count_QNTY      INT OUTPUT
 )
AS
 /*  
  *     PROCEDURE NAME    : DMJR_RETRIEVE_S15  
  *     DESCRIPTION       : Retrieve the Row COUNT for the given Other Party Idno with status as Start Remedy. 
  *     DEVELOPED BY      : IMP Team  
  *     DEVELOPED ON      : 05-AUG-2011 
  *     MODIFIED BY       :   
  *     MODIFIED ON       :   
  *     VERSION NO        : 1  
 */
 BEGIN
  SET @Ai_Count_QNTY = NULL;

  DECLARE @Lc_StatusStrt_CODE CHAR(4) = 'STRT';

  SELECT @Ai_Count_QNTY = COUNT(1)
    FROM DMJR_Y1 D
   WHERE D.OthpSource_IDNO = @An_OthpSource_IDNO
     AND D.Status_CODE = @Lc_StatusStrt_CODE;
 END; -- END OF DMJR_RETRIEVE_S15



GO
