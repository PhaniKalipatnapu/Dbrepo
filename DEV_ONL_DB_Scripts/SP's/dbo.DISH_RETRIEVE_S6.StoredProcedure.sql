/****** Object:  StoredProcedure [dbo].[DISH_RETRIEVE_S6]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DISH_RETRIEVE_S6](
 @An_CasePayorMCI_IDNO NUMERIC(10, 0),
 @Ac_TypeHold_CODE     CHAR(1),
 @An_Sequence_NUMB     NUMERIC(11, 0) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : DISH_RETRIEVE_S6
  *     DESCRIPTION       : Retrieves Sequence Number for the Casepayormci idno, typehold code combination
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 22-SEP-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  SET @An_Sequence_NUMB = NULL;

  DECLARE @Lc_CaseRelationshipNcp_CODE       CHAR(1) = 'A',
          @Lc_CaseRelationshipPutFather_CODE CHAR(1) = 'P',
          @Lc_CaseMembeStatusrActive_CODE    CHAR(1) = 'A',
          @Lc_TypeHoldPostingCase_CODE       CHAR(1) = 'C',
          @Lc_TypeHoldPostingPayor_CODE      CHAR(1) = 'P';

  SELECT @An_Sequence_NUMB = (ISNULL (MAX (d.Sequence_NUMB), 0) + 1)
    FROM DISH_Y1 d
   WHERE ((CasePayorMCI_IDNO = @An_CasePayorMCI_IDNO)
       OR (@Ac_TypeHold_CODE = @Lc_TypeHoldPostingPayor_CODE
           AND CasePayorMCI_IDNO IN (SELECT a.Case_IDNO
                                       FROM CMEM_Y1 a
                                      WHERE a.MemberMci_IDNO = @An_CasePayorMCI_IDNO
                                        AND a.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE)
                                        AND a.CaseMemberStatus_CODE = @Lc_CaseMembeStatusrActive_CODE))
       OR (@Ac_TypeHold_CODE = @Lc_TypeHoldPostingCase_CODE
           AND d.CasePayorMCI_IDNO IN (SELECT c.MemberMci_IDNO
                                         FROM CMEM_Y1 c
                                        WHERE c.Case_IDNO = @An_CasePayorMCI_IDNO
                                          AND c.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE)
                                          AND c.CaseMemberStatus_CODE = @Lc_CaseMembeStatusrActive_CODE)));
 END; --End of DISH_RETRIEVE_S6

GO
