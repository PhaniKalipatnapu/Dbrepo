/****** Object:  StoredProcedure [dbo].[TCHKV_DELETE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[TCHKV_DELETE_S1]
AS
 /*
  *     PROCEDURE NAME    : TCHKV_DELETE_S1
  *     DESCRIPTION       : Deletes the disbursement tracking details.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 14-FEB-2012
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DELETE TCHKV_Y1;

  DECLARE @Ln_RowsAffected_NUMB NUMERIC(10);
  DECLARE @Ltxt_ErrorMessage_TEXT VARCHAR(400);

  SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;
  SET @Ltxt_ErrorMessage_TEXT ='';

  SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB;
 END


GO
