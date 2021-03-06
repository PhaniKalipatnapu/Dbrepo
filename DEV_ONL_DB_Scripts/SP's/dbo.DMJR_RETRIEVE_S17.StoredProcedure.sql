/****** Object:  StoredProcedure [dbo].[DMJR_RETRIEVE_S17]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DMJR_RETRIEVE_S17] (
 @An_Case_IDNO          NUMERIC(6),
 @Ac_ActivityMajor_CODE CHAR(4),
 @Ac_Status_CODE        CHAR(4)
 )
AS
 /*  
  *     PROCEDURE NAME    : DMJR_RETRIEVE_S17  
  *     DESCRIPTION       : Retrieves Remedy details for the given Case ID, status and Major Activity code  
  *     DEVELOPED BY      : IMP Team    
  *     DEVELOPED ON      : 09-AUG-2011  
  *     MODIFIED BY       :   
  *     MODIFIED ON       :   
  *     VERSION NO        : 1  
  */
 BEGIN
  DECLARE @Li_Zero_NUMB                         SMALLINT = 0,
          @Lc_Empty_TEXT                        CHAR(1) = '',
		  @Lc_Space_TEXT                        CHAR(1) = ' ',
		  @Lc_TypeOthpSourceA_CODE				CHAR(1) = 'A',
		  @Lc_TypeOthpSourceC_CODE				CHAR(1) = 'C',
		  @Lc_TypeOthpSourceD_CODE				CHAR(1) = 'D',
		  @Lc_TypeOthpSourceP_CODE				CHAR(1) = 'P',
          @Lc_ApptStatusRs_CODE                 CHAR(2) = 'RS',
          @Lc_ApptStatusSc_CODE                 CHAR(2) = 'SC',
          @Lc_HyphenWithSpace_TEXT              CHAR(3) = ' - ',
          @Lc_TableCpro_ID                      CHAR(4) = 'CPRO',
          @Lc_TableSubReas_ID                   CHAR(4) = 'REAS',
          @Lc_ActivityMajorCrpt_CODE            CHAR(4) = 'CRPT',
          @Lc_ActivityMajorCclo_CODE            CHAR(4) = 'CCLO',
          @Lc_ActivityMajorRofo_CODE            CHAR(4) = 'ROFO',
          @Lc_ActivityMajorImiw_CODE            CHAR(4) = 'IMIW',
          @Lc_ActivityMajorLsnr_CODE            CHAR(4) = 'LSNR',
          @Lc_ActivityMajorCase_CODE            CHAR(4) = 'CASE',
          @Lc_JobBatchEnforcementCbtw_ID        CHAR(7) = 'DEB5360',
          @Lc_DateFormatMmDdYyyy_TEXT           CHAR(10)= 'MM/DD/YYYY',
          @Lc_CreditBureau1_TEXT				CHAR(34)= ' - Submitted to Credit Bureau on ',
          @Lc_CreditBureau2_TEXT				CHAR(34)= ' and the Arrear amount reported is ',
          @Ld_Low_DATE							DATE	= '01/01/0001',
          @Ld_High_DATE                         DATE	= '12/31/9999';

  SELECT m.MajorIntSeq_NUMB,
         m.ActivityMajor_CODE,
         m.Status_CODE,
         m.ReasonStatus_CODE,	
         m.Forum_IDNO,
         m.OthpSource_IDNO,
         CASE
          WHEN m.ActivityMajor_CODE = @Lc_ActivityMajorRofo_CODE
          THEN dbo.BATCH_COMMON$SF_GET_FIPS_NAME(m.Reference_ID)
         ELSE ISNULL((SELECT o.OtherParty_NAME
                   FROM OTHP_Y1 o
                  WHERE o.OtherParty_IDNO = m.OthpSource_IDNO
					AND ( m.TypeOthpSource_CODE NOT IN (@Lc_TypeOthpSourceA_CODE,@Lc_TypeOthpSourceC_CODE,@Lc_TypeOthpSourceD_CODE,@Lc_TypeOthpSourceP_CODE)
						 OR m.ActivityMajor_CODE IN (@Lc_ActivityMajorImiw_CODE, @Lc_ActivityMajorLsnr_CODE))
                    AND o.EndValidity_DATE = @Ld_High_DATE), dbo.BATCH_COMMON_GETS$SF_GET_MEMBER_NAME(m.OthpSource_IDNO)) 
         END AS OtherParty_NAME,
         m.TypeOthpSource_CODE,
         m.Entered_DATE,
         m.Status_DATE,
         m.TypeReference_CODE,
         CASE
          WHEN m.ActivityMajor_CODE = @Lc_ActivityMajorCclo_CODE
              AND m.Reference_ID != @Lc_Empty_TEXT
           THEN (SELECT RTRIM(d.Value_CODE) + @Lc_HyphenWithSpace_TEXT + d.DescriptionValue_TEXT
                   FROM REFM_Y1 d
                  WHERE d.Table_ID = @Lc_TableCpro_ID
                    AND d.TableSub_ID = @Lc_TableSubReas_ID
                    AND d.Value_CODE = m.Reference_ID)
          ELSE m.Reference_ID
         END AS Reference_ID,
         m.TransactionEventSeq_NUMB,
         dbo.BATCH_COMMON$SF_GET_UNCHECKED_FORMS(m.Topic_IDNO, NULL, @An_Case_IDNO, NULL) AS DescriptionUnCheckedNotices_TEXT,
         m.Topic_IDNO,
         m.ActivityMinor_CODE,
         CASE
          WHEN m.ActivityMajor_CODE = @Lc_ActivityMajorCrpt_CODE
           THEN ISNULL(m.UserLastPoster_ID, @Lc_Empty_TEXT) + ISNULL((SELECT CASE WHEN C.BeginValidity_DATE = @Ld_Low_DATE 
																				  THEN @Lc_Empty_TEXT
																				  ELSE @Lc_CreditBureau1_TEXT + ISNULL(CONVERT(VARCHAR,C.BeginValidity_DATE,101), @Lc_Empty_TEXT) + @Lc_CreditBureau2_TEXT + ISNULL(CAST(C.Arrear_AMNT AS NVARCHAR(MAX)), @Lc_Empty_TEXT)
																			  END
                                                                        FROM CBOR_Y1 C
                                                                       WHERE C.Case_IDNO = @An_Case_IDNO
                                                                         AND C.MemberMci_IDNO = m.MemberMci_IDNO
                                                                         AND C.TransactionEventSeq_NUMB = (SELECT MAX(X.TransactionEventSeq_NUMB)
                                                                                                             FROM CBOR_Y1 X
                                                                                                            WHERE X.Case_IDNO = @An_Case_IDNO
                                                                                                              AND X.MemberMci_IDNO = m.MemberMci_IDNO
                                                                                                              AND X.EndValidity_DATE <= (SELECT P.Run_DATE
                                                                                                                                           FROM PARM_Y1 P
                                                                                                                                          WHERE P.Job_ID = @Lc_JobBatchEnforcementCbtw_ID
                                                                                                                                            AND P.EndValidity_DATE = @Ld_High_DATE))), @Lc_Empty_TEXT)
          ELSE m.UserLastPoster_ID
         END AS UserLastPoster_ID,
         m.LastPost_DTTM,
         m.DescriptionNote_TEXT,
         (SELECT MAX(Petition_IDNO)
            FROM FDEM_Y1 F
           WHERE F.Case_IDNO = @An_Case_IDNO
             AND F.MajorIntSeq_NUMB = m.MajorIntSeq_NUMB
             AND F.EndValidity_DATE = @Ld_High_DATE) AS Petition_IDNO,
         (SELECT ISNULL(MAX(n.Schedule_NUMB), @Li_Zero_NUMB)
            FROM DMNR_Y1 n
                 JOIN SWKS_Y1 s
                  ON n.Schedule_NUMB = s.Schedule_NUMB
           WHERE n.Case_IDNO = s.Case_IDNO
             AND n.MajorIntSeq_NUMB = m.MajorIntSeq_NUMB
             AND s.ApptStatus_CODE IN (@Lc_ApptStatusSc_CODE, @Lc_ApptStatusRs_CODE)
             AND n.Case_IDNO = @An_Case_IDNO
             AND s.Worker_ID != @Lc_Space_TEXT
             AND n.ActivityMajor_CODE != @Lc_ActivityMajorCase_CODE) AS Schedule_NUMB
    FROM (SELECT j.MajorIntSeq_NUMB,
                 j.ReasonStatus_CODE,
                 j.OthpSource_IDNO,
                 j.TypeOthpSource_CODE,
                 j.ActivityMajor_CODE,
                 j.Status_CODE,
                 j.Forum_IDNO,
                 j.Entered_DATE,
                 j.Status_DATE,
                 j.TypeReference_CODE,
                 j.Reference_ID,
                 j.TransactionEventSeq_NUMB,
                 j.MemberMci_IDNO,
                 MAX(k.Topic_IDNO) OVER(PARTITION BY k.MajorIntSeq_NUMB,k.Forum_IDNO) AS MaxTopic_IDNO,
                 k.Topic_IDNO,
                 k.ActivityMinor_CODE,
                 k.UserLastPoster_ID,
                 k.LastPost_DTTM,
                 l.DescriptionNote_TEXT
            FROM DMJR_Y1 j
			JOIN DMNR_Y1 k
			  ON j.Case_IDNO = k.Case_IDNO
			 AND k.Status_CODE = @Ac_Status_CODE
             AND j.MajorIntSeq_NUMB = k.MajorIntSeq_NUMB
            LEFT JOIN NOTE_Y1 l
              ON k.Case_IDNO = l.Case_IDNO
             AND k.Topic_IDNO = l.Topic_IDNO
             AND k.PostLastPoster_IDNO = l.Post_IDNO
             AND l.EndValidity_DATE = @Ld_High_DATE
           WHERE j.Case_IDNO = @An_Case_IDNO
             AND j.ActivityMajor_CODE = @Ac_ActivityMajor_CODE
             AND j.Status_CODE = @Ac_Status_CODE) AS m
   WHERE m.Topic_IDNO = m.MaxTopic_IDNO
   ORDER BY MajorIntSeq_NUMB DESC;
 END; --END OF DMJR_RETRIEVE_S17  


GO
