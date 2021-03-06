/****** Object:  StoredProcedure [dbo].[OTHP_RETRIEVE_S104]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[OTHP_RETRIEVE_S104] (
 @Ac_TypeOthp_CODE  CHAR(1),
 @An_MemberMci_IDNO NUMERIC(10, 0),
 @Ai_RowFrom_NUMB   INT = 1,
 @Ai_RowTo_NUMB     INT = 10
 )
AS
 /*
  *     PROCEDURE NAME    : OTHP_RETRIEVE_S104
  *     DESCRIPTION       : Retrieve the Other Party details for a Member Id and Other Party Id of a certain type is certain Asset Type of Insurance Settlement.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 16-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Lc_Yes_INDC      CHAR(1) = 'Y',
          @Ld_High_DATE     DATE = '12/31/9999',
          @Lc_AssetIns_CODE CHAR(3) = 'INS';

  SELECT X.OtherParty_IDNO,
         X.OtherParty_NAME,
         X.Line1_ADDR,
         X.Line2_ADDR,
         X.City_ADDR,
         X.Zip_ADDR,
         X.State_ADDR,
         X.Fein_IDNO,
         X.Asset_CODE,
         X.AccountAssetNo_TEXT,
         X.Count_QNTY AS RowCount_NUMB
    FROM (SELECT o.Fein_IDNO,
                 o.OtherParty_IDNO,
                 o.OtherParty_NAME,
                 o.Line1_ADDR,
                 o.Line2_ADDR,
                 o.City_ADDR,
                 o.State_ADDR,
                 o.Zip_ADDR,
                 f.Asset_CODE,
                 f.AccountAssetNo_TEXT,
                 ROW_NUMBER() OVER ( ORDER BY o.OtherParty_IDNO ) AS rn,
                 COUNT(1) OVER() AS Count_QNTY
            FROM OTHP_Y1 o
                 JOIN ASFN_Y1 f
                  ON o.OtherParty_IDNO = f.OthpInsFin_IDNO
           WHERE o.EndValidity_DATE = @Ld_High_DATE
             AND o.TypeOthp_CODE = @Ac_TypeOthp_CODE
             AND f.MemberMci_IDNO = @An_MemberMci_IDNO
             AND f.Asset_CODE = @Lc_AssetIns_CODE
             AND f.EndValidity_DATE = @Ld_High_DATE
             AND f.Status_CODE = @Lc_Yes_INDC) AS X
   WHERE X.rn BETWEEN @Ai_RowFrom_NUMB AND @Ai_RowTo_NUMB;
 END; --END OF OTHP_RETRIEVE_S104


GO
