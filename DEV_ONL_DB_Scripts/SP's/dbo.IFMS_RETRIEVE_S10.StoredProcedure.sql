/****** Object:  StoredProcedure [dbo].[IFMS_RETRIEVE_S10]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE PROCEDURE [dbo].[IFMS_RETRIEVE_S10]    
  (
     @An_MemberSsn_NUMB		 NUMERIC(9,0),  
     @Ai_Count_QNTY          INT            OUTPUT  
  )
AS  
  
/*  
 *     PROCEDURE NAME    : IFMS_RETRIEVE_S10  
 *     DESCRIPTION       : This procedure is used to check the given ssn is exists or not in ifms table. 
 *     DEVELOPED BY      : IMP TEAM  
 *     DEVELOPED ON      : 02-SEP-2011  
 *     MODIFIED BY       :   
 *     MODIFIED ON       :   
 *     VERSION NO        : 1  
*/  
BEGIN 
	SET @Ai_Count_QNTY = NULL; 
 SELECT @Ai_Count_QNTY = COUNT(1)  
   FROM IFMS_Y1 i 
  WHERE i.MemberSsn_NUMB = @An_MemberSsn_NUMB; 
END;-- End of IFMS_RETRIEVE_S10

GO
