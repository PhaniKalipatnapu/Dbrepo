/****** Object:  StoredProcedure [dbo].[SLSD_RETRIEVE_S2]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SLSD_RETRIEVE_S2] (
 @An_OthpLocation_IDNO NUMERIC(9, 0),
 @Ac_TypeActivity_CODE CHAR(1)
 )
AS
 /*
  *     PROCEDURE NAME    : SLSD_RETRIEVE_S2
  *     DESCRIPTION       : populates the location availability details for the given location id.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-MAR-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ld_High_DATE      DATE = '12/31/9999',
          @Ln_Zero_TEXT      FLOAT(53) = '0',
          @Lc_Five_TEXT      CHAR(1) = '5',
          @Lc_Four_TEXT      CHAR(1) = '4',
          @Lc_Friday_TEXT    CHAR(6) = 'FRIDAY',
          @Lc_Monday_TEXT    CHAR(6) = 'MONDAY',
          @Lc_Saturday_TEXT  CHAR(8) = 'SATURDAY',
          @Lc_Seven_TEXT     CHAR(1) = '7',
          @Lc_Six_TEXT       CHAR(1) = '6',
          @Lc_Three_TEXT     CHAR(1) = '3',
          @Lc_Thursday_TEXT  CHAR(8) = 'THURSDAY',
          @Lc_Tuesday_TEXT   CHAR(7) = 'TUESDAY',
          @Lc_Two_TEXT       CHAR(1) = '2',
          @Lc_Wednesday_TEXT CHAR(9) = 'WEDNESDAY';

  SELECT x.Day_CODE,
         x.weekday AS Weekday_NAME,
         ISNULL(y.BeginWork_DTTM,'') AS BeginWork_DTTM,
         ISNULL(y.EndWork_DTTM,'') AS EndWork_DTTM,
         ISNULL(y.TypeActivity_CODE, @Ac_TypeActivity_CODE) AS TypeActivity_CODE,
         ISNULL(y.MaxLoad_QNTY, @Ln_Zero_TEXT) AS MaxLoad_QNTY,
         y.WorkerUpdate_ID,
         ISNULL(y.TransactionEventSeq_NUMB, @Ln_Zero_TEXT) AS TransactionEventSeq_NUMB
    FROM (SELECT @Lc_Two_TEXT AS Day_CODE,
                 @Lc_Monday_TEXT AS weekday
          UNION
          SELECT @Lc_Three_TEXT AS Day_CODE,
                 @Lc_Tuesday_TEXT AS weekday
          UNION
          SELECT @Lc_Four_TEXT AS Day_CODE,
                 @Lc_Wednesday_TEXT AS weekday
          UNION
          SELECT @Lc_Five_TEXT AS Day_CODE,
                 @Lc_Thursday_TEXT AS weekday
          UNION
          SELECT @Lc_Six_TEXT AS Day_CODE,
                 @Lc_Friday_TEXT AS weekday
          UNION
          SELECT @Lc_Seven_TEXT AS Day_CODE,
                 @Lc_Saturday_TEXT AS weekday) AS x
         LEFT OUTER JOIN SLSD_Y1 y
          ON x.Day_CODE = y.Day_CODE
             AND y.OthpLocation_IDNO = @An_OthpLocation_IDNO
             AND y.TypeActivity_CODE = @Ac_TypeActivity_CODE
             AND y.EndValidity_DATE = @Ld_High_DATE
   ORDER BY Day_CODE;
 END; -- END OF SLSD_RETRIEVE_S2


GO
