/****** Object:  StoredProcedure [dbo].[NOTE_RETRIEVE_S10]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[NOTE_RETRIEVE_S10] (
 @An_Case_IDNO         NUMERIC(6, 0),
 @An_Topic_IDNO        NUMERIC(10, 0),
 @Ac_SignedOnWorker_ID CHAR(30),
 @Ai_Count_QNTY        INT OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : NOTE_RETRIEVE_S10
  *     DESCRIPTION       : The  Check the valid worker is used to check whether the worker is authorized  delete a note                                                        
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 25-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Li_One_NUMB SMALLINT = 1;

  SET @Ai_Count_QNTY = NULL;

  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT @Ai_Count_QNTY = COUNT(1)
    FROM NOTE_Y1 N
   WHERE N.Case_IDNO = @An_Case_IDNO
     AND N.Topic_IDNO = @An_Topic_IDNO
     AND N.WorkerCreated_ID = @Ac_SignedOnWorker_ID
     AND N.Post_IDNO = @Li_One_NUMB
     AND N.EndValidity_DATE = @Ld_High_DATE;
 END; --END OF THE NOTE_RETRIEVE_S10

GO
