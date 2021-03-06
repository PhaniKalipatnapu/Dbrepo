/****** Object:  StoredProcedure [dbo].[APSR_UPDATE_S2]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[APSR_UPDATE_S2] (
 @An_Application_IDNO                 NUMERIC(15, 0),
 @An_MemberMci_IDNO                   NUMERIC(10, 0),
 @An_MemberMciKey_IDNO                NUMERIC(10, 0),
 @Ac_ChildSupportOrderExists_INDC     CHAR(1),
 @Ac_SupportOrderedCourt_TEXT         CHAR(40),
 @Ac_ChildSupportCounty_NAME          CHAR(40),
 @Ac_ChildSupportState_CODE           CHAR(2),
 @Ac_PaternityAcknowledgment_INDC     CHAR(1),
 @Ac_PersonRepresentChildAsOwn_INDC   CHAR(1),
 @An_ChildSupport_AMNT                NUMERIC(11, 2),
 @Ac_ChildSupportPayingFrequency_CODE CHAR(1),
 @Ad_ChildSupportEffective_DATE       DATE
 )
AS
 /*
  *     PROCEDURE NAME    : APSR_UPDATE_S2
  *     DESCRIPTION       : Retrieve Member Financial Asset details for an Application ID and Member ID when Type of Asset is Bankruptcy.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 20-SEP-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ln_RowsAffected_NUMB NUMERIC(10);

  UPDATE APSR_Y1
     SET MemberMci_IDNO = @An_MemberMci_IDNO,
         ChildSupportOrderExists_INDC = @Ac_ChildSupportOrderExists_INDC,
         SupportOrderedCourt_TEXT = @Ac_SupportOrderedCourt_TEXT,
         ChildSupportCounty_NAME = @Ac_ChildSupportCounty_NAME,
         ChildSupportState_CODE = @Ac_ChildSupportState_CODE,
         PaternityAcknowledgment_INDC = @Ac_PaternityAcknowledgment_INDC,
         PersonRepresentChildAsOwn_INDC = @Ac_PersonRepresentChildAsOwn_INDC,
         ChildSupport_AMNT = @An_ChildSupport_AMNT,
         ChildSupportPayingFrequency_CODE = @Ac_ChildSupportPayingFrequency_CODE,
         ChildSupportEffective_DATE = @Ad_ChildSupportEffective_DATE
   WHERE Application_IDNO = @An_Application_IDNO
     AND MemberMci_IDNO = @An_MemberMciKey_IDNO;

  SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;

  SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB;
 END; -- End Of APSR_UPDATE_S2

GO
