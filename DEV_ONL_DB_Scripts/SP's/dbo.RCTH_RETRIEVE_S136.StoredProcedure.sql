/****** Object:  StoredProcedure [dbo].[RCTH_RETRIEVE_S136]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[RCTH_RETRIEVE_S136](
     @An_Case_IDNO		 NUMERIC(6,0),
     @Ad_ReceiptFrom_DATE         DATE,  
     @Ad_ReceiptTo_DATE           DATE
     )                 
AS 
/*  
 *     PROCEDURE NAME    : RCTH_RETRIEVE_S136  
 *     DESCRIPTION       : It Retrieve the Type Posting Code for the Payor Idno.
 *     DEVELOPED BY      : IMP Team  
 *     DEVELOPED ON      : 04-AUG-2011  
 *     MODIFIED BY       :   
 *     MODIFIED ON       :   
 *     VERSION NO        : 1  
*/  
    BEGIN  
     
      DECLARE  
         @Lc_RelationshipCaseNcp_CODE       CHAR(1)      = 'A',   
         @Lc_RelationshipCasePutFather_CODE CHAR(1)      = 'P',   
         @Lc_StatusCaseMemberActive_CODE    CHAR(1)      = 'A',   
         @Lc_StatusReceiptHeld_CODE         CHAR(1)      = 'H',   
         @Ld_High_DATE                  DATE = '12/31/9999',   
         @Ld_Low_DATE                   DATE = '01/01/0001';  
          
      SELECT a.TypePosting_CODE, 
               a.Case_IDNO,
               a.PayorMCI_IDNO , 
               a.ToDistribute_AMNT 
      FROM RCTH_Y1 a  
      WHERE a.PayorMCI_IDNO IN 
         ( 
         SELECT C.MemberMci_IDNO 
         FROM  CMEM_Y1 C  
            WHERE C.Case_IDNO = @An_Case_IDNO    
               AND C.CaseRelationship_CODE IN (@Lc_RelationshipCaseNcp_CODE, @Lc_RelationshipCasePutFather_CODE)    
               AND C.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE  
         )    
        AND a.Receipt_DATE BETWEEN @Ad_ReceiptFrom_DATE AND @Ad_ReceiptTo_DATE    
         AND a.StatusReceipt_CODE = @Lc_StatusReceiptHeld_CODE    
         AND a.Distribute_DATE = @Ld_Low_DATE    
         AND a.EndValidity_DATE = @Ld_High_DATE; 
                    
    END;--End of RCTH_RETRIEVE_S136  
  

GO
