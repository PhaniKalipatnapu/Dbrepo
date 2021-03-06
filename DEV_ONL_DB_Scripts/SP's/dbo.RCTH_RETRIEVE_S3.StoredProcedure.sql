/****** Object:  StoredProcedure [dbo].[RCTH_RETRIEVE_S3]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RCTH_RETRIEVE_S3] (
 @Ad_From_DATE          DATE,
 @Ad_To_DATE            DATE,
 @An_County_IDNO        NUMERIC(3),
 @An_Case_IDNO          NUMERIC(6),
 @An_PayorMCI_IDNO      NUMERIC(10),
 @Ac_Worker_ID          CHAR(30),
 @Ac_ReleasePeriod_CODE CHAR(2),
 @Ac_ReasonStatus_CODE  CHAR(4),
 @Ai_RowFrom_NUMB       INT = 1,
 @Ai_RowTo_NUMB         INT = 10
 )
AS
 /*
  *     PROCEDURE NAME    : RCTH_RETRIEVE_S3
  *     DESCRIPTION       : Retrieve Receipt details for a Case Id in an Ascending Order of Release Date.
  *     DEVELOPED BY      : IMP TEAM
  *     DEVELOPED ON      : 02-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Lc_StatusCaseOpen_CODE            CHAR(1) = 'O',
          @Lc_CaseRelationshipNcp_CODE       CHAR(1) = 'A',
          @Lc_CaseRelationshipPutFather_CODE CHAR(1) = 'P',
          @Lc_StatusReceiptHeld_CODE         CHAR(1) = 'H',
          @Lc_Yes_TEXT                       CHAR(1) = 'Y',
          @Lc_ReleasePeriod1_TEXT            CHAR(1) = '1',
          @Lc_ReleasePeriod2_TEXT            CHAR(1) = '2',
          @Lc_ReleasePeriod11_TEXT           CHAR(2) = '11',
          @Lc_ReleasePeriod30_TEXT           CHAR(2) = '30',
          @Lc_ReleasePeriod60_TEXT           CHAR(2) = '60',
          @Lc_ReleasePeriod1AndAbove_TEXT    CHAR(1) = 'S',
          @Li_Zero_NUMB                      INT = 0,
          @Li_ReleasePeriod1_NUMB            INT = 1,
          @Li_ReleasePeriod2_NUMB            INT = 2,
          @Li_ReleasePeriod10_NUMB           INT = 10,
          @Li_ReleasePeriod11_NUMB           INT = 11,
          @Li_ReleasePeriod30_NUMB           INT = 30,
          @Li_ReleasePeriod31_NUMB           INT = 31,
          @Li_ReleasePeriod60_NUMB           INT = 60,
          @Ld_Current_DATE                   DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
          @Ld_Low_DATE                       DATE = '01/01/0001',
          @Ld_High_DATE                      DATE = '12/31/9999';

  SELECT X.Batch_DATE,
         X.SourceBatch_CODE,
         X.Batch_NUMB,
         X.SeqReceipt_NUMB,
         X.Receipt_DATE,
         X.PayorMCI_IDNO,
         X.Case_IDNO,
         X.ToDistribute_AMNT,
         X.BeginValidity_DATE,
         X.Release_DATE,
         X.County_IDNO,
         X.Worker_ID,
         X.ReasonStatus_CODE,
         X.First_NAME,
         X.Middle_NAME,
         X.Last_NAME,
         X.Suffix_NAME,
         X.TypePosting_CODE,
         X.EventGlobalBeginSeq_NUMB,
         X.RowCount_NUMB,
         X.Total_AMNT
    FROM (SELECT H.Batch_DATE,
                 H.SourceBatch_CODE,
                 H.Batch_NUMB,
                 H.SeqReceipt_NUMB,
                 H.Receipt_DATE,
                 H.PayorMCI_IDNO,
                 H.Case_IDNO,
                 H.ToDistribute_AMNT,
                 H.BeginValidity_DATE,
                 H.Release_DATE,
                 H.County_IDNO,
                 G.Worker_ID,
                 H.ReasonStatus_CODE,
                 D.First_NAME,
                 D.Middle_NAME,
                 D.Last_NAME,
                 D.Suffix_NAME,
                 H.TypePosting_CODE,
                 H.EventGlobalBeginSeq_NUMB,
                 H.RowCount_NUMB,
                 H.Total_AMNT,
                 ROW_NUMBER() OVER ( ORDER BY H.ORD_ROWNUM ) AS ORD_ROWNUM
            FROM (SELECT X.Batch_DATE,
                         X.SourceBatch_CODE,
                         X.Batch_NUMB,
                         X.SeqReceipt_NUMB,
                         X.Receipt_DATE,
                         X.PayorMCI_IDNO,
                         X.Case_IDNO,
                         X.ToDistribute_AMNT,
                         X.BeginValidity_DATE,
                         X.Release_DATE,
                         X.County_IDNO,
                         X.ReasonStatus_CODE,
                         X.TypePosting_CODE,
                         X.EventGlobalBeginSeq_NUMB,
                         X.RowCount_NUMB,
                         X.Total_AMNT,
                         X.ORD_ROWNUM
                    FROM (SELECT C.Batch_DATE,
                                 C.SourceBatch_CODE,
                                 C.Batch_NUMB,
                                 C.SeqReceipt_NUMB,
                                 C.Receipt_DATE,
                                 C.PayorMCI_IDNO,
                                 C.Case_IDNO,
                                 C.ToDistribute_AMNT,
                                 C.BeginValidity_DATE,
                                 C.Release_DATE,
                                 A.County_IDNO,
                                 C.ReasonStatus_CODE,
                                 C.TypePosting_CODE,
                                 C.EventGlobalBeginSeq_NUMB,
                                 COUNT(1) OVER() AS RowCount_NUMB,
                                 SUM(C.ToDistribute_AMNT) OVER()AS Total_AMNT,
                                 ROW_NUMBER() OVER ( ORDER BY C.Release_DATE ASC, C.Batch_DATE, C.SourceBatch_CODE, C.Batch_NUMB, C.SeqReceipt_NUMB, C.EventGlobalBeginSeq_NUMB ) AS ORD_ROWNUM
                            FROM CASE_Y1 AS A,
                                 CMEM_Y1 AS B,
                                 RCTH_Y1 AS C
                           WHERE A.Worker_ID = @Ac_Worker_ID
                             AND A.County_IDNO = @An_County_IDNO
                             AND A.StatusCase_CODE = @Lc_StatusCaseOpen_CODE
                             AND B.Case_IDNO = A.Case_IDNO
                             AND B.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE)
                             AND C.PayorMCI_IDNO = b.MemberMci_IDNO
                             AND C.StatusReceipt_CODE = @Lc_StatusReceiptHeld_CODE
                             AND C.Distribute_DATE = @Ld_Low_DATE
                             AND C.EndValidity_DATE = @Ld_High_DATE
                             AND A.Case_IDNO = ISNULL(@An_Case_IDNO , A.Case_IDNO)
                             AND C.PayorMCI_IDNO = ISNULL(@An_PayorMCI_IDNO, C.PayorMCI_IDNO)
                             AND C.ReasonStatus_CODE = ISNULL(@Ac_ReasonStatus_CODE, C.ReasonStatus_CODE)
                             AND C.Release_DATE BETWEEN @Ad_From_DATE AND @Ad_To_DATE
                             AND NOT EXISTS (SELECT 1
                                               FROM RCTH_Y1 AS T
                                              WHERE T.Batch_DATE = c.Batch_DATE
                                                AND T.SourceBatch_CODE = c.SourceBatch_CODE
                                                AND T.Batch_NUMB = c.Batch_NUMB
                                                AND T.SeqReceipt_NUMB = c.SeqReceipt_NUMB
                                                AND T.BackOut_INDC = @Lc_Yes_TEXT
                                                AND T.EndValidity_DATE = @Ld_High_DATE)
                             AND (@Ac_ReleasePeriod_CODE IS NULL
                                   OR (@Ac_ReleasePeriod_CODE = @Lc_ReleasePeriod1_TEXT
                                       AND C.Release_DATE BETWEEN @Ld_Current_DATE AND DATEADD(dd, @Li_ReleasePeriod1_NUMB, @Ld_Current_DATE))
                                   OR (@Ac_ReleasePeriod_CODE = @Lc_ReleasePeriod2_TEXT
                                       AND C.Release_DATE BETWEEN DATEADD(dd, @Li_ReleasePeriod2_NUMB, @Ld_Current_DATE) AND DATEADD(dd, @Li_ReleasePeriod10_NUMB, @Ld_Current_DATE))
                                   OR (@Ac_ReleasePeriod_CODE = @Lc_ReleasePeriod11_TEXT
                                       AND C.Release_DATE BETWEEN DATEADD(dd, @Li_ReleasePeriod11_NUMB, @Ld_Current_DATE) AND DATEADD(dd, @Li_ReleasePeriod30_NUMB, @Ld_Current_DATE))
                                   OR (@Ac_ReleasePeriod_CODE = @Lc_ReleasePeriod30_TEXT
                                       AND C.Release_DATE BETWEEN DATEADD(dd, @Li_ReleasePeriod31_NUMB, @Ld_Current_DATE) AND DATEADD(dd, @Li_ReleasePeriod60_NUMB, @Ld_Current_DATE))
                                   OR (@Ac_ReleasePeriod_CODE = @Lc_ReleasePeriod60_TEXT
                                       AND C.Release_DATE > DATEADD(dd, @Li_ReleasePeriod60_NUMB, @Ld_Current_DATE))
                                   OR (@Ac_ReleasePeriod_CODE = @Lc_ReleasePeriod1AndAbove_TEXT
                                       AND C.Release_DATE >= DATEADD(dd, @Li_ReleasePeriod1_NUMB, @Ld_Current_DATE)))) AS X
                   WHERE X.ORD_ROWNUM <= @Ai_RowTo_NUMB) AS H,
                 GLEV_Y1 AS G,
                 DEMO_Y1 AS D
           WHERE H.PayorMCI_IDNO = D.MemberMci_IDNO
             AND H.ORD_ROWNUM >= @Ai_RowFrom_NUMB
             AND H.EventGlobalBeginSeq_NUMB = G.EventGlobalSeq_NUMB) AS X;
 END


GO
