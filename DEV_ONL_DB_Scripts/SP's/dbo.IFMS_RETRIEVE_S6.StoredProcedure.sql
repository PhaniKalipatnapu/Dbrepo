/****** Object:  StoredProcedure [dbo].[IFMS_RETRIEVE_S6]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
    
 CREATE PROCEDURE  [dbo].[IFMS_RETRIEVE_S6] 
    (
     @An_MemberMci_IDNO				NUMERIC(10,0),
     @Ac_StateAdministration_CODE	CHAR(2)		 OUTPUT, 
     @Ai_Count_QNTY					INT			 OUTPUT  
     )
AS 
/*  
 *     PROCEDURE NAME    : IFMS_RETRIEVE_S6  
 *     DESCRIPTION       : This procedure is used to retrieve record count according to member_mci. 
 *     DEVELOPED BY      : IMP TEAM
 *     DEVELOPED ON      : 02-SEP-2011  
 *     MODIFIED BY       :   
 *     MODIFIED ON       :   
 *     VERSION NO        : 1  
*/  
BEGIN  

     SELECT @Ac_StateAdministration_CODE = NULL,
            @Ai_Count_QNTY = NULL;
	DECLARE @Li_One_NUMB SMALLINT = 1;
	     
	 SELECT TOP 1 @Ac_StateAdministration_CODE = i.StateAdministration_CODE, 
	              @Ai_Count_QNTY = @Li_One_NUMB  
	   FROM IFMS_Y1 i 
	  WHERE i.MemberMci_IDNO = @An_MemberMci_IDNO; 
END;  -- End of IFMS_RETRIEVE_S6

GO
