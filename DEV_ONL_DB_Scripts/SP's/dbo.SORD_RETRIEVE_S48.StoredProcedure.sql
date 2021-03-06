/****** Object:  StoredProcedure [dbo].[SORD_RETRIEVE_S48]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SORD_RETRIEVE_S48]  (
	 @An_Case_IDNO		                 NUMERIC(6,0),
	 @An_OrderSeq_NUMB		             NUMERIC(2,0),
     @An_EventGlobalBeginSeq_NUMB		 NUMERIC(19,0),
     @Ac_RespondentAppeared_INDC		 CHAR(1)	 OUTPUT,
     @Ac_RespondentAttorneyAppeared_INDC CHAR(1)	 OUTPUT,
     @Ac_RespondentAttorneyMailed_INDC	 CHAR(1)	 OUTPUT,
     @Ac_RespondentAttorneyReceived_INDC CHAR(1)	 OUTPUT,
     @Ac_RespondentMailed_INDC		     CHAR(1)	 OUTPUT,
     @Ac_RespondentReceived_INDC		 CHAR(1)	 OUTPUT,
     @Ac_OthersAppeared_INDC		     CHAR(1)	 OUTPUT,
     @Ac_OthersMailed_INDC		         CHAR(1)	 OUTPUT,
     @Ac_OthersReceived_INDC		     CHAR(1)	 OUTPUT,
     @Ac_PetitionerAppeared_INDC		 CHAR(1)	 OUTPUT,
     @Ac_PetitionerAttorneyAppeared_INDC CHAR(1)	 OUTPUT,
     @Ac_PetitionerAttorneyMailed_INDC	 CHAR(1)	 OUTPUT,
     @Ac_PetitionerAttorneyReceived_INDC CHAR(1)	 OUTPUT,
     @Ac_PetitionerMailed_INDC		     CHAR(1)	 OUTPUT,
     @Ac_PetitionerReceived_INDC		 CHAR(1)	 OUTPUT,
     @Ad_RespondentAttorneyMailed_DATE	 DATE	     OUTPUT,
     @Ad_RespondentMailed_DATE		     DATE	     OUTPUT,
     @Ad_OthersMailed_DATE		         DATE	     OUTPUT,
     @Ad_PetitionerAttorneyMailed_DATE	 DATE	     OUTPUT,
     @Ad_PetitionerMailed_DATE		     DATE	     OUTPUT,
     @Ac_CoverageDental_CODE			 CHAR(1)	 OUTPUT,
     @Ac_CoverageDrug_CODE				 CHAR(1)	 OUTPUT,
     @Ac_CoverageMedical_CODE			 CHAR(1)	 OUTPUT,
     @Ac_CoverageMental_CODE			 CHAR(1)	 OUTPUT,
     @Ac_CoverageOthers_CODE			 CHAR(1)	 OUTPUT,
     @Ac_CoverageVision_CODE			 CHAR(1)	 OUTPUT,
     @Ac_DescriptionCoverageOthers_TEXT	 CHAR(30)	 OUTPUT
     )
AS

/*
 *     PROCEDURE NAME    : SORD_RETRIEVE_S48
 *     DESCRIPTION       : Retrieves the Support odrder details.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 11/30/2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1.0
 */

BEGIN

      SELECT @Ac_RespondentAppeared_INDC         = NULL,
             @Ac_RespondentAttorneyAppeared_INDC = NULL,
             @Ac_RespondentAttorneyMailed_INDC   = NULL,
             @Ac_RespondentAttorneyReceived_INDC = NULL,
             @Ac_RespondentMailed_INDC           = NULL,
             @Ac_RespondentReceived_INDC         = NULL,
             @Ac_OthersAppeared_INDC             = NULL,
	         @Ac_OthersMailed_INDC               = NULL,
	         @Ac_OthersReceived_INDC             = NULL,
	         @Ac_PetitionerAppeared_INDC         = NULL,
	         @Ac_PetitionerAttorneyAppeared_INDC = NULL,
	         @Ac_PetitionerAttorneyMailed_INDC   = NULL,
	         @Ac_PetitionerAttorneyReceived_INDC = NULL,
	         @Ac_PetitionerMailed_INDC           = NULL,
	         @Ac_PetitionerReceived_INDC         = NULL,
	         @Ad_RespondentAttorneyMailed_DATE   = NULL,
	         @Ad_RespondentMailed_DATE           = NULL,
	         @Ad_OthersMailed_DATE               = NULL,
	         @Ad_PetitionerAttorneyMailed_DATE   = NULL,
	         @Ad_PetitionerMailed_DATE           = NULL;
	         
      SELECT @Ac_PetitionerAppeared_INDC         = s.PetitionerAppeared_INDC, 
             @Ac_RespondentAppeared_INDC         = s.RespondentAppeared_INDC, 
             @Ac_PetitionerAttorneyAppeared_INDC = s.PetitionerAttorneyAppeared_INDC, 
             @Ac_RespondentAttorneyAppeared_INDC = s.RespondentAttorneyAppeared_INDC, 
             @Ac_OthersAppeared_INDC             = s.OthersAppeared_INDC, 
         	 @Ac_PetitionerReceived_INDC         = s.PetitionerReceived_INDC, 
         	 @Ac_RespondentReceived_INDC         = s.RespondentReceived_INDC, 
         	 @Ac_PetitionerAttorneyReceived_INDC = s.PetitionerAttorneyReceived_INDC, 
         	 @Ac_RespondentAttorneyReceived_INDC = s.RespondentAttorneyReceived_INDC, 
         	 @Ac_OthersReceived_INDC             = s.OthersReceived_INDC, 
         	 @Ac_PetitionerMailed_INDC           = s.PetitionerMailed_INDC, 
         	 @Ac_RespondentMailed_INDC           = s.RespondentMailed_INDC, 
         	 @Ac_PetitionerAttorneyMailed_INDC   = s.PetitionerAttorneyMailed_INDC, 
         	 @Ac_RespondentAttorneyMailed_INDC   = s.RespondentAttorneyMailed_INDC, 
         	 @Ac_OthersMailed_INDC               = s.OthersMailed_INDC, 
         	 @Ad_PetitionerMailed_DATE           = s.PetitionerMailed_DATE, 
         	 @Ad_RespondentMailed_DATE           = s.RespondentMailed_DATE, 
         	 @Ad_PetitionerAttorneyMailed_DATE   = s.PetitionerAttorneyMailed_DATE, 
         	 @Ad_RespondentAttorneyMailed_DATE   = s.RespondentAttorneyMailed_DATE, 
         	 @Ad_OthersMailed_DATE               = s.OthersMailed_DATE,
         	 @Ac_CoverageMedical_CODE            = S.CoverageMedical_CODE, 
         	 @Ac_CoverageDental_CODE             = S.CoverageDental_CODE, 
         	 @Ac_CoverageMental_CODE             = S.CoverageMental_CODE, 
         	 @Ac_CoverageDrug_CODE               = S.CoverageDrug_CODE, 
         	 @Ac_CoverageVision_CODE             = S.CoverageVision_CODE, 
         	 @Ac_CoverageOthers_CODE             = S.CoverageOthers_CODE, 
         	 @Ac_DescriptionCoverageOthers_TEXT  = S.DescriptionCoverageOthers_TEXT
        FROM SORD_Y1 s
       WHERE s.Case_IDNO                = @An_Case_IDNO  
         AND s.OrderSeq_NUMB            = @An_OrderSeq_NUMB  
         AND s.EventGlobalBeginSeq_NUMB = @An_EventGlobalBeginSeq_NUMB;

END--END OF SORD_RETRIEVE_S48


GO
