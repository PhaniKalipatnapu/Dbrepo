/****** Object:  StoredProcedure [dbo].[REFM_RETRIEVE_S16]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[REFM_RETRIEVE_S16] (
 @Ac_Table_ID              CHAR(4),
 @Ac_TableSub_ID           CHAR(4),
 @Ac_DescriptionTable_TEXT CHAR(30) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : REFM_RETRIEVE_S16
  *     DESCRIPTION       : Retrieve Description for given Table Idno and SubTable Idno.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 05-AUG-2011
  *     MODIFIED BY       :
  *     MODIFIED ON       :
  *     VERSION NO        : 1
  */
 BEGIN
  SET @Ac_DescriptionTable_TEXT = NULL;

  SELECT TOP 1 @Ac_DescriptionTable_TEXT = R.DescriptionTable_TEXT
    FROM REFM_Y1 R
   WHERE R.Table_ID = @Ac_Table_ID
     AND R.TableSub_ID = @Ac_TableSub_ID;
 END; --End Of REFM_RETRIEVE_S16

GO
