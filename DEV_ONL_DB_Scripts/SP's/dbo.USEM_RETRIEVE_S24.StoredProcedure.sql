/****** Object:  StoredProcedure [dbo].[USEM_RETRIEVE_S24]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[USEM_RETRIEVE_S24] (
 @Ac_Worker_ID   CHAR(30),
 @Ac_First_NAME  CHAR(16) OUTPUT,
 @Ac_Middle_NAME CHAR(20) OUTPUT,
 @Ac_Last_NAME   CHAR(20) OUTPUT,
 @Ac_Suffix_NAME CHAR(4) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : USEM_RETRIEVE_S24
  *     DESCRIPTION       : Retrireve the WorkerName for the given WorkerId.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 11-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SELECT @Ac_Last_NAME = NULL,
         @Ac_Suffix_NAME = NULL,
         @Ac_First_NAME = NULL,
         @Ac_Middle_NAME = NULL;

  DECLARE @Ld_High_DATE    DATE = '12/31/9999',
          @Ld_Current_DATE DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

  SELECT @Ac_Last_NAME = U.Last_NAME,
         @Ac_Suffix_NAME = U.Suffix_NAME,
         @Ac_First_NAME = U.First_NAME,
         @Ac_Middle_NAME = U.Middle_NAME
    FROM USEM_Y1 U
   WHERE U.Worker_ID = @Ac_Worker_ID
     AND U.EndEmployment_DATE >= @Ld_Current_DATE
     AND U.BeginEmployment_DATE <= @Ld_Current_DATE
     AND U.EndValidity_DATE = @Ld_High_DATE;
 END; -- End Of USEM_RETRIEVE_S24


GO
