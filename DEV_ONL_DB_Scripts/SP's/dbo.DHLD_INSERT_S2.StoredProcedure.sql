/****** Object:  StoredProcedure [dbo].[DHLD_INSERT_S2]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DHLD_INSERT_S2] (
 @An_Case_IDNO                  NUMERIC(6, 0),
 @An_OrderSeq_NUMB              NUMERIC(2, 0),
 @An_ObligationSeq_NUMB         NUMERIC(2, 0),
 @Ad_Batch_DATE                 DATE,
 @Ac_SourceBatch_CODE           CHAR(3),
 @An_Batch_NUMB                 NUMERIC(4, 0),
 @An_SeqReceipt_NUMB            NUMERIC(6, 0),
 @Ad_Release_DATE               DATE,
 @Ac_TypeDisburse_CODE          CHAR(5),
 @An_Transaction_AMNT           NUMERIC(11, 2),
 @Ac_Status_CODE                CHAR(1),
 @Ac_TypeHold_CODE              CHAR(1),
 @Ac_ProcessOffset_INDC         CHAR(1),
 @Ac_CheckRecipient_ID          CHAR(10),
 @Ac_CheckRecipient_CODE        CHAR(1),
 @Ac_ReasonStatus_CODE          CHAR(4),
 @An_EventGlobalSupportSeq_NUMB NUMERIC(19, 0),
 @An_EventGlobalBeginSeq_NUMB   NUMERIC(19, 0),
 @Ad_Disburse_DATE              DATE,
 @An_DisburseSeq_NUMB           NUMERIC(4, 0),
 @Ad_StatusEscheat_DATE         DATE,
 @Ac_StatusEscheat_CODE         CHAR(2)
 )
AS
 /*  
  *     PROCEDURE NAME    : DHLD_INSERT_S2  
  *     DESCRIPTION       : Inserts data into DHLD_Y1.  
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 20-SEP-2011  
  *     MODIFIED BY       :   
  *     MODIFIED ON       :   
  *     VERSION NO        : 1  
  */
 BEGIN
  DECLARE @Ld_Current_DATE DATE= dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
          @Ld_High_DATE    DATE ='12/31/9999',
          @Li_Zero_NUMB    SMALLINT=0;

  INSERT DHLD_Y1
         (Case_IDNO,
          OrderSeq_NUMB,
          ObligationSeq_NUMB,
          Transaction_DATE,
          Batch_DATE,
          SourceBatch_CODE,
          Batch_NUMB,
          SeqReceipt_NUMB,
          Release_DATE,
          TypeDisburse_CODE,
          Transaction_AMNT,
          Status_CODE,
          TypeHold_CODE,
          ProcessOffset_INDC,
          CheckRecipient_ID,
          CheckRecipient_CODE,
          ReasonStatus_CODE,
          EventGlobalSupportSeq_NUMB,
          EventGlobalBeginSeq_NUMB,
          EventGlobalEndSeq_NUMB,
          BeginValidity_DATE,
          EndValidity_DATE,
          Disburse_DATE,
          DisburseSeq_NUMB,
          StatusEscheat_DATE,
          StatusEscheat_CODE)
  VALUES ( @An_Case_IDNO,--Case_IDNO
           @An_OrderSeq_NUMB,--OrderSeq_NUMB  
           @An_ObligationSeq_NUMB,--ObligationSeq_NUMB
           @Ld_Current_DATE,--Transaction_DATE     
           @Ad_Batch_DATE,--Batch_DATE   
           @Ac_SourceBatch_CODE,--SourceBatch_CODE  
           @An_Batch_NUMB,--Batch_NUMB  
           @An_SeqReceipt_NUMB,--SeqReceipt_NUMB            
           @Ad_Release_DATE,--Release_DATE 
           @Ac_TypeDisburse_CODE,--TypeDisburse_CODE 
           @An_Transaction_AMNT,--Transaction_AMNT 
           @Ac_Status_CODE,--Status_CODE
           @Ac_TypeHold_CODE,--TypeHold_CODE 
           @Ac_ProcessOffset_INDC,--ProcessOffset_INDC   
           @Ac_CheckRecipient_ID,--CheckRecipient_ID  
           @Ac_CheckRecipient_CODE,--CheckRecipient_CODE   
           @Ac_ReasonStatus_CODE,--ReasonStatus_CODE   
           @An_EventGlobalSupportSeq_NUMB,--EventGlobalSupportSeq_NUMB  
           @An_EventGlobalBeginSeq_NUMB,--EventGlobalBeginSeq_NUMB  
           @Li_Zero_NUMB,--EventGlobalEndSeq_NUMB 
           @Ld_Current_DATE,--BeginValidity_DATE  
           @Ld_High_DATE,--EndValidity_DATE
           @Ad_Disburse_DATE,--Disburse_DATE 
           @An_DisburseSeq_NUMB,--DisburseSeq_NUMB  
           @Ad_StatusEscheat_DATE,--StatusEscheat_DATE  
           @Ac_StatusEscheat_CODE --StatusEscheat_CODE 
  );
 END; --End of DHLD_INSERT_S2       

GO
