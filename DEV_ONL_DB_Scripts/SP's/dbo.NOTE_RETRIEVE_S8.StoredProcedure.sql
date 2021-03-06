/****** Object:  StoredProcedure [dbo].[NOTE_RETRIEVE_S8]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[NOTE_RETRIEVE_S8] (
 @Ac_Subject_CODE      CHAR(5),
 @Ac_Category_CODE     CHAR(2),
 @Ac_Status_CODE       CHAR(1),
 @Ac_WorkerAssigned_ID CHAR(30),
 @Ac_WorkerCreated_ID  CHAR(30),
 @Ad_From_DATE         DATE,
 @Ad_To_DATE           DATE,
 @An_County_IDNO       NUMERIC(3, 0),
 @Ai_Count_QNTY        INT
 )
AS
 /*  
  *     PROCEDURE NAME    : NOTE_RETRIEVE_S8  
  *     DESCRIPTION       : Retrieve Notes Details and sum of each month quantity for given a subject and category,worker assigned.  
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 23-AUG-2011  
  *     MODIFIED BY       :   
  *     MODIFIED ON       :   
  *     VERSION NO        : 1  
 */
 BEGIN
  DECLARE @Ld_High_DATE             DATE = '12/31/9999',
          @Ld_Current_DTTM          DATETIME2 = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
          @Li_Zero_NUMB             SMALLINT = 0,
          @Li_One_NUMB              SMALLINT = 1,
          @Li_Three_NUMB            SMALLINT = 3,
          @Lc_StatusResolvedCs_CODE CHAR(1) = 'V',
          @Lc_StatusResolvedFm_CODE CHAR(1) = 'P',
          @Lc_ProcessConf_ID        CHAR(4) = 'CONF',
          @Lc_MonthApr_TEXT         CHAR(3) = 'APR',
          @Lc_MonthAug_TEXT         CHAR(3) = 'AUG',
          @Lc_MonthDec_TEXT         CHAR(3) = 'DEC',
          @Lc_MonthFeb_TEXT         CHAR(3) = 'FEB',
          @Lc_MonthJan_TEXT         CHAR(3) = 'JAN',
          @Lc_MonthJul_TEXT         CHAR(3) = 'JUL',
          @Lc_MonthJun_TEXT         CHAR(3) = 'JUN',
          @Lc_MonthMar_TEXT         CHAR(3) = 'MAR',
          @Lc_MonthMay_TEXT         CHAR(3) = 'MAY',
          @Lc_MonthNov_TEXT         CHAR(3) = 'NOV',
          @Lc_MonthOct_TEXT         CHAR(3) = 'OCT',
          @Lc_MonthSep_TEXT         CHAR(3) = 'SEP',
          @Li_MinusDays_NUMB        SMALLINT = -365;

  SELECT X.County_IDNO,
         (SELECT c.County_NAME
            FROM COPT_Y1 c
           WHERE c.County_IDNO = @An_County_IDNO) AS County_NAME,
         X.JanTotal_QNTY,
         X.JanTotalResolved_QNTY,
         X.JanTotalUnresolved_QNTY,
         X.JanTotalOverdue_QNTY,
         X.FebTotal_QNTY,
         X.FebTotalResolved_QNTY,
         X.FebTotalUnresolved_QNTY,
         X.FebTotalOverdue_QNTY,
         X.MarTotal_QNTY,
         X.MarTotalResolved_QNTY,
         X.MarTotalUnresolved_QNTY,
         X.MarTotalOverdue_QNTY,
         X.AprTotal_QNTY,
         X.AprTotalResolved_QNTY,
         X.AprTotalUnresolved_QNTY,
         X.AprTotalOverdue_QNTY,
         X.MayTotal_QNTY,
         X.MayTotalResolved_QNTY,
         X.MayTotalUnresolved_QNTY,
         X.MayTotalOverdue_QNTY,
         X.JunTotal_QNTY,
         X.JunTotalResolved_QNTY,
         X.JunTotalUnresolved_QNTY,
         X.JunTotalOverdue_QNTY,
         X.JulTotal_QNTY,
         X.JulTotalResolved_QNTY,
         X.JulTotalUnresolved_QNTY,
         X.JulTotalOverdue_QNTY,
         X.AugTotal_QNTY,
         X.AugTotalResolved_QNTY,
         X.AugTotalUnresolved_QNTY,
         X.AugTotalOverdue_QNTY,
         X.SepTotal_QNTY,
         X.SepTotalResolved_QNTY,
         X.SepTotalUnresolved_QNTY,
         X.SepTotalOverdue_QNTY,
         X.OctTotal_QNTY,
         X.OctTotalResolved_QNTY,
         X.OctTotalUnresolved_QNTY,
         X.OctTotalOverdue_QNTY,
         X.NovTotal_QNTY,
         X.NovTotalResolved_QNTY,
         X.NovTotalUnresolved_QNTY,
         X.NovTotalOverdue_QNTY,
         X.DecTotal_QNTY,
         X.DecTotalResolved_QNTY,
         X.DecTotalUnresolved_QNTY,
         X.DecTotalOverdue_QNTY,
         X.TotalReferrals_QNTY,
         X.TotalResolved_QNTY,
         X.TotalUnresolved_QNTY,
         X.TotalOverdue_QNTY
    FROM (SELECT o.County_IDNO,
                 SUM(CASE
                      WHEN SUBSTRING(DATENAME(MM, n.Start_DATE), @Li_One_NUMB, @Li_Three_NUMB) = @Lc_MonthJan_TEXT
                       THEN @Li_One_NUMB
                      ELSE @Li_Zero_NUMB
                     END) AS JanTotal_QNTY,
                 SUM(CASE
                      WHEN SUBSTRING(DATENAME(MM, n.Start_DATE), @Li_One_NUMB, @Li_Three_NUMB) = @Lc_MonthJan_TEXT
                           AND n.Status_CODE IN (@Lc_StatusResolvedCs_CODE, @Lc_StatusResolvedFm_CODE)
                       THEN @Li_One_NUMB
                      ELSE @Li_Zero_NUMB
                     END) AS JanTotalResolved_QNTY,
                 SUM(CASE
                      WHEN SUBSTRING(DATENAME(MM, n.Start_DATE), @Li_One_NUMB, @Li_Three_NUMB) = @Lc_MonthJan_TEXT
                           AND n.Status_CODE NOT IN (@Lc_StatusResolvedCs_CODE, @Lc_StatusResolvedFm_CODE)
                       THEN @Li_One_NUMB
                      ELSE @Li_Zero_NUMB
                     END) AS JanTotalUnresolved_QNTY,
                 SUM(CASE
                      WHEN SUBSTRING(DATENAME(MM, n.Start_DATE), @Li_One_NUMB, @Li_Three_NUMB) = @Lc_MonthJan_TEXT
                           AND n.Status_CODE NOT IN (@Lc_StatusResolvedCs_CODE, @Lc_StatusResolvedFm_CODE)
                           AND n.Due_DATE < @Ld_Current_DTTM
                       THEN @Li_One_NUMB
                      ELSE @Li_Zero_NUMB
                     END) AS JanTotalOverdue_QNTY,
                 SUM(CASE
                      WHEN SUBSTRING(DATENAME(MM, n.Start_DATE), @Li_One_NUMB, @Li_Three_NUMB) = @Lc_MonthFeb_TEXT
                       THEN @Li_One_NUMB
                      ELSE @Li_Zero_NUMB
                     END) AS FebTotal_QNTY,
                 SUM(CASE
                      WHEN SUBSTRING(DATENAME(MM, n.Start_DATE), @Li_One_NUMB, @Li_Three_NUMB) = @Lc_MonthFeb_TEXT
                           AND n.Status_CODE IN (@Lc_StatusResolvedCs_CODE, @Lc_StatusResolvedFm_CODE)
                       THEN @Li_One_NUMB
                      ELSE @Li_Zero_NUMB
                     END) AS FebTotalResolved_QNTY,
                 SUM(CASE
                      WHEN SUBSTRING(DATENAME(MM, n.Start_DATE), @Li_One_NUMB, @Li_Three_NUMB) = @Lc_MonthFeb_TEXT
                           AND n.Status_CODE NOT IN (@Lc_StatusResolvedCs_CODE, @Lc_StatusResolvedFm_CODE)
                       THEN @Li_One_NUMB
                      ELSE @Li_Zero_NUMB
                     END) AS FebTotalUnresolved_QNTY,
                 SUM(CASE
                      WHEN SUBSTRING(DATENAME(MM, n.Start_DATE), @Li_One_NUMB, @Li_Three_NUMB) = @Lc_MonthFeb_TEXT
                           AND n.Status_CODE NOT IN (@Lc_StatusResolvedCs_CODE, @Lc_StatusResolvedFm_CODE)
                           AND n.Due_DATE < @Ld_Current_DTTM
                       THEN @Li_One_NUMB
                      ELSE @Li_Zero_NUMB
                     END) AS FebTotalOverdue_QNTY,
                 SUM(CASE
                      WHEN SUBSTRING(DATENAME(MM, n.Start_DATE), @Li_One_NUMB, @Li_Three_NUMB) = @Lc_MonthMar_TEXT
                       THEN @Li_One_NUMB
                      ELSE @Li_Zero_NUMB
                     END) AS MarTotal_QNTY,
                 SUM(CASE
                      WHEN SUBSTRING(DATENAME(MM, n.Start_DATE), @Li_One_NUMB, @Li_Three_NUMB) = @Lc_MonthMar_TEXT
                           AND n.Status_CODE IN (@Lc_StatusResolvedCs_CODE, @Lc_StatusResolvedFm_CODE)
                       THEN @Li_One_NUMB
                      ELSE @Li_Zero_NUMB
                     END) AS MarTotalResolved_QNTY,
                 SUM(CASE
                      WHEN SUBSTRING(DATENAME(MM, n.Start_DATE), @Li_One_NUMB, 3) = @Lc_MonthMar_TEXT
                           AND n.Status_CODE NOT IN (@Lc_StatusResolvedCs_CODE, @Lc_StatusResolvedFm_CODE)
                       THEN @Li_One_NUMB
                      ELSE @Li_Zero_NUMB
                     END) AS MarTotalUnresolved_QNTY,
                 SUM(CASE
                      WHEN SUBSTRING(DATENAME(MM, n.Start_DATE), @Li_One_NUMB, @Li_Three_NUMB) = @Lc_MonthMar_TEXT
                           AND n.Status_CODE NOT IN (@Lc_StatusResolvedCs_CODE, @Lc_StatusResolvedFm_CODE)
                           AND n.Due_DATE < @Ld_Current_DTTM
                       THEN @Li_One_NUMB
                      ELSE @Li_Zero_NUMB
                     END) AS MarTotalOverdue_QNTY,
                 SUM(CASE
                      WHEN SUBSTRING(DATENAME(MM, n.Start_DATE), @Li_One_NUMB, @Li_Three_NUMB) = @Lc_MonthApr_TEXT
                       THEN @Li_One_NUMB
                      ELSE @Li_Zero_NUMB
                     END) AS AprTotal_QNTY,
                 SUM(CASE
                      WHEN SUBSTRING(DATENAME(MM, n.Start_DATE), @Li_One_NUMB, @Li_Three_NUMB) = @Lc_MonthApr_TEXT
                           AND n.Status_CODE IN (@Lc_StatusResolvedCs_CODE, @Lc_StatusResolvedFm_CODE)
                       THEN @Li_One_NUMB
                      ELSE @Li_Zero_NUMB
                     END) AS AprTotalResolved_QNTY,
                 SUM(CASE
                      WHEN SUBSTRING(DATENAME(MM, n.Start_DATE), @Li_One_NUMB, @Li_Three_NUMB) = @Lc_MonthApr_TEXT
                           AND n.Status_CODE NOT IN (@Lc_StatusResolvedCs_CODE, @Lc_StatusResolvedFm_CODE)
                       THEN @Li_One_NUMB
                      ELSE @Li_Zero_NUMB
                     END) AS AprTotalUnresolved_QNTY,
                 SUM(CASE
                      WHEN SUBSTRING(DATENAME(MM, n.Start_DATE), @Li_One_NUMB, @Li_Three_NUMB) = @Lc_MonthApr_TEXT
                           AND n.Status_CODE NOT IN (@Lc_StatusResolvedCs_CODE, @Lc_StatusResolvedFm_CODE)
                           AND n.Due_DATE < @Ld_Current_DTTM
                       THEN @Li_One_NUMB
                      ELSE @Li_Zero_NUMB
                     END) AS AprTotalOverdue_QNTY,
                 SUM(CASE
                      WHEN SUBSTRING(DATENAME(MM, n.Start_DATE), @Li_One_NUMB, @Li_Three_NUMB) = @Lc_MonthMay_TEXT
                       THEN @Li_One_NUMB
                      ELSE @Li_Zero_NUMB
                     END) AS MayTotal_QNTY,
                 SUM(CASE
                      WHEN SUBSTRING(DATENAME(MM, n.Start_DATE), @Li_One_NUMB, @Li_Three_NUMB) = @Lc_MonthMay_TEXT
                           AND n.Status_CODE IN (@Lc_StatusResolvedCs_CODE, @Lc_StatusResolvedFm_CODE)
                       THEN @Li_One_NUMB
                      ELSE @Li_Zero_NUMB
                     END) AS MayTotalResolved_QNTY,
                 SUM(CASE
                      WHEN SUBSTRING(DATENAME(MM, n.Start_DATE), @Li_One_NUMB, @Li_Three_NUMB) = @Lc_MonthMay_TEXT
                           AND n.Status_CODE NOT IN (@Lc_StatusResolvedCs_CODE, @Lc_StatusResolvedFm_CODE)
                       THEN @Li_One_NUMB
                      ELSE @Li_Zero_NUMB
                     END) AS MayTotalUnresolved_QNTY,
                 SUM(CASE
                      WHEN SUBSTRING(DATENAME(MM, n.Start_DATE), @Li_One_NUMB, @Li_Three_NUMB) = @Lc_MonthMay_TEXT
                           AND n.Status_CODE NOT IN (@Lc_StatusResolvedCs_CODE, @Lc_StatusResolvedFm_CODE)
                           AND n.Due_DATE < @Ld_Current_DTTM
                       THEN @Li_One_NUMB
                      ELSE @Li_Zero_NUMB
                     END) AS MayTotalOverdue_QNTY,
                 SUM(CASE
                      WHEN SUBSTRING(DATENAME(MM, n.Start_DATE), @Li_One_NUMB, @Li_Three_NUMB) = @Lc_MonthJun_TEXT
                       THEN @Li_One_NUMB
                      ELSE @Li_Zero_NUMB
                     END) AS JunTotal_QNTY,
                 SUM(CASE
                      WHEN SUBSTRING(DATENAME(MM, n.Start_DATE), @Li_One_NUMB, @Li_Three_NUMB) = @Lc_MonthJun_TEXT
                           AND n.Status_CODE IN (@Lc_StatusResolvedCs_CODE, @Lc_StatusResolvedFm_CODE)
                       THEN 1
                      ELSE @Li_Zero_NUMB
                     END) AS JunTotalResolved_QNTY,
                 SUM(CASE
                      WHEN SUBSTRING(DATENAME(MM, n.Start_DATE), @Li_One_NUMB, @Li_Three_NUMB) = @Lc_MonthJun_TEXT
                           AND n.Status_CODE NOT IN (@Lc_StatusResolvedCs_CODE, @Lc_StatusResolvedFm_CODE)
                       THEN 1
                      ELSE @Li_Zero_NUMB
                     END) AS JunTotalUnresolved_QNTY,
                 SUM(CASE
                      WHEN SUBSTRING(DATENAME(MM, n.Start_DATE), @Li_One_NUMB, @Li_Three_NUMB) = @Lc_MonthJun_TEXT
                           AND n.Status_CODE NOT IN (@Lc_StatusResolvedCs_CODE, @Lc_StatusResolvedFm_CODE)
                           AND n.Due_DATE < @Ld_Current_DTTM
                       THEN 1
                      ELSE @Li_Zero_NUMB
                     END) AS JunTotalOverdue_QNTY,
                 SUM(CASE
                      WHEN SUBSTRING(DATENAME(MM, n.Start_DATE), @Li_One_NUMB, @Li_Three_NUMB) = @Lc_MonthJul_TEXT
                       THEN @Li_One_NUMB
                      ELSE @Li_Zero_NUMB
                     END) AS JulTotal_QNTY,
                 SUM(CASE
                      WHEN SUBSTRING(DATENAME(MM, n.Start_DATE), @Li_One_NUMB, @Li_Three_NUMB) = @Lc_MonthJul_TEXT
                           AND n.Status_CODE IN (@Lc_StatusResolvedCs_CODE, @Lc_StatusResolvedFm_CODE)
                       THEN 1
                      ELSE @Li_Zero_NUMB
                     END) AS JulTotalResolved_QNTY,
                 SUM(CASE
                      WHEN SUBSTRING(DATENAME(MM, n.Start_DATE), @Li_One_NUMB, @Li_Three_NUMB) = @Lc_MonthJul_TEXT
                           AND n.Status_CODE NOT IN (@Lc_StatusResolvedCs_CODE, @Lc_StatusResolvedFm_CODE)
                       THEN 1
                      ELSE @Li_Zero_NUMB
                     END) AS JulTotalUnresolved_QNTY,
                 SUM(CASE
                      WHEN SUBSTRING(DATENAME(MM, n.Start_DATE), @Li_One_NUMB, @Li_Three_NUMB) = @Lc_MonthJul_TEXT
                           AND n.Status_CODE NOT IN (@Lc_StatusResolvedCs_CODE, @Lc_StatusResolvedFm_CODE)
                           AND n.Due_DATE < @Ld_Current_DTTM
                       THEN 1
                      ELSE @Li_Zero_NUMB
                     END) AS JulTotalOverdue_QNTY,
                 SUM(CASE
                      WHEN SUBSTRING(DATENAME(MM, n.Start_DATE), @Li_One_NUMB, @Li_Three_NUMB) = @Lc_MonthAug_TEXT
                       THEN @Li_One_NUMB
                      ELSE @Li_Zero_NUMB
                     END) AS AugTotal_QNTY,
                 SUM(CASE
                      WHEN SUBSTRING(DATENAME(MM, n.Start_DATE), @Li_One_NUMB, @Li_Three_NUMB) = @Lc_MonthAug_TEXT
                           AND n.Status_CODE IN (@Lc_StatusResolvedCs_CODE, @Lc_StatusResolvedFm_CODE)
                       THEN @Li_One_NUMB
                      ELSE @Li_Zero_NUMB
                     END) AS AugTotalResolved_QNTY,
                 SUM(CASE
                      WHEN SUBSTRING(DATENAME(MM, n.Start_DATE), @Li_One_NUMB, @Li_Three_NUMB) = @Lc_MonthAug_TEXT
                           AND n.Status_CODE NOT IN (@Lc_StatusResolvedCs_CODE, @Lc_StatusResolvedFm_CODE)
                       THEN @Li_One_NUMB
                      ELSE @Li_Zero_NUMB
                     END) AS AugTotalUnresolved_QNTY,
                 SUM(CASE
                      WHEN SUBSTRING(DATENAME(MM, n.Start_DATE), @Li_One_NUMB, @Li_Three_NUMB) = @Lc_MonthAug_TEXT
                           AND n.Status_CODE NOT IN (@Lc_StatusResolvedCs_CODE, @Lc_StatusResolvedFm_CODE)
                           AND n.Due_DATE < @Ld_Current_DTTM
                       THEN @Li_One_NUMB
                      ELSE @Li_Zero_NUMB
                     END) AS AugTotalOverdue_QNTY,
                 SUM(CASE
                      WHEN SUBSTRING(DATENAME(MM, n.Start_DATE), @Li_One_NUMB, @Li_Three_NUMB) = @Lc_MonthSep_TEXT
                       THEN @Li_One_NUMB
                      ELSE @Li_Zero_NUMB
                     END) AS SepTotal_QNTY,
                 SUM(CASE
                      WHEN SUBSTRING(DATENAME(MM, n.Start_DATE), @Li_One_NUMB, @Li_Three_NUMB) = @Lc_MonthSep_TEXT
                           AND n.Status_CODE IN (@Lc_StatusResolvedCs_CODE, @Lc_StatusResolvedFm_CODE)
                       THEN @Li_One_NUMB
                      ELSE @Li_Zero_NUMB
                     END) AS SepTotalResolved_QNTY,
                 SUM(CASE
                      WHEN SUBSTRING(DATENAME(MM, n.Start_DATE), @Li_One_NUMB, @Li_Three_NUMB) = @Lc_MonthSep_TEXT
                           AND n.Status_CODE NOT IN (@Lc_StatusResolvedCs_CODE, @Lc_StatusResolvedFm_CODE)
                       THEN @Li_One_NUMB
                      ELSE @Li_Zero_NUMB
                     END) AS SepTotalUnresolved_QNTY,
                 SUM(CASE
                      WHEN SUBSTRING(DATENAME(MM, n.Start_DATE), @Li_One_NUMB, @Li_Three_NUMB) = @Lc_MonthSep_TEXT
                           AND n.Status_CODE NOT IN (@Lc_StatusResolvedCs_CODE, @Lc_StatusResolvedFm_CODE)
                           AND n.Due_DATE < @Ld_Current_DTTM
                       THEN @Li_One_NUMB
                      ELSE @Li_Zero_NUMB
                     END) AS SepTotalOverdue_QNTY,
                 SUM(CASE
                      WHEN SUBSTRING(DATENAME(MM, n.Start_DATE), @Li_One_NUMB, @Li_Three_NUMB) = @Lc_MonthOct_TEXT
                       THEN @Li_One_NUMB
                      ELSE @Li_Zero_NUMB
                     END) AS OctTotal_QNTY,
                 SUM(CASE
                      WHEN SUBSTRING(DATENAME(MM, n.Start_DATE), @Li_One_NUMB, @Li_Three_NUMB) = @Lc_MonthOct_TEXT
                           AND n.Status_CODE IN (@Lc_StatusResolvedCs_CODE, @Lc_StatusResolvedFm_CODE)
                       THEN @Li_One_NUMB
                      ELSE @Li_Zero_NUMB
                     END) AS OctTotalResolved_QNTY,
                 SUM(CASE
                      WHEN SUBSTRING(DATENAME(MM, n.Start_DATE), @Li_One_NUMB, @Li_Three_NUMB) = @Lc_MonthOct_TEXT
                           AND n.Status_CODE NOT IN (@Lc_StatusResolvedCs_CODE, @Lc_StatusResolvedFm_CODE)
                       THEN @Li_One_NUMB
                      ELSE @Li_Zero_NUMB
                     END) AS OctTotalUnresolved_QNTY,
                 SUM(CASE
                      WHEN SUBSTRING(DATENAME(MM, n.Start_DATE), @Li_One_NUMB, @Li_Three_NUMB) = @Lc_MonthOct_TEXT
                           AND n.Status_CODE NOT IN (@Lc_StatusResolvedCs_CODE, @Lc_StatusResolvedFm_CODE)
                           AND n.Due_DATE < @Ld_Current_DTTM
                       THEN @Li_One_NUMB
                      ELSE @Li_Zero_NUMB
                     END) AS OctTotalOverdue_QNTY,
                 SUM(CASE
                      WHEN SUBSTRING(DATENAME(MM, n.Start_DATE), @Li_One_NUMB, @Li_Three_NUMB) = @Lc_MonthNov_TEXT
                       THEN @Li_One_NUMB
                      ELSE @Li_Zero_NUMB
                     END) AS NovTotal_QNTY,
                 SUM(CASE
                      WHEN SUBSTRING(DATENAME(MM, n.Start_DATE), @Li_One_NUMB, @Li_Three_NUMB) = @Lc_MonthNov_TEXT
                           AND n.Status_CODE IN (@Lc_StatusResolvedCs_CODE, @Lc_StatusResolvedFm_CODE)
                       THEN @Li_One_NUMB
                      ELSE @Li_Zero_NUMB
                     END) AS NovTotalResolved_QNTY,
                 SUM(CASE
                      WHEN SUBSTRING(DATENAME(MM, n.Start_DATE), @Li_One_NUMB, @Li_Three_NUMB) = @Lc_MonthNov_TEXT
                           AND n.Status_CODE NOT IN (@Lc_StatusResolvedCs_CODE, @Lc_StatusResolvedFm_CODE)
                       THEN @Li_One_NUMB
                      ELSE @Li_Zero_NUMB
                     END) AS NovTotalUnresolved_QNTY,
                 SUM(CASE
                      WHEN SUBSTRING(DATENAME(MM, n.Start_DATE), @Li_One_NUMB, @Li_Three_NUMB) = @Lc_MonthNov_TEXT
                           AND n.Status_CODE NOT IN (@Lc_StatusResolvedCs_CODE, @Lc_StatusResolvedFm_CODE)
                           AND n.Due_DATE < @Ld_Current_DTTM
                       THEN @Li_One_NUMB
                      ELSE @Li_Zero_NUMB
                     END) AS NovTotalOverdue_QNTY,
                 SUM(CASE
                      WHEN SUBSTRING(DATENAME(MM, n.Start_DATE), @Li_One_NUMB, @Li_Three_NUMB) = @Lc_MonthDec_TEXT
                       THEN @Li_One_NUMB
                      ELSE @Li_Zero_NUMB
                     END) AS DecTotal_QNTY,
                 SUM(CASE
                      WHEN SUBSTRING(DATENAME(MM, n.Start_DATE), @Li_One_NUMB, @Li_Three_NUMB) = @Lc_MonthDec_TEXT
                           AND n.Status_CODE IN (@Lc_StatusResolvedCs_CODE, @Lc_StatusResolvedFm_CODE)
                       THEN @Li_One_NUMB
                      ELSE @Li_Zero_NUMB
                     END) AS DecTotalResolved_QNTY,
                 SUM(CASE
                      WHEN SUBSTRING(DATENAME(MM, n.Start_DATE), @Li_One_NUMB, @Li_Three_NUMB) = @Lc_MonthDec_TEXT
                           AND n.Status_CODE NOT IN (@Lc_StatusResolvedCs_CODE, @Lc_StatusResolvedFm_CODE)
                       THEN @Li_One_NUMB
                      ELSE @Li_Zero_NUMB
                     END) AS DecTotalUnresolved_QNTY,
                 SUM(CASE
                      WHEN SUBSTRING(DATENAME(MM, n.Start_DATE), @Li_One_NUMB, @Li_Three_NUMB) = @Lc_MonthDec_TEXT
                           AND n.Status_CODE NOT IN (@Lc_StatusResolvedCs_CODE, @Lc_StatusResolvedFm_CODE)
                           AND n.Due_DATE < @Ld_Current_DTTM
                       THEN @Li_One_NUMB
                      ELSE @Li_Zero_NUMB
                     END) AS DecTotalOverdue_QNTY,
                 SUM(1) AS TotalReferrals_QNTY,
                 SUM(CASE
                      WHEN n.Status_CODE IN (@Lc_StatusResolvedCs_CODE, @Lc_StatusResolvedFm_CODE)
                       THEN @Li_One_NUMB
                      ELSE @Li_Zero_NUMB
                     END) AS TotalResolved_QNTY,
                 SUM(CASE
                      WHEN n.Status_CODE NOT IN (@Lc_StatusResolvedCs_CODE, @Lc_StatusResolvedFm_CODE)
                       THEN @Li_One_NUMB
                      ELSE @Li_Zero_NUMB
                     END) AS TotalUnresolved_QNTY,
                 SUM(CASE
                      WHEN n.Status_CODE NOT IN (@Lc_StatusResolvedCs_CODE, @Lc_StatusResolvedFm_CODE)
                           AND n.Due_DATE < @Ld_Current_DTTM
                       THEN @Li_One_NUMB
                      ELSE @Li_Zero_NUMB
                     END) AS TotalOverdue_QNTY
            FROM NOTE_Y1 n
                 JOIN OFIC_Y1 o
                  ON o.Office_IDNO = n.Office_IDNO
           WHERE n.Post_IDNO = (SELECT MAX(b.Post_IDNO)
                                  FROM NOTE_Y1 b
                                 WHERE n.Topic_IDNO = b.Topic_IDNO
                                   AND n.Case_IDNO = b.Case_IDNO
                                   AND b.EndValidity_DATE = @Ld_High_DATE)
             AND (@Ai_Count_QNTY > @Li_Zero_NUMB
                   OR (@Ai_Count_QNTY = @Li_Zero_NUMB
                       AND n.Subject_CODE NOT IN (SELECT r.Reason_CODE
                                                    FROM RESF_Y1 r
                                                   WHERE r.Process_ID = @Lc_ProcessConf_ID)))
             AND o.County_IDNO =ISNULL(@An_County_IDNO,o.County_IDNO)
             AND n.WorkerCreated_ID = ISNULL(@Ac_WorkerCreated_ID, n.WorkerCreated_ID)
             AND n.WorkerAssigned_ID = ISNULL(@Ac_WorkerAssigned_ID, n.WorkerAssigned_ID)
             AND n.Subject_CODE = ISNULL(@Ac_Subject_CODE, n.Subject_CODE)
             AND n.Category_CODE = ISNULL(@Ac_Category_CODE, n.Category_CODE)
             AND n.Status_CODE = ISNULL(@Ac_Status_CODE, n.Status_CODE)
             AND n.Start_DATE BETWEEN ISNULL(@Ad_From_DATE, DATEADD(D, @Li_MinusDays_NUMB, @Ld_Current_DTTM)) AND ISNULL(@Ad_To_DATE, @Ld_Current_DTTM)
             AND o.EndValidity_DATE = @Ld_High_DATE
           GROUP BY o.County_IDNO) X
   ORDER BY County_IDNO;
 END; -- END OF NOTE_RETRIEVE_S8


GO
