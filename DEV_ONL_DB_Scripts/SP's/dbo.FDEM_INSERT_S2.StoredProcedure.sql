/****** Object:  StoredProcedure [dbo].[FDEM_INSERT_S2]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE 
	[dbo].[FDEM_INSERT_S2]  
		  (
			 @An_Case_IDNO					NUMERIC(6,0),
			 @Ac_File_ID					CHAR(10),
			 @Ac_TypeDoc_CODE				CHAR(1),
			 @Ad_Filed_DATE					DATE,
			 @An_Petitioner_IDNO			NUMERIC(10,0),
			 @An_Respondent_IDNO			NUMERIC(10,0),
			 @An_TransactionEventSeq_NUMB	NUMERIC(19,0),
			 @Ac_DocReference_CODE			CHAR(4),
			 @Ac_SourceDoc_CODE				CHAR(1),
			 @Ac_SignedOnWorker_ID			CHAR(30),
			 @Ac_FdemDisplay_INDC			CHAR(1),
			 @Ac_ApprovedBy_CODE			CHAR(4),
			 @An_Petition_IDNO				NUMERIC(7,0),
			 @An_Order_IDNO					NUMERIC(15,0),
			 @An_MajorIntSeq_NUMB			NUMERIC(5,0),
			 @An_MinorIntSeq_NUMB			NUMERIC(5,0)
		  )
AS

/*
 *     PROCEDURE NAME    : FDEM_INSERT_S2
 *     DESCRIPTION       : Insert docuement details filed independently in Court
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 25-JAN-2012
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
   BEGIN
   
	DECLARE 
	   @Ld_High_DATE	DATE		= '12/31/9999',
	   @Ld_Current_DTTM DATETIME2	= dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
	   
      INSERT FDEM_Y1
				(Case_IDNO, 
				 File_ID, 
				 TypeDoc_CODE,  
				 Filed_DATE,
				 Petitioner_IDNO, 
				 Respondent_IDNO,
				 TransactionEventSeq_NUMB,  
				 DocReference_CODE, 
				 SourceDoc_CODE,
				 BeginValidity_DATE, 
				 EndValidity_DATE, 
				 WorkerUpdate_ID, 
				 Update_DTTM, 
				 FdemDisplay_INDC, 
				 ApprovedBy_CODE, 
				 Petition_IDNO,
				 Order_IDNO,
				 MajorIntSeq_NUMB,
				 MinorIntSEQ_NUMB)
         VALUES (@An_Case_IDNO, 
				@Ac_File_ID, 
				@Ac_TypeDoc_CODE,
				@Ad_Filed_DATE,  
				@An_Petitioner_IDNO, 
				@An_Respondent_IDNO, 
				@An_TransactionEventSeq_NUMB, 
				@Ac_DocReference_CODE,
				@Ac_SourceDoc_CODE, 
				@Ld_Current_DTTM ,
				@Ld_High_DATE,
				@Ac_SignedOnWorker_ID,
				@Ld_Current_DTTM , 
				@Ac_FdemDisplay_INDC, 
				@Ac_ApprovedBy_CODE,
				@An_Petition_IDNO,
				@An_Order_IDNO ,
				@An_MajorIntSeq_NUMB,
				@An_MinorIntSeq_NUMB);
                  
END;	--END OF FDEM_INSERT_S2  


GO
