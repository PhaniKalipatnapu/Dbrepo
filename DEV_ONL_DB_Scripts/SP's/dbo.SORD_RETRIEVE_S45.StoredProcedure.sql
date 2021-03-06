/****** Object:  StoredProcedure [dbo].[SORD_RETRIEVE_S45]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SORD_RETRIEVE_S45](
	@An_Case_IDNO						NUMERIC(6),
    @An_OrderSeq_NUMB					NUMERIC(2)		OUTPUT,
	@An_Order_IDNO						NUMERIC(15)		OUTPUT,
	@Ac_File_ID							CHAR(10)		OUTPUT,
	@Ad_OrderEnt_DATE					DATE			OUTPUT,
	@Ad_OrderIssued_DATE				DATE			OUTPUT,
	@Ad_OrderEffective_DATE				DATE			OUTPUT,
	@Ad_OrderEnd_DATE					DATE			OUTPUT,
	@Ac_InsOrdered_CODE					CHAR(1)			OUTPUT,
	@Ac_MedicalOnly_INDC				CHAR(1)			OUTPUT,
	@Ac_Iiwo_CODE						CHAR(2)			OUTPUT,
	@Ac_GuidelinesFollowed_INDC			CHAR(1)			OUTPUT,
	@Ac_DeviationReason_CODE			CHAR(2)			OUTPUT,
	@Ac_DescriptionDeviationOthers_TEXT	CHAR(30)		OUTPUT,
	@Ac_OrderOutOfState_ID				CHAR(15)		OUTPUT,
	@Ac_CejStatus_CODE					CHAR(1)			OUTPUT,
	@Ac_CejFips_CODE					CHAR(7)		    OUTPUT,
	@Ac_IssuingOrderFips_CODE           CHAR(7)         OUTPUT,
	@Ac_Qdro_INDC						CHAR(1)			OUTPUT,
	@Ac_UnreimMedical_INDC				CHAR(1)			OUTPUT,
	@An_CpMedical_PCT					NUMERIC(5,2)	OUTPUT,
	@An_NcpMedical_PCT					NUMERIC(5,2)	OUTPUT,
	@An_ParentingTime_PCT				NUMERIC(5,2)	OUTPUT,
	@An_NoParentingDays_QNTY			NUMERIC(3)		OUTPUT,
	@Ac_WorkerUpdate_ID					CHAR(30)		OUTPUT,
	@Ad_BeginValidity_DATE				DATE			OUTPUT,
	@An_EventGlobalBeginSeq_NUMB		NUMERIC(19)		OUTPUT,
	@As_DescriptionParentingNotes_TEXT	VARCHAR(4000)	OUTPUT,
	@Ad_LastIrscReferred_DATE			DATE			OUTPUT,
	@Ad_LastIrscUpdated_DATE			DATE			OUTPUT,
	@An_LastIrscReferred_AMNT			NUMERIC(11,2)	OUTPUT,
	@Ac_StatusControl_CODE				CHAR(1)			OUTPUT,
	@Ac_StateControl_CODE				CHAR(2)			OUTPUT,
	@Ac_OrderControl_ID					CHAR(15)		OUTPUT,
	@Ac_TypeOrder_CODE					CHAR(1)			OUTPUT,
	@Ad_NextReview_DATE					DATE			OUTPUT,
	@Ad_LastReview_DATE					DATE			OUTPUT,
	@Ac_DirectPay_INDC					CHAR(1)			OUTPUT,
	@Ac_SourceOrdered_CODE				CHAR(1)			OUTPUT,
	@Ac_Judge_ID						CHAR(30)		OUTPUT,
	@Ac_Commissioner_ID					CHAR(30)		OUTPUT,
	@An_County_IDNO                     NUMERIC(3)		OUTPUT,
	@An_Petition_IDNO					NUMERIC(7)		OUTPUT
	     )
AS

/*
 *     PROCEDURE NAME    : SORD_RETRIEVE_S45
 *     DESCRIPTION       : Fetches the Support Order details.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 11/10/2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1.0
 */

