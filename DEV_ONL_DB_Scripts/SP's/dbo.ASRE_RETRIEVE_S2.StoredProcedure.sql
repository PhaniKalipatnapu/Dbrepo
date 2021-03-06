/****** Object:  StoredProcedure [dbo].[ASRE_RETRIEVE_S2]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ASRE_RETRIEVE_S2] (
 @An_MemberMci_IDNO           NUMERIC(10, 0),
 @Ac_Asset_CODE               CHAR(3),
 @An_AssetSeq_NUMB            NUMERIC(3, 0),
 @Ai_Record_NUMB              INT,
 @Ac_AssetOut_CODE            CHAR(3) OUTPUT,
 @Ac_SourceLoc_CODE           CHAR(3) OUTPUT,
 @Ac_AssetLotNo_TEXT          CHAR(5) OUTPUT,
 @Ac_AssetBookNo_TEXT         CHAR(5) OUTPUT,
 @Ac_AssetPageNo_TEXT         CHAR(5) OUTPUT,
 @As_Line1Asset_ADDR          VARCHAR(50) OUTPUT,
 @As_Line2Asset_ADDR          VARCHAR(50) OUTPUT,
 @Ac_CityAsset_ADDR           CHAR(28) OUTPUT,
 @Ac_StateAsset_ADDR          CHAR(2) OUTPUT,
 @Ac_CountryAsset_ADDR        CHAR(2) OUTPUT,
 @Ac_ZipAsset_ADDR            CHAR(15) OUTPUT,
 @Ad_Purchase_DATE            DATE OUTPUT,
 @An_ValueAsset_AMNT          NUMERIC(11, 2) OUTPUT,
 @An_OthpLien_IDNO            NUMERIC(9, 0) OUTPUT,
 @Ac_LienInitiated_INDC       CHAR(1) OUTPUT,
 @An_Mortgage_AMNT            NUMERIC(11, 2) OUTPUT,
 @An_MortgageBalance_AMNT     NUMERIC(11, 2) OUTPUT,
 @Ad_Balance_DATE             DATE OUTPUT,
 @Ad_Sold_DATE                DATE OUTPUT,
 @Ac_Status_CODE              CHAR(1) OUTPUT,
 @Ad_Status_DATE              DATE OUTPUT,
 @Ac_CntyFipsAssess_CODE      CHAR(3) OUTPUT,
 @Ac_StateAssess_CODE         CHAR(2) OUTPUT,
 @Ac_Mortgage_INDC            CHAR(1) OUTPUT,
 @Ac_WorkerUpdate_ID          CHAR(30) OUTPUT,
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0) OUTPUT,
 @An_RowCount_NUMB            NUMERIC(6, 0) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : ASRE_RETRIEVE_S2
  *     DESCRIPTION       : Retrieve Real Property details from Realty Assets table for Unique number assigned by the System to the Participants, Type of Asset and Unique number generated for Each Asset and Lien Holders ID is NULL (or) Lien Holders ID is NOT null and Lien Holders ID equal to Unique System Assigned number for the Other Party in Other Party table and Other Party Type in Other Party table equal to FINANCIAL INSTITUTION (H). 
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-MAR-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SELECT @Ac_Status_CODE = NULL,
         @Ac_LienInitiated_INDC = NULL,
         @Ac_Mortgage_INDC = NULL,
         @Ad_Balance_DATE = NULL,
         @Ad_Purchase_DATE = NULL,
         @Ad_Sold_DATE = NULL,
         @Ad_Status_DATE = NULL,
         @An_Mortgage_AMNT = NULL,
         @An_MortgageBalance_AMNT = NULL,
         @An_ValueAsset_AMNT = NULL,
         @An_RowCount_NUMB = NULL,
         @An_TransactionEventSeq_NUMB = NULL,
         @Ac_CityAsset_ADDR = NULL,
         @Ac_CountryAsset_ADDR = NULL,
         @As_Line1Asset_ADDR = NULL,
         @As_Line2Asset_ADDR = NULL,
         @Ac_StateAsset_ADDR = NULL,
         @Ac_ZipAsset_ADDR = NULL,
         @Ac_AssetBookNo_TEXT = NULL,
         @Ac_AssetLotNo_TEXT = NULL,
         @Ac_AssetPageNo_TEXT = NULL,
         @Ac_CntyFipsAssess_CODE = NULL,
         @Ac_AssetOut_CODE = NULL,
         @Ac_SourceLoc_CODE = NULL,
         @Ac_StateAssess_CODE = NULL,
         @An_OthpLien_IDNO = NULL,
         @Ac_WorkerUpdate_ID = NULL;

  DECLARE @Ld_High_DATE      DATE = '12/31/9999',
          @Lc_TypeOthpH_CODE CHAR(1) = 'H',
          @Li_Zero_NUMB      SMALLINT = 0;

  SELECT @Ac_AssetOut_CODE = X.Asset_CODE,
         @Ac_AssetLotNo_TEXT = X.AssetLotNo_TEXT,
         @Ac_AssetBookNo_TEXT = X.AssetBookNo_TEXT,
         @Ac_AssetPageNo_TEXT = X.AssetPageNo_TEXT,
         @An_ValueAsset_AMNT = X.ValueAsset_AMNT,
         @Ac_StateAssess_CODE = X.StateAssess_CODE,
         @Ac_CntyFipsAssess_CODE = X.CntyFipsAssess_CODE,
         @Ad_Purchase_DATE = X.Purchase_DATE,
         @Ad_Sold_DATE = X.Sold_DATE,
         @Ac_LienInitiated_INDC = X.LienInitiated_INDC,
         @Ac_Status_CODE = X.Status_CODE,
         @Ad_Status_DATE = X.Status_DATE,
         @Ac_SourceLoc_CODE = X.SourceLoc_CODE,
         @As_Line1Asset_ADDR = X.Line1Asset_ADDR,
         @As_Line2Asset_ADDR = X.Line2Asset_ADDR,
         @Ac_CityAsset_ADDR = X.CityAsset_ADDR,
         @Ac_StateAsset_ADDR = X.StateAsset_ADDR,
         @Ac_ZipAsset_ADDR = X.ZipAsset_ADDR,
         @Ac_CountryAsset_ADDR = X.CountryAsset_ADDR,
         @Ac_Mortgage_INDC = X.Mortgage_INDC,
         @An_Mortgage_AMNT = X.Mortgage_AMNT,
         @An_MortgageBalance_AMNT = X.MortgageBalance_AMNT,
         @Ad_Balance_DATE = X.Balance_DATE,
         @An_TransactionEventSeq_NUMB = X.TransactionEventSeq_NUMB,
         @An_OthpLien_IDNO = X.OthpLien_IDNO,
         @An_RowCount_NUMB = X.RowCount_NUMB,
         @Ac_WorkerUpdate_ID = X.WorkerUpdate_ID
    FROM (SELECT a.Asset_CODE,
                 a.AssetLotNo_TEXT,
                 a.AssetBookNo_TEXT,
                 a.AssetPageNo_TEXT,
                 a.ValueAsset_AMNT,
                 a.StateAssess_CODE,
                 a.CntyFipsAssess_CODE,
                 a.Purchase_DATE,
                 a.Sold_DATE,
                 a.LienInitiated_INDC,
                 a.Status_CODE,
                 a.Status_DATE,
                 a.SourceLoc_CODE,
                 a.Line1Asset_ADDR,
                 a.Line2Asset_ADDR,
                 a.CityAsset_ADDR,
                 a.StateAsset_ADDR,
                 a.ZipAsset_ADDR,
                 a.CountryAsset_ADDR,
                 a.Mortgage_INDC,
                 a.Mortgage_AMNT,
                 a.MortgageBalance_AMNT,
                 a.Balance_DATE,
                 a.TransactionEventSeq_NUMB,
                 a.OthpLien_IDNO,
                 ROW_NUMBER() OVER( ORDER BY a.EndValidity_DATE DESC, a.Update_DTTM DESC) AS RecRank_NUMB,
                 COUNT(1) OVER() AS RowCount_NUMB,
                 a.WorkerUpdate_ID
            FROM ASRE_Y1 a
           WHERE a.MemberMci_IDNO = @An_MemberMci_IDNO
             AND a.Asset_CODE = ISNULL(@Ac_Asset_CODE,a.Asset_CODE)
             AND a.AssetSeq_NUMB = ISNULL(@An_AssetSeq_NUMB,a.AssetSeq_NUMB)
             AND EXISTS (SELECT 1
                           FROM OTHP_Y1 O
                          WHERE (a.OthpLien_IDNO = @Li_Zero_NUMB
                                  OR (a.OthpLien_IDNO ! = @Li_Zero_NUMB
                                      AND a.OthpLien_IDNO = O.OtherParty_IDNO))
                            AND O.TypeOthp_CODE = @Lc_TypeOthpH_CODE
                            AND O.EndValidity_DATE = @Ld_High_DATE)) AS X
   WHERE X.RecRank_NUMB = @Ai_Record_NUMB;
 END; --END OF ASRE_RETRIEVE_S2

GO
