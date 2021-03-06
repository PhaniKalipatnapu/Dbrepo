/****** Object:  StoredProcedure [dbo].[VAPP_UPDATE_S2]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[VAPP_UPDATE_S2](
 @Ac_ChildBirthCertificate_ID		CHAR(7),
 @Ac_TypeDocument_CODE				CHAR(3),
 @An_MotherMemberMci_IDNO           NUMERIC(10, 0),
 @Ac_MotherLast_NAME				CHAR(20),
 @Ac_MotherFirst_NAME				CHAR(16),
 @Ad_MotherBirth_DATE				DATE,
 @An_MotherMemberSsn_NUMB			NUMERIC(9, 0),
 @Ac_MotherAddrExist_INDC			CHAR(1),
 @Ac_SignedOnWorker_ID				CHAR(30),
 @An_TransactionEventSeq_NUMB		NUMERIC(19)
 )
AS
 /*    
 *      PROCEDURE NAME    : VAPP_UPDATE_S2    
  *     DESCRIPTION       : Update mother information for the given birth certificate and document type.
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
    SET MotherMemberMci_IDNO = @An_MotherMemberMci_IDNO,
         MotherLast_NAME = @Ac_MotherLast_NAME,
         MotherFirst_NAME = @Ac_MotherFirst_NAME,
         MotherBirth_DATE = @Ad_MotherBirth_DATE,
         MotherMemberSsn_NUMB = @An_MotherMemberSsn_NUMB,
         MotherAddrExist_INDC = @Ac_MotherAddrExist_INDC,     
		 BeginValidity_DATE = @Ld_Current_DATE,  
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

 END; -- End Of VAPP_UPDATE_S2  


GO
