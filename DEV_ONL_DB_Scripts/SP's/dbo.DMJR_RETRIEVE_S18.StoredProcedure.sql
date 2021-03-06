/****** Object:  StoredProcedure [dbo].[DMJR_RETRIEVE_S18]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DMJR_RETRIEVE_S18] (
 @An_Case_IDNO                NUMERIC(6, 0),
 @An_MajorIntSeq_NUMB         NUMERIC(5, 0),
 @Ac_ActivityMajor_CODE       CHAR(4),
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0),
 @Ai_Count_QNTY               INT OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : DMJR_RETRIEVE_S18
  *     DESCRIPTION       : Retrieve the Row Count for a Case ID, Major Activity Code, Sequence Number for the Remedy and Case, Remedy Status is Start and Unique Sequence Number.
  *     DEVELOPED BY      : IMP Team   
  *     DEVELOPED ON      : 02-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  SET @Ai_Count_QNTY = NULL;

  DECLARE @Lc_StatusStart_CODE CHAR(4) = 'STRT';

  SELECT @Ai_Count_QNTY = COUNT(1)
    FROM DMJR_Y1 D
   WHERE D.Case_IDNO = @An_Case_IDNO
     AND D.ActivityMajor_CODE = @Ac_ActivityMajor_CODE
     AND D.MajorIntSeq_NUMB = @An_MajorIntSeq_NUMB
     AND D.Status_CODE = @Lc_StatusStart_CODE
     AND D.TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB;
 END; --END OF DMJR_RETRIEVE_S18


GO
