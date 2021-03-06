/****** Object:  StoredProcedure [dbo].[AMJR_RETRIEVE_S11]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[AMJR_RETRIEVE_S11]
AS
 /*
  *     PROCEDURE NAME    : AMJR_RETRIEVE_S11
  *     DESCRIPTION       : Gets the activity major code and description Lists from AMJR table. 
  *     DEVELOPED BY      : IMP TEAM
  *     DEVELOPED ON      : 02-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ld_High_DATE DATE= '12/31/9999';

  SELECT DISTINCT A.ActivityMajor_CODE,
			A.DescriptionActivity_TEXT
    FROM AMJR_Y1 A
   WHERE A.EndValidity_DATE = @Ld_High_DATE
   ORDER BY A.DescriptionActivity_TEXT;
 END; -- End of AMJR_RETRIEVE_S11


GO
