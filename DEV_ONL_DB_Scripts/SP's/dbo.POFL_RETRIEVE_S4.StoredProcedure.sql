/****** Object:  StoredProcedure [dbo].[POFL_RETRIEVE_S4]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[POFL_RETRIEVE_S4] (
 @Ac_CheckRecipient_ID		CHAR(10),         
 @Ac_CheckRecipient_CODE	CHAR(1),         
 @An_PendTotOffset_AMNT		NUMERIC(11,2) OUTPUT,
 @An_AssessTotOverpay_AMNT	NUMERIC(11,2) OUTPUT,
 @An_EventGlobalSeq_NUMB	NUMERIC(19,0) OUTPUT 
 )
AS
 /*
  *     PROCEDURE NAME    : POFL_RETRIEVE_S4
  *     DESCRIPTION       : The payee offset log for the given recipient id
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 01-DEC-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
  BEGIN
      SELECT
       @An_AssessTotOverpay_AMNT = NULL,
       @An_PendTotOffset_AMNT = NULL,
       @An_EventGlobalSeq_NUMB = NULL;

      DECLARE
         @Lc_TypeRecoupmentRegular_CODE	CHAR(1) = 'R';
        
      SELECT @An_EventGlobalSeq_NUMB = p.EventGlobalSeq_NUMB, 
             @An_PendTotOffset_AMNT = p.PendTotOffset_AMNT, 
             @An_AssessTotOverpay_AMNT = p.AssessTotOverpay_AMNT
        FROM POFL_Y1 p
          JOIN  (SELECT MAX(m.Unique_IDNO) AS Unique_IDNO
         		   FROM POFL_Y1 m
         		  WHERE m.CheckRecipient_ID = @Ac_CheckRecipient_ID
         		    AND m.CheckRecipient_CODE = @Ac_CheckRecipient_CODE
         		    AND m.TypeRecoupment_CODE = @Lc_TypeRecoupmentRegular_CODE 
         	    )r
			ON p.Unique_IDNO = r.Unique_IDNO        					  
       WHERE p.CheckRecipient_ID = @Ac_CheckRecipient_ID 
         AND p.CheckRecipient_CODE = @Ac_CheckRecipient_CODE 
         AND p.TypeRecoupment_CODE = @Lc_TypeRecoupmentRegular_CODE ;
         
END; -- END OF POFL_RETRIEVE_S4


GO
