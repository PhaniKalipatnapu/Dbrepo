/****** Object:  StoredProcedure [dbo].[OTHP_RETRIEVE_S38]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[OTHP_RETRIEVE_S38]  
(
     @Ac_TypeOthp_CODE                     CHAR(1) 
 )                
AS  
  
/*  
 *     PROCEDURE NAME    : OTHP_RETRIEVE_S38  
 *     DESCRIPTION       : IT Retrieve the Other Party Idno and Other Party Name for Office from othp Table. 
 *     DEVELOPED BY      : IMP Team  
 *     DEVELOPED ON      : 04-AUG-2011  
 *     MODIFIED BY       :   
 *     MODIFIED ON       :   
 *     VERSION NO        : 1  
*/  
    BEGIN 
      DECLARE  
         @Ld_High_DATE DATE = '12/31/9999';  
          
        SELECT o.OtherParty_IDNO ,
         UPPER(o.OtherParty_NAME) AS OtherParty_NAME
      FROM OTHP_Y1 o 
      WHERE o.TypeOthp_CODE = @Ac_TypeOthp_CODE 
        AND o.EndValidity_DATE = @Ld_High_DATE  
      ORDER BY OtherParty_NAME;
                    
END;--OTHP_RETRIEVE_S38  

GO
