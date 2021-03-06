/****** Object:  StoredProcedure [dbo].[APDM_UPDATE_S3]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[APDM_UPDATE_S3](
 @An_Application_IDNO NUMERIC(15, 0),
 @An_MemberMci_IDNO   NUMERIC(10, 0)
 )
AS
 /*       
  *     PROCEDURE NAME    : APDM_UPDATE_S3          
  *     DESCRIPTION       : Logically delete the valid record for a Member, Unique Sequence Number when end validity date is equal to high date.                        
  *     DEVELOPED BY      : IMP Team          
  *     DEVELOPED ON      : 22-AUG-2011          
  *     MODIFIED BY       :           
  *     MODIFIED ON       :           
  *     VERSION NO        : 1          
 */
 BEGIN
  DECLARE @Ld_Systemdate_DATE   DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
          @Ld_High_DATE         DATE = '12/31/9999',
          @Ln_RowsAffected_NUMB NUMERIC(10);

  UPDATE APDM_Y1
     SET EndValidity_DATE = @Ld_Systemdate_DATE
   WHERE Application_IDNO = @An_Application_IDNO
     AND MemberMci_IDNO = @An_MemberMci_IDNO
     AND EndValidity_DATE = @Ld_High_DATE;

  SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;

  SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB;
 END; -- End Of APDM_UPDATE_S3


GO
