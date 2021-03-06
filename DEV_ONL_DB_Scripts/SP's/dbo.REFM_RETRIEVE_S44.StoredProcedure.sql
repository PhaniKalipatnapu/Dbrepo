/****** Object:  StoredProcedure [dbo].[REFM_RETRIEVE_S44]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[REFM_RETRIEVE_S44] (
 @Ac_Value_CODE            CHAR(5),
 @As_DescriptionValue_TEXT VARCHAR(70) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : REFM_RETRIEVE_S44
  *     DESCRIPTION       : Retrieve the value's description within the Reference Table from Maintenance Reference table for value within the Reference Table equal, Reference Table that is being utilized equal to MAST and subtype within the Reference Table equal to REGV / RELP / FINA / FIIS / FINS.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-MAR-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @As_DescriptionValue_TEXT = NULL;

  DECLARE @Lc_Fiis_ID CHAR(4) = 'FIIS',
          @Lc_Fina_ID CHAR(4) = 'FINA',
          @Lc_Fins_ID CHAR(4) = 'FINS',
          @Lc_Mast_ID CHAR(4) = 'MAST',
          @Lc_Regv_ID CHAR(4) = 'REGV',
          @Lc_Relp_ID CHAR(4) = 'RELP';

  SELECT @As_DescriptionValue_TEXT = R.DescriptionValue_TEXT
    FROM REFM_Y1 R
   WHERE R.Value_CODE = @Ac_Value_CODE
     AND R.Table_ID = @Lc_Mast_ID
     AND R.TableSub_ID IN (@Lc_Regv_ID, @Lc_Relp_ID, @Lc_Fina_ID, @Lc_Fiis_ID, @Lc_Fins_ID);
 END; --END OF REFM_RETRIEVE_S44

GO
