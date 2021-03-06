/****** Object:  StoredProcedure [dbo].[USRL_RETRIEVE_S73]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[USRL_RETRIEVE_S73] (
 @An_Office_IDNO           NUMERIC(3),
 @Ac_Role_ID               CHAR(10),
 @Ac_Worker_ID             CHAR(30),
 @Ac_FamilyViolenceRole_ID CHAR(10),
 @Ac_HighProfileRole_ID    CHAR(10),
 @Ac_WorkerExits_INDC      CHAR(1) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : USRL_RETRIEVE_S73
  *     DESCRIPTION       : Retrieve the worker name (first, last, suffix, middle) for a Unique Office Identification code, Unique Worker ID, Role 
 							to which the Resource is associated, Family Violence role code, High Profile role code where end date validity is high date, 
 							Employment End Date of the Worker and Date on which role assignment to a worker at a particular office will expire is greater 
 							than system date-time and user office roles exists for family violence and high profiles role code.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 10/21/2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1.0
  */
 BEGIN
  DECLARE @Ld_Current_DTTM DATETIME2 = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
  DECLARE @Ld_Current_DATE DATE = @Ld_Current_DTTM,
          @Lc_Yes_INDC     CHAR(1) = 'Y',
          @Lc_No_INDC      CHAR(1) = 'N',
          @Ld_High_DATE    DATE = '12/31/9999';

  SET @Ac_WorkerExits_INDC = @Lc_No_INDC;

  SELECT @Ac_WorkerExits_INDC = @Lc_Yes_INDC
    FROM USRL_Y1 a,
         USEM_Y1 b
   WHERE a.Worker_ID = @Ac_Worker_ID
     AND a.Office_IDNO = @An_Office_IDNO
     AND a.Role_ID = @Ac_Role_ID
     AND a.Worker_ID = b.Worker_ID
     AND a.EndValidity_DATE = @Ld_High_DATE
     AND b.EndValidity_DATE = @Ld_High_DATE
     AND a.Expire_DATE > @Ld_Current_DATE
     AND b.EndEmployment_DATE > @Ld_Current_DTTM
     AND EXISTS (SELECT 1
                   FROM USRL_Y1 u
                  WHERE u.Worker_ID = a.Worker_ID
                    AND u.Office_IDNO = a.Office_IDNO
                    AND u.Role_ID = ISNULL(@Ac_FamilyViolenceRole_ID, a.Role_ID)
                    AND u.Effective_DATE <= @Ld_Current_DATE
                    AND u.Expire_DATE >= @Ld_Current_DATE
                    AND u.EndValidity_DATE = @Ld_High_DATE)
     AND EXISTS (SELECT 1
                   FROM USRL_Y1 u
                  WHERE u.Worker_ID = a.Worker_ID
                    AND u.Office_IDNO = a.Office_IDNO
                    AND u.Role_ID = ISNULL(@Ac_HighProfileRole_ID, a.Role_ID)
                    AND u.Effective_DATE <= @Ld_Current_DATE
                    AND u.Expire_DATE >= @Ld_Current_DATE
                    AND u.EndValidity_DATE = @Ld_High_DATE);
 END


GO
