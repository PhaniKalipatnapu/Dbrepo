/****** Object:  StoredProcedure [dbo].[GTST_RETRIEVE_S4]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[GTST_RETRIEVE_S4]  
 (
 	  @An_Case_IDNO         NUMERIC(6)       ,
 	  @An_Schedule_NUMB 	NUMERIC(10,0)    ,
      @Ad_Test_DATE         DATE             
 )              
AS

/*
 *     PROCEDURE NAME    : GTST_RETRIEVE_S4
 *     DESCRIPTION       : This sp is used to return the MemberMci_IDNO for the given Case_IDNO
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 02-AUG-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
 */

   BEGIN

      DECLARE
         @Ld_High_DATE				    DATE    = '12/31/9999', 
         @Lc_TestResultScheduled_CODE 	CHAR(1) = 'S';
        
      SELECT a.MemberMci_IDNO 
      		 FROM GTST_Y1 a
      		 WHERE a.Case_IDNO        = @An_Case_IDNO 
      		 AND   a.Schedule_NUMB    = @An_Schedule_NUMB 
      		 AND   a.EndValidity_DATE = @Ld_High_DATE 
      		 AND   a.Test_DATE		  = @Ad_Test_DATE 
      		 AND   a.TestResult_CODE  = @Lc_TestResultScheduled_CODE;

                  
END    -- End of GTST_RETRIEVE_S4;


GO
