/****** Object:  StoredProcedure [dbo].[SORD_RETRIEVE_S34]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SORD_RETRIEVE_S34] (
	 @An_Case_IDNO			 NUMERIC(6,0),
     @An_OrderSeq_NUMB		 NUMERIC(2,0),
     @Ad_OrderIssued_DATE	 DATE			OUTPUT,
     @Ad_OrderEffective_DATE DATE			OUTPUT,
     @Ad_OrderEnd_DATE		 DATE			OUTPUT,
     @Ac_TypeOrder_CODE		 CHAR(1)		OUTPUT,
     @Ac_DirectPay_INDC		 CHAR(1)		OUTPUT,
     @Ac_SourceOrdered_CODE	 CHAR(1)		OUTPUT,                                                                                                                                                                                                    
     @An_TotArrears_AMNT     NUMERIC(11,2)  OUTPUT
    )
AS

/*
 *     PROCEDURE NAME    : SORD_RETRIEVE_S34
 *     DESCRIPTION       : This procedure retrun the order details amount at case level to display in the order grid from SORD_Y1.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 15-DEC-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
   BEGIN

      SELECT @Ac_SourceOrdered_CODE = NULL,
             @Ac_TypeOrder_CODE = NULL,
			 @Ad_OrderIssued_DATE = NULL,
			 @Ad_OrderEffective_DATE = NULL,
			 @Ad_OrderEnd_DATE = NULL,
			 @An_TotArrears_AMNT = NULL,
			 @Ac_DirectPay_INDC	 = NULL;

      DECLARE
         @Lc_CaseLevel_CODE			 CHAR(1) = 'C', 
         @Lc_PreviewN_CODE			 CHAR(1) = 'N',
         @Ld_High_DATE				 DATE	 = '12/31/9999';
         
        SELECT @Ac_SourceOrdered_CODE = a.SourceOrdered_CODE, 
			   @Ad_OrderEffective_DATE = a.OrderEffective_DATE, 
			   @Ad_OrderEnd_DATE = a.OrderEnd_DATE, 
			   @Ad_OrderIssued_DATE = a.OrderIssued_DATE, 
			   @Ac_TypeOrder_CODE = a.TypeOrder_CODE, 
			   @An_TotArrears_AMNT = dbo.BATCH_COMMON$SF_GET_OBLEARREARS(a.Case_IDNO,a.OrderSeq_NUMB,NULL,NULL,@Lc_CaseLevel_CODE,@Lc_PreviewN_CODE),
			   @Ac_DirectPay_INDC = a.DirectPay_INDC
		  FROM SORD_Y1 a
		WHERE a.Case_IDNO = @An_Case_IDNO 
		AND   a.OrderSeq_NUMB = @An_OrderSeq_NUMB 
		AND   a.EndValidity_DATE = @Ld_High_DATE;

                  
END;--END OF SORD_RETRIEVE_S34


GO
