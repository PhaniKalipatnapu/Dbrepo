/****** Object:  StoredProcedure [dbo].[MHIS_RETRIEVE_S33]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[MHIS_RETRIEVE_S33] (
 @An_CaseWelfare_IDNO NUMERIC(10, 0),
 @Ac_IvaIve_INDC      CHAR(1),
 @Ai_Count_QNTY       INT OUTPUT
 )
AS
 /*
 *     PROCEDURE NAME     : MHIS_RETRIEVE_S33
  *     DESCRIPTION       : Checks whether a valid iva ive case.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @Ai_Count_QNTY = NULL;

  DECLARE @Lc_TypeWelfareFosterCare_CODE CHAR(1) = 'J',
          @Lc_TypeWelfareMedicaid_CODE   CHAR(1) = 'M',
          @Lc_TypeWelfareNonIve_CODE     CHAR(1) = 'F',
          @Lc_TypeWelfareTanf_CODE       CHAR(1) = 'A',
          @Lc_IndIva_INDC                CHAR(1) = 'A',
          @Lc_IndIve_INDC                CHAR(1) = 'E';

  SELECT @Ai_Count_QNTY = COUNT(1)
    FROM MHIS_Y1 M
   WHERE M.CaseWelfare_IDNO = @An_CaseWelfare_IDNO
     AND ((@Ac_IvaIve_INDC IS NULL)
           OR ((@Ac_IvaIve_INDC IS NOT NULL)
               AND (((@Ac_IvaIve_INDC = @Lc_IndIva_INDC)
                     AND (M.TypeWelfare_CODE IN (@Lc_TypeWelfareTanf_CODE, @Lc_TypeWelfareMedicaid_CODE)))
                     OR ((@Ac_IvaIve_INDC = @Lc_IndIve_INDC)
                         AND (M.TypeWelfare_CODE IN (@Lc_TypeWelfareNonIve_CODE, @Lc_TypeWelfareFosterCare_CODE))))));
 END; --End Of MHIS_RETRIEVE_S33

GO
