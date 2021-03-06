/****** Object:  StoredProcedure [dbo].[CMEM_RETRIEVE_S105]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CMEM_RETRIEVE_S105](
 @An_Case_IDNO  NUMERIC(6, 0),
 @Ai_Count_QNTY INT OUTPUT
 )
AS
 /*
 *     PROCEDURE NAME    : CMEM_RETRIEVE_S105
  *     DESCRIPTION       : Retrieve the record count for a Case ID, Members Case Relation is NCP and Putative Father, Case Member Status is Active and Locate Status is Located when Member ID is same in Case Member and Locate Status.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-NOV-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @Ai_Count_QNTY = 0;

  DECLARE @Lc_RelationshipCaseNcp_CODE       CHAR(1) = 'A',
          @Lc_RelationshipCasePutFather_CODE CHAR(1) = 'P',
          @Lc_StatusCaseMemberActive_CODE    CHAR(1) = 'A',
          @Ld_High_DATE                      DATE = '12/31/9999',
          @Lc_CdStatusLocated_CODE           CHAR(1) = 'L';

  SELECT @Ai_Count_QNTY = COUNT(1)
    FROM CMEM_Y1 C
         JOIN LSTT_Y1 L
          ON (C.MemberMci_IDNO = L.MemberMci_IDNO)
   WHERE C.Case_IDNO = @An_Case_IDNO
     AND C.CaseRelationship_CODE IN (@Lc_RelationshipCaseNcp_CODE, @Lc_RelationshipCasePutFather_CODE)
     AND C.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE
     AND L.StatusLocate_CODE = @Lc_CdStatusLocated_CODE
     AND L.EndValidity_DATE = @Ld_High_DATE;
 END; --End of CMEM_RETRIEVE_S105


GO
