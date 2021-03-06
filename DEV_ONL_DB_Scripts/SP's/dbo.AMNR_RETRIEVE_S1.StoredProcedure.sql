/****** Object:  StoredProcedure [dbo].[AMNR_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[AMNR_RETRIEVE_S1] (
 @Ac_ActivityMinor_CODE CHAR(5),
 @Ai_RowFrom_NUMB       INT = 1,
 @Ai_RowTo_NUMB         INT = 10
 )
AS
 /*
  *     PROCEDURE NAME    : AMNR_RETRIEVE_S1
  *     DESCRIPTION       : Retrieves Activity information for the given Minor Activity Code 
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 10-AUG-2011
  *     MODIFIED BY       :
  *     MODIFIED ON       :
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT Y.ActivityMinor_CODE,
         Y.TransactionEventSeq_NUMB,
         Y.TypeActivity_CODE,
         Y.DescriptionActivity_TEXT,
         Y.DayToComplete_QNTY,
         Y.ActionAlert_CODE,
         Y.MemberCombinations_CODE,
         Y.TypeLocation1_CODE,
         Y.TypeLocation2_CODE,
         Y.WorkerUpdate_ID,
         Y.Update_DTTM,
         Y.First_NAME,
         Y.Middle_NAME,
         Y.Last_NAME,
         Y.Suffix_NAME,
         Y.Row_Count AS Rowcount_NUMB
    FROM (SELECT X.ActivityMinor_CODE,
                 X.DescriptionActivity_TEXT,
                 X.DayToComplete_QNTY,
                 X.ActionAlert_CODE,
                 X.TypeActivity_CODE,
                 X.TypeLocation1_CODE,
                 X.TypeLocation2_CODE,
                 X.MemberCombinations_CODE,
                 X.Update_DTTM,
                 X.WorkerUpdate_ID,
                 U.Last_NAME,
                 U.Suffix_NAME,
                 U.First_NAME,
                 U.Middle_NAME,
                 X.TransactionEventSeq_NUMB,
                 X.Row_Count,
                 X.Ord_Rownum
            FROM (SELECT A.ActivityMinor_CODE,
                         A.DescriptionActivity_TEXT,
                         A.DayToComplete_QNTY,
                         A.ActionAlert_CODE,
                         A.TypeActivity_CODE,
                         A.TypeLocation1_CODE,
                         A.TypeLocation2_CODE,
                         A.MemberCombinations_CODE,
                         A.Update_DTTM,
                         A.TransactionEventSeq_NUMB,
                         A.WorkerUpdate_ID,
                         COUNT(1) OVER () AS Row_Count,
                         ROW_NUMBER() OVER ( ORDER BY A.ActivityMinor_CODE ) AS ORD_ROWNUM
                    FROM AMNR_Y1 A
                   WHERE (A.ActivityMinor_CODE = @Ac_ActivityMinor_CODE
                           OR @Ac_ActivityMinor_CODE IS NULL)
                     AND A.EndValidity_DATE = @Ld_High_DATE) X
                 LEFT OUTER JOIN USEM_Y1 U
                  ON X.WorkerUpdate_ID = U.Worker_ID
                     AND U.EndValidity_DATE = @Ld_High_DATE
           WHERE X.ORD_ROWNUM <= @Ai_RowTo_NUMB) Y
   WHERE Y.ORD_ROWNUM >= @Ai_RowFrom_NUMB
   ORDER BY Y.ORD_ROWNUM;
 END; --End Of AMNR_RETRIEVE_S1

GO
