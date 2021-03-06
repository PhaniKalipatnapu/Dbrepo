/****** Object:  StoredProcedure [dbo].[SLSD_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SLSD_RETRIEVE_S1] (
 @An_OthpLocation_IDNO NUMERIC(9, 0),
 @Ac_TypeActivity_CODE CHAR(1)
 )
AS
 /*
  *     PROCEDURE NAME    : SLSD_RETRIEVE_S1
  *     DESCRIPTION       : Retrieves the records of the location availability details such as weekday, start time, and end time availability of the worker.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-MAR-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT S.Day_CODE,
         S.BeginWork_DTTM,
         S.EndWork_DTTM,
         S.TypeActivity_CODE,
         S.MaxLoad_QNTY,
         S.WorkerUpdate_ID,
         S.TransactionEventSeq_NUMB
    FROM SLSD_Y1 S
   WHERE S.OthpLocation_IDNO = @An_OthpLocation_IDNO
     AND S.TypeActivity_CODE = @Ac_TypeActivity_CODE
     AND S.EndValidity_DATE = @Ld_High_DATE
   ORDER BY Day_CODE;
 END; --END OF SLSD_RETRIEVE_S1

GO
