/****** Object:  StoredProcedure [dbo].[DERR_RETRIEVE_S2]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DERR_RETRIEVE_S2] (  

     @Ac_CheckRecipient_CODE		 CHAR(1),
     @Ad_Generate_DATE				 DATE,
     @Ac_ReasonActionReject_CODE	 CHAR(3),
     @Ac_ReasonActionInfo_CODE       CHAR(3),
     @Ac_MediumDisburse_CODE		 CHAR(1),
     @An_TotDisburse_AMNT			 NUMERIC(22,2)  OUTPUT ,
     @Ai_RejectsCount_QNTY           INT			OUTPUT
     )
AS

/*
 *     PROCEDURE NAME    : DERR_RETRIEVE_S2
 *     DESCRIPTION       : This procedure is used to get the total count, total amount for EFT rejects
 *						   for the given date.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 05-NOV-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/

   BEGIN
      SET @An_TotDisburse_AMNT	   = NULL;
      SET @Ai_RejectsCount_QNTY    = NULL;
      
   DECLARE
		 @Li_One_NUMB						INT			 = 1,
         @Lc_RelationshipCaseCp_CODE        CHAR(1)      = 'C', 
         @Lc_Space_CODE                     CHAR(1)      = ' ', 
         @Lc_StatusCaseMemberActive_CODE    CHAR(1)      = 'A', 
         @Ld_High_DATE						DATE		 = '12/31/9999', 
         @Lc_DisburseStatusRejectedEft_CODE CHAR(2)		 = 'RE', 
         @Lc_DisburseStatusTransferEft_CODE CHAR(2)		 = 'TR', 
         @Lc_PreNoteEft_CODE                CHAR(1)      = 'P', 
         @Lc_ReasonActionR_CODE             CHAR(1)      = 'R',
         @Lc_ReasonActionC04_CODE			CHAR(3)		 = 'C04',
         @Lc_ReasonActionRpct_CODE			CHAR(2)		 = 'R%',
         @Lc_ReasonActionCpct_CODE			CHAR(2)		 = 'C%'; 
         
        
         SELECT @Ai_RejectsCount_QNTY	 = COUNT(1),      
				@An_TotDisburse_AMNT   = ISNULL(SUM(b.Disburse_AMNT), 0)
           FROM DERR_Y1 a 
				JOIN DSBH_Y1 b 
				  ON a.CheckRecipient_ID		= b.CheckRecipient_ID                            
					 AND a.CheckRecipient_CODE  = b.CheckRecipient_CODE                            
					 AND a.Misc_ID				= b.Misc_ID
				JOIN DSBL_Y1 d 
				  ON b.CheckRecipient_ID		= d.CheckRecipient_ID                            
					 AND b.CheckRecipient_CODE  = d.CheckRecipient_CODE                            
					 AND b.Disburse_DATE		= d.Disburse_DATE                                        
					 AND b.DisburseSeq_NUMB		= d.DisburseSeq_NUMB                                          
					 AND d.DisburseSubSeq_NUMB  = @Li_One_NUMB 	
				LEFT OUTER JOIN CMEM_Y1 e
				  ON d.Case_IDNO = e.Case_IDNO                                             
          WHERE	a.Generate_DATE = @Ad_Generate_DATE                                      
			AND a.TypeEft_CODE != @Lc_PreNoteEft_CODE                                         
			AND LEFT(a.ReasonAction_CODE, @Li_One_NUMB) = @Lc_ReasonActionR_CODE       
            AND (   @Ac_ReasonActionReject_CODE IS NULL                                        
                 OR @Ac_ReasonActionReject_CODE = @Lc_Space_CODE                                    
                 OR a.ReasonAction_CODE = @Ac_ReasonActionReject_CODE                          
                )                                                                        
            AND (   @Ac_ReasonActionInfo_CODE IS NULL                                          
                 OR @Ac_ReasonActionInfo_CODE = @Lc_Space_CODE                                      
                 OR a.ReasonAction_CODE = @Ac_ReasonActionInfo_CODE                            
                )                                                                        
            AND (   @Ac_MediumDisburse_CODE IS NULL                                      
                 OR (    @Ac_MediumDisburse_CODE IS NOT NULL                             
                     AND b.MediumDisburse_CODE = @Ac_MediumDisburse_CODE                 
                    )                                                                    
                )                                                                        
            AND (   @Ac_CheckRecipient_CODE IS NULL                                      
                 OR (    @Ac_CheckRecipient_CODE IS NOT NULL                             
                     AND a.CheckRecipient_CODE = @Ac_CheckRecipient_CODE                 
                    )                                                                    
                )                                                                        
            AND (   (    b.StatusCheck_CODE = @Lc_DisburseStatusRejectedEft_CODE              
                     AND (a.ReasonAction_CODE LIKE @Lc_ReasonActionRpct_CODE 
						  OR a.ReasonAction_CODE = @Lc_ReasonActionC04_CODE   
                         )                                                               
                    )                                                                    
                 OR (    b.StatusCheck_CODE = @Lc_DisburseStatusTransferEft_CODE              
                     AND (a.ReasonAction_CODE LIKE @Lc_ReasonActionCpct_CODE                                 
                          AND a.ReasonAction_CODE <> @Lc_ReasonActionC04_CODE                               
                         )                                                               
                    )                                                                    
                )                                                                        
            AND b.EndValidity_DATE		= @Ld_High_DATE                                        
            AND e.CaseRelationship_CODE = @Lc_RelationshipCaseCp_CODE                         
            AND e.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE;                    
                                                                                         
END; -- END OF DERR_RETRIEVE_S2


GO
