/****** Object:  StoredProcedure [dbo].[DMJR_RETRIEVE_S5]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DMJR_RETRIEVE_S5] (
	@An_MemberMciSecondary_IDNO	NUMERIC(10,0),
	@Ai_Count_QNTY					INT	 OUTPUT
)
AS

/*
 *     PROCEDURE NAME    : DMJR_RETRIEVE_S5
 *     DESCRIPTION       : Retrieve the count of records from Major Activity Diary table for Unique number assigned by the system to the participant (This is the ID value that will be searched and replaced by the primary member ID in all the tables that have this member ID as a column) with Status of the Remedy equal to START (STRT) and Code with in the system for the Major Activity NOT equal to CASE.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 20-DEC-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/

BEGIN
	SET @Ai_Count_QNTY = NULL;
 
	DECLARE 
		@Lc_StatusStart_CODE		CHAR(4) = 'STRT',
		@Lc_ActivityMajorCase_CODE	CHAR(4) = 'CASE';
 			
   SELECT @Ai_Count_QNTY = COUNT(1)
     FROM DMJR_Y1 dmp,
		  CMEM_Y1 b
    WHERE b.MemberMci_IDNO = @An_MemberMciSecondary_IDNO  
	  AND dmp.Case_IDNO = b.Case_IDNO
	  AND ((b.CaseRelationship_CODE IN ('P','A'))
                  OR (b.CaseRelationship_CODE IN ('C') AND (OthpSource_IDNO = b.MemberMci_IDNO OR Reference_ID = CAST(b.MemberMci_IDNO AS VARCHAR))))
      AND dmp.Status_CODE = @Lc_StatusStart_CODE
      AND dmp.ActivityMajor_CODE != @Lc_ActivityMajorCase_CODE;
                
END; --END OF DMJR_RETRIEVE_S5

GO
