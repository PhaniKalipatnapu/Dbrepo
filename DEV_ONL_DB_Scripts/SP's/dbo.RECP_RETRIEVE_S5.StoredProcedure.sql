/****** Object:  StoredProcedure [dbo].[RECP_RETRIEVE_S5]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RECP_RETRIEVE_S5](
 @Ac_CheckRecipient_ID			CHAR(10),
 @Ac_CheckRecipient_CODE		CHAR(1),
 @An_EventGlobalBeginSeq_NUMB	NUMERIC(19),
 @An_Recoupment_PCT				NUMERIC(5,2)  OUTPUT,
 @As_DescriptionNote_TEXT		VARCHAR(4000) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : RECP_RETRIEVE_S5
  *     DESCRIPTION       : Procedure to Retrieves the recouped percentage of money and reason notes 
                            for the given recipient and global event sequence
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02/12/2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  SELECT @An_Recoupment_PCT			= NULL,
         @As_DescriptionNote_TEXT	= NULL;

  SELECT @An_Recoupment_PCT = RC.Recoupment_PCT,
         @As_DescriptionNote_TEXT = UN.DescriptionNote_TEXT
    FROM RECP_Y1 RC
         LEFT OUTER JOIN UNOT_Y1 UN
      ON UN.EventGlobalSeq_NUMB = RC.EventGlobalBeginSeq_NUMB
   WHERE RC.CheckRecipient_ID = @Ac_CheckRecipient_ID
     AND RC.CheckRecipient_CODE = @Ac_CheckRecipient_CODE
     AND RC.EventGlobalBeginSeq_NUMB = @An_EventGlobalBeginSeq_NUMB;
     
 END; --End Of Procedure RECP_RETRIEVE_S5 


GO
