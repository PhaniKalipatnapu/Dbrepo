/****** Object:  StoredProcedure [dbo].[AFMS_RETRIEVE_S23]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[AFMS_RETRIEVE_S23] (
 @An_Case_IDNO              NUMERIC(6),
 @Ac_ActivityMajor_CODE     CHAR(4),
 @An_MajorIntSeq_NUMB       NUMERIC(5),
 @Ac_ActivityMinor_CODE     CHAR(5),
 @Ac_ActivityMinorNext_CODE CHAR(5),
 @Ac_Reason_CODE            CHAR(2),
 @Ac_TypeOthpSource_CODE	CHAR(1),
 @Ad_Entered_DATE           DATE
 )
AS
 /*  
  *     PROCEDURE NAME    : AFMS_RETRIEVE_S23  
  *     DESCRIPTION       : Retrieve information such as Notice ID, Description, Print method code, Barcode  and etc for the given 
 						Case ID, Major/Minor/Next Minor Activity code, etc.,  
  *     DEVELOPED BY      : IMP Team  
  *     DEVELOPED ON      : 10-AUG-2011  
  *     MODIFIED BY       :   
  *     MODIFIED ON       :   
  *     VERSION NO        : 1  
 */
 BEGIN
  DECLARE @Li_SeqMajorIntDefault_NUMB    INT	 = -1,
          @Li_Zero_NUMB                  INT	 = 0,
          @Lc_Empty_TEXT                 CHAR(1) = '',
          @Lc_Space_TEXT                 CHAR(1) = ' ',
          @Lc_StatusCaseOpen_CODE        CHAR(1) = 'O',
          @Lc_No_INDC                    CHAR(1) = 'N',
          @Lc_RespondInitResponding_CODE CHAR(1) = 'R',
          @Lc_Yes_INDC                   CHAR(1) = 'Y',
          @Lc_PrintMethodF_CODE          CHAR(1) = 'F',
          @Lc_PrintMethodI_CODE          CHAR(1) = 'I',
          @Lc_PrintMethodR_CODE          CHAR(1) = 'R',
          @Lc_TypeEditNoticeA_CODE       CHAR(1) = 'A',
          @Lc_TypeEditNoticeF_CODE       CHAR(1) = 'F',
          @Lc_TypeEditNoticeO_CODE       CHAR(1) = 'O',
          @Lc_TypeEditNoticeS_CODE       CHAR(1) = 'S',
          @Lc_TypeCasePaTanf_CODE        CHAR(1) = 'A',
          @Lc_TypeOthpSourceNcp_CODE	 CHAR(1) = 'A',
          @Lc_TypeOthpSourceCp_CODE		 CHAR(1) = 'C',
          @Lc_TypeOthpSourcePf_CODE		 CHAR(1) = 'P',
          @Lc_ReasonAf_CODE              CHAR(2) = 'AF',
          @Lc_RecipientNcp_CODE			 CHAR(2) = 'MN',
          @Lc_RecipientCp_CODE			 CHAR(2) = 'MC',
          @Lc_RecipientSi_CODE			 CHAR(2) = 'SI',	
          @Lc_ActivityMajorGtst_CODE     CHAR(4) = 'GTST',
          @Lc_ActivityMajorVapp_CODE     CHAR(4) = 'VAPP',
          @Lc_ActivityMajorCclo_CODE     CHAR(4) = 'CCLO',
          @Lc_ActivityMajorImiw_CODE     CHAR(4) = 'IMIW',
          @Lc_ActivityMajorObra_CODE     CHAR(4) = 'OBRA',
          @Lc_TableEiwo_CODE             CHAR(4) = 'EIWO',
          @Lc_TableSubSkip_ID            CHAR(4) = 'SKIP',
          @Lc_ActivityMinorWtrpa_CODE    CHAR(5) = 'WTRPA',
          @Lc_NoticeEnf01_ID             CHAR(6) = 'ENF-01',
          @Lc_NoticeEst10_ID             CHAR(6) = 'EST-10',
          @Lc_NoticeCsm05_ID             CHAR(6) = 'CSM-05',
          @Ld_High_DATE                  DATE    = '12/31/9999';

  SELECT W.Notice_ID,
         W.DescriptionNotice_TEXT,
         W.NavigateTo_CODE,
         W.ScannedDocuments_INDC,
         W.RejectionReason_INDC,
         W.PrintMethod_CODE,
         W.TypeEditNotice_CODE,
         W.Barcode_NUMB,
         W.NoticeMandatory_INDC 
    FROM ( SELECT DISTINCT Z.Notice_ID,
				 Z.DescriptionNotice_TEXT,
				 Z.NavigateTo_CODE,
				 Z.ScannedDocuments_INDC,
				 Z.RejectionReason_INDC,
				 Z.PrintMethod_CODE,
				 Z.TypeEditNotice_CODE,
				 Z.Barcode_NUMB,
				 Z.NoticeMandatory_INDC,
				 Z.NoticeOrder_NUMB,
				 Z.NoticeMinOrder_NUMB,
				 COUNT(1) OVER(PARTITION BY Z.Notice_ID)  AS NoticeCount_NUMB,
				 Z.RowCount_NUMB
			FROM (SELECT CASE
					  WHEN Y.PrintMethod_CODE = @Lc_PrintMethodR_CODE
							OR Y.TypeEditNotice_CODE = @Lc_TypeEditNoticeO_CODE
							OR (Y.PrintMethod_CODE IN (@Lc_PrintMethodI_CODE, @Lc_TypeEditNoticeF_CODE)
								AND Y.Barcode_NUMB IS NOT NULL
								AND Y.Barcode_NUMB != @Li_Zero_NUMB)
					   THEN Y.Notice_ID
					  ELSE NULL
					END Notice_ID,
					 Y.DescriptionNotice_TEXT,
					 Y.NavigateTo_CODE,
					 Y.ScannedDocuments_INDC,
					 Y.RejectionReason_INDC,
					 Y.TypeEditNotice_CODE,
					 Y.PrintMethod_CODE,
					 CASE
					  WHEN Y.Barcode_NUMB IS NULL OR Y.TypeEditNotice_CODE = @Lc_TypeEditNoticeS_CODE
					   THEN @Li_Zero_NUMB
					  ELSE Y.Barcode_NUMB
					 END AS Barcode_NUMB,
					 Y.NoticeMandatory_INDC,
					 Y.NoticeOrder_NUMB,
					 Y.NoticeMinOrder_NUMB,
					 Y.RowCount_NUMB
				FROM (SELECT X.Notice_ID,
							 CASE
							  WHEN LTRIM(RTRIM(X.Notice_ID)) IS NULL
							   THEN NULL
							  ELSE (SELECT n.DescriptionNotice_TEXT
									  FROM NREF_Y1 n
									 WHERE n.Notice_ID = X.Notice_ID
									   AND n.EndValidity_DATE = @Ld_High_DATE)
							 END AS DescriptionNotice_TEXT,
							 X.NavigateTo_CODE,
							 X.TypeEditNotice_CODE,
							 X.ScannedDocuments_INDC AS ScannedDocuments_INDC,
							 X.RejectionReason_INDC AS RejectionReason_INDC,
							 CASE
							  WHEN X.ApprovalRequired_INDC = @Lc_Yes_INDC
								   AND X.TypeEditNotice_CODE <> @Lc_TypeEditNoticeF_CODE
							   THEN @Lc_PrintMethodI_CODE
							  WHEN X.ApprovalRequired_INDC = @Lc_Yes_INDC
								   AND X.TypeEditNotice_CODE = @Lc_TypeEditNoticeF_CODE
							   THEN @Lc_PrintMethodF_CODE
							  WHEN X.ApprovalRequired_INDC = @Lc_No_INDC
							   THEN @Lc_PrintMethodR_CODE
							 END AS PrintMethod_CODE,
							 CASE
							  WHEN (X.ApprovalRequired_INDC = @Lc_Yes_INDC
									AND X.TypeEditNotice_CODE <> @Lc_TypeEditNoticeO_CODE )
							   THEN (SELECT MAX(c.Barcode_NUMB)
									   FROM (SELECT r.Notice_ID,
													r.Barcode_NUMB
											   FROM FORM_Y1 r
											  WHERE r.Topic_IDNO IN (SELECT d.Topic_IDNO
																	   FROM DMNR_Y1 d
																	  WHERE d.Case_IDNO = @An_Case_IDNO
																		AND d.MajorIntSeq_NUMB = @An_MajorIntSeq_NUMB)) AS c,
											AFMS_Y1 f,
											DMNR_Y1 n
									  WHERE n.Case_IDNO = @An_Case_IDNO
										AND n.MajorIntSeq_NUMB = @An_MajorIntSeq_NUMB
										AND n.ActivityMajor_CODE = f.ActivityMajor_CODE
										AND n.ActivityMinor_CODE = f.ActivityMinor_CODE
										AND n.ReasonStatus_CODE = f.Reason_CODE
										AND c.Notice_ID = f.Notice_ID
										AND f.Notice_ID = X.Notice_ID
										AND f.EndValidity_DATE = @Ld_High_DATE
										AND f.ApprovalRequired_INDC = @Lc_Yes_INDC
										AND f.TypeEditNotice_CODE IN (@Lc_TypeEditNoticeO_CODE, @Lc_TypeEditNoticeS_CODE, @Lc_TypeEditNoticeA_CODE, @Lc_TypeEditNoticeF_CODE))
							 END AS Barcode_NUMB,
							 X.NoticeMandatory_INDC,
							 X.NoticeOrder_NUMB,
							 X.NoticeMinOrder_NUMB,
							 X.RowCount_NUMB
						FROM (SELECT DISTINCT CASE ISNULL(@Ac_Reason_CODE, @Lc_Empty_TEXT)
									  WHEN @Lc_Empty_TEXT
									   THEN @Lc_Space_TEXT
									  ELSE x.NavigateTo_CODE
									 END AS NavigateTo_CODE,
									 CASE
									  WHEN LTRIM(RTRIM(@Ac_Reason_CODE)) IS NULL
									   THEN NULL
									  WHEN EXISTS (SELECT o.Eiwn_INDC
													 FROM OTHP_Y1 o
													WHERE o.OtherParty_IDNO IN (SELECT j.OthpSource_IDNO
																				  FROM DMJR_Y1 j
																				 WHERE j.Case_IDNO = @An_Case_IDNO
																				   AND j.MajorIntSeq_NUMB = @An_MajorIntSeq_NUMB
																				   AND j.ActivityMajor_CODE = @Lc_ActivityMajorImiw_CODE)
													  AND o.EndValidity_DATE = @Ld_High_DATE
													  AND o.Eiwn_INDC = @Lc_Yes_INDC)
										   AND a.Notice_ID = @Lc_NoticeEnf01_ID
										   -- Defect 13263 - CR0365 e-IWO Notice to NCP 20140217 Fix - Start --
										   AND a.Recipient_CODE = @Lc_RecipientSi_CODE
										   -- Defect 13263 - CR0365 e-IWO Notice to NCP 20140217 Fix - End --
										   AND EXISTS (SELECT r.DescriptionValue_TEXT
														 FROM REFM_Y1 r
														WHERE r.Table_ID = @Lc_TableEiwo_CODE
														  AND r.TableSub_ID = @Lc_TableSubSkip_ID
														  AND r.DescriptionValue_TEXT = @Lc_No_INDC)
										   AND LTRIM(RTRIM(@Ac_Reason_CODE)) IS NOT NULL
									   THEN NULL
									  WHEN EXISTS (SELECT c.RespondInit_CODE
													 FROM CASE_Y1 c
													WHERE c.Case_IDNO = @An_Case_IDNO
													  AND c.StatusCase_CODE = @Lc_StatusCaseOpen_CODE
													  AND c.RespondInit_CODE = @Lc_RespondInitResponding_CODE)
										   AND @Ac_ActivityMajor_CODE = @Lc_ActivityMajorCclo_CODE
										   AND dbo.BATCH_CM_CASE_CLOSURE_ELIG$SF_FIND_INTERSTATE_REASON_CC(@An_Case_IDNO, CONVERT(DATE, DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME()), @Ad_Entered_DATE) != @Lc_Space_TEXT
										   AND LTRIM(RTRIM(@Ac_Reason_CODE)) IS NOT NULL
									   THEN NULL
									  WHEN EXISTS (SELECT 1
													 FROM CASE_Y1 c
													WHERE c.Case_IDNO = @An_Case_IDNO
													  AND c.TypeCase_CODE != @Lc_TypeCasePaTanf_CODE)
										   AND @Ac_ActivityMajor_CODE = @Lc_ActivityMajorObra_CODE
										   AND @Ac_ActivityMinor_CODE = @Lc_ActivityMinorWtrpa_CODE
										   AND @Ac_Reason_CODE = @Lc_ReasonAf_CODE
										   AND a.Notice_ID = @Lc_NoticeCsm05_ID
									   THEN NULL
									  WHEN a.Notice_ID = @Lc_NoticeEst10_ID
										AND	@Ac_TypeOthpSource_CODE = @Lc_TypeOthpSourceCp_CODE
										THEN NULL
									  WHEN a.Notice_ID = @Lc_NoticeEst10_ID
									    THEN a.Notice_ID
									  WHEN @Ac_ActivityMajor_CODE IN ( @Lc_ActivityMajorGtst_CODE, @Lc_ActivityMajorVapp_CODE)
										AND EXISTS (SELECT 1
													FROM AFMS_Y1 f
												   WHERE f.ActivityMajor_CODE = @Ac_ActivityMajor_CODE 
												     AND f.ActivityMinor_CODE = @Ac_ActivityMinor_CODE
													 AND f.Reason_CODE = @Ac_Reason_CODE
													 AND f.ActivityMinorNext_CODE = @Ac_ActivityMinorNext_CODE
													 AND f.EndValidity_DATE = @Ld_High_DATE
													 AND f.Notice_ID = a.Notice_ID
													 AND ((a.Recipient_CODE = @Lc_RecipientNcp_CODE
														   AND @Ac_TypeOthpSource_CODE NOT IN (@Lc_TypeOthpSourceNcp_CODE,@Lc_TypeOthpSourcePf_CODE))
														   OR (a.Recipient_CODE = @Lc_RecipientCp_CODE
															 AND @Ac_TypeOthpSource_CODE != @Lc_TypeOthpSourceCp_CODE)))	
										THEN NULL
									  ELSE a.Notice_ID
									 END AS Notice_ID,
									 CASE ISNULL(@Ac_Reason_CODE, @Lc_Empty_TEXT)
									  WHEN @Lc_Empty_TEXT
									   THEN NULL
									  ELSE a.ApprovalRequired_INDC
									 END AS ApprovalRequired_INDC,
									 CASE ISNULL(@Ac_Reason_CODE, @Lc_Empty_TEXT)
									  WHEN @Lc_Empty_TEXT
									   THEN NULL
									  ELSE a.TypeEditNotice_CODE
									 END AS TypeEditNotice_CODE,
									 a.NoticeOrder_NUMB,
									 MIN(a.NoticeOrder_NUMB) OVER(PARTITION BY a.ActivityMajor_CODE, a.ActivityMinor_CODE, a.Reason_CODE) NoticeMinOrder_NUMB,
									 a.Mask_INDC AS NoticeMandatory_INDC,
									 x.ScannedDocuments_INDC,
									 x.RejectionReason_INDC,
									 a.RecipientSeq_NUMB,
									 COUNT(1) OVER() AS RowCount_NUMB
								FROM ANXT_Y1 x
									 LEFT OUTER JOIN AFMS_Y1 a
									  ON a.ActivityMajor_CODE = x.ActivityMajor_CODE
										 AND a.ActivityMinor_CODE = x.ActivityMinor_CODE
										 AND x.Reason_CODE = a.Reason_CODE
										 AND x.ActivityMinorNext_CODE = @Ac_ActivityMinorNext_CODE
										 AND a.EndValidity_DATE = @Ld_High_DATE
										 AND a.Notice_ID != @Lc_Empty_TEXT,
									 AMNR_Y1 m
							   WHERE x.ActivityMajor_CODE = @Ac_ActivityMajor_CODE
								 AND x.ActivityMinor_CODE = @Ac_ActivityMinor_CODE
								 AND x.Reason_CODE = ISNULL(@Ac_Reason_CODE, x.Reason_CODE)
								 AND x.EndValidity_DATE = @Ld_High_DATE
								 AND m.EndValidity_DATE = @Ld_High_DATE
								 AND m.ActivityMinor_CODE = CASE ISNULL(@Ac_ActivityMinorNext_CODE, @Lc_Empty_TEXT)
															 WHEN @Lc_Empty_TEXT
															  THEN x.ActivityMinor_CODE
															 ELSE x.ActivityMinorNext_CODE
															END) AS X
						) AS Y
				) AS Z
			) AS W
   WHERE W.Notice_ID IS NOT NULL
      OR (W.NoticeCount_NUMB = W.RowCount_NUMB
          AND W.NoticeOrder_NUMB = W.NoticeMinOrder_NUMB)
      OR W.NoticeOrder_NUMB IS NULL
      OR @An_MajorIntSeq_NUMB = @Li_SeqMajorIntDefault_NUMB
   ORDER BY W.NoticeOrder_NUMB;
 END; --End of  AFMS_RETRIEVE_S23


GO
