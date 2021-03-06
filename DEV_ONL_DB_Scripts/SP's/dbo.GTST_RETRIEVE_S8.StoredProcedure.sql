/****** Object:  StoredProcedure [dbo].[GTST_RETRIEVE_S8]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[GTST_RETRIEVE_S8]  
(
	@An_Case_IDNO      NUMERIC(6)         ,
	@An_Schedule_NUMB  NUMERIC(10,0)   ,
    @Ad_Test_DATE      DATE            ,
    @Ac_Exists_INDC     CHAR(1)	 OUTPUT
     )
AS

/*
 *     PROCEDURE NAME    : GTST_RETRIEVE_S8
 *     DESCRIPTION       : This sp is used to check whether the data present for the particular case id and member id.
 *     DEVELOPED BY      : IMP TEAM
 *     DEVELOPED ON      : 02-AUG-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
 */

   BEGIN

      DECLARE
         @Lc_CaseRelationshipDp_CODE		 CHAR(1) = 'D', 
         @Lc_CaseMemberStatusActive_CODE 	 CHAR(1) = 'A', 
         @Ld_High_DATE					     DATE    = '12/31/9999', 
         @Lc_TestResultScheduled_CODE 		 CHAR(1) = 'S',
          @Lc_Yes_TEXT                       CHAR(1) = 'Y',  
          @Lc_No_TEXT                        CHAR(1) = 'N';  
            
     SET @Ac_Exists_INDC = @Lc_No_TEXT;  
                                                     
        SELECT TOP 1 @Ac_Exists_INDC  = @Lc_Yes_TEXT 
      		FROM GTST_Y1 g
      		WHERE g.Case_IDNO     = @An_Case_IDNO 
      		AND   g.Schedule_NUMB = @An_Schedule_NUMB 
      		AND   g.Test_DATE     = @Ad_Test_DATE 
      		AND   g.TestResult_CODE  = @Lc_TestResultScheduled_CODE 
      		AND   g.EndValidity_DATE = @Ld_High_DATE 
      		AND   g.MemberMci_IDNO IN ( SELECT  c.MemberMci_IDNO
            								FROM  CMEM_Y1 c
            								WHERE c.Case_IDNO = g.Case_IDNO 
            								AND   c.CaseRelationship_CODE = @Lc_CaseRelationshipDp_CODE 
            								AND   c.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE );

                  
END      -- End of GTST_RETRIEVE_S8;


GO
