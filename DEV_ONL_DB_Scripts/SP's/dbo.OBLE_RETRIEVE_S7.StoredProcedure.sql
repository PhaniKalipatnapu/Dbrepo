/****** Object:  StoredProcedure [dbo].[OBLE_RETRIEVE_S7]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
                                                                                                                                                                                                                                                                     
CREATE PROCEDURE [dbo].[OBLE_RETRIEVE_S7]                                                                                                                                                                                                                                
   ( 
     @An_Case_IDNO		     NUMERIC(6,0),                                                                                                                                                                                                                                                                 
     @An_OrderSeq_NUMB		 NUMERIC(2,0),
     @An_ObligationSeq_NUMB	 NUMERIC(2,0),                                                                                                                                                                                                 
     @An_MemberMci_IDNO		 NUMERIC(10,0) OUTPUT,                                                                                                                                                                                          
     @Ac_TypeDebt_CODE		 CHAR(2)	OUTPUT, 
     @Ad_EndObligation_DATE	 DATE		OUTPUT,                                                                                                                                                                                         
     @Ac_CheckRecipient_ID	 CHAR(10)	OUTPUT,  
     @Ac_CheckRecipient_CODE CHAR(1)	OUTPUT                                                                                                                                                                                       
      
     )                                                                                                                                                                                      
AS                                                                                                                                                                                                                                                                   
/*                                                                                                                                                                                                                                                                   
*     PROCEDURE NAME    : OBLE_RETRIEVE_S7                                                                                                                                                                                                                           
 *     DESCRIPTION       : It retrives the case obligation detail for the maximum BeginObligation_DATE in a given case_idno.                                                                                                                                                                                                                                           
 *     DEVELOPED BY      : IMP Team                                                                                                                                                                                                                                
 *     DEVELOPED ON      : 02-SEP-2011                                                                                                                                                                                                                               
 *     MODIFIED BY       :                                                                                                                                                                                                                                           
 *     MODIFIED ON       :                                                                                                                                                                                                                                           
 *     VERSION NO        : 1                                                                                                                                                                                                                                         
*/                                                                                                                                                                                                                                                                   
BEGIN                                                                                                                                                                                                                                                             
                                                                                                                                                                                                                                                                     
      SELECT @Ac_CheckRecipient_CODE = NULL,                                                                                                                                                             
			 @Ad_EndObligation_DATE = NULL,
			 @Ac_TypeDebt_CODE = NULL,                                                                                                                                                                                                                                   
			 @Ac_CheckRecipient_ID = NULL,                                                                                                                                                                                                                             
			 @An_MemberMci_IDNO = NULL;                                                                                                                                                                                                                                  
                                                                                                                                                                                                                                                                     
     DECLARE @Ld_High_DATE		DATE = '12/31/9999',                                                                                                                                                                                                             
             @Ld_Current_DATE	DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();                                                                                                                                                                                                                                                           
      SELECT @An_MemberMci_IDNO = a.MemberMci_IDNO, 
             @Ac_TypeDebt_CODE = a.TypeDebt_CODE, 
             @Ac_CheckRecipient_ID = a.CheckRecipient_ID, 
             @Ac_CheckRecipient_CODE = a.CheckRecipient_CODE, 
             @Ad_EndObligation_DATE = ISNULL(a.EndObligation_DATE, @Ld_High_DATE)
        FROM OBLE_Y1 a                                                                                                                                                                                                                                         
       WHERE a.Case_IDNO = @An_Case_IDNO 
         AND a.OrderSeq_NUMB = @An_OrderSeq_NUMB 
         AND a.ObligationSeq_NUMB = @An_ObligationSeq_NUMB 
         AND a.EndValidity_DATE = @Ld_High_DATE 
         AND a.BeginObligation_DATE =                                                                                                                                                                                                                                    
						 (                                                                                                                                                                                                                                                           
							SELECT MAX(b.BeginObligation_DATE)                                                                                                                                                                                                              
							  FROM OBLE_Y1 b                                                                                                                                                                                                                                   
							 WHERE b.Case_IDNO = a.Case_IDNO 
							   AND b.OrderSeq_NUMB = a.OrderSeq_NUMB 
							   AND b.ObligationSeq_NUMB = a.ObligationSeq_NUMB 
							   AND b.BeginObligation_DATE <= @Ld_Current_DATE 
							   AND b.EndValidity_DATE = @Ld_High_DATE                                                                                                                                                                                                               
						 );                                                                                                                                                                                                                                                          
                                                                                                                                                                                                                                                                     
END;--End of OBLE_RETRIEVE_S7                                                                                                                                                                                                                                                                 
                                                                                                                                                                                                                                                                     

GO
