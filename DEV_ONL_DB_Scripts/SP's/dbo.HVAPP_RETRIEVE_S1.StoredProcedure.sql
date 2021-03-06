/****** Object:  StoredProcedure [dbo].[HVAPP_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[HVAPP_RETRIEVE_S1] (
 @Ac_ChildBirthCertificate_ID		CHAR(7),
 @Ac_TypeDocument_CODE				CHAR(3),
 @An_Record_NUMB					NUMERIC(6, 0),
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
 @An_RowCount_NUMB                  NUMERIC(6, 0) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME   : HVAPP_RETRIEVE_S1
  *     DESCRIPTION      : Retrieves the history details of vap or dop information for the given birth certificate and document type.
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
	SET @An_RowCount_NUMB = NULL;
         
  SELECT @An_ChildMemberMci_IDNO = X.ChildMemberMci_IDNO,
         @Ac_ChildLast_NAME = X.ChildLast_NAME,
         @Ac_ChildFirst_NAME = X.ChildFirst_NAME,
         @Ad_ChildBirth_DATE = X.ChildBirth_DATE,
         @An_ChildMemberSsn_NUMB = X.ChildMemberSsn_NUMB,
         @Ac_ChildBirthState_CODE = X.ChildBirthState_CODE,
         @Ac_ChildBirthCity_INDC = X.ChildBirthCity_INDC,
         @Ac_ChildBirthCounty_INDC = X.ChildBirthCounty_INDC,
         @Ac_PlaceOfAck_CODE = X.PlaceOfAck_CODE,
         @As_PlaceOfAck_NAME = X.PlaceOfAck_NAME,
		 @Ac_Declaration_INDC = X.Declaration_INDC,
         @Ac_GeneticTest_INDC = X.GeneticTest_INDC,
         @Ac_NoPresumedFather_CODE = X.NoPresumedFather_CODE,
         @Ac_VapPresumedFather_CODE = X.VapPresumedFather_CODE,
         @Ac_DopPresumedFather_CODE = X.DopPresumedFather_CODE,
         @Ac_VapAttached_CODE = X.VapAttached_CODE,
         @Ac_DopAttached_CODE = X.DopAttached_CODE,
		 @Ad_MotherSignature_DATE = X.MotherSignature_DATE,
         @Ad_FatherSignature_DATE = X.FatherSignature_DATE,
         @Ac_DataRecordStatus_CODE = X.DataRecordStatus_CODE,
		 @An_FatherMemberMci_IDNO = X.FatherMemberMci_IDNO,
         @Ac_FatherLast_NAME = X.FatherLast_NAME,
         @Ac_FatherFirst_NAME = X.FatherFirst_NAME,
         @Ad_FatherBirth_DATE = X.FatherBirth_DATE,
         @An_FatherMemberSsn_NUMB = X.FatherMemberSsn_NUMB,
         @Ac_FatherAddrExist_INDC = X.FatherAddrExist_INDC,
		 @An_MotherMemberMci_IDNO = X.MotherMemberMci_IDNO,
         @Ac_MotherLast_NAME = X.MotherLast_NAME,
         @Ac_MotherFirst_NAME = X.MotherFirst_NAME,
         @Ad_MotherBirth_DATE = X.MotherBirth_DATE,
         @An_MotherMemberSsn_NUMB = X.MotherMemberSsn_NUMB,
         @Ac_MotherAddrExist_INDC = X.MotherAddrExist_INDC,
         @As_Note_TEXT = X.Note_TEXT,
         @Ac_WorkerUpdate_ID = X.WorkerUpdate_ID,
         @An_TransactionEventSeq_NUMB = X.TransactionEventSeq_NUMB,
         @Ad_Update_DTTM = X.Update_DTTM,
		 @An_RowCount_NUMB = X.row_count
  FROM (SELECT H.ChildMemberMci_IDNO,
                 H.ChildLast_NAME,
                 H.ChildFirst_NAME,
                 H.ChildBirth_DATE,
                 H.ChildMemberSsn_NUMB,
                 H.ChildBirthState_CODE,
                 H.ChildBirthCity_INDC,
                 H.ChildBirthCounty_INDC,
                 H.PlaceOfAck_CODE,
                 H.PlaceOfAck_NAME,
                 H.Declaration_INDC,
                 H.GeneticTest_INDC,
                 H.NoPresumedFather_CODE,
                 H.VapPresumedFather_CODE,
                 H.DopPresumedFather_CODE,
                 H.VapAttached_CODE,
                 H.DopAttached_CODE,
                 H.MotherSignature_DATE,
                 H.FatherSignature_DATE,
                 H.DataRecordStatus_CODE,
                 H.FatherMemberMci_IDNO,
                 H.FatherLast_NAME,
                 H.FatherFirst_NAME,
                 H.FatherBirth_DATE,
                 H.FatherMemberSsn_NUMB,
                 H.FatherAddrExist_INDC,
                 H.MotherMemberMci_IDNO,
                 H.MotherLast_NAME,
                 H.MotherFirst_NAME,
                 H.MotherBirth_DATE,
                 H.MotherMemberSsn_NUMB,
                 H.MotherAddrExist_INDC,
                 H.Note_TEXT,
                 H.WorkerUpdate_ID,
				 H.TransactionEventSeq_NUMB,
                 H.Update_DTTM,
                 COUNT(1) OVER() AS row_count,
                 ROW_NUMBER() OVER( ORDER BY H.TransactionEventSeq_NUMB DESC ) AS RecRank_NUMB
            FROM HVAPP_Y1 H
           WHERE H.ChildBirthCertificate_ID = @Ac_ChildBirthCertificate_ID
		AND H.TypeDocument_CODE = @Ac_TypeDocument_CODE) AS X
	WHERE X.RecRank_NUMB = @An_Record_NUMB;
	
 END; --End Of HVAPP_RETRIEVE_S1


GO
