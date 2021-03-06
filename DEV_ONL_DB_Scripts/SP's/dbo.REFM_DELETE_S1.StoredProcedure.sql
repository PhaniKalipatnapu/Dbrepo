/****** Object:  StoredProcedure [dbo].[REFM_DELETE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[REFM_DELETE_S1] (
 @Ac_Table_ID    CHAR(4),
 @Ac_TableSub_ID CHAR(4),
 @Ac_Value_CODE  CHAR(10)
 )
AS
 /*
  *     PROCEDURE NAME    : REFM_DELETE_S1
  *     DESCRIPTION       : Delete RefMaintenance record for a  given Table Idno, Sub Table Idno, and Value Code.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 05-AUG-2011
  *     MODIFIED BY       :
  *     MODIFIED ON       :
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ln_RowsAffected_NUMB NUMERIC(10);

  DELETE REFM_Y1
   WHERE Table_ID = @Ac_Table_ID
     AND TableSub_ID = @Ac_TableSub_ID
     AND Value_CODE = @Ac_Value_CODE;

  SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;

  SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB;
 END; --End of REFM_DELETE_S1

GO
