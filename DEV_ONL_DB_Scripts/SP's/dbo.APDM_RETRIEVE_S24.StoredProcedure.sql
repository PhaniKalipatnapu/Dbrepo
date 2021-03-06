/****** Object:  StoredProcedure [dbo].[APDM_RETRIEVE_S24]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[APDM_RETRIEVE_S24](
 @An_Application_IDNO NUMERIC(15, 0),
 @Ai_Count_QNTY       INT OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : APDM_RETRIEVE_S24
  *     DESCRIPTION       : Retrieve the record count for an Application ID, Member Type is Dependent, Paternity Acknowledged is No when Application ID and Member ID is same in member demographics and case member at the time of application receiveA.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 28-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @Ai_Count_QNTY = NULL;

  DECLARE @Lc_No_INDC                 CHAR(1) = 'N',
          @Lc_RelationshipCaseDp_CODE CHAR(1) = 'D',
          @Ld_High_DATE               DATE = '12/31/9999';

  SELECT @Ai_Count_QNTY = COUNT(1)
    FROM APDM_Y1 A
         JOIN APCM_Y1 A1
          ON (A.MemberMci_IDNO = A1.MemberMci_IDNO
              AND A.Application_IDNO = A1.Application_IDNO)
   WHERE A.Application_IDNO = @An_Application_IDNO
     AND A.EndValidity_DATE = @Ld_High_DATE
     AND A1.EndValidity_DATE = @Ld_High_DATE
     AND A.PaternityEst_INDC = @Lc_No_INDC
     AND A1.CaseRelationship_CODE = @Lc_RelationshipCaseDp_CODE;
 END; -- End Of APDM_RETRIEVE_S24

GO
