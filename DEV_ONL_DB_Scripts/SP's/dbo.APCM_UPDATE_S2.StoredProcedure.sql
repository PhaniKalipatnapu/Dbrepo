/****** Object:  StoredProcedure [dbo].[APCM_UPDATE_S2]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[APCM_UPDATE_S2](
 @An_OthpAtty_IDNO    NUMERIC(9),
 @An_Application_IDNO NUMERIC(15),
 @An_MemberMci_IDNO   NUMERIC(10)
 )
AS
 /*                
  *     PROCEDURE NAME    : APCM_UPDATE_S2                
  *     DESCRIPTION       : Update Other party attorney ID for the member for an Application ID and Member ID.        
  *     DEVELOPED BY      : IMP Team                
  *     DEVELOPED ON      : 08-NOV-2011                
  *     MODIFIED BY       :                 
  *     MODIFIED ON       :                 
  *     VERSION NO        : 1                
 */
 BEGIN
  DECLARE @Ld_High_DATE         DATE = '12/31/9999',
          @Li_RowsAffected_NUMB INT;

  UPDATE APCM_Y1
     SET OthpAtty_IDNO = @An_OthpAtty_IDNO
   WHERE APCM_Y1.Application_IDNO = @An_Application_IDNO
     AND APCM_Y1.MemberMci_IDNO = @An_MemberMci_IDNO
     AND APCM_Y1.EndValidity_DATE = @Ld_High_DATE;

  SET @Li_RowsAffected_NUMB = @@ROWCOUNT;

  SELECT @Li_RowsAffected_NUMB AS RowsAffected_NUMB;
 END; --End of APCM_UPDATE_S2

GO
