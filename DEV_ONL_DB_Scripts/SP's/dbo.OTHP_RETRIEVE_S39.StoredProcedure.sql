/****** Object:  StoredProcedure [dbo].[OTHP_RETRIEVE_S39]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[OTHP_RETRIEVE_S39] (
 @An_OtherParty_IDNO  NUMERIC(9, 0),
 @Ac_TypeOthp_CODE    CHAR(1),
 @As_OtherParty_NAME  VARCHAR(60),
 @Ac_Aka_NAME         CHAR(30),
 @An_Fein_IDNO        NUMERIC(9, 0),
 @An_Sein_IDNO        NUMERIC(12, 0),
 @Ac_SrchOption_TEXT  CHAR(1),
 @Ac_SrchOption1_TEXT CHAR(1),
 @Ai_RowFrom_NUMB     INT = 1,
 @Ai_RowTo_NUMB       INT = 10
 )
AS
 /*      
 *     PROCEDURE NAME    : OTHP_RETRIEVE_S39      
 *     DESCRIPTION       : Retrieve OtherParty details FOR an Other Party number, TYPE Othp code .    
 *     DEVELOPED BY      : IMP Team     
 *     DEVELOPED ON      : 08-AUG-2011    
 *     MODIFIED BY       :       
 *     MODIFIED ON       :       
 *     VERSION NO        : 1      
 */
 BEGIN
  DECLARE @Lc_Percentage_PCT              CHAR(1) = '%',
          @Lc_SearchTypeContainsLike_TEXT CHAR(1) = 'C',
          @Lc_SearchTypeEndsLike_TEXT     CHAR(1) = 'L',
          @Lc_SearchTypeExactLike_TEXT    CHAR(1) = 'E',
          @Lc_SearchTypeSoundsLike_TEXT   CHAR(1) = 'D',
          @Lc_SearchTypeStartsLike_TEXT   CHAR(1) = 'S',
          @Lc_TypeAddrcp_CODE             CHAR(1) = 'Z',
          @Lc_TypeAddrpp_CODE             CHAR(1) = 'G',
          @Lc_TypeAddrhp_CODE             CHAR(1) = 'V',
          @Lc_TableCtry_ID                CHAR(4) = 'CTRY',
          @Ld_High_DATE                   DATE = '12/31/9999',
          @Lc_TableStat_ID                CHAR(4) = 'STAT';

  WITH Othp_CTE
       AS (SELECT B.OtherParty_NAME,
                  B.OtherParty_IDNO,
                  B.Fein_IDNO,
                  B.Sein_IDNO,
                  B.Line1_ADDR,
                  B.Line2_ADDR,
                  B.City_ADDR,
                  B.State_ADDR,
                  B.Country_ADDR,
                  B.DescriptionContactOther_TEXT,
                  B.Phone_NUMB,
                  B.Fax_NUMB,
                  B.Contact_EML,
                  B.BeginValidity_DATE,
                  B.EndValidity_DATE,
                  B.ParentFein_IDNO,
                  B.Aka_NAME,
                  B.Attn_ADDR,
                  B.Nsf_INDC,
                  B.Fips_CODE,
                  B.BarAtty_NUMB,
                  B.County_IDNO,
                  B.DchCarrier_IDNO,
                  B.Eiwn_INDC,
                  B.PpaEiwn_INDC,
                  B.Enmsn_INDC,
                  B.Zip_ADDR,
                  B.Tribal_INDC,
                  B.Tribal_CODE,
                  B.Verified_INDC,
                  B.SendShort_INDC,
                  B.ReferenceOthp_IDNO,
                  B.InsuranceProvided_INDC,
                  B.EportalSubscription_INDC,
                  B.ReceivePaperForms_INDC,
                  ROW_NUMBER () OVER ( ORDER BY b.OtherParty_NAME ) AS ORD_ROWNUM
             FROM OTHP_Y1 B
            WHERE B.TypeOthp_CODE = @Ac_TypeOthp_CODE
              AND ((@An_OtherParty_IDNO IS NULL)
                    OR (@An_OtherParty_IDNO IS NOT NULL
                        AND b.OtherParty_IDNO = @An_OtherParty_IDNO))
              AND ((@An_Fein_IDNO IS NULL)
                    OR (@An_Fein_IDNO IS NOT NULL
                        AND b.Fein_IDNO = @An_Fein_IDNO))
              AND ((@An_Sein_IDNO IS NULL)
                    OR (@An_Sein_IDNO IS NOT NULL
                        AND b.Sein_IDNO = @An_Sein_IDNO))
              AND ((@As_OtherParty_NAME IS NULL)
                    OR (@As_OtherParty_NAME IS NOT NULL
                        AND ((@Ac_SrchOption_TEXT = @Lc_SearchTypeExactLike_TEXT
                              AND UPPER (b.OtherParty_NAME) = UPPER (@As_OtherParty_NAME))
                              OR (@Ac_SrchOption_TEXT = @Lc_SearchTypeStartsLike_TEXT
                                  AND UPPER (b.OtherParty_NAME) LIKE UPPER (@As_OtherParty_NAME) + @Lc_Percentage_PCT)
                              OR (@Ac_SrchOption_TEXT = @Lc_SearchTypeEndsLike_TEXT
                                  AND UPPER (b.OtherParty_NAME) LIKE @Lc_Percentage_PCT + UPPER (@As_OtherParty_NAME))
                              OR (@Ac_SrchOption_TEXT = @Lc_SearchTypeSoundsLike_TEXT
                                  AND SOUNDEX(b.OtherParty_NAME) = SOUNDEX(@As_OtherParty_NAME))
                              OR (@Ac_SrchOption_TEXT = @Lc_SearchTypeContainsLike_TEXT
                                  AND UPPER (b.OtherParty_NAME) LIKE @Lc_Percentage_PCT + UPPER(@As_OtherParty_NAME) + @Lc_Percentage_PCT))))
              AND ((@Ac_Aka_NAME IS NULL)
                    OR (@Ac_Aka_NAME IS NOT NULL
                        AND ((@Ac_SrchOption1_TEXT = @Lc_SearchTypeExactLike_TEXT
                              AND UPPER (b.Aka_NAME) = UPPER(LTRIM(RTRIM(@Ac_Aka_NAME))))
                              OR (@Ac_SrchOption1_TEXT = @Lc_SearchTypeStartsLike_TEXT
                                  AND UPPER (b.Aka_NAME) LIKE UPPER(LTRIM(RTRIM(@Ac_Aka_NAME))) + @Lc_Percentage_PCT)
                              OR (@Ac_SrchOption1_TEXT = @Lc_SearchTypeEndsLike_TEXT
                                  AND UPPER (b.Aka_NAME) LIKE @Lc_Percentage_PCT + UPPER(LTRIM(RTRIM(@Ac_Aka_NAME))))
                              OR (@Ac_SrchOption1_TEXT = @Lc_SearchTypeSoundsLike_TEXT
                                  AND SOUNDEX(b.Aka_NAME) = SOUNDEX(LTRIM(RTRIM(@Ac_Aka_NAME))))
                              OR (@Ac_SrchOption1_TEXT = @Lc_SearchTypeContainsLike_TEXT
                                  AND UPPER (b.Aka_NAME) LIKE @Lc_Percentage_PCT + UPPER(LTRIM(RTRIM(@Ac_Aka_NAME))) + @Lc_Percentage_PCT))))
              AND b.EndValidity_DATE = @Ld_High_DATE),
       RecCount_CTE
       AS (SELECT COUNT(1) RowCount_NUMB
             FROM OTHP_CTE)
  SELECT Y.OtherParty_IDNO,
         Y.OtherParty_NAME,
         Y.Aka_NAME,
         Y.Attn_ADDR,
         Y.Line1_ADDR,
         Y.Line2_ADDR,
         Y.City_ADDR,
         Y.Zip_ADDR,
         Y.State_ADDR,
         Y.Fips_CODE,
         Y.Country_ADDR,
         Y.DescriptionContactOther_TEXT,
         Y.Phone_NUMB,
         Y.Fax_NUMB,
         Y.ReferenceOthp_IDNO,
         Y.Fein_IDNO,
         Y.Contact_EML,
         Y.ParentFein_IDNO,
         Y.InsuranceProvided_INDC,
         Y.Sein_IDNO,
         Y.DchCarrier_IDNO,
         Y.Nsf_INDC,
         Y.Verified_INDC,
         Y.Eiwn_INDC,
         Y.Enmsn_INDC,
         Y.Tribal_CODE,
         Y.Tribal_INDC,
         Y.BeginValidity_DATE,
         Y.EndValidity_DATE,
         Y.SendShort_INDC,
         Y.PpaEiwn_INDC,
         Y.EportalSubscription_INDC,
         Y.BarAtty_NUMB,
         Y.ReceivePaperForms_INDC,
         Y.County_IDNO,
         (SELECT R.DescriptionValue_TEXT
            FROM REFM_Y1 R
           WHERE R.Table_ID = @Lc_TableStat_ID
             AND R.TableSub_ID = @Lc_TableStat_ID
             AND R.Value_CODE = Y.State_ADDR) AS State_NAME,
         (SELECT R.DescriptionValue_TEXT
            FROM REFM_Y1 R
           WHERE R.Table_ID = @Lc_TableCtry_ID
             AND R.TableSub_ID = @Lc_TableCtry_ID
             AND R.Value_CODE = Y.Country_ADDR) AS Country_Name,
         OX.Corporate_IDNO AS Corporate_IDNO,
         OX.Corporate_NAME,
         OX.PensionPlanAdmin_CODE AS PensionPlanAdmin_IDNO,
         OX.PensionPlan_NAME,
         OX.HealthPlanAdmin_CODE AS HealthPlanAdmin_IDNO,
         OX.HealthPlan_NAME,
         RowCount_NUMB
    FROM Othp_CTE AS Y
         CROSS JOIN RecCount_CTE AS z
         OUTER apply (SELECT MAX(CASE
                                  WHEN C.TypeAddr_CODE = @Lc_TypeAddrcp_CODE
                                   THEN C.AddrOthp_IDNO
                                 END) Corporate_IDNO,
                             MAX(CASE
                                  WHEN C.TypeAddr_CODE = @Lc_TypeAddrpp_CODE
                                   THEN C.AddrOthp_IDNO
                                 END) PensionPlanAdmin_CODE,
                             MAX(CASE
                                  WHEN C.TypeAddr_CODE = @Lc_TypeAddrhp_CODE
                                   THEN C.AddrOthp_IDNO
                                 END) HealthPlanAdmin_CODE,
                             MAX(CASE
                                  WHEN C.TypeAddr_CODE = @Lc_TypeAddrcp_CODE
                                   THEN o.OtherParty_NAME
                                 END) Corporate_NAME,
                             MAX(CASE
                                  WHEN C.TypeAddr_CODE = @Lc_TypeAddrpp_CODE
                                   THEN o.OtherParty_NAME
                                 END) PensionPlan_NAME,
                             MAX(CASE
                                  WHEN C.TypeAddr_CODE = @Lc_TypeAddrhp_CODE
                                   THEN o.OtherParty_NAME
                                 END) HealthPlan_NAME
                        FROM OTHX_Y1 C,
                             OTHP_Y1 o
                       WHERE C.OtherParty_IDNO = Y.OtherParty_IDNO
                         AND o.OtherParty_IDNO = C.AddrOthp_IDNO
                         AND o.EndValidity_DATE = @Ld_High_DATE
                         AND C.EndValidity_DATE = @Ld_High_DATE
                         AND C.TypeAddr_CODE IN (@Lc_TypeAddrcp_CODE, @Lc_TypeAddrpp_CODE, @Lc_TypeAddrhp_CODE)) OX
   WHERE Y.ORD_ROWNUM BETWEEN @Ai_RowFrom_NUMB AND @Ai_RowTo_NUMB
   ORDER BY Y.ORD_ROWNUM;
 END; -- END OF  OTHP_RETRIEVE_S39;  


GO
