/****** Object:  StoredProcedure [dbo].[DMNR_RETRIEVE_S70]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DMNR_RETRIEVE_S70] (
 @An_Case_IDNO                NUMERIC(6, 0),
 @An_MajorIntSeq_NUMB         NUMERIC(5, 0),
 @An_MinorIntSeq_NUMB         NUMERIC(5, 0) OUTPUT,
 @An_Forum_IDNO               NUMERIC(10, 0) OUTPUT,
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : DMNR_RETRIEVE_S70
  *     DESCRIPTION       : Retrieve the new sequence number for the Minor Activity for a Case ID.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 03-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @An_MinorIntSeq_NUMB = NULL;
  SET @An_Forum_IDNO = NULL;
  SET @An_TransactionEventSeq_NUMB = NULL;

  DECLARE @Lc_StatusStart_CODE CHAR(4) = 'STRT';

  SELECT @An_MinorIntSeq_NUMB = d.MinorIntSeq_NUMB,
         @An_Forum_IDNO = d.Forum_IDNO,
         @An_TransactionEventSeq_NUMB = d.TransactionEventSeq_NUMB
    FROM DMNR_Y1 d
   WHERE d.Case_IDNO = @An_Case_IDNO
     AND d.MajorIntSeq_NUMB = @An_MajorIntSeq_NUMB
     AND d.Status_Code = @Lc_StatusStart_CODE;
 END; --END OF DMNR_RETRIEVE_S70

GO
