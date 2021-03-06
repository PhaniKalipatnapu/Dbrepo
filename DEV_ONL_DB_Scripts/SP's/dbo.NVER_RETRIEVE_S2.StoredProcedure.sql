/****** Object:  StoredProcedure [dbo].[NVER_RETRIEVE_S2]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[NVER_RETRIEVE_S2] (
 @Ac_Notice_ID        CHAR(8),
 @As_XslTemplate_TEXT VARCHAR(MAX) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : NVER_RETRIEVE_S2
  *     DESCRIPTION       : Retrieve the XSL Boilerplate Form for a respective Notice and Transaction sequence.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 10-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  SET @As_XslTemplate_TEXT = NULL;

  DECLARE @Li_Zero_NUMB SMALLINT = 0;

  SELECT @As_XslTemplate_TEXT = N.XslTemplate_TEXT
    FROM NVER_Y1 N
   WHERE N.Notice_ID = @Ac_Notice_ID
     AND N.NoticeVersion_NUMB != @Li_Zero_NUMB
     AND CONVERT (DATE, DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME()) BETWEEN CONVERT (DATE, N.Effective_DATE) AND CONVERT (DATE, N.End_DATE)
     AND N.TransactionEventSeq_NUMB = (SELECT MAX(N1.TransactionEventSeq_NUMB) AS expr
                                         FROM NVER_Y1 N1
                                        WHERE N1.Notice_ID = N.Notice_ID
                                          AND N1.NoticeVersion_NUMB != @Li_Zero_NUMB
                                          AND CONVERT (DATE, DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME()) BETWEEN CONVERT (DATE, N1.Effective_DATE) AND CONVERT (DATE, N1.End_DATE));
 END; -- End Of NVER_RETRIEVE_S2 

GO
