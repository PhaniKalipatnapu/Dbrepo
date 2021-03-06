/****** Object:  StoredProcedure [dbo].[CTHB_RETRIEVE_S13]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CTHB_RETRIEVE_S13] (
 @An_TransHeader_IDNO       NUMERIC(12, 0),
 @Ac_IVDOutOfStateFips_CODE CHAR(2),
 @Ad_Transaction_DATE       DATE,
 @Ai_Count_QNTY             INT OUTPUT
 )
AS
 /*      
  *     PROCEDURE NAME    : CTHB_RETRIEVE_S13      
  *     DESCRIPTION       : Retrieve the Row Count for a Transaction Header Idno, Transaction Date, Other State Fips Code, Case Idno is Not Null or Not Empty, and where the Indicator for whether UIFSA Form is printed or not is equal to Yes.      
  *     DEVELOPED BY      : IMP Team     
  *     DEVELOPED ON      : 02-SEP-2011      
  *     MODIFIED BY       :       
  *     MODIFIED ON       :       
  *     VERSION NO        : 1      
  */
 BEGIN
  SET @Ai_Count_QNTY = NULL;

  DECLARE @Lc_Yes_INDC  CHAR(1) = 'Y',
          @Li_Zero_NUMB SMALLINT = 0;

  SELECT @Ai_Count_QNTY = COUNT(1)
    FROM CTHB_Y1 CT
   WHERE CT.TransHeader_IDNO = @An_TransHeader_IDNO
     AND CT.Transaction_DATE = @Ad_Transaction_DATE
     AND CT.IVDOutOfStateFips_CODE = @Ac_IVDOutOfStateFips_CODE
     AND (CT.Case_IDNO != @Li_Zero_NUMB
           OR CT.Trans3Printed_INDC = @Lc_Yes_INDC);
 END; --End of CTHB_RETRIEVE_S13  

GO
