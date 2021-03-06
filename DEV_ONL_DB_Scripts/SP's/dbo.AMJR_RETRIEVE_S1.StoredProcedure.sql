/****** Object:  StoredProcedure [dbo].[AMJR_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[AMJR_RETRIEVE_S1] (
 @Ac_ActivityMajor_CODE CHAR(4),
 @Ac_Subsystem_CODE     CHAR(2),
 @Ai_RowFrom_NUMB       INT =1,
 @Ai_RowTo_NUMB         INT =10
 )
AS
 /*
  *     PROCEDURE NAME    : AMJR_RETRIEVE_S1
  *     DESCRIPTION       : Retrieves Activity information for the given Major Activity Code and Subsystem Code 
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 24-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ld_High_DATE              DATE = '12/31/9999',
          @Lc_ActivityMajorCase_CODE CHAR(4) = 'CASE';

  SELECT X.ActivityMajor_CODE,
         X.Subsystem_CODE,
         X.TransactionEventSeq_NUMB,
         X.ActivityMinor_CODE,
         X.DescriptionActivity_TEXT,
         X.DescriptionActivity1_TEXT,
         X.WorkerUpdate_ID,
         X.Update_DTTM,
         X.Stop_INDC,
         X.Last_NAME,
         X.Suffix_NAME,
         X.First_NAME,
         X.Middle_NAME,
         X.Row_Count AS Rowcount_NUMB
    FROM (SELECT C.ActivityMajor_CODE,
                 C.DescriptionActivity_TEXT,
                 CAST(C.ActivityMinor_CODE AS VARCHAR(100)) AS ActivityMinor_CODE,
                 A.DescriptionActivity_TEXT AS DescriptionActivity1_TEXT,
                 C.Subsystem_CODE,
                 C.Stop_INDC,
                 C.Update_DTTM,
                 C.WorkerUpdate_ID,
                 U.Last_NAME,
                 U.Suffix_NAME,
                 U.First_NAME,
                 U.Middle_NAME,
                 C.TransactionEventSeq_NUMB,
                 C.row_count,
                 C.ORD_ROWNUM
            FROM (SELECT A.ActivityMajor_CODE,
                         A.DescriptionActivity_TEXT,
                         (SELECT MIN(A2.ActivityMinor_CODE)
                            FROM ANXT_Y1 A2
                           WHERE A2.ActivityMajor_CODE = A.ActivityMajor_CODE
                             AND A2.EndValidity_DATE = @Ld_High_DATE
                             AND A2.ActivityOrder_QNTY = (SELECT MIN(A1.ActivityOrder_QNTY)
                                                            FROM ANXT_Y1 A1
                                                           WHERE A1.ActivityMajor_CODE = A2.ActivityMajor_CODE
                                                             AND A1.EndValidity_DATE = @Ld_High_DATE)) AS ActivityMinor_CODE,
                         A.Subsystem_CODE,
                         A.Stop_INDC,
                         A.Update_DTTM,
                         A.WorkerUpdate_ID,
                         A.TransactionEventSeq_NUMB,
                         COUNT(1) OVER () AS Row_Count,
                         ROW_NUMBER() OVER ( ORDER BY A.ActivityMajor_CODE ) AS ORD_ROWNUM
                    FROM AMJR_Y1 A
                   WHERE (A.Subsystem_CODE = @Ac_Subsystem_CODE
                           OR @Ac_Subsystem_CODE IS NULL)
                     AND (A.ActivityMajor_CODE = @Ac_ActivityMajor_CODE
                           OR @Ac_ActivityMajor_CODE IS NULL)
                     AND A.ActivityMajor_CODE <> @Lc_ActivityMajorCase_CODE
                     AND A.EndValidity_DATE = @Ld_High_DATE) C
                 LEFT OUTER JOIN USEM_Y1 U
                  ON U.Worker_ID = C.WorkerUpdate_ID
                     AND U.EndValidity_DATE = @Ld_High_DATE
                 LEFT OUTER JOIN AMNR_Y1 A
                  ON A.ActivityMinor_CODE = C.ActivityMinor_CODE
                     AND A.EndValidity_DATE = @Ld_High_DATE
           WHERE C.ORD_ROWNUM <= @Ai_RowTo_NUMB) X
   WHERE X.ORD_ROWNUM >= @Ai_RowFrom_NUMB;
 END; --End Of AMJR_RETRIEVE_S1

GO
