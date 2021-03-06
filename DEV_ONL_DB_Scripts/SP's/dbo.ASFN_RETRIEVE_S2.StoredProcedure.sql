/****** Object:  StoredProcedure [dbo].[ASFN_RETRIEVE_S2]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ASFN_RETRIEVE_S2] (
 @An_MemberMci_IDNO           NUMERIC(10, 0),
 @Ac_Asset_CODE               CHAR(3),
 @An_AssetSeq_NUMB            NUMERIC(3, 0),
 @Ai_Record_NUMB              INT,
 @Ac_SourceLoc_CODE           CHAR(3) OUTPUT,
 @Ac_AssetOut_CODE            CHAR(3) OUTPUT,
 @An_OthpInsFin_IDNO          NUMERIC(9, 0) OUTPUT,
 @An_OthpAtty_IDNO            NUMERIC(9, 0) OUTPUT,
 @Ac_Status_CODE              CHAR(1) OUTPUT,
 @Ad_Status_DATE              DATE OUTPUT,
 @Ac_AccountAssetNo_TEXT      CHAR(30) OUTPUT,
 @Ac_AcctType_CODE            CHAR(3) OUTPUT,
 @Ac_LienInitiated_INDC       CHAR(1) OUTPUT,
 @Ad_Settlement_DATE          DATE OUTPUT,
 @An_Settlement_AMNT          NUMERIC(11, 2) OUTPUT,
 @Ac_WorkerUpdate_ID          CHAR(30) OUTPUT,
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0) OUTPUT,
 @Ad_ClaimLoss_DATE           DATE OUTPUT,
 @An_RowCount_NUMB            NUMERIC(6, 0) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : ASFN_RETRIEVE_S2
  *     DESCRIPTION       : Retrieve Member Financial Asset details from Member Financial Assets table for Type of Asset, Unique number assigned by the System to the Participants and Unique number generated for Each Asset and Other Party Id of the Financial Institution or Insurance Company is NULL (or) Other Party Id of the Financial Institution or Insurance Company is NOT null and Other Party Id of the Financial Institution or Insurance Company equal to Unique System Assigned number for the Other Party in Other Party table and Other Party Type in Other Party table equal to INSURERS (I). 
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-JAN-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SELECT @Ac_Status_CODE = NULL,
         @Ac_LienInitiated_INDC = NULL,
         @Ad_Settlement_DATE = NULL,
         @Ad_Status_DATE = NULL,
         @An_Settlement_AMNT = NULL,
         @An_RowCount_NUMB = NULL,
         @An_TransactionEventSeq_NUMB = NULL,
         @Ac_AcctType_CODE = NULL,
         @Ac_AssetOut_CODE = NULL,
         @Ac_SourceLoc_CODE = NULL,
         @An_OthpAtty_IDNO = NULL,
         @An_OthpInsFin_IDNO = NULL,
         @Ac_WorkerUpdate_ID = NULL,
         @Ac_AccountAssetNo_TEXT = NULL,
         @Ad_ClaimLoss_DATE = NULL;

  DECLARE @Lc_TypeOthpI_CODE CHAR(1) = 'I',
          @Li_Zero_NUMB      SMALLINT = 0;

  SELECT @Ac_AssetOut_CODE = X.Asset_CODE,
         @Ac_AcctType_CODE = X.AcctType_CODE,
         @Ac_AccountAssetNo_TEXT = X.AccountAssetNo_TEXT,
         @An_Settlement_AMNT = X.Settlement_AMNT,
         @Ad_Settlement_DATE = X.Settlement_DATE,
         @Ac_Status_CODE = X.Status_CODE,
         @Ad_Status_DATE = X.Status_DATE,
         @Ac_SourceLoc_CODE = X.SourceLoc_CODE,
         @Ac_LienInitiated_INDC = X.LienInitiated_INDC,
         @An_TransactionEventSeq_NUMB = X.TransactionEventSeq_NUMB,
         @An_OthpInsFin_IDNO = X.OthpInsFin_IDNO,
         @An_OthpAtty_IDNO = X.OthpAtty_IDNO,
         @An_RowCount_NUMB = X.RowCount_NUMB,
         @Ac_WorkerUpdate_ID = X.WorkerUpdate_ID,
         @Ad_ClaimLoss_DATE = X.ClaimLoss_DATE
    FROM (SELECT a.Asset_CODE,
                 a.AcctType_CODE,
                 a.AccountAssetNo_TEXT,
                 a.Settlement_AMNT,
                 a.Settlement_DATE,
                 a.Status_CODE,
                 a.Status_DATE,
                 a.SourceLoc_CODE,
                 a.LienInitiated_INDC,
                 a.TransactionEventSeq_NUMB,
                 a.OthpInsFin_IDNO,
                 a.OthpAtty_IDNO,
                 ROW_NUMBER() OVER( ORDER BY a.EndValidity_DATE DESC, a.Update_DTTM DESC) AS RecRank_NUMB,
                 COUNT(1) OVER() AS RowCount_NUMB,
                 a.WorkerUpdate_ID,
                 a.ClaimLoss_DATE
            FROM ASFN_Y1 a
           WHERE a.MemberMci_IDNO = @An_MemberMci_IDNO
             AND (@Ac_Asset_CODE IS NULL
                   OR (@Ac_Asset_CODE IS NOT NULL
                       AND a.Asset_CODE = @Ac_Asset_CODE))
             AND (@An_AssetSeq_NUMB IS NULL
                   OR (@An_AssetSeq_NUMB IS NOT NULL
                       AND a.AssetSeq_NUMB = @An_AssetSeq_NUMB))
             AND EXISTS (SELECT 1
                           FROM OTHP_Y1 O
                          WHERE (a.OthpInsFin_IDNO = @Li_Zero_NUMB
                                  OR (a.OthpInsFin_IDNO != @Li_Zero_NUMB
                                      AND a.OthpInsFin_IDNO = O.OtherParty_IDNO))
                            AND O.TypeOthp_CODE = @Lc_TypeOthpI_CODE)) X
   WHERE X.RecRank_NUMB = @Ai_Record_NUMB;
 END; --END OF ASFN_RETRIEVE_S2

GO
