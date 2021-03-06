/****** Object:  StoredProcedure [dbo].[OBLE_RETRIEVE_S107]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE PROCEDURE
 	[dbo].[OBLE_RETRIEVE_S107]
 		(
     		@An_Case_IDNO		NUMERIC(6,0),
     		@An_OrderSeq_NUMB	NUMERIC(2,0)
        )
AS

/*
 *     PROCEDURE NAME    : OBLE_RETRIEVE_S107
 *     DESCRIPTION       : Retrieves all list elements & list values for the given case id.
 *     DEVELOPED BY      :IMP Team
 *     DEVELOPED ON      : 14-SEP-2011
 *     MODIFIED BY       :
 *     MODIFIED ON       :
 *     VERSION NO        : 1
*/
BEGIN

      DECLARE
         @Ld_High_DATE        DATE = '12/31/9999',
         @Lc_All_TEXT         CHAR(3)   = 'ALL',
         @Lc_DoubleSpace_TEXT CHAR(2)   = '  ',
         @Lc_Null_TEXT        CHAR(1)   ='';

      SELECT DISTINCT ISNULL(a.TypeDebt_CODE, @Lc_Null_TEXT) + ISNULL(@Lc_DoubleSpace_TEXT, @Lc_Null_TEXT) + ISNULL(CONVERT(VARCHAR(10), a.MemberMci_IDNO), @Lc_Null_TEXT) + ISNULL(@Lc_DoubleSpace_TEXT, @Lc_Null_TEXT) + ISNULL(a.Fips_CODE, @Lc_Null_TEXT) AS ListElement_TEXT, a.ObligationSeq_NUMB AS ListValue_TEXT
      FROM OBLE_Y1  a
      WHERE
         a.Case_IDNO = @An_Case_IDNO AND
         a.OrderSeq_NUMB = @An_OrderSeq_NUMB AND
         a.EndValidity_DATE = @Ld_High_DATE
       UNION ALL
      SELECT DISTINCT ISNULL(a.TypeDebt_CODE, @Lc_Null_TEXT) + ISNULL(@Lc_DoubleSpace_TEXT, @Lc_Null_TEXT) + ISNULL(@Lc_All_TEXT, @Lc_Null_TEXT) AS ListElement_TEXT, 0
      FROM OBLE_Y1 a
      WHERE
         a.Case_IDNO = @An_Case_IDNO AND
         a.OrderSeq_NUMB = @An_OrderSeq_NUMB AND
         a.EndValidity_DATE = @Ld_High_DATE
      ORDER BY ListElement_TEXT;


END; --End of  OBLE_RETRIEVE_S107


GO
