/****** Object:  StoredProcedure [dbo].[SHOL_INSERT_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SHOL_INSERT_S1] (
 @Ad_Holiday_DATE             DATE,
 @As_DescriptionHoliday_TEXT  VARCHAR(150),
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0),
 @An_OthpLocation_IDNO        NUMERIC(9, 0),
 @Ac_SignedOnWorker_ID        CHAR(30)
 )
AS
 /*
  *     PROCEDURE NAME    : SHOL_INSERT_S1
  *     DESCRIPTION       : To add a holiday in a year with holiday date and description, worker who created the holiday, updated date, and unique transaction sequence number, and Othp location id .
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-MAR-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ld_Systemdatetime_DTTM DATETIME2 = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

  INSERT SHOL_Y1
         (Holiday_DATE,
          DescriptionHoliday_TEXT,
          WorkerUpdate_ID,
          Update_DTTM,
          TransactionEventSeq_NUMB,
          OthpLocation_IDNO)
  VALUES ( @Ad_Holiday_DATE,
           @As_DescriptionHoliday_TEXT,
           @Ac_SignedOnWorker_ID,
           @Ld_Systemdatetime_DTTM,
           @An_TransactionEventSeq_NUMB,
           @An_OthpLocation_IDNO );
 END; -- END OF SHOL_INSERT_S1


GO
