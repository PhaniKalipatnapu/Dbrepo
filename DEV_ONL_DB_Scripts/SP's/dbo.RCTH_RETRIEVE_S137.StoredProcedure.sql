/****** Object:  StoredProcedure [dbo].[RCTH_RETRIEVE_S137]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE PROCEDURE [dbo].[RCTH_RETRIEVE_S137](
     @An_Case_IDNO		 NUMERIC(6,0), 
     @Ad_ReceiptFrom_DATE          DATE       ,  
     @Ad_ReceiptTo_DATE            DATE       ,
     @An_ToDistribute_AMNT		 NUMERIC(15,2)	 OUTPUT 
     ) 
AS  
  
/*  
 *     PROCEDURE NAME    : RCTH_RETRIEVE_S137  
 *     DESCRIPTION       : It Retrieve the Total Held Amount for the Member id.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 04-AUG-2011  
 *     MODIFIED BY       :   
 *     MODIFIED ON       :   
 *     VERSION NO        : 1  
*/  
 BEGIN  
  
      SET @An_ToDistribute_AMNT = NULL;  
  
      DECLARE  
         @Lc_RelationshipCaseNcp_CODE       CHAR(1)      = 'A',   
         @Lc_RelationshipCasePutFather_CODE CHAR(1)      = 'P',   
         @Lc_StatusCaseMemberActive_CODE    CHAR(1)      = 'A',   
         @Lc_StatusReceiptHeld_CODE         CHAR(1)      = 'H',   
         @Ld_High_DATE                  DATE = '12/31/9999',   
         @Ld_Low_DATE                   DATE = '01/01/0001';  
          
   SELECT @An_ToDistribute_AMNT = SUM(R.ToDistribute_AMNT)  
      FROM RCTH_Y1 R  
   WHERE R.PayorMCI_IDNO IN   
         (  
            SELECT C.MemberMci_IDNO  
            FROM CMEM_Y1 C  
            WHERE   
               C.Case_IDNO = @An_Case_IDNO    
               AND C.CaseRelationship_CODE IN (@Lc_RelationshipCaseNcp_CODE,@Lc_RelationshipCasePutFather_CODE)    
              AND C.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE  
         )    
        AND R.Receipt_DATE BETWEEN @Ad_ReceiptFrom_DATE AND @Ad_ReceiptTo_DATE    
        AND R.StatusReceipt_CODE = @Lc_StatusReceiptHeld_CODE    
        AND R.Distribute_DATE = @Ld_Low_DATE    
        AND R.EndValidity_DATE = @Ld_High_DATE;
                    
 END;--End of RCTH_RETRIEVE_S137   
  

GO
