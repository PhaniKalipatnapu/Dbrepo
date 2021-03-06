/****** Object:  StoredProcedure [dbo].[DPRS_UPDATE_S2]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
                                                                                    
                                                                                    
CREATE PROCEDURE [dbo].[DPRS_UPDATE_S2]                                                     
	(                                                                                  
     @Ac_File_ID						CHAR(10)                                               
    )                                                                               
AS                                                                                  
                                                                                    
/*                                                                                  
 *     PROCEDURE NAME    : DPRS_UPDATE_S2                                           
 *     DESCRIPTION       : End Validating Old File Persons Information in Docket Person table.                                           
 *     DEVELOPED BY      : IMP Team                                                 
 *     DEVELOPED ON      : 24-DEC-2011                                              
 *     MODIFIED BY       :                                                          
 *     MODIFIED ON       :                                                          
 *     VERSION NO        : 1                                                        
*/                                                                                  
   BEGIN                                                                            
		DECLARE                                                                              
			 @Ld_High_DATE          		DATE    = '12/31/9999',                                                                                      
			 @Ld_System_DATE				DATE	= dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),                  
			 @Ln_RowsAffected_NUMB  		NUMERIC(10);                                           
                                                                                    
      UPDATE DPRS_Y1                                                                
         SET EndValidity_DATE = @Ld_System_DATE                                                                                                                                                                                     
       WHERE File_ID = @Ac_File_ID                                                               
         AND EndValidity_DATE = @Ld_High_DATE;                                         
                                                                                    
          SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;                                   
       SELECT @Ln_RowsAffected_NUMB AS  RowsAffected_NUMB;                          
                                                                                    
END; --END OF DPRS_UPDATE_S2                                                        
                                                                                    

GO
