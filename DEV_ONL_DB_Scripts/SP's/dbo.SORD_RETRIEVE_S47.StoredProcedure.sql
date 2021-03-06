/****** Object:  StoredProcedure [dbo].[SORD_RETRIEVE_S47]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SORD_RETRIEVE_S47] (
	 @An_Case_IDNO							NUMERIC(6),
     @An_Row_NUMB  						    NUMERIC(22),
	 @An_Order_IDNO							NUMERIC(15)		OUTPUT,
	 @Ac_File_ID							CHAR(10)		OUTPUT,
	 @Ad_OrderEnt_DATE						DATE			OUTPUT,
	 @Ad_OrderIssued_DATE					DATE			OUTPUT,
     @Ad_OrderEffective_DATE				DATE			OUTPUT,
     @Ad_OrderEnd_DATE						DATE			OUTPUT,
     @Ac_InsOrdered_CODE					CHAR(1)			OUTPUT,
     @Ac_MedicalOnly_INDC					CHAR(1)			OUTPUT,
     @Ac_Iiwo_CODE							CHAR(2)			OUTPUT,
     @Ac_GuidelinesFollowed_INDC			CHAR(1)			OUTPUT,
     @Ac_DeviationReason_CODE				CHAR(2)			OUTPUT,
     @Ac_DescriptionDeviationOthers_TEXT	CHAR(30)		OUTPUT,
     @Ac_OrderOutOfState_ID					CHAR(15)		OUTPUT,
     @Ac_CejStatus_CODE						CHAR(1)			OUTPUT,
     @Ac_CejFips_CODE						CHAR(7)		    OUTPUT,
     @Ac_IssuingOrderFips_CODE				CHAR(7)		    OUTPUT,
     @Ac_Qdro_INDC							CHAR(1)			OUTPUT,
     @Ac_UnreimMedical_INDC					CHAR(1)			OUTPUT,
     @An_CpMedical_PCT						NUMERIC(5,2)	OUTPUT,
     @An_NcpMedical_PCT						NUMERIC(5,2)	OUTPUT,
     @An_ParentingTime_PCT					NUMERIC(5,2)	OUTPUT,
     @An_NoParentingDays_QNTY				NUMERIC(3)		OUTPUT,
     @Ac_WorkerUpdate_ID					CHAR(30)		OUTPUT,
     @Ad_BeginValidity_DATE					DATE			OUTPUT,
     @An_EventGlobalBeginSeq_NUMB			NUMERIC(19)		OUTPUT,
     @As_DescriptionParentingNotes_TEXT		VARCHAR(4000)	OUTPUT,
     @Ad_LastIrscReferred_DATE				DATE			OUTPUT,
     @Ad_LastIrscUpdated_DATE				DATE			OUTPUT,
     @An_LastIrscReferred_AMNT				NUMERIC(11,2)	OUTPUT,
     @Ac_StateControl_CODE					CHAR(2)			OUTPUT,
     @Ac_StatusControl_CODE					CHAR(1)			OUTPUT,
     @Ac_OrderControl_ID					CHAR(15)		OUTPUT,
     @Ac_TypeOrder_CODE						CHAR(1)			OUTPUT,
     @Ad_NextReview_DATE					DATE			OUTPUT,
     @Ad_LastReview_DATE					DATE			OUTPUT,
     @Ac_DirectPay_INDC						CHAR(1)			OUTPUT,
     @Ac_SourceOrdered_CODE					CHAR(1)			OUTPUT,
     @Ac_Judge_ID							CHAR(30)		OUTPUT,
     @Ac_Commissioner_ID					CHAR(30)		OUTPUT,
     @An_County_IDNO                        NUMERIC(3)		OUTPUT,
	 @An_Petition_IDNO						NUMERIC(7)		OUTPUT,
	 @An_RowCount_NUMB						NUMERIC(6)		OUTPUT
	 
	 )
AS

/*
 *     PROCEDURE NAME    : SORD_RETRIEVE_S47
 *     DESCRIPTION       : gets the history information of the Support order history details.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 11/18/2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1.0
*/

   BEGIN
      		
     DECLARE @Lc_TypeDoc_CODE                 CHAR(1)	= 'O',
			 @Ld_High_DATE	                  DATE		= '12/31/9999';
             
	  -- 13650 - SORD - CR0420 SORD Commissioner and Judge Field on Cases that Share a File ID - START
      SELECT @Ac_File_ID          			        = X.File_ID, 
         	 @Ac_SourceOrdered_CODE     			= X.SourceOrdered_CODE, 
         	 @Ac_TypeOrder_CODE         			= X.TypeOrder_CODE, 
         	 @Ac_DirectPay_INDC         			= X.DirectPay_INDC, 
         	 @Ad_OrderEnt_DATE          			= X.OrderEnt_DATE, 
         	 @Ad_OrderIssued_DATE       			= X.OrderIssued_DATE, 
         	 @Ad_OrderEffective_DATE    			= X.OrderEffective_DATE, 
         	 @Ad_OrderEnd_DATE          			= X.OrderEnd_DATE, 
         	 @Ac_Judge_ID               			= X.Judge_ID, 
         	 @Ac_Commissioner_ID        			= X.Commissioner_ID, 
         	 @Ac_StatusControl_CODE     			= X.StatusControl_CODE, 
         	 @Ac_StateControl_CODE      			= X.StateControl_CODE, 
         	 @Ac_OrderControl_ID        			= X.OrderControl_ID, 
         	 @Ac_CejFips_CODE           			= X.CejFips_CODE, 
         	 @Ac_IssuingOrderFips_CODE  			= X.IssuingOrderFips_CODE,
         	 @Ac_OrderOutOfState_ID     			= X.OrderOutOfState_ID, 
         	 @Ac_CejStatus_CODE         			= X.CejStatus_CODE, 
         	 @Ac_InsOrdered_CODE        			= X.InsOrdered_CODE, 
         	 @An_CpMedical_PCT                   	= X.CpMedical_PCT, 
         	 @An_NcpMedical_PCT                  	= X.NcpMedical_PCT, 
         	 @Ac_UnreimMedical_INDC              	= X.UnreimMedical_INDC, 
         	 @Ac_MedicalOnly_INDC                	= X.MedicalOnly_INDC, 
         	 @Ac_Iiwo_CODE                       	= X.Iiwo_CODE, 
         	 @Ac_Qdro_INDC                       	= X.Qdro_INDC, 
         	 @Ac_GuidelinesFollowed_INDC         	= X.GuidelinesFollowed_INDC, 
         	 @Ac_DeviationReason_CODE            	= X.DeviationReason_CODE, 
         	 @Ac_DescriptionDeviationOthers_TEXT 	= X.DescriptionDeviationOthers_TEXT, 
         	 @An_ParentingTime_PCT               	= X.ParentingTime_PCT, 
         	 @An_NoParentingDays_QNTY            	= X.NoParentingDays_QNTY, 
         	 @As_DescriptionParentingNotes_TEXT  	= X.DescriptionParentingNotes_TEXT, 
         	 @Ad_NextReview_DATE                 	= X.NextReview_DATE, 
         	 @Ad_LastReview_DATE                 	= X.LastReview_DATE, 
         	 @Ad_LastIrscReferred_DATE           	= X.LastIrscReferred_DATE, 
         	 @Ad_LastIrscUpdated_DATE            	= X.LastIrscUpdated_DATE, 
         	 @An_LastIrscReferred_AMNT           	= X.LastIrscReferred_AMNT, 
         	 @Ac_WorkerUpdate_ID                 	= X.WorkerUpdate_ID, 
         	 @An_County_IDNO                     	= X.County_IDNO, 
         	 @Ad_BeginValidity_DATE              	= X.BeginValidity_DATE, 
         	 @An_EventGlobalBeginSeq_NUMB        	= X.EventGlobalBeginSeq_NUMB, 
         	 @An_RowCount_NUMB                   	= X.Row_Count,
         	 @An_Order_IDNO                      	= X.Order_IDNO,
         	 @An_Petition_IDNO                   	= X.Petition_IDNO 
        FROM (SELECT s.Case_IDNO,
					 s.File_ID, 
                     s.SourceOrdered_CODE, 
                     s.TypeOrder_CODE, 
                     s.DirectPay_INDC, 
                     s.OrderEnt_DATE, 
                     s.OrderIssued_DATE, 
                     s.OrderEffective_DATE, 
                     s.OrderEnd_DATE, 
                     s.Judge_ID,
                     s.Commissioner_ID, 
                     s.StatusControl_CODE, 
               		 s.StateControl_CODE, 
               		 s.OrderControl_ID, 
               		 s.CejFips_CODE,
			   		 s.OrderOutOfState_ID, 
               		 s.CejStatus_CODE, 
               		 s.IssuingOrderFips_CODE, 
               		 s.InsOrdered_CODE, 
               		 s.CpMedical_PCT, 
               		 s.NcpMedical_PCT, 
               		 s.UnreimMedical_INDC, 
               		 s.MedicalOnly_INDC, 
               		 s.Iiwo_CODE, 
               		 s.Qdro_INDC, 
               		 s.GuidelinesFollowed_INDC, 
               		 s.DeviationReason_CODE, 
               		 s.DescriptionDeviationOthers_TEXT, 
               		 s.ParentingTime_PCT, 
               		 s.NoParentingDays_QNTY, 
               		 s.DescriptionParentingNotes_TEXT, 
               		 s.NextReview_DATE, 
               		 s.LastReview_DATE, 
               		 s.LastIrscReferred_DATE, 
               		 s.LastIrscUpdated_DATE, 
               		 s.LastIrscReferred_AMNT, 
               		 s.WorkerUpdate_ID, 
               		 c.County_IDNO,
               		 s.BeginValidity_DATE, 
               		 s.EventGlobalBeginSeq_NUMB, 
               		 s.Order_IDNO,
               		 d.Petition_IDNO AS Petition_IDNO,
               		 ROW_NUMBER() OVER( ORDER BY s.EventGlobalBeginSeq_NUMB DESC ) AS Row_NUMB, 
               		 COUNT(1) OVER() AS Row_Count
          		FROM SORD_Y1 s 
          		JOIN CASE_Y1 c
          		  ON c.Case_IDNO = @An_Case_IDNO
          		LEFT JOIN FDEM_Y1 d 
          		  ON d.Case_IDNO = s.Case_IDNO 
          		 AND d.File_ID = s.File_ID 
          		 AND d.Order_IDNO = s.Order_IDNO
          		 AND d.EndValidity_DATE = @Ld_High_DATE
          		 AND d.TypeDoc_CODE = @Lc_TypeDoc_CODE
          		WHERE s.Case_IDNO = @An_Case_IDNO 
          		  AND s.EndValidity_DATE <> @Ld_High_DATE
             )  X
       WHERE X.Row_NUMB = @An_Row_NUMB;
       -- 13650 - SORD - CR0420 SORD Commissioner and Judge Field on Cases that Share a File ID - END
END;--End of SORD_RETRIEVE_S47

GO
