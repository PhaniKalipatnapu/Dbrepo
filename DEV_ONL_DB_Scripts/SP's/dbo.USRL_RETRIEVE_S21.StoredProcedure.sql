/****** Object:  StoredProcedure [dbo].[USRL_RETRIEVE_S21]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[USRL_RETRIEVE_S21] (
 @An_Office_IDNO       NUMERIC(3),
 @Ac_Worker_ID         CHAR(30),
 @Ac_SignedOnWorker_ID CHAR(30),
 @Ai_Count_QNTY        INT OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : USRL_RETRIEVE_S21
  *     DESCRIPTION       : Check if a Worker Id exits for Supervisor Id, Office, Expire Date thats common between two tables.
  *     DEVELOPED BY      : IMP TEAM
  *     DEVELOPED ON      : 02-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @Ai_Count_QNTY = 0;

  DECLARE
	@Ld_Current_DATE	DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
	@Ld_High_DATE		DATE = '12/31/9999';

  SELECT TOP 1 @Ai_Count_QNTY = 1
    FROM (SELECT U.Worker_ID
            FROM USRL_Y1 U
           WHERE U.Worker_ID = @Ac_Worker_ID
             AND U.Supervisor_ID = @Ac_SignedOnWorker_ID
             AND U.Office_IDNO = ISNULL(@An_Office_IDNO, U.Office_IDNO)
             AND U.EndValidity_DATE = @Ld_High_DATE
             AND U.Effective_DATE <= @Ld_Current_DATE
             AND U.Expire_DATE >= @Ld_Current_DATE
          UNION ALL
          SELECT U1.Worker_ID
            FROM USRL_Y1 U1
           WHERE U1.Supervisor_ID IN (SELECT U2.Worker_ID
                                        FROM USRL_Y1 U2
                                       WHERE U2.EndValidity_DATE = @Ld_High_DATE
                                         AND U2.Effective_DATE <= @Ld_Current_DATE
                                         AND U2.Expire_DATE >= @Ld_Current_DATE
                                         AND U2.WorkerSub_ID = @Ac_SignedOnWorker_ID)
			 AND U1.Office_IDNO = ISNULL(@An_Office_IDNO, U1.Office_IDNO)  
             AND U1.EndValidity_DATE = @Ld_High_DATE
             AND U1.Effective_DATE <= @Ld_Current_DATE
             AND U1.Expire_DATE >= @Ld_Current_DATE
             AND U1.Worker_ID = @Ac_Worker_ID
          UNION ALL
          SELECT A.Worker_ID
            FROM ASIG_Y1 A
           WHERE A.AuthorizedDesignee_ID = @Ac_SignedOnWorker_ID
             AND A.Worker_ID = @Ac_Worker_ID
             AND A.EndValidity_DATE = @Ld_High_DATE) X;
 END

GO
