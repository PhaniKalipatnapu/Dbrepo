/****** Object:  StoredProcedure [dbo].[PRCA_UPDATE_S2]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
CREATE PROCEDURE [dbo].[PRCA_UPDATE_S2] (  
 @An_CaseWelfare_IDNO			NUMERIC(10,0),  
 @An_AgSequence_NUMB			NUMERIC(4,0),
 @Ad_ReferralReceived_DATE		DATE,
 @An_Application_IDNO           NUMERIC(15),
 @Ac_SignedOnWorker_ID			CHAR(30)
 )  
AS      
      
/*      
 *     PROCEDURE NAME    : PRCA_UPDATE_S2      
 *     DESCRIPTION       : When Process the Pending Referral Case in CCRT, Update the New Application Id & ReferralProcess as "P" in Pending Referral Case Table. 
 *     DEVELOPED BY      : IMP Team   
 *     DEVELOPED ON      : 04-APR-2012      
 *     MODIFIED BY       :       
 *     MODIFIED ON       :       
 *     VERSION NO        : 1      
 */      
BEGIN      
   DECLARE @Lc_ReferralProcessP_CODE CHAR(1) = 'P',
		   @Li_RowsAffected_NUMB INT;  

   UPDATE PRCA_Y1 
      SET ReferralProcess_CODE = @Lc_ReferralProcessP_CODE,
		  Application_IDNO = @An_Application_IDNO,
	      WorkerUpdate_ID = @Ac_SignedOnWorker_ID,
		  Update_DTTM     = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME()    
    WHERE CaseWelfare_IDNO = @An_CaseWelfare_IDNO  
      AND AgSequence_NUMB = @An_AgSequence_NUMB
      AND ReferralReceived_DATE = @Ad_ReferralReceived_DATE; 
              
   SET @Li_RowsAffected_NUMB = @@ROWCOUNT;

  SELECT @Li_RowsAffected_NUMB AS RowsAffected_NUMB;
        
END;--End of PRCA_UPDATE_S2.      
  

GO
