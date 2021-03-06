/****** Object:  StoredProcedure [dbo].[UCAT_RETRIEVE_S11]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[UCAT_RETRIEVE_S11]
AS
 /*
  *     PROCEDURE NAME    : UCAT_RETRIEVE_S11
  *     DESCRIPTION       : Retrieve the Un-Distributed Collections codes details.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT A.Udc_CODE,
         A.HoldLevel_CODE,
         A.Table_ID,
         A.TableSub_ID,
         (SELECT b.DescriptionValue_TEXT
            FROM REFM_Y1 B
           WHERE B.Table_ID = A.Table_ID
             AND B.TableSub_ID = A.TableSub_ID
             AND B.Value_CODE = A.Udc_CODE) AS DescriptionValue_TEXT
    FROM UCAT_Y1 A
   WHERE A.EndValidity_DATE = @Ld_High_DATE
   ORDER BY A.HoldLevel_CODE,
            DescriptionValue_TEXT;
 END; --End of UCAT_RETRIEVE_S11


GO
