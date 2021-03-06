/****** Object:  StoredProcedure [dbo].[DSBH_RETRIEVE_S3]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DSBH_RETRIEVE_S3](
 @Ad_IssueFrom_DATE      DATE,
 @Ad_IssueTo_DATE        DATE,
 @Ac_CheckRecipient_CODE CHAR(2),
 @Ac_MediumDisburse_CODE CHAR(1),
 @Ac_DisplayType_CODE    CHAR(4),
 @Ai_RowFrom_NUMB        INT = 1,
 @Ai_RowTo_NUMB          INT = 10
 )
AS
 /*  
  *     PROCEDURE NAME    : DSBH_RETRIEVE_S3  
  *     DESCRIPTION       : Retrieves the disbursement register details.  
  *     DEVELOPED BY      : IMP Team  
  *     DEVELOPED ON      : 02-OCT-2011  
  *     MODIFIED BY       :   
  *     MODIFIED ON       :   
  *     VERSION NO        : 1  
 */
 BEGIN
  DECLARE @Lc_CheckRecipientOtherParty_CODE CHAR(10) = '999999900',
          @Lc_TypeDisburseRefnd_CODE        CHAR(5) = 'REFND',
          @Lc_TypeDisburseRothp_CODE        CHAR(5) = 'ROTHP',
          @Lc_DispTypeCpch_CODE             CHAR(4) = 'CPCH',
          @Lc_DispTypeCpef_CODE             CHAR(4) = 'CPEF',
          @Lc_DispTypeCpsv_CODE             CHAR(4) = 'CPSV',
          @Lc_DispTypeFich_CODE             CHAR(4) = 'FICH',
          @Lc_DispTypeFief_CODE             CHAR(4) = 'FIEF',
          @Lc_DispTypeFirc_CODE             CHAR(4) = 'FIRC',
          @Lc_DispTypeNcre_CODE             CHAR(4) = 'NCRE',
          @Lc_DispTypeCprc_CODE             CHAR(4) = 'CPRC',
          @Lc_DispTypeOprc_CODE             CHAR(4) = 'OPRC',
          @Lc_DispTypeAgrc_CODE             CHAR(4) = 'AGRC',
          @Lc_DispTypeOpch_CODE             CHAR(4) = 'OPCH',
          @Lc_SourceReceiptCr_CODE          CHAR(2) = 'CR',
          @Lc_SourceReceiptCf_CODE          CHAR(2) = 'CF',
          @Lc_StatusCheckOu_CODE            CHAR(2) = 'OU',
          @Lc_StatusCheckTr_CODE            CHAR(2) = 'TR',
          @Li_Zero_NUMB                     SMALLINT =0,
          @Ld_High_DATE                     DATE = '12/31/9999';

  SELECT Y.Case_IDNO,
         Y.Check_NUMB,
         Y.CheckRecipient_ID,
         Y.CheckRecipient_CODE,
         dbo.BATCH_COMMON$SF_GET_MASKED_RECIPIENT_NAME(Y.CheckRecipient_ID, Y.CheckRecipient_CODE) AS Recipient_NAME,
         Y.Disburse_AMNT,
         Y.Misc_ID,
         Y.Issue_DATE,
         CONVERT(CHAR(20), Y.Check_NUMB) Check_NUMB,
         Y.MediumDisburse_CODE,
         Y.RowCount_NUMB,
         Y.TotCount_QNTY,
         Y.TotAmount_QNTY
    FROM (SELECT X.Case_IDNO,
                 X.Check_NUMB,
                 X.CheckRecipient_ID,
                 X.CheckRecipient_CODE,
                 X.Disburse_AMNT,
                 X.Misc_ID,
                 X.Issue_DATE,
                 X.MediumDisburse_CODE,
                 X.RowCount_NUMB,
                 X.TotCount_QNTY,
                 X.TotAmount_QNTY,
                 X.ORD_ROWNUM
            FROM (SELECT d.Case_IDNO,
                         d.Check_NUMB,
                         d.CheckRecipient_ID,
                         d.CheckRecipient_CODE,
                         SUM(d.Disburse_AMNT) AS Disburse_AMNT,
                         d.Misc_ID,
                         d.Issue_DATE,
                         d.MediumDisburse_CODE,
                         COUNT(1) OVER() AS RowCount_NUMB,
                         COUNT(1) OVER() AS TotCount_QNTY,
                         SUM(SUM(d.Disburse_AMNT)) OVER() AS TotAmount_QNTY,
                         ROW_NUMBER() OVER( ORDER BY d.CheckRecipient_ID ASC, d.CheckRecipient_CODE ASC, d.Misc_ID ASC) AS ORD_ROWNUM
                    FROM (SELECT d.CheckRecipient_CODE,
                                 d.CheckRecipient_ID,
                                 d1.Disburse_AMNT,
                                 d.Check_NUMB,
                                 d.Issue_DATE,
                                 d.Misc_ID,
                                 d1.Case_IDNO,
                                 d.MediumDisburse_CODE
                            FROM DSBH_Y1 d
                                 JOIN DSBL_Y1 d1
                                  ON(d.CheckRecipient_ID = d1.CheckRecipient_ID
                                     AND d.CheckRecipient_CODE = d1.CheckRecipient_CODE
                                     AND d.Disburse_DATE = d1.Disburse_DATE
                                     AND d.DisburseSeq_NUMB = d1.DisburseSeq_NUMB
                                     AND d.EventGlobalBeginSeq_NUMB = d1.EventGlobalSeq_NUMB)
                                 JOIN RCTH_Y1 r
                                  ON (d1.Batch_DATE = r.Batch_DATE
                                      AND d1.Batch_NUMB = r.Batch_NUMB
                                      AND d1.SeqReceipt_NUMB = r.SeqReceipt_NUMB
                                      AND d1.SourceBatch_CODE = r.SourceBatch_CODE
                                      AND r.EventGlobalBeginSeq_NUMB = d1.EventGlobalSupportSeq_NUMB)
                           WHERE R.EndValidity_DATE = @Ld_High_DATE
                             AND d.Issue_DATE BETWEEN @Ad_IssueFrom_DATE AND @Ad_IssueTo_DATE
                             AND d.StatusCheck_CODE IN (@Lc_StatusCheckOu_CODE, @Lc_StatusCheckTr_CODE)
                             AND d.CheckRecipient_CODE = ISNULL(@Ac_CheckRecipient_CODE, d.CheckRecipient_CODE)
                             AND d.MediumDisburse_CODE = ISNULL(@Ac_MediumDisburse_CODE, d.MediumDisburse_CODE)
                             AND ((@Ac_DisplayType_CODE IN (@Lc_DispTypeCpch_CODE, @Lc_DispTypeCpef_CODE, @Lc_DispTypeCpsv_CODE, @Lc_DispTypeFich_CODE,@Lc_DispTypeFief_CODE, @Lc_DispTypeOpch_CODE)
                                   AND d1.TypeDisburse_CODE NOT IN (@Lc_TypeDisburseRefnd_CODE, @Lc_TypeDisburseRothp_CODE))
                                   OR (@Ac_DisplayType_CODE IN (@Lc_DispTypeFirc_CODE, @Lc_DispTypeOprc_CODE, @Lc_DispTypeAgrc_CODE)
                                       AND d1.TypeDisburse_CODE IN (@Lc_TypeDisburseRefnd_CODE, @Lc_TypeDisburseRothp_CODE)
                                       AND ((@Ac_DisplayType_CODE = @Lc_DispTypeOprc_CODE
                                             AND d.CheckRecipient_ID <= @Lc_CheckRecipientOtherParty_CODE)
                                             OR @Ac_DisplayType_CODE <> @Lc_DispTypeOprc_CODE)
                                       AND ((@Ac_DisplayType_CODE IN (@Lc_DispTypeAgrc_CODE)
                                             AND d.CheckRecipient_ID > @Lc_CheckRecipientOtherParty_CODE)
                                             OR @Ac_DisplayType_CODE NOT IN (@Lc_DispTypeAgrc_CODE)))
                                   OR (@Ac_DisplayType_CODE IN (@Lc_DispTypeNcre_CODE, @Lc_DispTypeCprc_CODE)
                                       AND d1.TypeDisburse_CODE = @Lc_TypeDisburseRefnd_CODE
                                       AND ((@Ac_DisplayType_CODE IN (@Lc_DispTypeCprc_CODE)
                                             AND r.SourceReceipt_CODE IN (@Lc_SourceReceiptCr_CODE, @Lc_SourceReceiptCf_CODE))
                                             OR @Ac_DisplayType_CODE NOT IN (@Lc_DispTypeCprc_CODE))
                                       AND ((@Ac_DisplayType_CODE = @Lc_DispTypeNcre_CODE
                                             AND r.SourceReceipt_CODE NOT IN (@Lc_SourceReceiptCr_CODE, @Lc_SourceReceiptCf_CODE))
                                             OR @Ac_DisplayType_CODE <> @Lc_DispTypeNcre_CODE))
                                   OR @Ac_DisplayType_CODE IS NULL)) AS D
                   GROUP BY d.Case_IDNO,
                            d.Check_NUMB,
                            d.CheckRecipient_ID,
                            d.CheckRecipient_CODE,
                            d.Misc_ID,
                            d.Issue_DATE,
                            d.MediumDisburse_CODE,
                            CONVERT(VARCHAR, d.Check_NUMB) + '/' + d.Misc_ID) AS X
           WHERE ((X.ORD_ROWNUM <= @Ai_RowTo_NUMB)
               OR (@Ai_RowTo_NUMB = @Li_Zero_NUMB))) AS Y
   WHERE ((Y.ORD_ROWNUM >= @Ai_RowFrom_NUMB)
       OR (@Ai_RowFrom_NUMB = @Li_Zero_NUMB))
   ORDER BY Y.ORD_ROWNUM;
 END; -- End Of DSBH_RETRIEVE_S3

GO
