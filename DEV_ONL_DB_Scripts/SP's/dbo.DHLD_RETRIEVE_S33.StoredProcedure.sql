/****** Object:  StoredProcedure [dbo].[DHLD_RETRIEVE_S33]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DHLD_RETRIEVE_S33](
 @An_Case_IDNO           NUMERIC(6, 0),
 @Ac_CheckRecipient_ID   CHAR(10),
 @Ac_CheckRecipient_CODE CHAR(1),
 @Ac_ReasonStatus_CODE   CHAR(4),
 @Ai_RowFrom_NUMB        INT = 1,
 @Ai_RowTo_NUMB          INT = 10
 )
AS
 /*  
 *     PROCEDURE NAME    : DHLD_RETRIEVE_S33  
 *     DESCRIPTION       : Retrieves the Disbursement hold details for the given recipient id
 *     DEVELOPED BY      : IMP Team  
 *     DEVELOPED ON      : 02-AUG-2011  
 *     MODIFIED BY       :   
 *     MODIFIED ON       :   
 *     VERSION NO        : 1  
 */
 BEGIN
  DECLARE @Lc_CaseRelationCp_CODE          CHAR(1) = 'C',
          @Lc_CaseRelationNcp_CODE         CHAR(1) = 'A',
          @Lc_CaseRelationPutFather_CODE   CHAR(1) = 'P',
          @Lc_CaseMemberrStatusActive_CODE CHAR(1) = 'A',
          @Ld_High_DATE                    DATE = '12/31/9999',
          @Lc_StatusR_CODE                 CHAR(1)='R',
          @Li_Zero_NUMB                    SMALLINT = 0,
          @Li_One_NUMB                     SMALLINT=1,
          @Ld_Current_DATE                 DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

  SELECT b.Case_IDNO,
         b.OrderSeq_NUMB,
         b.ObligationSeq_NUMB,
         b.Transaction_DATE,
         b.Release_DATE,
         b.TypeDisburse_CODE,
         b.Transaction_AMNT,
         b.TransactionTotal_AMNT,
         b.TypeHold_CODE,
         b.CheckRecipient_ID,
         b.CheckRecipient_CODE,
         b.ReasonStatus_CODE,
         b.Unique_IDNO,
         b.EventGlobalSupportSeq_NUMB,
         b.EventGlobalBeginSeq_NUMB,
         b.Batch_DATE,
         b.SourceBatch_CODE,
         b.Batch_NUMB,
         b.SeqReceipt_NUMB,
         dbo.BATCH_COMMON$SF_GET_RECIPIENT_NAME(b.CheckRecipient_ID, b.CheckRecipient_CODE) AS RecipientName_TEXT,
         dbo.BATCH_COMMON_GETS$SF_GET_CHECK_NUM(b.CheckRecipient_ID, b.CheckRecipient_CODE, b.Disburse_DATE, b.DisburseSeq_NUMB) AS CheckNo_TEXT,
         ISNULL((SELECT TOP 1 C.MemberMci_IDNO
                   FROM CMEM_Y1 C
                  WHERE C.Case_IDNO = b.Case_IDNO
                    AND C.CaseRelationship_CODE = @Lc_CaseRelationCp_CODE
                    AND C.CaseMemberStatus_CODE = @Lc_CaseMemberrStatusActive_CODE), @Li_Zero_NUMB) CpMemberMci_IDNO,
         (SELECT G.Worker_ID
            FROM GLEV_Y1 G
           WHERE G.EventGlobalSeq_NUMB = b.EventGlobalBeginSeq_NUMB)Worker_ID,
         (SELECT G.Process_ID
            FROM GLEV_Y1 G
           WHERE G.EventGlobalSeq_NUMB = b.EventGlobalBeginSeq_NUMB) Process_ID,
         (SELECT TOP 1 MemberMci_IDNO
            FROM(SELECT o.MemberMci_IDNO,
                        ROW_NUMBER() OVER(ORDER BY b.Case_IDNO) row_num
                   FROM OBLE_Y1 o
                  WHERE o.Case_IDNO = b.Case_IDNO
                    AND o.OrderSeq_NUMB = b.OrderSeq_NUMB
                    AND o.ObligationSeq_NUMB = b.ObligationSeq_NUMB
                    AND o.EndValidity_DATE = @Ld_High_DATE)a
           WHERE row_num = @Li_One_NUMB) ObligeeMCI_IDNO,
         (SELECT TypeDebt_CODE
            FROM (SELECT TOP 1 o.TypeDebt_CODE,
                               ROW_NUMBER() OVER(ORDER BY b.Case_IDNO) Row_num
                    FROM OBLE_Y1 o
                   WHERE o.Case_IDNO = b.Case_IDNO
                     AND o.OrderSeq_NUMB = b.OrderSeq_NUMB
                     AND o.ObligationSeq_NUMB = b.ObligationSeq_NUMB
                     AND o.EndValidity_DATE = @Ld_High_DATE)a
           WHERE Row_num = @Li_One_NUMB) TypeDebt_CODE,
         (SELECT Fips_CODE
            FROM (SELECT TOP 1 o.Fips_CODE,
                               ROW_NUMBER() OVER(ORDER BY Case_IDNO) AS row_num
                    FROM OBLE_Y1 o
                   WHERE o.Case_IDNO = b.Case_IDNO
                     AND o.OrderSeq_NUMB = b.OrderSeq_NUMB
                     AND o.ObligationSeq_NUMB = b.ObligationSeq_NUMB
                     AND o.EndValidity_DATE = @Ld_High_DATE) a
           WHERE row_num = @Li_One_NUMB) Fips_CODE,
         b.Disburse_DATE,
         b.DisburseSeq_NUMB,
         D.Last_NAME,
         D.Suffix_NAME,
         D.First_NAME,
         D.Middle_NAME,
         RowCount_NUMB
    FROM(SELECT k.Transaction_DATE,
                k.TypeHold_CODE,
                k.Batch_DATE,
                k.SourceBatch_CODE,
                k.Batch_NUMB,
                k.SeqReceipt_NUMB,
                k.Case_IDNO,
                k.CheckRecipient_ID,
                k.CheckRecipient_CODE,
                k.Transaction_AMNT,
                k.TransactionTotal_AMNT,
                k.TypeDisburse_CODE,
                k.OrderSeq_NUMB,
                k.ObligationSeq_NUMB,
                k.Release_DATE,
                k.EventGlobalBeginSeq_NUMB,
                k.EventGlobalSupportSeq_NUMB,
                k.ReasonStatus_CODE,
                k.Unique_IDNO,
                k.Disburse_DATE,
                k.DisburseSeq_NUMB,
                row_num,
                RowCount_NUMB
           FROM(SELECT a.Transaction_DATE,
                       a.TypeHold_CODE,
                       a.Batch_DATE,
                       a.SourceBatch_CODE,
                       a.Batch_NUMB,
                       a.SeqReceipt_NUMB,
                       a.Case_IDNO,
                       a.CheckRecipient_ID,
                       a.CheckRecipient_CODE,
                       a.Transaction_AMNT,
                       SUM(a.Transaction_AMNT) OVER() AS TransactionTotal_AMNT,
                       a.TypeDisburse_CODE,
                       a.OrderSeq_NUMB,
                       a.ObligationSeq_NUMB,
                       a.Release_DATE,
                       a.EventGlobalBeginSeq_NUMB,
                       a.EventGlobalSupportSeq_NUMB,
                       a.ReasonStatus_CODE,
                       a.Unique_IDNO,
                       a.Disburse_DATE,
                       a.DisburseSeq_NUMB,
                       ROW_NUMBER() OVER(ORDER BY Transaction_DATE) row_num,
                       COUNT(1) OVER() RowCount_NUMB
                  FROM DHLD_Y1 a
                 WHERE a.CheckRecipient_ID = ISNULL(@Ac_CheckRecipient_ID, a.CheckRecipient_ID)
                   AND a.CheckRecipient_CODE = ISNULL(@Ac_CheckRecipient_CODE, a.CheckRecipient_CODE)
                   AND a.Status_CODE = @Lc_StatusR_CODE
                   AND a.Case_IDNO = ISNULL(@An_Case_IDNO, a.Case_IDNO)
                   AND a.ReasonStatus_CODE = ISNULL(@Ac_ReasonStatus_CODE, a.ReasonStatus_CODE)
                   AND a.EndValidity_DATE = @Ld_High_DATE
                   AND a.Transaction_DATE <= DATEADD(D, @Li_One_NUMB, @Ld_Current_DATE))k
          WHERE row_num <= @Ai_RowTo_NUMB)b
        LEFT OUTER JOIN DEMO_Y1 D
         ON D.MemberMci_IDNO = (SELECT TOP 1 CM.MemberMci_IDNO
                                  FROM CMEM_Y1 CM
                                 WHERE CM.Case_IDNO = b.Case_IDNO
                                   AND CM.CaseRelationship_CODE IN (@Lc_CaseRelationNcp_CODE, @Lc_CaseRelationPutFather_CODE)
                                   AND CM.CaseMemberStatus_CODE = @Lc_CaseMemberrStatusActive_CODE)
   WHERE row_num >= @Ai_RowFrom_NUMB;
 END; --End of DHLD_RETRIEVE_S33 

GO
