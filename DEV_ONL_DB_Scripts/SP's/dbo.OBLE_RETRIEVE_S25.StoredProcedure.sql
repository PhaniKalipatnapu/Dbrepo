/****** Object:  StoredProcedure [dbo].[OBLE_RETRIEVE_S25]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[OBLE_RETRIEVE_S25] (
 @An_Case_IDNO NUMERIC(6, 0)
 )
AS
 /*  
  *     PROCEDURE NAME    : OBLE_RETRIEVE_S25  
  *     DESCRIPTION       : Retrieve Members Obligation Details for a given Case.  
  *     DEVELOPED BY      : IMP Team  
  *     DEVELOPED ON      : 02-AUG-2011  
  *     MODIFIED BY       :   
  *     MODIFIED ON       :   
  *     VERSION NO        : 1  
 */
 BEGIN
  DECLARE @Ld_High_DATE               DATE = '12/31/9999',
          @Lc_CaseRelationshipCp_CODE CHAR(1) = 'C',
          @Lc_CaseRelationshipDp_CODE CHAR(1) = 'D';

  SELECT A.Last_NAME,
         A.First_NAME,
         A.Middle_NAME,
         A.Suffix_NAME,
         B.CaseRelationship_CODE,
         C.BeginObligation_DATE,
         C.TypeDebt_CODE,
         C.FreqPeriodic_CODE,
         C.Periodic_AMNT,
         C.EndObligation_DATE
    FROM DEMO_Y1 A
         JOIN CMEM_Y1 B
          ON B.MemberMci_IDNO = A.MemberMci_IDNO
         JOIN OBLE_Y1 C
          ON C.Case_IDNO = B.Case_IDNO
             AND B.MemberMci_IDNO = C.MemberMci_IDNO
         JOIN SORD_Y1 D
          ON D.Case_IDNO = C.Case_IDNO
             AND C.OrderSeq_NUMB = D.OrderSeq_NUMB
   WHERE B.Case_IDNO = @An_Case_IDNO
     AND ((B.CaseRelationship_CODE = @Lc_CaseRelationshipCp_CODE)
           OR (B.CaseRelationship_CODE = @Lc_CaseRelationshipDp_CODE))
     AND C.EndValidity_DATE = @Ld_High_DATE
     AND D.EndValidity_DATE = @Ld_High_DATE;
 END; --End of OBLE_RETRIEVE_S25  

GO
