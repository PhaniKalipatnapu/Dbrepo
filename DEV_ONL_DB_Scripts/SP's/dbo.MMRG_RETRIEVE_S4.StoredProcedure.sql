/****** Object:  StoredProcedure [dbo].[MMRG_RETRIEVE_S4]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[MMRG_RETRIEVE_S4] (
 @An_MemberMciPrimary_IDNO		NUMERIC(10,0),
 @An_MemberMciSecondary_IDNO	NUMERIC(10,0),
 @Ai_Count_QNTY		 			INT	 OUTPUT
 )
AS

/*
 *     PROCEDURE NAME    : MMRG_RETRIEVE_S4
 *     DESCRIPTION       : Retrieve the count of records from Member Merge table for Unique number assigned by the system to the participant (This is the ID value that will replace with the secondary DCN in all the tables that have this member ID) and Unique number assigned by the system to the participant (This is the ID value that will be searched and replaced by the primary member ID in all the tables that have this member ID as a column) and status of the merge equal to PENDING (P). 
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 22-DEC-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
 BEGIN

     SET @Ai_Count_QNTY = NULL;

 DECLARE @Ld_High_DATE 					DATE = '12/31/9999', 
       	 @Lc_StatusMergePending_CODE	CHAR(1) = 'P';        
                                                                  
 SELECT @Ai_Count_QNTY = COUNT(1)
   FROM MMRG_Y1 mr
  WHERE mr.MemberMciPrimary_IDNO = @An_MemberMciPrimary_IDNO 
    AND mr.MemberMciSecondary_IDNO = @An_MemberMciSecondary_IDNO 
    AND mr.StatusMerge_CODE = @Lc_StatusMergePending_CODE 
    AND mr.EndValidity_DATE = @Ld_High_DATE;

END; --END OF MMRG_RETRIEVE_S4


GO
