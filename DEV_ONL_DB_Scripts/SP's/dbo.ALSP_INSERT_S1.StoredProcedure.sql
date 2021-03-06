/****** Object:  StoredProcedure [dbo].[ALSP_INSERT_S1]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ALSP_INSERT_S1](
 @An_Application_IDNO NUMERIC(15),
 @An_MemberMci_IDNO   NUMERIC(10),
 @An_YearMonth_NUMB   NUMERIC(6),
 @An_Owed_AMNT        NUMERIC(11, 2),
 @An_Paid_AMNT        NUMERIC(11, 2)
 )
AS
 /*
 *     PROCEDURE NAME    : ALSP_INSERT_S1
  *     DESCRIPTION       : Retrieve Member Contact details at the time of Application Received for an Application ID and Member ID.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-MAR-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  INSERT INTO ALSP_Y1
              (Application_IDNO,
               MemberMCI_IDNO,
               YearMonth_NUMB,
               Owed_AMNT,
               Paid_AMNT)
       VALUES (@An_Application_IDNO,
               @An_MemberMci_IDNO,
               @An_YearMonth_NUMB,
               @An_Owed_AMNT,
               @An_Paid_AMNT );
 END; --End of ALSP_INSERT_S1


GO
