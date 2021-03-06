/****** Object:  StoredProcedure [dbo].[EFTR_RETRIEVE_S2]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[EFTR_RETRIEVE_S2] (
 @Ac_CheckRecipient_ID   CHAR(10),
 @Ac_CheckRecipient_CODE CHAR(1),
 @Ai_RowFrom_NUMB        INT=1,
 @Ai_RowTo_NUMB          INT=10
 )
AS

/*
*     PROCEDURE NAME    : EFTR_RETRIEVE_S2
 *     DESCRIPTION       : This procedure is used to inquire the EFTI detail information.It is used to view current and historical electronic funds transfer disbursement
                            instructions for Interstate IV-D Agencies,Custodial Parents and other agencies.Authorized workers can view EFT status records created by the system  or manually by the worker.It
                            will get the details from the eftr table.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 02-FEB-2012
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/

 BEGIN
  SELECT Y.RoutingBank_NUMB,
         Y.AccountBankNo_TEXT,
         Y.TypeAccount_CODE,
         Y.PreNote_DATE,
         Y.EftStatus_DATE,
         Y.StatusEft_CODE,
         Y.Reason_CODE,
         Y.BeginValidity_DATE,
         Y.Worker_ID,
         Y.RowCount_NUMB
    FROM (SELECT X.BeginValidity_DATE,
                 X.RoutingBank_NUMB,
                 X.AccountBankNo_TEXT,
                 X.TypeAccount_CODE,
                 X.StatusEft_CODE,
                 X.Reason_CODE,
                 X.EftStatus_DATE,
                 X.PreNote_DATE,
                 X.Worker_ID,
                 X.RowCount_NUMB,
                 X.ORD_ROWNUM AS rnm
            FROM (SELECT a.BeginValidity_DATE,
                         a.RoutingBank_NUMB,
                         a.AccountBankNo_TEXT,
                         a.TypeAccount_CODE,
                         a.StatusEft_CODE,
                         a.Reason_CODE,
                         a.EftStatus_DATE,
                         a.PreNote_DATE,
                         b.Worker_ID,
                         COUNT(1) OVER() AS RowCount_NUMB,
                         ROW_NUMBER() OVER( ORDER BY a.EventGlobalBeginSeq_NUMB DESC) AS ORD_ROWNUM
                    FROM EFTR_Y1 a
                         JOIN GLEV_Y1 b
                          ON b.EventGlobalSeq_NUMB = a.EventGlobalBeginSeq_NUMB
                   WHERE a.CheckRecipient_ID = @Ac_CheckRecipient_ID
                     AND a.CheckRecipient_CODE = @Ac_CheckRecipient_CODE) AS X
           WHERE X.ORD_ROWNUM <= @Ai_RowTo_NUMB) AS Y
   WHERE Y.rnm >= @Ai_RowFrom_NUMB
   ORDER BY RNM;
 END; --End of EFTR_RETRIEVE_S2

GO
