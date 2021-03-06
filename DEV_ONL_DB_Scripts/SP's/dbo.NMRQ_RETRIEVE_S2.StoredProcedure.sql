/****** Object:  StoredProcedure [dbo].[NMRQ_RETRIEVE_S2]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[NMRQ_RETRIEVE_S2] (
 @An_Barcode_NUMB             NUMERIC(12, 0),
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0),
 @Ai_Count_QNTY               INT OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : NMRQ_RETRIEVE_S2
  *     DESCRIPTION       : Identify whether a given notice is in print queue.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 10-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @Ai_Count_QNTY = NULL;

  DECLARE @Lc_StatusNoticeCancel_CODE CHAR(1) = 'C';

  SELECT @Ai_Count_QNTY = COUNT(1)
    FROM NMRQ_Y1 N
   WHERE N.Barcode_NUMB = @An_Barcode_NUMB
     AND N.StatusNotice_CODE <> @Lc_StatusNoticeCancel_CODE
     AND N.TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB
	 AND ISNUMERIC(N.Notice_ID) = 0;
 END; --End Of Procedure NMRQ_RETRIEVE_S2


GO
