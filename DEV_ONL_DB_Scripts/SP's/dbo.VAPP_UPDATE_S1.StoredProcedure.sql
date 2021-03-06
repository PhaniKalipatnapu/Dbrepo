/****** Object:  StoredProcedure [dbo].[VAPP_UPDATE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[VAPP_UPDATE_S1](
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
 @Ac_SignedOnWorker_ID				CHAR(30),
 @An_TransactionEventSeq_NUMB		NUMERIC(19)
 )
AS
 /*    
 *      PROCEDURE NAME    : VAPP_UPDATE_S1    
  *     DESCRIPTION       : Update child information for the given birth certificate and document type.
  *     DEVELOPED BY      : IMP Team    
  *     DEVELOPED ON      : 20-SEP-2011    
  *     MODIFIED BY       :     
  *     MODIFIED ON       :     
  *     VERSION NO        : 1    
 */
 BEGIN
 
  	DECLARE	@Ld_Current_DTTM DATETIME2 = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
	DECLARE @Ld_Current_DATE DATE = @Ld_Current_DTTM;

	UPDATE VAPP_Y1
    SET ChildBirthCertificate_ID = @Ac_ChildBirthCertificate_ID,
         ChildMemberMci_IDNO = @An_ChildMemberMci_IDNO,
         ChildLast_NAME = @Ac_ChildLast_NAME,
         ChildFirst_NAME = @Ac_ChildFirst_NAME,
         ChildBirth_DATE = @Ad_ChildBirth_DATE,
         ChildMemberSsn_NUMB = @An_ChildMemberSsn_NUMB,
         ChildBirthState_CODE = @Ac_ChildBirthState_CODE,
         ChildBirthCity_INDC = @Ac_ChildBirthCity_INDC,
         ChildBirthCounty_INDC = @Ac_ChildBirthCounty_INDC,
         PlaceOfAck_CODE = @Ac_PlaceOfAck_CODE,
		 BeginValidity_DATE = @Ld_Current_DATE,
         PlaceOfAck_NAME = @As_PlaceOfAck_NAME,        
         WorkerUpdate_ID = @Ac_SignedOnWorker_ID,
         TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB,
         Update_DTTM = @Ld_Current_DTTM   
	OUTPUT Deleted.ChildBirthCertificate_ID,
			 Deleted.TypeDocument_CODE,
			 Deleted.ChildMemberMci_IDNO,
			 Deleted.ChildLast_NAME,
			 Deleted.ChildFirst_NAME,
			 Deleted.ChildBirth_DATE,
			 Deleted.ChildMemberSsn_NUMB,
			 Deleted.ChildBirthState_CODE,
			 Deleted.ChildBirthCity_INDC,
			 Deleted.ChildBirthCounty_INDC,
			 Deleted.PlaceOfAck_CODE,
			 Deleted.PlaceOfAck_NAME,
			 Deleted.Declaration_INDC,
			 Deleted.GeneticTest_INDC,
			 Deleted.NoPresumedFather_CODE,
			 Deleted.VapPresumedFather_CODE,
			 Deleted.DopPresumedFather_CODE,
			 Deleted.VapAttached_CODE,
			 Deleted.DopAttached_CODE,
			 Deleted.MotherSignature_DATE,
			 Deleted.FatherSignature_DATE,
			 Deleted.Match_DATE,
			 Deleted.DataRecordStatus_CODE,
			 Deleted.ImageLink_INDC,
			 Deleted.FatherMemberMci_IDNO,
			 Deleted.FatherLast_NAME,
			 Deleted.FatherFirst_NAME,
			 Deleted.FatherBirth_DATE,
			 Deleted.FatherMemberSsn_NUMB,
			 Deleted.FatherAddrExist_INDC,
			 Deleted.MotherMemberMci_IDNO,
			 Deleted.MotherLast_NAME,
			 Deleted.MotherFirst_NAME,
			 Deleted.MotherBirth_DATE,
			 Deleted.MotherMemberSsn_NUMB,
			 Deleted.MotherAddrExist_INDC,
			 Deleted.Note_TEXT,
			 Deleted.BeginValidity_DATE,
			 @Ld_Current_DATE AS EndValidity_DATE,
			 Deleted.WorkerUpdate_ID,
			 Deleted.TransactionEventSeq_NUMB,
			 Deleted.Update_DTTM,
			 Deleted.MatchPoint_QNTY
	INTO HVAPP_Y1      
	WHERE ChildBirthCertificate_ID = @Ac_ChildBirthCertificate_ID
		AND TypeDocument_CODE = @Ac_TypeDocument_CODE;

  DECLARE @Ln_RowsAffected_NUMB NUMERIC(10);

  SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB;

 END; -- End Of VAPP_UPDATE_S1  


GO
