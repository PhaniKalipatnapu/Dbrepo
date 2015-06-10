/****** Object:  StoredProcedure [dbo].[APEH_UPDATE_S3]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[APEH_UPDATE_S3](
 @An_Application_IDNO NUMERIC(15, 0),
 @An_MemberMci_IDNO   NUMERIC(10, 0)
 )
AS
 /*        
  *     PROCEDURE NAME    : APEH_UPDATE_S3        
  *     DESCRIPTION       : Updates the enddate validity to current date time for the given Application Id, Member Id, Transaction Event Sequence where Type of Employer is Current Employer and  enddate validity is highdate.         
  *     DEVELOPED BY      : IMP Team        
  *     DEVELOPED ON      : 29-AUG-2011        
  *     MODIFIED BY       :         
  *     MODIFIED ON       :         
  *     VERSION NO        : 1        
 */
 BEGIN
  DECLARE @Ld_High_DATE            DATE = '12/31/9999',
          @Ln_RowsAffected_NUMB    NUMERIC(10),
          @Ln_MemberMciFoster_IDNO NUMERIC(10)= 0000999998;

  UPDATE APEH_Y1
     SET MemberMci_IDNO = @Ln_MemberMciFoster_IDNO
   WHERE Application_IDNO = @An_Application_IDNO
     AND MemberMci_IDNO = @An_MemberMci_IDNO
     AND EndValidity_DATE = @Ld_High_DATE;

  SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;

  SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB;
 END; -- End Of APEH_UPDATE_S3


GO
