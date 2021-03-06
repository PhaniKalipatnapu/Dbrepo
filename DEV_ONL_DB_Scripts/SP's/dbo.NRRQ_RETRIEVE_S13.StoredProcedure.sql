/****** Object:  StoredProcedure [dbo].[NRRQ_RETRIEVE_S13]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[NRRQ_RETRIEVE_S13] 
( 
	@An_Case_IDNO				NUMERIC(6,0),
	@An_MajorIntSeq_NUMB		NUMERIC(5,0),
	@Ad_Notice_DATE				DATE OUTPUT
)   
AS
/*
 *     PROCEDURE NAME    : NRRQ_RETRIEVE_S13
 *     DESCRIPTION       : This procedure is used to retrieve the Notice Date.
 *     DEVELOPED BY      : IMP TEAM
 *     DEVELOPED ON      : 02-MAR-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
BEGIN
		  SET @Ad_Notice_DATE					= NULL;
		  
	  DECLARE @Li_One_NUMB								INT     = 1,
			  @Li_Zero_NUMB								INT     = 0,
			  @Ld_High_DATE						DATE    = '12/31/9999',
			  @Ld_Low_DATE						DATE    = '01/01/0001',
			  @Lc_RecipientCpMC_CODE			CHAR(2) = 'MC',
		      @Lc_ActivityMajorCCLO_CODE		CHAR(4) = 'CCLO',
		      @Lc_StatusCOMP_CODE				CHAR(4) = 'COMP',
		      @Lc_NoticeCSM10_ID				CHAR(8) = 'CSM-10';
		      
		SELECT TOP 1 @Ad_Notice_DATE = ISNULL(n.Generate_DTTM, @Ld_Low_DATE)
		 FROM NRRQ_Y1 n 
		WHERE n.Barcode_NUMB IN 
			 (SELECT f.Barcode_NUMB
				FROM FORM_Y1 f
			   WHERE f.Topic_IDNO IN 
					(SELECT e.Topic_IDNO
					   FROM DMNR_Y1 e
					  WHERE e.Case_IDNO IN 
							(SELECT d.Case_IDNO
							   FROM DMNR_Y1 d
							  WHERE d.ActivityMajor_CODE IN 
									(SELECT DISTINCT a.ActivityMajor_CODE
									   FROM AFMS_Y1 a
									  WHERE a.Notice_ID = @Lc_NoticeCSM10_ID
										 AND a.ActivityMajor_CODE = @Lc_ActivityMajorCCLO_CODE
										 AND a.EndValidity_DATE	= @Ld_High_DATE)
								AND d.ActivityMinor_CODE IN 
									(SELECT DISTINCT a.ActivityMinor_CODE 
									   FROM AFMS_Y1 a
									  WHERE a.Notice_ID = @Lc_NoticeCSM10_ID
										AND a.ActivityMajor_CODE = @Lc_ActivityMajorCCLO_CODE
										AND a.EndValidity_DATE	= @Ld_High_DATE) 
								AND d.ReasonStatus_CODE IN 
									(SELECT DISTINCT a.Reason_CODE 
									   FROM AFMS_Y1 a
									  WHERE a.Notice_ID = @Lc_NoticeCSM10_ID
										AND a.ActivityMajor_CODE = @Lc_ActivityMajorCCLO_CODE
										AND a.EndValidity_DATE	= @Ld_High_DATE)
								AND d.Case_IDNO			= @An_Case_IDNO
								AND d.MajorIntSeq_NUMB	= @An_MajorIntSeq_NUMB
								AND d.Status_CODE		= @Lc_StatusCOMP_CODE)
						AND e.MajorIntSeq_NUMB IN  
							(SELECT d.MajorIntSeq_NUMB
							   FROM DMNR_Y1 d
							  WHERE d.ActivityMajor_CODE IN 
									(SELECT DISTINCT a.ActivityMajor_CODE 
									   FROM AFMS_Y1 a
									  WHERE a.Notice_ID = @Lc_NoticeCSM10_ID
										AND a.ActivityMajor_CODE = @Lc_ActivityMajorCCLO_CODE
										AND a.EndValidity_DATE	= @Ld_High_DATE)
								AND d.ActivityMinor_CODE IN 
									(SELECT DISTINCT a.ActivityMinor_CODE 
									   FROM AFMS_Y1 a
									  WHERE a.Notice_ID = @Lc_NoticeCSM10_ID
										AND a.ActivityMajor_CODE = @Lc_ActivityMajorCCLO_CODE
										AND a.EndValidity_DATE	= @Ld_High_DATE)
								AND d.ReasonStatus_CODE IN 
									(SELECT DISTINCT a.Reason_CODE 
									   FROM AFMS_Y1 a
									  WHERE a.Notice_ID = @Lc_NoticeCSM10_ID
										AND a.ActivityMajor_CODE = @Lc_ActivityMajorCCLO_CODE
										AND a.EndValidity_DATE	= @Ld_High_DATE)
								AND d.Case_IDNO			= @An_Case_IDNO
								AND d.MajorIntSeq_NUMB	= @An_MajorIntSeq_NUMB
								AND d.Status_CODE		= @Lc_StatusCOMP_CODE)
						AND e.MinorIntSeq_NUMB IN 
							(SELECT d.MinorIntSeq_NUMB + @Li_One_NUMB
							   FROM DMNR_Y1 d
							  WHERE d.ActivityMajor_CODE IN 
									(SELECT DISTINCT a.ActivityMajor_CODE 
									   FROM AFMS_Y1 a
									  WHERE a.Notice_ID = @Lc_NoticeCSM10_ID
										AND a.ActivityMajor_CODE = @Lc_ActivityMajorCCLO_CODE
										AND a.EndValidity_DATE	= @Ld_High_DATE)
								 AND d.ActivityMinor_CODE IN 
									 (SELECT DISTINCT a.ActivityMinor_CODE 
										FROM AFMS_Y1 a
									   WHERE a.Notice_ID = @Lc_NoticeCSM10_ID
										 AND a.ActivityMajor_CODE = @Lc_ActivityMajorCCLO_CODE
										 AND a.EndValidity_DATE	= @Ld_High_DATE)
								 AND d.ReasonStatus_CODE IN 
									 (SELECT DISTINCT a.Reason_CODE 
										FROM AFMS_Y1 a
									   WHERE a.Notice_ID = @Lc_NoticeCSM10_ID
										 AND a.ActivityMajor_CODE = @Lc_ActivityMajorCCLO_CODE
										 AND a.EndValidity_DATE	= @Ld_High_DATE)
								 AND d.Case_IDNO		= @An_Case_IDNO
								 AND d.MajorIntSeq_NUMB	= @An_MajorIntSeq_NUMB
								 AND d.Status_CODE		= @Lc_StatusCOMP_CODE))
					AND f.Barcode_NUMB	= (SELECT g.Barcode_NUMB 
											 FROM FORM_Y1 g
											WHERE g.Recipient_CODE	= @Lc_RecipientCpMC_CODE
												  AND g.Topic_IDNO		= f.Topic_IDNO))
					AND ISNUMERIC(n.Notice_ID) = @Li_Zero_NUMB; 
	                  
END; -- END OF NRRQ_RETRIEVE_S13
 

GO
