/****** Object:  StoredProcedure [dbo].[REFM_RETRIEVE_S21]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[REFM_RETRIEVE_S21]
AS
 /*
  *     PROCEDURE NAME    : REFM_RETRIEVE_S21
  *     DESCRIPTION       : Retrieve distinct Table Idno records.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 05-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  SELECT DISTINCT R.Table_ID
    FROM REFM_Y1 R
   ORDER BY R.Table_ID;
 END; -- End Of REFM_RETRIEVE_S21

GO
