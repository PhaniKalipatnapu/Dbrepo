/****** Object:  StoredProcedure [dbo].[BSTL_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[BSTL_RETRIEVE_S1] (
 @Ac_Job_ID                CHAR(7),
 @As_Process_NAME          VARCHAR(100),
 @Ad_EffectiveRunFrom_DATE DATE,
 @Ad_EffectiveRunTo_DATE   DATE,
 @Ac_Status_CODE           CHAR(1),
 @Ai_RowFrom_NUMB          INT = 1,
 @Ai_RowTo_NUMB            INT =10
 )
AS
 /*
 *     PROCEDURE NAME    : BSTL_RETRIEVE_S1
  *     DESCRIPTION       : Retrieve Batch Process Date, Job Idno with Description, Package name, Job Start Date, Job End Date, and Status Code for a Job Idno, Package Name, Status Code, and Batch Process Date.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE 
     @Ld_High_DATE     DATE = '12/31/9999',
     @Ld_Current_DATE  DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
          

  SELECT BSU.BatchLogSeq_NUMB,
         BSU.Job_ID,
         BSU.Process_NAME,
         BSU.EffectiveRun_DATE,
         BSU.Status_CODE,
         BSU.JobStart_DTTM,
         BSU.JobEnd_DTTM,
         BSU.ProcessedRecordCount_QNTY,
         (SELECT JP.DescriptionJob_TEXT
            FROM PARM_Y1 JP
           WHERE JP.Job_ID = BSU.Job_ID
             AND JP.EndValidity_DATE = @Ld_High_DATE) DescriptionJob_TEXT,
         BSU.RowCount_NUMB
    FROM (SELECT BSO.EffectiveRun_DATE,
                 BSO.Job_ID,
                 BSO.Process_NAME,
                 BSO.JobStart_DTTM,
                 BSO.JobEnd_DTTM,
                 BSO.Status_CODE,
                 BSO.RowCount_NUMB,
                 BSO.ProcessedRecordCount_QNTY,
                 BSO.BatchLogSeq_NUMB,
                 BSO.ORD_ROWNUM AS rnm
            FROM (SELECT BS.EffectiveRun_DATE,
                         BS.Job_ID,
                         BS.Process_NAME,
                         BS.JobStart_DTTM,
                         BS.JobEnd_DTTM,
                         BS.Status_CODE,
                         BS.BatchLogSeq_NUMB,
                         BS.ProcessedRecordCount_QNTY,
                         COUNT(1) OVER() AS RowCount_NUMB,
                         ROW_NUMBER() OVER( ORDER BY BS.JobStart_DTTM DESC, BS.BatchLogSeq_NUMB ASC ) AS ORD_ROWNUM
                    FROM BSTL_Y1 BS
                   WHERE BS.Job_ID = ISNULL(@Ac_Job_ID, BS.Job_ID)
                     AND BS.Process_NAME = ISNULL(@As_Process_NAME, BS.Process_NAME)
                     AND BS.Status_CODE = ISNULL(@Ac_Status_CODE, BS.Status_CODE)
                     AND BS.EffectiveRun_DATE >= @Ad_EffectiveRunFrom_DATE
                     AND BS.EffectiveRun_DATE <= ISNULL(@Ad_EffectiveRunTo_DATE, @Ld_Current_DATE)) AS BSO
           WHERE BSO.ORD_ROWNUM <= @Ai_RowTo_NUMB) BSU
   WHERE BSU.rnm >= @Ai_RowFrom_NUMB;
 END; --End of BSTL_RETRIEVE_S1

GO
