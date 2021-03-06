/****** Object:  StoredProcedure [dbo].[WEMO_RETRIEVE_S12]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[WEMO_RETRIEVE_S12]  
  (
     @An_Case_IDNO				NUMERIC(6,0),
     @An_OrderSeq_NUMB			NUMERIC(2,0),
     @An_ObligationSeq_NUMB		NUMERIC(2,0),
     @An_WelfareYearMonth_NUMB	NUMERIC(6,0),
     @An_Urg_AMNT				NUMERIC(11,2) OUTPUT
   )
AS
/*
*     PROCEDURE NAME    : WEMO_RETRIEVE_S12
 *     DESCRIPTION       : The procedure to  displaying the URA amount. 
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 02-SEP-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
BEGIN

         SET @An_Urg_AMNT = NULL;

     DECLARE @Li_Zero_NUMB SMALLINT = 0,
			 @Lc_CaseRelationshipCp_CODE CHAR(1) ='C',
			 @Lc_WelfareElig_CODE CHAR(1) ='A',
			 @Lc_CaseMemberStatus_CODE CHAR(1) = 'A',
             @Ld_High_DATE DATE = '12/31/9999'; 
             
     SELECT  @An_Urg_AMNT = ISNULL(SUM(a.LtdAssistExpend_AMNT - a.LtdAssistRecoup_AMNT), 0)
        FROM IVMG_Y1 a  
       WHERE a.WelfareElig_CODE = @Lc_WelfareElig_CODE 
       AND a.CaseWelfare_IDNO IN (SELECT DISTINCT b.CaseWelfare_IDNO
                                                      FROM WEMO_Y1 b  
                                                   WHERE b.Case_IDNO = @An_Case_IDNO   
                                                       AND b.OrderSeq_NUMB = @An_OrderSeq_NUMB   
                                                       AND b.ObligationSeq_NUMB = @An_ObligationSeq_NUMB  
                                                       AND b.EndValidity_DATE = @Ld_High_DATE   
                                                       AND b.WelfareYearMonth_NUMB =   
                                                   (  
                                                   SELECT MAX(c.WelfareYearMonth_NUMB)   
                                                       FROM WEMO_Y1 c  
                                                      WHERE c.Case_IDNO = b.Case_IDNO   
                                                        AND c.OrderSeq_NUMB = b.OrderSeq_NUMB   
                                                        AND c.ObligationSeq_NUMB = b.ObligationSeq_NUMB   
                                                        AND c.CaseWelfare_IDNO = b.CaseWelfare_IDNO   
                                                        AND c.WelfareYearMonth_NUMB <= @An_WelfareYearMonth_NUMB  
                                                        AND c.EndValidity_DATE =  @Ld_High_DATE 
                                                   ))  

         AND a.CpMci_IDNO IN (SELECT d.MemberMci_IDNO 
								FROM CMEM_Y1 d WHERE d.Case_IDNO = @An_Case_IDNO 
									AND d.CaseMemberStatus_CODE = @Lc_CaseMemberStatus_CODE 
                                    AND d.CaseRelationship_CODE = @Lc_CaseRelationshipCp_CODE) 
         AND a.WelfareYearMonth_NUMB = (SELECT MAX(c.WelfareYearMonth_NUMB)   
											   FROM IVMG_Y1 c  
										  WHERE c.CaseWelfare_IDNO = a.CaseWelfare_IDNO   
										  AND c.CpMci_IDNO = a.CpMci_IDNO   
										  AND c.WelfareYearMonth_NUMB <= @An_WelfareYearMonth_NUMB   
										  AND c.WelfareElig_CODE = a.WelfareElig_CODE)
		 AND a.EventGlobalSeq_NUMB = (SELECT MAX(y.EventGlobalSeq_NUMB) 
	                                           FROM IVMG_Y1 y
                                           WHERE y.CaseWelfare_IDNO = a.CaseWelfare_IDNO
                                            AND y.CpMci_IDNO = a.CpMci_IDNO
                                            AND y.WelfareYearMonth_NUMB = a.WelfareYearMonth_NUMB
                                            AND y.WelfareElig_CODE = a.WelfareElig_CODE)

END;--End of WEMO_RETRIEVE_S12


GO
