/****** Object:  StoredProcedure [dbo].[APAH_UPDATE_S3]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[APAH_UPDATE_S3](
 @An_Application_IDNO NUMERIC(15),
 @An_MemberMci_IDNO   NUMERIC(10)
 )
AS
 /*            
  *     PROCEDURE NAME    : APAH_UPDATE_S3            
  *     DESCRIPTION       : Updates the end date validity to current date time for the given Application Id, Member Id, Transaction Event Sequence where  Member Address Type is MAILING/PRIMARY RESIDENCE/SECONDARY RESIDENCE and enddate validity is highdate. 
  *     DEVELOPED BY      : IMP Team            
  *     DEVELOPED ON      : 02-NOV-2011            
  *     MODIFIED BY       :             
  *     MODIFIED ON       :             
  *     VERSION NO        : 1            
  */
 BEGIN
  DECLARE @Ld_Systemdate_DATE   DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
          @Ld_High_DATE         DATE = '12/31/9999',
          @Li_RowsAffected_NUMB INT;

  UPDATE APAH_Y1
     SET EndValidity_DATE = @Ld_Systemdate_DATE
   WHERE Application_IDNO = @An_Application_IDNO
     AND MemberMci_IDNO = @An_MemberMci_IDNO
     AND EndValidity_DATE = @Ld_High_DATE;

  SET @Li_RowsAffected_NUMB = @@ROWCOUNT;

  SELECT @Li_RowsAffected_NUMB AS RowsAffected_NUMB;
 END; --End of APAH_UPDATE_S3


GO
