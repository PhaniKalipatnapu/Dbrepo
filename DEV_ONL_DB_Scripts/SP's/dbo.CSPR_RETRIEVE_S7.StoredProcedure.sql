/****** Object:  StoredProcedure [dbo].[CSPR_RETRIEVE_S7]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CSPR_RETRIEVE_S7] (
 @An_Request_IDNO           NUMERIC(9, 0),
 @An_Case_IDNO              NUMERIC(6, 0),
 @Ac_IVDOutOfStateFips_CODE CHAR(2),
 @Ac_Exists_INDC            CHAR(1) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : CSPR_RETRIEVE_S7
  *     DESCRIPTION       : Retrieves the TransactionEvent Seq Numb for the given case idno, request idno, out of state fips code and the end validity date equal to high date
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 11-OCT-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  DECLARE @Lc_No_TEXT   CHAR(1) = 'N',
          @Lc_Yes_TEXT  CHAR(1) = 'Y',
          @Ld_High_DATE DATE = '12/31/9999';

  SET @Ac_Exists_INDC = @Lc_No_TEXT;

  SELECT @Ac_Exists_INDC = @Lc_Yes_TEXT
    FROM CSPR_Y1 c
   WHERE c.Case_IDNO = @An_Case_IDNO
     AND c.Request_IDNO = @An_Request_IDNO
     AND c.IVDOutOfStateFips_CODE = @Ac_IVDOutOfStateFips_CODE
     AND c.EndValidity_DATE = @Ld_High_DATE;
 END; -- End of CSPR_RETRIEVE_S7

GO
