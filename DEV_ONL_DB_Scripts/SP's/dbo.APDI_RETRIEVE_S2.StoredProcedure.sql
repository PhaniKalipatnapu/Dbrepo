/****** Object:  StoredProcedure [dbo].[APDI_RETRIEVE_S2]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[APDI_RETRIEVE_S2](
 @An_Application_IDNO  NUMERIC(15, 0),
 @An_MemberMci_IDNO    NUMERIC(10),
 @An_DependantMci_IDNO NUMERIC(10),
 @Ac_MedicalIns_INDC   CHAR(1) OUTPUT,
 @Ac_DentalIns_INDC    CHAR(1) OUTPUT
 )
AS
 /*      
  *     PROCEDURE NAME    : APDI_RETRIEVE_S2      
  *     DESCRIPTION       : Retrieves the medicaid and insurance details for the respective application and member.
  *     DEVELOPED BY      : IMP Team      
  *     DEVELOPED ON      : 3-FEB-2012      
  *     MODIFIED BY       :       
  *     MODIFIED ON       :       
  *     VERSION NO        : 1      
 */
 BEGIN
  SELECT @Ac_MedicalIns_INDC = MedicalIns_INDC,
         @Ac_DentalIns_INDC = DentalIns_INDC
    FROM APDI_Y1 A
   WHERE A.Application_IDNO = @An_Application_IDNO
     AND A.MemberMCI_IDNO = @An_MemberMci_IDNO
     AND A.DependantMci_IDNO = @An_DependantMci_IDNO;
 END; -- End Of APDI_RETRIEVE_S2

GO
