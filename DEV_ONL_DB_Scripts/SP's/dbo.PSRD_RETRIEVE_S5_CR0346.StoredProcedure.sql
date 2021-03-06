/****** Object:  StoredProcedure [dbo].[PSRD_RETRIEVE_S5_CR0346]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE  [dbo].[PSRD_RETRIEVE_S5_CR0346] (  
  @An_Case_IDNO  NUMERIC(6,0),  
  @Ac_Exists_INDC CHAR(1)   OUTPUT       
    )  
AS  
/*  
 *     PROCEDURE NAME    : PSRD_RETRIEVE_S5_CR0346  
 *     DESCRIPTION       : Retrieve the Existing indication from PSRD_Y1 for a case which recieved a order from FAMIS.  
 *     DEVELOPED BY      : IMP Team  
 *     DEVELOPED ON      : 12-DEC-2012  
 *     MODIFIED BY       :   
 *     MODIFIED ON       :   
 *     VERSION NO        : 1  
*/  
   BEGIN  
  SET @Ac_Exists_INDC   =  'N';  
        
    DECLARE  
  @Lc_ProcessS_CODE CHAR(1) = 'S',  
  @Lc_ProcessL_CODE CHAR(1) = 'L',  
  @Ld_High_DATE  DATE = '12/31/9999';  
        
  --SELECT @Ac_Exists_INDC = 'Y'  
  SELECT @Ac_Exists_INDC = 'N'  
   FROM PSRD_Y1 S     
  WHERE S.Case_IDNO  = @An_Case_IDNO    
  AND   S.Process_CODE = @Lc_ProcessL_CODE  
  AND NOT EXISTS (SELECT 1   
      FROM PSRD_Y1 P  
      WHERE S.Case_IDNO   = P.Case_IDNO        
      AND   P.Process_CODE  = @Lc_ProcessS_CODE);  
               
END; --END OF PSRD_RETRIEVE_S5  
GO
