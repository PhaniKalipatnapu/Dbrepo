/****** Object:  StoredProcedure [dbo].[NMRQ_RETRIEVE_S8]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE  [dbo].[NMRQ_RETRIEVE_S8](  
   @Ac_Notice_ID          CHAR(8),  
   @An_Barcode_NUMB       NUMERIC(12, 0),  
   @An_NoticeVersion_NUMB NUMERIC(5, 0) OUTPUT  
  )  
 AS    
 /*  
  *     PROCEDURE NAME    : NMRQ_RETRIEVE_S8
  *     DESCRIPTION       : Retrieve the Version of Notice template for a given notice.  
  *     DEVELOPED BY      : 
  *     DEVELOPED ON      : 11-jan-2012
  *     MODIFIED BY       :     
  *     MODIFIED ON       :   
  *     VERSION NO        : 1  
 */   
BEGIN  
   SET @An_NoticeVersion_NUMB = NULL;  
 
SELECT              @An_NoticeVersion_NUMB= H.notice
FROM
	(SELECT TOP 1   N.NoticeVersion_NUMB as notice
	 FROM           NRRQ_Y1 N  
	 WHERE          N.Notice_ID = @Ac_Notice_ID  
	 AND            N.Barcode_NUMB = @An_Barcode_NUMB
	 AND            ISNUMERIC(N.Notice_ID) = 0 
	 UNION
	 SELECT         N.NoticeVersion_NUMB as notice
     FROM           NMRQ_Y1 N  
     WHERE          N.Notice_ID = @Ac_Notice_ID  
     AND            N.Barcode_NUMB = @An_Barcode_NUMB
	 AND            ISNUMERIC(N.Notice_ID) = 0 ) H;
      
END; --End of NMRQ_RETRIEVE_S8


GO
