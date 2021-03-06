/****** Object:  StoredProcedure [dbo].[CWRK_RETRIEVE_S31]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CWRK_RETRIEVE_S31](
 @An_Case_IDNO	 NUMERIC(6,0),
 @Ac_Worker_ID   CHAR(30),
 @Ai_Count_QNTY  INT OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : CWRK_RETRIEVE_S31
  *     DESCRIPTION       : Checks if given worker is assigned for the case.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 10/20/2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1.0
  */
 BEGIN
  SET @Ai_Count_QNTY = 0;

  DECLARE @Ld_High_DATE           DATE = '12/31/9999';

  SELECT @Ai_Count_QNTY = COUNT(1)
    FROM CWRK_Y1 C
   WHERE C.Case_IDNO = @An_Case_IDNO
     AND C.Worker_ID = @Ac_Worker_ID
     AND C.EndValidity_DATE = @Ld_High_DATE;
 END


GO
