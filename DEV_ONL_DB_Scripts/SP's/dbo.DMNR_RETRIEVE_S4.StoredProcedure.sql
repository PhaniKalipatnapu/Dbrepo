/****** Object:  StoredProcedure [dbo].[DMNR_RETRIEVE_S4]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DMNR_RETRIEVE_S4] (
 @An_Case_IDNO              NUMERIC(6),
 @Ac_ActivityMajor_CODE     CHAR(4),
 @An_MajorIntSeq_NUMB       NUMERIC(5)
 )
AS
/*  
  *     PROCEDURE NAME    : DMNR_RETRIEVE_S4  
  *     DESCRIPTION       : Retrieve information such as Notice ID, and Barcode  and etc for the given 
 							Case ID, Major and Major Sequence number.
  *     DEVELOPED BY      : IMP Team  
  *     DEVELOPED ON      : 10-AUG-2011  
  *     MODIFIED BY       :   
  *     MODIFIED ON       :   
  *     VERSION NO        : 1  
 */
 BEGIN
  DECLARE @Lc_Yes_INDC                   CHAR(1) = 'Y',
          @Lc_StatusStart_CODE			 CHAR(4) = 'STRT';

SELECT f.Notice_ID, 
       f.Barcode_NUMB 
	FROM DMNR_Y1 d
	JOIN FORM_Y1 f
	  ON d.Topic_idno = f.topic_idno
	 AND ISNUMERIC(f.Notice_ID) = 1
  WHERE d.Case_IDNO = @An_Case_IDNO
	AND d.MajorIntSeq_NUMB = @An_MajorIntSeq_NUMB  
	AND d.Status_CODE = @Lc_StatusStart_CODE
END; --End of  DMNR_RETRIEVE_S4


GO
