/****** Object:  StoredProcedure [dbo].[ASFN_UPDATE_S1]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ASFN_UPDATE_S1] (
 @An_MemberMci_IDNO              NUMERIC(10, 0),
 @Ac_Asset_CODE                  CHAR(3),
 @An_AssetSeq_NUMB               NUMERIC(3, 0),
 @Ac_SourceLoc_CODE              CHAR(3),
 @An_OthpInsFin_IDNO             NUMERIC(9, 0),
 @An_OthpAtty_IDNO               NUMERIC(9, 0),
 @Ac_Status_CODE                 CHAR(1),
 @Ad_Status_DATE                 DATE,
 @Ac_AccountAssetNo_TEXT         CHAR(30),
 @Ac_AcctType_CODE               CHAR(3),
 @Ac_JointAcct_INDC              CHAR(1),
 @Ac_NameAcctPrimaryNo_TEXT      CHAR(40),
 @Ac_NameAcctSecondaryNo_TEXT    CHAR(40),
 @An_ValueAsset_AMNT             NUMERIC(11, 2),
 @As_DescriptionNote_TEXT        VARCHAR(250),
 @Ad_AssetValue_DATE             DATE,
 @Ac_LienInitiated_INDC          CHAR(1),
 @Ac_LocateState_CODE            CHAR(2),
 @Ad_Settlement_DATE             DATE,
 @An_Settlement_AMNT             NUMERIC(11, 2),
 @Ad_Potential_DATE              DATE,
 @An_Potential_AMNT              NUMERIC(11, 2),
 @Ac_SignedOnWorker_ID           CHAR(30),
 @An_TransactionEventSeqOld_NUMB NUMERIC(19, 0),
 @An_TransactionEventSeq_NUMB    NUMERIC(19, 0),
 @Ad_ClaimLoss_DATE              DATE
 )
AS
 /*
  *     PROCEDURE NAME    : ASFN_UPDATE_S1
  *     DESCRIPTION       : UPDATE End validity_DATE to current_DATE for that Membermci_IDNO, transactioneventseq_numb.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 20-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ld_Systemdatetime_DTTM DATETIME2 = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
          @Ld_High_DATE           DATE = '12/31/9999',
          @Ln_RowsAffected_NUMB   NUMERIC(10);

  UPDATE ASFN_Y1
     SET EndValidity_DATE = @Ld_Systemdatetime_DTTM
  OUTPUT @An_MemberMci_IDNO AS MemberMci_IDNO,
         @Ac_Asset_CODE AS Asset_CODE,
         @An_AssetSeq_NUMB AS AssetSeq_NUMB,
         @Ac_SourceLoc_CODE AS SourceLoc_CODE,
         @An_OthpInsFin_IDNO AS OthpInsFin_IDNO,
         @An_OthpAtty_IDNO AS OthpAtty_IDNO,
         @Ac_Status_CODE AS Status_CODE,
         @Ad_Status_DATE AS Status_DATE,
         @Ac_AccountAssetNo_TEXT AS AccountAssetNo_TEXT,
         @Ac_AcctType_CODE AS AcctType_CODE,
         @Ac_JointAcct_INDC AS JointAcct_INDC,
         @Ac_NameAcctPrimaryNo_TEXT AS NameAcctPrimaryNo_TEXT,
         @Ac_NameAcctSecondaryNo_TEXT AS NameAcctSecondaryNo_TEXT,
         @An_ValueAsset_AMNT AS ValueAsset_AMNT,
         @As_DescriptionNote_TEXT AS DescriptionNote_TEXT,
         @Ad_AssetValue_DATE AS AssetValue_DATE,
         @Ac_LienInitiated_INDC AS LienInitiated_INDC,
         @Ac_LocateState_CODE AS LocateState_CODE,
         @Ad_Settlement_DATE AS Settlement_DATE,
         @An_Settlement_AMNT AS Settlement_AMNT,
         @Ad_Potential_DATE AS Potential_DATE,
         @An_Potential_AMNT AS Potential_AMNT,
         @Ld_Systemdatetime_DTTM AS BeginValidity_DATE,
         @Ld_High_DATE AS EndValidity_DATE,
         @Ac_SignedOnWorker_ID AS WorkerUpdate_ID,
         @Ld_Systemdatetime_DTTM AS Update_DTTM,
         @An_TransactionEventSeq_NUMB AS TransactionEventSeq_NUMB,
         @Ad_ClaimLoss_DATE AS ClaimLoss_DATE
  INTO ASFN_Y1
   WHERE MemberMci_IDNO = @An_MemberMci_IDNO
     AND TransactionEventSeq_NUMB = @An_TransactionEventSeqOld_NUMB
     AND EndValidity_DATE = @Ld_High_DATE;

  SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;

  SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB;
 END; --END OF ASFN_UPDATE_S1

GO
