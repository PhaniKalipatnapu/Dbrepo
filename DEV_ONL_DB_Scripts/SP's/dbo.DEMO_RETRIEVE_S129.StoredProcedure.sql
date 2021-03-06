/****** Object:  StoredProcedure [dbo].[DEMO_RETRIEVE_S129]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DEMO_RETRIEVE_S129] (
 @An_CaseWelfare_IDNO NUMERIC(10, 0),
 @Ac_Last_NAME        CHAR(20) OUTPUT,
 @Ac_First_NAME       CHAR(15) OUTPUT,
 @Ac_Middle_NAME      CHAR(20) OUTPUT,
 @An_MemberSsn_NUMB   NUMERIC(9, 0) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : DEMO_RETRIEVE_S129
  *     DESCRIPTION       : Retrieve the name and ssn for given welfare id.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 20-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SELECT @Ac_Last_NAME = NULL,
         @Ac_First_NAME = NULL,
         @Ac_Middle_NAME = NULL,
         @An_MemberSsn_NUMB = NULL;

  DECLARE @Lc_WelfareTypeIveFosterCare_TEXT        CHAR(1) = 'F',
          @Lc_WelfareTypeNonFederalFosterCare_TEXT CHAR(1) = 'J';

  SELECT @Ac_Last_NAME = D.Last_NAME,
         @Ac_First_NAME = D.First_NAME,
         @Ac_Middle_NAME = D.Middle_NAME,
         @An_MemberSsn_NUMB = D.MemberSsn_NUMB
    FROM DEMO_Y1 D
         JOIN MHIS_Y1 M
          ON D.MemberMci_IDNO = M.MemberMci_IDNO
   WHERE M.CaseWelfare_IDNO = @An_CaseWelfare_IDNO
     AND M.TypeWelfare_CODE IN (@Lc_WelfareTypeIveFosterCare_TEXT, @Lc_WelfareTypeNonFederalFosterCare_TEXT);
 END -- END of DEMO_RETRIEVE_S129      


GO
