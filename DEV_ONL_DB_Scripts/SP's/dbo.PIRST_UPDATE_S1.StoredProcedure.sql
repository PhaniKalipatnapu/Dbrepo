/****** Object:  StoredProcedure [dbo].[PIRST_UPDATE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE PROCEDURE [dbo].[PIRST_UPDATE_S1]    
    (
     @An_MemberMci_IDNO		NUMERIC(10,0),  
     @Ac_ClChange_INDC		CHAR(1),  
     @Ac_PreOffset_INDC		CHAR(1),  
     @Ac_WorkerUpdate_ID	CHAR(30)              
    )
AS  
  
/*  
 *     PROCEDURE NAME    : PIRST_UPDATE_S1  
 *     DESCRIPTION       : THIS PROCEDURE IS USED TO UPDATE PIRST_Y1 TABLE DETAILS.  
 *     DEVELOPED BY      : IMP Team  
 *     DEVELOPED ON      : 04-DEC-2011  
 *     MODIFIED BY       :   
 *     MODIFIED ON       :   
 *     VERSION NO        : 1  
*/  
    BEGIN 
    
      DECLARE @Ld_Current_DTTM   DATETIME2(7) = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(); 
      
      UPDATE PIRST_Y1  
         SET ClChange_INDC     = @Ac_ClChange_INDC,   
             PreOffset_INDC    = @Ac_PreOffset_INDC,   
             WorkerUpdate_ID   = @Ac_WorkerUpdate_ID,   
             Update_DTTM       = @Ld_Current_DTTM
       WHERE MemberMci_IDNO    = @An_MemberMci_IDNO;
        
      DECLARE @Ln_RowsAffected_NUMB NUMERIC(10);  
        
      SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;  
        
      SELECT @Ln_RowsAffected_NUMB;
        
END; --END OF PIRST_UPDATE_S1;

GO
