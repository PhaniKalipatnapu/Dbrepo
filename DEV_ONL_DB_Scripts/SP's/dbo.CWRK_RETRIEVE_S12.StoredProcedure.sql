/****** Object:  StoredProcedure [dbo].[CWRK_RETRIEVE_S12]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
*     PROCEDURE NAME    : CWRK_RETRIEVE_S12
*     DESCRIPTION       : Retrieve Distinct Role Idno and Name for an Office, Case Idno, Worker Idno, and Role Idno.
*     DEVELOPED BY      : IMP Team
*     DEVELOPED ON      : 10-SEP-2011
*     MODIFIED BY       : 
*     MODIFIED ON       : 
*     VERSION NO        : 1
*/
CREATE PROCEDURE [dbo].[CWRK_RETRIEVE_S12](
 @Ac_Worker_ID   CHAR(30),
 @An_Case_IDNO   NUMERIC(6) =NULL,
 @An_Office_IDNO NUMERIC(3)
 )
AS
 BEGIN
  DECLARE @Ld_High_DATE DATE= '12/31/9999';

  SELECT DISTINCT
         cw.Role_ID,
         R.Role_NAME
    FROM CWRK_Y1 CW
         JOIN ROLE_Y1 r
          ON CW.Role_ID = r.Role_ID
   WHERE cw.Worker_ID = ISNULL(@Ac_Worker_ID, cw.Worker_ID)
     AND cw.Case_IDNO =  ISNULL(@An_Case_IDNO,cw.Case_IDNO)
     AND cw.Office_IDNO = @An_Office_IDNO
     AND cw.EndValidity_DATE = @Ld_High_DATE
     AND r.EndValidity_DATE = @Ld_High_DATE
   ORDER BY r.Role_NAME;
 END


GO
