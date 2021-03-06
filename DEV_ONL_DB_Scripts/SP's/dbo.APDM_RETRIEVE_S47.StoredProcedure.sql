/****** Object:  StoredProcedure [dbo].[APDM_RETRIEVE_S47]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[APDM_RETRIEVE_S47] (
 @An_Application_IDNO      NUMERIC(15, 0),
 @An_MemberMci_IDNO        NUMERIC(10, 0),
 @Ac_CaseRelationship_CODE CHAR(1),
 @Ac_First_NAME            CHAR(16) OUTPUT,
 @Ac_Last_NAME             CHAR(20) OUTPUT,
 @Ac_Middle_NAME           CHAR(20) OUTPUT,
 @Ac_Suffix_NAME           CHAR(4) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : APDM_RETRIEVE_S47
   *     DESCRIPTION       : Retrieve Referred to Locate Indicator for an Application ID and Member Type is NCP when Application ID & Member ID is same in Member Demographics and Case Member at the time of Application Received.
   *     DEVELOPED BY      : IMP Team
   *     DEVELOPED ON      : 02-NOV-2011
   *     MODIFIED BY       : 
   *     MODIFIED ON       : 
   *     VERSION NO        : 1
  */
 BEGIN
  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT @Ac_Last_NAME = Last_NAME,
         @Ac_First_NAME = First_NAME,
         @Ac_Middle_NAME = Middle_NAME,
         @Ac_Suffix_NAME = Suffix_NAME
    FROM APDM_Y1 a
         JOIN APCM_Y1 b
          ON (a.MemberMci_IDNO = b.MemberMci_IDNO
              AND a.Application_IDNO = b.Application_IDNO)
   WHERE b.CaseRelationship_CODE = ISNULL(@Ac_CaseRelationship_CODE, b.CaseRelationship_CODE)
     AND b.Application_IDNO = ISNULL(@An_Application_IDNO, b.Application_IDNO)
     AND a.MemberMci_IDNO = ISNULL(@An_MemberMci_IDNO, b.MemberMci_IDNO)
     AND a.EndValidity_DATE = @Ld_High_DATE
     AND b.EndValidity_DATE = @Ld_High_DATE;
 END; -- End Of APDM_RETRIEVE_S47

GO
