/****** Object:  StoredProcedure [dbo].[ASRV_RETRIEVE_S2]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ASRV_RETRIEVE_S2] (
 @An_MemberMci_IDNO NUMERIC(10, 0),
 @Ac_Asset_CODE     CHAR(3),
 @Ac_Status_CODE    CHAR(1),
 @Ac_AssetType_CODE CHAR(2),
 @Ai_RowFrom_NUMB   INT =1,
 @Ai_RowTo_NUMB     INT =10
 )
AS
 /*
  *     PROCEDURE NAME    : ASRV_RETRIEVE_S2
  *     DESCRIPTION       : Retrieve MAST Summary details from Registered Vehicles table, Realty Assets table and Member Financial Assets table for Unique number assigned by the System to the Participants, Verification Status code, Type of Asset equal to NULL (or) Type of Asset NOT equal to NULL and Type of Asset equal to RV in Registered Vehicles table (or) Type of Asset equal to RP in Realty Assets table (or) Type of Asset equal to F in Member Financial Assets table with Type of Asset does exist in Maintenance Reference table as value within the Reference Table for Reference Table that is being utilized equal to MAST and subtype within the Reference Table equal to FINA / FIIS / FINS. 
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-JAN-2012
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Li_Zero_NUMB        SMALLINT = 0,
          @Ld_High_DATE        DATE = '12/31/9999',
          @Lc_AssetTypeF_CODE  CHAR(1) = 'F',
          @Lc_AssetTypeRp_CODE CHAR(2) = 'RP',
          @Lc_AssetTypeRv_CODE CHAR(2) = 'RV',
          @Lc_Fiis_ID          CHAR(4) = 'FIIS',
          @Lc_Fina_ID          CHAR(4) = 'FINA',
          @Lc_Fins_ID          CHAR(4) = 'FINS',
          @Lc_Mast_ID          CHAR(4) = 'MAST',
          @Lc_Regv_ID          CHAR(4) = 'REGV',
          @Lc_Relp_ID          CHAR(4) = 'RELP';

  SELECT Y.AssetType_CODE,
         Y.AssetSeq_NUMB,
         Y.Asset_CODE,
         Y.DescriptionValue_TEXT,
         Y.BeginValidity_DATE,
         Y.EndValidity_DATE,
         Y.Status_CODE,
         Y.Status_DATE,
         Y.OthpInsFin_IDNO,
         Y.OthpLien_IDNO,
         Y.OthpAtty_IDNO,
         Y.TransactionEventSeq_NUMB,
         Y.RowCount_NUMB,
         Y.WorkerUpdate_ID
    FROM (SELECT X.AssetType_CODE,
                 X.AssetSeq_NUMB,
                 X.Asset_CODE,
                 X.DescriptionValue_TEXT,
                 X.BeginValidity_DATE,
                 X.EndValidity_DATE,
                 X.Status_CODE,
                 X.Status_DATE,
                 X.OthpInsFin_IDNO,
                 X.OthpLien_IDNO,
                 X.OthpAtty_IDNO,
                 X.TransactionEventSeq_NUMB,
                 COUNT(1) OVER() AS RowCount_NUMB,
                 X.WorkerUpdate_ID,
                 X.ORD_ROWNUM
            FROM (SELECT A.AssetType_CODE,
                         A.AssetSeq_NUMB,
                         A.Asset_CODE,
                         A.DescriptionValue_TEXT,
                         A.BeginValidity_DATE,
                         A.EndValidity_DATE,
                         A.Status_CODE,
                         A.Status_DATE,
                         A.OthpInsFin_IDNO,
                         A.OthpLien_IDNO,
                         A.OthpAtty_IDNO,
                         A.TransactionEventSeq_NUMB,
                         A.WorkerUpdate_ID,
                         ROW_NUMBER() OVER( ORDER BY A.TransactionEventSeq_NUMB DESC, A.AssetType_CODE, A.AssetSeq_NUMB) AS ORD_ROWNUM
                    FROM (SELECT @Lc_AssetTypeRv_CODE AS AssetType_CODE,
                                 a.AssetSeq_NUMB,
                                 a.Asset_CODE,
                                 (SELECT R.DescriptionValue_TEXT
                                    FROM REFM_Y1 R
                                   WHERE R.Table_ID = @Lc_Mast_ID
                                     AND R.TableSub_ID = @Lc_Regv_ID
                                     AND R.Value_CODE = a.Asset_CODE) AS DescriptionValue_TEXT,
                                 a.BeginValidity_DATE,
                                 a.EndValidity_DATE,
                                 a.Status_CODE,
                                 a.Status_DATE,
                                 @Li_Zero_NUMB AS OthpInsFin_IDNO,
                                 a.OthpLien_IDNO,
                                 @Li_Zero_NUMB AS OthpAtty_IDNO,
                                 a.TransactionEventSeq_NUMB,
                                 a.WorkerUpdate_ID
                            FROM ASRV_Y1 a
                           WHERE a.MemberMci_IDNO = @An_MemberMci_IDNO
                             AND (@Ac_AssetType_CODE IS NULL
                                   OR (@Ac_AssetType_CODE IS NOT NULL
                                       AND @Lc_AssetTypeRv_CODE = @Ac_AssetType_CODE))
                             AND (@Ac_Asset_CODE IS NULL
                                   OR (@Ac_Asset_CODE IS NOT NULL
                                       AND a.Asset_CODE = @Ac_Asset_CODE))
                             AND (@Ac_Status_CODE IS NULL
                                   OR (@Ac_Status_CODE IS NOT NULL
                                       AND a.Status_CODE = @Ac_Status_CODE))
                             AND a.EndValidity_DATE = @Ld_High_DATE
                          UNION
                          SELECT @Lc_AssetTypeRp_CODE AS AssetType_CODE,
                                 a.AssetSeq_NUMB,
                                 a.Asset_CODE,
                                 (SELECT R.DescriptionValue_TEXT
                                    FROM REFM_Y1 R
                                   WHERE R.Table_ID = @Lc_Mast_ID
                                     AND R.TableSub_ID = @Lc_Relp_ID
                                     AND R.Value_CODE = a.Asset_CODE) AS DescriptionValue_TEXT,
                                 a.BeginValidity_DATE,
                                 a.EndValidity_DATE,
                                 a.Status_CODE,
                                 a.Status_DATE,
                                 @Li_Zero_NUMB AS OthpInsFin_IDNO,
                                 a.OthpLien_IDNO,
                                 @Li_Zero_NUMB AS OthpAtty_IDNO,
                                 a.TransactionEventSeq_NUMB,
                                 a.WorkerUpdate_ID
                            FROM ASRE_Y1 a
                           WHERE a.MemberMci_IDNO = @An_MemberMci_IDNO
                             AND (@Ac_AssetType_CODE IS NULL
                                   OR (@Ac_AssetType_CODE IS NOT NULL
                                       AND @Lc_AssetTypeRp_CODE = @Ac_AssetType_CODE))
                             AND (@Ac_Asset_CODE IS NULL
                                   OR (@Ac_Asset_CODE IS NOT NULL
                                       AND a.Asset_CODE = @Ac_Asset_CODE))
                             AND (@Ac_Status_CODE IS NULL
                                   OR (@Ac_Status_CODE IS NOT NULL
                                       AND a.Status_CODE = @Ac_Status_CODE))
                             AND a.EndValidity_DATE = @Ld_High_DATE
                          UNION
                          SELECT @Lc_AssetTypeF_CODE AS AssetType_CODE,
                                 a.AssetSeq_NUMB,
                                 a.Asset_CODE,
                                 b.DescriptionValue_TEXT,
                                 a.BeginValidity_DATE,
                                 a.EndValidity_DATE,
                                 a.Status_CODE,
                                 a.Status_DATE,
                                 a.OthpInsFin_IDNO AS OthpInsFin_IDNO,
                                 @Li_Zero_NUMB AS OthpLien_IDNO,
                                 a.OthpAtty_IDNO AS OthpAtty_IDNO,
                                 a.TransactionEventSeq_NUMB,
                                 a.WorkerUpdate_ID
                            FROM ASFN_Y1 a
                                 JOIN (SELECT R.Value_CODE,
                                              R.DescriptionValue_TEXT
                                         FROM REFM_Y1 R
                                        WHERE R.Table_ID = @Lc_Mast_ID
                                          AND R.TableSub_ID IN (@Lc_Fina_ID, @Lc_Fins_ID, @Lc_Fiis_ID)) b
                                  ON (a.Asset_CODE = b.Value_CODE)
                           WHERE a.MemberMci_IDNO = @An_MemberMci_IDNO
                             AND (@Ac_AssetType_CODE IS NULL
                                   OR (@Ac_AssetType_CODE IS NOT NULL
                                       AND @Lc_AssetTypeF_CODE = @Ac_AssetType_CODE))
                             AND (@Ac_Asset_CODE IS NULL
                                   OR (@Ac_Asset_CODE IS NOT NULL
                                       AND a.Asset_CODE = @Ac_Asset_CODE))
                             AND (@Ac_Status_CODE IS NULL
                                   OR (@Ac_Status_CODE IS NOT NULL
                                       AND a.Status_CODE = @Ac_Status_CODE))
                             AND a.EndValidity_DATE = @Ld_High_DATE) AS A) AS X) AS Y
   WHERE Y.ORD_ROWNUM >= @Ai_RowFrom_NUMB
     AND Y.ORD_ROWNUM <= @Ai_RowTo_NUMB
   ORDER BY ORD_ROWNUM;
 END; --END OF ASRV_RETRIEVE_S2

GO
