/****** Object:  StoredProcedure [dbo].[SORD_RETRIEVE_S53]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SORD_RETRIEVE_S53](
	 @An_Case_IDNO					NUMERIC(6,0),
	 @Ac_File_ID					CHAR(10),
	 @An_OrderSeq_NUMB				NUMERIC(2,0),
     @Ac_StatusControl_CODE			CHAR(1)			OUTPUT,
     @Ac_StateControl_CODE			CHAR(2)			OUTPUT,
     @An_EventGlobalBeginSeq_NUMB	NUMERIC(19,0)   OUTPUT
     )
AS

/*
 *     PROCEDURE NAME    : SORD_RETRIEVE_S53
 *     DESCRIPTION       : Retrieves the SORD Details.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 12/20/2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1.0
*/

 BEGIN
      SELECT @Ac_StatusControl_CODE       = NULL,
             @Ac_StateControl_CODE        = NULL,
             @An_EventGlobalBeginSeq_NUMB = NULL;

     DECLARE @Ld_High_DATE DATE = '12/31/9999';
       
      SELECT @Ac_StatusControl_CODE       = s.StatusControl_CODE, 
			 @Ac_StateControl_CODE        = s.StateControl_CODE,
			 @An_EventGlobalBeginSeq_NUMB = s.EventGlobalBeginSeq_NUMB
        FROM SORD_Y1 s 
        LEFT OUTER JOIN DCKT_Y1 d 
          ON s.File_ID          = d.File_ID
       WHERE s.Case_IDNO        = @An_Case_IDNO 
         AND s.OrderSeq_NUMB    = @An_OrderSeq_NUMB 
         AND s.File_ID          = ISNULL(@Ac_File_ID, s.File_ID) 
         AND s.EndValidity_DATE = @Ld_High_DATE;
                 
END--END OF SORD_RETRIEVE_S53


GO
