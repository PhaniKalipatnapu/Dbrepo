/****** Object:  StoredProcedure [dbo].[DCKT_UPDATE_S2]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[DCKT_UPDATE_S2]
	(
     @Ac_File_ID						CHAR(10),
     @An_County_IDNO					NUMERIC(3),
     @Ad_Filed_DATE						DATE,
     @Ac_SignedOnWorker_ID				CHAR(30),
     @An_EventGlobalBeginSeq_NUMB		NUMERIC(19),
     @Ac_FileOld_ID						CHAR(10)
    )
AS

/*
 *     PROCEDURE NAME    : DCKT_UPDATE_S2
 *     DESCRIPTION       : Updating New File information in Docket table and moving the Old File information to Docket history table.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 24-DEC-2011
 *     MODIFIED BY       :
 *     MODIFIED ON       :
 *     VERSION NO        : 1
*/
BEGIN
	-- 13650 - SORD - CR0420 SORD Commissioner and Judge Field on Cases that Share a File ID - START
	DECLARE
		 @Ln_RowsAffected_NUMB  		NUMERIC(10),
		 @Ld_SystemDatetime_DTTM		DATETIME2	= dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

      UPDATE DCKT_Y1
         SET File_ID = @Ac_File_ID,
         	 County_IDNO = @An_County_IDNO,
         	 Filed_DATE = @Ad_Filed_DATE,
         	 WorkerUpdate_ID=@Ac_SignedonWorker_ID,
         	 BeginValidity_DATE = @Ld_SystemDatetime_DTTM,
         	 EventGlobalBeginSeq_NUMB = @An_EventGlobalBeginSeq_NUMB,
         	 Update_DTTM = @Ld_SystemDatetime_DTTM
      OUTPUT Deleted.File_ID,
			 Deleted.County_IDNO,
			 Deleted.FileType_CODE,
			 Deleted.CaseTitle_NAME,
			 Deleted.Filed_DATE,
			 Deleted.WorkerUpdate_ID,
			 Deleted.BeginValidity_DATE,
			 Deleted.EventGlobalBeginSeq_NUMB,
			 Deleted.Update_DTTM,
			 @Ld_SystemDatetime_DTTM,
			 @An_EventGlobalBeginSeq_NUMB
	  INTO HDCKT_Y1 ( 
	  					File_ID,
						County_IDNO,
						FileType_CODE,
						CaseTitle_NAME,
						Filed_DATE,
						WorkerUpdate_ID,
						BeginValidity_DATE,
						EventGlobalBeginSeq_NUMB,
						Update_DTTM,
						EndValidity_DATE,
						EventGlobalEndSeq_NUMB
    				)
      WHERE File_ID = @Ac_FileOld_ID;
      -- 13650 - SORD - CR0420 SORD Commissioner and Judge Field on Cases that Share a File ID - END

	SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;
    SELECT @Ln_RowsAffected_NUMB AS  RowsAffected_NUMB;

END; --END OF DCKT_UPDATE_S2


GO
