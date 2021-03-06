/****** Object:  StoredProcedure [dbo].[CAIN_RETRIEVE_S2]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CAIN_RETRIEVE_S2] (
 @An_TransHeader_IDNO       NUMERIC(12, 0),
 @Ac_IVDOutOfStateFips_CODE CHAR(2),
 @Ad_Transaction_DATE       DATE,
 @Ac_Notice_ID              CHAR(8),
 @An_Barcode_NUMB           NUMERIC(12, 0) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : CAIN_RETRIEVE_S2
  *     DESCRIPTION       : Retrieve Barcode_NUMB for the given TransHeader_IDNO, Transaction_DATE, Notice_ID and out of state fips code with the EndValidity_DATE equal to high_date
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 11-OCT-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  SET @An_Barcode_NUMB = NULL;

  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT @An_Barcode_NUMB = c.Barcode_NUMB
    FROM CAIN_Y1 c
   WHERE c.TransHeader_IDNO = @An_TransHeader_IDNO
     AND c.IVDOutOfStateFips_CODE = @Ac_IVDOutOfStateFips_CODE
     AND c.Transaction_DATE = @Ad_Transaction_DATE
     AND c.Notice_ID = @Ac_Notice_ID
     AND c.EndValidity_DATE = @Ld_High_DATE;
 END; -- End of CAIN_RETRIEVE_S2

GO
