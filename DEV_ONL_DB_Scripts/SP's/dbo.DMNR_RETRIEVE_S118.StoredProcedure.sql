/****** Object:  StoredProcedure [dbo].[DMNR_RETRIEVE_S118]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DMNR_RETRIEVE_S118] (
 @An_Case_IDNO          NUMERIC(6, 0),
 @Ac_ActivityMinor_CODE CHAR(5),
 @An_Topic_IDNO         NUMERIC(10, 0),
 @Ac_Status_CODE        CHAR(4) OUTPUT,
 @Ac_WorkerDelegate_ID  CHAR(30) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : DMNR_RETRIEVE_S118
  *     DESCRIPTION       : Retrieve Status Code Minor Activity details for a given Case topic and Minor Activity  . 
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 05-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @Ac_Status_CODE = NULL;

  SELECT @Ac_Status_CODE = D.Status_CODE,
         @Ac_WorkerDelegate_ID = D.WorkerDelegate_ID
    FROM DMNR_Y1 D
   WHERE D.Case_IDNO = @An_Case_IDNO
     AND D.ActivityMinor_CODE = @Ac_ActivityMinor_CODE
     AND D.Topic_IDNO = @An_Topic_IDNO;
 END; -- End of DMNR_RETRIEVE_S118


GO
