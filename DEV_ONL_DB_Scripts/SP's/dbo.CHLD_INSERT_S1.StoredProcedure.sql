/****** Object:  StoredProcedure [dbo].[CHLD_INSERT_S1]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CHLD_INSERT_S1] (
 @Ac_CheckRecipient_ID        CHAR(10),
 @Ac_CheckRecipient_CODE      CHAR(1),
 @Ac_ReasonHold_CODE          CHAR(4),
 @An_EventGlobalBeginSeq_NUMB NUMERIC(19, 0),
 @An_Case_IDNO                NUMERIC(6, 0),
 @Ad_Effective_DATE           DATE,
 @Ad_Expiration_DATE          DATE,
 @An_EventGlobalEndSeq_NUMB   NUMERIC(19, 0),
 @An_Sequence_NUMB            NUMERIC(11, 0)
 )
AS
 /*  
  *     PROCEDURE NAME    : CHLD_INSERT_S1  
  *     DESCRIPTION       : Inserts data into CpHold_T1 table.
  *     DEVELOPED BY      : IMP Team   
  *     DEVELOPED ON      : 22-SEP-2011  
  *     MODIFIED BY       :   
  *     MODIFIED ON       :   
  *     VERSION NO        : 1  
  */
 BEGIN
  DECLARE @Ld_Current_DATE DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
          @Ld_High_DATE    DATE = '12/31/9999';

  INSERT CHLD_Y1
         (CheckRecipient_ID,
          CheckRecipient_CODE,
          ReasonHold_CODE,
          EventGlobalBeginSeq_NUMB,
          Case_IDNO,
          Effective_DATE,
          Expiration_DATE,
          EventGlobalEndSeq_NUMB,
          BeginValidity_DATE,
          EndValidity_DATE,
          Sequence_NUMB)
  VALUES ( @Ac_CheckRecipient_ID,--CheckRecipient_ID 
           @Ac_CheckRecipient_CODE,--CheckRecipient_CODE 
           @Ac_ReasonHold_CODE,--ReasonHold_CODE  
           @An_EventGlobalBeginSeq_NUMB,--EventGlobalBeginSeq_NUMB  
           @An_Case_IDNO,--Case_IDNO               
           @Ad_Effective_DATE,--Effective_DATE  
           @Ad_Expiration_DATE,--Expiration_DATE               
           @An_EventGlobalEndSeq_NUMB,--EventGlobalEndSeq_NUMB  
           @Ld_Current_DATE,--BeginValidity_DATE
           @Ld_High_DATE,--EndValidity_DATE
           @An_Sequence_NUMB); --Sequence_NUMB
 END; --End Of CHLD_INSERT_S1     

GO
