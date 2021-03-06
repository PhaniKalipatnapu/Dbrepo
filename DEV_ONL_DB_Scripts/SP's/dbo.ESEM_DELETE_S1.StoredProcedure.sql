/****** Object:  StoredProcedure [dbo].[ESEM_DELETE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ESEM_DELETE_S1] (
 @Ac_Entity_ID           CHAR(30),
 @An_EventGlobalSeq_NUMB NUMERIC(19, 0)
 )
AS
 /*
  *     PROCEDURE NAME    : ESEM_DELETE_S1
  *     DESCRIPTION       : Delete Record for an Entity number and Global Event number.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 17-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ln_RowsAffected_NUMB NUMERIC(10);

  DELETE ESEM_Y1
   WHERE Entity_ID = @Ac_Entity_ID
     AND EventGlobalSeq_NUMB = @An_EventGlobalSeq_NUMB;

  SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;

  SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB;
 END; -- END OF ESEM_DELETE_S1


GO
