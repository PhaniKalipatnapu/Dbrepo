/****** Object:  StoredProcedure [dbo].[DCKT_RETRIEVE_S2]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DCKT_RETRIEVE_S2] (
 @Ac_File_ID					CHAR(10),
 @An_EventGlobalBeginSeq_NUMB	NUMERIC(19,0),
 @Ai_Count_QNTY					INT OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : DCKT_RETRIEVE_S2
  *     DESCRIPTION       : Checks whether the File ID exists in the Dockets_T1 table.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 12/28/2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1.0
 */
 BEGIN
  SET @Ai_Count_QNTY = NULL;

  SELECT @Ai_Count_QNTY = COUNT(1)
    FROM DCKT_Y1 D
   WHERE D.File_ID = @Ac_File_ID
     AND D.EventGlobalBeginSeq_NUMB = @An_EventGlobalBeginSeq_NUMB;
 END; -- End Of Procedure DCKT_RETRIEVE_S2

GO
