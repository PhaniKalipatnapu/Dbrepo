/****** Object:  StoredProcedure [dbo].[APMI_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[APMI_RETRIEVE_S1](
 @An_Application_IDNO NUMERIC(15, 0),
 @An_MemberMci_IDNO   NUMERIC(10, 0)
 )
AS
 /*
 *     PROCEDURE NAME    : APMI_RETRIEVE_S1
 *     DESCRIPTION       : Retrieves the insurance details of the member.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 20-SEP-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
 */
 BEGIN
  SELECT A.MedicalOthpIns_IDNO,
         A.MedicalPolicyInsNo_TEXT,
         A.MedicalMonthlyPremium_AMNT,
         A.DentalPolicyInsNo_TEXT,
         A.DentalOthpIns_IDNO,
         A.DentalMonthlyPremium_AMNT
    FROM APMI_Y1 A
   WHERE A.Application_IDNO = @An_Application_IDNO
     AND A.MemberMci_IDNO = @An_MemberMci_IDNO;
 END; -- End Of  APMI_RETRIEVE_S1  

GO
