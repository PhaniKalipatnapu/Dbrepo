/****** Object:  StoredProcedure [dbo].[RFMAP_RETRIEVE_S8]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 CREATE PROCEDURE [dbo].[RFMAP_RETRIEVE_S8](
			@Ad_Begin_DATE					DATE,
			@Ad_End_DATE					DATE,
			@An_Amount_PCT				NUMERIC (5,2) OUTPUT
			 )			
AS  
  
/*  
 *     PROCEDURE NAME    : RFMAP_RETRIEVE_S8   
 *     DESCRIPTION       : This procedure is used to fetch the fedshare percentage for that period
 *     DEVELOPED BY      : IMP Team  
 *     DEVELOPED ON      : 15-NOV-2011  
 *     MODIFIED BY       :   
 *     MODIFIED ON       :   
 *     VERSION NO        : 1  
 */  
 
 BEGIN  
	  					
	     SET @An_Amount_PCT = 0;
 
      SELECT @An_Amount_PCT = a.Amount_PCT
        FROM RFMAP_Y1 a
       WHERE @Ad_Begin_DATE BETWEEN a.Begin_DATE AND a.End_DATE
         AND @Ad_End_DATE   BETWEEN a.Begin_DATE AND a.End_DATE;

 
 END; --END OF RFMAP_RETRIEVE_S8
 

GO
