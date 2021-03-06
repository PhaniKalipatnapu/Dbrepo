/****** Object:  StoredProcedure [dbo].[OTHP_RETRIEVE_S102]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[OTHP_RETRIEVE_S102] (
 @Ac_TypeOthp_CODE  CHAR(1),
 @An_MemberMci_IDNO NUMERIC(10),
 @Ai_RowFrom_NUMB   INT = 1,
 @Ai_RowTo_NUMB     INT = 10
 )
AS
 /*
  *     PROCEDURE NAME    : OTHP_RETRIEVE_S102
  *     DESCRIPTION       : Retrieve the Other Party details for a Member Id and Other Party Id of a certain type is Expired License.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 16-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Lc_LicenseStatusActive_CODE		CHAR(1)		= 'A',
		  @Lc_StatusCg_CODE					CHAR(2)		= 'CG',
		  @Lc_TypeLicenseDr_CODE			CHAR(2)		= 'DR',
		  @Ld_High_DATE						DATE		= '12/31/9999';

  SELECT X.OtherParty_IDNO,
         X.OtherParty_NAME,
         X.Line1_ADDR,
         X.Line2_ADDR,
         X.City_ADDR,
         X.Zip_ADDR,
         X.State_ADDR,
         X.Fein_IDNO,
         X.TypeLicense_CODE,
         X.LicenseNo_TEXT,
         X.Count_QNTY AS RowCount_NUMB
    FROM (SELECT o.Fein_IDNO,
                 o.OtherParty_IDNO,
                 o.OtherParty_NAME,
                 o.Line1_ADDR,
                 o.Line2_ADDR,
                 o.City_ADDR,
                 o.State_ADDR,
                 o.Zip_ADDR,
                 l.LicenseNo_TEXT,
                 l.TypeLicense_CODE,
                 ROW_NUMBER() OVER ( ORDER BY o.OtherParty_IDNO ) AS rn,
                 COUNT(1) OVER() AS Count_QNTY
            FROM OTHP_Y1 o
                 JOIN PLIC_Y1 l
                  ON o.OtherParty_IDNO = l.OthpLicAgent_IDNO
           WHERE o.EndValidity_DATE = @Ld_High_DATE
             AND o.TypeOthp_CODE = @Ac_TypeOthp_CODE
             AND l.MemberMci_IDNO = @An_MemberMci_IDNO
             -- 13627 - License Suspension eligibility should not require an active license for DMV - Start
             AND ( l.TypeLicense_CODE = @Lc_TypeLicenseDr_CODE
					OR l.LicenseStatus_CODE = @Lc_LicenseStatusActive_CODE)
			 -- 13627 - License Suspension eligibility should not require an active license for DMV - End
             AND l.Status_CODE = @Lc_StatusCg_CODE
             AND l.ExpireLicense_DATE >= CONVERT(DATE, DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME())
             AND l.EndValidity_DATE = @Ld_High_DATE) AS X
   WHERE X.rn BETWEEN @Ai_RowFrom_NUMB AND @Ai_RowTo_NUMB;
 END; --END OF OTHP_RETRIEVE_S102


GO
