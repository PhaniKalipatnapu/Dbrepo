/****** Object:  StoredProcedure [dbo].[CAIN_RETRIEVE_S6]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CAIN_RETRIEVE_S6] (
 @An_TransHeader_IDNO         NUMERIC(12, 0),
 @Ac_Notice_ID                CHAR(8),
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0),
 @Ai_Count_QNTY               INT OUTPUT
 )
AS
 /*                                                                                                                     
  *     PROCEDURE NAME    : CAIN_RETRIEVE_S6                                                                             
  *     DESCRIPTION       : Retrieve the Row Count for Transaction Header Idno, Notice Idno, and Transaction sequence.  
  *     DEVELOPED BY      : IMP Team                                                                                     
  *     DEVELOPED ON      : 01-SEP-2011                                                                                 
  *     MODIFIED BY       :                                                                                             
  *     MODIFIED ON       :                                                                                             
  *     VERSION NO        : 1                                                                                           
  */
 BEGIN
  SET @Ai_Count_QNTY = NULL;

  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT @Ai_Count_QNTY = COUNT(1)
    FROM CAIN_Y1 CA
   WHERE CA.TransHeader_IDNO = @An_TransHeader_IDNO
     AND CA.Notice_ID = @Ac_Notice_ID
     AND CA.TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB
     AND CA.EndValidity_DATE = @Ld_High_DATE;
 END; --End of CAIN_RETRIEVE_S6

GO
