/****** Object:  StoredProcedure [dbo].[CHLD_RETRIEVE_S8]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[CHLD_RETRIEVE_S8](  
     @Ac_CheckRecipient_CODE		 CHAR(1),
     @Ac_CheckRecipient_ID		     CHAR(10),
     @An_EventGlobalBeginSeq_NUMB    NUMERIC(19,0),
     @An_Case_IDNO					 NUMERIC(6,0)	 OUTPUT,
     @Ac_ReasonHold_CODE		     CHAR(4)	     OUTPUT,
     @Ad_Effective_DATE		         DATE	         OUTPUT,
     @Ad_Expiration_DATE		     DATE	         OUTPUT,
     @As_DescriptionNote_TEXT        VARCHAR(4000)   OUTPUT
     )
AS

/*
 *     PROCEDURE NAME    : CHLD_RETRIEVE_S8
 *     DESCRIPTION       : This Procedure populates data for 'Disbursement Hold Instruction' pop up.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 12/09/2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/

   BEGIN

     SELECT @An_Case_IDNO		 = NULL,
        @Ac_ReasonHold_CODE		 = NULL,
        @Ad_Effective_DATE		 = NULL,
        @Ad_Expiration_DATE		 = NULL,
        @As_DescriptionNote_TEXT = NULL;
        
     SELECT @An_Case_IDNO		    = CH.Case_IDNO,
          @Ac_ReasonHold_CODE		= CH.ReasonHold_CODE, 
          @Ad_Effective_DATE		= CH.Effective_DATE, 
          @Ad_Expiration_DATE		= CH.Expiration_DATE, 
          @As_DescriptionNote_TEXT	= (SELECT UN.DescriptionNote_TEXT
      								   FROM UNOT_Y1 UN
      								   WHERE UN.EventGlobalSeq_NUMB = @An_EventGlobalBeginSeq_NUMB) 
     FROM CHLD_Y1 CH
     WHERE CH.CheckRecipient_ID			= @Ac_CheckRecipient_ID 
       AND CH.CheckRecipient_CODE		= @Ac_CheckRecipient_CODE 
       AND CH.EventGlobalBeginSeq_NUMB  = @An_EventGlobalBeginSeq_NUMB;
            
END; --End Of Procedure CHLD_RETRIEVE_S8


GO
