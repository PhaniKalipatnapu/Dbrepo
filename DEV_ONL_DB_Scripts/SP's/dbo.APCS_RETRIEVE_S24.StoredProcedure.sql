/****** Object:  StoredProcedure [dbo].[APCS_RETRIEVE_S24]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[APCS_RETRIEVE_S24](
 @An_CaseWelfare_IDNO NUMERIC(10),
 @Ac_Exists_INDC      CHAR(1) OUTPUT
 )
AS
 /*
 *     PROCEDURE NAME    : APCS_RETRIEVE_S24
  *     DESCRIPTION       : sets the ICOR indicator to 'N' if records exists for the input Welfare Case Id where welfare type of the member is medicaid, fostercare, temporary assistant for needy family, non-temporary assistant for needy family, non IVE, and the case type is not empty  and enddate validity is highdate.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-NOV-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Lc_Yes_INDC                   CHAR(1) = 'Y',
          @Lc_No_INDC                    CHAR(1) = 'N',
          @Lc_Space_TEXT                 CHAR(1) = ' ',
          @Lc_TypeWelfareFosterCare_CODE CHAR(1) = 'J',
          @Lc_TypeWelfareMedicaid_CODE   CHAR(1) = 'M',
          @Lc_TypeWelfareNonIve_CODE     CHAR(1) = 'F',
          @Lc_TypeWelfareNonTanf_CODE    CHAR(1) = 'N',
          @Lc_TypeWelfareTanf_CODE       CHAR(1) = 'A',
          @Ld_High_DATE                  DATE = '12/31/9999';

  SET @Ac_Exists_INDC = @Lc_No_INDC;

  SELECT @Ac_Exists_INDC = @Lc_Yes_INDC
    FROM APCS_Y1 AC
   WHERE AC.CaseWelfare_IDNO = @An_CaseWelfare_IDNO
     AND AC.TypeWelfare_CODE IN (@Lc_TypeWelfareMedicaid_CODE, @Lc_TypeWelfareNonTanf_CODE, @Lc_TypeWelfareFosterCare_CODE, @Lc_TypeWelfareNonIve_CODE, @Lc_TypeWelfareTanf_CODE)
     AND AC.TypeCase_CODE <> @Lc_Space_TEXT
     AND AC.EndValidity_DATE = @Ld_High_DATE;
 END; --End of APCS_RETRIEVE_S24

GO
