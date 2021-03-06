/****** Object:  StoredProcedure [dbo].[SORD_RETRIEVE_S50]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SORD_RETRIEVE_S50]  (
     @An_Case_IDNO		 NUMERIC(6,0),
     @Ac_File_ID		 CHAR(10)              
     )
AS

/*
 *     PROCEDURE NAME    : SORD_RETRIEVE_S50
 *     DESCRIPTION       : Retrieves the details for the given case ID ad Filenumber.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 11/22/2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1.0
 */

BEGIN

      SELECT u.DescriptionNote_TEXT AS DescriptionNote_TEXT, 
			 s.BeginValidity_DATE   AS BeginValidity_DATE, 
			 s.WorkerUpdate_ID      AS WorkerUpdate_ID
        FROM UNOT_Y1  u
        LEFT OUTER JOIN SORD_Y1   s
          ON u.EventGlobalSeq_NUMB = s.EventGlobalBeginSeq_NUMB
       WHERE s.Case_IDNO           = @An_Case_IDNO  
        AND  s.File_ID             = @Ac_File_ID  
    ORDER BY u.EventGlobalSeq_NUMB DESC;
    
END--END OF SORD_RETRIEVE_S50


GO
