/****** Object:  StoredProcedure [dbo].[DMNR_RETRIEVE_S98]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DMNR_RETRIEVE_S98] (
 @An_Case_IDNO          NUMERIC(6, 0),
 @An_MajorIntSeq_NUMB   NUMERIC(5, 0),
 @Ac_ActivityMinor_CODE CHAR(5),
 @Ad_Entered_DATE       DATE OUTPUT,
 @Ad_Due_DATE           DATE OUTPUT,
 @Ad_AlertPrior_DATE    DATE OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : DMNR_RETRIEVE_S98
  *     DESCRIPTION       : Retrieve Minor Activity expected updated date, Minor Activity inserted date and Alert Start date for a Case ID, Sequence Number for every new Minor Activity, Current Status of the Minor Activity is start and Activity Minor Code.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 10-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SELECT @Ad_Entered_DATE = NULL,
         @Ad_Due_DATE = NULL,
         @Ad_AlertPrior_DATE = NULL;

  DECLARE @Lc_StatusStart_CODE CHAR(4) = 'STRT';

  SELECT @Ad_Entered_DATE = d.Entered_DATE,
         @Ad_Due_DATE = d.Due_DATE,
         @Ad_AlertPrior_DATE = d.AlertPrior_DATE
    FROM DMNR_Y1 d
   WHERE d.Case_IDNO = @An_Case_IDNO
     AND d.MajorIntSeq_NUMB = @An_MajorIntSeq_NUMB
     AND d.Status_CODE = @Lc_StatusStart_CODE
     AND d.ActivityMinor_CODE = @Ac_ActivityMinor_CODE;
 END; --END OF DMNR_RETRIEVE_S98


GO
