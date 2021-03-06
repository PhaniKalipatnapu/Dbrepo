/****** Object:  StoredProcedure [dbo].[RBAT_RETRIEVE_S11]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[RBAT_RETRIEVE_S11]
(
     @Ad_Batch_DATE							DATE,
     @An_Batch_NUMB                         NUMERIC(4,0),
     @Ac_SourceBatch_CODE					CHAR(3),
     @Ac_RePost_INDC						CHAR(1)			 OUTPUT,
     @Ad_Receipt_DATE						DATE			 OUTPUT,
     @An_ActualReceipt_AMNT					NUMERIC(11,2)	 OUTPUT,
     @An_ControlReceipt_AMNT				NUMERIC(11,2)	 OUTPUT,
     @An_CtActualReceipt_QNTY				NUMERIC(3,0)	 OUTPUT,
     @An_CtActualTrans_QNTY					NUMERIC(3,0)	 OUTPUT,
     @An_CtControlReceipt_QNTY				NUMERIC(3,0)	 OUTPUT,
     @An_CtControlTrans_QNTY				NUMERIC(3,0)	 OUTPUT,
     @An_EventGlobalBeginSeq_NUMB			NUMERIC(19,0)	 OUTPUT,
     @Ac_SourceReceipt_CODE					CHAR(2)			 OUTPUT,
     @Ac_TypeRemittance_CODE				CHAR(3)			 OUTPUT
 )
AS

/*
 *     PROCEDURE NAME    : RBAT_RETRIEVE_S11
 *     DESCRIPTION       : Procedure To Retrieve The Receipt Batch Details By Using RBAT_Y1
 *     DEVELOPED BY      : IMP TEAM
 *     DEVELOPED ON      : 15-OCT-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/

   BEGIN

		SELECT 
			@Ac_RePost_INDC				 = NULL,
            @Ad_Receipt_DATE			 = NULL,
            @An_ActualReceipt_AMNT		 = NULL,
            @An_ControlReceipt_AMNT		 = NULL,
            @An_CtActualReceipt_QNTY	 = NULL,
            @An_CtActualTrans_QNTY		 = NULL,
            @An_CtControlReceipt_QNTY	 = NULL,
            @An_CtControlTrans_QNTY		 = NULL,
            @An_EventGlobalBeginSeq_NUMB = NULL,
            @Ac_SourceReceipt_CODE		 = NULL,
            @Ac_TypeRemittance_CODE		 = NULL;

		DECLARE
			@Ld_High_DATE DATE = '12/31/9999';
        
        SELECT 	@An_CtActualReceipt_QNTY	= a.CtActualReceipt_QNTY, 
			@An_ActualReceipt_AMNT			= a.ActualReceipt_AMNT, 
			@An_CtControlReceipt_QNTY	    = a.CtControlReceipt_QNTY, 
			@An_ControlReceipt_AMNT			= a.ControlReceipt_AMNT, 
			@An_CtControlTrans_QNTY			= a.CtControlTrans_QNTY, 
			@An_CtActualTrans_QNTY			= a.CtActualTrans_QNTY, 
			@An_EventGlobalBeginSeq_NUMB	= a.EventGlobalBeginSeq_NUMB, 
			@Ac_SourceReceipt_CODE			= a.SourceReceipt_CODE, 
			@Ad_Receipt_DATE				= a.Receipt_DATE, 
			@Ac_TypeRemittance_CODE			= a.TypeRemittance_CODE, 
			@Ac_RePost_INDC					= a.RePost_INDC
		FROM RBAT_Y1 a
	   WHERE a.Batch_DATE		= @Ad_Batch_DATE 
		 AND a.SourceBatch_CODE = @Ac_SourceBatch_CODE 
		 AND a.Batch_NUMB		= @An_Batch_NUMB 
		 AND a.EndValidity_DATE = @Ld_High_DATE;
                  
	END; --End Of Procedure RBAT_RETRIEVE_S11


GO
