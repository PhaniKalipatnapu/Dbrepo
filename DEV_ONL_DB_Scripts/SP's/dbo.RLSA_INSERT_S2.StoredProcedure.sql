/****** Object:  StoredProcedure [dbo].[RLSA_INSERT_S2]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RLSA_INSERT_S2](
 @Ac_Role_ID                  CHAR(10),
 @Ac_RoleLike_ID              CHAR(10),
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0),
 @Ac_SignedOnWorker_ID        CHAR(30)
 )
AS
 /*
 *     PROCEDURE NAME    :  RLSA_INSERT_S1
  *     DESCRIPTION       : Insert details into Role Screen Access Reference table.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 10/12/2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ld_Systemdatetime_DTTM DATETIME2 = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
  DECLARE @Ld_Current_DATE DATE = @Ld_Systemdatetime_DTTM;
  DECLARE @Ld_High_DATE DATE ='12/31/9999';

  INSERT INTO RLSA_Y1
              (Screen_ID,
               Role_ID,
               ScreenFunction_CODE,
               Access_INDC,
               BeginValidity_DATE,
               EndValidity_DATE,
               TransactionEventSeq_NUMB,
               Update_DTTM,
               WorkerUpdate_ID)
  (SELECT R.Screen_ID,
          @Ac_Role_ID AS Role_ID,
          R.ScreenFunction_CODE,
          R.Access_INDC,
          @Ld_Current_DATE AS BeginValidity_DATE,
          @Ld_High_DATE AS EndValidity_DATE,
          @An_TransactionEventSeq_NUMB AS TransactionEventSeq_NUMB,
          @Ld_Systemdatetime_DTTM AS Update_DTTM,
          @Ac_SignedOnWorker_ID AS WorkerUpdate_ID
     FROM RLSA_Y1 R
    WHERE R.Role_ID = @Ac_RoleLike_ID
      AND R.Screen_ID NOT IN (SELECT RS.Screen_ID
                                FROM RLSA_Y1 RS
                               WHERE RS.Role_ID = @Ac_Role_ID)
      AND R.EndValidity_DATE = @Ld_High_DATE);
 END


GO
