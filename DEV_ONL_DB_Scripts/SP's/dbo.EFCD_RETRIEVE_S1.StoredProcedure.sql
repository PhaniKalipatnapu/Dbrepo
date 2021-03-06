/****** Object:  StoredProcedure [dbo].[EFCD_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[EFCD_RETRIEVE_S1] ( 

     @Ad_Generate_DATE					DATE,
     @An_CountPreNotes_QNTY				NUMERIC(11,0)	 OUTPUT,
     @An_DirectDeposit_AMNT				NUMERIC(11,2)	 OUTPUT,
     @An_CountDirectDeposit_QNTY		NUMERIC(11,0)	 OUTPUT,
     @An_Svc_AMNT						NUMERIC(11,2)	 OUTPUT,
     @An_CountSvc_QNTY					NUMERIC(11,0)	 OUTPUT,
     @An_Agency_AMNT					NUMERIC(11,2)	 OUTPUT,
     @An_AgencyAddendaDiffCount_QNTY    NUMERIC(22,0)    OUTPUT,
     @An_CountAgencyAddenda_QNTY		NUMERIC(11,0)	 OUTPUT,
     @An_TotAddendaRecord_QNTY          NUMERIC(22,0)    OUTPUT,
     @An_TotDetails_AMNT				NUMERIC(22,2)    OUTPUT,
     @An_TotDetailsCount_QNTY           NUMERIC(22,0)    OUTPUT
     )
AS

/*
 *     PROCEDURE NAME    : EFCD_RETRIEVE_S1
 *     DESCRIPTION       : This procedure is used to get prenote, eft count details for the given date 
 *
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 02-NOV-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
 */
 
    BEGIN
 
      SELECT    @An_CountPreNotes_QNTY         = NULL,
				@An_DirectDeposit_AMNT         = NULL,
				@An_CountDirectDeposit_QNTY    = NULL,
				@An_Svc_AMNT                   = NULL,
				@An_CountSvc_QNTY              = NULL,
				@An_Agency_AMNT                = NULL,
				@An_AgencyAddendaDiffCount_QNTY  = NULL,
				@An_CountAgencyAddenda_QNTY    = NULL,
				@An_TotAddendaRecord_QNTY      = NULL,
				@An_TotDetails_AMNT			   = NULL,
				@An_TotDetailsCount_QNTY      = NULL;

      SELECT @An_CountPreNotes_QNTY      = e.CountPreNotes_QNTY, 
			 @An_DirectDeposit_AMNT      = e.DirectDeposit_AMNT, 
			 @An_CountDirectDeposit_QNTY = e.CountDirectDeposit_QNTY, 
			 @An_Svc_AMNT                = e.Svc_AMNT, 
			 @An_CountSvc_QNTY           = e.CountSvc_QNTY,
			 @An_Agency_AMNT             = e.Agency_AMNT, 
			 @An_AgencyAddendaDiffCount_QNTY  = e.CountAgency_QNTY - e.CountAgencyAddenda_QNTY,
			 @An_CountAgencyAddenda_QNTY = e.CountAgencyAddenda_QNTY, 
			 @An_TotDetailsCount_QNTY    = e.CountPreNotes_QNTY + e.CountDirectDeposit_QNTY + e.CountSvc_QNTY, 
			 @An_TotAddendaRecord_QNTY   = (e.CountAgency_QNTY - e.CountAgencyAddenda_QNTY) + e.CountAgencyAddenda_QNTY, 
			 @An_TotDetails_AMNT		 = e.DirectDeposit_AMNT + e.Svc_AMNT + e.Agency_AMNT 
        FROM EFCD_Y1 e
       WHERE e.Generate_DATE = @Ad_Generate_DATE;
                  
END; -- End of EFCD_RETRIEVE_S1 


GO
