/****** Object:  StoredProcedure [dbo].[USEM_RETRIEVE_S40]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[USEM_RETRIEVE_S40] (
 @Ac_Role_ID               CHAR(10),
 @Ac_Worker_ID             CHAR(30)
 )
AS
 /*
  *     PROCEDURE NAME    : USEM_RETRIEVE_S40
  *     DESCRIPTION       : Retrieve Role Workers
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 10/25/2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1.0
 */
 BEGIN
  DECLARE @Ld_High_DATE DATE = '12/31/9999',
          @Ld_Current_DATE DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

  SELECT a.Worker_ID,
         a.Last_NAME,
         a.Suffix_NAME,
         a.First_NAME,
         a.Middle_NAME
    FROM USEM_Y1 a
         JOIN USRL_Y1 b
          ON b.Worker_ID = a.Worker_ID
   WHERE b.Role_ID = @Ac_Role_ID
     AND a.Worker_ID != @Ac_Worker_ID
     AND b.Expire_DATE >= @Ld_Current_DATE
     AND b.EndValidity_DATE = @Ld_High_DATE
     AND a.EndValidity_DATE = @Ld_High_DATE
   ORDER BY a.Worker_ID,
            a.Last_NAME,
            a.Suffix_NAME,
            a.First_NAME,
            a.Middle_NAME;
 END


GO
