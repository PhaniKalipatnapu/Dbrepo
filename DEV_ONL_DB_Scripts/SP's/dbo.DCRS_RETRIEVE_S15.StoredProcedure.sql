/****** Object:  StoredProcedure [dbo].[DCRS_RETRIEVE_S15]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DCRS_RETRIEVE_S15] (
 @Ac_CheckRecipient_ID CHAR(10),
 @Ai_RowFrom_NUMB      INT=1,
 @Ai_RowTo_NUMB        INT=10
 )
AS
 /*
 *     PROCEDURE NAME    : DCRS_RETRIEVE_S15
  *     DESCRIPTION       : Retrieves account number, status code, status date, reason code for the given check recipient ID.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 14-SEP-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT Y.RoutingBank_NUMB,
         Y.AccountBankNo_TEXT,
         Y.DebitCard_NUMB,
         Y.Status_CODE,
         Y.Status_DATE,
         Y.Reason_CODE,
         Y.Worker_ID,
         Y.EventGlobalBeginSeq_NUMB,
         row_count AS RowCount_NUMB
    FROM (SELECT X.RoutingBank_NUMB,
                 X.AccountBankNo_TEXT,
                 X.DebitCard_NUMB,
                 X.Status_CODE,
                 X.Status_DATE,
                 X.Reason_CODE,
                 X.Worker_ID,
                 X.EventGlobalBeginSeq_NUMB,
                 X.ORD_ROWNUM AS rnm,
                 X.row_count
            FROM (SELECT d.RoutingBank_NUMB,
                         d.DebitCard_NUMB,
                         d.Status_CODE,
                         d.Status_DATE,
                         d.Reason_CODE,
                         g.Worker_ID,
                         d.EventGlobalBeginSeq_NUMB,
                         d.AccountBankNo_TEXT,
                         COUNT(1) OVER() AS row_count,
                         ROW_NUMBER() OVER( ORDER BY d.EventGlobalBeginSeq_NUMB DESC) AS ORD_ROWNUM
                    FROM DCRS_Y1 d
                         LEFT OUTER JOIN GLEV_Y1 g
                          ON g.EventGlobalSeq_NUMB = d.EventGlobalBeginSeq_NUMB
                   WHERE d.CheckRecipient_ID = @Ac_CheckRecipient_ID
                     AND d.EndValidity_DATE = @Ld_High_DATE) AS X
           WHERE X.ORD_ROWNUM <= @Ai_RowTo_NUMB) AS Y
   WHERE Y.rnm >= @Ai_RowFrom_NUMB
   ORDER BY RNM;
 END; --End of DCRS_RETRIEVE_S15

GO
