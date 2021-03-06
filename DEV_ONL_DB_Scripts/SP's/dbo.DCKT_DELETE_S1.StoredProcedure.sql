/****** Object:  StoredProcedure [dbo].[DCKT_DELETE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DCKT_DELETE_S1] (
@Ac_File_ID			        CHAR(10),
@An_EventGlobalEndSeq_NUMB  NUMERIC(19)
 )
AS
 /*
  *     PROCEDURE NAME    : DCKT_DELETE_S1
  *     DESCRIPTION       : Delete Record for a  given File ID .
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 11-JUN-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE   @Ld_Current_DATE			  DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
			@Ln_RowsAffected_NUMB		  NUMERIC(10);

  DELETE DCKT_Y1 
  OUTPUT DELETED.File_ID,
		 DELETED.County_IDNO,
		 DELETED.FileType_CODE,
		 DELETED.CaseTitle_NAME,
		 -- 13650 - SORD - CR0420 SORD Commissioner and Judge Field on Cases that Share a File ID - START
		 DELETED.Filed_DATE,
		 -- 13650 - SORD - CR0420 SORD Commissioner and Judge Field on Cases that Share a File ID - END
		 DELETED.WorkerUpdate_ID,
		 DELETED.BeginValidity_DATE,
		 DELETED.EventGlobalBeginSeq_NUMB,
		 DELETED.Update_DTTM,
		 @Ld_Current_DATE AS EndValidity_DATE,
		 @An_EventGlobalEndSeq_NUMB AS EventGlobalEndSeq_NUMB
    INTO HDCKT_Y1 
   WHERE FILE_ID=@Ac_File_ID;
   
  SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;

  SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB;
   END; -- END OF DCKT_DELETE_S1


GO
