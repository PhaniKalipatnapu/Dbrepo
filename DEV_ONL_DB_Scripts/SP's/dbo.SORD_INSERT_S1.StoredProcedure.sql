/****** Object:  StoredProcedure [dbo].[SORD_INSERT_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
                                                                               
CREATE PROCEDURE [dbo].[SORD_INSERT_S1]  
(
     @An_Case_IDNO								NUMERIC(6),
     @An_OrderSeq_NUMB							NUMERIC(2),
     @An_Order_IDNO								NUMERIC(15),
     @Ac_File_ID								CHAR(10),
     @Ad_OrderEnt_DATE							DATE,
     @Ad_OrderIssued_DATE						DATE,
     @Ad_OrderEffective_DATE					DATE,
     @Ad_OrderEnd_DATE							DATE,
     @Ac_InsOrdered_CODE						CHAR(1),
     @Ac_MedicalOnly_INDC						CHAR(1),
     @Ac_Iiwo_CODE								CHAR(2),
     @Ac_GuidelinesFollowed_INDC				CHAR(1),
     @Ac_DeviationReason_CODE					CHAR(2),
     @Ac_DescriptionDeviationOthers_TEXT		CHAR(30),
     @Ac_OrderOutOfState_ID						CHAR(15),
     @Ac_CejStatus_CODE							CHAR(1),
     @Ac_CejFips_CODE							CHAR(7),
     @Ac_IssuingOrderFips_CODE					CHAR(7),
     @Ac_Qdro_INDC								CHAR(1),
     @Ac_UnreimMedical_INDC						CHAR(1),
     @An_CpMedical_PCT							NUMERIC(5,2),
     @An_NcpMedical_PCT							NUMERIC(5,2),
     @An_ParentingTime_PCT						NUMERIC(5,2),
     @An_NoParentingDays_QNTY					NUMERIC(3),
     @Ac_PetitionerAppeared_INDC				CHAR(1),
     @Ac_RespondentAppeared_INDC				CHAR(1),
     @Ac_OthersAppeared_INDC					CHAR(1),
     @Ac_PetitionerReceived_INDC				CHAR(1),
     @Ac_RespondentReceived_INDC				CHAR(1),
     @Ac_OthersReceived_INDC					CHAR(1),
     @Ac_PetitionerMailed_INDC					CHAR(1),
     @Ac_RespondentMailed_INDC					CHAR(1),
     @Ac_OthersMailed_INDC						CHAR(1),
     @Ad_PetitionerMailed_DATE					DATE,
     @Ad_RespondentMailed_DATE					DATE,
     @Ad_OthersMailed_DATE						DATE,
     @Ac_CoverageMedical_CODE					CHAR(1),
     @Ac_CoverageDrug_CODE						CHAR(1),
     @Ac_CoverageMental_CODE					CHAR(1),
     @Ac_CoverageDental_CODE					CHAR(1),
     @Ac_CoverageVision_CODE					CHAR(1),
     @Ac_CoverageOthers_CODE					CHAR(1),
     @Ac_DescriptionCoverageOthers_TEXT			CHAR(30),
     @Ac_SignedOnWorker_ID						CHAR(30),
     @An_EventGlobalBeginSeq_NUMB				NUMERIC(19),
     @As_DescriptionParentingNotes_TEXT			VARCHAR(4000),
     @Ad_LastIrscReferred_DATE					DATE,
     @Ad_LastIrscUpdated_DATE					DATE,
     @An_LastIrscReferred_AMNT					NUMERIC(11,2),
     @Ac_StatusControl_CODE						CHAR(1),
     @Ac_StateControl_CODE						CHAR(2),
     @Ac_OrderControl_ID						CHAR(15),
     @Ac_PetitionerAttorneyAppeared_INDC		CHAR(1),
     @Ac_RespondentAttorneyAppeared_INDC		CHAR(1),
     @Ac_PetitionerAttorneyReceived_INDC		CHAR(1),
     @Ac_RespondentAttorneyReceived_INDC		CHAR(1),
     @Ac_PetitionerAttorneyMailed_INDC			CHAR(1),
     @Ac_RespondentAttorneyMailed_INDC			CHAR(1),
     @Ad_PetitionerAttorneyMailed_DATE			DATE,
     @Ad_RespondentAttorneyMailed_DATE			DATE,
     @Ac_TypeOrder_CODE							CHAR(1),
     @Ad_NextReview_DATE						DATE,
     @Ad_LastReview_DATE						DATE,
     @Ac_DirectPay_INDC							CHAR(1),
     @Ac_SourceOrdered_CODE						CHAR(1),
     @Ac_Judge_ID								CHAR(30),
     @Ac_Commissioner_ID						CHAR(30)
  )          
