/****** Object:  StoredProcedure [dbo].[APSR_INSERT_S1]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[APSR_INSERT_S1] (
 @An_Application_IDNO                 NUMERIC(15, 0),
 @An_MemberMci_IDNO                   NUMERIC(10, 0),
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
 *     PROCEDURE NAME    :APSR_INSERT_S1
  *     DESCRIPTION       : Retrieve Member Financial Asset details for an Application ID and Member ID when Type of Asset is Bankruptcy.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-NOV-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  INSERT APSR_Y1
         (Application_IDNO,
          MemberMci_IDNO,
          ChildSupportOrderExists_INDC,
          SupportOrderedCourt_TEXT,
          ChildSupportCounty_NAME,
          ChildSupportState_CODE,
          ChildSupport_AMNT,
          ChildSupportPayingFrequency_CODE,
          ChildSupportEffective_DATE,
          PaternityAcknowledgment_INDC,
          PersonRepresentChildAsOwn_INDC)
  VALUES (@An_Application_IDNO,
          @An_MemberMci_IDNO,
          @Ac_ChildSupportOrderExists_INDC,
          @Ac_SupportOrderedCourt_TEXT,
          @Ac_ChildSupportCounty_NAME,
          @Ac_ChildSupportState_CODE,
          @An_ChildSupport_AMNT,
          @Ac_ChildSupportPayingFrequency_CODE,
          @Ad_ChildSupportEffective_DATE,
          @Ac_PaternityAcknowledgment_INDC,
          @Ac_PersonRepresentChildAsOwn_INDC);
 END; -- End Of APSR_INSERT_S1

GO
