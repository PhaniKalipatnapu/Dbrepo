/****** Object:  StoredProcedure [dbo].[GTST_RETRIEVE_S12]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[GTST_RETRIEVE_S12]  
(
     @An_Case_IDNO       NUMERIC(6),
     @An_MemberMci_IDNO	 NUMERIC(10),
     @Ac_TypeTest_CODE   CHAR(1),
     @Ai_Count_QNTY      INT		OUTPUT
     )                                                        
AS

/*
 *     PROCEDURE NAME    : GTST_RETRIEVE_S12
 *     DESCRIPTION       : This sp is used to check the Test Result for the particular case id or member id.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 02-AUG-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
 */

   BEGIN


      DECLARE
         @Ld_High_DATE		 		        DATE    = '12/31/9999', 
         @Lc_TestResultScheduled_CODE 	    CHAR(1) = 'S';
            
       
      SELECT @Ai_Count_QNTY  = COUNT(1)
      FROM  GTST_Y1 a
      WHERE a.MemberMci_IDNO  = ISNULL(@An_MemberMci_IDNO,a.MemberMci_IDNO) 
      AND a.Case_IDNO       = @An_Case_IDNO 
      AND a.TestResult_CODE  = @Lc_TestResultScheduled_CODE
      AND a.TypeTest_CODE   = @Ac_TypeTest_CODE
      AND a.EndValidity_DATE = @Ld_High_DATE;

                  
END       -- ENd of  GTST_RETRIEVE_S12;


GO
