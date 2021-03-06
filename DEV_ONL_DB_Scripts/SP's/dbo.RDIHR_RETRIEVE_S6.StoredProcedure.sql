/****** Object:  StoredProcedure [dbo].[RDIHR_RETRIEVE_S6]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RDIHR_RETRIEVE_S6] (
 @Ac_CheckRecipient_ID CHAR(10),
 @Ad_Transaction_DATE  DATE,
 @Ac_ReasonStatus_CODE CHAR(4),
 @Ai_RowFrom_NUMB      INT = 1,
 @Ai_RowTo_NUMB        INT = 10
 )
AS
 /*
  *     PROCEDURE NAME    : RDIHR_RETRIEVE_S6
  *     DESCRIPTION       : Retrieve the Receipients details for the hold receipients.
  *     DEVELOPED BY      : IMP Team    
  *     DEVELOPED ON      : 02-NOV-2011 
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Lc_Space_TEXT             CHAR(1) = ' ',
          @Lc_StatusReceiptHeld_CODE CHAR(1) = 'H',
          @Lc_StatusR_CODE           CHAR(1) = 'R',
          @Lc_TypeHoldC_CODE         CHAR(1) = 'C',
          @Li_Zero_NUMB              SMALLINT = 0;

  SELECT X.CheckRecipient_ID,
         X.CheckRecipient_CODE,
         X.Case_IDNO,
         X.PayorMCI_IDNO,
         X.Transaction_AMNT,
         X.Receipt_ID,
         X.ControlNo_TEXT,
         X.ReasonStatus_CODE,
         X.BeginValidity_DATE,
         X.First_NAME,
         X.Last_NAME,
         X.Middle_NAME,
         X.Worker_ID,
         X.Release_DATE,
         X.RespondInit_CODE,
         X.Recipient_NAME,
         X.Transaction_CODE,
         X.RowCount_NUMB,
         X.Total_AMNT
    FROM (SELECT c.CheckRecipient_ID,
                 c.CheckRecipient_CODE,
                 c.Case_IDNO,
                 c.PayorMCI_IDNO,
                 c.Transaction_AMNT,
                 c.Receipt_ID,
                 c.ControlNo_TEXT,
                 c.ReasonStatus_CODE,
                 c.BeginValidity_DATE,
                 c.First_NAME,
                 c.Last_NAME,
                 c.Middle_NAME,
                 c.Worker_ID,
                 c.Release_DATE,
                 c.RespondInit_CODE,
                 c.Recipient_NAME,
                 c.Transaction_CODE,
                 c.RowCount_NUMB,
                 c.Total_AMNT,
                 c.ORD_ROWNUM
            FROM (SELECT b.CheckRecipient_ID,
                         b.CheckRecipient_CODE,
                         b.Case_IDNO,
                         b.PayorMCI_IDNO,
                         b.Transaction_AMNT,
                         b.Receipt_ID,
                         b.ControlNo_TEXT,
                         b.ReasonStatus_CODE,
                         b.BeginValidity_DATE,
                         b.First_NAME,
                         b.Last_NAME,
                         b.Middle_NAME,
                         b.Worker_ID,
                         b.Release_DATE,
                         b.RespondInit_CODE,
                         b.Recipient_NAME,
                         b.Transaction_CODE,
                         b.EventGlobalBeginSeq_NUMB,
                         COUNT(1) OVER() AS RowCount_NUMB,
                         SUM(b.Transaction_AMNT) OVER() AS Total_AMNT,
                         ROW_NUMBER() OVER( ORDER BY b.Worker_ID, b.Release_DATE, b.Case_IDNO, b.Receipt_ID, b.EventGlobalBeginSeq_NUMB) AS ORD_ROWNUM
                    FROM (SELECT r.CheckRecipient_ID,
                                 r.CheckRecipient_CODE,
                                 r.Case_IDNO,
                                 r.PayorMCI_IDNO,
                                 r.Transaction_AMNT,
                                 r.Receipt_ID,
                                 r.ControlNo_TEXT,
                                 r.ReasonStatus_CODE,
                                 r.BeginValidity_DATE,
                                 r.First_NAME,
                                 r.Last_NAME,
                                 r.Middle_NAME,
                                 r.Worker_ID,
                                 r.Release_DATE,
                                 r.RespondInit_CODE,
                                 r.Recipient_NAME,
                                 r.Transaction_CODE,
                                 r.EventGlobalBeginSeq_NUMB
                            FROM RDIHR_Y1 r
                           WHERE ((r.Transaction_DATE = @Ad_Transaction_DATE
                                   AND r.Transaction_CODE = @Lc_StatusReceiptHeld_CODE
                                   AND r.EndValidity_DATE > r.Transaction_DATE)
                                   OR (r.EndValidity_DATE = @Ad_Transaction_DATE
                                       AND (r.Transaction_CODE = @Lc_StatusReceiptHeld_CODE
                                             OR (r.Transaction_CODE = @Lc_StatusR_CODE
                                                 AND r.TypeHold_CODE = @Lc_TypeHoldC_CODE))
                                       AND r.EndValidity_DATE > r.Transaction_DATE))
                             AND r.ReasonStatus_CODE = ISNULL (@Ac_ReasonStatus_CODE, @Lc_Space_TEXT)
                             AND (@Ac_CheckRecipient_ID IS NULL
                                   OR r.CheckRecipient_ID = @Ac_CheckRecipient_ID)) AS b) AS c
           WHERE (c.ORD_ROWNUM <= @Ai_RowTo_NUMB
               OR @Ai_RowTo_NUMB = @Li_Zero_NUMB)) AS X
   WHERE (X.ORD_ROWNUM >= @Ai_RowFrom_NUMB
       OR @Ai_RowFrom_NUMB = @Li_Zero_NUMB)
   ORDER BY ORD_ROWNUM;
 END -- End of RDIHR_RETRIEVE_S6

GO
