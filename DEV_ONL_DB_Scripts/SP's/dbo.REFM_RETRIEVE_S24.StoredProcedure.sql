/****** Object:  StoredProcedure [dbo].[REFM_RETRIEVE_S24]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[REFM_RETRIEVE_S24] (
 @Ac_Table_ID              CHAR(4),
 @Ac_TableSub_ID           CHAR(4),
 @As_DescriptionValue_TEXT VARCHAR(70),
 @Ai_Count_QNTY            INT OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : REFM_RETRIEVE_S24
  *     DESCRIPTION       : Check if a record exists for a Table Idno, Sub Table Idno, and Description.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 05-AUG-2011
  *     MODIFIED BY       :
  *     MODIFIED ON       :
  *     VERSION NO        : 1
  */
 BEGIN
  SET @Ai_Count_QNTY = NULL;

  SELECT @Ai_Count_QNTY = COUNT(1)
    FROM REFM_Y1 R
   WHERE R.Table_ID = @Ac_Table_ID
     AND R.TableSub_ID = @Ac_TableSub_ID
     AND R.DescriptionValue_TEXT = @As_DescriptionValue_TEXT;
 END; --End Of REFM_RETRIEVE_S24

GO
