/****** Object:  StoredProcedure [dbo].[DISH_RETRIEVE_S7]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
CREATE PROCEDURE [dbo].[DISH_RETRIEVE_S7](
 @An_EventGlobalBeginSeq_NUMB  NUMERIC(19, 0),
 @Ac_Reason_CODE			   CHAR(4)		     OUTPUT,
 @Ad_Effective_DATE            DATE			     OUTPUT,
 @Ad_Expiration_DATE		   DATE			     OUTPUT,
 @Ac_SourceHold_CODE           CHAR(2)		     OUTPUT,
 @An_CasePayorMCI_IDNO         NUMERIC(10, 0)    OUTPUT,
 @Ac_TypeHold_CODE		       CHAR(1)		     OUTPUT,	
 @As_DescriptionNote_TEXT      VARCHAR(4000)	 OUTPUT
 )
AS
/*
 *     PROCEDURE NAME    : DISH_RETRIEVE_S7
 *     DESCRIPTION       : This Procedure is used to populate data for Distribution Hold Instruction popup
                           where it will  display Distribution and Receipt source holds. The Receipt source
						   Hold Instruction information will be displayed when the 'Receipt source' field
						   is populated. For a Distribution Hold Instruction the 'Receipt source' field
						   will be blank.
  *     DEVELOPED BY     : IMP Team
  *     DEVELOPED ON     : 12/09/2011
  *     MODIFIED BY      : 
  *     MODIFIED ON      : 
  *     VERSION NO       : 1
  */
 BEGIN
  SELECT @Ac_Reason_CODE		  = NULL,
         @Ad_Effective_DATE		  = NULL,
         @Ad_Expiration_DATE	  = NULL,
         @Ac_SourceHold_CODE      = NULL,
         @An_CasePayorMCI_IDNO	  = NULL,
         @Ac_TypeHold_CODE		  = NULL,
         @As_DescriptionNote_TEXT = NULL;

  SELECT @Ad_Effective_DATE			= DI.Effective_DATE,
         @Ad_Expiration_DATE		= DI.Expiration_DATE,
         @Ac_Reason_CODE			= DI.ReasonHold_CODE,
         @An_CasePayorMCI_IDNO		= DI.CasePayorMCI_IDNO,
         @As_DescriptionNote_TEXT	= UN.DescriptionNote_TEXT,
         @Ac_SourceHold_CODE		= DI.SourceHold_CODE,
         @Ac_TypeHold_CODE			= DI.TypeHold_CODE
    FROM DISH_Y1 DI
         JOIN UNOT_Y1 UN
          ON UN.EventGlobalSeq_NUMB	= DI.EventGlobalBeginSeq_NUMB
   WHERE DI.EventGlobalBeginSeq_NUMB= @An_EventGlobalBeginSeq_NUMB;
   
 END; --End Of Procedure DISH_RETRIEVE_S7


GO
