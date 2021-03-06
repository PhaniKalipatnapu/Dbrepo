/****** Object:  StoredProcedure [dbo].[REFM_RETRIEVE_S43]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[REFM_RETRIEVE_S43]
AS
 /*
  *     PROCEDURE NAME    : REFM_RETRIEVE_S43
  *     DESCRIPTION       : Retrieve the value within the Reference Table, the value's description within the Reference Table and the derived Description from Maintenance Reference table for Reference Table that is being utilized equal to MAST and subtype within the Reference Table equal to FINA / FIIS / FINS.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-MAR-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Lc_Fiis_ID CHAR(4) = 'FIIS',
          @Lc_Fina_ID CHAR(4) = 'FINA',
          @Lc_Fins_ID CHAR(4) = 'FINS',
          @Lc_Mast_ID CHAR(4) = 'MAST';

  SELECT DISTINCT R.Value_CODE AS Value_CODE,
         R.DescriptionValue_TEXT AS DescriptionValue_TEXT
    FROM REFM_Y1 R
   WHERE R.Table_ID = @Lc_Mast_ID
     AND R.TableSub_ID IN (@Lc_Fina_ID, @Lc_Fins_ID, @Lc_Fiis_ID)
   ORDER BY R.DescriptionValue_TEXT;
 END; --END OF  REFM_RETRIEVE_S43

GO
