/****** Object:  StoredProcedure [dbo].[DISH_RETRIEVE_S3]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DISH_RETRIEVE_S3] (
 @An_CasePayorMCI_IDNO NUMERIC(10, 0),
 @Ad_Run_DATE          DATE
 )
AS
 /*
  *     PROCEDURE NAME    : DISH_RETRIEVE_S3
  *     DESCRIPTION       : Retrieves the didtribution hold instructions.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 20-SEP-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  DECLARE @Lc_CaseRelationshipNcp_CODE       CHAR(1) = 'A',
          @Lc_CaseRelationshipPutFather_CODE CHAR(1) = 'P',
          @Lc_CaseMemberStatusActive_CODE    CHAR(1) = 'A',
          @Ld_High_DATE                      DATE = '12/31/9999';

  SELECT X.CasePayorMCI_IDNO,
         X.TypeHold_CODE,
         X.ReasonHold_CODE,
         X.Expiration_DATE
    FROM (SELECT TOP (100) PERCENT d.CasePayorMCI_IDNO,
                                   d.TypeHold_CODE,
                                   d.SourceHold_CODE,
                                   d.ReasonHold_CODE,
                                   d.Effective_DATE,
                                   d.Expiration_DATE,
                                   d.Sequence_NUMB,
                                   d.EventGlobalBeginSeq_NUMB,
                                   d.EventGlobalEndSeq_NUMB,
                                   d.BeginValidity_DATE,
                                   d.EndValidity_DATE
            FROM DISH_Y1 d
           WHERE (d.CasePayorMCI_IDNO = @An_CasePayorMCI_IDNO
                   OR d.CasePayorMCI_IDNO IN (SELECT c.Case_IDNO
                                                FROM CMEM_Y1 c
                                               WHERE c.MemberMci_IDNO = @An_CasePayorMCI_IDNO
                                                 AND c.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE)
                                                 AND c.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE))
             AND d.Effective_DATE <= @Ad_Run_DATE
             AND d.Expiration_DATE > @Ad_Run_DATE
             AND d.EndValidity_DATE = @Ld_High_DATE
           ORDER BY d.TypeHold_CODE,
                    d.Expiration_DATE DESC) AS X;
 END; --End of DISH_RETRIEVE_S3

GO
