/****** Object:  StoredProcedure [dbo].[DPRS_INSERT_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DPRS_INSERT_S1]  
(
     @Ac_File_ID		 			CHAR(10),
     @An_County_IDNO		 		NUMERIC(3,0),
     @Ac_TypePerson_CODE		 	CHAR(3),
     @An_DocketPerson_IDNO		 	NUMERIC(10,0),
     @An_TransactionEventSeq_NUMB	NUMERIC(19,0),
     @Ac_SignedOnWorker_ID		 	CHAR(30),
     @As_File_NAME		 			VARCHAR(60),
	 @Ad_EffectiveStart_DATE		DATE,
     @As_AttorneyAttn_NAME		 	VARCHAR(60),
	 @An_AssociatedMemberMci_IDNO	NUMERIC(10,0)             
)
AS

/*
 *     PROCEDURE NAME    : DPRS_INSERT_S1
 *     DESCRIPTION       : INSERT details INTO Docket Persons TABLE.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 05-AUG-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
  BEGIN

     DECLARE 
             @Ld_High_DATE 			DATE = '12/31/9999',
             @Ld_SystemDatetime_DTTM	DATETIME2 = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
             
	INSERT DPRS_Y1
	    	(File_ID, 
		 	County_IDNO, 
		 	TypePerson_CODE, 
		 	DocketPerson_IDNO, 
		 	TransactionEventSeq_NUMB,
		 	WorkerUpdate_ID, 
		 	File_NAME, 
		 	EffectiveStart_DATE, 
		 	EffectiveEnd_DATE, 
		 	BeginValidity_DATE, 
		 	EndValidity_DATE, 
		 	Update_DTTM, 
		 	AttorneyAttn_NAME,
			AssociatedMemberMci_IDNO)
	VALUES  (@Ac_File_ID, 
			@An_County_IDNO, 
			@Ac_TypePerson_CODE, 
			@An_DocketPerson_IDNO, 
			@An_TransactionEventSeq_NUMB,
			@Ac_SignedOnWorker_ID, 
			@As_File_NAME, 
			ISNULL(@Ad_EffectiveStart_DATE,@Ld_SystemDatetime_DTTM), 
			@Ld_High_DATE, 
			@Ld_SystemDatetime_DTTM, 
			@Ld_High_DATE, 
			@Ld_SystemDatetime_DTTM, 
			@As_AttorneyAttn_NAME,
			@An_AssociatedMemberMci_IDNO);

                  
END;  -- END OF DPRS_INSERT_S1


GO
