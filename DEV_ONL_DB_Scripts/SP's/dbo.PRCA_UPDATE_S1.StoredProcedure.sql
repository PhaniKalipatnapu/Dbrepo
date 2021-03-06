/****** Object:  StoredProcedure [dbo].[PRCA_UPDATE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
CREATE PROCEDURE [dbo].[PRCA_UPDATE_S1] (  
 @An_CaseWelfare_IDNO         NUMERIC(10,0),  
 @An_AgSequence_NUMB          NUMERIC(4,0),
 @An_TransactionEventSeq_NUMB NUMERIC(19,0),
 @Ac_SignedOnWorker_ID        CHAR(30)
 )  
AS      
      
/*      
 *     PROCEDURE NAME    : PRCA_UPDATE_S1      
 *     DESCRIPTION       : Delete the pending referrals case details for given case welfare.   
 *     DEVELOPED BY      : IMP Team   
 *     DEVELOPED ON      : 27-NOV-2011      
 *     MODIFIED BY       :       
 *     MODIFIED ON       :       
 *     VERSION NO        : 1      
 */      
BEGIN      
   DECLARE @Lc_ReferralProcessD_CODE CHAR(1) = 'D';  

   UPDATE PRCA_Y1 
      SET ReferralProcess_CODE = @Lc_ReferralProcessD_CODE,
	      WorkerUpdate_ID = @Ac_SignedOnWorker_ID,
		  Update_DTTM     = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME()    
    WHERE CaseWelfare_IDNO=@An_CaseWelfare_IDNO  
      AND AgSequence_NUMB=@An_AgSequence_NUMB
	  AND TransactionEventSeq_NUMB =@An_TransactionEventSeq_NUMB; 
              
   DECLARE @Ln_RowsAffected_NUMB NUMERIC(10);      
   SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;                            
   SELECT @Ln_RowsAffected_NUMB;      
        
END;--End of PRCA_UPDATE_S1.      
  

GO
