/****** Object:  StoredProcedure [dbo].[USRL_RETRIEVE_S56]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[USRL_RETRIEVE_S56] (
 @An_Case_IDNO  NUMERIC(6, 0),
 @Ac_Role_ID	CHAR(10),
 @Ai_Count_QNTY INT OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : USRL_RETRIEVE_S56
  *     DESCRIPTION       : Checks if record exists for the given Case and High Profile Role.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 13-OCT-2011
  *     MODIFIED BY       :   
  *     MODIFIED ON       :
  *     VERSION NO        : 1
 */
 BEGIN
  SET @Ai_Count_QNTY = NULL;

  DECLARE @Ld_Systemdate_DATE DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

  SELECT @Ai_Count_QNTY = COUNT(1)
    FROM CASE_Y1 C
         JOIN USRL_Y1 U
          ON U.Worker_ID = C.Worker_ID
             AND U.Office_IDNO = C.Office_IDNO
   WHERE C.Case_IDNO = @An_Case_IDNO
     AND U.Role_ID = @Ac_Role_ID
	 AND @Ld_Systemdate_DATE BETWEEN U.BeginValidity_DATE AND U.EndValidity_DATE;
 END; -- END OF USRL_RETRIEVE_S56


GO
