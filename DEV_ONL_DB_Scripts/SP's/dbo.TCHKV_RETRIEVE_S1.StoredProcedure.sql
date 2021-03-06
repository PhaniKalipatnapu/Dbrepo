/****** Object:  StoredProcedure [dbo].[TCHKV_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[TCHKV_RETRIEVE_S1] (
 @Ai_RowFrom_NUMB INT=1,
 @Ai_RowTo_NUMB   INT=10
 )
AS
 /*
  *     PROCEDURE NAME    : TCHKV_RETRIEVE_S1
  *     DESCRIPTION       : Retrieves the disbursement tracking details.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 14-FEB-2012
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SELECT Y.Check_NUMB,
         Y.Disburse_DATE,
         Y.StatusCheck_CODE,
         Y.Disburse_AMNT,
         Y.CheckRecipient_ID,
         Y.CheckRecipient_CODE,
         Y.Worker_ID,
         Y.CheckReplace_NUMB,
         Y.MediumDisburse_CODE,
         row_count AS RowCount_NUMB
    FROM (SELECT X.Check_NUMB,
                 X.Disburse_DATE,
                 X.StatusCheck_CODE,
                 X.Disburse_AMNT,
                 X.CheckRecipient_ID,
                 X.CheckRecipient_CODE,
                 X.CheckReplace_NUMB,
                 X.Worker_ID,
                 X.MediumDisburse_CODE,
                 X.ORD_ROWNUM,
                 X.row_count
            FROM (SELECT TC.Check_NUMB,
                         TC.Disburse_DATE,
                         TC.StatusCheck_CODE,
                         TC.Disburse_AMNT,
                         TC.CheckRecipient_ID,
                         TC.CheckRecipient_CODE,
                         TC.CheckReplace_NUMB,
                         TC.Worker_ID,
                         TC.MediumDisburse_CODE,
                         COUNT(1) OVER() AS row_count,
                         ROW_NUMBER() OVER( ORDER BY TC.Check_NUMB DESC) AS ORD_ROWNUM
                    FROM TCHKV_Y1 TC) X
           WHERE X.ORD_ROWNUM <= @Ai_RowTo_NUMB) Y
   WHERE Y.ORD_ROWNUM >= @Ai_RowFrom_NUMB
   ORDER BY ORD_ROWNUM;
 END


GO
