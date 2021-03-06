/****** Object:  StoredProcedure [dbo].[NVER_RETRIEVE_S6]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[NVER_RETRIEVE_S6] (
 @Ac_Notice_ID                CHAR(8),
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0),
 @Ai_Count_QNTY               INT OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : NVER_RETRIEVE_S6
  *     DESCRIPTION       : Checks whether the record exists for a respective Notice,Transaction sequence,Notice Version and where Present Date should be between Effective Date and End Date.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 10-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  DECLARE @Li_Zero_NUMB SMALLINT = 0;

  SET @Ai_Count_QNTY = NULL;

  SELECT @Ai_Count_QNTY = COUNT(1)
    FROM NVER_Y1 N
   WHERE N.Notice_ID = @Ac_Notice_ID
     AND N.TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB
     AND N.NoticeVersion_NUMB = @Li_Zero_NUMB
     AND CONVERT (DATE, DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME()) BETWEEN N.Effective_DATE AND N.End_DATE;
 END; -- End Of NVER_RETRIEVE_S6	

GO
