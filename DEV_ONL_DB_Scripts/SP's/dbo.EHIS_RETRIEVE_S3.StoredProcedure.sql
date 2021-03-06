/****** Object:  StoredProcedure [dbo].[EHIS_RETRIEVE_S3]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
                                                                                                             
 CREATE PROCEDURE [dbo].[EHIS_RETRIEVE_S3](
  @An_MemberMci_IDNO		NUMERIC(10,0)		,                                   
  @Ai_Count_QNTY			INT			OUTPUT 
  )                             
AS                                                                                                          
                                                                                                            
/*                                                                                                          
 *     PROCEDURE NAME    : EHIS_RETRIEVE_S3                                                                  
 *     DESCRIPTION       : Retrieve record count for a Member Idno where Employer is the Primary Employer.  
 *     DEVELOPED BY      : IMP Team                                                                        
 *     DEVELOPED ON      : 04-OCT-2011                                                                      
 *     MODIFIED BY       :                                                                                  
 *     MODIFIED ON       :                                                                                  
 *     VERSION NO        : 1                                                                                
*/                                                                                                          

BEGIN                                                                                                   
                                                                                                            
	SET 
		@Ai_Count_QNTY = NULL ;                                                                            
	                                                                                                        
	DECLARE                                                                                               
		@Lc_Yes_INDC	CHAR(1) = 'Y',                                                                        
		@Ld_High_DATE	DATE	= '12/31/9999';                                                    
	                                                                                                        
	SELECT @Ai_Count_QNTY = COUNT(1)                                                                    
	 FROM EHIS_Y1 a     
		JOIN OTHP_Y1  b 
     		ON b.OtherParty_IDNO = a.OthpPartyEmpl_IDNO                                                                                   
	WHERE a.MemberMci_IDNO = @An_MemberMci_IDNO 
	 AND  a.EmployerPrime_INDC = @Lc_Yes_INDC 
	 AND  a.EndEmployment_DATE = @Ld_High_DATE
	 AND  b.EndValidity_DATE = @Ld_High_DATE;                                                    
	                                                                                                        
                                                                                                            
END; --END OF EHIS_RETRIEVE_S3                                                                                                         
                                                                                                            

GO
