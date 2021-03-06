/****** Object:  StoredProcedure [dbo].[GTST_RETRIEVE_S2]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
                       
CREATE PROCEDURE [dbo].[GTST_RETRIEVE_S2]    
(  
     @An_Case_IDNO      NUMERIC(6,0) ,  
     @An_Schedule_NUMB  NUMERIC(10,0)    ,  
     @Ac_Exists_INDC    CHAR(1)   OUTPUT  
 )  
AS                                                            
  
/*  
 *     PROCEDURE NAME    : GTST_RETRIEVE_S2  
 *     DESCRIPTION       : This procedure is used to check whether the Case_IDNO is exist in the GTST_Y1 table  
 *     DEVELOPED BY      : IMP Team  
 *     DEVELOPED ON      : 02-AUG-2011  
 *     MODIFIED BY       :   
 *     MODIFIED ON       :   
 *     VERSION NO        : 1  
 */  
  
   BEGIN  
  
      DECLARE  
         @Lc_CaseRelationshipCp_CODE  CHAR(1) = 'C',   
         @Ld_High_DATE      DATE    = '12/31/9999',  
         @Lc_Yes_TEXT                   CHAR(1) = 'Y',    
         @Lc_No_TEXT                    CHAR(1) = 'N';    
        
      SET @Ac_Exists_INDC = @Lc_No_TEXT;    
                                                         
        SELECT TOP 1 @Ac_Exists_INDC   = @Lc_Yes_TEXT  
  FROM  GTST_Y1 g  
  WHERE g.Case_IDNO = @An_Case_IDNO   
        AND   g.Schedule_NUMB = @An_Schedule_NUMB   
        AND   g.MemberMci_IDNO =(SELECT c.MemberMci_IDNO  
                    FROM CMEM_Y1 c  
                    WHERE c.Case_IDNO = @An_Case_IDNO   
                    AND   c.CaseRelationship_CODE = @Lc_CaseRelationshipCp_CODE)  
       AND g.EndValidity_DATE = @Ld_High_DATE;  
  
                    
END  -- End of GTST_RETRIEVE_S2  
   
GO
