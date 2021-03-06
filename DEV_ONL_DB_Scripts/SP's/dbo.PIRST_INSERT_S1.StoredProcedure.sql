/****** Object:  StoredProcedure [dbo].[PIRST_INSERT_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE PROCEDURE [dbo].[PIRST_INSERT_S1]    
    (
     @An_MemberMci_IDNO		NUMERIC(10,0),  
     @Ac_ClChange_INDC		CHAR(1),  
     @Ac_PreOffset_INDC		CHAR(1),  
     @Ac_WorkerUpdate_ID	CHAR(30)  
    )              
AS  
  
/*  
 *     PROCEDURE NAME    : PIRST_INSERT_S1  
 *     DESCRIPTION       : THIS PROCEDURE IS USED TO INSERT PIRST_Y1 TABLE DETAILS.  
 *     DEVELOPED BY      : IMP Team  
 *     DEVELOPED ON      : 04-DEC-2011  
 *     MODIFIED BY       :   
 *     MODIFIED ON       :   
 *     VERSION NO        : 1  
*/  
    BEGIN 
    
      DECLARE @Ld_Current_DTTM   DATETIME2(7) = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(); 
      
      INSERT PIRST_Y1(  
         MemberMci_IDNO,   
         ClChange_INDC,   
         PreOffset_INDC,   
         WorkerUpdate_ID,   
         Update_DTTM)  
         VALUES (@An_MemberMci_IDNO,   --MemberMci_IDNO
                 @Ac_ClChange_INDC,    --ClChange_INDC
                 @Ac_PreOffset_INDC,   --PreOffset_INDC
                 @Ac_WorkerUpdate_ID,  --WorkerUpdate_ID 
                 @Ld_Current_DTTM      --Update_DTTM
                );    
  
END;  --END OF PIRST_INSERT_S1;

GO
