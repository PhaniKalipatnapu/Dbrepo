/****** Object:  StoredProcedure [dbo].[OTHP_RETRIEVE_S103]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[OTHP_RETRIEVE_S103] (
 @Ac_TypeOthp_CODE  CHAR(1),
 @An_MemberMci_IDNO NUMERIC(10),
 @Ai_RowFrom_NUMB   INT = 1,
 @Ai_RowTo_NUMB     INT = 10
 )
AS
 /*
  *     PROCEDURE NAME    : OTHP_RETRIEVE_S103
  *     DESCRIPTION       : Retrieve the Other Party details for a Member MCI ID Number and Other Party ID Number of the Asset Types from REFM MAST/FINA.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 16-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE	@Lc_Yes_INDC			CHAR(1)		= 'Y',
			@Lc_TableMast_ID		CHAR(4)		= 'MAST',
			@Lc_TableSubFina_ID		CHAR(4)		= 'FINA',
			@Ld_High_DATE			DATE		= '12/31/9999';

  SELECT DISTINCT x.OtherParty_IDNO,
         x.OtherParty_NAME,
         x.Line1_ADDR,
         x.Line2_ADDR,
         x.City_ADDR,
         x.Zip_ADDR,
         x.State_ADDR,
         x.Fein_IDNO,
         x.Asset_CODE,
         x.AccountAssetNo_TEXT,
         x.RowCount_NUMB
    FROM (SELECT o.Fein_IDNO,
                 o.OtherParty_IDNO,
                 o.OtherParty_NAME,
                 o.Line1_ADDR,
                 o.Line2_ADDR,
                 o.City_ADDR,
                 o.State_ADDR,
                 o.Zip_ADDR,
                 f.AccountAssetNo_TEXT,
                 f.Asset_CODE,
                 ROW_NUMBER() OVER ( ORDER BY o.OtherParty_IDNO ) AS Row_NUMB,
                 COUNT(1) OVER() AS RowCount_NUMB
            FROM OTHP_Y1 o
            JOIN ASFN_Y1 f
              ON f.OthpInsFin_IDNO = o.OtherParty_IDNO
             AND f.MemberMci_IDNO = @An_MemberMci_IDNO
             AND f.Status_CODE = @Lc_Yes_INDC
             AND f.EndValidity_DATE = @Ld_High_DATE
           WHERE o.TypeOthp_CODE = @Ac_TypeOthp_CODE
             AND o.EndValidity_DATE = @Ld_High_DATE
             AND EXISTS (SELECT 1 
							FROM REFM_Y1 r
						   WHERE r.Table_ID = @Lc_TableMast_ID
							 AND r.TableSub_ID = @Lc_TableSubFina_ID
							 AND r.Value_CODE = f.Asset_CODE)) AS x
    WHERE x.Row_NUMB BETWEEN @Ai_RowFrom_NUMB AND @Ai_RowTo_NUMB;
 END; --END OF OTHP_RETRIEVE_S103


GO
