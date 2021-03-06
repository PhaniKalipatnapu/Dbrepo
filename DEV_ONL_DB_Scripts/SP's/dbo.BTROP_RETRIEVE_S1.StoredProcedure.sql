/****** Object:  StoredProcedure [dbo].[BTROP_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE  [dbo].[BTROP_RETRIEVE_S1] (
	    @An_Report_IDNO          NUMERIC(10,0),
        @Ac_SignedOnWorker_ID	 CHAR(30) ,
        @Ac_Exists_INDC	         CHAR(1)   OUTPUT  
     )             
AS  
/*  
 *     PROCEDURE NAME    : BTROP_RETRIEVE_S1  
 *     DESCRIPTION       : Used to update a selected report profile.
						   This procedure is used to make changes to existing report templates.
                           Its invoked on click of the Save button under Report Profiles.
 *     DEVELOPED BY      : IMP TEAM  
 *     DEVELOPED ON      : 02-SEP-2011  
 *     MODIFIED BY       :   
 *     MODIFIED ON       :   
 *     VERSION NO        : 1  
*/  
 BEGIN 
		SET @Ac_Exists_INDC = NULL;
	DECLARE
		@Lc_Yes_INDC	CHAR(1) ='Y',
		@Lc_No_INDC		CHAR(1) ='N';
		
         SET @Ac_Exists_INDC = @Lc_No_INDC;  
       
      SELECT @Ac_Exists_INDC=@Lc_Yes_INDC
        FROM BTROP_Y1 a
       WHERE Report_IDNO=@An_Report_IDNO
         AND Worker_ID=@Ac_SignedOnWorker_ID;
 END ;--End of BTROP_RETRIEVE_S1

GO
