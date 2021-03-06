/****** Object:  StoredProcedure [dbo].[DERR_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 CREATE PROCEDURE [dbo].[DERR_RETRIEVE_S1](      
     @Ac_CheckRecipient_CODE		 CHAR(1), 
     @Ad_Generate_DATE				 DATE,
     @Ac_ReasonActionReject_CODE	 CHAR(3), 
     @Ac_ReasonActionInfo_CODE       CHAR(3),  
     @Ac_MediumDisburse_CODE		 CHAR(1),  
     @Ai_RowFrom_NUMB                INT = 1 ,  
     @Ai_RowTo_NUMB                  INT = 10
     ) 
AS  
  
/*  
 *     PROCEDURE NAME    : DERR_RETRIEVE_S1   
 *     DESCRIPTION       : This procedure is used to get the details from DERR_Y1 for the given date, and populated
 *						   the grid in the 'View Daily EFT Changes / Rejects' screen function. This
 *						   procedure is also used to generate  report where the row_from and row_to will
 *						   be passed as 0 and condition is handled.  
 *     DEVELOPED BY      : IMP Team  
 *     DEVELOPED ON      : 02-NOV-2011  
 *     MODIFIED BY       :   
 *     MODIFIED ON       :   
 *     VERSION NO        : 1  
 */  
 
    BEGIN  
       DECLARE  
         @Li_Zero_NUMB							INT			 = 0,
         @Lc_RelationshipCaseCp_CODE			CHAR(1)      = 'C',   
         @Lc_Space_CODE							CHAR(1)      = ' ',   
         @Lc_StatusCaseMemberActive_CODE		CHAR(1)      = 'A',   
         @Ld_High_DATE							DATE		 = '12/31/9999',   
         @Lc_DisburseStatusRejectedEft_CODE		CHAR(2)		 = 'RE',   
         @Lc_DisburseStatusTransferEft_CODE		CHAR(2)      = 'TR',   
         @Lc_PreNoteEft_CODE					CHAR(1)      = 'P',
         @Lc_ReasonActionC04_CODE				CHAR(3)		 = 'C04',
         @Lc_ReasonActionRpct_CODE				CHAR(2)		 = 'R%',
         @Lc_ReasonActionCpct_CODE				CHAR(2)		 = 'C%';
         
        
         SELECT Case_IDNO, 
         		CheckRecipient_IDNO,      
                MemberMci_IDNO, 
                MemberSsn_NUMB,              
                Disburse_DATE, 
                Disburse_AMNT,               
                Misc_ID,
                Recipient_NAME,                 
                ReasonAction_CODE,
                Y.RowCount_NUMB                                         
            FROM (
				   SELECT X.CheckRecipient_IDNO, 
                          X.MemberSsn_NUMB, 
                          X.MemberMci_IDNO,           
                          X.Disburse_AMNT, 
                          X.Disburse_DATE, 
                          X.Case_IDNO, 
                          X.Misc_ID,      
                          X.Recipient_NAME, 
                          X.ReasonAction_CODE,
                          COUNT (1) OVER () AS RowCount_NUMB,                              
                          ROW_NUMBER () OVER (ORDER BY X.CheckRecipient_IDNO,X.MemberSsn_NUMB,X.MemberMci_IDNO) AS ORD_ROWNUM                                 
                    FROM (
						   SELECT a.CheckRecipient_ID AS CheckRecipient_IDNO,            
                                  f.MemberSsn_NUMB,
                                  e.MemberMci_IDNO AS MemberMci_IDNO,                      
                                  b.Disburse_AMNT AS Disburse_AMNT,                        
                                  b.Disburse_DATE AS Disburse_DATE,                        
                                  d.Case_IDNO AS Case_IDNO, 
                                  a.Misc_ID AS Misc_ID,      
                                  dbo.BATCH_COMMON$SF_GET_MASKED_RECIPIENT_NAME            
												(b.CheckRecipient_ID,                       
												 b.CheckRecipient_CODE                        
												) AS Recipient_NAME,                          
                                  a.ReasonAction_CODE                             
                             FROM DERR_Y1 a
								  JOIN DSBH_Y1 b
									ON	a.CheckRecipient_ID = b.CheckRecipient_ID            
										AND a.CheckRecipient_CODE = b.CheckRecipient_CODE            
										AND a.Misc_ID = b.Misc_ID 
								  JOIN DSBL_Y1 d 
								    ON  b.CheckRecipient_ID = d.CheckRecipient_ID            
										AND b.CheckRecipient_CODE = d.CheckRecipient_CODE            
										AND b.Disburse_DATE = d.Disburse_DATE                        
										AND b.DisburseSeq_NUMB = d.DisburseSeq_NUMB                          
										AND d.DisburseSubSeq_NUMB = 1    
								  LEFT OUTER JOIN CMEM_Y1 e
									ON  d.Case_IDNO = e.Case_IDNO
								  LEFT OUTER JOIN DEMO_Y1 f
									ON	f.MemberMci_IDNO = e.MemberMci_IDNO                   
                            WHERE a.Generate_DATE = @Ad_Generate_DATE                      
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
                              AND a.TypeEft_CODE != @Lc_PreNoteEft_CODE                         
                              AND (   (    b.StatusCheck_CODE = @Lc_DisburseStatusRejectedEft_CODE         
                                       AND (   a.ReasonAction_CODE LIKE @Lc_ReasonActionRpct_CODE               
                                            OR a.ReasonAction_CODE = @Lc_ReasonActionC04_CODE               
                                           )                                               
                                      )                                                    
                                   OR (    b.StatusCheck_CODE = @Lc_DisburseStatusTransferEft_CODE         
                                       AND (    a.ReasonAction_CODE LIKE @Lc_ReasonActionCpct_CODE              
                                            AND a.ReasonAction_CODE <> @Lc_ReasonActionC04_CODE               
                                           )                                               
                                      )                                                    
                                  )                                                        
                              AND b.EndValidity_DATE = @Ld_High_DATE                        
                              AND e.CaseRelationship_CODE = @Lc_RelationshipCaseCp_CODE         
                              AND e.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE         
                           UNION                                                           
                          SELECT  a.CheckRecipient_ID AS CheckRecipient_IDNO,            
                                  c.MemberSsn_NUMB,    
                                  a.CheckRecipient_ID AS MemberMci_IDNO,                 
                                  0 AS Disburse_AMNT,                                      
                                  b.EftStatus_DATE AS Disburse_DATE,                       
                                  0 AS Case_IDNO,                                  
                                  a.Misc_ID AS Misc_ID,                                
                                  dbo.BATCH_COMMON$SF_GET_MASKED_RECIPIENT_NAME            
                                             (b.CheckRecipient_ID,                       
                                              b.CheckRecipient_CODE                        
                                             ) AS Recipient_NAME,                          
                                  a.ReasonAction_CODE
                            FROM  DERR_Y1 a
								   JOIN EFTR_Y1 b 
								     ON a.CheckRecipient_ID = b.CheckRecipient_ID            
										AND	a.CheckRecipient_CODE = b.CheckRecipient_CODE            
										AND	a.Misc_ID = b.Misc_ID
								   LEFT OUTER JOIN DEMO_Y1 c  
									 ON b.CheckRecipient_ID = c.MemberMci_IDNO
                            WHERE 	a.Generate_DATE = @Ad_Generate_DATE                      
                              AND	a.TypeEft_CODE = @Lc_PreNoteEft_CODE                          
                              AND (   @Ac_ReasonActionReject_CODE IS NULL                        
                                   OR @Ac_ReasonActionReject_CODE = @Lc_Space_CODE                    
                                   OR a.ReasonAction_CODE = @Ac_ReasonActionReject_CODE          
                                  )                                                        
                              AND (   @Ac_ReasonActionInfo_CODE IS NULL                          
                                   OR @Ac_ReasonActionInfo_CODE = @Lc_Space_CODE                      
                                   OR a.ReasonAction_CODE = @Ac_ReasonActionInfo_CODE            
                                  )                                                        
                              AND (   @Ac_CheckRecipient_CODE IS NULL                      
                                   OR (    @Ac_CheckRecipient_CODE IS NOT NULL             
                                       AND a.CheckRecipient_CODE = @Ac_CheckRecipient_CODE         
                                      )                                                    
                                  )                                                        
                              AND	b.EndValidity_DATE = @Ld_High_DATE
						 ) X
				) Y                  
          WHERE (    Y.ORD_ROWNUM >= @Ai_RowFrom_NUMB                                    
                 AND Y.ORD_ROWNUM <= @Ai_RowTo_NUMB                                      
                )                                                                        
             OR (@Ai_RowFrom_NUMB = @Li_Zero_NUMB)                                                   
       ORDER BY ORD_ROWNUM;                                                              
                                                                                           
END; -- END OF DERR_RETRIEVE_S1  
  

GO
