/****** Object:  StoredProcedure [dbo].[ASRV_RETRIEVE_S3]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ASRV_RETRIEVE_S3] (
 @An_MemberMci_IDNO            NUMERIC(10, 0),
 @An_AssetSeq_NUMB             NUMERIC(3, 0),
 @Ac_Asset_CODE                CHAR(3),
 @Ai_Record_NUMB               INT,
 @Ac_SourceLoc_CODE            CHAR(3) OUTPUT,
 @An_TransactionEventSeq_NUMB  NUMERIC(19, 0) OUTPUT,
 @Ac_TitleNo_TEXT              CHAR(15) OUTPUT,
 @Ac_DescriptionVin_TEXT       CHAR(20) OUTPUT,
 @Ac_DescriptionAutoMake_TEXT  CHAR(15) OUTPUT,
 @Ac_DescriptionAutoModel_TEXT CHAR(15) OUTPUT,
 @Ac_DescriptionAutoYear_TEXT  CHAR(4) OUTPUT,
 @Ac_DescriptionAutoNoLic_TEXT CHAR(10) OUTPUT,
 @Ac_StateVehicle_CODE         CHAR(2) OUTPUT,
 @Ad_Issued_DATE               DATE OUTPUT,
 @Ad_Expired_DATE              DATE OUTPUT,
 @An_ValueAsset_AMNT           NUMERIC(11, 2) OUTPUT,
 @An_OthpLien_IDNO             NUMERIC(9, 0) OUTPUT,
 @Ac_StateAssess_CODE          CHAR(2) OUTPUT,
 @Ac_CntyFipsAssess_CODE       CHAR(3) OUTPUT,
 @An_ValueAssessed_AMNT        NUMERIC(11, 2) OUTPUT,
 @Ac_AccountLienNo_TEXT        CHAR(15) OUTPUT,
 @An_Lien_AMNT                 NUMERIC(11, 2) OUTPUT,
 @Ac_LienInitiated_INDC        CHAR(1) OUTPUT,
 @Ac_Status_CODE               CHAR(1) OUTPUT,
 @Ad_Status_DATE               DATE OUTPUT,
 @Ac_AssetOut_CODE             CHAR(3) OUTPUT,
 @Ac_WorkerUpdate_ID           CHAR(30) OUTPUT,
 @An_RowCount_NUMB             NUMERIC(6, 0) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : ASRV_RETRIEVE_S3
  *     DESCRIPTION       : Retrieve Registered Vehicle Asset details from Registered Vehicles table for Unique number assigned by the System to the Participants, Type of Asset and Unique number generated for Each Asset and Lien Holders ID is NULL (or) Lien Holders ID is NOT null and Lien Holders ID equal to Unique System Assigned number for the Other Party in Other Party table. 
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-JAN-2012
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SELECT @Ac_Status_CODE = NULL,
         @Ac_LienInitiated_INDC = NULL,
         @Ad_Expired_DATE = NULL,
         @Ad_Issued_DATE = NULL,
         @Ad_Status_DATE = NULL,
         @An_Lien_AMNT = NULL,
         @An_ValueAssessed_AMNT = NULL,
         @An_ValueAsset_AMNT = NULL,
         @Ac_AccountLienNo_TEXT = NULL,
         @An_RowCount_NUMB = NULL,
         @An_TransactionEventSeq_NUMB = NULL,
         @Ac_CntyFipsAssess_CODE = NULL,
         @Ac_AssetOut_CODE = NULL,
         @Ac_SourceLoc_CODE = NULL,
         @Ac_StateAssess_CODE = NULL,
         @Ac_StateVehicle_CODE = NULL,
         @Ac_DescriptionAutoMake_TEXT = NULL,
         @Ac_DescriptionAutoModel_TEXT = NULL,
         @Ac_DescriptionAutoNoLic_TEXT = NULL,
         @Ac_DescriptionAutoYear_TEXT = NULL,
         @Ac_DescriptionVin_TEXT = NULL,
         @An_OthpLien_IDNO = NULL,
         @Ac_WorkerUpdate_ID = NULL,
         @Ac_TitleNo_TEXT = NULL;

  DECLARE @Ld_High_DATE DATE = '12/31/9999',
          @Li_Zero_NUMB SMALLINT = 0;

  SELECT @Ac_AssetOut_CODE = X.Asset_CODE,
         @Ac_TitleNo_TEXT = X.TitleNo_TEXT,
         @Ac_DescriptionVin_TEXT = X.DescriptionVin_TEXT,
         @Ac_DescriptionAutoMake_TEXT = X.DescriptionAutoMake_TEXT,
         @Ac_DescriptionAutoModel_TEXT = X.DescriptionAutoModel_TEXT,
         @Ac_DescriptionAutoYear_TEXT = X.DescriptionAutoYear_TEXT,
         @An_ValueAsset_AMNT = X.ValueAsset_AMNT,
         @An_ValueAssessed_AMNT = X.ValueAssessed_AMNT,
         @Ac_StateAssess_CODE = X.StateAssess_CODE,
         @Ac_CntyFipsAssess_CODE = X.CntyFipsAssess_CODE,
         @Ac_DescriptionAutoNoLic_TEXT = X.DescriptionAutoNoLic_TEXT,
         @Ac_StateVehicle_CODE = X.StateVehicle_CODE,
         @Ad_Issued_DATE = X.Issued_DATE,
         @Ad_Expired_DATE = X.Expired_DATE,
         @Ac_AccountLienNo_TEXT = X.AccountLienNo_TEXT,
         @An_Lien_AMNT = X.Lien_AMNT,
         @Ac_Status_CODE = X.Status_CODE,
         @Ad_Status_DATE = X.Status_DATE,
         @Ac_LienInitiated_INDC = X.LienInitiated_INDC,
         @Ac_SourceLoc_CODE = X.SourceLoc_CODE,
         @An_TransactionEventSeq_NUMB = X.TransactionEventSeq_NUMB,
         @An_OthpLien_IDNO = X.OthpLien_IDNO,
         @An_RowCount_NUMB = X.RowCount_NUMB,
         @Ac_WorkerUpdate_ID = X.WorkerUpdate_ID
    FROM (SELECT a.Asset_CODE,
                 a.TitleNo_TEXT,
                 a.DescriptionVin_TEXT,
                 a.DescriptionAutoMake_TEXT,
                 a.DescriptionAutoModel_TEXT,
                 a.DescriptionAutoYear_TEXT,
                 a.ValueAsset_AMNT,
                 a.ValueAssessed_AMNT,
                 a.StateAssess_CODE,
                 a.CntyFipsAssess_CODE,
                 a.DescriptionAutoNoLic_TEXT,
                 a.StateVehicle_CODE,
                 a.Issued_DATE,
                 a.Expired_DATE,
                 a.AccountLienNo_TEXT,
                 a.Lien_AMNT,
                 a.Status_CODE,
                 a.Status_DATE,
                 a.LienInitiated_INDC,
                 a.SourceLoc_CODE,
                 a.TransactionEventSeq_NUMB,
                 a.OthpLien_IDNO,
                 ROW_NUMBER() OVER( ORDER BY a.EndValidity_DATE DESC, a.Update_DTTM DESC) AS RecRank_NUMB,
                 COUNT(1) OVER() AS RowCount_NUMB,
                 a.WorkerUpdate_ID AS WorkerUpdate_ID
            FROM ASRV_Y1 a
           WHERE a.MemberMci_IDNO = @An_MemberMci_IDNO
             AND (@Ac_Asset_CODE IS NULL
                   OR (@Ac_Asset_CODE IS NOT NULL
                       AND a.Asset_CODE = @Ac_Asset_CODE))
             AND (@An_AssetSeq_NUMB IS NULL
                   OR (@An_AssetSeq_NUMB IS NOT NULL
                       AND a.AssetSeq_NUMB = @An_AssetSeq_NUMB))
             AND EXISTS (SELECT 1
                           FROM OTHP_Y1 O
                          WHERE (a.OthpLien_IDNO = @Li_Zero_NUMB
                                  OR (a.OthpLien_IDNO != @Li_Zero_NUMB
                                      AND a.OthpLien_IDNO = O.OtherParty_IDNO))
                            AND O.EndValidity_DATE = @Ld_High_DATE)) AS X
   WHERE X.RecRank_NUMB = @Ai_Record_NUMB;
 END; --END OF ASRV_RETRIEVE_S3

GO
