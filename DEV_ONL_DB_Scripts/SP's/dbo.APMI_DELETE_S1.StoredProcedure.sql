/****** Object:  StoredProcedure [dbo].[APMI_DELETE_S1]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[APMI_DELETE_S1](
 @An_Application_IDNO NUMERIC(15, 0),
 @An_MemberMci_IDNO   NUMERIC(10, 0)
 )
AS
 /*
  *     PROCEDURE NAME    : APMI_DELETE_S1
  *     DESCRIPTION       : Deletes the records when the member has no insurance.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 22-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ln_RowsAffected_NUMB NUMERIC(10);

  DELETE FROM APMI_Y1
   WHERE Application_IDNO = @An_Application_IDNO
     AND MemberMci_IDNO = @An_MemberMci_IDNO;

  SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;

  SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB;
 END; -- End Of APMI_DELETE_S1

GO
