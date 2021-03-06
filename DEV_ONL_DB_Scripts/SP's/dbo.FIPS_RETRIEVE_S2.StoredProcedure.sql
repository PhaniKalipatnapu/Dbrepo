/****** Object:  StoredProcedure [dbo].[FIPS_RETRIEVE_S2]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[FIPS_RETRIEVE_S2](
 @Ac_StateFips_CODE       CHAR(2),
 @Ac_Fips_NAME            CHAR(40),
 @Ac_TypeAddress1_CODE    CHAR(3),
 @Ac_TypeAddress2_CODE    CHAR(3),
 @Ac_TypeAddress3_CODE    CHAR(3),
 @Ac_TypeAddress4_CODE    CHAR(3),
 @Ac_SubTypeAddress1_CODE CHAR(3),
 @Ac_SubTypeAddress2_CODE CHAR(3),
 @Ac_SubTypeAddress3_CODE CHAR(3),
 @Ac_SubTypeAddress4_CODE CHAR(3),
 @Ai_RowFrom_NUMB         INT = 1,
 @Ai_RowTo_NUMB           INT = 10
 )
AS
 /*  
  *     PROCEDURE NAME    : FIPS_RETRIEVE_S2  
  *     DESCRIPTION       : Retrieveing the FIPS list details.   
  *     DEVELOPED BY      : IMP Team   
  *     DEVELOPED ON      : 26-JAN-2012
  *     MODIFIED BY       :   
  *     MODIFIED ON       :   
  *     VERSION NO        : 1.0
 */
 BEGIN
  DECLARE @Ld_High_DATE  DATE = '12/31/9999',
          @Li_One_NUMB   SMALLINT=1;
         

  SELECT Z.Fips_CODE,
         Z.TypeAddress_CODE,
         Z.SubTypeAddress_CODE,
         Z.StateFips_CODE,
         Z.CountyFips_CODE,
         Z.OfficeFips_CODE,
         Z.Fips_NAME,
         Z.Line1_ADDR,
         Z.City_ADDR,
         Z.State_ADDR,
         Z.RowCount_NUMB
    FROM (SELECT Y.Fips_NAME,
                 Y.State_ADDR,
                 Y.Fips_CODE,
                 Y.StateFips_CODE,
                 Y.CountyFips_CODE,
                 Y.OfficeFips_CODE,
                 Y.TypeAddress_CODE,
                 Y.SubTypeAddress_CODE,
                 Y.Line1_ADDR,
                 Y.City_ADDR,
                 Y.RowCount_NUMB,
                 Y.ORD_ROWNUM AS Row_NUMB
            FROM (SELECT X.Fips_NAME,
                         X.State_ADDR,
                         X.Fips_CODE,
                         X.StateFips_CODE,
                         X.CountyFips_CODE,
                         X.OfficeFips_CODE,
                         X.TypeAddress_CODE,
                         X.SubTypeAddress_CODE,
                         X.Line1_ADDR,
                         X.City_ADDR,
                         X.row_rank,
                         COUNT (1) OVER () AS RowCount_NUMB,
                         ROW_NUMBER () OVER ( ORDER BY X.Fips_NAME ) AS ORD_ROWNUM
                    FROM (SELECT f.Fips_NAME,
                                 f.State_ADDR,
                                 f.Fips_CODE,
                                 f.StateFips_CODE,
                                 f.CountyFips_CODE,
                                 f.OfficeFips_CODE,
                                 f.TypeAddress_CODE,
                                 f.SubTypeAddress_CODE,
                                 f.Line1_ADDR,
                                 f.City_ADDR,
                                 ROW_NUMBER () OVER ( PARTITION BY f.Fips_CODE ORDER BY f.Fips_CODE, f.Fips_NAME ) AS row_rank
                            FROM FIPS_Y1 f
                           WHERE ((f.TypeAddress_CODE            = @Ac_TypeAddress1_CODE
                                   AND f.SubTypeAddress_CODE     = @Ac_SubTypeAddress1_CODE)
                                   OR (f.TypeAddress_CODE        = @Ac_TypeAddress2_CODE
                                       AND f.SubTypeAddress_CODE = @Ac_SubTypeAddress2_CODE)
                                   OR (f.TypeAddress_CODE        = @Ac_TypeAddress3_CODE
                                       AND f.SubTypeAddress_CODE = @Ac_SubTypeAddress3_CODE)
                                   OR (f.TypeAddress_CODE        = @Ac_TypeAddress4_CODE
                                       AND f.SubTypeAddress_CODE = @Ac_SubTypeAddress4_CODE))
                             AND f.Fips_NAME >= ISNULL(@Ac_Fips_NAME, f.Fips_NAME)
                             AND f.StateFips_CODE = @Ac_StateFips_CODE
                             AND f.EndValidity_DATE = @Ld_High_DATE) X
                   WHERE X.row_rank =@Li_One_NUMB)  Y
           WHERE Y.ORD_ROWNUM <= @Ai_RowTo_NUMB)  Z
   WHERE Z.Row_NUMB >= @Ai_RowFrom_NUMB
   ORDER BY Z.Row_NUMB;
 END; --End Of FIPS_RETRIEVE_S2 

GO
