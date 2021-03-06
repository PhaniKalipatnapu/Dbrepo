/****** Object:  StoredProcedure [dbo].[ASFN_INSERT_S2]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ASFN_INSERT_S2](
          @An_MemberMci_IDNO            NUMERIC(10, 0),
          @Ac_Asset_CODE                CHAR(3),
          @An_AssetSeq_NUMB             NUMERIC(3, 0),
          @Ac_SourceLoc_CODE            CHAR(3),
          @An_OthpInsFin_IDNO           NUMERIC(9, 0),
          @An_OthpAtty_IDNO             NUMERIC(9, 0),
          @Ac_Status_CODE               CHAR(1),
          @Ad_Status_DATE               DATE,
          @Ac_AccountAssetNo_TEXT       CHAR(30),
          @Ac_AcctType_CODE             CHAR(3),
          @Ac_JointAcct_INDC            CHAR(1),
          @Ac_NameAcctPrimaryNo_TEXT    CHAR(40),
          @Ac_NameAcctSecondaryNo_TEXT  CHAR(40),
          @An_ValueAsset_AMNT           NUMERIC(11, 2),
          @As_DescriptionNote_TEXT      VARCHAR(250),
          @Ad_AssetValue_DATE           DATE,
          @Ac_LienInitiated_INDC        CHAR(1),
          @Ac_LocateState_CODE          CHAR(2),
          @Ad_Settlement_DATE           DATE,
          @An_Settlement_AMNT           NUMERIC(11, 2),
          @Ad_Potential_DATE            DATE,
          @An_Potential_AMNT            NUMERIC(11, 2),
          @Ac_SignedOnWorker_ID         CHAR(30),
          @An_TransactionEventSeq_NUMB  NUMERIC(19, 0),
          @Ad_ClaimLoss_DATE            DATE 
   )
AS
 /*
  *     PROCEDURE NAME    : ASFN_INSERT_S2
  *     DESCRIPTION       : Insert Member Financial Asset details with new Sequence Event Transaction and retrieved Unique number generated for Each Asset into Member Financial Assets table for Unique number assigned by the System to the Participants.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 20-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
 
 DECLARE 
 		@Ld_Systemdatetime_DTTM	  DATETIME2 = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
 		@Ld_High_DATE			  DATE	    = '12/31/9999';
 		
  INSERT ASFN_Y1
         (MemberMci_IDNO,
          Asset_CODE,
          AssetSeq_NUMB,
          SourceLoc_CODE,
          OthpInsFin_IDNO,
          OthpAtty_IDNO,
          Status_CODE,
          Status_DATE,
          AccountAssetNo_TEXT,
          AcctType_CODE,
          JointAcct_INDC,
          NameAcctPrimaryNo_TEXT,
          NameAcctSecondaryNo_TEXT,
          ValueAsset_AMNT,
          DescriptionNote_TEXT,
          AssetValue_DATE,
          LienInitiated_INDC,
          LocateState_CODE,
          Settlement_DATE,
          Settlement_AMNT,
          Potential_DATE,
          Potential_AMNT,
          BeginValidity_DATE,
          EndValidity_DATE,
          WorkerUpdate_ID,
          Update_DTTM,
          TransactionEventSeq_NUMB,
          ClaimLoss_DATE)
   VALUES ( @An_MemberMci_IDNO,
           @Ac_Asset_CODE,
           @An_AssetSeq_NUMB,
           @Ac_SourceLoc_CODE,
           @An_OthpInsFin_IDNO,
           @An_OthpAtty_IDNO,
           @Ac_Status_CODE,
           @Ad_Status_DATE,
           @Ac_AccountAssetNo_TEXT,
           @Ac_AcctType_CODE,
           @Ac_JointAcct_INDC,
           @Ac_NameAcctPrimaryNo_TEXT,
           @Ac_NameAcctSecondaryNo_TEXT,
           @An_ValueAsset_AMNT,
           @As_DescriptionNote_TEXT,
           @Ad_AssetValue_DATE,
           @Ac_LienInitiated_INDC,
           @Ac_LocateState_CODE,
           @Ad_Settlement_DATE,
           @An_Settlement_AMNT,
           @Ad_Potential_DATE,
           @An_Potential_AMNT,
           @Ld_Systemdatetime_DTTM,
           @Ld_High_DATE,
           @Ac_SignedOnWorker_ID,
           @Ld_Systemdatetime_DTTM,
           @An_TransactionEventSeq_NUMB,
           @Ad_ClaimLoss_DATE);
           
 END; -- End Of ASFN_INSERT_S2


GO
