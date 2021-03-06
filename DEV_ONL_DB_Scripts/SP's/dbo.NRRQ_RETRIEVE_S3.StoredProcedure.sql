/****** Object:  StoredProcedure [dbo].[NRRQ_RETRIEVE_S3]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[NRRQ_RETRIEVE_S3] (
 @An_Barcode_NUMB NUMERIC(12, 0),
 @Ai_Count_QNTY   INT OUTPUT
 )
AS
 /*                                                                                                              
  *     PROCEDURE NAME    : NRRQ_RETRIEVE_S3                                                                      
  *     DESCRIPTION       : Retrieve the existence of given notice with Canceled Status.  
  *     DEVELOPED BY      : IMP TEAM                                                                           
  *     DEVELOPED ON      : 03-AUG-2011                                                                          
  *     MODIFIED BY       :                                                                                      
  *     MODIFIED ON       :                                                                                      
  *     VERSION NO        : 1                                                                                    
 */
 BEGIN
  SET @Ai_Count_QNTY = NULL;

  DECLARE @Lc_NoticeStatusCancel_CODE CHAR(1) = 'C';

  SELECT @Ai_Count_QNTY = COUNT(1)
    FROM NRRQ_Y1 N1
   WHERE N1.Barcode_NUMB = @An_Barcode_NUMB
     AND N1.StatusNotice_CODE = @Lc_NoticeStatusCancel_CODE
	 AND ISNUMERIC(N1.Notice_ID) = 0;
 END; --End of NRRQ_RETRIEVE_S3  


GO
