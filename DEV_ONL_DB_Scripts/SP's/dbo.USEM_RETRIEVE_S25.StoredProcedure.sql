/****** Object:  StoredProcedure [dbo].[USEM_RETRIEVE_S25]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[USEM_RETRIEVE_S25] (
 @Ac_Worker_ID   CHAR(30),
 @Ac_Table_ID    CHAR(4),
 @Ac_TableSub_ID CHAR(4),
 @Ac_First_NAME  CHAR(16) OUTPUT,
 @Ac_Middle_NAME CHAR(20) OUTPUT,
 @Ac_Last_NAME   CHAR(20) OUTPUT,
 @Ac_Suffix_NAME CHAR(4) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : USEM_RETRIEVE_S25
  *     DESCRIPTION       : Retrieves the user master information.
  *     DEVELOPED BY      : IMP TEAM
  *     DEVELOPED ON      : 02-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SELECT @Ac_First_NAME = NULL,
         @Ac_Middle_NAME = NULL,
         @Ac_Last_NAME = NULL,
         @Ac_Suffix_NAME = NULL;

  DECLARE @Ld_High_DATE       DATE = '12/31/9999',
          @Ld_Systemdate_DATE DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

  SELECT @Ac_Last_NAME = U.Last_NAME,
         @Ac_Suffix_NAME = U.Suffix_NAME,
         @Ac_First_NAME = U.First_NAME,
         @Ac_Middle_NAME = U.Middle_NAME
    FROM USEM_Y1 U
   WHERE U.Worker_ID = @Ac_Worker_ID
     AND U.EndValidity_DATE = @Ld_High_DATE
     AND U.EndEmployment_DATE >= @Ld_Systemdate_DATE
     AND U.BeginEmployment_DATE <= @Ld_Systemdate_DATE
     AND EXISTS (SELECT U1.Worker_ID
                   FROM USRL_Y1 U1
                  WHERE U.Worker_ID = U1.Worker_ID
                    AND U1.Expire_DATE >= @Ld_Systemdate_DATE
                    AND U1.Effective_DATE <= @Ld_Systemdate_DATE
                    AND U1.EndValidity_DATE = @Ld_High_DATE
                    AND U1.Role_ID IN (SELECT R.Value_CODE
                                         FROM REFM_Y1 R
                                        WHERE R.Table_ID = @Ac_Table_ID
                                          AND R.TableSub_ID = @Ac_TableSub_ID));
 END; --End Of USEM_RETRIEVE_S25


GO
