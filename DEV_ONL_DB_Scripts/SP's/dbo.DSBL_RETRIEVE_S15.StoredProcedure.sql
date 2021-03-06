/****** Object:  StoredProcedure [dbo].[DSBL_RETRIEVE_S15]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DSBL_RETRIEVE_S15] (
 @Ac_CheckRecipient_CODE CHAR(1),
 @Ad_Disburse_DATE       DATE,
 @An_DisburseSeq_NUMB    NUMERIC(4, 0),
 @Ac_CheckRecipient_ID   CHAR(10),
 @Ai_RowFrom_NUMB        INT=1,
 @Ai_RowTo_NUMB          INT=10
 )
AS
 /*
  *     PROCEDURE NAME    : DSBL_RETRIEVE_S15
  *     DESCRIPTION       : Retrieves the cases and the debt types to which payments have been applied and disbursed with reference to the disbursement record selected for a given recipient and disbursement date.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 14-FEB-2012
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  --DSBL_RETRIEVE_S15 RETURNS REFCURSOR AREF_RESULT
  DECLARE @Lc_CpNcpCheckRecipient_CODE    CHAR(1) = '1',
          @Lc_FipsCheckRecipient_CODE     CHAR(1) = '2',
          @Lc_OthpCheckRecipient_CODE     CHAR(1) = '3',
          @Lc_CaseRelationshipCp_CODE     CHAR(1) = 'C',
          @Lc_CaseMemberStatusActive_CODE CHAR(1) = 'A',
          @Lc_Space_TEXT                  CHAR(1) = ' ',
          @Li_Zero_NUMB                   SMALLINT = 0,
          @Lc_DateFormatMmddyyyy_code     CHAR(8) = 'MMDDYYYY',
          @Lc_ZTypeDisburse_CODE          CHAR(1) = 'Z',
          @Lc_ReceiptZeroOne_CODE         CHAR(10) = '0101000100',
          @Lc_Refund_TypeDisburse_CODE    CHAR(5) = 'REFND',
          @Lc_Rothp_TypeDisburse_CODE     CHAR(5) = 'ROTHP',
          @Ld_High_DATE                   CHAR(10) = '12/31/9999';

  SELECT CheckRecipient_ID,
         X.Case_IDNO,
         X.TypeDisburse_CODE,
         Disburse_AMNT,
         TypeDebt_CODE,
         X.CheckRecipient_CODE,
         X.Batch_DATE,
         X.SourceBatch_CODE,
         X.Batch_NUMB,
         X.SeqReceipt_NUMB,
         CONVERT(VARCHAR, ActiveCheckRecipient_ID) ActiveCheckRecipient_ID,
         row_count AS RowCount_NUMB
    FROM (SELECT CheckRecipient_ID,
                 X.Case_IDNO,
                 X.TypeDisburse_CODE,
                 X.Disburse_AMNT,
                 TypeDebt_CODE,
                 X.CheckRecipient_CODE,
                 X.Batch_DATE,
                 X.SourceBatch_CODE,
                 X.Batch_NUMB,
                 X.SeqReceipt_NUMB,
                 ActiveCheckRecipient_ID,
                 ROW_NUMBER() OVER( ORDER BY CheckRecipient_ID) AS rnm,
                 X.row_count
            FROM (SELECT X.CheckRecipient_ID,
                         X.Case_IDNO,
                         X.TypeDisburse_CODE,
                         SUM(CAST(X.Disburse_AMNT AS FLOAT(53))) AS Disburse_AMNT,
                         X.TypeDebt_CODE,
                         MAX(X.CheckRecipient_CODE) CheckRecipient_CODE,
                         MAX(X.Batch_DATE) Batch_DATE,
                         MAX(X.SourceBatch_CODE) SourceBatch_CODE,
                         MAX(X.Batch_NUMB) Batch_NUMB,
                         MAX(X.SeqReceipt_NUMB) SeqReceipt_NUMB,
                         MAX(X.ActiveCheckRecipient_ID) ActiveCheckRecipient_ID,
                         COUNT(1) OVER() AS row_count,
                         ROW_NUMBER() OVER( ORDER BY X.CheckRecipient_ID, X.Case_IDNO) AS ORD_ROWNUM
                    FROM (SELECT a.CheckRecipient_CODE,
                                 a.CheckRecipient_ID,
                                 a.Batch_DATE,
                                 a.SourceBatch_CODE,
                                 a.Batch_NUMB,
                                 a.SeqReceipt_NUMB,
                                 ISNULL((SELECT bb.MemberMci_IDNO
                                           FROM CMEM_Y1 bb
                                          WHERE bb.Case_IDNO = a.Case_IDNO
                                            AND bb.CaseRelationship_CODE = @Lc_CaseRelationshipCp_CODE
                                            AND bb.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE), NULL) ActiveCheckRecipient_ID,
                                 a.Case_IDNO,
                                 a.TypeDisburse_CODE,
                                 ISNULL(a.Disburse_AMNT, @Li_Zero_NUMB) AS Disburse_AMNT,
                                 (SELECT TOP 1 OB.TypeDebt_CODE
                                    FROM OBLE_Y1 OB
                                   WHERE OB.Case_IDNO = a.Case_IDNO
                                     AND OB.OrderSeq_NUMB = a.OrderSeq_NUMB
                                     AND OB.ObligationSeq_NUMB = a.ObligationSeq_NUMB
                                     AND OB.EndValidity_DATE = @Ld_High_DATE) AS TypeDebt_CODE
                            FROM DSBL_Y1 a
                           WHERE a.CheckRecipient_ID = @Ac_CheckRecipient_ID
                             AND a.CheckRecipient_CODE = @Ac_CheckRecipient_CODE
                             AND a.Disburse_DATE = @Ad_Disburse_DATE
                             AND a.DisburseSeq_NUMB = @An_DisburseSeq_NUMB) X
                   GROUP BY X.CheckRecipient_ID,
                            X.Case_IDNO,
                            X.TypeDisburse_CODE,
                            X.TypeDebt_CODE,
                            X.Batch_DATE,
							X.SourceBatch_CODE,
							X.Batch_NUMB,
							X.SeqReceipt_NUMB) X
           WHERE X.ORD_ROWNUM <= @Ai_RowTo_NUMB) X
   WHERE X.rnm >= @Ai_RowFrom_NUMB
   ORDER BY RNM;
 END


GO
