/****** Object:  StoredProcedure [dbo].[NOST_RETRIEVE_S2]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[NOST_RETRIEVE_S2](  
 @Ac_Worker_ID                CHAR(30),  
 @Ac_Exists_INDC       CHAR(1) OUTPUT 
 )  
AS  
  /*      
   *     PROCEDURE NAME    : NOST_RETRIEVE_S2      
   *     DESCRIPTION       : This procedure is used to find whether notary pin generated through
							 USEM Screen or Change pin Popup        
   *     DEVELOPED BY      : IMP Team  
   *     DEVELOPED ON      : 18-SEP-2012    
   *     MODIFIED BY       :       
   *     MODIFIED ON       :       
   *     VERSION NO        : 1.0  
   */ 
BEGIN 
	DECLARE
	@Lc_No_TEXT                CHAR(1) = 'N',  
    @Lc_Yes_TEXT               CHAR(1) = 'Y';  
    
    SET  @Ac_Exists_INDC = @Lc_Yes_TEXT;
  
  SELECT @Ac_Exists_INDC  = @Lc_No_TEXT
		FROM NOST_Y1 
		WHERE Worker_ID= @Ac_Worker_ID
		AND BeginValidity_DATE > Update_DTTM
		
END -- END Of NOST_RETRIEVE_S2 ;
GO
