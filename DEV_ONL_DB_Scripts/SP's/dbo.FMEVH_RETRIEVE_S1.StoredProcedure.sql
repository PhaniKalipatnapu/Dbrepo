/****** Object:  StoredProcedure [dbo].[FMEVH_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[FMEVH_RETRIEVE_S1](
 @An_MemberMci_IDNO NUMERIC(10, 0),
 @Ad_From_DATE      DATE,
 @Ad_To_DATE        DATE,
 @Ac_EventType_CODE CHAR(4),
 @Ai_RowFrom_NUMB   SMALLINT,
 @Ai_RowTo_NUMB     SMALLINT
 )
AS
 /*
  *     PROCEDURE NAME    : FMEVH_RETRIEVE_S1
  *     DESCRIPTION       : Retrieves the frozen event history details for a given member.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 05-08-2012
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SELECT A.Initiation_DATE,
         A.EventTitleDescription_TEXT,
         A.InitiatingWorker_ID,
         A.ResponsibleWorker_ID,
         A.EventType_CODE,
         A.Disposition_CODE,
         A.EventCompletion_DATE,
         A.EventCompletion_DTTM,
         A.EventNotes_TEXT,
         A.RowCount_NUMB
    FROM (SELECT f.Initiation_DATE,
                 f.EventTitleDescription_TEXT,
                 f.InitiatingWorker_ID,
                 f.ResponsibleWorker_ID,
                 f.EventType_CODE,
                 f.Disposition_CODE,
                 f.EventCompletion_DATE,
                 f.EventCompletion_DTTM,
                 f.EventNotes_TEXT,
                 COUNT(1) OVER() AS RowCount_NUMB,
                 ROW_NUMBER() OVER ( ORDER BY f.Initiation_DATE ) AS ROWNUM
            FROM FMEVH_Y1 f
           WHERE f.MemberMci_IDNO = @An_MemberMci_IDNO
             AND f.Initiation_DATE >= @Ad_From_DATE
             AND f.Initiation_DATE <= @Ad_To_DATE
             AND f.EventType_CODE = ISNULL(@Ac_EventType_CODE, f.EventType_CODE)) AS A
   WHERE A.ROWNUM BETWEEN @Ai_RowFrom_NUMB AND @Ai_RowTo_NUMB;
 END;


GO
