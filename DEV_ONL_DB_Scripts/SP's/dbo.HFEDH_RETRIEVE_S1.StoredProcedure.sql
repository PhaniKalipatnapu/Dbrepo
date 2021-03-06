/****** Object:  StoredProcedure [dbo].[HFEDH_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE PROCEDURE [dbo].[HFEDH_RETRIEVE_S1]    
  (
     @Ac_TypeArrear_CODE	 CHAR(1), 
     @An_TaxYear_NUMB		 NUMERIC(4,0),  
     @An_MemberMci_IDNO		 NUMERIC(10,0), 
     @Ai_Count_QNTY          INT             OUTPUT  
   )
AS  
  
/*  
 *     PROCEDURE NAME    : HFEDH_RETRIEVE_S1  
 *     DESCRIPTION       : This procedure is used to show count of hfedh_y1 table according to membermci_idno,typearrear_code,taxyear_numb,rejectind_indc.
 *     DEVELOPED BY      : IMP TEAM  
 *     DEVELOPED ON      : 02-SEP-2011  
 *     MODIFIED BY       :   
 *     MODIFIED ON       :   
 *     VERSION NO        : 1  
*/  
BEGIN 
          SET @Ai_Count_QNTY = NULL ; 
      DECLARE @Lc_No_INDC CHAR(1) = 'N',   
              @Lc_Yes_INDC CHAR(1) = 'Y'; 
      SELECT  @Ai_Count_QNTY = COUNT(1)  
        FROM HFEDH_Y1 a  
       WHERE a.MemberMci_IDNO	= @An_MemberMci_IDNO    
         AND a.TypeArrear_CODE	= ISNULL(@Ac_TypeArrear_CODE, a.TypeArrear_CODE)    
         AND a.TaxYear_NUMB		= @An_TaxYear_NUMB    
         AND a.RejectInd_INDC	= @Lc_No_INDC    
         AND NOT EXISTS   
           (  
            SELECT 1  
              FROM FEDH_Y1 b  
             WHERE b.MemberMci_IDNO		= a.MemberMci_IDNO    
               AND b.TypeArrear_CODE	= a.TypeArrear_CODE    
               AND b.TaxYear_NUMB		= a.TaxYear_NUMB    
               AND b.RejectInd_INDC		= @Lc_No_INDC    
               AND NOT EXISTS   
                 (  
                  SELECT 1 
                    FROM HFEDH_Y1 c  
                   WHERE c.MemberMci_IDNO	= b.MemberMci_IDNO    
                     AND c.TypeArrear_CODE	= b.TypeArrear_CODE    
                     AND c.TaxYear_NUMB		= b.TaxYear_NUMB    
                     AND c.SubmitLast_DATE	= b.SubmitLast_DATE    
                     AND c.RejectInd_INDC	= @Lc_Yes_INDC  
               )  
         );         
END;-- End of HFEDH_RETRIEVE_S1;  

GO
