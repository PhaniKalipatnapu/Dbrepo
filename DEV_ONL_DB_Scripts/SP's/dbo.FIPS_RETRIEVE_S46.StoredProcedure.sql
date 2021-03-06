/****** Object:  StoredProcedure [dbo].[FIPS_RETRIEVE_S46]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[FIPS_RETRIEVE_S46](
 @An_Case_IDNO    NUMERIC(6),
 @Ai_RowFrom_NUMB INT = 1,
 @Ai_RowTo_NUMB   INT = 10
 )
AS
 /*
  *     PROCEDURE NAME    : FIPS_RETRIEVE_S46
  *     DESCRIPTION       : Retrieve Fips Code reference details for a Responding case, Interstate Case State & Country and Address Type.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02/03/2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Lc_CaseStatusOpen_CODE             CHAR(1) = 'O',
          @Lc_CaseRelationshipCp_CODE         CHAR(1) = 'C',
          @Lc_RespondingState_CODE            CHAR(1) = 'R',
          @Lc_RespondingInternational_CODE    CHAR(1) = 'Y',
          @Lc_RespondingTribal_CODE           CHAR(1) = 'S',
          @Lc_CaseMemberStatusActive_CODE     CHAR(1) = 'A',
          @Lc_IVDOutOfStateCountyFips00_CODE  CHAR(2) = '00',
          @Lc_HyphenWithSpace_TEXT            CHAR(3) = ' - ',
          @Lc_IVDOutOfStateCountyFips000_CODE CHAR(3) = '000',
          @Lc_SubTypeAddressC01_CODE          CHAR(3) = 'C01',
          @Lc_SubTypeAddressCrg_CODE          CHAR(3) = 'CRG',
          @Lc_SubTypeAddressFrc_CODE          CHAR(3) = 'FRC',
          @Lc_SubTypeAddressT01_CODE          CHAR(3) = 'T01',
          @Lc_TypeAddressInt_CODE             CHAR(3) = 'INT',
          @Lc_TypeAddressLocal_CODE           CHAR(3) = 'LOC',
          @Lc_TypeAddressState_CODE           CHAR(3) = 'STA',
          @Lc_TypeAddressTribal_CODE          CHAR(3) = 'TRB',
          @Lc_TableRela_ID                    CHAR(4) = 'RELA',
          @Lc_TableSubCase_ID                 CHAR(4) = 'CASE',
          @Ld_Current_DATE					  DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
          @Ld_High_DATE                       DATE = '12/31/9999';

  SELECT X.Fips_CODE,
         X.Fips_NAME,
         X.Line1_ADDR,
         X.Line2_ADDR,
         X.City_ADDR,
         X.State_ADDR,
         X.Zip_ADDR,
         X.CaseRelationship_CODE,
         X.MemberMci_IDNO,
         X.RowCount_NUMB
    FROM (SELECT f.Fips_CODE,
                 f.Fips_NAME,
                 f.Line1_ADDR,
                 f.Line2_ADDR,
                 f.City_ADDR,
                 f.State_ADDR,
                 f.Zip_ADDR,
                 ISNULL(c.CaseRelationship_CODE, '') + ISNULL(@Lc_HyphenWithSpace_TEXT, '') + ISNULL((SELECT r.DescriptionValue_TEXT
                                                                                                        FROM REFM_Y1 r
                                                                                                       WHERE r.Table_ID = @Lc_TableRela_ID
                                                                                                         AND r.TableSub_ID = @Lc_TableSubCase_ID
                                                                                                         AND r.Value_CODE = c.CaseRelationship_CODE), '') AS CaseRelationship_CODE,
                 c.MemberMci_IDNO,
                 ROW_NUMBER() OVER( ORDER BY f.Fips_CODE) AS rn,
                 COUNT(1) OVER() AS RowCount_NUMB
            FROM FIPS_Y1 f,
                 ICAS_Y1 s,
                 CMEM_Y1 c
           WHERE s.RespondInit_CODE IN (@Lc_RespondingState_CODE, @Lc_RespondingInternational_CODE, @Lc_RespondingTribal_CODE)
             AND s.IVDOutOfStateFips_CODE = f.StateFips_CODE
             AND s.IVDOutOfStateCountyFips_CODE = f.CountyFips_CODE
             AND ((f.TypeAddress_CODE = @Lc_TypeAddressState_CODE
                   AND f.SubTypeAddress_CODE = @Lc_SubTypeAddressCrg_CODE
                   AND (RTRIM(LTRIM(s.IVDOutOfStateCountyFips_CODE)) = @Lc_IVDOutOfStateCountyFips000_CODE
                         OR dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR(s.IVDOutOfStateCountyFips_CODE) IS NULL)
                   AND (RTRIM(LTRIM(s.IVDOutOfStateOfficeFips_CODE)) = @Lc_IVDOutOfStateCountyFips00_CODE
                         OR dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR(s.IVDOutOfStateOfficeFips_CODE) IS NULL))
                   OR (f.TypeAddress_CODE = @Lc_TypeAddressLocal_CODE
                       AND f.SubTypeAddress_CODE = @Lc_SubTypeAddressC01_CODE
                       AND (RTRIM(LTRIM(s.IVDOutOfStateCountyFips_CODE)) <> @Lc_IVDOutOfStateCountyFips000_CODE
                             OR dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR(s.IVDOutOfStateCountyFips_CODE) IS NOT NULL))
                   OR (f.TypeAddress_CODE = @Lc_TypeAddressInt_CODE
                       AND f.SubTypeAddress_CODE = @Lc_SubTypeAddressFrc_CODE
                       AND (RTRIM(LTRIM(s.IVDOutOfStateOfficeFips_CODE)) = @Lc_IVDOutOfStateCountyFips00_CODE
                             OR dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR(s.IVDOutOfStateOfficeFips_CODE) IS NULL))
                   OR (f.TypeAddress_CODE = @Lc_TypeAddressTribal_CODE
                       AND f.SubTypeAddress_CODE = @Lc_SubTypeAddressT01_CODE
                       AND (RTRIM(LTRIM(s.IVDOutOfStateOfficeFips_CODE)) = @Lc_IVDOutOfStateCountyFips00_CODE
                             OR dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR(s.IVDOutOfStateOfficeFips_CODE) IS NULL)))
             AND f.EndValidity_DATE = @Ld_High_DATE
             AND s.Status_CODE = @Lc_CaseStatusOpen_CODE
             AND s.EndValidity_DATE = @Ld_High_DATE
             AND @Ld_Current_DATE BETWEEN s.Effective_DATE AND s.End_DATE
             AND s.Case_IDNO = @An_Case_IDNO
             AND c.Case_IDNO = @An_Case_IDNO
             AND c.CaseRelationship_CODE = @Lc_CaseRelationshipCp_CODE
             AND c.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE) AS X
   WHERE X.rn BETWEEN @Ai_RowFrom_NUMB AND @Ai_RowTo_NUMB;
 END


GO
