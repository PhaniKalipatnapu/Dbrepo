/****** Object:  StoredProcedure [dbo].[BSASW_UPDATE_S1]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[BSASW_UPDATE_S1] 
(
	@Ac_TypeComponent_CODE		CHAR(4)
)
AS
/*
 *     PROCEDURE NAME    : BSASW_UPDATE_S1
 *     DESCRIPTION       : This procedure is used to End date the statewide records according to the given component.
 *     DEVELOPED BY      : IMP TEAM
 *     DEVELOPED ON      : 01-MAR-2012
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
 */
BEGIN
	
   DECLARE @Ld_High_DATE			DATE = '12/31/9999',
		   @Ld_Current_DATE			DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
	
	UPDATE BSASW_Y1
       SET StatusRequest_DATE = @Ld_Current_DATE
     WHERE TypeComponent_CODE = @Ac_TypeComponent_CODE
       AND StatusRequest_DATE = @Ld_High_DATE;
	
   DECLARE @Ln_RowsAffected_NUMB NUMERIC(10); 
	      		  
	   SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;  
	      
    SELECT @Ln_RowsAffected_NUMB;  

END  -- END OF BSASW_UPDATE_S1 
GO
