/****** Object:  StoredProcedure [dbo].[PSRD_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[PSRD_RETRIEVE_S1] (
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
	@An_County_IDNO				        NUMERIC(3)		OUTPUT,
	@An_Petition_IDNO					NUMERIC(7)		OUTPUT,
	@An_Record_NUMB						NUMERIC(19)		OUTPUT,
	@As_SordNotes_TEXT					VARCHAR(4000)	OUTPUT
     )
AS

/*
 *     PROCEDURE NAME    : PSRD_RETRIEVE_S1
 *     DESCRIPTION       : Fetches the Support Order details.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 11/10/2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1.0
 */

BEGIN

	DECLARE @Li_One_NUMB                        SMALLINT = 1,
             @Lc_ProcessLoaded_CODE			     CHAR(1)  = 'L',
             @Lc_TypeDoc_CODE                    CHAR(1)  = 'O',
             @Lc_InsOrdered_CODE				 CHAR(1)  = 'S',
             @Ld_High_DATE                       DATE     = '12/31/9999';
             
	  -- 13650 - SORD - CR0420 SORD Commissioner and Judge Field on Cases that Share a File ID - START 
      SELECT @An_OrderSeq_NUMB     		         = s.OrderSeq_NUMB, 
             @Ac_File_ID                 		 = ISNULL(p.File_ID, s.File_ID),
             @Ac_SourceOrdered_CODE      		 = ISNULL(p.SourceOrdered_CODE, s.SourceOrdered_CODE), 
             @Ac_TypeOrder_CODE          		 = ISNULL(p.TypeOrder_CODE, s.TypeOrder_CODE), 
             @Ac_DirectPay_INDC          		 = ISNULL(p.DirectPay_INDC, s.DirectPay_INDC), 
             @Ad_OrderEnt_DATE           		 = s.OrderEnt_DATE, 
             @Ad_OrderIssued_DATE        		 = ISNULL(p.OrderIssued_DATE, s.OrderIssued_DATE), 
             @Ad_OrderEffective_DATE     		 = s.OrderEffective_DATE, 
             @Ad_OrderEnd_DATE           		 = s.OrderEnd_DATE, 
             @Ac_Judge_ID                		 = ISNULL(p.Judge_ID,s.Judge_ID), 
             @Ac_Commissioner_ID         		 = ISNULL(p.Commissioner_ID,s.Commissioner_ID), 
             @Ac_StatusControl_CODE      		 = s.StatusControl_CODE, 
             @Ac_StateControl_CODE       		 = s.StateControl_CODE, 
             @Ac_OrderControl_ID         		 = s.OrderControl_ID, 
             @Ac_CejFips_CODE            		 = s.CejFips_CODE,
             @Ac_IssuingOrderFips_CODE  		 = s.IssuingOrderFips_CODE, 
             @Ac_OrderOutOfState_ID      		 = ISNULL(p.OrderOutOfState_ID, s.OrderOutOfState_ID),
             @Ac_CejStatus_CODE          		 = s.CejStatus_CODE, 
             @Ac_InsOrdered_CODE				 = CASE p.InsOrdered_CODE
														WHEN @Lc_InsOrdered_CODE THEN  s.InsOrdered_CODE
													ELSE ISNULL(p.InsOrdered_CODE,s.InsOrdered_CODE)
													END,
             @An_CpMedical_PCT           		 = s.CpMedical_PCT, 
             @An_NcpMedical_PCT          		 = s.NcpMedical_PCT, 
             @Ac_UnreimMedical_INDC      		 = s.UnreimMedical_INDC, 
             @Ac_MedicalOnly_INDC        		 = s.MedicalOnly_INDC, 
             @Ac_Iiwo_CODE               		 = ISNULL(p.Iiwo_CODE, s.Iiwo_CODE),
             @Ac_Qdro_INDC               		 = s.Qdro_INDC, 
             @Ac_GuidelinesFollowed_INDC 		 = ISNULL(p.GuidelinesFollowed_INDC, s.GuidelinesFollowed_INDC), 
             @Ac_DeviationReason_CODE    		 = ISNULL(p.DeviationReason_CODE, s.DeviationReason_CODE), 
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
             @An_County_IDNO                     = CA.County_IDNO, 
             @Ad_BeginValidity_DATE              = s.BeginValidity_DATE, 
             @An_EventGlobalBeginSeq_NUMB        = s.EventGlobalBeginSeq_NUMB, 
             @An_Order_IDNO                      = ISNULL(p.Order_IDNO,s.Order_IDNO),
             @An_Petition_IDNO                   = f.Petition_IDNO ,
             @An_Record_NUMB                     = p.Record_NUMB,
			 @As_SordNotes_TEXT					 = P.SordNotes_TEXT
        FROM (SELECT o.OrderSeq_NUMB,
                     o.SourceOrdered_CODE,
                     o.TypeOrder_CODE,
                     o.DirectPay_INDC,
                     o.OrderEnt_DATE,
                     o.OrderIssued_DATE,
					 o.OrderEffective_DATE, 
					 o.OrderEnd_DATE, 
					 o.Judge_ID,
					 o.Commissioner_ID,
				     o.StatusControl_CODE, 
					 o.StateControl_CODE, 
					 o.OrderControl_ID, 
					 o.CejFips_CODE,
					 o.IssuingOrderFips_CODE,
					 o.OrderOutOfState_ID,						                      
                     o.CejStatus_CODE,
                     o.InsOrdered_CODE,
					 o.CpMedical_PCT, 
					 o.NcpMedical_PCT, 
					 o.UnreimMedical_INDC,
					 o.MedicalOnly_INDC, 
                     o.Iiwo_CODE ,
                     o.Qdro_INDC, 
                     o.GuidelinesFollowed_INDC,
                     o.DeviationReason_CODE,
					 o.DescriptionDeviationOthers_TEXT,
					 o.ParentingTime_PCT, 
					 o.NoParentingDays_QNTY, 
					 o.DescriptionParentingNotes_TEXT, 
					 o.NextReview_DATE, 
					 o.LastReview_DATE, 
					 o.LastIrscReferred_DATE, 
					 o.LastIrscUpdated_DATE, 
					 o.LastIrscReferred_AMNT, 
					 o.WorkerUpdate_ID, 
					 o.BeginValidity_DATE, 
					 o.EventGlobalBeginSeq_NUMB, 
					 o.Order_IDNO,
					 o.Case_IDNO,
					 o.File_ID                                
	            FROM SORD_Y1 o 
	           WHERE o.EndValidity_DATE = @Ld_High_DATE 
	             AND o.Case_IDNO = @An_Case_IDNO) s
	            LEFT OUTER JOIN ( SELECT n.Case_IDNO,
	                                     n.File_ID,
                             			 n.SourceOrdered_CODE,
							 			 n.TypeOrder_CODE,
							 			 n.DirectPay_INDC,
                             			 n.OrderIssued_DATE,
							 			 n.Judge_ID,
							 			 n.Commissioner_ID,
							 			 n.OrderOutOfState_ID,
							 			 n.InsOrdered_CODE,
                             			 n.Iiwo_CODE,
                             			 n.GuidelinesFollowed_INDC, 
                             			 n.DeviationReason_CODE, 
                             			 n.Order_IDNO, 
                             			 n.Record_NUMB,
                             			 n.SordNotes_TEXT,
                             			 n.Row_NUMB  
                                   FROM (SELECT r.Case_IDNO,
                             					r.File_ID,
                             					r.SourceOrdered_CODE,
							 					r.TypeOrder_CODE,
							 					r.DirectPay_INDC,
                             					r.OrderIssued_DATE,
							 					r.Judge_ID,
							 					r.Commissioner_ID,
							 					r.OrderOutOfState_ID,
							 					r.InsOrdered_CODE,
                             					r.Iiwo_CODE,
                             					r.GuidelinesFollowed_INDC, 
                             					r.DeviationReason_CODE,
                             					r.Order_IDNO, 
                             					r.Record_NUMB,
                             					r.SordNotes_TEXT,
                             					ROW_NUMBER() OVER(ORDER BY Record_NUMB ASC) AS Row_NUMB 
										   FROM PSRD_Y1  r
										  WHERE r.Process_CODE IN (@Lc_ProcessLoaded_CODE) 
										    AND r.Case_IDNO = @An_Case_IDNO
										) n 
								  WHERE Row_NUMB =@Li_One_NUMB) p 
			      ON p.Case_IDNO = s.Case_IDNO 
			    JOIN CASE_Y1 CA
			      ON CA.Case_IDNO = @An_Case_IDNO
			    LEFT OUTER JOIN FDEM_Y1 f
			      ON f.Case_IDNO        = s.Case_IDNO 
			     AND f.File_ID          = s.File_ID 
			     AND f.Order_IDNO       = s.Order_IDNO
			     AND f.EndValidity_DATE = @Ld_High_DATE
			     AND f.TypeDoc_CODE     = @Lc_TypeDoc_CODE;
	-- 13650 - SORD - CR0420 SORD Commissioner and Judge Field on Cases that Share a File ID - END
              
END; --END OF PSRD_RETRIEVE_S1 


GO
