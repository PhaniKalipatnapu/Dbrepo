/****** Object:  StoredProcedure [dbo].[CERR_RETRIEVE_S2]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CERR_RETRIEVE_S2] (
 @An_TransHeader_IDNO NUMERIC(12, 0),
 @Ad_Transaction_DATE DATE,
 @An_SeqError_IDNO    NUMERIC(6, 0),
 @Ai_Count_QNTY       INT OUTPUT
 )
AS
 /*  
  *     PROCEDURE NAME    : CERR_RETRIEVE_S2  
  *     DESCRIPTION       : Retrieve the Row Count for a Transaction Header Idno, Transaction Date, and Error Sequence.  
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
    FROM CERR_Y1 CE
   WHERE CE.TransHeader_IDNO = @An_TransHeader_IDNO
     AND CE.Transaction_DATE = @Ad_Transaction_DATE
     AND CE.SeqError_IDNO = @An_SeqError_IDNO
     AND CE.ActionTaken_DATE < @Ld_High_DATE;
 END; --End of CERR_RETRIEVE_S2 

GO
