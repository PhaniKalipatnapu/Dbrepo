/****** Object:  StoredProcedure [dbo].[OTHP_RETRIEVE_S90]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[OTHP_RETRIEVE_S90] (  
 @An_OtherParty_IDNO          NUMERIC(9, 0),  
 @Ac_TypeOthp_CODE            CHAR(1),  
 @As_OtherParty_NAME          VARCHAR(60),  
 @Ac_Aka_NAME                 CHAR(30),  
 @An_Fein_IDNO                NUMERIC(9, 0),  
 @An_Sein_IDNO                NUMERIC(12, 0),  
 @Ac_NonEndDated_INDC         CHAR(1),  
 @Ac_SearchOptionName_TEXT    CHAR(1),  
 @Ac_SearchOptionAkaName_TEXT CHAR(1),  
 @Ai_RowFrom_NUMB             INT = 1,  
 @Ai_RowTo_NUMB               INT = 10  
 )  
AS  
 /*    
  *     PROCEDURE NAME    : OTHP_RETRIEVE_S90    
  *     DESCRIPTION       : Retrieve Other Party details for an Other Party number, Other Party TYPE, and Other Party Name.   
  *     DEVELOPED BY      : IMP Team    
  *     DEVELOPED ON      : 11-AUG-2011   
  *     MODIFIED BY       :     
  *     MODIFIED ON       :     
  *     VERSION NO        : 1    
  */  
 BEGIN  
  DECLARE @Ld_High_DATE                   DATE = '12/31/9999',  
          @Lc_Percentage_PCT              CHAR(1) = '%',  
          @Lc_Yes_INDC                    CHAR(1) = 'Y',  
          @Lc_TypeAddrcp_CODE             CHAR(1) = 'Z',  
          @Lc_TypeAddrpp_CODE             CHAR(1) = 'G',  
          @Lc_TypeAddrhp_CODE             CHAR(1) = 'V',  
          @Lc_SearchTypeExactLike_TEXT    CHAR(1) = 'E',  
          @Lc_SearchTypeStartsLike_TEXT   CHAR(1) = 'S',  
          @Lc_SearchTypeEndsLike_TEXT     CHAR(1) = 'L',  
          @Lc_SearchTypeSoundsLike_TEXT   CHAR(1) = 'D',  
          @Lc_SearchTypeContainsLike_TEXT CHAR(1) = 'C',  
          @Lc_NonEndDated_INDC            CHAR(1) = 'N';  
  
  WITH Othp_CTE
     AS (SELECT B.OtherParty_NAME,
                        B.TypeOthp_CODE,
                        B.OtherParty_IDNO,
                        B.Fein_IDNO,
                        B.Sein_IDNO,
                        B.Line1_ADDR,
                        B.Line2_ADDR,
                        B.BeginValidity_DATE,
                        B.EndValidity_DATE,
                        B.ParentFein_IDNO,
                        B.DescriptionContactOther_TEXT,
                        B.InsuranceProvided_INDC,
                        B.BarAtty_NUMB,
                        B.Phone_NUMB,
                        B.Eiwn_INDC,
                        B.Aka_NAME,
                        B.County_IDNO,
                        B.Fax_NUMB,
                        B.Attn_ADDR,
                        B.Fips_CODE,
                        B.DchCarrier_IDNO,
                        B.Contact_EML,
                        B.Zip_ADDR,
                        B.State_ADDR,
                        B.City_ADDR,
                        B.Enmsn_INDC,
                        B.Country_ADDR,
                        B.Tribal_INDC,
                        B.Tribal_CODE,
                        B.Verified_INDC,
                        B.SendShort_INDC,
                        B.PpaEiwn_INDC,
                        B.NewOtherParty_IDNO,
                        B.WorkerUpdate_ID,
                        B.Update_DTTM,
                        B.TransactionEventSeq_NUMB,
                        B.DescriptionNotes_TEXT,
                        B.Normalization_CODE,
                        B.ReferenceOthp_IDNO,
                        B.EportalSubscription_INDC,
                        B.ReceivePaperForms_INDC,
                        ROW_NUMBER() OVER( ORDER BY b.OtherParty_NAME, b.EndValidity_DATE DESC) AS ORD_ROWNUM
                   FROM OTHP_Y1 B
                  WHERE (b.TypeOthp_CODE = @Ac_TypeOthp_CODE
                          OR @Ac_TypeOthp_CODE IS NULL)
                    AND (b.OtherParty_IDNO = @An_OtherParty_IDNO
                          OR @An_OtherParty_IDNO IS NULL)
                    AND (b.Fein_IDNO = @An_Fein_IDNO
                          OR @An_Fein_IDNO IS NULL)
                    AND (b.Sein_IDNO = @An_Sein_IDNO
                          OR @An_Sein_IDNO IS NULL)
                    AND ((@As_OtherParty_NAME IS NOT NULL
                          AND ((@Ac_SearchOptionName_TEXT = @Lc_SearchTypeExactLike_TEXT
                                AND b.OtherParty_NAME = REPLACE(@As_OtherParty_NAME, '''', ''''''))
                                OR (@Ac_SearchOptionName_TEXT = @Lc_SearchTypeStartsLike_TEXT
                                    AND b.OtherParty_NAME LIKE REPLACE(@As_OtherParty_NAME, '''', '''''') + @Lc_Percentage_PCT)
                                OR (@Ac_SearchOptionName_TEXT = @Lc_SearchTypeEndsLike_TEXT
                                    AND b.OtherParty_NAME LIKE @Lc_Percentage_PCT + REPLACE(@As_OtherParty_NAME, '''', ''''''))
                                OR (@Ac_SearchOptionName_TEXT = @Lc_SearchTypeSoundsLike_TEXT
                                    AND SOUNDEX(OtherParty_NAME) = SOUNDEX(@As_OtherParty_NAME))
                                OR (@Ac_SearchOptionName_TEXT = @Lc_SearchTypeContainsLike_TEXT
                                    AND b.OtherParty_NAME LIKE @Lc_Percentage_PCT + REPLACE(@As_OtherParty_NAME, '''', '''''') + @Lc_Percentage_PCT)))
                          OR @As_OtherParty_NAME IS NULL)
                    AND ((@Ac_Aka_NAME IS NOT NULL
                          AND ((@Ac_SearchOptionAkaName_TEXT = @Lc_SearchTypeExactLike_TEXT
                                AND b.Aka_NAME = LTRIM(RTRIM(@Ac_Aka_NAME)))
                                OR (@Ac_SearchOptionAkaName_TEXT = @Lc_SearchTypeStartsLike_TEXT
                                    AND b.Aka_NAME LIKE LTRIM(RTRIM(@Ac_Aka_NAME)) + @Lc_Percentage_PCT)
                                OR (@Ac_SearchOptionAkaName_TEXT = @Lc_SearchTypeEndsLike_TEXT
                                    AND b.Aka_NAME LIKE @Lc_Percentage_PCT + LTRIM(RTRIM(@Ac_Aka_NAME)))
                                OR (@Ac_SearchOptionAkaName_TEXT = @Lc_SearchTypeSoundsLike_TEXT
                                    AND SOUNDEX(Aka_NAME) = SOUNDEX(LTRIM(RTRIM(@Ac_Aka_NAME))))
                                OR (@Ac_SearchOptionAkaName_TEXT = @Lc_SearchTypeContainsLike_TEXT
                                    AND b.Aka_NAME LIKE @Lc_Percentage_PCT + LTRIM(RTRIM(@Ac_Aka_NAME)) + @Lc_Percentage_PCT)))
                          OR @Ac_Aka_NAME IS NULL)
                  AND (((@Ac_NonEndDated_INDC = @Lc_NonEndDated_INDC
                        OR @Ac_NonEndDated_INDC IS NULL
                        )
                      AND (b.EndValidity_DATE = @Ld_High_DATE
                            OR EXISTS (SELECT 1
                                         FROM (SELECT c.OtherParty_IDNO AS m_id_other_party,
                                                      MAX(c.EndValidity_DATE) AS m_dt_end_validity,
                                                      MAX(c.Update_DTTM) AS m_ts_update
                                                 FROM OTHP_Y1 c
                                                WHERE c.EndValidity_DATE != @Ld_High_DATE
                                                GROUP BY c.OtherParty_IDNO) AS X
                                        WHERE X.m_dt_end_validity = b.EndValidity_DATE
                                          AND X.m_ts_update = b.Update_DTTM
                                          AND X.m_id_other_party = b.OtherParty_IDNO)))
                      OR (@Ac_NonEndDated_INDC <> @Lc_NonEndDated_INDC
                          AND b.EndValidity_DATE = @Ld_High_DATE))
                ),
     OthpTot_CTE
     AS (SELECT COUNT(1) RowCount_NUMB
           FROM othp_cte)
SELECT Y.OtherParty_IDNO,
       Y.TypeOthp_CODE,
       Y.TransactionEventSeq_NUMB,
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
       Y.NewOtherParty_IDNO,
       Y.Fein_IDNO,
       Y.Contact_EML,
       Y.ParentFein_IDNO,
       Y.InsuranceProvided_INDC,
       Y.Sein_IDNO,
       Y.County_IDNO,
       Y.DchCarrier_IDNO,
       Y.Verified_INDC,
       Y.Eiwn_INDC,
       Y.Enmsn_INDC,
       Y.Tribal_CODE,
       Y.Tribal_INDC,
       Y.BeginValidity_DATE,
       Y.EndValidity_DATE,
       Y.WorkerUpdate_ID,
       Y.Update_DTTM,
       Y.SendShort_INDC,
       Y.PpaEiwn_INDC,
       Y.DescriptionNotes_TEXT,
       Y.Normalization_CODE,
       Y.EportalSubscription_INDC,
       Y.BarAtty_NUMB,
       Y.ReceivePaperForms_INDC,
       (SELECT a.County_NAME
          FROM COPT_Y1 a
         WHERE a.County_IDNO = Y.County_IDNO) AS County_NAME,
       OX.Corporate_IDNO,
       OX.Corporate_NAME,
       OX.PensionPlanAdmin_IDNO,
       OX.PensionPlan_NAME,
       OX.HealthPlanAdmin_IDNO,
       OX.HealthPlan_NAME,
       (SELECT TOP 1 @Lc_Yes_INDC
          FROM OTHP_Y1 o
         WHERE o.OtherParty_IDNO = Y.OtherParty_IDNO
           AND o.TypeOthp_CODE = Y.TypeOthp_CODE
           AND o.EndValidity_DATE != @Ld_High_DATE) AS History_INDC,
       z.RowCount_NUMB
  FROM Othp_CTE AS Y
       CROSS JOIN OthpTot_CTE z
       OUTER apply (SELECT MAX(CASE
                                WHEN C.TypeAddr_CODE = @Lc_TypeAddrcp_CODE
                                 THEN C.AddrOthp_IDNO
                               END) Corporate_IDNO,
                           MAX(CASE
                                WHEN C.TypeAddr_CODE = @Lc_TypeAddrpp_CODE
                                 THEN C.AddrOthp_IDNO
                               END) PensionPlanAdmin_IDNO,
                           MAX(CASE
                                WHEN C.TypeAddr_CODE = @Lc_TypeAddrhp_CODE
                                 THEN C.AddrOthp_IDNO
                               END) HealthPlanAdmin_IDNO,
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

END; -- END OF OTHP_RETRIEVE_S90 


GO
