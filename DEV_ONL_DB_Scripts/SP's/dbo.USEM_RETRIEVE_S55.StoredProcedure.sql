/****** Object:  StoredProcedure [dbo].[USEM_RETRIEVE_S55]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[USEM_RETRIEVE_S55] (
 @An_Office_IDNO           NUMERIC(3, 0),
 @Ac_Role_ID               CHAR(10),
 @Ac_Worker_ID             CHAR(30),
 @Ac_FamilyViolenceRole_ID CHAR(10),
 @Ac_HighProfileRole_ID    CHAR(10)
 )
AS
 /*
  *     PROCEDURE NAME    : USEM_RETRIEVE_S55
  *     DESCRIPTION       : Retrieve the assigned worker id, and worker name for an Office Code, Role ID and Worker ID 
  *							is not equal to input value where end date validity is high date.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-MAR-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  DECLARE @Ld_Current_DATE DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
          @Ld_High_DATE    DATE = '12/31/9999';

  SELECT DISTINCT a.Worker_ID
    FROM USRL_Y1 a,
         USEM_Y1 b
   WHERE a.Office_IDNO = @An_Office_IDNO
     AND a.Role_ID = @Ac_Role_ID
     AND a.Worker_ID = b.Worker_ID
     AND a.Worker_ID != @Ac_Worker_ID
     AND a.EndValidity_DATE = @Ld_High_DATE
     AND b.EndValidity_DATE = @Ld_High_DATE
     AND a.Expire_DATE > DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME()
     AND b.EndEmployment_DATE > DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME()
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
                    AND u.EndValidity_DATE = @Ld_High_DATE)
   ORDER BY Worker_ID;
 END


GO
