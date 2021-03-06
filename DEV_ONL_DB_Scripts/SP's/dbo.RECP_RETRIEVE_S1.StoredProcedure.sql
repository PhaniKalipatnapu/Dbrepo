/****** Object:  StoredProcedure [dbo].[RECP_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RECP_RETRIEVE_S1] (
 @Ac_CheckRecipient_CODE		CHAR(1), 
 @Ac_CheckRecipient_ID		    CHAR(10), 
 @Ac_CpResponse_INDC		 	CHAR(1)	     OUTPUT,
 @Ad_BeginValidity_DATE			DATE	     OUTPUT,
 @An_Recoupment_PCT		 		NUMERIC(5,2) OUTPUT,
 @An_EventGlobalBeginSeq_NUMB	NUMERIC(19,0)OUTPUT 
 )
AS
 /*
  *     PROCEDURE NAME    : RECP_RETRIEVE_S1
  *     DESCRIPTION       : To get recoupment percent/amount based on the id_check_recipient, displays in the instruction group.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 30-NOV-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
  BEGIN
      SELECT
       @Ac_CpResponse_INDC = NULL ,
       @Ad_BeginValidity_DATE = NULL,
       @An_Recoupment_PCT = NULL ,
       @An_EventGlobalBeginSeq_NUMB = NULL;

      DECLARE
         @Ld_High_DATE	DATE = '12/31/9999';
        
      SELECT @Ac_CpResponse_INDC = r.CpResponse_INDC, 
        	 @Ad_BeginValidity_DATE = r.BeginValidity_DATE, 
        	 @An_Recoupment_PCT = r.Recoupment_PCT, 
        	 @An_EventGlobalBeginSeq_NUMB = r.EventGlobalBeginSeq_NUMB
        FROM RECP_Y1 r
       WHERE r.CheckRecipient_ID = @Ac_CheckRecipient_ID 
         AND r.CheckRecipient_CODE = @Ac_CheckRecipient_CODE 
         AND r.EndValidity_DATE = @Ld_High_DATE;
                  
END; --END OF RECP_RETRIEVE_S1


GO
