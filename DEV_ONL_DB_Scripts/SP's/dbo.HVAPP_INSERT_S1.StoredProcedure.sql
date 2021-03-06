/****** Object:  StoredProcedure [dbo].[HVAPP_INSERT_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[HVAPP_INSERT_S1]    
( 
 @Ac_ChildBirthCertificate_ID		CHAR(7),
 @Ac_TypeDocument_CODE				CHAR(3)
)          
AS  
  
  /*
   *     PROCEDURE NAME    : HVAPP_INSERT_S1
   *     DESCRIPTION       : Inserts the vap and dop information into history. 
   *     DEVELOPED BY      : IMP Team
   *     DEVELOPED ON      : 10/13/2011
   *     MODIFIED BY       :   
   *     MODIFIED ON       :
   *     VERSION NO        : 1
  */  
	BEGIN  
	
	DECLARE
		@Ld_Systemdate_DATE DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
		@Ld_Systemdatetime_DTTM DATETIME2 = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
		
	INSERT HVAPP_Y1(  
			 ChildBirthCertificate_ID,
			 TypeDocument_CODE,
			 ChildMemberMci_IDNO,
			 ChildLast_NAME,
			 ChildFirst_NAME,
			 ChildBirth_DATE,
			 ChildMemberSsn_NUMB,
			 ChildBirthState_CODE,
			 ChildBirthCity_INDC,
			 ChildBirthCounty_INDC,
			 PlaceOfAck_CODE,
			 PlaceOfAck_NAME,
			 Declaration_INDC,
			 GeneticTest_INDC,
			 NoPresumedFather_CODE,
			 VapPresumedFather_CODE,
			 DopPresumedFather_CODE,
			 VapAttached_CODE,
			 DopAttached_CODE,
			 MotherSignature_DATE,
			 FatherSignature_DATE,
			 Match_DATE,
			 DataRecordStatus_CODE,
			 ImageLink_INDC,
			 FatherMemberMci_IDNO,
			 FatherLast_NAME,
			 FatherFirst_NAME,
			 FatherBirth_DATE,
			 FatherMemberSsn_NUMB,
			 FatherAddrExist_INDC,
			 MotherMemberMci_IDNO,
			 MotherLast_NAME,
			 MotherFirst_NAME,
			 MotherBirth_DATE,
			 MotherMemberSsn_NUMB,
			 MotherAddrExist_INDC,
			 Note_TEXT,
			 BeginValidity_DATE,
			 EndValidity_DATE,
			 WorkerUpdate_ID,
			 TransactionEventSeq_NUMB,
			 Update_DTTM)  
	SELECT V.ChildBirthCertificate_ID,
		 V.TypeDocument_CODE,
		 V.ChildMemberMci_IDNO,
		 V.ChildLast_NAME,
		 V.ChildFirst_NAME,
		 V.ChildBirth_DATE,
		 V.ChildMemberSsn_NUMB,
		 V.ChildBirthState_CODE,
		 V.ChildBirthCity_INDC,
		 V.ChildBirthCounty_INDC,
		 V.PlaceOfAck_CODE,
		 V.PlaceOfAck_NAME,
		 V.Declaration_INDC,
		 V.GeneticTest_INDC,
		 V.NoPresumedFather_CODE,
		 V.VapPresumedFather_CODE,
		 V.DopPresumedFather_CODE,
		 V.VapAttached_CODE,
		 V.DopAttached_CODE,
		 V.MotherSignature_DATE,
		 V.FatherSignature_DATE,
		 V.Match_DATE,
		 V.DataRecordStatus_CODE,
		 V.ImageLink_INDC,
		 V.FatherMemberMci_IDNO,
		 V.FatherLast_NAME,
		 V.FatherFirst_NAME,
		 V.FatherBirth_DATE,
		 V.FatherMemberSsn_NUMB,
		 V.FatherAddrExist_INDC,
		 V.MotherMemberMci_IDNO,
		 V.MotherLast_NAME,
		 V.MotherFirst_NAME,
		 V.MotherBirth_DATE,
		 V.MotherMemberSsn_NUMB,
		 V.MotherAddrExist_INDC,
		 V.Note_TEXT,
		 V.BeginValidity_DATE,
		 @Ld_Systemdate_DATE,
		 V.WorkerUpdate_ID,
		 V.TransactionEventSeq_NUMB,
		 @Ld_Systemdatetime_DTTM
	FROM VAPP_Y1 V
	WHERE V.ChildBirthCertificate_ID = @Ac_ChildBirthCertificate_ID
		AND V.TypeDocument_CODE = @Ac_TypeDocument_CODE; 
     
 END; --End Of HVAPP_INSERT_S1


GO
