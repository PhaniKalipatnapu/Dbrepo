/****** Object:  StoredProcedure [dbo].[USRL_RETRIEVE_S9]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
  *     PROCEDURE NAME    : USRL_RETRIEVE_S9
   *     DESCRIPTION       : Retrieve Distinct Role Idno and Name for an Office, Worker Idno, and Role Idno.
   *     DEVELOPED BY      : IMP Team
   *     DEVELOPED ON      : 02-AUG-2011
   *     MODIFIED BY       : 
   *     MODIFIED ON       : 
   *     VERSION NO        : 1
  */
CREATE PROCEDURE [dbo].[USRL_RETRIEVE_S9](
 @An_Office_IDNO NUMERIC(3),
 @Ac_Worker_ID   CHAR(30) 
 )
AS
 BEGIN
  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT DISTINCT
         u.Role_ID,
         r.Role_NAME
    FROM USRL_Y1 u
         JOIN ROLE_Y1 r
          ON u.Role_ID = r.Role_ID
   WHERE u.Office_IDNO = @An_Office_IDNO
     AND u.Worker_ID = ISNULL(@Ac_Worker_ID, u.Worker_ID)
     AND u.EndValidity_DATE = @Ld_High_DATE
     AND r.EndValidity_DATE = @Ld_High_DATE
   ORDER BY r.Role_NAME;
 END


GO
