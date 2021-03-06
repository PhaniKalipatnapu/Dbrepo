/****** Object:  StoredProcedure [dbo].[ICAS_RETRIEVE_S25]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE 
	[dbo].[ICAS_RETRIEVE_S25]    
 		( 
     		@An_Case_IDNO		 	NUMERIC(6,0), 
     		@Ac_Function_CODE	    CHAR(3)	 OUTPUT,
     		@Ac_Action_CODE		    CHAR(1)	 OUTPUT,  
            @Ac_Reason_CODE         CHAR(5)          OUTPUT,  
     		@As_DescriptionFar_TEXT	VARCHAR(1000)	 OUTPUT  
 		)
AS  
  
/*  
 *     PROCEDURE NAME    : ICAS_RETRIEVE_S25  
 *     DESCRIPTION       : Retrieve the first Function Code, Action Code, Reason Code, Description of a Far Combination for Case Idno that's common between two tables.  
 *     DEVELOPED BY      : IMP Team  
 *     DEVELOPED ON      : 02-SEP-2011  
 *     MODIFIED BY       :   
 *     MODIFIED ON       :   
 *     VERSION NO        : 1  
 */  
    BEGIN  
  
      SELECT 
         @Ac_Function_CODE = NULL, 
         @Ac_Action_CODE = NULL,
         @Ac_Reason_CODE = NULL ,
         @As_DescriptionFar_TEXT = NULL  ;
  
      DECLARE  
         @Ld_High_DATE DATE = '12/31/9999';  
          
        SELECT TOP 1 
           @Ac_Function_CODE = b.Function_CODE,
           @Ac_Action_CODE = b.Action_CODE,       
           @Ac_Reason_CODE = b.Reason_CODE, 
           @As_DescriptionFar_TEXT =   
         (  
            SELECT c.DescriptionFar_TEXT  
            FROM CFAR_Y1  c  
            WHERE
               c.Function_CODE = b.Function_CODE AND
               c.Action_CODE =b.Action_CODE AND
               c.Reason_CODE = b.Reason_CODE
                 
         )  
      FROM 
      	ICAS_Y1  a
      JOIN 
      	CTHB_Y1   b  
      		ON
      			a.Case_IDNO = b.Case_IDNO 
      WHERE   
         b.Case_IDNO = @An_Case_IDNO AND
         a.EndValidity_DATE = @Ld_High_DATE;
                    
END; --End of ICAS_RETRIEVE_S25  
  

GO
