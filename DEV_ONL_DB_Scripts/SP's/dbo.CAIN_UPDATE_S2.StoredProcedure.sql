/****** Object:  StoredProcedure [dbo].[CAIN_UPDATE_S2]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CAIN_UPDATE_S2] (
 @An_TransHeader_IDNO       NUMERIC(12, 0),
 @Ac_IVDOutOfStateFips_CODE CHAR(2),
 @Ad_Transaction_DATE       DATE,
 @Ac_Notice_ID              CHAR(8),
 @An_Barcode_NUMB           NUMERIC(12, 0)
 )
AS
 /*
  *     PROCEDURE NAME     : CAIN_UPDATE_S2
  *     DESCRIPTION       : Updates the Barcode number for the given TransHeader idno, out of state fips code, transaction date, notice id and the end validity date equal to high date.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 04-OCT-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  DECLARE @Ld_High_DATE         DATE = '12/31/9999',
          @Ln_RowsAffected_NUMB NUMERIC(10);

  UPDATE CAIN_Y1
     SET Barcode_NUMB = @An_Barcode_NUMB
   WHERE TransHeader_IDNO = @An_TransHeader_IDNO
     AND IVDOutOfStateFips_CODE = @Ac_IVDOutOfStateFips_CODE
     AND Transaction_DATE = @Ad_Transaction_DATE
     AND Notice_ID = @Ac_Notice_ID
     AND EndValidity_DATE = @Ld_High_DATE;

  SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;

  SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB;
 END; -- End of CAIN_UPDATE_S2

GO
