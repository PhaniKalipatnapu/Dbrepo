/****** Object:  StoredProcedure [dbo].[APAG_UPDATE_S1]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[APAG_UPDATE_S1] (
 @An_Application_IDNO   NUMERIC(15, 0),
 @An_MemberMci_IDNO     NUMERIC(10, 0),
 @As_ServerPath_NAME    VARCHAR(60),
 @As_AgencyLine1_ADDR   VARCHAR(50),
 @As_AgencyLine2_ADDR   VARCHAR(50),
 @An_AgencyPhone_NUMB   NUMERIC(15, 0),
 @Ac_AgencyCity_ADDR    CHAR(28),
 @Ac_AgencyZip_ADDR     CHAR(15),
 @An_AgencyFax_NUMB     NUMERIC(15, 0),
 @Ac_AgencyState_ADDR   CHAR(2),
 @Ac_AgencyCountry_ADDR CHAR(2),
 @As_Agency_EML         VARCHAR(100)
 )
AS
 /*                                                                                                                                         
  *     PROCEDURE NAME    : APAG_UPDATE_S1                                                                                                   
  *     DESCRIPTION       : Insert values in Member Demographics.                                                                           
  *     DEVELOPED BY      : IMP Team                                                                                                      
  *     DEVELOPED ON      : 02-NOV-2011                                                                                                     
  *     MODIFIED BY       :                                                                                                                 
  *     MODIFIED ON       :                                                                                                                 
  *     VERSION NO        : 1                                                                                                               
 */
 BEGIN
  DECLARE @Li_RowsAffected_NUMB INT;

  UPDATE APAG_Y1
     SET ServerPath_NAME = @As_ServerPath_NAME,
         AgencyLine1_ADDR = @As_AgencyLine1_ADDR,
         AgencyLine2_ADDR = @As_AgencyLine2_ADDR,
         AgencyPhone_NUMB = @An_AgencyPhone_NUMB,
         AgencyCity_ADDR = @Ac_AgencyCity_ADDR,
         AgencyZip_ADDR = @Ac_AgencyZip_ADDR,
         AgencyFax_NUMB = @An_AgencyFax_NUMB,
         AgencyState_ADDR = @Ac_AgencyState_ADDR,
         AgencyCountry_ADDR = @Ac_AgencyCountry_ADDR,
         Agency_EML = @As_Agency_EML
   WHERE Application_IDNO = @An_Application_IDNO
     AND MemberMci_IDNO = @An_MemberMci_IDNO;

  SET @Li_RowsAffected_NUMB = @@ROWCOUNT;

  SELECT @Li_RowsAffected_NUMB AS RowsAffected_NUMB;
 END; --End of APAG_UPDATE_S1    

GO
