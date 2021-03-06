/****** Object:  StoredProcedure [dbo].[CNTDT_UPDATE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
  CREATE PROCEDURE [dbo].[CNTDT_UPDATE_S1]
  (
	@Ac_IamUser_ID					CHAR(30),    
	@Ac_NoticeTransmission_CODE		CHAR(1),     
	@Ac_SignedOnWorker_ID			CHAR(30),    
	@An_EventGlobalSeq_NUMB         NUMERIC(19,0)
                                                 
  )
  AS
 /*
  *     PROCEDURE NAME    : CNTDT_UPDATE_S1
  *     DESCRIPTION       : It Update the NoticeTransmission_CODE based on the Block site selection.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 05-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
  
  BEGIN
 	DECLARE @Ln_RowsAffected_NUMB	NUMERIC(10),
 			@Ld_Systemdatetime_DTTM	DATETIME2 = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
 			@Ld_Current_DATE		DATE =DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
 
	UPDATE CNTDT_Y1
	SET NoticeTransmission_CODE=@Ac_NoticeTransmission_CODE,
		BeginValidity_DATE=@Ld_Current_DATE,
	    Update_DTTM=@Ld_Systemdatetime_DTTM,
	    WorkerUpdate_ID=@Ac_SignedOnWorker_ID,
	    EventGlobalSeq_NUMB=@An_EventGlobalSeq_NUMB
	 WHERE IamUser_ID=@Ac_IamUser_ID
	 
	 	SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;
	
	    SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB;
	    
END;--End of CNTDT_UPDATE_S1

GO
