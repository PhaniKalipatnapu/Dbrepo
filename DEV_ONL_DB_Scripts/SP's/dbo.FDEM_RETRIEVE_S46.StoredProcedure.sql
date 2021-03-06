/****** Object:  StoredProcedure [dbo].[FDEM_RETRIEVE_S46]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[FDEM_RETRIEVE_S46]
(  
  @An_Case_IDNO			NUMERIC(6),
  @Ac_File_ID			CHAR(10)
 )
AS

/*
 *     PROCEDURE NAME    : FDEM_RETRIEVE_S46
 *     DESCRIPTION       : Retriving the remaining File IDs for the given Case ID and File ID and the result File IDs should not be linked with any other case.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 11-JUN-2012
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
 BEGIN
	  DECLARE @Ld_High_DATE  DATE = '12/31/9999';
	  
	   SELECT DISTINCT f.File_ID
         FROM FDEM_Y1 f 
        WHERE f.Case_IDNO = @An_Case_IDNO 
          AND f.File_ID != @Ac_File_ID
          AND f.EndValidity_DATE = @Ld_High_DATE
          -- 13639 - Add not successful error still received on SORD screen - Start
          AND EXISTS (SELECT 1 
					    FROM DCKT_Y1 d
					   WHERE d.File_ID = f.File_ID)
		  AND NOT EXISTS (SELECT 1
							FROM FDEM_Y1 d
						   WHERE d.File_ID = f.File_ID
							 AND d.Case_IDNO != f.Case_IDNO 
							 AND d.EndValidity_DATE = @Ld_High_DATE);
		  -- 13639 - Add not successful error still received on SORD screen - End
 END;--END OF FDEM_RETRIEVE_S46 
 

GO
