/****** Object:  StoredProcedure [dbo].[SCAS_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SCAS_RETRIEVE_S1]
AS  
 /*  
  *     PROCEDURE NAME    : SCAS_RETRIEVE_S1  
  *     DESCRIPTION       : Retrieve Screen Id and Screen Associated Id.  
  *     DEVELOPED BY      : IMP Team  
  *     DEVELOPED ON      : 11-AUG-2011  
  *     MODIFIED BY       :  
  *     MODIFIED ON       :  
  *     VERSION NO        : 1  
 */  
 BEGIN  
  DECLARE @Ld_High_DATE       DATE = '12/31/9999';
  
  SELECT S.Screen_ID,
		 S.ScreenAssociated_ID  
    FROM SCAS_Y1 S 
   WHERE S.EndValidity_DATE = @Ld_High_DATE  
   ORDER BY S.Screen_ID, S.ScreenAssociated_ID; 
    
 END; --End Of SCAS_RETRIEVE_S1  

GO
