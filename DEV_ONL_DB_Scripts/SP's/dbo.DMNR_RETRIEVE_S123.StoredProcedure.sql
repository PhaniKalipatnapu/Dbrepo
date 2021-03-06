/****** Object:  StoredProcedure [dbo].[DMNR_RETRIEVE_S123]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[DMNR_RETRIEVE_S123] (  
 @An_Case_IDNO      NUMERIC(6, 0),  
 @Ai_Count_QNTY     INT OUTPUT  
 )  
AS  
 /*  
  *     PROCEDURE NAME    : DMNR_RETRIEVE_S123  
  *     DESCRIPTION       : Retrieve the count of records from Minor Activity Diary table.
  *     DEVELOPED BY      : IMP Team  
  *     DEVELOPED ON      : 15-MAR-2012 
  *     MODIFIED BY       :   
  *     MODIFIED ON       :   
  *     VERSION NO        : 1  
  */  
 BEGIN  
  SET @Ai_Count_QNTY = NULL;  
  
  DECLARE @Lc_StatusStart_CODE   CHAR(4) = 'STRT',  
          @Lc_ActivityMinor_CODE CHAR(5) = 'IODEF';  
  
  SELECT @Ai_Count_QNTY = COUNT(1)  
    FROM DMNR_Y1 A  
   WHERE A.Case_IDNO = @An_Case_IDNO  
     AND A.ActivityMinor_CODE = @Lc_ActivityMinor_CODE  
     AND A.Status_CODE = @Lc_StatusStart_CODE;  
 END; -- End of DMNR_RETRIEVE_S123
 
 


GO
