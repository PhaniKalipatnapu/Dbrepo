/****** Object:  StoredProcedure [dbo].[VAPP_RETRIEVE_S2]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[VAPP_RETRIEVE_S2] (
 @Ac_ChildBirthCertificate_ID		CHAR(7),
 @Ac_TypeDocument_CODE				CHAR(3),
 @An_ChildMemberMci_IDNO            NUMERIC(10, 0) OUTPUT,
 @Ac_ChildLast_NAME					CHAR(20) OUTPUT,
 @Ac_ChildFirst_NAME				CHAR(16) OUTPUT,
 @Ad_ChildBirth_DATE				DATE OUTPUT,
 @An_ChildMemberSsn_NUMB			NUMERIC(9, 0) OUTPUT,
 @Ac_ChildBirthState_CODE			CHAR(2) OUTPUT,
 @Ac_ChildBirthCity_INDC			CHAR(1) OUTPUT,
 @Ac_ChildBirthCounty_INDC			CHAR(1) OUTPUT,
 @Ac_PlaceOfAck_CODE				CHAR(3) OUTPUT,
 @As_PlaceOfAck_NAME				VARCHAR(50) OUTPUT,
 @Ac_Declaration_INDC				CHAR(1) OUTPUT,
 @Ac_GeneticTest_INDC				CHAR(1) OUTPUT,
 @Ac_NoPresumedFather_CODE			CHAR(1) OUTPUT,
 @Ac_VapPresumedFather_CODE			CHAR(1) OUTPUT,
 @Ac_DopPresumedFather_CODE			CHAR(1) OUTPUT,
 @Ac_VapAttached_CODE				CHAR(1) OUTPUT,
 @Ac_DopAttached_CODE				CHAR(1) OUTPUT,
 @Ad_MotherSignature_DATE			DATE OUTPUT,
 @Ad_FatherSignature_DATE			DATE OUTPUT,
 @Ad_Match_DATE						DATE OUTPUT,
 @Ac_DataRecordStatus_CODE			CHAR(1) OUTPUT,
 @An_FatherMemberMci_IDNO           NUMERIC(10, 0) OUTPUT,
 @Ac_FatherLast_NAME				CHAR(20) OUTPUT,
 @Ac_FatherFirst_NAME				CHAR(16) OUTPUT,
 @Ad_FatherBirth_DATE				DATE OUTPUT,
 @An_FatherMemberSsn_NUMB			NUMERIC(9, 0) OUTPUT,
 @Ac_FatherAddrExist_INDC			CHAR(1) OUTPUT,
 @An_MotherMemberMci_IDNO           NUMERIC(10, 0) OUTPUT,
 @Ac_MotherLast_NAME				CHAR(20) OUTPUT,
 @Ac_MotherFirst_NAME				CHAR(16) OUTPUT,
 @Ad_MotherBirth_DATE				DATE OUTPUT,
 @An_MotherMemberSsn_NUMB			NUMERIC(9, 0) OUTPUT,
 @Ac_MotherAddrExist_INDC			CHAR(1) OUTPUT,
 @As_Note_TEXT						VARCHAR(4000) OUTPUT,
 @Ac_WorkerUpdate_ID				CHAR(30) OUTPUT,
 @An_TransactionEventSeq_NUMB		NUMERIC(19) OUTPUT,
 @Ad_Update_DTTM					DATE OUTPUT,
 @Ac_History_INDC					CHAR(1) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME   : VAPP_RETRIEVE_S2
  *     DESCRIPTION      : Retrieves the child details for the given birth certificate and document type.
  *     DEVELOPED BY     : IMP TEAM
  *     DEVELOPED ON     : 27-OCT-2011
  *     MODIFIED BY      : 
  *     MODIFIED ON      : 
  *     VERSION NO       : 1
  */
 BEGIN

	SET @An_ChildMemberMci_IDNO = NULL;
	SET	@Ac_ChildLast_NAME = NULL;
	SET	@Ac_ChildFirst_NAME = NULL;
	SET	@Ad_ChildBirth_DATE = NULL;
	SET	@An_ChildMemberSsn_NUMB = NULL;
	SET	@Ac_ChildBirthState_CODE = NULL;
	SET	@Ac_ChildBirthCity_INDC = NULL;
	SET	@Ac_ChildBirthCounty_INDC = NULL;
	SET	@Ac_PlaceOfAck_CODE = NULL;
	SET	@As_PlaceOfAck_NAME = NULL;
	SET @Ac_Declaration_INDC = NULL;
    SET @Ac_GeneticTest_INDC = NULL;
	SET @Ac_NoPresumedFather_CODE = NULL;
    SET @Ac_VapPresumedFather_CODE = NULL;
    SET @Ac_DopPresumedFather_CODE = NULL;
	SET	@Ac_VapAttached_CODE = NULL;
	SET	@Ac_DopAttached_CODE = NULL;
	SET @Ad_MotherSignature_DATE = NULL;
    SET @Ad_FatherSignature_DATE = NULL;
	SET @Ad_Match_DATE = NULL;
    SET @Ac_DataRecordStatus_CODE = NULL;
	SET @An_FatherMemberMci_IDNO = NULL;
    SET @Ac_FatherLast_NAME = NULL;
    SET @Ac_FatherFirst_NAME = NULL;
    SET @Ad_FatherBirth_DATE = NULL;
    SET @An_FatherMemberSsn_NUMB = NULL;
    SET @Ac_FatherAddrExist_INDC = NULL;
	SET	@An_MotherMemberMci_IDNO = NULL;
    SET @Ac_MotherLast_NAME = NULL;
    SET @Ac_MotherFirst_NAME = NULL;
    SET @Ad_MotherBirth_DATE = NULL;
    SET @An_MotherMemberSsn_NUMB = NULL;
    SET @Ac_MotherAddrExist_INDC = NULL;
	SET @As_Note_TEXT = NULL;
    SET @Ac_WorkerUpdate_ID = NULL;
    SET @An_TransactionEventSeq_NUMB = NULL;
    SET @Ad_Update_DTTM = NULL;
    SET @Ac_History_INDC = NULL;

  DECLARE @Lc_Yes_INDC CHAR(1) = 'Y',
		  @Lc_No_INDC  CHAR(1) = 'N';  
         
  SELECT @An_ChildMemberMci_IDNO = V.ChildMemberMci_IDNO,
         @Ac_ChildLast_NAME = V.ChildLast_NAME,
         @Ac_ChildFirst_NAME = V.ChildFirst_NAME,
         @Ad_ChildBirth_DATE = V.ChildBirth_DATE,
         @An_ChildMemberSsn_NUMB = V.ChildMemberSsn_NUMB,
         @Ac_ChildBirthState_CODE = V.ChildBirthState_CODE,
         @Ac_ChildBirthCity_INDC = V.ChildBirthCity_INDC,
         @Ac_ChildBirthCounty_INDC = V.ChildBirthCounty_INDC,
         @Ac_PlaceOfAck_CODE = V.PlaceOfAck_CODE,
         @As_PlaceOfAck_NAME = V.PlaceOfAck_NAME,
		 @Ac_Declaration_INDC = V.Declaration_INDC,
         @Ac_GeneticTest_INDC = V.GeneticTest_INDC,
         @Ac_NoPresumedFather_CODE = V.NoPresumedFather_CODE,
         @Ac_VapPresumedFather_CODE = V.VapPresumedFather_CODE,
         @Ac_DopPresumedFather_CODE = V.DopPresumedFather_CODE,
         @Ac_VapAttached_CODE = V.VapAttached_CODE,
         @Ac_DopAttached_CODE = V.DopAttached_CODE,
		 @Ad_MotherSignature_DATE = V.MotherSignature_DATE,
         @Ad_FatherSignature_DATE = V.FatherSignature_DATE,
		 @Ad_Match_DATE = V.Match_DATE,
         @Ac_DataRecordStatus_CODE = V.DataRecordStatus_CODE,
		 @An_FatherMemberMci_IDNO = V.FatherMemberMci_IDNO,
         @Ac_FatherLast_NAME = V.FatherLast_NAME,
         @Ac_FatherFirst_NAME = V.FatherFirst_NAME,
         @Ad_FatherBirth_DATE = V.FatherBirth_DATE,
         @An_FatherMemberSsn_NUMB = V.FatherMemberSsn_NUMB,
         @Ac_FatherAddrExist_INDC = V.FatherAddrExist_INDC,
		 @An_MotherMemberMci_IDNO = V.MotherMemberMci_IDNO,
         @Ac_MotherLast_NAME = V.MotherLast_NAME,
         @Ac_MotherFirst_NAME = V.MotherFirst_NAME,
         @Ad_MotherBirth_DATE = V.MotherBirth_DATE,
         @An_MotherMemberSsn_NUMB = V.MotherMemberSsn_NUMB,
         @Ac_MotherAddrExist_INDC = V.MotherAddrExist_INDC,
         @As_Note_TEXT = V.Note_TEXT,
         @Ac_WorkerUpdate_ID = V.WorkerUpdate_ID,
         @An_TransactionEventSeq_NUMB = V.TransactionEventSeq_NUMB,
         @Ad_Update_DTTM = V.Update_DTTM,
         @Ac_History_INDC = ISNULL ((SELECT TOP 1 @Lc_Yes_INDC
                                       FROM HVAPP_Y1 H
                                      WHERE H.ChildBirthCertificate_ID = @Ac_ChildBirthCertificate_ID), @Lc_No_INDC)
  FROM VAPP_Y1 V
  WHERE V.ChildBirthCertificate_ID = @Ac_ChildBirthCertificate_ID
		AND V.TypeDocument_CODE = @Ac_TypeDocument_CODE;
	
 END; --End Of VAPP_RETRIEVE_S2


GO
