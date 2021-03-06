/****** Object:  StoredProcedure [dbo].[DMNR_RETRIEVE_S117]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DMNR_RETRIEVE_S117] (
 @An_Case_IDNO                NUMERIC(6, 0),
 @An_Topic_IDNO               NUMERIC(10, 0),
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0)
 )
AS
 /*
 *     PROCEDURE NAME    : DMNR_RETRIEVE_S117 
 *     DESCRIPTION       : Retrieve the forum IDNO,Activity Minor CODE,Topic IDNO, Notice ID ,Barcode NUMB, Print method CODE ,Print Status CODE ,Type of Edit
                           Notice CODE and No of schedule conducted so far based on the given topic IDNO and case IDNO.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 17-AUG-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
 */
 BEGIN
  SELECT n.MajorIntSeq_NUMB,
         n.ActivityMinor_CODE,
         n.Forum_IDNO,
         n.Topic_IDNO,
         n.TransactionEventSeq_NUMB,
         m.Notice_ID,
         m.Barcode_NUMB,
         m.Recipient_CODE,
         m.PrintMethod_CODE
    FROM (SELECT z.MajorIntSeq_NUMB,
                 z.ActivityMinor_CODE,
                 z.Forum_IDNO,
                 z.Topic_IDNO,
                 z.TransactionEventSeq_NUMB
            FROM UDMNR_V1 z
           WHERE z.Case_IDNO = @An_Case_IDNO
             AND z.Topic_IDNO = @An_Topic_IDNO) n
         OUTER APPLY ((SELECT a.Notice_ID,
                              a.Barcode_NUMB,
                              a.Recipient_CODE,
                              a.PrintMethod_CODE
                         FROM NMRQ_Y1 a
                        WHERE a.Barcode_NUMB IN (SELECT f.Barcode_NUMB
                                                   FROM FORM_Y1 f
                                                  WHERE f.Topic_IDNO = n.Topic_IDNO)
                          AND a.TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB
                       UNION
                       SELECT b.Notice_ID,
                              b.Barcode_NUMB,
                              b.Recipient_CODE,
                              b.PrintMethod_CODE
                         FROM NRRQ_Y1 b
                        WHERE b.Barcode_NUMB IN (SELECT g.Barcode_NUMB
                                                   FROM FORM_Y1 g
                                                  WHERE g.Topic_IDNO = n.Topic_IDNO)
                          AND b.TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB)) m;
 END; --End of DMNR_RETRIEVE_S117   

GO
