/****** Object:  StoredProcedure [dbo].[MPAT_UPDATE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[MPAT_UPDATE_S1] (
 @An_MemberMci_IDNO                  NUMERIC(10, 0),
 @Ac_BirthCertificate_ID             CHAR(20),
 @Ac_BornOfMarriage_CODE             CHAR(1),
 @Ad_Conception_DATE                 DATE,
 @Ac_ConceptionCity_NAME             CHAR(28),
 @An_ConceptionCounty_IDNO           NUMERIC(3, 0),
 @Ac_ConceptionState_CODE            CHAR(2),
 @Ac_ConceptionCountry_CODE          CHAR(2),
 @Ac_EstablishedMother_CODE          CHAR(1),
 @An_EstablishedMotherMci_IDNO       NUMERIC(10, 0),
 @Ac_EstablishedMotherLast_NAME      CHAR(20),
 @Ac_EstablishedMotherFirst_NAME     CHAR(16),
 @Ac_EstablishedMotherMiddle_NAME    CHAR(20),
 @Ac_EstablishedMotherSuffix_NAME    CHAR(4),
 @Ac_EstablishedFather_CODE          CHAR(1),
 @An_EstablishedFatherMci_IDNO       NUMERIC(10, 0),
 @Ac_EstablishedFatherLast_NAME      CHAR(20),
 @Ac_EstablishedFatherFirst_NAME     CHAR(16),
 @Ac_EstablishedFatherMiddle_NAME    CHAR(20),
 @Ac_EstablishedFatherSuffix_NAME    CHAR(4),
 @Ac_DisEstablishedFather_CODE       CHAR(1),
 @An_DisEstablishedFatherMci_IDNO    NUMERIC(10, 0),
 @Ac_DisEstablishedFatherLast_NAME   CHAR(20),
 @Ac_DisEstablishedFatherFirst_NAME  CHAR(16),
 @Ac_DisEstablishedFatherMiddle_NAME CHAR(20),
 @Ac_DisEstablishedFatherSuffix_NAME CHAR(4),
 @Ac_PaternityEst_INDC               CHAR(1),
 @Ac_StatusEstablish_CODE            CHAR(1),
 @Ac_StateEstablish_CODE             CHAR(2),
 @Ac_FileEstablish_ID                CHAR(10),
 @Ac_PaternityEst_CODE               CHAR(2),
 @Ad_PaternityEst_DATE               DATE,
 @Ac_StateDisestablish_CODE          CHAR(2),
 @Ac_FileDisestablish_ID             CHAR(10),
 @Ac_MethodDisestablish_CODE         CHAR(3),
 @Ad_Disestablish_DATE               DATE,
 @As_DescriptionProfile_TEXT         VARCHAR(200),
 @Ac_QiStatus_CODE                   CHAR(1),
 @Ac_VapImage_CODE                   CHAR(1),
 @Ac_SignedOnWorker_ID               CHAR(30),
 @An_TransactionEventSeq_NUMB        NUMERIC(19, 0),
 @An_TransactionEventSeqOld_NUMB	 NUMERIC(19, 0)
 )
AS
 /*  
  *     PROCEDURE NAME    : MPAT_UPDATE_S1 
  *     DESCRIPTION       : Update Member Demographics table with Member Demographics Paternity details and new Sequence Event Transaction for Unique number assigned by the system to the participant.  
  *     DEVELOPED BY      : IMP Team  
  *     DEVELOPED ON      : 02-AUG-2011  
  *     MODIFIED BY       :   
  *     MODIFIED ON       :   
  *     VERSION NO        : 1  
  */
 BEGIN
  DECLARE @Ln_RowsAffected_NUMB   NUMERIC(10),
          @Ld_Current_DTTM       DATETIME2(0) = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
          @Ld_Lowdate_DATE        DATE = '01/01/0001',
          @Lc_No_INDC             CHAR(1) = 'N';

  UPDATE MPAT_Y1
     SET BirthCertificate_ID = @Ac_BirthCertificate_ID,
         BornOfMarriage_CODE = @Ac_BornOfMarriage_CODE,
         Conception_DATE = ISNULL(@Ad_Conception_DATE, @Ld_Lowdate_DATE),
         ConceptionCity_NAME = @Ac_ConceptionCity_NAME,
         ConceptionCounty_IDNO = @An_ConceptionCounty_IDNO,
         ConceptionState_CODE = @Ac_ConceptionState_CODE,
         ConceptionCountry_CODE = @Ac_ConceptionCountry_CODE,
         EstablishedMother_CODE = @Ac_EstablishedMother_CODE,
         EstablishedMotherMci_IDNO = @An_EstablishedMotherMci_IDNO,
         EstablishedMotherLast_NAME = @Ac_EstablishedMotherLast_NAME,
         EstablishedMotherFirst_NAME = @Ac_EstablishedMotherFirst_NAME,
         EstablishedMotherMiddle_NAME = @Ac_EstablishedMotherMiddle_NAME,
         EstablishedMotherSuffix_NAME = @Ac_EstablishedMotherSuffix_NAME,
         EstablishedFather_CODE = @Ac_EstablishedFather_CODE,
         EstablishedFatherMci_IDNO = @An_EstablishedFatherMci_IDNO,
         EstablishedFatherLast_NAME = @Ac_EstablishedFatherLast_NAME,
         EstablishedFatherFirst_NAME = @Ac_EstablishedFatherFirst_NAME,
         EstablishedFatherMiddle_NAME = @Ac_EstablishedFatherMiddle_NAME,
         EstablishedFatherSuffix_NAME = @Ac_EstablishedFatherSuffix_NAME,
         DisEstablishedFather_CODE = @Ac_DisEstablishedFather_CODE,
         DisEstablishedFatherMci_IDNO = @An_DisEstablishedFatherMci_IDNO,
         DisEstablishedFatherLast_NAME = @Ac_DisEstablishedFatherLast_NAME,
         DisEstablishedFatherFirst_NAME = @Ac_DisEstablishedFatherFirst_NAME,
         DisEstablishedFatherMiddle_NAME = @Ac_DisEstablishedFatherMiddle_NAME,
         DisEstablishedFatherSuffix_NAME = @Ac_DisEstablishedFatherSuffix_NAME,
         PaternityEst_INDC = @Ac_PaternityEst_INDC,
         StatusEstablish_CODE = @Ac_StatusEstablish_CODE,
         StateEstablish_CODE = @Ac_StateEstablish_CODE,
         FileEstablish_ID = @Ac_FileEstablish_ID,
         PaternityEst_CODE = @Ac_PaternityEst_CODE,
         PaternityEst_DATE = ISNULL(@Ad_PaternityEst_DATE, @Ld_Lowdate_DATE),
         StateDisestablish_CODE = @Ac_StateDisestablish_CODE,
         FileDisestablish_ID = @Ac_FileDisestablish_ID,
         MethodDisestablish_CODE = @Ac_MethodDisestablish_CODE,
         Disestablish_DATE = ISNULL(@Ad_Disestablish_DATE, @Ld_Lowdate_DATE),
         DescriptionProfile_TEXT = @As_DescriptionProfile_TEXT,
         QiStatus_CODE = ISNULL(@Ac_QiStatus_CODE, @Lc_No_INDC),
         VapImage_CODE = @Ac_VapImage_CODE,
         WorkerUpdate_ID = @Ac_SignedOnWorker_ID,
         BeginValidity_DATE =  @Ld_Current_DTTM ,
         Update_DTTM =  @Ld_Current_DTTM ,
         TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB
  OUTPUT DELETED.MemberMci_IDNO,
         DELETED.BirthCertificate_ID,
         DELETED.BornOfMarriage_CODE,
         DELETED.Conception_DATE,
         DELETED.ConceptionCity_NAME,
         DELETED.ConceptionCounty_IDNO,
         DELETED.ConceptionState_CODE,
         DELETED.ConceptionCountry_CODE,
         DELETED.EstablishedMother_CODE,
         DELETED.EstablishedMotherMci_IDNO,
         DELETED.EstablishedMotherLast_NAME,
         DELETED.EstablishedMotherFirst_NAME,
         DELETED.EstablishedMotherMiddle_NAME,
         DELETED.EstablishedMotherSuffix_NAME,
         DELETED.EstablishedFather_CODE,
         DELETED.EstablishedFatherMci_IDNO,
         DELETED.EstablishedFatherLast_NAME,
         DELETED.EstablishedFatherFirst_NAME,
         DELETED.EstablishedFatherMiddle_NAME,
         DELETED.EstablishedFatherSuffix_NAME,
         DELETED.DisEstablishedFather_CODE,
         DELETED.DisEstablishedFatherMci_IDNO,
         DELETED.DisEstablishedFatherLast_NAME,
         DELETED.DisEstablishedFatherFirst_NAME,
         DELETED.DisEstablishedFatherMiddle_NAME,
         DELETED.DisEstablishedFatherSuffix_NAME,
         DELETED.PaternityEst_INDC,
         DELETED.StatusEstablish_CODE,
         DELETED.StateEstablish_CODE,
         DELETED.FileEstablish_ID,
         DELETED.PaternityEst_CODE,
         DELETED.PaternityEst_DATE,
         DELETED.StateDisestablish_CODE,
         DELETED.FileDisestablish_ID,
         DELETED.MethodDisestablish_CODE,
         DELETED.Disestablish_DATE,
         DELETED.DescriptionProfile_TEXT,
         DELETED.QiStatus_CODE,
         DELETED.VapImage_CODE,
         DELETED.WorkerUpdate_ID,
         DELETED.BeginValidity_DATE,
         @Ld_Current_DTTM  AS EndValidity_DATE,
         DELETED.Update_DTTM,
         DELETED.TransactionEventSeq_NUMB 
    INTO HMPAT_Y1            
   WHERE MemberMci_IDNO = @An_MemberMci_IDNO
     AND TransactionEventSeq_NUMB = @An_TransactionEventSeqOld_NUMB;

  SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;

  SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB;
 END; --END of  MPAT_UPDATE_S1                                                       

GO
