/****** Object:  StoredProcedure [dbo].[RCTH_RETRIEVE_S96]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RCTH_RETRIEVE_S96] (
 @An_Case_IDNO            NUMERIC(6),
 @Ad_TransactionFrom_DATE DATE,
 @Ad_TransactionTo_DATE   DATE
 )
AS
 /*
  *     PROCEDURE NAME    : RCTH_RETRIEVE_S96
  *     DESCRIPTION       : Retrieves reason status, receipt number, distribute amount for the given case id.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 14-SEP-2011
  *     MODIFIED BY       :
  *     MODIFIED ON       :
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Li_Zero_NUMB                   SMALLINT	= 0,
          @Lc_RelationshipCaseNcp_CODE    CHAR(1)	= 'A',
          @Lc_StatusCaseMemberActive_CODE CHAR(1)	= 'A',
          @Lc_StatusReceiptHeld_CODE      CHAR(1)	= 'H',
          @Lc_TypePostingCase_CODE        CHAR(1)	= 'C',
          @Lc_TypePostingPayor_CODE       CHAR(1)	= 'P',
          @Ld_High_DATE                   DATE		= '12/31/9999',
          @Ld_Low_DATE                    DATE		= '01/01/0001';

  SELECT a.ReasonStatus_CODE,
         b.HoldLevel_CODE,
         a.Batch_DATE,
         a.SourceBatch_CODE,
         a.Batch_NUMB,
         a.SeqReceipt_NUMB,
         CASE a.TypePosting_CODE
          WHEN @Lc_TypePostingCase_CODE
           THEN a.Case_IDNO
          WHEN @Lc_TypePostingPayor_CODE
           THEN a.PayorMCI_IDNO
         END AS CaseDcn_IDNO,
         a.ToDistribute_AMNT
    FROM RCTH_Y1 a
         JOIN UCAT_Y1 b
          ON b.Udc_CODE = a.ReasonStatus_CODE
   WHERE a.PayorMCI_IDNO IN (SELECT x.MemberMci_IDNO
                               FROM CMEM_Y1 x
                              WHERE x.Case_IDNO = @An_Case_IDNO
                                AND x.CaseRelationship_CODE = @Lc_RelationshipCaseNcp_CODE
                                AND x.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE)
     AND a.Case_IDNO IN (@Li_Zero_NUMB, @An_Case_IDNO)
     AND a.Receipt_DATE BETWEEN @Ad_TransactionFrom_DATE AND @Ad_TransactionTo_DATE
     AND a.StatusReceipt_CODE = @Lc_StatusReceiptHeld_CODE
     AND a.EndValidity_DATE = @Ld_High_DATE
     AND a.Distribute_DATE = @Ld_Low_DATE
     AND b.EndValidity_DATE = @Ld_High_DATE
  UNION ALL
  SELECT a.ReasonStatus_CODE,
         b.HoldLevel_CODE,
         a.Batch_DATE,
         a.SourceBatch_CODE,
         a.Batch_NUMB,
         a.SeqReceipt_NUMB,
         a.Case_IDNO AS CaseDcn_IDNO,
         SUM(a.Transaction_AMNT) AS Receipt_AMNT
    FROM DHLD_Y1 a
         JOIN UCAT_Y1 b
          ON b.Udc_CODE = a.ReasonStatus_CODE
   WHERE a.Case_IDNO = @An_Case_IDNO
     AND a.Transaction_DATE BETWEEN @Ad_TransactionFrom_DATE AND @Ad_TransactionTo_DATE
     AND a.Status_CODE = @Lc_StatusReceiptHeld_CODE
     AND a.EndValidity_DATE = @Ld_High_DATE
     AND b.EndValidity_DATE = @Ld_High_DATE
   GROUP BY a.ReasonStatus_CODE,
            b.HoldLevel_CODE,
            a.Batch_DATE,
            a.SourceBatch_CODE,
            a.Batch_NUMB,
            a.SeqReceipt_NUMB,
            a.Case_IDNO;
 END; --End of RCTH_RETRIEVE_S96


GO
