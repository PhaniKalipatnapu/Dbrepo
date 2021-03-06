/****** Object:  StoredProcedure [dbo].[BATE_RETRIEVE_S3]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[BATE_RETRIEVE_S3] (
 @Ac_Job_ID            CHAR(7),
 @As_Process_NAME      VARCHAR(100),
 @Ad_EffectiveRun_DATE DATE,
 @Ac_TypeError_CODE    CHAR(1),
 @An_Case_IDNO         NUMERIC(6, 0),
 @Ac_Notice_ID         CHAR(8),
 @Ai_RowFrom_NUMB      INT =1,
 @Ai_RowTo_NUMB        INT =10
 )
AS
 /*
 *     PROCEDURE NAME    : BATE_RETRIEVE_S3
  *     DESCRIPTION       : Retrieve Batch Process Date, Job Idno, Package Name, Error Type, Create Date, Error Description, and Key Attributes involved in the Job for a Batch Process Date, Case Idno, Job Idno, Package Name, Error Type, Key Attributes involved in the Job, and Error Code and Description.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-AUG-2011
  *     MODIFIED BY       :
  *     MODIFIED ON       :
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ld_High_DATE       DATE = '12/31/9999',
          @Lc_ErrorE1081_CODE CHAR(5) = 'E1081',
          @Li_Zero_NUMB       SMALLINT = 0,
          @Lc_Percentage_CODE CHAR(1)= '%';

  SELECT a.Job_ID,
         a.Process_NAME,
         a.EffectiveRun_DATE,
         a.TypeError_CODE,
         a.Create_DTTM,
         a.ListKey_TEXT,
         a.DescriptionErrorBatch_TEXT,
         a.Error_CODE,
         a.DescriptionError_TEXT,
         (SELECT b.DescriptionJob_TEXT
            FROM PARM_Y1 b
           WHERE b.Job_ID = a.Job_ID
             AND b.EndValidity_DATE = @Ld_High_DATE) DescriptionJob_TEXT,
         RowCount_NUMB
    FROM (SELECT X.EffectiveRun_DATE,
                 X.Job_ID,
                 X.Process_NAME,
                 X.TypeError_CODE,
                 X.Create_DTTM,
                 X.ListKey_TEXT,
                 X.Error_CODE,
                 X.DescriptionErrorBatch_TEXT,
                 X.DescriptionError_TEXT,
                 X.ORD_ROWNUM AS rnm,
                 X.RowCount_NUMB
            FROM (SELECT BE.EffectiveRun_DATE,
                         BE.Job_ID,
                         BE.Process_NAME,
                         BE.TypeError_CODE,
                         BE.Create_DTTM,
                         BE.ListKey_TEXT,
                         BE.Error_CODE,
                         BE.DescriptionError_TEXT AS DescriptionErrorBatch_TEXT,
                         b.DescriptionError_TEXT,
                         COUNT(1) OVER() AS RowCount_NUMB,
                         ROW_NUMBER() OVER( ORDER BY BE.BatchLogSeq_NUMB DESC) AS ORD_ROWNUM
                    FROM BATE_Y1 BE
                         LEFT OUTER JOIN EMSG_Y1 b
                          ON b.Error_CODE = BE.Error_CODE
                   WHERE (BE.EffectiveRun_DATE = @Ad_EffectiveRun_DATE
                      AND BE.Error_CODE = @Lc_ErrorE1081_CODE
                      AND BE.Job_ID = ISNULL(@Ac_Job_ID, BE.Job_ID)
                      AND BE.Process_NAME = ISNULL(@As_Process_NAME, BE.Process_NAME)
                      AND BE.TypeError_CODE = ISNULL(@Ac_TypeError_CODE, BE.TypeError_CODE)
                      AND (@An_Case_IDNO IS NULL
                            OR (@An_Case_IDNO IS NOT NULL
                                AND BE.ListKey_TEXT LIKE @Lc_Percentage_CODE + ISNULL(CONVERT(VARCHAR(6), RTRIM(@An_Case_IDNO)), '') + @Lc_Percentage_CODE))
                      AND (@Ac_Notice_ID IS NULL
                            OR (@Ac_Notice_ID IS NOT NULL
                                AND BE.DescriptionError_TEXT LIKE @Lc_Percentage_CODE + ISNULL(RTRIM(@Ac_Notice_ID), '') + @Lc_Percentage_CODE)))) AS X
           WHERE X.ORD_ROWNUM <= @Ai_RowTo_NUMB
              OR (@Ai_RowFrom_NUMB = @Li_Zero_NUMB)) AS a
   WHERE a.rnm >= @Ai_RowFrom_NUMB
      OR (@Ai_RowFrom_NUMB = @Li_Zero_NUMB);
 END; --End of BATE_RETRIEVE_S3

GO
