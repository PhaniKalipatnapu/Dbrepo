/****** Object:  StoredProcedure [dbo].[CAIN_RETRIEVE_S8]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CAIN_RETRIEVE_S8] (
 @An_TransHeader_IDNO       NUMERIC(12, 0),
 @Ac_IVDOutOfStateFips_CODE CHAR(2),
 @Ad_Transaction_DATE       DATE,
 @Ai_Count_QNTY             INT OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : CAIN_RETRIEVE_S8
  *     DESCRIPTION       : Retrieve the Row Count for a Transaction Header Idno, Other State Fips Code, and Transaction Date.
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
    FROM CAIN_Y1 C
   WHERE C.TransHeader_IDNO = @An_TransHeader_IDNO
     AND C.IVDOutOfStateFips_CODE = @Ac_IVDOutOfStateFips_CODE
     AND C.Transaction_DATE = @Ad_Transaction_DATE
     AND C.EndValidity_DATE = @Ld_High_DATE;
 END; --End of CAIN_RETRIEVE_S8

GO
