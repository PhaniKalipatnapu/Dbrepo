/****** Object:  StoredProcedure [dbo].[CTHB_RETRIEVE_S3]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CTHB_RETRIEVE_S3]
 @Ad_Transaction_DATE DATE,
 @Ac_StateFips_CODE   CHAR(2),
 @An_TransHeader_IDNO NUMERIC(12),
 @Ad_Referral_DATE    DATE OUTPUT
AS
 /*
  *     PROCEDURE NAME    : CTHB_RETRIEVE_S3
  *     DESCRIPTION       : The procedure is used to obtain the referal date.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-MAR-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @Ad_Referral_DATE = NULL;

  SELECT @Ad_Referral_DATE = C.Transaction_DATE
    FROM CTHB_Y1 C
   WHERE C.TransHeader_IDNO = @An_TransHeader_IDNO
     AND C.IVDOutOfStateFips_CODE = @Ac_StateFips_CODE
     AND C.Transaction_DATE = @Ad_Transaction_DATE;
 END;


GO
