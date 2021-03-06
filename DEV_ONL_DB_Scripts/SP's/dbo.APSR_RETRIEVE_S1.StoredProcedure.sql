/****** Object:  StoredProcedure [dbo].[APSR_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[APSR_RETRIEVE_S1] (
 @An_Application_IDNO                 NUMERIC(15, 0),
 @An_MemberMci_IDNO                   NUMERIC(10, 0),
 @Ac_ChildSupportOrderExists_INDC     CHAR(1) OUTPUT,
 @Ac_SupportOrderedCourt_TEXT         CHAR(40) OUTPUT,
 @Ac_ChildSupportCounty_NAME          CHAR(40) OUTPUT,
 @Ac_ChildSupportState_CODE           CHAR(2) OUTPUT,
 @Ac_PaternityAcknowledgment_INDC     CHAR(1) OUTPUT,
 @Ac_PersonRepresentChildAsOwn_INDC   CHAR(1) OUTPUT,
 @An_ChildSupport_AMNT                NUMERIC(11, 2) OUTPUT,
 @Ac_ChildSupportPayingFrequency_CODE CHAR(1) OUTPUT,
 @Ad_ChildSupportEffective_DATE       DATE OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : APSR_RETRIEVE_S1
  *     DESCRIPTION       : Retrieve Member Financial Asset details for an Application ID and Member ID when Type of Asset is Bankruptcy.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 20-SEP-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SELECT @Ac_ChildSupportOrderExists_INDC = NULL,
         @Ac_SupportOrderedCourt_TEXT = NULL,
         @Ac_ChildSupportCounty_NAME = NULL,
         @Ac_ChildSupportState_CODE = NULL,
         @Ac_PaternityAcknowledgment_INDC = NULL,
         @Ac_PersonRepresentChildAsOwn_INDC = NULL,
         @An_ChildSupport_AMNT = NULL,
         @Ac_ChildSupportPayingFrequency_CODE = NULL,
         @Ad_ChildSupportEffective_DATE = NULL;

  SELECT @Ac_ChildSupportOrderExists_INDC = A.ChildSupportOrderExists_INDC,
         @Ac_SupportOrderedCourt_TEXT = A.SupportOrderedCourt_TEXT,
         @Ac_ChildSupportCounty_NAME = A.ChildSupportCounty_NAME,
         @Ac_ChildSupportState_CODE = A.ChildSupportState_CODE,
         @Ac_PaternityAcknowledgment_INDC = A.PaternityAcknowledgment_INDC,
         @Ac_PersonRepresentChildAsOwn_INDC = A.PersonRepresentChildAsOwn_INDC,
         @An_ChildSupport_AMNT = A.ChildSupport_AMNT,
         @Ac_ChildSupportPayingFrequency_CODE = A.ChildSupportPayingFrequency_CODE,
         @Ad_ChildSupportEffective_DATE = A.ChildSupportEffective_DATE
    FROM APSR_Y1 A
   WHERE A.Application_IDNO = @An_Application_IDNO
     AND A.MemberMci_IDNO = @An_MemberMci_IDNO;
 END; -- End Of APSR_RETRIEVE_S1 

GO
