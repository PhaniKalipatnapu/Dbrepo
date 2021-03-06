/****** Object:  StoredProcedure [dbo].[RCTR_RETRIEVE_S14]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RCTR_RETRIEVE_S14] (  

			 @Ad_Batch_DATE          DATE,
			 @Ac_SourceBatch_CODE    CHAR(3),
			 @An_Batch_NUMB          NUMERIC(4,0),
			 @An_SeqReceipt_NUMB     NUMERIC(6,0),
			 @Ai_Count_QNTY          INT  OUTPUT
			)
AS

/*
 *     PROCEDURE NAME    : RCTR_RETRIEVE_S14
 *     DESCRIPTION       : This proceudre is used to check whether the given receipt is  posted/reposted on the same day
 *						   If the COUNT > 0 then receipt was posted/repostd on sameday else no
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 02-DEC-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
 */
BEGIN
      
      DECLARE
			 @Ld_High_DATE	   DATE  = '12/31/9999',
			 @Ld_Current_DATE  DATE  = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
       
         SET @Ai_Count_QNTY = NULL; 
        
      SELECT @Ai_Count_QNTY = COUNT(1)
        FROM RCTR_Y1 a
       WHERE a.Batch_DATE		  = @Ad_Batch_DATE 
         AND a.SourceBatch_CODE   = @Ac_SourceBatch_CODE 
         AND a.Batch_NUMB		  = @An_Batch_NUMB 
         AND a.SeqReceipt_NUMB	  = @An_SeqReceipt_NUMB 
         AND a.BeginValidity_DATE = @Ld_Current_DATE
         AND a.EndValidity_DATE   = @Ld_High_DATE;
                  
END


GO