AS
        /*                                                                     
         *     PROCEDURE NAME    : SORD_INSERT_S1                               
         *     DESCRIPTION       : Inserts the Support order details.
         *     DEVELOPED BY      : IMP Team                                 
         *     DEVELOPED ON      : 11/15/2011
         *     MODIFIED BY       :                                             
         *     MODIFIED ON       :                                             
         *     VERSION NO        : 1.0                                  
         */                                                                     
		 -- 13650 - SORD - CR0420 SORD Commissioner and Judge Field on Cases that Share a File ID - START
		 DECLARE @Li_Zero_NUMB						INT			= 0,
				 @Lc_Space_TEXT						CHAR(1)		= ' ',
				 @Ld_Low_DATE						DATE		= '01/01/0001', 
				 @Ld_High_DATE						DATE		= '12/31/9999';
		 DECLARE @Ld_Current_DATE					DATE		= DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(); 
			     
           BEGIN                                                               
              INSERT SORD_Y1(                                              
                 Case_IDNO,                                                    
                 OrderSeq_NUMB,                                                    
                 Order_IDNO,                                                   
                 File_ID,                                                    
                 OrderEnt_DATE,                                                
                 OrderIssued_DATE,                                             
                 OrderEffective_DATE,                                          
                 OrderEnd_DATE,                                                
                 ReasonStatus_CODE,                                            
                 StatusOrder_CODE,                                             
                 StatusOrder_DATE,                                             
                 InsOrdered_CODE,                                              
                 MedicalOnly_INDC,                                             
                 Iiwo_CODE,                                                    
                 NoIwReason_CODE,                                    
                 IwoInitiatedBy_CODE,                                          
                 GuidelinesFollowed_INDC,                                      
                 DeviationReason_CODE,                                         
                 DescriptionDeviationOthers_TEXT,                              
                 OrderOutOfState_ID,                                         
                 CejStatus_CODE,                                               
                 CejFips_CODE,                                                 
                 IssuingOrderFips_CODE,                                        
                 Qdro_INDC,              
                 UnreimMedical_INDC,                                           
                 CpMedical_PCT,                                                
                 NcpMedical_PCT,                                               
                 ParentingTime_PCT,                                            
                 NoParentingDays_QNTY,                                         
                 PetitionerAppeared_INDC,                                      
                 RespondentAppeared_INDC,          
                 OthersAppeared_INDC,                                          
                 PetitionerReceived_INDC,                                      
                 RespondentReceived_INDC,            
                 OthersReceived_INDC,                                          
                 PetitionerMailed_INDC,                                        
                 RespondentMailed_INDC,                                        
                 OthersMailed_INDC,                                            
                 PetitionerMailed_DATE,                                        
                 RespondentMailed_DATE,                                        
                 OthersMailed_DATE, 
                 CoverageMedical_CODE,                                         
                 CoverageDrug_CODE,                                            
                 CoverageMental_CODE,                                          
                 CoverageDental_CODE,                                          
                 CoverageVision_CODE,                                          
                 CoverageOthers_CODE,                                          
                 DescriptionCoverageOthers_TEXT,                               
                 WorkerUpdate_ID,                                            
                 BeginValidity_DATE,                                           
                 EndValidity_DATE,                                             
                 EventGlobalBeginSeq_NUMB,                                         
                 EventGlobalEndSeq_NUMB,                 
                 DescriptionParentingNotes_TEXT,                               
                 LastIrscReferred_DATE,                                        
                 LastIrscUpdated_DATE,                                         
                 LastIrscReferred_AMNT,    
                 StatusControl_CODE,                                           
                 StateControl_CODE,                                            
                 OrderControl_ID,                   
                 PetitionerAttorneyAppeared_INDC,                              
                 RespondentAttorneyAppeared_INDC,                              
                 PetitionerAttorneyReceived_INDC,                              
                 RespondentAttorneyReceived_INDC,                              
                 PetitionerAttorneyMailed_INDC,                                
                 RespondentAttorneyMailed_INDC,                                
                 PetitionerAttorneyMailed_DATE,                                
                 RespondentAttorneyMailed_DATE,                                
                 TypeOrder_CODE,                                               
                 ReviewRequested_DATE,                                         
                 NextReview_DATE,                                              
                 LastReview_DATE,                                              
                 LastNoticeSent_DATE,                                           
                 DirectPay_INDC,                                               
                 SourceOrdered_CODE,
                 Judge_ID,
                 Commissioner_ID                                           
                 )                                                             
                 SELECT  @An_Case_IDNO,    --Case_IDNO                                             
						  @An_OrderSeq_NUMB,--OrderSeq_NUMB                                             
						  @An_Order_IDNO,  --Order_IDNO                                          
						  @Ac_File_ID,  --File_ID                                             
						  @Ad_OrderEnt_DATE,--OrderEnt_DATE                                         
						  @Ad_OrderIssued_DATE, --OrderIssued_DATE                                      
						  @Ad_OrderEffective_DATE,--OrderEffective_DATE                                   
						  @Ad_OrderEnd_DATE, --OrderEnd_DATE                                        
						  @Lc_Space_TEXT, --ReasonStatus_CODE                                    
						  @Lc_Space_TEXT, --StatusOrder_CODE                                     
						  @Ld_Low_DATE, -- StatusOrder_DATE                                    
						  @Ac_InsOrdered_CODE,--InsOrdered_CODE                                       
						  @Ac_MedicalOnly_INDC, --MedicalOnly_INDC                                     
						  @Ac_Iiwo_CODE, --Iiwo_CODE                                            
						  @Lc_Space_TEXT, -- NoIwReason_CODE                           
						  @Lc_Space_TEXT,-- IwoInitiatedBy_CODE                                   
						  @Ac_GuidelinesFollowed_INDC,-- GuidelinesFollowed_INDC                              
						  @Ac_DeviationReason_CODE, --DeviationReason_CODE                                 
						  @Ac_DescriptionDeviationOthers_TEXT,-- DescriptionDeviationOthers_TEXT                      
						  @Ac_OrderOutOfState_ID,--OrderOutOfState_ID                                  
						  @Ac_CejStatus_CODE,--CejStatus_CODE                                        
						  @Ac_CejFips_CODE, --CejFips_CODE                                         
						  @Ac_IssuingOrderFips_CODE,-- IssuingOrderFips_CODE                                
						  @Ac_Qdro_INDC, --Qdro_INDC                                            
						  @Ac_UnreimMedical_INDC, --UnreimMedical_INDC                                   
						  @An_CpMedical_PCT, -- CpMedical_PCT                                       
						  @An_NcpMedical_PCT,  --NcpMedical_PCT                                      
						  @An_ParentingTime_PCT,--  ParentingTime_PCT                                   
						  @An_NoParentingDays_QNTY, -- NoParentingDays_QNTY                                
						  @Ac_PetitionerAppeared_INDC,-- PetitionerAppeared_INDC                              
						  @Ac_RespondentAppeared_INDC,--RespondentAppeared_INDC                               
						  @Ac_OthersAppeared_INDC, --OthersAppeared_INDC                                  
						  @Ac_PetitionerReceived_INDC,-- PetitionerReceived_INDC                              
						  @Ac_RespondentReceived_INDC, --RespondentReceived_INDC                              
						  @Ac_OthersReceived_INDC, --OthersReceived_INDC                                  
						  @Ac_PetitionerMailed_INDC, --PetitionerMailed_INDC                                
						  @Ac_RespondentMailed_INDC, -- RespondentMailed_INDC                               
						  @Ac_OthersMailed_INDC,  --  OthersMailed_INDC                                 
						  @Ad_PetitionerMailed_DATE,--  PetitionerMailed_DATE                               
						  @Ad_RespondentMailed_DATE, -- RespondentMailed_DATE                               
						  @Ad_OthersMailed_DATE, -- OthersMailed_DATE                                   
						  @Ac_CoverageMedical_CODE, --CoverageMedical_CODE                                 
						  @Ac_CoverageDrug_CODE,  -- CoverageDrug_CODE                                  
						  @Ac_CoverageMental_CODE,-- CoverageMental_CODE                                  
						  @Ac_CoverageDental_CODE, -- CoverageDental_CODE                                 
						  @Ac_CoverageVision_CODE, -- CoverageVision_CODE                                 
						  @Ac_CoverageOthers_CODE, --  CoverageOthers_CODE                                
						  @Ac_DescriptionCoverageOthers_TEXT, --                       
						  @Ac_SignedOnWorker_ID, -- WorkerUpdate_ID                                   
						  @Ld_Current_DATE,  -- BeginValidity_DATE                                 
						  @Ld_High_DATE,  --   EndValidity_DATE                                 
						  @An_EventGlobalBeginSeq_NUMB,--EventGlobalBeginSeq_NUMB                                  
						  @Li_Zero_NUMB, --EventGlobalEndSeqZero_NUMB                                   
						  @As_DescriptionParentingNotes_TEXT, -- DescriptionParentingNotes_TEXT                      
						  @Ad_LastIrscReferred_DATE,          -- LastIrscReferred_DATE                     
						  @Ad_LastIrscUpdated_DATE,  -- LastIrscUpdated_DATE                               
						  @An_LastIrscReferred_AMNT, -- LastIrscReferred_AMNT                               
						  @Ac_StatusControl_CODE, -- StatusControl_CODE                                  
						  @Ac_StateControl_CODE, --StateControl_CODE                                    
						  @Ac_OrderControl_ID, --OrderControl_ID                                    
						  @Ac_PetitionerAttorneyAppeared_INDC,--PetitionerAttorneyAppeared_INDC                       
						  @Ac_RespondentAttorneyAppeared_INDC, --RespondentAttorneyAppeared_INDC                      
						  @Ac_PetitionerAttorneyReceived_INDC,  --PetitionerAttorneyReceived_INDC                     
						  @Ac_RespondentAttorneyReceived_INDC, --RespondentAttorneyReceived_INDC                      
						  @Ac_PetitionerAttorneyMailed_INDC,  -- PetitionerAttorneyMailed_INDC                      
						  @Ac_RespondentAttorneyMailed_INDC,   --RespondentAttorneyMailed_INDC                      
						  @Ad_PetitionerAttorneyMailed_DATE,   --PetitionerAttorneyMailed_DATE                      
						  @Ad_RespondentAttorneyMailed_DATE,   -- RespondentAttorneyMailed_DATE                     
						  @Ac_TypeOrder_CODE,     --TypeOrder_CODE                                   
						  @Ld_Low_DATE,     -- ReviewRequested_DATE                            
						  @Ad_NextReview_DATE,-- NextReview_DATE                                      
						  @Ad_LastReview_DATE,-- LastReview_DATE                                      
						  @Ld_Low_DATE,--   LastNoticeSent_DATE                                  
						  @Ac_DirectPay_INDC, --DirectPay_INDC                                       
						  @Ac_SourceOrdered_CODE,-- SourceOrdered_CODE
						  @Ac_Judge_ID,	-- Judge_ID
						  @Ac_Commissioner_ID	-- Commissioner_ID                                   
                    WHERE NOT EXISTS ( SELECT 1 
										  FROM SORD_Y1  A WITH (READUNCOMMITTED )   
										 WHERE Case_IDNO = @An_Case_IDNO 
										   AND EndValidity_DATE = @Ld_High_DATE );  
		                                                       
		-- 13650 - SORD - CR0420 SORD Commissioner and Judge Field on Cases that Share a File ID - END                                                                           
	END;	--END OF SORD_INSERT_S1                                           

GO
