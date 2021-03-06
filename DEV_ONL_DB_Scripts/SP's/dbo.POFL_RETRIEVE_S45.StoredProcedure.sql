/****** Object:  StoredProcedure [dbo].[POFL_RETRIEVE_S45]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[POFL_RETRIEVE_S45](                  
 @Ac_Reason_CODE	CHAR(2)		,                  
 @Ac_Status_CODE	CHAR(1)		,              
 @Ad_From_DATE		DATE		,                  
 @Ad_To_DATE		DATE		, 
 @Ai_RowFrom_NUMB	INT = 1		,                  
 @Ai_RowTo_NUMB	INT = 10	               
 )             
 AS          
 
 /*        
 *     PROCEDURE NAME    : POFL_RETRIEVE_S45        
 *     DESCRIPTION       : Retrieve transaction details for reason code,status code  
 *     DEVELOPED BY      : IMP Team        
 *     DEVELOPED ON      : 19-OCT-2011        
 *     MODIFIED BY       :         
 *     MODIFIED ON       :         
 *     VERSION NO        : 1        
*/                
  BEGIN  
                  
   DECLARE                   
       @Ld_High_DATE						DATE	= '12/31/9999',                  
       @Lc_Yes_INDC							CHAR(1) = 'Y',
       @Lc_Zero_TEXT						CHAR(1)='0',       
       @Lc_RecoupmentPayeeSDU_CODE			CHAR(1) = 'D',                  
       @Lc_TypeRecoupmentR_CODE				CHAR(1) = 'R',                  
       @Lc_RecoupmentPayeeState_CODE		CHAR(1) = 'S',                  
       @Lc_StatusPending_CODE				CHAR(1) = 'P',                  
       @Lc_StatusActive_CODE				CHAR(1) = 'A',                  
       @Lc_StatusRecouped_CODE				CHAR(1) = 'R',
       @Lc_CaseRelationshipCp_CODE			CHAR(1) = 'C',  
       @Lc_CaseRelationshipNcp_CODE			CHAR(1) = 'A',  
       @Lc_CaseRelationshipPutFather_CODE	CHAR(1) = 'P',  
       @Lc_CaseMemberStatusActive_CODE		CHAR(1) = 'A',
       @Ls_Select1_TEXT						VARCHAR(4000),
       @Ls_Select2_TEXT						VARCHAR(4000),
       @Ls_Where_TEXT						VARCHAR(4000);                     
                        
     SET @Ls_Select1_TEXT = 'SELECT Z.CheckRecipient_ID,
            Z.CheckRecipient_CODE,
            Z.Case_IDNO,
            Z.Transaction_CODE,
            Z.Transaction_DATE, 
            Z.PendOffset_AMNT, 
            Z.AssessOverpay_AMNT, 
			Z.RecOverpay_AMNT, 
            Z.Batch_DATE,   
            Z.SourceBatch_CODE,             
            Z.Batch_NUMB,        
            Z.SeqReceipt_NUMB ,              
            Z.ReasonBackOut_CODE,
            Z.Worker_ID,
			Z.MemberMci_IDNO ,     
			dbo.BATCH_COMMON$SF_GET_MASKED_MEMBER_NAME                  
						   (Z.MemberMci_IDNO) NCPMember_NAME,   
			Z.CPMember_IDNO,                  
              dbo.BATCH_COMMON$SF_GET_MASKED_MEMBER_NAME                  
                   ( Z.CPMember_IDNO ) CPMember_NAME,
                dbo.BATCH_COMMON$SF_GET_MASKED_MEMBER_NAME                  
                                          (Z.CheckRecipient_ID                  
                                          ) CheckRecipient_NAME, 
               Z.RowCount_NUMB  
           FROM ( SELECT Y.Transaction_DATE, 
						Y.Transaction_CODE, 
						Y.Case_IDNO,                  
                        Y.CheckRecipient_ID, 
                        Y.CheckRecipient_CODE,                  
                        Y.PendOffset_AMNT, 
                        Y.AssessOverpay_AMNT, 
                        Y.RecOverpay_AMNT,                  
                        Y.ReasonBackOut_CODE, 
                        Y.Batch_DATE, 
                        Y.SourceBatch_CODE,                  
                        Y.Batch_NUMB, 
                        Y.SeqReceipt_NUMB, 
                        Y.EventGlobalSeq_NUMB,
                        Y.EventGlobalBeginSeq_NUMB,                  
                        Y.EventGlobalEndSeq_NUMB,
                        Y.Unique_IDNO,    
                        Y.Worker_ID, 
							(  SELECT TOP 1 c.MemberMci_IDNO  
							FROM CMEM_Y1 c  
						   WHERE c.Case_IDNO = Y.Case_IDNO  
							 AND c.CaseRelationship_CODE = CASE c.CaseRelationship_CODE WHEN'''+@Lc_CaseRelationshipNcp_CODE+'''
																						THEN '''+@Lc_CaseRelationshipNcp_CODE+'''
																						WHEN '''+@Lc_CaseRelationshipPutFather_CODE+'''  
																						THEN '''+@Lc_CaseRelationshipPutFather_CODE+'''  
															END
							 AND c.CaseMemberStatus_CODE = '''+@Lc_CaseMemberStatusActive_CODE +'''
							 )  MemberMci_IDNO ,   						    
					(  SELECT  c.MemberMci_IDNO  
						FROM CMEM_Y1 c  
						WHERE c.Case_IDNO = Y.Case_IDNO 
						AND c.CaseRelationship_CODE = '''+@Lc_CaseRelationshipCp_CODE  +'''
						AND c.CaseMemberStatus_CODE = '''+@Lc_CaseMemberStatusActive_CODE + ''') CPMember_IDNO,            
                        COUNT (1) OVER () RowCount_NUMB,  
                        ROW_NUMBER() OVER(ORDER BY Y.Transaction_DATE ,Y.EventGlobalSeq_NUMB,Y.Unique_IDNO) row_num                  
                   FROM (' ;
                 
            SET @Ls_Select2_TEXT =   ' SELECT   a.Transaction_DATE,                  
                                  a.Transaction_CODE, 
                                  a.Case_IDNO,                  
                                  a.PendOffset_AMNT, 
                                  a.AssessOverpay_AMNT,                  
                                  a.RecOverpay_AMNT, 
                                  b.ReasonBackOut_CODE,                  
                                  a.EventGlobalSeq_NUMB, 
                                  b.EventGlobalBeginSeq_NUMB,                  
                                  b.EventGlobalEndSeq_NUMB, 
                                  a.CheckRecipient_CODE,                  
                                  a.CheckRecipient_ID,   
                                  c.Worker_ID,   
                                  a.Batch_DATE, 
                                  a.SourceBatch_CODE,                  
                                  a.Batch_NUMB, 
                                  a.SeqReceipt_NUMB,
                                  a.Unique_IDNO 
                                 FROM  POFL_Y1 a 
                                 LEFT OUTER JOIN  RCTH_Y1 b 
										ON  (
												a.Batch_DATE = b.Batch_DATE 
											AND a.SourceBatch_CODE = b.SourceBatch_CODE                  
											AND a.Batch_NUMB = b.Batch_NUMB 
											AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB 
											AND a.Reason_CODE = b.ReasonBackOut_CODE
											AND b.BackOut_INDC = ''' +@Lc_Yes_INDC+'''   
											AND b.EndValidity_DATE =   ''' + CONVERT(VARCHAR(10), @Ld_High_DATE, 111) + '''  
                                           )  
								JOIN GLEV_Y1 c 
										ON (
												c.EventGlobalSeq_NUMB = a.EventGlobalSeq_NUMB
											) ' ;
											
				SET @Ls_Where_TEXT = '	WHERE a.Transaction_DATE BETWEEN ''' + CONVERT(VARCHAR(10), @Ad_From_DATE, 111) + ''' AND ''' + CONVERT(VARCHAR(10), @Ad_To_DATE, 111) + '''
							AND (  a.TypeRecoupment_CODE <> '''+@Lc_TypeRecoupmentR_CODE + '''
								OR (  	a.TypeRecoupment_CODE = '''+@Lc_TypeRecoupmentR_CODE +'''                   
									AND a.RecoupmentPayee_CODE IN ( '''+@Lc_RecoupmentPayeeState_CODE+''' ,  '''+@Lc_RecoupmentPayeeSdu_CODE+''' )                    
									)                    
                                )  
							AND ( '
							
							+ CASE WHEN  @Ac_Status_CODE = @Lc_StatusPending_CODE
								   THEN 	' ( (a.PendOffset_AMNT <> '+@Lc_Zero_TEXT+')                 
											 AND a.AssessOverpay_AMNT <='+@Lc_Zero_TEXT+')  '
								   WHEN  @Ac_Status_CODE = @Lc_StatusActive_CODE
								   THEN   ' ( ( a.AssessOverpay_AMNT <> '+@Lc_Zero_TEXT+'                  
											 AND a.PendOffset_AMNT <='+@Lc_Zero_TEXT+' )                  
										   ) '
									WHEN  @Ac_Status_CODE = @Lc_StatusRecouped_CODE                  
									THEN  '( a.PendOffset_AMNT ='+@Lc_Zero_TEXT+'                  
											 AND a.AssessOverpay_AMNT ='+@Lc_Zero_TEXT+'                  
											AND a.RecOverpay_AMNT !='+@Lc_Zero_TEXT+'
											)'   
									WHEN  @Ac_Status_CODE IS NULL             
								    THEN  '(    a.PendOffset_AMNT != '+@Lc_Zero_TEXT+'                   
											   OR a.AssessOverpay_AMNT !='+@Lc_Zero_TEXT+'               
											   OR a.RecOverpay_AMNT !='+@Lc_Zero_TEXT+'             
											 )  ' 
									END
							+  	CASE WHEN @Ac_Reason_CODE IS NOT NULL	 
								   THEN 'AND a.Reason_CODE = '''+@Ac_Reason_CODE+ ''''
								   ELSE ''
								 END
							+ ') 	
								)Y ) Z 
		     WHERE  (
					(
						'''+CONVERT(VARCHAR(10),@Ai_RowFrom_NUMB )+'''= '+@Lc_Zero_TEXT+'
					)
					OR ( '''+CONVERT(VARCHAR(10),@Ai_RowFrom_NUMB)+''' <> '+@Lc_Zero_TEXT+'
					AND row_num <= '''+CONVERT(VARCHAR(10),@Ai_RowTo_NUMB)+'''  
					AND row_num >= '''+CONVERT(VARCHAR(10),@Ai_RowFrom_NUMB)+''' 
					) 
				 )	              
      ORDER BY  Z.Transaction_DATE ,Z.EventGlobalSeq_NUMB, Z.Unique_IDNO, Z.EventGlobalBeginSeq_NUMB,                  
       Z.EventGlobalEndSeq_NUMB';
       
       EXEC (@Ls_Select1_TEXT+@Ls_Select2_TEXT+@Ls_Where_TEXT);
     
               
 END;	--END OF POFL_RETRIEVE_S45

GO
