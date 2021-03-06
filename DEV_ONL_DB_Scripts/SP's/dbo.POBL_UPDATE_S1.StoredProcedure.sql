/****** Object:  StoredProcedure [dbo].[POBL_UPDATE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[POBL_UPDATE_S1]  
			(
			@An_Record_NUMB						NUMERIC(19,0),
			@Ac_TypeDebt_CODE					CHAR(2),			
			@Ac_PayBack_INDC					CHAR(1),
			@Ac_Process_CODE					CHAR(1),
			@Ac_SignedOnWorker_ID				CHAR(30)
			)
AS

/*
 *     PROCEDURE NAME    : POBL_UPDATE_S1
 *     DESCRIPTION       : Update the Process code status in POBL_Y1 table.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 13-MAR-2012
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1.0
 */

   BEGIN

      DECLARE
		 @Ln_RowsAffected_NUMB   NUMERIC(10),
		 @Lc_ProcessL_CODE		CHAR(1)	  = 'L',
		 @Ld_Current_DTTM		DATETIME2 = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
                                                                      
     UPDATE POBL_Y1
		SET Process_CODE = @Ac_Process_CODE,
		    WorkerUpdate_ID = @Ac_SignedOnWorker_ID,
		    Update_DTTM = @Ld_Current_DTTM
      WHERE Record_NUMB = @An_Record_NUMB
		AND TypeDebt_CODE = @Ac_TypeDebt_CODE		
		AND PayBack_INDC = @Ac_PayBack_INDC
		AND Process_CODE = @Lc_ProcessL_CODE; 
        
        SET @Ln_RowsAffected_NUMB=@@ROWCOUNT;
		SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB;
                  
END --END OF POBL_UPDATE_S1 


GO
