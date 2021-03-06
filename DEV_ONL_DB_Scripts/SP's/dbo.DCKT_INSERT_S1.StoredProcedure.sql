/****** Object:  StoredProcedure [dbo].[DCKT_INSERT_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- 13650 - SORD - CR0420 SORD Commissioner and Judge Field on Cases that Share a File ID - START
CREATE PROCEDURE [dbo].[DCKT_INSERT_S1] (
     @Ac_File_ID		 			CHAR(10),
     @An_County_IDNO		 		NUMERIC(3),
	 @Ac_FileType_CODE				CHAR(2),
	 @As_CaseTitle_NAME				VARCHAR(60),
	 @Ad_Filed_DATE					DATE,
	 @Ac_SignedOnWorker_ID		 	CHAR(30),
     @An_EventGlobalBeginSeq_NUMB	NUMERIC(19)
	 )
AS

/*
 *     PROCEDURE NAME    : DCKT_INSERT_S1
 *     DESCRIPTION       : INSERT Docket details INTO Docket TABLE.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 05-AUG-2011
 *     MODIFIED BY       :
 *     MODIFIED ON       :
 *     VERSION NO        : 1
*/
  BEGIN

     DECLARE @Ld_SystemDatetime_DTTM	DATETIME2 = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

	INSERT DCKT_Y1
	    	(File_ID,
			County_IDNO,
			FileType_CODE,
			CaseTitle_NAME,
			Filed_DATE,
			WorkerUpdate_ID,
			BeginValidity_DATE,
			EventGlobalBeginSeq_NUMB,
			Update_DTTM)
	VALUES (@Ac_File_ID,
			@An_County_IDNO,
			@Ac_FileType_CODE,
			@As_CaseTitle_NAME,
			@Ad_Filed_DATE,
			@Ac_SignedOnWorker_ID,
			@Ld_SystemDatetime_DTTM,
			@An_EventGlobalBeginSeq_NUMB,
			@Ld_SystemDatetime_DTTM);


END;  -- END OF DCKT_INSERT_S1
-- 13650 - SORD - CR0420 SORD Commissioner and Judge Field on Cases that Share a File ID - END


GO
