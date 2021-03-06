/****** Object:  StoredProcedure [dbo].[DMNR_RETRIEVE_S42]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DMNR_RETRIEVE_S42]  
      (
     @An_Case_IDNO			NUMERIC(6,0),
	 @Ac_ActivityMinor_CODE	CHAR(5),
     @Ac_Exists_INDC		CHAR(1) OUTPUT
     )
AS

/*
 *     PROCEDURE NAME    : DMNR_RETRIEVE_S42
 *     DESCRIPTION       : Retrieve the count of records from Minor Activity Diary table for the retrieved Case, Code with in the system for the Minor Activity equal to MEDICAL INSURANCE ADDITION (MSMAD) and Current Status of the Minor Activity equal to START (STRT).
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 13-OCT-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
 */
   BEGIN

     DECLARE
         @Lc_StatusStart_CODE 			CHAR(4) = 'STRT', 
		 @Lc_Yes_INDC					CHAR(1) = 'Y',
		 @Lc_No_INDC					CHAR(1)	= 'N';;
    
	 SET @Ac_Exists_INDC = @Lc_No_INDC;
	    
        SELECT @Ac_Exists_INDC = @Lc_Yes_INDC
      FROM DMNR_Y1 d
      WHERE d.Case_IDNO = @An_Case_IDNO 
        AND d.ActivityMinor_CODE = @Ac_ActivityMinor_CODE 
        AND d.Status_CODE = @Lc_StatusStart_CODE;  
                  
END   -- End of DMNR_RETRIEVE_S42


GO
