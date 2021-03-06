/****** Object:  StoredProcedure [dbo].[SCFN_RETRIEVE_S2]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SCFN_RETRIEVE_S2] (
 @Ac_Screen_ID CHAR(4)
 )
AS
 /*
 *      PROCEDURE NAME    : SCFN_RETRIEVE_S2
  *     DESCRIPTION       : Retrieve the screen function details for the given screen.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT s.ScreenFunction_CODE,
         s.ScreenFunction_NAME,
         s.AccessAdd_INDC,
         s.AccessDelete_INDC,
         s.AccessView_INDC,
         s.AccessModify_INDC,
         s.DescriptionScreenFunction_TEXT
    FROM SCFN_Y1 s
   WHERE s.Screen_ID = @Ac_Screen_ID
     AND s.EndValidity_DATE = @Ld_High_DATE
   ORDER BY s.NoPosition_IDNO;
 END; -- End Of SCFN_RETRIEVE_S2

GO
