/****** Object:  StoredProcedure [dbo].[FSRT_UPDATE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE 
	[dbo].[FSRT_UPDATE_S1]
		(
		  @An_Case_IDNO 					NUMERIC(6,0)	,
		  @An_Petition_IDNO					NUMERIC(7,0)	,
		  @An_MajorIntSeq_NUMB				NUMERIC(5,0)	,
		  @An_MinorIntSeq_NUMB				NUMERIC(5,0)	,
		  @An_TransactionEventSeq_NUMB		NUMERIC(19,0)	,
		  @Ac_File_ID 						CHAR(10)		,
		  @Ac_ServiceMethod_CODE			CHAR(1)			,
		  @Ac_ServiceResult_CODE			CHAR(1)			,
		  @Ac_ServiceFailureReason_CODE		CHAR(1)			,
		  @Ad_ProcessServer_DATE			DATE			,
		  @Ad_Service_DATE					DATE			,
		  @Ac_ServiceAttn_ADDR				CHAR(40)		,
		  @As_ServiceLine1_ADDR				VARCHAR(50)		,
		  @As_ServiceLine2_ADDR				VARCHAR(50)		,
		  @Ac_ServiceCity_ADDR				CHAR(28)		,
		  @Ac_ServiceState_ADDR 			CHAR(2)			,
		  @Ac_ServiceZip_ADDR				CHAR(15)		,
		  @As_ServiceNotes_TEXT				VARCHAR(1000)	,
		  @Ac_SignedOnWorker_ID				CHAR(30)		,
		  @Ac_ServiceCountry_ADDR			CHAR(2)			,
		  @An_NewTransactionEventSeq_NUMB	NUMERIC(19,0)	
		)
AS

/*                                                                                                                                    
 *     PROCEDURE NAME    : FSRT_UPDATE_S1                                                                                           
 *     DESCRIPTION       : Modify service information details for a case id, file id,major& minor seq no.
 *     DEVELOPED BY      : IMP Team    
 *     DEVELOPED ON      : 25-JAN-2012                                                                                                
 *     MODIFIED BY       :                                                                                                            
 *     MODIFIED ON       :                                                                                                            
 *     VERSION NO        : 1                                                                                                          
*/ 

BEGIN
	DECLARE 
	    @Ld_High_DATE			DATE		= '12/31/9999',
		@Ld_Current_DTTM		DATETIME2	= dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
		@Ln_RowsAffected_NUMB	NUMERIC(10);
	   
	UPDATE FSRT_Y1
	   SET  ServiceMethod_CODE		=  @Ac_ServiceMethod_CODE 	    ,
			ServiceResult_CODE		=  @Ac_ServiceResult_CODE 	    ,
			ServiceFailureReason_CODE= @Ac_ServiceFailureReason_CODE,
			ProcessServer_DATE		=  @Ad_ProcessServer_DATE 	    ,
			Service_DATE			=  @Ad_Service_DATE 			,
			ServiceAttn_ADDR		=  @Ac_ServiceAttn_ADDR 		,
			ServiceLine1_ADDR		=  @As_ServiceLine1_ADDR		,
			ServiceLine2_ADDR		=  @As_ServiceLine2_ADDR		,
			ServiceCity_ADDR		=  @Ac_ServiceCity_ADDR 		,
			ServiceState_ADDR		=  @Ac_ServiceState_ADDR 		,
			ServiceZip_ADDR			=  @Ac_ServiceZip_ADDR          ,
			ServiceNotes_TEXT		=  @As_ServiceNotes_TEXT        ,
			TransactionEventSeq_NUMB=  @An_NewTransactionEventSeq_NUMB ,
			ServiceCountry_ADDR		=  @Ac_ServiceCountry_ADDR	    ,
			WorkerUpdate_ID			=  @Ac_SignedOnWorker_ID        ,
			BeginValidity_DATE		=  @Ld_Current_DTTM,
			Update_DTTM				=  @Ld_Current_DTTM 
	 OUTPUT	Deleted.Case_IDNO  ,
			Deleted.File_ID  ,
			Deleted.MajorIntSeq_NUMB ,
			Deleted.MinorIntSeq_NUMB ,
			Deleted.Petition_IDNO  ,
			Deleted.ServiceMethod_CODE ,
			Deleted.ServiceResult_CODE  ,
			Deleted.ServiceFailureReason_CODE ,
			Deleted.ProcessServer_DATE,
			Deleted.Service_DATE ,
			Deleted.ServiceAttn_ADDR ,
			Deleted.ServiceLine1_ADDR,
			Deleted.ServiceLine2_ADDR,
			Deleted.ServiceCity_ADDR  ,
			Deleted.ServiceState_ADDR,
			Deleted.ServiceZip_ADDR,
			Deleted.ServiceNotes_TEXT,
			Deleted.BeginValidity_DATE,
			@Ld_Current_DTTM AS EndValidity_DATE ,
			Deleted.WorkerUpdate_ID ,
			Deleted.Update_DTTM  ,
			Deleted.TransactionEventSeq_NUMB ,
			Deleted.ServiceCountry_ADDR 
	  INTO  FSRT_Y1
	 WHERE Case_IDNO = @An_Case_IDNO
	   AND File_ID = @Ac_File_ID
	   AND Petition_IDNO = @An_Petition_IDNO
	   AND MajorIntSeq_NUMB = @An_MajorIntSeq_NUMB
	   AND MinorIntSeq_NUMB = @An_MinorIntSeq_NUMB
	   AND TransactionEventSeq_NUMB=@An_TransactionEventSeq_NUMB
	   AND EndValidity_DATE = @Ld_High_DATE;

      SET
		@Ln_RowsAffected_NUMB  = @@ROWCOUNT;   
                                                      
    SELECT 
		@Ln_RowsAffected_NUMB AS RowsAffected_NUMB;
		
END;	--END OF FSRT_UPDATE_S1                                                
                                                      

GO
