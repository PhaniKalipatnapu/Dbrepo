/****** Object:  StoredProcedure [dbo].[APCS_RETRIEVE_S21]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[APCS_RETRIEVE_S21](
 @An_Application_IDNO NUMERIC(15),
 @Ai_Count_QNTY       INT OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : APCS_RETRIEVE_S21
  *     DESCRIPTION       : gets the record count for the input application id where Member Type is Custodial Parent, Member id is 'F9999999'  and enddate validity is highdate.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-NOV-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @Ai_Count_QNTY = NULL;

  DECLARE @Lc_CaseRelationshipCp_CODE  CHAR(1) = 'C',
          @Ld_High_DATE                DATE = '12/31/9999',
          @Ln_FosterCaseMemberMci_IDNO NUMERIC(10) = 999998;

  SELECT @Ai_Count_QNTY = COUNT(1)
    FROM APCS_Y1 C
         JOIN APCM_Y1 M
          ON c.Application_IDNO = m.Application_IDNO
   WHERE c.Application_IDNO = @An_Application_IDNO
     AND c.EndValidity_DATE = @Ld_High_DATE
     AND m.EndValidity_DATE = @Ld_High_DATE
     AND m.CaseRelationship_CODE = @Lc_CaseRelationshipCp_CODE
     AND m.MemberMci_IDNO = @Ln_FosterCaseMemberMci_IDNO;
 END; --End of APCS_RETRIEVE_S21

GO
