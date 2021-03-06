/****** Object:  StoredProcedure [dbo].[FSRT_RETRIEVE_S2]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE 
	[dbo].[FSRT_RETRIEVE_S2]
		(
		  @An_Case_IDNO					NUMERIC(6,0)		,
		  @An_Petition_IDNO				NUMERIC(7,0)		,
		  @An_MajorIntSeq_NUMB			NUMERIC(5,0)		,
		  @An_MinorIntSeq_NUMB			NUMERIC(5,0)		,
		  @Ac_File_ID					CHAR(10)			,  
		  @An_Record_NUMB               NUMERIC(6,0)		,
		  @An_TransactionEventSeq_NUMB 	NUMERIC(19,0)	OUTPUT,
		  @Ac_ServiceMethod_CODE 		CHAR(1)			OUTPUT,
		  @Ac_ServiceResult_CODE 		CHAR(1)			OUTPUT,
		  @Ac_ServiceFailureReason_CODE	CHAR(1)			OUTPUT,
		  @Ad_ProcessServer_DATE 		DATE			OUTPUT,
		  @Ad_Service_DATE 				DATE			OUTPUT,
		  @Ac_ServiceAttn_ADDR 			CHAR(40)		OUTPUT,
		  @As_ServiceLine1_ADDR 		VARCHAR(50)		OUTPUT, 
		  @As_ServiceLine2_ADDR 		VARCHAR(50)		OUTPUT,
		  @Ac_ServiceCity_ADDR 			CHAR(28)		OUTPUT,
		  @Ac_ServiceState_ADDR 		CHAR(2)			OUTPUT,
		  @Ac_ServiceZip_ADDR 			CHAR(15)		OUTPUT,
		  @As_ServiceNotes_TEXT 		VARCHAR(1000)	OUTPUT,
		  @Ad_Update_DTTM               DATETIME2(0)	OUTPUT,
		  @Ac_WorkerUpdate_ID			CHAR(30)		OUTPUT,
		  @Ac_ServiceCountry_ADDR       CHAR(2)			OUTPUT,
		  @An_Office_IDNO				NUMERIC(3,0)	OUTPUT,
		  @An_TotalCount_QNTY           NUMERIC(6,0)	OUTPUT
		)
AS

/*                                                                                                                                    
 *     PROCEDURE NAME    : FSRT_RETRIEVE_S2                                                                                           
 *     DESCRIPTION       : RETRIEVE THE SERVICE INFORMATION HISTORY FOR A CASE ID,FILE ID,MAJOR & MINOR SEQ NO.
 *     DEVELOPED BY      : IMP Team    
 *     DEVELOPED ON      : 25-JAN-2011                                                                                                
 *     MODIFIED BY       :                                                                                                            
 *     MODIFIED ON       :                                                                                                            
 *     VERSION NO        : 1                                                                                                          
*/ 

BEGIN
	
 SELECT @An_TransactionEventSeq_NUMB  = NULL ,      
        @Ac_ServiceMethod_CODE        = NULL ,
        @Ac_ServiceResult_CODE        = NULL ,
        @Ac_ServiceFailureReason_CODE = NULL ,
        @Ad_ProcessServer_DATE        = NULL , 
        @Ad_Service_DATE              = NULL ,     
        @Ac_ServiceAttn_ADDR          = NULL ,
        @As_ServiceLine1_ADDR         = NULL ,
        @As_ServiceLine2_ADDR         = NULL , 
        @Ac_ServiceCity_ADDR          = NULL , 
        @Ac_ServiceState_ADDR         = NULL , 
        @Ac_ServiceZip_ADDR           = NULL ,
        @As_ServiceNotes_TEXT         = NULL , 
        @Ad_Update_DTTM               = NULL ,
        @Ac_WorkerUpdate_ID           = NULL ,    
        @Ac_ServiceCountry_ADDR       = NULL ,
        @An_Office_IDNO               = NULL ,  
        @An_TotalCount_QNTY           = NULL ;

  DECLARE 
	@Ld_High_DATE DATE = '12/31/9999';     

  SELECT  @An_TransactionEventSeq_NUMB = TransactionEventSeq_NUMB,
          @Ac_ServiceMethod_CODE = ServiceMethod_CODE,
          @Ac_ServiceResult_CODE = ServiceResult_CODE,
          @Ac_ServiceFailureReason_CODE = ServiceFailureReason_CODE,
          @Ad_ProcessServer_DATE = ProcessServer_DATE,
          @Ad_Service_DATE = Service_DATE,
          @Ac_ServiceAttn_ADDR = ServiceAttn_ADDR,
          @As_ServiceLine1_ADDR = ServiceLine1_ADDR,
          @As_ServiceLine2_ADDR = ServiceLine2_ADDR,
          @Ac_ServiceCity_ADDR = ServiceCity_ADDR,
          @Ac_ServiceState_ADDR = ServiceState_ADDR,
          @Ac_ServiceZip_ADDR = ServiceZip_ADDR,
          @As_ServiceNotes_TEXT = ServiceNotes_TEXT,
          @Ad_Update_DTTM = Update_DTTM,
          @Ac_WorkerUpdate_ID = WorkerUpdate_ID,
          @Ac_ServiceCountry_ADDR = ServiceCountry_ADDR,
          @An_Office_IDNO=A.Office_IDNO ,
          @An_TotalCount_QNTY = TotalCount_QNTY
    FROM (
		  SELECT  F.ServiceMethod_CODE,
				  F.ServiceResult_CODE,
				  F.ServiceFailureReason_CODE,
				  F.ProcessServer_DATE,
				  F.Service_DATE,
				  F.ServiceAttn_ADDR,
				  F.ServiceLine1_ADDR,
				  F.ServiceLine2_ADDR,
				  F.ServiceCity_ADDR,
				  F.ServiceState_ADDR,
				  F.ServiceZip_ADDR,
				  F.ServiceNotes_TEXT,
				  F.TransactionEventSeq_NUMB,
				  F.Update_DTTM,
				  F.WorkerUpdate_ID,
				  F.ServiceCountry_ADDR,
				  (SELECT  TOP 1 u.Office_IDNO 
				    FROM  UASM_Y1 u 
				   WHERE 
					u.Worker_ID = F.WorkerUpdate_ID) Office_IDNO,
				  ROW_NUMBER() OVER(ORDER BY F.BeginValidity_DATE DESC,F.TransactionEventSeq_NUMB DESC) RowCount_NUMB,
				  COUNT(1) OVER() TotalCount_QNTY 
			FROM FSRT_Y1 F
		   WHERE F.Case_IDNO = @An_Case_IDNO 
			 AND F.File_ID = @Ac_File_ID
			 AND F.Petition_IDNO = @An_Petition_IDNO
			 AND F.MajorIntSeq_NUMB = @An_MajorIntSeq_NUMB
			 AND F.MinorIntSeq_NUMB = @An_MinorIntSeq_NUMB
			 AND F.EndValidity_DATE <> @Ld_High_DATE
        ) A 
       WHERE A.RowCount_NUMB = @An_Record_NUMB;

END;	--END OF FSRT_RETRIEVE_S2


GO
