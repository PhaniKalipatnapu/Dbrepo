/****** Object:  StoredProcedure [dbo].[FSRT_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE 
	[dbo].[FSRT_RETRIEVE_S1]
		(
			  @An_Case_IDNO 				NUMERIC(6,0)	,
			  @An_Petition_IDNO				NUMERIC(7,0)	,
			  @An_MajorIntSeq_NUMB			NUMERIC(5,0)	,
			  @An_MinorIntSeq_NUMB			NUMERIC(5,0)	,
			  @Ac_File_ID 					CHAR(10)		,
			  @An_TransactionEventSeq_NUMB	NUMERIC(19,0)	OUTPUT,
			  @Ac_ServiceMethod_CODE		CHAR(1)			OUTPUT,
			  @Ac_ServiceResult_CODE		CHAR(1)			OUTPUT,
			  @Ac_ServiceFailureReason_CODE	CHAR(1)			OUTPUT,
			  @Ad_ProcessServer_DATE		DATE			OUTPUT,
			  @Ad_Service_DATE				DATE			OUTPUT,
			  @Ac_ServiceAttn_ADDR			CHAR(40)		OUTPUT,
			  @As_ServiceLine1_ADDR			VARCHAR(50)		OUTPUT,
			  @As_ServiceLine2_ADDR			VARCHAR(50)		OUTPUT,
			  @Ac_ServiceCity_ADDR			CHAR(28)		OUTPUT,
			  @Ac_ServiceState_ADDR 		CHAR(2)			OUTPUT,
			  @Ac_ServiceZip_ADDR			CHAR(15)		OUTPUT,
			  @As_ServiceNotes_TEXT			VARCHAR(1000)	OUTPUT,
			  @Ac_ServiceCountry_ADDR       CHAR(2)			OUTPUT
		)
AS

/*                                                                                                                                    
 *     PROCEDURE NAME    : FSRT_RETRIEVE_S1                                                                                           
 *     DESCRIPTION       : RETRIEVE THE SERVICE DETAILS FOR A CASE ID,FILE ID,MAJOR & MINOR SEQ NO.
 *     DEVELOPED BY      : IMP Team   
 *     DEVELOPED ON      : 25-JAN-2012                                                                                                
 *     MODIFIED BY       :                                                                                                            
 *     MODIFIED ON       :                                                                                                            
 *     VERSION NO        : 1                                                                                                          
*/ 

BEGIN

  DECLARE 
	@Ld_High_DATE DATE = '12/31/9999';

  SELECT @An_TransactionEventSeq_NUMB = f.TransactionEventSeq_NUMB,
         @Ac_ServiceMethod_CODE = f.ServiceMethod_CODE,
         @Ac_ServiceResult_CODE = f.ServiceResult_CODE,
         @Ac_ServiceFailureReason_CODE = f.ServiceFailureReason_CODE,
         @Ad_ProcessServer_DATE = f.ProcessServer_DATE,
         @Ad_Service_DATE = f.Service_DATE,
         @Ac_ServiceAttn_ADDR = f.ServiceAttn_ADDR,
         @As_ServiceLine1_ADDR = f.ServiceLine1_ADDR,
         @As_ServiceLine2_ADDR = f.ServiceLine2_ADDR,
         @Ac_ServiceCity_ADDR = f.ServiceCity_ADDR,
         @Ac_ServiceState_ADDR = f.ServiceState_ADDR,
         @Ac_ServiceZip_ADDR = f.ServiceZip_ADDR,
         @As_ServiceNotes_TEXT = f.ServiceNotes_TEXT,
         @Ac_ServiceCountry_ADDR = f.ServiceCountry_ADDR
    FROM FSRT_Y1 f
   WHERE f.Case_IDNO = @An_Case_IDNO 
     AND f.File_ID = @Ac_File_ID
     AND f.Petition_IDNO = @An_Petition_IDNO
     AND f.MajorIntSeq_NUMB = @An_MajorIntSeq_NUMB
     AND f.MinorIntSEQ_NUMB = @An_MinorIntSeq_NUMB
     AND f.EndValidity_DATE = @Ld_High_DATE;

END;	--END OF FSRT_RETRIEVE_S1


GO
