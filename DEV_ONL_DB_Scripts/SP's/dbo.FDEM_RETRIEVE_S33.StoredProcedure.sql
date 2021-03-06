/****** Object:  StoredProcedure [dbo].[FDEM_RETRIEVE_S33]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 CREATE PROCEDURE   
	[dbo].[FDEM_RETRIEVE_S33] 
	  (    
		@An_Petition_IDNO	NUMERIC(7,0),   
		@Ac_Exists_INDC		CHAR(1)   OUTPUT  
	  )  
AS  
  
/*  
 *     PROCEDURE NAME    : FDEM_RETRIEVE_S33  
 *     DESCRIPTION       : Check the existance of Order for the given Petition no.  
 *     DEVELOPED BY      : IMP Team  
 *     DEVELOPED ON      : 01-MAR-2012  
 *     MODIFIED BY       :   
 *     MODIFIED ON       :   
 *     VERSION NO        : 1  
*/  
 BEGIN  
  
      DECLARE  
         @Lc_Yes_INDC		CHAR(1) = 'Y' ,  
		 @Lc_No_INDC		CHAR(1) = 'N' ,  
		 @Lc_TypeDocO_CODE	CHAR(1) = 'O',
         @Ld_High_DATE		DATE	= '12/31/9999';  
           
 SET   
  @Ac_Exists_INDC = @Lc_No_INDC ;  
          
  SELECT  @Ac_Exists_INDC = @Lc_Yes_INDC  
	FROM  FDEM_Y1 F  
   WHERE  F.Petition_IDNO = @An_Petition_IDNO 
     AND  F.TypeDoc_CODE = @Lc_TypeDocO_CODE 
     AND  F.EndValidity_DATE = @Ld_High_DATE;  
                    
END; --END OF FDEM_RETRIEVE_S33  
   
GO
