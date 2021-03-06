/****** Object:  StoredProcedure [dbo].[BSAMS_UPDATE_S2]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[BSAMS_UPDATE_S2] 
AS
/*
 *     PROCEDURE NAME    : BSAMS_UPDATE_S2
 *     DESCRIPTION       : This procedure is used to End date the Medical Support records.
 *     DEVELOPED BY      : IMP TEAM
 *     DEVELOPED ON      : 20-FEB-2012
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
 */
BEGIN

   DECLARE @Ld_High_DATE			DATE = '12/31/9999',
		   @Ld_Current_DATE			DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

	UPDATE BSAMS_Y1
       SET EndValidity_DATE = @Ld_Current_DATE
     WHERE EndValidity_DATE = @Ld_High_DATE;
	
   DECLARE @Ln_RowsAffected_NUMB NUMERIC(10) ;
	      		  
	   SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;  
	      
	SELECT @Ln_RowsAffected_NUMB;  

END  -- END OF BSAMS_UPDATE_S2
GO
