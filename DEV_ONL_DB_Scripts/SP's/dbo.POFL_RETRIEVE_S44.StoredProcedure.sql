/****** Object:  StoredProcedure [dbo].[POFL_RETRIEVE_S44]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[POFL_RETRIEVE_S44] 
  (                                                     
   @Ad_From_DATE  DATE,                                               
   @Ad_To_DATE  DATE,                                                   
   @Ac_ReasonBackOut_CODE   CHAR(2),                                                   
   @Ac_Worker_ID   CHAR(30),    
   @An_OffsetRec_AMNT    NUMERIC(11,2) OUTPUT,    
   @An_OffsetRecCnt_QNTY   NUMERIC(11)  OUTPUT   
  )    
AS

/*
 *     PROCEDURE NAME    : POFL_RETRIEVE_S44
 *     DESCRIPTION       : This will display the Recoupments Recovered Count and Recoupments Recovered Amount details

 *     DEVELOPED BY      : IMP TEAM
 *     DEVELOPED ON      : 05-NOV-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/

BEGIN

 DECLARE
	 	@Lc_CaseRelationshipA_CODE CHAR(1) = 'A',
	 	@Lc_CaseMemberStatusA_CODE CHAR(1) = 'A',
	 	@Li_Zero_NUMB	SMALLINT	= 0;

  --13698 - RRAR - receiving Timeout Expired system error - Start 	

  SELECT @An_OffsetRec_AMNT = ABS (ISNULL (SUM (a.RecOverpay_AMNT + a.RecAdvance_AMNT), 0)),    
         @An_OffsetRecCnt_QNTY = COUNT (DISTINCT CAST (a.Batch_DATE AS VARCHAR)     
         + CAST (a.Batch_NUMB AS VARCHAR)    
         + CAST (a.SeqReceipt_NUMB AS VARCHAR)    
         + CAST (a.SourceBatch_CODE AS VARCHAR))
       FROM POFL_Y1 a, GLEV_Y1 g    
       WHERE a.Transaction_DATE BETWEEN @Ad_From_DATE AND @Ad_To_DATE    
         AND (a.RecOverpay_AMNT + a.RecAdvance_AMNT > @Li_Zero_NUMB)    
         AND a.Reason_CODE = ISNULL (@Ac_ReasonBackOut_CODE, a.Reason_CODE)    
         AND ( a.Case_IDNO != 0
				OR EXISTS (SELECT 1 
							 FROM CMEM_Y1 m    
                       	    WHERE m.MemberMci_IDNO = a.CheckRecipient_ID    
                         	  AND m.CaseRelationship_CODE = @Lc_CaseRelationshipA_CODE    
                         	  AND m.CaseMemberStatus_CODE = @Lc_CaseMemberStatusA_CODE))  
         AND a.EventGlobalSeq_NUMB = g.EventGlobalSeq_NUMB    
         AND ISNULL(@Ac_Worker_ID, g.Worker_ID) = g.Worker_ID;

  --13698 - RRAR - receiving Timeout Expired system error - End
             
END -- END OF POFL_RETRIEVE_S44
                 

GO
