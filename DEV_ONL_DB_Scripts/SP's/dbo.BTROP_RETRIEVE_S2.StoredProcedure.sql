/****** Object:  StoredProcedure [dbo].[BTROP_RETRIEVE_S2]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE  [dbo].[BTROP_RETRIEVE_S2] 
	 (  
     @Ac_Template_NAME  CHAR(30),  
     @Ac_Exists_INDC   CHAR(1) OUTPUT    
     )               
AS  
 /*      
  *     PROCEDURE NAME    : BTROP_RETRIEVE_S2      
  *     DESCRIPTION       : This function is used to check the templane name already exists are
                            not. If exists then this function will reutrn Yes or else it will
                            return No    
  *     DEVELOPED BY      : IMP Team     
  *     DEVELOPED ON      : 21-Feb-2012      
  *     MODIFIED BY       :       
  *     MODIFIED ON       :       
  *     VERSION NO        : 1      
 */   
    
 BEGIN 
       SET @Ac_Exists_INDC = NULL;
   DECLARE @Lc_No_TEXT	CHAR(1)	= 'N',
		   @Lc_Yes_TEXT	CHAR(1)	= 'Y';
   
  SET @Ac_Exists_INDC = @Lc_No_TEXT;
         
      SELECT TOP 1 @Ac_Exists_INDC = @Lc_Yes_TEXT  
      FROM BTROP_Y1 T  
      WHERE Template_NAME=@Ac_Template_NAME; 
       
 END ;  --END of BTROP_RETRIEVE_S2

GO
