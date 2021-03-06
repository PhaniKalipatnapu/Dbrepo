/****** Object:  StoredProcedure [dbo].[CMEM_RETRIEVE_S182]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CMEM_RETRIEVE_S182] (
 @An_Case_IDNO           NUMERIC(6, 0),
 @Ac_CheckRecipient_CODE CHAR(1) OUTPUT,
 @An_MemberMci_IDNO      NUMERIC(10, 0) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : CMEM_RETRIEVE_S182
  *     DESCRIPTION       : Retrieves the recipient for a given case.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 14-FEB-2012
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @Ac_CheckRecipient_CODE = NULL;
  SET @An_MemberMci_IDNO = NULL;

  DECLARE @Lc_RecipientTypeCpNcp_CODE      CHAR(1) = '1',
          @Lc_CpCaseRelationship_CODE CHAR(1) = 'C';

  SELECT TOP 1 @An_MemberMci_IDNO = X.MemberMci_IDNO,
               @Ac_CheckRecipient_CODE = @Lc_RecipientTypeCpNcp_CODE
    FROM (SELECT a.MemberMci_IDNO,
                 a.CaseMemberStatus_CODE,
                 ROW_NUMBER() OVER( ORDER BY a.CaseMemberStatus_CODE) AS ORD_ROWNUM
            FROM CMEM_Y1 a
           WHERE a.Case_IDNO = @An_Case_IDNO
             AND a.CaseRelationship_CODE = @Lc_CpCaseRelationship_CODE) X;
 END


GO
