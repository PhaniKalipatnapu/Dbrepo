/****** Object:  StoredProcedure [dbo].[CERR_RETRIEVE_S3]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CERR_RETRIEVE_S3] (
 @An_TransHeader_IDNO NUMERIC(12, 0),
 @Ad_Transaction_DATE DATE,
 @An_SeqError_IDNO    NUMERIC(6, 0),
 @An_Case_IDNO        NUMERIC(6, 0) OUTPUT
 )
AS
 /*  
  *     PROCEDURE NAME    : CERR_RETRIEVE_S3  
  *     DESCRIPTION       : Retrieve the Case Idno for a Transaction Header Idno, Transaction Date, and Error Sequence number.  
  *     DEVELOPED BY      : IMP Team  
  *     DEVELOPED ON      : 01-SEP-2011  
  *     MODIFIED BY       :   
  *     MODIFIED ON       :   
  *     VERSION NO        : 1  
  */
 BEGIN
  SET @An_Case_IDNO = NULL;

  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT @An_Case_IDNO = CE.Case_IDNO
    FROM CERR_Y1 CE
   WHERE CE.TransHeader_IDNO = @An_TransHeader_IDNO
     AND CE.Transaction_DATE = @Ad_Transaction_DATE
     AND CE.SeqError_IDNO = @An_SeqError_IDNO
     AND CE.ActionTaken_DATE = @Ld_High_DATE;
 END; --End of CERR_RETRIEVE_S3

GO