BEGIN
			                    
     DECLARE @Lc_TypeDoc_CODE           CHAR(1)  = 'O',
			 @Ld_High_DATE              DATE     = '12/31/9999';
             
	  -- 13650 - SORD - CR0420 SORD Commissioner and Judge Field on Cases that Share a File ID - START  
      SELECT @An_OrderSeq_NUMB 			         = s.OrderSeq_NUMB, 
             @Ac_File_ID             			 = s.File_ID, 
             @Ac_SourceOrdered_CODE  			 = s.SourceOrdered_CODE, 
             @Ac_TypeOrder_CODE      			 = s.TypeOrder_CODE, 
             @Ac_DirectPay_INDC      			 = s.DirectPay_INDC, 
             @Ad_OrderEnt_DATE       			 = s.OrderEnt_DATE, 
             @Ad_OrderIssued_DATE    			 = s.OrderIssued_DATE, 
             @Ad_OrderEffective_DATE 			 = s.OrderEffective_DATE, 
             @Ad_OrderEnd_DATE       			 = s.OrderEnd_DATE, 
             @Ac_Judge_ID            			 = s.Judge_ID,  
             @Ac_Commissioner_ID     			 = s.Commissioner_ID, 
             @Ac_StatusControl_CODE  			 = s.StatusControl_CODE, 
             @Ac_StateControl_CODE       		 = s.StateControl_CODE, 
             @Ac_OrderControl_ID         		 = s.OrderControl_ID, 
             @Ac_CejFips_CODE            		 = s.CejFips_CODE,
             @Ac_IssuingOrderFips_CODE   		 = s.IssuingOrderFips_CODE, 
             @Ac_OrderOutOfState_ID 			 = s.OrderOutOfState_ID, 
             @Ac_CejStatus_CODE     			 = s.CejStatus_CODE, 
             @Ac_InsOrdered_CODE            	 = s.InsOrdered_CODE, 
             @An_CpMedical_PCT              	 = s.CpMedical_PCT, 
             @An_NcpMedical_PCT             	 = s.NcpMedical_PCT, 
             @Ac_UnreimMedical_INDC         	 = s.UnreimMedical_INDC, 
             @Ac_MedicalOnly_INDC           	 = s.MedicalOnly_INDC, 
             @Ac_Iiwo_CODE                  	 = s.Iiwo_CODE, 
             @Ac_Qdro_INDC                  	 = s.Qdro_INDC, 
             @Ac_GuidelinesFollowed_INDC    	 = s.GuidelinesFollowed_INDC, 
             @Ac_DeviationReason_CODE       	 = s.DeviationReason_CODE, 
             @Ac_DescriptionDeviationOthers_TEXT = s.DescriptionDeviationOthers_TEXT, 
             @An_ParentingTime_PCT               = s.ParentingTime_PCT, 
             @An_NoParentingDays_QNTY            = s.NoParentingDays_QNTY, 
             @As_DescriptionParentingNotes_TEXT  = s.DescriptionParentingNotes_TEXT, 
             @Ad_NextReview_DATE                 = s.NextReview_DATE, 
             @Ad_LastReview_DATE                 = s.LastReview_DATE, 
             @Ad_LastIrscReferred_DATE           = s.LastIrscReferred_DATE, 
             @Ad_LastIrscUpdated_DATE            = s.LastIrscUpdated_DATE, 
             @An_LastIrscReferred_AMNT           = s.LastIrscReferred_AMNT, 
             @Ac_WorkerUpdate_ID                 = s.WorkerUpdate_ID, 
             @An_County_IDNO                     = c.County_IDNO,
             @Ad_BeginValidity_DATE              = s.BeginValidity_DATE, 
             @An_EventGlobalBeginSeq_NUMB        = s.EventGlobalBeginSeq_NUMB, 
             @An_Order_IDNO                      = s.Order_IDNO,
             @An_Petition_IDNO                   = y.Petition_IDNO
        FROM SORD_Y1   s
        JOIN CASE_Y1 c
          ON c.Case_IDNO = @An_Case_IDNO
        LEFT JOIN FDEM_Y1 y
          ON y.Case_IDNO        = s.Case_IDNO 
         AND y.File_ID          = s.File_ID 
         AND y.Order_IDNO       = s.Order_IDNO
         AND y.EndValidity_DATE = @Ld_High_DATE
         AND y.TypeDoc_CODE     = @Lc_TypeDoc_CODE 
       WHERE s.Case_IDNO 		  = @An_Case_IDNO 
         AND s.EndValidity_DATE   = @Ld_High_DATE;
	  -- 13650 - SORD - CR0420 SORD Commissioner and Judge Field on Cases that Share a File ID - END
       
END; --END OF SORD_RETRIEVE_S45 


GO
