/****** Object:  StoredProcedure [dbo].[APAG_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[APAG_RETRIEVE_S1](
 @An_Application_IDNO   NUMERIC(15),
 @An_MemberMci_IDNO     NUMERIC(10),
 @An_Agency_IDNO        NUMERIC(9) OUTPUT,
 @As_ServerPath_NAME    VARCHAR(60) OUTPUT,
 @As_AgencyLine1_ADDR   VARCHAR(50) OUTPUT,
 @As_AgencyLine2_ADDR   VARCHAR(50) OUTPUT,
 @An_AgencyPhone_NUMB   NUMERIC(15) OUTPUT,
 @Ac_AgencyCity_ADDR    CHAR(28) OUTPUT,
 @Ac_AgencyZip_ADDR     CHAR(15) OUTPUT,
 @An_AgencyFax_NUMB     NUMERIC(15) OUTPUT,
 @Ac_AgencyState_ADDR   CHAR(2) OUTPUT,
 @Ac_AgencyCountry_ADDR CHAR(2) OUTPUT,
 @As_Agency_EML         VARCHAR(100) OUTPUT
 )
AS
 /*                                                                                                                                         
  *     PROCEDURE NAME    : APAG_RETRIEVE_S1                                                                                                   
  *     DESCRIPTION       : Insert values in Member Demographics.                                                                           
  *     DEVELOPED BY      : IMP Team                                                                                                      
  *     DEVELOPED ON      : 02-NOV-2011                                                                                                     
  *     MODIFIED BY       :                                                                                                                 
  *     MODIFIED ON       :                                                                                                                 
  *     VERSION NO        : 1                                                                                                               
 */
 BEGIN
  SELECT @As_ServerPath_NAME = NULL,
         @As_AgencyLine1_ADDR = NULL,
         @As_AgencyLine2_ADDR = NULL,
         @An_AgencyPhone_NUMB = NULL,
         @Ac_AgencyCity_ADDR = NULL,
         @Ac_AgencyZip_ADDR = NULL,
         @An_AgencyFax_NUMB = NULL,
         @Ac_AgencyState_ADDR = NULL,
         @Ac_AgencyCountry_ADDR = NULL,
         @As_Agency_EML = NULL;

  SELECT @As_ServerPath_NAME = AP.ServerPath_NAME,
         @An_Agency_IDNO = AP.Agency_IDNO,
         @As_AgencyLine1_ADDR = AP.AgencyLine1_ADDR,
         @As_AgencyLine2_ADDR = AP.AgencyLine2_ADDR,
         @An_AgencyPhone_NUMB = AP.AgencyPhone_NUMB,
         @Ac_AgencyCity_ADDR = AP.AgencyCity_ADDR,
         @Ac_AgencyZip_ADDR = AP.AgencyZip_ADDR,
         @An_AgencyFax_NUMB = AP.AgencyFax_NUMB,
         @Ac_AgencyState_ADDR = AP.AgencyState_ADDR,
         @Ac_AgencyCountry_ADDR = AP.AgencyCountry_ADDR,
         @As_Agency_EML = AP.Agency_EML
    FROM APAG_Y1 AP
   WHERE AP.Application_IDNO = @An_Application_IDNO
     AND AP.MemberMci_IDNO = @An_MemberMci_IDNO;
 END; --End of APAG_RETRIEVE_S1


GO
