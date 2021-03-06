/****** Object:  StoredProcedure [dbo].[FDEM_RETRIEVE_S43]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[FDEM_RETRIEVE_S43](                
@An_Petition_IDNO				NUMERIC(7,0)     , 
@An_Petitioner_IDNO				NUMERIC(10,0)    OUTPUT , 
@An_Respondent_IDNO				NUMERIC(10,0)	 OUTPUT           
)                
AS                
      
/*      
 *     PROCEDURE NAME    : FDEM_RETRIEVE_S43     
 *     DESCRIPTION       : Retrieves Petitioner,Respondent values for the given Petition ID     
 *     DEVELOPED BY      : IMP Team       
 *     DEVELOPED ON      : 22-MAR-2012      
 *     MODIFIED BY       :       
 *     MODIFIED ON       :       
 *     VERSION NO        : 1      
*/      
  BEGIN
  
	SELECT @An_Petitioner_IDNO = NULL,
		   @An_Respondent_IDNO = NULL;
  DECLARE
	  @Lc_TypeDocP_CODE				CHAR(1) = 'P' ,
	  @Ld_High_DATE					DATE	= '12/31/9999';
  
  SELECT @An_Petitioner_IDNO = s.Petitioner_IDNO,
		 @An_Respondent_IDNO = s.Respondent_IDNO
	  FROM FDEM_Y1 s 
     WHERE s.Petition_IDNO    = @An_Petition_IDNO
	   AND s.TypeDoc_CODE     = @Lc_TypeDocP_CODE
       AND s.EndValidity_DATE = @Ld_High_DATE;
			
END;	--END OF FDEM_RETRIEVE_S43
 

GO
