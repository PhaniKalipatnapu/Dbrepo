/****** Object:  StoredProcedure [dbo].[APDI_UPDATE_S1]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[APDI_UPDATE_S1](
 @An_Application_IDNO  NUMERIC(15, 0),
 @An_MemberMci_IDNO    NUMERIC(10),
 @An_DependantMci_IDNO NUMERIC(10),
 @Ac_MedicalIns_INDC   CHAR(1),
 @Ac_DentalIns_INDC    CHAR(1)
 )
AS
 /*      
  *     PROCEDURE NAME    : APDI_UPDATE_S1      
  *     DESCRIPTION       : Retrieves the medicaid and insurance details for the respective application and member.
  *     DEVELOPED BY      : IMP Team      
  *     DEVELOPED ON      : 3-FEB-2012      
  *     MODIFIED BY       :       
  *     MODIFIED ON       :       
  *     VERSION NO        : 1      
 */
 BEGIN
  DECLARE @Li_RowsAffected_NUMB INT;

  UPDATE APDI_Y1
     SET MedicalIns_INDC = @Ac_MedicalIns_INDC,
         DentalIns_INDC = @Ac_DentalIns_INDC
   WHERE Application_IDNO = @An_Application_IDNO
     AND MemberMci_IDNO = @An_MemberMci_IDNO
     AND DependantMci_IDNO = @An_DependantMci_IDNO;

  SET @Li_RowsAffected_NUMB = @@ROWCOUNT;

  SELECT @Li_RowsAffected_NUMB AS RowsAffected_NUMB;
 END; -- End Of APDI_UPDATE_S1

GO
