/****** Object:  StoredProcedure [dbo].[RECP_INSERT_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RECP_INSERT_S1](  
 @Ac_CheckRecipient_CODE		CHAR(1),
 @Ac_CheckRecipient_ID			CHAR(10),
 @An_EventGlobalBeginSeq_NUMB	NUMERIC(19,0),
 @An_Recoupment_PCT		 		NUMERIC(5,2),
 @An_EventGlobalEndSeq_NUMB		NUMERIC(19,0),
 @Ac_CpResponse_INDC		 	CHAR(1)                   
)
AS
 /*
  *     PROCEDURE NAME    : RECP_INSERT_S1
  *     DESCRIPTION       : Insert RecoupmentPercent for provided values.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 30-NOV-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ld_Current_DATE        DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),      
          @Ld_EndValidity_DATE    DATE = '12/31/9999';                                   
 
      INSERT RECP_Y1
            (CheckRecipient_ID,  
         	 CheckRecipient_CODE,  
         	 Recoupment_PCT,       
         	 EventGlobalBeginSeq_NUMB, 
         	 EventGlobalEndSeq_NUMB,   
         	 BeginValidity_DATE,   
         	 EndValidity_DATE,     
         	 CpResponse_INDC)      
     VALUES ( @Ac_CheckRecipient_ID, 
              @Ac_CheckRecipient_CODE, 
              @An_Recoupment_PCT, 
              @An_EventGlobalBeginSeq_NUMB, 
              @An_EventGlobalEndSeq_NUMB, 
              @Ld_Current_DATE, 
              @Ld_EndValidity_DATE, 
              @Ac_CpResponse_INDC);

END; --END OF RECP_INSERT_S1


GO
