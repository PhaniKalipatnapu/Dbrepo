/****** Object:  StoredProcedure [dbo].[CERR_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CERR_RETRIEVE_S1] (
 @An_Case_IDNO    NUMERIC(6, 0),
 @Ai_RowFrom_NUMB INT =1,
 @Ai_RowTo_NUMB   INT =10
 )
AS
 /*  
  *     PROCEDURE NAME    : CERR_RETRIEVE_S1  
  *     DESCRIPTION       : Retrieve Csenet Host Error details for a Case Idno and Date of Action.  
  *     DEVELOPED BY      : IMP Team 
  *     DEVELOPED ON      : 01-SEP-2011  
  *     MODIFIED BY       :   
  *     MODIFIED ON       :   
  *     VERSION NO        : 1  
  */
 BEGIN
  DECLARE @Li_Zero_NUMB                 SMALLINT = 0,
          @Li_One_NUMB                  SMALLINT = 1,
          @Li_Two_NUMB                  SMALLINT = 2,
          @Lc_Space_TEXT                CHAR(1) = ' ',
          @Lc_ExchangeMode_CODE         CHAR(1) = 'C',
          @Lc_Percentage_TEXT           CHAR(1) = '%',
          @Lc_ErrorTypeHost_INDC        CHAR(1) = 'H',
          @Lc_ErrorTypeBate_INDC        CHAR(1) = 'B',
          @Lc_JobOugoing_ID             CHAR(7) = 'DEB0740',
          @Lc_ListKeyCase_TEXT          CHAR(13) = '%Case_IDNO = ',          
          @Lc_HostErrorDescription_TEXT CHAR(15) = 'HE - HOST ERROR',
          @Lc_BateErrorDescription_TEXT CHAR(15) = 'BA - BATE ERROR',
          @Ld_High_DATE                 DATE = '12/31/9999';

  SELECT Z.TransHeader_IDNO,
         Z.Transaction_DATE,
         SUBSTRING(Z.OtherFips_CODE, @Li_One_NUMB, @Li_Two_NUMB) AS CerrOtherFips_CODE,
         Z.SeqError_IDNO,
         SUBSTRING(Z.Fips_CODE, @Li_One_NUMB, @Li_Two_NUMB) AS CerrFips_CODE,
         Z.Case_IDNO,
         Z.OutStateCase_ID,
         Z.Error_CODE,
         Z.DescriptionError_TEXT,
         ISNULL((SELECT ST.State_NAME
                   FROM STAT_Y1 ST
                  WHERE ST.StateFips_CODE = SUBSTRING(Z.OtherFips_CODE, @Li_One_NUMB, @Li_Two_NUMB)), @Lc_Space_TEXT) AS NameStateOtherFips_ADDR,
         ISNULL((SELECT S.State_NAME
                   FROM STAT_Y1 S
                  WHERE S.StateFips_CODE = SUBSTRING(Z.Fips_CODE, @Li_One_NUMB, @Li_Two_NUMB)), @Lc_Space_TEXT) AS NameStateFips_ADDR,
         ErrorTypeDescription_TEXT,
         @Lc_ExchangeMode_CODE AS ExchangeMode_CODE,
         Z.Action_CODE,
         Z.Function_CODE,
         Z.Reason_CODE,
         ISNULL((SELECT DescriptionFar_TEXT
                   FROM CFAR_Y1 c
                  WHERE c.Action_CODE = Z.Action_CODE
                    AND c.Function_CODE = Z.Function_CODE
                    AND c.Reason_CODE = Z.Reason_CODE), @Lc_Space_TEXT) AS DescriptionFar_TEXT,
         ErrorType_INDC,
         RowCount_NUMB
    FROM (SELECT Y.Transaction_DATE,
                 Y.Fips_CODE,
                 Y.OtherFips_CODE,
                 Y.OutStateCase_ID,
                 Y.Error_CODE,
                 Y.DescriptionError_TEXT,
                 Y.SeqError_IDNO,
                 Y.TransHeader_IDNO,
                 Y.Case_IDNO,
                 Y.Action_CODE,
                 Y.Function_CODE,
                 Y.Reason_CODE,
                 ErrorTypeDescription_TEXT,
                 ErrorType_INDC,
                 Y.RowCount_NUMB,
                 Y.ORD_ROWNUM AS row_num
            FROM (SELECT X.Transaction_DATE,
                         X.Fips_CODE,
                         X.OtherFips_CODE,
                         X.OutStateCase_ID,
                         X.Error_CODE,
                         X.DescriptionError_TEXT,
                         X.SeqError_IDNO,
                         X.TransHeader_IDNO,
                         X.Case_IDNO,
                         X.Action_CODE,
                         X.Function_CODE,
                         X.Reason_CODE,
                         ErrorTypeDescription_TEXT,
                         ErrorType_INDC,
                         COUNT(1) OVER() AS RowCount_NUMB,
                         ROW_NUMBER() OVER(ORDER BY X.Transaction_DATE DESC) AS ORD_ROWNUM
                    FROM (SELECT a.Transaction_DATE,
                                 a.Fips_CODE,
                                 a.OtherFips_CODE,
                                 a.OutStateCase_ID,
                                 a.Error_CODE,
                                 a.DescriptionError_TEXT,
                                 a.SeqError_IDNO,
                                 a.TransHeader_IDNO,
                                 a.Case_IDNO,
                                 a.Action_CODE,
                                 a.Function_CODE,
                                 a.Reason_CODE,
                                 @Lc_HostErrorDescription_TEXT AS ErrorTypeDescription_TEXT,
                                 @Lc_ErrorTypeHost_INDC ErrorType_INDC
                            FROM CERR_Y1 a
                           WHERE (@An_Case_IDNO IS NULL
                                   OR (@An_Case_IDNO IS NOT NULL
                                       AND a.Case_IDNO = @An_Case_IDNO))
                             AND a.ActionTaken_DATE = @Ld_High_DATE
                          UNION ALL
                          SELECT EffectiveRun_Date,
                                 @Lc_Space_TEXT Fips_CODE,
                                 @Lc_Space_TEXT OtherFips_CODE,
                                 @Lc_Space_TEXT OutStateCase_ID,
                                 TypeError_CODE AS Error_CODE,
                                 DescriptionError_TEXT,
                                 BatchLogSeq_NUMB,
                                 @Li_Zero_NUMB TransHeader_IDNO,
                                 ISNULL(@An_Case_IDNO, @Li_Zero_NUMB) Case_IDNO,
                                 @Lc_Space_TEXT Action_CODE,
                                 @Lc_Space_TEXT Function_CODE,
                                 @Lc_Space_TEXT Reason_CODE,
                                 @Lc_BateErrorDescription_TEXT,
                                 @Lc_ErrorTypeBate_INDC ErrorType_INDC
                            FROM BATE_Y1 b
                           WHERE b.JOB_id = @Lc_JobOugoing_ID
                             AND (@An_Case_IDNO IS NULL OR (@An_Case_IDNO IS NOT NULL AND ((b.ListKey_TEXT LIKE @Lc_ListKeyCase_TEXT + ISNULL(CONVERT(VARCHAR(6), RTRIM(@An_Case_IDNO)), '') + @Lc_Percentage_TEXT)    
                             OR (b.DescriptionError_TEXT LIKE @Lc_ListKeyCase_TEXT + ISNULL(CONVERT(VARCHAR(6), RTRIM(@An_Case_IDNO)), '') + @Lc_Percentage_TEXT))))) AS X) AS Y    
           WHERE Y.ORD_ROWNUM <= @Ai_RowTo_NUMB) AS Z    
   WHERE Z.row_num >= @Ai_RowFrom_NUMB    
   ORDER BY ROW_NUM;    
 END; --End of CERR_RETRIEVE_S1   

GO
