/****** Object:  StoredProcedure [dbo].[PLIC_RETRIEVE_S3]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
                                                                                                                       
CREATE PROCEDURE [dbo].[PLIC_RETRIEVE_S3] (                                                                                    
     @An_MemberMci_IDNO			NUMERIC(10,0)		,                                                                             
     @Ac_TypeLicense_CODE		CHAR(5)				,                                                                                
     @Ai_Row_NUMB				INT          	  	,                                                                     
	 @Ac_LicenseNo_TEXT         CHAR(25)			,                                                                        
     @Ac_LicenseStatus_CODE		CHAR(1)	 	  OUTPUT,                                                                       
     @Ad_IssueLicense_DATE		DATE	 	  OUTPUT,                                                                           
     @Ad_ExpireLicense_DATE		DATE	 	  OUTPUT,                                                                          
     @Ad_SuspLicense_DATE		DATE	 	  OUTPUT,                                                                            
     @Ac_Status_CODE            CHAR(2)       OUTPUT,                                                                  
     @Ad_Status_DATE			DATE	 	  OUTPUT,                                                                                
     @Ac_SourceVerified_CODE	CHAR(3)	 	  OUTPUT,                                                                       
     @Ac_WorkerUpdate_ID		CHAR(30)	  OUTPUT,                                                                           
     @Ac_Profession_CODE		CHAR(3)		  OUTPUT,                                                                           
     @As_Business_NAME			VARCHAR(50)	  OUTPUT,                                                                         
     @As_Trade_NAME				VARCHAR(50)	  OUTPUT,                                                                           
     @An_OtherParty_IDNO		NUMERIC(9,0)  OUTPUT,                                                                        
     @As_OtherParty_NAME		VARCHAR(60)	  OUTPUT,                                                                        
     @As_Line1_ADDR		 		VARCHAR(50)	  OUTPUT,                                                                          
     @As_Line2_ADDR		 		VARCHAR(50)	  OUTPUT,                                                                          
     @Ac_City_ADDR		 		CHAR(28)	  OUTPUT,                                                                              
     @Ac_Zip_ADDR		 		CHAR(15)	  OUTPUT,                                                                               
     @Ac_State_ADDR             CHAR(2)       OUTPUT,                                                                  
     @Ac_Country_ADDR		 	CHAR(2)	 	  OUTPUT,                                                                           
     @An_Phone_NUMB		 		NUMERIC(15,0) OUTPUT,                                                                          
     @An_Fax_NUMB		 		NUMERIC(15,0) OUTPUT,                                                                            
     @An_RowCount_NUMB          NUMERIC(6,0)  OUTPUT                                                                   
     )                                                                                                                 
AS                                                                                                                     
                                                                                                                       
/*                                                                                                                     
 *     PROCEDURE NAME    : PLIC_RETRIEVE_S3                                                                            
 *     DESCRIPTION       : Retrieve License History Details for a Member ID, License Type Code and Record number.      
 *     DEVELOPED BY      : IMP Team                                                                                    
 *     DEVELOPED ON      : 14-SEP-2011                                                                                 
 *     MODIFIED BY       :                                                                                             
 *     MODIFIED ON       :                                                                                             
 *     VERSION NO        : 1                                                                                           
 */                                                                                                                    
    BEGIN                                                                                                              
  --13767 - MLIC - MLIC screen - display issue with License Number - START -                                                                                           
                                                                                                                       
      DECLARE                                                                                                          
         @Ld_High_DATE DATE =  '12/31/9999';                                                                           
                                                                                                                       
	SELECT  @Ac_LicenseStatus_CODE	= X.LicenseStatus_CODE,                                                               
         @Ad_IssueLicense_DATE		= X.IssueLicense_DATE,                                                                 
         @Ad_ExpireLicense_DATE		= X.ExpireLicense_DATE,                                                               
         @Ad_SuspLicense_DATE		= X.SuspLicense_DATE,
         @Ac_Status_CODE			= X.Status_CODE, 
         @Ad_Status_DATE			= X.Status_DATE,                                                                           
         @Ac_SourceVerified_CODE	= X.SourceVerified_CODE,                                                              
         @Ac_WorkerUpdate_ID		= X.WorkerUpdate_ID,                                                                     
         @Ac_Profession_CODE		= X.Profession_CODE,                                                                     
         @As_Business_NAME			= X.Business_NAME,                                                                        
         @As_Trade_NAME				= X.Trade_NAME,                                                                             
         @An_OtherParty_IDNO		= X.OtherParty_IDNO,                                                                     
         @As_OtherParty_NAME		= X.OtherParty_NAME,                                                                     
         @As_Line1_ADDR				= X.Line1_ADDR,                                                                             
         @As_Line2_ADDR				= X.Line2_ADDR,                                                                             
         @Ac_City_ADDR				= X.City_ADDR, 
         @Ac_Zip_ADDR				= X.Zip_ADDR,                                                                              
         @Ac_State_ADDR				= X.State_ADDR,                                                                             
         @Ac_Country_ADDR			= X.Country_ADDR,                                                                                                                                                                    
         @An_Phone_NUMB				= X.Phone_NUMB,                                                                             
         @An_Fax_NUMB				= X.Fax_NUMB,                                                                                 
         @An_RowCount_NUMB			= X.row_count                                                                             
    FROM (SELECT a.TypeLicense_CODE,                                                                                       			 
    			 a.LicenseStatus_CODE,                                                                                          
                 a.IssueLicense_DATE,                                                                                  
                 a.SuspLicense_DATE,                                                                                   
                 a.ExpireLicense_DATE,                                                                                 
                 a.Status_CODE,                                                                                        
                 a.SourceVerified_CODE,                                                                                
                 a.Status_DATE,                                                                                        
                 a.WorkerUpdate_ID,                                                                                    
                 a.Profession_CODE,                                                                                    
				 a.Business_NAME,                                                                                                  
				 a.Trade_NAME,                                                                                                     
                 b.OtherParty_IDNO,                                                                                    
                 b.OtherParty_NAME,                                                                                    
                 b.Line1_ADDR,                                                                                         
                 b.Line2_ADDR,                                                                                         
                 b.City_ADDR,                                                                                          
                 b.State_ADDR,                                                                                         
                 b.Country_ADDR,                                                                                       
                 b.Zip_ADDR,                                                                                           
                 b.Phone_NUMB,                                                                                         
                 b.Fax_NUMB,                                                                                           
                 ROW_NUMBER () OVER (ORDER BY a.Update_DTTM DESC) AS RecRank_NUMB,                                     
                 COUNT (1) OVER () row_count,                                                                          
                 ROW_NUMBER () OVER (ORDER BY a.TransactionEventSeq_NUMB DESC) AS ORD_ROWNUM                           
            FROM PLIC_Y1 a JOIN OTHP_Y1 b                                                                              
            ON  a.OthpLicAgent_IDNO	= b.OtherParty_IDNO                                                                
           WHERE a.MemberMci_IDNO		= @An_MemberMci_IDNO                                                                
             AND a.TypeLicense_CODE		= @Ac_TypeLicense_CODE
			 AND a.LicenseNo_TEXT		= @Ac_LicenseNo_TEXT                                                            
             AND a.EndValidity_DATE		!= @Ld_High_DATE                                                                  
             AND b.EndValidity_DATE		= @Ld_High_DATE) X                                                                
   WHERE X.RecRank_NUMB = @Ai_Row_NUMB                                                                             
ORDER BY RecRank_NUMB;

  --13767 - MLIC - MLIC screen - display issue with License Number - END -                                                                                     
                                                                                                                       
END   --End of PLIC_RETRIEVE_S3                                                                                        
                                                                                                                       

GO
