/****** Object:  StoredProcedure [dbo].[RBAT_INSERT_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RBAT_INSERT_S1]    
   (                                
     @Ad_Batch_DATE				   DATE,          
     @Ac_SourceBatch_CODE		   CHAR(3),       
     @An_Batch_NUMB				   NUMERIC(4,0),
     @An_EventGlobalBeginSeq_NUMB  NUMERIC(19,0),
     @Ac_SourceReceipt_CODE		   CHAR(2),       
     @An_CtControlReceipt_QNTY	   NUMERIC(3,0),  
     @An_CtActualReceipt_QNTY	   NUMERIC(3,0),  
     @An_ControlReceipt_AMNT	   NUMERIC(11,2), 
     @An_ActualReceipt_AMNT		   NUMERIC(11,2), 
     @Ac_TypeRemittance_CODE	   CHAR(3),       
     @Ad_Receipt_DATE		       DATE,          
     @Ac_StatusBatch_CODE		   CHAR(1),       
     @Ac_RePost_INDC		       CHAR(1),       
     @An_CtControlTrans_QNTY	   NUMERIC(3,0),  
     @An_CtActualTrans_QNTY		   NUMERIC(3,0)   
   )               
AS

/*
 *     PROCEDURE NAME    : RBAT_INSERT_S1
 *     DESCRIPTION       : PROCEDURE TO INSERT THE RECEIPT BATCH DETAILS
                           INTO RBAT_Y1
 *     DEVELOPED BY      : IMP TEAM
 *     DEVELOPED ON      : 11-OCT-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
	BEGIN
		DECLARE 
			@Ld_High_DATE				DATE		  = '12/31/9999',
			@Ld_Current_DATE			DATE		  = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
			@Li_EventGlobalEndSeq_NUMB	SMALLINT      = 0 ;
		
	INSERT RBAT_Y1
		(Batch_DATE, 
         SourceBatch_CODE, 
         Batch_NUMB, 
         SourceReceipt_CODE, 
         CtControlReceipt_QNTY, 
         CtActualReceipt_QNTY, 
         ControlReceipt_AMNT, 
         ActualReceipt_AMNT, 
         TypeRemittance_CODE, 
         Receipt_DATE, 
         StatusBatch_CODE, 
         RePost_INDC, 
         EventGlobalBeginSeq_NUMB, 
         EventGlobalEndSeq_NUMB, 
         BeginValidity_DATE, 
         EndValidity_DATE, 
         CtControlTrans_QNTY, 
         CtActualTrans_QNTY
        )
	VALUES (@Ad_Batch_DATE,					-- Batch_DATE
			@Ac_SourceBatch_CODE,			-- SourceBatch_CODE
			@An_Batch_NUMB,					-- Batch_NUMB
			@Ac_SourceReceipt_CODE,			-- SourceReceipt_CODE
			@An_CtControlReceipt_QNTY,		-- CtControlReceipt_QNTY 
			@An_CtActualReceipt_QNTY,		-- CtActualReceipt_QNTY 
			@An_ControlReceipt_AMNT,		-- ControlReceipt_AMNT	
			@An_ActualReceipt_AMNT,			-- ActualReceipt_AMNT 
			@Ac_TypeRemittance_CODE,		-- TypeRemittance_CODE
			@Ad_Receipt_DATE,				-- Receipt_DATE
			@Ac_StatusBatch_CODE,			-- StatusBatch_CODE 
			@Ac_RePost_INDC,				-- RePost_INDC
			@An_EventGlobalBeginSeq_NUMB,	-- EventGlobalBeginSeq_NUMB
			@Li_EventGlobalEndSeq_NUMB,		-- EventGlobalEndSeq_NUMB
			@Ld_Current_DATE,				-- BeginValidity_DATE
			@Ld_High_DATE,					-- EndValidity_DATE
			@An_CtControlTrans_QNTY,		-- CtControlTrans_QNTY
			@An_CtActualTrans_QNTY			-- CtActualTrans_QNTY
			);
END; --END OF RBAT_INSERT_S1


GO
