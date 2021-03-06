/****** Object:  StoredProcedure [dbo].[RCTH_RETRIEVE_S139]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE PROCEDURE [dbo].[RCTH_RETRIEVE_S139](
     @An_Case_IDNO					NUMERIC(6),  
     @An_SupportYearMonthFrom_NUMB  NUMERIC(6),  
     @An_SupportYearMonthTo_NUMB    NUMERIC(6),  
     @An_Payment_AMNT				NUMERIC(15,2)	 OUTPUT 
     ) 
AS  
  
/*  
 *     PROCEDURE NAME    : RCTH_RETRIEVE_S139  
 *     DESCRIPTION       : It Retrieve the Held Reciept Amount
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 04-AUG-2011  
 *     MODIFIED BY       :   
 *     MODIFIED ON       :   
 *     VERSION NO        : 1  
*/  
   BEGIN  
  
      SET @An_Payment_AMNT = NULL;  
  
      DECLARE  
         @Lc_RelationshipCaseNcp_CODE       CHAR(1)     = 'A',   
         @Lc_RelationshipCasePutFather_CODE CHAR(1)     = 'P',   
         @Lc_StatusCaseMemberActive_CODE    CHAR(1)     = 'A',   
         @Lc_TypeRecordOriginal_CODE        CHAR(1)     = 'O',   
         @Ld_High_DATE						DATE		= '12/31/9999',   
         @Ld_Low_DATE						DATE		= '01/01/0001',   
         @Li_DirectPayCredit1040_NUMB		INT			= 1040,   
         @Li_ReceiptReversed1250_NUMB		INT			= 1250,   
         @Li_ManuallyDistributeReceipt1810_NUMB    INT	= 1810,   
         @Li_ReceiptDistributed1820_NUMB    INT			= 1820;  
  
      SELECT @An_Payment_AMNT = SUM(X.Payment_AMNT)  
      FROM (  
            SELECT CASE WHEN a.Distribute_DATE != @Ld_Low_DATE THEN dbo.BATCH_COMMON$SF_AMT_DISTRIBUTE(  
                     @An_Case_IDNO,   
                     a.Batch_DATE,   
                     a.SourceBatch_CODE,   
                     a.Batch_NUMB,   
                     a.SeqReceipt_NUMB,   
                     a.BackOut_INDC,   
                     a.EventGlobalBeginSeq_NUMB)  
                  ELSE a.ToDistribute_AMNT  
               END AS Payment_AMNT  
            FROM RCTH_Y1 a  
            WHERE a.PayorMCI_IDNO IN   
               (  
                  SELECT C.MemberMci_IDNO  
                  FROM CMEM_Y1 C 
                  WHERE   
                     C.Case_IDNO = @An_Case_IDNO    
                    AND C.CaseRelationship_CODE IN ( @Lc_RelationshipCaseNcp_CODE, @Lc_RelationshipCasePutFather_CODE)    
                    AND  C.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE  
               )   
              AND a.StatusReceipt_CODE='I'   
              AND EXISTS   
               (  
                  SELECT 1  
                  FROM LSUP_Y1 b  
                  WHERE  b.Case_IDNO = @An_Case_IDNO    
                    AND b.SupportYearMonth_NUMB BETWEEN @An_SupportYearMonthFrom_NUMB AND @An_SupportYearMonthTo_NUMB    
                    AND b.EventFunctionalSeq_NUMB IN ( @Li_ManuallyDistributeReceipt1810_NUMB, @Li_ReceiptDistributed1820_NUMB, @Li_ReceiptReversed1250_NUMB, @Li_DirectPayCredit1040_NUMB )    
                    AND b.TypeRecord_CODE = @Lc_TypeRecordOriginal_CODE    
                    AND b.Batch_DATE = a.Batch_DATE    
                    AND b.Batch_NUMB = a.Batch_NUMB    
                    AND b.SourceBatch_CODE = a.SourceBatch_CODE    
                    AND b.SeqReceipt_NUMB = a.SeqReceipt_NUMB  
               )    
             AND  a.EndValidity_DATE = @Ld_High_DATE  
         )  AS X;  
          
   END;--End of RCTH_RETRIEVE_S139  
  


GO
