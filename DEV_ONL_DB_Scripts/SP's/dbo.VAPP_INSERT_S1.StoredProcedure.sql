/****** Object:  StoredProcedure [dbo].[VAPP_INSERT_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[VAPP_INSERT_S1] (
 @Ac_ChildBirthCertificate_ID		CHAR(7),
 @Ac_TypeDocument_CODE				CHAR(3),
 @An_ChildMemberMci_IDNO            NUMERIC(10, 0),
 @Ac_ChildLast_NAME					CHAR(20),
 @Ac_ChildFirst_NAME				CHAR(16),
 @Ad_ChildBirth_DATE				DATE,
 @An_ChildMemberSsn_NUMB			NUMERIC(9, 0),
 @Ac_ChildBirthState_CODE			CHAR(2),
 @Ac_ChildBirthCity_INDC			CHAR(1),
 @Ac_ChildBirthCounty_INDC			CHAR(1),
 @Ac_PlaceOfAck_CODE				CHAR(3),
 @As_PlaceOfAck_NAME				VARCHAR(50),
 @Ac_Declaration_INDC				CHAR(1),
 @Ac_GeneticTest_INDC				CHAR(1),
 @Ac_NoPresumedFather_CODE			CHAR(1),
 @Ac_VapPresumedFather_CODE			CHAR(1),
 @Ac_DopPresumedFather_CODE			CHAR(1),
 @Ac_VapAttached_CODE				CHAR(1),
 @Ac_DopAttached_CODE				CHAR(1),
 @Ac_DataRecordStatus_CODE			CHAR(1),
 @Ac_ImageLink_INDC					CHAR(1),
 @An_FatherMemberMci_IDNO           NUMERIC(10, 0),
 @Ac_FatherLast_NAME				CHAR(20),
 @Ac_FatherFirst_NAME				CHAR(16),
 @An_FatherMemberSsn_NUMB			NUMERIC(9, 0),
 @Ac_FatherAddrExist_INDC			CHAR(1),
 @An_MotherMemberMci_IDNO           NUMERIC(10, 0),
 @Ac_MotherLast_NAME				CHAR(20),
 @Ac_MotherFirst_NAME				CHAR(16),
 @An_MotherMemberSsn_NUMB			NUMERIC(9, 0),
 @Ac_MotherAddrExist_INDC			CHAR(1),
 @As_Note_TEXT						VARCHAR(4000),
 @Ac_SignedOnWorker_ID				CHAR(30),
 @An_TransactionEventSeq_NUMB		NUMERIC(19, 0),
 @An_MatchPoint_QNTY				NUMERIC(2, 0)
 )
AS
 /*
  *     PROCEDURE NAME    : VAPP_INSERT_S1
  *     DESCRIPTION       : Inserts the vap or dop information.
  *     DEVELOPED BY      : IMP TEAM
  *     DEVELOPED ON      : 02-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
 DECLARE
		@Ld_High_DATE           DATE = '12/31/9999',
		@Ld_Low_DATE			DATE = '01/01/0001',
		@Ld_Systemdate_DATE DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
		@Ld_Systemdatetime_DTTM DATETIME2 = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
		 
  INSERT VAPP_Y1 
			(ChildBirthCertificate_ID,
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
			 WorkerUpdate_ID,
			 TransactionEventSeq_NUMB,
			 Update_DTTM,
			 MatchPoint_QNTY)
  VALUES( @Ac_ChildBirthCertificate_ID,
		 @Ac_TypeDocument_CODE,
		 @An_ChildMemberMci_IDNO,
		 @Ac_ChildLast_NAME,
		 @Ac_ChildFirst_NAME,
		 @Ad_ChildBirth_DATE,
		 @An_ChildMemberSsn_NUMB,
		 @Ac_ChildBirthState_CODE,
		 @Ac_ChildBirthCity_INDC,
		 @Ac_ChildBirthCounty_INDC,
		 @Ac_PlaceOfAck_CODE,
		 @As_PlaceOfAck_NAME,
		 @Ac_Declaration_INDC,
		 @Ac_GeneticTest_INDC,
		 @Ac_NoPresumedFather_CODE,
		 @Ac_VapPresumedFather_CODE,
		 @Ac_DopPresumedFather_CODE,
		 @Ac_VapAttached_CODE,
		 @Ac_DopAttached_CODE,
		 @Ld_Low_DATE,
		 @Ld_Low_DATE,
		 @Ld_Low_DATE,
		 @Ac_DataRecordStatus_CODE,
		 @Ac_ImageLink_INDC,
		 @An_FatherMemberMci_IDNO,
		 @Ac_FatherLast_NAME,
		 @Ac_FatherFirst_NAME,
		 @Ld_Low_DATE,
		 @An_FatherMemberSsn_NUMB,
		 @Ac_FatherAddrExist_INDC,
		 @An_MotherMemberMci_IDNO,
		 @Ac_MotherLast_NAME,
		 @Ac_MotherFirst_NAME,
		 @Ld_Low_DATE,
		 @An_MotherMemberSsn_NUMB,
		 @Ac_MotherAddrExist_INDC,
		 @As_Note_TEXT,
		 @Ld_Systemdate_DATE,
		 @Ac_SignedOnWorker_ID,
		 @An_TransactionEventSeq_NUMB,
		 @Ld_Systemdatetime_DTTM,
		 @An_MatchPoint_QNTY);
 END;


GO
