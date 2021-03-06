/****** Object:  StoredProcedure [dbo].[MMRG_UPDATE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[MMRG_UPDATE_S1] (
 @An_MemberMciPrimary_IDNO		NUMERIC(10,0),
 @An_MemberMciSecondary_IDNO	NUMERIC(10,0),
 @An_TransactionEventSeq_NUMB	NUMERIC(19,0)
 )                                                
AS

/*
 *     PROCEDURE NAME    : MMRG_UPDATE_S1
 *     DESCRIPTION       : Logically delete the record in Member Merge table for Unique number assigned by the system to the participant (This is the ID value that will replace with the secondary DCN in all the tables that have this member ID), Unique number assigned by the system to the participant (This is the ID value that will be searched and replaced by the primary member ID in all the tables that have this member ID as a column), status of the merge equal to PENDING (P) and Unique Sequence Number that will be generated for any given Transaction on the Table.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 21-DEC-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/

  BEGIN
	DECLARE @Ld_High_DATE         		DATE = '12/31/9999',
    	    @Ld_Current_DATE      		DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
    	    @Lc_StatusMergePending_CODE	CHAR(1) = 'P',
            @Ln_RowsAffected_NUMB 		NUMERIC(10);

  UPDATE MMRG_Y1
     SET EndValidity_DATE = @Ld_Current_DATE 
   WHERE MemberMciPrimary_IDNO = @An_MemberMciPrimary_IDNO 
     AND MemberMciSecondary_IDNO = @An_MemberMciSecondary_IDNO 
     AND StatusMerge_CODE = @Lc_StatusMergePending_CODE
     AND TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB
     AND EndValidity_DATE = @Ld_High_DATE;
          
  SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;           
                                                    
  SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB;
  
END; --END OF MMRG_UPDATE_S1 


GO
