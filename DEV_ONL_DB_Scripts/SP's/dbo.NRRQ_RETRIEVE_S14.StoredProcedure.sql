/****** Object:  StoredProcedure [dbo].[NRRQ_RETRIEVE_S14]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[NRRQ_RETRIEVE_S14] 
( 
	@An_Case_IDNO				NUMERIC(6,0),
	@An_MajorIntSeq_NUMB		NUMERIC(5,0),
	@Ad_Notice_DATE				DATE OUTPUT
)   
AS
/*
 *     PROCEDURE NAME    : NRRQ_RETRIEVE_S14
 *     DESCRIPTION       : This procedure is used to retrieve the Notice date.
 *     DEVELOPED BY      : IMP TEAM
 *     DEVELOPED ON      : 02-MAR-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
BEGIN
		  SET @Ad_Notice_DATE					= NULL;
	  DECLARE @Li_One_NUMB						INT     = 1,
			  @Ld_High_DATE						DATE    = '12/31/9999',
			  @Ld_Low_DATE						DATE    = '01/01/0001',
			  @Lc_NoticeCSM07_ID				CHAR(8) = 'CSM-07',
			  @Lc_NoticeCSM08_ID				CHAR(8) = 'CSM-08',
			  @Lc_ActivityMajorOBRA_CODE		CHAR(4) = 'OBRA';
		      
   SELECT @Ad_Notice_DATE = ISNULL(x.Notice_DATE,@Ld_Low_DATE) 
	 FROM (SELECT DBO.BATCH_COMMON_SCALAR$SF_TRUNC_DATE(n.Generate_DTTM) AS Notice_DATE
			 FROM NRRQ_Y1 n 
			WHERE n.Barcode_NUMB IN 
				 (SELECT f.Barcode_NUMB
					FROM FORM_Y1 f
				   WHERE f.Topic_IDNO IN 
						(SELECT e.Topic_IDNO
						   FROM DMNR_Y1 e
						  WHERE e.Case_IDNO  IN 
								(SELECT d.Case_IDNO
								   FROM DMNR_Y1 d
								  WHERE d.ActivityMajor_CODE IN 
										(SELECT DISTINCT a.ActivityMajor_CODE 
										   FROM AFMS_Y1 a
										  WHERE a.Notice_ID IN (@Lc_NoticeCSM07_ID, @Lc_NoticeCSM08_ID)
											 AND a.ActivityMajor_CODE = @Lc_ActivityMajorOBRA_CODE
											 AND a.EndValidity_DATE	= @Ld_High_DATE)
									AND d.ActivityMinor_CODE IN 
										(SELECT DISTINCT p.ActivityMinor_CODE 
										   FROM AFMS_Y1 p
										  WHERE p.Notice_ID IN (@Lc_NoticeCSM07_ID, @Lc_NoticeCSM08_ID)
											AND p.ActivityMajor_CODE = @Lc_ActivityMajorOBRA_CODE
											AND p.EndValidity_DATE	= @Ld_High_DATE) 
									AND d.ReasonStatus_CODE IN 
										(SELECT DISTINCT q.Reason_CODE 
										   FROM AFMS_Y1 q
										  WHERE q.Notice_ID IN (@Lc_NoticeCSM07_ID, @Lc_NoticeCSM08_ID)
											AND q.ActivityMajor_CODE = @Lc_ActivityMajorOBRA_CODE
											AND q.EndValidity_DATE	= @Ld_High_DATE)
									AND d.Case_IDNO			= @An_Case_IDNO
									AND d.MajorIntSeq_NUMB	= @An_MajorIntSeq_NUMB)
							AND e.MajorIntSeq_NUMB IN  
								(SELECT d.MajorIntSeq_NUMB
								   FROM DMNR_Y1 d
								  WHERE d.ActivityMajor_CODE IN 
										(SELECT DISTINCT r.ActivityMajor_CODE 
										   FROM AFMS_Y1 r
										  WHERE r.Notice_ID IN (@Lc_NoticeCSM07_ID, @Lc_NoticeCSM08_ID)
											AND r.ActivityMajor_CODE = @Lc_ActivityMajorOBRA_CODE
											AND r.EndValidity_DATE	= @Ld_High_DATE)
									AND d.ActivityMinor_CODE IN 
										(SELECT DISTINCT s.ActivityMinor_CODE 
										   FROM AFMS_Y1 s
										  WHERE s.Notice_ID IN (@Lc_NoticeCSM07_ID, @Lc_NoticeCSM08_ID)
											AND s.ActivityMajor_CODE = @Lc_ActivityMajorOBRA_CODE
											AND s.EndValidity_DATE	= @Ld_High_DATE)
									AND d.ReasonStatus_CODE IN 
										(SELECT DISTINCT t.Reason_CODE 
										   FROM AFMS_Y1 t
										  WHERE t.Notice_ID IN (@Lc_NoticeCSM07_ID, @Lc_NoticeCSM08_ID)
											AND t.ActivityMajor_CODE = @Lc_ActivityMajorOBRA_CODE
											AND t.EndValidity_DATE	= @Ld_High_DATE)
									AND d.Case_IDNO			= @An_Case_IDNO
									AND d.MajorIntSeq_NUMB	= @An_MajorIntSeq_NUMB)
							AND e.MinorIntSeq_NUMB IN 
								(SELECT d.MinorIntSeq_NUMB + @Li_One_NUMB
								   FROM DMNR_Y1 d
								  WHERE d.ActivityMajor_CODE IN 
										(SELECT DISTINCT u.ActivityMajor_CODE 
										   FROM AFMS_Y1 u
										  WHERE u.Notice_ID IN (@Lc_NoticeCSM07_ID, @Lc_NoticeCSM08_ID)
											AND u.ActivityMajor_CODE = @Lc_ActivityMajorOBRA_CODE
											AND u.EndValidity_DATE	= @Ld_High_DATE)
									 AND d.ActivityMinor_CODE IN 
										 (SELECT DISTINCT v.ActivityMinor_CODE 
											FROM AFMS_Y1 v
										   WHERE v.Notice_ID IN (@Lc_NoticeCSM07_ID, @Lc_NoticeCSM08_ID)
											 AND v.ActivityMajor_CODE = @Lc_ActivityMajorOBRA_CODE
											 AND v.EndValidity_DATE	= @Ld_High_DATE)
									 AND d.ReasonStatus_CODE IN 
										 (SELECT DISTINCT w.Reason_CODE 
											FROM AFMS_Y1 w
										   WHERE w.Notice_ID IN (@Lc_NoticeCSM07_ID, @Lc_NoticeCSM08_ID)
											 AND w.ActivityMajor_CODE = @Lc_ActivityMajorOBRA_CODE
											 AND w.EndValidity_DATE	= @Ld_High_DATE)
									 AND d.Case_IDNO		= @An_Case_IDNO
									 AND d.MajorIntSeq_NUMB	= @An_MajorIntSeq_NUMB))
						))x; 
	                  
END; -- END OF NRRQ_RETRIEVE_S14
 

GO
