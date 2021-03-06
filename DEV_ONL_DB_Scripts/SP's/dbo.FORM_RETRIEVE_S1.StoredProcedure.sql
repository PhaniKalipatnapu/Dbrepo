/****** Object:  StoredProcedure [dbo].[FORM_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[FORM_RETRIEVE_S1] (
 @An_Topic_IDNO NUMERIC(10)
 )
AS
 /*  
  *     PROCEDURE NAME    : FORM_RETRIEVE_S4  
  *     DESCRIPTION       : Retrieve Minor Activity Diary FileNet Documents the given Topic ID.  
  *     DEVELOPED BY      : IMP Team  
  *     DEVELOPED ON      : 02-AUG-2011  
  *     MODIFIED BY       :   
  *     MODIFIED ON       :   
  *     VERSION NO        : 1  
 */
 BEGIN
 
  DECLARE @Li_One_NUMB INT = 1;
  
  SELECT b.Notice_ID,
         b.Recipient_CODE,
         b.Barcode_NUMB,
         b.WorkerRqst_ID,
         c.TypeService_CODE,
         c.PrintMethod_CODE,
         c.Generate_DTTM
    FROM FORM_Y1 b
          JOIN NRRQ_Y1 c
          ON b.Notice_ID = c.Notice_ID
             AND b.Barcode_NUMB = c.Barcode_NUMB
   WHERE b.Topic_IDNO = @An_Topic_IDNO
	 AND ISNUMERIC(b.Notice_ID) = @Li_One_NUMB
  UNION
  SELECT b.Notice_ID,
         b.Recipient_CODE,
         b.Barcode_NUMB,
         b.WorkerRqst_ID,
         c.TypeService_CODE,
         c.PrintMethod_CODE,
         c.Request_DTTM AS Generate_DTTM
    FROM FORM_Y1 b
          JOIN NMRQ_Y1 c
          ON b.Notice_ID = c.Notice_ID
             AND b.Barcode_NUMB = c.Barcode_NUMB
   WHERE b.Topic_IDNO = @An_Topic_IDNO
	 AND ISNUMERIC(b.Notice_ID) = @Li_One_NUMB;
 END; --End of FORM_RETRIEVE_S4  


GO
