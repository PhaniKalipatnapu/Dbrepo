/****** Object:  StoredProcedure [dbo].[URCT_RETRIEVE_S2]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE PROCEDURE [dbo].[URCT_RETRIEVE_S2]    (
  
     @Ad_Batch_DATE							DATE,  
     @Ai_Row_NUMB                           INT,  
     @An_Batch_NUMB                         NUMERIC(4,0),  
     @Ac_SourceBatch_CODE		 			CHAR(3),  
     @An_SeqReceipt_NUMB		 			NUMERIC(6,0),  
     @Ac_IdentificationStatus_CODE		 	CHAR(1)	 				OUTPUT,  
     @Ad_Identified_DATE					DATE	 				OUTPUT,  
     @An_RowCount_NUMB                      NUMERIC(6,0)            OUTPUT,  
     @An_EventGlobalBeginSeq_NUMB			NUMERIC(19,0)	 		OUTPUT,  
     @An_BankAcct_NUMB		 				NUMERIC(17,0)	 		OUTPUT,  
     @Ac_Bank1_ADDR		 					CHAR(25)	 			OUTPUT,  
     @Ac_Bank2_ADDR		 					CHAR(25)	 			OUTPUT,  
     @Ac_BankCity_ADDR		 				CHAR(20)	 			OUTPUT,
     @An_Bank_IDNO		 	 				NUMERIC(10,0)	 		OUTPUT,  
     @Ac_BankState_ADDR		 				CHAR(2)	 	 			OUTPUT,  
     @Ac_BankZip_ADDR		 				CHAR(15)	 			OUTPUT,  
     @Ac_ReasonStatus_CODE              	CHAR(4)					OUTPUT,  
     @Ac_SourceReceipt_CODE		 			CHAR(2)				    OUTPUT,  
     @An_Employer_IDNO		 				NUMERIC(9,0)	 		OUTPUT,  
     @An_UnidentifiedMemberMci_IDNO		 	NUMERIC(10,0)	 		OUTPUT,  
     @An_OtherParty_IDNO		 			NUMERIC(9,0)	 		OUTPUT,  
     @As_Bank_NAME		 		 			VARCHAR(50)	 			OUTPUT,  
     @As_OtherParty_NAME		 	 		VARCHAR(60)	 			OUTPUT,  
     @Ac_PayorLine1_ADDR		 			CHAR(25)	 			OUTPUT,  
     @Ac_PayorLine2_ADDR		 			CHAR(25)	 			OUTPUT,  
     @Ac_PayorCity_ADDR		 	 			CHAR(20)	 			OUTPUT,  
     @As_Payor_NAME                         VARCHAR(71)             OUTPUT,  
     @Ac_PayorState_ADDR		 			CHAR(2)	 	 	 		OUTPUT,  
     @Ac_PayorZip_ADDR		 				CHAR(15)	 	 		OUTPUT,  
     @As_Remarks_TEXT		 				VARCHAR(328)	 		OUTPUT,  
     @An_UnidentifiedSsn_NUMB		 		NUMERIC(9,0)	 		OUTPUT,  
     @Ac_Worker_ID		 			 		CHAR(30)	 			OUTPUT,  
     @Ac_RefundRecipient_CODE		 		CHAR(1)	 				OUTPUT,  
     @Ac_RefundRecipient_ID		 		    CHAR(10)	 		    OUTPUT,
     @An_Rapid_IDNO		 					NUMERIC(7,0)	 		OUTPUT,
     @An_RapidEnvelope_NUMB					NUMERIC(10,0)			OUTPUT,
     @An_RapidReceipt_NUMB					NUMERIC(10,0)			OUTPUT,
     @Ac_TypePosting_CODE					CHAR(1)  				OUTPUT,
     @An_Case_IDNO							NUMERIC(6,0)			OUTPUT,
     @An_PayorMci_IDNO						NUMERIC(10,0)			OUTPUT
 )
AS  
/*  
 *     PROCEDURE NAME    : URCT_RETRIEVE_S2  
 *     DESCRIPTION       : Retrieving the Unidentified Receipt details.  
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 02-MAR-2011  
 *     MODIFIED BY       :   
 *     MODIFIED ON       :   
 *     VERSION NO        : 1  
*/  
    BEGIN  
  
      SELECT @Ac_IdentificationStatus_CODE = NULL,  
             @Ad_Identified_DATE = NULL,  
             @An_RowCount_NUMB = NULL , 
             @An_EventGlobalBeginSeq_NUMB = NULL,  
             @An_BankAcct_NUMB = NULL , 
             @Ac_Bank1_ADDR = NULL,  
             @Ac_Bank2_ADDR = NULL,
             @Ac_BankCity_ADDR = NULL,  
             @An_Bank_IDNO = NULL,
             @Ac_BankState_ADDR = NULL,  
             @Ac_BankZip_ADDR = NULL,  
             @Ac_ReasonStatus_CODE = NULL,  
             @Ac_SourceReceipt_CODE = NULL , 
             @An_Employer_IDNO = NULL,  
             @An_UnidentifiedMemberMci_IDNO = NULL,  
             @An_OtherParty_IDNO = NULL,  
             @As_Bank_NAME = NULL,  
             @As_OtherParty_NAME = NULL,  
             @Ac_PayorLine1_ADDR = NULL,  
             @Ac_PayorLine2_ADDR = NULL,  
             @Ac_PayorCity_ADDR = NULL , 
             @As_Payor_NAME = NULL , 
             @Ac_PayorState_ADDR = NULL , 
             @An_Case_IDNO = NULL,  
             @An_PayorMci_IDNO = NULL,
             @Ac_PayorZip_ADDR = NULL , 
             @As_Remarks_TEXT = NULL , 
             @An_UnidentifiedSsn_NUMB = NULL , 
             @Ac_Worker_ID = NULL , 
             @Ac_RefundRecipient_CODE = NULL , 
             @Ac_RefundRecipient_ID = NULL , 
             @An_Rapid_IDNO=NULL ,
             @Ac_TypePosting_CODE =NULL,
             @An_RapidEnvelope_NUMB = NULL,
             @An_RapidReceipt_NUMB = NULL;
  
      DECLARE  
         @Ld_High_DATE				  DATE    = '12/31/9999',
         @Lc_TypeOthpE_CODE           CHAR(1) = 'E',
         @Lc_Empty_Space_TEXT         CHAR(1) = '';  
          
        SELECT @As_Payor_NAME = a.Payor_NAME,   
         @An_UnidentifiedMemberMci_IDNO = a.UnidentifiedMemberMci_IDNO,   
         @An_UnidentifiedSsn_NUMB = a.UnidentifiedSsn_NUMB,   
         @Ac_SourceReceipt_CODE = a.SourceReceipt_CODE,   
         @Ac_PayorLine1_ADDR = a.PayorLine1_ADDR,   
         @Ac_PayorLine2_ADDR = a.PayorLine2_ADDR,   
         @Ac_PayorCity_ADDR = a.PayorCity_ADDR,   
         @Ac_PayorState_ADDR = a.PayorState_ADDR,   
         @Ac_PayorZip_ADDR = a.PayorZip_ADDR,     
         @An_Employer_IDNO = a.Employer_IDNO,   
         @As_OtherParty_NAME = (SELECT TOP 1 O.OtherParty_NAME  
       						  FROM OTHP_Y1 O 
      						 WHERE O.Fein_IDNO = RTRIM(LTRIM(a.Employer_IDNO))  
        					 AND O.TypeOthp_CODE = @Lc_TypeOthpE_CODE  
        					 AND O.EndValidity_DATE = @Ld_High_DATE),  
         @An_Bank_IDNO = a.Bank_IDNO,   
         @As_Bank_NAME = a.Bank_NAME,   
         @An_BankAcct_NUMB = a.BankAcct_NUMB,   
         @Ac_Bank1_ADDR = a.Bank1_ADDR,   
         @Ac_Bank2_ADDR = a.Bank2_ADDR,   
         @Ac_BankCity_ADDR = a.BankCity_ADDR,   
         @Ac_BankState_ADDR = a.BankState_ADDR,   
         @Ac_BankZip_ADDR = a.BankZip_ADDR,     
         @Ac_IdentificationStatus_CODE = a.IdentificationStatus_CODE,   
		 @An_Case_IDNO = a.Case_IDNO,	   
		 @An_PayorMci_IDNO = a. PayorMci_IDNO,  
         @Ad_Identified_DATE = a.Identified_DATE,   
         @An_OtherParty_IDNO = a.OtherParty_IDNO,   
         @An_EventGlobalBeginSeq_NUMB = a.EventGlobalBeginSeq_NUMB,   
         @Ac_ReasonStatus_CODE = a.ReasonStatus_CODE,   
         @As_Remarks_TEXT = a.Remarks_TEXT,   
         @Ac_Worker_ID = a.Worker_ID,   
         @Ac_RefundRecipient_ID = a.RefundRecipient_ID,   
         @Ac_RefundRecipient_CODE = a.RefundRecipient_CODE, 
         @Ac_TypePosting_CODE =a.TypePosting_CODE,
	     @An_Rapid_IDNO = R.Rapid_IDNO,
		 @An_RapidEnvelope_NUMB = R.RapidEnvelope_NUMB,
		 @An_RapidReceipt_NUMB = R.RapidReceipt_NUMB,
         @An_RowCount_NUMB = a.row_count  
      FROM ( SELECT  X.Payor_NAME,   
               X.UnidentifiedMemberMci_IDNO,   
               X.UnidentifiedSsn_NUMB,   
               X.SourceReceipt_CODE,   
               X.PayorLine1_ADDR,   
               X.PayorLine2_ADDR,   
               X.PayorCity_ADDR,   
               X.PayorState_ADDR,   
               X.PayorZip_ADDR,     
               X.Employer_IDNO,   
               X.Bank_IDNO,   
               X.Bank_NAME,   
               X.BankAcct_NUMB,   
               X.Bank1_ADDR,   
               X.Bank2_ADDR,   
               X.BankCity_ADDR,   
               X.BankState_ADDR,   
               X.BankZip_ADDR,     
               X.IdentificationStatus_CODE,     
 			   X.Case_IDNO,
               X.PayorMCI_IDNO,
               X.Identified_DATE,   
               X.OtherParty_IDNO,   
               X.EventGlobalBeginSeq_NUMB,
               --13541 - UDC field on URCT screen showing Refund Reason codes in error Fix - Start
               CASE WHEN  LEN(LTRIM(RTRIM(X.ReasonStatus_CODE))) = 4 THEN X.ReasonStatus_CODE ELSE @Lc_Empty_Space_TEXT END ReasonStatus_CODE,    
               --13541 - UDC field on URCT screen showing Refund Reason codes in error Fix - End
               X.Remarks_TEXT,   
               X.Worker_ID,   
               X.RefundRecipient_ID,
               X.TypePosting_CODE,   
               X.RefundRecipient_CODE,
               x.Batch_DATE,
               x.Batch_NUMB,
               x.SeqReceipt_NUMB,
               x.SourceBatch_CODE,    
               ROW_NUMBER() OVER(  
                  ORDER BY X.EventGlobalSeq_NUMB DESC) AS RecRank_NUMB,   
               COUNT(1) OVER() AS row_count  
            FROM ( SELECT  u.Payor_NAME,   
                     u.UnidentifiedMemberMci_IDNO,   
                     u.UnidentifiedSsn_NUMB,   
                     u.SourceReceipt_CODE,   
                     u.PayorLine1_ADDR,   
                     u.PayorLine2_ADDR,   
                     u.PayorCity_ADDR,   
                     u.PayorState_ADDR,   
                     u.PayorZip_ADDR,     
                     u.Employer_IDNO,   
                     u.Bank_IDNO,   
                     u.Bank_NAME,   
                     u.BankAcct_NUMB,   
                     u.Bank1_ADDR,   
                     u.Bank2_ADDR,   
                     u.BankCity_ADDR,   
                     u.BankState_ADDR,   
                     u.BankZip_ADDR,      
                     u.IdentificationStatus_CODE,
                     r.TypePosting_CODE,
                     r.Case_IDNO,
                     r.PayorMCI_IDNO,      
                     u.Identified_DATE, 
                     u.OtherParty_IDNO,   
                     g.EventGlobalSeq_NUMB,   
                     u.EventGlobalBeginSeq_NUMB,   
                     r.ReasonStatus_CODE ,
                     u.Remarks_TEXT,   
                     g.Worker_ID,   
                     r.RefundRecipient_ID,   
                     r.RefundRecipient_CODE,
                     r.Batch_DATE,
                     r.Batch_NUMB,
                     r.SeqReceipt_NUMB,
                     r.SourceBatch_CODE ,   
                     ROW_NUMBER() OVER(  
                        ORDER BY g.EventGlobalSeq_NUMB DESC) AS ORD_ROWNUM  
                  FROM  RCTH_Y1   r
                        JOIN 
                        URCT_Y1   u 
                      ON(
                              r.Batch_DATE = u.Batch_DATE 
                          AND r.Batch_NUMB = u.Batch_NUMB 
                          AND r.SeqReceipt_NUMB = u.SeqReceipt_NUMB 
                          AND r.SourceBatch_CODE = u.SourceBatch_CODE 
                         ) 
                       JOIN    
                       GLEV_Y1   g  
                       ON (
                            u.EventGlobalBeginSeq_NUMB = g.EventGlobalSeq_NUMB 
                          )
                  WHERE u.Batch_DATE = @Ad_Batch_DATE 
                   AND  u.Batch_NUMB = @An_Batch_NUMB 
                   AND  u.SeqReceipt_NUMB = @An_SeqReceipt_NUMB 
                   AND  u.SourceBatch_CODE = @Ac_SourceBatch_CODE    
                   AND r.EventGlobalBeginSeq_NUMB = (  
                                                       SELECT MAX(y.EventGlobalBeginSeq_NUMB)  
                                                       FROM RCTH_Y1 y  
                                                       WHERE y.Batch_DATE = u.Batch_DATE 
                                                        AND  y.Batch_NUMB = u.Batch_NUMB 
                                                        AND  y.SeqReceipt_NUMB = u.SeqReceipt_NUMB 
                                                        AND  y.SourceBatch_CODE = u.SourceBatch_CODE 
                                                        AND  y.EventGlobalBeginSeq_NUMB <= u.EventGlobalBeginSeq_NUMB  
                                                    )  
                   UNION ALL  
                  SELECT   
                     x.Payor_NAME,   
                     x.UnidentifiedMemberMci_IDNO,   
                     x.UnidentifiedSsn_NUMB,   
                     x.SourceReceipt_CODE,   
                     x.PayorLine1_ADDR,   
                     x.PayorLine2_ADDR,   
                     x.PayorCity_ADDR,   
                     x.PayorState_ADDR,   
                     x.PayorZip_ADDR,     
                     x.Employer_IDNO,   
                     x.Bank_IDNO,   
                     x.Bank_NAME,   
                     x.BankAcct_NUMB,   
                     x.Bank1_ADDR,   
                     x.Bank2_ADDR,   
                     x.BankCity_ADDR,   
                     x.BankState_ADDR,   
                     x.BankZip_ADDR,      
                     x.IdentificationStatus_CODE, 
                     r.TypePosting_CODE,
                     r.Case_IDNO,
                     r.PayorMCI_IDNO,   
                     x.Identified_DATE,
                     x.OtherParty_IDNO,   
                     g.EventGlobalSeq_NUMB,   
                     x.EventGlobalBeginSeq_NUMB ,   
                     r.ReasonStatus_CODE,
                     x.Remarks_TEXT,   
                     g.Worker_ID,   
                     r.RefundRecipient_ID,   
                     r.RefundRecipient_CODE,
                     r.Batch_DATE,
                     r.Batch_NUMB,
                     r.SeqReceipt_NUMB,
                     r.SourceBatch_CODE ,
                     ROW_NUMBER() OVER(  
                        ORDER BY g.EventGlobalSeq_NUMB DESC) AS ORD_ROWNUM                   
                   FROM RCTH_Y1   r
                        JOIN
                        URCT_Y1   x
                        ON (
                                 x.Batch_DATE = r.Batch_DATE 
                             AND x.Batch_NUMB = r.Batch_NUMB 
                             AND x.SeqReceipt_NUMB = r.SeqReceipt_NUMB 
                             AND x.SourceBatch_CODE = r.SourceBatch_CODE 
                            )
                       JOIN
                          GLEV_Y1   g  
                        ON (
                              r.EventGlobalBeginSeq_NUMB = g.EventGlobalSeq_NUMB     
                            )
                  WHERE  r.Batch_DATE = @Ad_Batch_DATE 
                   AND r.Batch_NUMB = @An_Batch_NUMB 
                   AND r.SeqReceipt_NUMB = @An_SeqReceipt_NUMB 
                   AND r.SourceBatch_CODE = @Ac_SourceBatch_CODE 
                   AND NOT EXISTS   
                               (  
                                  SELECT 1  
                                  FROM URCT_Y1  u  
                                  WHERE u.Batch_DATE = r.Batch_DATE 
                                   AND  u.Batch_NUMB = r.Batch_NUMB 
                                   AND  u.SeqReceipt_NUMB = r.SeqReceipt_NUMB 
                                   AND  u.SourceBatch_CODE = r.SourceBatch_CODE 
                                   AND u.EventGlobalBeginSeq_NUMB = r.EventGlobalBeginSeq_NUMB  
                               ) 
                               
                   AND x.EventGlobalBeginSeq_NUMB = (SELECT MAX(y.EventGlobalBeginSeq_NUMB)  
                                                       FROM URCT_Y1 y  
                                                      WHERE y.Batch_DATE = x.Batch_DATE 
                                                       AND  y.Batch_NUMB = x.Batch_NUMB 
                                                       AND  y.SeqReceipt_NUMB = x.SeqReceipt_NUMB 
                                                       AND  y.SourceBatch_CODE = x.SourceBatch_CODE 
                                                       AND  y.EventGlobalBeginSeq_NUMB < r.EventGlobalBeginSeq_NUMB  
                                                     )   
               ) X  
         ) a  LEFT OUTER JOIN RSDU_Y1 R 
			ON R.Batch_DATE = a.Batch_DATE 
            AND R.SourceBatch_CODE = a.SourceBatch_CODE
            AND R.Batch_NUMB = a.Batch_NUMB
            AND R.SeqReceipt_NUMB = a.SeqReceipt_NUMB
				
      WHERE a.RecRank_NUMB = @Ai_Row_NUMB  
ORDER BY RecRank_NUMB;  
  
                    
END   --END OF URCT_RETRIEVE_S2
  



GO
