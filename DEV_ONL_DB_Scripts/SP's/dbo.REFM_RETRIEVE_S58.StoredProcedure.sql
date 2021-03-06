/****** Object:  StoredProcedure [dbo].[REFM_RETRIEVE_S58]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
                                      
       
CREATE PROCEDURE  
	[dbo].[REFM_RETRIEVE_S58] 
		(  
			 @Ac_Value_CODE				CHAR(10)	,  
			 @As_DescriptionValue_TEXT  VARCHAR(70) OUTPUT       
		)                                                       
AS  
  
/*  
 *     PROCEDURE NAME    : REFM_RETRIEVE_S58 
 *     DESCRIPTION       : Retreive REFM Description Value For given Value code
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 22-DEC-2011  
 *     MODIFIED BY       :   
 *     MODIFIED ON       :   
 *     VERSION NO        : 1  
*/  
  
   BEGIN  
	  
	  SET
		@As_DescriptionValue_TEXT = NULL;
  
      DECLARE   
         @Ld_High_DATE					DATE    ='12/31/9999',
         @Lc_HoldLevelDistribute_CODE	CHAR(4) = 'DIST',   
         @Lc_RefmTableRcth_ID			CHAR(4) = 'RCTH';  
          
        SELECT  @As_DescriptionValue_TEXT = B.DescriptionValue_TEXT
         FROM  REFM_Y1 B
       JOIN
			UCAT_Y1 A
				ON
					B.Value_CODE = A.Udc_CODE
	   WHERE B.Table_ID = @Lc_RefmTableRcth_ID
		 AND B.TableSub_ID = @Lc_RefmTableRcth_ID
		 AND B.Value_CODE  =@Ac_Value_CODE
         AND A.HoldLevel_CODE = @Lc_HoldLevelDistribute_CODE
         AND A.EndValidity_DATE = @Ld_High_DATE ;
  
                    
END; --END OF REFM_RETRIEVE_S58
  
  
   
GO
