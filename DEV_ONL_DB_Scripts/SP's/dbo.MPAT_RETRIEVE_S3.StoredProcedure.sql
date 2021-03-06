/****** Object:  StoredProcedure [dbo].[MPAT_RETRIEVE_S3]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[MPAT_RETRIEVE_S3] (
 @An_Case_IDNO  NUMERIC(6, 0),
 @Ai_Count_QNTY INT OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : MPAT_RETRIEVE_S3
  *     DESCRIPTION       : Retrieve the count of records from Member Demographics table and Case Members table for each retrieved Case whose Dependant (D) Member is Active in Case Members table with Paternity NOT been Acknowledged in Member Demographics table and do not have a valid obligation for the retrieved Case in Obligation table with obligation amount to be collected for a given time period greater than 0 and effective End date for the obligation greater than Current Date.
  *     DEVELOPED BY      : IMP Team  
  *     DEVELOPED ON      : 08-SEP-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @Ai_Count_QNTY = NULL;

  DECLARE @Lc_CaseRelationshipDp_CODE     CHAR(1) = 'D',
          @Lc_CaseRelationshipNcp_CODE    CHAR(1) = 'A',
          @Lc_CaseMemberStatusActive_CODE CHAR(1) = 'A',
          @Lc_MemberSexM_CODE             CHAR(1) = 'M',
          @Lc_PaternityEstN_INDC          CHAR(1) = 'N',
          @Ld_High_DATE                   DATE = '12/31/9999';

  SELECT @Ai_Count_QNTY = COUNT(1)
    FROM MPAT_Y1 D
         JOIN CMEM_Y1 C
          ON D.MemberMci_IDNO = C.MemberMci_IDNO
   WHERE C.Case_IDNO = @An_Case_IDNO
     AND D.PaternityEst_INDC = @Lc_PaternityEstN_INDC
     AND C.CaseRelationship_CODE = @Lc_CaseRelationshipDp_CODE
     AND C.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
     AND NOT EXISTS (SELECT 1
                       FROM SORD_Y1 S
                      WHERE S.Case_IDNO = C.Case_IDNO
                        AND S.EndValidity_DATE = @Ld_High_DATE)
     AND EXISTS (SELECT 1
                   FROM DEMO_Y1 D1
                  WHERE D1.MemberMci_IDNO IN(SELECT MemberMci_IDNO
                                               FROM CMEM_Y1 C1
                                              WHERE C1.case_idno = C.Case_IDNO
                                                AND C1.CaseRelationship_CODE = @Lc_CaseRelationshipNcp_CODE)
                    AND D1.MemberSex_CODE = @Lc_MemberSexM_CODE);
 END; -- END OF MPAT_RETRIEVE_S3


GO
