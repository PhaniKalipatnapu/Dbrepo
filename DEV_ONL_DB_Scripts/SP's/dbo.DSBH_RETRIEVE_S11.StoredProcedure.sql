/****** Object:  StoredProcedure [dbo].[DSBH_RETRIEVE_S11]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DSBH_RETRIEVE_S11] (
 @Ac_CheckRecipient_CODE   CHAR(1),
 @An_Case_IDNO             NUMERIC(6, 0),
 @Ac_CheckRecipient_ID     CHAR(10),
 @Ad_DisbursementFrom_DATE DATE,
 @Ad_DisbursementTo_DATE   DATE
 )
AS
 /*
  *     PROCEDURE NAME    : DSBH_RETRIEVE_S11
  *     DESCRIPTION       : Retrieves the disbursement report associated with a recipient, case and the date range within which the disbursement took place.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 14-FEB-2012
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Lc_CashedStatusCheck_CODE      CHAR(2) = 'CA',
          @Lc_OutstandingStatusCheck_CODE CHAR(2) = 'OU',
          @Lc_TransferEftStatusCheck_CODE CHAR(2) = 'TR',
          @Lc_Svc_MediumDisburse_CODE     CHAR(1) = 'B',
          @Lc_CheckMediumDisburse_CODE    CHAR(1) = 'C',
          @Lc_EftMediumDisburse_CODE      CHAR(1) = 'E',
          @Ld_High_DATE                   DATE = '31-DEC-9999';
  DECLARE @Ld_Current_DATE                DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

  SELECT StatusCheck_CODE,
		 x.Disburse_DATE,
         d.Misc_ID,
         d.Check_NUMB,
         d.MediumDisburse_CODE,
         x.TypeDebt_CODE,
         x.Disburse_AMNT,
         SUM(x.Disburse_AMNT) OVER(PARTITION BY x.Disburse_DATE) AS TotalDisburse_AMNT,
         d.StatusCheck_CODE,
         SUM(x.Disburse_AMNT) OVER() AS TotalDisbursed_AMNT
    FROM DSBH_Y1 d,
         (SELECT o.TypeDebt_CODE,
                 SUM(l.Disburse_AMNT) AS Disburse_AMNT,
                 l.Disburse_DATE,
                 l.DisburseSeq_NUMB
            FROM DSBL_Y1 l,
                 OBLE_Y1 o
           WHERE l.CheckRecipient_ID = @Ac_CheckRecipient_ID
             AND l.CheckRecipient_CODE = @Ac_CheckRecipient_CODE
             AND l.Disburse_DATE BETWEEN @Ad_DisbursementFrom_DATE AND @Ad_DisbursementTo_DATE
             AND o.Case_IDNO = @An_Case_IDNO
             AND l.Case_IDNO = o.Case_IDNO
             AND l.OrderSeq_NUMB = o.OrderSeq_NUMB
             AND l.ObligationSeq_NUMB = o.ObligationSeq_NUMB
             AND o.EndValidity_DATE = @Ld_High_DATE
             AND o.BeginObligation_DATE <= @Ld_Current_DATE
             AND o.EndObligation_DATE = (SELECT MAX(b.EndObligation_DATE) AS expr
                                           FROM OBLE_Y1 b
                                          WHERE b.Case_IDNO = o.Case_IDNO
                                            AND b.OrderSeq_NUMB = o.OrderSeq_NUMB
                                            AND b.ObligationSeq_NUMB = o.ObligationSeq_NUMB
                                            AND b.BeginObligation_DATE <= @Ld_Current_DATE
                                            AND b.EndValidity_DATE = @Ld_High_DATE)
           GROUP BY o.TypeDebt_CODE,
                    l.Disburse_DATE,
                    l.DisburseSeq_NUMB) x
   WHERE d.CheckRecipient_ID = @Ac_CheckRecipient_ID
     AND d.CheckRecipient_CODE = @Ac_CheckRecipient_CODE
     AND d.StatusCheck_CODE IN (@Lc_CashedStatusCheck_CODE, @Lc_OutstandingStatusCheck_CODE, @Lc_TransferEftStatusCheck_CODE)
     AND d.Disburse_DATE = x.Disburse_DATE
     AND d.DisburseSeq_NUMB = x.DisburseSeq_NUMB
     AND d.EndValidity_DATE = @Ld_High_DATE
   ORDER BY d.Disburse_DATE,
            ISNULL(d.Check_NUMB, ''),
            ISNULL(d.Misc_ID, ''),
            x.TypeDebt_CODE;
 END


GO
