/****** Object:  StoredProcedure [dbo].[DMNR_RETRIEVE_S116]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DMNR_RETRIEVE_S116](
 @An_Case_IDNO          NUMERIC(6),
 @An_MajorIntSeq_NUMB   NUMERIC(5),
 @Ac_ActivityMajor_CODE CHAR(4)
 )
AS
 /*  
 *     PROCEDURE NAME    : DMNR_RETRIEVE_S116  
 *     DESCRIPTION       : Retrieves the minor activity details for the given case idno,  major activity code and the majoe int seq number.
 *     DEVELOPED BY      : IMP team  
 *     DEVELOPED ON      : 17-AUG-2011  
 *     MODIFIED BY       :   
 *     MODIFIED ON       :   
 *     VERSION NO        : 1  
 */
 BEGIN
  DECLARE @Li_Zero_NUMB                             SMALLINT = 0,
          @Li_One_NUMB                              SMALLINT = 1,
          @Lc_No_INDC                               CHAR(1) = 'N',
          @Lc_ExecutionOrderS_TEXT                  CHAR(1) = 'S',
          @Lc_RespManSysSystem_CODE                 CHAR(1) = 'S',
          @Lc_Yes_INDC                              CHAR(1) = 'Y',
          @Lc_Space_TEXT                            CHAR(1) = ' ',
          @Lc_NULL_TEXT                             CHAR(1) = NULL,
          @Lc_HyphenWithSpace_TEXT                  CHAR(3) = ' - ',
          @Lc_TableCpro_ID                          CHAR(4) = 'CPRO',
          @Lc_TableSubAgrp_ID                       CHAR(4) = 'AGRP',
          @Lc_ActivityMajorCclo_CODE                CHAR(4) = 'CCLO',
          @Lc_StatusStrt_CODE                       CHAR(4) = 'STRT',
          @Lc_StatusComp_CODE                       CHAR(4) = 'COMP',
          @Lc_TableSubReas_ID                       CHAR(4) = 'REAS',
          @Lc_ActivityMinorCsfcc_CODE               CHAR(5) = 'CSFCC',
          @Lc_ActivityMinorRmdcy_CODE               CHAR(5) = 'RMDCY',
          @Lc_ValueGclac_CODE                       CHAR(5) = 'GCLAC',
          @Lc_StatusCodeCompleted_TEXT              CHAR(9) = 'COMPLETED',
          @Lc_StatusCodeInProgress_TEXT             CHAR(11) = 'IN PROGRESS',
          @Lc_ActivityMinorRemedyClosed_CODE        CHAR(13) = 'REMEDY CLOSED',
          @Lc_StatusCodeNotYetStarted_TEXT          CHAR(15) = 'NOT YET STARTED',
          @Lc_ActivityMinorActivityChainClosed_CODE CHAR(21) = 'Activity chain closed',
          @Lc_ActivityChainCloses_TEXT              CHAR(21) = 'Activity Chain Closes',
          @Ld_High_DATE                             DATE = '12/31/9999',
          @Ld_Current_DATE                          DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

  SELECT q.DescriptionValue_TEXT,
         q.Action_TEXT,
         q.Result_TEXT,
         q.WaitTime_QNTY,
         UPPER(q.StatusCode_TEXT)AS StatusCode_TEXT,
         q.ActivityMinor_CODE,
         q.Entered_DATE,
         q.Status_DATE,
         q.Due_DATE,
         q.TransactionEventSeq_NUMB,
         q.MinorIntSeq_NUMB,
         q.IsBold_INDC,
         q.Visibility_INDC
    FROM (SELECT ISNULL((SELECT DISTINCT f.DescriptionValue_TEXT
                           FROM ANXT_Y1 t
                                JOIN REFM_Y1 f
                                 ON f.Value_Code = t.Group_ID
                          WHERE t.ActivityMajor_CODE = @Ac_ActivityMajor_CODE
                            AND f.Table_ID = @Lc_TableCpro_ID
                            AND f.TableSub_ID = @Lc_TableSubAgrp_ID
                            AND t.EndValidity_DATE = @Ld_High_DATE
                            AND t.ActivityMinor_CODE = a.ActivityMinor_CODE), (SELECT r.DescriptionValue_TEXT
                                                                                 FROM REFM_Y1 r
                                                                                WHERE r.Table_ID = @Lc_TableCpro_ID
                                                                                  AND r.TableSub_ID = @Lc_TableSubAgrp_ID
                                                                                  AND r.Value_Code = @Lc_ValueGclac_CODE)) AS DescriptionValue_TEXT,
                 a.Action_TEXT,
                 a.Result_TEXT,
                 a.WaitTime_QNTY,
                 a.StatusCode_TEXT,
                 a.ActivityMinor_CODE,
                 a.Entered_DATE,
                 a.Status_DATE,
                 a.Due_DATE,
                 a.BudgetDate_NUMB,
                 a.TransactionEventSeq_NUMB,
                 a.MinorIntSeq_NUMB,
                 ISNULL((SELECT TOP 1 x.ActivityOrder_QNTY
                           FROM ANXT_Y1 x
                          WHERE x.ActivityMinor_CODE = a.ActivityMinor_CODE
                            AND x.ActivityMajor_CODE = @Ac_ActivityMajor_CODE), (SELECT MAX(t.ActivityOrder_QNTY) + 1
                                                                                   FROM ANXT_Y1 t
                                                                                  WHERE t.ActivityMajor_CODE = @Ac_ActivityMajor_CODE)) AS ActivityOrder_QNTY,
                 CASE
                  WHEN a.ActivityMinor_CODE IN (SELECT o.ActivityMinorNext_CODE
                                                  FROM ANXT_Y1 o
                                                 WHERE o.ActivityMajor_CODE = b.ActivityMajor_CODE
                                                   AND o.ActivityMinor_CODE = b.ActivityMinor_CODE
                                                   AND o.EndValidity_DATE = @Ld_High_DATE
                                                EXCEPT
                                                SELECT DISTINCT p.ActivityMinorNext_CODE
                                                  FROM ANXT_Y1 p
                                                 WHERE p.ActivityMajor_CODE = @Lc_ActivityMajorCclo_CODE
                                                   AND p.RespManSys_CODE = @Lc_RespManSysSystem_CODE
                                                   AND p.ActivityMinor_CODE = @Lc_ActivityMinorCsfcc_CODE
                                                   AND p.ActivityMinor_CODE = b.ActivityMinor_CODE
                                                   AND p.EndValidity_DATE = @Ld_High_DATE)
                       AND a.StatusCode_TEXT IN (@Lc_StatusCodeNotYetStarted_TEXT, @Lc_StatusCodeInProgress_TEXT, @Lc_StatusCodeCompleted_TEXT)
                   THEN @Lc_Yes_INDC
                  WHEN a.StatusCode_TEXT = @Lc_StatusCodeInProgress_TEXT
                   THEN @Lc_Yes_INDC
                  ELSE @Lc_No_INDC
                 END IsBold_INDC,
                 a.Visibility_INDC,
                 ROW_NUMBER() OVER (PARTITION BY a.ActivityMinor_CODE, a.Action_TEXT ORDER BY a.TransactionEventSeq_NUMB DESC) Row_NUMB
            FROM (SELECT s.Action_TEXT,
                         s.Result_TEXT,
                         s.WaitTime_QNTY,
                         s.StatusCode_TEXT,
                         s.ActivityMinor_CODE,
                         s.Entered_DATE,
                         s.Status_DATE,
                         s.Due_DATE,
                         s.BudgetDate_NUMB,
                         s.TransactionEventSeq_NUMB,
                         s.MinorIntSeq_NUMB,
                         s.IsBold_INDC,
                         s.Visibility_INDC
                    FROM (SELECT n.DescriptionActivity_TEXT AS Action_TEXT,
                                 @Lc_NULL_TEXT AS Result_TEXT,
                                 @Li_Zero_NUMB AS WaitTime_QNTY,
                                 @Lc_StatusCodeNotYetStarted_TEXT AS StatusCode_TEXT,
                                 a.ActivityMinor_CODE AS ActivityMinor_CODE,
                                 @Ld_High_DATE AS Entered_DATE,
                                 @Ld_High_DATE AS Status_DATE,
                                 @Ld_High_DATE AS Due_DATE,
                                 @Li_Zero_NUMB AS BudgetDate_NUMB,
                                 @Li_Zero_NUMB AS TransactionEventSeq_NUMB,
                                 @Li_Zero_NUMB AS MinorIntSeq_NUMB,
                                 @Lc_No_INDC AS IsBold_INDC,
                                 @Lc_Yes_INDC AS Visibility_INDC
                            FROM ANXT_Y1 a
                                 JOIN AMNR_Y1 n
                                  ON a.ActivityMinor_CODE = n.ActivityMinor_CODE
                           WHERE a.ActivityMajor_CODE = @Ac_ActivityMajor_CODE
                             AND n.EndValidity_DATE = @Ld_High_DATE
                             AND a.EndValidity_DATE = @Ld_High_DATE
                          UNION
                          SELECT @Lc_ActivityChainCloses_TEXT,
                                 @Lc_NULL_TEXT AS Result_TEXT,
                                 @Li_Zero_NUMB AS WaitTime_QNTY,
                                 @Lc_StatusCodeNotYetStarted_TEXT AS StatusCode_TEXT,
                                 @Lc_ActivityMinorRmdcy_CODE,
                                 @Ld_High_DATE AS Entered_DATE,
                                 @Ld_High_DATE AS Status_DATE,
                                 @Ld_High_DATE AS Due_DATE,
                                 @Li_Zero_NUMB AS BudgetDate_NUMB,
                                 @Li_Zero_NUMB AS TransactionEventSeq_NUMB,
                                 @Li_Zero_NUMB AS MinorIntSeq_NUMB,
                                 @Lc_No_INDC AS IsBold_INDC,
                                 @Lc_Yes_INDC AS Visibility_INDC) s
                  UNION
                  (SELECT CASE
                           WHEN g.ActivityCount_QNTY != @Li_One_NUMB
                            THEN g.Action_TEXT + @Lc_Space_TEXT + '(' + CONVERT(CHAR, g.ActivityCount_QNTY) + ')'
                           ELSE g.Action_TEXT
                          END Action_TEXT,
                          g.Result_TEXT,
                          g.WaitTime_QNTY,
                          g.StatusCode_TEXT,
                          g.ActivityMinor_CODE,
                          g.Entered_DATE,
                          g.Status_DATE,
                          g.Due_DATE,
                          g.BudgetDate_NUMB,
                          g.TransactionEventSeq_NUMB,
                          g.MinorIntSeq_NUMB,
                          @Lc_No_INDC AS IsBold_INDC,
                          CASE
                           WHEN g.LastMinorIntSeq_NUMB = g.MinorIntSeq_NUMB 
                           THEN g.Visibility_INDC
                           ELSE @Lc_No_INDC
                          END Visibility_INDC
                     FROM (SELECT (SELECT w.DescriptionActivity_TEXT
                                     FROM AMNR_Y1 w
                                    WHERE w.ActivityMinor_CODE = n.ActivityMinor_CODE
                                      AND w.EndValidity_DATE = @Ld_High_DATE) Action_TEXT,
                                  CASE
                                   WHEN (n.ActivityMinor_CODE) = @Lc_ActivityMinorRmdcy_CODE
                                    THEN @Lc_ActivityMinorActivityChainClosed_CODE
                                   WHEN (n.Status_CODE) = @Lc_StatusStrt_CODE
                                    THEN @Lc_StatusCodeInProgress_TEXT
                                   ELSE (SELECT TOP 1 r.DescriptionValue_TEXT
                                           FROM REFM_Y1 r
                                          WHERE r.Value_CODE = n.reasonStatus_CODE
                                            AND Table_ID = @Lc_TableCpro_ID
                                            AND TableSub_ID = @Lc_TableSubReas_ID) + @Lc_HyphenWithSpace_TEXT + (SELECT TOP 1 x.DescriptionActivity_TEXT
                                                                                                                   FROM AMNR_Y1 x
                                                                                                                  WHERE x.ActivityMinor_CODE = n.ActivityMinorNext_CODE
                                                                                                                    AND EndValidity_DATE = @Ld_High_DATE)
                                  END Result_TEXT,
                                  CASE
                                   WHEN (n.Status_CODE) = @Lc_StatusComp_CODE
                                    THEN DATEDIFF(DAY, Entered_DATE, Status_DATE)
                                   WHEN (n.Status_CODE) != @Lc_StatusComp_CODE
                                    THEN DATEDIFF(DAY, Entered_DATE, @Ld_Current_DATE)
                                  END WaitTime_QNTY,
                                  CASE
                                   WHEN (n.ActivityMinor_CODE) = @Lc_ActivityMinorRmdcy_CODE
                                    THEN @Lc_ActivityMinorRemedyClosed_CODE
                                   WHEN (n.Status_CODE) = @Lc_StatusComp_CODE
                                    THEN @Lc_StatusCodeCompleted_TEXT
                                   WHEN (n.Status_CODE) = @Lc_StatusStrt_CODE
                                    THEN @Lc_StatusCodeInProgress_TEXT
                                  END StatusCode_TEXT,
                                  n.ActivityMinor_CODE,
                                  n.Entered_DATE,
                                  n.Status_DATE,
                                  n.Due_DATE,
                                  @Li_Zero_NUMB BudgetDate_NUMB,
                                  n.TransactionEventSeq_NUMB,
                                  n.MinorIntSeq_NUMB,
                                  @Lc_ExecutionOrderS_TEXT AS ExecutionOrder_TEXT,
                                  @Lc_Yes_INDC AS  Visibility_INDC,
                                  ROW_NUMBER() OVER(PARTITION BY n.ActivityMinor_CODE ORDER BY n.MinorIntSeq_NUMB)ActivityCount_QNTY,
                                  MAX(n.MinorIntSeq_NUMB) OVER(PARTITION BY n.ActivityMinor_CODE) AS LastMinorIntSeq_NUMB
                             FROM DMNR_Y1 n
                            WHERE n.Case_IDNO = @An_Case_IDNO
                              AND n.MajorIntSeq_NUMB = @An_MajorIntSeq_NUMB
                              AND n.ActivityMajor_CODE = @Ac_ActivityMajor_CODE
                              AND (SELECT DISTINCT ActivityMajor_CODE
                                     FROM DMJR_Y1 v
                                    WHERE v.Case_IDNO = @An_Case_IDNO
                                      AND v.MajorIntSeq_NUMB = @An_MajorIntSeq_NUMB
                                      AND v.ActivityMajor_CODE = @Ac_ActivityMajor_CODE) = @Ac_ActivityMajor_CODE)g
                    )) a
                 OUTER APPLY (SELECT q.ActivityMajor_CODE,
                                     q.ActivityMinor_CODE
                                FROM DMNR_Y1 q
                               WHERE q.Case_IDNO = @An_Case_IDNO
                                 AND q.MajorIntSeq_NUMB = @An_MajorIntSeq_NUMB
                                 AND q.ActivityMajor_CODE = @Ac_ActivityMajor_CODE
                                 AND Status_CODE IN (@Lc_StatusStrt_CODE)) b)q
   WHERE q.Row_NUMB = @Li_One_NUMB
   ORDER BY q.ActivityOrder_QNTY,
            q.MinorIntSeq_NUMB;
 END; --End of DMNR_RETRIEVE_S116

GO
