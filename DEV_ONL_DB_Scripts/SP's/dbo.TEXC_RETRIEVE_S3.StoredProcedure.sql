/****** Object:  StoredProcedure [dbo].[TEXC_RETRIEVE_S3]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE PROCEDURE [dbo].[TEXC_RETRIEVE_S3]                                        
    (                                                                          
     @An_Case_IDNO			NUMERIC(6,0),        
     @An_MemberMci_IDNO		NUMERIC(10,0),           
     @Ac_ExcludeFin_INDC	CHAR(1)	 OUTPUT,      
     @Ac_ExcludeIns_INDC	CHAR(1)	 OUTPUT,      
     @Ac_ExcludeIrs_INDC	CHAR(1)	 OUTPUT,      
     @Ac_ExcludePas_INDC	CHAR(1)	 OUTPUT,      
     @Ac_ExcludeRet_INDC	CHAR(1)	 OUTPUT,      
     @Ac_ExcludeSal_INDC	CHAR(1)	 OUTPUT,      
     @Ac_ExcludeState_CODE	CHAR(1)	 OUTPUT,     
     @Ac_ExcludeVen_INDC	CHAR(1)	 OUTPUT,      
     @Ad_Effective_DATE		DATE	 OUTPUT,  
     @Ad_End_DATE			DATE	 OUTPUT
    )   
AS                                                                            
                                                                              
/*                                                                            
 *     PROCEDURE NAME    : TEXC_RETRIEVE_S3                                    
 *     DESCRIPTION       : Retrieve the exclusion details for the given membermci_idno & case_idno.                                                  
 *     DEVELOPED BY      : IMP Team                                         
 *     DEVELOPED ON      : 02-DEC-2011                                        
 *     MODIFIED BY       :                                                    
 *     MODIFIED ON       :                                                    
 *     VERSION NO        : 1                                                  
*/                                                                            
 BEGIN                                                                         
      SELECT @Ac_ExcludeFin_INDC   = NULL,                                                 
             @Ac_ExcludeIns_INDC   = NULL,                                                 
             @Ac_ExcludeIrs_INDC   = NULL,                                                 
             @Ac_ExcludePas_INDC   = NULL,                                                 
             @Ac_ExcludeRet_INDC   = NULL,                                                 
             @Ac_ExcludeSal_INDC   = NULL,                                                 
             @Ac_ExcludeState_CODE = NULL,                                               
             @Ac_ExcludeVen_INDC   = NULL,                                                 
             @Ad_Effective_DATE    = NULL,                                           
             @Ad_End_DATE          = NULL; 
			                                    
      DECLARE @Ld_High_DATE DATE = '12/31/9999';   
	                              
      SELECT @Ad_Effective_DATE	   = K.Effective_DATE,                   
			 @Ad_End_DATE		   = K.End_DATE,                                     
			 @Ac_ExcludeIrs_INDC   = K.ExcludeIrs_INDC,                              
			 @Ac_ExcludeFin_INDC   = K.ExcludeFin_INDC,                              
			 @Ac_ExcludePas_INDC   = K.ExcludePas_INDC,                              
			 @Ac_ExcludeRet_INDC   = K.ExcludeRet_INDC,                              
			 @Ac_ExcludeSal_INDC   = K.ExcludeSal_INDC,                                                          
			 @Ac_ExcludeVen_INDC   = K.ExcludeVen_INDC,                              
			 @Ac_ExcludeIns_INDC   = K.ExcludeIns_INDC,                              
			 @Ac_ExcludeState_CODE = K.ExcludeState_CODE                           
        FROM TEXC_Y1  K                                                      
       WHERE K.MemberMci_IDNO   = @An_MemberMci_IDNO 
         AND K.Case_IDNO        = @An_Case_IDNO 
         AND K.EndValidity_DATE = @Ld_High_DATE;  
		                             
END;  --END OF TEXC_RETRIEVE_S3     

GO
