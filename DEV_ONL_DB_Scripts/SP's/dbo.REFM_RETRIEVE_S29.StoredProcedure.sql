/****** Object:  StoredProcedure [dbo].[REFM_RETRIEVE_S29]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[REFM_RETRIEVE_S29]
AS
 /*
  *     PROCEDURE NAME    : REFM_RETRIEVE_S29
  *     DESCRIPTION       : Retrieving the value and description for the given Table and TableSub.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Lc_TableWlcm_ID CHAR(4) = 'WLCM';

  SELECT r.Value_CODE,
         r.DescriptionValue_TEXT
    FROM REFM_Y1 r
   WHERE r.Table_ID = @Lc_TableWlcm_ID
     AND r.TableSub_ID = @Lc_TableWlcm_ID
   ORDER BY r.Value_CODE;
 END; --End of REFM_RETRIEVE_S29

GO
