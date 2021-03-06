/****** Object:  StoredProcedure [dbo].[FORM_RETRIEVE_S4]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[FORM_RETRIEVE_S4] (
 @An_Topic_IDNO NUMERIC(10)
 )
AS
 /*  
  *     PROCEDURE NAME    : FORM_RETRIEVE_S4  
  *     DESCRIPTION       : Retrieve Minor Activity Diary Form details for a Topic ID.  
  *     DEVELOPED BY      : IMP Team  
  *     DEVELOPED ON      : 02-AUG-2011  
  *     MODIFIED BY       :   
  *     MODIFIED ON       :   
  *     VERSION NO        : 1  
 */
 BEGIN
  SELECT b.Notice_ID,
         b.Recipient_CODE,
         b.Barcode_NUMB,
         b.WorkerRqst_ID,
         a.DescriptionNotice_TEXT,
         c.TypeService_CODE,
         c.PrintMethod_CODE,
         c.Generate_DTTM,
         c.StatusNotice_CODE
    FROM NREF_Y1 a
         JOIN FORM_Y1 b
          ON a.Notice_ID = b.Notice_ID
         JOIN NRRQ_Y1 c
          ON b.Notice_ID = c.Notice_ID
             AND a.Notice_ID = c.Notice_ID
             AND b.Barcode_NUMB = c.Barcode_NUMB
   WHERE b.Topic_IDNO = @An_Topic_IDNO
  UNION
  SELECT b.Notice_ID,
         b.Recipient_CODE,
         b.Barcode_NUMB,
         b.WorkerRqst_ID,
         a.DescriptionNotice_TEXT,
         c.TypeService_CODE,
         c.PrintMethod_CODE,
         c.Request_DTTM AS Generate_DTTM,
         c.StatusNotice_CODE
    FROM NREF_Y1 a
         JOIN FORM_Y1 b
          ON a.Notice_ID = b.Notice_ID
         JOIN NMRQ_Y1 c
          ON b.Notice_ID = c.Notice_ID
             AND a.Notice_ID = c.Notice_ID
             AND b.Barcode_NUMB = c.Barcode_NUMB
   WHERE b.Topic_IDNO = @An_Topic_IDNO;
 END; --End of FORM_RETRIEVE_S4  


GO
