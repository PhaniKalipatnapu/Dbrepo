/****** Object:  StoredProcedure [dbo].[APAG_INSERT_S1]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[APAG_INSERT_S1] (
 @An_Application_IDNO   NUMERIC(15),
 @An_MemberMci_IDNO     NUMERIC(10),
 @As_ServerPath_NAME    VARCHAR(60),
 @As_AgencyLine1_ADDR   VARCHAR(50),
 @As_AgencyLine2_ADDR   VARCHAR(50),
 @An_AgencyPhone_NUMB   NUMERIC(15),
 @Ac_AgencyCity_ADDR    CHAR(28),
 @Ac_AgencyZip_ADDR     CHAR(15),
 @An_AgencyFax_NUMB     NUMERIC(15),
 @Ac_AgencyState_ADDR   CHAR(2),
 @Ac_AgencyCountry_ADDR CHAR(2),
 @As_Agency_EML         VARCHAR(100)
 )
AS
 /*          
  *     PROCEDURE NAME    : APAG_INSERT_S1          
  *     DESCRIPTION       : Retrieves the agency details for the respective member.          
  *     DEVELOPED BY      : IMP Team          
  *     DEVELOPED ON      : 02-NOV-2011          
  *     MODIFIED BY       :           
  *     MODIFIED ON       :           
  *     VERSION NO        : 1          
 */
 BEGIN
  DECLARE @Li_Zero_NUMB SMALLINT = 0;

  INSERT INTO APAG_Y1
              (Application_IDNO,
               MemberMci_IDNO,
               Agency_IDNO,
               ServerPath_NAME,
               AgencyLine1_ADDR,
               AgencyLine2_ADDR,
               AgencyPhone_NUMB,
               AgencyCity_ADDR,
               AgencyZip_ADDR,
               AgencyFax_NUMB,
               AgencyState_ADDR,
               AgencyCountry_ADDR,
               Agency_EML)
       SELECT @An_Application_IDNO,
                @An_MemberMci_IDNO,
                @Li_Zero_NUMB,
                @As_ServerPath_NAME,
                @As_AgencyLine1_ADDR,
                @As_AgencyLine2_ADDR,
                @An_AgencyPhone_NUMB,
                @Ac_AgencyCity_ADDR,
                @Ac_AgencyZip_ADDR,
                @An_AgencyFax_NUMB,
                @Ac_AgencyState_ADDR,
                @Ac_AgencyCountry_ADDR,
                @As_Agency_EML
                WHERE   NOT EXISTS (SELECT 1 FROM APAG_Y1  A WITH (Readuncommitted ) 
          WHERE Application_IDNO=@An_Application_IDNO AND MemberMci_IDNO=@An_MemberMci_IDNO);
                 END; --End of APAG_INSERT_S1


GO
