/****** Object:  StoredProcedure [dbo].[SWKS_RETRIEVE_S52]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SWKS_RETRIEVE_S52] (
 @An_OthpLocation_IDNO NUMERIC(9, 0),
 @Ac_Worker_ID         CHAR(30),
 @Ad_Start_DATE        DATE,
 @Ad_End_DATE          DATE,
 @Ai_RowFrom_NUMB      INT =1,
 @Ai_RowTo_NUMB        INT =10
 )
AS
 /*                                                                                                                                              
  *     PROCEDURE NAME    : SWKS_RETRIEVE_S52                                                                                                     
  *     DESCRIPTION       : Retrieve the Default Lab Idno and Location Name where the Members will be Scheduled for Genetic Testing for a County.                                                                                          
  *     DEVELOPED BY      : IMP Team                                                                                                           
  *     DEVELOPED ON      : 02-MAR-2011                                                                                                          
  *     MODIFIED BY       :                                                                                                                      
  *     MODIFIED ON       :                                                                                                                      
  *     VERSION NO        : 1                                                                                                                    
 */
 BEGIN
   
   DECLARE
          @Ld_High_DATE                  DATE = '12/31/9999',
          @Lc_ApptStatusSC_CODE          CHAR(2) = 'SC',
          @Lc_ApptStatusRS_CODE          CHAR(2) = 'RS',
          @Lc_Screen_INDC                CHAR(1) = 'A';

  SELECT W.Schedule_DATE,
         W.Worker_ID,
         W.Last_NAME,  
         W.Suffix_NAME,
         W.First_NAME, 
         W.Middle_NAME,
         W.OthpLocation_IDNO,
         (SELECT OtherParty_NAME
	        FROM OTHP_Y1 O
	        WHERE O.OtherParty_IDNO = W.OthpLocation_IDNO
	        AND EndValidity_DATE = @Ld_High_DATE) AS OtherParty_NAME,
         W.BeginSch_DTTM,
         W.EndSch_DTTM,
         W.NoMaximum_QNTY,
        (SELECT COUNT(Schedule_NUMB)
         FROM SWKS_Y1
         WHERE Schedule_DATE = W.Schedule_DATE
         AND OthpLocation_IDNO = W.OthpLocation_IDNO
         AND Worker_ID = W.Worker_ID
         AND ApptStatus_CODE IN (@Lc_ApptStatusSC_CODE, @Lc_ApptStatusRS_CODE)) AS NoScheduled_QNTY,
         W.RowCount_NUMB
    FROM (SELECT Q.Schedule_DATE,
                 Q.Worker_ID,
                 Q.Last_NAME,
                 Q.Suffix_NAME,
                 Q.First_NAME,
                 Q.Middle_NAME,
                 Q.OthpLocation_IDNO,
                 Q.BeginSch_DTTM,
                 Q.EndSch_DTTM,
                 Q.NoMaximum_QNTY,
                 Q.ORD_NUMB,
                 Q.RowCount_NUMB
            FROM (SELECT E.Schedule_DATE,
                         E.Worker_ID,
                         E.Last_NAME,
                         E.Suffix_NAME,
                         E.First_NAME,
                         E.Middle_NAME,
                         E.OthpLocation_IDNO,
                         E.BeginSch_DTTM,
                         E.EndSch_DTTM,
                         E.NoMaximum_QNTY,
                         COUNT(1) OVER() RowCount_NUMB,
						 ROW_NUMBER() OVER(ORDER BY E.Schedule_DATE, E.BeginSch_DTTM ) ORD_NUMB
                    FROM (SELECT DISTINCT
                                 a.Available_DATE AS Schedule_DATE,
                                 c.Worker_ID AS Worker_ID,
                                 U.Last_NAME,
                                 U.Suffix_NAME,
                                 U.First_NAME,
                                 U.Middle_NAME,
                                 b.OthpLocation_IDNO,
                                 MIN(S1.SchdTime_DTTM) OVER(PARTITION BY c.Worker_ID, b.OthpLocation_IDNO) AS BeginSch_DTTM,
                                 MAX(S1.SchdTime_DTTM) OVER(PARTITION BY c.Worker_ID, b.OthpLocation_IDNO) AS EndSch_DTTM,
                                 b.MaxLoad_QNTY AS NoMaximum_QNTY
                            FROM (SELECT Available_DATE
                                    FROM dbo.Batch_Common$Sf_Get_Available_Schedule_Date(@An_OthpLocation_IDNO,@Ad_Start_DATE,@Ad_End_DATE,@Lc_Screen_INDC)) AS A
                                 JOIN SLSD_Y1 b
                                 ON b.Day_CODE = DATEPART(DW,a.Available_DATE)
                                 JOIN SWRK_Y1 C
                                 ON c.Day_CODE = DATEPART(DW,a.Available_DATE)
                                 JOIN USEM_Y1 U
                                 ON C.Worker_ID = U.Worker_ID
                                 JOIN STMS_Y1 S1
                                 ON S1.SchdTime_DTTM BETWEEN B.BeginWork_DTTM AND B.EndWork_DTTM
                                 JOIn STMS_Y1 S2
                                 ON S2.SchdTime_DTTM BETWEEN C.BeginWork_DTTM AND C.EndWork_DTTM
                           WHERE b.OthpLocation_IDNO = @An_OthpLocation_IDNO
                             AND S1.SchdTime_DTTM = S2.SchdTime_DTTM
                             AND b.EndValidity_DATE = @Ld_High_DATE
                             AND c.EndValidity_DATE = @Ld_High_DATE
                             AND U.EndValidity_DATE = @Ld_High_DATE
                             AND c.Worker_ID = @Ac_Worker_ID
                          ) AS E) AS Q
           WHERE ORD_NUMB <= @Ai_RowTo_NUMB)W
   WHERE ORD_NUMB >= @Ai_RowFrom_NUMB;
 END; --END OF SWKS_RETRIEVE_S52                                                                                                                                             



GO
