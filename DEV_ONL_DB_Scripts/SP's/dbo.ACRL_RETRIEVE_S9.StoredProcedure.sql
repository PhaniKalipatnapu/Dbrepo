/****** Object:  StoredProcedure [dbo].[ACRL_RETRIEVE_S9]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
    
CREATE PROCEDURE [dbo].[ACRL_RETRIEVE_S9] (                                                            
     @Ac_ActivityMinor_CODE	CHAR(5),  
     @Ac_Category_CODE     	CHAR(2),  
     @Ac_SubCategory_CODE  	CHAR(4)  
  )                                                            
AS                                                           
  
/*  
 *     PROCEDURE NAME    : ACRL_RETRIEVE_S9  
 *     DESCRIPTION       : Retrieve the activity role description
 *     DEVELOPED BY      : IMP Team  
 *     DEVELOPED ON      : 23-AUG-2011  
 *     MODIFIED BY       :   
 *     MODIFIED ON       :   
 *     VERSION NO        : 1  
*/  
  
 BEGIN  
   DECLARE @Ld_Highdate        DATE = '12/31/9999',   
              @Lc_HyphenWithSpace CHAR(3) = ' - ';             
          
      SELECT a.Role_ID ,   
             b.Role_NAME                  
      	FROM ACRL_Y1 A, 
      	     ROLE_Y1 B  
      WHERE A.ActivityMinor_CODE = @Ac_ActivityMinor_CODE 
       AND  A.Category_CODE = @Ac_Category_CODE 
       AND  A.SubCategory_CODE = @Ac_SubCategory_CODE 
       AND  B.Role_ID = A.Role_ID 
       AND  A.EndValidity_DATE = @Ld_Highdate 
       AND  B.EndValidity_DATE = @Ld_Highdate;  
END;    --END OF ACRL_RETRIEVE_S9  
  

GO
