/****** Object:  StoredProcedure [dbo].[SLSD_INSERT_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SLSD_INSERT_S1] (
 @An_OthpLocation_IDNO        NUMERIC(9, 0),
 @Ac_Day_CODE                 CHAR(1),
 @Ac_TypeActivity_CODE        CHAR(1),
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0),
 @Ad_BeginWork_DTTM           DATETIME2,
 @Ad_EndWork_DTTM             DATETIME2,
 @Ad_BeginBreak_DTTM          DATETIME2,
 @Ad_EndBreak_DTTM            DATETIME2,
 @An_MaxLoad_QNTY             NUMERIC(3, 0),
 @Ad_EndValidity_DATE         DATE,
 @Ac_SignedOnWorker_ID        CHAR(30)
 )
AS
 /* 
  *     PROCEDURE NAME    : SLSD_INSERT_S1
  *     DESCRIPTION       : Inserts the location availability details of the location with new sequence number
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-MAR-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ld_BeginValidity_DATE DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
          @Ld_Update_DTTM        DATETIME = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

  INSERT SLSD_Y1
         (OthpLocation_IDNO,
          Day_CODE,
          TypeActivity_CODE,
          BeginWork_DTTM,
          EndWork_DTTM,
          BeginBreak_DTTM,
          EndBreak_DTTM,
          MaxLoad_QNTY,
          BeginValidity_DATE,
          EndValidity_DATE,
          WorkerUpdate_ID,
          Update_DTTM,
          TransactionEventSeq_NUMB)
  VALUES ( @An_OthpLocation_IDNO,
           @Ac_Day_CODE,
           @Ac_TypeActivity_CODE,
           @Ad_BeginWork_DTTM,
           @Ad_EndWork_DTTM,
           @Ad_BeginBreak_DTTM,
           @Ad_EndBreak_DTTM,
           @An_MaxLoad_QNTY,
           @Ld_BeginValidity_DATE,
           @Ad_EndValidity_DATE,
           @Ac_SignedOnWorker_ID,
           @Ld_Update_DTTM,
           @An_TransactionEventSeq_NUMB );
 END; -- END OF SLSD_INSERT_S1


GO
