/****** Object:  StoredProcedure [dbo].[CHLD_RETRIEVE_S6]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CHLD_RETRIEVE_S6]
	(
	 @Ac_CheckRecipient_ID		CHAR(10)		  ,
	 @Ac_ReasonHold_CODE		CHAR(4)		      ,    
	 @An_Case_IDNO		 		NUMERIC(6,0)	  ,          
     @Ai_Count_QNTY           	INT     	OUTPUT    
     )
AS    
    
/*    
 *     PROCEDURE NAME    : CHLD_RETRIEVE_S6    
 *     DESCRIPTION       : Retrieves the record count for a check recipient id, case idno and check recipient code   
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 23-SEP-2011    
 *     MODIFIED BY       :     
 *     MODIFIED ON       :     
 *     VERSION NO        : 1    
 */    
    BEGIN    
    
      SET @Ai_Count_QNTY = NULL;
    
      DECLARE    
         @Li_Zero_NUMB           	SMALLINT  = 0,
         @Ld_High_DATE				DATE	  =  '12/31/9999',     
         @Lc_CheckRecipient1_CODE	CHAR(1)	  = '1',
		 @Ld_Current_DATE			DATE	  = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
		                      
		SELECT @Ai_Count_QNTY = COUNT (1)
		  FROM CHLD_Y1 a
		 WHERE a.CheckRecipient_ID	= @Ac_CheckRecipient_ID
		   AND a.CheckRecipient_CODE	= @Lc_CheckRecipient1_CODE
		   AND a.Case_IDNO	= ISNULL (@An_Case_IDNO, @Li_Zero_NUMB)
		   AND a.ReasonHold_CODE		= @Ac_ReasonHold_CODE
		   AND a.Expiration_DATE		>= @Ld_Current_DATE
		   AND a.EndValidity_DATE		= @Ld_High_DATE;
   
END;   --End of CHLD_RETRIEVE_S6.  


GO
