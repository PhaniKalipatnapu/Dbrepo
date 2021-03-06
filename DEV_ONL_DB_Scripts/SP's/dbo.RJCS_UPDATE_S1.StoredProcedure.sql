/****** Object:  StoredProcedure [dbo].[RJCS_UPDATE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
         
CREATE PROCEDURE [dbo].[RJCS_UPDATE_S1] (  
     @An_MemberMci_IDNO		NUMERIC(10,0),     
     @Ac_TypeArrear_CODE	CHAR(1),  
     @Ac_SignedOnWorker_ID	CHAR(30)                      
    )  
AS    
/*        
 *     PROCEDURE NAME    : RJCS_UPDATE_S1        
 *     DESCRIPTION       : Modify the EndValidity for the member_id        
 *     DEVELOPED BY      : IMP Team        
 *     DEVELOPED ON      : 27-NOV-2011        
 *     MODIFIED BY       :         
 *     MODIFIED ON       :         
 *     VERSION NO        : 1        
*/ 
 BEGIN   
     
	DECLARE	@Ld_High_DATE		DATE  =  '12/31/9999',
			@Ld_Current_DATE	DATE  = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();  
			
	 UPDATE RJCS_Y1    
		SET EndValidity_DATE  = @Ld_Current_DATE,  
			WorkerUpdate_ID  = @Ac_SignedOnWorker_ID,  
			Update_DTTM		= DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME()
	  WHERE MemberMci_IDNO  = @An_MemberMci_IDNO  
		AND TypeArrear_CODE = @Ac_TypeArrear_CODE  
		AND EndValidity_DATE = @Ld_High_DATE;    
      
	DECLARE @Ln_RowsAffected_NUMB NUMERIC(10);    
		SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;    
     SELECT @Ln_RowsAffected_NUMB; 
     
 END; --End of RJCS_UPDATE_S1.          

GO
