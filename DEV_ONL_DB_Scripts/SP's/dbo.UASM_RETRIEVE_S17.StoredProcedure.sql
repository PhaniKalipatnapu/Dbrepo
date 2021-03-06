/****** Object:  StoredProcedure [dbo].[UASM_RETRIEVE_S17]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[UASM_RETRIEVE_S17](
 @An_Office_IDNO         NUMERIC(3),
 @Ac_Supervisor_ID		 CHAR(30),
 @Ai_Count_QNTY          INT OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : UASM_RETRIEVE_S17
  *     DESCRIPTION       : Retrieve the record count for an Office Code & Unique ID for Each Resource in user offices 
 							and Unique ID for Each Resource in user offices is equal to Unique ID assigned for each worker in User Master.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 10/19/2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1.0
 */
 BEGIN
  SET @Ai_Count_QNTY = NULL;

  DECLARE @Ld_High_DATE DATE = '12/31/9999',
          @Ld_Current_DATE DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
  SELECT @Ai_Count_QNTY = COUNT(1)
    FROM UASM_Y1 a
         JOIN USEM_Y1 b
          ON a.Worker_ID = b.Worker_ID
   WHERE a.Office_IDNO = @An_Office_IDNO
     AND a.Worker_ID = @Ac_Supervisor_ID
	 AND a.Expire_DATE >= @Ld_Current_DATE
     AND a.EndValidity_DATE = @Ld_High_DATE
     AND b.EndValidity_DATE = @Ld_High_DATE;
 END


GO
