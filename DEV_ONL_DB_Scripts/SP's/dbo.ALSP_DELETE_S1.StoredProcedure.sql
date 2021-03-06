/****** Object:  StoredProcedure [dbo].[ALSP_DELETE_S1]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ALSP_DELETE_S1] (
 @An_Application_IDNO NUMERIC(15),
 @An_MemberMci_IDNO   NUMERIC(10),
 @An_YearMonth_NUMB   NUMERIC(6) = NULL
 )
AS
 /*
  *     PROCEDURE NAME    : ALSP_DELETE_S1
  *     DESCRIPTION       : Removes the whole affidavit of payment records. 
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-NOV-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ln_RowsAffected_NUMB NUMERIC(10) = 0;

  DELETE FROM ALSP_Y1
   WHERE Application_IDNO = @An_Application_IDNO
     AND MemberMCI_IDNO = @An_MemberMci_IDNO
     AND YearMonth_NUMB = ISNULL(@An_YearMonth_NUMB, YearMonth_NUMB);

  SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;

  SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB;
 END; --End of ALSP_DELETE_S1

GO
