/****** Object:  StoredProcedure [dbo].[USRL_RETRIEVE_S17]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[USRL_RETRIEVE_S17] (
 @An_Office_IDNO       NUMERIC(3),
 @Ac_SignedOnWorker_ID CHAR(30),
 @Ai_Count_QNTY        INT OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : USRL_RETRIEVE_S17
  *     DESCRIPTION       : Retrieve the Row Count for Worker Idno, Office, Minor Activity, and Role Idno thats common between two tables.
  *     DEVELOPED BY      : IMP TEAM
  *     DEVELOPED ON      : 02-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  SET @Ai_Count_QNTY = NULL;

  DECLARE @Ld_Current_DATE   DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
          @Ld_High_DATE      DATE = '12/31/9999',
          @Lc_ProcessConf_ID CHAR(4) = 'CONF';

  SELECT @Ai_Count_QNTY = COUNT(1)
    FROM USRL_Y1 A
         JOIN ACRL_Y1 B
          ON A.Role_ID = B.Role_ID
   WHERE A.Worker_ID = @Ac_SignedOnWorker_ID
     AND A.Office_IDNO = ISNULL(@An_Office_IDNO,A.Office_IDNO )
     AND B.ActivityMinor_CODE IN (SELECT R.Reason_CODE
                                    FROM RESF_Y1 R
                                   WHERE R.Process_ID = @Lc_ProcessConf_ID)
     AND A.Effective_DATE <= @Ld_Current_DATE
     AND A.Expire_DATE >= @Ld_Current_DATE
     AND A.EndValidity_DATE = @Ld_High_DATE
     AND B.EndValidity_DATE = @Ld_High_DATE;
 END; --END OF USRL_RETRIEVE_S17


GO
