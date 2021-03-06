/****** Object:  StoredProcedure [dbo].[OFIC_RETRIEVE_S23]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[OFIC_RETRIEVE_S23] (
 @An_SignedOnOffice_IDNO NUMERIC(3, 0),
 @Ac_Exists_INDC         CHAR(1) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : OFIC_RETRIEVE_S23
  *     DESCRIPTION       : It Check whether the data is Exists for the Office id.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 04-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  DECLARE @Ld_High_DATE DATE 	= '12/31/9999',
          @Lc_Yes_TEXT  CHAR(1) = 'Y',
          @Lc_No_TEXT   CHAR(1) = 'N';
          
  SET @Ac_Exists_INDC = @Lc_No_TEXT;

  SELECT @Ac_Exists_INDC = @Lc_Yes_TEXT
    FROM OFIC_Y1 O
   WHERE O.Office_IDNO = @An_SignedOnOffice_IDNO
     AND O.EndValidity_DATE = @Ld_High_DATE;
 END; --End of OFIC_RETRIEVE_S23

GO
