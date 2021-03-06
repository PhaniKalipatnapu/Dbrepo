/****** Object:  StoredProcedure [dbo].[CWRK_RETRIEVE_S26]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CWRK_RETRIEVE_S26](
 @Ac_Worker_ID   CHAR(30),
 @An_Office_IDNO NUMERIC(3) = NULL,
 @Ac_Role_ID     CHAR(10) = NULL,
 @Ai_Count_QNTY  INT OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : CWRK_RETRIEVE_S26
  *     DESCRIPTION       : Retrieve the record count for a Worker ID, Case Status is Open, Role ID 
  *							and Office Code where Case ID in Case Worker is equal to Case ID in Case details.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 10/20/2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1.0
  */
 BEGIN
  SET @Ai_Count_QNTY = 0;

  DECLARE @Lc_CaseStatusOpen_CODE	CHAR(1) = 'O',
          @Ld_High_DATE				DATE	= '12/31/9999';
  DECLARE @Ld_Current_DATE			DATE	= DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();  

  SELECT @Ai_Count_QNTY = COUNT(1)
    FROM CWRK_Y1 CW
         JOIN CASE_Y1 C
          ON CW.Case_IDNO = C.Case_IDNO
   WHERE C.StatusCase_CODE = @Lc_CaseStatusOpen_CODE
     AND CW.Worker_ID = @Ac_Worker_ID
     AND CW.Role_ID = ISNULL(@Ac_Role_ID, CW.Role_ID)
     AND CW.Office_IDNO = ISNULL(@An_Office_IDNO, CW.Office_IDNO)
     AND CW.Expire_DATE > @Ld_Current_DATE  
     AND CW.EndValidity_DATE = @Ld_High_DATE;
 END


GO
