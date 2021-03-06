/****** Object:  StoredProcedure [dbo].[DMJR_RETRIEVE_S6]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DMJR_RETRIEVE_S6] ( 
     @An_Case_IDNO		    NUMERIC(6,0),
     @Ad_Update_DTTM		DATETIME2	 OUTPUT
)
AS
/*
 *     PROCEDURE NAME    : DMJR_RETRIEVE_S6
 *     DESCRIPTION       : This procedure returns the update date for obligation from DMJR_Y1
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 16-DEC-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
   BEGIN
      SET @Ad_Update_DTTM = NULL;

      DECLARE
         @Lc_RemedyStatusStart_CODE CHAR(4) = 'STRT', 
         @Lc_RemedyCola_CODE        CHAR(4) = 'COLA';
        
      SELECT @Ad_Update_DTTM = a.Update_DTTM
        FROM DMJR_Y1  a
       WHERE a.ActivityMajor_CODE = @Lc_RemedyCola_CODE 
         AND a.Status_CODE = @Lc_RemedyStatusStart_CODE 
         AND a.Case_IDNO = @An_Case_IDNO;
                  
END;--End of DMJR_RETRIEVE_S6


GO
