/****** Object:  StoredProcedure [dbo].[APMI_UPDATE_S1]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[APMI_UPDATE_S1](
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
 *     PROCEDURE NAME     : APMI_UPDATE_S1
  *     DESCRIPTION       : Updates the changed insurance value of a member.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 20-SEP-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ln_RowsAffected_NUMB NUMERIC(10);

  UPDATE APMI_Y1
     SET MedicalOthpIns_IDNO = @An_MedicalOthpIns_IDNO,
         MedicalPolicyInsNo_TEXT = @Ac_MedicalPolicyInsNo_TEXT,
         MedicalMonthlyPremium_AMNT = @An_MedicalMonthlyPremium_AMNT,
         DentalPolicyInsNo_TEXT = @Ac_DentalPolicyInsNo_TEXT,
         DentalOthpIns_IDNO = @An_DentalOthpIns_IDNO,
         DentalMonthlyPremium_AMNT = @An_DentalMonthlyPremium_AMNT
   WHERE Application_IDNO = @An_Application_IDNO
     AND MemberMci_IDNO = @An_MemberMci_IDNO;

  SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;

  SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB;
 END; -- End Of APMI_UPDATE_S1 

GO
