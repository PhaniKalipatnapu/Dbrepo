/****** Object:  StoredProcedure [dbo].[MMRG_RETRIEVE_S5]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[MMRG_RETRIEVE_S5] (
 @An_MemberMciPrimary_IDNO		NUMERIC(10,0),
 @An_MemberMciSecondary_IDNO	NUMERIC(10,0),
 @An_TransactionEventSeq_NUMB	NUMERIC(19,0),
 @Ai_Count_QNTY		 			INT	 OUTPUT
 )   
AS

/*
 *     PROCEDURE NAME    : MMRG_RETRIEVE_S5
 *     DESCRIPTION       : Retrieve the count of records from Member Merge table for Unique number assigned by the system to the participant (This is the ID value that will replace with the secondary DCN in all the tables that have this member ID), Unique number assigned by the system to the participant (This is the ID value that will be searched and replaced by the primary member ID in all the tables that have this member ID as a column), status of the merge equal to PENDING (P) and Unique Sequence Number that will be generated for any given Transaction on the Table. 
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 23-DEC-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
   BEGIN

      SET @Ai_Count_QNTY = NULL;

   DECLARE @Ld_High_DATE 				DATE = '12/31/9999', 
           @Lc_StatusMergePending_CODE	CHAR(1) = 'P';        
        
   SELECT @Ai_Count_QNTY = COUNT(1)
     FROM MMRG_Y1  a
    WHERE a.MemberMciPrimary_IDNO = @An_MemberMciPrimary_IDNO 
      AND a.MemberMciSecondary_IDNO = @An_MemberMciSecondary_IDNO 
      AND a.StatusMerge_CODE = @Lc_StatusMergePending_CODE 
      AND a.TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB 
      AND a.EndValidity_DATE = @Ld_High_DATE;

END; --END OF MMRG_RETRIEVE_S5 


GO
