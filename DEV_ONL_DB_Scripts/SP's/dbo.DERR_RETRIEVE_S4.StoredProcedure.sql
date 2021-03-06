/****** Object:  StoredProcedure [dbo].[DERR_RETRIEVE_S4]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DERR_RETRIEVE_S4] ( 
		 @Ac_CheckRecipient_CODE		CHAR(1),
		 @Ad_Generate_DATE				DATE,
		 @Ac_ReasonAction_CODE          CHAR(3),
		 @Ac_ReasonActionType_CODE      CHAR(1),
		 @Ai_CountPreNotes_QNTY         INT				OUTPUT
		 )
AS

/*
 *     PROCEDURE NAME    : DERR_RETRIEVE_S4
 *     DESCRIPTION       : This procedure is used to get the PreNote Reject Count for the given date
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 05-NOV-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
 */

    BEGIN
      SET @Ai_CountPreNotes_QNTY	= NULL;
      
    DECLARE
		 @Li_One_NUMB				INT			 = 1,
         @Lc_Space_CODE				CHAR(1)      = ' ', 
         @Ld_High_DATE				DATE		 = '12/31/9999', 
         @Lc_PreNoteEft_CODE		CHAR(1)      = 'P'; 
        
         SELECT @Ai_CountPreNotes_QNTY = COUNT(1) 
           FROM DERR_Y1 a 
				JOIN EFTR_Y1 b
				  ON a.CheckRecipient_ID = b.CheckRecipient_ID                           
					 AND a.CheckRecipient_CODE = b.CheckRecipient_CODE                           
					 AND a.Misc_ID = b.Misc_ID                                              
          WHERE a.Generate_DATE = @Ad_Generate_DATE                                     
            AND a.TypeEft_CODE = @Lc_PreNoteEft_CODE                                         
            AND LEFT (a.ReasonAction_CODE, @Li_One_NUMB) = @Ac_ReasonActionType_CODE   
            AND (   @Ac_ReasonAction_CODE IS NULL                                         
                 OR @Ac_ReasonAction_CODE = @Lc_Space_CODE                                     
                 OR a.ReasonAction_CODE = @Ac_ReasonAction_CODE                           
                )                                                                       
            AND (   @Ac_CheckRecipient_CODE IS NULL                                     
                 OR (    @Ac_CheckRecipient_CODE IS NOT NULL                            
                     AND a.CheckRecipient_CODE = @Ac_CheckRecipient_CODE                
                    )                                                                   
                )                                                                       
            AND b.EndValidity_DATE = @Ld_High_DATE;                                      
         
END; -- END OF DERR_RETRIEVE_S4


GO
