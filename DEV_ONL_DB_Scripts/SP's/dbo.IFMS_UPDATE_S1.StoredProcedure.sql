/****** Object:  StoredProcedure [dbo].[IFMS_UPDATE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
    
 CREATE PROCEDURE  [dbo].[IFMS_UPDATE_S1] 
 (
			@An_MemberMci_IDNO				NUMERIC(10,0),  
			@Ac_StateAdministration_CODE	CHAR(2),  
			@Ac_WorkerUpdate_ID				CHAR(30) 
     )           
AS  
/*  
 *     PROCEDURE NAME    : IFMS_UPDATE_S1  
 *     DESCRIPTION       : THIS PROCEDURE IS USED TO UPDATE IFMS_Y1 TABLE ACCORDING TO MEMBERMCI.  
 *     DEVELOPED BY      : IMP TEAM  
 *     DEVELOPED ON      : 02-SEP-2011  
 *     MODIFIED BY       :   
 *     MODIFIED ON       :   
 *     VERSION NO        : 1  
*/  
 BEGIN  
    DECLARE @Ld_Current_DTTM	DATETIME2(7)	= DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

	UPDATE  IFMS_Y1  
	   SET  StateAdministration_CODE = @Ac_StateAdministration_CODE,   
		    WorkerUpdate_ID = @Ac_WorkerUpdate_ID,   
		    Update_DTTM = @Ld_Current_DTTM   
	WHERE   MemberMci_IDNO = @An_MemberMci_IDNO ; 
	 
	DECLARE @Ln_RowsAffected_NUMB NUMERIC(10);
	    SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;
	 SELECT @Ln_RowsAffected_NUMB;

END;-- End of IFMS_UPDATE_S1

GO
