/****** Object:  StoredProcedure [dbo].[AMJR_RETRIEVE_S16]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[AMJR_RETRIEVE_S16] (
 @Ac_Subsystem_CODE                CHAR(2),
 @An_Case_IDNO                     NUMERIC(6, 0),
 @Ai_StatusCaseCount_QNTY          INT,
 @Ai_StatusEnforceCloseCount_QNTY  INT,
 @Ai_StatusEnforceExemptCount_QNTY INT,
 @Ai_StatusSordCount_QNTY          INT
 )
AS
 /*                                                                                                                                                                                                                       
  *     PROCEDURE NAME    : AMJR_RETRIEVE_S16                                                                                                                                                                             
  *     DESCRIPTION       : Retrieve total number of Completed , started count for Each Remedies for a given subsystem and Retrives last 
                            Post Details and exempt status for Each Remedies.                                                                                                                                                
  *     DEVELOPED BY      : IMP Team                                                                                                                                                                                      
  *     DEVELOPED ON      : 02-AUG-2011                                                                                                                                                                                   
  *     MODIFIED BY       :                                                                                                                                                                                               
  *     MODIFIED ON       :                                                                                                                                                                                               
  *     VERSION NO        : 1                                                                                                                                                                                             
  */
 BEGIN
  DECLARE @Li_Zero_NUMB              SMALLINT = 0,
          @Li_One_NUMB               SMALLINT = 1,
          @Lc_TypeCaseNonIvd_CODE    CHAR(1) = 'H',
          @Lc_No_INDC                CHAR(1) = 'N',
          @Lc_Yes_INDC               CHAR(1) = 'Y',
          @Lc_FlagDisable_INDC       CHAR(1) = 'D',
          @Lc_FlagEnable_INDC        CHAR(1) = 'E',
          @Lc_NULL_TEXT              CHAR(1) = NULL,
          @Lc_No_TEXT                CHAR(2) = 'No',
          @Lc_Yes_TEXT               CHAR(3) = 'Yes',
          @Lc_ActivityMajorCase_CODE CHAR(4) = 'CASE',
          @Lc_StatusComplete_CODE    CHAR(4) = 'COMP',
          @Lc_StatusExempt_CODE      CHAR(4) = 'EXMT',
          @Lc_StatusStart_CODE       CHAR(4) = 'STRT',
          @Lc_TableCpro_ID           CHAR(4) = 'CPRO',
          @Lc_ActivityMajorAren_CODE CHAR(4) = 'AREN',
          @Lc_ActivityMajorCpls_CODE CHAR(4) = 'CPLS',
          @Lc_TableSubNonIvd_ID      CHAR(4) = 'NIVD',
          @Ld_High_DATE              DATE	 = '12/31/9999';

  SELECT y.ActivityMajor_CODE,
         CASE
          WHEN z.TypeCase_CODE = @Lc_TypeCaseNonIvd_CODE
               AND EXISTS (SELECT 1
                             FROM REFM_Y1 r
                            WHERE r.Table_ID = @Lc_TableCpro_ID
                              AND r.TableSub_ID = @Lc_TableSubNonIvd_ID
                              AND r.Value_CODE = y.ActivityMajor_CODE)
           THEN @Lc_No_INDC
          WHEN (y.Stop_INDC = @Lc_Yes_INDC
                 OR y.major_status_exempt = @Lc_Yes_INDC
                 OR @Ai_StatusCaseCount_QNTY = @Li_Zero_NUMB
                 OR @Ai_StatusEnforceCloseCount_QNTY > = @Li_One_NUMB)
           THEN @Lc_No_INDC
          -- 13383 - CR0379 Capias License Suspension on Non-Ordered Cases - Start
          WHEN y.ActivityMajor_CODE = @Lc_ActivityMajorCpls_CODE
           AND EXISTS (SELECT 1
						 FROM SORD_Y1 s
						WHERE s.Case_IDNO = @An_Case_IDNO
						  AND s.EndValidity_DATE = @Ld_High_DATE)
			THEN @Lc_No_INDC
		  -- 13383 - CR0379 Capias License Suspension on Non-Ordered Cases - End
          WHEN y.Stop_INDC = @Lc_No_INDC
               AND y.MultipleActiveInstance_INDC = @Lc_No_INDC
               AND ActiveRemedyCount_QNTY = @Li_Zero_NUMB
           THEN @Lc_Yes_INDC
          WHEN y.Stop_INDC = @Lc_No_INDC
               AND y.MultipleActiveInstance_INDC = @Lc_No_INDC
               AND ActiveRemedyCount_QNTY > @Li_Zero_NUMB
           THEN @Lc_No_INDC
          WHEN y.Stop_INDC = @Lc_No_INDC
               AND y.MultipleActiveInstance_INDC = @Lc_Yes_INDC
           THEN @Lc_Yes_INDC
         END AS StartNewRemedy_INDC,
         CASE y.major_status_exempt
          WHEN @Lc_Yes_INDC
           THEN @Lc_Yes_TEXT
          ELSE @Lc_No_TEXT
         END AS ExemptRemedy_INDC,
         CASE
          WHEN (@Ai_StatusCaseCount_QNTY = @Li_Zero_NUMB
                 OR @Ai_StatusSordCount_QNTY = @Li_Zero_NUMB
                 OR @Ai_StatusEnforceCloseCount_QNTY = @Li_One_NUMB
                 OR @Ai_StatusEnforceExemptCount_QNTY = @Li_One_NUMB)
           THEN @Lc_FlagDisable_INDC
          WHEN (y.ActivityMajor_CODE = @Lc_ActivityMajorAren_CODE)
           THEN @Lc_FlagDisable_INDC
          ELSE @Lc_FlagEnable_INDC
         END AS EnableExempt_INDC,
         ActiveRemedyCount_QNTY,
         CompletedRemedyCount_QNTY,
         m.MajorIntSeq_NUMB,
         y.Forum_IDNO,
         y.Topic_IDNO,
         m.ActivityMinor_CODE,
         dbo.BATCH_COMMON$SF_GET_UNCHECKED_FORMS(m.Topic_IDNO, @Lc_NULL_TEXT, @An_Case_IDNO, @Lc_NULL_TEXT) AS DescriptionUnCheckedNotices_TEXT,
         n.DescriptionNote_TEXT,
         ISNULL(m.LastPost_DTTM, @Ld_High_DATE) AS Entered_DATE,
         CASE
          WHEN ActiveRemedyCount_QNTY = @Li_Zero_NUMB
               AND CompletedRemedyCount_QNTY = @Li_Zero_NUMB
           THEN @Lc_NULL_TEXT
          ELSE
           CASE
            WHEN (m.UserLastPoster_ID IS NULL)
             THEN @Lc_NULL_TEXT
            ELSE m.UserLastPoster_ID
           END
         END AS UserLastPoster_ID
    FROM (SELECT o.ActivityMajor_CODE,
                 o.DescriptionActivityMajor_TEXT,
                 o.Stop_INDC,
                 o.MultipleActiveInstance_INDC,
                 o.ActiveRemedyCount_QNTY,
                 o.CompletedRemedyCount_QNTY,
                 dbo.BATCH_COMMON$SF_GET_EXEMPT_STATUS(@An_Case_IDNO, o.ActivityMajor_CODE) AS major_status_exempt,
                 (SELECT r.Forum_IDNO
                    FROM DMNR_Y1 r
                   WHERE r.Case_IDNO = @An_Case_IDNO
                     AND r.Topic_IDNO = (SELECT MAX(n.Topic_IDNO)
                                           FROM DMNR_Y1 n
                                          WHERE n.Case_IDNO = @An_Case_IDNO
                                            AND n.MajorIntSeq_NUMB IN (SELECT d.MajorIntSeq_NUMB
                                                                         FROM DMJR_Y1 d
                                                                        WHERE d.Case_IDNO = @An_Case_IDNO
                                                                          AND d.ActivityMajor_CODE = o.ActivityMajor_CODE
                                                                          AND d.Status_CODE != @Lc_StatusExempt_CODE))) AS Forum_IDNO,
                 (SELECT MAX(d.Topic_IDNO)
                    FROM DMNR_Y1 d
                   WHERE d.Case_IDNO = @An_Case_IDNO
                     AND d.MajorIntSeq_NUMB IN (SELECT a.MajorIntSeq_NUMB
                                                  FROM DMJR_Y1 a
                                                 WHERE a.Case_IDNO = @An_Case_IDNO
                                                   AND a.ActivityMajor_CODE = o.ActivityMajor_CODE
                                                   AND a.Status_CODE != @Lc_StatusExempt_CODE)) AS Topic_IDNO
            FROM (SELECT x.ActivityMajor_CODE,
                         x.DescriptionActivity_TEXT AS DescriptionActivityMajor_TEXT,
                         x.Stop_INDC,
                         x.MultipleActiveInstance_INDC,
                         ISNULL(y.MajorStatusCountStrt_QNTY, @Li_Zero_NUMB) AS ActiveRemedyCount_QNTY,
                         ISNULL(y.MajorStatusCountComp_QNTY, @Li_Zero_NUMB) AS CompletedRemedyCount_QNTY,
                         ISNULL(y.major_status_count_exmt, @Li_Zero_NUMB) AS exempted_remedy_count,
                         ROW_NUMBER() OVER( ORDER BY x.ActivityMajor_CODE) AS ORD_ROWNUM
                    FROM (SELECT a.ActivityMajor_CODE,
                                 a.DescriptionActivity_TEXT,
                                 a.Stop_INDC,
                                 a.MultipleActiveInstance_INDC
                            FROM AMJR_Y1 a
                           WHERE a.EndValidity_DATE = @Ld_High_DATE
                             AND a.Subsystem_CODE = @Ac_Subsystem_CODE
                             AND a.ActivityMajor_CODE NOT IN (@Lc_ActivityMajorCase_CODE)) AS x
                         LEFT OUTER JOIN (SELECT X.ActivityMajor_CODE,
                                                 MAX(CASE X.Status_CODE
                                                      WHEN @Lc_StatusStart_CODE
                                                       THEN X.remedy_status_count
                                                      ELSE @Li_Zero_NUMB
                                                     END) AS MajorStatusCountStrt_QNTY,
                                                 MAX(CASE X.Status_CODE
                                                      WHEN @Lc_StatusComplete_CODE
                                                       THEN X.remedy_status_count
                                                      ELSE @Li_Zero_NUMB
                                                     END) AS MajorStatusCountComp_QNTY,
                                                 MAX(CASE X.Status_CODE
                                                      WHEN @Lc_StatusExempt_CODE
                                                       THEN X.remedy_status_count
                                                      ELSE @Li_Zero_NUMB
                                                     END) AS major_status_count_exmt
                                            FROM (SELECT j.ActivityMajor_CODE,
                                                         j.Status_CODE,
                                                         COUNT(j.Status_CODE) AS remedy_status_count
                                                    FROM DMJR_Y1 j
                                                   WHERE j.Case_IDNO = @An_Case_IDNO
                                                     AND j.Subsystem_CODE = @Ac_Subsystem_CODE
                                                   GROUP BY j.ActivityMajor_CODE,
                                                            j.Status_CODE) AS X
                                           GROUP BY X.ActivityMajor_CODE) AS y
                          ON x.ActivityMajor_CODE = y.ActivityMajor_CODE) AS o) AS y
         LEFT OUTER JOIN DMNR_Y1 m
          ON y.Forum_IDNO = m.Forum_IDNO
             AND y.Topic_IDNO = m.Topic_IDNO
             AND m.Case_IDNO = @An_Case_IDNO
         LEFT JOIN NOTE_Y1 n
          ON n.Topic_IDNO = m.Topic_IDNO
             AND n.Case_IDNO = @An_Case_IDNO
             AND n.Post_IDNO <= @Li_One_NUMB
             AND n.EndValidity_DATE = @Ld_High_DATE,
         CASE_Y1 z
   WHERE z.Case_IDNO = @An_Case_IDNO
   ORDER BY y.ActivityMajor_CODE;
 END


GO
