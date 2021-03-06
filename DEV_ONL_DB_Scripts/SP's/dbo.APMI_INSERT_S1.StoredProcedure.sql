/****** Object:  StoredProcedure [dbo].[APMI_INSERT_S1]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[APMI_INSERT_S1](
 @An_Application_IDNO           NUMERIC(15, 0),
 @An_MemberMci_IDNO             NUMERIC(10, 0),
 @An_MedicalOthpIns_IDNO        NUMERIC(9, 0),
 @Ac_MedicalPolicyInsNo_TEXT    CHAR(20),
 @An_MedicalMonthlyPremium_AMNT NUMERIC(11, 2),
 @Ac_DentalPolicyInsNo_TEXT     CHAR(20),
 @An_DentalOthpIns_IDNO         NUMERIC(9, 0),
 @An_DentalMonthlyPremium_AMNT  NUMERIC(11, 2)
 )
AS
 /*
  *     PROCEDURE NAME    : APMI_INSERT_S1
  *     DESCRIPTION       : Inserts the insurance details of the member.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 20-SEP-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  INSERT INTO APMI_Y1
              (Application_IDNO,
               MemberMci_IDNO,
               MedicalOthpIns_IDNO,
               MedicalPolicyInsNo_TEXT,
               MedicalMonthlyPremium_AMNT,
               DentalPolicyInsNo_TEXT,
               DentalOthpIns_IDNO,
               DentalMonthlyPremium_AMNT)
       VALUES ( @An_Application_IDNO,
                @An_MemberMci_IDNO,
                @An_MedicalOthpIns_IDNO,
                @Ac_MedicalPolicyInsNo_TEXT,
                @An_MedicalMonthlyPremium_AMNT,
                @Ac_DentalPolicyInsNo_TEXT,
                @An_DentalOthpIns_IDNO,
                @An_DentalMonthlyPremium_AMNT );
 END; -- End Of APMI_INSERT_S1              

GO
