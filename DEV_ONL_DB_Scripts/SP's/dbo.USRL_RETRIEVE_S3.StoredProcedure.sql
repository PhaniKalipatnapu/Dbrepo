/****** Object:  StoredProcedure [dbo].[USRL_RETRIEVE_S3]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[USRL_RETRIEVE_S3] (
 @An_Case_IDNO                NUMERIC(6, 0),
 @An_Topic_IDNO               NUMERIC(10, 0),
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0),
 @Ac_SignedOnWorker_ID        CHAR(30),
 @Ac_Exists_INDC              CHAR(1) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : USRL_RETRIEVE_S3
  *     DESCRIPTION       : Checks Whether the log on worker is Supervisor on Originator Note.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 26-FEB-2013
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Lc_Yes_TEXT     CHAR(1) = 'Y',
          @Lc_No_TEXT      CHAR(1) = 'N',
          @Ld_High_DATE    DATE = '12/31/9999',
          @Ld_Current_DATE DATE =dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

  SET @Ac_Exists_INDC = @Lc_No_TEXT;

  SELECT TOP 1 @Ac_Exists_INDC = @Lc_Yes_TEXT
    FROM USRL_Y1 a
         JOIN USEM_Y1 b
          ON (a.Worker_ID = b.Worker_ID)
   WHERE a.Worker_ID = (SELECT WorkerCreated_ID
                          FROM NOTE_Y1
                         WHERE CASE_IDNO = @An_Case_IDNO
                           AND Topic_Idno = @An_Topic_IDNO
                           AND TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB)
     AND a.EndValidity_DATE = @Ld_High_DATE
     AND b.EndValidity_DATE = @Ld_High_DATE
     AND A.Supervisor_ID = @Ac_SignedOnWorker_ID
     AND a.Expire_DATE > @Ld_Current_DATE
     AND b.EndEmployment_DATE > @Ld_Current_DATE;
 END; -- End Of USRL_RETRIEVE_S3

GO
