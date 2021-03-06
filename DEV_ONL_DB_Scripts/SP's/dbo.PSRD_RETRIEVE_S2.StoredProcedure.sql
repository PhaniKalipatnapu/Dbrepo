/****** Object:  StoredProcedure [dbo].[PSRD_RETRIEVE_S2]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
CREATE PROCEDURE [dbo].[PSRD_RETRIEVE_S2](  
 @An_Case_IDNO					NUMERIC(6),  
 @An_Order_IDNO					NUMERIC(15)		OUTPUT,  
 @Ac_File_ID					CHAR(10)		OUTPUT,  
 @Ad_OrderIssued_DATE			DATE			OUTPUT,  
 @Ac_InsOrdered_CODE			CHAR(1)			OUTPUT,  
 @Ac_Iiwo_CODE					CHAR(2)			OUTPUT,  
 @Ac_GuidelinesFollowed_INDC	CHAR(1)			OUTPUT,  
 @Ac_DeviationReason_CODE		CHAR(2)			OUTPUT,  
 @Ac_OrderOutOfState_ID			CHAR(15)		OUTPUT,  
 @Ac_SourceOrdered_CODE			CHAR(1)			OUTPUT,  
 @Ac_TypeOrder_CODE				CHAR(1)			OUTPUT,  
 @Ac_DirectPay_INDC				CHAR(1)			OUTPUT,  
 @Ac_Judge_ID					CHAR(30)		OUTPUT,  
 @Ac_Commissioner_ID			CHAR(30)		OUTPUT,  
 @An_Record_NUMB				NUMERIC(19)		OUTPUT,   
 @An_Petition_IDNO              NUMERIC(7)		OUTPUT,
 @As_SordNotes_TEXT				VARCHAR(4000)	OUTPUT 
   
     )  
AS  
  
/*  
 *     PROCEDURE NAME    : PSRD_RETRIEVE_S2  
 *     DESCRIPTION       : Fetches the Support Order details.  
 *     DEVELOPED BY      : IMP Team  
 *     DEVELOPED ON      : 11/10/2011  
 *     MODIFIED BY       :   
 *     MODIFIED ON       :   
 *     VERSION NO        : 1.0  
 */  
  
   BEGIN  
                      
      DECLARE @Lc_ProcessLoaded_CODE    CHAR(1) = 'L',  
              @Ld_High_DATE             DATE    ='12/31/9999';  
	   -- 13650 - SORD - CR0420 SORD Commissioner and Judge Field on Cases that Share a File ID - START                                                     
       SELECT @Ac_File_ID               = p.File_ID,   
            @Ac_SourceOrdered_CODE      = p.SourceOrdered_CODE,   
            @Ac_TypeOrder_CODE          = p.TypeOrder_CODE,   
            @Ac_DirectPay_INDC          = p.DirectPay_INDC,   
            @Ad_OrderIssued_DATE        = p.OrderIssued_DATE,   
            @Ac_Judge_ID                = p.Judge_ID,   
            @Ac_Commissioner_ID         = p.Commissioner_ID,   
            @Ac_OrderOutOfState_ID      = p.OrderOutOfState_ID,   
            @Ac_InsOrdered_CODE         = p.InsOrdered_CODE,   
            @Ac_Iiwo_CODE               = p.Iiwo_CODE,   
            @Ac_GuidelinesFollowed_INDC = p.GuidelinesFollowed_INDC,   
            @Ac_DeviationReason_CODE    = p.DeviationReason_CODE,   
            @An_Order_IDNO              = p.Order_IDNO,  
            @An_Record_NUMB             = p.Record_NUMB,
            @As_SordNotes_TEXT			= p.SordNotes_TEXT, 
            @An_Petition_IDNO           = y.Petition_IDNO                                                                              
         FROM PSRD_Y1  p   
         LEFT OUTER JOIN FDEM_Y1 y  
           ON y.Case_IDNO        = p.Case_IDNO   
          AND y.File_ID          = p.File_ID   
          AND y.Order_IDNO       = p.Order_IDNO  
          AND y.EndValidity_DATE = @Ld_High_DATE  
        WHERE p.Process_CODE	 = @Lc_ProcessLoaded_CODE
          AND p.Record_NUMB      = (SELECT MIN(y.Record_NUMB)  
                                      FROM PSRD_Y1 y   
                                     WHERE Case_IDNO=@An_Case_IDNO)   
          AND P.Case_IDNO        = @An_Case_IDNO;
		-- 13650 - SORD - CR0420 SORD Commissioner and Judge Field on Cases that Share a File ID - END  
                    
END; --END OF PSRD_RETRIEVE_S2   
  

GO
