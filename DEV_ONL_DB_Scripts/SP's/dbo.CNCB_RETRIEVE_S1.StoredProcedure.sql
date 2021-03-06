/****** Object:  StoredProcedure [dbo].[CNCB_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CNCB_RETRIEVE_S1](
 @An_TransHeader_IDNO          NUMERIC(12, 0),
 @Ac_IVDOutOfStateFips_CODE    CHAR(2),
 @Ad_Transaction_DATE          DATE,
 @Ac_DescriptionWeightLbs_TEXT CHAR(3) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : CNCB_RETRIEVE_S1
  *     DESCRIPTION       : Retrieve Weight for a Transaction Header Block, State FIPS for the state and Transaction Date.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-NOV-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @Ac_DescriptionWeightLbs_TEXT = NULL;

  SELECT @Ac_DescriptionWeightLbs_TEXT = C.DescriptionWeightLbs_TEXT
    FROM CNCB_Y1 C
   WHERE C.TransHeader_IDNO = @An_TransHeader_IDNO
     AND C.IVDOutOfStateFips_CODE = @Ac_IVDOutOfStateFips_CODE
     AND C.Transaction_DATE = @Ad_Transaction_DATE;
 END; --End of CNCB_RETRIEVE_S1


GO
