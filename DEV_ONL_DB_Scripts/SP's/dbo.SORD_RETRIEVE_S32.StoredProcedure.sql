/****** Object:  StoredProcedure [dbo].[SORD_RETRIEVE_S32]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SORD_RETRIEVE_S32] (
 @An_MemberMci_IDNO        NUMERIC(10, 0),
 @Ac_CaseRelationship_CODE CHAR(1)
 )
AS
 /*
  *     PROCEDURE NAME    : SORD_RETRIEVE_S32
  *     DESCRIPTION       : This procedure is used to return the order information that to be display in grid at member level.
  *     DEVELOPED BY      : IMP Team 
  *     DEVELOPED ON      : 20-DEC-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Li_Zero_NUMB                      SMALLINT = 0,
          @Lc_RelationshipCaseCp_CODE        CHAR(1) = 'C',
          @Lc_RelationshipCaseNcp_CODE       CHAR(1) = 'A',
          @Lc_RelationshipCasePutFather_CODE CHAR(1) = 'P',
          @Lc_CaseLevel_CODE                 CHAR(1) = 'C',
          @Lc_StatusCaseMemberActive_CODE    CHAR(1) = 'A',
          @Ld_High_DATE                      DATE = '12/31/9999';

  SELECT a.Case_IDNO,
         a.File_ID,
         a.SourceOrdered_CODE,
         a.TypeOrder_CODE,
         a.OrderEffective_DATE,
         a.OrderEnd_DATE,
         a.OrderIssued_DATE,
         DBO.BATCH_COMMON$SF_GET_PAYBACK_AMNT(a.Case_IDNO, a.OrderSeq_NUMB) AS Payback_AMNT,
         DBO.BATCH_COMMON$SF_GET_OBLEARREARS(a.Case_IDNO, a.OrderSeq_NUMB, @Li_Zero_NUMB, NULL, @Lc_CaseLevel_CODE, NULL) AS TotalBal_AMNT,
         a.OrderSeq_NUMB
    FROM CMEM_Y1 c
         JOIN SORD_Y1 a
          ON a.Case_IDNO = c.Case_IDNO
   WHERE c.MemberMci_IDNO = @An_MemberMci_IDNO
     AND ((@Ac_CaseRelationship_CODE = @Lc_RelationshipCaseCp_CODE
           AND c.CaseRelationship_CODE = @Lc_RelationshipCaseCp_CODE)
           OR (@Ac_CaseRelationship_CODE = @Lc_RelationshipCaseNcp_CODE
               AND c.CaseRelationship_CODE IN (@Lc_RelationshipCaseNcp_CODE, @Lc_RelationshipCasePutFather_CODE)))
     AND c.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE
     AND a.EndValidity_DATE = @Ld_High_DATE
   ORDER BY Case_IDNO ASC;
 END; --End of  SORD_RETRIEVE_S32

GO
