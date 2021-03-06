/****** Object:  StoredProcedure [dbo].[NOTE_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[NOTE_RETRIEVE_S1]
 @An_MajorIntSeq_NUMB             NUMERIC(5),
 @An_MinorIntSeq_NUMB             NUMERIC(5),
 @An_OrderSeq_NUMB                NUMERIC(5),
 @An_TransactionEventSeq_NUMB     NUMERIC(19),
 @An_Case_IDNO                    NUMERIC(6),
 @An_Topic_IDNO                   NUMERIC(10) OUTPUT,
 @An_TransactionEventSeqNote_NUMB NUMERIC(19, 0) OUTPUT
AS
 /*
  *     PROCEDURE NAME    : NOTE_RETRIEVE_S1
  *     DESCRIPTION       : Retrieve the Topic Idno and Transaction sequence for a common Case Idno, Order sequence, Major and Minor Int sequence,
 							 Transaction sequence, Topic Idno, and Post Idno that's common between two tables.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @An_Topic_IDNO = NULL;
  SET @An_TransactionEventSeqNote_NUMB = NULL;

  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT @An_Topic_IDNO = N.Topic_IDNO,
         @An_TransactionEventSeqNote_NUMB = N.TransactionEventSeq_NUMB
    FROM DMNR_Y1 D,
         NOTE_Y1 N
   WHERE D.Case_IDNO = @An_Case_IDNO
     AND D.Case_IDNO = N.Case_IDNO
     AND D.OrderSeq_NUMB = @An_OrderSeq_NUMB
     AND D.MajorIntSEQ_NUMB = @An_MajorIntSeq_NUMB
     AND D.MinorIntSeq_NUMB = @An_MinorIntSeq_NUMB
     AND D.TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB
     AND D.Topic_IDNO = N.Topic_IDNO
     AND N.Post_IDNO = (SELECT MAX(B.Post_IDNO)
                          FROM NOTE_Y1 B
                         WHERE B.Topic_IDNO = N.Topic_IDNO
                           AND B.Case_IDNO = D.Case_IDNO
                           AND B.EndValidity_DATE = @Ld_High_DATE)
     AND N.EndValidity_DATE = @Ld_High_DATE;
 END


GO
