/****** Object:  StoredProcedure [dbo].[FIPS_RETRIEVE_S3]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[FIPS_RETRIEVE_S3] (
 @Ac_TypeAddress_CODE    CHAR(3),
 @Ac_SubTypeAddress_CODE CHAR(3),
 @Ac_StateFips_CODE      CHAR(2),
 @Ac_CountyFips_CODE     CHAR(3),
 @Ac_OfficeFips_CODE     CHAR(2),
 @Ai_RowFrom_NUMB        INT = 1,
 @Ai_RowTo_NUMB          INT = 10
 )
AS
 /*
  *     PROCEDURE NAME    : FIPS_RETRIEVE_S3
  *     DESCRIPTION       : Retrieves FIPS details for a given State,County,office with specified addresses
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 04-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE 
  	@Ld_High_DATE               DATE = '12/31/9999';
          

  SELECT Y.StateFips_CODE,
         Y.CountyFips_CODE,
         Y.OfficeFips_CODE,
         Y.Fips_NAME,
         Y.Fips_CODE,
         Y.State_ADDR,
         Y.Country_ADDR,
         Y.TypeAddress_CODE,
         Y.SubTypeAddress_CODE,
         Y.ContactTitle_NAME,
         Y.BeginValidity_DATE,
         Y.TransactionEventSeq_NUMB,
         Y.WorkerUpdate_ID,
         RowCount_NUMB
    FROM (SELECT X.StateFips_CODE,
                 X.CountyFips_CODE,
                 X.OfficeFips_CODE,
                 X.Fips_NAME,
                 X.Fips_CODE,
                 X.State_ADDR,
                 X.TypeAddress_CODE,
                 X.SubTypeAddress_CODE,
                 X.ContactTitle_NAME,
                 X.BeginValidity_DATE,
                 X.TransactionEventSeq_NUMB,
                 X.WorkerUpdate_ID,
                 X.RowCount_NUMB,
                 X.ORD_ROWNUM AS Row_Num,
                 X.Country_ADDR
            FROM (SELECT F.StateFips_CODE,
                         F.CountyFips_CODE,
                         F.OfficeFips_CODE,
                         F.Fips_NAME,
                         F.Fips_CODE,
                         F.State_ADDR,
                         F.TypeAddress_CODE,
                         F.SubTypeAddress_CODE,
                         F.ContactTitle_NAME,
                         F.BeginValidity_DATE,
                         F.TransactionEventSeq_NUMB,
                         F.WorkerUpdate_ID,
                         COUNT (1) OVER () AS RowCount_NUMB,
                         F.Country_ADDR,
                         ROW_NUMBER() OVER(ORDER BY F.StateFips_CODE, F.CountyFips_CODE, F.OfficeFips_CODE, F.TypeAddress_CODE, F.SubTypeAddress_CODE DESC) AS ORD_ROWNUM
                    FROM FIPS_Y1 F
                   WHERE F.StateFips_CODE = @Ac_StateFips_CODE
                     AND F.CountyFips_CODE = ISNULL(@Ac_CountyFips_CODE, F.CountyFips_CODE)
                     AND F.OfficeFips_CODE = ISNULL(@Ac_OfficeFips_CODE, F.OfficeFips_CODE)
                     AND F.TypeAddress_CODE = ISNULL(@Ac_TypeAddress_CODE, F.TypeAddress_CODE)
                     AND F.SubTypeAddress_CODE = ISNULL(@Ac_SubTypeAddress_CODE, F.SubTypeAddress_CODE)
                     AND F.EndValidity_DATE = @Ld_High_DATE) AS X
           WHERE X.ORD_ROWNUM <= @Ai_RowTo_NUMB) AS Y
   WHERE Y.Row_Num >= @Ai_RowFrom_NUMB
   ORDER BY Row_Num;
 END; -- END OF FIPS_RETRIEVE_S3 


GO
