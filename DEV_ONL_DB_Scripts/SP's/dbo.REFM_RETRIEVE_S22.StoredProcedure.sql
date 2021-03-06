/****** Object:  StoredProcedure [dbo].[REFM_RETRIEVE_S22]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[REFM_RETRIEVE_S22] (
 @Ac_Table_ID CHAR(4)
 )
AS
 /*
  *     PROCEDURE NAME    : REFM_RETRIEVE_S22
  *     DESCRIPTION       : Retrieve Sub Table Idno and Description for a Table Idno.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 05-AUG-2011
  *     MODIFIED BY       :
  *     MODIFIED ON       :
  *     VERSION NO        : 1
  */
 BEGIN
  SELECT DISTINCT R.TableSub_ID,
         R.DescriptionTable_TEXT
    FROM REFM_Y1 R
   WHERE R.Table_ID = @Ac_Table_ID
   ORDER BY R.DescriptionTable_TEXT;
 END; -- End Of REFM_RETRIEVE_S22

GO
