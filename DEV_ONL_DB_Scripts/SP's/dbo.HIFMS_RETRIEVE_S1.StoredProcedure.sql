/****** Object:  StoredProcedure [dbo].[HIFMS_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE PROCEDURE [dbo].[HIFMS_RETRIEVE_S1]    
 ( 
     @An_MemberSsn_NUMB		 NUMERIC(9,0),  
     @Ai_Count_QNTY          INT            OUTPUT  
  )
AS  
  
/*  
 *     PROCEDURE NAME    : HIFMS_RETRIEVE_S1  
 *     DESCRIPTION       : This procedure is used to check the given ssn is exists or not in hifms_y1 table.  
 *     DEVELOPED BY      : IMP TEAM  
 *     DEVELOPED ON      : 02-SEP-2011  
 *     MODIFIED BY       :   
 *     MODIFIED ON       :   
 *     VERSION NO        : 1  
*/  
BEGIN 
    SET @Ai_Count_QNTY = NULL; 
	 
 SELECT @Ai_Count_QNTY = COUNT(1)  
   FROM HIFMS_Y1 h 
  WHERE h.MemberSsn_NUMB = @An_MemberSsn_NUMB; 

END;--End of HIFMS_RETRIEVE_S1

GO
