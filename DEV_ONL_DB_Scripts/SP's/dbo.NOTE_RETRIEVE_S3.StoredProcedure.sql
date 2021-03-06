/****** Object:  StoredProcedure [dbo].[NOTE_RETRIEVE_S3]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[NOTE_RETRIEVE_S3] (
 @An_Topic_IDNO NUMERIC(10, 0),
 @An_Case_IDNO  NUMERIC(6, 0)
 )
AS
 /*
  *     PROCEDURE NAME    : NOTE_RETRIEVE_S3
  *     DESCRIPTION       : Retrieve the Post and Worker's Name for a given  Case Topic .
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 24-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ld_High_DATE       DATE = '12/31/9999',
          @Lc_StatusNote_CODE CHAR(4) = 'NOTE',
          @Lc_StatusStat_CODE CHAR(4) = 'STAT';

  SELECT N.Post_IDNO,
         U.Last_NAME,
         U.Suffix_NAME,
         U.First_NAME,
         U.Middle_NAME,
         N.Update_DTTM,
         (SELECT R.DescriptionValue_TEXT
            FROM REFM_Y1 R
           WHERE R.Table_ID = @Lc_StatusNote_CODE
             AND R.TableSub_ID = @Lc_StatusStat_CODE
             AND R.Value_CODE = N.Status_CODE) AS DescriptionValue_TEXT,
         N.DescriptionNote_TEXT
    FROM NOTE_Y1 N
         LEFT OUTER JOIN USEM_Y1 U
          ON U.Worker_ID = N.WorkerUpdate_ID
             AND U.EndValidity_DATE = @Ld_High_DATE
   WHERE N.Case_IDNO = @An_Case_IDNO
     AND N.Topic_IDNO = @An_Topic_IDNO
     AND N.EndValidity_DATE = @Ld_High_DATE
   ORDER BY Post_IDNO DESC;
 END; --END OF NOTE_RETRIEVE_S3

GO
