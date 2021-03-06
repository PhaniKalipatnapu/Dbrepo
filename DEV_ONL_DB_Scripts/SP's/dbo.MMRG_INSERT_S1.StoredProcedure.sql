/****** Object:  StoredProcedure [dbo].[MMRG_INSERT_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[MMRG_INSERT_S1] (
 @An_MemberMciPrimary_IDNO		NUMERIC(10,0),
 @An_MemberMciSecondary_IDNO	NUMERIC(10,0),
 @Ac_StatusMerge_CODE			CHAR(1),
 @An_TransactionEventSeq_NUMB	NUMERIC(19,0),
 @Ac_SignedOnWorker_ID        	CHAR(30)    
 )                          	                  
AS

 /*
  *     PROCEDURE NAME    : MMRG_INSERT_S1
  *     DESCRIPTION       : Insert Member Merge Request details with new Sequence Event Transaction, Unique number assigned by the system to the participant (This is the ID value that will replace with the secondary DCN in all the tables that have this member ID), Unique number assigned by the system to the participant (This is the ID value that will be searched and replaced by the primary member ID in all the tables that have this member ID as a column) and status of the merge equal to PENDING (P) into Member Merge table. 
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 20-DEC-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN                                                                                   
  DECLARE @Ld_Current_DATE        DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),     
          @Ld_Systemdatetime_DTTM DATETIME2 = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),                                                                		
          @Ld_High_DATE   		  DATE = '12/31/9999';                                   
          
 INSERT MMRG_Y1
 		(MemberMciPrimary_IDNO, 
         MemberMciSecondary_IDNO, 
         StatusMerge_CODE, 
         BeginValidity_DATE, 
         EndValidity_DATE, 
         WorkerUpdate_ID, 
         Update_DTTM, 
         TransactionEventSeq_NUMB )
  VALUES( @An_MemberMciPrimary_IDNO, 
          @An_MemberMciSecondary_IDNO, 
          @Ac_StatusMerge_CODE, 
          @Ld_Current_DATE, 
          @Ld_High_DATE, 
          @Ac_SignedOnWorker_ID, 
          @Ld_Systemdatetime_DTTM, 
          @An_TransactionEventSeq_NUMB);

END; --END OF MMRG_INSERT_S1


GO
