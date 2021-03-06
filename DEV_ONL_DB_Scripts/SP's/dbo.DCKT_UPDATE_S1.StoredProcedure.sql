/****** Object:  StoredProcedure [dbo].[DCKT_UPDATE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DCKT_UPDATE_S1](
  @Ac_File_ID                     CHAR(10),
  @Ac_Judge_ID                    CHAR(30),
  @Ac_Commissioner_ID             CHAR(30),
  @An_EventGlobalBeginSeq_NUMB    NUMERIC(19,0),
  @Ac_SignedOnWorker_ID           CHAR(30))
AS
  /*    
   *     PROCEDURE NAME    : DCKT_UPDATE_S1    
   *     DESCRIPTION       : Logically delete the valid record for a File ID and inserts a record with the updated information.    
   *     DEVELOPED BY      : IMP Team
   *     DEVELOPED ON      : 10/20/2011
   *     MODIFIED BY       :     
   *     MODIFIED ON       :     
   *     VERSION NO        : 1.0
   */
  BEGIN
    DECLARE @Ld_Current_DTTM DATETIME2 = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
    DECLARE @Ld_Current_DATE DATE = @Ld_Current_DTTM;

    UPDATE DCKT_Y1
       SET Judge_ID=@Ac_Judge_ID,
           Commissioner_ID=@Ac_Commissioner_ID,
           WorkerUpdate_ID=@Ac_SignedOnWorker_ID,
           BeginValidity_DATE=@Ld_Current_DATE,
           EventGlobalBeginSeq_NUMB=@An_EventGlobalBeginSeq_NUMB,
           Update_DTTM=@Ld_Current_DTTM
    OUTPUT Inserted.File_ID,
           Inserted.County_IDNO,
           Inserted.FileType_CODE,
           Inserted.CaseTitle_NAME,
           Deleted.Judge_ID,
           Inserted.Filed_DATE,
           Deleted.Commissioner_ID,
           Deleted.WorkerUpdate_ID,
           Inserted.BeginValidity_DATE,
           Deleted.EventGlobalBeginSeq_NUMB,
           @Ld_Current_DTTM,
           @An_EventGlobalBeginSeq_NUMB,
           @Ld_Current_DATE
    INTO HDCKT_Y1(FILE_ID,
                  County_IDNO, 
                  FileType_CODE, 
                  CaseTitle_NAME,
                  Judge_ID, 
                  Filed_DATE, 
                  Commissioner_ID,
                  WorkerUpdate_ID,
                  BeginValidity_DATE, 
                  EventGlobalBeginSeq_NUMB, 
                  Update_DTTM, 
                  EventGlobalEndSeq_NUMB, 
                  EndValidity_DATE )
   WHERE File_ID=@Ac_File_ID;
       
   DECLARE @Li_RowsAffected_NUMB INT = @@ROWCOUNT;

	SELECT @Li_RowsAffected_NUMB AS RowsAffected_NUMB;
	
  END -- END OF DCKT_UPDATE_S1

GO
