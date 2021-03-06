/****** Object:  StoredProcedure [dbo].[GTST_RETRIEVE_S15]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[GTST_RETRIEVE_S15]  
(
     @An_Case_IDNO       NUMERIC(6)      ,
     @An_Schedule_NUMB   NUMERIC(10)    ,
     @Ac_Exists_INDC     CHAR(1)	OUTPUT
)
AS                                              

/*
 *     PROCEDURE NAME    : GTST_RETRIEVE_S15
 *     DESCRIPTION       : This sp is used to display the count of records present in the GTST_Y1 table for the particular case id.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 02-AUG-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
 */

   BEGIN

      DECLARE 
         @Lc_CaseRelationshipCp_CODE 		 CHAR(1) = 'C', 
         @Lc_CaseRelationshipNcp_CODE		 CHAR(1) = 'A', 
         @Lc_CaseRelationshipPutFather_CODE  CHAR(1) = 'P', 
         @Lc_CaseMemberStatusActive_CODE 	 CHAR(1) = 'A', 
         @Ld_High_DATE 					     DATE    = '12/31/9999', 
         @Lc_TestResultScheduled_CODE        CHAR(1) = 'S',
          @Lc_Yes_TEXT                       CHAR(1) = 'Y',  
          @Lc_No_TEXT                        CHAR(1) = 'N';  
            
  SET @Ac_Exists_INDC = @Lc_No_TEXT; 
                                                          
      SELECT TOP 1 @Ac_Exists_INDC  =  @Lc_Yes_TEXT
      FROM   GTST_Y1 a
      WHERE  a.Case_IDNO       = @An_Case_IDNO 
      AND    a.TestResult_CODE = @Lc_TestResultScheduled_CODE 
      AND    a.Schedule_NUMB   = @An_Schedule_NUMB
      AND    a.MemberMci_IDNO IN ( SELECT c.MemberMci_IDNO
            						 FROM CMEM_Y1 c
            						 WHERE  c.Case_IDNO = a.Case_IDNO 
            						 AND   c.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE 
            						 AND   c.CaseRelationship_CODE IN ( @Lc_CaseRelationshipCp_CODE, @Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE )) 
      AND   a.EndValidity_DATE = @Ld_High_DATE;

                  
END		-- End of GTST_RETRIEVE_S15;


GO
