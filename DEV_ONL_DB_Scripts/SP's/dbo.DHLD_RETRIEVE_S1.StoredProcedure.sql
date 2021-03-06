/****** Object:  StoredProcedure [dbo].[DHLD_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DHLD_RETRIEVE_S1] (
 @An_Case_IDNO           NUMERIC(6, 0),
 @Ad_Transaction_DATE    DATE,
 @Ac_CheckRecipient_ID   CHAR(10),
 @Ac_CheckRecipient_CODE CHAR(1),
 @Ac_ReasonStatus_CODE   CHAR(4),
 @Ai_RowFrom_NUMB        INT=1,
 @Ai_RowTo_NUMB          INT=10
 )
AS
 /*  
 *     PROCEDURE NAME    : DHLD_RETRIEVE_S1  
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
          @Lc_ReasonStatus_CODE            CHAR(4)='DO',
          @Lc_StatusH_CODE                 CHAR(1)='H',
          @Lc_DisbursementTypeL_CODE       CHAR(1)='L';

  SELECT X.Case_IDNO,
         X.OrderSeq_NUMB,
         X.ObligationSeq_NUMB,
         X.Transaction_DATE,
         X.Release_DATE,
         X.TypeDisburse_CODE,
         X.Transaction_AMNT,
         X.TransactionTotal_AMNT,
         X.TypeHold_CODE,
         X.CheckRecipient_ID,
         X.CheckRecipient_CODE,
         X.Unique_IDNO,
         X.EventGlobalSupportSeq_NUMB,
         X.EventGlobalBeginSeq_NUMB,
         X.Batch_DATE,
         X.SourceBatch_CODE,
         X.Batch_NUMB,
         X.SeqReceipt_NUMB,
         dbo.BATCH_COMMON_GETS$SF_GET_CHECK_NUM(X.CheckRecipient_ID, X.CheckRecipient_CODE, X.Disburse_DATE, X.DisburseSeq_NUMB) AS CheckNo_TEXT,
         dbo.BATCH_COMMON$SF_GET_RECIPIENT_NAME(X.CheckRecipient_ID, X.CheckRecipient_CODE) AS RecipientName_TEXT,
         X.Disburse_DATE,
         X.DisburseSeq_NUMB,
         (SELECT TOP 1 C.MemberMci_IDNO
            FROM CMEM_Y1 C
           WHERE C.Case_IDNO = X.Case_IDNO
             AND C.CaseRelationship_CODE = @Lc_CaseRelationCp_CODE
             AND C.CaseMemberStatus_CODE = @Lc_CaseMemberrStatusActive_CODE) AS CpMemberMci_IDNO,
         (SELECT G.Worker_ID
            FROM GLEV_Y1 G
           WHERE G.EventGlobalSeq_NUMB = X.EventGlobalBeginSeq_NUMB)AS Worker_ID,
         (SELECT GL.Process_ID
            FROM GLEV_Y1 GL
           WHERE GL.EventGlobalSeq_NUMB = X.EventGlobalBeginSeq_NUMB) AS Process_ID,
         X.Udc_CODE,
         X.NumDaysHold_QNTY,
         X.ExtendResearch_INDC,
         X.ManualRelease_INDC,
         X.ErDuration_QNTY,
         AlertDuration_QNTY,
         D.Last_NAME,
         D.Suffix_NAME,
         D.First_NAME,
         D.Middle_NAME,
         (SELECT TOP 1 o.TypeDebt_CODE
            FROM OBLE_Y1 o
           WHERE o.Case_IDNO = X.Case_IDNO
             AND o.OrderSeq_NUMB = X.OrderSeq_NUMB
             AND o.ObligationSeq_NUMB = X.ObligationSeq_NUMB
             AND o.EndValidity_DATE = @Ld_High_DATE) AS TypeDebt_CODE,
         (SELECT TOP 1 o.Fips_CODE
            FROM OBLE_Y1 o
           WHERE o.Case_IDNO = X.Case_IDNO
             AND o.OrderSeq_NUMB = X.OrderSeq_NUMB
             AND o.ObligationSeq_NUMB = X.ObligationSeq_NUMB
             AND o.EndValidity_DATE = @Ld_High_DATE) AS Fips_CODE,
         (SELECT TOP 1 o.MemberMci_IDNO
            FROM OBLE_Y1 o
           WHERE o.Case_IDNO = X.Case_IDNO
             AND o.OrderSeq_NUMB = X.OrderSeq_NUMB
             AND o.ObligationSeq_NUMB = X.ObligationSeq_NUMB
             AND o.EndValidity_DATE = @Ld_High_DATE) AS ObligeeMCI_IDNO,
         X.Alert_INDC,
         RowCount_NUMB
    FROM (SELECT Y.Transaction_DATE,
                 Y.TypeHold_CODE,
                 Y.Batch_DATE,
                 Y.SourceBatch_CODE,
                 Y.Batch_NUMB,
                 Y.SeqReceipt_NUMB,
                 Y.Case_IDNO,
                 Y.CheckRecipient_ID,
                 Y.CheckRecipient_CODE,
                 Y.Transaction_AMNT,
                 Y.TransactionTotal_AMNT,
                 Y.TypeDisburse_CODE,
                 Y.OrderSeq_NUMB,
                 Y.ObligationSeq_NUMB,
                 Y.Release_DATE,
                 Y.EventGlobalBeginSeq_NUMB,
                 Y.EventGlobalSupportSeq_NUMB,
                 Y.Udc_CODE,
                 Y.Unique_IDNO,
                 Y.Disburse_DATE,
                 Y.DisburseSeq_NUMB,
                 Y.ExtendResearch_INDC,
                 Y.ManualRelease_INDC,
                 Y.ErDuration_QNTY,
                 Y.AlertDuration_QNTY,
                 Y.NumDaysHold_QNTY,
                 Y.Alert_INDC,
                 Y.RowCount_NUMB,
                 Y.ORD_ROWNUM AS row_num
            FROM (SELECT a.Transaction_DATE,
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
                         b.Udc_CODE,
                         a.Unique_IDNO,
                         a.Disburse_DATE,
                         a.DisburseSeq_NUMB,
                         b.ExtendResearch_INDC,
                         b.ManualRelease_INDC,
                         b.ErDuration_QNTY,
                         b.AlertDuration_QNTY,
                         b.NumDaysHold_QNTY,
                         b.Alert_INDC,
                         COUNT(1) OVER() AS RowCount_NUMB,
                         ROW_NUMBER() OVER( ORDER BY a.Transaction_DATE, a.TypeHold_CODE) AS ORD_ROWNUM
                    FROM DHLD_Y1 a
                         LEFT OUTER JOIN UCAT_Y1 b
                          ON b.Udc_CODE = a.ReasonStatus_CODE
                             AND b.EndValidity_DATE = @Ld_High_DATE
                   WHERE a.EndValidity_DATE = @Ld_High_DATE
                     AND a.ReasonStatus_CODE != @Lc_ReasonStatus_CODE
                     AND a.Transaction_DATE <= @Ad_Transaction_DATE
                     AND (a.Case_IDNO = @An_Case_IDNO
                           OR @An_Case_IDNO IS NULL)
                     AND (a.CheckRecipient_ID = ISNULL(@Ac_CheckRecipient_ID, a.CheckRecipient_ID)
                          AND a.CheckRecipient_CODE = ISNULL(@Ac_CheckRecipient_CODE, a.CheckRecipient_CODE))
                     AND (a.Status_CODE = @Lc_StatusH_CODE)
                     AND (a.ReasonStatus_CODE = @Ac_ReasonStatus_CODE
                          AND @Ac_ReasonStatus_CODE <> @Lc_DisbursementTypeL_CODE
                           OR @Ac_ReasonStatus_CODE = @Lc_DisbursementTypeL_CODE
                           OR @Ac_ReasonStatus_CODE IS NULL)) AS Y
           WHERE Y.ORD_ROWNUM <= @Ai_RowTo_NUMB) AS X
         LEFT OUTER JOIN DEMO_Y1 D
          ON D.MemberMci_IDNO = (SELECT CM.MemberMci_IDNO
                                   FROM CMEM_Y1 CM
                                  WHERE CM.Case_IDNO = X.Case_IDNO
                                    AND CM.CaseRelationship_CODE IN (@Lc_CaseRelationNcp_CODE, @Lc_CaseRelationPutFather_CODE)
                                    AND CM.CaseMemberStatus_CODE = @Lc_CaseMemberrStatusActive_CODE)
   WHERE X.row_num >= @Ai_RowFrom_NUMB
   ORDER BY ROW_NUM;
 END; --End of DHLD_RETRIEVE_S1 

GO
