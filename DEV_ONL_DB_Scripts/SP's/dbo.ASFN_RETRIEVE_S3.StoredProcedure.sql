/****** Object:  StoredProcedure [dbo].[ASFN_RETRIEVE_S3]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ASFN_RETRIEVE_S3] (
 @An_MemberMci_IDNO           NUMERIC(10, 0),
 @Ac_Asset_CODE               CHAR(3),
 @An_AssetSeq_NUMB            NUMERIC(3, 0),
 @Ai_Record_NUMB              INT,
 @Ac_AssetOut_CODE            CHAR(3) OUTPUT,
 @Ac_SourceLoc_CODE           CHAR(3) OUTPUT,
 @An_OthpInsFin_IDNO          NUMERIC(9, 0) OUTPUT,
 @An_OthpAtty_IDNO            NUMERIC(9, 0) OUTPUT,
 @Ac_Status_CODE              CHAR(1) OUTPUT,
 @Ad_Status_DATE              DATE OUTPUT,
 @Ac_AccountAssetNo_TEXT      CHAR(30) OUTPUT,
 @Ac_JointAcct_INDC           CHAR(1) OUTPUT,
 @Ac_NameAcctPrimaryNo_TEXT   CHAR(40) OUTPUT,
 @Ac_NameAcctSecondaryNo_TEXT CHAR(40) OUTPUT,
 @An_ValueAsset_AMNT          NUMERIC(11, 2) OUTPUT,
 @As_DescriptionNote_TEXT     VARCHAR(250) OUTPUT,
 @Ad_AssetValue_DATE          DATE OUTPUT,
 @Ac_LienInitiated_INDC       CHAR(1) OUTPUT,
 @Ac_LocateState_CODE         CHAR(2) OUTPUT,
 @Ad_Settlement_DATE          DATE OUTPUT,
 @An_Settlement_AMNT          NUMERIC(11, 2) OUTPUT,
 @Ad_Potential_DATE           DATE OUTPUT,
 @An_Potential_AMNT           NUMERIC(11, 2) OUTPUT,
 @Ac_WorkerUpdate_ID          CHAR(30) OUTPUT,
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0) OUTPUT,
 @Ad_ClaimLoss_DATE           DATE OUTPUT,
 @An_RowCount_NUMB            NUMERIC(6, 0) OUTPUT
 )
AS
 /*
  *  PROCEDURE NAME    : ASFN_RETRIEVE_S3
  *  DESCRIPTION       : Retrieve Member Financial Settlement details from Member Financial Assets table for Type of Asset, Unique number assigned by the System to the Participants and Unique number generated for Each Asset.    
  *  DEVELOPED BY      : IMP Team
  *  DEVELOPED ON      : 02-JAN-2011
  *  MODIFIED BY       : 
  *  MODIFIED ON       : 
  *  VERSION NO        : 1
 */
 BEGIN
  SELECT @Ac_Status_CODE = NULL,
         @Ac_AccountAssetNo_TEXT = NULL,
         @An_ValueAsset_AMNT = NULL,
         @Ad_AssetValue_DATE = NULL,
         @Ac_JointAcct_INDC = NULL,
         @Ac_NameAcctPrimaryNo_TEXT = NULL,
         @Ac_NameAcctSecondaryNo_TEXT = NULL,
         @Ac_LocateState_CODE = NULL,
         @Ac_LienInitiated_INDC = NULL,
         @Ad_Potential_DATE = NULL,
         @Ad_Settlement_DATE = NULL,
         @Ad_Status_DATE = NULL,
         @An_Potential_AMNT = NULL,
         @An_Settlement_AMNT = NULL,
         @An_RowCount_NUMB = NULL,
         @An_TransactionEventSeq_NUMB = NULL,
         @Ac_AssetOut_CODE = NULL,
         @Ac_SourceLoc_CODE = NULL,
         @As_DescriptionNote_TEXT = NULL,
         @An_OthpAtty_IDNO = NULL,
         @An_OthpInsFin_IDNO = NULL,
         @Ac_WorkerUpdate_ID = NULL,
         @Ad_ClaimLoss_DATE = NULL;

  SELECT @Ac_AssetOut_CODE = X.Asset_CODE,
         @Ac_AccountAssetNo_TEXT = X.AccountAssetNo_TEXT,
         @An_ValueAsset_AMNT = X.ValueAsset_AMNT,
         @Ad_AssetValue_DATE = X.AssetValue_DATE,
         @Ac_JointAcct_INDC = X.JointAcct_INDC,
         @Ac_NameAcctPrimaryNo_TEXT = X.NameAcctPrimaryNo_TEXT,
         @Ac_NameAcctSecondaryNo_TEXT = X.NameAcctSecondaryNo_TEXT,
         @Ac_LocateState_CODE = X.LocateState_CODE,
         @An_Potential_AMNT = X.Potential_AMNT,
         @Ad_Potential_DATE = X.Potential_DATE,
         @An_Settlement_AMNT = X.Settlement_AMNT,
         @Ad_Settlement_DATE = X.Settlement_DATE,
         @Ac_Status_CODE = X.Status_CODE,
         @Ad_Status_DATE = X.Status_DATE,
         @Ac_SourceLoc_CODE = X.SourceLoc_CODE,
         @Ac_LienInitiated_INDC = X.LienInitiated_INDC,
         @As_DescriptionNote_TEXT = X.DescriptionNote_TEXT,
         @An_TransactionEventSeq_NUMB = X.TransactionEventSeq_NUMB,
         @An_OthpInsFin_IDNO = X.OthpInsFin_IDNO,
         @An_OthpAtty_IDNO = X.OthpAtty_IDNO,
         @An_RowCount_NUMB = X.RowCount_NUMB,
         @Ac_WorkerUpdate_ID = X.WorkerUpdate_ID,
         @Ad_ClaimLoss_DATE = X.ClaimLoss_DATE
    FROM (SELECT a.Asset_CODE,
                 a.AccountAssetNo_TEXT,
                 a.ValueAsset_AMNT,
                 a.AssetValue_DATE,
                 a.JointAcct_INDC,
                 a.NameAcctPrimaryNo_TEXT,
                 a.NameAcctSecondaryNo_TEXT,
                 a.LocateState_CODE,
                 a.Potential_AMNT,
                 a.Potential_DATE,
                 a.Settlement_AMNT,
                 a.Settlement_DATE,
                 a.Status_CODE,
                 a.Status_DATE,
                 a.SourceLoc_CODE,
                 a.LienInitiated_INDC,
                 a.DescriptionNote_TEXT,
                 a.TransactionEventSeq_NUMB,
                 a.OthpInsFin_IDNO,
                 a.OthpAtty_IDNO,
                 ROW_NUMBER() OVER( ORDER BY a.EndValidity_DATE DESC, a.Update_DTTM DESC) AS RecRank_NUMB,
                 COUNT(1) OVER() AS RowCount_NUMB,
                 a.WorkerUpdate_ID,
                 a.ClaimLoss_DATE
            FROM ASFN_Y1 a
           WHERE a.MemberMci_IDNO = @An_MemberMci_IDNO
             AND a.Asset_CODE = ISNULL(@Ac_Asset_CODE,a.Asset_CODE)
             AND a.AssetSeq_NUMB = ISNULL(@An_AssetSeq_NUMB,a.AssetSeq_NUMB)) AS X
   WHERE X.RecRank_NUMB = @Ai_Record_NUMB;
 END; --END OF  ASFN_RETRIEVE_S3

GO
