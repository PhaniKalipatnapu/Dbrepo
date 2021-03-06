/****** Object:  StoredProcedure [dbo].[DMNR_RETRIEVE_S21]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DMNR_RETRIEVE_S21] (
 @An_MajorIntSeq_NUMB         NUMERIC(5, 0),
 @An_MinorIntSeq_NUMB         NUMERIC(5, 0),
 @An_OrderSeq_NUMB            NUMERIC(2, 0),
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0),
 @An_Case_IDNO                NUMERIC(6, 0),
 @An_Schedule_NUMB            NUMERIC(10, 0) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : DMNR_RETRIEVE_S21
  *     DESCRIPTION       : Retrieves the Schedule number for a Case Idno, Order sequence, Major and Minor Int sequence, and Transaction sequence.
  *     DEVELOPED BY      : IMP TEAM
  *     DEVELOPED ON      : 02-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @An_Schedule_NUMB = 0;

  SELECT @An_Schedule_NUMB = D.Schedule_NUMB
    FROM DMNR_Y1 D
   WHERE D.Case_IDNO = @An_Case_IDNO
     AND D.OrderSeq_NUMB = @An_OrderSeq_NUMB
     AND D.MajorIntSeq_NUMB = @An_MajorIntSeq_NUMB
     AND D.MinorIntSeq_NUMB = @An_MinorIntSeq_NUMB
     AND D.TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB;
 END


GO
