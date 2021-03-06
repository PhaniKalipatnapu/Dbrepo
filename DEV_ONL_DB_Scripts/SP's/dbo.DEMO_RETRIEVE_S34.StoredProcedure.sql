/****** Object:  StoredProcedure [dbo].[DEMO_RETRIEVE_S34]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DEMO_RETRIEVE_S34] (
 @An_MemberMci_IDNO  NUMERIC(10, 0),
 @Ac_Last_NAME       CHAR(20)        OUTPUT,
 @Ac_First_NAME      CHAR(16)        OUTPUT,
 @Ac_Middle_NAME     CHAR(20)        OUTPUT,
 @Ac_Suffix_NAME     CHAR(4)         OUTPUT,
 @An_MemberSsn_NUMB	 NUMERIC(9,0)	 OUTPUT,
 @Ad_Birth_DATE      DATE            OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : DEMO_RETRIEVE_S34
  *     DESCRIPTION       : Retrieves the Last Name, First Name, Middile Initial, Suffix Name and the Birth Date from the DEMO table for a Member IDNO
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 18-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SELECT @Ac_Last_NAME = NULL,
         @Ac_First_NAME = NULL,
         @Ac_Middle_NAME = NULL,
         @Ac_Suffix_NAME = NULL,
         @Ad_Birth_DATE = NULL,
         @An_MemberSsn_NUMB = NULL;

  SELECT @Ac_Last_NAME = D.Last_NAME,
         @Ac_First_NAME = D.First_NAME,
         @Ac_Middle_NAME = D.Middle_NAME,
         @Ac_Suffix_NAME = D.Suffix_NAME,
         @An_MemberSsn_NUMB = d.MemberSsn_NUMB,
         @Ad_Birth_DATE = D.Birth_DATE
    FROM DEMO_Y1 D
   WHERE D.MemberMci_IDNO = @An_MemberMci_IDNO;
 END; -- END of DEMO_RETRIEVE_S34

GO
