/****** Object:  StoredProcedure [dbo].[CFAR_RETRIEVE_S5]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CFAR_RETRIEVE_S5] (
 @Ac_AutomaticUpdate_INDC CHAR(1)
 )
AS
 /*
 *      PROCEDURE NAME    : CFAR_RETRIEVE_S5
  *     DESCRIPTION       : Retrieve Distinct Function Code for a System Update Indicator
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 11-OCT-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  DECLARE @Lc_No_INDC         CHAR(1) = 'N',
          @Lc_Yes_INDC        CHAR(1) = 'Y',
          @Lc_ObsoleteNo_INDC CHAR(1) = 'N',
          @Lc_TableSubFunc_ID CHAR(5) = 'FUNC',
          @Lc_TableInts_ID    CHAR(5) = 'INTS';

  SELECT DISTINCT c.Function_CODE,
         (SELECT R.DescriptionValue_TEXT
            FROM REFM_Y1 R
           WHERE R.Table_ID = @Lc_TableInts_ID
             AND R.TableSub_ID = @Lc_TableSubFunc_ID
             AND R.Value_CODE = c.Function_CODE) AS DescriptionValue_TEXT
    FROM CFAR_Y1 c
   WHERE ((@Ac_AutomaticUpdate_INDC = @Lc_Yes_INDC
           AND c.AutomaticUpdate_INDC IN (@Lc_Yes_INDC, @Lc_No_INDC))
           OR (c.AutomaticUpdate_INDC = @Ac_AutomaticUpdate_INDC))
     AND c.Obsolete_INDC = @Lc_ObsoleteNo_INDC
   ORDER BY DescriptionValue_TEXT;
 END; -- End of CFAR_RETRIEVE_S5

GO
