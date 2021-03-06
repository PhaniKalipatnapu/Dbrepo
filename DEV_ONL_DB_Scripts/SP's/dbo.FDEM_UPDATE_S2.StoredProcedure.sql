/****** Object:  StoredProcedure [dbo].[FDEM_UPDATE_S2]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE 
	[dbo].[FDEM_UPDATE_S2]  
		(
			 @An_Case_IDNO						NUMERIC(6,0)     ,
			 @Ac_File_ID						CHAR(10)         ,
			 @Ac_TypeDoc_CODE					CHAR(1)          ,
			 @Ad_Filed_DATE						DATE             ,
			 @An_TransactionEventSeq_NUMB		NUMERIC(19,0)    ,
			 @An_NewTransactionEventSeq_NUMB	NUMERIC(19,0)	 ,
			 @Ac_DocReference_CODE				CHAR(4)          ,
			 @An_Document_IDNO					NUMERIC(15,0)    ,
			 @Ac_SignedOnWorker_ID				CHAR(30)              
		)
AS

/*
 *     PROCEDURE NAME    : FDEM_UPDATE_S2
 *     DESCRIPTION       : Delete document details filed independently in Court
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 25-JAN-2012
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
   BEGIN
		
	DECLARE 
		@Lc_TypeDocP_CODE		CHAR(1)		=	'P' ,
		@Lc_TypeDocO_CODE		CHAR(1)		=	'O' , 
		@Ld_High_DATE			DATE		=	'12/31/9999' ,
		@Ld_Current_DTTM		DATETIME2	=	dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
		@Ln_RowsAffected_NUMB   NUMERIC(10); 
		
	UPDATE FDEM_Y1
       SET  BeginValidity_DATE=@Ld_Current_DTTM,
            EndValidity_DATE = @Ld_Current_DTTM ,
            TransactionEventSeq_NUMB=@An_NewTransactionEventSeq_NUMB,
            Update_DTTM=@Ld_Current_DTTM,
            WorkerUpdate_ID=@Ac_SignedOnWorker_ID
    OUTPUT	Deleted.Case_IDNO,               
			Deleted.File_ID ,                
			Deleted.DocReference_CODE ,      
			Deleted.TypeDoc_CODE ,           
			Deleted.SourceDoc_CODE ,         
			Deleted.Filed_DATE  ,            
			Deleted.BeginValidity_DATE,      
			@Ld_Current_DTTM AS EndValidity_DATE ,        
			Deleted.WorkerUpdate_ID ,        
			Deleted.Update_DTTM   ,          
			Deleted.TransactionEventSeq_NUMB   ,
			Deleted.FdemDisplay_INDC ,       
			Deleted.ApprovedBy_CODE  ,       
			Deleted.Petitioner_IDNO ,        
			Deleted.Respondent_IDNO  ,       
			Deleted.Petition_IDNO ,          
			Deleted.Order_IDNO   ,                   
			Deleted.MajorIntSeq_NUMB ,       
			Deleted.MinorIntSeq_NUMB 
	   INTO FDEM_Y1         
      WHERE Case_IDNO = @An_Case_IDNO 
       AND	File_ID = @Ac_File_ID 
       AND	TransactionEventSeq_NUMB=@An_TransactionEventSeq_NUMB
			 AND ( (	TypeDoc_CODE = @Lc_TypeDocP_CODE
					AND Petition_IDNO=@An_Document_IDNO
					)
				 OR (	TypeDoc_CODE = @Lc_TypeDocO_CODE
					AND Order_IDNO=@An_Document_IDNO
					)
				) 
		AND	TypeDoc_CODE = @Ac_TypeDoc_CODE 
		AND DocReference_CODE=@Ac_DocReference_CODE 
		AND Filed_DATE = @Ad_Filed_DATE 
		AND EndValidity_DATE = @Ld_High_DATE;
      
        SET 
			@Ln_RowsAffected_NUMB = @@ROWCOUNT;                                               
                                                                                                                                                                   
		SELECT 
			@Ln_RowsAffected_NUMB AS RowsAffected_NUMB;  
    
   END;	--END OF FDEM_UPDATE_S2


GO
