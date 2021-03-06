/****** Object:  StoredProcedure [dbo].[FSRT_INSERT_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE 
	[dbo].[FSRT_INSERT_S1]
		(
		   @An_Case_IDNO					NUMERIC(6,0),
		   @An_Petition_IDNO				NUMERIC(7,0),
		   @An_MajorIntSeq_NUMB				NUMERIC(5,0),
		   @An_MinorIntSeq_NUMB				NUMERIC(5,0),
		   @An_TransactionEventSeq_NUMB		NUMERIC(19,0),
		   @Ac_File_ID						CHAR(10),
		   @Ac_ServiceMethod_CODE			CHAR(1),
		   @Ac_ServiceResult_CODE			CHAR(1),
		   @Ac_ServiceFailureReason_CODE	CHAR(1),
		   @Ad_ProcessServer_DATE			DATE,
		   @Ad_Service_DATE					DATE,
		   @Ac_ServiceAttn_ADDR				CHAR(40),
		   @As_ServiceLine1_ADDR			VARCHAR(50),
		   @As_ServiceLine2_ADDR			VARCHAR(50),
		   @Ac_ServiceCity_ADDR				CHAR(28),
		   @Ac_ServiceState_ADDR 			CHAR(2),
		   @Ac_ServiceZip_ADDR				CHAR(15),
		   @As_ServiceNotes_TEXT			VARCHAR(1000),
		   @Ac_SignedOnWorker_ID			CHAR(30),
		   @Ac_ServiceCountry_ADDR			CHAR(2)
		)
AS

/*                                                                                                                                    
 *     PROCEDURE NAME    : FSRT_INSERT_S1                                                                                           
 *     DESCRIPTION       : ADD SERVICE INFORMATION DETAILS FOR A CASE ID,FILE ID
 *     DEVELOPED BY      : IMP Team    
 *     DEVELOPED ON      : 25-JAN-2012                                                                                                
 *     MODIFIED BY       :                                                                                                            
 *     MODIFIED ON       :                                                                                                            
 *     VERSION NO        : 1                                                                                                          
*/ 

BEGIN

	DECLARE  
	   @Ld_High_DATE	DATE		='12/31/9999' ,
	   @Ld_Current_DTTM DATETIME2	= dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
	
	INSERT FSRT_Y1
			(	Case_IDNO,
				Petition_IDNO,
				MajorIntSeq_NUMB,
				MinorIntSEQ_NUMB,
				TransactionEventSeq_NUMB,
				File_ID,
				ServiceMethod_CODE,
				ServiceResult_CODE,
				ServiceFailureReason_CODE,
				ProcessServer_DATE,
				Service_DATE,
				ServiceAttn_ADDR,
				ServiceLine1_ADDR,
				ServiceLine2_ADDR,
				ServiceCity_ADDR,
				ServiceState_ADDR,
				ServiceZip_ADDR,
				ServiceNotes_TEXT,
				BeginValidity_DATE,
				EndValidity_DATE,
				WorkerUpdate_ID,
				Update_DTTM,
				ServiceCountry_ADDR )
		VALUES (  @An_Case_IDNO,
				  @An_Petition_IDNO,
				  @An_MajorIntSeq_NUMB,
				  @An_MinorIntSeq_NUMB,
				  @An_TransactionEventSeq_NUMB,
				  @Ac_File_ID,
				  @Ac_ServiceMethod_CODE,
				  @Ac_ServiceResult_CODE,
				  @Ac_ServiceFailureReason_CODE,
				  @Ad_ProcessServer_DATE,
				  @Ad_Service_DATE,
				  @Ac_ServiceAttn_ADDR,
				  @As_ServiceLine1_ADDR,
				  @As_ServiceLine2_ADDR,
				  @Ac_ServiceCity_ADDR,
				  @Ac_ServiceState_ADDR,
				  @Ac_ServiceZip_ADDR,
				  @As_ServiceNotes_TEXT,
				  @Ld_Current_DTTM,
				  @Ld_High_DATE ,
				  @Ac_SignedOnWorker_ID,
				  @Ld_Current_DTTM,
				  @Ac_ServiceCountry_ADDR );

END;	--END OF FSRT_INSERT_S1


GO
