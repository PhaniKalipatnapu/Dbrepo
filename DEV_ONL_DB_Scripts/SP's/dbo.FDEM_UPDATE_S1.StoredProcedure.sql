/****** Object:  StoredProcedure [dbo].[FDEM_UPDATE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[FDEM_UPDATE_S1]  
		(
			 @An_Case_IDNO						NUMERIC(6,0)	,
			 @Ac_File_ID						CHAR(10)		,
			 @Ac_SignedOnWorker_ID				CHAR(30)		,
			 @An_TransactionEventSeq_NUMB		NUMERIC(19,0)	,
			 @Ac_FileOld_ID						CHAR(10)
		)
AS

/*
 *     PROCEDURE NAME    : FDEM_UPDATE_S1
 *     DESCRIPTION       : Delete document details filed independently in Court
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 25-JAN-2012
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
   BEGIN
		
	DECLARE 
		@Ld_High_DATE			DATE		=	'12/31/9999' ,
		@Ld_Current_DTTM		DATETIME2	=	dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
		@Ln_RowsAffected_NUMB   NUMERIC(10); 
		
	UPDATE FDEM_Y1
       SET  File_ID = @Ac_File_ID,
			BeginValidity_DATE = @Ld_Current_DTTM,
            EndValidity_DATE = @Ld_High_DATE ,
            TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB,
            Update_DTTM = @Ld_Current_DTTM,
            WorkerUpdate_ID = @Ac_SignedOnWorker_ID
    OUTPUT	Deleted.Case_IDNO,               
			Deleted.File_ID,                
			Deleted.DocReference_CODE,      
			Deleted.TypeDoc_CODE,           
			Deleted.SourceDoc_CODE,         
			Deleted.Filed_DATE,            
			Deleted.BeginValidity_DATE,      
			@Ld_Current_DTTM AS EndValidity_DATE,        
			Deleted.WorkerUpdate_ID,        
			Deleted.Update_DTTM,          
			Deleted.TransactionEventSeq_NUMB,
			Deleted.FdemDisplay_INDC,       
			Deleted.ApprovedBy_CODE,       
			Deleted.Petitioner_IDNO,        
			Deleted.Respondent_IDNO,       
			Deleted.Petition_IDNO,          
			Deleted.Order_IDNO,                   
			Deleted.MajorIntSeq_NUMB,       
			Deleted.MinorIntSeq_NUMB 
	   INTO FDEM_Y1         
      WHERE Case_IDNO = @An_Case_IDNO 
        AND File_ID = @Ac_FileOld_ID 
		AND EndValidity_DATE = @Ld_High_DATE;
      
        SET 
			@Ln_RowsAffected_NUMB = @@ROWCOUNT;                                               
                                                                                                                                                                   
		SELECT 
			@Ln_RowsAffected_NUMB AS RowsAffected_NUMB;  
    
   END;	--END OF FDEM_UPDATE_S1


GO
