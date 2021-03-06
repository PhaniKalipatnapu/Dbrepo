/****** Object:  StoredProcedure [dbo].[EHIS_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 

CREATE PROCEDURE [dbo].[EHIS_RETRIEVE_S1] (                                                                                               
 @An_MemberMci_IDNO		NUMERIC(10,0)	,                                               
 @Ac_Status_CODE		CHAR(1)			,                                                               
 @Ai_RowFrom_NUMB		INT = 1         ,                                                             
 @Ai_RowTo_NUMB			INT = 10 
)                                                                     
AS                                                                                                                                   
                                                                                                                                     
/*                                                                                                                                   
 *     PROCEDURE NAME    : EHIS_RETRIEVE_S1                                                                                           
 *     DESCRIPTION       : Retrieves Employment Summary for a Member ID, Status Code, Row to Number and Row from number.             
 *     DEVELOPED BY      : IMP Team                                                                                                
 *     DEVELOPED ON      : 04-OCT-2011                                                                                               
 *     MODIFIED BY       :                                                                                                           
 *     MODIFIED ON       :                                                                                                           
 *     VERSION NO        : 1                                                                                                         
*/     
                                                                                                                              
BEGIN                                                                      
                                                                                                                                     
	DECLARE                                                                                                                        
		@Ld_High_DATE					DATE	 = '12/31/9999',  
		@Li_One_NUMB					SMALLINT = 1,
		@Li_Two_NUMB					SMALLINT = 2;                                                                                  
	                                                                                                                               
	SELECT	d.OthpPartyEmpl_IDNO , 
			d.BeginEmployment_DATE , 
			d.EndEmployment_DATE , 
			d.SourceLoc_CODE ,
			d.Status_CODE ,                                                                                        
			d.Status_DATE , 
			d.OtherParty_NAME ,                                                                                               
			d.RowCount_NUMB                                                                                             
	 FROM (
		SELECT	c.OthpPartyEmpl_IDNO,
	       		c.BeginEmployment_DATE,                                                                                               
	       		c.EndEmployment_DATE,  
	       		c.SourceLoc_CODE ,                                                                                                               
	       		c.Status_CODE,                                                                                                        
	       		c.Status_DATE,
	       		c.OtherParty_NAME,                                                                                                        
	       		c.RowCount_NUMB,                                                                                                      
	       		c.ORD_ROWNUM AS rnm                                                                                                   
	      	  FROM (
	        	 SELECT a.OthpPartyEmpl_IDNO,
	               		a.BeginEmployment_DATE,                                                                                         
	               		a.EndEmployment_DATE,
	               		a.SourceLoc_CODE,                                                                              
	               		a.Status_CODE,
	               		a.Status_DATE,                                                                                          
	               		b.OtherParty_NAME ,                                                                                                                                                                     
	               		COUNT(1) OVER() AS RowCount_NUMB,                                                                               
	               		ROW_NUMBER() OVER	(                                                                                              
		               		   					ORDER BY 
		               		   						CASE a.EndEmployment_DATE
		               		      						WHEN @Ld_High_DATE THEN @Li_One_NUMB                                                                             
		               		      						ELSE @Li_Two_NUMB                                                                                                    
		               		   						END, 
		               		   					a.BeginEmployment_DATE DESC, 
		               		   					a.Update_DTTM DESC
		               		   				) AS ORD_ROWNUM                                          
	            	 FROM EHIS_Y1  a
	            		JOIN OTHP_Y1  b 
	                 		ON b.OtherParty_IDNO = a.OthpPartyEmpl_IDNO                                                                         
	                WHERE 
	                	a.MemberMci_IDNO = @An_MemberMci_IDNO
	                AND a.Status_CODE= ISNULL(@Ac_Status_CODE,a.Status_CODE)
	                AND b.EndValidity_DATE = @Ld_High_DATE
	           )  AS c                                                                                                               
	         WHERE c.ORD_ROWNUM <= @Ai_RowTo_NUMB                                                                                     
	   	)  AS d                                                                                                                     
	WHERE d.rnm >= @Ai_RowFrom_NUMB                                                                                                
	ORDER BY 
		RNM;                                                                                                                        
	                                                                                                                                 
                                                                                                                                     
END; --END OF EHIS_RETRIEVE_S1                                                                                                                                  

GO
