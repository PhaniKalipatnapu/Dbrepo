/****** Object:  StoredProcedure [dbo].[COMP_INSERT_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
   
CREATE PROCEDURE [dbo].[COMP_INSERT_S1]    
(
     @An_Compliance_IDNO			NUMERIC(19,0),  
     @An_Case_IDNO					NUMERIC(6,0),  
     @An_OrderSeq_NUMB				NUMERIC(2,0),  
     @Ac_ComplianceType_CODE		CHAR(2),  
     @Ac_ComplianceStatus_CODE		CHAR(2),  
     @Ad_Effective_DATE				DATE,  
     @Ad_End_DATE					DATE,  
     @An_Compliance_AMNT			NUMERIC(11,2),  
     @Ac_Freq_CODE					CHAR(1),    
     @An_NoMissPayment_QNTY			NUMERIC(5,0),  
     @Ac_OrderedParty_CODE			CHAR(1), 
     @Ad_BeginValidity_DATE			DATE,
     @Ad_EndValidity_DATE			DATE,
     @Ad_Update_DTTM				DATE,
     @Ac_SignedOnWorker_ID			CHAR(30),   
     @An_TransactionEventSeq_NUMB	NUMERIC(19,0),
     @Ad_Entry_DATE					DATE   
)
AS  
  
/*  
 *     PROCEDURE NAME    : COMP_INSERT_S1  
 *     DESCRIPTION       : Inserts the compliance schedule details. 
 *     DEVELOPED BY      : IMP TEAM  
 *     DEVELOPED ON      : 17-JAN-2012  
 *     MODIFIED BY       :   
 *     MODIFIED ON       :   
 *     VERSION NO        : 1  
*/  
BEGIN  
      INSERT COMP_Y1
			(Compliance_IDNO,   
			 Case_IDNO,   
			 OrderSeq_NUMB,   
			 ComplianceType_CODE,   
			 ComplianceStatus_CODE,   
			 Effective_DATE,   
			 End_DATE,   
			 Compliance_AMNT,   
			 Freq_CODE,  
			 NoMissPayment_QNTY,   
			 OrderedParty_CODE,   
			 BeginValidity_DATE,   
			 EndValidity_DATE,   
			 WorkerUpdate_ID,   
			 Update_DTTM,   
			 TransactionEventSeq_NUMB,   
			 Entry_DATE
			 )  
         VALUES (@An_Compliance_IDNO,							--Compliance_IDNO
				 @An_Case_IDNO,									--Case_IDNO
				 @An_OrderSeq_NUMB,								--OrderSeq_NUMB   
				 @Ac_ComplianceType_CODE,						--ComplianceType_CODE 
				 @Ac_ComplianceStatus_CODE,						--ComplianceStatus_CODE  
				 @Ad_Effective_DATE,							--Effective_DATE
				 @Ad_End_DATE,									--End_DATE
				 @An_Compliance_AMNT,							--Compliance_AMNT
				 @Ac_Freq_CODE,									--Freq_CODE
			     @An_NoMissPayment_QNTY,						--NoMissPayment_QNTY
				 @Ac_OrderedParty_CODE,							--OrderedParty_CODE 
				 @Ad_BeginValidity_DATE,						--BeginValidity_DATE
				 @Ad_EndValidity_DATE,							--EndValidity_DATE
				 @Ac_SignedOnWorker_ID,							--WorkerUpdate_ID
				 @Ad_Update_DTTM,								--Update_DTTM
				 @An_TransactionEventSeq_NUMB,					--TransactionEventSeq_NUMB 
				 @Ad_Entry_DATE							      	--Entry_DATE
				 );  
                    
END  --END OF COMP_INSERT_S1 

GO
