/****** Object:  StoredProcedure [dbo].[PSRD_UPDATE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[PSRD_UPDATE_S1]  (
	@An_Case_IDNO						NUMERIC(6,0),
	@An_Record_NUMB						NUMERIC(19,0),
	@Ac_Process_CODE					CHAR(1),
	@Ac_SignedOnWorker_ID				CHAR(30)
 )
AS

/*
 *     PROCEDURE NAME    : PSRD_UPDATE_S1
 *     DESCRIPTION       : Fetches the Support Order details.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 11/10/2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1.0
 */

 BEGIN

      DECLARE @Ln_RowsAffected_NUMB  NUMERIC(10),
              @Ld_Current_DTTM	     DATETIME2 = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
                                                                      
         UPDATE PSRD_Y1
			SET Process_CODE=@Ac_Process_CODE,
			    WorkerUpdate_ID=@Ac_SignedOnWorker_ID,
			    Update_DTTM=@Ld_Current_DTTM
		  WHERE Record_NUMB = @An_Record_NUMB 
		    AND Case_IDNO = @An_Case_IDNO;
		  
		SET @Ln_RowsAffected_NUMB =@@ROWCOUNT;
      
      SELECT @Ln_RowsAffected_NUMB  AS RowsAffected_NUMB;
              
END; --END OF PSRD_UPDATE_S1 


GO
